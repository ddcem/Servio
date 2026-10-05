namespace Servio.Services.Database.Entities;

public class Role : INamedEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<User> Users { get; set; } = [];
}
