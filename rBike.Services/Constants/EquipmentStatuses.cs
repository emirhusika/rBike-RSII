using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace rBike.Services.Constants
{
    public static class EquipmentStatuses
    {
        public const string Active = "Active";
        public const string Inactive = "Inactive";

        public static readonly string[] All = { Active, Inactive };

        public static bool IsValid(string status) => All.Contains(status);
    }
} 