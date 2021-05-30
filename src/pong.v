`default_nettype none
`timescale 1ns / 1ps

module pong
    #(parameter integer SCREENTIMERWIDTH = 10,
      parameter integer BALLSPEED = 20,
      parameter integer GAMECLK = 6000)
    (
    input wire clk12mhz,
    input wire clk32mhz,
    input wire clk,
    input wire reset,
    input wire start,

    input wire player1_a,
    input wire player1_b,
    input wire player2_a,
    input wire player2_b,

    // 7-segment scoreboards:
    output wire seg_a,
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
    output wire seg_e,
    output wire seg_f,
    output wire seg_g,
    output wire cath,

    // Dot-matrix display out:
    output wire RCLK,
    output wire RSDI,
    output wire OEB,
    output wire CSDI,
    output wire CCLK,
    output wire LE,

    // VGA out:
    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb
    );

    wire [4:0] entropy;

    wire player1_a_deb;
    wire player1_b_deb;
    wire player2_a_deb;
    wire player2_b_deb;

    wire out_left, out_right;
    wire [3:0] score_p1, score_p2;

    reg [7:0] x, y;
    wire game_clk;
    wire signed [4:0] speed;
    assign speed = 11;

    reg [15:0] paddle_1;
    reg [15:0] paddle_2;

    wire signed [1:0] player1_encoder, player2_encoder;

    rnd random(
        .clk(game_clk),
        .reset(reset),
        .q(entropy)
    );

    // A 1000Hz clock to driver the game:
    customclk #(.TOP(GAMECLK)) game_clk_mod(
        .clk(clk12mhz),
        .clkout(game_clk)
    );

    debounce #(.HIST_LEN(16)) debounce_1a (
        .clk(clk12mhz),
        .reset(reset),
        .button(player1_a),
        .debounced(player1_a_deb)
    );

    debounce #(.HIST_LEN(16)) debounce_1b (
        .clk(clk12mhz),
        .reset(reset),
        .button(player1_b),
        .debounced(player1_b_deb)
    );

    debounce #(.HIST_LEN(16)) debounce_2a (
        .clk(clk12mhz),
        .reset(reset),
        .button(player2_a),
        .debounced(player2_a_deb)
    );

    debounce #(.HIST_LEN(16)) debounce_2b (
        .clk(clk12mhz),
        .reset(reset),
        .button(player2_b),
        .debounced(player2_b_deb)
    );

    rot_encoder encoder_1(
        .clk(clk12mhz),
        .reset(reset),
        .a(player1_a_deb),
        .b(player1_b_deb),
        .value(player1_encoder)
    );

    rot_encoder encoder_2(
        .clk(clk12mhz),
        .reset(reset),
        .a(player2_a_deb),
        .b(player2_b_deb),
        .value(player2_encoder)
    );

    paddle paddlemod_1(
        .clk(clk12mhz),
        .reset(reset),
        .encoder_value(player1_encoder),
        .width(1'b0),
        .paddle_o(paddle_1)
    );

    paddle paddlemod_2(
        .clk(clk12mhz),
        .reset(reset),

        // input:
        .encoder_value(player2_encoder),
        .width(1'b0),

        // output:
        .paddle_o(paddle_2)
    );

    game game0(
        .game_clk(game_clk),
        .reset(reset),
        .entropy(entropy),

        // input:
        .lpaddle(paddle_1),
        .rpaddle(paddle_2),
        .start(start),

        // output:
        .x(x),
        .y(y),
        .out_left(out_left),
        .out_right(out_right),
        .score_p1(score_p1),
        .score_p2(score_p2)
    );

    score score0(
        .clk(game_clk),
        .reset(reset),

        // input:
        .score_p1(score_p1),
        .score_p2(score_p2),

        // output:
        .seg_a(seg_a),
        .seg_b(seg_b),
        .seg_c(seg_c),
        .seg_d(seg_d),
        .seg_e(seg_e),
        .seg_f(seg_f),
        .seg_g(seg_g),
        .cath(cath)
    );

    screen #(.TIMERWIDTH(SCREENTIMERWIDTH)) screen0(
        .clk(clk12mhz),
        .reset(reset),
        .x(x[7:4]),
        .y(y[7:4]),
        .lpaddle(paddle_1),
        .rpaddle(paddle_2),
        .rclk(RCLK),
        .rsdi(RSDI),
        .oeb(OEB),
        .csdi(CSDI),
        .cclk(CCLK),
        .le(LE)
    );

    vga vga0(
        .clk(clk32mhz),
        .reset(reset),
        .ball_x(x),
        .ball_y(y),
        .lpaddle(paddle_1),
        .rpaddle(paddle_2),
        .switch_background(out_left || out_right),

        .hsync(hsync),
        .vsync(vsync),
        .rrggbb(rrggbb)
    );

endmodule
