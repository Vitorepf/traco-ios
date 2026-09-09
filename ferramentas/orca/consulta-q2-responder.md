# Conselho — G0 Q2: responder à pergunta

Consulta 1 de no máximo 2. Parecer sobre `3005673`, em 08/09/2026;
somente leitura e este documento, sem execução de IA ou simulador.

**1. Resolvido — frase para colar no spec.**

> `responder` pode sair de `indisponivelPorQualidade` para o Grok quando a comparação antes/depois pela sonda, em condições identificadas e comparáveis, e a leitura independente de cada saída inteira do candidato final demonstrarem, em três inferências novas sem memo por caso obrigatório, incluindo regressões e casos novos do revisor, nota ≥9 em cada uma das cinco dimensões de QUALIDADE-IA.md, respondendo tudo que é sustentado e limitando somente o fato ausente com continuação útil, sem fabricação, recusa integral indevida ou violação de autoria/proteção em nenhuma execução; um único descumprimento reprova, acertos e médias não o compensam, e a aprovação vale para esse escopo medido, não como garantia universal.

**2. Prompt primeiro; copiar o contrato de sustentação, não a operação.**

`Sabia.sistemaResponder` pede informação, opções e critérios, mas não proíbe
preencher lacunas com fatos. `MotorTrabalho.sistema`, em
`Traco/Trabalho/OficinaTrabalho.swift:445`, proíbe inventar fatos/fontes/ações,
manda nomear precisamente o dado indispensável ausente, distinguir proposta,
pressuposto e observação, declarar suposições e entregar conteúdo utilizável.
Adapte essas regras ao cartão: responda a parte sustentada; não deduza fato
pessoal/atual ausente; explique a lacuna e dê cálculo simbólico, critério ou
caminho de consulta pertinente; respeite correções explícitas; conhecimento
geral continua disponível sem nota. Opções só quando a pergunta as exigir:
não acrescentar condições fictícias a uma resposta já suficiente.

No JSONL, combustível passa de orientação (129) a R$ 1.008 inventados (323);
biblioteca, de consulta (135) a 13h inventadas (329). `produzir` preserva os
dados fornecidos, explica cotações ausentes e entrega fórmula/molde (195/389/583).
**Isso sustenta uma hipótese de conserto, não prova causal:** as corridas usam
`grok-4.3` sem esforço em responder e `grok-4.6` com `medium` em produzir.
Não copiar modelo/esforço, Markdown de artefato, permissão de redigir pelo
autor, contexto de Trabalho ou teto longo; preservar a resposta no cartão e
as guardas locais. `produzirEntrega` também não tem verificador factual nem
schema de recusa: aceita texto não vazio. Não existe validador milagroso a copiar.

As fabricações ocorreram com contexto curto e sem timeout: contexto/teto
não são a primeira causa indicada. Não copiar de `responderNasNotas` a regra
`insuficiente → texto vazio`, que transforma lacuna parcial em silêncio total.

**3. Prova contra recusa covarde: pares que mudam apenas a evidência.**

Fixar antes da correção o que deve ser respondido e o que não pode ser afirmado:

| Mesma pergunta, contexto alterado | Saída exigida |
|---|---|
| Gasolina: nenhum dado → só distância → distância total 600 km, consumo 12 km/l, preço R$ 6/l fornecidos | Sem total e fórmula → usar 600 e pedir só os dois faltantes → calcular R$ 300, atribuído aos dados fornecidos |
| Biblioteca: sem horário → endereço informado, horário ausente → comunicado da unidade datado de hoje com abertura às 14h | Caminho para confirmar → aproveitar endereço sem inventar horário → informar 14h segundo o comunicado, sem recusar por ser fato atual |
| Prazo: correção explícita para 12/09 → duas datas conflitantes sem resolução | Responder 12/09 sem exigir confirmação extra → expor conflito e a informação que o resolve |
| Espanhol iniciante, sozinho, 3×5 minutos; pergunta geral sem notas | Orientação executável nas restrições e resposta geral útil, sem recusa por ausência de fontes pessoais |

Aplicar o critério de §1 a cada variante, com modelo/configuração iguais
salvo a alavanca em teste. Avaliar aderência, correção sustentada, utilidade,
destinatário/divisão de trabalho e contexto. Recusa integral, indisponibilidade
e timeout falham atendimento; limitação parcial só passa entregando a ajuda
exigida. Preservar falhas, entradas/saídas, duração, configuração e candidato.
Reexaminar também os seis casos antigos: a linha 325 inventa necessidade de
confirmação formal do prazo, e 133/327/521 inventam páginas do relatório;
a antiga contagem 3/6 não é gabarito semântico.

**Instrumento.** `Politica.provedor(.responder)` hoje retorna `nil`; a sonda
não alcança Grok. Medir base/candidato pelo mesmo `Sabia.responder`, com
habilitação apenas no candidato isolado de avaliação, explicitamente registrada.
A sonda guarda saída após parser: ler o retorno inteiro do cartão e, para
afirmar leitura da geração inteira, registrar também o bruto sintético.
Acrescentar caso cuja evidência está além do recorte de 5.000 caracteres e
verificar perda no corte de 900 da resposta: prompt não recupera dado cortado.

Leitura: QUALIDADE-IA, SPEC ADR 08q, política, sonda, chamadores e corridas.
`prova/q-qualidade.md` está ausente; usei `ferramentas/orca/q-qualidade.md`.
Bootstrap documental emulado com visão/contratos locais: `artisan` e a
governança Atlas indicada estão ausentes. Sem nova superfície, troca de
provedor ou alteração de vazamento; implementar, medir e habilitar ficam
para a volta. Esta consulta não aprova a operação.
