using System.Threading.Tasks;
using rBike.Services.Database;

namespace rBike.Services
{
    public interface IReportService
    {
        Task<Report> GenerateMonthlyEquipmentReport(int month, int year, int adminUserId);
    }
} 