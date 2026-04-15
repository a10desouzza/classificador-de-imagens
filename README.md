# Co-processador ELM em FPGA para Classificação de Dígitos
## MI Sistemas Digitais 2026.1 — Marco 1

## 1. Apresentação do projeto

Este repositório reúne a implementação do **Marco 1** da disciplina **MI Sistemas Digitais**, com foco no desenvolvimento de um **co-processador em FPGA** capaz de realizar a inferência de dígitos numéricos a partir de imagens.

O trabalho foi desenvolvido em grupo por:

- **Arthur de Andrade Souza**
- **Lucas Vilas Boas Dourado**
- **Pedro Henrique Santos Silva**

A proposta do projeto foi construir, em hardware, uma base funcional de inferência inspirada em uma **ELM (Extreme Learning Machine)**, usando a placa **DE1-SoC** como plataforma de testes. Mais do que apenas “fazer rodar”, a ideia foi estruturar uma solução organizada, compreensível e preparada para evoluir nos próximos marcos.

---

## 2. Objetivo

O objetivo deste marco foi implementar um núcleo de hardware capaz de:

- receber os dados necessários para a inferência;
- controlar o fluxo de execução por meio de uma máquina de estados;
- processar a imagem de entrada em hardware;
- calcular a saída final da rede;
- indicar o estado atual do sistema;
- retornar a predição do dígito classificado;
- preparar a arquitetura para futura integração com um processador.

Em outras palavras, este projeto busca mostrar que a inferência pode ser feita diretamente em FPGA, com controle próprio, memórias organizadas e saída interpretável tanto na placa quanto futuramente por software externo.

---

## 3. Levantamento de requisitos

Para o desenvolvimento da solução, foram considerados os seguintes requisitos.

### 3.1 Requisitos funcionais

O sistema deve:

- aceitar comandos de controle;
- permitir o carregamento lógico de imagem, pesos e bias;
- iniciar a inferência apenas quando os dados necessários estiverem prontos;
- retornar a predição final;
- indicar estados como ocupado, concluído e erro;
- permitir leitura do resultado em barramento de 32 bits;
- funcionar localmente na placa e, no futuro, poder ser controlado por um processador.

### 3.2 Requisitos de arquitetura

A solução deve possuir:

- uma **FSM de controle**;
- uma **unidade MAC**;
- memórias para imagem, pesos, bias e beta;
- função de ativação em hardware;
- bloco de decisão final por comparação entre classes;
- suporte a reset;
- contagem de ciclos para análise de latência.

### 3.3 Requisitos de validação

Também foram considerados como requisitos importantes:

- funcionamento coerente em simulação e em placa;
- organização clara do datapath;
- documentação da interface de controle;
- análise dos resultados obtidos;
- possibilidade de expansão para futuras integrações.

---

## 4. Softwares utilizados

Os principais softwares usados no desenvolvimento, teste e compilação do projeto foram os seguintes:

| Software | Finalidade | Versão |
|---|---|---|
| Intel Quartus Prime Lite Edition | Síntese, compilação, pinagem e geração do projeto para FPGA | [25.1] |
| Verilog HDL | Implementação dos módulos do sistema | Linguagem |
| Python 3 | Apoio na conversão de imagens e geração de arquivos `.mif` | [Atual] |

### 4.1 Softwares básicos de apoio

Além das ferramentas principais, também foram utilizados:

- terminal/prompt de comando;
- navegador para consulta de documentação;
- utilitários de manipulação de arquivos;
- drivers necessários para uso da DE1-SoC.

> Antes da entrega final, recomenda-se preencher esta seção com os nomes e versões exatas realmente utilizadas pelo grupo.

---

## 5. Hardware utilizado nos testes

Os testes principais foram realizados com a placa **DE1-SoC**, utilizada como plataforma de validação local do projeto.

### 5.1 Hardware principal

| Hardware | Função |
|---|---|
| DE1-SoC | Execução do projeto em FPGA |
| Cabo de programação USB | Gravação do projeto na placa |
| Computador host | Compilação, simulação e transferência |

### 5.2 Recursos da placa usados no projeto

Durante os testes locais, foram utilizados:

- `CLOCK_50` como clock principal;
- `KEY[0]` como reset;
- `KEY[1]` como botão de confirmação de comando;
- `KEY[3]` como botão de preparação de dados para o `STORE`;
- `SW[2:0]` como opcode;
- `SW[5:3]` como endereço de teste;
- `SW[8:6]` como dado de teste;
- `LEDR[3:0]` para mostrar a predição;
- `LEDR[6:4]` para mostrar flags de carregamento;
- `HEX0..HEX3` para exibir o status do sistema.

---

## 6. Processo de instalação e configuração do ambiente

Esta seção descreve o fluxo básico para preparar o ambiente e utilizar a solução.

### 6.1 Preparação inicial

1. Instalar o **Intel Quartus Prime Lite Edition**.
2. Instalar um simulador compatível, como **ModelSim** ou **Questa Intel FPGA Edition**.
3. Instalar os drivers da placa DE1-SoC.
4. Organizar os arquivos do projeto em uma estrutura consistente.
5. Garantir que os arquivos `.mif` estejam nos locais corretos.

### 6.2 Configuração do projeto no Quartus

1. Criar um novo projeto no Quartus.
2. Definir o módulo `top` como entidade principal.
3. Adicionar todos os arquivos `.v` ao projeto.
4. Garantir que as memórias instanciadas estejam apontando corretamente para seus arquivos de inicialização.
5. Fazer a pinagem da DE1-SoC pelo Pin Planner ou pelo `.qsf`.
6. Compilar o projeto.

### 6.3 Programação da placa

1. Conectar a DE1-SoC ao computador.
2. Abrir o programador do Quartus.
3. Selecionar o hardware correto.
4. Carregar o arquivo compilado.
5. Programar a FPGA.

### 6.4 Preparação para uso local

1. Verificar se o reset está funcionando.
2. Confirmar se a placa foi programada corretamente.
3. Selecionar o comando desejado nos switches.
4. Usar `KEY[1]` para enviar o comando.
5. Usar `KEY[3]` apenas quando quiser preparar dados para um `STORE` real.

---

## 7. Interface de controle e tabela de instruções

A interface principal foi organizada em **32 bits**, mesmo que, na placa, apenas alguns bits estejam sendo usados no momento.

### 7.1 Formato da entrada

Na prática, o barramento é usado assim:

```text
SW[2:0] = opcode
SW[5:3] = endereço de teste
SW[8:6] = dado de teste
```
### 7.2 Instruções implementadas

| Valor decimal | Binário | Nome da instrução | Função |
|---|---|---|---|
| 0 | 000 | `CLEAR_ERR` | Limpa o estado de erro e devolve o sistema ao estado normal |
| 1 | 001 | `STORE_IMG` | Confirma ou grava a imagem na memória |
| 2 | 010 | `STORE_W` | Confirma ou grava os pesos da camada oculta |
| 3 | 011 | `STORE_B` | Confirma ou grava os bias |
| 4 | 100 | `START` | Inicia a inferência |
| 5 | 101 | `STATUS` | Mostra o estado atual do sistema |

### 7.3 Como o `STORE` foi pensado

Uma parte importante deste projeto foi ajustar o funcionamento do `STORE` para que ele fizesse sentido tanto no cenário atual quanto em uma futura integração com processador.

Hoje, o sistema pode funcionar de duas maneiras:

**Modo 1 — uso com arquivos `.mif`**  
Nesse caso, os dados já estão carregados nas memórias desde o início. Então, quando usamos `STORE_IMG`, `STORE_W` ou `STORE_B`, o objetivo principal é apenas confirmar logicamente que aquele bloco está pronto. Ou seja, a memória não precisa ser alterada; o comando serve para levantar a flag correspondente e permitir o avanço do fluxo.

**Modo 2 — escrita manual de teste**  
Também deixamos preparado um modo de teste em que é possível montar um dado simples pelos switches, preparar esse valor com um botão e depois usar o `STORE` para realmente gravar na memória. Esse modo foi mantido porque ajuda a validar o caminho de escrita e também deixa a arquitetura mais preparada para o futuro.

Na prática, isso significa que o `STORE` ficou mais flexível: ele pode servir apenas como confirmação lógica ou como escrita real, dependendo de como o sistema estiver sendo usado.

---

## 8. Visão geral da arquitetura

A arquitetura foi organizada para ficar clara, modular e fácil de manter. A ideia não foi só “fazer funcionar”, mas construir uma base que permita entender bem o fluxo do projeto.

Os principais blocos da solução são:

- `top.v`
- `elm_accel.v`
- `Mem_block.v`
- `Mac.v`
- `tanh_lut.v`
- `argmax.v`
- `Control_unit.v`

Cada um desses módulos tem um papel específico dentro do projeto.

### 8.1 `top.v`

O módulo `top` é a interface entre a placa e o acelerador. É nele que entram:

- clock da placa;
- botões;
- switches;
- LEDs;
- displays de 7 segmentos.

Ele é responsável por empacotar os sinais físicos da placa no formato que o acelerador espera e por conectar as saídas do sistema aos elementos visuais da DE1-SoC.

### 8.2 `elm_accel.v`

Esse é o núcleo principal do projeto. É nele que ficam:

- os comandos;
- os estados principais;
- a FSM da inferência;
- o controle do `STORE`;
- os índices da camada oculta e da camada de saída;
- o cálculo do resultado final;
- a montagem da saída de 32 bits.

Se o projeto fosse comparado a um organismo, esse módulo seria o “centro nervoso” do sistema.

### 8.3 `Mem_block.v`

Esse bloco reúne as memórias usadas pelo acelerador:

- memória da imagem;
- memória dos pesos da camada oculta;
- memória dos bias;
- ROM com os coeficientes beta.

Ele também resolve a prioridade entre leitura e escrita, permitindo que o sistema tanto acesse os dados durante a inferência quanto grave novos valores quando necessário.

### 8.4 `Mac.v`

O módulo `Mac` faz a multiplicação dos operandos e depois reescala o resultado para manter os números no formato Q4.12. Ele é essencial no cálculo tanto da camada oculta quanto da camada de saída.

### 8.5 `tanh_lut.v`

Esse bloco implementa a função de ativação usando uma aproximação por LUT e interpolação por trechos. A escolha foi feita para manter o hardware simples e ainda assim preservar o comportamento esperado da ativação.

### 8.6 `argmax.v`

Depois que as saídas das classes são calculadas, esse módulo compara todas elas e escolhe a maior. O índice correspondente é a predição final.

### 8.7 `Control_unit.v`

Apesar do nome, neste projeto ele é responsável principalmente pela exibição do estado nos displays. Ele mostra mensagens como `BUSY`, `DONE` ou `ERRO`, tornando o comportamento do sistema mais fácil de acompanhar diretamente na placa.

---

## 9. Organização do fluxo da inferência

A inferência acontece em duas etapas principais: camada oculta e camada de saída.

### 9.1 Primeira etapa: camada oculta

Para cada neurônio oculto, o sistema:

1. lê os pixels da imagem;
2. lê os pesos correspondentes;
3. multiplica os dois valores;
4. acumula o resultado;
5. soma o bias;
6. aplica a ativação;
7. guarda o valor calculado em uma memória interna.

Essa etapa transforma a entrada bruta da imagem em um vetor intermediário mais útil para a classificação.

### 9.2 Segunda etapa: camada de saída

Depois da camada oculta, o sistema:

1. lê os valores armazenados em `h_mem`;
2. lê os coeficientes `beta`;
3. faz novas multiplicações e acumulações;
4. gera as saídas das classes;
5. compara essas saídas no `argmax`.

No fim desse processo, o sistema escolhe qual dígito tem a maior pontuação e apresenta essa classe como resposta.

---

## 10. Máquina de estados

Para manter o controle do sistema simples e robusto, a FSM principal foi estruturada com três estados:

- `DONE`
- `BUSY`
- `ERROR`

### 10.1 `DONE`

Esse é o estado de repouso. Quando o sistema está em `DONE`, ele está pronto para receber um novo comando.

### 10.2 `BUSY`

Esse estado indica que algo está acontecendo. Pode ser:

- um `STORE`;
- a execução da inferência;
- algum processamento interno.

Enquanto o sistema está em `BUSY`, ele não deve aceitar qualquer nova ação que quebre o fluxo.

### 10.3 `ERROR`

Esse estado é usado quando acontece alguma situação inválida, como tentar iniciar a inferência sem ter confirmado os blocos necessários antes. Quando isso ocorre, o sistema para naquele estado até receber o comando de limpeza de erro.

### 10.4 Fases internas

Dentro de `BUSY`, principalmente durante o `START`, o sistema passa por várias fases menores. Essas fases existem para organizar o processamento passo a passo, por exemplo:

- leitura da imagem;
- espera da memória;
- multiplicação e acumulação;
- leitura do bias;
- ativação;
- leitura dos betas;
- cálculo das saídas;
- seleção da classe final.

Essa divisão deixa o comportamento do hardware mais previsível e mais fácil de depurar.

---

## 11. Formato numérico usado

O projeto trabalha com números em **ponto fixo Q4.12**.

Isso quer dizer que:

- o número total tem 16 bits;
- 12 desses bits representam a parte fracionária.

Essa escolha foi importante porque o uso de ponto fixo simplifica bastante o hardware em comparação com ponto flutuante. Ao mesmo tempo, ainda oferece precisão suficiente para o cálculo da inferência.

---

## 12. Funcionamento prático do `STORE`

Como o `STORE` foi uma parte que exigiu bastante ajuste, vale explicar com calma o que ele faz na prática.

### 12.1 Quando queremos apenas levantar a flag

Se a memória já foi inicializada por `.mif`, então não há necessidade de escrever de novo. Nesse caso:

- o `STORE_IMG` apenas levanta `img_ok`;
- o `STORE_W` apenas levanta `w_ok`;
- o `STORE_B` apenas levanta `b_ok`.

Ou seja, o comando serve como confirmação lógica.

### 12.2 Quando queremos realmente gravar algo

Se a intenção for testar escrita manual, o fluxo muda:

1. colocamos nos switches o opcode, o endereço e o dado;
2. usamos `KEY[3]` para preparar essa escrita;
3. usamos `KEY[1]` para confirmar o `STORE`.

A partir daí, se houver dado preparado, a memória correspondente é alterada.

### 12.3 Por que isso foi útil

Esse mecanismo foi importante porque resolveu um problema prático do projeto: o sistema precisava funcionar bem no presente, com arquivos `.mif`, mas também precisava já nascer com uma estrutura compatível com uma futura escrita externa por processador.

---

## 13. Funcionamento na placa

Nos testes em placa, o sistema foi usado com a seguinte lógica:

- `SW[2:0]` definem o comando;
- `SW[5:3]` definem um endereço de teste;
- `SW[8:6]` definem um dado de teste;
- `KEY[1]` envia a instrução principal;
- `KEY[3]` prepara uma escrita manual para o `STORE`.

### 13.1 Fluxo mais comum

No uso com memórias inicializadas por `.mif`, a sequência típica foi:

1. `STORE_IMG`
2. `STORE_W`
3. `STORE_B`
4. `START`
5. `STATUS`

Esse fluxo foi suficiente para validar o comportamento completo do acelerador.

### 13.2 O que aparece visualmente

Durante os testes, usamos a placa para acompanhar o sistema em tempo real:

- os LEDs mostram a predição e as flags;
- os displays mostram o estado atual quando o `STATUS` é solicitado.

Isso ajudou bastante a verificar se o controle interno estava realmente funcionando como esperado.

---

## 14. Testes realizados

Os testes foram feitos de forma gradual, começando pelo comportamento mais básico e depois avançando para o fluxo completo da inferência.

### 14.1 Testes de controle

Primeiro foram verificados:

- reset;
- resposta aos botões;
- reconhecimento dos opcodes;
- mudança entre `DONE`, `BUSY` e `ERROR`;
- funcionamento do `STATUS`.

### 14.2 Testes do `STORE`

Depois disso, foi importante confirmar:

- `STORE` apenas levantando flags;
- `STORE` com escrita real após preparação;
- não alteração da memória quando não havia preparação válida.

### 14.3 Testes da inferência

Na etapa seguinte, foram observados:

- leitura dos pixels;
- leitura dos pesos;
- soma no acumulador;
- soma do bias;
- aplicação da ativação;
- cálculo da camada de saída;
- decisão da classe final.

### 14.4 Testes com imagens reais

Também foram usados arquivos de imagem convertidos para `.mif`, justamente para aproximar o teste do uso real do sistema.

Esses testes foram importantes porque mostraram que o projeto não estava funcionando apenas “no papel”, mas também em condições próximas da aplicação final.

---

## 15. Resultados observados

Os resultados alcançados até agora mostram que o projeto já possui uma base funcional bastante consistente.

Entre os principais pontos positivos, podemos destacar:

- o fluxo de controle está funcionando;
- a inferência completa consegue ser executada em hardware;
- a predição final é calculada corretamente na maior parte dos casos;
- o estado do sistema pode ser acompanhado em placa;
- a saída de 32 bits já deixa o projeto pronto para evolução futura.

Outro ponto importante foi a correção do `STORE`, que deixou de ser apenas uma ideia incompleta e passou a ter um comportamento bem definido, tanto no modo de confirmação lógica quanto no modo de escrita real.

---

## 16. Limitações atuais

Mesmo com os avanços, ainda existem pontos que podem ser melhorados:

- falta consolidar uma taxa de acerto formal;
- ainda não há uma comparação mais completa com um golden model;
- a documentação pode ganhar mais diagramas;
- ainda faltam métricas finais do Quartus sobre uso de recursos e frequência máxima;
- a arquitetura continua sequencial e, portanto, não é a mais rápida possível.

Essas limitações são naturais nesta fase do projeto e ajudam a mostrar o que ainda pode ser aperfeiçoado.

---

## 17. Próximos passos

O projeto já chegou em um ponto em que dá para enxergar bem o que está funcionando e também o que ainda pode evoluir. A base principal foi construída, o fluxo de controle existe, a inferência roda em hardware e a saída já pode ser acompanhada na placa. A partir daqui, os próximos passos deixam de ser “fazer aparecer alguma resposta” e passam a ser melhorar robustez, organização e qualidade dos resultados.

Entre os próximos passos mais importantes, estão:

- consolidar os testes com um conjunto maior de imagens;
- medir de forma mais organizada a taxa de acerto do hardware;
- comparar os resultados com um modelo de referência;
- registrar melhor o uso de recursos da FPGA;
- refinar a documentação do projeto;
- preparar o caminho para integração com processador.

### 17.1 Melhorar a validação da inferência

Até aqui, os testes já mostraram que o sistema funciona, mas uma evolução natural é validar com mais profundidade. Isso significa separar melhor os casos de teste, registrar as entradas usadas e anotar com clareza quais dígitos foram classificados corretamente e quais ainda apresentaram erro.

Essa etapa é importante porque ajuda a responder perguntas como:

- qual a precisão atual do sistema;
- em quais dígitos ele se sai melhor;
- em quais dígitos ele ainda confunde;
- se os erros estão mais ligados à imagem, aos pesos ou ao fluxo interno do hardware.

### 17.2 Comparar com um modelo de referência

Outro próximo passo muito importante é comparar o hardware com um modelo de referência, ou seja, uma versão considerada correta do mesmo cálculo. Essa comparação ajuda a identificar se o erro está na lógica da inferência, na representação numérica, na memória ou até na etapa de pré-processamento.

Essa análise também fortalece bastante o projeto, porque mostra que a validação não foi feita apenas “olhando os LEDs”, mas também com base em uma referência confiável.

### 17.3 Registrar métricas de síntese

(Adicionar print e texto do Quartus)

### 17.4 Refinar o uso do `STORE`

O `STORE` já foi corrigido para funcionar de forma mais coerente, mas ele ainda pode evoluir. Hoje ele já consegue atender bem dois cenários:

- confirmação lógica de blocos carregados por `.mif`;
- escrita manual de teste por meio da preparação seguida de commit.

Mais à frente, esse mesmo mecanismo pode ser aproveitado de forma mais completa em uma integração com processador, em que os dados deixariam de vir das chaves da placa e passariam a ser enviados por software.

### 17.5 Preparar integração com processador

Uma parte interessante da arquitetura atual é que ela já foi organizada pensando no futuro. Mesmo sendo testado localmente na placa, o sistema já possui uma saída de 32 bits e uma estrutura de controle que facilita a leitura externa do estado e da predição.

O próximo passo natural, nesse sentido, é permitir que:

- um processador envie comandos no lugar dos switches;
- a predição seja lida por software;
- o hardware funcione como um verdadeiro coprocessador dentro de um sistema maior.

---

## 18. Modo de uso

Esta seção explica, de forma prática, como usar o sistema na placa DE1-SoC durante os testes.

O projeto foi pensado para funcionar em dois cenários:

- usando memórias já inicializadas por arquivos `.mif`;
- usando escrita manual de teste com apoio dos switches e botões.

Na maior parte dos testes do Marco 1, o uso mais comum foi com os dados já carregados nas memórias. Mesmo assim, o sistema também permite preparar e gravar valores manualmente, o que ajuda bastante na depuração.

### 18.1 Organização dos switches e botões

Durante o uso local na placa, os sinais são interpretados da seguinte forma:

- `SW[2:0]` → opcode da instrução;
- `SW[5:3]` → endereço de teste;
- `SW[8:6]` → dado de teste;
- `KEY[0]` → reset;
- `KEY[1]` → confirmação da instrução;
- `KEY[3]` → preparação de escrita para o `STORE`.

Além disso:

- `LEDR[3:0]` mostram a predição;
- `LEDR[6:4]` mostram as flags de carregamento;
- `HEX0..HEX3` mostram o status do sistema quando solicitado.

---

### 18.2 Uso mais comum com arquivos `.mif`

Quando as memórias já estão carregadas com `.mif`, o fluxo mais comum é:

1. programar a FPGA na placa;
2. enviar `STORE_IMG`;
3. enviar `STORE_W`;
4. enviar `STORE_B`;
5. enviar `START`;
6. enviar `STATUS`, se quiser ver o estado no display.

Nesse modo, normalmente os comandos `STORE` servem apenas para confirmar logicamente que os blocos necessários estão prontos. Ou seja, eles levantam as flags internas e liberam a execução do `START`, sem necessidade de regravar os valores já carregados por `.mif`.

---

### 18.3 Como enviar uma instrução

Para enviar uma instrução simples:

1. ajuste `SW[2:0]` com o opcode desejado;
2. pressione `KEY[1]`.

Exemplos:

- `000` → `CLEAR_ERR`
- `001` → `STORE_IMG`
- `010` → `STORE_W`
- `011` → `STORE_B`
- `100` → `START`
- `101` → `STATUS`

Se a instrução não depender de escrita manual, esse procedimento já é suficiente.

---

### 18.4 Como usar o `STORE` apenas para levantar a flag

Se a memória já foi carregada por `.mif`, você pode usar o `STORE` apenas como confirmação lógica.

Exemplo:

1. coloque o opcode de `STORE_IMG` em `SW[2:0]`;
2. pressione `KEY[1]`.

Nesse caso:

- a memória não precisa ser alterada;
- a flag `img_ok` será ativada;
- o sistema passa a considerar a imagem como pronta.

O mesmo vale para:

- `STORE_W`
- `STORE_B`

Esse modo foi mantido justamente porque ele combina melhor com o uso de memórias inicializadas por arquivo.

---

### 18.5 Como fazer uma escrita manual de teste

Se quiser testar gravação real em memória, use o seguinte fluxo:

1. ajuste `SW[2:0]` com o opcode do `STORE`;
2. ajuste `SW[5:3]` com o endereço de teste;
3. ajuste `SW[8:6]` com o dado de teste;
4. pressione `KEY[3]` para preparar a escrita;
5. pressione `KEY[1]` para confirmar o `STORE`.

Nesse caso, a escrita acontece em duas etapas:

- primeiro o valor é preparado;
- depois ele é realmente gravado.

Esse comportamento foi escolhido para evitar escritas acidentais e tornar o fluxo mais organizado.

---

### 18.6 Exemplo prático de escrita manual

Suponha que queremos testar um `STORE_IMG`.

#### Exemplo:
- opcode = `001`
- endereço = `111`
- dado = `101`

Passos:

1. colocar `001` em `SW[2:0]`;
2. colocar `111` em `SW[5:3]`;
3. colocar `101` em `SW[8:6]`;
4. apertar `KEY[3]` para preparar;
5. apertar `KEY[1]` para gravar.

Importante:

- apertar apenas `KEY[3]` não grava nada;
- apertar `KEY[1]` sem preparação também não grava nada;
- para haver escrita real, é necessário fazer as duas etapas.

---

### 18.7 Como iniciar a inferência

Depois que as flags de imagem, pesos e bias estiverem ativas, a inferência pode ser iniciada.

Passos:

1. colocar `100` em `SW[2:0]`;
2. pressionar `KEY[1]`.

Se tudo estiver certo, o sistema entra em processamento.  
Se faltar alguma flag necessária, ele pode ir para o estado de erro.

---

### 18.8 Como consultar o estado

Para visualizar o estado atual do sistema nos displays:

1. colocar `101` em `SW[2:0]`;
2. pressionar `KEY[1]`.

O estado será mostrado temporariamente nos displays `HEX0..HEX3`. Depois do tempo configurado no projeto, a exibição será apagada automaticamente.

---

### 18.9 Como limpar um erro

Se o sistema entrar em erro, use:

1. `SW[2:0] = 000`
2. pressione `KEY[1]`

Isso envia `CLEAR_ERR` e devolve o sistema ao estado normal.

---

### 18.10 Resumo rápido de uso

#### Fluxo normal com `.mif`
1. `STORE_IMG`
2. `STORE_W`
3. `STORE_B`
4. `START`
5. `STATUS`

#### Fluxo de escrita manual
1. configurar opcode, endereço e dado
2. `KEY[3]` para preparar
3. `KEY[1]` para gravar

#### Fluxo de erro
1. `CLEAR_ERR`
2. repetir o processo corretamente

---

### 18.11 Observação importante

Mesmo que o sistema esteja sendo usado atualmente com a placa e os switches, a arquitetura já foi preparada para evoluir. Isso significa que, no futuro, o envio de instruções e dados poderá deixar de ser manual e passar a ser feito por um processador externo, sem exigir uma reformulação completa da lógica principal.

---

## 19. Conclusão

Este projeto foi uma etapa importante na construção de um acelerador de inferência em FPGA para classificação de dígitos. Ao longo do desenvolvimento, o foco não ficou apenas em montar blocos isolados, mas em fazer com que eles conversassem corretamente e formassem um fluxo coerente de processamento.

No fim das contas, o que foi construído aqui não é só um conjunto de módulos em Verilog. É uma base funcional que já consegue:

- receber comandos;
- controlar o estado do sistema;
- acessar memórias;
- processar dados da imagem;
- calcular a saída da rede;
- escolher a classe final;
- mostrar o resultado na placa.

Também foi importante perceber que parte do trabalho real não estava apenas em “programar a FSM”, mas em ajustar detalhes que fazem muita diferença na prática, como o comportamento do `STORE`, a forma de carregar dados, o tratamento da imagem de entrada e a organização da interface com a placa.

Outro ponto positivo é que o projeto já nasce com espaço para crescer. Ele não foi feito só para resolver o problema imediato do Marco 1, mas também para servir como base de evolução. Isso deixa o caminho mais aberto para melhorias futuras, tanto em desempenho quanto em integração com outros componentes.

De forma geral, este trabalho mostrou que a ideia do acelerador é viável, que a arquitetura está funcional e que a equipe conseguiu montar uma solução coerente, testável e tecnicamente consistente para a proposta da disciplina.

---

## 20. Checklist final

Antes de considerar a entrega completamente encerrada, vale a pena revisar os seguintes pontos:

- [ ] revisar os comentários do código;
- [ ] verificar a coerência final dos nomes dos sinais e módulos;
- [ ] consolidar os testes com mais imagens;
- [ ] medir a taxa de acerto do hardware;
- [ ] registrar uso de recursos no Quartus;
- [ ] registrar frequência máxima estimada;
- [ ] revisar o README;
- [ ] garantir que os arquivos `.mif` corretos estão no projeto;
- [ ] conferir a pinagem da placa;
- [ ] validar mais uma vez o fluxo completo em hardware.

---
