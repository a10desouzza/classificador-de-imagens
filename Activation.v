module Activation (  // sigmoid piecewise-linear
    input wire signed [31:0] z_in,
    input wire signed [15:0] b_in,
    output wire signed [15:0] h_out
);
    wire signed [31:0] z_val = z_in + {{16{b_in[15]}}, b_in};
    wire signed [31:0] z_div4 = {{2{z_val[31]}}, z_val[31:2]};
    wire signed [31:0] sigmoid_approx = z_div4 + 32'sd2048;

    assign h_out = (z_val >= 32'sd8192)  ? 16'sd4096 :
                   (z_val <= -32'sd8192) ? 16'sd0    : sigmoid_approx[15:0];
endmodule