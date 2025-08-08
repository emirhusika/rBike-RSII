using System;

namespace rBike.Model
{
    public class Comment
    {
        public int CommentId { get; set; }

        public string? Content { get; set; }

        public DateTime? DateAdded { get; set; }

        public int UserId { get; set; }

        public int BikeId { get; set; }

        public string? Status { get; set; }

        public virtual Bike Bike { get; set; } = null!;

        public virtual User User { get; set; } = null!;

        public string? BikeName { get; set; }

        public string? Username { get; set; }
    }
}
