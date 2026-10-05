namespace Servio.Model.Responses;

public record LoginResponse(string Token, DateTime ExpiresAt, UserResponse User);
