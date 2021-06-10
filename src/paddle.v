`default_nettype none
`timescale 1ns / 1ps

module paddle (
    input clk,
    input reset,

    input signed [1:0] encoder_value,

    output [31:0] paddle_o
);
    localparam PADDLE = 32'b00000000000011111111000000000000;

    reg [31:0] ram;
    assign paddle_o = ram;

    reg signed [1:0] prev;
    wire signed [1:0] diff;
    assign diff = encoder_value - prev;

    initial begin
        ram <= PADDLE;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prev <= 2'b00;
            ram <= PADDLE;

        end else begin
            prev <= encoder_value;

            if (diff == 2'b01 && !paddle_o[0]) begin
                ram <= {ram[0], ram[31:1]};

            end else if (diff == 2'b11 && !paddle_o[31]) begin
                ram <= {ram[30:0], ram[31]};
            end
        end
    end

endmodule
