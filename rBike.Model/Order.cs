using System;
using System.Collections.Generic;

namespace rBike.Model
{
    public class Order
    {
        public int OrderId { get; set; }

        public int UserId { get; set; }

        public DateTime OrderDate { get; set; }

        public string Status { get; set; } = null!;

        public string? TransactionNumber { get; set; }

        public decimal TotalAmount { get; set; }

        public string? OrderCode { get; set; }

        public string? DeliveryAddress { get; set; }

        public string? City { get; set; }

        public string? PostalCode { get; set; }

        public DateTime? ModifiedDate { get; set; }

        public string? Username { get; set; }

        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

        public virtual User User { get; set; } = null!;
    }
}
