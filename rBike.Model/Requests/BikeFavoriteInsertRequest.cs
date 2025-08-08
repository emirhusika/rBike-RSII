using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.Requests
{
    public class BikeFavoriteInsertRequest
    {
        public int UserId { get; set; }
        public int BikeId { get; set; }
    }
} 