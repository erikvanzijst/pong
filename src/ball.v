`default_nettype none
`timescale 1ns / 1ps

module ball #(parameter integer THETA_WIDTH = 6)
    (
    input wire clk, // should be 2000Hz for optimally playable speed
    input wire reset,
    input [4:0] entropy,

    // the ball's current vector:
    input signed [4:0] speed,       // length of the direction vector (speed range: -16 to 15)
    input wire [31:0] lpaddle,
    input wire [31:0] rpaddle,

    output wire [4:0] x,
    output wire [4:0] y,

    output out_left,    // ball reached far-left edge
    output out_right    // ball reached far-right edge
    );

    reg [THETA_WIDTH-1:0] theta;   // angular direction in 64 increments

    reg [20:0] hor;     // 4 high bits is x pos on screen
    reg [20:0] vert;    // 4 high bits is y pos on screen

    assign x = hor[20:16];
    assign y = vert[20:16];

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
        (next_hor[20:16] == 5'h1F && moving_left && (lpaddle & (1 << next_vert[20:16]))) ||
        (next_hor[20:16] == 5'h0 && moving_right && (rpaddle & (1 << next_vert[20:16])));

    assign out_left = !next_hor[20:16] && hor[20:16] && moving_left;
    assign out_right = next_hor[20:16] && !hor[20:16] && moving_right;

    wire wrap_y;
    assign wrap_y = (next_vert[20:16] && !vert[20:16] && theta[THETA_WIDTH-1]) ||     // top
                    (!next_vert[20:16] && vert[20:16] && !theta[THETA_WIDTH-1]);      // bottom

    trig trig0 (.CLK(clk), .theta_i(theta), .sin_o(sin_theta), .cos_o(cos_theta));

    // Temporary hardwired rotation:
    wire rotation_clk;
    customclk #(.TOP(500)) rotator(.clk(clk), .clkout(rotation_clk));

    always @(posedge clk) begin
        if (reset) begin
            // place the ball at the center of the screen:
            hor <= 16 << 16;
            vert <= 16 << 16;

            // start off in a random direction:
            case (entropy[4:3])
                2'b00: theta <= {3'b000, entropy[2:0]};
                2'b01: theta <= {3'b011, entropy[2:0]};
                2'b10: theta <= {3'b100, entropy[2:0]};
                2'b11: theta <= {3'b111, entropy[2:0]};
            endcase

        end else begin
            if (paddle_hit || out_left || out_right) begin
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
