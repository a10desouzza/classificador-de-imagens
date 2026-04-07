module Mac (
    input wire clk,
    input wire reset_n,
    input wire clr,
    input wire en,
    input wire signed [15:0] in_a,
    input wire signed [15:0] in_b,
    output reg signed [31:0] acc_out
);

    wire signed [31:0] mult_val;
    wire signed [31:0] mult_shifted;

    assign mult_val     = $signed(in_a) * $signed(in_b);
    assign mult_shifted = { {12{mult_val[31]}}, mult_val[31:12] };

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            acc_out <= 32'sd0;
        end else if (clr) begin
            acc_out <= 32'sd0;
        end else if (en) begin
            acc_out <= acc_out + mult_shifted;
        end
    end

endmodule