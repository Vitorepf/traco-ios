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

