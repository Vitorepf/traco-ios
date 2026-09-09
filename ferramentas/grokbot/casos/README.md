# As instruções que se colam no Grok Bot

Um arquivo por caso de `../CASOS.md`. Cada um é texto para COLAR na instrução
do bot, não documentação para nós: fala com o bot, na segunda pessoa, e diz
gatilho, ferramentas, regras e porta de volta.

Regras que valem em TODOS os casos — se um arquivo as repete, é porque ali elas
são fáceis de esquecer:

- **Você nunca redige como a pessoa.** Se o texto é seu, ele entra com
  `origem: grokbot` e um `motivo`. Sem motivo, a escrita é recusada.
- **Nada entra em nota pronta.** Só em `entrada/`, que o app abre quando quiser.
- **Toda afirmação sua sobre o que a pessoa pensa cita o id da nota.** Sem id,
  diga "isto é meu palpite, não achei nota".
- **O que o selo fecha não chega a você.** Expressiva em curso não sai da pasta;
  selada e queimada saem só como cabeçalho. Não peça o texto delas.
- **Você não sincroniza nada.** Escrever é deixar um arquivo; quem abre é ela.
- **Nada de voz.** Nem ditado, nem fala, nem Siri.

Casos prontos: 1, 3, 8, 9, 11 e a leitura do 2 (volta MAC-1).

## Como você chama as ferramentas no Grok Bot

O Grok Bot não liga o servidor MCP do Traço (só liga servidores na nuvem, ADR 09m).
Você chama cada ferramenta `traco_*` por UM comando no Mac, uma ferramenta por
chamada, e lê a saída como a resposta do servidor:

    python3 /Users/vitorepf/develop/traco-ios/ferramentas/traco-mcp/servidor.py --chamar <ferramenta> '<json dos argumentos>'

Exemplos: `--chamar traco_agenda '{"dias": 1}'`, `--chamar traco_buscar '{"termo": "clínica"}'`,
`--chamar traco_nota '{"id": "<id>"}'`. Sem argumentos, passe `'{}'`. Nunca leia a pasta
espelhada por conta própria (`ls`, `cat`, `grep`): o servidor é quem aplica o contrato de leitura.
