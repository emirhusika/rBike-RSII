using System;
using System.Collections.Generic;

namespace rBike.Services.Database;

public partial class Category
{
    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public virtual ICollection<Bike> Bikes { get; set; } = new List<Bike>();
}
