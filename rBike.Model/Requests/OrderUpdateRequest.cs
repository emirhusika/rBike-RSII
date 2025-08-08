using System;

namespace rBike.Model.Requests
{
    public class OrderUpdateRequest
    {
        public string Status { get; set; } = null!;
        public string? TransactionNumber { get; set; }
    }
} 