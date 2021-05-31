`default_nettype none
`timescale 1ns / 1ps

module customclk
    #(parameter integer WIDTH = 16,
      parameter integer TOP = 12000)
    (
        input clk,
        output clkout
    );

    reg [WIDTH-1:0] counter;
    assign clkout = (counter == TOP);

    initial begin
        counter <= 0;
    end

    always @(posedge clk) begin
        counter <= (counter == TOP) ? 0 : counter + 1;
    end
endmodule
