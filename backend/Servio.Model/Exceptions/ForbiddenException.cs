namespace Servio.Model.Exceptions;

public class ForbiddenException(string format, params object?[] args) : ServioException(format, args);
