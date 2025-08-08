using System;
using System.Collections.Generic;

namespace rBike.Model
{
    public class Equipment
    {
        public int EquipmentId { get; set; }

        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public decimal Price { get; set; }

        public byte[]? Image { get; set; }

        public string Status { get; set; } = null!;

        public int StockQuantity { get; set; }

        public int EquipmentCategoryId { get; set; }

        public string? EquipmentCategoryName { get; set; }

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }
}
