using System.Threading.Tasks;
using rBike.Model;

namespace rBike.Services
{
    public interface IMailService
    {
        Task StartConnection(MailObject obj);
    }
}