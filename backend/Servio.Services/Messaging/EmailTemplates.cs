using System.Net;
using Servio.Model.Messages;

namespace Servio.Services.Messaging;

/// <summary>
/// Builds the HTML emails sent through the worker. All user-provided text is HTML-encoded.
/// </summary>
public static class EmailTemplates
{
    public static EmailMessage PasswordReset(string email, string name, string code, int validMinutes) =>
        new(email, name, "Your Servio password reset code",
            Layout($"""
                <p>Hi {Encode(name)},</p>
                <p>Use this code to reset your Servio password:</p>
                <p style="font-size:28px;font-weight:bold;letter-spacing:6px">{code}</p>
                <p>The code is valid for {validMinutes} minutes. If you did not ask for a reset, you can ignore this email.</p>
                """));

    public static EmailMessage ReservationConfirmed(string email, string guestName, string restaurantName,
        int tableNumber, int partySize, string localStart, string localEnd) =>
        new(email, guestName, $"Your reservation at {restaurantName} is confirmed",
            Layout($"""
                <p>Hi {Encode(guestName)},</p>
                <p>Your reservation at <strong>{Encode(restaurantName)}</strong> is confirmed.</p>
                <table cellpadding="4">
                  <tr><td>Date and time</td><td><strong>{localStart} – {localEnd}</strong></td></tr>
                  <tr><td>Guests</td><td><strong>{partySize}</strong></td></tr>
                  <tr><td>Table</td><td><strong>{tableNumber}</strong></td></tr>
                </table>
                <p>We look forward to seeing you.</p>
                """));

    public static EmailMessage ReservationCancelled(string email, string guestName, string restaurantName,
        string localStart, string reason) =>
        new(email, guestName, $"Your reservation at {restaurantName} was cancelled",
            Layout($"""
                <p>Hi {Encode(guestName)},</p>
                <p>Your reservation at <strong>{Encode(restaurantName)}</strong> for <strong>{localStart}</strong> was cancelled.</p>
                <p>Reason: {Encode(reason)}</p>
                <p>Please contact us if you would like to book another time.</p>
                """));

    private static string Encode(string value) => WebUtility.HtmlEncode(value);

    private static string Layout(string content) => $"""
        <div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#1f2937;max-width:520px">
          {content}
          <p style="color:#6b7280;font-size:12px;margin-top:24px">This message was sent by Servio.</p>
        </div>
        """;
}
