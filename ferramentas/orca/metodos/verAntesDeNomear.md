# Ver antes de nomear — ficha do candidato

Volta M9 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

**GRAU A** — obra publicada, lida no texto integral, em domínio público.

Faculdade: **percepção** (vazia até esta rodada).
Ciclo: **MELHORAR** — todo o resto do catálogo trabalha em cima do que o autor
acha que viu. Se a entrada já vem interpretada, os 37 métodos seguintes estão
raciocinando sobre a conclusão dele, não sobre o mundo.

## A M1 disse que aqui não havia nada. A M1 estava errada.

Na primeira rodada eu escrevi que em percepção "não achei nada com origem e
movimento que mereçam". Naquela altura eu procurava em literatura de método e de
psicologia — e lá, de fato, o que existe ou é treinamento clínico ou é escrita
criativa sem autor. **O que faltava era procurar onde as pessoas treinam o olho
profissionalmente: desenho, pintura, história natural.** Foi a régua que me
ensinou isso, com a restrição de grau A da M7: quando fui obrigado a achar livro,
achei em vinte minutos.

## Fonte

**John Ruskin, *The Elements of Drawing* (1857)**, carta I, nota do parágrafo 5.
Texto integral lido no Project Gutenberg (eBook 30325). Domínio público.

> "The perception of solid Form is entirely a matter of experience. We see nothing
> but flat colors; and it is only by a series of experiments that we find out that
> a stain of black or gray indicates the dark side of a solid substance […] The
> whole technical power of painting depends on our recovery of what may be called
> the _innocence of the eye_; that is to say, of a sort of childish perception of
> these flat stains of color, merely as such, without consciousness of what they
> signify,—as a blind man would see them if suddenly gifted with sight."

E a frase que é o método inteiro:

> "having once come to conclusions touching the signification of certain colors, we
> always suppose that we _see_ what we only know, and have hardly any consciousness
> of the real aspect of the signs we have learned to interpret."

**"Supomos que vemos o que apenas sabemos."** Ruskin está falando de grama
amarelada pelo sol, e vale igual para um relatório, uma reunião e a cara de
alguém.

## O que a fonte afirma, e o que não afirma

**Afirma:** que a interpretação chega junto com a percepção e a substitui sem
aviso; que o profissional do olho treina para recuperar o registro cru; e que
quase ninguém tem consciência do aspecto real dos sinais que aprendeu a
interpretar.

**Não afirma** nada que se possa medir: é um manual de desenho de 1857, uma
lente. E mais: **a teoria de Ruskin sobre a percepção da forma sólida é do tempo
dele** — a psicologia da percepção discute isso desde então, e o Traço não usa a
teoria, usa a distinção. Ruskin também não propõe este exercício: os campos são
do Traço, e a ficha diz onde ele acaba e onde eu começo.

Não há evidência de que separar registro e conclusão numa nota melhore julgamento
algum.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR, e é o ciclo na sua forma mais barata: a qualidade de
   entrada de todos os outros métodos.
2. **Origem verificável — grau A** — obra, autor, ano, carta, parágrafo, edição
   lida; duas citações literais de texto em domínio público.
3. **Não duplica** — os **Primeiros princípios** separam o que se sabe do que se
   supõe, mas trabalham sobre CRENÇAS herdadas, não sobre uma cena diante dos
   olhos. O **Argumento** pede evidência para uma tese que já existe; aqui a tese
   ainda não foi formada, e o ponto é não formá-la cedo demais. A **Nota do fato
   contrário** (leva 2) captura um fato que vai contra você; este captura o fato
   antes de haver lado. E nenhum deles tem o campo que separa este método:
   **o que o mesmo registro também poderia significar.**
4. **Honestidade sobre evidência** — dita acima, incluindo a datação da teoria de
   Ruskin e o limite do que ele propõe.

## O que ele desbanca ou complementa

Complementa quase tudo, porque vem antes. O encadeamento leva para o
**Argumento**: o registro vira evidência e a conclusão vira tese — e é aí que se
descobre se a evidência sustentava mesmo. O compromisso de três dias marca a
observação que faltava, que é a única forma de o método terminar em fato e não em
prosa.

## Caso de uso real no Traço

Um relato de agente chega e o dono escreve "claro que ele não leu o brief". A
forma cobra o registro: *o relato tem 400 palavras, cita dois arquivos, não cita
o brief, e responde a três das cinco perguntas*. A conclusão vai para o campo de
baixo. O campo do "o que mais isso poderia significar" produz a segunda leitura
(leu e discordou; leu e esqueceu; não achou o arquivo), e o último campo diz o
que olhar para separar as três — que costuma ser uma pergunta de dez segundos.

## O que a forma pede e o app ainda não faz

Nada de estrutura. Uma fronteira medida nesta rodada, que vale para quem colar:
**quando o objeto observado é uma tela, um app ou um sistema, a regex larga da
Especificação vence** (`\b(feature|sistema|api|tela|site|função|app|módulo|construir)\b`).
É a mesma classe dos cinco desvios herdados, e o conserto é o mesmo — estreitar
a lista de palavras da Especificação. Está registrado em `achados-catalogo.md`.

## JSON pronto para colar

```json
{
  "id": "verAntesDeNomear",
  "nome": "Ver antes de nomear",
  "origem": "John Ruskin, 1857",
  "faculdade": "percepção",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral. John Ruskin, The Elements of Drawing (1857), carta I, nota do parágrafo 5; Project Gutenberg, eBook 30325. Ruskin escreve sobre desenho e não propõe este exercício: o Traço toma dele o critério — supomos ver o que apenas sabemos — e monta os campos.",
    "funcao": "lente",
    "adaptacao": "Ruskin treina o olho para pintar. O Traço separa em campos o que ele diz estar colado: o registro (só o que uma câmera pegaria) fica em um campo, a conclusão em outro, e mais dois que são do Traço — o que o MESMO registro também poderia significar, e o que seria preciso olhar para separar as duas leituras.",
    "evidencia": "É um manual de desenho de 1857, uma lente: sem estudo, sem medida. A afirmação de Ruskin sobre a percepção da forma sólida é do seu tempo e a psicologia da percepção discute isso desde então — o Traço não usa a teoria, usa a distinção. Não há evidência de que separar registro e conclusão numa nota melhore julgamento algum.",
    "aplicabilidade": "Serve para uma cena, tela, relatório ou fala que o autor já está explicando enquanto olha. Não serve quando não há nada para observar — opinião sobre ideia é Argumento."
  },
  "filtro": "Ver",
  "reconhecimento": "isto já veio interpretado — falta o que estava lá.",
  "movimento": "A inocência do olho (Ruskin, 1857): \"sempre supomos que VEMOS o que apenas sabemos\". Primeiro o registro — só o que uma câmera pegaria: palavras ditas, números, o que se vê —, sem nome, sem causa e sem adjetivo. A conclusão vem depois, em campo separado. Cobre a separação: se no registro aparecer uma palavra que já explica (nervoso, atrasado, ruim, confuso), ela é da conclusão. E cobre o que o mesmo registro também poderia significar.",
  "pergunta": "O que uma câmera teria registrado — sem nome, sem causa?",
  "roteamento": [
    "\\bcl[áa]ro que (ele|ela|eles|isso|est[áa])\\b|\\bobviamente (ele|ela|eles|est[áa]|foi)\\b|\\bd[áa] para ver que\\b|\\best[áa] na cara que\\b",
    "\\bs[óo] o que d[áa] para ver\\b|\\bantes de interpretar\\b|\\bo que eu vi foi\\b|\\bdescrever sem (julgar|interpretar)\\b",
    "\\binoc[êe]ncia do olho\\b|\\bo que estava l[áa] de fato\\b"
  ],
  "campos": [
    {
      "id": "olho",
      "rotulo": "O que eu estou olhando (a cena, a tela, o relato)"
    },
    {
      "id": "registro",
      "rotulo": "Só o que uma câmera registraria: palavras, números, o que se vê"
    },
    {
      "id": "conclui",
      "rotulo": "O que eu concluí (aqui, e não no campo de cima)"
    },
    {
      "id": "outra",
      "rotulo": "O que o MESMO registro também poderia significar"
    },
    {
      "id": "olharia",
      "rotulo": "O que eu teria de olhar para separar as duas leituras"
    }
  ],
  "recordar": {
    "alvo": [
      "registro"
    ],
    "pista": [
      "conclui"
    ],
    "pergunta": "O que estava lá, antes da sua conclusão?",
    "instrucao": "A conclusão fica. O registro some — como ele sempre some.",
    "rotuloAlvo": "O REGISTRO"
  },
  "encadeamentos": [
    {
      "rotulo": "Virar tese e evidência",
      "para": "argumento",
      "mapa": {
        "tese": "conclui",
        "evidencia": "registro"
      },
      "exige": [
        "conclui"
      ]
    },
    {
      "rotulo": "Olhar de novo em 3 dias",
      "compromisso": {
        "titulo": "olhar de novo: ",
        "campo": "olharia",
        "dias": 3
      },
      "exige": [
        "olharia"
      ]
    }
  ],
  "definicao": "uma cena, tela ou relato em que a interpretação já entrou no lugar do que se vê"
}
```
