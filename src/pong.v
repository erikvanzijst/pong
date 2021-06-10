`default_nettype none
`timescale 1ns / 1ps

`ifndef SCREENTIMERWIDTH
    `define SCREENTIMERWIDTH 10
`endif

`ifndef GAMECLK
    `define GAMECLK 10000
`endif

`ifndef DEBOUNCEWIDTH
    `define DEBOUNCEWIDTH 16
`endif

module pong
    #(parameter integer SCREENTIMERWIDTH = `SCREENTIMERWIDTH,
      parameter integer GAMECLK = `GAMECLK,
      parameter integer DEBOUNCEWIDTH = `DEBOUNCEWIDTH)
    (
    input wire clk32mhz,
    input wire reset,
    input wire start,

    input wire [3:0] difficulty,

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

    wire clk10mhz;  // clk32mhz / 3 for the slower game logic
    wire [4:0] entropy;

    wire player1_a_deb;
    wire player1_b_deb;
    wire player2_a_deb;
    wire player2_b_deb;

    wire out_left, out_right;
    wire [3:0] score_p1, score_p2;

    wire [4:0] x, y;
    wire game_clk;

    wire [31:0] paddle_1;
    wire [31:0] paddle_2;

    wire signed [1:0] player1_encoder, player2_encoder;

    rnd random(
        .clk(game_clk),
        .reset(reset),
        .q(entropy)
    );

    customclk #(.WIDTH(2), .TOP(2)) clk10_mod(
        .clk(clk32mhz),
        .reset(reset),
        .clkout(clk10mhz)
    );

    // A 1500Hz clock to driver the game and 7-segment cathode modulation:
    customclk #(.WIDTH(17), .TOP(GAMECLK)) game_clk_mod(
        .clk(clk32mhz),
        .reset(reset),
        .clkout(game_clk)
    );

    debounce #(.HIST_LEN(DEBOUNCEWIDTH)) debounce_1a (
        .clk(clk10mhz),
        .reset(reset),
        .button(player1_a),
        .debounced(player1_a_deb)
    );

    debounce #(.HIST_LEN(DEBOUNCEWIDTH)) debounce_1b (
        .clk(clk10mhz),
        .reset(reset),
        .button(player1_b),
        .debounced(player1_b_deb)
    );

    debounce #(.HIST_LEN(DEBOUNCEWIDTH)) debounce_2a (
        .clk(clk10mhz),
        .reset(reset),
        .button(player2_a),
        .debounced(player2_a_deb)
    );

    debounce #(.HIST_LEN(DEBOUNCEWIDTH)) debounce_2b (
        .clk(clk10mhz),
        .reset(reset),
        .button(player2_b),
        .debounced(player2_b_deb)
    );

    rot_encoder encoder_1(
        .clk(clk10mhz),
        .reset(reset),
        .a(player1_a_deb),
        .b(player1_b_deb),
        .value(player1_encoder)
    );

    rot_encoder encoder_2(
        .clk(clk10mhz),
        .reset(reset),
        .a(player2_a_deb),
        .b(player2_b_deb),
        .value(player2_encoder)
    );

    paddle paddlemod_1(
        .clk(clk10mhz),
        .reset(reset),
        .encoder_value(player1_encoder),
        .paddle_o(paddle_1)
    );

    paddle paddlemod_2(
        .clk(clk10mhz),
        .reset(reset),
        .encoder_value(player2_encoder),
        .paddle_o(paddle_2)
    );

    game game0(
        .game_clk(game_clk),
        .reset(reset),
        .entropy(entropy),
        .difficulty(difficulty),

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
        .clk(clk10mhz),
        .reset(reset),
        .x(x),
        .y(y),
        .lpaddle(paddle_1),
        .rpaddle(paddle_2),
        .rclk(RCLK),
        .rsdi(RSDI),
        .oeb(OEB),
        .csdi(CSDI),
        .cclk(CCLK),
        .le(LE)
    );

    parameter BLACK         = 6'b000000;
    parameter LIGHTGREY     = 6'b010101;
    parameter GREY          = 6'b101010;
    parameter LIGHTRED      = 6'b100000;
    parameter RED           = 6'b110000;
    parameter LIGHTGREEN    = 6'b001000;
    parameter GREEN         = 6'b001100;
    parameter LIGHTBLUE     = 6'b000010;
    parameter BLUE          = 6'b000011;
    parameter LIGHTYELLOW   = 6'b101000;
    parameter YELLOW        = 6'b111100;
    parameter LIGHTMAGENTA  = 6'b100010;
    parameter MAGENTA       = 6'b110011;
    parameter LIGHTCYAN     = 6'b001010;
    parameter CYAN          = 6'b001111;
    parameter WHITE         = 6'b111111;

    function [5:0] bgcolor (input [3:0] difficulty);
        case (difficulty)
            4'h0: bgcolor = LIGHTGREY;
            4'h1: bgcolor = LIGHTRED;
            4'h2: bgcolor = LIGHTGREEN;
            4'h3: bgcolor = LIGHTBLUE;
            4'h4: bgcolor = LIGHTYELLOW;
            4'h5: bgcolor = LIGHTCYAN;
            4'h6: bgcolor = LIGHTMAGENTA;
            4'h7: bgcolor = GREY;
            4'h8: bgcolor = BLACK;
            4'h9: bgcolor = RED;
            4'ha: bgcolor = GREEN;
            4'hb: bgcolor = BLUE;
            4'hc: bgcolor = YELLOW;
            4'hd: bgcolor = CYAN;
            4'he: bgcolor = MAGENTA;
            4'hf: bgcolor = BLACK;
        endcase
    endfunction

    vga vga0(
        .clk(clk32mhz),
        .reset(reset),
        .ball_x(x),
        .ball_y(y),
        .lpaddle(paddle_1),
        .rpaddle(paddle_2),
        .bgcolor(bgcolor(difficulty)),

        .hsync(hsync),
        .vsync(vsync),
        .rrggbb(rrggbb)
    );

endmodule
