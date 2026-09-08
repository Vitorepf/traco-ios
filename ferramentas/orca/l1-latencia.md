# Volta L1 — a latência da descoberta

Ordem do dono de 06/09, seção A de `ferramentas/orca/IDEIAS.md`. Ciclo:
**MELHORAR** — lacuna "modelo revisável do autor" do EVOLUCAO. Contrato em
SPEC.md, **ADR 2026-09-06j**.

## 1. O que já estava gravado, medido ANTES de inventar campo

A ordem do dono foi literal e o resultado é **nenhum campo novo**.

| Já gravado | Onde | O que dá para dizer |
|---|---|---|
| `Hipotese.data` | `Trabalho.swift:170` | quando o autor afirmou |
| `Hipotese.avaliadaEm` | `Trabalho.swift:179` (ADR 05r) | quando soube — a latência inteira |
| `Hipotese.estado` | proposta/confirmada/contestada | avaliada sem `avaliadaEm` = descobriu, tempo desconhecido |
| `DocumentoTrabalho.encerrado` | | fechou com hipótese em pé = abandonou |
| Decisão, `criadaEm` | `Nota` | quando afirmou |
| Decisão, campo `espero` | `Metodos.json` | a hora de conferir, por `Gatilho` |
| Decisão, campo `aconteceu` | | descobriu (sim/não) |
| **`Versoes`** | `Modelo/Versoes.swift` | **QUANDO descobriu** |

O achado que dispensou o campo novo é o último. `editadaEm` seria a mentira
fácil: é a última edição de qualquer coisa e desliza a cada retoque. O
histórico de versões guarda o estado **anterior** carimbado com a hora da
gravação (`Sessao.swift:1014`), então a versão mais recente que ainda tinha
"o que aconteceu" vazio é a hora em que ele deixou de estar vazio.

**Motor sem superfície, confirmado por grep:** o único leitor de `avaliadaEm`
em todo o app era `TrabalhoView.avaliacao` (`TrabalhoView.swift:304`), que
imprime a data absoluta ao lado de UMA hipótese. Distância entre os dois
carimbos: nenhuma. Série: nenhuma.

**O que faltou (declarado, não preenchido):** decisão respondida sem histórico
(importada, ou 30 versões por cima) fica sem data da descoberta — e a tela diz
isso. Se um dia o custo de ler o histórico doer, aí sim nasce um campo: a data
gravada no instante em que "o que aconteceu" enche.

## 2. A série, não o número

Mês, o tempo do **meio** daquele mês (mediana, não média — uma hipótese
esquecida por um ano deslocaria a média inteira) e quantas descobertas houve.
Os **abertos aparecem ao lado dos fechados**: série só do que fechou é viés de
sobrevivência, que é justamente o que a conversa de origem veio combater.
"Mediana" fica no código; na tela é "a do meio".

## 3. Estado honesto — o contrato desta volta

Quatro estados distintos na tela, com essas palavras: **afirmado** (dito, ainda
não é hora), **devido** (a hora chegou e continua sem resposta), **descoberto**
(soube — com ou sem a data) e **abandonado** (fechou sem conferir). Nenhum é
falha. Hipótese nunca avaliada é informação. Abandonar é resultado.

Nada de placar: sem meta, sem sequência, sem XP, sem seta, sem verde e
vermelho. A barra do mês é a mesma tinta em todos os meses. **Nenhuma ação na
seção** — a cobrança de conferir já existe na lista de Notas
(`Volta.campoDevido`) e não foi duplicada: um botão "conferir agora" aqui
transformaria a medida em lista de tarefas e destruiria o que ela mede.

## 4. As seis fases do `design-router`

1. **Ancorar.** O autor no Perfil, entre ajustes; não veio buscar métrica. Tarefa:
   reconhecer quanto tempo levou entre afirmar e saber, e se a distância encurta.
   Restrição dura: não pode virar cobrança. Sistema existente é a âncora.
2. **Sistema.** Zero token novo. `Tema.label`/`chrome`/`miudo`/`.footnote`,
   `tinta`/`tintaSuave`/`tintaFraca`/`superficieBaixa`, `entreItens`, o `emCartao()`
   e o `rotulo()` que o Perfil já tem. `Tema.swift` não foi tocado (volta 12).
3. **Construir.** Rótulo, uma frase que explica e já responde à `curva-zero`
   ("não há nada a preencher aqui"), resumo, série por mês (linha + barra) e os
   registros. Cada linha é UM `Text` que quebra sozinho — nenhum `HStack` para
   estourar em AX5. A barra é `.accessibilityHidden` e cada linha é um elemento
   combinado.
4. **Mover.** Nenhum movimento. A leitura é estática; sob Reduzir Movimento nada
   muda porque não há nada a cortar.
5. **Julgar.** Capturas em large e AX5, com os quatro estados na mesma tela.
6. **Portão.** Fluxo `maestro/latencia.yaml` afirma os quatro estados, o "tempo
   desconhecido" e a ausência das palavras de placar; prova por
   `xcrun simctl io screenshot`, não pela captura do maestro.

## 5. `curva-zero`

- **Jornada:** abrir o Perfil → rolar até LATÊNCIA DA DESCOBERTA → ler. Fim.
  Nenhuma decisão, nenhum campo, nenhuma confirmação, nenhum passo que possa falhar.
- **Resultado verificável:** o autor lê o tempo do meio por mês e o estado de
  cada registro seu, e reconhece os registros pelo texto que ele mesmo escreveu.
- **Atrito observado:** o de hoje é total — o dado está gravado e não existe
  tela nenhuma (grep acima). O atrito que a volta poderia CRIAR é pedir um passo
  novo, e a resposta é que não pede: nasce inteiramente do que ele já escreve.
- **Recuperação:** vazio desenhado ("ainda não há série — ela nasce quando você
  propõe uma hipótese num Trabalho ou escreve uma Decisão com data de conferir"),
  que diz de onde a série viria em vez de culpar quem não tem dados.

## 6. Prova

- **`LatenciaTests`: 11 testes.** Suíte integral: `✔ Test run with 758 tests in
  129 suites passed after 7.505 seconds.` / `** TEST SUCCEEDED **`, iPhone 17
  Pro Max 6033B043 em 06/09/2026.
- **Capturas (`xcrun simctl io screenshot`, não a do maestro):**
  `l1-serie-large.png` e `l1-tempo-desconhecido-large.png` (large),
  `l1-serie-ax5.png` e `l1-tempo-desconhecido-ax5.png` (AX5). Os quatro estados
  cabem na mesma captura em large; em AX5 tudo quebra em linha e nada some.
- **A série capturada:** julho de 2026 · 21 dias · 3 descobertas; agosto · 4
  dias · 2; setembro · 49 dias · 2. Não é uma linha bonita de propósito — a
  distância encurtou e voltou a esticar, que é o que "encurtar ou não" quer
  dizer. Resumo: "7 descobertas com as duas datas · a do meio levou 9 dias · 1
  sem a data da descoberta · 3 em aberto · 1 abandonada".
- **Barras medidas na própria captura** (pixels, `l1-serie-large.png`): julho
  42,6 % da largura contra 21/49 = 42,9 %; agosto 7,8 % contra 4/49 = 8,2 %.
- **Fluxo:** `maestro/latencia.yaml`, sem `clearState` (limpar apagaria a
  prova), passando em large e em AX5. Rola até cada estado em vez de afirmar
  que todos estão visíveis: em AX5 a seção não cabe numa tela, e a asserção
  seria sobre o tamanho do texto, não sobre a tela. Em AX5 a rolagem até a
  seção precisou de 90 s (com 25 s parava nos Avisos) — o Perfil inteiro é
  muito mais longo nesse tamanho.

## 7. Limites, ditos e não escondidos

- **Não é a série do aparelho do dono.** O simulador não viaja no tempo: os
  registros de junho a setembro foram semeados no formato que o próprio app
  grava (mesma tabela SwiftData, mesmo JSON do `DocumentoTrabalho`, mesmo
  histórico `Versoes`), por `ferramentas/orca/semear-latencia.py`. A série do
  aparelho dele continua sem captura.
- Decisão respondida **sem** histórico de versões (importada, ou 30 versões por
  cima) fica sem data da descoberta — e a tela diz isso.
- `Gatilho` prefere uma hora escrita ("às 9h") à data do mesmo texto: limite
  herdado, que atinge igualmente a cobrança da lista de Notas.
- O estado DEVIDO ancora o "espero" em `criadaEm`; `Volta.devida` o relê a
  partir de hoje. Em texto relativo ("em duas semanas") a lista adia a cobrança
  para sempre e esta tela não. Divergência **declarada**, não resolvida — mexer
  em `Volta` é da lista de Notas, não desta volta.
- `Versoes.listar` roda uma vez por decisão ao abrir o Perfil, síncrono na main.
- Não há rota `traco://` para o Perfil: toda captura desta seção pede maestro.
- Nenhum VoiceOver real: a leitura por leitor de tela está declarada por
  construção (cada linha é um elemento combinado, a barra é
  `accessibilityHidden`), não medida com a tecnologia assistiva ligada.
