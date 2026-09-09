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
