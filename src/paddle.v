`default_nettype none
`timescale 1ns / 1ps

module paddle (
    input clk,
    input reset,

    input signed [1:0] encoder_value,

    output wire[31:0] paddle_o
);

    reg [31:0] ram [0:0];

    assign paddle_o = ram[0];

    reg signed [1:0] prev;
    wire signed [1:0] diff;
    assign diff = encoder_value - prev;

    initial begin
        $readmemb("paddles.rom", ram);
    end

    always @(posedge clk) begin
        prev <= encoder_value;

        if (diff == 1 && !paddle_o[0]) begin
            ram[0] <= {ram[0][0], ram[0][31:1]};

        end else if (diff == -1 && !paddle_o[31]) begin
            ram[0] <= {ram[0][30:0], ram[0][31]};
        end
    end

endmodule
