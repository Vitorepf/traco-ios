# G3 independente — Q2 `responder`

09/09/2026 · revisor independente · commit avaliado `3c4213b` · sem correção
funcional. **Veredito: NÃO APROVAR. `responder` permanece
`indisponivelPorQualidade`.**

O motivo não é substituir a decisão do dono sobre a espera. A condição dura do
conselho — três inferências novas, sem memo, para casos que o implementador não
escreveu — não foi completada: a conta do único aparelho autorizado caiu depois
do install por cima, e não a contornei.

## Escopo, rota e leitura independente

Li por inteiro o parecer do conselho, o relatório Q2, a ADR 2026-09-08z, a
fixture e os cinco JSONL. Li também as 36 saídas inteiras de
`prova/q2-responder-modelo46.jsonl`: 12 casos, três lançamentos, sem erro,
`grok-4.6` solicitado/respondido, esforço `medium`, `responder` liberado só
para a sonda. A agregação direta do JSONL dá 19,38 s a 77,46 s, média 36,12 s.

A sonda chama `Sabia.responder` em `Traco/Analise/AvaliacaoIA.swift:207-209`.
O cartão de produção chama a mesma função em `Traco/App/Sessao.swift:551-580`;
logo não é a sobrecarga fantasma que invalidou a medição anterior de
`responderNasNotas`. A produção, porém, continua bloqueada pela `Politica`, e a
sonda a abre apenas em DEBUG: isto mede motor, não entrega uma superfície ao
autor.

Minha leitura das 36 respostas existentes não encontrou fabricação de número,
horário, terceiro, suporte ou ação já realizada; tampouco recusa integral de
pedido atendível. Elas atendem os requisitos das doze fixtures na amostra
registrada. Isso é evidência favorável limitada, não a aprovação: faltam os
casos novos exigidos pelo próprio portão.

## Casos novos do revisor e interrupção obrigatória

Escrevi seis casos que o implementador não viu em
`prova/q2-revisao-responder-casos.json`:

1. orçamento em moeda estrangeira e cotação datada: cálculo parcial sem dizer
   que há aprovação, estoque, imposto ou entrega;
2. revisão de slides sem responsável por apresentar;
3. retomada de proposta em celular sem inventar PDF, aplicativo ou pasta;
4. proposta enviada sem transformar em venda observada;
5. espanhol 3×5 sem áudio, internet ou outra pessoa;
6. correção explícita de R$ 600 sem exigir confirmação formal nem inventar
   fornecedor ou pagamento.

Usei somente o `C2416CBC-C5D9-41F9-ACD8-45EED8FC355E` para IA, sem `erase`,
`clearState`, `uninstall`, `xcodebuild test`, maestro, `orca emulator`, voz,
VoiceOver ou iPad. A fumaça pré-instalação, às 03:20:38Z, tinha
`contaGrokLigada:true` e 12 modelos. A instalação por cima do candidato
transitório foi seguida da fumaça obrigatória às 03:22:07Z, que registrou
`contaGrokLigada:false`, zero modelos e `Falha.semRetorno`; interrompi o app.
Os seis casos novos começaram já sem conta e retornaram `semRetorno`, portanto
não são inferências válidas e não contam nem como passe nem como reprovação de
conteúdo. A cópia completa é
`prova/q2-revisao-responder-interrompida.jsonl` (SHA-256
`32fe80c474352776d0fed3cf2b86407f8c0c5f96f4e5be613fd19f0b26d8b042`).

O build do candidato transitório, sob `ferramentas/orca/com-trava.sh`, terminou
em `** BUILD SUCCEEDED **` no derived data isolado. Não rodei a suíte: depois da
perda da conta, um verde de host não supriria a prova ausente e não justifica
continuar tocando aparelhos. O `B91C8DEF` não foi usado para IA e está desligado.

## Reexame dos seis antigos

O antigo “3 de 6” não é gabarito semântico. Em
`prova/q-qualidade-avaliacoes.jsonl`, as três respostas de gasolina têm números
ou margem escolhidos sem evidência em pelo menos uma execução; as de prazo
impõem confirmação formal/terceiro ou inventam cliente; as do relatório inventam
páginas, sumário, PDF, gráficos, tabelas ou seções. Biblioteca tem uma execução
que crava 13h. Só esses descumprimentos já derrubam cada caso sob a regra de
“uma execução reprova”; eles confirmam a ressalva do conselho sobre as linhas
133/325/327/521 e não dão base para conservar o placar antigo.

## Atribuição das alavancas

A atribuição do **prompt contra número** é razoável no escopo medido: as quatro
primeiras séries mantêm `grok-4.3` e alteram o prompt; nas três variantes de
candidato não reaparece total de gasolina nem horário inventado. A atribuição
de **modelo contra cenário** não está isolada: a quinta série troca junto modelo
4.3→4.6, esforço `none`→`medium` e timeout 20→240 s. O timeout não encostou na
amostra, mas modelo e esforço continuam confundidos; a evidência sustenta a
configuração conjunta `grok-4.6`/`medium`, não a frase causal de que só o modelo
matou a invenção de cenário.

## Scorecard e notas Q2

| dimensão de `QUALIDADE-IA.md` | nota nova | evidência e decisão |
|---|---:|---|
| aderência ao pedido | inconclusiva | as 36 antigas são favoráveis; 18 inferências novas obrigatórias não existem |
| correção sustentada | inconclusiva | não há novo conteúdo válido; a atribuição modelo/esforço também é confundida |
| utilidade concreta | inconclusiva | novos casos de recusa covarde não produziram saída para leitura |
| destinatário e divisão de trabalho | inconclusiva | não houve saída nova para testar responsável, venda e decisão de compra |
| uso do contexto pertinente | inconclusiva | não houve saída nova para testar cotação, correção e ausência de suporte |
| estado honesto | 9 | a política continua bloqueada; relatório e prova declaram a interrupção |
| privacidade e autoria | 9 | leitura do diff: a abertura de avaliação é DEBUG, não há executor em Release |
| correção de build | 9 | candidato transitório compilou sob trava; isto não substitui a bateria semântica |
| performance | não aprovada | os 36,12 s médios / 77,46 s máximos existem, mas o dono aceita o preço e a nova amostra não ocorreu |

Não há mudança de nota das cinco dimensões de qualidade: a proposta “9” do
implementador permanece proposta, não passa a nota oficial. A condição para
retomar é o dono reautorizar a conta no `C2416CBC`; depois, uma nova revisão
deve instalar por cima, checar a conta antes de cada lançamento e executar os
seis casos acima três vezes, lendo integralmente as 18 saídas. Não use outro
simulador, não limpe o atual e não recupere a conta por automação.

## Nova tentativa após a reautorização declarada

**Veredito permanece: NÃO APROVAR.** Antes de instalar qualquer candidato ou
de disparar os casos cegos, preservei o JSONL anterior e executei a fumaça
limpa `q2-fumaca.json` no único aparelho autorizado,
`C2416CBC-C5D9-41F9-ACD8-45EED8FC355E`. Às `2026-09-09T04:30:19Z`, a corrida
`786451F2-34AF-4255-88E7-5DE38FFFE011` registrou
`contaGrokLigada:false`, `Falha.semRetorno` e nenhuma chamada Grok; a cópia
permanece em
`.../Containers/Data/Application/F834D0EC-B9F1-47DE-BC15-F5E8B014B51F/Documents/avaliacoes-ia.jsonl`.

Interrompi ali: sem `erase`, `clearState`, `uninstall`, instalação por cima,
`xcodebuild test`, voz, VoiceOver, iPad, Maestro ou outro aparelho. Portanto
não há inferência nova válida, nem mudança de nota nas cinco dimensões:
aderência, correção sustentada, utilidade, destinatário/divisão de trabalho e
uso do contexto continuam **inconclusivos**, e `responder` continua
`indisponivelPorQualidade`. O `B91C8DEF` não foi iniciado: build/suíte não
substituiriam a pré-condição perdida nem autorizariam contornar a conta.

## Q2-C — casos cegos sem instalar: interrupção antes da primeira inferência

**Veredito: NÃO APROVAR.** Não houve corrida dos seis casos nem há alteração de
nota: a fumaça obrigatória, antes da primeira corrida, voltou a achar a conta
desligada. Parei antes de lançar a fixture de casos, portanto não há uma falsa
fumaça de fecho nem uma saída sem retorno sendo contada como inferência.

### Candidato e instrumento

O aparelho autorizado continua sendo o iPhone 17 Pro
`C2416CBC-C5D9-41F9-ACD8-45EED8FC355E`; não instalei, apaguei, desinstalei,
limpei estado ou rodei testes nele. A fixture já presente no Documents é a que
o revisor escreveu, `q2-revisao-responder-casos.json`, SHA-256
`e3ace2b6ae91d27bff4266303d542b33a2f21625aff32fcb51b9c079cffbd08e`, com os
seis casos e uma repetição por lançamento; ela não foi reescrita nem lançada.

O `Traco.debug.dylib` instalado tem SHA-256 `25d2ed41951…`, diferente do
`461de14a…` registrado para a v3 no relatório Q2. Uma compilação limpa do
código de `3c4213b` passou (`** BUILD SUCCEEDED **`, sem instalar em simulador),
mas também gerou outro hash (arm64 `49c302e6…`): o artefato não é
byte-identificável por esses hashes. Os marcadores funcionais conferíveis no
dylib instalado e no candidato — `sistemaResponder` v3 (inclusive “Não suponha
o cenário”), `TRACO_AVALIAR_LIBERAR`, `indisponivelPorQualidade` e a assinatura
de `Sabia.responder` — coincidem. Isso sustenta compatibilidade funcional, não
uma atribuição criptográfica do bundle a `3c4213b`; por isso a próxima passada
deve registrar também o artefato que o dono aceita medir, sem instalar nada.

### Fumaça e parada

A corrida `C27FE4AC-0622-434F-A08D-44D753A01676`, às
`2026-09-09T05:42:01Z`, lançou somente `q2-fumaca.json` por
`SIMCTL_CHILD_TRACO_AVALIAR_IA` e terminou com `contaGrokLigada:false`, nenhuma
lista/modelo disponível (contagem observável: 0), `Falha.semRetorno` e
`chamadasGrok:[]`. A evidência preservada é
`prova/q2-revisao-responder-q2c-conta-indisponivel.jsonl` (SHA-256
`95f836599d06263e8c74fee347e2a8811760c93e7ec12e6ce3affb34edf6f450`). Não há
fumaça posterior porque nenhuma corrida de caso começou; não havia conta a
proteger entre as duas.

Não usei voz, Siri, ditado, VoiceOver, iPad, Maestro, `orca emulator`, mouse ou
outro simulador. A compilação foi protegida por `ferramentas/orca/com-trava.sh`;
não rodei suíte, pois um verde local não resolve conta ausente nem mede a
qualidade semântica.

| dimensão de `QUALIDADE-IA.md` | nota Q2-C | motivo |
|---|---:|---|
| aderência ao pedido | inconclusiva | 0/18 novas saídas para ler |
| correção sustentada | inconclusiva | não houve caso de fabricação de cenário válido |
| utilidade concreta | inconclusiva | não houve caso de recusa covarde válido |
| destinatário e divisão de trabalho | inconclusiva | responsável, venda e compra não chegaram ao motor |
| uso do contexto pertinente | inconclusiva | cotação, suporte e correção não chegaram ao motor |

`responder` permanece `indisponivelPorQualidade`. Para retomar, o dono precisa
reativar a conta neste mesmo aparelho e a revisão precisa obter fumaça com conta
ligada e lista autenticada de modelos antes e depois de cada um dos três
lançamentos; só então pode ler integralmente as 18 saídas. Mesmo nesse cenário,
uma aprovação só pode cobrir a configuração que o JSONL efetivamente registrar:
o binário atual declara `grok-4.3`; não há evidência nova de
`grok-4.6`/`medium`.

## Q2-D — conta recuperada, binário incompatível: parada antes da leitura

**Veredito: NÃO APROVAR.** A conta voltou, mas o binário já instalado no
`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` não contém o protocolo de avaliação do
candidato `3c4213b`; sem instalar por cima — ordem expressa desta volta — não
há como obter as 18 inferências exigidas.

Segurei `ferramentas/orca/com-trava.sh` para cada acesso ao instrumento, não
instalei, apaguei, desinstalei, limpei estado, rodei testes, Maestro, voz,
VoiceOver, iPad ou outro simulador. A fumaça prévia, corrida
`081D7BB5-1CC9-4961-AA8D-2233FBCA33CE`, às `14:00:47Z`, e a posterior, corrida
`951BFC20-AA41-4015-81AE-8B132C7ED88E`, às `14:04:07Z`, registraram
`contaGrokLigada:true` e os mesmos 12 modelos autenticados, inclusive
`grok-4.6`; portanto a conta **não caiu**.

As duas tentativas com os seis casos existentes, sem reescrever a fixture,
terminaram em `Falha.semRetorno` em cerca de 0,001 s e `chamadasGrok:[]`. A
segunda foi lançada também com
`SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=responder`, porém suas linhas não têm o
campo `operacoesLiberadasParaAvaliacao` que `3c4213b` grava; isso prova que o
app instalado ignora a abertura DEBUG e não é o binário avaliável. A evidência
integral é `prova/q2-revisao-responder-q2d-instrumento-incompativel.jsonl`
(SHA-256 `1fc6b8b9f9ddac10cf7b59b4dbc85e73c85c514d2fc4dbadfd4b9928a6231bd3`).

| dimensão de `QUALIDADE-IA.md` | nota Q2-D | motivo |
|---|---:|---|
| aderência ao pedido | inconclusiva | 0/18 novas saídas chegaram ao provedor |
| correção sustentada | inconclusiva | a política do binário instalado bloqueou todos os seis casos |
| utilidade concreta | inconclusiva | não há resposta a ler |
| destinatário e divisão de trabalho | inconclusiva | responsável, venda e compra não alcançaram o motor |
| uso do contexto pertinente | inconclusiva | cotação, suporte e correção não alcançaram o motor |

`responder` permanece `indisponivelPorQualidade`. Para retomar, o responsável
precisa autorizar uma única instalação por cima do binário que contém `3c4213b`
e então a revisão relança esta mesma fixture três vezes, conferindo a conta
antes e depois de cada uma; sem isso, não há hora honesta de retorno nem cartão
real a capturar.

## G3-E — revisão de `5c07138`: a adoção global não se sustenta

**Veredito: NÃO APROVAR. Sim: peço a reversão, em `main`, da adoção da ADR
2026-09-09n (commit `5c07138`), incluindo `Grok.modelo = grok-4.6` e a saída de
`responder` de `indisponivelPorQualidade`.** A correção visual é boa, mas não
autoriza transformar uma escolha de modelo não decidida em padrão de todas as
rotas.

### Findings

**[P1] A comparação que escolheu o padrão global não é pareada.** O relatório
diz que somente `TRACO_AVALIAR_MODELO` variou (Q2-E, linhas 47--60), mas ele
também declara `TRACO_AVALIAR_SEM_ESFORCO=1` no lado 4.20 (linhas 39--45).
`Grok.corpo` omite de fato `reasoning_effort` quando essa chave está ligada
(`Traco/Analise/Grok.swift:61-67,247`); o 4.6 recebeu `medium`, o 4.20 recebeu
uma requisição diferente. O JSONL registra `esforco: medium` nos dois lados,
mas esse é o argumento Swift de `Diagnostico`, não uma prova do corpo HTTP
enviado (`Grok.swift:205-220`). Portanto os 12/12 contra 9/12 não isolam o
modelo, e não podem decidir o modelo global.

**[P1] A triagem não deixa somente dois candidatos por fato observado.** A
listagem autenticada preservada em `prova/q2e-fumaca-fecho.jsonl` entrega IDs,
não capacidades. Não há corrida de qualidade de `grok-4.5`; o seu corte é
"abaixo do 4.6 na mesma linha". `grok-build-0.1` e
`grok-4.20-0309-non-reasoning` também caem por leitura do nome/posição, não por
uma capacidade declarada ou resultado. A própria ADR 09n reconhece ao fim que
4.5 e non-reasoning foram cortados por nome e posição. Eles voltam para a
disputa antes de se afirmar "o melhor Grok possível".

### O que confirmou

Os três defeitos atribuídos ao 4.20 são reais nas saídas completas: ele inventa
a regra de vigência no prazo conflitante, não fornece 5+5+5 e limita espanhol
por material ausente, e atribui ao autor um relatório "aberto agora" seguido de
`(487 caracteres)` (`prova/q2e-modelo-420.jsonl`). As doze respostas do 4.6
atendem aos requisitos da fixture escrita pelo implementador; isso é evidência
favorável, não o portão independente nem a comparação necessária para padrão
global.

O piso cobre os chamadores atuais: não restou `esforco: "none"`; os defaults de
`Grok.responder`, `Sabia.chamar` e `chamarComProveniencia` são `low`, enquanto
as rotas deliberadas pedem `medium`/`high`. A remoção de `timeout: 10`,
`modeloTrabalho` e `tetoTrabalho` não deixou chamador órfão, e `Grok.teto = 240`
cobre tanto 77,5 s como o piso histórico de 179 s. Isto não repara o finding:
9 chamadas de transporte não provam a qualidade das demais rotas.

### Tela, fases e limites

Abri as três capturas: a espera mostra pergunta, contador de 22 s e
"Parar de esperar"; a resposta limita consumo/preço e conserva 600 km; o
cancelamento devolve a pergunta e "Perguntar à sábia". Auditar, Ancorar,
Sistema, Construir e Mover estão demonstrados; Julgar/Portão recebe **9** nesta
revisão visual, sem descontar a ausência de voz/VoiceOver, que foi corretamente
proibida. A captura atual em `ferramentas/orca/revisao-q2-pos-launch.png` mostra
o app do binário instalado abrindo em Notas, sem tocar texto do dono.

Não rodei uma segunda suíte: o `34CC3F94-FDB5-4575-A4F5-80271829A18B` já estava
ligado e, ao pedir coordenação, havia uma corrida de outro trabalhador protegida
por `com-trava.sh`; não desliguei nem disputei o aparelho. A sonda sem instalação
no `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` apenas relançou o binário já instalado;
as capturas estão em `ferramentas/orca/revisao-q2-*.png`, e não houve queda de
conta observada.

| dimensão | nota | evidência |
|---|---:|---|
| Correção/modelo global | 0 | dois P1: candidato incompleto e medição com duas alavancas |
| Qualidade da IA | 0 | o portão de escolha global não foi cumprido; uma falha reprova |
| Estado honesto | 9 | piso/teto e saída visível no cartão |
| Jornada real | 9 | três capturas abertas, inclusive cancelar sem perda |
| Design | 9 | seis fases julgadas; componente e tokens existentes |
| Simplicidade/Ponytail | 9 | reutiliza `LinhaDeEstado`, sem componente ou configuração nova |
| Acessibilidade | 9 | captura legível; leitura falada não exercida por proibição explícita |
| Privacidade/autoria | 9 | não há texto do autor escrito pela resposta; a falha permanece visível |
| Performance | 7 | 38,3 s de média e 77,5 s máxima são aceitáveis somente se o modelo estiver aprovado |

O item abaixo de 9 basta para **CORRIGIR ANTES**. A próxima medição deve manter
fixture, binário, aparelho, prompt, temperatura e corpo HTTP idênticos, ou
declarar que compara configurações e não coroar um vencedor global; deve também
medir os candidatos devolvidos à disputa e usar casos do revisor antes de nova
adoção.
