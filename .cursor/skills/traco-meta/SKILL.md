---
name: traco-meta
description: Loop de horas no Traço — mente × IA que recusa × Markdown-arquivo. Use when working on traco-ios for a long session, improving quality, fixing caderno/porteiro bugs, expanding the régua, or when the user says meta, loop, multiplicar a mente, or "não pares".
---

# Traço — meta e loops

Lê isto inteiro. Depois `portoes.md` e `anti.md`. SPEC.md e SISTEMA.md são lei. Este ficheiro é o processo.

Não executes um supermercado de features. Executa o loop. Uma fatia. Evidência. A seguinte.

## Tese (decorar)

A IA do ChatGPT escreve. Esta recusa — para o autor ter de escrever, ver, e depois lembrar.

Traço é o caderno mais avançado que existe **sem ensinar uma língua**. Markdown é o arquivo. A régua é o gesto. A IA nomeia o gesto ou cala. Nunca a prosa.

Se o trabalho ensina `#`, oferece texto pronto, ou achata o laboratório / o acto / o rito num atalho — é traição. Apaga.

## Contrato de uma sessão

Copia e preenche no topo do turno:

```
TESIS: mente × IA-recusa × markdown-arquivo
FATIA: <um gesto do autor, uma frase>
NÃO FAÇO: <o atalho tentador desta fatia>
BARRA: <portão que tem de ficar verde, com comando>
```

Sem fatia, não há código. "Melhorar o app" não é fatia. "Toque na Chamada mantém o cartão e não mostra :::" é fatia.

## O loop (repetir até a fila P0 acabar ou o humano parar)

### 0. Contratar

Lê SPEC.md, SISTEMA.md, `anti.md`. Diz a tese numa frase. Se não consegues, para.

Inventário em silêncio: caderno (régua, portais, parser), porteiro local, puxar, códice, expressiva, pilha/busca, véu. Não perguntes o que o disco já diz.

### 1. Diagnosticar (não inventar trabalho)

Ordena o que **hoje** impede a tese. Só estas classes, por gravidade:

| P | Classe | Pergunta |
|---|---|---|
| 0 | Fonte na cara | O autor vê `#` ` ``` ` `:::` `\|---` `- [ ]` ou `traco://`? |
| 0 | IA escreve | Algum caminho insere prosa do modelo / template-como-se-fosse-IA na nota? |
| 0 | Gesto partido | Toque, régua, porteiro, puxar, tranca — o acto não faz o que a palavra promete? |
| 1 | Figura feia | Código/ficheiro/forma é dump, não portal? Chrome some ao editar? |
| 1 | Mente presa | Forma que pedia um sítio mental ficou atalho, ícone, ou markdown? |
| 2 | Atrito morto | Hick, alvo <44, dois âmbares, placeholder, animação a escrever? |
| 3 | Ampliar vocabulário | Nome novo na régua, portal novo, língua nova — só se P0/P1 estão limpos *nessa superfície*. |

Escolhe **uma** linha do topo. Escreve a FATIA. O resto espera.

Proibido "já que estou aqui" em ficheiro que não é da fatia.

### 2. Desenhar o gesto

Antes do patch, em 4 linhas:

1. O autor faz _isto_.
2. Vê _esta figura_.
3. Nunca vê _esta marca_.
4. A IA faz _nada / rotar / travar / uma pergunta / calar_ — nunca escreve o bloco.

Se (3) falha no desenho, o patch é inválido.

### 3. Implementar o mínimo

- Swift 6.2, MainActor por defeito. Helpers de parse `nonisolated`. `Sendable` nos valores.
- Markdown só em `Caderno.serializar` / parser. UI fala `textoVisivel` e cromo.
- Toque edita **dentro** da figura (Cartão, colunas, portal de código). Não trocar a figura por `TextEditor` nu.
- Um âmbar vivo por vista. Tokens só de SISTEMA.md.
- Porteiro classifica `Caderno.prosa` — sem labels, sem cercas, sem media.
- Sem `api.x.ai`, sem Keychain de modelo, sem `URLSession` para LLM.

### 4. Portões

Abre `portoes.md`. Corre **todos** os aplicáveis à fatia. Cada um: `pass` / `fail` / `skip` + evidência (comando, path de screenshot, id de teste).

Opinião não fecha portão. "Parece bom" é fail do processo.

Falhou → o menor patch que mata a evidência → re-corre o portão e os de regressão (ferro, caderno, testes).

### 5. Crítico cego (tu, segundo papel)

Relê o diff **sem** a tua justificação. És o autor que odeia Markdown e odeia ChatGPT.

Pergunta única: **isto multiplica a mente ou o atalho?**

Se atalho, não merges a fatia. Reescreve ou aborta.

### 6. Só então a seguinte

Regista: fatia, portões, evidência, o que ficou P0.

Volta ao §1. Não alargues o raio.

## Parar

**Pronto** quando: a FATIA passou todos os portões aplicáveis; SPEC/SISTEMA não foram violados; P0 da superfície tocada está limpo; o que não verificaste está dito.

**Bloqueado** quando: falta permissão (Simulador, Acessibilidade), a barra exige decisão humana, ou a mesma abordagem falhou 3 vezes. Nomeia o bloqueio. Não baixes a barra.

**Não pares** por cansaço de prompt se ainda há P0 na superfície em que estás e podes agir.

## Como o humano te liga

```
Lê .cursor/skills/traco-meta/SKILL.md e corre o loop.
Fatia (opcional): <uma frase>
Não pares nas P0 do caderno / porteiro / mente.
```

Horas = muitas voltas do loop, não um plano de 40 features.

## Referências

- [portoes.md](portoes.md) — barra mensurável
- [anti.md](anti.md) — o que parece progresso e é traição
- [fila.md](fila.md) — dívida conhecida; não é backlog sagrado
