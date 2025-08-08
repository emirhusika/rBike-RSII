using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.Requests
{
    public class UserUpdateRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string? Email { get; set; }

        public string? Password { get; set; }

        public string? ConfirmPassword { get; set; }

        public string? Phone { get; set; }

        public bool? Status { get; set; }

        public byte[]? Image { get; set; }

    }
}
