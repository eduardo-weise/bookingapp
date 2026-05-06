using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookingApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDebtTypeDescriptionAndFeePercentage : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "DebtBalances",
                type: "character varying(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "FeePercentage",
                table: "DebtBalances",
                type: "numeric(5,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "Type",
                table: "DebtBalances",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Description",
                table: "DebtBalances");

            migrationBuilder.DropColumn(
                name: "FeePercentage",
                table: "DebtBalances");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "DebtBalances");
        }
    }
}
