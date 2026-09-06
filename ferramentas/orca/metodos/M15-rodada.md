# M15 — o fechamento

Duas entregas, as duas de fechamento. Nenhum método novo, nenhuma rejeição nova.

## 1. [`leva-3-e-fusao.md`](leva-3-e-fusao.md) — o pacote de execução

Tudo que a trilha produziu e que ainda não está no app, num arquivo só, em cinco
passos na ordem em que uma volta de código deve executá-los. **Quem for colar não
precisa abrir nenhuma ficha.**

**A fusão da Inversão no Pré-mortem** (decisão do dono na M15) rendeu três coisas
que eu não tinha antes de conferir:

- **Apagar não basta.** Cinco frases de gatilho ficam sem dono se a Inversão só
  sair. A linha de regex dela tem de ser herdada pelo Pré-mortem, e eu rodei as
  26 frases antes e depois: **a única mudança fora da Inversão é uma melhora** —
  "como garantir que isso falhe", que hoje não acha ninguém (a regex atual exige
  "que falhe", sem palavra no meio), passa a achar o Pré-mortem.
- **A fusão custa um `recordar`.** A Inversão tem um, o Pré-mortem não. Sem
  conserto, o Recordar dessas notas cai em `.livre` (`RecordarView.swift:17`).
  Escrevi o bloco pronto, marcado como opcional — e se o dono não quiser, que o
  custo entre na ADR, porque custo declarado não é dívida escondida.
- **Dois testes quebram, com número de linha:** `CatalogoTests.swift:10` (a
  contagem e a lista literal) e `:163` (`Catalogo.metodo("inversao")?…`, que passa
  a comparar `nil`). Nada mais em `Traco/` cita a Inversão.

## A pergunta do dono: a nota que já usa a forma Inversão

**A resposta é a que ele imaginou, e a lei já existe:** a nota conserva a forma
antiga e o catálogo diz que ela saiu. `Gesto` é uma `String`, não um `case`;
`metodoDef` cai em `Metodo.desconhecido`; `Gesto.estadoDoMetodo` (ADR 05x) devolve
a linha; `LenteView.swift:67` a desenha com o identificador `metodo-ausente`;
`CatalogoTests.swift:224` já prova a frase; e `Corpus.swift:222` garante o mesmo na
exportação (ADR 05o). **Nenhuma migração de dado, nenhum aviso, nenhuma conversão.**

**Mas a lei tem duas arestas, e a primeira é achado de voz:**

> `estadoDoMetodo` diz *"o método saiu da SUA PASTA"*. Aqui isso é falso — o autor
> nunca teve a Inversão numa pasta; ela veio no app, e quem a tirou fomos nós.
> O app estaria afirmando uma ação do autor que não aconteceu.

O conserto é uma linha (*"não está mais no catálogo"*), serve aos dois casos, e
mexe em `Gesto.swift:68` mais a string do teste. **Se a volta não quiser tocar em
Swift, então a fusão não deve acontecer nessa volta:** melhor adiar uma deleção do
que publicar uma frase falsa para o autor.

A segunda aresta é cosmética: com o método fora, o nome vira o id cru, e o autor
lê `inversao` onde lia **Inversão**. Descrevi as duas saídas e **não proponho
nenhuma** — a régua da M14 diz que aposentar método vai ser raro.

## O resto do pacote

- **Os catorze da leva 2 + leva 3** (8 da M4–M7, 2 da M9, 1 da M10, 3 da M13) num
  array só, pronto para colar no fim, com grau, capacidade e contagem de campos.
  Onze de grau A, um C declarado, um de ficção com a linha que a emenda obriga.
- **A higiene II.0** (a reversibilidade sai do movimento da Decisão quando a Porta
  entrar) e as **duas** frases de origem da M6 — eram três, e a terceira era a
  Inversão, que sai.
- **As seis frases de voz da M8**, todas ainda em `main`, conferidas hoje, com o
  texto pronto. Mais a sétima opcional.
- **As provas**, separadas entre as três que eu já rodei (escrita pessoal,
  alcance 14/14, regressão da fusão) e as que só o app pode rodar.

## 2. [`o-que-a-trilha-aprendeu.md`](o-que-a-trilha-aprendeu.md) — fechado

Seis seções novas, escritas para o dono: a régua da proveniência e a emenda da
ficção; a régua da voz e por que ela vale para o app inteiro; as duas lendas que a
M13 desfez ao abrir as fontes (a Porta não é da carta de 1997; a história do avião
de Wald não está no documento de Wald); a curadoria e a revisão da minha própria
medida.

E duas seções que a trilha não tinha: **o que ela NÃO conseguiu fazer** (nunca
abri o app; o teto de dez da análise de bordo continua de pé, e enquanto continuar
cada método aceito é meio método; duas capacidades vazias por falta de livro;
nenhuma eficácia provada, e nem se pretende) e **onde ela erraria de novo** —
inventar uma faculdade por método, aceitar a citação de segunda mão quando ela é
bonita, ler o veredito agregado em vez da lista de falhas, acreditar num número
que eu mesmo produzi, e propor demais.

## Escopo

Só `ferramentas/orca/metodos/`. Nenhum Swift editado, nenhum simulador, nenhum
build. Código lido para conferir: `Gesto.swift`, `Metodo.swift`, `LenteView.swift`,
`RecordarView.swift`, `Corpus.swift`, `CatalogoTests.swift`, `Metodos.json` de
`main` e do branch da M3.
