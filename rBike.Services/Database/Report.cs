using System;
using System.Collections.Generic;

namespace rBike.Services.Database;

public partial class Report
{
    public int ReportId { get; set; }

    public int Month { get; set; }

    public int Year { get; set; }

    public decimal TotalValue { get; set; }

    public string TopProductsJson { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public int CreatedById { get; set; }

    public string PdfFilePath { get; set; } = null!;

    public virtual User CreatedBy { get; set; } = null!;
}
