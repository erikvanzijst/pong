`default_nettype none
`timescale 1ns / 1ps

module ball #(parameter integer THETA_WIDTH = 6)
    (
    input wire clk, // should be 2000Hz for optimally playable speed
    input wire reset,
    input wire ball_reset,
    input [4:0] entropy,

    // the ball's current vector:
    input [3:0] speed,       // length of the direction vector (speed range: 0 to 15)
    input wire [31:0] lpaddle,
    input wire [31:0] rpaddle,

    output wire [4:0] x,
    output wire [4:0] y,

    output wire paddle_hit,  // ball hit a paddle
    output wire wall_hit,    // ball hit a wall

    output out_left,    // ball reached far-left edge
    output out_right    // ball reached far-right edge
    );

    reg signed [THETA_WIDTH-1:0] theta;   // angular direction in 64 increments
    wire signed [4:0] speed_s;
    assign speed_s = {1'b0, speed}; // 5-bit signed speed value so we can multiply with dx/dy

    wire signed [2:0] bounce;
    assign bounce = entropy[2:0];

    reg [20:0] hor;     // 5 high bits is x pos on VGA, 4 MSB on dotmatrix
    reg [20:0] vert;    // 5 high bits is y pos on VGA, 4 MSB on dotmatrix

    assign x = hor[20:16];
    assign y = vert[20:16];

    wire signed [7:0] sin_theta;
    wire signed [7:0] cos_theta;
    wire signed [20:0] next_hor;
    wire signed [20:0] next_vert;

    wire signed [20:0] dx;
    wire signed [20:0] dy;
    assign dx = cos_theta * speed_s;
    assign dy = sin_theta * speed_s;

    assign next_hor = hor + dx;
    assign next_vert = vert + dy;

    wire moving_left;
    assign moving_left = !(theta[THETA_WIDTH-1] ^ theta[THETA_WIDTH-2]);
    wire moving_right;
    assign moving_right = (theta[THETA_WIDTH-1] ^ theta[THETA_WIDTH-2]);

    assign paddle_hit =
        (next_hor[20:16] == 5'h1F && moving_left && (lpaddle & (1 << next_vert[20:16]))) ||
        (next_hor[20:16] == 5'h0 && moving_right && (rpaddle & (1 << next_vert[20:16])));

    assign out_left = !next_hor[20:16] && hor[20:16] && moving_left;
    assign out_right = next_hor[20:16] && !hor[20:16] && moving_right;

    wire wrap_y;
    assign wrap_y = (next_vert[20:16] && !vert[20:16] && theta[THETA_WIDTH-1]) ||     // top
                    (!next_vert[20:16] && vert[20:16] && !theta[THETA_WIDTH-1]);      // bottom

    assign wall_hit = out_left || out_right || wrap_y;

    trig trig0 (.CLK(clk), .theta_i(theta), .sin_o(sin_theta), .cos_o(cos_theta));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hor <= 16 << 16;
            vert <= 16 << 16;
            theta <= 6'b0;

        end else if (ball_reset) begin
            // place the ball at the center of the screen:
            hor <= 16 << 16;
            vert <= 16 << 16;

            // start off in a random direction:
            case (entropy[4:3])
                2'b00: theta <= {3'b000, entropy[2:0]};
                2'b01: theta <= {3'b011, entropy[2:0]};
                2'b10: theta <= {3'b100, entropy[2:0]};
                default: theta <= {3'b111, entropy[2:0]};
            endcase

        end else begin
            if (!(paddle_hit || out_left || out_right || wrap_y)) begin
                hor <= next_hor;
                vert <= next_vert;
            end

            if (paddle_hit) begin
                theta <= ((1 << THETA_WIDTH-1) - theta) + bounce;
            end

            if (wrap_y) begin
                theta <= ((1 << THETA_WIDTH) - theta) + bounce;
            end
        end
    end

endmodule
