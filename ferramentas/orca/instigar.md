# INSTIGAR — condicionar à matéria (ADR 2026-09-10c)

**Volta:** INSTIGAR · branch `Vitorepf/instigar` · aparelho de conta `B91C8DEF` (teste 2)
· suíte no `A1DF082C` (teste 4) · 10/09/2026.

**A alavanca, numa frase:** o requisito das três perguntas — *o quê aconteceu*, *quando
aconteceu*, *o que seria dar certo* — deixa de ser incondicional e passa a depender do que
a nota dá. Uma linha do pedido trocada por uma linha, na mesma posição.

---

## 1. De onde vem, e o que custou não fazer isto antes

A Q4-C mediu, reprovou-se, **escreveu o conserto e não o aplicou de propósito**, para o
binário comitado não divergir do medido. A dívida ficou nomeada no `RUMO.md` e é esta
volta que a paga.

O que a promoção incondicional do LOTE-5 comprou, com número (G3 `a850ec7`):

| o que a cláusula promovida fez | LOTE-3 | LOTE-5 |
|---|---|---|
| `quando` no `q4-instigar-texto-magro` (`grok-4.3`) | 0/3 | **3/3** ← o ganho |
| perguntas **ancoradas** na nota, 5 casos ricos (`grok-4.3`) | 49/51 = 96% | **48/63 = 76%** ← o preço |
| idem, `grok-4.5` | 59/61 = 97% | **63/71 = 89%** |
| repetição inteiramente GENÉRICA (`grok-4.3`) | 0/15 | **1/15** |

**A forma do defeito:** o requisito que subiu para MORDER na nota pobre virou **acréscimo**
na nota farta. O modelo cumpriu a lista promovida e a **somou** às perguntas que já faria.

*Promover não é somar peso, é mudar quem manda entre linhas que se contradizem.*

## 2. O que mudou no código

Uma linha por uma linha, no fim de `Sabia.sistemaInstigar` — a posição importa: a cláusula
do LOTE-5 entrava **no alto** do pedido, e foi por isso que governou tudo.

O resto do diff não é a alavanca; é o que faz a medida valer:

| arquivo | o quê | por quê |
|---|---|---|
| `Sabia.swift` | `sistemaInstigarBase` (DEBUG, por ambiente) + `pedidoDeInstigar` | os DOIS braços no MESMO dylib. Sem isso eu compararia contra uma tabela do G3 feita com outro binário |
| `AvaliacaoIA.swift` | `pedidoInstigarSHA256` em toda linha, em `carimbosDoPedido` | qual pedido rodou cada caso, pelo dado e não pelo nome do arquivo. **Na mescla com `main` esta chave e a `pedidoResponderSHA256` da 10b caíam na MESMA linha que fecha o literal do registro**, e resolver de afogadilho derrubaria uma das duas em silêncio — a corrida seguinte perderia o carimbo do braço e pareceria medida. As duas saíram para uma constante com nome, onde cada rota tem a sua linha; `AvaliacaoIACarimboTests` fica vermelho se uma sumir |
| `Grok.swift` | `Diagnostico.bruto` no portão por onde TODAS as rotas passam | sem ele a pergunta que `parsePerguntas` derruba some sem rastro e a medida credita ao modelo o que foi a nossa tesoura. **Hunk idêntico ao do branch `responder`**, de propósito: duas voltas com o mesmo texto mesclam sem conflito |
| `f5-ler.swift` | o `--xy` do branch `q4-c`, hunk idêntico | o helper de AX devolve árvore vazia neste simulador |

## 3. O instrumento, e a prova de que ele enxerga

- `ferramentas/orca/lote-ia-09e-q4c.py` — **cópia verbatim** do medidor do LOTE-5
  (`cmp` idêntico). Mudar o instrumento faz o LOTE-3, o LOTE-5 e esta corrida deixarem de
  se comparar.
- `ferramentas/orca/instigar-medidor.py` — **só as colunas que esta volta acrescenta**, e
  as duas correm TAMBÉM na base.
- `ferramentas/orca/instigar-prompt.py` — extrai do binário o TEXTO do pedido e o SHA-256
  dele. Fecha a dívida do RUMO de 10/09: a janela carimbava o *hash do binário* e não
  guardava o *conteúdo do pedido*, e quando o G3 da Q3-C foi conferir, o `.dylib` já não
  existia.

**O medidor reproduz a tabela do G3 da Q4-C célula a célula** — 49/51, 48/63, 59/61,
63/71, e cada linha por caso. Uma coluna nova que não reproduz o número conhecido está
medindo outra coisa.

**Metade dessa calibração não se confere NESTE branch, e é justo dizê-lo.** O que qualquer
um reproduz aqui é o LOTE-3 — `prova/lote09c-q4-grok-4.3.jsonl` e `-4.5.jsonl`, que dão
**49/51 = 96%** e **59/61 = 97%**, por caso e no total. Os **48/63 e 63/71** são do LOTE-5,
e os JSONL do `lote09e` vivem no branch `q4-c`: não estão aqui nem em `main`. Quem quiser
conferir a outra metade tem de ir buscá-los lá.

**O vigia é provado nos dois sentidos**, com frases REAIS da corrida: **13 execuções, 6
que ele TEM de acusar e 7 que ele NÃO PODE** — não são seis e seis, e a metade exata nunca
foi requisito: o que o portão cobra é que ele acuse e cale, não que os dois lados empatem.
`instigar-medidor.py --vigia` sai vermelho se um caso cego sumir da fixture ou se a letra
perder as palavras `REPROVA POR` / `PASSA`.

## 4. As duas janelas, e a conta viva nas duas

| | janela 1 | janela 2 |
|---|---|---|
| quando | 17:26:57Z – 17:49:21Z | 18:11:40Z – 18:35:39Z |
| aparelho | `B91C8DEF` (teste 2) | idem |
| instalações | **UMA**, por cima | **UMA**, por cima |
| `ContaGrok.ligada` antes | `true` (17:27:00Z) | `true` (18:11:43Z) |
| `ContaGrok.ligada` depois do install | `true` (17:27:03Z) | `true` (18:11:47Z) |
| `ContaGrok.ligada` no fim | `true` (17:49:21Z) | `true` (18:35:06Z) |
| `cmp` do binário | bate com o meu produto | bate com o meu produto |
| binário | `cd84aeaf…` do início ao fim | `fb2a28b1…` do início ao fim |
| pedidos extraídos do dylib | candidato `90fd80e7`, base `5110e22a` | candidato `7c505d21`, base `5110e22a` |
| falhas de transporte | **0** em 42+42 chamadas `200` | 0 |

A segunda instalação foi **autorizada pelo coordenador**: a regra das DUAS TENTATIVAS no
caso cego pressupõe uma segunda medida, e a regra de "UMA instalação por volta" nasceu
para impedir reinstalação por hábito, não para impedir a segunda tentativa.

**Os quatro braços correm no MESMO binário de cada janela.** A única alavanca é o PEDIDO,
que troca por ambiente (`TRACO_AVALIAR_PEDIDO=base`), e `pedidoInstigarSHA256` grava em
**toda linha** qual dos dois rodou. "O binário era outro" deixa de ser uma dúvida possível.

## 5. O resultado, e ele é uma tabela só

Cada linha é 8 casos × 3 repetições, 24 execuções. `magro quando` é o GANHO que a volta
anterior comprou caro e que esta não pode perder; `ancoradas` é o PREÇO que ela pagou e que
esta não pode repetir; os dois cegos são novos. **A base tem DUAS linhas por modelo, uma
por janela** — é ela que diz quanto vale um ponto nesta régua.

| braço · modelo | SHA do pedido | magro `quando` | cego JÁ RESPONDE | cego NEGA | perguntas ao todo | ancoradas (casos com matéria) |
|---|---|---|---|---|---|---|
| base · t1 · `grok-4.3` | `5110e22a` | **1/3** | 2 falhas | 5 falhas | 78 (3,25/exec) | 55/60 = **92%** |
| base · **t2** · `grok-4.3` | `5110e22a` | **0/3** | 1 falha | 4 falhas | 76 (3,17/exec) | 52/59 = **88%** |
| base · t1 · `grok-4.5` | `5110e22a` | **1/3** | passa | passa | 98 (4,08/exec) | 68/74 = **92%** |
| base · **t2** · `grok-4.5` | `5110e22a` | **2/3** | passa | passa | 97 (4,04/exec) | 66/74 = **89%** |
| 1ª redação · t1 · `grok-4.3` | `90fd80e7` | **3/3** | passa | 6 falhas | 74 (3,08/exec) | 52/56 = **93%** |
| 1ª redação · t1 · `grok-4.5` | `90fd80e7` | **3/3** | passa | passa | 95 (3,96/exec) | 67/72 = **93%** |
| 2ª redação · t2 · `grok-4.3` | `7c505d21` | **1/3** | passa | 1 falha | 71 (2,96/exec) | 40/54 = **74%** |
| 2ª redação · t2 · `grok-4.5` | `7c505d21` | **2/3** | passa | passa | 93 (3,88/exec) | 65/73 = **89%** |

**A linha que faltava é a `base · t2`, e ela é a régua desta tabela.** A base rodou nas
DUAS janelas, com o mesmo `5110e22a`, a mesma fixture e as mesmas 8 entradas byte a byte,
em binários diferentes (`cd84aeaf` / `fb2a28b1`). Era medida de ruído de graça, estava na
minha mão, no mesmo commit, **e eu nunca a rodei**. As duas corridas da base discordam
**4 pontos** no `grok-4.3` (92% → 88%) e **3** no `grok-4.5` (92% → 89%). Qualquer efeito
menor do que isto é ruído do instrumento, e a única linha de base que a versão anterior
desta tabela mostrava era **a melhor das duas**.

**Lê-se assim, e nesta ordem:**

1. **A alavanca cura a nota magra, e o número é o das DUAS janelas juntas.** A 1ª redação
   leva o texto magro a **6/6** — 2 modelos × 3 repetições — contra **4/12** da base
   pooled nas duas janelas (1/3 e 1/3 em t1, 0/3 e 2/3 em t2). Fisher exato de uma cauda:
   **p = 0,011**. Quem lê só a janela 1 superestima o degrau, porque ali a base parece 1/3
   nos dois modelos; o número honesto é o pooled, e ele é MAIS forte do que o que eu tinha
   escrito.
2. **E não repete o colapso do LOTE-5** — que é o que se pode afirmar sobre as ancoradas,
   e só isso. Elas ficam na faixa da **própria base** (88–93%), onde a promoção
   incondicional as tinha derrubado a **76% e 89%**: 12 a 17 pontos abaixo, 3 a 4 vezes
   fora do ruído. Contra a base, porém, **o ganho de 1 ponto é ruído** — p = 0,54 no
   `grok-4.3` e 0,52 no `grok-4.5`, quando a base contra **ela mesma** dá 0,37 e 0,39, a
   mesma ordem de grandeza.
   **E a contagem ABSOLUTA de ancoradas CAI: 55 → 52 no `grok-4.3`** (a base t2 também dá
   52), e no `grok-4.5` o candidato (**67**) fica *entre* as duas corridas da base (66 e
   68). Os 93% vêm de o denominador cair mais depressa que o numerador — o candidato faz
   4 perguntas a menos no 4.3, e **3 delas eram ancoradas**. Em números absolutos o autor
   recebe MENOS pergunta ancorada, não mais. O caso que paga é
   `q4-instigar-com-metodo-decisao`: 12/14 → 10/12.
   **A §7 desta página escreve a lei — *"a média esconde o caso que foi a zero"* — e a
   versão anterior deste item violava-a**, vendendo 1 ponto de média como resultado
   enquanto a conta caía. O G3 baixou "Estado honesto" de 9 para 7 por isto, e tinha razão.
   `GENÉRICAS` fica 0/3 em todos os casos ricos, e o degrau 4 continua não repetindo o
   degrau 0.
3. **O caso cego achou o furo da 1ª redação, e ele é do `grok-4.3`.** Numa nota que NEGA
   por escrito o quando e o "dar certo", o 4.3 pergunta os dois assim mesmo em **3 de 3**;
   o 4.5 não pergunta em 3 de 3. A causa, nomeada: *a 1ª redação condiciona à QUANTIDADE
   de matéria, não ao que a nota já resolveu.*
4. **A 2ª redação consertou isso e quebrou o controle.** "Entra só a que a nota deixou EM
   ABERTO, e negar fecha a perna tanto quanto responder" derrubou o cego do 4.3 de 6
   falhas para 1 — e levou junto o texto magro (3/3 → 1/3 no 4.3, 2/3 no 4.5) e as
   ancoradas (93% → 74% e 89%). **Ensinar a não perguntar o que a nota fechou ensinou
   junto a não perguntar quando ela só é MAGRA.** As duas falhas são simétricas e cada uma
   esconde a outra. **A 2ª foi medida e descartada; o descarte é o resultado.**
   **Mas o 6 → 1 do cego não é achado independente, e o G3 achou o que eu não vi:** a 2ª
   redação põe no PEDIDO as strings que o `cego()` procura (*"não sei quando"*, *"não sei
   o que seria"*). Ali o conferidor está a medir obediência à sua própria instrução, não
   conserto. Como ela foi descartada, isso não contamina a decisão — mas *"a 2ª consertou
   o cego"* estava escrito como se fosse prova, e não é.
5. **O que fica é a 1ª redação, e o que sobra é limite MEDIDO do modelo**, não do pedido.

**Uma ressalva contra o meu próprio caso cego, e ela é importante:** no `grok-4.5` o cego
`fatos-negados` **também passa na BASE**. Ali ele não discrimina — o que ele mede é o 4.3,
onde a base falha 5 vezes, a 1ª redação 6 e a 2ª uma. No 4.5 o mérito da volta é o texto
magro sem a diluição, não o cego.

## 6. O caso cego, e por que são dois

Os seis casos da Q4 medem o vazamento do nosso andaime e a nota magra. Nenhum media o eixo
em que uma operação de PERGUNTA morre: **material que nega o que se perguntaria**. Ali as
duas falhas são simétricas — quem ensina a perguntar sempre compra a pergunta já
respondida, e quem ensina a calar compra o silêncio na nota que só é magra.

| id | o que a nota faz | o polo que mede |
|---|---|---|
| `revisor-instigar-nota-que-ja-responde` | diz O QUÊ (o preço errado), QUANDO (ontem de manhã) e O QUE SERIA dar certo — as três, com todas as letras, e ainda deixa matéria | **pergunta já respondida** |
| `revisor-instigar-fatos-negados` | é magra COMO a do `texto-magro` e ainda assim NEGA duas das três ("não consigo dizer quando começou", "nem sei o que seria dar certo"); o O QUÊ ela nunca diz | **pergunta já negada** vs. **recusa covarde** |

A fixture diz pela LETRA o que reprova — cada requisito começa por `REPROVA POR` ou
`PASSA` —, e `instigar-medidor.py` **quebra** se um id cego sumir do arquivo ou se a letra
perder essas palavras.

**Os dois foram escritos por MIM, depois de a alavanca estar congelada no arquivo, e isso
não é caso cego de revisor.** É held-out do prompt, não do autor do prompt. A aprovação
final continua pedindo casos de quem não os viu.

## 7. O que o instrumento cobrou de mim, e vale para o próximo

- **Falso positivo que REPROVA é o pior tipo.** O proxy do `quando` casava com a conjunção
  ("O que muda QUANDO você põe essa palavra?") e o do "dar certo" casava com a premissa
  ("SEM SABER o que seria dar certo, o que a desistência resolveu?"). Os dois reprovavam
  perguntas boas da BASE. Apertei antes de ler, e o aperto **favorece a base** — tira
  reprovação do braço antigo, não do meu.
- **Zero só vale se havia o que ver.** A coluna da nossa tesoura diz `NÃO VERIFICÁVEL` nos
  JSONL sem `bruto`, em vez de dizer "nenhuma derrubada". Nos **oito** braços com `bruto`
  há **uma** derrubada, e ela só apareceu quando rodei a base da 2ª janela: `base · t2 ·
  grok-4.5`, `revisor-instigar-fatos-negados` r1, o modelo devolveu 4 perguntas e
  `parsePerguntas` deixou 3. Nos outros sete, zero — e é um fato lido, não um silêncio. **A
  versão anterior desta linha dizia "nas quatro corridas: nenhuma", e as quatro eram as que
  eu tinha rodado.**
- **A média esconde o caso que foi a zero.** A coluna sai por caso, e a média vem depois,
  com a etiqueta dizendo o que ela esconde.

## 8. O que ficou de fora, e por quê

- **A operação NÃO volta ao Perfil.** Pelas §14/§15 nenhuma operação retorna sem a
  superfície aprovada no G4 e vista pelo dono, e a superfície da resposta está sendo
  redesenhada agora. `Politica.linha(.instigar)` continua `indisponivelPorQualidade`. O que
  mudou é o que o autor LÊ: o `motivo`, o `conserto` e a frase da tela diziam *"quando você
  escreveu pouco, pergunta vago e não pergunta quando aconteceu"* — defeito que esta volta
  consertou e mediu — e passam a dizer o defeito de hoje, *"quando você diz que não sabe
  quando foi, ela pergunta assim mesmo"*. Deixar na tela um motivo já consertado é mentir
  para o autor tanto quanto prometer uma volta que não aconteceu.
- **Não escolhi o modelo da rota.** A evidência para `grok-4.5` está medida e pareada, e é
  insumo direto para a 09v — mas `Sabia.modeloMedido` numa rota que a `Politica` não deixa
  correr é código para depois. Fica para a volta que devolver a operação, com este número
  na mão.
- **A captura do cartão vivo não saiu.** Duas tentativas dentro das janelas, as duas por
  defeito do roteiro e não do aparelho: na primeira eu chamei o roteiro sem o 3º argumento
  e o texto da nota caiu em `$LER` (consertado com uma guarda: argumento posicional errado
  não pode custar uma janela); na segunda o aparelho da CONTA abriu na LISTA de notas — ele
  tem notas do autor — e não no editor, como o aparelho de trabalho vazio (consertado: toca
  "Escrever" primeiro). A navegação inteira está ENSAIADA e provada no teste 4, com a
  rolagem calibrada. **Não gastei uma terceira instalação nisso**, porque a superfície está
  reprovada e sendo refeita: a prova de fecho vai ser no componente novo.
- **`grok-4.6` não correu.** Uma alavanca por volta: esta é o PEDIDO, e os dois modelos são
  os do LOTE-3/LOTE-5, para a comparação por id continuar valendo.

## 9. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | prova |
|---|---|---|
| Contrato | 9 | ADR 10c dentro da letra reservada pelo despacho, `grep -c "^\| 10c"` = 1 e `grep -c "^## ADR 2026-09-10c"` = 1; `Politica`/SPEC/EVOLUCAO coerentes; a seção 8 diz o que NÃO foi feito antes de alguém perguntar |
| Correção | 9 | **1047 testes em 165 suítes verdes na árvore JÁ MESCLADA com `origin/main`**, no `A1DF082C`, sob `com-trava.sh` — a volta que mede fecha com o binário que mediu. Compilação sem aviso novo: o único que sai é herdado de `main` (`NotasView.swift:814`, `+` de `Text` depreciado em iOS 26), em arquivo que esta volta não toca. As guardas novas provadas VERMELHAS por mutação: a do contrato com a cláusula do LOTE-5 de volta (3 issues), a do pareamento com UM espaço a mais no braço da base (1 issue), e as duas do carimbo — **apagar a chave da 10b derruba a prova de valor e deixa as outras duas verdes; apagar a linha que copia os carimbos para o registro derruba SÓ a que lê o fonte**, que é exatamente o buraco que ela existe para tapar |
| Qualidade de IA | 8 | quatro braços, dois modelos, duas janelas, um binário por janela e o SHA do pedido em toda linha; o caso cego achou o que sobra e a 2ª redação foi descartada com número. **Menos um ponto, e o G3 tem razão:** a 2ª corrida da base estava na minha mão, no mesmo commit, e eu não a rodei — era a medida do ruído do meu próprio instrumento, de graça |
| Jornada real | 7 | a medida é a rota de produção (`Sabia.instigar` pelo `chamar`), no aparelho da conta, com a conta ligada — mas a resposta real na TELA não foi fotografada nesta volta, e isso é o que falta |
| Design | n/a | nenhum token, layout, cor ou movimento tocado. A copy da `Politica` mudou, e `design-router` não foi carregado: é ajuste de texto de tabela, não direção visual — declarado, não escondido |
| Simplicidade | 9 | a alavanca é UMA linha trocada por UMA linha; zero arquivo novo de produção; o resto é sonda `#if DEBUG`, fixture e conferidor. Os carimbos saíram para `AvaliacaoIA.carimbosDoPedido` — 6 linhas em DEBUG que **tiram** a armadilha em vez de a documentar |
| Movimento · Componentes · Acessibilidade · Performance | n/a | nada anima, nada de componente novo, nenhuma superfície nova, nada em caminho quente |
| Privacidade e autoria | 9 | a sonda é `#if DEBUG` e o `bruto` também; nenhuma nota do autor entrou na medida (as 14 entradas são sintéticas); o `f5-ler` roda no Mac sobre captura do simulador |
| Estado honesto | 7 | a 2ª redação está escrita, medida e descartada no código e aqui; a ressalva contra o meu próprio caso cego está na seção 5; o aperto do proxy favorece a base e isso está dito. **Menos dois, e o G3 tem razão:** a §7 escreve a lei da média e a §5 violava-a — 1 ponto de média vendido como resultado enquanto a contagem ABSOLUTA de ancoradas caía. Corrigido acima; a nota fica com a versão que o revisor leu |
| Complexidade | 9 | +1 braço de pedido em DEBUG, +1 campo no diagnóstico, +2 conferidores, +1 roteiro; produção praticamente intocada |
| Fora do app | n/a | nada fora do app |
| Relato | 8 | esta página, com as linhas de resultado coladas, o JSONL citado por braço e o TEXTO dos dois pedidos guardado ao lado dele. **Menos um:** a tabela da §5 mostrava UMA linha de base sem dizer que houve duas corridas, e era a melhor; "seis que ele NÃO PODE" eram 7; metade da calibração citava JSONL que não está neste branch. Os três, corrigidos acima |

**Limites do instrumento, declarados (não descontam nota):** a árvore de AX volta vazia
neste aparelho e a navegação é por OCR; o caso cego é held-out do prompt, não de quem
escreveu o prompt; e o oráculo das `ancoradas` é **paráfrase da cláusula que julga** — mede
*"a pergunta carrega palavra da nota"*, que é o que o candidato acrescenta, e a base só tem
a versão fraca. A régua está inclinada **a favor do candidato**, e ele não passou do ruído
nem assim.

## 10. O fecho, em uma linha: **MÉRITO APROVADO, SUPERFÍCIE PENDENTE**

O mérito passou e está medido. A operação **não volta ao Perfil nesta volta**, e a
**captura de fecho não foi tirada** — não por falta de instrumento, mas porque a
superfície está em redesenho (§14/§15, ordens do dono de 14h10 e 14h35, depois de ele
abrir o cartão às 13h58 e escrever *"experiência deplorável, design deplorável e
doentio"*). Uma captura tirada hoje seria da tela que ele acabou de reprovar, e custaria
uma **terceira instalação** no aparelho da conta — cuja conta ele refez à mão hoje, e que
já apareceu `Shutdown` sozinho às 16h08Z. **A captura será tirada no componente novo.**

O roteiro está pronto e ensaiado para quando esse dia chegar: `instigar-cartao.sh`, com a
navegação fechada e os dois defeitos das tentativas de hoje já consertados.

## 11. A decisão que fica PRONTA para quem devolver o `instigar` (ADR 09v)

**O número que sustenta esta decisão não é o do PEDIDO — é o do MODELO**, e ele é o mais
forte da volta inteira. Juntando as **quatro** corridas em que o caso cego rodou (base e
candidato × as duas janelas), `fatos-negados` separa os dois modelos e não é por pouco:

| `revisor-instigar-fatos-negados` | base t1 | cand. t1 | base t2 | cand. t2 | **ao todo** |
|---|---|---|---|---|---|
| `grok-4.3` (padrão global) | 3/3 | 3/3 | 3/3 | 1/3 | **10 de 12 execuções falham** |
| `grok-4.5` | 0/3 | 0/3 | 0/3 | 0/3 | **0 de 12** |

Duas janelas, dois binários, **os dois pedidos** — e a separação repete-se nas quatro. É
isso que pesa, mais do que qualquer p tratando execuções como independentes (daria
≈ 3·10⁻⁵). **Isto basta para os passos 1–3 abaixo sem remedir nada.**

**E a ressalva vem junto, porque ela é do mesmo tamanho:** é **um caso**, e escrito **por
quem escreveu o pedido**. É held-out do prompt, não do autor do prompt. A confirmação
final quer um **segundo caso de negação, escrito por quem não viu este** — e enquanto ele
não existir, o que está medido é *"o 4.3 falha neste eixo e o 4.5 não"*, não *"o 4.5
resolve o eixo"*.

O pareamento que autoriza a leitura continua limpo: mesma fixture, mesma janela, mesmo
binário, um SHA de pedido por arquivo.

| na 1ª redação | `grok-4.3` (padrão global) | `grok-4.5` |
|---|---|---|
| cego `nota-que-ja-responde` | passa | passa |
| cego `fatos-negados` | **6 falhas em 3 execuções** | **passa** |
| texto magro `quando` | 3/3 | 3/3 |
| ancoradas | 93% (52/56) | 93% (67/72) |

**A recomendação: `instigar` vai para o `grok-4.5`**, como `responderNasNotas` foi na 09v,
e o padrão global fica onde está — o 4.5 é PIOR no `contrapor`, e um vencedor único
consertaria uma rota e estragaria outra.

**A linha exata que muda**, para quem fizer:

1. `Sabia.swift`, ao lado de `modeloMedido` (que hoje é da rota das Notas), uma constante
   própria: `static let modeloMedidoInstigar = "grok-4.5"`.
2. `Sabia.chamar` e `Sabia.chamarComProveniencia` ganham `modelo: String? = nil` e o
   repassam a `Grok.responder` — hoje só `responderNasNotas` tem modelo por rota, e ela o
   consegue **furando** o `chamar` e falando direto com o `Grok`. Enfiar o parâmetro no
   `chamar` é o que evita a segunda rota furando o portão pelo mesmo motivo.
3. `Sabia.instigar` passa `modelo: Grok.modelo(daRota: modeloMedidoInstigar)`. A
   precedência `sonda → rota → padrão global` já existe em `Grok.modelo(daRota:)` e
   continua deixando `TRACO_AVALIAR_MODELO` medir esta rota.
4. `Politica.linha(.instigar)` vira `.soGrok`, o `motivo`/`conserto` saem, e a linha some
   da lista do Perfil sozinha — a tela lê `Politica.indisponiveis`, não uma cópia.

**E a ordem importa:** o passo 4 é o que a §14/§15 prende — ele espera a superfície nova,
e não é desta volta. Os passos 1–3 podem entrar antes, se alguém quiser o modelo certo no
lugar antes da tela, e o 10 de 12 contra 0 de 12 basta para eles. Remedir, não.
