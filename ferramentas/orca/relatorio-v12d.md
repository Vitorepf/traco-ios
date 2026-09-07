# V12-D — a correção do G4 da volta 12

Claude Opus 5, 06/09/2026. Worktree `volta-12-pagina`, topo `1ed1a73`
(merge de main `3f07a3d` antes de fechar). Simulador **iPhone 17 Pro
C2416CBC**, o meu — ligado por mim, `TRACO_SEM_MODELO=1`, Dynamic Type e
Reduzir Movimento restaurados (`large`, RM 0) e desligado no fim. O iPhone 17
`1A46B6D3` do dono não foi tocado; nenhum simulador alheio foi ligado ou
desligado. Todo `xcodebuild` e todo `maestro` sob `ferramentas/orca/com-trava.sh`,
com `--device` preso ao meu UDID; **toda prova de tela é `xcrun simctl io` presa
ao meu UDID** (screenshot ou quadros nativos extraídos por `ffmpeg`).

## Skills, e as seis fases

`design-router` carregada ANTES da primeira linha de SwiftUI, e `curva-zero`
porque a volta toca a jornada de escrever e a folha dos campos.

| fase | o que foi feito nesta volta |
|---|---|
| **Ancorar** | Contrato lido antes de tocar: AGENTS, VISAO-PRODUTO, SPEC §ADR 05y (inteira, com V12-B e V12-C) e o G4 inteiro. Pessoa e situação: o autor a escrever DEPRESSA uma ideia que não quer perder, iPhone, teclado de pé. Resultado observável: a linha que ele digita fica na tela. Restrição vigente: a régua e as ações não saem do lugar (ganho da volta, não se mexe) |
| **Sistema** | Nada de token novo: `Tema.margem/alvo/Duracao/Mola`, `.cartao(.flutuante)`, `corpoCartao`, `.rotulo`, `.discreto`, `BarraBotaoStyle`. O único material novo é uma chave de ambiente (`tetoDoEncaixe`) para o Caderno dizer ao cartão quanto sobra |
| **Construir** | Piso do papel em `CadernoView`; cartão recolhido em `CartaoAnaliseView`; a lei em `Tema.swift`. Duas decisões saíram do `body` para ter teste |
| **Mover** | Filmado nos dois modos, quadros nativos: a linha que abre, o toque em "Abrir os campos", a chegada do cartão e — noutra tela — as escalas do Calendário |
| **Julgar** | Travessia `curva-zero` abaixo; medi na tela o que o G4 mediu, no mesmo estado e com o mesmo método (base da topbar, topo do cartão, topo do teclado) |
| **Portão** | Suíte 760/0; o que ficou de fora está declarado, não escondido |

## A travessia da `curva-zero`

**Jornada:** o autor escreve depressa → a forma veste sozinha → ele CONTINUA a
escrever → abre os campos quando quiser.
**Resultado verificável:** a frase que ele digitou está na tela enquanto o cartão
está de pé, e a nota fica com o texto inteiro.
**Atrito observado (medido pelo G4, reproduzido por mim):** 33 pt de papel, a
frase fora da tela, 37 caracteres digitados às cegas.
**Recuperação:** "Deixar como nota" continua a um toque em todo tamanho — à vista
fora de AX, no menu da própria linha em AX; e o texto do autor nunca muda.

| estado | o que vi, no build que estou a entregar |
|---|---|
| escrevendo, forma vestida, `large` | papel **141 pt**, a frase inteira e o caret na tela (`v12d-large-vestida-teclado.png`) |
| o mesmo em **AX5** | uma linha de papel, cartão numa linha, "Mais ações da nota" INTEIRO acima do teclado, topbar fora da barra de estado (`v12d-ax5-vestida-teclado.png`) |
| as saídas em AX5 | menu da linha, "Abrir os campos" e "Deixar como nota" inteiros (`v12d-ax5-menu-do-cartao.png`) |
| falha (aviso) | **não recolhe**: cartão inteiro, com degradê a dizer que há mais texto (`v12d-aviso-nao-recolhe.png`) |
| movimento, sem RM | a linha abre e o cartão sai em UM quadro (`v12d-sem-rm-quadros.png`) |
| movimento, com RM | idem (`v12d-com-rm-quadros.png`, `v12d-com-rm.mp4`) |
| outra tela, com RM | Calendário Dia→Semana e Semana→Mês em UM quadro (`v12d-calendario-rm-corta.png`) |

## Os quatro itens da lista mínima

1. **Piso para o papel** — feito. `CadernoView.tetoDoEncaixe(altura:pe:piso:)`,
   testado (`oPapelTemPiso`). Medido no mesmo estado e método do G4 (captura
   `simctl` 1206×2622): base da topbar **94** (o mesmo ponto do G4), topo do
   cartão **235**, teclado em **540** → **papel 141 pt** contra 33, **encaixe
   305 pt = 35%** contra 413 = 47%. Aceite do G4 cumprido: repeti o cenário do
   dono e a frase "quero correr de manhã e nadar à noite quando der, sem falta"
   está na tela com o caret.
2. **AX5 não transborda** — feito, pelo mesmo mecanismo. Nada de caso especial:
   a pilha passou a caber.
3. **A quinta ocorrência** — a causa que o juiz nomeou está corrigida na LEI
   (`Tema.swift`), e o gatilho está limpo nos dois modos, em quadros nativos.
4. **O par antes/depois do estado que decide** — o "antes" com o teclado de pé
   são as capturas do próprio G4 (`g4-v12-cartao-come-o-papel.png` e
   `g4-v12-ax5-cartao.png`, agora versionadas); o "depois" são
   `v12d-large-vestida-teclado.png` e `v12d-ax5-vestida-teclado.png`, mesmo
   estado, mesmo simulador, mesmo método de medida.

## O que mudou em `Tema.swift` (arquivo do app inteiro)

- `movimento(_:_:reduzido:)`: sob reduzido devolve `normal` só para
  `.opacidade`; `.deslocamento`, `.escala` e `.laco` devolvem **nil**.
- `fadeReduzido` **apagado**. Não sobrou caso: quem quer fade declara
  `.opacidade`, que mantém a animação pedida.
- `animacao(_:reduzido:)` e `gaveta(reduzido:)` passam a devolver `Animation?`
  (eram `Animation`). `corte(_:reduzido:)` fica, agora como o mesmo corte com o
  nome à vista de quem move com o dedo ou o relógio.
- `CalendarioTema.morph` passa a `Animation?` pelo mesmo motivo.
- Chamadores: 12 de `.deslocamento`, 8 de `animacao`/`morph`, 4 de `gaveta` —
  todos em `withAnimation` ou `.animation(_:value:)`, que aceitam opcional.
- Testes: `movimentoReduzidoCorta`, `soAOpacidadeAnimaSobReduzido`,
  `deslocamentoCorta` e `gavetaECalendarioSeguemAMesmaLei` reescritos contra a
  lei nova.

## Limites honestos

- **Nota mais alta que o papel visível**: o autor continua a ver as PRIMEIRAS
  linhas enquanto escreve no fim. O `TextEditor` desta página não rola sozinho e
  quem rola é o `ScrollView` de fora, que não segue caret. Medi e filmei;
  tentei corrigir com teto no editor e com `ScrollViewReader` e as duas
  tentativas partiram o caso curto (o texto subia sozinho). A correção mexe na
  estrutura de `paginaUna` que a V12-C acabou de estabilizar — vai para o RUMO,
  declarada na ADR. **O caso do G4 (nota curta) está resolvido.**
- **Resíduo do `.sheet`**: ao abrir a folha dos campos, o rótulo "Todas" fica no
  lugar por alguns quadros enquanto o pé desce. É sobre o fundo da barra, nunca
  sobre texto, e é a fotografia que o `.sheet` tira da tela que apresenta.
- **VoiceOver e Instruments não foram medidos.** O AX5 aqui é geometria e
  leitura de tela.
- **A sábia não foi exercitada** (`TRACO_SEM_MODELO=1`): a decisão de a resposta
  dela nunca recolher está no código e no teste, não filmada.
- **`maestro/aceite.yaml` falha** no segundo trecho por causa do diálogo de
  permissão de notificações, que o `clearState` repõe a cada corrida e que
  engole o texto digitado. Não é desta volta: reproduzi o trecho à mão e o cartão
  de Aviso chega e não recolhe (`v12d-aviso-nao-recolhe.png`). Os flows ganharam
  uma guarda `runFlow when visible "Permitir"` no meu roteiro de teste; o
  `aceite.yaml` do repositório não foi mexido.

## Prova

`✔ Test run with 760 tests in 128 suites passed after 7.188 seconds.`
Build sem aviso novo. Swift do app **+261 líquidas** (+337 −76; 123 das linhas
somadas são comentário) — a volta inteira fecha em +323 e NÃO cumpre a regra de
shortstat líquido-negativo da 05v, pelo motivo declarado na ADR.
