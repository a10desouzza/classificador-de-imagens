module Control_unit (
    input wire clk,
    input wire reset_n,
    input wire [2:0] sw,
    input wire confirm_btn,

    output wire clr_mac,
    output wire en_mac,
    output wire mac_src_sel,
    output wire h_we,
    output wire clr_inf,
    output wire en_inf,

    output wire [9:0]  img_addr,
    output wire [16:0] w_addr,
    output wire [6:0]  b_addr,
    output wire [10:0] beta_addr,
    output wire [6:0]  h_addr,
    output wire [3:0]  current_class,

    output wire [2:0] ledr_flags,
    output reg [6:0] hex3,
    output reg [6:0] hex2,
    output reg [6:0] hex1,
    output reg [6:0] hex0,
    output wire [1:0] current_state_out,
    output reg [31:0] cycles_reg
);

    localparam DONE  = 2'b00;
    localparam BUSY  = 2'b01;
    localparam ERROR = 2'b10;

    reg [1:0] estado_atual;
    reg [1:0] proximo_estado;

    reg [2:0] opcode;

    reg img_ok;
    reg w_ok;
    reg b_ok;
    reg en_status;

    reg calc_done;
    reg [31:0] contador_ciclos;

    reg [3:0] calc_state;
    reg [6:0] h_cnt;
    reg [9:0] p_cnt;
    reg [3:0] c_cnt;
    reg [16:0] w_addr_cnt;

    reg confirm_d1;
    reg confirm_d2;

    wire confirm_pulse;
    wire is_calc;

    assign confirm_pulse = (~confirm_d2) & confirm_d1;

    assign ledr_flags = {img_ok, w_ok, b_ok};
    assign current_state_out = estado_atual;

    assign img_addr = p_cnt;
    assign w_addr   = w_addr_cnt;
    assign b_addr   = h_cnt;

    assign beta_addr = (c_cnt * 11'd128) + h_cnt;

    assign h_addr = h_cnt;
    assign current_class = c_cnt;

    assign is_calc = (estado_atual == BUSY) && (opcode == 3'b100);

    assign clr_mac     = is_calc && ((calc_state == 4'd0) || (calc_state == 4'd6));
    assign en_mac      = is_calc && ((calc_state == 4'd3) || (calc_state == 4'd8));
    assign h_we        = is_calc && (calc_state == 4'd5);
    assign clr_inf     = is_calc && (calc_state == 4'd6) && (c_cnt == 4'd0);
    assign en_inf      = is_calc && (calc_state == 4'd9);
    assign mac_src_sel = (calc_state >= 4'd6) ? 1'b1 : 1'b0;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            estado_atual    <= DONE;
            opcode          <= 3'b000;

            img_ok          <= 1'b0;
            w_ok            <= 1'b0;
            b_ok            <= 1'b0;
            en_status       <= 1'b0;

            calc_done       <= 1'b0;
            contador_ciclos <= 32'd0;
            cycles_reg      <= 32'd0;

            calc_state      <= 4'd0;
            h_cnt           <= 7'd0;
            p_cnt           <= 10'd0;
            c_cnt           <= 4'd0;
            w_addr_cnt      <= 17'd0;

            confirm_d1      <= 1'b0;
            confirm_d2      <= 1'b0;
        end else begin
            estado_atual <= proximo_estado;

            confirm_d1 <= confirm_btn;
            confirm_d2 <= confirm_d1;

            calc_done <= 1'b0;

            if (confirm_pulse) begin
                if (sw == 3'b000) begin
                    img_ok    <= 1'b0;
                    w_ok      <= 1'b0;
                    b_ok      <= 1'b0;
                    en_status <= 1'b0;
                end else if (sw == 3'b101) begin
                    en_status <= 1'b1;
                end
            end

            if ((estado_atual == DONE) && confirm_pulse) begin
                if ((sw == 3'b001) || (sw == 3'b010) || (sw == 3'b011) || (sw == 3'b100)) begin
                    opcode <= sw;
                end
            end

            if (estado_atual == BUSY) begin
                contador_ciclos <= contador_ciclos + 32'd1;

                if (opcode == 3'b001) begin
                    img_ok <= 1'b1;
                    calc_done <= 1'b1;
                end
                else if (opcode == 3'b010) begin
                    w_ok <= 1'b1;
                    calc_done <= 1'b1;
                end
                else if (opcode == 3'b011) begin
                    b_ok <= 1'b1;
                    calc_done <= 1'b1;
                end
                else if (opcode == 3'b100) begin
                    case (calc_state)

                        4'd0: begin
                            h_cnt      <= 7'd0;
                            p_cnt      <= 10'd0;
                            w_addr_cnt <= 17'd0;
                            calc_state <= 4'd1;
                        end

                        4'd1: begin
                            calc_state <= 4'd2;
                        end

                        4'd2: begin
                            calc_state <= 4'd3;
                        end

                        4'd3: begin
                            if (p_cnt < 10'd783) begin
                                p_cnt      <= p_cnt + 10'd1;
                                w_addr_cnt <= w_addr_cnt + 17'd1;
                                calc_state <= 4'd2;
                            end else begin
                                calc_state <= 4'd4;
                            end
                        end

                        4'd4: begin
                            calc_state <= 4'd5;
                        end

                        4'd5: begin
                            if (h_cnt < 7'd127) begin
                                h_cnt      <= h_cnt + 7'd1;
                                p_cnt      <= 10'd0;
                                w_addr_cnt <= w_addr_cnt + 17'd1;
                                calc_state <= 4'd1;
                            end else begin
                                c_cnt      <= 4'd0;
                                h_cnt      <= 7'd0;
                                calc_state <= 4'd6;
                            end
                        end

                        4'd6: begin
                            h_cnt      <= 7'd0;
                            calc_state <= 4'd7;
                        end

                        4'd7: begin
                            calc_state <= 4'd8;
                        end

                        4'd8: begin
                            if (h_cnt < 7'd127) begin
                                h_cnt      <= h_cnt + 7'd1;
                                calc_state <= 4'd7;
                            end else begin
                                calc_state <= 4'd9;
                            end
                        end

                        4'd9: begin
                            if (c_cnt < 4'd9) begin
                                c_cnt      <= c_cnt + 4'd1;
                                h_cnt      <= 7'd0;
                                calc_state <= 4'd6;
                            end else begin
                                cycles_reg <= contador_ciclos;
                                calc_done  <= 1'b1;
                                calc_state <= 4'd0;
                            end
                        end

                        default: begin
                            calc_state <= 4'd0;
                        end
                    endcase
                end
            end else begin
                contador_ciclos <= 32'd0;
                calc_state <= 4'd0;
            end
        end
    end

    always @(*) begin
        proximo_estado = estado_atual;

        case (estado_atual)
            DONE: begin
                if (confirm_pulse) begin
                    if (sw == 3'b100) begin
                        if (img_ok && w_ok && b_ok)
                            proximo_estado = BUSY;
                        else
                            proximo_estado = ERROR;
                    end
                    else if ((sw == 3'b001) || (sw == 3'b010) || (sw == 3'b011)) begin
                        proximo_estado = BUSY;
                    end
                end
            end

            BUSY: begin
                if (calc_done)
                    proximo_estado = DONE;
            end

            ERROR: begin
                if (confirm_pulse && (sw == 3'b000))
                    proximo_estado = DONE;
            end

            default: begin
                proximo_estado = DONE;
            end
        endcase
    end

    always @(*) begin
        if (estado_atual == ERROR) begin
            hex3 = 7'b0000110;
            hex2 = 7'b0101111;
            hex1 = 7'b0101111;
            hex0 = 7'b0100011;
        end else if (en_status) begin
            case (estado_atual)
                DONE: begin
                    hex3 = 7'b0100001;
                    hex2 = 7'b0101011;
                    hex1 = 7'b1000000;
                    hex0 = 7'b0000110;
                end
                BUSY: begin
                    hex3 = 7'b0000011;
                    hex2 = 7'b1000001;
                    hex1 = 7'b0010010;
                    hex0 = 7'b1000111;
                end
                default: begin
                    hex3 = 7'b1111111;
                    hex2 = 7'b1111111;
                    hex1 = 7'b1111111;
                    hex0 = 7'b1111111;
                end
            endcase
        end else begin
            hex3 = 7'b1111111;
            hex2 = 7'b1111111;
            hex1 = 7'b1111111;
            hex0 = 7'b1111111;
        end
    end

endmodule