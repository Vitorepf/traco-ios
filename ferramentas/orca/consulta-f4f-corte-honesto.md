# Consulta F4-F — publicação, corte honesto e legibilidade

Parecer do conselho de arquitetura, 08/09/2026. Segunda recusa da volta; primeira consulta. Recomendação ao coordenador, a quem cabe a decisão conforme DIRETRIZ §6. Apenas este documento foi produzido; sem implementação, build, alteração de contratos ou commit.

**Não contesto os dois fatos medidos pelo G4 e sustento a recusa.** As capturas mostram o texto praticamente estacionado no caso de 103 caracteres e mostram o corte com 247; os valores de ~11 e ~7 pt são estimativas do relatório a partir dos pixels, não uma medição tipográfica independente deste conselho. Corrijo uma interpretação contratual: reticência não é, por si, mentira; o defeito é desperdiçar espaço ou legibilidade para depois cortar, enquanto se promete integralidade.

## A pergunta, como recebida

> 1. **O teto do que se publica é do PUBLICADOR ou do RENDERIZADOR?** A ADR 05u diz que quem corta conta (a F4-E já moveu o corte da lista para `publicar`). Se `VozDoAutor.titulo` sai sem teto do app para o App Group, quem deve limitá-lo — e o que exatamente o teto deve preservar (caracteres? palavras? a primeira frase?) para que a face não minta sobre o que existe do outro lado?
> 2. **Qual é a regra de "corte honesto" que vale para TODA face**, e não só para esta? Hoje a lei do estado honesto diz que a face conta o que não mostrou ("+4 depois" na lista). Para um texto contínuo, o equivalente é "…" — mas "…" também era o defeito que a volta veio consertar. **Diga a regra que distingue os dois casos**, em uma frase que sirva de teste: quando reticência é honestidade e quando é falha.
> 3. **O piso de legibilidade deve ser em pontos absolutos ou em fração do corpo pedido pela pessoa?** O fato 1 é o que me incomoda mais: um piso em fração faz o texto do autor ignorar o pedido de acessibilidade **justamente de quem mais precisa dele**. Existe alguma leitura em que o comportamento atual seja defensável, ou é defeito puro?
> 4. **A ordem de sacrifício.** O juiz propõe que o pequeno largue o atalho decorativo antes de encolher a frase. Isso é decisão de produto que se repete em toda face com espaço apertado: **existe uma ordem de sacrifício declarável no contrato** (conteúdo do autor > ação > enfeite), ou isso tem de ser decidido face a face?

## 1. O publicador limita a projeção; a face limita sua apresentação

**O teto editorial pertence ao contrato público de `Superficie` e é aplicado pelo app ao produzir a projeção.** O renderizador decide quanto desse trecho cabe naquela família, naquele estado e no tamanho de texto escolhido. São duas omissões diferentes; cada responsável declara a sua. O primeiro não conhece a geometria final, e o segundo não conhece o texto que o primeiro deixou de publicar.

Isso mantém a lei da F4-E. Para listas, o publicador conta os itens omitidos; para texto contínuo, basta declarar que há continuação, sem inventar uma contagem de palavras ou caracteres na interface. A projeção precisa distinguir **trecho integral / trecho abreviado / integralidade desconhecida em documento antigo**. A pontuação literal do autor não serve de metadado: uma frase que já termina em “…” não prova que o app a cortou. A face combina a omissão recebida com a sua própria; uma segunda redução não pode apagar a informação de que existe mais.

O que preservar é **um prefixo fiel do texto público escolhido pelo contrato atual**, com sua identidade e origem, sem reescrever, resumir, escolher outra oração ou substituir o original guardado. O teto é medido em caracteres percebidos pela pessoa — grafemas completos, como `Character` em Swift —, incluindo o marcador quando ele é acrescentado. Prefere-se terminar numa fronteira de palavra dentro desse orçamento; uma palavra maior que o orçamento ou uma escrita sem espaços exige corte por grafema, ainda sinalizado. “Primeira frase” não é limite: pode ter 247 caracteres ou milhares e depende de uma interpretação de pontuação. Contagem de palavras também não limita seu comprimento.

`VozDoAutor.titulo` continua responsável por extrair a voz conforme seus consumidores atuais; não deve perder conteúdo globalmente para resolver o widget. Já existe `VozDoAutor.truncar`, que reconhece corte por palavra, mas hoje pode produzir `n + 1` caracteres e devolve só texto: sua existência não prova o contrato acima. O limite público deve ser explícito e comum aos consumidores do mesmo campo; **43 caracteres não é um limite comprovado, e nenhum número de caracteres garante que o texto caiba**. Não deduzo um novo valor editorial das três amostras de tela: o valor escolhido continua exigindo corte adicional na face.

Há uma fronteira concreta a não perder: `DestaqueDoDia.publicar` entrega `projecao` a `SuperficieDisco`, mas `reconciliar` usa a mesma `projecao` diretamente para criar o `ContentState` da Live Activity. Portanto, limitar apenas a escrita de `superficie.json` deixaria Ilha e tela bloqueada com outro contrato. A responsabilidade é da **produção do trecho público**, antes da distribuição aos destinos existentes. O texto integral da nota e do campo do autor permanece preservado; publicação não redefine autoria nem autorização de acesso.

## 2. Uma regra verificável para toda face

**“Reticência é honestidade quando indica continuação realmente omitida por um limite público declarado ou pelo espaço restante após retirar elementos dispensáveis, preservando leitura no tamanho escolhido e acesso ao original; é falha quando encobre corte evitável, texto ilegível ou uma promessa de integralidade.”**

Essa frase muda a promessa da ADR 08g de “inteira, sempre” para **“trecho fiel e legível, com omissão reconhecível”**. Não absolve a regressão original: cortar 43 caracteres com metade do cartão aproveitável vazia continua sendo corte evitável. E o caso de 247 caracteres continua recusado mesmo que o marcador esteja correto, pois chegou a ele reduzindo o conteúdo abaixo do piso de leitura. O símbolo pode dizer a verdade sobre a continuação enquanto a apresentação continua defeituosa.

O marcador é da interface, não uma edição da voz. Não transforma um prefixo em frase completa, resumo ou instrução suficiente. Por exemplo, `“Vou aceitar a proposta…”` pode omitir `“somente se corrigirem o prazo”`: a face deve assumir que está mostrando um trecho e não pode usar o prefixo como novo significado da ação. Identidade estável continua obrigatória; a ação se refere ao registro original, nunca ao texto abreviado como identificador.

O acesso ao original também tem de ser verdadeiro. O G4 provou que o pequeno fresco abre **Nova nota**; logo, hoje não se pode prometer que tocar no trecho abre sua continuação. A recomendação exige uma saída coerente para o conteúdo existente, respeitando as rotas e permissões do app, sem superfície nova; enquanto essa correspondência não estiver demonstrada, a promessa de continuação acessível fica pendente. VoiceOver deve distinguir trecho de texto integral; ler uma cadeia maior não corrige a ilegibilidade visual, e ler apenas a projeção não autoriza anunciar “texto completo”.

## 3. Piso em pontos efetivos, dependente do tamanho escolhido

**Um piso fixo em pontos absolutos é insuficiente, e uma fração isolada também.** Concordo com o G4 se “pontos” significa o tamanho efetivamente desenhado correspondente a `Tema.miudo` **na categoria corrente**, como ele escreveu; discordaria de interpretar a proposta como “11 ou 12 pt em todas as categorias”.

O contrato deve escolher um papel tipográfico estável para o conteúdo em cada face e respeitar sua curva de Dynamic Type. Minha recomendação para esta frase principal é **manter o corpo do papel escolhido e reduzir a quantidade de texto, sem encolhimento automático para fazê-lo caber**; o piso geral de `Tema.miudo` corrente é a barreira mínima, não licença para rebaixar o assunto a legenda sempre que apertar. Assim o aumento pedido pela pessoa chega ao conteúdo, em vez de ser consumido pelo algoritmo de encaixe. A face pode ter um papel compacto próprio, declarado; não pode trocar para um papel menor justamente porque a pessoa aumentou o texto.

A Apple orienta, em geral, fontes de pelo menos 11 pt nos widgets e documenta suporte de Large a AX5; esse mínimo geral não é autorização para manter 11 pt em AX5. Os estilos de texto oferecem suporte ao tamanho escolhido pela pessoa. A regra mais estrita acima é minha recomendação de produto para o Traço, não uma exigência numérica atribuída à Apple. Fontes: [Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets) e [Typography](https://developer.apple.com/design/human-interface-guidelines/typography).

Uma fração pode ser apenas um mecanismo de implementação de um piso já definido em tamanho efetivo; **0,35 como política de produto não é defensável neste caso**. Em geometria fixa, aumentar a fonte nominal permite ao ajuste encolher mais e retornar aproximadamente ao mesmo tamanho final. O relato não prova que determinada pessoa seja incapaz de ler exatamente 11 pt, mas prova que a escolha de acessibilidade não produziu o aumento esperado no conteúdo central. O defeito independe dessa inferência individual. Uma constante absoluta impediria ~7 pt e ainda deixaria essa segunda falha aberta.

## 4. A ordem é comum; a função de cada elemento depende da face

**Declare uma ordem comum de sacrifício, com invariantes acima dela.** Legibilidade, indicação de falha/desatualização/omissão, identificação do objeto e entendimento do que um toque faz não entram na disputa como enfeites. Alvos acessíveis e recuperação também não podem ser reduzidos para ganhar uma linha.

Depois desses invariantes, cede primeiro o ornamento e a identidade visual repetida; depois, os atalhos secundários ou redundantes; depois, a quantidade de conteúdo exposto, com corte honesto. A ação indispensável à finalidade daquela face é preservada junto do conteúdo mínimo necessário para entendê-la. **O corpo de leitura não é a última moeda para pagar a falta de espaço.**

“Conteúdo do autor > ação > enfeite” é uma boa intuição para o Destaque, mas uma lei universal incompleta: uma face de ação pode precisar de um comando identificável antes de mais linhas, e “Desatualizado” não pode desaparecer para preservar prosa. O contrato comum define as prioridades; cada face classifica seus elementos pelo propósito existente e declara qualquer exceção funcional. Isso evita tanto um motor genérico de prioridades quanto decisões contraditórias espalhadas.

No pequeno desta volta, **“Nova nota” deve ceder antes de reduzir a frase**: é o rótulo visual de um caminho redundante, e o G4 confirmou que não é um segundo alvo independente. Sua retirada, porém, não torna automaticamente o destino do cartão correto para um trecho abreviado. Já no vazio, “Nova nota” é a oferta principal: o mesmo rótulo tem outra função e não é dispensável pela mesma razão.

## Alternativas descartadas, riscos e prova necessária

| Alternativa | Por que descarto |
|---|---|
| Diminuir mais o fator ou proibir toda reticência | Texto livre não tem máximo geométrico; a integridade aparente é comprada com ilegibilidade. |
| Somente um piso absoluto | Impede letra minúscula, mas permite anular Dynamic Type. |
| Somente teto no publicador | Caracteres têm larguras diferentes; família, estado e acessibilidade ainda exigem corte local. |
| Somente corte na view | Não declara a omissão editorial e deixa outros destinos recebendo projeções sem limite. |
| Resumir, extrair a primeira frase ou limitar globalmente `titulo` | Muda o texto ou sua função para consumidores alheios à face, sem resolver o limite geométrico. |

O custo assumido é mostrar menos palavras nos tamanhos maiores e, às vezes, exigir abrir o conteúdo. Isso é perda explícita de densidade; a alternativa atual perde acesso à leitura. Um prefixo pode omitir uma condição decisiva, portanto nenhuma ação pode presumir que ele contém toda a intenção. Instantâneos antigos exigem tratamento de integralidade desconhecida; silêncio não equivale a “inteiro”.

Para aceitar a nova promessa, a prova deve mostrar: publicação preservando origem, identidade e original com um limite verificável, inclusive grafemas compostos, palavras longas e reticências escritas pelo autor; consistência da omissão entre snapshot e atividade; crescimento efetivo da frase entre normal e AX5, com 43, 103 e 247 caracteres e textos além do teto; corte sem espaço recuperável desperdiçado nem elemento dispensável competindo; estado velho e continuação perceptíveis; e destino/toques/VoiceOver correspondendo ao que a face anuncia. Isso é critério de aceitação do contrato, não plano de execução. Capturas de amostras pequenas e testes de constantes não demonstram essas propriedades.

## Base consultada e limites

Li o brief `consultor-astra.md`, a DIRETRIZ, a visão do produto, a ADR 05u e a evolução F4-C/D/E neste checkout (`d169068`), além do fluxo de `Sessao.linhaDoDestaque` → `DestaqueDoDia` → projeção/publicação/atividade e de `VozDoAutor`. O G4 e a ADR 08g não estão neste checkout: foram lidos integralmente em `/Users/vitorepf/orca/workspaces/traco-ios/volta-f5-fora-do-app`, topo `0beddcb`, correspondente ao candidato nomeado pelo relatório. Inspecionei ali também `FraseDoAutor`, o pequeno e as capturas `g4-f4f-pequeno-normal-x-ax5.png`, `g4-f4f-longa-normal.png` e `g4-f4f-longa-ax5.png`.

Não executei novamente o candidato nem certifiquei dimensões, destinos ou dispositivos além da evidência citada. O documento de governança Atlas indicado na projeção não existe neste checkout; não usei KB, Obsidian ou projeção Atlas como prova de implementação. O contexto histórico de F2 serviu apenas para localizar a fronteira, confirmada no código desta consulta.
