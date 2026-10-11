using Servio.Services.Localization;

namespace Servio.API.Middleware;

/// <summary>
/// Reads the language the app asked for (Accept-Language, e.g. "bs") so errors, validation messages
/// and PDFs come back in that language. Runs before the error handling so errors are translated too.
/// </summary>
public class LanguageMiddleware(RequestDelegate next)
{
    public Task InvokeAsync(HttpContext context)
    {
        var requested = context.Request.Headers.AcceptLanguage.ToString().Split(',')[0];
        LanguageContext.Set(requested);
        context.Response.Headers.ContentLanguage = LanguageContext.Current;
        return next(context);
    }
}
