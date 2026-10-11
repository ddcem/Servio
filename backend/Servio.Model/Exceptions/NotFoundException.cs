namespace Servio.Model.Exceptions;

public class NotFoundException(string format, params object?[] args) : ServioException(format, args);
