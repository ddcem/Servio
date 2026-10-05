namespace Servio.Model.Constants;

/// <summary>
/// Input formats shared by request validation, so every form reports the same rules.
/// </summary>
public static class ValidationRules
{
    public const string PhonePattern = @"^\+?[0-9][0-9 /-]{5,18}$";
    public const string PhoneMessage = "Enter a phone number with 6 to 19 digits, optionally starting with +, e.g. +387 61 123 456.";

    public const string EmailMessage = "Enter a valid email address, e.g. name@example.com.";

    public const string UsernamePattern = @"^[a-zA-Z0-9._]{3,50}$";
    public const string UsernameMessage = "Username must be 3 to 50 characters and may contain only letters, digits, dots and underscores.";

    public const string PasswordPattern = @"^(?=.*[A-Za-z])(?=.*\d).{8,100}$";
    public const string PasswordMessage = "Password must be 8 to 100 characters long and contain at least one letter and one digit.";

    public const string PasswordMismatchMessage = "Passwords do not match.";

    public const string CurrencyCodePattern = "^[A-Z]{3}$";
    public const string CurrencyCodeMessage = "Currency code must be exactly 3 uppercase letters (ISO 4217), e.g. EUR.";

    public const string ResetCodePattern = "^[0-9]{6}$";
    public const string ResetCodeMessage = "The reset code is the 6-digit number from the email.";
}
