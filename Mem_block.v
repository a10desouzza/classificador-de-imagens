module Mem_block (
    input  wire                  clk,

    input  wire [9:0]            img_addr,
    output wire signed [15:0]    img_q,

    input  wire [16:0]           w_addr,
    output wire signed [15:0]    w_q,

    input  wire [6:0]            b_addr,
    output wire signed [15:0]    b_q,

    input  wire [10:0]           beta_addr,
    output wire signed [15:0]    beta_q,

    input  wire                  wr_en_img,
    input  wire [9:0]            wr_addr_img,
    input  wire signed [15:0]    wr_data_img,

    input  wire                  wr_en_w,
    input  wire [16:0]           wr_addr_w,
    input  wire signed [15:0]    wr_data_w,

    input  wire                  wr_en_b,
    input  wire [6:0]            wr_addr_b,
    input  wire signed [15:0]    wr_data_b
);

    wire [9:0]  img_addr_mux;
    wire [16:0] w_addr_mux;
    wire [6:0]  b_addr_mux;

    assign img_addr_mux = wr_en_img ? wr_addr_img : img_addr;
    assign w_addr_mux   = wr_en_w   ? wr_addr_w   : w_addr;
    assign b_addr_mux   = wr_en_b   ? wr_addr_b   : b_addr;

    ram_img_784x16 mem_img (
        .clock(clk),
        .address(img_addr_mux),
        .data(wr_data_img),
        .wren(wr_en_img),
        .q(img_q)
    );

    ram_W_100352x16 mem_W (
        .clock(clk),
        .address(w_addr_mux),
        .data(wr_data_w),
        .wren(wr_en_w),
        .q(w_q)
    );

    ram_b_128x16 mem_b (
        .clock(clk),
        .address(b_addr_mux),
        .data(wr_data_b),
        .wren(wr_en_b),
        .q(b_q)
    );

    rom_beta_1280x16 rom_beta (
        .clock(clk),
        .address(beta_addr),
        .q(beta_q)
    );

endmodule