`default_nettype none
`timescale 1ns / 1ps

module ball #(parameter integer THETA_WIDTH = 6)
    (
    input wire clk, // should be 2000Hz for optimally playable speed
    input wire reset,

    // the ball's current vector:
    input signed [4:0] speed,       // length of the direction vector (speed range: -16 to 15)
    input wire [15:0] lpaddle,
    input wire [15:0] rpaddle,

    output wire [3:0] x,
    output wire [3:0] y
    );

    reg [THETA_WIDTH-1:0] theta;   // angular direction in 64 increments

    reg [20:0] hor;     // 4 high bits is x pos on screen
    reg [20:0] vert;    // 4 high bits is y pos on screen

    assign x = hor[20:17];
    assign y = vert[20:17];

    wire signed [7:0] sin_theta;
    wire signed [7:0] cos_theta;
    wire signed [20:0] next_hor;
    wire signed [20:0] next_vert;

    wire signed [20:0] dx;
    wire signed [20:0] dy;
    assign dx = cos_theta * speed;
    assign dy = sin_theta * speed;

    assign next_hor = hor + dx;
    assign next_vert = vert + dy;

    wire moving_left;
    assign moving_left = !(theta[THETA_WIDTH-1] ^ theta[THETA_WIDTH-2]);
    wire moving_right;
    assign moving_right = (theta[THETA_WIDTH-1] ^ theta[THETA_WIDTH-2]);

    wire paddle_hit;
    assign paddle_hit =
        (next_hor[20:17] == 4'hF && moving_left && (lpaddle & (1 << next_vert[20:17]))) ||
        (next_hor[20:17] == 4'h0 && moving_right && (rpaddle & (1 << next_vert[20:17])));

    wire wrap_y;
    assign wrap_y = (next_vert[20:17] && !y && theta[THETA_WIDTH-1]) ||     // top
                    (!next_vert[20:17] && y && !theta[THETA_WIDTH-1]);      // bottom

    sin #(.THETA_WIDTH(THETA_WIDTH)) sinlut (.CLK(clk), .theta_i(theta), .sin_o(sin_theta));
    cos #(.THETA_WIDTH(THETA_WIDTH)) coslut (.CLK(clk), .theta_i(theta), .cos_o(cos_theta));

    // Temporary hardwired rotation:
    wire rotation_clk;
    customclk #(.TOP(500)) rotator(.clk(clk), .clkout(rotation_clk));

    always @(posedge clk) begin
        if (reset) begin
            // place the ball at the center of the screen:
            hor <= 8 << 17;
            vert <= 8 << 17;

            // start off in hor direction:
            theta <= 0;

        end else begin
            if (paddle_hit) begin
                theta <= (1 << THETA_WIDTH-1) - theta;
            end else begin
                hor <= next_hor;
            end

            if (wrap_y) begin
                theta <= (1 << THETA_WIDTH) - theta;
            end else begin
                vert <= next_vert;
            end

            // Introduce some gradual curving:
            if (!paddle_hit && ! wrap_y)
                theta <= rotation_clk ? theta + 1 : theta;
        end
    end

endmodule
