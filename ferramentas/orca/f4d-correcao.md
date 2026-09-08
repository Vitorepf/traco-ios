# F4-D — a última milha do re-G3: o corte em AX5 (ADR 2026-09-06d)

Implementador: Claude Opus 5, 06/09/2026, ~20h–21h. Worktree `f4-widgets`
sobre `af10375`. Simulador de teste: **iPhone 17 Pro (teste 3)**
`34CC3F94-FDB5-4575-A4F5-80271829A18B` — ligado, usado e desligado por mim.
Havia seis simuladores de outros ligados a sessão inteira: **todo `maestro`
por `--device 34CC3F94…`**, nenhum toque por coordenada fora dele, e nenhuma
prova saiu da hierarquia do maestro — prova de tela é
`xcrun simctl io … screenshot`. Todo `xcodebuild` e todo `maestro` por
`ferramentas/orca/com-trava.sh`. O iPhone 17 `1A46B6D3` do dono **não foi
ligado**.

## O que o revisor recusou, e o que era de verdade

O revisor apontou três coisas (N1, N2, N3) e disse que o conserto era de duas
propriedades. **Duas eram; a terceira não.**

### N1 — a frase do Destaque terminava em reticências. Era propriedade. **Fechada.**

`linhaDoDestaque` usava `minimumScaleFactor(0.85)`, e 85% não chega em 155 pt
no AX5: saía `Terminar / o / capítul…`. `Velho()`, três linhas ao lado, já usa
**0,6** exatamente para encolher inteiro em vez de cortar. Alinhei as duas e
acrescentei `allowsTightening`. Agora sai `Terminar / o capítulo / do meio`,
inteira.

### N3 — o mesmo corte no ramo "o vazio traz o Destaque". Mesma propriedade. **Fechada.**

A frase do Destaque é desenhada em DOIS lugares: `linhaDoDestaque` (widget do
Traço) e o ramo `vazio` do widget do Próximo, que a F4 criou. O segundo cortava
em AX5 **com a superfície fresca**, sem rodapé nenhum na face — o revisor tem
razão: aquele corte não era do rodapé, e eu tinha atribuído a ele. Mesmos 0,85,
mesma correção.

### N2 — a palavra do estado quebrava com hífen. **Não era propriedade: era o teto de linhas.**

Aqui o conserto que o revisor sugeriu **não bastou, e eu vi na tela.** Pus
`allowsTightening` + `minimumScaleFactor(0.6)` no `Text(estado)` da `Oferta`,
reconstruí, plantei e fotografei: continuava `Desatualiza-/do.`
(`f4d-ax5-hifen-persiste.png`, 20:34).

A causa é mais funda. Com `lineLimit(3)` o SwiftUI **prefere hifenizar a
encolher**: como cabe em três linhas partindo a palavra, ele parte e nunca
chega a usar o `minimumScaleFactor`. É por isso que `Velho()` sempre acertou —
ele tem `lineLimit(1)`, não tem para onde quebrar, e aí encolhe.

Conserto: o teto de linhas do estado sai da view e vira lei com suíte, como a
R1 virou `EstadoNaFace`:

```swift
// TracoWidget/Relogio.swift
nonisolated enum LinhasDoEstado {
    static func de(_ frase: String, teto: Int = 3) -> Int {
        frase.contains(" ") ? teto : 1
    }
}
```

**Palavra sem espaço não tem quebra honesta** — uma linha, e encolhe inteira.
Frase com espaço quebra a linha e sai no corpo cheio, que é o que a A3 exigiu
("quebra a LINHA, nunca a palavra"). Três testes em `LinhasDoEstadoTests`
travam os quatro estados que a face escreve hoje. Um teto decidido na view não
tem suíte, e foi um corte de view que derrubou esta volta duas vezes.

## O custo declarado, agora inteiro

A F4-C escreveu que a frase "cede uma linha". **Na tela ela terminava em
reticências**, e a palavra do estado partia ao meio sem que eu declarasse.
Corrigido no SPEC (ADR 06d, item 10 e "Custo assumido"). O custo inteiro, hoje
e medido:

> Em AX5, no pequeno, com Destaque longo e horizonte vencido, a frase do
> Destaque tem **três linhas em vez de quatro e encolhe até 60%** para caber
> nelas. Não há reticências em lugar nenhum, nem hífen no meio de palavra, em
> nenhuma das quatro famílias, em nenhum dos dois temas.

A troca que o revisor julgou certa (o estado ganha do comprimento da frase)
continua de pé — e o custo dela deixou de ser pago.

## Prova, na tela

Cenário: Destaque `Terminar o capítulo do meio`, três compromissos de um
minuto (`validoAte` = fim do terceiro), AX5
(`accessibility-extra-extra-extra-large`), **as quatro famílias plantadas na
casa** — inclusive o médio do Próximo, que a F4-C não conseguiu plantar
(a galeria do iOS 26 é um carrossel de quatro páginas; o "Adicionar Widget"
não aparece na hierarquia do maestro, mas responde a toque por ponto).

| arquivo | o que mostra |
|---|---|
| `f4d-ax5-claro.png` | 20:58, horizonte vencido às 20:57:44: as **quatro** famílias em AX5, tema claro. `Terminar / o capítulo / do meio` inteiro nos dois do Traço, `Desatualizado.` numa linha só nos dois do Próximo — sem reticências, sem hífen |
| `f4d-ax5-escuro.png` | 21:00, o mesmo estado em modo escuro de verdade (papel de parede e dock escuros, `appearance dark` + SpringBoard reiniciada) |
| `f4d-ax5-vazio-destaque-claro.png` | 21:02, superfície **fresca** e agenda vazia: o ramo "o vazio traz o Destaque" (N3) com a frase inteira nas duas famílias do Próximo |
| `f4d-ax5-vazio-destaque-escuro.png` | 21:01, o mesmo ramo no escuro |
| `f4d-ax5-hifen-persiste.png` | 20:34, **antes do conserto certo**: com as duas propriedades postas, `Desatualiza-/do.` continuava. É a prova de que o teto de linhas era a causa |

Antes, para comparar: `f4-reg3b-ax5-corte.png` e
`f4-reg3b-ax5-destaque-corta.png`, do revisor.

## Instrumento

- `xcodebuild build -scheme TracoWidget` e `-scheme Traco`: `** BUILD
  SUCCEEDED **`, **zero `warning:`** nos dois.
- `xcodebuild test -scheme Traco`: `Test run with 767 tests in 132 suites
  passed`, `** TEST SUCCEEDED **` (eram 764/131; +3 de `LinhasDoEstadoTests`).
- Semeadura: `calendario.json` no contêiner do app e as chaves do Destaque no
  plist do App Group, com **`cfprefsd` morto antes do lançamento** — é o que
  faz o app ler o disco em vez da cópia em memória (a lição que o revisor
  registrou; matar o daemon resolve sem reiniciar o simulador).
- Restaurei ao fim: `content_size medium`, `appearance light`, e desliguei o
  `34CC3F94`. Não desliguei simulador de ninguém.

## Skills

**`design-router`** (redesenho: começa auditando).
**Ancorar** — li a segunda seção "Re-G3" inteira e as três capturas antes de
tocar em Swift; o defeito é o mesmo `PRÓXI-/MO` do G0, na palavra que diz a
verdade. **Sistema** — nenhum token novo, `Tema.swift` intocado; a receita já
existia no arquivo (`Velho()`), e o trabalho foi alinhar três `Text` a ela.
**Construir** — três propriedades e uma função pura; nenhuma view nova.
**Mover** — nada: não há transição aqui e não inventei uma. **Julgar** — é a
fase que salvou esta volta: as duas propriedades que o revisor prescreveu
**não consertaram o N2**, e só a captura mostrou. Reconstruí, olhei de novo e
achei a causa real. **Portão** — os quatro estados exigidos estão fotografados
nos dois temas, na tela, no build de agora; o que não fotografei
(`accessoryRectangular`/`accessoryInline` na bloqueada trancada) está dito
como pendente de instrumento, F1 §7, e não foi tocado por esta volta.

**`curva-zero`.** *Jornada:* o autor olha a casa em tamanho grande e precisa
saber (a) qual é a única coisa de hoje e (b) se o que vê ainda vale.
*Resultado verificável:* as duas frases legíveis por inteiro, sem reticências
e sem palavra partida, nas quatro famílias e nos dois temas — está nas
capturas. *Atrito observado:* `Desatualiza-/do.` obriga a decifrar a palavra
que existe para dispensar decifração, e `capítul…` faz o autor abrir o app só
para ler a frase que o widget existe para mostrar. *Recuperação:* intacta —
`Abrir o Traço` continua na face do estado, e o alvo é o widget inteiro.

## O que deixo, com nome próprio

- **BAIXO, do revisor, não tocado:** o `accessoryInline` do widget do
  **Próximo** diz só `"Traço"` quando o instantâneo está velho, igual a quando
  não há nada marcado — o do Traço já diz `Traço · desatualizado`. É uma
  linha, mas muda uma família que **o simulador não renderiza** (F1 §7): eu
  entregaria um diff sem prova de tela na volta que existe para fechar a
  prova de tela. Fica para a volta do widget configurável, junto com as outras
  mudanças de acessório.
