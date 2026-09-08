# Avaliação independente de conteúdo — base de 07/09/2026

**Resultado: a base parcial não atinge o contrato.** Das nove saídas, três
passam no escopo estreito de classificação; as três de produção e as três de
resposta contextual não cumprem todos os requisitos obrigatórios. Nenhum
resultado certifica o conjunto das 16 operações nem o objetivo integral.

## Candidato e método

- Contrato: `QUALIDADE-IA.md`, rubrica de cinco dimensões, cada uma >=9 e
  nenhum requisito obrigatório descumprido. Sem média compensatória.
- Evidência lida integralmente: `prova/qualidade-ia-base-20260907.jsonl`.
- Corrida: `DEB76986-B20C-4200-ACC6-F9CC3413F768`, 13:56:59–13:57:40 UTC.
- SHA-256 do JSONL, calculado nesta revisão:
  `e16df7408813c3faf0e69be313cd3964cee3f8ef494dfa474a2c986318d8ad8d`.
- Fixture: `prova/qualidade-ia-casos.json`, SHA-256 calculado e conferido
  contra o cabeçalho:
  `44b07090d487b89b1571b2033cc2930b4e9df1292db94ddae5da45e2c2669207`.
  Conteúdo decodificado coincide com o lote embutido no JSONL.
- Binário indicado pelo executor:
  `0c20cc0b974c6d50541339d85740fbd777b39b70819500cfb9e7dc2fe7b34d43`.
  O arquivo binário não foi reinspecionado por este avaliador; esse vínculo
  vem do registro do executor, não do JSONL.
- Nove inícios e nove conclusões, IDs/repetições únicos e evento final
  presentes. Não há resposta omitida nem erro registrado nesse lote.
- Ambiente registrado: sistema 26.5, build 23F77; conta Grok desligada,
  Apple Intelligence disponível e `Motores.desligados == false` em cada caso.
  O campo `modeloConfigurado` nomeia Grok, não o executor. Produção declara
  `Apple Intelligence no aparelho`; as outras APIs não registram executor
  efetivo. Não atribuí essas respostas ao Grok nem inventei versão do modelo.

O avaliador implementou a sonda, mas não o gerador nem seus prompts nesta
base. A leitura é independente da autoria do conteúdo, não é teste cego:
entradas e requisitos eram conhecidos. A revisão avalia o texto retornado pelas
APIs, não o corpo bruto descartado por parsers, a tela ou uma jornada real.

As notas abaixo são julgamento qualitativo ancorado nos defeitos descritos.
9 significa requisitos cumpridos com refinamentos menores; 10 significa nenhum
defeito encontrado naquele escopo. Notas inferiores não são probabilidades ou
medidas clínicas. Uma única dimensão abaixo de 9 reprova a saída.

## Notas por saída completa

A = aderência ao pedido; C = correção sustentada; U = utilidade concreta;
D = adequação ao destinatário/divisão de trabalho; X = contexto pertinente.

| Caso / repetição | Linha JSONL | Segundos | A | C | U | D | X | Resultado |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Espanhol / 1 | 3 | 13,503 | 4 | 5 | 5 | 7 | 5 | Reprovado |
| Espanhol / 2 | 5 | 9,507 | 4 | 7 | 6 | 7 | 6 | Reprovado |
| Espanhol / 3 | 7 | 13,036 | 6 | 6 | 6 | 6 | 6 | Reprovado |
| Classificação / 1 | 9 | 0,744 | 10 | 10 | 9 | 9 | 9 | Passou neste caso |
| Classificação / 2 | 11 | 0,721 | 10 | 10 | 9 | 9 | 9 | Passou neste caso |
| Classificação / 3 | 13 | 0,739 | 10 | 10 | 9 | 9 | 9 | Passou neste caso |
| Contexto / 1 | 15 | 0,770 | 8 | 10 | 9 | 10 | 8 | Reprovado: fonte omitida |
| Contexto / 2 | 17 | 0,743 | 8 | 10 | 9 | 10 | 8 | Reprovado: fonte omitida |
| Contexto / 3 | 19 | 0,802 | 8 | 10 | 9 | 10 | 8 | Reprovado: fonte omitida |

## Produção: espanhol solo

**Repetição 1.** A abertura anuncia três blocos de cinco minutos, mas a
distribuição enumera apenas os minutos 1–2 no bloco 1, 3–4 no bloco 2 e 5–6 no
bloco 3. Nenhum trecho atribui os nove minutos restantes. Esse contraste
reprova aderência e correção temporal; não se pode completar mentalmente o
roteiro para aprová-lo. Além disso, ensina `Es las 15:00.` com tradução
`É as 15:00.`: há erro de concordância no material apresentado ao iniciante.

Há traduções correspondentes e frases utilizáveis, mas o conjunto é pouco
dirigido a apresentar-se: falta uma frase de nome/origem e predominam
cumprimentos, compra e localização. A ação em cada minuto é descrita como
“Prática” ou “Conversação” sem esclarecer como praticar sozinho; exemplos
ajudam, mas não completam a alocação temporal. Não exige explicitamente
instrutor, parceiro ou câmera. Não encontrei afirmação de que a pessoa já
realizou a prática. São acertos parciais, sem compensar os defeitos materiais.

**Repetição 2.** O cabeçalho anuncia 15 minutos, enquanto as atividades
folhas distribuem 3 + 2 + 2 = 7 minutos. Os blocos 2 e 3 ainda recebem o rótulo
“(1 minuto)” apesar de cada um conter duas atividades de um minuto. Não é
simples dupla contagem de um total: o documento fornece durações incompatíveis
e não distribui cinco minutos por bloco. A correção numérica é material.

As traduções acompanham as frases e não encontrei erro material nas frases
completas fornecidas. “Hola, soy [Seu Nome]” serve à apresentação; os outros
dois blocos concentram-se em comida, bebida e gostos, limitando a aderência à
intenção. O espaço `[Tipo de comida]` exige que o iniciante invente vocabulário
e ajuste artigo sem exemplo completo. As instruções finais de repetir em voz
alta tornam a prática solo compreensível, mas não resolvem os tempos.
Aplicativo de tradução é opcional: não o tratei como parceiro obrigatório nem
como violação automática da restrição. A autoavaliação “excelente maneira”
não demonstra eficácia e é dispensável.

**Repetição 3.** Os três blocos agora possuem cinco minutos cada; este
requisito passa. Todas as entradas de frase possuem tradução associada.
Contudo, `¿Hay restrooms?` apresenta uma palavra inglesa como material de
espanhol. É erro material justamente na habilidade que o destinatário não
consegue conferir sozinho; a tradução portuguesa presente não corrige a
frase-fonte.

O primeiro bloco traz nome e origem, mas `¿Dónde estás de nuevo?` é pouco
pertinente à situação proposta. Os outros blocos mudam para estacionamento,
Wi-Fi e agradecimentos. O objeto indicado como material não participa de uma
atividade definida. A sugestão “Pratique com outras pessoas que falam
espanhol, se possível” ignora a restrição fornecida; por ser opcional, não a
classifiquei como dependência obrigatória que impediria a execução solo.
Mesmo assim, prejudica adequação e uso de contexto. A conclusão “você estará
pronto para se apresentar e se comunicar com confiança em espanhol” promete
um resultado sem demonstração; não é uma afirmação de execução passada, mas
excede o que o material sustenta.

**Requisitos obrigatórios de espanhol:**

| Requisito | R1 | R2 | R3 |
|---|---|---|---|
| Três blocos de cinco minutos, distribuição coerente | Falhou | Falhou | Passou |
| Espanhol correto com tradução correta de cada frase | Falhou | Sem erro material encontrado nas frases completas | Falhou |
| Execução solo para iniciante, sem equipamentos/pessoas indisponíveis | Parcial: ações vagas | Parcial: vocabulário aberto | Parcial: instruções vagas e sugestão incompatível |
| Material completo, pertinente e sem inventar realização/aprendizagem | Falhou | Falhou | Falhou |

## Classificação: decisão de custo

As três saídas completas são idênticas: modelo, algoritmo local e escolha
final indicam `decisao`; a pergunta é “Quais são as opções — uma por linha?”.
A entrada de fato contém duas alternativas e restrições. Não foi tratada como
expressiva e não houve invenção de custo, cliente ou decisão tomada.

O requisito da fixture aceita **método ou pergunta** pertinente: o método
Decisão atende. A pergunta repete informação que já existe, um refinamento
relevante de interação, mas não torna incorreta a classificação nem implica
que o classificador deveria produzir uma análise financeira. Por isso U/D/X
ficam em 9, sem inventar um requisito de aconselhamento.

Passaram os dois requisitos em 3/3. Como o algoritmo local chega ao mesmo
resultado nas três amostras, o teste não demonstra ganho da chamada ao modelo
nem eficiência da sua necessidade; mede apenas acerto final nesse positivo.
Não inclui negativos, ambiguidade, escrita pessoal nem qualquer outro método.

## Resposta contextual: prazo corrigido

R1 responde “A proposta deve estar pronta em 12/09. Não pode gastar mais do
que R$ 800.” R2 muda apenas “mais do que” para “mais de”. R3 explicita
“12/09, não em 10/09” e acrescenta corretamente que nenhum fornecedor foi
contratado.

As três leem a atualização correta, conservam o limite financeiro e não
inventam compromisso. São curtas, úteis e adequadas ao destinatário. Nenhuma
atribui a informação à nota “Proposta da oficina” ou à atualização de 07/09,
apesar de a fixture exigir atribuição à nota pertinente. Não é falsidade nos
valores: é ausência de rastreabilidade, sobretudo importante diante de duas
notas contraditórias. A penalidade recai em aderência e contexto, sem reduzir
artificialmente a correção factual dos valores.

| Requisito | R1 | R2 | R3 |
|---|---|---|---|
| Prazo 12/09 e teto R$ 800 | Passou | Passou | Passou |
| Atribuição à nota pertinente; sem inventar contratação/execução | Falhou na atribuição | Falhou na atribuição | Falhou na atribuição |
| Não promover o rascunho antigo a compromisso vigente | Passou | Passou | Passou |

## Limites e validade do instrumento

Não encontrei nesta leitura um defeito da sonda que invalide as nove saídas
como baseline de retorno público. O instrumento limpa os memos que conhece
antes de cada caso; respostas iguais, isoladamente, não provam cache nem
independência estatística. Os metadados disponíveis e três retornos não
certificam estabilidade geral do modelo.

Para avaliações seguintes, registrar também o hash do binário/código no
artefato de evidência e proveniência por chamada fortalecerá o vínculo.
Capturar resposta bruta e falha de transporte no cliente real permitirá
distinguir indisponibilidade, recusa e rejeição de parser; hoje `semRetorno`
não os distingue. Esses limites não tornam os defeitos textuais encontrados
incertos: eles estão no conteúdo efetivamente devolvido.

Não foram avaliados: Grok, queda remota, erros/recuperação, proteção durante
await, dados persistentes, respostas na tela, prática/feedback, revisão de
artefato, vestir, Recordar, ecos, calibragem, Padrões, domínio nem contexto
recuperado automaticamente. O contexto deste lote foi entregue diretamente
ao motor em texto sintético. A lista de 16 operações disponíveis não é uma
lista de operações aprovadas. A qualidade do Traço permanece não demonstrada
no escopo integral; esta base localiza falhas concretas para corrigir.
