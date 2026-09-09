# re-G3 independente — C1-B, a gaveta e a medida

**Veredito: CORRIGIR ANTES.** O defeito geométrico foi reproduzido no pai e
sumiu no candidato, nos dois tamanhos, mas a nova sonda ainda não mede toda a
invariante 08f em cada quadro: mede `E ⊆ P`, não `P ∩ O = ∅`. Além disso, o MP4
versionado e anunciado como a gaveta consertada contém 44,04 s da Tela Inicial,
sem o Traço; a sequência textual vermelha é utilizável, mas o vídeo é uma prova
falsa e não pode continuar a sustentar a ADR.

## Instrumento e limite de aparelho

Usei exclusivamente o iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`, em
retrato, sem alterar o tamanho de texto global. Toda corrida passou por
`ferramentas/orca/com-trava.sh`; não usei maestro, `orca emulator`, mouse,
Siri, ditado, VoiceOver, fala ou iPad. Não toquei em `C2416CBC` nem em
`6033B043`, que estava reservado à F5b; portanto a parte Pro Max abaixo é a
prova herdada e a aritmética executada no 17e, não uma nova observação minha.

O candidato terminou instalado no `C7341E64`. A captura posterior
`/tmp/c1-caret-revisor-pos-teste.png` só mostra a Tela Inicial depois do runner;
não a conto como prova da Página. `main` avançou a `0d09aa3` enquanto eu revia
(`git log HEAD..main` não vazio): este parecer é do `600608f`, não uma aprovação
de mescla atualizada.

## Vermelho repetido, depois verde no mesmo instrumento

Para não chamar o log versionado de reprodução, montei um checkout temporário
descartável do pai `4898703`, trouxe **somente** a sonda de teste de `600608f` e
rodei no mesmo 17e; o checkout foi removido ao fim. O produto do pai reproduziu
o vermelho que a C1-B diz ter encontrado:

```
PAI 4898703 + sonda 600608f, teclado de software real 308 pt
GAVETA AX5, cartão a chegar: 85 quadros em 1.42 s, 7 fora;
  +0.268 a +0.367 s = 0.116 s; pior corte 32 pt
GAVETA large, cartão a chegar: 86 quadros em 1.42 s, 6 fora;
  +0.283 a +0.367 s = 0.100 s; pior corte 13 pt
GAVETA AX5/large, aviso e toast: 0 fora
✘ Test aLinhaFicaNoPapelEmCadaQuadroDaGaveta ... failed after 27.089 s, 2 issues
✘ Test run with 2 tests in 1 suite failed after 51.302 s with 2 issues.

CANDIDATO 600608f, mesmo UDID, re-instalado depois do pai
GAVETA AX5: cartão 84; aviso 87; toast 87 quadros — 0 fora em todas
GAVETA large: cartão 86; aviso 87; toast 87 quadros — 0 fora em todas
ESCRITA AX5: 31/31; large: 44/44; teclado real 308 pt
✔ Test run with 2 tests in 1 suite passed after 51.166 seconds.
```

Os logs são `/tmp/c1-caret-qa-pai-vermelho.log` e
`/tmp/c1-caret-qa-candidato-pos-vermelho.log`. A variação AX5 de 6 no artefato
versionado para 7 nesta repetição é cadência/limite de frame, não uma
contradição: os dois têm o mesmo intervalo e o mesmo corte máximo. Isto prova
o vermelho e o verde da geometria, não pixels em cada quadro.

## O que a sonda mede — e o que ela não mede

`CADisplayLink` chama `linhaApresentada` e `areaApresentada` em cada frame;
ambas consultam `layer.presentation()` (ou a camada-modelo quando não há
animação). Ela traz instante, total, duração, mediana de cadência e custo da
leitura. Isso mede adequadamente a geometria apresentada do resíduo que existia:
o pai deu 7/6 quadros fora e o candidato 0/0, com 16,7 ms e 0,2–0,4 ms/quadro.

Mas `Quadro.cabe` é apenas `area.contains(linha)`. Ao contrário de `Medida`, a
sonda por quadro **não chama `intrusos(sobre:editor:)`** nem um oráculo de pixels.
Assim, uma camada à frente que pinte a mesma geometria do papel passa em todos
os frames. A 08f inclui expressamente a ausência de superfície sobre a escrita;
o próprio RUMO 195–230 reconhece essa dívida. Registrar a dívida é correto; usá-la
para chamar a invariante inteira de provada em cada quadro não é.

## Tempo, vídeo e RUMO

`c1/c1b-quadros-vermelho.txt` é sequência carimbada suficiente para a alegação
do vermelho: lista +0.268, +0.283, ... +0.350 e calcula 0.098/0.100 s para seis
frames no artefato. A minha repetição acima confirma o fenômeno. Portanto o
antigo "~0,11 s em 220 screenshots" deixou de ser a única medida.

O MP4 não é alternativo válido: `ffprobe` informa H.264, 262×568, 286 frames,
44.042723 s; amostras em 0,25, 10, 20, 30 e 40 s mostram a mesma Tela Inicial.
Ele deve ser removido ou regravado com a Página, a linha e a gaveta visíveis.
Enquanto estiver no commit e na ADR como `c1b-gaveta-consertada.mp4`, o relato
faz uma alegação visual que o arquivo não entrega.

As três dívidas prometidas entraram no RUMO (linhas 195–230): barra inferior em
AX, oráculo de pixels para composição nativa e o limite de um seguidor diante de
altura animada. Este ponto está fechado documentalmente.

## Pro Max e TextKit 2

`TemaTests` foi executada no 17e e passou:

```
PISO: 2687 combinações com folga sobrando (a 08w dá o mesmo que a 05y),
338 apertadas (a 08w dá mais papel)
✔ Test run with 15 tests in 1 suite passed after 0.090 seconds.
** TEST SUCCEEDED **
```

Isso sustenta a resposta de código à pergunta do Pro Max: quando meia sobra já
comporta uma linha, o teto devolve o mesmo papel; só o caso apertado recebe mais.
O log/cópia verde do Pro Max no commit permanece não reexecutado por mim, porque
o preâmbulo reserva `6033B043` à F5b. Não transformo essa prova herdada em
observação independente.

As bordas de `linhaDoCaret` foram exercitadas no candidato e passaram: documento
vazio, linha vazia depois de `\n`, quebra por palavra, fim do documento e todos
os 61 offsets de fronteira. Resultado observado:

```
LINHA: 61 offsets varridos, 0 em que a linha visual difere do caret;
menor linha 63 pt, maior 65 pt
✔ Test run with 7 tests in 2 suites passed after 51.171 seconds.
```

Isso fecha as quatro bordas pedidas para um `UITextView` TextKit 2. O limite
permanece bem nomeado: nesse editor nu a caixa do caret coincide com a linha;
a diferença que motivou a função é coberta pela jornada hospedada da Página.

## Scorecard

| dimensão | nota | evidência e remédio abaixo de 9 |
|---|---:|---|
| Visão | 10 | Protege a escrita ativa em vez de preservar uma gaveta. |
| Contrato | 8 | `E ⊆ P` passou por quadro, mas falta `P ∩ O = ∅`; adicionar intruso/oráculo por quadro. |
| Correção | 8 | Pai 7/6 fora → candidato 0/0, mas não há prova temporal de sobreposição visual. |
| Jornada real | 9 | Página hospedada e teclado de software real 308 pt nos dois tamanhos. |
| Design | n/a | Sem superfície ou componente novo. |
| Simplicidade | 9 | Duas mudanças localizadas e sem dependência nova. |
| Movimento | 9 | A gaveta corta com foco; o defeito temporal geométrico deixou de ocorrer. |
| Componentes | n/a | Sem componente alterado. |
| Acessibilidade | 9 | AX5, large e cinco bordas TextKit 2 verdes; VoiceOver falado corretamente não exercitado. |
| Performance | 9 | 16,7 ms e 0,2–0,4 ms/quadro na corrida observada. |
| Privacidade e autoria | n/a | Diff não toca conteúdo, origem, acesso ou envio. |
| Estado honesto | 7 | RUMO registra as dívidas, mas o MP4 afirma visualmente uma prova que não contém o app; regravar/remover. |
| Complexidade | 9 | Correção no fluxo compartilhado, sem abstração nova. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 7 | A sequência vermelha corrige a duração; o vídeo versionado contradiz o título e precisa ser corrigido. |

Há dimensões abaixo de 9; não segue ao G5. Para o próximo re-G3: (1) prova por
quadro também `O`, idealmente captura nativa/oráculo de pixels ou intruso
adversarial de camada; (2) substituir/remover o MP4 vazio e apontar ADR/relato
para a evidência verdadeira; (3) rebasear e reexecutar contra a ponta atual de
`main`; (4) quando a reserva liberar, repetir no Pro Max para tornar essa prova
independente.
