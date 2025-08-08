using System;

namespace rBike.Model.Requests
{
    public class EquipmentUpsertRequest
    {
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public byte[]? Image { get; set; }
        public string? Status { get; set; }
        public int StockQuantity { get; set; }
        public int EquipmentCategoryId { get; set; }
    }
} 