using System;

namespace rBike.Model.SearchObjects
{
    public class EquipmentSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Status { get; set; }
        public int? EquipmentCategoryId { get; set; }
    }
} 