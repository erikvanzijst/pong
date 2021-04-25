`default_nettype none
`timescale 1ns / 1ps

module ball #(parameter SPEED = 22)
	(
	input wire clk,
	input wire reset,
    output wire [3:0] x,
    output wire [3:0] y
    );

    reg [SPEED-1:0] counter;
    reg [3:0] xx;
    reg [3:0] yy;
    assign x = xx;
    assign y = yy;

    wire [5:0] theta;
    assign theta = 2;
    wire [7:0] result;

    sin #(.THETA_WIDTH(6)) sinlut (.CLK(clk), .theta_i(theta), .sin_o(result));

    always @(posedge clk) begin
        if (reset) begin
            xx <= 0;
            yy <= 0;
            counter <= 1;

        end else begin
            counter <= counter + 1;

            if (counter == 0) begin
                xx <= xx + 1;
                yy <= yy + 1;
            end
        end
    end
endmodule
