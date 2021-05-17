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

    reg [7:0] rom [16:0];
    wire [7:0] sinlut [63:0];
    wire [7:0] coslut [63:0];

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin
            assign sinlut[i]    =  rom[i];
            assign sinlut[31-i] =  rom[i+1];
            assign sinlut[32+i] = ~rom[i];
            assign sinlut[63-i] = ~rom[i+1];
        end
    endgenerate

    genvar j;
    generate
        for (j=0; j<64; j=j+1) begin
            assign coslut[j] = sinlut[(j+80) % 64];
        end
    endgenerate

    initial begin
        $readmemb("sine.lut", rom);
    end

    assign sin_o = sinlut[theta_i];
    assign cos_o = coslut[theta_i];

endmodule
