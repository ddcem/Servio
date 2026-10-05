using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Constants;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Reports;

namespace Servio.API.Controllers;

[ApiController]
[Route("api/reports")]
[Authorize(Roles = Roles.Admin)]
public class ReportsController(IReportService service) : ControllerBase
{
    private const string PdfContentType = "application/pdf";

    [HttpGet("sales")]
    public async Task<ActionResult<SalesReportResponse>> GetSales([FromQuery] ReportPeriodSearchObject period,
        CancellationToken cancellationToken) =>
        Ok(await service.GetSalesReportAsync(period, cancellationToken));

    [HttpGet("sales/pdf")]
    public async Task<IActionResult> GetSalesPdf([FromQuery] ReportPeriodSearchObject period, CancellationToken cancellationToken) =>
        File(await service.GetSalesReportPdfAsync(period, cancellationToken), PdfContentType, "servio-sales-report.pdf");

    [HttpGet("staff")]
    public async Task<ActionResult<StaffReportResponse>> GetStaff([FromQuery] ReportPeriodSearchObject period,
        CancellationToken cancellationToken) =>
        Ok(await service.GetStaffReportAsync(period, cancellationToken));

    [HttpGet("staff/pdf")]
    public async Task<IActionResult> GetStaffPdf([FromQuery] ReportPeriodSearchObject period, CancellationToken cancellationToken) =>
        File(await service.GetStaffReportPdfAsync(period, cancellationToken), PdfContentType, "servio-staff-report.pdf");
}
