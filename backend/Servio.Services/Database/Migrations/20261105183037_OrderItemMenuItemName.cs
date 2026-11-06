using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Servio.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class OrderItemMenuItemName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MenuItemName",
                table: "OrderItems",
                type: "character varying(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            // Existing order lines get the item's current name; new lines store the name when they are ordered.
            migrationBuilder.Sql(
                """
                UPDATE "OrderItems" AS oi
                SET "MenuItemName" = mi."Name"
                FROM "MenuItems" AS mi
                WHERE mi."Id" = oi."MenuItemId";
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MenuItemName",
                table: "OrderItems");
        }
    }
}
