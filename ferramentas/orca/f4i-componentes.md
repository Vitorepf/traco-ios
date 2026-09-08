# F4-I — as duas linhas de Componentes, o critério medível, e o merge que destrava o G5

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f5-fora-do-app`, sobre `d1d7301`, mesclada com `main` (`7499e80` e depois `53cc724`). **Aparelho:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, ligado por mim às 14:11 e devolvido desligado às 14:33. Casa intocada (não plantei nem semeei; a Live Activity que o juiz deixou viva seguia na Ilha).
**Skills:** `design-router` não foi carregada: a volta não desenha nem toca a face (ordem do orquestrador — Design, Simplicidade, Movimento e Fora do app estão em 9 e não se mexe no que passou). Nenhuma cor, fonte, espaço ou movimento foi decidido; os previews reusam os tokens que as faces já vestem. Fases: Ancorar (re-G4 e ADR 08i), Sistema (`Tema`, sem token novo), Portão (abaixo). Construir/Mover/Julgar não se aplicam — não há superfície nova.
**Instrumento:** todo `xcodebuild` e `xcodebuild test` por `ferramentas/orca/com-trava.sh` — segurei a trava em cada um. Nenhum `orca emulator`, nenhum maestro, nenhum toque no mouse do dono. Uma captura `simctl io <UDID>` só para diagnosticar o runner (não é prova de nada).

## O que fiz, ponto a ponto

| ponto | escolha | onde |
|---|---|---|
| 1 preview por estado | `FraseDoAutor`: inteira/trecho/desconhecida; a face cortando em corpo cheio (~100 chars em 123×138); com "Desatualizado."; AX5; tela bloqueada (`acessorio`, feito e não). `CapsulaViva`: casa (papel, `ambarTinta`), bloqueada e Ilha (material, `ambar`, `compacta`); AX5. O trecho do preview sai do MESMO `Superficie.Destaque.trecho()` do publicador. | `TracoWidget/TracoWidget.swift`, fim do arquivo (`Amostra` ganhou `longa`, `paragrafo`, `inteira`, `trecho`, `desconhecida`) |
| 1 mover para `Traco/Componentes`? | **Não movi.** O alvo `TracoWidget` compila só `TracoWidget/`, `Traco/Tema.swift` e `Traco/App/Intents/Compartilhado` (`project.yml`, ADR 05u); nada no app usa as duas (`grep` acha só o arquivo do widget). Mover exigiria pôr um arquivo de `Traco/Componentes/` nas fontes da extensão — abrir à extensão uma pasta que é do app — e o compilaria no app para ninguém. A casa de um componente é onde ele é usado. Dito na ADR. | ADR 08i, emenda |
| 2 duas gramáticas | **(b) descrever as duas na ADR, com honestidade.** O publicador corta em palavra porque corta antes de qualquer layout, uma vez, para três larguras — sem linha, a palavra é a única fronteira honesta. A face corta em grafema porque o `lineLimit(n)` do SwiftUI conhece a linha real. Unificar seria medir texto por fora do layout e devolver ao SwiftUI um texto já cortado — reproduzir o motor de texto e errar onde ele acerta (hífen, tightening, categoria). A regra pede omissão reconhecível, não fronteira de palavra. | ADR 08i, emenda |
| 3 critério medível | Escrito com as palavras pedidas: **"corte é evitável quando cabe uma linha inteira do corpo do papel no espaço livre ao lado do marcador"**. Testável na suíte? A suíte não renderiza layout; o que ela garante é a PREMISSA que faz o `ViewThatFits` cumprir o critério — os candidatos de `Sacrificio` descem de um em um, sem lacuna, e o primeiro que cabe é o maior que cabe (se n + 1 não coube, sobra menos de uma linha). Teste novo `SacrificioTests.semLacunaEntreCandidatos`. A medida em pontos continua sendo da captura, como o juiz fez. | ADR 08i; `TracoTests/LinhaDoTempoWidgetTests.swift` |
| 4 merge | `main` trazido duas vezes. Conflito só em `SPEC.md`, e só de lugar: HEAD com 08g+08i e `main` com 08h no mesmo ponto — resolvido com as três em ordem cronológica **08g (5581), 08h (5603), 08i (5716)**, nada perdido de nenhum lado (`git diff main -- SPEC.md EVOLUCAO.md` = só as minhas adições). Segunda mescla (3 commits de documentos em `ferramentas/orca/`) sem conflito. `git log HEAD..main` = **0**. | commits de merge |
| 5 prova | abaixo | teste 4 |

## Provas de máquina (todas por `com-trava.sh`, `-destination id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`)

Árvore provada: a mescla com `7499e80` mais o meu diff. Os 3 commits que `main` ganhou depois (`c164f07`, `83ca4d5`, `53cc724`) tocam só `ferramentas/orca/*.md` — nenhum Swift, nenhum `project.yml` — e entraram sem conflito; não reprovei a árvore por causa deles e digo isso aqui.

- **Build dos dois alvos:** `xcodebuild build -scheme Traco` → `** BUILD SUCCEEDED **`, `grep -c "warning:"` = **0**; no log `CodeSign …/Traco.app` e `CodeSign …/TracoWidget.appex` (o alvo do widget compila os previews novos).
- **Suíte integral:** `✔ Test run with 910 tests in 148 suites passed after 9.967 seconds.` / `** TEST SUCCEEDED **` (main passava 894; a F4-H trouxe 15 e esta volta 1). O teste novo no log: `✔ Test "o critério medível: os candidatos descem de um em um, sem lacuna" passed after 0.001 seconds.`
- **Portão do movimento, sozinho:** `✔ Suite PortaoDoMovimentoTests passed after 0.999 seconds.` / `✔ Test run with 2 tests in 1 suite passed` — a lista congelada segue vazia; o diff em `TracoWidget/` não escreve curva nem duração.

## Instrumento — o que aprendi (para a ESTEIRA, se o orquestrador quiser)

`xcodebuild test` pendurou **duas vezes seguidas** (372 s cada) em *"The test runner hung before establishing connection"* com quatro simuladores ligados na máquina (load ~5); o app arrancava normal à mão no mesmo aparelho. **`-parallel-testing-enabled NO` resolveu de primeira** (portão em 1 s, suíte em 10 s): o modo paralelo clona o simulador, e a clonagem é o que pendura sob carga. Guardei na memória.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Contrato | 9 | emenda na 08i com as palavras pedidas; as duas gramáticas ditas e defendidas; EVOLUCAO |
| Correção | 9 | 910 verdes; portão verde; teste do critério |
| Componentes | 9 | preview por estado dos dois; trecho do preview vem do publicador; a casa deles justificada |
| Design / Simplicidade / Movimento / Fora do app | — | não tocados, por ordem: seguem os 9 do re-G4 |
| Complexidade | 9 | +135 linhas, das quais previews, um teste e prosa de ADR; zero lógica nova |
| Estado honesto | 9 | a árvore provada e os 3 commits de documentos depois dela, ditos; o runner pendurado, dito |
| Relato | 9 | este arquivo |

## O que fica

As lacunas do aparelho real (StandBy noturno, Ilha mínima, VoiceOver ouvido, Ilha compacta com duas atividades em AX5 e o "t" cortado) seguem no RUMO, como mandado. O rodapé "Desatualizado." crescendo 1,2× contra 1,33× da frase em AX5 (re-G4, 2.2) está fora deste diff e a própria ADR já diz o remédio.
