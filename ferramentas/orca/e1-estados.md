# Volta E1 — o resultado da ação volta ao trabalho

Branch `Vitorepf/volta-e1-estados`. Aparelho: iPhone 17 Pro (teste 4)
`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`. ADR nova: **2026-09-08m**.
Skills carregadas: `design-router` — **fase de Sistema apenas** (nenhum
componente, token, cor ou movimento novo; o trilho de resultado reusa `Pilula`
`.filtro` e o padrão do trilho do apoio, incluindo a quebra em `VStack` em
tamanho de acessibilidade). Nenhuma tela nova, como o G0 pedia.

## G0 — a linha da volta

**Ciclo:** multiplicar (a intenção vira ação e a ação volta como aprendizado) e
melhorar (a orientação seguinte nasce do que aconteceu de verdade).
**Obstáculo:** `EstadoAcao` tinha `pendente`/`executada`/`cancelada` e a
auditoria de 07/09 achou os três mortos — sem "observado", `cancelada`
inalcançável, e o relato não mudava a orientação seguinte.
**Critério do dono (item 5):** *"o resultado informado muda a próxima
orientação; agendado, feito e funcionou continuam distintos"*.

## O que mudou

| onde | o quê |
|---|---|
| `Trabalho.swift` | `ResultadoObservado` (`funcionou`/`parcial`/`naoFuncionou`) com `rotulo`; `Evidencia.resultado` opcional; `observacao(de:)` e `ultimaObservacao`; `registrarRelato(_:acaoID:resultado:)`; `cancelarAcao(_:)`; `GatilhoDoAjuste.resultadoInformado`; `validarAjuste` para o gatilho novo; `validar()` recusa resultado em tentativa; `contextoDeRetorno` diz os três eixos |
| `OficinaTrabalho.swift` | a seção AÇÕES REGISTRADAS do pedido delegado passa a trazer `resultado informado pela pessoa` por ação |
| `PraticaTrabalho.swift` | `nucleoDoAjuste` fala de RELATO quando não há tentativa; `origemDoAjuste` ganha "A partir do resultado que você informou" |
| `TrabalhoView.swift` | duas linhas por ação (ato e resultado); "Cancelar esta ação"; trilho de três cápsulas + a frase do estado honesto; resultado ao lado de cada relato; `orientacaoDoRelato` (três instruções); `causaDoRelato`; `causaDaVersao` no cartão da versão |
| `ResultadoObservadoTests.swift` | 11 testes novos |

`git diff --shortstat`: **7 files changed, 273 insertions(+), 12 deletions(-)**
(mais `TracoTests/ResultadoObservadoTests.swift`, 231 linhas, e `prova/e1/`).

### O reuso, e por que serve

O G0 pediu para reusar `Pedido.ajuste`/`Artefato.pedidoID` da 08j em vez de
inventar um segundo mecanismo. **Serve, e foi reusado inteiro**: a causa é
`Pedido.ajuste`, o vínculo é `Artefato.pedidoID`, a explicação ao autor sai de
`ajuste(de:)`. O único acréscimo foi um caso no `GatilhoDoAjuste` — e ele não
fura a "lista fechada" da 08j, porque a lista existe para impedir que **o app**
invente um motivo: aqui o motivo é o resultado que **a pessoa** informou, citado
com o relato dela e conferido contra o documento.

**Onde não serve, dito:** a entrega delegada não recebe o `nucleoDoAjuste` como
núcleo obrigatório. Ela tem duas janelas (remoto e aparelho) e nenhuma rota de
`ajusteIndisponivel`; exigir a causa inteira ali produziria meia causa mandada
calada — o oposto do que a 08j fixou. A causa chega pela instrução (que não se
corta) e pelo `contextoDeRetorno`; a explicação ao autor vem do documento.

## G1 — instrumento

Build sem aviso e suíte integral, sob `com-trava.sh`, com `-destination id=` e
`-parallel-testing-enabled NO` (declaro que segurei a trava em todo build, todo
teste e toda sessão de `orca emulator`):

```
** BUILD SUCCEEDED **
✔ Test run with 939 tests in 150 suites passed after 11.906 seconds.
```

Só a suíte nova:

```
✔ Test atoEResultadoSaoEixosIndependentes() passed after 0.001 seconds.
✔ Test asTresFormasEntramERelatoSemClassificacaoFicaNaoObservado() passed after 0.001 seconds.
✔ Test registroAntigoSemAChaveContinuaNaoObservado() passed after 0.003 seconds.
✔ Test tentativaNaoCarregaResultadoObservado() passed after 0.004 seconds.
✔ Test cancelarAcaoTemGestoESoAlcancaOPendente() passed after 0.001 seconds.
✔ Test aOrientacaoSeguinteMudaPeloResultado() passed after 0.001 seconds.
✔ Test aCausaDoRelatoFicaGuardadaNaVersaoQueNasceuDela() passed after 0.002 seconds.
✔ Test semResultadoInformadoNaoHaCausa() passed after 0.001 seconds.
✔ Test oDocumentoRecusaACausaQueNaoFecha() passed after 0.001 seconds.
✔ Test oContextoDizOsTresEixosSeparados() passed after 0.001 seconds.
✔ Test oNucleoDaCausaNaoChamaRelatoDeTentativa() passed after 0.001 seconds.
✔ Test run with 11 tests in 1 suite passed after 0.015 seconds.
```

A migração está coberta: `registroAntigoSemAChaveContinuaNaoObservado` apaga a
chave `resultado` do JSON de um relato de ação **executada** e prova que ele
volta como não observado, com o ato intacto.

## G2 — a jornada na tela

Capturas em `prova/e1/`, todas `xcrun simctl io <UDID> screenshot` do meu UDID.
Trabalho plantado no `default.store` do App Group (JSON gerado por teste
descartável pelos mutadores reais, depois apagado). Direção por
`orca emulator tap/type/gesture --device`, com cada medida da árvore de AX
conferida contra a captura do mesmo instante.

| captura | o que prova |
|---|---|
| `01-ato-nao-observado-large.png` | os dois eixos separados no cartão: "Realização ainda não confirmada" + "Resultado ainda não informado"; as três cápsulas e a frase do estado honesto |
| `02-resultado-funcionou-large.png` | ação **pendente** com "Resultado que você informou: Funcionou" — observar não marca executada |
| `03-orientacao-funcionou-large.png` | o relato com "Resultado informado: Funcionou" e "A revisão vai partir do resultado que você informou: Funcionou." |
| `04-escolha-parcial-large.png` | "Funcionou em parte" selecionada, com o relato escrito |
| `05-orientacao-parcial-large.png` | dois relatos, dois resultados; a orientação mudou para "Funcionou em parte" |
| `06-escolha-fracasso-large.png` | "Não funcionou" selecionada |
| `07-ato-fracasso-large.png` | o cartão com "Resultado que você informou: Não funcionou" |
| `08-orientacao-fracasso-large.png` | a orientação mudou de novo: "Não funcionou" |
| `09-tres-relatos-tres-resultados-large.png` | os três relatos com os três resultados, um sob o outro |
| `10-pedido-mudou-large.png` | **a orientação seguinte, escrita**: "A pessoa informou que NÃO FUNCIONOU. Proponha um caminho diferente, não uma variação do mesmo; diga o que está mudando. Não trate o relato dela como erro dela." — e a falha do provedor dita na tela |
| `11-cancelada-large.png` | `cancelada` alcançável: "Enviar o orcamento revisado / Cancelado / Resultado ainda não informado" |
| `12-ato-ax5.png` | AX5: os dois eixos legíveis, sem clipe |
| `13-trilho-resultado-ax5.png` | AX5: as três cápsulas empilhadas, texto quebrando dentro da cápsula, nada fora da tela |
| `14-cancelada-ax5.png` | AX5: o estado cancelado |

**A causa, conferida no disco** (não só na tela) — leitura do
`default.store` depois da jornada:

```
evidencias:
  funcionou     | O cliente aceitou a proposta na hora
  parcial       | Ele aceitou o escopo mas travou no prazo
  naoFuncionou  | O cliente recusou o prazo e suspendeu a conversa
pedidos:
 estado: falhou
  instrucao: A pessoa informou que NÃO FUNCIONOU. Proponha um caminho diferente, ...
  ajuste: {"criterioIDs": [], "motivo": "Você informou o resultado desta ação: Não
           funcionou. Seu relato: O cliente recusou o prazo e suspendeu a conversa",
           "evidenciaID": "BA672D16-…", "gatilho": "resultadoInformado"}
```

### Limites de instrumento, declarados

- **A versão nascida do relato não se fotografa neste aparelho.** Sem conta Grok
  (que só existe no `C2416CBC`, e esse eu não toquei), o pedido nasce com a causa,
  é guardado e falha; a tela diz a falha. `causaDaVersao` está provado por código
  e pela leitura do disco, não por captura. É prova da frente Q.
- **A rolagem do `orca emulator` amplifica de forma variável** (medi 5x num
  trecho e ~20x noutro, no mesmo documento): posicionar exige arrastos de 0,015
  a 0,03 e conferência da árvore a cada passo. Confirma o achado da V12.
- **`orca emulator gesture` exige `type` (`begin`/`move`/`end`) em cada ponto**;
  sem isso responde `invalid_argument` e nada rola — perdi três tentativas nisso.
- **O `bundle id` do Traço é `app.traco`.** `simctl launch com.vitorfreire.Traco`
  falha com `FBSOpenApplicationErrorDomain code 4 ("NotFound")`, que parece crash
  de app e não é.
- **O aparelho estava em AX5 quando o recebi** (deixado por sessão anterior).
  Baixei para `large` para as capturas e **restaurei AX5 ao fim**, conferido por
  `xcrun simctl ui <UDID> content_size`. O simulador foi ligado por mim e
  desligado por mim; `orca emulator kill --device` executado.
- O Trabalho plantado ("Fechar o contrato com a Acme") **ficou no aparelho** — é
  a evidência desta volta. O outro Trabalho que já estava lá não foi tocado.

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | linha G0 + diff do EVOLUCAO: fecha a lacuna "resultados reais" do ciclo intenção→ação→evidência→ajuste |
| Contrato | 9 | ADR 08m, SPEC e EVOLUCAO coerentes com o código; o reuso da 08j e o que ficou de fora estão ditos |
| Correção | 9 | 939/150 verdes; 11 testes novos, um por comportamento novo; migração coberta |
| Jornada real | 9 | 14 capturas nomeadas, os três resultados percorridos na tela, `cancelada` fotografada, e a causa conferida no disco |
| Design | n/a | nenhum componente, token, cor ou movimento novo; reuso do trilho do apoio e da `Pilula`. Fase de Sistema do `design-router` cumprida; Mover/Julgar não se aplicam |
| Simplicidade | 9 | duas cápsulas novas no cartão (cancelar e o trilho de três), nenhuma tela nova, nenhum passo a mais no caminho comum: informar resultado é opcional e o relato continua funcionando sem ele |
| Movimento | n/a | nenhuma animação nova |
| Componentes | n/a | nenhum componente novo; `Pilula` reusada |
| Acessibilidade | 9 | trilho empilha em tamanho de acessibilidade (mesmo padrão do apoio), `.isSelected` nas cápsulas, identificadores em todas as linhas novas, AX5 fotografado sem clipe |
| Performance | n/a | nenhuma lista, editor ou parser tocado |
| Privacidade e autoria | 9 | nada publica, gasta ou envia sem gesto; o resultado é atribuído à pessoa ("Resultado que você informou"), nunca ao app |
| Estado honesto | 9 | é a dimensão da volta: agendado (ficha), feito (linha do ato) e funcionou (linha do resultado) distintos na tela e no contexto da IA; ausência dita como "não observado"; a falha do provedor visível |
| Complexidade | 9 | +273/−12 em 7 arquivos, um mecanismo reusado em vez de dois, nenhum arquivo de produção novo |
| Fora do app | n/a | nada fora do app |
| Relato | — | este documento |
