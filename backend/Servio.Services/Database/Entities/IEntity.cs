namespace Servio.Services.Database.Entities;

/// <summary>
/// Lets the generic base services find any entity by its primary key.
/// </summary>
public interface IEntity
{
    int Id { get; }
}
