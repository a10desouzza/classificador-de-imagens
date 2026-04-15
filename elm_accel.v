module elm_accel #(
    parameter integer D       = 784,       // 28x28 pixels
    parameter integer H       = 128,       // neurônios ocultos
    parameter integer C       = 10,        // classes de saída
    parameter integer DATA_W  = 16,
    parameter integer ACC_W   = 32,
    parameter integer Q_FRAC  = 12,
    parameter integer CLK_HZ  = 50000000,
    parameter integer STATUS_ON_SECONDS = 10,
    parameter integer IMG_BIN_TH = 1536
)(
    input  wire                  clk,
    input  wire                  reset_n,

    // Barramento vindo do top
    input  wire [31:0]           sw,

    // KEY[1] = confirmar instrução
    input  wire                  confirm_btn,

    // KEY[3] = preparar STORE
    input  wire                  prep_btn,

    // Saída consolidada
    output wire [31:0]           result_out,

    // Interface Avalon
    input  wire [3:0]            avs_address,
    input  wire                  avs_write,
    input  wire [31:0]           avs_writedata,
    input  wire                  avs_read,
    output reg  [31:0]           avs_readdata,
    output wire                  avs_waitrequest,

    // Saídas locais
    output wire [6:0]            hex3,
    output wire [6:0]            hex2,
    output wire [6:0]            hex1,
    output wire [6:0]            hex0,
    output wire [3:0]            ledr_pred,
    output wire [2:0]            ledr_flags
);

    assign avs_waitrequest = 1'b0;

    // -------------------------------------------------------------------------
    // Decodificação dos switches
    // -------------------------------------------------------------------------
    wire [2:0] cmd_opcode;   // SW[2:0]
    wire [2:0] test_addr3;   // SW[5:3]
    wire [2:0] test_data3;   // SW[8:6]

    assign cmd_opcode = sw[2:0];
    assign test_addr3 = sw[5:3];
    assign test_data3 = sw[8:6];

    // -------------------------------------------------------------------------
    // Comandos
    // -------------------------------------------------------------------------
    localparam [2:0] CMD_CLEAR_ERR = 3'd0;
    localparam [2:0] CMD_STORE_IMG = 3'd1;
    localparam [2:0] CMD_STORE_W   = 3'd2;
    localparam [2:0] CMD_STORE_B   = 3'd3;
    localparam [2:0] CMD_START     = 3'd4;
    localparam [2:0] CMD_STATUS    = 3'd5;

    // -------------------------------------------------------------------------
    // Estados principais
    // -------------------------------------------------------------------------
    localparam [1:0] DONE  = 2'b00;
    localparam [1:0] BUSY  = 2'b01;
    localparam [1:0] ERROR = 2'b10;

    // -------------------------------------------------------------------------
    // Fases internas da inferência
    // -------------------------------------------------------------------------
    localparam [4:0] PH_H_ADDR        = 5'd0;
    localparam [4:0] PH_H_WAIT0       = 5'd1;
    localparam [4:0] PH_H_WAIT1       = 5'd2;
    localparam [4:0] PH_H_MAC         = 5'd3;
    localparam [4:0] PH_H_BIAS        = 5'd4;
    localparam [4:0] PH_H_BIAS_WAIT0  = 5'd5;
    localparam [4:0] PH_H_BIAS_WAIT1  = 5'd6;
    localparam [4:0] PH_H_TANH        = 5'd7;
    localparam [4:0] PH_H_TANH_LATCH  = 5'd8;
    localparam [4:0] PH_O_ADDR        = 5'd9;
    localparam [4:0] PH_O_WAIT0       = 5'd10;
    localparam [4:0] PH_O_WAIT1       = 5'd11;
    localparam [4:0] PH_O_MAC         = 5'd12;
    localparam [4:0] PH_ARGMAX        = 5'd13;

    localparam integer STATUS_HOLD_CYCLES = CLK_HZ * STATUS_ON_SECONDS;

    // -------------------------------------------------------------------------
    // Geração de pulso de borda para os botões
    // -------------------------------------------------------------------------
    reg confirm_d1, confirm_d2;
    reg prep_d1, prep_d2;

    wire cmd_fire;
    wire prep_fire;

    assign cmd_fire  = confirm_d1 & ~confirm_d2;
    assign prep_fire = prep_d1 & ~prep_d2;

    // -------------------------------------------------------------------------
    // Estado principal
    // -------------------------------------------------------------------------
    reg [1:0]  estado_atual;
    reg [2:0]  opcode;
    reg [4:0]  phase;

    // -------------------------------------------------------------------------
    // Flags de disponibilidade dos blocos
    // -------------------------------------------------------------------------
    reg img_ok, w_ok, b_ok;
    assign ledr_flags = {img_ok, w_ok, b_ok};

    // -------------------------------------------------------------------------
    // Predição final
    // -------------------------------------------------------------------------
    reg [3:0] pred_reg;
    assign ledr_pred = pred_reg;

    // -------------------------------------------------------------------------
    // Montagem da palavra de saída
    // -------------------------------------------------------------------------
    function [31:0] make_result;
        input [1:0] st;
        input imgf;
        input wf;
        input bf;
        input [3:0] predf;
        begin
            make_result = {
                20'd0,            // reservado
                st,               // estado codificado
                imgf,             // img_ok
                wf,               // w_ok
                bf,               // b_ok
                predf,            // predição
                (st == ERROR),    // erro
                (st == DONE),     // done
                (st == BUSY)      // busy
            };
        end
    endfunction

    wire [31:0] result_live;
    assign result_live = make_result(estado_atual, img_ok, w_ok, b_ok, pred_reg);
    assign result_out  = result_live;

    // -------------------------------------------------------------------------
    // Controle do display de status
    // -------------------------------------------------------------------------
    reg        status_visible;
    reg [31:0] status_hold_counter;
    reg [31:0] status_display_word;

    // -------------------------------------------------------------------------
    // Índices internos da inferência
    // -------------------------------------------------------------------------
    reg [9:0] in_idx;
    reg [6:0] hid_idx;
    reg [3:0] cls_idx;

    // -------------------------------------------------------------------------
    // Endereços das memórias
    // -------------------------------------------------------------------------
    reg [9:0]  img_addr;
    reg [16:0] w_addr;
    reg [6:0]  b_addr;
    reg [10:0] beta_addr;

    // Leituras das memórias
    wire signed [15:0] img_q;
    wire signed [15:0] w_q;
    wire signed [15:0] b_q;
    wire signed [15:0] beta_q;

    // -------------------------------------------------------------------------
    // Binarização da imagem
    // -------------------------------------------------------------------------
    wire signed [15:0] img_q_bin;
    assign img_q_bin = (img_q >= IMG_BIN_TH) ? 16'sd4095 : 16'sd0;

    // -------------------------------------------------------------------------
    // Sinais de escrita real das memórias
    // -------------------------------------------------------------------------
    reg                  wr_en_img, wr_en_w, wr_en_b;
    reg [9:0]            wr_addr_img;
    reg signed [15:0]    wr_data_img;
    reg [16:0]           wr_addr_w;
    reg signed [15:0]    wr_data_w;
    reg [6:0]            wr_addr_b;
    reg signed [15:0]    wr_data_b;

    // -------------------------------------------------------------------------
    // Registradores de preparação do STORE
    // KEY[3] coloca endereço+dado aqui
    // KEY[1] com STORE faz o commit real
    // -------------------------------------------------------------------------
    reg                  prep_img_valid;
    reg [9:0]            prep_img_addr;
    reg signed [15:0]    prep_img_data;

    reg                  prep_w_valid;
    reg [16:0]           prep_w_addr;
    reg signed [15:0]    prep_w_data;

    reg                  prep_b_valid;
    reg [6:0]            prep_b_addr;
    reg signed [15:0]    prep_b_data;

    // -------------------------------------------------------------------------
    // Dados manuais de teste
    // -------------------------------------------------------------------------
    wire signed [15:0] test_img_data_q412;
    wire signed [15:0] test_signed_data_q412;

    // Para imagem, monta um valor positivo simples em Q4.12
    assign test_img_data_q412    = {4'd0, test_data3, 9'd0};

    // Para peso/bias, interpreta os 3 bits como signed
    assign test_signed_data_q412 = $signed({{13{test_data3[2]}}, test_data3}) <<< 10;

    // -------------------------------------------------------------------------
    // Datapath principal
    // -------------------------------------------------------------------------
    reg signed [ACC_W-1:0] acc;
    reg signed [ACC_W-1:0] z_hidden;

    reg signed [DATA_W-1:0] h_mem [0:H-1];
    reg signed [ACC_W-1:0]  y_mem [0:C-1];

    wire signed [ACC_W-1:0] mult_hidden_full;
    wire signed [ACC_W-1:0] mult_hidden_scaled;
    wire signed [ACC_W-1:0] mult_output_full;
    wire signed [ACC_W-1:0] mult_output_scaled;

    wire signed [DATA_W-1:0] z_sat;
    wire signed [DATA_W-1:0] tanh_out;

    wire [3:0]              pred_argmax;
    wire signed [ACC_W-1:0] max_val_unused;

    reg [31:0] cycles_reg;
    reg [31:0] run_cycles;

    // -------------------------------------------------------------------------
    // Cálculo de endereços
    // -------------------------------------------------------------------------
    wire [16:0] hid_x784;
    wire [10:0] hid_x10;

    assign hid_x784 = ({10'b0, hid_idx} << 9)
                    + ({10'b0, hid_idx} << 8)
                    + ({10'b0, hid_idx} << 4);

    assign hid_x10  = ({4'b0, hid_idx} << 3)
                    + ({4'b0, hid_idx} << 1);

    // -------------------------------------------------------------------------
    // Saturação de 32 para 16 bits
    // -------------------------------------------------------------------------
    function signed [DATA_W-1:0] sat32_to_q16;
        input signed [ACC_W-1:0] x;
        begin
            if (x > 32'sd32767)
                sat32_to_q16 = 16'sd32767;
            else if (x < -32'sd32768)
                sat32_to_q16 = -16'sd32768;
            else
                sat32_to_q16 = x[DATA_W-1:0];
        end
    endfunction

    assign z_sat = sat32_to_q16(z_hidden);

    // -------------------------------------------------------------------------
    // Instâncias dos blocos
    // -------------------------------------------------------------------------
    Mem_block u_mem (
        .clk(clk),
        .img_addr(img_addr),
        .img_q(img_q),
        .w_addr(w_addr),
        .w_q(w_q),
        .b_addr(b_addr),
        .b_q(b_q),
        .beta_addr(beta_addr),
        .beta_q(beta_q),
        .wr_en_img(wr_en_img),
        .wr_addr_img(wr_addr_img),
        .wr_data_img(wr_data_img),
        .wr_en_w(wr_en_w),
        .wr_addr_w(wr_addr_w),
        .wr_data_w(wr_data_w),
        .wr_en_b(wr_en_b),
        .wr_addr_b(wr_addr_b),
        .wr_data_b(wr_data_b)
    );

    Mac #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W),
        .Q_FRAC(Q_FRAC)
    ) u_mac_hidden (
        .a(img_q_bin),
        .b(w_q),
        .product_full(mult_hidden_full),
        .product_scaled(mult_hidden_scaled)
    );

    Mac #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W),
        .Q_FRAC(Q_FRAC)
    ) u_mac_output (
        .a(h_mem[hid_idx]),
        .b(beta_q),
        .product_full(mult_output_full),
        .product_scaled(mult_output_scaled)
    );

    tanh_lut #(
        .DATA_W(DATA_W),
        .Q_FRAC(Q_FRAC)
    ) u_tanh_lut (
        .x_in(z_sat),
        .y_out(tanh_out)
    );

    argmax #(
        .ACC_W(ACC_W)
    ) u_argmax (
        .y0(y_mem[0]), .y1(y_mem[1]), .y2(y_mem[2]), .y3(y_mem[3]), .y4(y_mem[4]),
        .y5(y_mem[5]), .y6(y_mem[6]), .y7(y_mem[7]), .y8(y_mem[8]), .y9(y_mem[9]),
        .pred(pred_argmax),
        .max_val(max_val_unused)
    );

    Control_unit u_Control_unit (
        .visible(status_visible),
        .status_word(status_display_word),
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0)
    );

    // -------------------------------------------------------------------------
    // Sincronização dos botões
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            confirm_d1 <= 1'b0;
            confirm_d2 <= 1'b0;
            prep_d1    <= 1'b0;
            prep_d2    <= 1'b0;
        end else begin
            confirm_d1 <= confirm_btn;
            confirm_d2 <= confirm_d1;
            prep_d1    <= prep_btn;
            prep_d2    <= prep_d1;
        end
    end

    // -------------------------------------------------------------------------
    // Bloco único da preparação do STORE
    // Resolve o problema de múltiplos drivers em prep_*_valid
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prep_img_valid <= 1'b0;
            prep_img_addr  <= 10'd0;
            prep_img_data  <= 16'sd0;

            prep_w_valid   <= 1'b0;
            prep_w_addr    <= 17'd0;
            prep_w_data    <= 16'sd0;

            prep_b_valid   <= 1'b0;
            prep_b_addr    <= 7'd0;
            prep_b_data    <= 16'sd0;
        end else begin
            // Modo Avalon: prepara dado externo
            if (avs_write) begin
                case (avs_address)
                    4'h0: begin
                        prep_img_valid <= 1'b1;
                        prep_img_addr  <= avs_writedata[25:16];
                        prep_img_data  <= avs_writedata[15:0];
                    end
                    4'h1: begin
                        prep_w_valid <= 1'b1;
                        prep_w_addr  <= avs_writedata[28:12];
                        prep_w_data  <= avs_writedata[15:0];
                    end
                    4'h2: begin
                        prep_b_valid <= 1'b1;
                        prep_b_addr  <= avs_writedata[22:16];
                        prep_b_data  <= avs_writedata[15:0];
                    end
                    default: begin
                    end
                endcase
            end
            // Modo manual: KEY[3] prepara endereço+dado
            else if (prep_fire) begin
                case (cmd_opcode)
                    CMD_STORE_IMG: begin
                        prep_img_valid <= 1'b1;
                        prep_img_addr  <= {7'd0, test_addr3};
                        prep_img_data  <= test_img_data_q412;
                    end
                    CMD_STORE_W: begin
                        prep_w_valid <= 1'b1;
                        prep_w_addr  <= {14'd0, test_addr3};
                        prep_w_data  <= test_signed_data_q412;
                    end
                    CMD_STORE_B: begin
                        prep_b_valid <= 1'b1;
                        prep_b_addr  <= {4'd0, test_addr3};
                        prep_b_data  <= test_signed_data_q412;
                    end
                    default: begin
                    end
                endcase
            end
            // Depois do commit por KEY[1], limpa a validade
            else if (cmd_fire) begin
                case (cmd_opcode)
                    CMD_STORE_IMG: begin
                        if (prep_img_valid)
                            prep_img_valid <= 1'b0;
                    end
                    CMD_STORE_W: begin
                        if (prep_w_valid)
                            prep_w_valid <= 1'b0;
                    end
                    CMD_STORE_B: begin
                        if (prep_b_valid)
                            prep_b_valid <= 1'b0;
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

    // -------------------------------------------------------------------------
    // Commit real nas memórias
    // Se não houver preparação válida, não escreve nada
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_en_img   <= 1'b0;
            wr_en_w     <= 1'b0;
            wr_en_b     <= 1'b0;
            wr_addr_img <= 10'd0;
            wr_data_img <= 16'sd0;
            wr_addr_w   <= 17'd0;
            wr_data_w   <= 16'sd0;
            wr_addr_b   <= 7'd0;
            wr_data_b   <= 16'sd0;
        end else begin
            wr_en_img <= 1'b0;
            wr_en_w   <= 1'b0;
            wr_en_b   <= 1'b0;

            if (cmd_fire) begin
                case (cmd_opcode)
                    CMD_STORE_IMG: begin
                        if (prep_img_valid) begin
                            wr_en_img   <= 1'b1;
                            wr_addr_img <= prep_img_addr;
                            wr_data_img <= prep_img_data;
                        end
                    end
                    CMD_STORE_W: begin
                        if (prep_w_valid) begin
                            wr_en_w   <= 1'b1;
                            wr_addr_w <= prep_w_addr;
                            wr_data_w <= prep_w_data;
                        end
                    end
                    CMD_STORE_B: begin
                        if (prep_b_valid) begin
                            wr_en_b   <= 1'b1;
                            wr_addr_b <= prep_b_addr;
                            wr_data_b <= prep_b_data;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

    // -------------------------------------------------------------------------
    // Controle do STATUS nos displays
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            status_visible      <= 1'b0;
            status_hold_counter <= 32'd0;
            status_display_word <= 32'd0;
        end else begin
            if (cmd_fire && (cmd_opcode == CMD_STATUS)) begin
                status_display_word <= result_live;
                status_visible      <= 1'b1;
                status_hold_counter <= 32'd0;
            end else if (status_visible) begin
                if (status_hold_counter < STATUS_HOLD_CYCLES - 1)
                    status_hold_counter <= status_hold_counter + 32'd1;
                else begin
                    status_hold_counter <= 32'd0;
                    status_visible      <= 1'b0;
                end
            end else begin
                status_hold_counter <= 32'd0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // FSM principal
    // -------------------------------------------------------------------------
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            estado_atual <= DONE;
            opcode       <= CMD_CLEAR_ERR;
            phase        <= PH_H_ADDR;

            img_ok       <= 1'b0;
            w_ok         <= 1'b0;
            b_ok         <= 1'b0;

            pred_reg     <= 4'd0;
            cycles_reg   <= 32'd0;
            run_cycles   <= 32'd0;

            in_idx       <= 10'd0;
            hid_idx      <= 7'd0;
            cls_idx      <= 4'd0;

            img_addr     <= 10'd0;
            w_addr       <= 17'd0;
            b_addr       <= 7'd0;
            beta_addr    <= 11'd0;

            acc          <= 32'sd0;
            z_hidden     <= 32'sd0;

            for (i = 0; i < H; i = i + 1)
                h_mem[i] <= 16'sd0;

            for (i = 0; i < C; i = i + 1)
                y_mem[i] <= 32'sd0;
        end else begin
            case (estado_atual)

                // Estado ocioso
                DONE: begin
                    phase <= PH_H_ADDR;

                    if (cmd_fire) begin
                        case (cmd_opcode)
                            CMD_STORE_IMG: begin
                                opcode       <= CMD_STORE_IMG;
                                estado_atual <= BUSY;
                            end

                            CMD_STORE_W: begin
                                opcode       <= CMD_STORE_W;
                                estado_atual <= BUSY;
                            end

                            CMD_STORE_B: begin
                                opcode       <= CMD_STORE_B;
                                estado_atual <= BUSY;
                            end

                            CMD_START: begin
                                // Só inicia se tudo estiver pronto
                                if (img_ok && w_ok && b_ok) begin
                                    opcode       <= CMD_START;
                                    estado_atual <= BUSY;

                                    phase      <= PH_H_ADDR;
                                    in_idx     <= 10'd0;
                                    hid_idx    <= 7'd0;
                                    cls_idx    <= 4'd0;
                                    acc        <= 32'sd0;
                                    z_hidden   <= 32'sd0;
                                    pred_reg   <= 4'd0;
                                    run_cycles <= 32'd0;

                                    for (i = 0; i < H; i = i + 1)
                                        h_mem[i] <= 16'sd0;

                                    for (i = 0; i < C; i = i + 1)
                                        y_mem[i] <= 32'sd0;
                                end else begin
                                    estado_atual <= ERROR;
                                end
                            end

                            CMD_CLEAR_ERR: begin
                                estado_atual <= DONE;
                            end

                            CMD_STATUS: begin
                                estado_atual <= DONE;
                            end

                            default: begin
                                estado_atual <= DONE;
                            end
                        endcase
                    end
                end

                // Estado ocupado
                BUSY: begin
                    if (opcode != CMD_START) begin
                        // STORE só levanta as flags
                        case (opcode)
                            CMD_STORE_IMG: img_ok <= 1'b1;
                            CMD_STORE_W:   w_ok   <= 1'b1;
                            CMD_STORE_B:   b_ok   <= 1'b1;
                            default: ;
                        endcase

                        estado_atual <= DONE;
                    end else begin
                        run_cycles <= run_cycles + 32'd1;

                        case (phase)
                            // Camada oculta
                            PH_H_ADDR: begin
                                img_addr <= in_idx;
                                w_addr   <= hid_x784 + {7'b0, in_idx};
                                phase    <= PH_H_WAIT0;
                            end

                            PH_H_WAIT0: begin
                                phase <= PH_H_WAIT1;
                            end

                            PH_H_WAIT1: begin
                                phase <= PH_H_MAC;
                            end

                            PH_H_MAC: begin
                                acc <= acc + mult_hidden_scaled;

                                if (in_idx == D-1) begin
                                    in_idx <= 10'd0;
                                    phase  <= PH_H_BIAS;
                                end else begin
                                    in_idx <= in_idx + 10'd1;
                                    phase  <= PH_H_ADDR;
                                end
                            end

                            PH_H_BIAS: begin
                                b_addr <= hid_idx;
                                phase  <= PH_H_BIAS_WAIT0;
                            end

                            PH_H_BIAS_WAIT0: begin
                                phase <= PH_H_BIAS_WAIT1;
                            end

                            PH_H_BIAS_WAIT1: begin
                                z_hidden <= acc + {{(ACC_W-DATA_W){b_q[DATA_W-1]}}, b_q};
                                phase    <= PH_H_TANH;
                            end

                            PH_H_TANH: begin
                                phase <= PH_H_TANH_LATCH;
                            end

                            PH_H_TANH_LATCH: begin
                                h_mem[hid_idx] <= tanh_out;
                                acc            <= 32'sd0;
                                z_hidden       <= 32'sd0;

                                if (hid_idx == H-1) begin
                                    hid_idx <= 7'd0;
                                    cls_idx <= 4'd0;
                                    phase   <= PH_O_ADDR;
                                end else begin
                                    hid_idx <= hid_idx + 7'd1;
                                    phase   <= PH_H_ADDR;
                                end
                            end

                            // Camada de saída
                            PH_O_ADDR: begin
                                beta_addr <= hid_x10 + {7'b0, cls_idx};
                                phase     <= PH_O_WAIT0;
                            end

                            PH_O_WAIT0: begin
                                phase <= PH_O_WAIT1;
                            end

                            PH_O_WAIT1: begin
                                phase <= PH_O_MAC;
                            end

                            PH_O_MAC: begin
                                if (hid_idx == H-1) begin
                                    y_mem[cls_idx] <= acc + mult_output_scaled;
                                    acc            <= 32'sd0;
                                    hid_idx        <= 7'd0;

                                    if (cls_idx == C-1) begin
                                        cls_idx <= 4'd0;
                                        phase   <= PH_ARGMAX;
                                    end else begin
                                        cls_idx <= cls_idx + 4'd1;
                                        phase   <= PH_O_ADDR;
                                    end
                                end else begin
                                    acc     <= acc + mult_output_scaled;
                                    hid_idx <= hid_idx + 7'd1;
                                    phase   <= PH_O_ADDR;
                                end
                            end

                            // Argmax final
                            PH_ARGMAX: begin
                                pred_reg     <= pred_argmax;
                                cycles_reg   <= run_cycles + 32'd1;
                                estado_atual <= DONE;
                            end

                            default: begin
                                estado_atual <= ERROR;
                            end
                        endcase
                    end
                end

                // Estado de erro
                ERROR: begin
                    if (cmd_fire && (cmd_opcode == CMD_CLEAR_ERR))
                        estado_atual <= DONE;
                end

                default: begin
                    estado_atual <= ERROR;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Leitura Avalon
    // -------------------------------------------------------------------------
    always @(*) begin
        if (avs_read) begin
            case (avs_address)
                4'h3: avs_readdata = result_live;
                4'h4: avs_readdata = {28'd0, pred_reg};
                4'h5: avs_readdata = cycles_reg;
                default: avs_readdata = 32'd0;
            endcase
        end else begin
            avs_readdata = 32'd0;
        end
    end

endmodule