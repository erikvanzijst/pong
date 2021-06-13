`default_nettype none
`timescale 1ns / 1ps

module vga (
    input clk,  // needs to be 31.5Mhz
    input reset,
    input wire [4:0] ball_x,
    input wire [4:0] ball_y,
    input wire [31:0] lpaddle,
    input wire [31:0] rpaddle,
    input wire [5:0] bgcolor,

    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb
    );

    // the VGA module
    wire activevideo;
    wire [9:0] x_px;          // X position for actual pixel.
    wire [9:0] x_prime;
    wire [9:0] y_px;          // Y position for actual pixel.
    wire [9:0] y_prime;
    wire [4:0] x_px_scaled;
    wire [4:0] y_px_scaled;

    // Center the game in the middle of the screen
    assign x_prime = x_px - 192;
    assign y_prime = y_px - 112;
    assign x_px_scaled = x_prime[7:3];
    assign y_px_scaled = y_prime[7:3];

    assign rrggbb = activevideo ? (

        (x_prime[9:8] == 2'b00 && y_prime[9:8] == 2'b00 && (
            (x_px_scaled == ball_x && y_px_scaled == ball_y) ||
            (x_px_scaled == 5'h1f && lpaddle[y_px_scaled]) ||
            (x_px_scaled == 5'h0 && rpaddle[y_px_scaled]))
        ) ? 6'b111111 : bgcolor

    ) : 6'b000000;

    vgasync vga_0 (
        .px_clk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .x_px(x_px),
        .y_px(y_px),
        .activevideo(activevideo),
        .reset(reset));

endmodule
`default_nettype wire
