# Porta — ficha do candidato

Volta M13 da trilha Métodos · 06/09/2026 · **proposto**, não colado. Pedido do
dono (IDEIAS.md, seção C).

**GRAU A** — documento público, lido na íntegra.

Faculdade: **decidir** — rótulo que já existe (a Decisão mora nele). Não criei
rótulo novo, pela lição da M9.
Ciclo: **MULTIPLICAR agora** — é o método que faz o autor gastar menos, não mais.

## Primeiro, a correção de origem

O pedido dizia "carta aos acionistas de 1997 e seguintes". **Fui às duas.**

- **Carta de 1997** (lida na íntegra): não tem porta, não tem reversibilidade.
  Fala de decisões de investimento e de horizonte longo — *"We will make bold
  rather than timid investment decisions where we see a sufficient probability of
  gaining market leadership advantages."*
- **Carta de 2015**, publicada em abril de 2016, seção "Invention Machine": **é
  esta.**

É o teste de bolso da régua funcionando: *se eu abrir a obra citada no ano citado,
acho este método lá dentro?* Não achei em 1997. Achei em 2015.

## Fonte

Jeff Bezos, carta aos acionistas da Amazon de **2015**, seção "Invention
Machine". PDF público da área de relações com investidores, lido na íntegra.

> "Some decisions are consequential and irreversible or nearly irreversible –
> one-way doors – and these decisions must be made methodically, carefully,
> slowly, with great deliberation and consultation. If you walk through and don't
> like what you see on the other side, you can't get back to where you were
> before. We can call these Type 1 decisions. But most decisions aren't like that
> – they are changeable, reversible – they're two-way doors."

E o modo de falha, que é o que justifica o método existir:

> "As organizations get larger, there seems to be a tendency to use the
> heavy-weight Type 1 decision-making process on most decisions, including many
> Type 2 decisions. The end result of this is slowness, unthoughtful risk
> aversion, failure to experiment sufficiently, and consequently diminished
> invention."

## O que a fonte afirma, e o que não afirma

**Afirma:** que decisões se dividem por reversibilidade; que a irreversível pede
lentidão e consulta; que a reversível deve ser rápida; e que o erro caro é o
inverso — processo pesado na porta de duas vias.

**Não afirma** nada medido: é carta de acionistas, argumento de quem administra.
E a própria carta traz o limite, numa nota de rodapé que quase ninguém cita:

> "The opposite situation is less interesting and there is undoubtedly some
> survivorship bias. Any companies that habitually use the light-weight Type 2
> decision-making process to make Type 1 decisions go extinct before they get
> large."

**Bezos declara viés de sobrevivência na mesma carta** — a evidência dele é feita
só de empresas que sobreviveram. Isso é honestidade da fonte, e é também a razão
de o **Sobrevivente** (mesma rodada) existir.

## Por que passa nas quatro barras — e a barra 3 quase o derrubou

1. **Ciclo** — MULTIPLICAR: menos deliberação onde ela não paga.
2. **Origem verificável — grau A**, com a correção do ano feita acima.
3. **Não duplica — e esta é a parte difícil, então escrevo o raciocínio inteiro.**

   O `movimento` da **Decisão** já diz: *"quanto custa errar para cada lado, e se
   dá para desfazer. Decisão reversível e barata não merece o mesmo cuidado que
   uma que não volta."* A ideia da reversibilidade **já está no catálogo**.

   Cheguei a marcar este candidato para rejeição por isso. O que o salvou:

   - **na Decisão, a reversibilidade está no texto do movimento, não em campo
     nenhum.** Os campos são escolha, opções, critério, decidido, espero,
     aconteceu, saldo. O autor pode preencher a Decisão inteira sem nunca
     escrever se aquilo volta;
   - **e, sobretudo, a Decisão é o processo pesado.** Quando o autor a abre, já
     está deliberando. Porta existe para rodar ANTES, em vinte segundos, e
     decidir se a Decisão deve ser aberta. Uma triagem que só funciona dentro do
     processo que ela deveria triar não é triagem.

   É por isso que a forma tem **quatro campos e nenhum a mais**, e que os dois
   encadeamentos são o produto dela: uma via abre a Decisão ou o Pré-mortem;
   duas vias fecha a nota e o autor decide.

   **Consequência de higiene, se este entrar:** a frase da reversibilidade deve
   sair do `movimento` da Decisão, para o catálogo não dizer a mesma coisa em
   dois lugares. É uma frase, e vai na volta que abrir o arquivo.
4. **Honestidade sobre evidência** — carta de acionistas, sem medida, com o viés
   declarado pelo próprio autor.

## O que ele desbanca ou complementa

Complementa a Decisão e o Pré-mortem sendo o degrau antes deles. E tem parentesco
com o **Começaria hoje?** (leva 2) pelo outro lado do tempo: Porta pergunta antes
de atravessar, Começaria hoje? pergunta depois de já estar do outro lado.

## Caso de uso real no Traço

O dono hesita em publicar um trecho do produto. Porta: dá para voltar? Publicar
volta — despublica-se, e o custo é constrangimento. Duas vias: decide agora. Já
"mandar o Traço para a App Store com este nome" não volta barato: uma via, e o
botão abre o Pré-mortem. **A forma inteira leva menos tempo que ler esta ficha, e
é esse o ponto.**

## O que a forma pede e o app ainda não faz

Nada — e, por design, ela é a menor forma do catálogo. Se um dia o app tiver um
"caminho rápido" (concluir sem passar por cartão nenhum), é aqui que ele valeria.

## JSON pronto para colar

```json
{
  "id": "porta",
  "nome": "Porta",
  "origem": "Jeff Bezos, 2015",
  "faculdade": "decidir",
  "proveniencia": {
    "fonte": "GRAU A: documento público, lido na íntegra. Jeff Bezos, carta aos acionistas da Amazon de 2015 (publicada em abril de 2016), seção \"Invention Machine\". A distinção NÃO está na carta de 1997 — essa fala de decisões de investimento e de horizonte longo, e não usa porta nem reversibilidade.",
    "funcao": "lente",
    "adaptacao": "Bezos escreve sobre organizações que ficam lentas. O Traço traz para uma pessoa e faz da triagem uma forma DELIBERADAMENTE PEQUENA: quatro campos, porque uma triagem que custa o que custa a decisão não serve para nada. O encadeamento é o produto: porta de uma via abre a Decisão ou o Pré-mortem; porta de duas vias fecha a nota e o autor decide.",
    "evidencia": "É uma carta de acionistas — argumento de quem administra, não estudo. Não há medida de nada, e a própria carta admite o limite em nota de rodapé: \"há sem dúvida algum viés de sobrevivência. Empresas que habitualmente usam o processo leve para decisões do Tipo 1 se extinguem antes de ficarem grandes.\" Ou seja: a fonte só observou quem sobreviveu. Nada aqui mede o efeito de classificar decisões numa nota.",
    "aplicabilidade": "Serve para uma decisão que ainda não foi deliberada. Não serve para decisão já tomada — aí é o Começaria hoje? — nem para escolher entre caminhos, que é a Decisão."
  },
  "filtro": "Porta",
  "reconhecimento": "isto é uma decisão que ainda não foi pesada pela volta.",
  "movimento": "Porta (Bezos, 2015). Antes de deliberar, classificar: \"se você atravessar e não gostar do que vê do outro lado, não consegue voltar para onde estava\" — porta de uma via, decisão devagar, com consulta. Porta de duas vias volta barato e deve ser decidida rápido. O erro que a carta descreve é usar o processo pesado na porta de duas vias, e o preço é lentidão e menos experimento. Cobre a classificação e o custo de voltar — e mais nada: uma triagem que custa o que custa a decisão não serve para nada.",
  "pergunta": "Se você atravessar e não gostar, dá para voltar? A que custo?",
  "roteamento": [
    "\\bd[áa] para voltar atr[áa]s\\b|\\bisso (tem|n[ãa]o tem) volta\\b|\\bn[ãa]o tem volta\\b|\\bsem volta\\b",
    "\\bporta de (uma|duas) vias?\\b|\\bd[áa] para desfazer\\b|\\bse eu me arrepender\\b",
    "\\birrevers[íi]vel\\b|\\bd[áa] para experimentar e ver\\b"
  ],
  "campos": [
    {
      "id": "oQue",
      "rotulo": "A decisão, em uma linha"
    },
    {
      "id": "volta",
      "rotulo": "Dá para voltar? E o que custa voltar"
    },
    {
      "id": "via",
      "rotulo": "Uma via ou duas vias"
    },
    {
      "id": "agora",
      "rotulo": "Duas vias: decido agora e sigo. Uma via: o que eu faço antes"
    }
  ],
  "encadeamentos": [
    {
      "rotulo": "Uma via: abrir a Decisão",
      "para": "decisao",
      "mapa": {
        "escolha": "oQue"
      },
      "exige": [
        "via"
      ]
    },
    {
      "rotulo": "Uma via: imaginar a falha",
      "para": "premortem",
      "mapa": {
        "plano": "oQue"
      },
      "exige": [
        "via"
      ]
    }
  ],
  "definicao": "uma decisão ainda não classificada pela reversibilidade (\"dá para voltar atrás?\", \"isso não tem volta\")"
}
```
