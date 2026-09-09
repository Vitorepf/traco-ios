# G3 — revisão independente B1 (`ea48a8e`)

## Veredito: CORRIGIR ANTES

Há um achado P1: o novo portão da quinta não garante que **todo** argumento de
`ConferenciaTrabalho.regex(_:)` seja literal. O restante do mérito B1 foi
reproduzido e passa; isto não é acabamento, pois uma chamada futura com padrão
externo pode voltar a executar o `try! Regex` que encerra o processo.

## Achado

### [P1] `TracoTests/PortaoDoTryBangTests.swift:268` — a varredura perde argumento com chamada aninhada

O reconhecedor usa `regex\(([^()]*)\)`, portanto não enxerga uma chamada cujo
argumento tenha parênteses. No checkout descartável em
`/tmp/traco-b1-trybang-g3-bypass`, mantive as quatro chamadas que o teste espera
e acrescentei em `ConferenciaTrabalho.tempo`:

```swift
let padraoDeFora = blocosDeTempo
_ = regex(padraoDeFora.trimmingCharacters(in: .whitespaces))
```

`aConferenciaSoAceitaPadraoLiteralDoProprioArquivo()` passou (`0,003 s`), embora
o argumento não seja um dos `private static let` aceitos. A mesma forma com
`padraoDeFora` vindo de documento/pedido/IA pode carregar `[` e chegar ao
`try! Regex` de `Traco/Trabalho/ConferenciaTrabalho.swift:179`; logo o portão só
cobre chamadas planas, não todas as irmãs possíveis. A sonda teve dois vermelhos
independentes de caminho — os portões de movimento/try! tentaram ler
`privateAnalise/AnaliseDeBordo.swift`, arquivo ignorado ausente do checkout
temporário — mas o teste específico da quinta executou e passou; não é evidência
favorável ao candidato.

O plantio plano também foi reproduzido: trocar uma chamada por
`regex(padraoDeFora)` tornou o teste vermelho, com
`deFora → ["padraoDeFora"]`. Isso prova o caso documentado, não fecha o bypass.

## O que passou na revisão

- `Corpus:171` codifica apenas `String` de `[String: String]`, com o `!`
  precedido por `f.campos[$0] != nil`; `Sessao:615` codifica `[String]`.
  A prova B1 com NUL, controle, U+FFFF, emoji, U+2028/U+2029, aspas e barra
  passou no candidato, inclusive round-trip e mudança da assinatura.
- A sonda independente de Foundation com `Double.nan` confirmou exit `134` e
  `NSInvalidArgumentException` para `try!`, `try?` **e** `do/catch`.
  Portanto `isValidJSONObject` antes de `data(withJSONObject:)` é a correção
  material; substituir somente por `try?` seria teatro.
- Todas as entradas atuais dos dois `json(_ objeto: Any)` foram rastreadas:
  quatro em `RespostaNotas` (`[[String:String]]`, dicionários/arrays de
  `String`/`Int` e esquema) e três em `PraticaTrabalho` (linhas `[String]` e
  esquemas). Ambas as funções passam por `isValidJSONObject` antes da chamada.
- Candidato imutável: `xcodebuild test ... id=34CC3F94-FDB5-4575-A4F5-80271829A18B
  -parallel-testing-enabled NO` sob `ferramentas/orca/com-trava.sh`:
  `Test run with 996 tests in 161 suites passed` e `** TEST SUCCEEDED **`.
  A varredura reproduzível listou exatamente 6 `try!` de produção, e
  `nenhumTryBangNovoNaProducao()` passou.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 10 | remove morte evitável, preservando a recuperação honesta |
| Contrato | 8 | ADR 09o correto; portão da quinta é incompleto (P1) |
| Correção | 6 | JSON corrigido; invariante do `try! Regex` ainda bypassável |
| Jornada real | n/a | sem alteração de tela/navegação nesta volta |
| Design | n/a | sem superfície visual |
| Simplicidade | 9 | guardas locais; dívida de helper duplicado já nomeada no RUMO |
| Movimento | n/a | sem animação alterada |
| Componentes | n/a | sem componente alterado |
| Acessibilidade | n/a | sem superfície alterada; VoiceOver não foi acionado |
| Performance | n/a | sem lista/editor/parser em rota nova |
| Privacidade e autoria | 10 | somente serialização interna; proteções não tocadas |
| Estado honesto | 10 | a exceção de serialização deixou de depender de `try!`; rotas atuais seguem recusa existente |
| Complexidade | 9 | diff pequeno; parser textual do portão é a exceção que gera o P1 |
| Fora do app | n/a | sem superfície externa |
| Relato | 10 | ADR, EVOLUCAO, RUMO e evidência B1 presentes |

## Instrumento e limites

Usei somente o aparelho de trabalho `34CC3F94-FDB5-4575-A4F5-80271829A18B`,
ligado e desligado dentro de cada corrida sob a trava; `B91C8DEF` ficou apenas
ligado como aparelho da conta e não recebeu teste, instalação, limpeza ou toque.
Os dois checkouts temporários foram removidos após as sondas. Não há captura de
tela pertinente a esta mudança de motor; nenhuma função de voz, Siri, ditado ou
VoiceOver foi acionada.
