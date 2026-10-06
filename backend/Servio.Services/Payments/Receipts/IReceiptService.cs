namespace Servio.Services.Payments.Receipts;

public interface IReceiptService
{
    /// <summary>The guest's receipt for a completed (or later refunded) payment, as a PDF.</summary>
    Task<byte[]> GetPdfAsync(int paymentId, CancellationToken cancellationToken = default);
}
