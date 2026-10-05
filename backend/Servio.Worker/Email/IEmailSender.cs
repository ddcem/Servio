using Servio.Model.Messages;

namespace Servio.Worker.Email;

public interface IEmailSender
{
    Task SendAsync(EmailMessage message, CancellationToken cancellationToken);
}
