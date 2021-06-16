`default_nettype none
`timescale 1ns / 1ps

module score (
    input clk,
    input reset,

    input [3:0] score_p1,
    input [3:0] score_p2,

    output wire [3:0] score_o,
    output wire cath1,
    output wire cath2
);

    reg clk_toggle;
    reg [9:0] blinker;

    // Blink the scores when the game is over:
    wire on;
    assign on = (score_p1 < 9 && score_p2 < 9) || blinker[9];

    assign score_o = clk_toggle ? score_p1 : score_p2;
    assign cath1 = on && clk_toggle;
    assign cath2 = on && !clk_toggle;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_toggle <= 0;
            blinker <= 0;

        end else begin
            // Divide the incoming clk to ensure we get a 50% duty cycle, even if
            // the incoming clk doesn't have that:
            clk_toggle <= ~clk_toggle;

            blinker <= blinker + 1;
        end
    end
endmodule
