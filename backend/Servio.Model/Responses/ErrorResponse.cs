namespace Servio.Model.Responses;

public record ErrorResponse(string Message, Dictionary<string, string[]>? Errors = null);
