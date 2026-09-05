# traco-mcp — o companheiro no Mac

**Contrato operativo deste conector.** Finalidade do produto: [VISAO-PRODUTO](../../VISAO-PRODUTO.md). Permissões e formatos aceitos: [SPEC](../../SPEC.md); capacidades do app: [README](../../README.md). Este servidor atende ao corpus de notas e à entrada de métodos; não é uma API do agregado Trabalho nem implementa toda a colaboração prevista pela visão.

Um servidor MCP sobre a pasta do Traço. Sem dependências além do Python 3 do
sistema. Lê os arquivos expostos da pasta espelhada; escreve apenas em
`entrada/` (texto para uma nota nova, ADR 2026-09-04p) e `metodos/`
(um método novo, ADR 04l). Não modifica `notas/` nem chama modelos.

A IA pode produzir artefatos explicitamente delegados no Traço, com origem
preservada. Isso não amplia a permissão desta ferramenta: `traco_escrever`
recebe texto do próprio autor e não deve receber prosa gerada apresentada como
voz pessoal. Para devolver material produzido fora, use o intercâmbio Markdown
de Trabalho com prévia e origem externa, conforme SPEC; não o disfarce de nota
humana pela entrada MCP. O servidor não oferece importação de versões de
Trabalho, execução de HTML, publicação ou sincronização automática de artefatos.

## O que ele lê

A pasta que o app espelha:

- `Documents/Traço` no iPhone, visível no Finder com o cabo (Arquivos › Traço), ou
- a pasta que você escolheu em **Perfil › Dados › Espelhar numa pasta** — no
  iCloud Drive ela aparece no Mac em
  `~/Library/Mobile Documents/com~apple~CloudDocs/Traço`.

Dentro: `LEIA-ME.md` (o contrato), `INDICE.md`, `traco-corpus.md` e `notas/*.md`.
O contrato de exportação do app exclui o corpo de expressivas, seladas e
queimadas; somente metadados permitidos e a linha de sentido podem aparecer
quando previstos na SPEC. O servidor lê o que está na pasta: não consulta o
SwiftData nem verifica o selo vivo no iPhone. Não acrescente manualmente
conteúdo protegido ao espelho. Uma cópia já entregue ao cliente externo não é
recolhida por uma proteção posterior no app.

## Ferramentas

| nome | devolve |
|---|---|
| `traco_contrato` | o LEIA-ME |
| `traco_indice` | o índice |
| `traco_notas` | lista com gesto, data, domínio, sentido, primeira linha (filtro por forma) |
| `traco_nota` | uma nota inteira pelo id |
| `traco_buscar` | busca lexical com trechos |
| `traco_sentidos` | as linhas de sentido |
| `traco_corpus` | o corpus inteiro |
| `traco_semana` | a revisão da semana |
| `traco_escrever` | grava texto do próprio autor em `entrada/`, para importação posterior como nota aberta; não cria versão de Trabalho |
| `traco_metodo_escrever` | grava um método em `metodos/<id>.json`; entra no catálogo quando o app abrir |

## Entrega e confirmação

A resposta “Guardado em entrada” confirma o arquivo na pasta; não confirma que
o iPhone o importou ou que a nota foi salva. O app valida a entrada e confirma
persistência antes de retirar arquivos elegíveis. Falha, recibos de importação
e conteúdo protegido seguem os contratos da SPEC; importar não deve abrir um
selo nem reatribuir conteúdo de IA à pessoa. Métodos também passam pela
validação do app: recebimento não equivale a eficácia comprovada do método.

## Ligar ao Claude Desktop

`~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "traco": {
      "command": "python3",
      "args": [
        "/caminho/para/traco-ios/ferramentas/traco-mcp/servidor.py",
        "/Users/voce/Library/Mobile Documents/com~apple~CloudDocs/Traço"
      ]
    }
  }
}
```

Sem o segundo argumento ele procura a pasta no iCloud Drive.

## Provar

```bash
python3 ferramentas/traco-mcp/servidor.py --autoteste
```
