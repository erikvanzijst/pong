`default_nettype none
`timescale 1ns / 1ps

module paddle (
    input clk,
    input reset,
    input width,      // 2 different paddle widths

    input signed [1:0] encoder_value,

    output reg[15:0] paddle_o
);

    reg [24*2-1:0] ram [0:0];

    wire [15:0] paddles [1:0];
    assign paddles[0] = ram[0][24*2-1-4:24+4];
    assign paddles[1] = ram[0][23-4:4];

    reg signed [1:0] prev;
    wire signed [1:0] diff;
    assign diff = encoder_value - prev;

    initial begin
        $readmemb("paddles.rom", ram);
    end

    always @(posedge clk) begin
        paddle_o <= paddles[width];
        prev <= encoder_value;

        if (diff == 1 && !paddle_o[0]) begin
            ram[0] <= {ram[0][0], ram[0][24*2-1:1]};

        end else if (diff == -1 && !paddle_o[15]) begin
            ram[0] <= {ram[0][24*2-2:0], ram[0][24*2-1]};
        end
    end

endmodule
