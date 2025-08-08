using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.SearchObjects
{
    public class BikeFavoriteSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? BikeId { get; set; }
    }
} 