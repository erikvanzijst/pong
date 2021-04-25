`default_nettype none
`timescale 1ns / 1ps

module clkdiv
    #(parameter WIDTH = 16,
      parameter RESETVAL = 16'h7fff)
    (
    input wire clk,
    input wire reset,
    output clkout
    );

    reg [WIDTH-1:0] counter;
    assign clkout = counter[WIDTH-1];

    always @(posedge clk) begin
        if (reset) begin
            counter <= RESETVAL;
        end else begin
            counter <= counter+1;
        end
    end
endmodule
