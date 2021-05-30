`default_nettype none
`timescale 1ns / 1ps

module fpga (
    input wire clk,
    input wire reset,
    input wire start,

//  Not enough pins on the iCEBreaker :-/
//    input wire player1_a,
//    input wire player1_b,
//    input wire player2_a,
//    input wire player2_b,

    // 7-segment scoreboards:
    output wire seg_a,
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
    output wire seg_e,
    output wire seg_f,
    output wire seg_g,
    output wire cath,

    // Dot-matrix display out:
    output wire RCLK,
    output wire RSDI,
    output wire OEB,
    output wire CSDI,
    output wire CCLK,
    output wire LE,

    // VGA out:
    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb
);
    wire clk12mhz, clk32mhz;

    // Generated values for pixel clock of 31.5Mhz and 72Hz frame frecuency.
    // # icepll -i12 -o31.5
    //
    // F_PLLIN:    12.000 MHz (given)
    // F_PLLOUT:   31.500 MHz (requested)
    // F_PLLOUT:   31.500 MHz (achieved)
    //
    // FEEDBACK: SIMPLE
    // F_PFD:   12.000 MHz
    // F_VCO: 1008.000 MHz
    //
    // DIVR:  0 (4'b0000)
    // DIVF: 83 (7'b1010011)
    // DIVQ:  5 (3'b101)
    //
    // FILTER_RANGE: 1 (3'b001)
    //
    `ifdef SYNTH
        SB_PLL40_2_PAD #(
            .FEEDBACK_PATH("SIMPLE"  ),
            .DIVR         (4'b0000   ),
            .DIVF         (7'b1010011),
            .DIVQ         (3'b101    ),
            .FILTER_RANGE (3'b001    )
        ) uut (
            .RESETB    (1'b1  ),
            .BYPASS    (1'b0  ),
            .PACKAGEPIN(clk   ),
            .PLLOUTGLOBALB(clk32mhz),
            .PLLOUTGLOBALA(clk12mhz)
        );
    `else
        assign clk12mhz = clk;
        assign clk32mhz = clk;
    `endif

    pong pong0(
        .clk32mhz(clk32mhz),
        .clk12mhz(clk12mhz),
        .reset(reset),

        .start(start),

        // Hardwire paddle inputs to 0 as we use the PMOD 1A port for VGA on the iCEBreaker:
        .player1_a(1'b0),
        .player1_b(1'b0),
        .player2_a(1'b0),
        .player2_b(1'b0),

        .seg_a(seg_a),
        .seg_b(seg_b),
        .seg_c(seg_c),
        .seg_d(seg_d),
        .seg_e(seg_e),
        .seg_f(seg_f),
        .seg_g(seg_g),
        .cath(cath),
        
        .RCLK(RCLK),
        .RSDI(RSDI),
        .OEB(OEB),
        .CSDI(CSDI),
        .CCLK(CCLK),
        .LE(LE),

        // VGA out:
        .hsync(hsync),
        .vsync(vsync),
        .rrggbb(rrggbb)
    );

endmodule
