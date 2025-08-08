using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.Constants
{
    public static class OrderStatuses
    {
        public const string Pending = "Pending";
        public const string Rejected = "Rejected";
        public const string Processed = "Processed";

        public static readonly string[] All = { Pending, Rejected, Processed };

        public static bool IsValid(string status) => All.Contains(status);
    }
} 