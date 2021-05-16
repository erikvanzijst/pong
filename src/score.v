`default_nettype none
`timescale 1ns / 1ps

module score (
    input clk,
    input reset,

    input [3:0] score_p1,
    input [3:0] score_p2,

    output wire seg_a,
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
    output wire seg_e,
    output wire seg_f,
    output wire seg_g,
    output wire cath
);

    reg clk_toggle;
    reg [9:0] blinker;

    wire [6:0] dout;
    assign {seg_g, seg_f, seg_e, seg_d, seg_c, seg_b, seg_a} = dout;
    wire [6:0] dout_p1, dout_p2;

    // Blink the scores when the game is over:
    wire on;
    assign on = (score_p1 < 9 && score_p2 < 9) || blinker[9];

    assign dout_p1 = on ? seven_seg(score_p1) : 6'b0;
    assign dout_p2 = on ? seven_seg(score_p2) : 6'b0;

    assign dout = clk_toggle ? dout_p2 : dout_p1;
    assign cath = clk_toggle;

    initial begin
        clk_toggle <= 0;
        blinker <= 0;
    end

    always @(posedge clk) begin
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

    function [6:0] seven_seg (input [3:0] din);
		case (din)
			4'h0: seven_seg = 7'b 0111111;
			4'h1: seven_seg = 7'b 0000110;
			4'h2: seven_seg = 7'b 1011011;
			4'h3: seven_seg = 7'b 1001111;
			4'h4: seven_seg = 7'b 1100110;
			4'h5: seven_seg = 7'b 1101101;
			4'h6: seven_seg = 7'b 1111101;
			4'h7: seven_seg = 7'b 0000111;
			4'h8: seven_seg = 7'b 1111111;
			4'h9: seven_seg = 7'b 1101111;

            // unused:
			default: seven_seg = 7'b 0000000;
		endcase
    endfunction

endmodule
