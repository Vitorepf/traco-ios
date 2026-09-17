# prova/e8-instigar-contrapor — as perguntas que instigam e o contraponto, remedidos. Régua registrada em 17/09/2026, antes da corrida

**Rotas:** `instigar` e `contrapor` (`Politica`: `indisponivelPorQualidade`, medidas em 10/09; "volta a ter executor quando algum passar a MESMA matriz"). Árvore pós-E7/E8-responder.

**Antes da medida (varredura das guardas que calam, líder 17/09):** `Sabia.parsePerguntas` — item que não é texto sai sozinho (antes a lista inteira virava nil); `Sabia.parseContraparte` — chave fora das cinco é ignorada (antes nil) e, em cada campo, sai só a FRASE com fato ou número que a pessoa não deu (antes o campo inteiro). `GuardaDeInstigar` e `GuardaDeContrapor` tiram um item e ficam como estão.

**Mudança na sonda (registrada):** o texto vai como a produção o manda — `Caderno.prosa(de:)` (Sessao e LenteView); em 10/09 ia cru. Isso muda o que se mede em relação a 10/09.

**Casos (`lote.json`, sha256 `0556410407632a8c…`, 34 casos × 3):**
- instigar, a MESMA matriz: `prova/instigar-cego-base-casos.json` (sha `b831b3c3…`), 8 casos — os dois cegos são `revisor-instigar-nota-que-ja-responde` e `revisor-instigar-fatos-negados`;
- contrapor, a MESMA matriz: `prova/q4c-contrapor-cego-casos.json` (sha `da012e21…`), 8 casos — os dois cegos são `revisor-contrapor-alternativas-negadas` e `revisor-contrapor-razoes-fechadas`;
- regressão: os 6 + 6 de `prova/q-qualidade-casos.json` (08/09: instigar 1/6, contrapor 1/6);
- novos: `casos-novos.json` (sha `213fd983…`), 3 + 3 **SINTÉTICOS**, escritos por agente cego ao código e ao caderno do dono.

**Braço:** só `grok-4.5` (decisão do líder: o 4.3 reprovou em 10/09 e o controle não muda a decisão). `TRACO_AVALIAR_MODELO=grok-4.5`, `TRACO_AVALIAR_LIBERAR=instigar,contrapor`. Bruto em `chamadasGrok[].bruto`.

**Leitura:** os mesmos dois leitores cegos, itens embaralhados, pelo PRINCÍPIO DA SÁBIA (fiel, não literal; não inventa; útil; sem gênero presumido; a IA nunca fala como a pessoa), cada item contra os seus `requisitos`, com um critério a mais (líder): **instigar** — a pergunta faz pensar sobre o que a pessoa escreveu, sem responder por ela e sem pedir o que ela já disse; **contrapor** — mostra o outro lado ou a opção que faltou com base no que ela escreveu, sem inventar fato. Um descumprimento em qualquer repetição reprova o caso.

**Barra, por rota (líder, 17/09):** os dois casos cegos cumprem **3/3**; a matriz **≥ 6 de 8**; os novos **≥ 2 de 3**; voz e gênero **0**; a regressão de q-qualidade não fica abaixo do medido em 08/09 (≥ 1 de 6). Passou: a rota aponta para o `grok-4.5` (como o `modeloMedido` das Notas), com teste, e volta à tabela. Não passou: `porque` com a causa e o conserto nomeado.

## Volta 1 — medida (Air, 17/09, binário `df75d134…`, corrida `77158A03`, `grok45.jsonl`)

102 respostas: 0 erros, 0 listas vazias, 0 contrapontos com os três campos vazios; guardas tiraram algo em 3. Leitura cega (`leitura-cega-veredictos.txt`, chave em `leitura-cega-chave.json`):

| rota | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (08/09: 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| instigar | 1 de 2 | **6 de 8** | **2 de 3** | 5 de 6 | 3 | 44 de 51 |
| contrapor | 0 de 2 | 2 de 8 | **2 de 3** | 0 de 6 | 11 | 28 de 51 |

**Não passou.** Causa, lida no código e NOSSA: os pedidos tratam quem escreve no feminino (`sistemaInstigar`, 10 vezes; o corpo do contrapor, 4) e nenhum leva o `semGenero` — o modelo devolve «enganada», «que ela fixou»; o `outroCampo` pede «um caso de outro campo (… época)» e o modelo afirma fato histórico (GPS, calculadora, fotografia) — 4 invenções que derrubam três casos; «passo básico» vaza (2), variante do andaime que a guarda não conhece. Depois: pergunta já respondida (2), substituto do que falta (1), argumento por fator que a nota tirou (2), contra vazio (1).

## Volta 2 — conserto e régua (autorizados pelo líder, registrados ANTES da corrida)

(a) Gênero pela raiz, em TODOS os pedidos do app (varredura dos `sistema*`): quem escreve vira "quem escreve", neutro, e o `semGenero` entra em todos. (b) `outroCampo`: analogia MARCADA ("é como quando…") ou pergunta ("isso lembra…?"), nunca fato histórico afirmado; sem analogia fiel, "". **Leitura:** analogia marcada não conta como invenção. (c) Andaime: "passo básico" na lista da guarda, e conferir "passo mais básico" e "movimento" soltos. Barra igual.

### Varredura de gênero nos pedidos (volta 2, antes da corrida) — o que achei e o que fiz

Busca por "ela/dela/ele/dele/o autor/a autora/sozinha/mesma" dirigido a quem escreve em todos os `sistema*` (117 ocorrências; a maioria não fala de quem escreve — "a mesma coisa", "dela" = a regra, a nota, o artefato):
- **Trocados agora para "quem escreve"/"a nota"/"a pessoa", com `semGenero`:** `sistemaInstigar` e `sistemaInstigarBase` (10 + 10), corpo do contrapor (14, os dois braços; e o `outroCampo` das duas formas), `sistemaRecordar` (1), `sistemaCalibrar` (3), `OficinaTrabalho.sistema` (2), `PraticaTrabalho.sistemaPreparar` (2) e `sistemaConferir` (1), `RevisaoTrabalho.sistema` (só `semGenero`), `PadroesRemoto.sistema` (só `semGenero`), e o próprio `semGenero` e o `vozDaObra` ("a pessoa — ela não disse" / "anotação dela").
- **Depois do commit da E9 volta 4, com remedida na próxima corrida dessas rotas:** `sistemaResponder` (30), `sistemaResponderNasNotas` (21) e `sistemaConferirNasNotas` (6) — estão em medida ou acabaram de ser medidos, e o que se commita tem de ser o que rodou.
- **Sem `semGenero` (só devolvem números ou estados, nada que a pessoa leia):** `sistemaEscolherRegra`, `sistemaEscolherSecoes`, `sistemaEscolherNotas`, `sistemaVestir`, `sistemaEcos` (trecho literal), `sistemaConferir` do Recordar (estados). `SinteseDeNota.sistema` já proíbe flexionar gênero; o `semGenero` entra junto dos pedidos das Notas, com a versão da leitura subindo.
- **Andaime:** no bruto medido vazaram "passo básico" (2) e "passo mais básico" (1) — os dois entram na guarda; "movimento" solto não vazou (0). A origem é o texto do degrau 0 ("Cobre o passo mais básico…"), que fica como está. **Corrigido pela suíte depois de a corrida `6598F42E` começar:** "passo mais básico" NÃO pode entrar na guarda — é a redação do degrau 0, e o invariante da ADR 09i (`oDegrauSobeComAPratica`) proíbe a guarda de conter o que o pedido diz. O binário da volta 2 roda com os dois na guarda; o commit leva só "passo básico". Na leitura da volta 2, contar "passo mais básico" no BRUTO: se voltar, o conserto é a redação do degrau 0, na volta seguinte.
- **Achado pela suíte DEPOIS de a corrida `6598F42E` (volta 2) começar:** as duas formas do contrapor ainda diziam "o que ela NÃO considerou", "contrária à dela", "o que ela já fixou", "as que ela listou", "na palavra dela; [] se ela não fecha nada" (7 linhas; "ela" ambíguo entre a nota e quem escreve). O teste novo (nenhum ela/dela nos quatro pedidos) as pegou; viraram "a nota". **O binário da volta 2 roda com essas 7 linhas no feminino; o commit leva "a nota".** Se a volta 2 passar com gênero 0, a diferença fica declarada aqui; se o gênero do contrapor não for 0, esta é a primeira causa a conferir, e a remedida roda no binário do commit. No mesmo passe, os rótulos das mensagens do Trabalho que falavam de quem escreve no feminino ("COMO ELA RECONHECE", "O TRECHO QUE ELA VAI EXERCITAR", "RESULTADO QUE ELA INFORMOU", "observação dela", "material dela", "contribuição dela") viraram "a pessoa".

## Volta 2 — medida (corrida `6598F42E`, grok-4.5, braço `esquema-da-saida`, `grok45-volta2.jsonl`)

Árvore da varredura de gênero ANTES das 7 linhas das formas do contrapor e com "passo mais básico" na guarda (ver acima; o commit `3cab6102` difere nisso). Pedidos: instigar `2c8de273…`, contrapor `a8a7e0a1…`. 102 respostas: 0 erros, 0 listas vazias, 0 contrapontos com os três campos vazios; guardas tiraram algo em 6; "passo mais básico" no bruto 3 (as três perguntas saíram pela guarda do binário medido — no commit, sem o termo na guarda, ficariam: o conserto é a redação do degrau 0). Leitura cega (`leitura-cega-volta2-veredictos.txt`, chave `leitura-cega-volta2-chave.json`, semente 202609176, mesmos dois leitores, regra nova "analogia marcada não é invenção"):

| rota | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (≥ 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| instigar | 1 de 2 (v1: 1) | **6 de 8** (v1: 6) | **3 de 3** (v1: 2) | **3 de 6** (v1: 5) | **0** (v1: 3) | 45 de 51 (v1: 44) |
| contrapor | 0 de 2 (v1: 0) | 3 de 8 (v1: 2) | 1 de 3 (v1: 2) | **2 de 6** (v1: 0) | 2 (v1: 11) | 34 de 51 (v1: 28) |

**Não passou nenhuma das duas.** O gênero caiu de 3 e 11 para 0 e 2 (os 2: «sozinho» sobre quem pratica ou carrega — masculino, que nenhum pedido usa). Causas, lidas no bruto:
- **instigar** — só a barra dos cegos: `revisor-instigar-nota-que-ja-responde` rep 1 pergunta «em que ponto a ligação de desculpa passou a valer como desfecho?» (leitor: fato suposto, leve); reps 2 e 3 cumprem. Fora da barra: pergunta pelo critério que a nota já deu (2, `qn-instigar-*`), nada do limite nem dos clientes (1), perguntas circulares (1).
- **contrapor** — (1) o `contra` defende manter o que a nota fechou (`revisor-contrapor-razoes-fechadas` reps 2 e 3: «preço justo, proximidade e horário livre»), com o `fechadas` preenchido no mesmo JSON; (2) a `foraDaLista` é variação do que a nota fechou («rollback ensaiado em volume sintético», «ensaio só em cópia sanitizada»: `revisor-contrapor-alternativas-negadas` 2 de 3); (3) a analogia MARCADA ainda afirma fato histórico («é como quando a calculadora se espalhou…», 5 — o requisito veta a calculadora pelo nome); (4) `contra` vazio (3); (5) «frequência zero» sem dado (1).
- **Conserto seguinte nomeado (não feito):** instigar — nenhum. A única falha da barra é um item leve em 1 de 3; remedir com o degrau 0 sem "passo mais básico" na redação. Contrapor — o `contra` e a `foraDaLista` nunca usam nem variam o que está em `fechadas` (conferido no nosso lado contra o próprio `fechadas`, frase a frase, como o `fatoQueEleNaoDeu`); o `outroCampo` só com estrutura, sem objeto ou episódio histórico; `contra` com `minLength` 1 no esquema.
