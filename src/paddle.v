`default_nettype none
`timescale 1ns / 1ps

module paddle (
    input clk,
    input reset,
    input [1:0] width,      // 4 different paddle widths
    input up,               // should go low immediately following high
    input down,             // should go low immediately following high
    output wire[15:0] paddle_o
);

    reg [32*4-1:0] rom [0:0];
    reg [32*4-1:0] ram;

    wire [15:0] paddles [3:0];
    assign paddles[0] = ram[32*4-1-8:32*3+8];
    assign paddles[1] = ram[32*3-1-8:32*2+8];
    assign paddles[2] = ram[32*2-1-8:32+8];
    assign paddles[3] = ram[31-8:8];

    assign paddle_o = paddles[width];

    initial begin
        $readmemb("paddles.rom", rom);
    end

    always @(posedge clk) begin
        if (reset) begin
            ram <= rom[0];

        end else begin
            if (up && !paddle_o[0]) begin
                ram <= {ram[0], ram[32*4-1:1]};

            end else if (down && !paddle_o[15]) begin
                ram <= {ram[32*4-2:0], ram[32*4-1]};
            end
        end
    end

endmodule
