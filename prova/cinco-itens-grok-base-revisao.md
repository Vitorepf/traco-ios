# Revisão independente — Grok, cinco itens, base

Corrida `0F738527-7495-40F1-B3E3-89919B46C91A`, concluída em
2026-09-08T13:08:52Z. Modelo configurado: `grok-4-fast-non-reasoning`;
conta ligada. Fixture `cinco-itens-ia-casos.json`, SHA256
`83ea14f5582368249bf63f09cbf9aeed24968f2f92577e4e0686da1ecc8392d3`.

Fonte lida integralmente para as quatro operações abaixo: JSONL no Documents
do app do simulador B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9, corrida filtrada
pelo identificador. Foram confrontados entrada e requisitos do evento
`inicio/lote` com cada `casoConcluido`. O evento `fim` foi confirmado.
Os casos são conhecidos e sintéticos; esta leitura não prova realização
humana, uso pela interface, generalização nem as outras doze operações.

## Resultado por repetição

| Caso | R1 | R2 | R3 |
|---|---|---|---|
| espanhol-solo-3x5 / produzir | Falha na duração exata | Atende no escopo, com ressalva de ritmo | Atende no escopo |
| q2-conhecido-preparar-espanhol-solo / prepararPratica | Reprovado | Reprovado | Reprovado |
| q2-conhecido-feedback-espanhol-correto / conferirTentativa | Atende no escopo | Atende no escopo | Atende semanticamente; rótulos internos expostos |
| espanhol-revisao-duracao / revisar | Detecta defeitos centrais, mas citações inválidas | Detecta defeitos centrais, mas acrescenta exigência não sustentada | Detecta defeitos centrais, mas citações e critérios sem fonte |

## Produção delegada

R1 traz material espanhol utilizável, traduções corretas e prática solo,
sem afirmar aprendizagem. Contudo, os intervalos são 0:00–5:00,
5:01–10:00 e 10:01–15:00: dois blocos têm 4m59s. É um defeito pequeno
para uso, mas descumpre a duração exata obrigatória previamente fixada.

R2 soma explicitamente 1+2+2, 1+1+3 e 1+2+2 minutos. Traduções dos
componentes são corretas; as frases compostas reutilizam esses componentes.
É executável solo e não inventa recursos ou realização. Ressalva: as
contagens de cinco repetições em dois minutos e oito pares em três minutos
não explicam o ritmo; o usuário terá de distribuir o tempo. Não há evidência
suficiente para afirmar que esses intervalos sejam impossíveis.

R3 distribui cinco frases de 60 segundos em cada um dos dois primeiros
blocos, seguidos por 2+2+1 minutos. As traduções estão corretas; a sequência
final é composta de trechos já traduzidos. Nenhum recurso incompatível ou
afirmação de aprendizagem encontrada. Atende a este caso; não mede precisão
oral e não a promete.

## Preparação de prática

R1: o exercício manda usar estruturas do exemplo, mas o exemplo é uma
pergunta sobre estação de trem e uma resposta de localização. Os critérios
exigem seguir essa estrutura com ser/estar na primeira pessoa e restringem
vocabulário ao exemplo ou cognatos. Isso não fornece apoio suficiente para
nome/cidade/profissão e pode penalizar construções corretas como `Me llamo`
e `Vivo en`. A duração 5+5+5 e as traduções do exemplo atendem. Não aprova
utilidade só porque o JSON e o número de critérios são válidos.

R2: há um critério sobre a tradução do EXEMPLO, que é produção da IA,
não sobre a tentativa do usuário. Outro proíbe qualquer palavra do exemplo,
restrição arbitrária que pode penalizar palavras espanholas comuns.
O enunciado pede comparar fala com escrita e encontrar diferenças
ORTOGRÁFICAS, embora não haja áudio nem transcrição. O prólogo espanhol
`En la calle, un turista pregunta` não está traduzido. Não explicita o
limite de avaliação oral pedido. A duração nominal atende.

R3: continua sem apoio linguístico suficiente para alguém começando do zero
escrever uma apresentação; o exemplo de localização não ensina essa tarefa.
O critério "Cada frase inclui, na ordem indicada, nome, cidade e profissão"
contradiz a distribuição dos três elementos em três frases e pode reprovar
uma tentativa correta. Não explicita que a conferência escrita não verifica
desempenho oral. Duração e traduções do exemplo atendem.

Conclusão desta operação: **0/3 atende integralmente**. Causas comuns:
confusão entre apoio e tarefa-alvo, critérios que avaliam o material da IA,
e instruções que não podem ser verificadas no canal disponível.

## Conferência da tentativa correta

As três repetições reconhecem os três critérios como `atendidoNoEscopo`.
Reconhecem `diseñadora` como designer, não inventam erro, não reescrevem a
tentativa nem atribuem pronúncia ou aprendizagem. As citações correspondem
literalmente à tentativa fornecida. Esse caso positivo atende 3/3.

R3 expõe `T1`, `T2` e `T3` nas observações, embora o usuário veja a tentativa
sem essas etiquetas. É dívida de clareza; não invalida a classificação
semântica correta deste caso. Ainda falta medir tentativa errada, parcial,
ambígua e feedback que motive adaptação pertinente.

## Revisão assistida

As três repetições detectam corretamente 20 minutos (5+10+5), o bloco de
dez minutos e a dependência proibida de professor. As citações exibidas
para essas divergências são literais e pertinentes.

R1 acrescenta três critérios inconclusivos porque a aplicação rejeitou
citações não literais. A guarda evita confirmação falsa, mas o atendimento
não alcança a exigência de citações corretas em toda a revisão.

R2 acrescenta que duas frases seriam insuficientes para quinze minutos.
O pedido não define quantidade mínima e repetição solo pode usar poucas
frases; essa conclusão categórica não é sustentada apenas pela contagem.
Seria válido apontar falta de orientação para preencher o tempo, sem
inventar um mínimo de material. Também deixa adequação/traduções não
avaliadas apesar de a amostra ser curta.

R3 tem citações rejeitadas e inventa um critério de "Ausência de repetições",
sem fonte no pedido; repetição é compatível com treino linguístico. A guarda
o torna inconclusivo, mas não transforma a revisão em integralmente útil.

Não aprovar esta operação como 3/3 por encontrar os dois defeitos esperados:
ela também precisa evitar critérios inventados e sustentar as demais
afirmações. As três saídas são parcialmente úteis, ainda abaixo da régua.

## Próxima prova

Repetir preparação após correção com um caso novo de outra habilidade,
mantendo apoio suficiente, divisão clara entre exemplo e produção, e
critérios exclusivamente observáveis na tentativa. Na revisão, incluir
artefato BOM com poucas frases e repetição planejada: deve evitar inventar
falta de variedade/quantidade. Na jornada, avaliar uma tentativa errada
seguida de exercício adaptado, com histórico e autoria preservados.
