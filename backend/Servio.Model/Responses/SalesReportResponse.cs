namespace Servio.Model.Responses;

public class SalesReportResponse
{
    public DateOnly From { get; set; }
    public DateOnly To { get; set; }
    public string CurrencySymbol { get; set; } = string.Empty;

    /// <summary>Totals of paid orders (prices include VAT), excluding tips.</summary>
    public decimal Revenue { get; set; }
    public decimal TaxCollected { get; set; }
    public decimal Tips { get; set; }
    public decimal Refunds { get; set; }
    public decimal NetRevenue { get; set; }
    public int OrderCount { get; set; }
    public int GuestCount { get; set; }
    public decimal AverageBill { get; set; }
    public int CancelledOrderCount { get; set; }

    public List<DailySalesResponse> Daily { get; set; } = [];
    public List<ItemSalesResponse> TopItems { get; set; } = [];
    public List<ItemSalesResponse> LeastSoldItems { get; set; } = [];
    public List<CategorySalesResponse> Categories { get; set; } = [];
    public List<PaymentMethodSalesResponse> PaymentMethods { get; set; } = [];
}

public class DailySalesResponse
{
    public DateOnly Date { get; set; }
    public decimal Revenue { get; set; }
    public int OrderCount { get; set; }
}

public class ItemSalesResponse
{
    public int MenuItemId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public bool HasImage { get; set; }
    public int Quantity { get; set; }
    public decimal Revenue { get; set; }
}

public class CategorySalesResponse
{
    public string CategoryName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal Revenue { get; set; }
}

public class PaymentMethodSalesResponse
{
    public string PaymentMethod { get; set; } = string.Empty;
    public int PaymentCount { get; set; }
    public decimal Amount { get; set; }
}
