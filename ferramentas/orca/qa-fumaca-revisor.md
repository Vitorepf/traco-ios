# QA do teste de fumaça — revisor (Opus 5), 05/set 13:32

Não editei nada. Sem `xcodebuild test`, sem maestro, sem tocar em simulador.

## 0. Build e pbxproj — CONFIRMADO

- `xcodebuild build -destination 'generic/platform=iOS Simulator' -derivedDataPath build-arquiteto` → `** BUILD SUCCEEDED **`, exit 0. Reproduzi por conta própria.
- pbxproj contém `ReciboEntrada.swift` (4 ocorrências) e os 10 arquivos de `Traco/Trabalho/` (4 ocorrências cada; grupo `path = Trabalho` na linha 361). Bate com os arquivos em disco. O `xcodegen generate` das 13:23 pegou.
- `Metodos.json` está no pbxproj **e chega ao bundle** — presente em `build-arquiteto/.../Traço.app/Metodos.json` (30k) e no bundle instalado no simulador. O catálogo não fica vazio em runtime.

## 1. Os 3 riscos do arquiteto

### Risco 1 — corte de 3500 no fallback do aparelho: **REAL. Severidade certa (ALTA/P1), mas a causa-raiz é maior do que ele descreveu.**

Confirmado no código:
- `Sabia.swift:167-170` — `responder` monta `contexto.prefix(5000)` + retrato + `"\n\nPergunta: \(pergunta)"`. A pergunta é o **último** pedaço.
- `Sabia.swift:308-314` — `noAparelho` faz `String(usuario.prefix(3500))`. Corte cego pela cauda.
- Nota longa ⇒ a pergunta some. O modelo vê só `"Contexto (a nota, só para você entender; não a reescreva):\n<nota>"`. O resultado mais provável não é "resposta alheia ao pedido": é **reescrever/resumir a nota**, exatamente o que a própria instrução e o SPEC §5 ("não atribuir texto gerado ao autor") proíbem.

Duas provas de que o autor já conhecia o problema e o contrato:
- `Sabia.swift:54-58` (`responderNasNotas`) põe a pergunta **primeiro**, com o comentário explícito: *"o modelo de bordo corta o pedido no teto, e com o contexto na frente ele repetia o contexto em vez de responder (visto na primeira chamada real, 05/set)"*. A correção existe uma função acima e não foi aplicada em `responder`.
- `Sabia.swift:296-297` documenta a ADR 04t: *"A janela do aparelho é menor, então o pedido é cortado — menos candidatas, **nunca menos verificação**."* O corte de `responder` remove a pergunta, não candidatas.

### Risco 2 — `parseVoltaram` aceita booleano e chave extra: **REAL. Severidade SUBESTIMADA. Elevo de MÉDIA/P2 para ALTA/P1.**

Verifiquei empiricamente (Swift no Mac, mesma função copiada de `Sabia.swift:418-430`):

```
bool  [true,false] -> Optional(Set([0, 1]))
chave extra       -> Optional(Set([0]))
double 1.0        -> Optional(Set([1]))
double 1.5        -> nil
string "1"        -> nil
```

Por que é P1 e não P2:
1. **`false` não é ignorado — vira o índice 0**, que significa "o ponto 0 VOLTOU". Não é aceitar lixo: é **inverter o sentido**. `{"voltaram":[false,false,false]}` (o modelo dizendo "nada voltou") vira "o ponto 0 voltou".
2. Contradiz o comentário da própria função (`Sabia.swift:415-417`: *"não-inteiro derruba a conferência INTEIRA … Meia conferência mentiria sobre o que não voltou"*) e o prompt (`sistemaConferir`: *"Nenhuma outra chave"*).
3. O erro **persiste e viaja**: `RecordarView.swift:224-227` grava `Sinais.naoVoltou(g, faltaram: pontos.count - r.count, de: pontos.count)`. Esse sinal entra em `Retrato.ler` (`Retrato.swift`, bloco *"Nas últimas N provas do Recordar, X de Y pontos não voltaram"*) e o retrato **é enviado à rede** em toda instigação/resposta/contrapor. Um número errado sobre a memória do autor vira fato durável e depois vira contexto de IA. É "estado desonesto" no sentido forte.
4. Amplificador menor: `Sabia.swift:251-252` memoiza (`memoPor: "conferir\u{1}\(usuario.hashValue)"`), então o resultado errado gruda para aquela memória+pontos na sessão.

### Risco 3 — `Gesto.doNome` rejeita método sumido do catálogo: **REAL, severidade certa (MÉDIA/P2).**

Confirmado: `Gesto.swift:14-18` `init?(rawValue:)` aceita qualquer string não-vazia ("a nota não perde o gesto"), mas `Gesto.swift:38-44` `doNome` só aceita (a) id presente em `Catalogo.metodo`, ou (b) nome de exibição batendo em `allCases` (= `Catalogo.todos`). Método fora do catálogo falha nos dois. `Corpus.swift:117` exporta `gesto.nome` — para id desconhecido isso vem de `Metodo.desconhecido(id)` (`Metodo.swift:143`), então o round-trip export→import perde o gesto. `Corpus.swift:216` (`separarCampos`) tem `guard let gesto else { return (texto, [:]) }`: sem gesto, os campos estruturados ficam como prosa.

MÉDIA está certo: o disco não perde nada (só o corpus exportado), o texto sobrevive como prosa, e a janela é estreita (método removido da pasta entre exportar e importar).

## 2. Risco MAIOR que ele deixou passar

### **ALTA/P1 — o mesmo corte de 3500 mutila `Sabia.conferir`, e ali o resultado é PERSISTIDO.**

`Sabia.swift:243-254`:
```swift
let lista = pontos.enumerated().map { "[\($0.offset)] \($0.element.prefix(400))" }.joined(separator: "\n")
let usuario = "PONTOS:\n\(lista)\n\nDE MEMÓRIA:\n\(escrito.prefix(4000))"
```
Teto possível: 400×N + 4000. Com ~9 pontos os PONTOS sozinhos passam de 3500. No caminho do aparelho, `noAparelho` corta a **cauda** — ou seja, corta justamente **o que o autor escreveu de memória**, e no limite corta até o rótulo `DE MEMÓRIA:`. O modelo então julga "o que voltou" vendo os pontos e nenhuma memória.

Por que isto é pior que o risco 1 dele, e não apenas mais um caso:
- O risco 1 produz um cartão ruim que o autor **vê e pode dispensar**.
- Este produz um veredito que o app **grava sem o autor conferir** (`Sinais.naoVoltou`) e que depois **sai para a rede** dentro do retrato como um fato sobre a memória dele.
- E ele passa pelo parser do risco 2, que converte `false` em "voltou". Os dois compõem: prova longa no aparelho ⇒ conferência feita sem a memória ⇒ parseada por um parser que inverte negativas ⇒ persistida como fato do autor.

A causa-raiz única é `noAparelho` truncar pela cauda uma mensagem composta sem saber qual parte carrega a carga. O arquiteto nomeou o sintoma em `responder` (`Sabia.swift:314`) mas não varreu os outros chamadores de `chamar`. `instigar` (175-185), `contrapor` (193-198) e o de 226-230 sofrem o mesmo corte, mas ali a perda é só de contexto/retrato — degradação, não mentira.

### MÉDIA — a superfície de revisão dele estava incompleta

Ele disse "revisei o WIP de Modelo/Analise" via `git diff`. `git diff` **não mostra nada** para arquivo não rastreado, e há 11 deles em Modelo/Analise, 1258 linhas:

```
?? Traco/Analise/AnaliseDeBordo.swift   ?? Traco/Analise/Grok.swift
?? Traco/Modelo/Degraus.swift           ?? Traco/Modelo/Ferias.swift
?? Traco/Modelo/Metodo.swift            ?? Traco/Modelo/Metodos.json
?? Traco/Modelo/ProximoCompromisso.swift ?? Traco/Modelo/ReciboEntrada.swift
?? Traco/Modelo/Retrato.swift           ?? Traco/Modelo/Sinais.swift
?? Traco/Modelo/Volta.swift
```

Inclui o cliente de rede inteiro (`Grok.swift`) e o `Retrato.swift`, que é o que manda evidência do autor para a rede — e inclui `Metodo.swift`/`Metodos.json`, o catálogo sobre o qual o risco 3 dele inteiro raciocina. Não é acusação de erro: **eu revisei esses arquivos e não achei falha neles** (ver abaixo). É que a afirmação de cobertura não se sustenta pelo método usado. Quem revisar de novo tem de usar `git status --porcelain` / `git add -N`, não `git diff`.

## 3. O que eu revisei e está LIMPO (para não virar retrabalho)

- **Privacidade do selo, caminho remoto: OK.** `Retrato.ler` (`Retrato.swift`) filtra `!fechada && !expressiva`; `Nota.swift:70` define `fechada = trancada || queimada`. `PaginaView.swift:110-114` mapeia certo. `Sessao.contextoDasNotas:591` filtra `!n.fechada, n.gesto != .expressiva`. Nada de nota trancada ou queimada chega à rede. SPEC §5 respeitado.
- **O portão dos motores: OK.** `Grok.responder` tem `guard !Motores.desligados` (`Grok.swift`), e o degrau do aparelho também: `Sabia.swift:279-281` — `noAparelho = AnaliseDeBordo.disponivel && !Motores.desligados`. A queda de `chamar` para o aparelho **não** fura o portão. A suíte não gasta assinatura nem chama modelo de bordo.
- **Catálogo no bundle: OK** (ver §0).

## 4. Evidência do frontend

### Data/atualidade: CONFIRMADO
- PNG `ferramentas/orca/fumaca-frontend.png` — 5 Sep 13:24.
- Binário instalado no sim 1A46B6D3 — `.../Traço.app/Traço`, 5 Sep 13:24.
- `xcodegen` às 13:23, antes dos dois. `xcrun simctl listapps booted` confirma `app.traco` no device 1A46B6D3 (iPhone 17, o único booted). `Metodos.json` presente no bundle instalado.
- Resolução 1206×2622 = 402×874pt @3x = tela cheia do iPhone 17. Captura íntegra, não recorte.

### Conteúdo vs. descrição: bate no literal
Confirmei na imagem: relógio 13:24, tema claro, título "Notas", "Sábado, 5 de setembro", barra `Título · Seção · Lista · Numerada · Tarefa | Todas · [ícone de teclado]`, teclado QWERTY com "PT EN" na barra de espaço, corpo vazio, sem alerta/crash/overlay. Nenhuma divergência factual.

### Divergências de **leitura**, não de fato (BAIXA, mas registrem):
1. **"tela inicial"** — a tela está com o **teclado aberto e o foco num editor**. `PaginaView.onAppear` chama `restaurarFoco()`. Isso não é o estado de lançamento frio; é a superfície de escrita já focada. A barra `Título/Seção/Lista/Numerada/Tarefa` são tipos de **bloco de escrita**, não uma lista de notas. Chamar isso de "tela inicial … Notas … vazia" mistura duas coisas.
2. **A captura não prova quase nada do que mudou.** Tela sem uma única nota e sem nenhuma forma visível: ela **não distingue** "vazio saudável" de "catálogo não carregou e não há forma nenhuma disponível" — que é exatamente o risco 3. Eu fechei essa dúvida por outro caminho (`Metodos.json` no bundle, §0), não pela captura. Se quiserem fumaça que valha para este WIP, o próximo passo é uma nota com forma escolhida, não uma tela em branco.

## Ordem sugerida de correção
1. **P1** `Sabia.noAparelho` corta pela cauda — conserta `responder` (pergunta primeiro) **e** `conferir` (a memória não pode ser o que se corta). Uma causa, dois consertos.
2. **P1** `parseVoltaram` — rejeitar `NSNumber` booleano (`CFGetTypeID(x as CFTypeRef) == CFBooleanGetTypeID()`) e rejeitar chave extra, como o comentário e o prompt já prometem.
3. **P2** `Gesto.doNome` — aceitar id gravado que sumiu do catálogo, igual `init?(rawValue:)` já faz.
