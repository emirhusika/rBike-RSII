using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.Constants
{

    public static class ReservationStatuses
    {
        public const string Active = "Active";
        public const string Processed = "Processed";
        public const string Rejected = "Rejected";

        public static readonly string[] All = { Active, Processed, Rejected };

        public static bool IsValid(string status) => All.Contains(status);
    }

}
