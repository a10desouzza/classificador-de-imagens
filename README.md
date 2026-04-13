# classificador de imagens

<details>
<summary><h3>Tabela de Instruções</h3></summary>

### Tabela de Instruções

 OP Code | Nome da operação | Descrição
 :------ | :-------- |:-------
 000 | [REFRESH](#refresh) |Informa ao coprocessador que uma nova imagem foi carregada na memoria _A_ e atualiza a memória de exibição para essa nova imagem.
 001 | [LOAD](#load) |carrega no barramento de [SAIDA](#barramento-de-saida-data_out) o valor do pixel associado ao endereço solicitado na instrução.
 010 | [STORE](#store) |Usado para guardar um valor de pixel na memoria A.
 011 | [Vizinho mais proximo para zoom in](#vizinho-mais-proximo-para-zoom-in-nhi_alg-instruction) |Usado para realizar operação de vizinho mais proximo para zoom in.
 100 | [Replicação de pixel](#replicação-de-pixel-pr_alg-instruction) |Usado para realizar operação de replicação de pixel para zoom in.
 101 | [Vizinho mais proximo para zoom out](#vizinho-mais-proximo-para-zoom-out-nh_alg-instruction) |Usado para realizar operação de vizinho mais proximo para zoom out.
 110 | [Média de blocos](#media-de-blocos-ba_alg-instruction) |Usado para realizar operação de media de blocos para zoom out.
 111 | [Reset](#rst) |Usado para reiniciar o coprocessador, retornar o zoom para o padrão e a imagem para a que esta armazenada na memoria _A_.
