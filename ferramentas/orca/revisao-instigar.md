# G3 do INSTIGAR — verdito do mérito (ADR 2026-09-10c)

# NÃO PASSA — o mérito da alavanca é real, a frase que o vende não é.

O pedido novo FICA: ele cura a nota magra com número que aguenta (p = 0,011). O que não
passa é a segunda metade da conclusão da §5 — *"e não paga o preço dela: as ancoradas sobem
de 92% para 93%"*. **Esse ganho de 1 ponto está dentro do ruído que a própria volta mediu e
não leu.** A matéria que o desmente está comitada, no mesmo commit, e nunca foi rodada.
Zero aparelho para consertar: são três frases e uma linha de tabela.

---

## 1. A base rodou duas vezes, e as duas discordam mais do que o ganho

Mesmo `pedidoInstigarSHA256` (`5110e22a`), mesma fixture, mesmas 8 entradas byte a byte,
binários diferentes (`cd84aeaf` / `fb2a28b1`). É medida de ruído de graça:

| ancoradas · base | t1 | t2 | ruído |
|---|---|---|---|
| `grok-4.3` | 55/60 = **92%** | 52/59 = **88%** | **4 pontos** |
| `grok-4.5` | 68/74 = **92%** | 66/74 = **89%** | **3 pontos** |

O ganho declarado é de **1 ponto**. Fisher exato: candidato vs. base **p = 0,54** (4.3) e
**p = 0,52** (4.5) — e a base contra **ela mesma** dá p = 0,37 e p = 0,39, a mesma ordem de
grandeza. A tabela da §5 mostra uma linha de base só, e é a melhor das duas.

**O que sobrevive:** o contraste GRANDE. O LOTE-5 derrubou as ancoradas a 76% e 89%; esta
corrida inteira fica na faixa 88–93%. São 12 a 17 pontos, 3–4× fora do ruído. A frase certa
é *"não repete o colapso do LOTE-5"* — nunca *"sobem de 92% para 93%"*.

## 2. A porcentagem subiu e a conta caiu — o autor recebe MENOS

| `grok-4.3` | perguntas ao todo | ancoradas (casos ricos) | não-ancoradas |
|---|---|---|---|
| base t1 | 78 (3,25/exec) | **55** | 5 |
| base t2 | 76 (3,17/exec) | **52** | 7 |
| candidato t1 | 74 (3,08/exec) | **52** | 4 |

| `grok-4.5` | perguntas ao todo | ancoradas | não-ancoradas |
|---|---|---|---|
| base t1 | 98 (4,08/exec) | **68** | 6 |
| base t2 | 97 (4,04/exec) | **66** | 8 |
| candidato t1 | 95 (3,96/exec) | **67** | 5 |

O candidato perdeu 4 perguntas no 4.3, e **3 delas eram ancoradas**. Os 93% vêm de o
denominador cair mais rápido que o numerador, não de o modelo ancorar mais. Em números
absolutos o autor recebe **3 perguntas ancoradas a menos** no 4.3 e 1 a menos no 4.5.
No 4.5 o candidato (**67**) fica *entre* as duas corridas da base (**66** e **68**): não há
efeito para medir. É a lei da §7 do relatório — *"a média esconde o caso que foi a zero"* —
rodando ao contrário, e contra quem a escreveu. O caso que paga é
`q4-instigar-com-metodo-decisao`: 12/14 → 10/12.

## 3. Um caso × três repetições: o magro AGUENTA, os cegos aguentam só o MODELO

- **`magro quando` passa.** 1ª redação **6/6** (2 modelos × 3) contra base **4/12** pooled
  nas duas janelas: **p = 0,011**. Aguenta, e aguenta *porque* eu juntei as duas janelas —
  a base sozinha em t1 dá 1/3, mas em t2 dá **0/3 no 4.3 e 2/3 no 4.5**. Quem lê só t1
  superestima o degrau. O número honesto é 6/6 vs 4/12, e o relatório não o calculou.
- **Os cegos não sustentam nada sobre o PEDIDO** — 1 caso × 3, e no 4.5 `fatos-negados`
  passa na base também (o relatório diz isso, e em nota de rodapé).
- **Mas sustentam o MODELO, e com folga.** Pooling as 4 corridas (2 janelas × 2 pedidos):
  `grok-4.3` falha em **10 de 12** execuções, `grok-4.5` em **0 de 12** (p ≈ 3·10⁻⁵ tratando
  execuções como independentes; o que de facto pesa é a separação **repetir-se nas 4 corridas**,
  em duas janelas e sob os dois pedidos). É o número mais forte da volta inteira.
- **O que faltaria para o pedido:** não mais repetições — **mais casos magros e mais casos
  que negam**, escritos por quem não escreveu o pedido. O relatório já admite isso na §6 e
  então gasta a admissão numa ressalva em vez de na força da conclusão.

## 4. O oráculo e a régua — o que conferi e o que achei

- **O `cmp` do `lote-ia-09e-q4c.py` é VERDADE.** Blob `0508fee`, byte a byte idêntico ao de
  `bff6d1a` — o commit em que a janela do LOTE-5 mediu. (Contra `d1773e1`, versão anterior à
  medição, difere; a comparação certa é a que o relatório faz.)
- **A calibração reproduz na minha mão.** Rodei o medidor novo sobre `prova/lote09c-q4-grok-4.3
  .jsonl` e `-4.5.jsonl` (LOTE-3): **49/51 = 96%** e **59/61 = 97%**, por caso e no total, à
  vírgula. Instrumento novo que reproduz tabela que não escreveu é instrumento. ✓
  **Metade da afirmação não é conferível aqui:** 48/63 e 63/71 são do LOTE-5, e os JSONL do
  `lote09e` não estão neste branch nem em `main`.
- **`--vigia` enxerga nos dois sentidos:** 6 que tem de acusar + 7 que tem de calar, 13/13,
  saída 0. (O relatório diz "seis e seis" e o docstring "três e três"; são 6 e 7.)
- **O oráculo É paráfrase da regra que julga — e isso PESA A FAVOR do candidato.** A coluna
  `ancoradas` mede *"a pergunta carrega palavra da nota"*, que é a cláusula nova do candidato
  (*"as perguntas saem do que ELA escreveu"*); a base tem só a versão fraca. Régua inclinada
  a favor — **e o candidato não passou do ruído nem assim.** O cego mede *"só entra a que a
  nota deixou sem resposta"*, também cláusula do candidato — **e o candidato falhou 6 vezes.**
  Resultado negativo sob oráculo favorável é resultado forte: é o melhor achado da volta.
- **A 2ª redação foi corrigida pelo próprio gabarito.** Ela põe no pedido *"não sei quando",
  "não sei o que seria"* — as strings que o `cego()` procura. O 6→1 é o oráculo avaliando a
  obediência à sua própria instrução, não um conserto. Descartada, então não contamina a
  decisão — mas *"a 2ª consertou isso"* não é achado independente e está escrito como se fosse.
- **Pareamento íntegro:** as 8 entradas idênticas nos 8 braços; pedido da base byte a byte
  igual nas duas janelas; 264 chamadas, **264 `conteúdo completo`**, zero falha de transporte;
  conta `true` nas 8 fumaças. O `0b` diz `NÃO VERIFICÁVEL` nos binários velhos — a lei
  *"zero só vale se havia o que ver"* está honrada. ✓
- **§12 e voz:** o branch não acrescenta AX/XXXL (contagem de `AX5` em `EVOLUCAO.md` é 13
  antes e 13 depois — todas herdadas de `main`). **Uma linha a apagar:** a §9 do relatório
  cita *"VoiceOver falado não se prova em simulador"* como limite declarado. VoiceOver é
  proibido; não se declara limite de coisa proibida.

## 5. As 15 dimensões — só onde discordo

Conferidas e mantidas: **Contrato 9** (`## ADR 2026-09-10c` = 1, letra única; `Politica.linha
(.instigar)` segue `indisponivelPorQualidade`, §14/§15 respeitada), **Correção 9** (1029
`@Test` na árvore, bate com a §9; as duas guardas são reais e ficariam vermelhas como
descrito — `"Aí MANDA o vazio"` proibido + as 3 pernas exigidas = 3 issues; `ate()` no trecho
comum = 1 issue), **Simplicidade 9** (uma linha por uma linha, `pedidoDeInstigar` só troca em
DEBUG, Release intocado), **Privacidade e autoria 9**, **Complexidade 9**, **Design / Movimento
/ Componentes / Acessibilidade / Performance / Fora do app n/a**, **Jornada real 7** (a nota
que o autor se deu já é a certa).

| dimensão | autor | eu | por quê |
|---|---|---|---|
| Qualidade de IA | 9 | **8** | a 2ª corrida da base estava na mão, no mesmo commit, e nunca foi rodada; o número de manchete está dentro do ruído que ela mede |
| Estado honesto | 9 | **7** | a §7 escreve a lei da média e a §5 a viola: 1 ponto de média reportado como resultado enquanto a **contagem absoluta de ancoradas cai**. E a §11 diz *"não é preciso remedir"* sobre um caso escrito pelo autor do pedido |
| Relato | 9 | **8** | a linha de base da §5 é a melhor de duas corridas, sem dizer que houve duas; "seis que ele NÃO PODE" são 7; metade da calibração cita JSONL que não está no branch |

## 6. O defeito, em uma frase — e o menor conserto

**O defeito:** o relatório vende como resultado um ganho de 1 ponto nas ancoradas que a sua
própria segunda corrida da base mostra ser ruído de 3 a 4 pontos, e faz isso enquanto a
contagem absoluta de perguntas ancoradas CAI.

**O menor conserto que fecha — nenhuma corrida, nenhuma instalação, tudo já comitado:**

1. **Acrescentar a linha `base · t2` à tabela da §5** (4.3 = 52/59 = 88%; 4.5 = 66/74 = 89%;
   magro `quando` 0/3 e 2/3) e a coluna de perguntas ao todo. A tabela passa a mostrar o
   ruído em vez de o esconder.
2. **Reescrever o item 1 da §5:** trocar *"não paga o preço dela: as ancoradas sobem de 92%
   para 93%"* por *"não repete o colapso do LOTE-5: as ancoradas ficam na faixa da própria
   base (88–93%), onde a promoção incondicional as derrubou a 76% e 89%. Contra a base o
   ganho de 1 ponto é ruído (p = 0,54) e a contagem absoluta de ancoradas cai — 55 → 52 no
   4.3."* O ganho do magro fica, e mais forte: **6/6 contra 4/12 pooled, p = 0,011.**
3. **Narrar a §11 pelo número que a sustenta:** o `fatos-negados` separa os MODELOS em 4
   corridas independentes — 4.3 falha em 10 de 12 execuções, 4.5 em 0 de 12. **Isso basta
   para os passos 1–3 da §11 sem remedir** (o passo 4 espera a superfície de qualquer jeito,
   §14/§15). Mas dizer que é **um caso, escrito por quem escreveu o pedido**, e que a
   confirmação final quer um segundo caso de negação de quem não o viu.
4. **Apagar** a menção a VoiceOver na §9. **Ajustar** "seis e seis" para 6 e 7 na §3, e o
   docstring do `--vigia`. **Dizer** que 48/63 e 63/71 vivem no branch `q4-c`, e que o que se
   confere aqui é 49/51 e 59/61.

**Fora do mérito, e bloqueia o pouso:** `origin/main` **não mescla**. Quatro conflitos, e um
é de código: em `Traco/Analise/AvaliacaoIA.swift` a `10c` (`pedidoInstigarSHA256`) e a `10b`
do `main` (`pedidoResponderSHA256`) caem na mesma cauda do dicionário, onde a linha
`.map { … }.joined()]` fecha o literal — resolver de afogadilho **derruba uma das duas chaves
em silêncio** e a corrida seguinte perde o carimbo do braço. As duas chaves têm de ficar, cada
uma com o seu `.joined()`, e a última com o `]`. Não resolvi: é do autor da volta.
Os outros três são aditivos (`SPEC.md`, `LACO.md`, e a `PerfilQualidadeTests` quer o
`.responder` do `main` com o `.instigar` deste branch).

**O que NÃO julguei:** a superfície (§14/§15, cadeira do G4) e a captura do cartão vivo.
