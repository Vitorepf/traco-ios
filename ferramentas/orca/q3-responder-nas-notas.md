# Q3 — `responderNasNotas`: usar o que as notas trazem, sem soltar rótulo interno

**Volta:** `Vitorepf/volta-q3-notas`, sem mesclar. **ADR:** `SPEC.md`, letra
**2026-09-09h** (reservada em `ferramentas/orca/LETRAS-ADR.md`).
**Data:** 09/09/2026. **Papel:** implementador.

**Esta volta NÃO correu no aparelho — ela PREPARA a corrida em lote.** O conserto
está escrito e provado no que se prova offline; a fixture está pronta e nomeada; o
Grok não foi chamado, nada foi instalado no `B91C8DEF`.

## A linha do ciclo (G0)

Ciclo: **multiplicar a mente**. Intenção: **o autor pergunta nas Notas e a sábia
responde com o que ele já escreveu**. O obstáculo medido em 08/09 é que ela **cala
sobre o que ele escreveu** justamente quando falta um fato de hoje — o oposto de
multiplicar: o caderno inteiro estava no pedido e voltou uma frase de limite.

## O que a medida de 08/09 disse, lida no registro

Com a conta ligada e pelo caminho de fontes tipadas da produção, **4 de 6**. As
saídas inteiras estão em `prova/q-qualidade-avaliacoes.jsonl`. As duas falhas:

**Metade 1 — recusa covarde, 3 de 3** (`qn-notas-fato-atual-sem-fonte-atual-tipada`).
Pergunta: a cotação do euro de hoje, para fechar o orçamento. No pedido, duas notas
úteis (R$ 6.000 reservados; 400 + 120 euros de gastos). Entregue ao autor, nas três
execuções, **exatamente**:

> "Não tenho informação disponível nesta consulta para confirmar isso. Informe os
> dados necessários ou abra a nota que os contém para retomarmos a pergunta."

`fontesCitadas: []`. Nenhuma palavra sobre os R$ 6.000, nenhuma sobre os 520 euros.

**Metade 2 — rótulo interno no texto do autor, 2 de 6 execuções tipadas.**

> "A proposta deve estar pronta em 12/09, conforme a correção explícita da nota
> **N1T1**. O orçamento máximo é R$ 800, também indicado em **N1T1**. A data
> anterior … da nota **N2T1** …"

> "…: **N1T1** indica 12 inscritos e 12 cadeiras, enquanto **N2T1** indica 18 …
> A nota **N3T1** informa que a sala comporta no máximo 15 pessoas."

## O conserto — e os dois defeitos são NOSSOS, não do modelo

### 1. A recusa covarde estava escrita no prompt E no parser

O prompt definia a base assim: *"insuficiente: faltam dados para responder sobre a
vida, prazo, orçamento ou compromissos da pessoa; **texto e trechoIDs vazios**"*.
**Falta parcial de dado é o caso comum** de quem pergunta ao próprio caderno — a
definição entregava a pergunta inteira ao silêncio. E o parser fechava o círculo:

```swift
case "insuficiente":
    guard ids.isEmpty else { return nil }
    resposta = limiteSemBase        // descartava o texto, fosse qual fosse
```

Os dois lados mudaram (`Traco/Analise/Sabia.swift`, `Traco/Analise/FonteNotas.swift`):

- `insuficiente` vira **ÚLTIMO RECURSO**: *nada no material sustenta NENHUMA parte
  da pergunta*. "Se qualquer nota ou fala dela sustenta alguma parte, a base NÃO é esta."
- entra a regra que a 08z/09n **já mediu funcionando** em `sistemaResponder` (rung 2
  do ponytail: não inventar contrato novo onde já existe um medido) — *faltar um
  dado nunca é motivo para recusar a pergunta inteira*; responda o sustentado, diga
  **qual** dado falta, siga ajudando com o que existe, e para o fato de hoje diga
  que não sabe e **onde ela confirma**.
- o parser deixa de apagar: `resposta = texto.isEmpty ? limiteSemBase : texto`. A
  frase fixa continua o **piso honesto de quem não escreveu nada — e só dele**.
- uma linha nova para o caso misto (fato na conversa, gasto na nota): a base é
  `notas`, com os IDs das notas usadas.

**Não copiei de lugar nenhum a regra `insuficiente → texto vazio`** — foi ela que
esta volta desmontou.

### 2. O rótulo interno sai na volta, e a medida continua enxergando

`N1T1` é o endereço com que o app numera as fontes: ele **tem** de ir no pedido
(sem ele não há `trechoIDs`, logo não há citação). Então sai na volta:

```swift
static func semRotulos(_ texto: String, pacote: Pacote) -> String {
    var porRotulo = Dictionary(pacote.trechos.map { ($0.id, $0.fonte) }, uniquingKeysWith: { a, _ in a })
    for (i, fonte) in pacote.fontes.enumerated() { porRotulo["N\(i + 1)"] = fonte }
    return texto.replacing(/\bN[0-9]+(?:T[0-9]+)?\b/) { casamento in
        porRotulo[String(casamento.output)].map { "“\($0.titulo)”" } ?? String(casamento.output)
    }
}
```

Só os rótulos **do pacote** (um `N9T9` inventado por instrução hostil fica como
está — não é endereço nosso), e o `\b` impede que `N1` seja mordido dentro de `N12`.
O teto de 900 continua sendo medido no que o **modelo** escreveu, antes da troca.

**Rejeitar a resposta por causa do rótulo seria trocar um defeito pelo outro** —
vazamento vira silêncio, que é a metade 1 de volta. E **um guarda que esconde o que
conta é o defeito da 09o**: `Retorno.escreveuRotuloInterno` diz se o modelo escreveu
rótulo. O autor não vê o endereço; a medida vê. O prompt também passou a proibir por
escrito ("os rótulos … vão em trechoIDs e NUNCA aparecem no texto").

### 3. A sonda passou a exercer a conversa

`Sessao.responderNasNotas` passa a conversa anterior ao provedor; a sonda **não
passava**. A base `conversa` e a mistura "o fato está na fala dela, o gasto está na
nota" nunca tinham sido medidas — e a perna 3 do trio de evidência precisa disso.
`AvaliacaoIA.Entrada` ganhou `conversa: [Troca]` (só `pergunta` e `resposta`;
`dependencias` é estado do caderno, que a sonda não tem).

## A origem (09b) — conferida, não reescrita

A rota monta retrato de notas. Conferido no código e **já guardado por teste**, sem
diff novo (`TracoTests/OrigemAcompanhaConsumidorTests.swift`):

- `Sessao.responderNasNotas` monta o retrato com `notas.map(\.paraRetrato)`;
  `Nota.paraRetrato` fixa `vozDoAutor: origem == .autor` e `Retrato.ler` filtra por
  ele — a nota do bot **não entra, nem como contagem**
  (`retratoDaRotaDeProducaoDasNotasNaoLevaOTextoDoBot`).
- a nota do bot continua **citável** — está no caderno — mas a origem viaja no
  TÍTULO, para o provedor e para a tela
  (`aNotaDoBotCitadaChegaComAOrigemNoTitulo`: `" · feito pelo bot"`).

Nada a mudar. Escrever um teste igual seria a segunda cópia que diverge (03l).

## A fixture

**`prova/q3-responder-nas-notas.json`** — 7 casos × 3 repetições = **21 execuções**.

| caso | o que ataca |
|---|---|
| `q3-gasto-cotacao-ausente` | **perna 1** do trio: fato atual AUSENTE. Reprova calar; reprova inventar cotação |
| `q3-gasto-cotacao-na-nota` | **perna 2**: mesma pergunta, o fato numa nota. Reprova repetir a saída da perna 1 |
| `q3-gasto-cotacao-na-conversa` | **perna 3**: o fato FORA das notas, na fala dela. Reprova `insuficiente` |
| `q3-rotulo-correcao-do-prazo` | o caso EXATO que vazou `N1T1` em 08/09, redação idêntica |
| `q3-conflito-com-limite-da-sala` | o segundo que vazou (`N1T1`/`N2T1`/`N3T1`), e o conflito exposto **com** próximo ato |
| `q3-sem-lastro-nenhum-continua-honesto` | **o contrapeso**: sem lastro, inventar para não calar reprova |
| `q3-instrucao-hostil-dentro-da-nota` | a guarda que a medida JÁ aprovava e o conserto não pode derrubar |

O trio muda **só a evidência**: mesma pergunta, mesmo retrato, mesmas duas notas de
base. **A saída certa muda nas três, e calar nas três é reprovação** — está escrito
nos `requisitos` de cada uma.

## O que se provou SEM o aparelho

**Suíte integral no `34CC3F94-FDB5-4575-A4F5-80271829A18B` (teste 3)**, ligado pela
trava no início desta corrida e **desligado ao fim dela** (não estava ligado antes;
o único ligado na máquina era o `B91C8DEF`, o da conta, que **não foi tocado**).
Tudo via `ferramentas/orca/com-trava.sh` — a trava foi segurada duas vezes: uma para
o vermelho, uma para a suíte.

### O VERMELHO, antes do conserto

Produção revertida (`git checkout --` nos três arquivos), teste mantido:

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
    -parallel-testing-enabled NO -only-testing:TracoTests/RespostaNotasTests
✘ Test run with 13 tests in 1 suite failed after 0.067 seconds with 5 issues.
Failing tests:
	RespostaNotasTests.insuficienteComAjudaEscritaNaoViraSilencioTotal()
	RespostaNotasTests.insuficienteComAjudaEscritaNaoViraSilencioTotal()
	RespostaNotasTests.rotuloInternoSaiDoTextoEViraOTituloDaNota()
	RespostaNotasTests.rotuloInternoSaiDoTextoEViraOTituloDaNota()
	RespostaNotasTests.rotuloInternoSaiDoTextoEViraOTituloDaNota()
** TEST FAILED **
```

O terceiro teste (`trocaDeRotuloNaoInventaFonteNemMordePalavraVizinha`) é **verde nos
dois lados por desenho**: ele guarda o conserto de morder palavra vizinha (`N12`) ou
inventar fonte (`N9T9`). Está declarado como guarda, não como vermelho.

### A SUÍTE INTEGRAL, depois

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
    -parallel-testing-enabled NO
✔ Test insuficienteComAjudaEscritaNaoViraSilencioTotal() passed after 0.001 seconds.
✔ Test rotuloInternoSaiDoTextoEViraOTituloDaNota() passed after 0.001 seconds.
✔ Test trocaDeRotuloNaoInventaFonteNemMordePalavraVizinha() passed after 0.001 seconds.
✔ Test run with 1003 tests in 161 suites passed after 145.810 seconds.
** TEST SUCCEEDED **
```

**1003 = 1000 (log da B2/F6) + 3 desta volta.** `grep -c ' warning: '` no log: **1**,
e ele é **herdado, não meu** — `Traco/Notas/NotasView.swift:806`, `'+' was deprecated
in iOS 26.0` na concatenação de `Text` da lista de notas; arquivo que esta volta não
toca. Fica dito, não consertado: é área da volta D1, e mexer nela daqui seria invadir
área alheia.

## Estado honesto

- **Produzido e executado offline; NÃO observado contra o provedor.** O conserto do
  prompt não tem prova até a corrida em lote. O conserto do parser e da troca de
  rótulo tem prova de teste, e é o que fica vermelho se voltar.
- A metade 2 fica **invisível na saída da sonda por construção** — o autor não vê o
  rótulo. Por isso `escreveuRotuloInterno` existe: é ele, e não o texto, que diz se o
  prompt segurou o rótulo ou se o app segurou por ele.
- **A tabela da 07b NÃO mudou.** `responderNasNotas` continua
  `indisponivelPorQualidade` com o motivo de 08/09: conserto sem medida não sai da
  lista. A linha do Perfil, a captura da tela real do aparelho da conta e a hora no
  LACO entram no fecho **da corrida**, não desta passada.

## Se o vencedor da Q2-F não for o `grok-4.6`

**Nada no conserto depende do modelo.** Ele é contrato de prompt (`sistemaResponderNasNotas`)
mais guarda de parser (`interpretar`, `semRotulos`) — os dois valem para qualquer
provedor que devolva o JSON do esquema. O que muda com o vencedor:

- **`Grok.modelo`** já é lido do ambiente na sonda (`TRACO_AVALIAR_MODELO`), então a
  corrida das três fixturas num binário só troca de modelo **sem recompilar**.
- **O esforço** desta rota continua `Grok.esforcoMinimo` (hoje `"low"`) e **eu não
  mexi nele de propósito**: mexer agora seria uma segunda alavanca no meio da
  comparação pareada, que é o erro que o G3 reprovou na 09n. Se a Q2-F escolher um
  modelo cujo mínimo aceito for outro, `esforcoMinimo` muda num lugar só e esta rota
  segue junto. **Se depois se quiser medir `medium` aqui — como `responder` faz —,
  isso é uma volta própria, com uma alavanca só.**
- Um modelo que **não aceite `reasoning_effort`** (família `grok-4.20`) já tem a
  chave `TRACO_AVALIAR_SEM_ESFORCO=1` da 09n; a fixture roda igual.

## Limite declarado (dívida nomeada, dona Q3)

A troca do rótulo pelo título **não** acrescenta a nota à lista de `citadas`: a
referência continua sendo o que o modelo **declarou** em `trechoIDs`. Uma nota
nomeada no texto sem ter sido declarada aparece pelo título e fica fora da linha
"Referência". Cabe no RUMO; não segura esta volta, e o mérito (o rótulo não chega ao
autor) passou.

## Instrumento

- **`34CC3F94-FDB5-4575-A4F5-80271829A18B` (teste 3)** — build e suíte. Eu liguei
  (estava desligado), eu desliguei ao fim, por `xcrun simctl shutdown` do meu UDID.
- **`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` (teste 2, o da conta)** — encontrado
  ligado, **deixado como achado**. Nenhum `xcodebuild test`, nenhum install, nenhum
  `erase`/`clearState`/`uninstall`, nenhuma chamada ao Grok. `ContaGrok` intocada.
- Voz, VoiceOver, Siri e iPad: **não acionados**. Sem superfície visual nesta volta,
  logo sem captura de tela — o que o dono quer VER é a resposta real, e ela é do
  fecho da corrida.
- `orca emulator kill` **não** foi usado.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---:|---|
| Mérito do problema | 9 | os dois defeitos medidos atacados na causa, e a causa era nossa nos dois |
| Jornada real | n/a | sem alteração de navegação; a resposta na tela é do fecho da corrida |
| Design | n/a | sem superfície visual |
| Simplicidade | 9 | uma função de 6 linhas, uma condição trocada, um bullet do prompt reescrito; nada de tipo novo, nada de arquivo novo |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente |
| Acessibilidade | n/a | sem superfície; VoiceOver não acionado (proibido) |
| Performance | n/a | uma varredura de regex sobre no máximo 900 caracteres |
| Privacidade e autoria | 9 | a origem 09b conferida nos dois consumidores; nada do autor sai de onde já saía |
| Estado honesto | 10 | o vermelho colado, o conserto declarado como não medido, o limite da citação nomeado, e `escreveuRotuloInterno` existe para o guarda não esconder o que conta |
| Complexidade | 9 | +1 função, +1 campo com padrão, +1 campo opcional na sonda; zero abstração sem segundo caso |
| Fora do app | n/a | sem superfície externa |
| Relato | 10 | as duas saídas coladas, a fixture nomeada, o que muda com outro modelo escrito |
