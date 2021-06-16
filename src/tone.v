`default_nettype none
`timescale 1ns / 1ps

module tone (
    input clk,      // 3.16kHz game clock
    input reset,
    input tone,     // which of the two tones to select (0: B4, 1: B5)
    input start,    // commence playing if high

    output reg buzzer
    );

    localparam B4 = 3;  // Wall
    localparam B5 = 2;  // Paddle

    // Tones are played for 80ms (258 game_clock ticks)
    localparam DURATION = 258;

    reg [2:0] tonecounter;
    reg [8:0] durationcounter;
    reg current_tone;

    wire [2:0] period;
    assign period = current_tone ? B5 : B4;

    always @(posedge clk) begin
        if (reset) begin
            tonecounter     <= 16'b0;
            durationcounter <= 23'b0;
            current_tone    <= 1'b0;

        end else begin
            current_tone <= start ? tone : current_tone;

            durationcounter <= start ?
                DURATION :
                (durationcounter ? durationcounter - 1'b1 : durationcounter);

            tonecounter <= tonecounter == 16'b0 ? period : tonecounter - 1'b1;
            if (durationcounter && tonecounter == 16'b0) begin
                buzzer <= !buzzer;
            end
        end
    end
endmodule
