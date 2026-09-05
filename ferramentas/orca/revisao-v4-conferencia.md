# Revisão V4 — conferência do artefato contra o pedido (ADR 2026-09-05p)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026. Só leitura; nada
editado nem commitado (este arquivo e as capturas `v4-*.png` ficam fora do
commit). Branch `Vitorepf/volta-4-conferencia` @ 155044b sobre main b857b81.

## Veredito

**CORRIGIR ANTES — lista mínima de UM item (P2-a).** O resto pode entrar
depois. Nenhum P1: contratos de acesso, autoria, commit-antes-da-conferência,
export/import e "nunca aprovado" estão cumpridos e provados por teste e por
jornada real na tela. O P2 é uma frase FALSA na tela sobre o artefato
("nenhuma marca de minutos") quando o artefato escreve "cinco minutos" por
extenso — a gramática do pedido lê números por extenso, o leitor do artefato
só lê dígitos. Correção de poucas linhas (reusar `valor()`/a mesma
alternância no regex de `conferirTempo`).

Fatos duros desta revisão: suíte integral **598/0** no 6033B043; build do
dono e build genérico **sem warnings**; regressão `trabalho-acao-aviso.yaml`
**passou**; jornada real pela TELA com Apple Intelligence no iPhone 17 do dono
**funcionou** (versão + linha + disclosure + "Conferir de novo" gravando 2º
registro no disco); merge em main é **fast-forward limpo**.

## 1. Contratos — leitura do diff

Diff: `git diff main...HEAD`, 9 arquivos, +1066/−5. `xcodegen generate` sobre
project.yml não altera o pbxproj commitado (git status limpo).

| Pergunta do orquestrador | Resposta | Evidência |
|---|---|---|
| JSON V4 antigo decodifica com nil? | Sim | `Artefato.conferencias: [Conferencia]?` (Trabalho.swift:86), Codable sintetizado; teste `jsonV4AntigoDecodificaSemConferencia` remove a chave e lê `nil` |
| Conferência de versão antiga nunca aplicada à nova? | Sim | `registrarConferencia` exige `i == artefatos.count - 1`, senão `Erro.pedidoAntigo` (Trabalho.swift:183-187); `conferir` da Oficina lê a intenção por `artefato.intencaoID`, não `intencaoAtual`; teste `conferenciaDeVersaoAntigaNaoSeAplicaAVersaoNova` |
| Bilinguismo declarado não vira erro? | Sim | `conferirIdioma`: trecho passa se QUALQUER idioma esperado tem hipótese ≥ 0,30 (ConferenciaTrabalho.swift:169); teste `bilinguismoLegitimo…` |
| Texto curto = inconclusivo? | Sim | `prosa()` descarta linhas < 40 chars; sem prosa → `.inconclusivo` com "Não é o mesmo que dizer que o idioma está certo" (:154-156); teste `textoCurtoDemais…` |
| Pedido sem restrição = tudo naoAvaliado e a linha diz? | Sim | critérios vazios → resultado "Restrições do pedido" naoAvaliado + "Destinatário…" naoAvaliado; linha "Conferência: nenhum critério examinado · 2 critérios não avaliados" (teste `pedidoSemRestricao…`) |
| Soma não conta o total duas vezes? | Sim, com heurística estreita | remove UMA ocorrência do valor igual ao total só se `count > 1 && soma != total` (:197-200); teste `totalAnunciadoNoCabecalho…`. Ver P3-c para o caso em que a heurística erra |
| Leitura do artefato antes de AcessoTrabalho? | Não | `OficinaTrabalho.conferir` chama `verificarAcesso()` antes de tocar `documento` (OficinaTrabalho.swift:200); a view só monta `conferencia(…)` dentro de `documento(oficina)`, que só existe se `acesso.permitido` (TrabalhoView.swift:35-40); teste `acessoNegadoNaoLeOArtefato…` prova zero leituras do closure |
| Concorrência Swift 6.2 limpa? | Sim | `ConferenciaTrabalho` é `nonisolated enum` sem estado mutável; `NLLanguageRecognizer()` instanciado por trecho dentro de função síncrona (:161); `Regex` fica em propriedade computada (não Sendable, não compartilhado). Compilou sem warnings de concorrência na suíte |
| 05g/05i: commit da versão antes da conferência; falha não perde artefato | Sim | `gerar`: `guard alterar({ receber }) … else { return }; conferir(...)` — dois commits (OficinaTrabalho.swift:179-183); teste `falhaAoGravarAConferenciaPreservaOArtefatoJaCommitado` |
| 05l: export/import não leva/cria conferência | Sim | `IntercambioTrabalho` não referencia `conferencias` (grep vazio); teste `exportarMarkdownNaoLevaConferenciaEImportarNaoCriaUma` |
| 04a: a linha diz o que fez e o que NÃO avaliou | Sim | `linha()` sempre anexa "· N critério(s) não avaliado(s)" e o critério "Destinatário, conteúdo e adequação" é acrescentado em toda conferência concluída (:41-43) |
| VISAO "nunca qualidade verificada" | Sim | nenhuma string "verificad"/"aprovad" na linha (teste `aLinhaNuncaAprova…`); rodapé do disclosure: "nada aqui aprova o artefato" |

Achados de código (severidade abaixo em §6).

## 2. Caso real (prova/4.md)

**Leitura humana do implementador (prova/4.md): correta.** Reli a saída
integral gravada contra as 4 restrições: não há UMA tradução em português
(os parênteses são alternativas em espanhol); "Minuto 1/2/3" ×3 blocos = 9
min, o "5 Minutos" só no título copiado do pedido; portunhol dentro das falas
("comendo", "jogando", "¿Qué estás fazendo?"); Bloco 2 e 3 repetem a mesma
lista; aspas desbalanceadas. "Não utilizável como pedido" está certo.

**Linha de EVOLUCAO: honesta.** "Qualidade ainda insuficiente", "DEIXOU
PASSAR a ausência de traduções", "jornada pela tela" nomeada como falta.

**ADR 05p: descreve o código sem inflar.** Gramática declarada (2 regras),
custo nomeado (regra ≠ sentido; caso real como exemplo), Fora explícito
(2ª passada, semântica, com/sem histórico, tela). Uma imprecisão pequena:
"Prova: … um caso real executado" — a conferência gravada em prova/4.md diz
"encontrei **1 marcas** somando 5", mas o código commitado emite "1 marca"
(singular, ConferenciaTrabalho.swift:203); a saída gravada é de um build
anterior ao commit (o texto humano abaixo já cita o singular). Nit.

**Caso real NOVO, pela tela, nesta revisão (16:57, iPhone 17 do dono, Apple
Intelligence no aparelho, sem conta Grok; artefato integral extraído do
`default.store` do App Group — 2.214 caracteres):**

| Restrição | O que saiu | Leitura |
|---|---|---|
| roteiro solo | "Incentive a pessoa a praticar a frase com um amigo ou familiar"; "Comece com uma breve introdução…" — instruções para um facilitador, não fala para quem pratica sozinho | não atende |
| 3 blocos de 5 min | 3 blocos, mas "Minuto 1…7" corridos (3+2+2 = 7 min); a introdução AFIRMA "cada um com cinco minutos" | não atende |
| frases em espanhol com tradução | desta vez HÁ pares ("hola" (olá), "¿Dónde está el baño?" (Onde está o banheiro?)), poucos; "gracias" (graças) errado; boa parte é "Lista de palavras básicas…" — instrução, não material | parcial |
| iniciante | vocabulário inicial | atende |

Conferência gravada (lida do disco): idioma `atendidoNoEscopo`; tempo
`divergencia` com justificativa "Não encontrei distribuição: nenhuma marca de
minutos no artefato" — **falsa**: o artefato escreve "cinco minutos" (por
extenso) e "Minuto 1…7"; destinatário `naoAvaliado`. Linha: "Conferência: 1
possível divergência · 1 critério não avaliado". Direção certa, motivo errado
(ver P2-a). "Qualidade ainda insuficiente" continua verdadeiro.

## 3. Design (julgar/portão)

Capturas simctl (iPhone 17 do dono, 1A46B6D3): `v4-conferencia-linha.png`,
`v4-conferencia-expandida.png`, `v4-conferencia-expandida-2.png`,
`v4-conferir-de-novo.png`, `v4-conferencia-historico.png`,
`v4-regressao-acao-aviso.png`.

- **Hierarquia:** a linha vem logo abaixo do produtor, dentro do cartão da
  versão, em `Tema.meta` com chevron — lê como atributo da versão, não como
  ação. Correto. No histórico, texto simples em `tintaSuave` sob o título da
  versão — correto e discreto.
- **Tokens:** só `Tema.meta`, `Tema.barra`, `Tema.tintaSuave`, `Tema.aviso`
  (apenas na palavra "Possível divergência"), botão no `AcaoTrabalhoStyle`
  existente. Sem cor nova, sem cartaz, sem "aprovado". Rodapé "nada aqui
  aprova o artefato" presente.
- **Defeito visível (P3-c):** a label do `DisclosureGroup(String)` quebra em
  duas linhas CENTRALIZADA ("…1 critério / não avaliado" centrado) enquanto
  todo o resto do cartão é alinhado à esquerda (`v4-conferencia-linha.png`).
- **Cópia (P3-d):** "No pedido (instrucao)" mostra o `rawValue` do enum, sem
  acento e sem ser palavra do produto; devia ser "instrução" / "resultado
  desejado" / "intenção".
- **Densidade:** 3 critérios × (título, situação, trecho do pedido repetido
  3×, justificativa) — o mesmo trecho literal do pedido aparece três vezes
  seguidas porque os três critérios vêm da mesma frase. Aceitável para a fatia
  (o autor confere a leitura), mas é o primeiro lugar a enxugar quando houver
  mais critérios.
- Fora do diff, visível em todas as capturas: `ConteudoTrabalhoView` mostra
  `**Título**` com asteriscos literais dentro de `###`. Pré-existente, não é
  desta volta.

## 4. Prova executada por este revisor

Tudo via `ferramentas/orca/com-trava.sh`.

| Passo | Resultado literal |
|---|---|
| `xcodebuild test` no 6033B043 (iPhone 17 Pro Max), `-derivedDataPath build` | 1ª tentativa: "The test runner hung before establishing connection" (simulador recém-ligado, infraestrutura). 2ª: **"✔ Test run with 598 tests in 121 suites passed after 6.501 seconds"**; `Suite ConferenciaTrabalhoTests passed` (20 testes contados no arquivo). Simulador de teste desligado ao fim. |
| `xcodebuild build` destino `id=1A46B6D3` | BUILD SUCCEEDED, 0 warnings |
| `xcodebuild build` destino `generic/platform=iOS Simulator` | BUILD SUCCEEDED, 0 warnings |
| `./maestro/varrer.sh maestro/trabalho-acao-aviso.yaml` (só o 1A46B6D3 booted) | `FALHAS: nenhuma`, EXIT 0 |
| Jornada real pela tela, modelo LIGADO (`launchctl getenv TRACO_SEM_MODELO` vazio) | Trabalho novo → pedido literal do orquestrador → "Preparar com IA" → versão "Apple Intelligence no aparelho" em ~1 min → linha → disclosure → "Conferir de novo" (rodapé 15:57 → 16:00; disco passa de 1 para 2 `conferencias`, mesmo `pedidoID` do pedido) |

Observação de instrumento: o `tapOn: {id: "trabalho-gerar"}` após os dois
swipes não disparou (o botão estava visível); tocar pelo texto "Preparar com
IA" funcionou. E `{id: "trabalho-conferir"}` não é encontrado pelo maestro
mesmo com o botão na tela ("Element not found"); tocar por texto "Conferir de
novo" funciona (P3-i).

## 5. Merge

`git merge-base --is-ancestor main HEAD` → verdadeiro. `git merge-base main
HEAD` = b857b81 = `main`. main não avançou; `git diff main...HEAD` toca só os
9 arquivos da volta. **Merge em main é fast-forward limpo.** `xcodegen
generate` não altera o pbxproj commitado.

## 6. Achados por severidade

### P1
Nenhum.

### P2
- **a) O leitor de tempo do artefato só lê dígitos; o do pedido lê por extenso.**
  `conferirTempo` usa `#/(?i)(?<x>\d+)\s*(minutos?|mins?\b)/#`
  (ConferenciaTrabalho.swift:188) enquanto `tempo(em:)` aceita "cinco",
  "quinze" etc. (:139-149). Evidência: caso real 16:57 — artefato diz "cada
  um com cinco minutos" e a tela diz "nenhuma marca de minutos no artefato"
  (`v4-conferencia-expandida-2.png`; JSON do disco). Consequência: (1) frase
  falsa na tela; (2) um artefato CORRETO escrito "cinco minutos" ×3 seria
  marcado divergente com o mesmo motivo falso. Contraria 04a ("a linha diz o
  que fez") no detalhe, embora a situação (divergência) fique do lado seguro.
  Correção mínima: mesma alternância + `valor()` no regex do artefato, ou, no
  mínimo, a justificativa dizer "nenhuma marca de minutos EM DÍGITOS".
  Anexo: "Minuto 1…7" (número após a unidade) também não conta, como o
  implementador declarou na prova — nos DOIS casos reais a divergência de
  tempo saiu com motivo parcial/errado.

### P3
- **b) Versão produzida SEM conferência é silêncio, não "sem conferência".**
  JSON anterior à ADR, ou primeiro commit ok e segundo falhou/app morreu
  entre `receber` e `conferir` (OficinaTrabalho.swift:181-183): a view não
  mostra nada e o botão "Conferir de novo" só existe DENTRO do disclosure que
  só existe com conferência. Não há rota para pedir a primeira. ADR diz "nil é
  sem conferência, nunca sem divergências" — no disco sim; na tela é ausência
  muda (04a).
- **c) Label do disclosure centralizada ao quebrar linha** (TrabalhoView.swift:246,
  `DisclosureGroup(String)`); ver `v4-conferencia-linha.png`. Label custom com
  `.multilineTextAlignment(.leading)` + frame leading.
- **d) `r.fonte.rawValue` na tela** ("No pedido (instrucao)", TrabalhoView.swift:257).
- **e) `EstadoConferencia.falhou` nunca é produzido** (Trabalho.swift:45) — caso
  morto que `linha()` trata. Apagar ou usar.
- **f) prova/4.md grava "1 marcas"** mas o código emite "1 marca": a saída da
  conferência na prova não é do build commitado (nit de honestidade documental).
- **g) Conferência roda síncrona no MainActor**: `NLLanguageRecognizer` por
  linha, até 200.000 caracteres, dentro do `Task` de `gerar` e no botão. Para
  artefatos típicos (2 KB) é imperceptível; num de 150 KB pode travar a tela
  por segundos. Sem prova de tempo; risco, não defeito observado.
- **h) Heurística "total não conta duas vezes"** remove UMA ocorrência; artefato
  com total no cabeçalho E no rodapé vira divergência falsa. Limite da
  gramática declarada; só registrar.
- **i) `accessibilityIdentifier("trabalho-conferir")` não chega ao maestro**
  ("Element not found" com o botão visível); por texto funciona. Testabilidade.
- **j) Densidade:** o mesmo trecho do pedido repetido 3× no disclosure (§3).
- Fora do diff: asteriscos literais em `### **Título**` no `ConteudoTrabalhoView`.

### O que está certo e provado (para não ser refeito)
Decodificação aditiva; conferência presa ao pedido/intenção da versão (nunca à
atual); só a última versão recebe registro; acesso revalidado antes de ler e
antes de mostrar; falha do 2º commit preserva o 1º; export/import sem
conferência; linha sempre conta os não avaliados e nunca diz
verificado/aprovado; bilinguismo declarado não vira erro; texto curto =
inconclusivo; concorrência limpa (instância nova do reconhecedor por trecho,
nada compartilhado); 598/0; ff-merge.
