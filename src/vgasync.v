`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Ridotech
// Engineer: Juan Manuel Rico
//
// Create Date:    09:34:23 30/09/2017
// Module Name:    vga_controller
// Description:    Basic control for 640x480@72Hz VGA signal.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created for Roland Coeurjoly (RCoeurjoly) in 640x480@85Hz.
// Revision 0.02 - Change for 640x480@60Hz.
// Revision 0.03 - Solved some mistakes.
// Revision 0.04 - Change for 640x480@72Hz and output signals 'activevideo'
//                 and 'px_clk'.
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module vgasync (
            input wire       px_clk,        // Input clock: 31.5MHz
            input wire       reset,         // reset
            output wire      hsync,         // Horizontal sync out
            output wire      vsync,         // Vertical sync out
            output reg [9:0] x_px,          // X position for actual pixel.
            output reg [9:0] y_px,          // Y position for actual pixel.
            output wire      activevideo
         );

    /*
    http://www.epanorama.net/faq/vga2rgb/calc.html
    [*User-Defined_mode,(640X480)]
    PIXEL_CLK   =   31500
    H_DISP      =   640
    V_DISP      =   480
    H_FPORCH    =   24
    H_SYNC      =   40
    H_BPORCH    =   128
    V_FPORCH    =   9
    V_SYNC      =   3
    V_BPORCH    =   28
    */

    // Video structure constants.
    parameter ACTIVEHVIDEO = 640;               // Width of visible pixels.
    parameter ACTIVEVVIDEO =  480;              // Height of visible lines.
    parameter HFP = 24;                         // Horizontal front porch length.
    parameter HPULSE = 40;                      // Hsync pulse length.
    parameter HBP = 128;                        // Horizontal back porch length.
    parameter VFP = 9;                          // Vertical front porch length.
    parameter VPULSE = 3;                       // Vsync pulse length.
    parameter VBP = 28;                         // Vertical back porch length.
    parameter BLACKH = HFP + HPULSE + HBP;      // Hide pixels in one line.
    parameter BLACKV = VFP + VPULSE + VBP;      // Hide lines in one frame.
    parameter HPIXELS = BLACKH + ACTIVEHVIDEO;  // Total horizontal pixels.
    parameter VLINES = BLACKV + ACTIVEVVIDEO;   // Total lines.

    // Registers for storing the horizontal & vertical counters.
    reg [9:0] hc;
    reg [9:0] vc;

    // Initial values.
    initial
    begin
      x_px = 0;
      y_px = 0;
      hc = 0;
      vc = 0;
    end

    // Counting pixels.
    always @(posedge px_clk)
    begin
        if(reset) begin
            hc <= 0;
            vc <= 0;
        end else begin
            // Keep counting until the end of the line.
            if (hc < HPIXELS - 1)
                hc <= hc + 1;
            else
            // When we hit the end of the line, reset the horizontal
            // counter and increment the vertical counter.
            // If vertical counter is at the end of the frame, then
            // reset that one too.
            begin
                hc <= 0;
                if (vc < VLINES - 1)
                vc <= vc + 1;
            else
               vc <= 0;
            end
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync = (hc >= HFP && hc < HFP + HPULSE) ? 0:1;
    assign vsync = (vc >= VFP && vc < VFP + VPULSE) ? 0:1;
    assign activevideo = (hc >= BLACKH && vc >= BLACKV) ? 1:0;

    // Generate color.
    always @(posedge px_clk)
    begin
        if(reset) begin
            x_px <= 0;
            y_px <= 0;
        end else begin
            x_px <= hc - BLACKH;
            y_px <= vc - BLACKV;
        end
     end
 endmodule
`default_nettype wire
