# G3 independente — C1, caret do Caderno no iPhone 17e

**Veredito: CORRIGIR ANTES.** O conserto fecha o vermelho estável no aparelho
onde ele morava, mas não fecha a invariante que a ADR 08f ainda escreve como
"em cada quadro apresentado": `c1-04-residuo-gaveta-cartao.png` mostra a linha
ativa cortada pelo cartão durante a própria gaveta. A volta declara o fato —
isso é honesto —, mas declará-lo como resíduo não torna compatível mesclar uma
violação conhecida de 0,11 s com a regra sem exceção. A duração de 0,11 s
também não é verificável: há uma captura e a alegação de 220 screenshots, mas
não há timestamps, sequência ou vídeo versionado que meça o intervalo.

## O que repeti (trava segura; iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`)

Usei só este simulador, ligado por mim, sempre com `ferramentas/orca/com-trava.sh`;
sem maestro, `orca emulator`, voz, VoiceOver, ditado, Siri, iPad ou mouse. O pai
`4681615` foi montado em worktree temporário isolado, portanto o checkout
principal não foi lido nem alterado como fonte de build.

```
PAI 4681615, -only-testing:TracoTests/EscritaVisivelTests
ESCRITA AX5: 31 amostras, 13 com a linha do caret na área livre do papel
... UICTContentSizeCategoryAccessibilityXXXL ... 18 issues
✘ Test run with 1 test in 1 suite failed after 24.759 seconds with 18 issues.

CANDIDATO 51eade6, mesmo alvo e UDID
ESCRITA AX5: 31 amostras, 31 com a linha do caret na área livre do papel; teclado real 308 pt
ESCRITA large: 44 amostras, 44 com a linha do caret na área livre do papel; teclado real 308 pt
✔ Test run with 1 test in 1 suite passed after 24.614 seconds.

CANDIDATO, integral, -parallel-testing-enabled NO
✔ Test run with 949 tests in 153 suites passed after 56.107 seconds.
grep -c warning: 0
```

Não houve caso de runner travado antes de conectar (`0 de N`): as duas corridas
do alvo iniciaram e terminaram com resultado. A corrida integral deixou AX5
emulado pela área segura (318 pt), portanto a prova principal é a corrida
isolada anterior, que teve teclado de software real de 308 pt. `TemaTests`
também passou 14/14, inclusive `oPapelTemPiso`; o `CadernoHitchesTests`, ligado
explicitamente, passou e mediu 0 quadros perdidos na rolagem (a digitação teve
4 quadros/29,4 s, maior 61,3 ms, fora de mudança de inset).

## Causa e implementação

As duas mudanças estão no ponto comum correto, e todos os três chamadores de
`seguirCaret` em `CadernoView` passam por ele. A aritmética também reproduz a
causa: com sobra 139,00, a regra anterior reservava 69,50 de papel; com sobra
87,00, 43,50; ambos menores que a linha medida de 67. A nova função reserva
`min(max(min(piso, sobra/2), piso/3), sobra)`: para os números do 17e dá 86,44
e 87,00 de papel, respectivamente. É uma correção de causa, não uma guarda no
teste.

Contudo, `piso/3` só é "uma linha" por comentário e pela convenção de que o
`@ScaledMetric` de 92 representa três linhas. A prova nova só cobra
`papel17 > 67`; ela não mede `piso/3` contra a linha real do TextKit em cada
tamanho. Assim, o número é plausível e fecha AX5, mas a universalidade
anunciada (qualquer aparelho/tamanho) ainda não está demonstrada.

`linhaDoCaret` usa o fragmento TextKit 2 e escolhe o `textLineFragment` cujo
`characterRange` contém o offset; por isso a quebra suave por palavra é medida
como linha visual, não como parágrafo. O último fragmento cobre o offset em
`NSMaxRange`, logo o fim de texto é tratado quando há fragmento. Documento
vazio, linha vazia após `\n` e seleção exatamente nos dois lados de uma quebra
não têm caso de teste: nos `guard` sem fragmento o comportamento cai de volta
para `caretRect`. O teste hospedado exerce wraps e inserção no meio/fim, mas
não essas três bordas. Isso é prova faltante, não defeito que eu possa afirmar
ter reproduzido.

## Capturas e limites

Conferi as sete PNGs em `ferramentas/orca/c1/`. `c1-02`, `c1-03` e `c1-05`
mostram a linha e caret visíveis no papel; `c1-04` confirma o recorte transitório;
`c1-06` bate visualmente com a árvore de AX nas etiquetas e geometria expostas;
`c1-07` e minha captura `/private/tmp/c1-caret-revisor-medium.png` confirmam a
restauração em medium. A varredura `simctl` enquanto o teste hospedado digita
na Página real sustenta que os quadros são da rota real e sustenta a existência
do resíduo, mas não sustenta sozinha contagem de 220 nem duração de 0,11 s.

Não rodei no Pro Max: o preâmbulo manda usar só o 17e e proíbe expressamente
`6033B043`. O `large` verde no 17e é regressão parcial, não prova do Pro Max;
a compatibilidade naquele aparelho permanece não avaliada.

O relato chama o tamanho de **AX XXXL** e o teste mostra o raw value
`UICTContentSizeCategoryAccessibilityXXXL`; **as 18 são AX5**, não uma outra
categoria. O rótulo do assunto do worker que dizia AX XXXL é compatível com
isso; a discrepância aparente é terminológica, não uma troca de tamanho.

## Dívidas declaradas

- **Gaveta (~0,11 s): rejeito como dívida para esta mescla.** É uma exceção
  conhecida à invariante temporal que C1 afirma reparar, na superfície que C1
  exercita. Corrigir a sincronização ou mudar explicitamente o contrato e sua
  prova é pré-requisito.
- **Barra de baixo (275/414): aceito como escopo separado, mas não como RUMO
  já registrado.** É a causa estrutural restante e a decisão de sacrificar o
  cartão ao texto é coerente. Porém `ferramentas/orca/RUMO.md` atual só lista o
  achado C1 em linhas 190–193 e não contém esta dívida nem a da gaveta; a ADR
  08w diz que ambas vão ao RUMO. Atualizar RUMO é requisito de contrato/estado
  honesto antes do G5.

## Scorecard

| dimensão | nota | evidência e limite |
|---|---:|---|
| Visão | 10 | Remove escrita às cegas no ciclo de multiplicar a mente. |
| Contrato | 7 | 08f diz cada quadro; `c1-04` é exceção conhecida; ADR 08w promete RUMO ainda ausente. |
| Correção | 8 | 18 AX5 no pai para 0 no candidato e 949/153 verde; falta Pro Max e há recorte transitório. |
| Jornada real | 9 | Página real, teclado real na corrida isolada e capturas conferidas; duração do resíduo não demonstrada. |
| Design | n/a | Não há novo sistema visual, token ou fluxo a julgar. |
| Simplicidade | 9 | Duas funções compartilhadas, sem nova dependência ou gesto. |
| Movimento | 7 | A gaveta tem quadro(s) de linha cortada; não há exceção válida à invariante temporal. |
| Componentes | n/a | Nenhum componente criado ou alterado. |
| Acessibilidade | 9 | AX5 31/31, captura e árvore conferidas; VoiceOver falado corretamente não exercitado. |
| Performance | 9 | `CadernoHitchesTests` pós-diff passou; rolagem 0 quadros perdidos. |
| Privacidade e autoria | n/a | Diff não toca conteúdo, origem, acesso ou envio. |
| Estado honesto | 7 | Resíduo é declarado, mas a transferência prometida ao RUMO não existe. |
| Complexidade | 9 | +uma função e nenhuma abstração/dependência; diff centrado na causa. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 8 | Boa separação de observado/limite; confunde AX5/AX XXXL na redação e não prova 0,11 s/220 quadros. |

Nenhuma dimensão abaixo de 9 pode seguir ao G5. Para re-G3: eliminar ou
contratualizar a exceção da gaveta, registrar as duas dívidas no RUMO, provar
o Pro Max sem violar sua reserva, e cobrir TextKit 2 para vazio, `\n`, wrap e
fim do documento com a linha visual real.
