using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int UserId { get; set; }     

        public int BikeId { get; set; }     

        public DateTime StartDateTime { get; set; }  

        public DateTime EndDateTime { get; set; }
    }
}
