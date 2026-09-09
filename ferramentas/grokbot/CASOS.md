# O Traço no Mac com o Grok Bot — os onze casos de uso

Ordem do dono, 08/09/2026: implementar os onze. Este arquivo é o contrato em linguagem de uso: o que a pessoa diz, o que o bot lê, o que o bot escreve, o que aparece no iPhone e a guarda. As voltas que os pagam estão em `ferramentas/orca/papeis/trilha-mac.md`.

O que o bot tem que o app não tem: tela grande e teclado; um modelo grande com conhecimento de mundo e busca na web; leitura de todas as notas de uma vez; conversa. O que o bot NUNCA faz: redigir como se fosse a pessoa, resumir expressiva ou selada (nem chegam a ele), inventar fato sem citar a nota de onde veio, sincronizar sozinho, usar voz.

Regras de origem, para todos os casos:
- Texto da pessoa vai para `entrada/` como nota dela (`origem: autor`).
- Texto do bot vai para `entrada/` ou `trabalhos/entrada/` com `origem: grokbot` e o motivo. O app mostra a etiqueta "feito pelo bot", nunca conta isso como voz do autor, e nunca põe no Retrato.
- Pesquisa vai com `origem: pesquisa` e a lista de fontes.
- Toda afirmação do bot sobre o que a pessoa pensa cita o id da nota. Sem id, é opinião do bot e vem marcada.

| # | caso | a pessoa diz | o bot lê | o bot escreve | no iPhone aparece | volta |
|---|---|---|---|---|---|---|
| 1 | O que eu já pensei sobre isso | "o que eu já escrevi sobre abrir a segunda clínica?" | `traco_buscar`, `traco_nota`, `traco_corpus` | nada, ou uma nota `origem: grokbot` se a pessoa pedir "guarda isso" | a nota com etiqueta do bot | MAC-1 |
| 2 | Revisão da semana | "revisão da semana" | `traco_semana`, `traco_decisoes` (novo: esperava × aconteceu × sem resposta) | as respostas da pessoa, uma por decisão, como relato (`traco_relatar`) | cada relato ligado à decisão, e a latência da descoberta anda | MAC-1 lê, MAC-2 escreve |
| 3 | Onde eu me contradigo | "onde eu me contradigo sobre projetos novos?" | `traco_corpus` ou `traco_buscar` | nada por padrão; nota `origem: grokbot` com as citações se pedirem | a nota com as duas frases e as datas | MAC-1 |
| 4 | Preparar reunião, proposta, conversa | "amanhã falo com o fulano sobre o contrato" | `traco_buscar` pela pessoa e pelo assunto, `traco_trabalho` se houver trabalho aberto | `traco_trabalho_escrever`: o roteiro como versão nova do trabalho, `origem: grokbot` | a versão na folha do Trabalho, com prévia e "de onde veio" | MAC-2 |
| 5 | Da intenção ao plano com datas | "quero lançar X até novembro" | `traco_trabalho` (a intenção) e `traco_agenda` (o que já está marcado) | versão nova com etapas e datas propostas; as ações a marcar ficam listadas na versão | a pessoa marca as ações na folha; o calendário cobra; o resultado volta pela E1 | MAC-2 |
| 6 | Estudar com correção | "me dá o próximo exercício de espanhol" | `traco_trabalho` (o exercício e as tentativas anteriores) | a tentativa da pessoa por `traco_tentativa`; o feedback e a lição seguinte por `traco_trabalho_escrever` com o motivo ("errou a conjugação de ir") | tentativa como evidência da pessoa; feedback e lição como versão do bot; nunca misturados | MAC-2 |
| 7 | Pesquisa com fontes, cruzada com as notas | "pesquisa como clínicas fazem agendamento e cruza com o que eu escrevi" | a web (do bot) e `traco_buscar` | `traco_escrever` com `origem: pesquisa` e `fontes: [...]` | a nota com etiqueta de pesquisa e as fontes no pé | MAC-3 |
| 8 | Da ideia solta ao método, por pergunta | a pessoa despeja uma página | `traco_contrato` (os métodos e as perguntas de cada um) | só as PERGUNTAS do método; a nota final, respondida pela pessoa, por `traco_escrever` com a forma | a nota já vestida, com os campos preenchidos pela pessoa | MAC-1 |
| 9 | O que está se repetindo | "nos últimos 90 dias, o que aparece toda semana e não resolve?" | `traco_corpus` | nada, ou nota `origem: grokbot` com os três temas e as citações | a nota com etiqueta do bot | MAC-1 |
| 10 | Do desejo ao briefing de software | "quero um app que faça X" | `traco_trabalho`, `traco_buscar` pelas restrições que a pessoa já escreveu | versão nova do trabalho, com cada requisito apontando o id da nota de origem; requisito sem id vem marcado como "proposto pelo bot" | a versão na folha, pronta para ir ao Cursor ou ao Claude | MAC-3, depois da Q medir o Grok nesta rota |
| 11 | Briefing da manhã | "bom dia" | `traco_agenda` (novo: compromissos e ações de hoje, decisões esperando resposta, prova do Recordar vencida) | nada | nada; é leitura | MAC-1 |

## O que precisa existir

**No MCP (`ferramentas/traco-mcp`), ferramentas novas:**
- `traco_agenda(dias)`: compromissos, ações pendentes com data, decisões com "quando eu confiro" vencido, Recordar devido. Lê `agenda.md`, que o app passa a exportar.
- `traco_decisoes(dias)`: por decisão, o que a pessoa esperava, o que escreveu que aconteceu, e as sem resposta. Lê o corpus; pode nascer de `traco_semana`.
- `traco_trabalhos()` e `traco_trabalho(id)`: os trabalhos abertos e um trabalho inteiro (intenção, pedido, versões com origem, ações, relatos, hipóteses, exercício e tentativas). Lê `trabalhos/<id>.md`, que o app passa a exportar.
- `traco_trabalho_escrever(id, texto, motivo)`: versão nova, `origem: grokbot`, gravada em `trabalhos/entrada/` com o marcador `<!-- traco-trabalho:v1 … -->` que o intercâmbio já entende.
- `traco_tentativa(id, texto)`: a resposta da pessoa a um exercício, `origem: autor`, evidência e nunca versão.
- `traco_relatar(acao_ou_decisao_id, texto)`: o que aconteceu, nas palavras da pessoa, ligado à ação ou à decisão.
- `traco_escrever` ganha `origem` (`autor` | `grokbot` | `pesquisa`) e `fontes`; o padrão continua `autor`, e o bot é obrigado a declarar quando não é.

**No app:**
- A pasta espelhada exporta `agenda.md` e `trabalhos/<id>.md`, e vigia `trabalhos/entrada/` como já vigia `entrada/`.
- Nota de `entrada/` com `origem` diferente de autor entra com etiqueta, fora do Retrato, fora da voz do autor, e o selo continua valendo.
- Versão de `trabalhos/entrada/` passa pela prévia e pelo conflito da volta 11; tentativa e relato entram pelos caminhos da V6 e da E1.

**No bot:** um arquivo de instruções por caso em `ferramentas/grokbot/casos/`, com o gatilho, as ferramentas, as regras e a porta de volta. É o que se cola no Grok Bot.
