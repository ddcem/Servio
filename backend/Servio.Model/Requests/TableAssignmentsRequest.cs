using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

/// <summary>Moves tables to waiters (or back to "any waiter") in one step, e.g. one drag or a whole shift.</summary>
public class TableAssignmentsRequest
{
    [Required(ErrorMessage = "Choose at least one table.")]
    [MinLength(1, ErrorMessage = "Choose at least one table.")]
    [MaxLength(500, ErrorMessage = "At most 500 tables can be assigned at once.")]
    public List<TableAssignmentRequest> Items { get; set; } = [];
}

public class TableAssignmentRequest
{
    [Required(ErrorMessage = "Table is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a table.")]
    public int? TableId { get; set; }

    /// <summary>null removes the assignment: any waiter may serve the table.</summary>
    [Range(1, int.MaxValue, ErrorMessage = "Choose a waiter.")]
    public int? WaiterId { get; set; }
}
