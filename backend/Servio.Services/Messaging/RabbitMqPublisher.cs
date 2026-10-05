using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using Servio.Model.Configuration;
using Servio.Model.Messages;

namespace Servio.Services.Messaging;

/// <summary>
/// Singleton publisher that keeps one RabbitMQ connection and channel for the lifetime of the API.
/// </summary>
public sealed class RabbitMqPublisher(IOptions<RabbitMqOptions> options, ILogger<RabbitMqPublisher> logger)
    : IMessagePublisher, IAsyncDisposable
{
    private readonly RabbitMqOptions _options = options.Value;
    private readonly SemaphoreSlim _lock = new(1, 1);
    private IConnection? _connection;
    private IChannel? _channel;

    public async Task PublishEmailAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        var body = JsonSerializer.SerializeToUtf8Bytes(message);

        await _lock.WaitAsync(cancellationToken);
        try
        {
            var channel = await GetChannelAsync(cancellationToken);
            await channel.BasicPublishAsync(
                exchange: string.Empty,
                routingKey: _options.EmailQueue,
                mandatory: false,
                basicProperties: new BasicProperties { Persistent = true, ContentType = "application/json" },
                body: body,
                cancellationToken: cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to publish email '{Subject}' to queue {Queue}", message.Subject, _options.EmailQueue);
            throw;
        }
        finally
        {
            _lock.Release();
        }
    }

    private async Task<IChannel> GetChannelAsync(CancellationToken cancellationToken)
    {
        if (_channel is { IsOpen: true })
        {
            return _channel;
        }

        if (_connection is not { IsOpen: true })
        {
            var factory = new ConnectionFactory
            {
                HostName = _options.Host,
                Port = _options.Port,
                UserName = _options.Username,
                Password = _options.Password
            };
            _connection = await factory.CreateConnectionAsync(cancellationToken);
        }

        _channel = await _connection.CreateChannelAsync(cancellationToken: cancellationToken);
        await _channel.QueueDeclareAsync(_options.EmailQueue, durable: true, exclusive: false, autoDelete: false,
            cancellationToken: cancellationToken);
        return _channel;
    }

    public async ValueTask DisposeAsync()
    {
        if (_channel is not null) await _channel.DisposeAsync();
        if (_connection is not null) await _connection.DisposeAsync();
        _lock.Dispose();
    }
}
