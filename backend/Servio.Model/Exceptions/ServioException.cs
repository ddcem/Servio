using Servio.Model.Localization;

namespace Servio.Model.Exceptions;

/// <summary>
/// An error whose message is shown to the user. The message is kept as a <see cref="LocalizedText"/>
/// so the API can answer in the language the app asked for.
/// </summary>
public abstract class ServioException(string format, object?[] args)
    : Exception(new LocalizedText(format, args).ToString())
{
    public LocalizedText Text { get; } = new(format, args);
}
