using System;
using System.Collections.Generic;

namespace rBike.Services.Database;

public partial class Bike
{
    public int BikeId { get; set; }

    public string Name { get; set; } = null!;

    public string BikeCode { get; set; } = null!;

    public decimal Price { get; set; }

    public int CategoryId { get; set; }

    public byte[]? Image { get; set; }

    public bool? Status { get; set; }

    public string? StateMachine { get; set; }

    public virtual ICollection<BikeFavorite> BikeFavorites { get; set; } = new List<BikeFavorite>();

    public virtual Category Category { get; set; } = null!;

    public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
}
