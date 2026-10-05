using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;
using Servio.Model.Messages;
using Servio.Worker.Configuration;

namespace Servio.Worker.Email;

public class SmtpEmailSender(IOptions<SmtpOptions> options) : IEmailSender
{
    private const int ImplicitTlsPort = 465;
    private readonly SmtpOptions _options = options.Value;

    public async Task SendAsync(EmailMessage message, CancellationToken cancellationToken)
    {
        var mime = new MimeMessage();
        mime.From.Add(new MailboxAddress(_options.FromName, _options.FromEmail));
        mime.To.Add(new MailboxAddress(message.ToName, message.ToEmail));
        mime.Subject = message.Subject;
        mime.Body = new BodyBuilder { HtmlBody = message.HtmlBody }.ToMessageBody();

        // Port 465 uses TLS from the start, port 587 upgrades the connection with STARTTLS.
        var security = !_options.UseSsl
            ? SecureSocketOptions.None
            : _options.Port == ImplicitTlsPort ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTls;

        using var client = new SmtpClient();
        await client.ConnectAsync(_options.Host, _options.Port, security, cancellationToken);
        await client.AuthenticateAsync(_options.Username, _options.Password, cancellationToken);
        await client.SendAsync(mime, cancellationToken);
        await client.DisconnectAsync(true, cancellationToken);
    }
}
