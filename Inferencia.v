module Inferencia (
    input wire clk, reset_n,
    input wire clr, en,
    input wire signed [31:0] class_val,
    input wire [3:0] class_idx,
    output reg [3:0] pred_out
);
    reg signed [31:0] max_val;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n || clr) begin
            max_val  <= -32'sh7FFFFFFF;   // valor bem negativo
            pred_out <= 4'd0;
        end else if (en) begin
            if (class_val > max_val) begin
                max_val  <= class_val;
                pred_out <= class_idx;
            end
        end
    end
endmodule