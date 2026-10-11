namespace Servio.Model.Exceptions;

public class BusinessException(string format, params object?[] args) : ServioException(format, args);
