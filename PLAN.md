# PLAN — registro histórico da campanha de 01/set

**Histórico, sem autoridade operativa.** O plano abaixo pertence a um worktree e uma sessão anteriores. Não limita o escopo atual, não autoriza commits ou alterações de ambiente, não veta VoiceOver e não manda executar widget/share hoje. “IA nunca escreve” era a fronteira antiga: a [visão vigente](VISAO-PRODUTO.md) permite produção delegada com origem preservada, mantendo regras locais de prática e selo.

Para agir, use pedido atual → [SPEC e ADRs vigentes](SPEC.md) → [EVOLUCAO.md](EVOLUCAO.md), código e evidência atuais. “Passou”, “cap”, “visual aprovado” e instruções de parada abaixo descrevem apenas a campanha histórica; não provam nem governam a tarefa presente. [META.md](META.md) contém o prompt operativo de continuidade.

<details>
<summary>Plano original de 01/set — preservado somente para consulta histórica</summary>

# PLAN — Traço unidades 1–5 (01/set)

Uma unidade por volta. Sequencial. Destino, não arquitetura. Não mergeie. Não dê push. Não mexa em /Users/vitorepf/develop/traco-ios (outro Claude lá).

Lei: a IA nunca escreve a prosa do autor. Campo nasce vazio. Visual já aprovado (MOTION/VISUAL). Só iPhone. Sem Expo. Sem drive-by. Não ligue segundo simulador — se o aparelho estiver ocupado, implementa e commita; a prova de tela espera o aparelho único.

Fora de escopo: o que não está nestas 5. Não expanda FILA. VoiceOver e iPad não existem neste recado (nem como recusa, nem na FILA).

Prova vive em prova/U.md + prova/U-antes.png + prova/U-depois.png. Commit por unidade neste branch.

Cap por unidade: 3 voltas de crítico fresco (subagent novo, só vê screenshot + teste + esta barra). Estourou → BLOCKED nessa unidade, prova do que faltou, não afrouxa a barra.

## 1 Construtor visual da régua
Destino: cada chip da régua abre um construtor visual. Toque monta (coluna, linha, verso). O autor não precisa entender a forma. Hoje a tabela é grid vazio cru.
Barra (tudo exit 0):
- maestro/cenarios/regua-construtor.yaml (novo)
- maestro/caderno-tabela.yaml
- maestro/caderno-regua.yaml
- prova/1-depois.png mostra construtor, não grid cru

## 2 Vestir a nota
Destino: um botão veste a nota inteira (títulos, listas, destaques) num toque. O autor só escreveu.
Barra:
- maestro/cenarios/vestir-nota.yaml (novo) exit 0
- testes permanentes de que a IA não escreve continuam 0
- prova/2-depois.png: o botão existe e a nota vestida

## 3 Dedo a caminho da régua
Destino: a forma não veste no meio de um toque a caminho da régua. Alvos não saltam.
Barra:
- maestro/cenarios/regua-dedo-em-voo.yaml (novo) exit 0
- caso: auto-vestir armado + dedo indo à régua → chip ainda acerta
- prova/3-depois.png

## 4 Widget
Destino: widget na tela inicial. Um toque = página em branco. Outro = Recordar. Visual da casa.
Barra:
- alvo Widget no xcodeproj; build do widget exit 0
- toque dispara as rotas já existentes (Rota / App Intents)
- prova/4-depois.png do widget no simulador (quando o aparelho estiver livre)

## 5 Share
Destino: de outro app, Compartilhar texto abre o Traço numa nota com aquele texto. Sem prosa da IA. Trancada nunca entra.
Barra:
- alvo Share Extension no xcodeproj; build exit 0
- texto compartilhado vira nota (teste ou flow)
- prova/5-depois.png

Stop do hop: as 5 barras passaram, ou cap, ou aparelho/permissão faltando. Grava prova/PROVA.md. Não declare done em compile.

</details>
