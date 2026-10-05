namespace Servio.Model.Responses;

/// <summary>
/// Confirmation text for actions that do not return a record, shown to the user as-is.
/// </summary>
public record MessageResponse(string Message);
