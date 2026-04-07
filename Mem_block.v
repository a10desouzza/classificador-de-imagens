module Mem_block (
    input wire clk,

    input wire [9:0] img_addr,
    output wire signed [15:0] img_q,

    input wire [16:0] w_addr,
    output wire signed [15:0] w_q,

    input wire [6:0] b_addr,
    output wire signed [15:0] b_q,

    input wire [10:0] beta_addr,
    output wire signed [15:0] beta_q,

    input wire [6:0] h_addr,
    input wire h_we,
    input wire signed [15:0] h_data_in,
    output wire signed [15:0] h_q,

    input wire wr_en_img,
    input wire [9:0] wr_addr_img,
    input wire signed [15:0] wr_data_img,

    input wire wr_en_w,
    input wire [16:0] wr_addr_w,
    input wire signed [15:0] wr_data_w,

    input wire wr_en_b,
    input wire [6:0] wr_addr_b,
    input wire signed [15:0] wr_data_b
);

    wire [9:0]  img_addr_mux  = wr_en_img ? wr_addr_img : img_addr;
    wire signed [15:0] img_data_mux = wr_data_img;
    wire        img_wren_mux  = wr_en_img;

    ram_img_784x16 mem_img (
        .clock   (clk),
        .address (img_addr_mux),
        .data    (img_data_mux),
        .wren    (img_wren_mux),
        .q       (img_q)
    );

    wire [16:0] w_addr_mux   = wr_en_w ? wr_addr_w : w_addr;
    wire signed [15:0] w_data_mux = wr_data_w;
    wire        w_wren_mux   = wr_en_w;

    ram_W_100352x16 mem_W (
        .clock   (clk),
        .address (w_addr_mux),
        .data    (w_data_mux),
        .wren    (w_wren_mux),
        .q       (w_q)
    );

    wire [6:0]  b_addr_mux   = wr_en_b ? wr_addr_b : b_addr;
    wire signed [15:0] b_data_mux = wr_data_b;
    wire        b_wren_mux   = wr_en_b;

    ram_b_128x16 mem_b (
        .clock   (clk),
        .address (b_addr_mux),
        .data    (b_data_mux),
        .wren    (b_wren_mux),
        .q       (b_q)
    );

    rom_beta_1280x16 rom_beta (
        .clock   (clk),
        .address (beta_addr),
        .q       (beta_q)
    );

    reg signed [15:0] H_ram [0:127];

    always @(posedge clk) begin
        if (h_we) begin
            H_ram[h_addr] <= h_data_in;
        end
    end

    assign h_q = H_ram[h_addr];

endmodule