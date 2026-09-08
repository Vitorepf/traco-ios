# V17 — o artefato que se reescreve, em Markdown

Implementador (Opus 5), branch `Vitorepf/volta-v17-artefato`, 08/09/2026.
Simulador **iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`**. Todo `xcodebuild`,
`xcodebuild test` e toda sessão de `orca emulator` passaram por
`ferramentas/orca/com-trava.sh` — **segurei a trava** em cada uma. Nenhum maestro.
Nenhum toque no mouse ou no teclado do Mac. O aparelho `B91C8DEF` não foi tocado.

## A linha da volta

**Ciclo:** os dois. Multiplicar (o autor avança no espanhol) e melhorar (a versão
seguinte ataca o que ele errou).
**Intenção:** o autor pratica no artefato, erra, e o artefato se reescreve para
atacar aquilo — guardando versões, origem e **motivo**.
**Obstáculo reduzido:** a causa do ajuste não existia como dado. `pedidoDe` a
inferia por base e intenção; inferência não pode ser a autoridade que explica ao
autor por que o exercício dele mudou.
**Evidência:** ADR 08j, 909 testes verdes (eram 894), build sem aviso, e sete
capturas do aparelho.

## O que entrou, contra os sete pontos do contrato

| # | contrato | como ficou |
|---|---|---|
| 1 | dono único: o Trabalho | `Artefato.pratica` continua o exercício; N+1 nasce por `gerar` → `produzir` → `receber`. Zero versão, corpus ou índice paralelo. Zero tela nova. |
| 2 | contrato mínimo | `Pedido.ajuste?` (gatilho fechado, motivo, evidência/conferência/critérios) e `Artefato.pedidoID?`. `validarAjuste` recusa vínculo quebrado, causa que não se sustenta e critério inventado. Registro antigo devolve `nil`: vínculo não registrado. |
| 3 | nenhum `EstadoExercicio` | nada acrescentado. Teste `nadaNoDocumentoGuardaDesempenhoGlobalOuAprendizagem` lê o JSON gravado e recusa `aprendido`, `pontuacao`, `dominio`, `nivel`, `score`. |
| 4 | a causa fora do trecho descartável | num ajuste, tentativa + leitura + critérios + restrições sobem para a cabeça do contexto. Não cabendo, o pedido fica `ajusteIndisponivel` e a folha diz isso (captura `d`). |
| 5 | fronteira no TIPO | esquema `additionalProperties:false` com `mudanca` e nada mais; chave `tentativa` derruba a resposta inteira; `guardarTentativa` continua do autor; o campo nasce vazio (captura `b-tentativa-da-causa`). O limite semântico está escrito na ADR. |
| 6 | o ato "Conferir e adaptar o exercício" | novo e explícito, ao lado de "Conferir minha tentativa" (captura `a`). Leitura sem divergência ou indisponível **não** reescreve e diz por quê. A mesma leitura não gera duas versões; reabrir não dispara; nada em segundo plano. |
| 7 | anúncio numa seção só | "Nesta versão" no alto do exercício: descrição do modelo, origem e motivo do app, sem ID e sem "você aprendeu" (captura `b-nesta-versao`). |

## As três provas do dono

**1. Uma tentativa com erro gera atividade diferente e pertinente, preserva as
restrições e deixa a próxima resposta em branco.**
Teste `umaTentativaComErroGeraExercicioDiferenteComACausaEARespostaEmBranco`:
N+1 com enunciado diferente, `pedidoID` ligado, `ajuste.gatilho ==
necessidadePercebida`, `criterioIDs` = os divergentes, uma única seção "## Nesta
versão", nenhum UUID no conteúdo, e `tentativas(doArtefato: n1).isEmpty`.
Na tela: `v17-b-nesta-versao.png` (o anúncio) e `v17-b-tentativa-da-causa.png`
(o campo "Minha tentativa" da N+1 em branco, com a tentativa da N acima, em
leitura). O núcleo obrigatório está provado em
`oNucleoDoAjusteTrazTentativaLeituraCriteriosERestricoesForaDoTrechoDescartavel`,
que corta a mensagem em `<material_de_referencia>` e confere a cabeça.

**2. Uma correção do dono remove a interpretação equivocada do ajuste seguinte.**
`contestarLeitura` marca `contestadaEm`/`motivoDaContestacao`. A leitura **fica**
com todos os resultados; sai do `contextoDeRetorno` e do núcleo do ajuste, e não
sustenta um ajuste novo. Testes
`aLeituraContestadaSaiDoContextoEDoNucleoMasFicaNoRegistro` e
`oAjusteSeguinteNaoRepeteAInterpretacaoQueODonoCorrigiu` (este captura a mensagem
que o motor de fato monta). **Exercida ao vivo no aparelho**, digitando o motivo
e tocando o botão: `v17-b-contestar-leitura.png` (a rota) e
`v17-c-leitura-contestada.png` (a leitura contestada, inteira, dizendo que não
orienta mais os ajustes).

**3. Fechar e reabrir conserva N, tentativa, causa e N+1.**
`reabrirConservaVersaoTentativaCausaEVersaoSeguinte`;
`falhaDeGravacaoRetryEConflitoNaoPerdemACausaNemDuplicamAVersao` (append, commit
antes do anúncio, retry da mesma versão sem gerar outra, conflito com conteúdo
preservado); `revogarAOrigemInterrompeOAjusteEmCurso` (o selo cancela e a leitura
atrasada não é aplicada); `aMesmaLeituraNaoGeraDuasVersoesEReabrirNaoDispara`.

## Um defeito real, achado na tela e corrigido nesta volta

A lista de tentativas é filtrada pela versão vigente. Depois do ajuste, a
tentativa que **causou** a versão sumia da folha — e com ela o feedback e a rota
de contestar a leitura, exatamente no estado em que ela mais importa. Motor com
superfície inalcançável. A seção "A tentativa que gerou esta versão"
(`tentativaQueGerou`) a devolve, em leitura, com o feedback e o "Não foi isso que
eu errei". Foi a tela que achou; os testes não achariam.

## design-router — as seis fases

- **Ancorar.** Ajuste local de componente e copy dentro da folha do Trabalho, que
  já foi redesenhada na volta 18 (ADR 06b). Pessoa: o autor praticando espanhol.
  Tarefa: saber o que a leitura achou e ter o exercício reescrito para atacar
  aquilo. Resultado observável: um exercício diferente com uma seção que diz o
  que mudou e por quê.
- **Sistema.** Zero token novo, zero componente novo, zero arquivo de UI novo.
  Reuso puro: `secao`, `acaoSecundaria` (a cápsula `Pilula .filtro`), `campo`,
  `.cartao(.campo)`/`.cartao(.papel)`, `.rotulo`, `Tema.meta`, `Tema.tintaSuave`,
  `Tema.aviso`. `Tema.swift` e `Traco/Componentes` não foram tocados (são de
  outra volta).
- **Construir.** A lei de cor da folha respeitada: "carvão avança, âmbar salva" —
  o ato novo é cápsula em tinta, não âmbar, porque não é saída de problema. A
  ordem de leitura do cartão da tentativa: resposta → apoio → feedback →
  contestação → ações. O anúncio fica no ALTO do exercício, antes da tarefa: quem
  abre o documento lê a mudança antes de trabalhar nela.
- **Mover.** Nenhuma animação nova. A chegada da versão continua na animação de
  `artefatos.count` que já existia; a gaveta da contestação usa `Tema.gaveta`; o
  progresso do ato novo é um `ProgressView` com texto próprio, porque quem tocou
  "conferir e adaptar" espera outra coisa de quem tocou só "conferir".
- **Julgar.** Custo real e assumido: a seção Praticar passou de **três** cápsulas
  para **quatro** na última tentativa ("Conferir minha tentativa", "Conferir e
  adaptar o exercício", "Nova tentativa", "Adaptar o próximo exercício"), e isso
  está na captura `v17-a-conferir-e-adaptar.png`. Os quatro atos são distintos e
  o contrato do dono pede o novo explícito (ponto 6), mas é uma pilha. Se o dono
  quiser cortar, o candidato é "Adaptar o próximo exercício": a rota do pedido do
  autor já existe no campo "O que você quer praticar?", com a instrução dele em
  vez de uma frase enlatada. Não cortei por conta própria — o botão existe e
  funciona, e o dono não pediu para tirá-lo.
- **Portão.** AX5 conferido no anúncio (`v17-e-ax5-nesta-versao.png`): quebra sem
  clipe e sem sangrar. Contraste, alvo e rótulos vêm dos componentes que já
  passaram no portão da volta 18.

## Instrumento — o que foi limite, e o que não foi

- **Sem conta Grok neste aparelho.** A conta do dono está no `B91C8DEF`, proibido
  para esta volta. Os dois atos que a oferta gateia não se fotografam sem ela.
  Usei o mesmo instrumento que a ADR 06c criou para o ditado: um argumento de
  lançamento **só em Debug**, `-ensaio-oferta-da-pratica`, que abre a OFERTA e
  nada mais — não fabrica token, não chama rede, e o que a tela mostra depois do
  toque continua sendo a indisponibilidade real (visível na captura `d`, com a
  linha "Revisão pela IA precisa da conta Grok").
- **Documento plantado, não gerado.** A jornada foi observada sobre um
  `DocumentoTrabalho` construído pela API real do modelo e escrito no
  `default.store` do aparelho. Por isso esta volta **não** afirma nada sobre a
  qualidade semântica do exercício adaptado: isso é prova da frente Q, com a
  conta ligada, e está escrito na ADR e no EVOLUCAO.
- **O `orca emulator` amplifica o arrasto** em cerca de 6 a 24 vezes, e o fator
  muda com o conteúdo. Rolagem por passo fixo passa direto do alvo. O que
  funcionou foi medir o ganho a cada passo pela árvore de AX e realimentar
  (`ir.sh` no scratchpad). Fica como achado do instrumento.
- **Tamanho de letra:** o aparelho já estava em `large` quando cheguei. Subi para
  AX5 para a captura de acessibilidade e **restaurei para `large`**, conferido
  por `xcrun simctl ui`. Não devolvi para `medium` porque não fui eu quem mudou.
- **Helper solto** ao fim (`orca emulator kill --device C7341E64`). O simulador
  ficou ligado — não fui eu que o liguei.

## Prova

```
** BUILD SUCCEEDED **                       (0 warning:)
✔ Test run with 909 tests in 145 suites passed after 10.112 seconds.
```
Antes da volta: 894 testes em 144 suítes. Quinze testes novos em
`TracoTests/AjusteDoExercicioTests.swift`.

```
$ git diff --shortstat
 6 files changed, 493 insertions(+), 44 deletions(-)
```
(mais `TracoTests/AjusteDoExercicioTests.swift`, novo, e a ADR/EVOLUCAO/relatório.)

Capturas, todas `xcrun simctl io C7341E64-... screenshot`:

| arquivo | o que prova |
|---|---|
| `v17-a-conferir-e-adaptar.png` | o ato novo na tela, ao lado dos que já existiam |
| `v17-b-nesta-versao.png` | "Nesta versão": o que mudou, de onde veio, e "reescrever não é dizer que você aprendeu" |
| `v17-b-tentativa-da-causa.png` | a tentativa que gerou a versão, em leitura, e a próxima resposta **em branco** |
| `v17-b-contestar-leitura.png` | a rota da correção do dono dentro do feedback |
| `v17-c-leitura-contestada.png` | leitura contestada ao vivo: fica inteira no registro e não orienta mais |
| `v17-d-ajuste-indisponivel.png` | estado honesto: a causa não coube e o app não mandou um pedaço dela |
| `v17-e-ax5-nesta-versao.png` | o anúncio em AX5, sem clipe |

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | os dois ciclos, e fecha a lacuna "Artefato que se transforma" no EVOLUCAO — dizendo o que ela **não** fecha |
| Contrato | 9 | ADR 08j curta, SPEC/EVOLUCAO coerentes com o código, limite semântico declarado |
| Correção | 9 | 15 testes novos, 909 verdes, build sem aviso; conflito, retry e revogação cobertos |
| Jornada real | 8 | sete capturas nos estados que importam, mas o documento foi plantado e a oferta simulada em Debug: falta a jornada com provedor real |
| Design | 9 | seis fases cumpridas, zero token novo, lei de cor respeitada |
| Simplicidade | 7 | quatro cápsulas na última tentativa. É o preço do contrato de sete pontos e está fotografado; a saída está proposta acima |
| Movimento | n/a | nenhuma animação nova; a que existe é a da volta 18 |
| Componentes | 9 | reuso puro, nenhum arquivo de UI novo |
| Acessibilidade | 9 | AX5 conferido no bloco novo; rótulos e identificadores em todos os controles novos |
| Performance | n/a | não toca lista, editor nem parser de rolagem |
| Privacidade e autoria | 9 | a IA não escreve tentativa nem `Evidencia`, por tipo; o selo cancela o ajuste em curso, com teste |
| Estado honesto | 9 | leitura sem divergência, leitura não concluída e ajuste indisponível são ditos na tela, cada um com o seu texto |
| Complexidade | 8 | +493/−44, um arquivo novo (de teste). Nenhuma tela, nenhum agregado, nenhum token |
| Fora do app | n/a | não toca widget, Intents nem Live Activity |
| Relato | 9 | este documento, com o defeito achado e o limite de instrumento declarados |
