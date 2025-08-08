using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using Newtonsoft.Json;

namespace rBike.Subscriber
{
    class Program
    {
        static void Main()
        {
            var hostname = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
            var username = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASS") ?? "guest";

            var factory = new ConnectionFactory
            {
                HostName = hostname,
                UserName = username,
                Password = password
            };

            int retries = 10;
            int delayMs = 5000;
            IConnection connection = null;
            IModel channel = null;
            while (retries > 0)
            {
                try
                {
                    connection = factory.CreateConnection();
                    channel = connection.CreateModel();
                    Console.WriteLine("Connected to RabbitMQ!");
                    break;
                }
                catch (RabbitMQ.Client.Exceptions.BrokerUnreachableException ex)
                {
                    retries--;
                    Console.WriteLine($"RabbitMQ not available, retries left: {retries}. Waiting {delayMs / 1000} seconds...");
                    if (retries == 0)
                    {
                        Console.WriteLine("Could not connect to RabbitMQ. Exiting.");
                        throw;
                    }
                    Thread.Sleep(delayMs);
                }
            }

            using (connection)
            using (channel)
            {
                channel.QueueDeclare(queue: "email_sending",
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                Console.WriteLine("Waiting for email messages...");

                var consumer = new EventingBasicConsumer(channel);

                consumer.Received += (model, ea) =>
                {
                    try
                    {
                        var body = ea.Body.ToArray();
                        var json = Encoding.UTF8.GetString(body);
                        var mail = JsonConvert.DeserializeObject<MailMessageDto>(json);

                        if (mail != null)
                            MailSender.SendEmail(mail);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error in message processing: " + ex);
                    }
                };

                channel.BasicConsume(queue: "email_sending",
                                     autoAck: true,
                                     consumer: consumer);

                Console.WriteLine("Listening...");
                while (true)
                {
                    Thread.Sleep(1000);
                }
            }
        }
    }
}