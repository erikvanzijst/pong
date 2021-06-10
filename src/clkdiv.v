`default_nettype none
`timescale 1ns / 1ps

module customclk
    #(parameter integer WIDTH = 16,
      parameter integer TOP = 12000)
    (
        input clk,
        input reset,
        output clkout
    );

    reg [WIDTH-1:0] counter;
    assign clkout = (counter == TOP);

    initial begin
        counter <= 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
        end else begin
            counter <= (counter == TOP) ? 1'b0 : (counter + 1'b1);
        end
    end
endmodule
