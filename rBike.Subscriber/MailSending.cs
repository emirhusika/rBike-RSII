using System.Net;
using System.Net.Mail;
// using rBike.Model;

namespace rBike.Subscriber
{
    public class MailSender
    {
        public static void SendEmail(MailMessageDto obj)
        {
            string smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
            string senderEmail = Environment.GetEnvironmentVariable("EMAIL_SENDER") ?? "rbikeapp@gmail.com";
            string senderPass = Environment.GetEnvironmentVariable("EMAIL_PASS") ?? "sxxu vmvs unhe nyhq";
            int port = int.Parse(Environment.GetEnvironmentVariable("EMAIL_PORT") ?? "587");

            var message = new MailMessage()
            {
                From = new MailAddress(senderEmail),
                Subject = obj.Subject,
                Body = obj.Message,
                IsBodyHtml = true
            };

            message.To.Add(new MailAddress(obj.EmailAddress));

            var smtp = new SmtpClient(smtpServer, port)
            {
                Credentials = new NetworkCredential(senderEmail, senderPass),
                EnableSsl = true
            };

            try
            {
                smtp.Send(message);
                Console.WriteLine($"Mail sent to {obj.EmailAddress}");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error sending mail: " + ex.Message);
            }
        }
    }
}