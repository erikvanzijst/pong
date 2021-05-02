`default_nettype none
`timescale 1ns / 1ps

/*
 * Returns the sine of theta_i. The result is an 8 bit wide, two's complement
 * value.
 */
module sin
    #(parameter string FILE = "sine.lut",
      parameter integer THETA_WIDTH = 6)
    (input wire CLK,
     input wire [THETA_WIDTH-1:0] theta_i,
     output wire [7:0] sin_o);

    reg [7:0] sine_lut [(1 << THETA_WIDTH)-1:0];

    initial begin
        $readmemb(FILE, sine_lut);
    end

    assign sin_o = sine_lut[theta_i];

endmodule

/*
 * Returns the cosine of theta_i. The result is an 8 bit wide, two's complement
 * value.
 */
module cos
    #(parameter string FILE = "cosine.lut",
      parameter integer THETA_WIDTH = 6)
    (input wire CLK,
     input wire [THETA_WIDTH-1:0] theta_i,
     output wire [7:0] cos_o);

    reg [7:0] cosine_lut [(1 << THETA_WIDTH)-1:0];

    initial begin
        $readmemb(FILE, cosine_lut);
    end

    assign cos_o = cosine_lut[theta_i];

endmodule
