using System;

namespace rBike.Model.Requests
{
    public class CommentInsertRequest
    {
        public int BikeId { get; set; }
        public int UserId { get; set; }
        public string Content { get; set; } = null!;
    }
} 