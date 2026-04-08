module Control_unit (
    input  wire        visible,
    input  wire [31:0] status_word,
    output reg  [6:0]  hex3,
    output reg  [6:0]  hex2,
    output reg  [6:0]  hex1,
    output reg  [6:0]  hex0
);

    // Display de 7 segmentos ativo em nível baixo
    localparam [6:0] SEG_BLANK = 7'b1111111;

    // Dígitos / letras aproximadas
    localparam [6:0] SEG_O = 7'b0100011; // 0 / O
    localparam [6:0] SEG_D = 7'b0100001; // d
    localparam [6:0] SEG_E = 7'b0000110; // E
    localparam [6:0] SEG_B = 7'b0000011; // b
    localparam [6:0] SEG_U = 7'b1000001; // U
    localparam [6:0] SEG_S = 7'b0010010; // S
    localparam [6:0] SEG_Y = 7'b0010001; // y aproximado
    localparam [6:0] SEG_R = 7'b0101111; // r aproximado
    localparam [6:0] SEG_N = 7'b0101011; // n aproximado

    always @(*) begin
        // apagado por padrão
        hex3 = SEG_BLANK;
        hex2 = SEG_BLANK;
        hex1 = SEG_BLANK;
        hex0 = SEG_BLANK;

        if (visible) begin
            // prioridade: ERROR > BUSY > DONE
            if (status_word[2]) begin
                // ERRO
                hex3 = SEG_E;
                hex2 = SEG_R;
                hex1 = SEG_R;
                hex0 = SEG_O;
            end
            else if (status_word[0]) begin
                // BUSY
                hex3 = SEG_B;
                hex2 = SEG_U;
                hex1 = SEG_S;
                hex0 = SEG_Y;
            end
            else if (status_word[1]) begin
                // DONE
                hex3 = SEG_D;
                hex2 = SEG_O;
                hex1 = SEG_N;
                hex0 = SEG_E;
            end
        end
    end

endmodule