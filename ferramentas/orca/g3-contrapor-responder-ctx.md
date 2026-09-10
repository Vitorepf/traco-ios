# G3 + POUSO — `contrapor` (ADR 10d) e `responder`/contexto (ADR 10g)

Revisor independente, 10/09. Não medi nada novo: nenhuma chamada ao provedor,
nenhum aparelho de conta tocado (`B91C8DEF` e `34CC3F94` ficaram como estavam).
Recontei das provas comitadas, li o código e as saídas, e rodei build e suíte
só no **teste 4 `A1DF082C`**, sob `com-trava.sh`.

---

# PEÇA 1 · `contrapor` — ADR 2026-09-10d

## **PASSA** (com duas frases corrigidas antes de pousar)
## **MESCLA** — feito: `Vitorepf/q4-c` → `main`

Suíte na árvore JÁ MESCLADA com `origin/main`: **1064 testes em 167 suítes,
`** TEST SUCCEEDED **`**, 152,8 s. Build **limpo**, um único warning, o herdado
de `NotasView.swift:814`. Tudo no `A1DF082C`, sob `com-trava.sh`.

## Fio 1 — a recontagem é legítima. A recusa da segunda instalação estava certa.

Confirmado no código, não no relato:

- `Sabia.dependeDoQueElaFechou` (`Sabia.swift:823`) é uma função Swift pura
  chamada — quando era chamada — dentro de `parseContraparte` (`:770`), **depois**
  do retorno do provedor. O pedido são `formaContraporComEsquema` + `corpoContrapor`
  (`:277` e `:287`) e **nenhum dos dois menciona a guarda, o join ou qualquer
  consequência de `dependeDe`**. O modelo não a vê.
- Os `requisitos` da fixture também não chegam ao modelo: `AvaliacaoIA.Caso`
  decodifica o campo (`AvaliacaoIA.swift:26`) e o despacho passa **só** `entrada`
  a `Sabia.contrapor(texto:gesto:retrato:)` (`:260`). Nada do critério viaja.
- Logo o `bruto` gravado é, byte a byte, o que um binário sem o join teria
  produzido. **Uma segunda instalação teria medido a mesma coisa duas vezes.**

E o número saiu do MESMO JSONL: rodei `lote-ia-09g-contrapor.py` sobre
`prova/lote09i/*.jsonl` e **todas as células reproduzem** — controle 11 / 12 / 13
de 18, conta absoluta 55 / 61 / 63 de 72 no `4.3`; 18 / 17 / 18 e 70 / 69 / 72
no `4.5`; join com 2 + 3 = **5 disparos**, e a coluna A cai de 2 para 1 no `4.5`
quando o join entra, que é o único acerto dele.

**Uma ressalva de instrumento, que não muda o número.** A coluna G restaura o
`foraDaLista` do `bruto` **sem re-executar `limpo`** — nas 5 linhas em que o join
disparou, as outras guardas (tamanho, imperativo, fato/número alheio, corte em
280) ficam de fora, ao contrário do que o comentário do script diz. Conferi as 5
cadeias restauradas: 35 a 117 caracteres, nenhum dígito, nenhum prefixo
imperativo. Nenhuma delas seria apagada. **O comentário é que está errado, não a
conta.**

## Fio 2 — 3/3 aguenta pouco, e o controle **NÃO SUBIU**. Corrigido no código.

O piso de ruído está na própria prova desta volta, e é maior do que o efeito:

| o que se compara | mesma coisa? | LOTE-8 | LOTE-9 | oscilação |
|---|---|---:|---:|---:|
| controle, braço antigo `4.3` | pedido SHA `e4b665fb…`, fixture `da012e21…`, mesmo parser | **16 de 18** | **11 de 18** | **5** |
| cego `razoes-fechadas`, braço antigo `4.3` | idem | **1 de 3** | **3 de 3** | **2** |

Conferi que é mesmo o mesmo pedido: o `pedidoContraporSHA256` gravado em toda
linha de `lote09i-antigo-*.jsonl` é `e4b665fb…`, e o `sistemaContrapor` comitado
em `28cc409` — a árvore que rodou o LOTE-8 — dá **exatamente** esse SHA.
(Nota de rodapé: o relatório diz "2.620 bytes"; são 2.745. O hash é que manda, e
ele bate.)

**O que 3/3 aguenta:** dizer que o defeito **não apareceu em três tiradas**.
**O que não aguenta:** dizer que a forma o fechou. O cego `alternativas-negadas`
foi 1/3 → 3/3 — Fisher exato **p = 0,40**; juntando as duas janelas do braço
antigo (2 de 6 contra 3 de 3), **p = 0,17**. E a linha de cima mostra o mesmo
salto de 1/3 para 3/3 acontecendo num braço em que **nada mudou**.

**O controle:** +2 num polo onde o mesmo braço oscila 5. "Não caiu" é o que os
números sustentam. **"Subiu" não é** — e essa palavra estava em três lugares:
`Sabia.swift` (doc de `formaContraporComEsquema`), `Politica.porque` do
`contrapor` e o relatório. Corrigi os três, com o número do ruído ao lado.

## Fio 3 — o oráculo NÃO é cópia da regra. Mas o 3/3 é leitura, não script.

- As palavras que o conferidor procura (`etapas|fasea|adia|ensai|homologa|
  ambiente de teste|dados reais|…`) vêm das frases com que **a própria nota**
  fecha as saídas, não do pedido. O pedido diz a regra em abstrato ("nada disso
  volta como proposta sua"); nunca enumera as palavras.
- O conferidor **não lê `fechadas`** — o campo que o esquema acrescenta. Só
  `foraDaLista` (com veredito) e `contra`/`outroCampo` (sem). Então o 3/3 não
  mede obediência a um vocabulário que o esquema ensinou.
- **Mas a nota do relatório é honesta e eu confirmo: o 3/3 é dela, lido saída a
  saída.** Li as seis do braço `esquema 4.3` e concordo na linha do substituto:
  nenhuma oferece ensaio, cópia, faseamento, adiamento, outra academia ou treino
  em casa.

**Onde discordo, e é o único achado de mérito desta peça:** *"passa os DOIS
cegos 3 de 3"* vale para **uma** das linhas de reprovação, não para o caso
inteiro. O cego `alternativas-negadas` também reprova por *"afirmar backup,
plano de volta, janela de manutenção, equipe, ferramenta… que a nota não dá"* —
e duas das três saídas do `esquema 4.3` propõem exatamente isso: *"executar a
virada com janela de observação ativa e **rollback imediato**"* (r1) e
*"Realizar a virada com **plano de rollback imediato preparado**"* (r2). O
próprio modelo entrega a prova no campo novo: o `dependeDe` de r2 é *"Acesso a
logs completos, **backups consistentes** e **janela de manutenção** maior que o
tempo estimado"* — três recursos que a nota nunca deu.

Isto **não derruba a volta** (o braço antigo não é medível nessa linha: não tem
`dependeDe`), e é o melhor argumento a favor da dívida do fio 4: o campo que
falta já teria acusado aqui.

## Fio 4 — a dívida está nomeada como DESENHO, não como desculpa. Confirmado.

`Sabia.swift:797-822` diz o mecanismo, não o resultado: *"casar palavra não
separa 'ela não tem X' de 'ela tem X e a proposta usa X de outro jeito': o join
lê a palavra e não lê a RELAÇÃO"*, e nomeia o que falta — *"um campo que diga se
o recurso vem DE FORA do que ela tem, e que seja FATO, não juízo"*. Os quatro
erros e o acerto estão colados com a palavra que casou.

E há a irmã que a casa exige: `oJoinPorPalavraNaoSeparaOQueElaNaoTemDoQueElaUsaDeOutroJeito`
guarda o acerto **e** o erro lado a lado, com a linha certa no comentário — se o
erro deixar de acusar, o desenho mudou e a dívida se revê.

## A frase da tela — FICA, e por causa do fio 2.

*"Contrapor pela IA está indisponível: ela ainda oferece um substituto para o que
você disse que não tem."* Ela nomeia um defeito que o `grok-4.3` **não repetiu**
em 6 repetições cegas com o esquema — mas 6 repetições não matam um defeito que
apareceu no `4.5` nesta mesma janela e no `4.3` nos LOTES 6, 7 e 8. Trocá-la
agora seria comprar com 3 tiradas a certeza que o fio 2 diz não existir.
Diz o defeito de hoje, na língua do autor, sem data e sem jargão. Fica.

A rota **não volta** ao Perfil: `indisponivelPorQualidade`, superfície pendente
no G4 (§14/§15). Nenhuma captura de cartão nesta peça, e é o certo.

## Um achado que a mescla trouxe, e que não é da volta

A mescla ingênua de `q4-c` com `main` **ressuscitava a cláusula do `instigar`
que o G3 da Q4-C tinha reprovado** ("Nota CURTA… MANDA o vazio"), por cima da
versão CONDICIONADA à matéria que o `main` mediu e mesclou hoje. O git não
acusava: o conflito abria com o lado HEAD vazio e o texto reprovado já
incorporado acima. Resolvido tomando o pedido do `main` inteiro, mais
`sistemaInstigarBase` e o teste `oContratoDeInstigarDizDeQuemEOAssunto` dele.

E o portão `todoCaminhoDeProvaCitadoPelaPoliticaAbre` — que veio do `main` na
mesma mescla — **mordeu na primeira corrida**: o `porque` do `contrapor` desta
rama ainda citava `prova/q-qualidade.md`, que nunca existiu. Corrigido para
`ferramentas/orca/q-qualidade.md`. É o portão a fazer o que foi escrito para
fazer, no primeiro dia.

## Scorecard — só onde discordo da autora

| dimensão | dela | minha | por quê |
|---|---:|---:|---|
| medida que se pode repetir | 8 | **9** | a recontagem reproduz célula a célula, o pedido vai por SHA em toda linha e os dois braços correm o mesmo dylib — o que faltava era ler o ruído da própria prova, e agora está lido e escrito |
| fidelidade ao que o autor escreveu | 7 | 7 | mantida: o `dependeDe` de duas saídas nomeia recursos que a nota não dá |
| utilidade do que volta | 8 | 8 | mantida |
| honestidade do silêncio | 9 | 9 | conferida: `bruto` nas 96 linhas, coluna C = 0 |
| estado na tela | 9 | 9 | a frase fica, e agora o `porque` por trás dela não promete seta |

As demais dimensões da ESTEIRA: **n/a** — volta sem superfície, sem movimento,
sem componente e sem jornada nova, por ordem do dono (§14/§15).

---

# PEÇA 2 · `responder` · contexto — ADR 2026-09-10g

## **PASSA** — o mérito reprova, e ela diz isso; o CÓDIGO passa.
## **MESCLA** — sim, com uma correção de prova (fio 2) e uma retratação (fio 4).

Os dois vereditos, separados, que é o que a volta pede:
**`responder` FICA `indisponivelPorQualidade`.** **O código ENTRA.**

## Fio 1 — 9 não é ruído. A assimetria fecha a questão.

Contei do JSONL, com um padrão que **eu** afinei para pegar as nove declarações
que a §3.1 cita (`não consta aqui|não veio|não chegou|não foram lid|caracteres|
truncad|o trecho lido|não coube|parcial|restante|cortad|…`):

| metade | `antigo` | `novo` |
|---|---:|---:|
| material NÃO cabe (10 casos × 3) | **0 de 30** | 11 de 30 marcadas, ≥ 9 genuínas |
| tudo cabe (10 casos × 3) | 2 marcas, ambas falsas | 1 marca, falsa |

**O braço velho é 0 de 30 com variância zero** — dez casos distintos, três
repetições cada, nenhuma declaração de nenhuma espécie. Ruído não desce abaixo
de zero: se a taxa verdadeira do braço velho fosse ruído, 0/30 põe o teto em
9,5 % a 95 %, e o braço novo está em 30 %. **Fisher exato, 0/30 contra 9/30:
p = 0,0019.** O piso de ±2 repetições da §2 é por CASO e continua válido; o que
não vale é aplicá-lo a um deslocamento repartido por quatro casos com mecanismo
nomeado. **A leitura dela está certa.**

## Fio 2 — a varredura da §3.2 **não é** a que achou as 9. O zero cai como prova.

O padrão publicado é `não li|não leu|não veio|não chegou|truncad|caracteres
não|não coube|parcial`. Rodei-o sobre a metade que a alavanca ataca:

- acha **5 das 9** declarações (`duas-notas` r2 e r3, `contrato` r2, `orcamento`
  r2 e r3);
- **não acha nenhuma** em `10c-reuniao-nao-cabe`, que a §3.1 credita com 2 de 3
  — as frases lá são *"Faltam os 1043 caracteres finais"* e *"Os 1043 caracteres
  finais… não foram lidos"*, e nenhuma casa;
- e acusa **1 de 3** no braço ANTIGO em `10c-relatorio-nao-cabe`, onde a §3.1 diz
  0 de 3.

**Vigia com ~55 % de alcance que devolve zero não prova que enxerga.** Como está
escrito, a conclusão *"a alavanca não trocou um defeito por outro"* não está
provada.

**Está agora, e por isso a peça passa.** Refiz a varredura das 30 repetições do
polo de controle com o padrão afinado nas nove — **uma marca no braço novo, e é
falsa** (*"decisões que ainda parecerem incompletas"*, `relatorio-estrutura-cabe`
r1: a palavra usada noutro sentido). **Zero declarações espúrias.** A conclusão
sobrevive; a prova dela precisa ser trocada pela minha no §3.2, ou o script
publicado junto. **Isto é o único conserto obrigatório desta peça.**

## Fio 3 — o pouso, com número: o autor não perde nada hoje, e o app deixa de mentir.

Segui a rota antes de pesar: `Sessao.notasLigadas` → `contextoDoCaderno` →
`Sabia.contextoDaPergunta` → `responderNaPagina`. **Esse é o único consumidor.**
`responderNasNotas`, que está VIVA, passa por `contextoDasNotas`, outro caminho.
E `responder` está `indisponivelPorQualidade`. **Conclusão dura: nada disto chega
a autor nenhum hoje** — nem o ganho nem a perda.

Com isso pesado:

**O que entra** é a remoção de uma tesoura silenciosa que fazia o app **afirmar
ao autor que a nota dele não tem o que ela tem** — seis frases falsas, 3 de 3 em
três casos distintos (*"o contrato colado não traz cláusula sobre rescisão"*,
*"a transcrição não registra nenhuma atribuição"*, *"faltam três dados
indispensáveis"* com os três escritos na nota). Isso é defeito de fidelidade, e
fidelidade é invariante, não dimensão que compensa por média (QUALIDADE-IA).
Junto vêm 2,1× mais material do autor ao modelo e o corte declarado quando há
corte.

**O que se perde**, e não desconto: na única pergunta REAL, do aparelho do
autor, **nenhuma das três** do braço novo nomeia preço e prazo entre o que falta
definir, e **duas das três** do braço velho nomeavam. Conferi saída a saída: as
velhas trazem *"Prazo de entrega… Orçamento fechado (custo fixo + manutenção)"*
e *"Valor total, separando desenvolvimento de custos recorrentes"*; as novas
trazem "preços" só como campo de dado do cardápio. n = 3, uma pergunta. **É
regressão medida, e vai ao RUMO como o custo nomeado da alavanca seguinte** — não
como motivo para segurar um conserto de defeito que ninguém vê hoje.

Na mesma pergunta real o braço novo **ganha** o que a 10b tinha medido como
falsa intimidade: nenhuma das três importa *"o dia da apresentação"*, o *"caderno
que responde"* ou *"fechar o orçamento"* da nota vizinha; o velho importava em
2 de 3.

**Decisão: entra.** Defeito tem prioridade sobre função nova (§11), o risco
medido deu zero, e o custo mede-se num aparelho que a rota nem alcança.

## Fio 4 — o desconto NÃO se sustenta, e o placar muda para o outro lado.

Li o caso e as três saídas. O que está escrito na fixture é *"Quero saber se o
que anotei **da conta** ou se falta alguma coisa"* — **sem acento**. Não há
"dá conta" no texto que o modelo recebeu; a única leitura possível de "o que
anotei da conta" é a que o modelo fez. Ela chama isso de erro de redação dela, e
nisso tem razão.

**Mas o desconto está aplicado ao contrário.** O caso tem quatro requisitos
escritos, e as três saídas do braço novo **não violam nenhum**: tudo coube e
nenhuma diz que deixou de ler (r1 *"As anotações da conta não aparecem na nota"*
afirma ausência no caderno, não leitura parcial); as duas notas são usadas pelo
que são; *"fechar o orçamento"* não vira decisão tomada; nada é inventado. Ela
reprovou o caso por um critério que **não está escrito nele** — "leu a pergunta
como eu quis" — e depois perdoou a si mesma a reprovação que ela própria criou.

Sem essa cobrança, o caso não é perda: o lado "tudo cabe" fica **7 e 7**, e o
placar total é **7 (antigo) contra 8 (novo)**, não o empate. **O empate 7 = 7 foi
comprado por uma reprovação inventada e depois anulada** — o desconto e a
cobrança cancelam-se, e o que sobra é um ponto que o relatório não conta.

E há uma observação que o desconto enterrou, e ela é útil: com 2,1× mais
contexto o modelo **ancorou mais na letra da página** (o velho ignorou "da conta"
e respondeu sobre a semana; o novo levou a palavra a sério, 3 de 3, com a MESMA
entrada). É plausivelmente o mesmo mecanismo que custa preço e prazo na pergunta
real do fio 3. **Vale mais escrito como mecanismo do que apagado como erro de
redação.**

## O caso cego de fora: os dois polos, sim; o **C5**, não.

| do casos-cegos.md | coberto pelos 20? | onde |
|---|---|---|
| C1 · não coube, com folga | **sim** | `relatorio-nao-cabe`, `reuniao-nao-cabe`, `duas-notas-uma-fica-de-fora` (a nota inteira que fica de fora, pelo nome) |
| C2 · não coube, na borda | **em parte** | o mecanismo está (`prazo-correcao-no-fim`, `gasolina-numeros-no-fim` põem o fato decisivo na cauda), a MAGNITUDE não: os cortes dela são ~20 % (≈1.100 de ≈5.600), C2 pede 5 % |
| C3 · coube e é FARTO — controle | **em parte** | há o polo (`relatorio-estrutura-cabe`, `orcamento-cabe`, `biblioteca-cabe`), mas as vizinhas que cabem têm 105 a 307 caracteres; C3 pede três notas de 300 a 400 PALAVRAS. **O zero do controle foi medido em material magro** |
| C4 · coube e é magro — 2.º controle | **sim, bem** | `acordar-cedo-sem-vizinha` e `espanhol-sem-vizinha` (sem vizinha nenhuma), `prazo-correcao-cabe` (144 caracteres) |
| **C5 · a nota que NÃO EXISTE** | **NÃO** | nenhum dos 20 pergunta por uma nota inexistente |

**O C5 é o que falta, e falta justamente por causa desta alavanca.** O que ela
ensinou à rota foi a dizer *"não veio aqui"*, *"não consta aqui"*, *"não chegou
aqui"* — as três frases estão nas saídas de `10c-duas-notas-uma-fica-de-fora`.
São exatamente as frases que o C5 REPROVA quando não há nada que pudesse ter
vindo. **Nada nos 20 casos distingue "não coube" de "não há"**, e a fronteira é
o que decide se a alavanca ensinou a rota a mentir do outro lado.

O detalhe que fecha o argumento: a vizinha de `10c-contrato-nao-cabe` chama-se
**"Contrato do estúdio"** — o nome que o C5 exige que NÃO exista. Os dois casos
são espelho um do outro sobre o mesmo título, e só um foi rodado.

Não o rodei, por ordem. **Recomendo-o como a primeira corrida da volta seguinte,
antes de qualquer alavanca nova** — é uma janela curta (1 caso × 3 × 2 braços) e
mede um risco que esta volta criou.

## Scorecard — só onde discordo

| dimensão | dela | minha | por quê |
|---|---:|---:|---|
| Honestidade da medida | 9 | **7** | a varredura que prova o CONTROLE pega 5 das 9 e é dada como prova de zero; e o único caso perdido foi reprovado por critério não escrito e depois descontado. Volta a 9 com a varredura trocada e o §3.3 retratado |
| Contexto | 8 | 8 | mantida — o zero é verdadeiro, eu re-provei-o |
| Veracidade | 7 | 7 | mantida |
| Utilidade | 6 | 6 | mantida, e a perda de preço/prazo na pergunta real é a prova dela |
| Fronteira | 6 | 6 | mantida |

## O que falta correr, e por que eu não corri

1. **O C5.** Uma janela de 1 caso × 3 × 2 braços. Mede se a rota passou a dizer
   "não li" sobre o que nunca existiu — risco criado por esta volta e por
   nenhuma outra. Não corri: ordem de não gastar aparelho de conta.
2. **Um C3 farto.** O controle de zero foi medido em vizinhas de até 307
   caracteres; o risco de confissão espúria mora no material grande que ainda
   assim cabe. Não corri: mesma ordem.

Nenhuma das duas segura a mescla: a primeira mede um risco **novo** que a rota
cortada não expõe, e a segunda alarga uma prova que, no tamanho medido, deu zero.
