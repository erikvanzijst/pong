`default_nettype none
`timescale 1ns / 1ps

module fpga (
    input wire clk,
    input wire reset,
    input wire start,

    input wire player1_a,
    input wire player1_b,
    input wire player2_a,
    input wire player2_b,

    input wire [3:0] difficulty,

    // BCD scoreboards:
    output wire [3:0] score,
    output wire cath1,
    output wire cath2,

    // Dot-matrix display out:
//    output wire RCLK,
//    output wire RSDI,
//    output wire OEB,
//    output wire CSDI,
//    output wire CCLK,
//    output wire LE,

    // VGA out:
    output wire hsync,
    output wire vsync,
    output wire [5:0] rrggbb
);
    wire clk10mhz, clk12mhz, clk32mhz;

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

    // Disconnected dot matrix display as we use the PMOD 1B for the difficulty dial:
    wire RCLK;
    wire RSDI;
    wire OEB;
    wire CSDI;
    wire CCLK;
    wire LE;

    // Unconnected wires for debugging:
    wire [4:0] x;
    wire [4:0] y;

    pong pong0(
        .clk32mhz(clk32mhz),
        .reset(reset),

        .start(start),
        .difficulty(difficulty),

        .player1_a(player1_a),
        .player1_b(player1_b),
        .player2_a(player2_a),
        .player2_b(player2_b),

        .score(score),
        .cath1(cath1),
        .cath2(cath2),

        .RCLK(RCLK),
        .RSDI(RSDI),
        .OEB(OEB),
        .CSDI(CSDI),
        .CCLK(CCLK),
        .LE(LE),

        // VGA out:
        .hsync(hsync),
        .vsync(vsync),
        .rrggbb(rrggbb),

        .x(x),
        .y(y)
    );

endmodule
