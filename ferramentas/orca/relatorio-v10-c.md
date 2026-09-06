# V10-C — correção do G3 (ADR 2026-09-05v)

Fable C, 06/09/2026, branch `Vitorepf/volta-10-fundacao`, rebaseado sobre main 59e5833. Simulador: iPhone 17 Pro C2416CBC (ligado por mim, desligado ao fim; `large`, RM 0, intocados). Todo `xcodebuild test` por `com-trava.sh`. Sem maestro.

## O que saiu / o que ligou (zero pixel)

| achado | o que fiz |
|---|---|
| M1 `BotaoCompacto`/`.compacto` sem chamador, duplicando `CompactoStyle` | `CartaoAnaliseView` passa a citar `.compacto` nas seis chamadas; `CompactoStyle` apagado (o `makeBody` era byte a byte o mesmo: font, alvo, scale, opacity, animation na mesma ordem). Estilos no repositório: **sete** (três em Componentes + `PressaoClara`, `CartaoBotaoStyle`, `BarraBotaoStyle`, `AcaoTrabalhoStyle`); o doc de `Botao.swift` e a ADR dizem sete, não três. |
| M2 `Toast`/`.toast()` sem chamador | `Toast.swift` apagado (72 linhas) e tirado do pbxproj; ADR e relatório de B dizem "entra na V15 com o calendário". |
| M2 `LinhaQueAbre.abaixo` sem chamador | enum `Abre` removido; a linha abre só menu; doc diz "entra na V12 com as Versões". Preview "aberta" foi junto. |
| B1 `Tema.confirmacaoEntra` órfã | apagada (4 linhas). |
| M3 queima sob RM (3,0 s → fade 0,15 s + 3,15 s parado) e mola da célula nova (+0,25 s) | declarados no Custo assumido da ADR e na tabela do relatório de A. |
| M4 frases infladas | ADR: "três estilos" → sete no repositório; Prova em pixels reais (0 px onde foi 0; 235 px caret; 1 922 px = 0,07 %; 2 186 px = 0,08 %; 3,7 % pergunta da sábia; 218–636 px anti-aliasing; 1,2 %/5,1 % ordem de notas do mesmo segundo). EVOLUCAO 15 idem. Relatório de A: a frase "fica como ponte enquanto Toast o cita" corrigida (nunca citou). |
| Complexidade (decisão do orquestrador) | ADR ganhou o parágrafo "Complexidade, decisão do orquestrador": +679 como custo assumido, regra "cada volta por tela é líquido-negativa ao migrar para Componentes"; número pós-correção e rebase: **+570** (+1058 −488; Componentes +758, telas −188). V10-C sozinha: +27 −136. |
| B3 peso | `v10a-diff-ax5.png` 491 543 → 162 619 bytes; `v10a-diff-large.png` 401 763 → 119 263 (`sips -Z 1000`). Nenhum outro `v10*.png` acima de 400 000 bytes. |

Não tocados (fora da lista mínima, ficam nas voltas das telas): B2 (`.animation` antes de `scaleEffect` no `BotaoPrimario`, Recordar), B4 (filme da célula), B5 (`accessibilityIdentifier("")` do cabeçalho).

## Rebase

`merge-tree` contra 59e5833 antes: conflito em `SPEC.md` (ADR 05u × 05v no mesmo ponto), `EVOLUCAO.md` (linhas "Desenvolvimento de capacidades" e "Direção visual") e `project.pbxproj`; `Tema.swift` mesclou sozinho (`miudo`/`acaoViva` de F2 e os tokens de A convivem). Resolvi mantendo as duas versões: 05u e depois 05v; linha "Desenvolvimento" do main + linha "Direção visual" com o trecho da V10; pbxproj regenerado por `xcodegen` (o `project.yml` não conflitou). Depois do rebase: `merge-tree` **zero conflito**. Topo: A 0709f9f, B 1f0c8f3, C (hash no `worker_done`).

## Prova

- Suíte antes do rebase (só a correção): `✔ Test run with 650 tests in 123 suites passed after 8.477 seconds`.
- Suíte depois do rebase: `✔ Test run with 713 tests in 125 suites passed after 7.172 seconds` (main trouxe os testes de V6/F2).
- Avisos: só os pré-existentes (`EditorBlocoView.swift:272` Sendable; `ConferenciaTrabalhoTests.swift:381` var→let). Nenhum novo.
- App instalado e rodando no C2416CBC: `v10c-calendario-dia.png`. Não filmei nem refiz os pares de pixel: nenhuma edição muda modificador de view (o `.compacto` é o `CompactoStyle` idêntico; `LinhaQueAbre` na ficha só usa `.menu`; `Toast` e `confirmacaoEntra` não tinham chamador). O `traco://anotar?texto=` não plantou texto na página pela rota, então a captura do cartão da análise ficou de fora.
- Commitei também os arquivos do revisor (`revisao-v10-fundacao.md` e `v10-rev-*.png`, todos ≤ 352 KB), que a ADR passou a citar.
