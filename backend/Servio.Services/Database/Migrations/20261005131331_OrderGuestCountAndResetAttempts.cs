using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Servio.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class OrderGuestCountAndResetAttempts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FailedAttempts",
                table: "PasswordResetTokens",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "GuestCount",
                table: "Orders",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FailedAttempts",
                table: "PasswordResetTokens");

            migrationBuilder.DropColumn(
                name: "GuestCount",
                table: "Orders");
        }
    }
}
