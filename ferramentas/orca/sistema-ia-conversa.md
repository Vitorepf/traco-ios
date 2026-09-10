# SISTEMA-IA / conversa — a conversa com a sábia como folha do Traço (ADR 2026-09-10f)

**Linha do ciclo.** G1 de frontend, Astra no G0 (parecer entra como conferência); intenção "resolver a experiência, o design e o uso da IA"; obstáculo "a IA aparece em oito superfícies e cada uma inventou a sua forma — o dono abriu uma e chamou de deplorável e doentia"; prova: componente único em `Traco/Componentes` (`CartaoDeResposta`, com os três estados), suíte com árvore própria no teste 4, jornada real no aparelho da conta em `large`, vídeo.

**Base.** O diff não comitado da cadeira irmã (worktree `superficie`) entrou como commit-base `dde4136`, com autorização do orquestrador: `CartaoDeResposta`, `Espera`, `ControleDeRetorno`, `Sessao.semRepetida`, jargão fora da tela nas três rotas. A dúvida aberta dela — as três notas são a MESMA ou três distintas — está respondida na tela do aparelho da conta (`sistema-ia-00-antes-34CC3F94-large.png`): são três notas distintas com o texto idêntico; a deduplicação por texto fica, porque duas notas com o mesmo texto são a mesma fonte PARA A PERGUNTA (nenhuma nota é apagada; só a montagem não repete).

## design-router, as seis fases

1. **Auditar antes de tocar (Fase 5, redesenho).** O "antes" é a captura viva do aparelho da conta às 14h40 (`sistema-ia-00-antes-34CC3F94-large.png`): "A SÁBIA, SOBRE: COMO USAR O TRACO?", resposta cortada em "CONTINUA", "Foram junto:" com a mesma nota três vezes, "serviu não serviu" soltos, "Fechar", e o campo "buscar ou perguntar". Cada item da §14 está nela.
2. **Ancorar.** A identidade do Traço é papel, letra e silêncio (§9): palavras em tinta suave, hierarquia por tipografia, nada de cápsula, selo ou balão. A conversa é uma FOLHA: pergunta em `chrome`/tinta suave (contexto), resposta em `corpo`/tinta (assunto), fontes e retorno em `meta`. O gesto de pedir é uma palavra em âmbar-tinta, a mesma cor do "Repetir"/"Instigar".
3. **Sistema.** Só tokens de `Tema`; `CartaoDeResposta` é a superfície única (Notas, Página, Lente) e ganhou o estado de falha; `Espera` e `ControleDeRetorno` reusados; `SinalDeSobra` apagado (a causa — o teto — sumiu).
4. **Construir.** `ConversaNotas.perguntando/modoPergunta`; `NotasView`: a folha na área da lista, a linha do pé com "perguntar"/"pergunte de novo", o único Fechar na topbar; `busca` só filtra no modo de busca.
5. **Mover.** Abrir a folha: opacidade em `Duracao.media` (`Tema.corte`), sem deslocamento; fechar sem animação (transação); Movimento Reduzido: `Tema.corte` devolve nil. O relógio da `Espera` é `TimelineView`, sem animação.
6. **Julgar/Portão.** G4 do Fable, e o dono vê o vídeo.

## curva-zero, em toques

| tarefa | antes | depois |
|---|---|---|
| perguntar a primeira vez | 2 (escrever, enviar) — mas o mesmo campo filtrava e perguntava | 3 (perguntar, escrever, enviar), sem ambiguidade |
| perguntar de novo | 3 (fechar, escrever, enviar), e a troca anterior sumia | 2 (escrever, enviar); a troca anterior fica |
| ler a resposta inteira | 1–2 rolagens dentro do cartão com teto de 220 pt | 0 |
| ver de onde veio | 0, mas a mesma nota 3× em cinza miúdo, sempre | 1, só se quiser; títulos tocáveis, uma vez cada |
| retorno | 1 (dois links soltos) | 1 (um controle) |
| fechar | 2 Fechar na tela | 1 |
| parar de esperar | não existia | 1 |

## Provas

**Build LIMPO** (worktree sem `build/`), teste 4 `A1DF082C`, 14h39–14h58: **1 warning**, o herdado de `NotasView.swift` (`'+' was deprecated`, ~:835). **Suíte integral**: `✔ Test run with 1033 tests in 164 suites passed after 152.591 seconds.` / `** TEST SUCCEEDED **`. Árvore própria provada pelas linhas exclusivas deste candidato: `✔ Test aRespostaNaoTemTeto() passed`, `✔ Test oModoDePerguntarNasceDoGestoOuDaConversa() passed`, `✔ Test aMesmaNotaTresVezesViraUma() passed`. **Sobre o binário FINAL** (build incremental, 15h50–15h53): `✔ Test run with 1033 tests in 164 suites passed after 152.096 seconds.` / `** TEST SUCCEEDED **`, com `aRespostaNaoTemTeto` e `oModoDePerguntarNasceDoGestoOuDaConversa` de novo; e a UI 4/4 de novo (corrida 5, 15h54, `** TEST SUCCEEDED **`). A contagem de warning vale só do build limpo: 1, o herdado.

**UI (esquema `TracoUITests`, teste 4, corrida 4, 15h50)** — a suíte integral não inclui este alvo: `EsperaComEstadoUITests.testAEsperaNasNotasMostraPensandoTempoEParar passed (8.981 s)`, `testARespostaTemPerguntaFontesRetornoEUmFechar passed (13.030 s)` (título = pergunta; "leu 4 notas suas" abre em 4 títulos; retorno → "anotado."; UM Fechar; a linha do pé diz "pergunte de novo" e volta a "buscar" ao fechar; **a avaliação sobrevive à troca de aba**); `PerguntaSobreviveUITests` 2/2 (o gesto "perguntar" + escrever + enviar; a conversa sobrevive à troca de aba). `** TEST SUCCEEDED **`. As corridas 1–3 falharam por dois motivos reais, os dois consertados: o contêiner da conversa era a rolagem (`scrollView` na árvore, e a suíte procura `otherElement`) e o retorno passava POR TRÁS da linha do pé no meio da rolagem (o teste agora rola até ele ficar acima dela).

**Jornada REAL no aparelho da conta `34CC3F94`, `large`, 15h40** (`ferramentas/orca/sistema-ia-conversa/`, script `sistema-ia-conversa.sh`, tudo numa chamada de `com-trava.sh`):
- conta: `15:40:25 CONTA (00): conectada - o Grok é o motor, pago pela sua` (antes) · `15:40:39 CONTA (01)` (depois do install) · `15:41:13 CONTA (11)` (depois da medida) — **as três "conectada"**;
- binário: **uma instalação por cima** às 15h11 (`860cf325…`; `cmp: o binario instalado E O MEU`); às 15h40 o instalado já era o meu e o script não reinstalou. Antes da volta o aparelho tinha `47d37050…`;
- pergunta real sobre notas reais do aparelho: *"Que riscos eu ja anotei sobre a virada do banco?"* → `02-notas-large` (a linha do pé: "buscar · perguntar") → `03-modo-perguntar-large` ("pergunte sobre as suas notas") → `04-escrita-large` (a lista NÃO filtra enquanto se pergunta) → `05-pensando-large` (a pergunta como título, "a sábia pensa…", "Parar de esperar", um Fechar) → `07-resposta-large` (**resposta inteira**, 9 s, "leu 2 notas suas ›" — as três notas idênticas viraram uma —, "serviu | não serviu", "pergunte de novo") → `09-fontes-large` (o título da nota, tocável) → `10-anotado-large` ("anotado.") → `11-perfil` (conta). **Vídeo**: `sistema-ia-conversa-15s.mp4` (o bruto de 25,9 s retimado por `setpts` a 15 s; o bruto de 8 MB não entra no git), enviado ao dono.
- **Defeito achado NA TELA e consertado no mesmo candidato:** depois de ir ao Perfil e voltar, "serviu / não serviu" voltava sobre a resposta já avaliada — a avaliação morava na `NotasView`, recriada a cada aba (ADR 09c). Mudou-se para `ConversaNotas.avaliadas`; o UI test guarda. O relógio "há N s" não aparece nas capturas porque a resposta chegou em 9 s (o número entra do 4º s e o quadro de 4,5 s já era a resposta); é o teste de UI que o prova andando.
- **Limite do instrumento:** o helper do `orca emulator` deixou de tocar depois da troca de aba (taps "ok" sem efeito); matar o `serve-sim` do UDID e reatar resolveu (memória: helper velho). A captura das fontes abertas veio nessa segunda passada, no mesmo estado.

**Antes/depois:** `sistema-ia-00-antes-34CC3F94-large.png` (14h40, a tela que o dono viu) × `07-resposta-large.png`.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota minha | evidência |
|---|---|---|
| Visão | 9 | §14/§15: a conversa é a primeira tela do sistema da IA; EVOLUCAO "Direção visual e uso simples" |
| Contrato | 9 | ADR 10f; LETRAS 10f uma vez; EVOLUCAO; ADR 05e substituída no ponto do campo |
| Correção | 9 | suíte 1033/164 verde (linhas coladas); 4/4 UI; teste novo por comportamento novo (modo, sem teto, avaliação sobrevive, falha junto da pergunta) |
| Jornada real | 9 | jornada no aparelho da conta com notas reais, capturas por estado (pedir, escrevendo, pensando, resposta, fontes, retorno, conta); falha/recolhida/sem-conta provados pelo ensaio e pela suíte, não fotografados na conta |
| Design | 8 | seis fases citadas; folha, tipografia, tokens; G4 decide — o G4 e o dono ainda não viram |
| Simplicidade | 9 | curva-zero em toques (tabela); um gesto por intenção; poder (fontes) encontrável |
| Movimento | 9 | opacidade em `Duracao.media`, fechar sem animação, Movimento Reduzido por `Tema.corte`; relógio sem animação; vídeo |
| Componentes | 9 | `CartaoDeResposta` único com três estados + previews; `SinalDeSobra` apagado; `ControleDeRetorno` e `Espera` reusados |
| Acessibilidade | 9 | rótulos e ids na árvore (pergunta, resposta, fontes, retorno, fechar), alvos 44 pt (medido no UI test), `large` |
| Performance | n/a | lista e folha sem trabalho novo por quadro; o relógio é `TimelineView` a 1 Hz |
| Privacidade e autoria | 9 | ADR 02o intacta: nada entra na nota; fontes deduplicadas sem apagar nota; selo/expressiva fora (`fonteParaPergunta`) |
| Estado honesto | 9 | pensando/tempo/parar, falha junto da pergunta com recuperação, "anotado.", sem-conta na língua do autor |
| Complexidade | 9 | `git diff --shortstat` contra a base da irmã: 14 arquivos, +243/−320 antes dos últimos consertos — a volta APAGA mais do que escreve |
| Fora do app | n/a | não toca |
| Relato | 9 | este arquivo + LACO uma linha |

## Limites e dívidas nomeadas

- **"Guardar como nota"** exige um caso `OrigemNota` para a sábia (Modelo, arquiteto); sem ele uma nota "da sábia" mentiria a origem. Até lá, o ato do autor é selecionar e copiar (ADR 02o).
- Os `.sheet` de versões/rede/série ficam na `regencia`, que não está na árvore enquanto a folha está aberta; nenhuma dessas folhas se abre a partir da conversa hoje.
- Astra no G0 não chegou a tempo (o agente estava bloqueado): o parecer entra como conferência.
