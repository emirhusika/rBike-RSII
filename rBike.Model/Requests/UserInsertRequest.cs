using System;
using System.Collections.Generic;
using System.Text;

namespace rBike.Model.Requests
{
    public class UserInsertRequest
    {
        public string FirstName { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string? Email { get; set; }

        public string? Phone { get; set; }

        public string Username { get; set; } = null!;

        public string Password { get; set; }

        public string ConfirmPassword { get; set; }

        public bool? Status { get; set; }

        public DateTime? DateRegistered { get; set; }

        public byte[]? Image { get; set; }

        public List<UserRoleInsertRequest> UserRoles { get; set; } = new List<UserRoleInsertRequest>();
    }
}
