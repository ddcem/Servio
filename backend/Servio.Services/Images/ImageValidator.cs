using Servio.Model.Exceptions;

namespace Servio.Services.Images;

/// <summary>
/// Accepts an upload only if its content really is an image: the type is detected from
/// the file's magic bytes, never from the file name or the content type sent by the client.
/// </summary>
public static class ImageValidator
{
    public const int MaxSizeBytes = 2 * 1024 * 1024;

    private const string InvalidImageMessage = "Upload a JPEG, PNG or WebP image of at most 2 MB.";

    private static readonly byte[] JpegSignature = [0xFF, 0xD8, 0xFF];
    private static readonly byte[] PngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    private static readonly byte[] RiffSignature = "RIFF"u8.ToArray();
    private static readonly byte[] WebpSignature = "WEBP"u8.ToArray();

    public static ImageFile Validate(byte[] content)
    {
        if (content.Length == 0 || content.Length > MaxSizeBytes)
        {
            throw new BusinessException(InvalidImageMessage);
        }

        var span = content.AsSpan();
        string? contentType = null;

        if (span.StartsWith(JpegSignature))
        {
            contentType = "image/jpeg";
        }
        else if (span.StartsWith(PngSignature))
        {
            contentType = "image/png";
        }
        else if (span.Length > 12 && span.StartsWith(RiffSignature) && span[8..12].SequenceEqual(WebpSignature))
        {
            contentType = "image/webp";
        }

        return contentType is null
            ? throw new BusinessException(InvalidImageMessage)
            : new ImageFile(content, contentType);
    }
}
