`default_nettype none
`timescale 1ns / 1ps

module vga (
    input clk,  // needs to be 31.5Mhz
    input reset,
    input wire [4:0] ball_x,
    input wire [4:0] ball_y,
    input wire [31:0] lpaddle,
    input wire [31:0] rpaddle,
    input wire switch_background,

    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb
    );

    // the VGA module
    wire activevideo;
    wire [9:0] x_px;          // X position for actual pixel.
    wire [9:0] y_px;          // Y position for actual pixel.
    wire [4:0] x_px_scaled;
    wire [4:0] y_px_scaled;
    wire [5:0] background;
    reg [2:0] bgcolor;
    reg bgtoggle;

    initial begin
        bgtoggle <= 0;
    end

    assign x_px_scaled = x_px[7:3];
    assign y_px_scaled = y_px[7:3];
    assign background = ((x_px ^ y_px) % 10'd9) == 1 ? {bgcolor[2], 1'b0, bgcolor[1], 1'b0, bgcolor[0], 1'b0} : 6'b000000;

    assign rrggbb = activevideo ? (x_px[9:8] == 2'b00 && y_px[9:8] == 2'b00 && (
        (x_px_scaled == ball_x && y_px_scaled == ball_y) ||
        (x_px_scaled == 5'h1f && lpaddle[y_px_scaled]) ||
        (x_px_scaled == 5'h0 && rpaddle[y_px_scaled])
    ) ? 6'b111111 : background) :
    6'b000000;

    vgasync vga_0 (.px_clk(clk), .hsync(hsync), .vsync(vsync), .x_px(x_px), .y_px(y_px), .activevideo(activevideo), .reset(reset));

    always @(posedge clk) begin
        bgtoggle <= switch_background;
        if (bgtoggle != switch_background) begin
            bgcolor <= bgcolor + 1;
        end
    end

endmodule
`default_nettype wire
