using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookingApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class RemoveClientServiceDuration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ClientServiceDurations");

            migrationBuilder.AddColumn<TimeSpan>(
                name: "ExtraServiceDuration",
                table: "Users",
                type: "interval",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ExtraServiceDuration",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "ClientServiceDurations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ClientId = table.Column<Guid>(type: "uuid", nullable: false),
                    Duration = table.Column<TimeSpan>(type: "interval", nullable: false),
                    ServiceId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClientServiceDurations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ClientServiceDurations_Services_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "Services",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ClientServiceDurations_Users_ClientId",
                        column: x => x.ClientId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ClientServiceDurations_ClientId_ServiceId",
                table: "ClientServiceDurations",
                columns: new[] { "ClientId", "ServiceId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ClientServiceDurations_ServiceId",
                table: "ClientServiceDurations",
                column: "ServiceId");
        }
    }
}
