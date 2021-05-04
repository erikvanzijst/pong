`default_nettype none
`timescale 1ns / 1ps

module pong
    #(parameter integer SCREENTIMERWIDTH = 10,
      parameter integer BALLSPEED = 20)
    (
    input wire clk,
    input wire BTN1,

    output wire RCLK,
    output wire RSDI,
    output wire OEB,
    output wire CSDI,
    output wire CCLK,
    output wire LE
    );

    wire reset;
    assign reset = BTN1;

    wire [3:0] x, y;
    wire game_clk;
    wire signed [4:0] speed;
    assign speed = 15;

    wire [15:0] paddle_l;
    wire [15:0] paddle_r;

    // A 1000Hz clock to driver the game:
    customclk #(.TOP(6000)) game_clk_mod(
        .clk(clk),
        .clkout(game_clk)
    );

    paddle paddle0(
        .clk(clk),
        .reset(reset),
        .up(BTN1),
        .down(BTN1),
        .width(2'b1),
        .paddle_o(paddle_l)
    );

    paddle paddle1(
        .clk(clk),
        .reset(reset),
        .up(BTN1),
        .down(BTN1),
        .width(2'b1),
        .paddle_o(paddle_r)
    );

    ball ball0(
        .clk(game_clk),
        .reset(reset),
        .speed(speed),
        .x(x),
        .y(y)
    );

    screen #(.TIMERWIDTH(SCREENTIMERWIDTH)) screen0(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .lpaddle(paddle_l),
        .rpaddle(paddle_r),
        .rclk(RCLK),
        .rsdi(RSDI),
        .oeb(OEB),
        .csdi(CSDI),
        .cclk(CCLK),
        .le(LE)
    );

endmodule
