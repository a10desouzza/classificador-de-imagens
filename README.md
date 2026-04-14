# MI Sistemas Digitais 2026.1 — Marco 1
## Co-processador ELM em FPGA para Classificação de Dígitos

## 1. Identificação do projeto

**Disciplina:** TEC499 – MI Sistemas Digitais  
**Marco:** Marco 1  
**Tema do projeto:** Implementação de um co-processador em FPGA para inferência de imagens de dígitos numéricos  
**Trabalho desenvolvido em grupo por:** Arthur de Andrade Souza, Lucas Vilas Boas Dourado e Pedro Santos  
**Placa utilizada nos testes:** DE1-SoC  
**Linguagem principal:** Verilog HDL  
**Ferramentas utilizadas:** Quartus Prime, ModelSim/Questa e scripts auxiliares para geração de arquivos `.mif`

Este repositório apresenta a implementação do Marco 1 do problema proposto na disciplina, com foco na construção e validação de um núcleo de inferência em FPGA capaz de classificar imagens de dígitos. O trabalho foi desenvolvido em grupo e tem como objetivo entregar uma base funcional de hardware, acompanhada de documentação técnica suficiente para demonstrar o funcionamento do co-processador, a organização do datapath, a estrutura da FSM, a interface de comunicação e os critérios de validação adotados.

---

## 2. Objetivo do Marco 1

O Marco 1 tem como foco a implementação do núcleo de hardware responsável pela inferência da rede ELM. O escopo desta etapa envolve desenvolver o co-processador em Verilog, organizar o fluxo de processamento da imagem, estruturar a comunicação por comandos e retornar a predição final do dígito classificado.

De forma mais específica, este marco busca demonstrar que o hardware é capaz de:

- receber parâmetros e imagem em memória;
- executar a inferência de forma sequencial;
- manter um controle coerente por máquina de estados;
- produzir uma saída interpretável;
- disponibilizar sinais de estado e resultado para testes locais e futura integração com processador.

O barema do Marco 1 enfatiza seis dimensões de avaliação: correção funcional, arquitetura do datapath, paralelismo dos MACs, interface MMIO, ciclo de instrução e uso de recursos. Por isso, este README foi estruturado diretamente com base nesses critérios. :contentReference[oaicite:0]{index=0}

---

## 3. Levantamento de requisitos

A partir do enunciado do problema e do barema do Marco 1, foram levantados os seguintes requisitos para a solução.

### 3.1 Requisitos funcionais

O co-processador deve:

- receber dados de imagem, pesos e bias;
- iniciar a inferência a partir de um comando explícito;
- executar a classificação de uma imagem de dígito;
- informar o estado atual da execução;
- retornar a predição final;
- operar com barramentos de 32 bits na interface de controle e saída;
- permitir futura integração com um processador que substitua as chaves da placa.

### 3.2 Requisitos de arquitetura

A solução deve possuir:

- arquitetura sequencial;
- FSM de controle;
- unidade MAC;
- memória para imagem, pesos, bias e beta;
- função de ativação em hardware;
- bloco de decisão final por comparação das saídas;
- suporte a reset do sistema;
- contagem de ciclos para medição da latência.

### 3.3 Requisitos de validação

Para a entrega do Marco 1, devem ser demonstrados:

- funcionamento correto em simulação;
- coerência da saída do hardware com o comportamento esperado;
- documentação da interface;
- organização do datapath;
- análise de recursos e frequência;
- testes de funcionamento em placa ou em ambiente de simulação.

---

## 4. Softwares utilizados

Os softwares utilizados no desenvolvimento, simulação, compilação e teste da solução foram os seguintes:

| Software | Finalidade | Versão |
|---|---|---|
| Intel Quartus Prime Lite Edition | Síntese, compilação, pinagem e geração do bitstream | [Preencher versão utilizada] |
| ModelSim / Questa Intel FPGA Edition | Simulação funcional e análise temporal | [Preencher versão utilizada] |
| Verilog HDL | Implementação dos módulos de hardware | Linguagem |
| Python 3 | Scripts auxiliares para conversão de imagem e geração de `.mif` | [Preencher versão] |
| Editor/IDE de texto | Edição do código-fonte | [Preencher nome e versão] |
| Sistema Operacional | Ambiente base de desenvolvimento | [Preencher nome e versão] |

### 4.1 Softwares básicos

Além das ferramentas principais, também foram utilizados softwares básicos de apoio, como:

- navegador para consulta de documentação;
- compactadores e utilitários de gerenciamento de arquivos;
- terminal ou prompt de comando;
- drivers de programação da placa FPGA.

> Observação: antes da entrega final, esta seção deve ser preenchida com as versões exatas realmente usadas pelo grupo.

---

## 5. Especificação dos hardwares usados nos testes

Os testes principais da solução foram realizados utilizando a placa **DE1-SoC**, adotada como plataforma de validação do co-processador.

### 5.1 Hardware principal

| Hardware | Função |
|---|---|
| DE1-SoC | Execução e validação do projeto em FPGA |
| Cabo USB-Blaster / programação USB | Gravação do projeto na placa |
| Computador host | Compilação, síntese, simulação e transferência do projeto |

### 5.2 Recursos da placa utilizados no projeto

No uso local da placa, foram empregados:

- `CLOCK_50` como clock principal do sistema;
- `KEY[0]` como reset;
- `KEY[1]` como confirmação de comando;
- `SW[2:0]` como entrada local de opcode;
- `LEDR[3:0]` para exibição da predição;
- `LEDR[6:4]` para flags de carga;
- `HEX0..HEX3` para exibição temporária do status.

### 5.3 Observação sobre a arquitetura futura

Embora a validação local tenha sido feita com chaves e botões da DE1-SoC, a arquitetura do co-processador já foi organizada para futura substituição dessas entradas por um processador, mantendo barramentos de 32 bits para entrada de instruções e leitura de saída.

---

## 6. Processo de instalação e configuração do ambiente

Esta seção descreve o processo adotado para preparar o ambiente e utilizar a solução.

### 6.1 Preparação do ambiente

1. Instalar o **Intel Quartus Prime Lite Edition**.
2. Instalar o simulador compatível, como **ModelSim** ou **Questa Intel FPGA Edition**.
3. Instalar os drivers necessários para programação da placa DE1-SoC.
4. Garantir que o computador reconheça a FPGA corretamente.
5. Organizar os arquivos do projeto em uma estrutura de diretórios contendo:
   - módulos Verilog;
   - arquivos `.mif`;
   - testbenches;
   - documentação.

### 6.2 Criação e configuração do projeto no Quartus

1. Criar um novo projeto no Quartus.
2. Definir o módulo `top` como entidade principal.
3. Adicionar todos os arquivos `.v` ao projeto.
4. Associar corretamente os arquivos de memória utilizados pelas ROMs e RAMs.
5. Configurar a pinagem da placa DE1-SoC no arquivo `.qsf` ou pelo Pin Planner.
6. Definir padrão de I/O compatível com a placa.

### 6.3 Inclusão dos arquivos de memória

1. Garantir que os arquivos `.mif` estejam no diretório correto.
2. Confirmar que as memórias geradas no projeto apontam para os arquivos certos.
3. Verificar se o formato dos dados está compatível com Q4.12 quando necessário.

### 6.4 Compilação

1. Executar `Analysis & Synthesis`.
2. Executar `Fitter`.
3. Executar `Assembler`.
4. Verificar warnings e erros.
5. Gerar o arquivo de programação da FPGA.

### 6.5 Gravação na placa

1. Conectar a DE1-SoC ao computador.
2. Abrir o `Programmer` do Quartus.
3. Selecionar o hardware de programação.
4. Carregar o arquivo compilado.
5. Programar a FPGA.

### 6.6 Preparação para testes locais

1. Confirmar o funcionamento do clock e do reset.
2. Carregar a imagem, pesos e bias conforme o fluxo do sistema.
3. Usar os 3 bits menos significativos das chaves para escolher o comando.
4. Pressionar o botão de confirmação.
5. Observar LEDs e displays.

### 6.7 Preparação para simulação

1. Adicionar o testbench ao projeto de simulação.
2. Inicializar sinais de clock e reset.
3. Aplicar os vetores de entrada.
4. Executar a sequência de instruções.
5. Verificar predição, ciclos e status.

---

## 7. Tabela de instruções

A interface de controle do co-processador utiliza instruções de 32 bits. Na validação local em placa, apenas os 3 bits menos significativos são usados como opcode, enquanto os demais permanecem em zero.

### 7.1 Formato da instrução

```text
[31:3] = 0
[2:0]  = opcode
```
### 7.2 Instruções implementadas

| Valor decimal | Binário | Nome da instrução | Descrição |
|---|---|---|---|
| 0 | 000 | `CLEAR_ERR` | Limpa o estado de erro e retorna o sistema ao estado normal |
| 1 | 001 | `STORE_IMG` | Indica que a imagem foi carregada e habilita o uso do conjunto de entrada |
| 2 | 010 | `STORE_W` | Indica que os pesos da camada oculta foram carregados |
| 3 | 011 | `STORE_B` | Indica que os vieses foram carregados |
| 4 | 100 | `START` | Inicia a inferência completa da ELM |
| 5 | 101 | `STATUS` | Solicita a exibição do estado atual do co-processador e permite leitura do resultado consolidado |

### 7.3 Comentários sobre as instruções

A instrução `START` só executa corretamente quando os dados necessários já foram carregados. Caso contrário, o sistema pode entrar em estado de erro.

A instrução `STATUS` não altera a inferência. Sua função é disponibilizar a leitura do estado atual do hardware e da predição. Na implementação local, essa instrução também aciona temporariamente a exibição do estado nos displays de 7 segmentos.

As instruções `STORE_IMG`, `STORE_W` e `STORE_B` foram mantidas como comandos de controle da lógica, enquanto a escrita real dos dados nas memórias é feita pela interface Avalon/MMIO.

---

## 8. Correção funcional

### 8.1 O que o barema exige

O primeiro item do barema cobra **acurácia funcional do testbench comparado com o golden model** e também exige que a **simulação funcional ocorra sem falhas lógicas**, com acerto de pelo menos 90% dos vetores usados na validação. :contentReference[oaicite:0]{index=0}

### 8.2 Estratégia funcional adotada

A validação funcional do projeto foi baseada em três frentes:

1. verificação da sequência correta de comandos;
2. observação do fluxo interno da inferência;
3. comparação do resultado final com o comportamento esperado para imagens conhecidas.

Durante os testes, foram observados:

- reset correto do sistema;
- carregamento da imagem;
- carregamento de pesos e bias;
- início da inferência;
- transição entre os estados do controle;
- cálculo da predição final;
- leitura do status do co-processador.

Além disso, foi feita validação prática diretamente na DE1-SoC, usando imagens reais convertidas para `.mif`, o que permitiu identificar e corrigir ambiguidades em casos específicos, como os dígitos 3 e 7.

### 8.3 Ajustes funcionais realizados

Durante os testes em placa, alguns dígitos apresentaram confusão de classificação. Em especial, observou-se erro de predição em determinadas imagens do 3 e do 7. Após análise dos arquivos de imagem e dos `.mif` correspondentes, foi introduzido um pré-processamento simples de binarização da imagem de entrada por limiar, reduzindo tons intermediários que estavam deixando o padrão visual mais próximo de outras classes.

Esse ajuste foi inserido no caminho da camada oculta, antes da operação MAC, mantendo a lógica geral da solução, mas tornando a entrada mais robusta para o hardware.

### 8.4 Situação atual

O projeto já apresenta funcionamento coerente para a maior parte das imagens testadas, com fluxo completo de inferência executando sem travamentos lógicos. Para a entrega definitiva, ainda é necessário anexar ao repositório o testbench com comparação explícita contra o golden model e registrar quantitativamente a taxa de acerto alcançada.

---

## 9. Arquitetura do datapath

### 9.1 O que o barema exige

O barema solicita uma **FSM de controle completa**, um **MAC completo**, buffers/ROM para pesos e ativação implementada corretamente. Também pede que a FSM esteja documentada e que o código esteja comentado. :contentReference[oaicite:1]{index=1}

### 9.2 Organização do datapath

O datapath foi estruturado para realizar o processamento em duas etapas principais: camada oculta e camada de saída.

Na camada oculta:
- a imagem é lida da memória de entrada;
- os pesos correspondentes são lidos da memória de `W`;
- o módulo `Mac` realiza a multiplicação e acumulação em ponto fixo;
- o viés do neurônio é somado ao acumulador;
- a ativação é aplicada;
- o resultado é armazenado em memória intermediária `h_mem`.

Na camada de saída:
- os valores de `h_mem` são lidos;
- os coeficientes `beta` são acessados;
- o módulo `Mac` volta a ser utilizado para formar as saídas das classes;
- os resultados são armazenados em `y_mem`;
- por fim, o módulo `argmax` seleciona a classe de maior valor.

### 9.3 Módulos principais do projeto

A solução está organizada nos seguintes módulos:

**`elm_accel.v`**  
Módulo principal do co-processador. Reúne a lógica global do sistema, controla a execução da inferência, organiza o fluxo entre os estados e produz a saída consolidada de 32 bits.

**`Mem_block.v`**  
Agrupa as memórias de imagem, pesos, bias e beta.

**`Mac.v`**  
Implementa a multiplicação e o ajuste do produto para o formato Q4.12. Esse bloco é a base aritmética principal do datapath.

**`tanh_lut.v`**  
Implementa a função de ativação aproximada por LUT.

**`argmax.v`**  
Recebe as saídas das classes e determina a predição final selecionando o maior valor.

**`Control_unit.v`**  
Responsável pela apresentação do estado nos displays, utilizando o barramento de status e a lógica de visibilidade temporária.

**`top.v`**  
Wrapper usado para testes locais na placa DE1-SoC, conectando clock, botão, switches, LEDs e displays ao co-processador.

### 9.4 Máquina de estados

A FSM principal da solução foi mantida em três estados globais:

- `DONE`
- `BUSY`
- `ERROR`

A escolha foi feita para manter o controle global simples e bem definido. Dentro do estado `BUSY`, o processamento é refinado por fases internas, que controlam a ordem detalhada da inferência.

Essas fases incluem:
- endereçamento da imagem;
- espera de leitura;
- MAC da camada oculta;
- leitura de bias;
- ativação;
- armazenamento do vetor oculto;
- endereçamento da camada de saída;
- MAC das classes;
- argmax final.

Essa abordagem permitiu manter os estados principais estáveis, enquanto o detalhamento do processamento ficou distribuído em microetapas bem definidas.

### 9.5 Ativação

Embora o barema cite explicitamente ReLU como referência de avaliação, a implementação do grupo utiliza `tanh` aproximada via LUT, por compatibilidade com o modelo de inferência adotado. Essa decisão deve ser justificada no relatório, explicando que a lógica da solução foi orientada pelo comportamento do classificador utilizado no projeto e pela coerência com os testes realizados. :contentReference[oaicite:2]{index=2}

---

## 10. Paralelismo dos MAC

### 10.1 O que o barema exige

O barema considera como critério a replicação de MACs para ganho de throughput e se há comparação entre execução serial e paralela. :contentReference[oaicite:3]{index=3}

### 10.2 Situação da implementação atual

A implementação atual é **sequencial**. Ou seja, a inferência utiliza um caminho de processamento serial, reaproveitando a estrutura de MAC ao longo dos diferentes ciclos da camada oculta e da camada de saída.

Essa decisão foi tomada por três razões principais:

1. simplificação do controle;
2. redução da complexidade inicial do projeto;
3. maior facilidade de depuração funcional.

### 10.3 Consequências da escolha sequencial

Como resultado, a solução atual:
- utiliza menos recursos do que uma versão paralela;
- possui maior latência total;
- é mais simples de testar e depurar;
- serve como base sólida para futuras otimizações.

### 10.4 Evolução futura

Como possibilidade de evolução, o projeto pode ser ampliado com:
- replicação de múltiplas unidades `Mac`;
- leitura paralela de múltiplos pesos;
- ajuste da FSM para contagem paralela;
- redução do número total de ciclos de inferência.

Para cumprir integralmente esse item do barema, recomenda-se acrescentar ao relatório uma estimativa comparativa entre a versão sequencial atual e uma versão paralela proposta, mesmo que ainda não implementada. :contentReference[oaicite:4]{index=4}

---

## 11. Interface MMIO

### 11.1 O que o barema exige

O barema pede documentação completa dos registradores **CTRL / STATUS / RESULT / CYCLES**, incluindo offsets, bits, formato das instruções e um testbench de leitura/escrita da interface MMIO. :contentReference[oaicite:5]{index=5}

### 11.2 Formato da entrada

A entrada principal do co-processador foi organizada como um barramento de **32 bits** chamado `sw`.

Na placa:
- apenas os **3 bits menos significativos** são usados;
- os outros 29 bits permanecem em zero.

No futuro:
- esse mesmo barramento de 32 bits poderá ser dirigido por um processador, substituindo as chaves físicas.

### 11.3 Formato dos comandos

Os comandos utilizados atualmente são:

| Valor decimal | Binário (3 LSB) | Comando |
|---|---|---|
| 0 | 000 | CLEAR_ERR |
| 1 | 001 | STORE_IMG |
| 2 | 010 | STORE_W |
| 3 | 011 | STORE_B |
| 4 | 100 | START |
| 5 | 101 | STATUS |

### 11.4 Formato da saída

A saída principal do co-processador é um barramento de **32 bits** chamado `result_out`, organizado da seguinte forma:

| Bits | Campo |
|---|---|
| 0 | `BUSY` |
| 1 | `DONE` |
| 2 | `ERROR` |
| 6:3 | Predição |
| 7 | `b_ok` |
| 8 | `w_ok` |
| 9 | `img_ok` |
| 11:10 | Estado codificado |
| 31:12 | Reservado |

Essa organização já foi pensada para que um processador consiga ler esse barramento e interpretar tanto o estado quanto a classe prevista.

### 11.5 Leitura por MMIO

A leitura via Avalon/MMIO foi organizada com os seguintes offsets:

| Offset | Nome lógico | Função |
|---|---|---|
| `0x3` | STATUS/RESULT | Resultado consolidado de 32 bits |
| `0x4` | PRED | Predição expandida |
| `0x5` | CYCLES | Número de ciclos da inferência |

### 11.6 Handshake

O protocolo funcional observado no projeto segue a sequência:

- comando é enviado;
- o hardware entra em `BUSY`;
- a FSM executa a inferência;
- o hardware retorna a `DONE`;
- em caso de inconsistência, vai para `ERROR`.

Isso atende à ideia de handshake **start → busy → done** pedida no barema. :contentReference[oaicite:6]{index=6}

---

## 12. Ciclo de instrução

### 12.1 O que o barema exige

O barema pede protocolo **Start-Execute-Done**, reset funcional e latência determinística. :contentReference[oaicite:7]{index=7}

### 12.2 Fluxo implementado

O ciclo de instrução do sistema foi estruturado assim:

1. um comando é colocado em `sw`;
2. o botão `confirm_btn` gera o pulso de confirmação;
3. o comando é capturado pela lógica de controle;
4. se o comando for `START`, a inferência é iniciada;
5. o sistema entra em `BUSY`;
6. as fases internas realizam leitura, multiplicação, ativação, armazenamento e decisão final;
7. a predição é gerada;
8. o sistema retorna ao estado `DONE`.

### 12.3 Reset

O reset limpa:
- estado principal;
- opcode atual;
- fase;
- índices;
- acumuladores;
- predição;
- contadores;
- flags;
- memórias intermediárias.

### 12.4 Latência

A solução apresenta latência determinística porque o fluxo percorre uma sequência fixa de etapas para cada neurônio oculto e para cada classe de saída. Além disso, há um contador de ciclos (`cycles_reg`) que registra o custo total da inferência, permitindo mensurar o tempo de execução do hardware.

---

## 13. Descrição detalhada dos testes de funcionamento

Os testes de funcionamento foram organizados para verificar tanto a lógica de controle quanto o comportamento final da inferência.

### 13.1 Testes de controle

Foram realizados testes para validar:

- reset do sistema;
- transição entre os estados `DONE`, `BUSY` e `ERROR`;
- interpretação correta dos opcodes;
- comportamento do comando `STATUS`;
- retorno ao estado normal após limpeza de erro.

### 13.2 Testes do datapath

Foram observados:

- leitura da imagem em memória;
- leitura dos pesos e dos bias;
- funcionamento da multiplicação e reescala em Q4.12;
- aplicação da ativação;
- armazenamento da camada oculta;
- cálculo das saídas da camada final;
- seleção da predição pelo bloco `argmax`.

### 13.3 Testes em placa

Na DE1-SoC, os testes locais seguiram a sequência:

1. carregar a configuração da FPGA;
2. usar `SW[2:0]` para selecionar o comando;
3. usar `KEY[1]` para enviar o comando;
4. observar `LEDR[3:0]` para a predição;
5. observar `LEDR[6:4]` para flags de carga;
6. usar `STATUS` para visualizar o estado no display.

### 13.4 Testes com imagens reais

Foram utilizados arquivos de imagem convertidos para `.mif`. Essa etapa permitiu verificar o comportamento do sistema com dados próximos do uso real esperado pelo problema.

Durante esses testes, foram identificados casos em que o classificador confundia algumas imagens específicas. A partir disso, foi introduzido um ajuste de pré-processamento por limiarização da entrada para reduzir ambiguidades visuais.

### 13.5 Testes de leitura por MMIO

Também foi considerado o fluxo de leitura por Avalon/MMIO, com verificação dos offsets destinados a:

- resultado consolidado;
- predição expandida;
- contagem de ciclos.

> Para a versão final da entrega, recomenda-se incluir um testbench específico de escrita/leitura MMIO, conforme solicitado pelo barema. :contentReference[oaicite:8]{index=8}

---

## 14. Softwares e códigos usados para automação dos testes

A automação dos testes foi apoiada pelos seguintes recursos:

| Recurso | Uso |
|---|---|
| Testbench em Verilog | Simulação funcional do co-processador |
| ModelSim / Questa | Execução da simulação e observação temporal |
| Scripts em Python | Conversão de imagens para `.mif` e preparação de dados |
| Quartus Prime | Compilação e validação estrutural do projeto |

### 14.1 Testbench

O testbench tem como objetivo automatizar:

- geração de clock;
- aplicação de reset;
- envio da sequência de comandos;
- observação do estado final;
- verificação da saída produzida pelo hardware.

### 14.2 Scripts auxiliares

Foram utilizados scripts auxiliares para:

- transformar imagens PNG em arquivos `.mif`;
- adequar os valores para o formato esperado pelo hardware;
- facilitar a repetição dos testes com diferentes imagens.

### 14.3 Pendência para a entrega final

Na versão final do repositório, esta seção deve incluir:
- nomes dos arquivos de testbench;
- nomes dos scripts usados;
- breve descrição da função de cada script;
- exemplos de execução.

---

## 15. Uso de recursos

### 15.1 O que o barema exige

O barema exige estimativa de uso de:
- LUT
- FF
- DSP
- BRAM
- frequência máxima

e pede que isso seja acompanhado de screenshots do Quartus. :contentReference[oaicite:9]{index=9}

### 15.2 Estratégia da implementação

A solução foi pensada para ser compacta em recursos, priorizando inicialmente a correção funcional. Como a arquitetura é sequencial, espera-se:

- consumo menor de DSPs do que uma arquitetura paralela;
- controle mais simples;
- menor ocupação lógica global;
- maior número de ciclos por inferência.

### 15.3 O que deve ser documentado

Antes da entrega final do Marco 1, o grupo deve acrescentar:

- captura do relatório de uso de recursos;
- captura da frequência máxima;
- justificativa técnica para o consumo observado;
- comparação entre os recursos usados e o limite recomendado.

---

## 16. Análise dos resultados alcançados

Os resultados parciais obtidos até o momento mostram que a arquitetura implementada já é capaz de executar o fluxo completo de inferência da ELM em hardware, com separação clara entre controle, processamento e exibição do resultado.

Entre os resultados mais relevantes, destacam-se:

- funcionamento da FSM principal;
- execução correta do fluxo de start, processamento e finalização;
- saída de predição em LEDs;
- saída consolidada em 32 bits para futura integração com processador;
- exibição controlada do status nos displays da placa;
- capacidade de teste em placa real com a DE1-SoC.

Além disso, os testes com imagens reais permitiram identificar limitações do sistema em situações específicas. Isso foi importante porque mostrou que o hardware estava funcional, mas sensível à forma como a imagem de entrada era representada. Como consequência, foi introduzido um ajuste de pré-processamento por binarização, melhorando o comportamento em alguns casos de confusão.

Do ponto de vista de engenharia, os resultados indicam que:

- a base do hardware está funcional;
- a estratégia sequencial foi adequada para depuração e validação inicial;
- a interface está suficientemente organizada para evolução futura;
- ainda há espaço para melhorias em automação de testes, análise de recursos e comparação com modelo de referência.

### 16.1 Limitações observadas

As principais limitações atuais são:

- ausência, até o momento, de uma tabela final com comparação contra golden model;
- falta de quantificação consolidada da acurácia;
- ausência de uma versão paralela do datapath para comparação de desempenho;
- necessidade de anexar métricas do Quartus.

### 16.2 Síntese da análise

Mesmo com as pendências de documentação final, os resultados obtidos mostram que o grupo conseguiu construir uma base funcional e coerente com os objetivos do Marco 1, atendendo à maior parte dos requisitos estruturais do problema e preparando o projeto para continuação nos próximos marcos.

---

## 17. Estrutura dos arquivos

A organização atual do repositório é:

```text
.
├── rtl/
│   ├── elm_accel.v
│   ├── Mem_block.v
│   ├── Mac.v
│   ├── tanh_lut.v
│   ├── argmax.v
│   ├── Control_unit.v
│   └── top.v
├── mif/
│   ├── image.mif
│   ├── weights.mif
│   ├── bias.mif
│   └── beta.mif
├── docs/
│   ├── fsm.png
│   ├── mmio_table.png
│   ├── quartus_resources.png
│   └── quartus_fmax.png
└── README.md
```
## 18. Como executar na placa DE1-SoC

A placa DE1-SoC foi utilizada como plataforma de validação local do co-processador. Nessa etapa, o objetivo principal não foi apenas verificar se o projeto sintetizava corretamente, mas também confirmar se o fluxo completo de controle e inferência funcionava de forma coerente em hardware real.

Na prática, o uso local da placa foi organizado de maneira simples para facilitar a observação do comportamento do sistema:

- as chaves `SW[2:0]` são usadas para selecionar o comando;
- o botão de confirmação envia esse comando ao co-processador;
- os LEDs mostram a predição e algumas flags de controle;
- os displays mostram o estado do sistema quando a instrução `STATUS` é solicitada.

### 18.1 Sequência típica de uso

A sequência básica de operação usada nos testes foi:

1. carregar o hardware na FPGA;
2. selecionar o comando desejado nas chaves `SW[2:0]`;
3. pressionar o botão de confirmação;
4. repetir a sequência conforme o tipo de comando;
5. observar LEDs e displays.

Na lógica atual, a ordem típica de uso é:

1. `STORE_IMG`
2. `STORE_W`
3. `STORE_B`
4. `START`
5. `STATUS`

Essa ordem foi adotada porque a instrução `START` só deve ser executada após o carregamento dos dados necessários. Caso contrário, o sistema pode ir para estado de erro, o que também foi previsto como parte do comportamento esperado da lógica de controle.

### 18.2 Leitura visual em placa

Durante os testes locais, a observação do sistema foi feita da seguinte forma:

- `LEDR[3:0]` mostram a predição final;
- `LEDR[6:4]` mostram flags de carregamento;
- `HEX0..HEX3` mostram o status atual do sistema, de forma temporária, quando o comando `STATUS` é solicitado.

Essa estratégia foi importante porque permitiu validar o comportamento do hardware mesmo antes da integração com um processador externo.

### 18.3 Vantagem dessa abordagem

Essa forma de execução em placa foi útil porque:
- simplificou a depuração do sistema;
- permitiu observar rapidamente se os comandos estavam sendo aceitos;
- ajudou a validar o ciclo de instrução;
- serviu como base para futuras etapas de integração com processador.

---

## 19. Resultados parciais

Os resultados obtidos até o momento mostram que a arquitetura implementada já consegue executar o fluxo principal de inferência da ELM em hardware. A organização do controle, o uso do datapath e o retorno da predição funcionaram de forma coerente na maioria dos testes realizados.

Entre os principais resultados observados, destacam-se:

- funcionamento consistente da FSM principal;
- execução correta do protocolo de início, processamento e finalização;
- saída de predição em LEDs;
- saída consolidada em 32 bits para futura leitura por processador;
- exibição controlada do estado nos displays;
- validação prática na placa DE1-SoC.

Além disso, os testes com imagens reais mostraram que o sistema é sensível à qualidade visual da entrada, especialmente em casos de dígitos com traços mais próximos entre si. Essa observação foi importante porque mostrou que o problema não estava apenas no controle do hardware, mas também na forma como a imagem era representada na entrada.

### 19.1 Casos de confusão observados

Durante os testes realizados em placa, foram encontrados casos em que a classificação retornava um dígito incorreto para determinadas imagens específicas. Entre os exemplos observados:

- o dígito **7** foi confundido com **1**;
- o dígito **3** foi confundido com **8**.

A análise dessas imagens indicou que tons intermediários e borrões podiam deixar a entrada visualmente mais próxima de outras classes. Isso levou à adoção de um pré-processamento mais rígido da imagem por limiarização, reduzindo a influência de pixels fracos no cálculo da camada oculta.

### 19.2 Impacto dos ajustes

A introdução da binarização da entrada melhorou a robustez do sistema em alguns dos casos problemáticos e mostrou que a etapa de pré-processamento influencia diretamente a qualidade da inferência, mesmo quando a lógica do hardware está correta.

Do ponto de vista do projeto, isso foi um resultado importante, porque mostrou que a validação não depende apenas da síntese do circuito, mas também da compatibilidade entre os dados de entrada e a forma como o classificador os interpreta.

---

## 20. Limitações atuais

Apesar do avanço do projeto e do funcionamento já demonstrado em placa, ainda existem limitações e pendências para que a entrega fique totalmente alinhada ao barema do Marco 1.

As principais limitações atuais são:

- ainda não há uma tabela final consolidada comparando o hardware com um golden model;
- a acurácia total do sistema ainda não foi quantificada formalmente;
- ainda não foi implementada uma versão paralela para comparação de desempenho com a arquitetura sequencial;
- ainda faltam capturas e métricas completas do Quartus sobre recursos e frequência máxima;
- o conjunto final de testes automatizados ainda precisa ser formalizado no repositório.

Essas limitações não invalidam a base funcional já construída, mas indicam pontos importantes para fechamento da documentação e fortalecimento da entrega.

### 20.1 Limitação de arquitetura

A opção por uma arquitetura sequencial simplificou bastante o desenvolvimento inicial, mas também trouxe uma consequência natural: a latência é maior do que seria em uma solução paralela.

Assim, a implementação atual é boa para:
- validar a lógica;
- entender o fluxo;
- depurar comportamento funcional;

mas ainda não representa a solução mais otimizada possível em termos de throughput.

### 20.2 Limitação de documentação

Outra limitação importante é que parte da documentação ainda precisa ser complementada com evidências mais formais, como:

- diagrama final da FSM;
- prints do relatório de síntese;
- tabela MMIO consolidada;
- análise quantitativa da taxa de acerto.

---

## 21. Próximos passos

Para fortalecer a entrega final do Marco 1, os próximos passos recomendados são:

1. concluir a validação com comparação sistemática contra um golden model;
2. medir e documentar a taxa de acerto funcional do hardware;
3. registrar a quantidade total de ciclos da inferência completa;
4. complementar a documentação da FSM com diagrama;
5. organizar a documentação final da interface MMIO;
6. coletar e anexar screenshots do Quartus com:
   - uso de LUTs;
   - uso de FFs;
   - uso de DSPs;
   - uso de BRAMs;
   - frequência máxima estimada;
7. elaborar uma comparação entre a arquitetura sequencial atual e uma proposta paralela;
8. consolidar os scripts e arquivos auxiliares de teste que foram usados durante o desenvolvimento.

### 21.1 Evolução esperada para os próximos marcos

A organização atual do projeto já prepara a solução para uma próxima etapa de integração com processador, em que:

- as chaves deixarão de ser a origem do comando;
- um processador passará a enviar comandos de 32 bits;
- a saída de 32 bits do co-processador será interpretada externamente;
- o controle local em placa deixará de ser apenas manual e passará a fazer parte de um fluxo maior de hardware + software.

Isso mostra que a estrutura atual não foi pensada apenas para “passar na placa”, mas para servir como base de integração futura.

---

## 22. Conclusão

Este trabalho em grupo, desenvolvido por Arthur de Andrade Souza, Lucas Vilas Boas Dourado e Pedro Santos, apresenta a implementação de um co-processador ELM em FPGA voltado para o Marco 1 da disciplina TEC499.

A solução construída já oferece uma base sólida de hardware, com:

- arquitetura funcional em Verilog;
- controle estruturado por máquina de estados;
- datapath com multiplicação, acumulação, ativação e decisão final;
- interface local para testes na DE1-SoC;
- barramento de saída de 32 bits preparado para futura integração com processador.

Mesmo existindo pontos a complementar para a entrega final, o projeto já demonstra que o grupo conseguiu construir uma solução coerente, funcional e tecnicamente organizada, capaz de realizar a inferência em hardware e de servir como base para evolução nos próximos marcos da disciplina.

De forma geral, os resultados alcançados até aqui mostram que:

- a solução atende ao núcleo do problema proposto para o Marco 1;
- a arquitetura sequencial foi adequada para a etapa de validação inicial;
- os testes em placa foram essenciais para identificar e corrigir problemas reais de classificação;
- a interface em 32 bits já deixa o sistema preparado para futuras extensões.

---

## 23. Checklist para entrega final

Abaixo está um checklist resumido dos itens que ainda devem ser conferidos antes da entrega definitiva do Marco 1:

- [ ] Código Verilog comentado
- [ ] Diagrama da FSM
- [ ] Comparação funcional com golden model
- [ ] Taxa de acerto consolidada
- [ ] Tabela formal de MMIO
- [ ] Medição da latência total em ciclos
- [ ] Comparação serial vs. paralelo
- [ ] Relatório de uso de recursos
- [ ] Frequência máxima
- [ ] Análise final dos resultados

Esse checklist foi organizado para ajudar o grupo a verificar rapidamente se o material final da entrega está coerente com o barema de avaliação e com o conteúdo mínimo exigido pelo enunciado.
