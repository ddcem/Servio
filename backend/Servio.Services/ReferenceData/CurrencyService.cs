using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.ReferenceData;

public interface ICurrencyService
    : ICrudService<CurrencyResponse, BaseSearchObject, CurrencyUpsertRequest, CurrencyUpsertRequest>;

public class CurrencyService(ServioDbContext context)
    : BaseCrudService<Currency, CurrencyResponse, BaseSearchObject, CurrencyUpsertRequest, CurrencyUpsertRequest>(context),
        ICurrencyService
{
    protected override string EntityName => "Currency";

    protected override Expression<Func<Currency, CurrencyResponse>> Projection => x => new CurrencyResponse
    {
        Id = x.Id,
        Code = x.Code,
        Name = x.Name,
        Symbol = x.Symbol,
        IsInUse = Context.RestaurantSettings.Any(s => s.CurrencyId == x.Id) || Context.Orders.Any(o => o.CurrencyId == x.Id)
    };

    protected override IQueryable<Currency> ApplyFilter(IQueryable<Currency> query, BaseSearchObject search) =>
        Normalize(search.FTS) is { } fts
            ? query.Where(x => EF.Functions.ILike(x.Name, ContainsPattern(fts)) || EF.Functions.ILike(x.Code, ContainsPattern(fts)))
            : query;

    protected override IQueryable<Currency> ApplyOrdering(IQueryable<Currency> query, BaseSearchObject search) =>
        query.OrderBy(x => x.Code);

    protected override void MapInsert(CurrencyUpsertRequest request, Currency entity) => Map(request, entity);
    protected override void MapUpdate(CurrencyUpsertRequest request, Currency entity) => Map(request, entity);

    protected override Task BeforeInsertAsync(CurrencyUpsertRequest request, Currency entity, CancellationToken cancellationToken) =>
        EnsureUniqueCodeAsync(entity, cancellationToken);

    protected override async Task BeforeUpdateAsync(CurrencyUpsertRequest request, Currency entity, CancellationToken cancellationToken)
    {
        await EnsureUniqueCodeAsync(entity, cancellationToken);

        // Orders keep the currency they were paid in, so its code must not change underneath them.
        if (Context.Entry(entity).Property(x => x.Code).IsModified && await IsInUseAsync(entity.Id, cancellationToken))
        {
            throw new BusinessException("The code of a currency that is used by orders or the settings cannot be changed.");
        }
    }

    protected override async Task BeforeDeleteAsync(Currency entity, CancellationToken cancellationToken)
    {
        if (await IsInUseAsync(entity.Id, cancellationToken))
        {
            throw new BusinessException(
                "{0} is used by the restaurant settings or by existing orders and cannot be deleted.", entity.Code);
        }
    }

    private static void Map(CurrencyUpsertRequest request, Currency entity)
    {
        entity.Code = request.Code.Trim().ToUpperInvariant();
        entity.Name = request.Name.Trim();
        entity.Symbol = request.Symbol.Trim();
    }

    private async Task<bool> IsInUseAsync(int currencyId, CancellationToken cancellationToken) =>
        await Context.RestaurantSettings.AnyAsync(x => x.CurrencyId == currencyId, cancellationToken)
        || await Context.Orders.AnyAsync(x => x.CurrencyId == currencyId, cancellationToken);

    private async Task EnsureUniqueCodeAsync(Currency entity, CancellationToken cancellationToken)
    {
        if (await Context.Currencies.AnyAsync(x => x.Id != entity.Id && x.Code == entity.Code, cancellationToken))
        {
            throw new BusinessException("The currency {0} already exists.", entity.Code);
        }
    }
}
