using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public DateTime? Date { get; set; }
        public int? UserId { get; set; }
        public string? Username { get; set; }
    }
}
