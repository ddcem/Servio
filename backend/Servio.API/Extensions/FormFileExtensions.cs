namespace Servio.API.Extensions;

public static class FormFileExtensions
{
    /// <summary>Upload endpoints are capped with RequestSizeLimit, so buffering the file is safe.</summary>
    public static async Task<byte[]> ReadAllBytesAsync(this IFormFile file, CancellationToken cancellationToken)
    {
        using var stream = new MemoryStream();
        await file.CopyToAsync(stream, cancellationToken);
        return stream.ToArray();
    }
}
