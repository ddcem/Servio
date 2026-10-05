using Microsoft.EntityFrameworkCore;
using Npgsql;
using Servio.Model.Exceptions;
using Servio.Model.Responses;

namespace Servio.API.Middleware;

/// <summary>
/// Maps custom exceptions to HTTP status codes. Unexpected errors are logged with request details
/// and the client only receives a generic message (no stack traces or internal details).
/// </summary>
public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    private const string UnexpectedErrorMessage = "Something went wrong on our side. Please try again later.";

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            var (statusCode, message) = ex switch
            {
                BusinessException => (StatusCodes.Status400BadRequest, ex.Message),
                NotFoundException => (StatusCodes.Status404NotFound, ex.Message),
                AuthenticationException => (StatusCodes.Status401Unauthorized, ex.Message),
                ForbiddenException => (StatusCodes.Status403Forbidden, ex.Message),
                PaymentProviderException => (StatusCodes.Status502BadGateway, ex.Message),
                // Safety net for races that slip past the service checks (two users saving at the same moment).
                DbUpdateException { InnerException: PostgresException { SqlState: PostgresErrorCodes.UniqueViolation } } =>
                    (StatusCodes.Status409Conflict, "This record was just changed by someone else. Reload and try again."),
                DbUpdateException { InnerException: PostgresException { SqlState: PostgresErrorCodes.ForeignKeyViolation } } =>
                    (StatusCodes.Status409Conflict, "This record is used by other data and cannot be changed or deleted."),
                OperationCanceledException when context.RequestAborted.IsCancellationRequested => (499, "Request was cancelled."),
                _ => (StatusCodes.Status500InternalServerError, UnexpectedErrorMessage)
            };

            if (statusCode is StatusCodes.Status500InternalServerError or StatusCodes.Status409Conflict)
            {
                logger.LogError(ex, "Request failed for {Method} {Path}{Query} (user: {User}, trace: {TraceId})",
                    context.Request.Method, context.Request.Path, context.Request.QueryString,
                    context.User.Identity?.Name ?? "anonymous", context.TraceIdentifier);
            }
            else
            {
                logger.LogInformation("{ExceptionType} for {Method} {Path}: {Message}",
                    ex.GetType().Name, context.Request.Method, context.Request.Path, ex.Message);
            }

            if (context.Response.HasStarted)
            {
                throw;
            }

            context.Response.StatusCode = statusCode;
            await context.Response.WriteAsJsonAsync(new ErrorResponse(message));
        }
    }
}
