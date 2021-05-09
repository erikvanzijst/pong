`default_nettype none
`timescale 1ns / 1ps

module pong
    #(parameter integer SCREENTIMERWIDTH = 10,
      parameter integer BALLSPEED = 20)
    (
    input wire clk,
    input wire BTN1,

    input wire player1_a,
    input wire player1_b,
    input wire player2_a,
    input wire player2_b,

    output wire RCLK,
    output wire RSDI,
    output wire OEB,
    output wire CSDI,
    output wire CCLK,
    output wire LE
    );

    wire reset;
    assign reset = BTN1;

    wire player1_a_deb;
    wire player1_b_deb;
    wire player2_a_deb;
    wire player2_b_deb;

    wire [3:0] x, y;
    wire game_clk;
    wire debounce_clk;
    wire signed [4:0] speed;
    assign speed = 11;

    wire [15:0] paddle_1;
    wire [15:0] paddle_2;

    // reg signed [1:0] prev;
    wire signed [1:0] diff, player1_encoder, player2_encoder;
    // wire up, down;

    // assign diff = player1_encoder - prev;
    // assign up = diff > 0;
    // assign down = diff == -1;

    // always @(posedge clk) begin
    //     if (reset) begin
    //         prev <= 1'b0;

    //     end else begin
    //         prev <= curr;
    //     end
    // end

    // A 1000Hz clock to driver the game:
    customclk #(.TOP(6000)) game_clk_mod(
        .clk(clk),
        .clkout(game_clk)
    );

    customclk #(.TOP(7)) debounce_clk_mod(
        .clk(clk),
        .clkout(debounce_clk)
    );

    debounce #(.HIST_LEN(9)) debounce_1a (
        .clk(clk),
        .reset(reset),
        .button(player1_a),
        .debounced(player1_a_deb)
    );

    debounce #(.HIST_LEN(9)) debounce_1b (
        .clk(debounce_clk),
        .reset(reset),
        .button(player1_b),
        .debounced(player1_b_deb)
    );

    debounce #(.HIST_LEN(9)) debounce_2a (
        .clk(debounce_clk),
        .reset(reset),
        .button(player2_a),
        .debounced(player2_a_deb)
    );

    debounce #(.HIST_LEN(9)) debounce_2b (
        .clk(debounce_clk),
        .reset(reset),
        .button(player2_b),
        .debounced(player2_b_deb)
    );

    rot_encoder encoder_1(
        .clk(clk),
        .reset(reset),
        .a(player1_a_deb),
        .b(player1_b_deb),
        .value(player1_encoder)
    );

    rot_encoder encoder_2(
        .clk(clk),
        .reset(reset),
        .a(player2_a_deb),
        .b(player2_b_deb),
        .value(player2_encoder)
    );

    paddle paddlemod_1(
        .clk(clk),
        .reset(reset),
        .encoder_value(player1_encoder),
        .width(2'b1),
        .paddle_o(paddle_1)
    );

    paddle paddlemod_2(
        .clk(clk),
        .reset(reset),
        .encoder_value(player2_encoder),
        .width(2'b1),
        .paddle_o(paddle_2)
    );

    ball ball0(
        .clk(game_clk),
        .reset(reset),
        .speed(speed),
        .lpaddle(16'hFFFF),
        .rpaddle(paddle_2),
        .x(x),
        .y(y)
    );

    screen #(.TIMERWIDTH(SCREENTIMERWIDTH)) screen0(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .lpaddle(16'hFFFF),
        .rpaddle(paddle_2),
        .rclk(RCLK),
        .rsdi(RSDI),
        .oeb(OEB),
        .csdi(CSDI),
        .cclk(CCLK),
        .le(LE)
    );

endmodule
