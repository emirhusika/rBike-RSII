using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? BikeId { get; set; }
        public int? UserId { get; set; }
    }
}
