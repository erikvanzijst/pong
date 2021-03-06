`default_nettype none
`timescale 1ns / 1ps

module screen #(parameter integer TIMERWIDTH = 12)
    (
    input clk,  // 12MHz
    input reset,
    input wire [4:0] x,
    input wire [4:0] y,
    input wire [31:0] lpaddle,
    input wire [31:0] rpaddle,
    output reg rclk,
    output reg rsdi,
    output wire oeb,
    output reg csdi,
    output reg cclk,
    output reg le);

    reg [TIMERWIDTH+4:0] rowtimer;  // ~1465 lines/s, or ~92Hz screen refresh rate

    wire [3:0] row;
    wire [TIMERWIDTH-1:0] col;
    wire pclk;
    assign row = rowtimer[TIMERWIDTH+4:TIMERWIDTH+1];
    assign col = rowtimer[TIMERWIDTH:1];
    assign pclk = rowtimer[0];

    // Adjust for hardware wiring error in dotmatrix v01:
    // https://github.com/erikvanzijst/dotmatrix/commit/3c7690eb47
    wire [3:0] corrected_row;
    assign corrected_row = row + (row[0] ? -1 : 1'b1);

    assign oeb = 0;

    initial begin
        rowtimer <= 0;
        rclk <= 0;
        rsdi <= 0;
        cclk <= 0;
        csdi <= 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rowtimer <= 0;
            rclk <= 0;
            rsdi <= 0;
            cclk <= 0;
            csdi <= 0;

        end else begin
            rowtimer <= rowtimer + 1;
            if (pclk == 0) begin
                rsdi <= !(col == 0 && row == 0);
                rclk <= 0;
                cclk <= 0;

                csdi <= (col>>4 == 0) && (
                    // ball:
                    (corrected_row == y[4:1] && x[4:1] == 4'hf - col[3:0]) ||

                    // right paddle:
                    (col == 4'hf && rpaddle[{corrected_row, 1'b0}]) ||

                    // left paddle:
                    (col == 4'h0 && lpaddle[{corrected_row, 1'b0}])
                    );

            end else begin
                rclk <= col == 0 ? 1 : 0;
                cclk <= (col>>4 == 0) ? 1 : 0;
                le <= col == 16 ? 1 : 0;

            end
        end
    end

endmodule
