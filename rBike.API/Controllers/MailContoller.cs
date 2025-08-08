using Microsoft.AspNetCore.Mvc;
using rBike.Model;
using rBike.Services;

namespace rBike.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MailController : ControllerBase
    {
        private readonly IMailService _mailService;

        public MailController(IMailService mailService)
        {
            _mailService = mailService;
        }

        [HttpPost]
        public async Task<IActionResult> SendMail([FromBody] MailObject mail)
        {
            await _mailService.StartConnection(mail);
            return Ok("Mail request sent to queue.");
        }
    }
}