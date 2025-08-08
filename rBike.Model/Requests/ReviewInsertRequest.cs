using System;

namespace rBike.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int BikeId { get; set; }
        public int UserId { get; set; }
        public int Rating { get; set; }
    }
} 