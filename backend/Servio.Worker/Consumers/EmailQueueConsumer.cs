using System.Text.Json;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using Servio.Model.Configuration;
using Servio.Model.Messages;
using Servio.Worker.Email;

namespace Servio.Worker.Consumers;

/// <summary>
/// Listens on the email queue and sends each message over SMTP.
/// Failed sends are retried with exponential backoff before the message is rejected.
/// </summary>
public class EmailQueueConsumer(
    IOptions<RabbitMqOptions> options,
    IEmailSender emailSender,
    ILogger<EmailQueueConsumer> logger) : BackgroundService
{
    private static readonly TimeSpan[] RetryDelays =
        [TimeSpan.FromSeconds(1), TimeSpan.FromSeconds(2), TimeSpan.FromSeconds(4), TimeSpan.FromSeconds(8)];

    private static readonly TimeSpan ReconnectDelay = TimeSpan.FromSeconds(5);

    private readonly RabbitMqOptions _options = options.Value;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ConsumeAsync(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Lost connection to RabbitMQ at {Host}:{Port}, reconnecting in {Delay}",
                    _options.Host, _options.Port, ReconnectDelay);
                await Task.Delay(ReconnectDelay, stoppingToken);
            }
        }
    }

    private async Task ConsumeAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _options.Host,
            Port = _options.Port,
            UserName = _options.Username,
            Password = _options.Password
        };

        await using var connection = await factory.CreateConnectionAsync(stoppingToken);
        await using var channel = await connection.CreateChannelAsync(cancellationToken: stoppingToken);

        await channel.QueueDeclareAsync(_options.EmailQueue, durable: true, exclusive: false, autoDelete: false,
            cancellationToken: stoppingToken);
        await channel.BasicQosAsync(prefetchSize: 0, prefetchCount: 1, global: false, cancellationToken: stoppingToken);

        var consumer = new AsyncEventingBasicConsumer(channel);
        consumer.ReceivedAsync += async (_, args) =>
        {
            var handled = await HandleAsync(args.Body, stoppingToken);
            if (handled)
            {
                await channel.BasicAckAsync(args.DeliveryTag, multiple: false, stoppingToken);
            }
            else
            {
                await channel.BasicRejectAsync(args.DeliveryTag, requeue: false, stoppingToken);
            }
        };

        await channel.BasicConsumeAsync(_options.EmailQueue, autoAck: false, consumer, stoppingToken);
        logger.LogInformation("Listening for emails on queue {Queue}", _options.EmailQueue);

        var closed = new TaskCompletionSource();
        connection.ConnectionShutdownAsync += (_, _) =>
        {
            closed.TrySetResult();
            return Task.CompletedTask;
        };

        await closed.Task.WaitAsync(stoppingToken);
        throw new InvalidOperationException("RabbitMQ connection was closed.");
    }

    private async Task<bool> HandleAsync(ReadOnlyMemory<byte> body, CancellationToken stoppingToken)
    {
        EmailMessage? message;
        try
        {
            message = JsonSerializer.Deserialize<EmailMessage>(body.Span);
        }
        catch (JsonException ex)
        {
            logger.LogError(ex, "Received an email message that is not valid JSON; discarding it");
            return false;
        }

        if (message is null)
        {
            logger.LogError("Received an empty email message; discarding it");
            return false;
        }

        for (var attempt = 0; ; attempt++)
        {
            try
            {
                await emailSender.SendAsync(message, stoppingToken);
                logger.LogInformation("Sent email '{Subject}' to {Email}", message.Subject, message.ToEmail);
                return true;
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                if (attempt >= RetryDelays.Length)
                {
                    logger.LogError(ex, "Giving up on email '{Subject}' to {Email} after {Attempts} attempts",
                        message.Subject, message.ToEmail, attempt + 1);
                    return false;
                }

                logger.LogWarning(ex, "Sending email '{Subject}' to {Email} failed (attempt {Attempt}), retrying in {Delay}",
                    message.Subject, message.ToEmail, attempt + 1, RetryDelays[attempt]);
                await Task.Delay(RetryDelays[attempt], stoppingToken);
            }
        }
    }
}
