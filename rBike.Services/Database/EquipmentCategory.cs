using System;
using System.Collections.Generic;

namespace rBike.Services.Database;

public partial class EquipmentCategory
{
    public int CategoryId { get; set; }

    public string EquipmentName { get; set; } = null!;

    public virtual ICollection<Equipment> Equipment { get; set; } = new List<Equipment>();
}
