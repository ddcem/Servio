using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Servio.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class TableAssignedWaiter : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AssignedWaiterId",
                table: "RestaurantTables",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_RestaurantTables_AssignedWaiterId",
                table: "RestaurantTables",
                column: "AssignedWaiterId");

            migrationBuilder.AddForeignKey(
                name: "FK_RestaurantTables_Users_AssignedWaiterId",
                table: "RestaurantTables",
                column: "AssignedWaiterId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RestaurantTables_Users_AssignedWaiterId",
                table: "RestaurantTables");

            migrationBuilder.DropIndex(
                name: "IX_RestaurantTables_AssignedWaiterId",
                table: "RestaurantTables");

            migrationBuilder.DropColumn(
                name: "AssignedWaiterId",
                table: "RestaurantTables");
        }
    }
}
