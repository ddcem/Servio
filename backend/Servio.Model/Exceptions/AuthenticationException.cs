namespace Servio.Model.Exceptions;

public class AuthenticationException(string format, params object?[] args) : ServioException(format, args);
