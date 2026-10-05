namespace Servio.Services.Auth;

public interface ICurrentUserService
{
    int UserId { get; }
    string? TokenJti { get; }
    bool IsInRole(string role);
}
