using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.SearchObjects
{
    public class BikeSearchObject : BaseSearchObject
    {
        public string? FTS { get; set; }
        public string? BikeCode { get; set; }
        public string? StateMachine { get; set; }
    }
}
