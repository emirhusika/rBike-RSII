using System;
using System.Collections.Generic;

namespace rBike.Model
{
    public class OrderItem
    {
        public int OrderItemsId { get; set; }

        public int OrderId { get; set; }

        public int EquipmentId { get; set; }

        public int Quantity { get; set; }

        public virtual Equipment Equipment { get; set; } = null!;

        public virtual Order Order { get; set; } = null!;
    }
}
