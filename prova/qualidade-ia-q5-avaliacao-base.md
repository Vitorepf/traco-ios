# Q5 — avaliação da base viva de 07/09/2026

**A base não cumpre Q5.** Sete dos trinta retornos públicos satisfazem os
requisitos dos respectivos casos; 23 falham. Desses 23, doze não entregaram
retorno utilizável e onze retornaram conteúdo incorreto ou insuficiente.
Somente dois dos dez casos passam nas três repetições. Não há média que
compense falha obrigatória, nem aprovação do objetivo integral.

## Evidência e candidato

- Corrida: `6EC9C95B-5F15-48C1-854F-7A58B25B74FF`, de 14:20:52 a
  14:21:27 UTC em 07/09/2026.
- Fonte completa lida: `qualidade-ia-q5-base-20260907.jsonl`, SHA-256
  `1f561fd6f81dd326ce56d25256eedfbc7b168fa74c92ef7a4a0a775616dbf669`.
- Fixture: `qualidade-ia-q5-casos.json`, SHA-256
  `8c02e9ee2be822695aad3ce6ac1f0bacb62baadde229021f3d1ee43080afc686`.
  Hash e conteúdo decodificado conferidos contra o lote embutido no JSONL.
- Trinta conclusões únicas por caso/repetição e evento final presentes.
  Em todas: Grok desligado, Apple Intelligence disponível, motores habilitados;
  sistema 26.5, build 23F77. A versão específica do modelo local não é exposta.
- Candidato vinculado pelo executor ao pacote
  `test_sim_2026-09-07T14-16-12-595Z_pid22167_19372c2e.xctestproducts`.
  Conferi o arquivo real `Binaries/0/Debug-iphonesimulator/Traco.app/Traco.debug.dylib`:
  SHA-256 `3fe225402070c78002ec01cbb2e2a29ae11e879b6e4feb0b49c25d919c71cffd`,
  igual ao manifesto `qualidade-ia-candidatos.json`. O manifesto informa hash
  do conteúdo integral do app
  `602716a30a3cfe4e46c1b7a53e8ada59baf33ed20753e00d43cb81b4a9cb0459`;
  não recalculei este último. O hash do lançador `Traco` sozinho não distingue
  estas compilações Debug e não foi usado como prova de identidade do código.

## Resultado de todas as execuções

`Sem retorno` significa o erro público `Falha.semRetorno`, não uma resposta
vazia avaliada pelo modelo. Os números de linha apontam os registros completos
no JSONL. Nos negativos, `[]` pode cumprir o contrato; isso não o transforma em
prova de que o modelo examinou corretamente todo o material antes do parser.

| Caso | Linhas | R1 | R2 | R3 | Julgamento |
|---|---|---|---|---|---|
| Recordar capital Lisboa | 3, 5, 7 | Sem retorno | Sem retorno | “Onde está Lisboa?” | Falhou 3/3: duas indisponibilidades; a pergunta restante revela Lisboa e troca a recuperação da capital por uma pergunta sobre localização. |
| Conferir paráfrase completa | 9, 11, 13 | `[0,2]` | `[0,2]` | `[0,2]` | Falhou 3/3: deveria incluir também 1. “O trem sai às 8h” recupera “O comboio parte às oito horas”. |
| Conferir contradição | 15, 17, 19 | `[0]` | `[0]` | `[0]` | Falhou 3/3: deveria retornar `[]`. O texto afirma Porto e nega Lisboa; mencionar Lisboa dentro da negação não recupera corretamente o ponto. |
| Conferir resposta parcial | 21, 23, 25 | `[0]` | `[0]` | `[0]` | Passou 3/3 neste caso: reconhece a capital e não preenche horário/preço ausentes. |
| Ecos por sentido e contradição | 27, 29, 31 | Sem retorno | Sem retorno | Sem retorno | Falhou 3/3: não entregou os vínculos claros 0 e 2 nem qualquer resultado avaliável. |
| Ecos por coincidência lexical | 33, 35, 37 | Sem retorno | Sem retorno | Sem retorno | Falhou atendimento 3/3. Não equivale ao `[]` exigido; não é possível concluir que os falsos ecos foram semanticamente rejeitados. |
| Calibragem: dependência externa | 39, 41, 43 | `[]` | `[]` | `[]` | Falhou 3/3: nenhuma pergunta útil sobre a dependência externa omitida em três previsões. O vazio não atende ao positivo. |
| Calibragem: sem atraso | 45, 47, 49 | `[]` | `[]` | `[]` | Passou o retorno público 3/3: não inventa atraso/otimismo nem diagnostica capacidade. O vazio é permitido neste negativo. |
| Padrões: sobrecarga | 51, 53, 55 | `[]` | Sem retorno | Sem retorno | Falhou 3/3: nenhuma pergunta útil sobre aceitar novos pedidos e adiar compromissos prévios. |
| Padrões: notas sem vínculo | 57, 59, 61 | Sem retorno | `[]` | Sem retorno | Só R2 passa no retorno público; R1/R3 falham atendimento. |

## Implicações e limites

Os dois erros de Conferir são distintos: perda de uma paráfrase correta e
confirmação de um conteúdo explicitamente contradito. Corrigir apenas números
ou palavras isoladas não demonstra a comparação correta de significado.
Recordar precisa entregar pergunta pertinente sem expor a resposta; bloquear
“Lisboa” e devolver indisponibilidade também não atenderia ao caso positivo.

Os negativos vazios não compensam os positivos sem utilidade. Em particular,
a combinação de calibragem sempre vazia e ecos sempre sem retorno não pode
ser descrita como prudência excelente: aqui ela não ajuda nos casos em que
existe relação clara para examinar.

Esta análise leu integralmente todas as saídas disponíveis, mas o instrumento
captura retorno público após parsers. Não há resposta bruta para separar
geração vazia, formato inválido, citação rejeitada, recusa e falha do provedor.
Por isso não atribuí uma causa de transporte aos doze erros nem uma decisão
semântica explícita a cada `[]`.

A fixture foi escrita por este avaliador e é conhecida pelo implementador;
não é avaliação cega. Esta é a primeira base desses dez casos. Não houve
alteração de produção nem execução de simulador nesta revisão. As aprovações
limitam-se aos retornos públicos indicados: não demonstram retenção,
aprendizagem, capacidades da pessoa, experiência de tela, recuperação de dados,
proteção, outro provedor ou toda a abrangência de Q5.
