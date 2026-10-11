using System.Net;
using Servio.Model.Localization;
using Servio.Model.Messages;
using Servio.Services.Localization;

namespace Servio.Services.Messaging;

/// <summary>
/// Builds the HTML emails sent through the worker, in the given language. All user-provided text is HTML-encoded.
/// </summary>
public static class EmailTemplates
{
    public static EmailMessage PasswordReset(string email, string name, string code, int validMinutes, string language)
    {
        string T(string format, params object?[] args) => Translator.Render(new LocalizedText(format, args), language);
        return new(email, name, T("Your Servio password reset code"),
            Layout(language, $"""
                <p>{T("Hi {0},", Encode(name))}</p>
                <p>{T("Use this code to reset your Servio password:")}</p>
                <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{code}</p>
                <p>{T("The code is valid for {0} minutes. If you did not ask for a reset, you can ignore this email.", validMinutes)}</p>
                """));
    }

    public static EmailMessage ReservationConfirmed(string email, string guestName, string restaurantName,
        int tableNumber, int partySize, string localStart, string localEnd, string language)
    {
        string T(string format, params object?[] args) => Translator.Render(new LocalizedText(format, args), language);
        return new(email, guestName, T("Your reservation at {0} is confirmed", restaurantName),
            Layout(language, $"""
                <p>{T("Hi {0},", Encode(guestName))}</p>
                <p>{T("Your reservation at {0} is confirmed.", $"<strong>{Encode(restaurantName)}</strong>")}</p>
                <table cellpadding="4">
                  <tr><td>{T("Date and time")}</td><td><strong>{localStart} – {localEnd}</strong></td></tr>
                  <tr><td>{T("Guests")}</td><td><strong>{partySize}</strong></td></tr>
                  <tr><td>{T("Table")}</td><td><strong>{tableNumber}</strong></td></tr>
                </table>
                <p>{T("We look forward to seeing you.")}</p>
                """));
    }

    public static EmailMessage ReservationCancelled(string email, string guestName, string restaurantName,
        string localStart, string reason, string language)
    {
        string T(string format, params object?[] args) => Translator.Render(new LocalizedText(format, args), language);
        return new(email, guestName, T("Your reservation at {0} was cancelled", restaurantName),
            Layout(language, $"""
                <p>{T("Hi {0},", Encode(guestName))}</p>
                <p>{T("Your reservation at {0} for {1} was cancelled.", $"<strong>{Encode(restaurantName)}</strong>", $"<strong>{localStart}</strong>")}</p>
                <p>{T("Reason: {0}", Encode(reason))}</p>
                <p>{T("Please contact us if you would like to book another time.")}</p>
                """));
    }

    private static string Encode(string value) => WebUtility.HtmlEncode(value);

    private static string Layout(string language, string content) => $"""
        <div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#1f2937;max-width:520px">
          {content}
          <p style="color:#6b7280;font-size:12px;margin-top:24px">{Translator.T("This message was sent by Servio.", language)}</p>
        </div>
        """;
}
