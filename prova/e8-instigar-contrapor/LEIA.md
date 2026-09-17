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

## Volta 3 — conserto e régua (autorizados pelo líder em 17/09, registrados ANTES do código e da corrida)

**Para o dono ver:** na volta 2 a barra do instigar caiu por UM item de UMA repetição — `revisor-instigar-nota-que-ja-responde` rep 1, «Em que ponto a ligação de desculpa passou a valer como desfecho?», julgado pelo leitor cego como "fato suposto, leve" (a nota diz que ligou pedindo desculpa e o cliente não respondeu mais; a pergunta supõe que a ligação encerrou o assunto). As reps 2 e 3 do mesmo caso cumprem.

**Medida antes de escrever a guarda pedida para o contrapor (1)+(2), no bruto da volta 2:** a regra "frase do `contra`/`foraDaLista` que partilha radical de 5+ letras com um item do `fechadas`" atinge **54 frases, 29 delas em respostas que os leitores julgaram CUMPRE** — o contra bom começa aceitando o que foi fixado ("Com o piso de cinco quilômetros já fixado…"), e a palavra do fechado está nas duas. E perde o que devia pegar ("ensaio só em cópia sanitizada" não casa com "ambiente de teste com os dados reais"). É o defeito da ADR 2026-09-10d (`dependeDoQueElaFechou`, 4 erros em 5). **Decisão do líder: (A), só pelo pedido; se a volta 3 falhar por (1)/(2), a conferência por modelo (B) entra na seguinte, com o falso positivo medido neste mesmo bruto antes de ligar.**

**Conserto:**
- **instigar** — a redação do degrau 0 deixa de dizer "passo mais básico" ("Cobre o primeiro passo que este texto ainda não deu…"), e "passo mais basico" volta à guarda do andaime (o invariante da ADR 09i fica: a guarda não contém o que o pedido diz). Os degraus 1–4, que a varredura de gênero não pegou (estão em `Degraus.swift` e entram no pedido: "que ela escreveu", "como ela sabe", "se estiver enganada"), ficam neutros.
- **contrapor** (braço com esquema, e a forma antiga igual onde couber) — (A) `contra`: tudo o que está em `fechadas` é dado aceito; nunca defende manter, retomar ou reconsiderar um item de `fechadas`; ataca o que ficou aberto. `foraDaLista`: não é versão menor, parcial, adaptada nem meio-termo de um item de `fechadas`. (3) `outroCampo`: só pela ESTRUTURA do problema, numa situação comum, sem episódio datado, sem invenção, época ou pessoa nomeada; "" se não houver. (4) `contra` com `minLength` 1 no esquema.

**Mesma régua** (barra por rota da volta 1), mesmo lote (`lote.json`, sha `05564104…`), mesmos dois leitores cegos, mesmas regras de leitura (analogia marcada não é invenção; "é como quando a calculadora se espalhou" continua fato histórico). As duas rotas na mesma corrida. Passou: a rota aponta para o `grok-4.5`, com teste, e volta à tabela. Não passou: `conserto` na `Politica` com o texto do líder — instigar "falta a Sábia não supor um fato ao perguntar sobre o que a nota já respondeu"; contrapor "falta a Sábia não defender nem variar o que você já descartou, e não citar episódio histórico como exemplo".

**Ajustes da revisão adversarial, antes da corrida:** (1) o esquema proíbe o `contra` vazio, mas o corpo comum ainda admite "" nos campos — o braço com esquema ganha "o contra nunca é "": se a razão escrita sustenta a escolha, diga o limite real dessa razão" (o corpo continua byte a byte igual nos dois braços); (2) "sem episódio datado" deixava passar «é como quando a calculadora se espalhou» e o corpo ainda definia o campo como "analogia MARCADA… nunca fato histórico afirmado" — agora, no corpo e nas duas formas: analogia HIPOTÉTICA, no presente, pela estrutura ("é como alguém que…"), sem episódio histórico datado ou não, sem objeto técnico, época ou pessoa nomeada; (3) a regra do `contra` vale para "tudo o que a nota fechou, esteja ou não em fechadas" (o modelo já deixou item fechado fora da própria lista); (4) os degraus 2 e 3 não falam de "quem escreve" (convidavam pergunta em terceira pessoa): "de onde vem o que o texto afirma", "se o que o texto afirma não se confirmar". Sem medida nesta volta: o lote não tem caso de degrau 3.

**Correção da volta 2:** escrevi que o «sozinho» vinha de palavra "que nenhum pedido usa". Não é exato: as descrições de método em `Metodos.json` (woop, inversão, primeiros princípios, atualização, cinco porquês) falam de "o autor… ele" e entram no pedido do instigar e do contrapor quando a nota tem forma. O lote só usa `decisao`, cuja descrição é neutra — então não foi a causa aqui, mas é dívida da varredura (texto que também aparece na tela: passa pelo líder).

**Binário da volta 3:** montado DEPOIS dos commits do líder `462a25b2` e `9c516902` (Metodos.json sem «o autor… ele»; o `movimento` do WOOP e da Nota permanente neutros) — o `Metodos.json` dentro do app é idêntico ao de `9c516902`; dylib `783018c0…` (a árvore leva também a E9 volta 5, staged, que não toca instigar nem contrapor). Corrida `8F8A01A8`, grok-4.5, braço `esquema-da-saida`, lote `05564104…`.

## Volta 3 — medida (corrida `8F8A01A8`, grok-4.5, braço `esquema-da-saida`, `grok45-volta3.jsonl`)

102 respostas: 0 erros, 0 listas vazias, 0 contrapontos com os três campos vazios; guardas tiraram algo em 5; "passo mais básico" no bruto 0; "calculadora" 0; `contra` vazio 2 — os dois pelas NOSSAS guardas, não pelo modelo (`contra · tamanho` em `e8-contra-descartes-e-recurso-que-falta` rep 1; `contra · número que ele não deu` em `e8-contra-numeros-da-nota` rep 2). Leitura cega (`leitura-cega-volta3-veredictos.txt`, chave `leitura-cega-volta3-chave.json`, semente 202609177):

| rota | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (≥ 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| instigar | 0 de 2 (v2: 1) | 4 de 8 (v2: 6) | **3 de 3** | **3 de 6** | **0** | 38 de 51 (v2: 45) |
| contrapor | 0 de 2 (v2: 0) | **6 de 8** (v2: 3) | 1 de 3 (v2: 1) | **2 de 6** | 2 (v2: 2) | 36 de 51 (v2: 34) |

**Não passou nenhuma das duas.** Causas, lidas no bruto e no leitor:
- **instigar — piorou, e a causa é nossa:** a redação nova do degrau 0 ("Cobre o primeiro passo que este texto ainda não deu") voltou como molde da pergunta em 7 respostas («Qual primeiro passo este texto ainda não deu?») — o mesmo defeito do "movimento básico que se pula" e do "passo mais básico", com outra frase. Seguem: a pergunta pelo critério que a nota já deu (3) e não pedir o «quando» (2). **Lição:** qualquer sintagma nominal na instrução do degrau vira molde citável; o conserto seguinte é descrever o que cobrar sem nome de passo.
- **contrapor — a matriz passou (6/8), os cegos não:** o `contra` ainda defende as razões descartadas («preço justo, cinco minutos a pé e horário livre: manter», «vínculo baixo-atrito») em `revisor-contrapor-razoes-fechadas`, e a `foraDaLista` ainda varia a saída fechada («ensaio numa restauração isolada», «janela de manutenção com critério de abortar») em `revisor-contrapor-alternativas-negadas` — as causas (1)/(2), agora sem a analogia histórica (0) e sem calculadora. Nos novos: os dois `contra` vazios das guardas e «bem não urgente». Pelo líder: a conferência por modelo (B) é a próxima alavanca, com o falso positivo medido neste bruto antes de ligar.
- **Politica:** as duas seguem `indisponivelPorQualidade`, `medidaEm` 17/09/2026, `conserto` pelo texto do líder — instigar "falta a Sábia não supor um fato ao perguntar sobre o que a nota já respondeu"; contrapor "falta a Sábia não defender nem variar o que você já descartou" (sem "e não citar episódio histórico como exemplo": a volta 3 mediu 0).

## Volta 4 — conserto e régua (ordem do líder em 17/09, registrados ANTES do código e da corrida)

**Medidas no bruto antes de escrever (v2+v3):**
- *Guarda do critério já dado (instigar):* "a pergunta tem «critério» e a nota traz a razão (`porque`, `pois`, `já que`, `critério`)" tira **6** perguntas nas duas voltas — **5** em respostas NÃO por "pergunta já respondida: o critério" e **1** em resposta CUMPRE. Sem a condição da razão na nota tiraria 9 perguntas boas (sala × casa, onde a nota não dá critério).
- *Ecos dos degraus no bruto da v3:* degrau 0 "primeiro passo" 16, "trata como resolvido" 7, "ainda não deu" 6; degrau 2 "mostraria o contrário" 8; degrau 4 "deixa de valer" 3 — só os do degrau 0 são sintagma nominal lido como andaime.
- *O «quando» (V042, V050):* o requisito de `qn-instigar-contexto-insuficiente` ("Não deu certo de novo.") pede a pergunta que faça nomear o quê, QUANDO e o que era dar certo — a falha foi NÃO pedir o quando (a instrução do degrau 0 competia com a regra da nota magra). Regra: "se a nota não diz quando e não diz que não sabe, uma pergunta pede quando".

**Conserto — instigar:** (1) os cinco degraus descrevem o que cobrar só em verbos sobre o texto, sem sintagma nominal que vire pergunta (nada de "passo", "movimento", "primeiro…"); um teste lista os sintagmas nominais de cada degrau e falha se algum aparecer no bruto da última corrida, com o "primeiro passo" da v3 como sonda que acusa; (2) no pedido, duas linhas curtas: não perguntar pela razão ou critério que a nota já deu; se a nota não diz quando e não diz que não sabe, uma pergunta pede quando; (3) `GuardaDeInstigar` ganha a perna do critério (a medida acima).

**Conserto — contrapor:** (1) as guardas de tamanho e de número que a nota não deu tiram só a frase do `contra` e nunca o deixam vazio — se sobrar vazio, fica o original (os 2 vazios da v3 eram delas); (2) **(B), a conferência por modelo**, só entra se passar a barra do falso positivo abaixo.

**Medida do falso positivo da (B), antes de ligar:** uma chamada nova (`grok-4.5`, pela sonda no Air) recebe a nota e as frases numeradas do `contra` e da `foraDaLista` e devolve as que defendem, retomam ou usam o que a nota fechou, ou propõem versão, parte, substituto ou meio-termo de uma saída fechada. Roda sobre as **102 respostas do contrapor já julgadas** (51 da v2 + 51 da v3, a saída que os leitores leram). Conta: frases que ela tiraria de respostas **CUMPRE** ÷ frases de respostas CUMPRE. **Barra: ≤ 5%.** Registrado junto, sem barra: quantas das respostas NÃO pelas causas (1)/(2) ela pegaria. Passou → entra na volta 4; não passou → a volta 4 vai sem ela e o contrapor para.

**Régua da volta 4:** a de sempre (barra por rota), mesmo lote `05564104…`, mesmos leitores cegos, as duas rotas na mesma corrida.

**(B) medida e NÃO ligada** (corrida `4DA61EEF`, grok-4.5, `b-conferencia/lote.json` sha `fa625a09…`, `b-conferencia/medida-grok45.jsonl`, contagem em `b-conferencia/contagem.txt`): 102 respostas, 0 erros. Frases de respostas CUMPRE apontadas: **81 de 142 = 57%** (barra ≤ 5%), em 53 das 70 respostas aprovadas. Das 9 respostas NÃO pelas causas (1)/(2), pegou 5. O modelo lê como "defesa do fechado" o contra que só argumenta a partir dele («Com o piso de cinco quilômetros já fixado…», «Com reserva de só três meses…») e aponta quase toda `foraDaLista`. **A volta 4 vai sem ela; depois da volta 4 o contrapor para** (líder). A função fica sem chamador na produção, com a medida no comentário.

**Achado ao escrever o teste da guarda de número (antes da corrida):** o `contra` da geladeira saiu vazio na v3 porque `numeroAlheio` partia "R$ 3.600" em "3" e "600" — "3600" na frase parecia número inventado. O separador entre dígitos agora não parte o número (conserto na raiz da guarda, junto do "nunca vazio" pedido).

## Volta 4 — medida (corrida `026DF0EA`, grok-4.5, braço `esquema-da-saida`, dylib `94c288b2…`, `grok45-volta4.jsonl`)

102 respostas: 0 erros, 0 listas vazias, 0 contrapontos com os três campos vazios; `contra` vazio 1 (guarda de FATO, que segue apagando); sintagmas dos degraus novos no bruto: **0**; "primeiro passo": 0. Leitura cega (`leitura-cega-volta4-veredictos.txt`, chave `leitura-cega-volta4-chave.json`, semente 202609178):

| rota | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (≥ 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| instigar | 1 de 2 (v3: 0) | 3 de 8 (v3: 4) | 0 de 3 (v3: 3) | **3 de 6** | **0** | 33 de 51 (v3: 38) |
| contrapor | 0 de 2 (v3: 0) | 5 de 8 (v3: 6) | **2 de 3** (v3: 1) | **4 de 6** (v3: 2) | **0** (v3: 2) | 41 de 51 (v3: 36) |

**Não passou nenhuma das duas.**
- **instigar — piorou de novo, por nossa causa:** a linha nova "Se a nota não diz quando e não diz que não sabe, uma das perguntas pede QUANDO" virou fórmula em quase todo caso («Quando essa regra de três vídeos por semana passou a valer no mercado?», «Quando essa espera por uma hora livre costuma surgir?») — 10 reprovações por andaime e 2 por fato suposto nela. O pedido já mandava pedir o quando só na nota magra; a linha incondicional generalizou. Os degraus em verbos não voltaram como molde (0 no bruto). **Lição, a mesma da v3 por outro lado:** toda instrução incondicional de UMA pergunta vira molde em todas as notas. **Conserto seguinte nomeado (não feito):** tirar a linha do QUANDO (a regra da nota magra já cobre `qn-instigar-contexto-insuficiente`); ficam os degraus em verbos e a perna do critério.
- **contrapor — a melhor volta (41/51, gênero 0, novos e q-qualidade na barra), mas os cegos não:** o `contra` ainda usa as razões descartadas («com preço, distância e horário já fora de questão, manter», «a ida exige só sair de casa») e a `foraDaLista` ainda varia a saída fechada («ensaio completo da virada numa réplica isolada», «condição clara de parar no meio»); duas propõem «outra pessoa» que a nota não tem. As guardas de número e tamanho não esvaziaram nenhum contra. **Pela regra do líder, o contrapor para aqui** — a (B) reprovou no falso positivo, e o pedido sozinho não fecha os cegos em quatro voltas.

## Volta 5 do instigar — só subtração (líder, 17/09; registrada ANTES do código e da corrida; a última)

**Contrapor:** parado com a medida da volta 4 (ADR 17j); não roda nesta volta.

**Conserto:** tirar do `sistemaInstigar` a linha incondicional "Se a nota não diz quando e não diz que não sabe, uma das perguntas pede QUANDO." Ficam os degraus em verbos, a perna do critério na `GuardaDeInstigar`, a linha do critério já dado e a regra da nota magra que já existia. Nenhuma linha nova, nenhuma guarda nova. **Regra do líder daqui em diante:** nenhuma instrução incondicional sobre UMA pergunta ou UMA forma de frase — condição explícita ou não entra.

**Perguntas que começam por «Quando»** (bruto, antes desta volta): v1 8 de 202; v2 8 de 210; v3 7 de 208; **v4 28 de 212**.

**Régua:** a mesma do instigar, os 17 casos do instigar do mesmo lote `05564104…`, separados sem mudar uma letra em `lote-instigar-volta5.json` (sha `d9c5c30288dbe2d1…`), mesmos dois leitores cegos, e a contagem de «Quando» lado a lado. **Não passou → o instigar para como o contrapor e a frente volta ao líder para redesenho: sem volta 6 por prompt.**

## Volta 5 do instigar — medida (corrida `C04C701E`, grok-4.5, dylib `205891b4…`, `grok45-volta5-instigar.jsonl`)

51 respostas: 0 erros, 0 listas vazias, guardas tiraram algo em 0. Perguntas que começam por «Quando», lado a lado: v1 8/202 · v2 8/210 · v3 7/208 · v4 **28/212** · **v5 6/206**. Leitura cega (`leitura-cega-volta5-veredictos.txt`, chave `leitura-cega-volta5-chave.json`, semente 202609179):

| volta | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (≥ 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| v1 | 1 de 2 | 6 de 8 | 2 de 3 | 5 de 6 | 3 | 44 de 51 |
| v2 | 1 de 2 | 6 de 8 | 3 de 3 | 3 de 6 | 0 | 45 de 51 |
| v3 | 0 de 2 | 4 de 8 | 3 de 3 | 3 de 6 | 0 | 38 de 51 |
| v4 | 1 de 2 | 3 de 8 | 0 de 3 | 3 de 6 | 0 | 33 de 51 |
| **v5** | **1 de 2** | **6 de 8** | **2 de 3** | **5 de 6** | **0** | **43 de 51** |

**Não passou** — só a barra dos cegos: `revisor-instigar-nota-que-ja-responde` cai em 2 das 3 repetições por fato suposto («a de 8.400 passou a valer?», «passou a valer para os dois?» — a nota diz que o cliente não respondeu). É o defeito que o `conserto` da `Politica` já nomeia. Fora da barra: a fórmula de relação («se contradizem ou um depende do outro?») repetida no caso do capítulo (3 andaimes). **Pela regra do líder, o instigar PARA como o contrapor, e a frente volta ao líder para redesenho: sem volta 6 por prompt.**
