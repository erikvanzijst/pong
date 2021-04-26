`default_nettype none
`timescale 1ns / 1ps

module ball #(parameter THETA_WIDTH = 6)
	(
	input wire clk, // should be 1000Hz for optimally playable speed
	input wire reset,

    // the ball's current vector:
    input signed [4:0] speed,       // length of the direction vector (speed range: -16 to 15)

    output wire [3:0] x,
    output wire [3:0] y
    );

    reg [THETA_WIDTH-1:0] theta;   // angular direction in 64 increments

    reg [20:0] horizontal;  // 4 high bits is x pos on screen
    reg [20:0] vertical;    // 4 high bits is y pos on screen

    assign x = horizontal[20:17];
    assign y = vertical[20:17];

    wire signed [7:0] sin_theta;
    wire signed [7:0] cos_theta;
    wire signed [20:0] dx;
    wire signed [20:0] dy;

    assign dx = cos_theta * speed;
    assign dy = sin_theta * speed;

    sin #(.THETA_WIDTH(THETA_WIDTH)) sinlut (.CLK(clk), .theta_i(theta), .sin_o(sin_theta));
    cos #(.THETA_WIDTH(THETA_WIDTH)) coslut (.CLK(clk), .theta_i(theta), .cos_o(cos_theta));

    always @(posedge clk) begin
        if (reset) begin
            // place the ball at the center of the screen:
            horizontal <= 8 << 17;
            vertical <= 8 << 17;

            // start off in horizontal direction:
            theta <= 0;

        end else begin
            horizontal <= horizontal + dx;
            vertical <= vertical + dy;
        end
    end
endmodule
