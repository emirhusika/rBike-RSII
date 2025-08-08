using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Linq;

namespace rBike.Model
{
    public class Bike
    {
        public int BikeId { get; set; }

        public string Name { get; set; } = null!;

        public string BikeCode { get; set; } = null!;

        public decimal Price { get; set; }

        public int CategoryId { get; set; }

        public byte[]? Image { get; set; }

        public bool? Status { get; set; }

        public string? StateMachine { get; set; }
    }
}
