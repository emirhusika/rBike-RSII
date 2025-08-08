using System;

namespace rBike.Model
{
    public class BikeFavorite
    {
        public int FavoriteId { get; set; }

        public int BikeId { get; set; }

        public int UserId { get; set; }

        public virtual Bike Bike { get; set; } = null!;

        public virtual User User { get; set; } = null!;

        public string? BikeName { get; set; }
        public string? Username { get; set; }
    }
}
