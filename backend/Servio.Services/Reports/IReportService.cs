using Servio.Model.Responses;
using Servio.Model.SearchObjects;

namespace Servio.Services.Reports;

public interface IReportService
{
    Task<SalesReportResponse> GetSalesReportAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default);
    Task<StaffReportResponse> GetStaffReportAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default);
    Task<byte[]> GetSalesReportPdfAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default);
    Task<byte[]> GetStaffReportPdfAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default);
}
