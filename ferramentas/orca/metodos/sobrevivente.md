# Sobrevivente — ficha do candidato

Volta M13 da trilha Métodos · 06/09/2026 · **proposto**, não colado. Pedido do
dono (IDEIAS.md, seção C).

**GRAU A** — documento público, lido na íntegra. E o cuidado de régua que o dono
pediu rendeu **achado**: a história popular de Wald não está em Wald.

Faculdade: **honestidade** — rótulo existente (a Nota do fato contrário mora
nele).
Ciclo: **MELHORAR** — é a capacidade de não aprender coisa errada com quem deu
certo, e o dono lê biografias.

## Fonte

Abraham Wald, **"A Method of Estimating Plane Vulnerability Based on Damage of
Survivors"** — oito memorandos do Statistical Research Group / Applied
Mathematics Panel, **1943**; desclassificados e reimpressos pelo Center for Naval
Analyses (CRC 432, julho de 1980). Li a digitalização do DTIC no Internet
Archive, inteira.

O problema, na abertura da Parte I:

> "Denote by P_i the probability that a plane will be downed by i hits […]
> Suppose that p_i and P_i are unknown and our information consists only of the
> following data concerning planes participating in combats: the total number N
> of planes participating in combat; for any integer i, the number A_i of planes
> that received exactly i hits…"

E o uso, na Parte VIII, que é a única linha sobre blindagem em todo o documento:

> "These, and other conclusions that can be made from the table of vulnerabilities
> derived by the method of analysis of part VIII, can be used as guides for
> locating protective armor and can be used to make a prediction of the estimated
> loss of a future mission."

## O achado: a história popular NÃO está no documento

A versão que todo mundo conta — o mapa do avião com pontos vermelhos onde os
aviões voltavam furados, e Wald dizendo "blindem onde NÃO há furos" — é uma boa
história. **Ela não está nos memorandos.**

Nos **113 mil caracteres** da reimpressão: **zero** ocorrências de "hole",
**zero** de "diagram", **zero** de "red dot". Não há cena de reunião, não há
general, não há frase de efeito. O que há são oito memorandos de estatística com
equações, estimando a probabilidade de um avião ser derrubado por um acerto em
cada parte, **tratando os aviões que não voltaram como dado ausente** — que é a
ideia de verdade, e é melhor que a anedota.

Isto é a régua funcionando na direção que o dono pediu: **quem cita Wald pela
anedota está citando quem contou a anedota, não Wald.** A ficha cita Wald.

## O que a fonte afirma, e o que não afirma

**Afirma:** que dá para estimar a vulnerabilidade das partes a partir apenas da
distribuição de danos de quem VOLTOU, se você modelar quem não voltou como o
dado que falta.

**Não afirma:** nada sobre relatos, biografias, negócios ou aprendizado. Não há
parábola, não há moral, não há a frase famosa. E não há evidência nenhuma de que
desconfiar de um relato de sucesso melhore decisão alguma — o que a fonte dá é a
**estrutura**: a amostra é feita só de sobreviventes.

**A pergunta da simetria é do Traço**, não de Wald, e a ficha diz isso: *esta
mesma frase também seria verdadeira na boca de quem fracassou com o mesmo método?*

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR.
2. **Origem verificável — grau A**, com o documento lido e a anedota desmentida.
3. **Não duplica** — a **Leitura** entende o texto ("a tese nas suas palavras,
   onde discordo"); esta desconfia da amostra de onde o texto saiu. **Ver antes
   de nomear** (leva 3) separa registro de conclusão numa cena que o autor
   observa; aqui a observação é de outra pessoa, e o que se separa é o que ELA
   viu do que ELA concluiu. O **Argumento** pede a melhor objeção a uma tese
   própria. Nenhum tem o teste da simetria nem o campo de quem não aparece.
4. **Honestidade sobre evidência** — dita acima, incluindo o que é meu e não de
   Wald.

## O que ele desbanca ou complementa

É a primeira metade do par com a **Transferência**: primeiro o relato é
confiável, depois ele se aplica. O encadeamento leva o que sobrou de instrução
para lá. E encadeia para o **Argumento**, que transforma o inferido em tese e o
observado em evidência — onde costuma ficar claro que a evidência não sustentava.

## A fronteira medida: quem diz que LEU cai na Leitura

Testado nesta rodada: *"foi assim que ele conseguiu, segundo a entrevista"* vai
para a **Leitura**, porque `\bsegundo (o|a) \w+\b` casa primeiro e a Leitura vem
antes no catálogo. **É defensável** — primeiro entender o texto, depois
desconfiar dele — e o Sobrevivente pega o caso em que o autor já está repetindo a
explicação ("o segredo dele foi…"). Se o dono quiser costurar os dois, o lugar é
um encadeamento **Leitura → Sobrevivente**, numa volta que edite método já
colado.

## Caso de uso real no Traço

Uma entrevista diz que o fundador acordava às cinco. Observado: acordava às
cinco; a empresa cresceu. Inferido: acordar cedo fez a empresa crescer. Teste da
simetria: alguém que faliu também acordava às cinco e diria a mesma frase — logo
ela não explica nada. Quem não aparece: os milhares que acordaram às cinco e
sumiram. O que sobra de instrução costuma ser bem menor que o relato, e é a única
parte que vale levar para a Transferência.

## O que a forma pede e o app ainda não faz

Nada.

## JSON pronto para colar

```json
{
  "id": "sobrevivente",
  "nome": "Sobrevivente",
  "origem": "Abraham Wald, 1943",
  "faculdade": "honestidade",
  "proveniencia": {
    "fonte": "GRAU A: documento público, lido na íntegra. Abraham Wald, \"A Method of Estimating Plane Vulnerability Based on Damage of Survivors\", oito memorandos do Statistical Research Group / Applied Mathematics Panel, 1943; reimpressão do Center for Naval Analyses (CRC 432, 1980), lida na digitalização do DTIC no Internet Archive.",
    "funcao": "lente",
    "adaptacao": "Wald resolve um problema estatístico: estimar a vulnerabilidade de cada parte do avião a partir dos danos de quem VOLTOU, tratando os que não voltaram como dado ausente. O Traço toma a estrutura — a amostra é só de sobreviventes — e a transforma em três perguntas sobre um relato de sucesso. A pergunta da simetria (a mesma frase na boca de quem fracassou) é do Traço, não de Wald.",
    "evidencia": "São memorandos de estatística aplicada, com equações, não uma parábola. **A história popular não está no documento:** nos 113 mil caracteres da reimpressão não aparecem as palavras \"buraco\", \"diagrama\" nem \"ponto vermelho\", e não há nenhuma cena de reunião nem a frase sobre blindar onde não há furos. O que existe é o método de estimativa e uma linha dizendo que a tabela de vulnerabilidade resultante \"pode ser usada como guia para posicionar blindagem\". Quem cita Wald pela anedota está citando quem contou a anedota, não Wald. E nada nele mede o efeito de desconfiar de um relato.",
    "aplicabilidade": "Serve para um relato de sucesso — biografia, entrevista, caso de estudo, thread. Não serve para relato de fracasso, que tem o viés oposto, nem para entender o texto, que é a Leitura."
  },
  "filtro": "Sobrevivente",
  "reconhecimento": "isto é um relato de quem voltou.",
  "movimento": "Viés de sobrevivência (Wald, 1943). A amostra é feita só de quem voltou: o método de Wald estima a vulnerabilidade do avião a partir dos danos dos sobreviventes, tratando quem não voltou como dado ausente. Aqui: separar o que a pessoa OBSERVOU do que ela INFERIU, e então a pergunta que desarma quase tudo — esta mesma frase também seria verdadeira na boca de quem fracassou com o mesmo método? Se for, ela não explica o sucesso. Cobre também quem não aparece no relato.",
  "pergunta": "Quem fracassou com o mesmo método diria esta mesma frase?",
  "roteamento": [
    "\\bo segredo (dele|dela|deles)\\b|\\b(ele|ela) conseguiu porque\\b|\\bfoi assim que (ele|ela) (fez|conseguiu)\\b",
    "\\bvi[ée]s de sobreviv[êe]ncia\\b|\\bhist[óo]ria de sucesso\\b|\\btodos os que deram certo\\b",
    "\\ba receita (dele|dela)\\b|\\bo que fez (ele|ela) dar certo\\b"
  ],
  "campos": [
    {
      "id": "relato",
      "rotulo": "O relato, e de quem"
    },
    {
      "id": "observou",
      "rotulo": "O que a pessoa OBSERVOU: o que ela viu, fez, mediu"
    },
    {
      "id": "inferiu",
      "rotulo": "O que ela INFERIU: a explicação que ela dá"
    },
    {
      "id": "mesmaFrase",
      "rotulo": "A mesma frase na boca de quem fracassou: continua verdadeira?"
    },
    {
      "id": "naoVoltaram",
      "rotulo": "Quem fez o mesmo e não aparece neste relato"
    },
    {
      "id": "sobra",
      "rotulo": "O que sobra de instrução depois disso"
    }
  ],
  "recordar": {
    "alvo": [
      "mesmaFrase"
    ],
    "pista": [
      "relato"
    ],
    "pergunta": "A frase resistia à boca de quem fracassou?",
    "instrucao": "O relato fica. O teste some.",
    "rotuloAlvo": "O TESTE DA SIMETRIA"
  },
  "encadeamentos": [
    {
      "rotulo": "Isto vale para mim? (Transferência)",
      "para": "transferencia",
      "mapa": {
        "funcionou": "sobra"
      },
      "exige": [
        "sobra"
      ]
    },
    {
      "rotulo": "Virar tese e evidência",
      "para": "argumento",
      "mapa": {
        "tese": "inferiu",
        "evidencia": "observou"
      },
      "exige": [
        "inferiu"
      ]
    }
  ],
  "definicao": "um relato de sucesso, separado entre o que foi observado e o que foi inferido (\"o segredo dele\", \"foi assim que ele conseguiu\")"
}
```
