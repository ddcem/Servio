namespace Servio.Model.Enums;

/// <summary>
/// Computed from the table's open order and confirmed reservations; it is not stored.
/// </summary>
public enum TableStatus
{
    Available = 0,
    Occupied = 1,
    Reserved = 2
}
