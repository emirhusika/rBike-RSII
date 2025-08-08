using System;

namespace rBike.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public string? OrderCode { get; set; }
        public string? Username { get; set; }
        public string? Status { get; set; }
        public DateTime? OrderDateFrom { get; set; }
        public DateTime? OrderDateTo { get; set; }
        public int? UserId { get; set; }
    }
} 