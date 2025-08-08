using System;

namespace rBike.Model.SearchObjects
{
    public class CommentSearchObject : BaseSearchObject
    {
        public int? BikeId { get; set; }
        public int? UserId { get; set; }
        public string? Status { get; set; }
    }
} 