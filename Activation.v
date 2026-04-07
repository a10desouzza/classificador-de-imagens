module Activation (
    input wire signed [31:0] z_in,
    input wire signed [15:0] b_in,
    output wire signed [15:0] h_out
);

    wire signed [31:0] b_ext;
    wire signed [31:0] z_val;
    wire signed [31:0] z_div_4;
    wire signed [31:0] plan_calc;

    assign b_ext     = {{16{b_in[15]}}, b_in};
    assign z_val     = z_in + b_ext;
    assign z_div_4   = { {2{z_val[31]}}, z_val[31:2] };
    assign plan_calc = z_div_4 + 32'sd2048;

    assign h_out = (z_val >= 32'sd8192)   ? 16'sd4096 :
                   (z_val <= -32'sd8192)  ? 16'sd0    :
                                            plan_calc[15:0];

endmodule