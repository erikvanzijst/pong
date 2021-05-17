`default_nettype none
`timescale 1ns / 1ps

module paddle (
    input clk,
    input reset,
    input [1:0] width,      // 4 different paddle widths

    input signed [1:0] encoder_value,

    output wire[15:0] paddle_o
);

    reg [32*4-1:0] ram [0:0];

    wire [15:0] paddles [3:0];
    assign paddles[0] = ram[0][32*4-1-8:32*3+8];
    assign paddles[1] = ram[0][32*3-1-8:32*2+8];
    assign paddles[2] = ram[0][32*2-1-8:32+8];
    assign paddles[3] = ram[0][31-8:8];

    assign paddle_o = paddles[width];

    reg signed [1:0] prev;
    wire signed [1:0] diff;
    assign diff = encoder_value - prev;

    initial begin
        $readmemb("paddles.rom", ram);
    end

    always @(posedge clk) begin
        prev <= encoder_value;

        if (diff == 1 && !paddle_o[0]) begin
            ram[0] <= {ram[0][0], ram[0][32*4-1:1]};

        end else if (diff == -1 && !paddle_o[15]) begin
            ram[0] <= {ram[0][32*4-2:0], ram[0][32*4-1]};
        end
    end

endmodule
