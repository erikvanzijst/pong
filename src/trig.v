`default_nettype none
`timescale 1ns / 1ps

/*
 * Returns the sine and cosine of theta_i. The result is an 8 bit wide, two's complement
 * value.
 */
module trig
    (input wire CLK,
     input wire [5:0] theta_i,
     output wire [7:0] sin_o,
     output wire [7:0] cos_o
     );

    wire [7:0] sinlut [63:0];
    wire [7:0] coslut [63:0];

    assign sinlut[0]    = 8'b00000000;
    assign sinlut[1]    = 8'b00001100;
    assign sinlut[2]    = 8'b00011000;
    assign sinlut[3]    = 8'b00100100;
    assign sinlut[4]    = 8'b00110000;
    assign sinlut[5]    = 8'b00111011;
    assign sinlut[6]    = 8'b01000110;
    assign sinlut[7]    = 8'b01010000;
    assign sinlut[8]    = 8'b01011001;
    assign sinlut[9]    = 8'b01100010;
    assign sinlut[10]   = 8'b01101001;
    assign sinlut[11]   = 8'b01110000;
    assign sinlut[12]   = 8'b01110101;
    assign sinlut[13]   = 8'b01111001;
    assign sinlut[14]   = 8'b01111100;
    assign sinlut[15]   = 8'b01111110;
    assign sinlut[16]   = 8'b01111111;

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin
            assign sinlut[31-i] =  sinlut[i+1];
            assign sinlut[32+i] = ~sinlut[i];
            assign sinlut[63-i] = ~sinlut[i+1];
        end
    endgenerate

    genvar j;
    generate
        for (j=0; j<64; j=j+1) begin
            assign coslut[j] = sinlut[(j+80) % 64];
        end
    endgenerate

    assign sin_o = sinlut[theta_i];
    assign cos_o = coslut[theta_i];

endmodule
