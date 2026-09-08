# Revisão independente — sondagem Grok 4.6

Fonte: `cinco-itens-grok46-sondagem.jsonl`, corrida
`7D6D5A0F-C9CB-44CB-B853-337FB1CCDF5A`, encerrada em
2026-09-08T14:08:09Z. Quatro casos, uma execução por caso; entradas,
requisitos e saídas foram lidos integralmente. Não é a prova de três
repetições exigida para aprovação sustentada. O fixture de comida ainda
menciona três execuções nos requisitos, mas o lote observado tem uma.

As chamadas identificam efetivamente `grok-4.6` solicitado/respondido,
HTTP 200, esforço high nas preparações/feedback e medium na revisão.
`modeloConfigurado: grok-4.3` é configuração geral; o diagnóstico da
chamada e `modeloTrabalhoConfigurado` mostram o executor desta sondagem.
Transporte e contagem de tokens não determinam os vereditos abaixo.

| Caso | Parecer semântico desta execução | Duração |
|---|---|---|
| Apresentação iniciante | Não atende: profissão sem apoio espanhol | 74,42 s |
| Pedidos de comida | Atende no escopo, com refinamento de artigo | 76,78 s |
| Feedback parcial | Atende | 24,93 s |
| Revisão de material adequado | Atende | 78,34 s |

**3/4 atendem nesta sondagem unitária.** Não certifica repetibilidade,
adaptação, produção delegada ou todos os cinco objetivos do usuário.

## Apresentação

Há escrita e fala em três blocos de cinco, restrições solo preservadas,
limite explícito de feedback escrito e exemplo de outra situação com
traduções corretas. A regra diferencia origem de profissão, e a opção
fictícia está identificada como tal, sem inventar perfil do usuário.

Entretanto, o material pede que alguém começando do zero preencha sua
profissão em espanhol e não ensina nenhuma palavra espanhola de profissão.
Até a opção fictícia oferecida diz **professora**, em português, sem
ensinar `profesora`. A opção alternativa portanto não elimina a dependência
que deveria resolver. O usuário teria de saber ou buscar o vocabulário.
O fato de o exercício não escrever a frase pronta não justifica omitir
uma palavra necessária para a pessoa construí-la.

Também há uma atividade de ler duas vezes em bloco de cinco minutos sem
orientação sobre usar o restante; isso é menos determinante que a falta
de vocabulário, mas ainda limita o roteiro como uso do tempo.

## Comida

Material oferece vocabulário espanhol suficiente, estruturas incompletas,
regra de `sin`, dois blocos de quatro e exemplo alternativo traduzido.
Os critérios cobrem os dois pedidos específicos e compreensibilidade,
sem avaliar o exemplo nem entregar as frases-alvo prontas. Atende ao
conteúdo e à autonomia do iniciante neste caso.

O trecho `agua = água (use una)` merece refinamento, **não uma acusação
de erro gramatical absoluto**. Conferi a fonte primária da RAE: antes de
substantivo feminino iniciado por /a/ tônico, `un` é usual; a forma plena
`una` é admitida, embora menos frequente.
[RAE: El agua, esta agua, mucha agua](https://www.rae.es/espanol-al-dia/el-agua-esta-agua-mucha-agua-0).
Ensinar a forma habitual ou dispensar o artigo é mais natural para este
iniciante. Não seria correto inventar uma regra de reprovação de toda
tentativa com `una agua`.

## Feedback parcial

Reconhece divergência de quantidade (uma frase, não três) e de perfil
incompleto, mas atende ao critério de tradução da única frase escrita.
Observações explicam os vereditos e citam literalmente a tentativa.
Não reescreve frases ausentes nem infere aprendizagem. Corrige nesta
execução a confusão semântica vista nas rodadas anteriores.

## Revisão do material adequado

Reconhece corretamente três intervalos consecutivos de cinco minutos,
explicando que a instrução de repetir até completar o primeiro bloco não
cria um quarto. Confere efetivamente os pares espanhol/português e
considera recursos e atividades suficientes para uso solo. Não exige
câmera, instrutor, mais frases ou proibição de repetir. Todas as citações
exibidas são literais e pertinentes. Reconhece o roteiro sem certificar
execução humana ou aprendizagem. Atende nesta execução.

## Causa geral ainda corrigível

A fronteira entre **ensinar componentes** e **produzir a tentativa pelo
autor** ainda parece ampla demais para o gerador. A falta de vocabulário
é compatível com uma interpretação excessiva de "não dar a resposta";
essa é uma hipótese de contrato, não prova causal. Uma regra geral curta
resolve a ambiguidade sem mencionar espanhol, profissão ou fixture:

> Ensine as palavras, regras e componentes necessários para montar a
> tentativa. Preservar autoria significa deixar a composição/resolução
> para a pessoa, não omitir esses componentes. Uma opção fictícia também
> deve poder ser realizada com o apoio fornecido.

É coerente medir a permissão explícita de ensinar palavras isoladas que
o candidato seguinte já incorporou. Não há justificativa nesta prova para
adicionar tabelas fixas de profissão, correção textual de `agua` ou outro
remendo específico. A correção deve ser medida novamente com variação.

Preparações acima de 74 segundos também são custo real da jornada. Não
invalidam a semântica correta, mas impedem tratar a mudança de modelo como
melhoria gratuita de experiência. Este relatório não avaliou a interface
de espera, cancelamento ou recuperação desse candidato.
