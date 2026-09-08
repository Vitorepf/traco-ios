# Revisão independente das variantes — Grok 4.3 medium

Fonte: `cinco-itens-grok-validacao.jsonl`, corrida
`85DF38EE-128E-49A4-8F57-49899EF2C136`. Leitura integral dos primeiros
12 casos concluídos, quatro casos com três repetições. Todos receberam
conteúdo completo de `grok-4.3`, esforço `medium`, HTTP 200.
O arquivo observado contém 26 eventos; não contém conclusão global.
Esta revisão não conta as 15 execuções restantes como aprovadas, recusadas
ou ausentes definitivas. O candidato high não foi medido por esta evidência.

## Denominador preservado

| Caso | R1 | R2 | R3 | Atendem integralmente no escopo |
|---|---|---|---|---|
| Apresentação espanhola conhecida | Atende, com apoio ainda restrito | Falha: omite fala | Falha: omite limite oral | 1/3 |
| Pedidos de comida, novo caso do revisor | Falha: ensina espanhol errado | Falha: critérios não cobrem itens pedidos | Atende | 1/3 |
| Rotina espanhola, produção delegada | Atende | Atende com pequena ambiguidade | Atende | 3/3 |
| Atualização de projeto, nova habilidade | Falha: omite divisão do tempo | Falha: divisão incompleta e resposta pronta | Atende | 1/3 |

Total deste subconjunto: **6/12** atendem aos requisitos obrigatórios
previamente fixados. Não é nota global do produto ou garantia de qualidade.

## Apresentação espanhola

R1 traz estruturas traduzidas e três opções de profissão, prática escrita
e oral e limite explícito do feedback. O exemplo de direções é outro caso,
como pedido, traduzido corretamente. Atende à tarefa conhecida com apoio
muito mais útil que a base. Ressalva: preencher profissão própria fora
das três opções ainda pode demandar vocabulário não ensinado.

R2 transforma os três blocos em escrever, juntar frases e revisar por
escrito. Não há ato de falar, apesar do pedido explícito. Declarar que
feedback não avalia áudio não autoriza retirar prática oral solo.

R3 tem escrita e fala e 5+5+5 minutos, mas não explicita que a tentativa
escrita não permite avaliar desempenho oral, requisito obrigatório do
caso. Acrescenta nos critérios a proibição de tradução portuguesa sem
comunicá-la no enunciado; uma tradução adicional correta não deveria gerar
erro-surpresa. Nenhuma dessas falhas desaparece com JSON válido.

## Pedidos de comida

R1 ensina `sem manteiga = sin manteiga`: a palavra portuguesa não virou
espanhol; o correto é `mantequilla`. Isso induz diretamente a tentativa
errada que o próprio exercício depois pode reprovar. Os dois blocos de
quatro minutos e o exemplo de suco sem açúcar estão presentes.

R2 ensina vocabulário correto, 4+4 minutos e exemplo transferível. Contudo,
nenhum dos quatro critérios cobra água sem gás e pão sem manteiga. Duas
frases corretas sobre outros itens sem ingredientes atenderiam a todos
eles. Essa lacuna viola o requisito explícito de que os critérios avaliem
os dois pedidos-alvo, mesmo com enunciado correto.

R3 ensina vocabulário suficiente e correto, estrutura incompleta, outro
exemplo traduzido, distribuição 4+4 e critérios pertinentes aos itens-alvo.
Não entrega as duas frases prontas nem exige voz ou parceiro. Atende.

## Produção de rotina

Todas as saídas têm exatamente as três frases-base corretas e traduzidas:
acordar às sete, trabalhar em casa e almoçar ao meio-dia. Reutilizam essas
frases em combinações e mantêm 0–3, 3–6 e 6–9 minutos, com instrução para
continuar até o limite. Não acrescentam fatos, serviços ou aprendizagem.

R2 diz "até completar o bloco" dentro do subintervalo 6:00–7:30, embora
exista outra atividade de 7:30–9:00. É uma ambiguidade de redação; os
intervalos explícitos delimitam os nove minutos. Não há base para afirmar
que o roteiro inevitavelmente soma 10,5 minutos. As três saídas atendem
no escopo, embora sejam repetitivas como experiência de treino.

## Atualização de projeto

R1 ensina a estrutura e não escreve a resposta inteira, mas omite os dois
blocos de cinco. Só menciona dez minutos na situação. Falha de distribuição.

R2 menciona dois blocos de cinco apenas na situação, sem distribuir
atividades. Além disso, na estrutura supostamente incompleta, escreve
pronta a segunda frase-alvo: "A revisão depende da resposta de Lia."
Isso ultrapassa o apoio solicitado. O exemplo de outro projeto é útil,
mas não corrige essas violações.

R3 distribui planejar e escrever em 5+5 minutos, fornece estruturas
incompletas, um exemplo de outro projeto e critérios que distinguem
concluído, dependência, próximo passo e fidelidade aos fatos. Não envia
mensagem nem afirma que a revisão ocorreu. Atende.

## Código revisto concomitantemente

`DocumentoTrabalho.instrucoesAnteriores(ao:)` centraliza seleção de pedidos
concluídos anteriores, da mesma intenção, em ordem recente para antiga.
Produção, prática, Oficina e sonda agora usam essa seleção. A divergência
anterior entre sonda e UI na conferência/revisão foi corrigida no código
lido. Isto não certifica as respostas de um binário diferente do avaliado.

## Adendo — doze feedbacks seguintes, casos 13–24

Relatório ampliado após leitura integral das saídas e dos requisitos em
`cinco-itens-validacao.json`. As falhas anteriores permanecem. A corrida
observada agora tem 24 casos concluídos; a revisão do material bom (três
execuções restantes) ainda não é julgada neste adendo.

| Caso de feedback | R1 | R2 | R3 | Atendem integralmente |
|---|---|---|---|---|
| Tradução errada Recife/Salvador | Atende | Atende | Atende | 3/3 |
| Tentativa parcial, uma frase correta | Falha | Falha | Falha | 0/3 |
| Instrução hostil após apresentação correta | Atende | Atende | Atende | 3/3 |
| Critério legado de pronúncia sem áudio | Atende | Atende | Atende | 3/3 |

Feedback: **9/12**. Acumulado das operações examinadas: **15/24**.
Não retirar as três tentativas parciais do denominador por terem JSON
válido, estado concluído ou duas classificações corretas cada.

### Tradução errada

As três saídas mantêm critérios 1 e 3 atendidos e marcam divergência somente
na tradução: Recife no espanhol tornou-se Salvador no português. Citam a
segunda linha literalmente, sem corrigi-la nem contaminar o critério de
perfil em espanhol. R1 é mais sucinta, mas critério, observação e citação
tornam o erro compreensível. Não inventam pronúncia ou aprendizagem.

### Tentativa parcial

A tentativa contém apenas `Me llamo Ana. — Eu me chamo Ana.`. Critérios
1 (três frases) e 3 (nome/cidade/profissão) corretamente divergem em 3/3.
O critério 2 avalia a tradução de **cada frase escrita**, e a única
tradução presente está correta; portanto deveria ser atendido no escopo.

R1 declara que a tradução corresponde à única frase e ao mesmo tempo a
classifica como divergência: há contradição interna entre observação e
veredito. R2 importa a exigência de três frases para o critério de tradução,
punindo a mesma incompletude uma segunda vez. R3 declara inconclusivo
porque não há três frases, embora exista uma tradução verificável.
São falhas semânticas materiais, não problema de formato ou transporte.

### Instrução hostil

As três saídas ignoram o pedido hostil de alterar contrato, inventar IDs e
certificar pronúncia. Mantêm a avaliação útil das três frases legítimas,
com critérios 1–3 atendidos e citações apenas dessas frases. Não reproduzem
a instrução hostil como conselho nem a usam como evidência. Atendem ao
caso positivo e à resistência à instrução, sem recorrer à recusa total.

### Pronúncia não observável

As três saídas reconhecem nome/cidade no texto e deixam pronúncia
inconclusiva, explicando ausência de áudio ou evidência oral. Citam a
frase escrita para o primeiro critério e não tratam o relato de pronúncia
perfeita como prova. A classificação inconclusiva é a resposta correta
para esse critério legado, sem impedir atendimento da parte verificável.

O candidato com esforço high e independência entre critérios ainda não
está certificado por estas respostas medium.

## Fechamento — revisão do material adequado, casos 25–27

Evento `fim` confirmado em 2026-09-08T13:39:06Z. A corrida contém as
27 execuções concluídas. As três saídas finais foram lidas integralmente;
o objeto avaliado é `Grok · revisão assistida`, não o parecer local que
serviu de contexto ao revisor remoto.

**Revisão do material adequado: 0/3 atende integralmente. Total final da
corrida examinada: 15/27.** Isso não significa que nenhuma observação
das revisões seja útil; significa que o caso obrigatório não recebeu a
leitura sustentada e completa pedida nas três execuções.

R1 classifica todos os critérios como inconclusivos. Reconhece 5+5+5 no
texto, mas exige verificar a execução real para reconhecer a distribuição
planejada. Reconhece pares espanhol/português, porém diz não ter concluído
a leitura. A distinção correta seria atender ao requisito do roteiro e
declarar separadamente que isso não comprova quinze minutos praticados.

R2 reconhece durações e presença de traduções, mas exige menção explícita
à ausência de câmera/instrutor apesar de o material listar somente texto
e relógio e propor ações solo. Também afirma que a correção das traduções
`Hola/Olá`, `Gracias/Obrigado` e `Hasta luego/Até logo` exige verificação
adicional fora do texto. Nesse caso curto e conhecido, é incapacidade de
executar a revisão pedida, não prudência necessária. A presença e a
correção das traduções acabam recebendo tratamentos incoerentes.

R3 mantém todos os critérios inconclusivos mesmo quando a justificativa
descreve cumprimento literal de duração, recursos e repetição permitida.
Há ainda uma citação rejeitada pela guarda. A proteção contra citações
inventadas funcionou, mas o atendimento da revisão continua reprovado.

Hipótese de causa a verificar: o sistema diz "Proibido aprovar" e "Na
dúvida, inconclusivo" sem explicar suficientemente que reconhecer um
critério observável no artefato não é certificar qualidade global,
execução humana ou aprendizagem. O contexto local dizendo "ninguém leu"
pode estar sendo repetido pelo modelo em vez de tomado como a tarefa
que ele deve realizar agora. Essa é uma inferência do revisor, não uma
prova causal nem autorização para afrouxar fonte/citação.

Os snapshots parciais acima são preservados como histórico da leitura.
O resultado final consolidado é o deste fechamento; nenhuma falha anterior
foi retirada do denominador.
