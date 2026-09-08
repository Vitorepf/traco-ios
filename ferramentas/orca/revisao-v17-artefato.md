# G3 — revisão independente V17: o artefato que se reescreve

**VEREDITO: CORRIGIR ANTES.** O vínculo causal, a preservação da tentativa, a contestação e a recusa por orçamento cumprem o contrato na rota apresentada, mas duas garantias ficam somente na UI: o mesmo `conferenciaID` ainda pode sustentar duas versões por uma segunda entrada no modelo, e uma versão pode chegar enquanto a pessoa começou a editar a versão anterior.

## Escopo e instrumento

- Candidato: `5b627e9` contra `HEAD^`; árvore limpa antes da revisão e `git diff --check` sem saída.
- Teste independente: `ferramentas/orca/com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco -destination 'platform=iOS Simulator,id=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9' -parallel-testing-enabled NO`.
- Resultado no `Test-Traco-2026.09.08_14-52-10--0300.xcresult`: **909 testes, 0 falhas, 0 ignorados**, iPhone 17 Pro (teste 2), iOS 26.5. O resultado de configuração também soma 917 execuções porque três testes têm parâmetros dinâmicos.
- Sessões de `orca emulator` passaram por `com-trava.sh`, sempre no UDID B91C8DEF; cada leitura AX foi confrontada com `simctl io` do mesmo UDID. Capturas desta revisão: `/tmp/v17-b-documento.png`, `/tmp/v17-b-pratica.png` e `/tmp/v17-b-pos-tap.png`.
- A árvore não tem `artisan` nem `docs/engineering-knowledge-base/atlas-ai-knowledge-governance-system.md`; portanto bootstrap/placement Atlas não são executáveis neste worktree. A ADR e o RUMO são as fontes locais usadas.

## Ataque ao contrato

1. **Causa persistida, não inferida — PASSA.** `Pedido.ajuste` e `Artefato.pedidoID` entram em `Trabalho.swift`; `receber` grava o ponteiro e `ajuste(de:)` só o segue. Registro sem `pedidoID` retorna `nil`; a inferência antiga ficou limitada a `pedidoDe` para a rota histórica de conferência, como a ADR 08j declara. O teste `aVersaoGuardaOPedidoQueAProduziuEOAntigoFicaSemVinculo` cobre os dois lados.
2. **Nenhum estado de exercício — PASSA.** Não há `EstadoExercicio` no diff; o JSON gravado é varrido contra `aprendido`, pontuação, domínio, nível e score em `nadaNoDocumentoGuardaDesempenhoGlobalOuAprendizagem`. A tela também diz literalmente que reescrever não é dizer que a pessoa aprendeu.
3. **Causa inteira ou ajuste indisponível — PASSA.** `montarPreparacao` põe tentativa, leitura, critérios e restrições na cabeça não truncável; `MotorTrabalho.produzir` rejeita acima de 18.000 antes de chamar o provedor. `v17-d-ajuste-indisponivel.png` mostra a mensagem e o campo da próxima tentativa preservado; o teste cobre a versão vigente intacta.
4. **Fronteira da IA — PASSA com limite declarado.** O schema de adaptação tem somente capacidade, situação, enunciado, exemplo, critérios e `mudanca`, com `additionalProperties: false`; `tentativa` é recusada. `guardarTentativa` segue no domínio do autor e a captura `v17-b-tentativa-da-causa.png` mostra os dois campos da N+1 vazios. A ADR declara corretamente que isso não prova que um enunciado não esconde uma solução.
5. **Contestação — PASSA.** `contestarLeitura` mantém a conferência e a tentativa, marca data/motivo e `contextoDeRetorno` substitui o feedback pela contestação. Em `v17-c-leitura-contestada.png`, a leitura íntegra permanece visível e a própria tela afirma que ela não orienta ajustes; os testes conferem também o núcleo enviado depois.
6. **Superfície que devolve a tentativa causal — PASSA.** `tentativaQueGerou` busca a evidência pelo `ajuste` da versão vigente, fora da lista filtrada pela N+1. A seção “A tentativa que gerou esta versão” e o campo vazio seguinte aparecem juntos em `v17-b-tentativa-da-causa.png`; sem ela, a contestação ficaria inalcançável no estado importante.
7. **Anúncio — PASSA.** `PraticaTrabalho.anuncio` é montado pelo app e junta descrição validada, origem e motivo persistidos. `v17-b-nesta-versao.png` contém exatamente uma seção, declara o vínculo com a tentativa e não faz alegação de aprendizagem.

## Achados que impedem o portão

### P1 — a unicidade da conferência é guarda de tela, não invariante do documento

`OficinaTrabalho.conferirEAdaptar` impede repetição em `OficinaTrabalho.swift:372`, mas `DocumentoTrabalho.validarAjuste` só verifica que `conferenciaID` existe na tentativa. Ele não exige conferência concluída/divergente, não rejeita uma leitura contestada e não exige que aquele `conferenciaID` apareça uma única vez nos `Pedido.ajuste`; assim uma segunda rota, importação ou regressão de chamador pode criar N+2 da mesma leitura. O teste “a mesma leitura” só toca a UI de `conferirEAdaptar`; não exerce o invariante do agregado.

**CORRIGIR ANTES:** em `DocumentoTrabalho.iniciarPedido`/`validar`, faça `necessidadePercebida` exigir a conferência concluída, não contestada e com divergência/critério correspondente, e rejeite `conferenciaID` já usado por outro ajuste; acrescente o teste de N+2 recusada.

### P1 — o documento ainda pode trocar depois que a adaptação começou e antes de a pessoa terminar de editar

O botão novo chama `levouAoQueFalta`, então bloqueia o início se já houver rascunho. Porém, depois de `adaptando = true`, só o cartão da tentativa vira `ProgressView`; “Editar esta versão” continua disponível em `TrabalhoView.swift:787-796`. A pessoa pode iniciar essa edição durante o `await` e `artefatos.count` troca a N quando a resposta chega — precisamente a condição que o contrato proíbe. Não há teste desse entrelaçamento.

**CORRIGIR ANTES:** enquanto `adaptando`/pedido de ajuste estiver ativo, bloqueie a entrada em edição (ou retenha a chegada até a edição ser guardada/cancelada) e teste o fluxo começar-adaptar → editar → resposta chegar.

## Scorecard

| dimensão | nota | evidência colada e julgamento |
|---|---:|---|
| Visão | 9 | G0 V17 fecha a lacuna “Artefato que se transforma”; `EVOLUCAO.md` registra mecanismo e separa uso real/qualidade semântica ainda pendentes. |
| Contrato | 8 | ADR 08j, SPEC e implementação coincidem no vínculo e no tipo; cai pelo `conferenciaID` não único/não semanticamente validado. **Corrigir:** invariante persistido descrito no P1. |
| Correção | 8 | 909/0 no simulador independente e 15 testes novos; cai pelos dois caminhos acima, não cobertos pela suíte. **Corrigir:** testes de duplicação do agregado e de edição concorrente. |
| Jornada real | 8 | A tela e as sete capturas cobrem contrato/superfície; documento foi plantado e Debug só abriu a oferta. **Corrigir fora desta árvore (volta Q):** executar espanhol completo com Grok, ler a resposta inteira contra as restrições e cobrir resposta ruim/interrupção/nova tentativa. |
| Design | 9 | Seis fases do relato são consistentes com a tela: anúncio antes da tarefa, uma seção, materiais existentes e sem tela/token novo. `v17-b-nesta-versao.png` preserva hierarquia clara. |
| Simplicidade | 7 | `v17-a-conferir-e-adaptar.png` mostra quatro cápsulas consecutivas na última tentativa. A proposta de cortar “Adaptar o próximo exercício” **não é suficiente como está**: esse é o único chamador de UI que cria `Pedido.ajuste(gatilho: .pedidoDoAutor)`; o campo geral chama `gerar` sem ajuste. **Corrigir:** primeiro dar ao pedido escrito pelo autor essa mesma causa explícita; então retirar a cápsula enlatada (ou movê-la para uma ação secundária não concorrente). |
| Movimento | n/a | Nenhuma animação nova; a chegada já existente usa `Tema.movimento`. Não há vídeo novo a julgar. |
| Componentes | 9 | Reuso de `acaoSecundaria`, `campo`, cartões e Tema; não há componente/dep novo nem tela paralela. |
| Acessibilidade | 9 | `v17-e-ax5-nesta-versao.png` não mostra clipe horizontal; árvore AX no B91C8DEF expõe rótulos/identificadores para tentativa, apoio, guardar e editar. A ordem visual da tentativa causal → entrada N+1 é legível. |
| Performance | n/a | Não toca lista, parser de rolagem ou editor; não há alegação de medida de desempenho. |
| Privacidade e autoria | 9 | Sem novo corpus/índice, sem escrita de Evidencia pela saída da IA e revogação em curso coberta por `revogarAOrigemInterrompeOAjusteEmCurso`. |
| Estado honesto | 9 | Sem divergência, leitura inconclusiva e causa que não cabe recebem mensagens persistentes; `v17-d-ajuste-indisponivel.png` mostra que o exercício/tentativa continuam. |
| Complexidade | 8 | Diff total `+1299/-45`; código+testes `+1035/-44`, concentrado em quatro arquivos de Trabalho e uma suíte. Não há agregado/tela/dependência paralelos, mas o P1 deveria ser invariante compartilhado em vez de guarda adicional de UI. **Corrigir:** mover unicidade para validação e eliminar a dependência da guarda local como autoridade. |
| Fora do app | n/a | Não houve mudança em widget, Intent, Live Activity ou superfície externa. |
| Relato | 9 | `v17-artefato.md` declara as capturas, a simulação de oferta e a ausência de IA real; a proposta de corte, contudo, conflita com o chamador atual e foi corrigida nesta revisão. |

## Limite confirmado de provedor e release

No B91C8DEF, o app abriu com `-ensaio-oferta-da-pratica` e a árvore mostrou um Trabalho local existente, sem qualquer conta Grok. O argumento só aparece em `PraticaTrabalho.swift:22-36`, dentro de `#if DEBUG`; a configuração Release não define `DEBUG` (`project.pbxproj:1147`), portanto não compila para Release. Ele somente torna `oferta` visível: `prepararPratica` e `conferirTentativa` continuam retornando indisponibilidade sem conta e não há token/rede criado por esse ramo.

Fica por verificar com IA real: recebimento de uma leitura semanticamente útil, adaptação realmente pertinente ao erro e às três restrições do caso espanhol, comportamento diante de JSON/resultado ruim, cancelamento de uma chamada real e nova tentativa posterior. Isso é limite assumido da V17, não evidência de aprovação semântica.
