using System;
using System.Threading.Tasks;
using rBike.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Text.Json;
using System.IO;
using System.Collections.Generic;
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;

namespace rBike.Services
{
    public class ReportService : IReportService
    {
        private readonly RBikeContext _context;
        public ReportService(RBikeContext context)
        {
            _context = context;
        }

        public async Task<rBike.Services.Database.Report> GenerateMonthlyEquipmentReport(int month, int year, int adminUserId)
        {
            var processedOrders = await _context.Orders
                .Where(o => o.Status == "Processed" &&
                            o.OrderDate.Month == month &&
                            o.OrderDate.Year == year)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Equipment)
                .ToListAsync();

            if (processedOrders == null || processedOrders.Count == 0)
                return null;

            var totalValue = processedOrders.Sum(o => o.TotalAmount);

            var topProducts = processedOrders
                .SelectMany(o => o.OrderItems)
                .GroupBy(oi => new { oi.EquipmentId, oi.Equipment.Name, oi.Equipment.Price })
                .Select(g => new {
                    ProductId = g.Key.EquipmentId,
                    Name = g.Key.Name,
                    Quantity = g.Sum(oi => oi.Quantity),
                    TotalValue = g.Sum(oi => oi.Quantity * g.Key.Price)
                })
                .OrderByDescending(x => x.Quantity)
                .Take(3)
                .ToList();

            var topProductsJson = JsonSerializer.Serialize(topProducts);

            string pdfPath = GeneratePdf(month, year, totalValue, topProductsJson);

            var report = new rBike.Services.Database.Report
            {
                Month = month,
                Year = year,
                TotalValue = totalValue,
                TopProductsJson = topProductsJson,
                CreatedAt = DateTime.Now,
                CreatedById = adminUserId,
                PdfFilePath = pdfPath
            };
            _context.Reports.Add(report);
            await _context.SaveChangesAsync();

            return report;
        }

        private string GeneratePdf(
            int month, int year, decimal totalValue,
            string topProductsJson)
        {
            QuestPDF.Settings.License = LicenseType.Community;
            var reportsDir = Path.Combine("/app", "Reports");
            if (!Directory.Exists(reportsDir))
                Directory.CreateDirectory(reportsDir);

            var pdfPath = Path.Combine(reportsDir, $"Report_{year}_{month}_{Guid.NewGuid()}.pdf");

            var monthYear = $"{month}/{year}";

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);
                    page.Header().Text($"REPORT ZA: {monthYear}").FontSize(20).Bold();
                    page.Content().Column(col =>
                    {
                        col.Item().Height(30);
                        col.Item().Text($"UKUPNA VRIJEDNOST USPJESNO KREIRANIH NARUDZBI: {totalValue:N2} BAM").FontSize(16);
                        col.Item().Height(20);
                        col.Item().Text("TRI NAJPRODAVANIJA PROIZVODA:").FontSize(14).Bold();
                        
                        try
                        {
                            var products = JsonSerializer.Deserialize<List<JsonElement>>(topProductsJson);
                            if (products != null)
                            {
                                for (int i = 0; i < products.Count; i++)
                                {
                                    var product = products[i];
                                    var name = product.GetProperty("Name").GetString();
                                    var quantity = product.GetProperty("Quantity").GetInt32();
                                    var totalValue = product.GetProperty("TotalValue").GetDecimal();
                                    col.Item().Text($"#{i + 1}. {name}: {quantity} kom, {totalValue:N2} BAM").FontSize(12);
                                }
                            }
                        }
                        catch
                        {
                            col.Item().Text("• Greška u prikazu proizvoda").FontSize(12);
                        }
                        
                        col.Item().Height(20);
                        col.Item().Text($"Mjesec: {month} | Godina: {year} | Status: Uspješno").FontSize(12);
                    });
                    page.Footer().AlignCenter().Text(x =>
                    {
                        x.Span("Generisano od strane rBike Admin tima");
                        x.Span($" | {DateTime.Now:dd.MM.yyyy HH:mm}");
                    });
                });
            });

            document.GeneratePdf(pdfPath);

            return pdfPath;
        }
    }
}
