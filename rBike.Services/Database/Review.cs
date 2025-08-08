using System;
using System.Collections.Generic;

namespace rBike.Services.Database;

public partial class Review
{
    public int BikeReviewId { get; set; }

    public int BikeId { get; set; }

    public int UserId { get; set; }

    public int Rating { get; set; }

    public DateTime Date { get; set; }

    public virtual Bike Bike { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
