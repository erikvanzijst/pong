`default_nettype none
`timescale 1ns / 1ps

module top
	#(parameter SCREENTIMERWIDTH = 10,
	  parameter BALLSPEED = 20)
	(
	input wire CLK,
	input wire reset,

	output wire RCLK,
	output wire RSDI,
	output wire OEB,
	output wire CSDI,
	output wire CCLK,
	output wire LE
    );

	wire [3:0] x, y;

	ball #(.SPEED(BALLSPEED)) ball0(
		.clk(CLK),
		.reset(reset),
		.x(x),
		.y(y)
	);

	screen #(.TIMERWIDTH(SCREENTIMERWIDTH)) screen0(
		.clk(CLK),
		.reset(reset),
		.x(x),
		.y(y),
		.rclk(RCLK),
		.rsdi(RSDI),
		.oeb(OEB),
		.csdi(CSDI),
		.cclk(CCLK),
		.le(LE)
	);

endmodule
