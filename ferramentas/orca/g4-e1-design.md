# G4 — juízo de design da E1 (+E1-B): PASSA

Juiz de design (Fable 5.1), 08/09/2026, 18h30–18h40. Candidato `9d724f1` (E1 + E1-B) contra `main`.
Simulador **iPhone Air `64F7B8B4`**, já ligado quando o recebi, deixado ligado (é onde está a evidência).
Nenhum toque no `C2416CBC` (Grok), no `A1DF082C`, no `6033B043` nem no `34CC3F94`. Nenhum mouse.
Build com `-destination id=64F7B8B4…`, `-parallel-testing-enabled NO`, `derivedDataPath` próprio; app
desinstalado e reinstalado; `nm` no `Traco.debug.dylib` instalado acha `podeCancelar` (6 símbolos) — é o
código da volta, não o de `main`. Toda sessão de `orca emulator` (attach, tap, type, gesture, kill) por
`com-trava.sh`; **não usei a árvore de AX para nenhuma medida** — o helper perde a árvore quando o Traço
abre, e o revisor da E1-B já registrou isso; dirigi por posição lida na captura `simctl io 64F7B8B4` do
instante anterior, e cada toque foi conferido pela captura seguinte. Não corrigi nem comitei nada: as 16
capturas `g4-e1-*.png` ficam soltas em `ferramentas/orca/`. `revisao-e1-estados.md` aparece modificado na
árvore — não fui eu; é do revisor.

**Como plantei o estado.** Copiei o `default.store` do `A1DF082C` (só leitura, para o meu scratch), li o
JSON do Trabalho do autor e escrevi um **documento novo** com UUID próprio, três ações pendentes e
**nenhum relato**, inserido em `ZTRABALHO` do meu App Group. A jornada inteira — combinar, marcar feita,
informar os três resultados, cancelar recusado, revisar — foi feita por mim, na tela, do zero. Nenhuma das
capturas abaixo é do autor.

O que pesou no veredito, em uma linha cada:

- **O coração passa: agendado, feito e funcionou são três linhas distintas num só cartão**
  (`g4-e1-05`): "Você marcou como realizada" / "Resultado que você informou: Funcionou" / "Horário no
  calendário". Antes de cada passo o mesmo cartão dizia "Realização ainda não confirmada" / "Resultado
  ainda não informado" / "Escolher um horário" (`g4-e1-01` → `02` → `03` → `05`). Quem olha distingue os
  três sem ler o código, e nenhum resume o outro.
- **Fracasso e parcial são de primeira classe.** As três cápsulas têm o mesmo peso, a selecionada
  escurece igual para as três (`04`, `06`, `08`), a linha do cartão diz "Não funcionou" com a mesma
  tipografia do "Funcionou", e a frase de apoio diz por escrito que "vale para tentativa parcial e para
  fracasso" e que sem resultado "fica como não observado — nunca como sucesso". O app não sabe só sucesso.
- **A orientação muda de forma diferente por resultado, e eu li as duas no campo do pedido**
  (`11` fracasso: "Proponha um caminho diferente…"; `13` parcial: "Preserve o que ela relatou ter
  funcionado e trabalhe apenas o que ela relatou ter faltado"). Não são a mesma frase com um adjetivo
  trocado. O eixo novo não é decorativo.
- **A recusa do cancelamento é honesta e a contraprova está na mesma captura** (`07`): a ação com
  resultado perde o gesto e ganha "Esta ação não se cancela mais: você já informou um resultado, e cancelar
  apagaria o que aconteceu"; a ação de baixo, pendente e não observada, **continua** com "Cancelar esta
  ação". A frase não culpa, não usa jargão e diz a consequência.
- **Nada de juízo sobre a pessoa.** No diff de produção não há nota, pontuação, "melhorou" nem "aprendeu"
  gravados; a única ocorrência é a instrução "Não declare que ela aprendeu". "Resultado que você informou"
  atribui a observação a ela em toda linha.
- **Portão limpo:** só `Tema.meta`/`Tema.tintaSuave` nas linhas novas, nenhum movimento, nenhuma tela
  nova, ADRs **08m** e **08n** no `SPEC.md`. AX5 sem clipe nos dois eixos, no trilho empilhado e na frase
  da recusa (`14`, `15`).

## Achados que ficam (nenhum bloqueia)

1. **P2 — a orientação segue o último relato do Trabalho inteiro, e a tela não diz de qual ação.**
   `TrabalhoView.swift:1143` e `:1148-1149` leem `ultimaObservacao` (`Trabalho.swift:312`), que é o último
   relato com resultado **entre todas as ações**. Em `g4-e1-09` há três ações com três resultados
   (proposta: Funcionou; orçamento: em parte; ensaio: Não funcionou) e a linha diz só "A revisão vai partir
   do resultado que você informou: Não funcionou." — o botão fala em "estes relatos" (plural) e a linha
   num resultado (singular) sem nome. A instrução gerada (`11`) manda "propor um caminho diferente" para um
   Trabalho cuja ação principal a pessoa disse que **funcionou**. O contexto da IA traz o resultado por
   ação (`OficinaTrabalho.swift:502`), mas o pedido vigente prevalece. **Conserto (uma linha em dois
   textos):** nomear a ação — `"A revisão vai partir do último resultado que você informou, na ação
   “\(acao.texto)”: \(r.rotulo)."` e, em `orientacaoDoRelato`, `"A pessoa informou que a ação
   “\(acao.texto)” NÃO FUNCIONOU…"`. Não bloqueia porque o critério do dono ("o resultado informado muda a
   próxima orientação") está cumprido, o último relato fica logo acima do botão, e o campo do pedido é
   editável antes de "Preparar com IA".
2. **P3 — ordem de foco: a explicação vem depois do botão.** `:1148` renderiza "A revisão vai partir…"
   **abaixo** de "Revisar com estes relatos" (`:1137-1147`). O VoiceOver lê o relato → o botão → e só então
   de que resultado a revisão parte. **Conserto:** mover o `Text` para antes do botão ou passá-lo como
   `.accessibilityHint` do botão.
3. **P3 — o cartão da ação mostra só o último resultado.** Em `g4-e1-12`, a mesma ação que tinha
   "Funcionou" passou a dizer "Funcionou em parte" depois do segundo relato; o histórico continua em "O
   que aconteceu", então nada se perde, mas o cartão não diz que há mais de um. **Conserto opcional:**
   "Último resultado que você informou:" quando `evidencias` da ação com resultado > 1.

## Observações fora do escopo da volta (registro, não contam contra)

- **Pedir permissão de avisos volta a tela ao topo** (`g4-e1-16`): ao tocar "Marcar no calendário" o
  diálogo do sistema aparece, e ao permitir a `TrabalhoView` reconstrói no topo; a pessoa perde o cartão
  e precisa descer de novo. É de `AgendamentoAcaoView`/permissão, anterior à E1.
- **"Horário no calendário" recolhido não mostra o dia/hora** (`02`, `05`): "agendado" fica dito, "para
  quando" só ao expandir. Anterior à E1 (`AgendamentoAcaoView.swift:108`).
- **Registrar um relato empurra a página**: aparece o bloco "Último retorno · Você" no alto e o cartão
  desce ~300 px (`05` comparado a `04`). Comportamento de qualquer relato, anterior à E1.

## Mover

Nada a mover: a volta não acrescenta animação, transição nem estado que mude com o tempo. As cápsulas do
trilho reusam `Pilula .filtro` (mesma resposta de seleção do trilho do apoio, `04`/`06`/`08`); o gesto que
some é substituição de conteúdo, sem transição. `reduceMotion` não tem o que respeitar aqui.

## Julgar — pares antes/depois por arquivo

| arquivo | antes (main) | depois (candidato) | veredito |
|---|---|---|---|
| `TrabalhoView.swift` cartão da ação (`:984-1000`) | uma linha: "Realização ainda não confirmada / Você marcou como realizada / Cancelado" | duas linhas: o ato **e** "Resultado ainda não informado / Resultado que você informou: X" (`01`, `03`, `05`, `12`) | passa: os eixos não se resumem; mesma fonte e tinta das linhas vizinhas |
| `TrabalhoView.swift` gestos (`:1012-1028`) | só "Realizei esta ação" | + "Cancelar esta ação" só se `podeCancelar`; senão a frase da recusa (`07`) | passa: honesto, sem culpa; contraprova na mesma captura |
| `TrabalhoView.swift` trilho (`:1033-1035`, `:1059-1075`) | campo "O que aconteceu?" + botão | + três cápsulas de igual peso, toque de novo desmarca, frase de apoio que nomeia parcial e fracasso (`04`, `06`, `08`, `15` AX5) | passa: HStack em `large`, VStack em AX5, nada fora da tela |
| `TrabalhoView.swift` relatos (`:1115-1121`) | "Relato de Você · data" + texto | + "Resultado informado: X" / "Resultado não observado" (`09`) | passa: relato antigo não vira sucesso por releitura |
| `TrabalhoView.swift` retorno (`:1137-1152`) | pedido fixo "Revise a versão à luz dos relatos…" | pedido por resultado (`11`, `13`) + linha "A revisão vai partir…" (`09`) | passa com P2 (ação não nomeada) e P3 (ordem de foco) |
| `TrabalhoView.swift` `causaDaVersao` (`:816-826`) | nada | "A partir do resultado que você informou em <data>. Você informou o resultado desta ação: X. Seu relato: …" no cartão da versão | **não fotografado**: exige versão nascida do pedido, que sem Grok falha (`10`). Lido no código e no `default.store` do autor; é da frente Q |
| `PraticaTrabalho.swift` | gatilho "a pessoa pediu"/"leitura da tentativa" | + "o resultado que ela informou"; RELATO em vez de TENTATIVA no núcleo | passa (texto para a IA; sem tela própria) |
| `OficinaTrabalho.swift` | ações sem resultado no contexto | "resultado informado pela pessoa: X/não observado" por ação | passa; é o que salva o P2 do lado da IA |

Curva-zero, medida em toques a partir do cartão da ação: combinar = 2 (expandir, "Marcar no calendário")
+ 1 do diálogo do sistema na primeira vez; feito = 1; funcionou = escrever + 1 (cápsula) + 1 (registrar).
Informar resultado custa **um toque a mais** que o relato de antes, e é opcional — o caminho comum não
ficou mais longo.

## Portão

| item | resultado |
|---|---|
| tokens de `Tema` nas linhas novas | `Tema.meta` ×6, `Tema.tintaSuave` ×6; zero cor, fonte ou duração literal (`grep` no diff) |
| movimento vindo de `Tema` | nenhum movimento novo (`withAnimation`/`.animation`/`.transition`: 0 no diff) |
| nenhuma tela nova | confirmado: tudo dentro de `TrabalhoView`, sem sheet, sem rota |
| ADR | `SPEC.md:5875` ADR 2026-09-08m; `:5941` ADR 2026-09-08n |
| AX5 sem clipe | `14` (dois eixos + horário), `15` (trilho empilhado + frase de apoio); a frase da recusa em AX5 **não fotografei** — vale a `17` do autor, que li e que mostra a frase inteira dentro do cartão |
| ordem de foco do resultado à orientação | relato → botão → explicação (P3 acima) |
| `.isSelected` nas cápsulas, ids nas linhas | no código (`:1067-1068`, `:990`, `:994`, `:1027`, `:1120`, `:1151`); **não validei com VoiceOver humano** |
| tamanho de texto restaurado | `simctl ui 64F7B8B4 content_size` → `large` (era `large` quando recebi; AX5 só durante `33`–`37`) |

## O limite declarado — confirmo, e o que ficaria por ver com IA real

A versão nascida do relato **não se fotografa sem conta Grok**: no meu aparelho o pedido nasce com a
causa, falha e a tela diz a falha com honestidade (`10`: "precisa da conta Grok (em Perfil)… O pedido foi
guardado; você também pode escrever sua versão"). É a prova certa para o que o aparelho permite. Com IA
real, na corrida da frente Q, eu combinaria ver:

1. **`causaDaVersao` no cartão da versão** — a linha "A partir do resultado que você informou em <data>…"
   ao lado do produtor, e se ela cabe sem virar parágrafo (o motivo carrega o relato inteiro até o teto
   `Limite.motivoDoAjuste`);
2. **a saída do modelo para os três pedidos** lida contra a instrução: no fracasso, é mesmo um caminho
   diferente e diz o que mudou; no parcial, preserva o que funcionou; no sucesso, não declara aprendizado;
3. **o P2 ao vivo**: com dois resultados opostos em duas ações, o que o modelo faz quando a instrução diz
   "NÃO FUNCIONOU" e o contexto diz "Funcionou" na ação principal — é a medida de quanto o conserto de uma
   linha importa;
4. a chegada da versão nova com o relato ainda visível em "O que aconteceu", para a pessoa ligar causa e
   efeito na mesma tela.

## Limites do meu instrumento

- Sem árvore de AX: o helper do `orca emulator` não a entrega com o Traço aberto. Posições vieram da
  captura; a rolagem por `gesture` amplifica de 5 a 20× (arrastos de 0,015–0,03 de tela), como a V12 e a
  E1 registraram. Nenhuma medida de geometria neste relato — só leitura de conteúdo.
- O teclado do simulador está em modo de teclado físico: nenhuma captura mostra o teclado na tela; o
  comportamento da folha com o teclado aberto não foi julgado aqui.
- Dois toques em "Revisar" geraram dois pedidos falhos guardados no meu Trabalho; ficou assim.
- Não rodei a suíte: o revisor rodou 941/0 no candidato e este juízo é de tela, não de correção.
