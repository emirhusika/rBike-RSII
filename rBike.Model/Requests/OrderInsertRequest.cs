using System;
using System.Collections.Generic;

namespace rBike.Model.Requests
{
    public class OrderInsertRequest
    {
        public int UserId { get; set; }
        public decimal TotalAmount { get; set; }
        public string? TransactionNumber { get; set; }
        public string? DeliveryAddress { get; set; }
        public string? City { get; set; }
        public string? PostalCode { get; set; }
        public List<OrderItemInsertRequest> OrderItems { get; set; } = new List<OrderItemInsertRequest>();
    }

    public class OrderItemInsertRequest
    {
        public int EquipmentId { get; set; }
        public int Quantity { get; set; }
    }
} 