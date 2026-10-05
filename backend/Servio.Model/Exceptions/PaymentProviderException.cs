namespace Servio.Model.Exceptions;

/// <summary>
/// The payment provider (PayPal) rejected a request or could not be reached.
/// The message is safe to show; provider details are only logged.
/// </summary>
public class PaymentProviderException(string message) : Exception(message);
