namespace Servio.Model.Messages;

public record EmailMessage(string ToEmail, string ToName, string Subject, string HtmlBody);
