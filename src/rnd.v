`default_nettype none
`timescale 1ns / 1ps

// 5-bit LFSR pseudo random number generator.
module rnd (
    input clk,
    input reset,    // reset to sequence to 5'b11111
    output reg [4:0] q
);
    initial begin
        q <= 5'h1F;
    end

    always @(posedge clk) begin
        if (reset) begin
            q <= 5'h1F;
        end else begin
            q <= {q[0], q[4], (q[0] ^ q[3]), q[2], q[1]};
        end
    end
endmodule
