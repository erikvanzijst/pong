`default_nettype none
`timescale 1ns / 1ps

/*
 * Returns the sine and cosine of theta_i. The result is an 8 bit wide, two's complement
 * value.
 */
module trig
    (input wire CLK,
     input wire [4:0] theta_i,
     output wire [7:0] sin_o,
     output wire [7:0] cos_o
     );

    reg [7:0] rom [8:0];
    wire [7:0] sinlut [31:0];
    wire [7:0] coslut [31:0];

    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin
            assign sinlut[i]    =  rom[i];
            assign sinlut[15-i] =  rom[i+1];
            assign sinlut[16+i] = ~rom[i];
            assign sinlut[31-i] = ~rom[i+1];
        end
    endgenerate

    genvar j;
    generate
        for (j=0; j<32; j=j+1) begin
            assign coslut[j] = sinlut[(j+32+8) % 32];
        end
    endgenerate

    initial begin
        $readmemb("sine.lut", rom);
    end

    assign sin_o = sinlut[theta_i];
    assign cos_o = coslut[theta_i];

endmodule
