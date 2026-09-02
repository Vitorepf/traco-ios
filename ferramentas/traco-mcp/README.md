# traco-mcp — o companheiro no Mac

Um servidor MCP **só de leitura** sobre a pasta do Traço. Sem dependências
além do Python 3 do sistema. Nunca escreve na pasta, nunca chama modelo.

## O que ele lê

A pasta que o app espelha:

- `Documents/Traço` no iPhone, visível no Finder com o cabo (Arquivos › Traço), ou
- a pasta que você escolheu em **Perfil › Dados › Espelhar numa pasta** — no
  iCloud Drive ela aparece no Mac em
  `~/Library/Mobile Documents/com~apple~CloudDocs/Traço`.

Dentro: `LEIA-ME.md` (o contrato), `INDICE.md`, `traco-corpus.md` e `notas/*.md`.
O selo do app já vale ali: expressiva em curso nunca sai; selada e queimada só
como metadado e linha de sentido.

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
