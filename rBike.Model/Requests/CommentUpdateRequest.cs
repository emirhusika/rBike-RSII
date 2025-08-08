using System;

namespace rBike.Model.Requests
{
    public class CommentUpdateRequest
    {
        public string? Content { get; set; }
        public string? Status { get; set; }
    }
} 