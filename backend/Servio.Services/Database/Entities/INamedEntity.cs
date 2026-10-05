namespace Servio.Services.Database.Entities;

/// <summary>
/// Reference data that is identified by a name; served by the generic lookup service.
/// </summary>
public interface INamedEntity : IEntity
{
    string Name { get; }
}
