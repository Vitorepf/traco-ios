# R1 — a retomada do Trabalho: voltar depois e continuar sem reconstruir o contexto

Implementador (Claude Opus 5), 08/09/2026, 21h30–22h20.
Branch `Vitorepf/volta-r1-retomada`, sem mesclar. ADR **2026-09-08y** no `SPEC.md`.

**Simulador: iPhone 17 Pro (teste 3) `34CC3F94-FDB5-4575-A4F5-80271829A18B`**,
recebido desligado, ligado por mim, usado sozinho, desligado ao fim. Nenhum toque
no `C2416CBC` (conta Grok do dono), no `A1DF082C`, no `C7341E64` nem no
`6033B043`. **Nenhum mouse do Mac, nenhuma voz, nenhuma Siri, nenhum VoiceOver,
nenhum iPad, nenhum maestro.** Todo `xcodebuild`, `xcodebuild test` e toda
sessão de `orca emulator` passaram por `ferramentas/orca/com-trava.sh` — segurei
a trava em cada uma. As capturas são `xcrun simctl io 34CC3F94… screenshot`,
sempre com o UDID explícito, nunca `booted`.

---

## 1. A auditoria antes de codar — e o defeito que já tinha caído

`design-router`, rota **"ajuste local de componente/copy"**, começando pela
fase 5 (auditar antes de tocar). Estado plantado com
`ferramentas/orca/semear-retomada.py` (novo): escreve no formato que o app já
grava — `ZTRABALHO` do App Group, mesmo JSON — a história de um autor que
trabalhou no dia 7 e volta no dia 8.

A auditoria do G0 nomeava três defeitos. Aberta a folha na tela viva,
**o primeiro não existe mais**:

> **"A folha não abre no ponto certo."** Falso hoje. A `retomada` é o segundo
> bloco e nasce ACIMA da dobra: o "Continuar: \<ato\>" está a **0,36 tela** do
> topo e o "Último retorno" a **0,46**. E o que está no topo é a **intenção**,
> que é o *objetivo* que o critério do dono manda retomar. Rolar automaticamente
> na abertura esconderia justamente isso.

Não implementei rolagem automática. É decisão, com o motivo escrito na ADR — não
esquecimento. A auditoria é datada, e metade dos defeitos deste projeto já caiu
sozinha antes de alguém chegar.

Os outros dois são reais e estão medidos abaixo.

## 2. A régua: alturas de tela na árvore de AX

A rolagem por arrasto do `orca emulator` **amplifica de 6 a 24x** (achado de
08/09, na ESTEIRA): um arrasto de 30% da tela saltou do topo da folha até o
rodapé, 4,7 telas abaixo. Por isso **não** usei "número de arrastos" como régua.

A régua é a **árvore de AX do mesmo instante**, que devolve a posição de cada
elemento em **alturas de tela a partir do topo da folha** (não recortada pela
janela visível: o documento inteiro aparece com `y` até 4,74 antes e 4,95 depois). Mesma folha,
mesmo estado plantado, mesmo aparelho, mesmo tamanho de letra (`large`, o
padrão do iOS), mesmos três toques até chegar lá.

| o que o autor precisa saber ao voltar | antes | depois |
|---|---|---|
| objetivo (a intenção) | 0,15 | 0,15 |
| próximo passo ("Continuar: …") | 0,36 | 0,36 |
| **versão nova preparada ontem** | **1,57** | **0,58** |
| **ato que ele marcou como realizado** | **2,41** | **0,53** |
| **resultado que ele mesmo informou** | **2,45** | **0,67** |
| **quando foi o último retorno** | **3,76** | **0,64** |
| **dificuldade que ele registrou** | **4,22** | **0,48** |
| altura total do documento | 4,74 | 4,95 |

**Curva-zero, em toques e em gestos.** Os três toques do app até a folha
(Notas → Trabalhos → o trabalho) são **idênticos** nos dois builds — a diferença
está toda dentro da folha. Lá dentro:

- **antes:** 0 gestos dão 2 das 7 coisas. As outras cinco estão espalhadas por
  cinco blocos diferentes entre 1,57 e 4,22 telas — no mínimo **quatro arrastos
  deliberados** e cinco leituras separadas, e o autor ainda precisa juntar
  sozinho o que aconteceu quando.
- **depois:** **0 gestos** dão as 7, num bloco só e em ordem, com as datas.

Evidência do mesmo instante:
`ferramentas/orca/r1-antes-folha.png` + `r1-ax-antes.json`;
`ferramentas/orca/r1-depois-folha.png` + `r1-ax-depois.json`.

**Lei de hoje respeitada:** ausência na árvore não é prova de ausência na tela.
Todas as afirmações desta tabela são de **presença** — cada linha citada está na
árvore *e* legível na captura correspondente. Nenhuma conclusão foi tirada de
algo que a árvore não mostrou.

## 3. O que mudou no código

**`Traco/Trabalho/Trabalho.swift`** (+69/−1)

- `DocumentoTrabalho.mudancasDesde(_ instante: Date) -> [Mudanca]`. Sai dos
  vínculos que o app guarda — versão e produtor, ato executado, relato,
  resultado observado, decisão de apoio, dificuldade. Mais recente primeiro.
  **Nenhuma frase é gerada por modelo.** O que não tem data no registro não
  entra, e ausência aqui é ausência de data, nunca "nada aconteceu".
- `apoioMarcadoEm` e `trechoDelimitadoEm`: duas datas opcionais. `apoio` e
  `trechoExercitado` eram valores sem história, e a retomada precisa **datar** a
  decisão para contá-la. `nil` = registro anterior ao contrato: decisão não
  datada, nunca data inventada.
- `Apoio.nome` — o rótulo desceu da view para o modelo porque agora duas telas
  o escrevem; a cópia que existia na view foi apagada.

**`Traco/Trabalho/TrabalhoView.swift`** (+77/−12)

- `desdeAUltimaVisita(_:)` dentro da `retomada` que já existia. Teto de quatro
  linhas e o excedente **dito** (`e mais N desde então`). A linha do excedente
  não promete onde o resto está: nem tudo mora no histórico — a decisão de
  apoio, por exemplo, está no trilho logo abaixo — e mandar o autor ao lugar
  errado é pior que não mandar a lugar nenhum.
- "Último retorno" ganhou **data** e o **resultado que a pessoa informou**
  (ADR 08m: eixo próprio, e estava a 2,4 telas dali).
- A visita anterior mora em `UserDefaults`, chave `trabalho.visita.<uuid>`, ao
  lado dos rascunhos — **não** no documento: quando o autor abriu a folha é fato
  deste aparelho, exportar o Markdown não carrega a visita de ninguém, e o
  registro compartilhado não ganha campo de vigilância. Lida uma vez por folha
  aberta, para que o bloco não se apague sob os olhos de quem o está lendo.
- A mesma notícia não sai duas vezes na mesma tela: a linha do relato que a
  folha já mostra inteiro logo abaixo é filtrada da lista.

**Fronteiras respeitadas:** nenhuma tela nova, nenhum agregado novo, nenhum
componente novo (`secao`, `Tema.meta`, `Tema.tintaSuave` — o que a folha já
usa), nenhum `EstadoExercicio` persistido, nenhum resumo escrito pela IA.
Nenhum arquivo de `Traco/Caderno/*`, `Traco/Notas/*`, `ferramentas/traco-mcp/`
ou `TracoWidget/` foi tocado.

## 4. O teste, e o vermelho antes do verde

`TracoTests/RetomadaTrabalhoTests.swift`, 5 testes. Dois deles cobrem os dois
sentidos de "apontar para o lugar errado", e **mostrei o vermelho primeiro**,
quebrando de propósito uma coisa de cada vez:

```
✘ oResumoContaOQueHouveDepoisDaVisitaENadaDeAntes() recorded an issue at
  RetomadaTrabalhoTests.swift:67:9: Expectation failed:
  !(textos.contains { $0.contains("Versão 1") } → <not evaluated>)
✘ semNovidadeOResumoCalaEmVezDeFalarDoVelho() … .isEmpty → false
✘ todaRolagemDaFolhaTemDestinoQueExiste() recorded an issue at :139:13:
  Expectation failed: (ancoras → [...]).contains(alvo → "trabalho-acoes")
✘ Test run with 5 tests in 1 suite failed after 0.027 seconds with 3 issues.
```

(a janela do resumo desligada; e `rolarPara = "trabalho-atos"` renomeado para um
`.id` que não existe). Restaurado o código, os mesmos 5 passam.

**O portão da âncora conta a forma certa, medida antes de congelar.** A regex
crua contava menos do que devia: dois destinos moram num ternário e dois são
`chave` de campo, que o helper `campo(…)` marca com `.id(chave)`. São **8**
destinos literais hoje, e os dois que passam por variável (`chave`, `falta`)
ficam **declaradamente fora** — o portão diz isso em vez de fingir que os cobre.

## 5. Suíte integral

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
id=34CC3F94-… -parallel-testing-enabled NO`

```
✔ Test run with 963 tests in 155 suites passed after 75.211 seconds.
** TEST SUCCEEDED **
```

`grep -c warning:` no log completo: **0**. O runner conectou nas duas execuções
que fiz (não houve `0 de N`).

## 6. Acessibilidade

AX5 (`accessibility-extra-extra-extra-large`) medido na árvore: **nenhum
elemento sai de `x = 0,050 … 0,950`** — nada sangra pelos lados, tudo quebra
linha. Captura em `ferramentas/orca/r1-depois-ax5.png`. Tamanho restaurado para
`large` (o padrão do iOS) e conferido: as posições do bloco da intenção voltaram
a bater exatamente com as do "antes" (0,146 / 0,238 / 0,272 / 0,359), que é como
sei que a comparação é justa e que a restauração pegou.

**VoiceOver falado fica declarado como limite**, por ordem do dono: a prova de
acessibilidade aqui é a árvore de AX mais a captura do mesmo instante. Os
rótulos novos entram na ordem de leitura certa (cabeçalho "DESDE …" seguido das
linhas), com `accessibilityIdentifier` próprio em cada uma.

## 7. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | ciclo multiplicar a mente, item 4 da fila, lacuna do EVOLUCAO atualizada com a medida |
| Contrato | 9 | ADR 08y curta, letra conferida no LETRAS-ADR, SPEC e EVOLUCAO coerentes com o código |
| Correção | 9 | 963 testes / 0 falhas / 0 avisos, e o vermelho mostrado antes do verde nos dois sentidos do erro |
| Jornada real | 9 | antes e depois no mesmo aparelho, mesmo estado, mesmos três toques, captura + árvore de AX do mesmo instante |
| Design | 9 | `design-router` fase 5 primeiro; um defeito da auditoria derrubado na tela; só tokens da casa |
| Simplicidade | 9 | 5 fatos que estavam entre 1,57 e 4,22 telas passaram a 0 gesto; nenhum toque novo em nenhuma jornada |
| Movimento | n/a | nenhuma animação nova; o bloco entra com o documento |
| Componentes | n/a | nenhum componente novo — reuso de `secao`/`Pilula`/`Tema`; a única extração foi `Apoio.nome`, que **apagou** uma cópia |
| Acessibilidade | 9 | AX5 sem sangramento medido na árvore; identificadores por linha; VoiceOver falado declarado como limite |
| Performance | n/a | nenhuma lista, editor ou parser tocado; `mudancasDesde` percorre uma vez as coleções do documento já em memória |
| Privacidade e autoria | 9 | a visita é do APARELHO e não do documento — o Markdown exportado não a carrega; nada publica, gasta ou envia; nenhuma frase escrita por modelo |
| Estado honesto | 9 | executar e observar continuam duas linhas com duas datas; decisão sem data no registro antigo não vira data inventada; excedente dito, não escondido |
| Complexidade | 8 | +146 linhas de produção, nenhum arquivo novo em `Traco/`, nenhuma dependência; a volta é aditiva e não devolveu linhas ao caixa |
| Fora do app | n/a | nenhuma superfície fora do app |
| Relato | 9 | este documento, com a evidência nomeada |

## 8. O que esta volta NÃO prova, e prefiro dizer

- **Não prova que o dono volta e continua.** Isso fecha no uso dele. A volta
  entrega o mecanismo e a jornada medida; o item 4 da fila só fecha quando ele
  efetivamente retoma uma situação real.
- **Avaliação de hipótese ficou de fora da lista** (confirmar ou contestar uma
  dificuldade é evento real e datado, `avaliadaEm`). Deixei de fora por
  enxugamento, não por impossibilidade; é uma linha de código.
- **Dois destinos de rolagem passam por variável** e o portão não os alcança.
- **A rolagem por arrasto do emulador não serve de régua** (amplifica 6 a 24x);
  a medida desta volta é a árvore de AX, e digo isso em vez de apresentar uma
  contagem de arrastos que eu não consigo reproduzir.
- **O alerta de permissão do Calendário travou o helper** por três tentativas
  depois do reinstalar: `xcrun simctl privacy grant` não o dispensou e só um
  toque pelo helper reatachado resolveu. Limite do instrumento, registrado.

## 9. Incidente do instrumento, causado por mim

Ao fechar a volta rodei `orca emulator kill --device 34CC3F94…` seguido de
`xcrun simctl shutdown 34CC3F94…`. O meu aparelho desligou como devia — **e o
`6033B043` (F5b), que estava ligado quando recebi a máquina e que eu nunca
toquei, desligou no mesmo segundo** (`device.plist` do `6033B043` modificado às
22:08:33; meu comando às 22:08:34).

A causa provável é o achado que já está na ESTEIRA: **o helper do
`orca emulator` é UM SÓ na máquina**, e o `kill` derrubou os aparelhos que ele
gerenciava, não só o meu. Perguntei ao orquestrador o que fazer
(`orca orchestration ask`) e a pergunta expirou em 10 min sem resposta; então
**religuei o `6033B043`** — restaurar o estado em que encontrei a máquina é o
menor dano, e `shutdown` não apaga contêiner nem perde dado. Estado final igual
ao inicial: `C2416CBC` e `6033B043` ligados, `34CC3F94`, `A1DF082C` e
`C7341E64` desligados. O `C2416CBC` (conta Grok do dono) não foi tocado em
momento nenhum.

**A lei que isto sugere, para o orquestrador decidir se entra na ESTEIRA:**
`orca emulator kill` não é uma operação por aparelho — use `xcrun simctl
shutdown <SEU-UDID>` sozinho, e deixe o helper vivo para os outros workers.
