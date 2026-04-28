using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookingApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAbsenceStartEndDate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AbsenceDays_Date",
                table: "AbsenceDays");

            migrationBuilder.DropColumn(
                name: "Date",
                table: "AbsenceDays");

            migrationBuilder.AddColumn<DateTime>(
                name: "EndDate",
                table: "AbsenceDays",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "StartDate",
                table: "AbsenceDays",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_AbsenceDays_StartDate_EndDate",
                table: "AbsenceDays",
                columns: new[] { "StartDate", "EndDate" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AbsenceDays_StartDate_EndDate",
                table: "AbsenceDays");

            migrationBuilder.DropColumn(
                name: "EndDate",
                table: "AbsenceDays");

            migrationBuilder.DropColumn(
                name: "StartDate",
                table: "AbsenceDays");

            migrationBuilder.AddColumn<DateTime>(
                name: "Date",
                table: "AbsenceDays",
                type: "date",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_AbsenceDays_Date",
                table: "AbsenceDays",
                column: "Date",
                unique: true);
        }
    }
}
