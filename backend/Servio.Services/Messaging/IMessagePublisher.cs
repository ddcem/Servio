using Servio.Model.Messages;

namespace Servio.Services.Messaging;

public interface IMessagePublisher
{
    Task PublishEmailAsync(EmailMessage message, CancellationToken cancellationToken = default);
}
