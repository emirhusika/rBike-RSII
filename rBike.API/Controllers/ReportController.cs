using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using rBike.Services;
using System.Security.Claims;
using rBike.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService _reportService;
        private readonly RBikeContext _context;
        public ReportController(IReportService reportService, RBikeContext context)
        {
            _reportService = reportService;
            _context = context;
        }

        [HttpPost("generate")]
        public async Task<IActionResult> GenerateMonthlyReport([FromQuery] int month, [FromQuery] int year)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                return Unauthorized();

            int adminUserId;
            if (!int.TryParse(userIdClaim.Value, out adminUserId))
            {
                var username = userIdClaim.Value;
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
                if (user == null)
                    return Unauthorized();
                adminUserId = user.UserId;
            }

            var report = await _reportService.GenerateMonthlyEquipmentReport(month, year, adminUserId);
            if (report == null)
            {
                return NotFound(new { message = "No data found for the selected month and year." });
            }
            return Ok(report);
        }

        [HttpGet("download/{id}")]
        public async Task<IActionResult> DownloadReportPdf(int id)
        {
            try
            {
                Console.WriteLine($"Download request for report ID: {id}");
                
                var report = await _context.Reports.FindAsync(id);
                if (report == null)
                {
                    Console.WriteLine($"Report not found for ID: {id}");
                    return NotFound("Report not found.");
                }

                Console.WriteLine($"Found report: ID={report.ReportId}, Path={report.PdfFilePath}");

                if (string.IsNullOrEmpty(report.PdfFilePath))
                {
                    Console.WriteLine("PDF file path is empty");
                    return NotFound("PDF file path is empty.");
                }

                if (!System.IO.File.Exists(report.PdfFilePath))
                {
                    Console.WriteLine($"PDF file not found at path: {report.PdfFilePath}");
                    return NotFound($"PDF file not found at path: {report.PdfFilePath}");
                }

                Console.WriteLine($"PDF file exists, reading bytes...");
                var fileBytes = await System.IO.File.ReadAllBytesAsync(report.PdfFilePath);
                var fileName = Path.GetFileName(report.PdfFilePath);
                Console.WriteLine($"Successfully read {fileBytes.Length} bytes, filename: {fileName}");

                return File(fileBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error downloading PDF: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
} 