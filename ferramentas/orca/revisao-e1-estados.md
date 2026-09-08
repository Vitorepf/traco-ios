# G3 — revisão independente E1: CORRIGIR ANTES

**Veredito:** CORRIGIR ANTES. A ação que já tem resultado observado ainda pode ser cancelada: isso viola o critério explícito de não cancelar o que já foi observado, e a garantia está ausente no agregado.

## Instrumento e escopo

- Candidato: `72a665a`; árvore inicialmente limpa. Não toquei `C2416CBC`, `B91C8DEF` nem `A1DF082C`.
- Simulador próprio: iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, iOS 26.5. Todas as chamadas de teste, `orca emulator` e captura passaram por `ferramentas/orca/com-trava.sh`; o AX foi comparado a uma captura `simctl io` do mesmo UDID.
- Suíte refeita: `xcodebuild test ... -destination id=6033B043-F436-41F9-B4F8-2D9E67761980 -derivedDataPath /tmp/traco-e1-g3-6033 -parallel-testing-enabled NO`. O `xcresult` registra `result: Passed`, `totalTestCount: 939`, `failedTests: 0`. A ausência de aviso de compilação não é afirmada como prova independente porque o log bruto foi truncado pela captura do terminal.

## P1 — cancelar depois de observar é permitido

**Reprodução/observação:** abri `prova/e1/02-resultado-funcionou-large.png`. O mesmo cartão diz literalmente **“Realização ainda não confirmada”** e **“Resultado que você informou: Funcionou”**, mas ainda expõe **“Cancelar esta ação”**. Isso é a tela do estado proibido, não apenas uma hipótese de código.

**Causa no modelo:** `cancelarAcao` só verifica `estado == .pendente` ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L602-L605)); uma observação deliberadamente deixa a ação pendente ([ResultadoObservadoTests.swift](../../TracoTests/ResultadoObservadoTests.swift#L41-L47)). Logo `registrarRelato(... resultado: .funcionou)` seguido de `cancelarAcao` é aceito. A view espelha a mesma condição ([TrabalhoView.swift](../../Traco/Trabalho/TrabalhoView.swift#L1011-L1020)), e o teste só recusa a ação executada, não a observada ([ResultadoObservadoTests.swift](../../TracoTests/ResultadoObservadoTests.swift#L111-L128)). Além disso, `registrarRelato` aceita uma ação cancelada ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L584-L591)) e `validar()` não recusa evidência com resultado ligada a ela ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L705-L710)); outra rota/importação pode criar o inverso do mesmo estado.

**Conserto nomeado (uma linha):** no agregado, permitir cancelamento e relato somente em ação pendente **sem observação** (e `validar()` deve rejeitar `cancelada` com resultado), com testes para as duas ordens; a view apenas reflete essa invariante.

## Contrato, persistência e causa

- **Passa — migração/ausência:** `Evidencia.resultado?` decodifica ausente como `nil`; o teste remove a chave de um relato de ação executada e confirma ato executado + observação `nil` ([ResultadoObservadoTests.swift](../../TracoTests/ResultadoObservadoTests.swift#L76-L90)). `observacao(de:)` procura explicitamente um resultado e não lê o estado ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L304-L312)). Isso distingue “não observado” de “não funcionou”.
- **Passa — resultado não é tentativa:** `validar()` restringe resultado a `.relato` ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L705-L710)); há teste de tentativa forjada ([ResultadoObservadoTests.swift](../../TracoTests/ResultadoObservadoTests.swift#L93-L104)).
- **Passa — causa persistida, não inferida:** `causaDoRelato` cria `Pedido.ajuste(gatilho: .resultadoInformado, evidenciaID:)` ([TrabalhoView.swift](../../Traco/Trabalho/TrabalhoView.swift#L1086-L1095)); `validarAjuste` exige a evidência com resultado e vazia a bagagem de conferência/critérios ([Trabalho.swift](../../Traco/Trabalho/Trabalho.swift#L622-L634)). A prova recebe versão e redecodifica preservando o vínculo ([ResultadoObservadoTests.swift](../../TracoTests/ResultadoObservadoTests.swift#L149-L168)). As invariantes antigas de conferência única, leitura concluída, divergência e contestação permanecem no ramo `necessidadePercebida`; o novo gatilho corretamente não carrega uma conferência inexistente.
- **Passa — três orientações materiais:** as três strings diferem: preservar o que funcionou, trabalhar apenas a falta parcial, ou propor caminho diferente no fracasso ([TrabalhoView.swift](../../Traco/Trabalho/TrabalhoView.swift#L1073-L1083)). As capturas `03`, `05`, `08` e `10` contêm, respectivamente, “Funcionou”, “Funcionou em parte”, “Não funcionou” e a instrução de caminho diferente. A captura `10` ainda diz a falha do provedor, sem inventar versão.
- **Limite honesto, não buraco:** a exclusão de `nucleoDoAjuste` da entrega delegada é coerente com as duas janelas sem `ajusteIndisponivel`: a instrução vigente não é cortada, `contextoDeRetorno` acompanha e a explicação autoritativa continua no documento/`Pedido.ajuste`. A causa não se perde pelos vínculos persistidos; o que fica sem prova é a qualidade semântica de uma entrega/versão feita pelo Grok real.
- **Passa — sem juízo sobre a pessoa:** a varredura da alteração não introduz nota, pontuação, score, “aprendeu” ou “melhorou” gravados. A cópia atribui o resultado à pessoa e a orientação de sucesso veda declarar aprendizagem.

## Jornada e acessibilidade

- Li as 14 capturas, não só os nomes. `01` separa “Realização ainda não confirmada” de “Resultado ainda não informado”; `02` mostra que observação não executa; `09` traz os três relatos com Funcionou/Funcionou em parte/Não funcionou; `11` mostra `Cancelado` e “Resultado ainda não informado”.
- Em AX5, `12` mantém os dois eixos legíveis; `13` mostra as três cápsulas empilhadas e texto dentro delas; `14` mostra cancelada. Os identificadores e o empilhamento por tamanho de acessibilidade estão no código. Isto confirma legibilidade dos estados fotografados, não valida VoiceOver humano.
- Minha tentativa de abrir a jornada no próprio UDID após a suíte chegou à tela de Notas sem fixture de Trabalho; não replantei dados nem forcei o provedor. Portanto a repetição independente ao vivo cobre compilação/testes e inspeção da tela/AX atual, enquanto a sequência de 14 estados é evidência examinada do autor. O P1 foi reproduzido visualmente na própria captura `02` e no modelo.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | fecha a lacuna ação → observação → ajuste sem converter uso em realização/aprendizagem. |
| Contrato | 6 | os eixos, migração e causa fecham; P1 permite cancelar observação. |
| Correção | 6 | 939/0 no UDID próprio, porém falta a invariante e seu teste negativo. |
| Jornada real | 7 | 14 estados foram lidos e a captura `02` revela o P1; não replantei a sequência no meu aparelho. |
| Design | n/a | não há token, componente ou movimento novos; `Pilula` é reuso. |
| Simplicidade | 8 | o fluxo normal é direto, mas a ação contraditória cria uma decisão/saída enganosa. |
| Movimento | n/a | nenhuma animação nova. |
| Componentes | n/a | nenhum componente novo. |
| Acessibilidade | 9 | `12`–`14` em AX5 legíveis; cápsulas empilham e têm identificadores/seleção. |
| Performance | n/a | não toca lista, editor ou parser; não há alegação de trace. |
| Privacidade e autoria | 9 | resultado permanece relato atribuído; sem publicação, gasto ou juízo novo. |
| Estado honesto | 6 | distingue agendado/feito/resultado, mas permite apagar por cancelamento o ato pendente já observado. |
| Complexidade | 9 | reuso de `Pedido.ajuste`/`Artefato.pedidoID`; sem mecanismo paralelo. |
| Fora do app | n/a | fora do escopo. |
| Relato | 9 | este documento declara evidência, falha e limites. |

## O que continua por ver

Com conta Grok real, falta observar a versão que nasce de `resultadoInformado`, ler integralmente a saída contra a instrução/relato e confirmar `causaDaVersao` na versão efetivamente recebida. Sem essa conta, a prova disponível é apenas a correta: pedido e causa persistidos, falha comunicada na tela; ela não certifica semântica nem utilidade da produção do provedor.

---

# re-G3 — revisão independente E1-B: APROVADO (9/10)

**Veredito:** APROVADO (9/10). O P1 foi fechado no agregado nas duas ordens, a rota de validação externa recusa o par proibido, e a contraprova mantém o cancelamento para a ação pendente sem resultado.

## Instrumento e candidato

- Candidato revisado: `9d724f112838ce1577b34e14d49cd68f79e33c13`; árvore limpa antes deste relatório. Não toquei o `C2416CBC` da frente Q.
- Reexecutei no iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, iOS 26.5, sempre por `ferramentas/orca/com-trava.sh`, `-destination id=` e `-parallel-testing-enabled NO`.
- `xcodebuild build` passou; a suíte integral retornou `result: Passed`, `totalTestCount: 941`, `failedTests: 0`. A bateria focada `ResultadoObservadoTests` retornou 13/13, incluindo `observadoAntes_naoSeCancelaDepois`, `canceladaAntes_naoRecebeResultadoDepois` e `cancelarAcaoTemGestoESoAlcancaOPendente`.

## Invariante, três ordens e rota não-UI

- **Observado → cancelar:** `podeCancelar(_:)` exige ação pendente e `observacao(de:) == nil`; `cancelarAcao` o relê antes da escrita. O teste independente confirmou a recusa, preservando ação pendente e resultado informado.
- **Cancelar → resultado:** `registrarRelato(... resultado:)` recusa ação cancelada; relato sem classificação segue permitido. O teste independente confirmou a recusa e preservação do estado cancelado.
- **Cancelar e relatar ao mesmo tempo:** não há janela de `await` entre guarda e mutação. As duas entradas da tela passam por `OficinaTrabalho.alterar`, que é `@MainActor`, cria `proximo` a partir do documento atual, aplica uma mutação inteira, valida e só então publica; o segundo evento inevitavelmente lê o estado já alterado e é recusado. Não há outro chamador mutável compartilhado de `DocumentoTrabalho`.
- **Fora da view:** `validar()` rejeita uma evidência com resultado ligada à ação cancelada; `Trabalho.ler()` e `Trabalho.atualizar(_:)` chamam essa validação antes de devolver ou persistir o documento. A prova forjada do teste focalizado voltou `DocumentoTrabalho.Erro`, cobrindo migração/importação ou novo chamador que tente introduzir o par diretamente.

## Tela, copy e contraprova

- Examinei as quatro imagens reais. A `15` reproduz o cartão da falha original com “Resultado que você informou: Não funcionou”, sem “Cancelar esta ação” e com a explicação; `16` e `17` mostram em AX5 que a frase inteira continua legível dentro do cartão.
- A frase é honesta e direta: atribui o resultado à pessoa, explica que cancelar não cabe porque contradiz/apagaria o acontecido registrado, sem jargão nem culpa.
- A `18` é a contraprova necessária: a ação cancelada fica distinguida, enquanto “Ensaiar a apresentação” permanece pendente, sem resultado e ainda oferece “Cancelar esta ação”.
- Limite mantido: não revi a versão gerada por Grok real; ela pertence à frente Q, fora deste veredito.

## Scorecard

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | protege o resultado relatado sem confundir ato, observação e realização. |
| Contrato | 9 | predicado único, duas guardas de mutação e `validar()` cobrem UI, persistência e chamador externo. |
| Correção | 9 | 13 testes focados e 941 totais verdes no UDID próprio; ordem concorrente analisada no isolamento Main Actor. |
| Jornada real | 9 | `15`–`18` examinadas, incluindo a contraprova do gesto ainda disponível. |
| Simplicidade | 9 | reutiliza o predicado do agregado; não cria tela, componente ou passo. |
| Acessibilidade | 9 | `16`–`17` em AX5 preservam a explicação sem clipe observado. |
| Privacidade e autoria | 9 | o relato atribuído deixa de poder entrar num estado contraditório por cancelamento. |
| Estado honesto | 9 | a interface não oferece mais cancelar depois de resultado observado e explica a restrição. |
| Complexidade | 9 | menor mudança centralizada; sem abstração ou caminho paralelo. |
| Relato | 9 | candidato, instrumento, provas e limite declarados acima. |
