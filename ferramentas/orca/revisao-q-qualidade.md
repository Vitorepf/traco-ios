# G3 — revisão independente da volta Q

## Veredito: CORRIGIR ANTES

O corte das sete rotas é correto e executável, mas a ADR identifica o candidato e a disponibilidade com números contraditórios. Pior: manter produzir, prepararPratica e revisar como oferta contradiz a regra de que timeout material significa operação ausente para o autor — prepararPratica atende só 1/6.

Revisor independente de quem implementou/mediu. Não alterei Swift nem commitei. Havia WIP alheio de Perfil; não o julguei como entrega.

## Instrumento, candidato e evidência

325c819, declarado candidato, é o pai de acdfcb4, commit que contém os 15 arquivos da Q. Portanto ADR e q-qualidade.md não identificam o binário que implementa a decisão.

Para isolar o WIP, fiz worktree destacada em acdfcb4, build genérico sem warning e instalei seu app por cima no C2416CBC. Nunca usei erase, clearState, uninstall nem xcodebuild test no aparelho com Grok, e não toquei Safari. Li no Perfil, antes e depois da instalação: “conectada — o Grok é o motor, pago pela sua assinatura.” A corrida F71D3BDC gravou contaGrokLigada:true nos 12 inícios.

No 34CC3F94, com-trava.sh xcodebuild test e parallel-testing-enabled NO passou 914 testes / 149 suítes. O único warning foi PerfilView.swift:648, WIP da outra frente, não atribuído à Q. Li as 610 linhas de prova/q-qualidade-avaliacoes.jsonl — entradas, saídas e erros, não hashes. A contagem fecha: 297 execuções de rota e uma fumaça de modelos.

## Casos novos do revisor

Fixture: prova/q-revisao-casos.json, SHA-256 4747b4c8948114ecd2a03f48cfbc237c10002356481d71fd247669a13c72a13c. Saídas integrais: prova/q-revisao-avaliacoes.jsonl, SHA-256 a9ad6d9a572c82b668afcebb0cf3b867373603e2b63f7b445e826bf08f33518f.

| caso novo, não visto pelo implementador | caminho executado | resultado | veredito |
|---|---|---|---|
| r3-conferir-negacao-com-unidades | Sabia.conferir | 3/3 [1] | passa: negou corretamente 2 L/R$300 e reconheceu somente 14h. |
| r3-responder-custo-sem-dados | Sabia.responder | 0/3, Falha.semRetorno, sem chamada | confirma o corte; não é aprovação nova. |
| r3-notas-fato-atual-com-orcamento | Sabia.responderNasNotas(fontes:) | 0/3 | reprova: todas recusaram por inteiro. |
| r3-contrapor-sem-fato-externo | Sabia.contrapor | 0/3, Falha.semRetorno, sem chamada | confirma o corte, sem queda ao aparelho. |

Saída integral decisiva de Notas, repetida três vezes:

> Não tenho informação disponível nesta consulta para confirmar isso. Informe os dados necessários ou abra a nota que os contém para retomarmos a pergunta.

O caso tinha teto R$5.000, US$300 + US$120 previstos e cotação de R$5,20 datada; a resposta não usou nada nem citou fontes. Confirma que responderNasNotas continua reprovada e que conserto nomeado não é conserto feito.

## Leitura por operação

| operação | resultado original | concordo? | evidência lida |
|---|---:|---|---|
| produzir | 5/6 | sim, não passa 9 | Combinar chegou a Erro.praticaIndisponivel após 91 s; boas recusas não compensam. |
| prepararPratica | 1/6 | sim | 11/18 transportes a 91 s; conteúdo eventual não é atendimento. |
| conferirTentativa | 6/6 | sim | distinguiu Recife/Salvador, parcial e empate 480/480 com trecho literal. |
| revisar | 3/6 | sim | três revisão assistida não executada; quando veio, achou omissão sem inventar. |
| responderNasNotas | 4/6 | sim | além de N1T1/N2T1, meu caso tipado deu 0/3. |
| responder | 3/6 | sim | inventou abre às 13h e 1.650 km/R$1.072,50; meu caso ficou cortado. |
| instigar | 1/6 | sim | devolveu Qual é o movimento básico que se pula?, jargão interno. |
| contrapor | 1/6 | sim | citou metanálises de 2022 e fato histórico sem suporte; meu caso ficou cortado. |
| vestir | 5/6 local | sim | formatou texto que pedia não quero organizar isso; Grok não foi chamado. |
| recordar | 1/6 | sim | vazou: Por que a sala 7 não pode receber mais que 15 pessoas? |
| conferir | 6/6 | sim | paráfrase, negação, parcial e unidades; meu caso novo passou 3/3. |
| ecos | 3/6 | sim | lista vazia para 18 inscritos versus sala de 15. |
| calibragem | 2/6 | sim | ausência em par único e silêncio onde a interpretação era necessária. |
| padroes | 6/6 | sim | cita material disponível e não diagnostica choro/aperto. |
| classificar | 5/6 | sim | lista de compras virou Destaque; erro local, remoto calou. |
| dominio | 4/6 | sim | texto voltou trabalho, estudo e casa; azul oscilou. |

Não usei nota do gerador para aprovar. Falha obrigatória reprova, sem compensação por média.

## Rota realmente medida

A sobrecarga morta responderNasNotas(contexto:) foi removida; rg só encontra a assinatura tipada e a sonda exige fontes. Não achei outra rota fantasma equivalente.

| conclusão | operações |
|---|---|
| executor de produção igual, mas não jornada completa | produzir, conferirTentativa, revisar, instigar, contrapor, vestir, recordar, conferir, ecos, calibragem, padroes, dominio |
| parcial | prepararPratica pula o invólucro MotorTrabalho.produzir; responder recebe contexto sem montagem da Sessao; responderNasNotas usa fontes tipadas mas não seleção da Sessao; classificar usa Sessao.escolher mas duplica orquestração periférica. |

A correção da rota fantasma é real, mas pelo caminho de produção deve manter essas ressalvas; não equivale a jornada integrada.

## Corte, filtro e Perfil

Concordo com cinco sem substituto medido: ecos, calibragem, recordar, instigar e contrapor; e duas com conserto nomeado: responder e responderNasNotas. Politica.provedor retorna nil e desceAoAparelho é falso; minha corrida confirmou nil em responder/contrapor. peloAparelho é filtro por inclusão das regras que oferecem aparelho, e o teste soma as três listas: nenhuma reprovada aparece disponível pelo aparelho.

O Perfil WIP observado mostra os cinco e, abaixo, as duas em correção com motivos coerentes. Não é entrega: a árvore AX põe conteúdo abaixo do rodapé (y maior que 1) em tamanho padrão, o corte conhecido da outra frente.

**Achado ALTO:** q-qualidade.md diz que operação que falha por tempo não está lá, mas Politica continua oferecendo prepararPratica 1/6, revisar 3/6 e produzir 5/6 como só Grok. Denominador honesto não torna a oferta honesta.

## ADR/SPEC

Está correto proibir IA maior ou igual a 9 sempre, Grok aprovado nas dezesseis, fallback equivalente, JSON válido como utilidade e qualquer alegação de aprendizagem. A ADR também declara corretamente a diferença entre retorno de domínio e bruto descartado pelo parser.

Não passa, porém:

1. ADR 08k e relatório dizem candidato 325c819; código/provas Q entraram em acdfcb4.
2. ADR fala em 12 falhas de transporte, mas enumera 11+6+3 = 20; EVOLUCAO.md repete 12 e só seis das sete cortadas. JSONL e relatório sustentam 20/72 em 4.6 e 0/177 em 4.3.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | lacuna de medição com conta fechada; falhas ficaram no denominador. |
| Contrato | 6 | hash errado, 12/20 contraditório e ofertas 1/6/3/6. |
| Correção | 8 | corte das sete funciona; timeout ainda promete operação. |
| Jornada real | 7 | sonda real/Perfil, mas não jornada de falha-retomada e três rotas são só executor. |
| Design | n/a | motor; Perfil é outra frente. |
| Simplicidade | 8 | regra evita quedas perigosas; timeout mantém promessa indevida. |
| Movimento | n/a | sem mudança Q. |
| Componentes | n/a | sem componente Q entregue. |
| Acessibilidade | n/a | Perfil não é entrega e está cortado. |
| Performance | 7 | 20/72 a 90 s é indisponibilidade material. |
| Privacidade e autoria | 9 | casos sintéticos; fontes tipadas; sem token nas provas. |
| Estado honesto | 6 | rota fantasma/casos não cegos bem declarados; hash, totais e oferta contradizem. |
| Complexidade | 9 | regra única e remoção de sobrecarga, sem dependência. |
| Fora do app | n/a | nada tocado. |
| Relato | 6 | JSONL é auditável, mas candidato e totais não fecham. |

## Correções antes de G5

1. Fixar hash/artefato candidato e reconciliar 20/72 versus 12 e as sete rotas em ADR, relatório, QUALIDADE-IA e EVOLUCAO.
2. Corrigir disponibilidade de Trabalho: teto, retentativa ou estado explicitamente indisponível, provado na jornada.
3. Não reativar responderNasNotas: meu caso tipado 0/3 repete a recusa que a tabela promete consertar.

# re-G3 — as três correções da Q-B

## Veredito: CORRIGIR ANTES

As três recusas de `prepararPratica` após HTTP 200 são reais, mas a prova
descarta justamente a saída que permitiria decidir se o defeito é do provedor ou
se uma regra nossa é estreita; portanto não aprovo a explicação de causalidade
nem a disponibilidade como se estivesse fechada. As correções de candidato,
contagem e transporte fecham o que o G3 anterior havia apontado; a correção
necessária é diagnóstico tipado/redigido da recusa e remedição dos três casos,
não afrouxar o parser às cegas nem cortar toda a operação.

Revisor independente. Não alterei Swift, dados do usuário, conta ou Safari. O
Grok `C2416CBC` ficou ligado; não recebeu `erase`, `clearState`, `uninstall` ou
`xcodebuild test`, e `TRACO_AVALIAR_IA` foi conferido desdefinido ao final.

## Achados

### [P1] A causa das 3 recusas não é auditável com a prova que sustenta a decisão

`prova/qb-teto-avaliacoes.jsonl` mostra, para
`revisor-sintetico-resumo-projeto-2x5` (repetições 2 e 3) e
`q2-conhecido-preparar-apresentacao-proposta` (repetição 3), `HTTP 200`,
`grok-4.6`, conteúdo completo e respectivamente 5.854, 3.777 e 6.865 tokens de
raciocínio, mas `saida: null`. O caminho de produção só pode chegar ali por
`parsePreparacao` ou `validar` (`PraticaTrabalho.swift:127-162`), mas o JSONL
deliberadamente não guarda o bruto e não registra qual guarda recusou. Logo,
"o nosso parser é estreito" e "o provedor devolveu conteúdo inválido" são hoje
inferências concorrentes, não fatos; liberar regra de anti-gabarito sem esse
dado arriscaria entregar a resposta da prática.

Correção antes de G5: registrar na sonda de DEBUG uma categoria sem conteúdo
bruto (por exemplo, forma/schema, limite, exemplo contido ou critério que vaza),
reexecutar os três casos e ler as saídas completas contra a rubrica. Se a causa
for forma, o contrato atual está correto; se for uma regra sem violação de
autoria/prática, corrigir essa regra e remedir. Não há evidência para escolher
qual dos dois agora.

### [P2] O novo teste do teto não protege o valor decidido de 240 s

`GrokContratoTests.swift:22-25` passa com `Grok.tetoTrabalho = 181`: ele só
impõe `>= 180` e `> 90`. Isso cobre minimamente o pior tempo de ponta a ponta
publicado (178,144 s), mas não falha quando alguém baixa o teto decidido de
240 s, como o relato afirma; além disso o comentário chama 141 s de pior
latência, embora a medida de `produzir` seja 178,144 s. O teste é útil como
piso histórico, mas não é a guarda descrita para a decisão nem para a folga.

Correção: separar o piso observado (>= 180) da decisão atual (240) ou reescrever
o comentário/relato para não prometer uma proteção que o teste não fornece.

## Conferências que fecham

- **Candidato e dois binários:** `git show --stat` confirma `325c819` como só
  `LACO.md` e `acdfcb4` como os 15 arquivos da Q. O diff `325c819..acdfcb4`
  muda a sonda de Notas de `contexto` para `fontes`, remove a sobrecarga morta
  e atualiza `Politica`; nas quatro rotas de Trabalho a política continua
  `soGrok`. Assim, a troca não é entrada da matriz de Trabalho: a defesa contra
  contaminação se sustenta, com a ressalva corretamente declarada de que a
  matriz e a remedição são binários diferentes. No dylib hoje instalado no
  `C2416CBC`, `nm` encontra somente `responderNasNotas(...fontes...)`, sem
  assinatura `contexto:`.
- **Números:** o `jq` independente sobre
  `prova/q-qualidade-avaliacoes.jsonl` dá 52 completas + 20 sem resposta de
  transporte em 72 chamadas `grok-4.6`, e 186 completas em `grok-4.3` (177 na
  matriz, mais 9 da remedição). `SPEC.md`, `QUALIDADE-IA.md`, `EVOLUCAO.md` e
  `q-qualidade.md` agora dizem 20, não 12; os quatro também reconciliam as
  sete cortadas, incluindo `responderNasNotas`.
- **Teto e medida própria:** as quatro chamadas usam
  `Grok.tetoTrabalho = 240`. A suíte no `34CC3F94` passou 915 testes, 0 falhas,
  build com um único aviso pré-existente de `PerfilView.swift:636`. Minha sonda
  sintética, após fumaça autenticada com `ContaGrok.ligada: true` e 12 modelos,
  repetiu `qn-preparar-outro-dominio-planilha`: retorno completo de `grok-4.6`,
  HTTP 200, exercício válido em **92,648 s**. É uma medida independente acima
  do antigo teto; 240 s cobre-a por 147,352 s e cobre o pior histórico de
  178,144 s por pelo menos 61,856 s. Isto apoia o teto de 240, não prova uma
  cauda segura para sempre.
- **Tabela versus tela:** o argumento contra mover as 3/15 para
  `Politica` se sustenta: a tabela só consegue desabilitar a operação inteira,
  enquanto `EstadoPedido.praticaIndisponivel` preserva o pedido e
  `TrabalhoView` mostra `pratica-preparacao-indisponivel` com "Retomar esse
  pedido". A superfície é honesta para a falha por pedido; o que falta é saber
  qual condição a causou e provar a tela nessa ocorrência real. Não há base
  para reclassificar a operação inteira como indisponível por qualidade.
- **Notas:** `responderNasNotas` permanece `indisponivelPorQualidade`; não achei
  reativação nem fallback que desça ao aparelho.

## Scorecard re-G3

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 8 | candidato/números fecham; causa de 3 recusas segue sem classificação auditável |
| Correção | 8 | 915 testes verdes, mas o teste do teto não guarda o valor/folga que o relato promete |
| Jornada real | 8 | sonda real repetida; a falha `praticaIndisponivel` não foi reaberta na tela nesta volta |
| Performance | 9 | 0/30 transporte na remedição e medida independente de 92,648 s acima de 90 |
| Estado honesto | 8 | estado por pedido existe, porém sem motivo tipado para explicar a recusa medida |
| Privacidade e autoria | 9 | não recomendo salvar bruto; a categoria de recusa basta para investigar sem expor prática |
| Simplicidade | 9 | um teto para quatro chamadas; sem passo novo para o autor |
| Demais dimensões | n/a | volta de motor, sem mudança de view, componente, movimento ou fora do app |

# re-G3 (segundo)

## Veredito: CORRIGIR ANTES

O teto agora está realmente protegido e a leitura/validação produtiva converge
numa única régua, mas não aprovo este candidato: a ADR usa `08n`, já ocupada em
`main` e na volta A1, e a instrumentação ainda serializa quatro palavras do
exemplo — conteúdo que pode ser protegido — no JSONL de DEBUG.

Não alterei Swift nem toquei no `C2416CBC`: ele permaneceu ligado, sem
`erase`, `clearState`, `uninstall`, Safari ou `xcodebuild test`. A revisão
leu o código, as cinco linhas de recusa, a ADR e as provas já registradas;
build e testes foram só no `34CC3F94`, sempre por `com-trava.sh` e sem paralelo.

## Achados

### [P1] A ADR 08n colide com `main` e com a volta A1 viva

Esta branch escreve `## ADR 2026-09-08n — Por que o NOSSO parser...`
(`SPEC.md:5793`). `git show main:SPEC.md` já contém `08n — Cancelar não apaga
o que já foi observado` e `git show Vitorepf/volta-a1-arranque:SPEC.md` contém
`08n — O arranque que não abre...`. Portanto a letra usada foi **08n**, não
uma letra livre; a colisão impede levar a ADR adiante como está. Renumerar para
a próxima letra desocupada e conferir de novo as voltas vivas antes do merge.

### [P1] O quadrigrama é conteúdo do exemplo, não só uma medida segura

`Recusa.criterioVazaOExemplo(indice:trecho:)` conserva `trecho` e
`redigida` o emite literalmente; `MotorTrabalho` o põe em
`recusasDaPreparacao` e `AvaliacaoIA` o persiste no JSONL. A normalização tira
acento e pontuação, não retira o conteúdo: um exemplo que contivesse dado
pessoal, texto selado ou credencial em quatro palavras o publicaria na sonda.
O teste de privacidade não fecha esse furo: usa `segredo = "¿dónde está la
estación?"`, mas a saída seria `donde esta la estacion`, e só procura a forma
com acento/pontuação. A exigência de motivo auditável é válida; a medida deve
ser não reversível/estrutural ou a captura precisa estar sob a mesma proteção
do exemplo, com teste que prove o caso normalizado.

### [P2] A conclusão causal é correta para a regra, mas excede a prova das cinco saídas

As cinco linhas em `prova/qc-recusa-avaliacoes.jsonl` confirmam a **mesma
guarda** `vazamento`; só a quinta (`0065BE4A`, caso do revisor, repetição 4)
expõe `“a dependencia ainda aberta”`. Esse vocabulário descreve a estrutura
que o pedido manda separar (concluído, dependência, próximo passo), não entrega
o fato-alvo — concordo que essa ocorrência não deveria ser recusada pela régua
herdada de Recordar, cujo alvo é a própria resposta. Porém as quatro recusas
anteriores registram apenas categoria e índice, sem quadrigrama; como o bruto
foi corretamente descartado, elas não permitem afirmar que **as cinco** têm o
mesmo conteúdo estrutural. A ADR já reconhece esse limite no final; a conclusão
deve conservar essa qualificação.

## Conferências que passam

- **Uma cópia produtiva das regras:** `MotorTrabalho.prepararPratica` é o único
  caminho produtivo encontrado e compõe `lerPreparacao(...).flatMap(provar)`.
  `parsePreparacao` e `validar` são wrappers `try? ...get()`, sem validação
  paralela divergente; não encontrei outro chamador que aceite preparação.
- **Teto:** `GrokContratoTests` separa piso `>= 179`, marco histórico `> 90` e
  decisão `== 240`. Em worktree temporário isolado, baixar
  `Grok.tetoTrabalho` para 239 deixou vermelho exatamente o `== 240`; subir o
  piso a 241 deixou vermelho exatamente o `>= 241`. Os dois vermelhos também
  acusaram um `PortaoDoMovimentoTests` pré-existente do snapshot isolado
  (`privateAnalise/AnaliseDeBordo.swift` ausente), não atribuído a esta mutação.
- **Candidato atual:** build passou no `34CC3F94`; a suíte integral
  passou **916 testes, 0 falhas** no mesmo UDID (`xcresult`, iOS 26.5), com
  `-parallel-testing-enabled NO`.

## Scorecard re-G3 (segundo)

| dimensão | nota | evidência |
|---|---:|---|
| Contrato | 7 | a ADR 08n colide com main e A1 viva |
| Correção | 9 | 916/0; piso e decisão ficam vermelhos nas mutações certas |
| Privacidade e autoria | 7 | quadrigrama normalizado de exemplo pode sair no JSONL |
| Estado honesto | 8 | a guarda é auditável; quatro das cinco não têm trecho para sustentar a causalidade individual |
| Simplicidade | 9 | uma leitura/prova produtiva, sem cópia divergente |
| Performance | 9 | teto central continua 240 e a suíte não regrediu |
| Jornada real | 8 | li a remedição real preservada; não reexecutei a conta do dono |
| Demais dimensões | n/a | sem mudança de view, componente, movimento ou fora do app |
