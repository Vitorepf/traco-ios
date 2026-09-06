# V10 — correção do G4 (queima da expressiva sob Reduzir Movimento)

Fable front, 06/09/2026, branch `Vitorepf/volta-10-fundacao` sobre 71db7b1. Simulador iPhone 17 Pro C2416CBC (ligado por mim, RM restaurado a 0, desligado ao fim). Sem maestro; dirigido por cliclick.

## O que mudou

- `Traco/Confirmacao/FechoExpressivaView.swift:134,137`: as duas chamadas da cena passam de `Tema.movimento(.deslocamento, …)` para `Tema.movimento(.opacidade, …)`. A frente de fogo é máscara que revela (`Queima.swift`), não camada que desliza.
- ADR 05v (`SPEC.md`): o "Δ (1)" do custo assumido deixa de descrever um fade de 0,15 s + 3,15 s parado e passa a registrar a decisão e o que o vídeo mostra; ganha a linha sobre os três estados só exercidos por previews (`Cartao.flutuante`, `.tingido`, `LinhaDeEstado.lendo`: V15 e V13, com dona); Prova cita a árvore final 713/125.
- `EVOLUCAO.md`: 650/123 → 713/125 na árvore final, com a nota do G4.

## O que o vídeo mostra (e o G4 e a ADR não tinham visto)

`queimar()` tem, desde main, `guard !reduceMotion else { sessao.queimar(…); return }` (linha 126): sob Reduzir Movimento a cena nem começa e a lei de classe nunca é consultada. O "wipe de 0,15 s seguido de 3,15 s de tela parada" era leitura de código, não comportamento. Com a classe corrigida, nada muda em nenhum dos modos:

- `v10-g4fix-rm-queima.mp4` (7 s, esquerda RM ligado, direita sem RM, a partir de 1 s antes do toque em Queimar): à esquerda o fecho cruza em fade para a lista das Notas com "Expressiva — queimada" em ~0,7 s, sem fogo, sem wipe, sem espera; à direita o fogo sobe a folha em 3 s e depois a página amanhece.
- `v10-g4fix-rm-queima-quadros.png`: linha 1 RM a 10 quadros/s desde o toque (7 quadros de crossfade, depois a lista parada); linha 2 sem RM a 2 quadros/s (escurece, o fogo sobe por 6 quadros = 3 s, amanhece).

## Prova de instrumento

- Build (`com-trava.sh xcodebuild … build`, 17 Pro): `** BUILD SUCCEEDED **`, `grep -c warning:` = 0.
- `TemaTests`: `✔ Test run with 8 tests in 1 suite passed after 0.055 seconds.`
- Suíte integral: `✔ Test run with 713 tests in 125 suites passed after 8.392 seconds.` / `** TEST SUCCEEDED **`.

## Fora do escopo, visto de passagem

Na segunda passada (sem RM) o alerta de notificações do sistema reapareceu sobre a lista das Notas depois da queima (meu toque em "Permitir" no primeiro segundo não pegou); é do instrumento, não da cena.
