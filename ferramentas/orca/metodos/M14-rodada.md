# M14 — a curadoria

**Entrega:** [`a-curadoria.md`](a-curadoria.md). Sem método novo, sem rejeição
nova: esta rodada julga o que já está proposto.

## O que foi feito

Os 42 do catálogo com as levas coladas, um por um, com três respostas em uma
linha cada — que movimento **só ele** faz, **quem mais** no catálogo faz parte
disso, e o que o autor **perde** se ele sair. A Expressiva ficou de fora da conta
por ser superfície de proteção, não método: **41 julgados**.

## As três listas

- **Núcleo: 32** — e não 25. A defesa está no arquivo: as nove capacidades não
  são igualmente rasas (Decidir precisa de sete; Perceber e Conviver vivem com
  dois), e a soma do mínimo honesto de cada uma dá 32. Abaixo disso, cada corte
  apaga um movimento que nada substitui.
- **Saem: 3** — Destaque (funde com o Dia), Inversão (funde com o Pré-mortem),
  Palavra (some, por orçamento — e é o único corte de gosto, marcado como tal).
- **Em observação: 6** — O ponto que decide, O que se repetiu, A reparação,
  Sobrevivente, Primeiros princípios, Cinco porquês. **Quatro dos seis são
  meus**, e o de que menos gosto de propor, O ponto que decide, é meu contra o
  Steelman, que é mais velho e melhor fundado.

**32 + 6 = 38 métodos + Expressiva = 39 entradas.** A curadoria devolve o array
para dentro do teto de ~40 sem cortar nada de bom.

## O que eu corrigi de mim mesmo

Na M9 e na M10 eu escrevi que fundir o Destaque **custaria a superfície** da tela
bloqueada. Fui ao código: `Sessao.aplicarDestaque` publica o Destaque do dia a
partir de **qualquer método com um campo `unica`**, e o comentário diz por quê
("ADR 04k: a única do Dia é o Destaque do dia — mesma lei, mesma tela"). O Dia tem
`unica`. **O argumento era meu e estava errado.** O que se perde de verdade é a
porta de entrada de um campo só, que é bem menos.

## O teto de ~40

Mantenho o número e corrijo o que ele mede: nunca foi limite de escolha do autor
— é limite de **manutenção**, porque cada método novo disputa as mesmas frases no
roteador. 42 cabem tecnicamente e não cabem economicamente.

## A segunda pergunta (apresentação)

**O roteamento escolhe pelo autor** — `detectarGesto` devolve uma forma e o
cartão oferece uma, com "Deixar como nota" ao lado. A Hicks não morde ao
escrever, e não morderia com 60. Ela morde em três superfícies de escolha, e a
saída não é ter menos métodos:

1. **Chips da busca** (20 hoje, 41 com tudo colado) — chip por **capacidade**,
   nove, e a forma dentro dela.
2. **Perfil / folha de formas** — copiar o `MenuFormasView`, que já apresenta
   **124 formas em 13 famílias** com cabeçalho grudado, busca e contagem.
3. **`GestoEscolha` (nove, à mão) e a análise de bordo (dez)** — as únicas listas
   fechadas de verdade, e **nenhuma curadoria conserta isso**: é volta de app.

## Escopo

Só `ferramentas/orca/metodos/`. Nenhum Swift editado, nenhum simulador, nenhum
build. Código lido para conferir: `Sessao.aplicarDestaque`, `Intencoes.swift`
(`GestoEscolha`), `MenuFormasView.swift`, `Metodos.json` (21 métodos, 20 filtros).
