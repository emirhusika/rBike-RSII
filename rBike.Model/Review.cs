using System;

namespace rBike.Model
{
    public class Review
    {
        public int BikeReviewId { get; set; }

        public int BikeId { get; set; }

        public int UserId { get; set; }

        public int Rating { get; set; }

        public DateTime Date { get; set; }

        public virtual Bike Bike { get; set; } = null!;

        public virtual User User { get; set; } = null!;

        public string? Username { get; set; }

        public string? BikeName { get; set; }
    }
}
