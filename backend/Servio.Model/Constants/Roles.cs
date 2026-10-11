namespace Servio.Model.Constants;

public static class Roles
{
    public const string Admin = "Admin";
    public const string Waiter = "Waiter";
    public const string Kitchen = "Kitchen";
    public const string Bar = "Bar";

    public const string Stations = Admin + "," + Kitchen + "," + Bar;
}
