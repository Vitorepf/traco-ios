# Trilha Métodos — volta M11: a missão nova

06/09/2026 · worktree `metodos-m1`, mesmo branch. **Nenhum candidato novo**, por
decisão do dono: a trilha passa a auditar a voz do app.

## O que entreguei

[`auditoria-da-voz.md`](auditoria-da-voz.md) — a primeira varredura, com o método,
os achados, o que foi varrido e estava limpo, e a conclusão.

## Como varri

Extraí toda cadeia que chega ao autor (`Text(`, `Label(`, `Button(`,
`accessibilityLabel/Hint`, `navigationTitle`, `mostrarToast`, `Vazio(`,
`conteudo.title`) dos **149 arquivos Swift** de `main` — app e widget — e depois
li à mão as telas de maior tráfego, na ordem que o dono pediu: Página e cartão da
análise, Lente, Recordar, Perfil, Padrões, estados vazios, avisos e notificações.

Não abri simulador; é leitura de código. E marco no arquivo quais achados caem em
arquivo que uma volta está editando agora.

## Os achados, em uma linha cada

1. **`CartaoAnaliseView.swift:35`** — *"ele aprende com você"*. Doença (b). O que
   acontece de fato é uma janela de **duas** respostas por forma (`Degraus.swift:26`):
   duas iguais seguidas mudam um degrau, de 0 a 4. **Arquivo em obra pela volta da
   Página — o achado precisa ir para quem está lá dentro.**
2. **`PerfilView.swift:159`** — *"O que o Traço aprendeu de você"*, título cujo
   conteúdo é literalmente *"12 sinais desde 3 de setembro"* (`Sinais.swift:110`).
   Doença (b). Contagem chamada de aprendizado.
3. **`Lente.swift:33`** — o rótulo **"muletas"** afirma a função de uma palavra
   que uma lista fechada não pode saber; e a lista inclui hedges que o próprio
   catálogo ensina a usar. Confiança menor, e a ressalva é forte: a tela já diz
   "só aponta".
4. **`AnaliseLocal.swift:16`** — *"o que, em você, **costuma** atrapalhar"*.
   Confiança baixa, é uma palavra, e eu não defendo com força.

Cada um com a frase corrigida pronta para colar.

## O que foi varrido e estava limpo — e é a maior parte

Doze superfícies, listadas no arquivo. Três merecem ser citadas:

- **As notificações têm `body = ""` em todas.** O título é uma palavra fixa ou o
  texto do próprio autor. É a fronteira aplicada onde ninguém olha.
- **Padrões**: *"Dois períodos, lado a lado. Sem nota, sem seta: quem lê é você."*
  É o melhor texto do app.
- **Trabalho** tem três frases que negam explicitamente o que esta auditoria
  caça: *"Não é o app avaliando você, nem prova de que você aprendeu."*

## O que eu não sabia e achei lendo

A doença (c) — o app dar a resposta do autor — é **a melhor defendida**, e por
código, não por disciplina de quem escreve:

- contrato fechado nos dois motores de análise (rótulo de lista fixa, nunca
  texto);
- o dicionário de avisos como *"a ÚNICA porta entre um rótulo da IA e uma frase
  na tela"*;
- **`Sabia.swift:326`**: resposta da sábia que começa em "você deve / faça /
  escreva / tente / comece / pare de / precisa / deve" é **descartada por regex**;
- **`Sabia.sistemaCalibrar`**: *"PERGUNTAS, nunca vereditos. Proibido dar nota,
  medir acerto, elogiar, diagnosticar ou aconselhar."*, com a pergunta só passando
  se citar um fragmento literal do que o autor escreveu.

## A conclusão

**As doenças se concentram num lugar só: onde o app fala de si mesmo.** Os dois
achados firmes são as duas vezes em que o Traço descreve a própria capacidade.
Nas centenas de frases em que ele fala do autor ou do que faz, o padrão é
rigoroso: diz o fato, diz a regra, diz como desfazer, devolve a decisão.

É a mesma doença do `avisoWood` (M5) e das seis frases de `movimento` (M8), num
terceiro disfarce — **o marketing de si**: a frase simpática sobre o que o app
faz, escrita por quem está orgulhoso do que construiu, num lugar onde ninguém
procura fonte. Nas três vezes, a correção ficou mais curta, mais concreta e mais
útil.

## E a frase que ficou pela metade na M10

Fechada no fim de [`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md):
quais seriam as **outras proteções** (a Expressiva, a nota trancada, e o conteúdo
de outra pessoa — que o `VISAO-PRODUTO` nomeia e o app ainda não trata), o
critério que separa proteção de método (**proteção é o que faz o app deixar de
fazer alguma coisa**) e os campos que a lista precisaria: além do reconhecimento,
**o que ela desliga** — `naoComenta`, `naoVaiARede`, `naoRecorda`, `naoEncadeia`.
Hoje esses quatro comportamentos estão espalhados como `if` que sabem o nome
"expressiva" de cor.
