module top (
    input  wire        CLOCK_50,   // Clock principal da placa
    input  wire [3:0]  KEY,        // Botões
    input  wire [9:0]  SW,         // Chaves
    output wire [9:0]  LEDR,       // LEDs vermelhos
    output wire [6:0]  HEX0,       // Display 0
    output wire [6:0]  HEX1,       // Display 1
    output wire [6:0]  HEX2,       // Display 2
    output wire [6:0]  HEX3        // Display 3
);

    // Barramento de 32 bits que será enviado ao acelerador
    // SW[2:0] = opcode
    // SW[5:3] = endereço de teste
    // SW[8:6] = dado de teste
    wire [31:0] sw_bus_32;

    // Saída principal de 32 bits do coprocessador
    wire [31:0] result_out;

    // Sinais da interface Avalon não usados neste modo de teste em placa
    wire [31:0] avs_readdata_unused;
    wire        avs_waitrequest_unused;

    // Empacota os 9 bits relevantes das chaves em um barramento de 32 bits
    assign sw_bus_32 = {23'd0, SW[8:0]};

    // Instância principal do acelerador
    elm_accel #(
        .CLK_HZ(50000000),         // clock da placa = 50 MHz
        .STATUS_ON_SECONDS(10),    // status fica visível 10 segundos
        .IMG_BIN_TH(1536)          // limiar de binarização da imagem
    ) u_elm_accel (
        .clk(CLOCK_50),
        .reset_n(KEY[0]),          // reset ativo em 0 na placa

        .sw(sw_bus_32),
        .confirm_btn(~KEY[1]),     // botão de confirmação
        .prep_btn(~KEY[3]),        // botão de preparação do STORE
        .result_out(result_out),

        // Interface Avalon desativada neste top
        .avs_address(4'd0),
        .avs_write(1'b0),
        .avs_writedata(32'd0),
        .avs_read(1'b0),
        .avs_readdata(avs_readdata_unused),
        .avs_waitrequest(avs_waitrequest_unused),

        // Saídas locais
        .hex3(HEX3),
        .hex2(HEX2),
        .hex1(HEX1),
        .hex0(HEX0),
        .ledr_pred(LEDR[3:0]),
        .ledr_flags(LEDR[6:4])
    );

    // LEDs restantes apagados
    assign LEDR[9:7] = 3'b000;

endmodule