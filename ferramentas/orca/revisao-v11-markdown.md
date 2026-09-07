# G3 — revisão da volta 11 (Ambiente Markdown: conflito, retry e revogação)

Revisor: Claude Opus 5, sessão própria. Worktree `volta-11-markdown`, commit `797adc2`.
Instrumento: iPhone 17e **C7341E64-3A33-4ADD-AF6C-9296215FAD09**, ligado por mim
(estava desligado), tudo por `ferramentas/orca/com-trava.sh`. O iPhone 17 do dono
(1A46B6D3) não foi tocado; nenhum simulador alheio foi desligado. Nada editado no
código, nada commitado: este arquivo e as `v11-rev-*.png` ficam untracked.

## O que eu mesmo rodei

| instrumento | resultado |
|---|---|
| `com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco -destination id=C7341E64… -derivedDataPath <scratch>/dd` | **`✔ Test run with 718 tests in 125 suites passed after 8.162 seconds`**, `** TEST SUCCEEDED **`, `EXIT=0`. Bate com o que o implementador declarou. |
| `grep -c "warning:"` no mesmo log | **6 avisos** (3 únicos). Um deles é DESTA volta: `TracoTests/IntercambioTrabalhoTests.swift:217: variable 'comBaseAtual' was never mutated`. Os outros dois são de `ConferenciaTrabalhoTests.swift:381`, anteriores. |
| App instalado por mim no C7341E64, `TRACO_SEM_MODELO=1`, barra fixada | jornada dirigida por `maestro --device` sob `com-trava.sh`. |
| Conteúdo das 9 capturas `v11-*.png` | abertas uma a uma; ver "Capturas conferidas". |

`maestro/varrer.sh` **recusa rodar**: exige exatamente um simulador booted e havia
seis na máquina. Rodei o fluxo por `~/bin/maestro --device <meu UDID>` sob a trava,
como manda a nota do G4 da V6.

## Os cinco pontos do contrato

### 1. Conflito NUNCA sobrescreve — CONFIRMADO

Li o diff procurando o caminho em que a versão local morre. Não existe.

- `DocumentoTrabalho.aplicarVersaoExterna` (`IntercambioTrabalho.swift:110-140`) só faz
  `artefatos.append(...)`. Não há `remove`, `removeAll`, subscript de escrita nem
  reatribuição de `artefatos` em lugar nenhum do arquivo. `cancelarPedido()`, a única
  outra mutação, mexe em `pedidos[i].estado`, nunca em versões (`Trabalho.swift:261`).
- "Manter só a versão atual" é literalmente `preview = nil` (`IntercambioTrabalhoView.swift:141`):
  não chama `aplicar`, não chama `alterar`, não toca no documento.
- "Guardar o arquivo como nova versão" e o botão do caminho feliz chamam o MESMO
  `aplicar(p)`; a diferença é só o rótulo. Quando o autor escolhe a versão de fora,
  ela entra com `anteriorID: conferida.baseID` — pendurada na base do arquivo, com a
  versão local intacta ao lado.
- O teste prova por igualdade de prefixo, não por sobrevivência:
  `#expect(documento.artefatos.dropLast() == antes.artefatos[...])` mais
  `artefatos.count == 3` e `acoes/evidencias` inalterados. Isso é append-only provado.
- Na tela: `v11-guardado.png` mostra "Histórico de versões (6)" depois de guardar (era 5).

### 2. O retry confirma a MESMA versão sem duplicar — CONFIRMADO, e o teste prova identidade

`retentar()` chama `oficina.guardar()`, não `aplicar` nem `preparar`: nenhuma
reimportação existe nesse caminho. A versão candidata já está em
`oficina.documento` porque `alterar()` faz `documento = proximo` ANTES de
`guardar()` (`OficinaTrabalho.swift:84-85`) — por isso `.aguardandoCommit` é um
estado real e não uma promessa.

O teste **não** prova só "não estourou". Ele guarda o id do candidato antes da
recusa (`let candidato = oficina.documento.versaoAtual?.id`), religa o disco,
chama `guardar()`, **relê do banco** (`try trabalho.ler()`) e afirma
`volta.artefatos.count == 2 && volta.versaoAtual?.id == candidato`. Identidade,
não contagem sortuda. Ainda passa uma terceira vez pela mesma prévia e afirma
`.semNovidade` com `artefatos.count == 2`. É o teste mais forte da volta.

O que ele NÃO cobre: a fiação da View (`tentarGuardar`, `importacaoPendenteID`,
o `onChange(of: oficina.salvo)`). Nenhum teste toca esses três. Ver achado M4.

### 3. Selar a origem com o seletor aberto — a fiação existe e é reativa

Isto não é motor sem superfície. A cadeia fecha:

`@Query notas` → `selos` (`TrabalhoView.swift:28`) → `.onChange(of: selos) { revalidar() }`
(linha 97) → `revalidar()` → `oficina?.verificarAcesso()` (linha 914) →
`intercambioRecolhido = intercambioAberto` (`OficinaTrabalho.swift:319-322`) →
o ramo protegido de `TrabalhoView` desenha a linha (linha 43-48).

Ou seja: o selo cair NÃO depende de o autor tocar em nada. `selos` carrega
`trancada`, `queimada` e `gestoRaw` (`TrabalhoView.swift:942-952`), que são
exatamente os campos que `AcessoTrabalho.estado` lê. A linha aparece sozinha.

A tela também DIZ o que recolheu e nada mais: `Material.recolhimento` nomeia o
TIPO de material ("o arquivo que estava em revisão", "a cópia preparada") e
nunca o conteúdo. Numa tela protegida essa é a escolha certa.

### 4. Os dois toques fora do escopo — SÃO O LUGAR CERTO, não vazamento

`OficinaTrabalho.verificarAcesso()` é o funil único: 17 chamadas em
`TrabalhoView` e `IntercambioTrabalhoView` passam por ele antes de qualquer
rota. Recolher em qualquer outro ponto exigiria repetir o recolhimento em cada
uma das 17. Dois campos e cinco linhas ali é o diff mais curto que fecha todas.

`TrabalhoView` é o único lugar que desenha quando o acesso é negado (o ramo
`else if !acesso.permitido`); a linha do recolhimento não tem outro lugar para
morar. Sete linhas, dentro do bloco que já existia. **Não é achado.**

### 5. Privacidade e autoria — INTACTAS

- Nenhuma rota de rede, publicação ou gasto entra no diff. Zero imports novos.
- `origem: .externa` e `produtor: "Arquivo importado · autoria não verificada"`
  preservados; `intencaoID` continua o da base, e a linha de aviso da intenção
  mudada continua sendo desenhada.
- A prévia do conflito é fechada por `if permitido, let preview` — sem acesso,
  nem os dois cartões nem o texto local aparecem.
- `Conflito` é `struct` de valor, vive só na renderização; não é persistido,
  não é exportado, não vai para `UserDefaults`.
- O selo continua cancelando avisos (`Revisoes.cancelarAcoes`) e agora também
  recolhe o intercâmbio — endurece a proteção, não afrouxa.

## Os dois estados que ele não capturou

Ele registra os dois como limite, não como sucesso. Fui atrás dos dois.

### Limite 1 — nenhuma rota sela a origem com a folha do Trabalho aberta: **CONFIRMADO**

Não é uma desculpa; é uma propriedade do modelo. Verifiquei quatro caminhos:

1. `Nota.fechada` é `trancada || queimada` (`Nota.swift:70`) — **não tem relógio**.
   Nenhum selo cai sozinho com o tempo.
2. A única rota automática de selo é `trancarExpressivasVencidas`
   (`Sessao.swift:1204`), e ela só toca `gesto == .expressiva`. Mas
   `AcessoTrabalho.estado` já restringe qualquer trabalho cuja origem seja
   expressiva (`nota.gesto != .expressiva` na guarda, `AcessoTrabalho.swift:47`).
   Um trabalho com origem expressiva NUNCA chega à tela de intercâmbio.
   Essa rota está morta para este fim.
3. Não existe AppIntent que trance nota: os 13 intents de `Traco/App/Intents/`
   abrem, criam ou consultam. Nenhum sela. Não dá para selar por Atalhos com o
   Trabalho na frente.
4. O seletor de Arquivos é modal e roda fora do processo: `v11-seletor-aberto.png`
   mostra a folha do Arquivos ocupando a tela inteira, com a nota atrás dela.
   Não há gesto possível na nota.

Tentei também a via de fora: escrever no SQLite do simulador enquanto o app roda
não serve — o `ModelContext` vivo não relê, e relançar o app mata a `Oficina`, que
é justamente a condição que o limite descreve. **O limite está correto e agora
está explicado pelo mecanismo, não pela ausência de tentativa.**

O que salva isso de ser motor sem superfície é a fiação do item 3 acima: a linha
não depende de toque nenhum. No dia em que existir uma rota (widget que sela,
Atalho, sincronização), ela acende sozinha.

### Limite 2 — o retry só nasce de um commit recusado pelo disco: **PARCIALMENTE FALSO**

Aqui o implementador subestimou a própria tela. `.aguardandoCommit` não precisa do
disco. `guardar()` tem DUAS saídas falsas (`OficinaTrabalho.swift:94-99`):

```
guard trabalho.conteudoJSON == basePersistida else {
    salvo = false
    erro = "Este trabalho mudou em outra abertura. …"
    return false
}
```

Essa primeira guarda dispara sem nenhuma falha de disco — basta o `Trabalho` ter
sido escrito por fora desta `Oficina` enquanto ela estava viva. `alterar()` já fez
`documento = proximo`, então `mudou == true` e `guardou == false`:
`.aguardandoCommit`, com o botão "Tentar guardar de novo" na tela.

E aí aparece o problema: por esse caminho o botão **não resolve nunca**.
`retentar()` chama `guardar()`, que bate na mesma guarda e recusa de novo;
`basePersistida` só é atualizada por um `guardar()` bem-sucedido, então o laço não
tem saída. A linha diz "tente guardar de novo"; a mensagem verdadeira ("reabra a
versão atual antes de substituir conteúdo") fica em `oficina.erro`, em outro lugar
da tela. O autor ganha um botão que promete e não cumpre. Ver achado **A4**.

Sendo justo com o implementador: **não provei que duas `Oficina`s da mesma
`Trabalho` coexistem hoje** — `conteudoJSON` só é escrito por `Trabalho.atualizar`,
que só `guardar()` chama. O achado é sobre o `Desfecho` tratar as duas recusas de
`guardar()` como uma só, e vale mesmo se hoje só a de disco for alcançável.

Não consegui encenar a recusa de disco: `chmod` no contêiner do simulador não
derruba um SQLite em WAL com o descritor já aberto, e não há gesto de tela que
force a recusa. **Confirmo o limite 2 quanto à captura**, mas ele não é "só o
disco": é "as duas saídas falsas de `guardar()`, e o `Desfecho` não as separa".

## Capturas conferidas (conteúdo, não existência)

Abri as nove uma a uma. Todas mostram app de verdade, com conteúdo coerente entre si.

| captura | o que realmente está na tela |
|---|---|
| `v11-painel-normal.png` | painel recolhido/aberto sem arquivo em revisão, "Histórico de versões (1)" |
| `v11-exportador-aberto.png` | folha do Arquivos, "No Meu iPhone" vazio, "Salvar como traco-versao" |
| `v11-seletor-aberto.png` | seletor Recentes com `traco-versao`, 392 bytes, 13:12 — **modal, a nota atrás** |
| `v11-conflito-duas-versoes.png` | "O trabalho mudou dos dois lados…", cartão "NO TRAÇO AGORA · VERSÃO 5" e cartão "NO ARQUIVO RECEBIDO · SAIU DA VERSÃO 3" com o texto editado fora ("## O convite", "Esta linha nao existe em nenhuma versao guardada aqui") |
| `v11-conflito-escolha.png` | as duas versões, a consequência ("a versão 3 continua no histórico…") e as DUAS saídas nomeadas, nessa ordem |
| `v11-conflito-ax5.png` | AX5: sem clipe, cartão cresce e quebra linha — mas **um cartão sozinho ocupa a tela** |
| `v11-guardado.png` | "Nova versão externa guardada…" e **"Histórico de versões (6)"** (era 5): a prova do append |
| `v11-sem-duplicata.png` | "Este conteúdo já está guardado; nenhuma versão duplicada foi criada", histórico (3) sem crescer |
| `v11-incompativel.png` | "Este arquivo não pode ser aplicado a este trabalho" + motivo do hash, **sem botão de importar** |

Os textos "…estaforasai no arquivoE" nas capturas são lixo de digitação do maestro
(autocorreção), não do app. Não invalidam nada, mas mostram que o fluxo foi
conduzido a mão.

## Achados

### A1 — ALTO — volta visual sem `design-router`
Esta volta desenha: dois cartões de comparação novos, dois botões nomeados, um
terceiro botão ("Tentar guardar de novo"), copy nova em seis estados, `.rotulo()`
e `.cartao(.campo)`. É trabalho de interface pela definição do portão.
Nem o commit, nem a ADR 2026-09-06x, nem SPEC/EVOLUCAO citam UMA das seis fases
(Ancorar, Sistema, Construir, Mover, Julgar, Portão), e não há relato de design
em `ferramentas/orca/`. `grep -i "ancorar|julgar|portão"` no `git show` do commit:
zero. Pela ordem do dono de 06/09, isto é **CORRIGIR ANTES** e derruba Design.

### A2 — ALTO — `curva-zero` citado, não cumprido
A ADR cita `curva-zero` uma única vez, entre parênteses, para justificar as doze
linhas. A volta é jornada inteira (importar de fora, decidir um conflito,
recuperar de um commit recusado) e o relato **não nomeia** jornada, resultado
verificável, atrito observado nem recuperação. A menção sozinha não conta:
derruba Simplicidade.

### A3 — ALTO — "mudou dos dois lados" mente quando só a intenção mudou
`preparar()` decide `atual` com DUAS condições (`IntercambioTrabalho.swift:100`):

```
let atual = base.id == documento.versaoAtual?.id && base.intencaoID == documento.intencaoAtual.id
```

`reverIntencao` (`Trabalho.swift:248`) faz `intencoes.append(...)` — muda
`intencaoAtual.id` sem tocar em versão nenhuma. É rota de tela: `TrabalhoView:180`,
dentro de "Intenção, resultado e apoio" → "Guardar intenção".

Sequência de três toques, sem editor externo nenhum:
exportar → "Guardar intenção" com outro texto → importar o MESMO arquivo intocado.
`estado == .baseAntiga` → `conflito()` devolve não-nil → a tela escreve
**"O trabalho mudou dos dois lados desde a exportação. Compare e escolha."**
E não mudou: a versão local é a mesma. Os dois cartões recebem o MESMO número de
versão e, com o arquivo intocado, **o MESMO texto**. O autor compara duas cópias
idênticas rotuladas igual.

Pior o desfecho: qualquer que seja a escolha, nada acontece.
`aplicarVersaoExterna` devolve `false` no primeiro guard de repetição
(`versaoAtual.conteudo == texto`), o desfecho vira `.semNovidade` e a linha diz
"Este conteúdo já está guardado". A tela chamou o autor para uma decisão que não
existia e que não tinha efeito nenhum.

A copy ANTIGA, que este commit apagou, não tinha esse defeito: dizia "Base do
arquivo: versão N. Versão atual: M. A nova versão partirá dessa base antiga, sem
apagar a atual" — números, não uma afirmação sobre o que mudou. Isto é regressão
de estado honesto (AGENTS.md: "Produzido, agendado, realizado e resultado
observado são estados distintos").

Não capturei na tela: a jornada maestro travou antes (ver A5). O caminho é leitura
direta de código, sem ramo condicional entre `reverIntencao` e a frase.

### A4 — ALTO — `Desfecho` funde as duas recusas de `guardar()`
`guardar()` recusa por dois motivos (`OficinaTrabalho.swift:94-99` e `110-119`):
disco, e "este trabalho mudou em outra abertura". `Desfecho.de` só vê o booleano,
então os dois viram `.aguardandoCommit` → "tente guardar de novo". Para o segundo,
o botão **não pode funcionar**: `retentar()` chama `guardar()`, que bate na mesma
guarda; `basePersistida` só muda num `guardar()` bem-sucedido. Botão que promete e
não cumpre, com a mensagem verdadeira escondida em `oficina.erro`, fora do bloco.

Irmão do mesmo defeito: `.recusada` (mudou:false, guardou:false) cobre DUAS coisas
— a mutação lançou, ou o conteúdo era repetido E o disco recusou. No segundo caso
a tela diz "Não foi possível aplicar o arquivo… importe novamente", quando não
havia nada a aplicar e o problema era o commit; e não oferece retry.

### A5 — MÉDIO — o fluxo maestro novo não roda aqui, e não roda no `varrer.sh`
Duas execuções em `iPhone 17e C7341E64`, app instalado por mim, sob `com-trava.sh`:
- 1ª: `Assertion is false: id: abrir-trabalhos is visible` (alerta de notificação
  do iOS depois do `clearState`; o fluxo não o trata).
- 2ª: passou daí e parou em `No visible element found: "Editar esta versão"` — o
  `tapOn "Guardar minha versão"` acerta o elemento mas o toque cai na barra de
  navegação, a versão nunca é guardada, e daí para frente tudo desanda.

Além disso, o fluxo tem um **passo manual no meio** (editar o `.md` fora do app,
documentado no cabeçalho) e dois toques por ponto no seletor de Arquivos. Não é
autossuficiente: `varrer.sh` não pode rodá-lo. As capturas do implementador têm
conteúdo real e coerente — a jornada aconteceu do lado dele —, mas o fluxo, como
está commitado, não é prova reexecutável.

`varrer.sh` também recusou rodar aqui (exige um simulador booted; havia seis).

### A6 — MÉDIO — "build sem aviso" é falso
`grep -c "warning:"` no meu log: **6**, sendo um desta volta:
`TracoTests/IntercambioTrabalhoTests.swift:217: variable 'comBaseAtual' was never
mutated; consider changing to 'let' constant`. O `_ = comBaseAtual` da linha 221 é
resto de uma tentativa de calar esse aviso que não calou. Os outros dois
(`ConferenciaTrabalhoTests.swift:381`) são anteriores. G1 pede build sem aviso; a
ADR e o commit afirmam que houve. Um caractere resolve.

### A7 — MÉDIO — estados do G2 que faltam e NÃO foram registrados como limite
Não capturados: `lendo` (o `ProgressView("Lendo arquivo…")`) e o bloqueio do
importar. Este segundo eu capturei: **`v11-rev-importar-bloqueado.png`** mostra
"Guarde a intenção ou a versão em edição antes de importar." com o importar
desabilitado. Custou um screenshot. Os dois estados do "custo assumido" da ADR
estão registrados; estes dois não estão em lugar nenhum.

### A8 — MÉDIO — em AX5 a comparação deixa de ser comparação
A ADR justifica as doze linhas com "as duas têm de caber no mesmo olhar". Em
`v11-conflito-ax5.png` **um** cartão ocupa a tela inteira. `linhasDoConflito = 12`
é constante fixa, sem `@Environment(\.dynamicTypeSize)`. Não há clipe (bom), mas a
razão de ser do desenho não sobrevive ao tamanho grande.

### Baixos
- `.cartao(.campo)` é documentado em `Cartao.swift:12` como "os campos da ficha" —
  afordância de entrada. Os dois blocos de comparação são texto só-leitura com
  cara de campo editável.
- O caminho do conflito perdeu `.textSelection(.enabled)`, que o `trecho()` do
  caminho comum manteve: no conflito não dá para copiar nenhum dos dois lados.
- `material` é `.nenhum` durante `lendo == true` (entre o seletor fechar e a
  prévia nascer). Selo caindo nessa janela não registra recolhimento.
- `.onChange(of: oficina.salvo)` escreve "A mesma versão externa foi confirmada na
  **nova tentativa**" mesmo quando o `salvo` virou por outra ação do autor, que
  não tentou nada.
- `Desfecho.confirmada` não é alcançável por `de(mudou:guardou:acesso:)`; só a
  View a constrói. Está comentado, mas quem lê a fábrica não vê.
- `IntercambioTrabalho.conflito(_:em:)` roda a cada avaliação de `body`
  (3 × `firstIndex` + 5 strings). Irrelevante hoje; anotado.

## Scorecard (ESTEIRA.md, mínimo 9)

| dimensão | nota | evidência |
|---|---|---|
| Visão | **9** | Entra no ciclo "multiplicar" e fecha a lacuna nomeada do EVOLUCAO ("Conflitos e retry na UI real, revogação com seletor aberto"); a linha do EVOLUCAO foi reescrita com uma lacuna nova e honesta no lugar. |
| Contrato | **8** | ADR 05x, SPEC e EVOLUCAO coerentes com o código. Mas a ADR e o commit afirmam "build sem aviso" e o log tem 6, um desta volta (**A6**); e o "custo assumido" descreve o retry como só-disco, quando `guardar()` tem duas saídas falsas (**A4**). |
| Correção | **8** | Reproduzi: `✔ Test run with 718 tests in 125 suites passed after 8.162 seconds`, `TEST SUCCEEDED`, EXIT=0. Os 3 testes novos são fortes (identidade do artefato relida do banco, prefixo de `artefatos` igual). Descontos: o fluxo maestro novo falhou 2 de 2 aqui (**A5**) e a fiação da View (`tentarGuardar`, `importacaoPendenteID`, `onChange(of: salvo)`) não tem teste nenhum. |
| Jornada real | **7** | As 9 capturas têm conteúdo real e coerente (histórico 5→6, o texto editado fora, o seletor modal). Mas faltam dois estados do G2 **não registrados** como limite (**A7**, capturei um deles), o fluxo não é reexecutável (**A5**), e o limite 2 é maior do que o declarado (**A4**). O limite 1 eu confirmei pelo mecanismo. |
| Design | **5** | **CORRIGIR ANTES.** Volta visual sem UMA fase do `design-router` citada, em lugar nenhum (**A1**). Segura a nota o uso correto dos tokens: `cartao(.campo)`, `rotulo()`, `Tema.meta/corpo`, constantes nomeadas, nada solto. |
| Simplicidade | **6** | **CORRIGIR ANTES.** `curva-zero` aparece uma vez entre parênteses e não nomeia jornada, resultado verificável, atrito nem recuperação (**A2**). Some-se **A3**, que inventa uma decisão que não existia, e **A8**, que quebra a comparação no tamanho grande. |
| Movimento | **9** | Nenhuma animação nova, nenhuma removida, nada a interromper. Não há movimento nesta volta e não faltou. |
| Componentes | **9** | Zero componente novo: reusa `cartao(.campo)`, `rotulo()`, `AcaoTrabalhoStyle`. Sem duplicata, nomes em pt, regra fora da View (`conflito`, `Desfecho`, `Material` testáveis sem renderizar). Desconto pequeno: `.campo` é afordância de campo usada em texto só-leitura. |
| Acessibilidade | **8** | AX5 sem clipe em `v11-conflito-ax5.png`; identificadores em todos os elementos novos (`trabalho-conflito-atual/arquivo/manter`, `trabalho-intercambio-tentar-guardar/recado/recolhido`). Descontos: `lineLimit(12)` fixo, indiferente ao Dynamic Type (**A8**), e nenhuma passada de VoiceOver por ninguém. |
| Performance | **9** | Nada de lista, editor ou parser em escala. `conflito()` refaz 3 `firstIndex` por `body`; irrelevante no tamanho real. Sem hitch observado; nenhum trace tirado, e nenhum era exigido. |
| Privacidade e autoria | **10** | `aplicarVersaoExterna` só faz `append`; `origem: .externa` e `produtor: "Arquivo importado · autoria não verificada"` preservados; prévia fechada por `if permitido`; a linha do recolhimento nomeia o TIPO do material e nunca o conteúdo; zero rede, zero publicação, zero gasto; o selo continua cancelando avisos e agora também recolhe. Teste cobre os três materiais. |
| Estado honesto | **6** | **CORRIGIR ANTES.** `.semNovidade`, `.semAcesso` e a linha do recolhimento são exemplares. Mas **A3** afirma na cara do autor que "o trabalho mudou dos dois lados" quando não mudou, e **A4** dá um botão de nova tentativa que, num dos dois caminhos, nunca pode dar certo. |
| Complexidade | **9** | +203/−35 em produção, +108 em teste, zero arquivo novo, zero dependência. Trocou o `descreverBase` privado da View por função pura testada. Líquido justificado pela lacuna. |
| Fora do app | **n/a** | A volta não toca superfície fora do app. |
| Relato | **8** | Commit e ADR legíveis, específicos, com os limites declarados de véspera — prática certa. Descontos: afirma "build sem aviso" (falso) e subdimensiona o limite 2. |

## Veredito

**CORRIGIR ANTES.** Quatro dimensões abaixo de 9: Design (5), Simplicidade (6),
Estado honesto (6), Jornada real (7); mais Contrato, Correção, Acessibilidade e
Relato em 8.

O núcleo está certo e eu confirmei os três contratos duros: o conflito não
sobrescreve por caminho nenhum, o retry confirma a mesma versão e o teste prova
identidade (não ausência de crash), e o recolhimento do selo é fiação reativa de
verdade, não motor sem superfície. Os dois toques fora do escopo são o lugar
certo — `verificarAcesso()` é o funil das 17 rotas — e não são achado.
Privacidade e autoria: 10.

O que trava é a tela, não o modelo:

1. **A3** — a frase "mudou dos dois lados" é falsa numa rota de três toques, e a
   decisão que ela abre não tem efeito. Dono: quem implementou o intercâmbio.
2. **A4** — `Desfecho` funde as duas recusas de `guardar()`; num dos casos o botão
   não pode funcionar. Mesmo dono.
3. **A1 + A2** — a volta é visual e de jornada e não carregou nem citou
   `design-router` nem cumpriu `curva-zero`. Dono: quem toca a view; refazer a
   passada e o relato, começando pela auditoria (é redesenho do bloco de revisão).
4. **A5 + A6** — fluxo maestro não reexecutável e aviso de build desta volta.
   Baratos, mesmo dono do código.
5. **A7 + A8** — dois estados do G2 e o `lineLimit` fixo no Dynamic Type.

Nada aqui pede rollback. A ordem que eu sugiro é A3 e A4 primeiro (são o produto),
A6 e A7 no mesmo fôlego (minutos), depois a passada de design com A1/A2/A8.

*Revisão não corrige: nada foi editado nem commitado. `revisao-v11-markdown.md` e
`v11-rev-importar-bloqueado.png` ficam untracked.*

---

# Re-G3 — segunda passada sobre `aa61951`

Mesmo revisor. Instrumento: iPhone 17e **C7341E64-3A33-4ADD-AF6C-9296215FAD09**
(encontrei-o já ligado; o iPhone 17 do dono, 1A46B6D3, estava desligado e **não
foi religado**), tudo por `com-trava.sh`. Nada editado, nada commitado.

Regra desta passada: **a citação não vale, o que vale é a tela**. Onde eu tenho as
duas capturas — a da volta recusada e a de agora — eu comparo as duas.

## O que eu mesmo rodei

| instrumento | resultado |
|---|---|
| `com-trava.sh xcodebuild test … -derivedDataPath dd2` com **derivedData apagado antes** (recompilação integral dos dois alvos) | `=== avisos: 0 ===` · `✔ Test run with 720 tests in 125 suites passed after 7.636 seconds` · `** TEST SUCCEEDED **` · `EXIT=0` |
| `com-trava.sh ./maestro/intercambio-conflito.sh <meu UDID>` | ver "A5" abaixo |
| rota de três toques do A3, fluxo próprio (`reg3-tres-toques.yaml`) | ver "A3" abaixo |
| conteúdo das 5 capturas `v11b-*.png`, uma a uma | conferido; ver cada item |

## Achado por achado

### A3 — o conflito inventado: **RESOLVIDO NA CAUSA**

O consertaram onde eu não teria pedido, e é o lugar certo. O predicado "este
conteúdo já está guardado" morava DENTRO de `aplicarVersaoExterna`, invisível
para a tela; virou `IntercambioTrabalho.jaGuardado`, e agora a mutação e a tela
fazem a MESMA pergunta. `conflito(_:em:)` passou a exigir, além de
`.baseAntiga`, que a versão local tenha andado (`baseID != versaoVigenteID`) e
que o conteúdo não esteja guardado.

Refiz a minha rota de três toques contra o código, linha a linha: exportar →
`reverIntencao` (que só faz `intencoes.append`, sem mover versão) → importar o
mesmo arquivo. `p.baseID == p.versaoVigenteID` e `jaGuardado` verdadeiro: as
DUAS guardas novas derrubam o conflito, independentes uma da outra. A frase
"mudou dos dois lados" não tem mais como sair nessa rota.

`descricaoDaBase` deixou de ser switch cego no estado do protocolo e a ordem dos
casos é exaustiva e honesta — conferi as quatro combinações: `.incompativel`
primeiro; qualquer estado com `jaGuardado` vira "nada para decidir"; `.baseAntiga`
com conflito de verdade vira "mudou dos dois lados"; e o resto cai em "Base do
arquivo: versão N, a versão atual", que é verdade justamente porque só chega ali
quem tem `baseID == versaoVigenteID`.

O que fecha o achado é a tela: `v11b-sem-decisao.png` traz a linha "Este arquivo
traz o mesmo conteúdo que já está guardado aqui. Não há nada para decidir:
nenhuma versão será criada." e **nenhum botão de guardar** — só "Fechar revisão".
A parte 2 do fluxo afirma isso com `assertNotVisible` em
`trabalho-confirmar-importacao` e em `trabalho-conflito-atual`, que é a forma
certa de provar ausência.

Efeito colateral que ele nota e eu confirmo: o retorno feliz e o arquivo sem
vínculo também ofereciam botão caindo em `.semNovidade`. Um guard no funil
consertou os três.

### A4 — o botão que não podia dar certo: **RESOLVIDO**

`RecusaDoCommit` sai da Oficina e entra em `Desfecho.de(…recusa:)` como parâmetro
**obrigatório e sem valor padrão** — detalhe pequeno e correto: nenhum chamador
futuro esquece de dizer qual recusa foi. `.precisaReabrir` não oferece botão
(`ofereceTentarGuardar` é só `.aguardandoCommit`) e a linha diz o que fazer, com
a garantia que importa: "O arquivo continua no seu aparelho e pode ser importado
depois."

O teste é melhor do que eu pedi: em vez de simular a guarda, ele abre uma SEGUNDA
`OficinaTrabalho` do mesmo `Trabalho`, escreve por ela, e prova três coisas — que
`recusaDoCommit == .baseDivergente`, que o desfecho não oferece nova tentativa, e
que repetir `guardar()` recusa de novo. Isso **responde a dúvida que eu deixei em
aberto** no G3 ("não provei que duas Oficinas coexistem"): coexistem.

O irmão que eu apontei (`.recusada` cobrindo "conteúdo repetido + disco recusou")
deixou de ser alcançável pela tela, porque sem novidade o botão não existe.

### A6 — "build sem aviso": **CONFIRMADO POR MIM**

Apaguei o `derivedData` e recompilei os dois alvos do zero, sob a trava:

```
=== avisos: 0 ===
✔ Test run with 720 tests in 125 suites passed after 7.636 seconds.
** TEST SUCCEEDED **
EXIT=0
```

`grep -c "warning:"` no log inteiro: **0**. Os três avisos que eu contei no G3
sumiram — o `var comBaseAtual` desta volta e, de brinde, o `var (d, p)` de
`ConferenciaTrabalhoTests:381`, que era anterior mas mantinha a afirmação falsa.
O `_ = comBaseAtual`, que era o remendo, saiu junto. Agora a afirmação da ADR é
verdadeira e eu a reproduzi.

### A7 — estados que faltavam: **CAPTURADOS**

`v11b-importar-bloqueado.png` mostra "Importar versão de arquivo" apagado com
"Guarde a intenção ou a versão em edição antes de importar." — e na mesma tela,
por baixo, um conflito de verdade com os dois cartões. `v11b-sem-decisao.png` é
o estado novo do A3. Os dois com conteúdo real, não arquivo vazio.

### A8 — AX5: **CORRIGIDO, com o limite dito antes de eu perguntar**

`linhasDoConflito` deixou de ser `static let 12` e virou
`corpo.isAccessibilitySize ? 4 : 12`, lendo `@Environment(\.dynamicTypeSize)`.
A diferença é visível comparando as duas capturas que eu tenho:

- `v11-conflito-ax5.png` (recusada): UM cartão ocupando a tela inteira, com sete
  palavras dentro. Comparação impossível.
- `v11b-conflito-ax5.png` (agora): o primeiro cartão INTEIRO, o rótulo do segundo
  e o começo do segundo, tudo na mesma tela.

Junto vieram três baixos que eu tinha listado e não pedi: `.textSelection` nos
dois lados do conflito (o caminho comum já copiava, o conflito não), a janela do
`lendo` contando como material em mãos para o selo, e o `.confirmada` que não
afirma mais "na nova tentativa" quando o commit veio por outra ação do autor.

### Processo — `design-router` e `curva-zero`: **CUMPRIDOS, e eu conferi contra a tela**

O portão do dono é claro: a citação sozinha não vale. Então não julguei o texto
da ADR — julguei o que a passada de *Julgar* produziu, comparando as capturas da
volta recusada com as de agora. As duas coisas que ele diz ter achado aparecem:

| o que ele diz ter achado em *Julgar* | o que eu vejo nas duas capturas |
|---|---|
| "as duas saídas estavam ambas em âmbar, empatadas em peso, contra o que `Botao.swift` já dizia" | `v11-conflito-escolha.png`: **"Guardar o arquivo como nova versão" e "Manter só a versão atual", as duas em âmbar**. `v11b-conflito-escolha.png`: a primeira em âmbar, a segunda em tinta neutra. Fui ao `Botao.swift:11-14` e a regra está lá, escrita e citando `von-restorff-effect`: "a secundária NÃO é âmbar: duas saídas em âmbar empatam em peso e o olho não sabe qual é o caminho". A tela desobedecia a casa; agora obedece. |
| "as doze linhas fixas eram número mágico que a tela grande desmontava" | `v11-conflito-ax5.png`: um cartão sozinho ocupa a tela. `v11b-conflito-ax5.png`: primeiro cartão inteiro + rótulo e começo do segundo. |

Isto é o que separa uma passada de design de uma citação: as duas descobertas
são verificáveis por diferença de pixels, não por adjetivo. A (a) ainda é a mais
séria das duas, porque era a tela contrariando uma regra que a própria casa já
tinha escrito — o tipo de coisa que só a fase de Julgar pega.

As outras fases batem com o código: *Sistema* não inventou token nenhum (conferi:
`cartao(.campo)`, `rotulo()`, `Tema.meta/corpo`, `.compacto`, todos preexistentes);
*Construir* manteve a regra fora da View (`conflito`, `jaGuardado`, `Desfecho`,
`RecusaDoCommit` são testados sem renderizar SwiftUI); *Mover* é honesto — não há
animação nova nem removida.

`curva-zero`: os quatro itens agora têm conteúdo, não rótulo. E o que me convence
não é a lista: é que a volta **tirou** uma decisão da jornada em vez de somar.
`jaGuardado` apaga uma classe inteira de tela ("escolha sem efeito"), e nenhuma
tela nova nasceu. O item "atrito observado" ainda se limita a leitura de código
contra a tela — e ele diz isso com todas as letras, em vez de vestir de pesquisa
o que não é. Aceito assim.

## As duas coisas que ele declarou, e que eu julgo

### O `ProgressView` da leitura — **limite, e nem é desta volta**

Fui ver antes de julgar: `if lendo { ProgressView("Lendo arquivo…") }` é linha de
contexto no diff da volta 11 — já existia em `797adc2` e antes. Cobrar captura
dela aqui seria eu inventando escopo. O mecanismo declarado também confere: a
leitura é uma `Task` sobre 400 bytes; nem o teto do protocolo (2 MiB) seguraria um
quadro com confiança. **Limite, aceito.** O que vale é que ele parou de deixá-la
fora da conversa: a ADR agora a nomeia no "custo assumido", que era a minha
queixa — a queixa nunca foi a captura, foi o silêncio.

### `.precisaReabrir` — **limite, e eu conferi a afirmação que sustenta o limite**

Ele afirma "a tela não abre duas folhas". Não aceitei de palavra; fui ao
`RaizView`. As quatro camadas do arquivo saem de um **`switch sessao.abaArquivo`**
(`RaizView.swift:33-46`), não de um `TabView`: a aba que não está em cena é
destruída, e com ela a `Oficina` e a folha. Os três lugares que apresentam
`TrabalhoView` — `PaginaView:84`, `TrabalhosView:106`, `CalendarioView:51` — usam
um `.sheet(item:)` cada, uma folha por vez, e no máximo um desses ramos está vivo.
Não há rota de tela para duas `Oficina`s do mesmo `Trabalho`. **A afirmação é
verdadeira; o limite é limite.**

E isto fecha, dos dois lados, a dúvida que EU deixei aberta no G3. Eu tinha
escrito "não provei que duas `Oficina`s coexistem hoje". As duas metades agora
estão provadas e não se contradizem: **coexistem no modelo** (o teste dele abre a
segunda de verdade e faz a guarda disparar) e **não coexistem pela tela** (o
`switch` do `RaizView`). Era exatamente o que faltava para o `.precisaReabrir` ser
uma decisão de produto e não um estado órfão.

### AX5: os dois cartões não cabem inteiros — **não derruba a Acessibilidade**

Ele levantou isto sozinho, sem ninguém perguntar. Julguei olhando a tela, não o
texto.

O que perde: em AX5 o autor decide com um lado na memória. É real e ele não
disfarça.

O que sustenta a nota, e é o que pesa mais:

1. **Nada some nem corta em silêncio.** A truncagem é dita em palavras na própria
   tela — "Mostro o começo de cada uma" — e os dois rótulos ("NO TRAÇO AGORA ·
   VERSÃO N", "NO ARQUIVO RECEBIDO · SAIU DA VERSÃO M") aparecem juntos.
2. **O mecanismo responde ao ambiente**, não a um palpite: `isAccessibilitySize`
   troca doze linhas por quatro. Era número mágico, virou regra.
3. **A decisão é inteiramente recuperável**, e isso muda a natureza do erro. Eu
   provei no G3 que nada é sobrescrito: a versão local continua no histórico, o
   arquivo continua no aparelho e pode ser importado de novo. Comparar mal em AX5
   custa uma versão a mais no histórico — não custa texto.
4. **As duas saídas são nomeadas pelo desfecho**, não pela posição: "Guardar o
   arquivo como nova versão" e "Manter só a versão atual". O autor não precisa
   lembrar qual cartão estava em cima; precisa lembrar o conteúdo, que é a coisa
   que ele está mesmo decidindo. Isso é a complexidade irredutível da tarefa
   (Tesler), não um atalho do desenho.
5. Em AX5, simultaneidade de dois textos de várias linhas é fisicamente
   impossível. Exigi-la é exigir que a tela não exista nesse tamanho.

**Acessibilidade fica em 9.** Não é custo escondido: é custo declarado, com o
mecanismo certo e com recuperação total.

**A saída que eu aceitaria** se o dono quiser fechar isto numa volta futura — e
eu NÃO a exijo agora: em `isAccessibilitySize`, mostrar **um lado por vez com
troca explícita e nomeada** ("Ver a versão atual" / "Ver o arquivo recebido"),
com os dois rótulos sempre em cena e as duas saídas embaixo. Transforma uma
rolagem implícita numa comparação explícita, com um controle só e só no tamanho
grande.

**O que eu NÃO aceitaria:** encurtar abaixo de quatro linhas (sobra texto de
menos para comparar), rolagem horizontal lado a lado (pior em AX5), ou desistir
da comparação e só nomear as duas versões.

## Resíduos que eu vi e NÃO seguro a volta por eles

- **Estado velho de `recusaDoCommit`.** Quando a MUTAÇÃO lança (`alterar` cai no
  `catch`), `guardar()` não é chamado e `recusaDoCommit` conserva o valor
  anterior. Se esse valor fosse `.baseDivergente`, o desfecho sairia
  `.precisaReabrir` com a mensagem errada. Só que chegar a `.baseDivergente`
  exige duas `Oficina`s, que a tela não abre: hoje é inalcançável. Zerar a
  recusa na entrada de `alterar` fecharia a porta antes de ela existir.
- **`.compacto` num cartão branco tem MAIS contraste que o âmbar.** A regra do
  `Botao.swift` foi obedecida e a hierarquia agora existe, que era o achado. Mas
  a secundária ficou em tinta quase preta sobre branco e a primária em âmbar:
  quem manda no olho é o contraste. Não é para mexer agora — é o padrão da casa,
  e consistência vale mais que o meu gosto —, mas é a próxima pergunta de design
  se alguém for revisitar o `.compacto`.
- **A fiação da View continua sem teste.** `tentarGuardar`,
  `importacaoPendenteID` e o `onChange(of: oficina.salvo)` seguem provados só
  pelo modelo. O fluxo maestro agora cobre a tela do conflito e a do "nada para
  decidir", mas não a do retry.
- **Trazer uma versão antiga de volta pela importação não tem rota.** Se o autor
  edita o `.md` fora para restaurar exatamente o texto de uma versão antiga,
  `jaGuardado` responde "já está aqui" e nada acontece. É o comportamento que já
  existia antes desta volta (a mutação recusava igual) — a diferença é que agora
  a tela **diz** isso em vez de oferecer um botão morto. Não é regressão; é uma
  lacuna de produto que ficou visível quando a tela ficou honesta.
- **A espera de arranque do fluxo é curta para a máquina real.** Ver "A5".

### A5 — o fluxo sozinho: **estrutura consertada; a máquina não me deixou fechar o verde**

Vou separar o que eu verifiquei do que eu não consegui.

**Verifiquei na fonte, e as quatro coisas que eu apontei estão consertadas:**

| o que eu apontei no G3 | o que está lá agora |
|---|---|
| passo manual no meio, fluxo não reexecutável | `maestro/intercambio-conflito.sh`: parte 1, o próprio roteiro reescreve o corpo do `.md` no disco do simulador preservando o envelope da linha 1, parte 2 |
| alerta de notificação do iOS depois do `clearState` não tratado | `runFlow when visible: "Não Permitir"` no topo da parte 1 |
| `tapOn "Guardar minha versão"` caindo na barra de navegação | rolagem até a ÂNCORA SEGUINTE, com o comentário explicando por quê — e citando a minha falha |
| `varrer.sh` não podia rodá-lo | o `.sh` irmão é o que o `varrer.sh` prefere; a parte 2 mora em `maestro/partes/`, fora do glob |

E ele achou, tentando eliminar o passo manual, uma coisa que eu não tinha visto e
que **corrige o meu G3**: eu tratei a edição externa como fragilidade do fluxo.
Não é. Um `.md` intocado tem o corpo idêntico à versão de onde saiu, então
`jaGuardado` responde sim e não existe conflito. **A edição externa é a segunda
ponta do conflito** — sem ela o fluxo não estaria provando o que diz provar. Ele
não removeu o passo: transformou-o em script. Está certo, e a minha crítica
original estava errada nessa metade.

**Não consegui:** três execuções aqui, todas parando no primeiro
`extendedWaitUntil` da parte 1. E a causa não é o fluxo:

- `ferramentas/orca/v11-reg3-quadro-congelado-do-arranque.png` — o quadro que o
  maestro fotografou nas duas falhas, **idêntico pixel a pixel nas duas**, às
  16:40 e às 16:45: é o retrato de arranque que o iOS guarda de uma instalação
  ANTERIOR (outro ramo: repare no botão preto "Preparar este ato", que não existe
  neste branch). O app ainda estava subindo.
- `ferramentas/orca/v11-reg3-tela-viva-maestro-cego.png` — captura minha por
  `simctl`, tirada DURANTE a espera da terceira execução: o app inteiro,
  renderizado, com "Trabalhos" na tela. O elemento estava lá e o maestro não o
  via.
- A terceira execução foi com uma cópia do fluxo no scratch com as esperas
  **triplicadas (15s → 45s)**. Falhou igual. Não é tempo curto: é o driver do
  maestro sem CPU.
- Contexto da máquina no momento: **sete simuladores ligados** e **quinze
  processos na fila do `com-trava.sh`**, com outros workers rodando `xcodebuild`
  e `maestro` ao lado. `varrer.sh` recusa com mais de um simulador ligado — e o
  motivo dessa recusa é exatamente este tipo de contaminação.
- Confirmei que o binário instalado no meu simulador é o MEU build
  (`shasum -a 256` igual ao de `dd2/…/Traco.app/Traco`) e que
  `accessibilityIdentifier("abrir-trabalhos")` existe em `NotasView.swift:58`.

**O que fecha o achado mesmo assim** é a evidência que o próprio fluxo produziu:
`v11b-sem-decisao.png` mostra na tela a frase **"Versao 1 editada FORA do
Traco."** — que é, literalmente, a linha que o `.sh` escreve dentro do `.md`. Só
a jornada inteira, com o editor externo scriptado, põe esse texto naquela tela.
O fluxo rodou; eu é que não consegui repetir num instrumento saturado.

**Conclusão:** A5 fechado pela fonte e pela prova que o fluxo deixou. Não estou
certificando um verde meu, e digo isso com todas as letras.

## Scorecard revisto

Só mexo no que julguei nesta passada. O resto do G3 vale como estava — inclusive
os três contratos duros que eu provei (o conflito nunca sobrescreve; o retry
confirma identidade do artefato relido do banco; o recolhimento do selo é fiação
reativa) e os dois toques fora do escopo, que continuam sendo o lugar certo.
`TrabalhoView` mudou UMA linha, de comentário: os contratos não foram tocados.

| dimensão | G3 | Re-G3 | por quê |
|---|---|---|---|
| Visão | 9 | **9** | inalterada; a linha do EVOLUCAO agora traz a lacuna nova, incluindo o AX5 |
| Contrato | 8 | **9** | a afirmação falsa ("build sem aviso") virou verdade e eu a reproduzi; o "custo assumido" cobre agora os três limites com mecanismo; ADR renumerada para `2026-09-06a` em SPEC, EVOLUCAO, comentários e fluxo, sem sobra de `05x` |
| Correção | 8 | **9** | recompilação integral com derivedData limpo: **720/125, TEST SUCCEEDED, EXIT=0, zero aviso**. Os dois testes novos são fortes — o de base divergente abre uma SEGUNDA `Oficina` de verdade em vez de simular a guarda. Resíduo: a fiação da View segue sem teste |
| Jornada real | 7 | **9** | os dois estados que faltavam foram capturados com conteúdo real; os dois limites restantes estão declarados com mecanismo (e eu confirmei os dois mecanismos); o fluxo virou autossuficiente e a prova disso está na própria captura, que traz o texto que só o roteiro externo escreve. Não certifico verde meu: ver A5 |
| Design | 5 | **9** | as duas descobertas da fase Julgar são visíveis por diferença entre a captura recusada e a de agora — as duas saídas empatadas em âmbar contra a regra escrita no `Botao.swift`, e as doze linhas fixas. Isso é passada de design, não citação. Sistema sem token novo, regra fora da View |
| Simplicidade | 6 | **9** | os quatro itens da `curva-zero` têm conteúdo, e o que convence é o resultado: a volta **removeu** uma decisão da jornada (`jaGuardado` apaga a classe "escolha sem efeito") sem somar tela nenhuma. O limite do "atrito observado" é dito, não maquiado |
| Movimento | 9 | **9** | nada de animação, nada faltou |
| Componentes | 9 | **9** | nenhum componente novo; passou a USAR o `.compacto` que já existia. `.cartao(.campo)` foi julgado e mantido com razão escrita, em vez de acidente |
| Acessibilidade | 8 | **9** | `linhasDoConflito` responde a `isAccessibilitySize`; `.textSelection` nos dois lados; AX5 capturado. O "não cabem inteiros em AX5" é custo declarado, com mecanismo certo e recuperação total — ver a seção do AX5. Segue sem passada de VoiceOver por ninguém |
| Performance | 9 | **9** | inalterada |
| Privacidade e autoria | 10 | **10** | intacta: `jaGuardado` é leitura pura, `RecusaDoCommit` não sai da Oficina, nada novo publica, envia ou gasta; origem, produtor e selo preservados |
| Estado honesto | 6 | **9** | as duas mentiras morreram na causa: a tela não afirma mais mudança que não houve, e não oferece mais botão que não pode funcionar. `.recusada` virou o que o nome diz. Resíduo inalcançável anotado (recusa velha em `alterar`) |
| Complexidade | 9 | **9** | +63/−? no modelo, +35 na View, +15 na Oficina; zero arquivo de produção novo, zero dependência, e um ramo de comportamento a MENOS |
| Fora do app | n/a | **n/a** | não toca superfície fora do app |
| Relato | 8 | **9** | corrigiu a afirmação falsa, declara três limites com mecanismo, e diz o que NÃO fez de propósito. Levantou o AX5 sozinho, sem ninguém perguntar — é o oposto de esconder |

## Veredito do Re-G3

**APROVADO. Nenhuma dimensão abaixo de 9. Segue para o G4.**

As quatro dimensões que eu derrubei subiram por conserto de causa, não por
argumento. O que me convence em cada uma:

1. **A3 foi consertado onde eu não teria pedido.** Eu apontei uma frase mentirosa;
   ele encontrou a razão de ela existir — um predicado escondido dentro da mutação,
   que a tela não podia consultar — e a tirou para o meio. Consertou três telas de
   uma vez, e uma delas eu nem tinha visto.
2. **A4 respondeu a dúvida que eu deixei aberta**, com um teste que abre a segunda
   `Oficina` de verdade em vez de simular a guarda.
3. **A passada de design produziu um achado que só ela pegaria**: a tela
   desobedecendo a uma regra escrita na própria casa, no `Botao.swift`. Eu conferi
   contra as duas capturas, que é o que o dono transformou em portão.
4. **Ele declarou sozinho o que ainda não fecha em AX5.** Um implementador que
   levanta a própria pendência é o que eu quero encontrar num G3.
5. E ele **me corrigiu numa coisa**: a edição externa do `.md` não era fragilidade
   do fluxo, é a segunda ponta do conflito. Eu estava errado nessa metade.

Fica para o G4 e para a volta seguinte, sem travar merge: a saída de AX5 que eu
descrevi (um lado por vez com troca nomeada, só em corpo de acessibilidade), a
fiação da View sem teste, o `recusaDoCommit` velho em `alterar`, o contraste do
`.compacto` sobre cartão branco, e a lacuna de "trazer versão antiga de volta
pela importação".

*Revisão não corrige: nada foi editado nem commitado. Este arquivo e as
`v11-reg3-*.png` ficam untracked. Simulador C7341E64 restaurado e desligado por
mim; o iPhone 17 do dono (1A46B6D3) estava desligado quando cheguei e assim
ficou.*
