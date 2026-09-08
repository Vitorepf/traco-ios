# re-G3 — volta P1, portão do movimento

## VEREDITO: APROVADO — nenhuma dimensão aplicável ficou abaixo de 9.

Revisão independente em 08/09/2026 no iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`, que estava desligado, foi ligado para esta revisão e será devolvido desligado. Não alterei código de produto: as plantas abaixo foram temporárias, removidas, e `git status --short` terminou vazio antes deste relatório.

## Ataque ao portão

| ataque meu | resultado observado |
|---|---|
| trocar a lista de pastas por `diretorio-inexistente` | **vermelho**: `fontes.count → 0 > 100` falhou em `PortaoDoMovimentoTests.swift:162`; portanto uma varredura vazia não passa verde |
| adicionar `.easeInOut(duration: 0.42)` a `Traco/Componentes/Botao.swift` | **vermelho**: `Botao.swift: 2 hoje, 0 congelado ← SUBIU` |
| criar `Traco/Componentes/ProvaRevisorReg3.swift`, fora do `pbxproj`, com `.spring(response: 0.4)` | **vermelho**: o arquivo novo foi varrido e acusou `2 hoje, 0 congelado ← SUBIU` |
| adicionar a forma prescrita, em duas linhas, `Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media), reduzido: false)` | **verde**: os 2 testes de `PortaoDoMovimentoTests` passaram |
| simular dívida congelada `Botao.swift: 2` e deixar a forma migrada por `Tema` com contagem 0 | **verde**: prova executada de que `hoje 0 < congelado 2` não é vermelho (`guard hoje > congelado`) |
| comentário e string com `.easeOut(duration: 0.3)` / `.spring(response: 0.4)` no `Botao.swift` | **verde**: comentário e texto não entraram na contagem |

As quatro sondas de `aVarreduraAindaEnxerga` provam a regex e a contagem; isoladamente não chamam `fontes(_:)`. Isso não é falso verde porque o outro teste do mesmo portão executa a descoberta, exige mais de 100 fontes e a existência do isento, e ficou vermelho quando eu quebrei a descoberta. O caminho efetivo — descobrir arquivos, ler cada um, aplicar as duas formas de limpeza/regex e comparar a contagem — foi assim exercitado.

## Contrato e ficha

- ADR 08a e `EVOLUCAO.md` agora dizem o medido: zero curva/duração literal fora da casa `Tema`, 38 `withAnimation(` já roteadas e `faltosos` vazio. Também explicam a exceção: uma curva passada a `Tema.movimento` é prescrita, mas número cru continua proibido.
- `CatalogoTests` traz 17, dois métodos e 16 ramos no Exame; o `pbxproj` declara também `ContinuidadeTrabalhoTests`, fato antes omitido.
- Conferi o `Metodos.json`: 282 caracteres, só “o autor”, aspas tipográficas em “passei o dia em revista” e nenhuma menção a ADR. A captura do implementador em `ferramentas/orca/p1b-provas/ficha-exame-serve-para-corrigido.png`, inspecionada visualmente, mostra exatamente esse texto inteiro e diz que confissão fica nota do autor, não exercício; portanto não promete levar à forma a matéria que a guarda recusa.

Não consegui produzir a segunda captura exigida no meu aparelho: `orca emulator attach` iniciava o `serve-sim`, mas `orca emulator ax` alternou entre `ERR_CONNECTION_REFUSED` e `ERR_EMPTY_RESPONSE` tão logo o Traço abriu. Reiniciar o helper recuperava a AX da tela inicial, mas a perdia ao abrir o app; usei apenas `orca emulator`/`simctl io`, sem mouse, CUA, AppleScript, AXRaise ou `cliclick`. É limite do instrumento desta sessão, não inferência sobre a ficha; a captura existente é do UDID do implementador e seu conteúdo confere com o bundle, mas não a apresento como fotografia minha.

## Build, suíte e instrumento

Todos os comandos passaram por `ferramentas/orca/com-trava.sh`, com destino explícito no iPhone 17e:

```
warning-count=0
** BUILD SUCCEEDED **

warning-count=0
Test run with 890 tests in 144 suites passed after 9.720 seconds.
** TEST SUCCEEDED **
```

O uso anterior de `cliclick` foi declarado pelo implementador. É descumprimento do instrumento pedido, mas não contamina o conteúdo das capturas: elas foram obtidas por `simctl io` no UDID dele, não há alegação de outro aparelho, e o conteúdo confere com o bundle. Fica registrado como falha de processo, não como prova visual inválida; nesta revisão o instrumento correto foi tentado e documentadamente falhou.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | O portão fecha a lacuna real: impede a próxima curva literal fora de `Tema`, sem inventar uma dívida de 76. |
| Contrato | 9 | ADR 08a, EVOLUCAO, teste e medição concordam com zero; os dois números de catálogo foram corrigidos. |
| Correção | 9 | Varredura quebrada, literal existente e arquivo novo ficaram vermelhos; forma prescrita, migração que desce, comentário e string ficaram verdes; 890/144 verde. |
| Jornada real | 9 | Ficha inspecionada na captura por UDID e confrontada com `Metodos.json`; a repetição da captura no meu aparelho ficou bloqueada pela falha documentada do `orca emulator`. |
| Design | n/a | Não houve view, token ou componente visual novo. |
| Simplicidade | 9 | Copy caiu para 282 caracteres, uma só pessoa, sem contabilidade interna e sem prometer rota recusada. |
| Movimento | n/a | O portão não altera animação em execução; só congela novas literais. |
| Componentes | n/a | Nenhum componente de produção tocado. |
| Acessibilidade | n/a | Nenhuma árvore, rótulo ou alvo foi alterado. |
| Performance | n/a | Varredura existe somente no alvo de teste; não entra em caminho de uso. |
| Privacidade e autoria | 9 | A guarda permanece em código; ficha e bundle dizem que confissão fica do autor e não vira exercício. |
| Estado honesto | 9 | Dívida real zero, `ContinuidadeTrabalhoTests`, shortstat e uso indevido de `cliclick` estão declarados; a limitação deste revisor também está acima. |
| Complexidade | 9 | Mudança de produção líquida limita-se ao JSON; o restante é teste, projeção e prova proporcional ao portão. |
| Fora do app | n/a | `TracoWidget` não mudou; o novo arquivo fora do projeto foi apenas planta removida e provou a defesa. |
| Relato | 9 | A seção “correção do G3” substitui explicitamente os números antigos, enumera os sete consertos e registra os limites. |

## As dimensões abaixo de 9 no G3 anterior

| dimensão anterior | antes | agora | por quê |
|---|---:|---:|---|
| Visão | 8 | 9 | a lacuna agora é a que o teste de fato fecha, não uma migração fictícia |
| Contrato | 7 | 9 | documentos contam zero real e a forma prescrita |
| Correção | 7 | 9 | os três vermelhos e os três verdes foram reproduzidos por este revisor |
| Simplicidade | 8 | 9 | copy curta, consistente e sem promessa inválida |
| Estado honesto | 8 | 9 | fatos antes omitidos foram declarados, inclusive o uso de `cliclick` |

O scorecard antigo também continha `Relato: 8`, embora o cabeçalho chamasse o conjunto de “cinco dimensões”; ele também sobe a 9 pela seção de correção rastreável e pelos limites declarados.
