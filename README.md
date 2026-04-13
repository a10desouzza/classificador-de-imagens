# classificador de imagens

<details>
<summary><h3>Barramento de instruções</h3></summary>

### Barramento de instruções

Este barramento é responsavel por enviar ao Coprocessador as instruções a serem execultadas. O barramento de instruções é de 32 bits sendo 3 deles dedicados aos 6 OPCODES
que o coprocessador possui, as intruções possuem campos e formatos diferentes, sendo assim nem todas as instruções utilizam os 32 bits.

<details>
<summary><h3>Tabela de Instruções</h3></summary>

### Tabela de Instruções

| OP Code | Nome da operação | Descrição |
|--------:|-----------------|-----------|
| 000 | RESET | Limpa os registradores e flags, e zera a predição (`pred = 0`). |
| 001 | STORE_IMG | Escreve valores de pixels na memória de imagem (`mem_img[addr]`). |
| 010 | STORE_WEIGHTS | Armazena os pesos na memória (`mem_W[addr]` ou `mem_beta`). |
| 011 | STORE_BIAS | Armazena os viezes na memória (`mem_b[...]`). |
| 100 | START | Inicia o processamento após verificar se os dados foram carregados. |
| 101 | STATUS | Retorna o estado atual, incluindo flags e resultado da predição. |
