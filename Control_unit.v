module Control_unit (
    input  wire        visible,       // indica se o status deve ser mostrado
    input  wire [31:0] status_word,   // palavra com flags/status
    output reg  [6:0]  hex3,
    output reg  [6:0]  hex2,
    output reg  [6:0]  hex1,
    output reg  [6:0]  hex0
);

    // Códigos de segmentos para mostrar letras
    localparam [6:0] SEG_BLANK = 7'b1111111;
    localparam [6:0] SEG_O     = 7'b1000000;
    localparam [6:0] SEG_D     = 7'b0100001;
    localparam [6:0] SEG_E     = 7'b0000110;
    localparam [6:0] SEG_B     = 7'b0000011;
    localparam [6:0] SEG_U     = 7'b1000001;
    localparam [6:0] SEG_S     = 7'b0010010;
    localparam [6:0] SEG_Y     = 7'b0010001;
    localparam [6:0] SEG_R     = 7'b0101111;
    localparam [6:0] SEG_N     = 7'b0101011;

    always @(*) begin
        // Por padrão, apaga os displays
        hex3 = SEG_BLANK;
        hex2 = SEG_BLANK;
        hex1 = SEG_BLANK;
        hex0 = SEG_BLANK;

        // Só mostra algo se visible = 1
        if (visible) begin
            // Prioridade:
            // 1) ERROR
            // 2) BUSY
            // 3) DONE
            if (status_word[2]) begin
                // Mostra "ERRO"
                hex3 = SEG_E;
                hex2 = SEG_R;
                hex1 = SEG_R;
                hex0 = SEG_O;
            end
            else if (status_word[0]) begin
                // Mostra "BUSY"
                hex3 = SEG_B;
                hex2 = SEG_U;
                hex1 = SEG_S;
                hex0 = SEG_Y;
            end
            else if (status_word[1]) begin
                // Mostra "DONE"
                hex3 = SEG_D;
                hex2 = SEG_O;
                hex1 = SEG_N;
                hex0 = SEG_E;
            end
        end
    end

endmodule