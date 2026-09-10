# Q4-F · CONTRAPOR — as duas tentativas, e o que o modelo faz de errado

**Aparelho:** `34CC3F94-FDB5-4575-A4F5-80271829A18B` (conta). **Suíte:** `A1DF082C`.
**ADR:** 2026-09-10d. **Prova:** `prova/lote09g/`, `prova/lote09h/`, `prova/q4f/`.

## As cinco linhas do regime (a operação NÃO passou o caso cego em duas tentativas)

1. Para o recurso que a nota diz **não ter**, o modelo oferece um **substituto** —
   "ensaio com dado sintético", "cópia mascarada", "recorte representativo": ele lê
   a falta declarada como lacuna a preencher, não como condição.
2. O `grok-4.3` ainda **argumenta a favor dela com o motivo que ela pôs fora da
   conta** (preço, distância, horário) e não toca no que ela não examinou.
3. O `grok-4.3` também propõe, em `foraDaLista`, o que a nota fecha por outras
   palavras — "replicação paralela" quando as duas versões não rodam juntas.
4. O `grok-4.5` acerta o cego das razões fechadas 3 de 3 e erra o das alternativas
   negadas 1 de 3, sempre pela mesma porta do item 1.
5. **Nenhum dos dois passa os DOIS cegos em 3 de 3** — e a escolha por operação
   (09v) não salva: o melhor de cada um falha no cego do outro.

## O que a volta entrega, medido

- **A alavanca (uma):** no `sistemaContrapor`, *o que ela já descartou, recusou ou
  disse não ter é DADO; nada disso volta como proposta sua, nem no `foraDaLista`,
  nem como etapa antes; e quanto mais saídas ela fecha, mais o contraponto se
  aperta no que SOBRA.* Condicionada à matéria — sem promover lista, sem exigir
  número de campos, sem autocertificação.
- **O portão antes do prompt:** `Grok.Diagnostico.bruto` (DEBUG). Sem ele,
  "os três vazios são do modelo" era inferência. O conferidor acusa três vazios
  que chegam sem o bruto — e acusou, relendo o LOTE-6.
- **Os três vazios sobre HTTP 200 foram a ZERO** e lá ficaram em 96 execuções.
  Conferido: nenhuma guarda nossa apagou (`guardasQueApagaram` vazio), então a
  rota **herdou** o conserto da 09s; o defeito era do modelo, e a alavanca o
  derrubou.
- **A tela:** a linha perdeu "e às vezes não devolve nada" — 1 em 24 no LOTE-6,
  0 em 48 e 0 em 48 depois. Diz o que ele encontra: *"ela ainda oferece a saída
  que você já tinha descartado"*.

## A tabela

| | cego `alternativas-negadas` | cego `razoes-fechadas` | três vazios | campos vazios |
|---|---|---|---|---|
| LOTE-6 `4.3` | 2/3 | ~1/3 | **1** | 12/72 |
| LOTE-6 `4.5` | **0/3** | 3/3 | 0 | 0/72 |
| LOTE-7 t1 `4.3` | 2/3 | 0–1/3 | **0** | 14/72 |
| LOTE-7 t1 `4.5` | 1/3 | 3/3 | 0 | 0/72 |
| LOTE-8 t2 `4.3` | 1/3 | 1/3 | **0** | **10/72** |
| LOTE-8 t2 `4.5` | **2/3** | **3/3** | 0 | 0/72 |

Ler por **intervalo, não por seta**: são 3 repetições por célula, e o LOTE-5 já
devolveu número diferente na remedida com o mesmo prompt e o mesmo parser.

## Instrumento — o que foi conferido, com a hora

- Fixture **byte a byte** a do LOTE-6: SHA `da012e21bcde220c5f745f9bd7e5d7bcf7b2f845095bbe7ef889c844f2afb029`.
- **LOTE-7** 15:54:27Z–16:05:29Z · **LOTE-8** 16:14Z–16:26Z · captura 16:50–16:52:20Z.
- `ContaGrok.ligada` **true** nas quatro fumaças de cada janela e às **16:45:01Z**
  depois da instalação da captura.
- `cmp` do `Traco.debug.dylib` contra o produto de build: **igual**, no install e
  no fim de cada janela. (O `Traco` de 59 k é só o lançador; o prompt vive no dylib.)
- **Três instalações na volta**, uma por janela de medida mais a da captura —
  declarada, porque fotografar frase que o código já não tem seria mentira na prova.
- Nenhum `xcodebuild test` no aparelho de conta. Suíte só no `A1DF082C`.
- Letra em **`large`** antes e depois; tema `light`; contraste `disabled`.

## Suíte

`✔ Test run with 1039 tests in 164 suites passed after 146.933 seconds.`
Árvore própria, os dois testes exclusivos deste candidato:
`✔ Test oContratoDeContraporFechaASaidaQueElaMesmaDescartou() passed after 0.001 seconds.`
`✔ Test tresVaziosDoModeloNaoSaoTresVaziosDaGuarda() passed after 0.001 seconds.`
Build **incremental** (não limpo) — a contagem de warning desta volta não vale;
o warning herdado de `NotasView.swift:814` continua lá.

## A vigia prova que enxerga

`lote-ia-09g-contrapor.py` foi rodado **primeiro no LOTE-6**, onde os defeitos são
conhecidos: acusou o ensaio do `4.5` 3 de 3, os três vazios do `4.3` e a ausência
do retorno bruto. E na primeira redação ele **sobre-acusava** — contava "sem teste
com dados reais" no `contra` como se fosse a proposta do ensaio, quando o revisor
lera o oposto. Restringi a coluna ao `foraDaLista`, que é o campo que PROPÕE por
contrato, com guarda de negação; o resto vai para o revisor **sem veredito**.
Ele ainda **sub-acusa** (não pega "convênio", "caminhadas", "replicação
paralela") — por isso a leitura de mérito acima é minha, lida saída a saída, e a
nota final é do revisor.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão de `QUALIDADE-IA.md` | nota | prova |
|---|---:|---|
| fidelidade ao que o autor escreveu | 7 | 0 fatos fabricados em 96 execuções; mas o substituto do item 1 introduz recurso que a nota nega |
| utilidade do que volta | 8 | `4.5` morde o não-examinado 3/3 no cego das razões fechadas; `4.3` argumenta pelo que ela excluiu |
| honestidade do silêncio | 9 | três vazios 1 → 0 → 0; `nil` ≠ vazio herdado e conferido; retorno bruto agora preservado |
| estado na tela | 9 | linha na língua do autor, sem data e sem jargão, fotografada em `large` às 16:52:20Z |
| medida que se pode repetir | 8 | mesma fixture byte a byte, uma janela e um install por tentativa, `cmp` dos dois lados; mas 3 repetições por célula é amostra fina |

**Nota que eu não me dou:** a final. O G3 lê a saída inteira e os dois cegos.
