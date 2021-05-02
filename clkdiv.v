`default_nettype none
`timescale 1ns / 1ps

module clkdiv
    #(parameter integer WIDTH = 16)
    (
    input wire clk,
    output clkout
    );

    reg [WIDTH-1:0] counter;
    assign clkout = counter[WIDTH-1];

    always @(posedge clk) begin
        counter <= counter + 1;
    end
endmodule

module customclk
    #(parameter integer TOP = 12000)
    (
        input clk,
        output clkout
    );

    reg [31:0] counter;
    assign clkout = (counter == TOP);

    initial begin
        counter <= 0;
    end

    always @(posedge clk) begin
        counter <= (counter == TOP) ? 0 : counter + 1;
    end
endmodule
