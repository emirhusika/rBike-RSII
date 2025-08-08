using System;

namespace rBike.Model
{
    public class Reservation
    {
        public int ReservationId { get; set; }

        public int UserId { get; set; }

        public int BikeId { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime StartDateTime { get; set; }

        public DateTime EndDateTime { get; set; }

        public string? Status { get; set; }

        public virtual Bike Bike { get; set; } = null!;

        public virtual User User { get; set; } = null!;

        public string? BikeName { get; set; }
        public string? Username { get; set; }
    }
}
