`default_nettype none
`timescale 1ns / 1ps

module game (
    input game_clk, // 1000Hz clock
    input reset,

    input wire [15:0] lpaddle,
    input wire [15:0] rpaddle,

    input wire start,   // debounced start button

    // screen output:
    output wire [3:0] x,
    output wire [3:0] y,

    output reg [3:0] score_p1,
    output reg [3:0] score_p2
);

    reg signed [4:0] speed;

    // freeze countdown between games and when ball is out (max 16.846 seconds):
    reg [13:0] freeze;
    reg ball_reset;

    wire out_left, out_right;

    initial begin
        score_p1 <= 0;
        score_p2 <= 0;
        speed <= 0;
        ball_reset <= 0;
    end

    always @(posedge game_clk) begin
        if (reset) begin
            freeze <= 14'h3FFF;
            score_p1 <= 0;
            score_p2 <= 0;
            speed <= 0;
            ball_reset <= 1;

        end else begin

            if (freeze == 0) begin
                if (out_left) begin
                    score_p1 <= score_p1 + 1;

                    freeze <= score_p1 == 8 ? 14'h3FFF : 2000; // start 2 second timeout
                    speed <= 0;
                end else if (out_right) begin
                    score_p2 <= score_p2 + 1;

                    freeze <= score_p2 == 8 ? 14'h3FFF : 2000; // start 2 second timeout
                    speed <= 0;
                end else begin
                    speed <= 11;    // restart the game
                end

            end else begin
                // players can cut short the countdown:
                freeze <= start ? 1 : freeze - 1;

                // new game starts; reset scores:
                if ((score_p1 == 9 || score_p2 == 9) && freeze == 1) begin
                    score_p1 <= 0;
                    score_p2 <= 0;
                end
            end

            // reset ball to center position:
            ball_reset <= freeze == 1;
        end
    end

    ball ball0(
        .clk(game_clk),
        .reset(ball_reset),

        .speed(speed),
        .lpaddle(lpaddle),
        .rpaddle(rpaddle),

        .x(x),
        .y(y),
        .out_left(out_left),
        .out_right(out_right),
    );

endmodule
