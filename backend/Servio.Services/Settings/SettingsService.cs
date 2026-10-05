using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Auth;
using Servio.Services.Database;

namespace Servio.Services.Settings;

/// <summary>
/// The single settings row. It is read on every order, so it is cached until the admin changes it.
/// </summary>
public class SettingsService(ServioDbContext context, IMemoryCache cache, ICurrentUserService currentUser) : ISettingsService
{
    private const string CacheKey = "restaurant-settings";

    public async Task<SettingsResponse> GetAsync(CancellationToken cancellationToken = default)
    {
        if (cache.TryGetValue(CacheKey, out SettingsResponse? cached) && cached is not null)
        {
            return cached;
        }

        var settings = await context.RestaurantSettings
            .AsNoTracking()
            .Select(x => new SettingsResponse
            {
                RestaurantName = x.RestaurantName,
                CurrencyId = x.CurrencyId,
                CurrencyCode = x.Currency.Code,
                CurrencySymbol = x.Currency.Symbol,
                TaxRate = x.TaxRate,
                UpdatedAt = x.UpdatedAt,
                UpdatedByName = x.UpdatedByUser == null ? null : x.UpdatedByUser.FirstName + " " + x.UpdatedByUser.LastName
            })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("Restaurant settings are missing. Restart the API to seed them.");

        cache.Set(CacheKey, settings);
        return settings;
    }

    public async Task<SettingsResponse> UpdateAsync(SettingsUpdateRequest request, CancellationToken cancellationToken = default)
    {
        if (!await context.Currencies.AnyAsync(x => x.Id == request.CurrencyId, cancellationToken))
        {
            throw new BusinessException("The selected currency does not exist.");
        }

        var settings = await context.RestaurantSettings.FirstOrDefaultAsync(cancellationToken)
                       ?? throw new NotFoundException("Restaurant settings are missing. Restart the API to seed them.");

        // Open orders keep the tax rate and currency they were opened with; new orders use the new values.
        settings.RestaurantName = request.RestaurantName.Trim();
        settings.CurrencyId = request.CurrencyId!.Value;
        settings.TaxRate = request.TaxRate!.Value;
        settings.UpdatedAt = DateTime.UtcNow;
        settings.UpdatedByUserId = currentUser.UserId;

        await context.SaveChangesAsync(cancellationToken);

        cache.Remove(CacheKey);
        return await GetAsync(cancellationToken);
    }
}
