# Rumo — as próximas voltas do laço, por valor

Mantido pelo orquestrador a cada fecho (ESTEIRA.md). Volta que não está aqui não abre. Ordem = valor para a visão (dois ciclos) ÷ esforço, com a regra da frente de front-end: auditoria → fundação → telas. Notas de tela no scorecard só existem depois da V9.

## Em curso (08/09 de manhã — o laço retomado pelo vigia)

Três voltas abertas ao mesmo tempo, cada uma no próprio worktree filho nascido de `main` (5065929), áreas de arquivo disjuntas, todas tirando dívida da limpeza de 07/09. Workers em Opus 5 (cotas às 10h20: janela 9%, semanal 11%, Fable semanal 6% — o Fable voltou no reset de domingo).

| volta | dívida que fecha | área | simulador | estado |
|---|---|---|---|---|
| P1 | item 7 (o portão que impede `withAnimation` fora de `Tema`) + item 5 (A-6) + item 6 (M3) | TracoTests, Metodos.json, Analise, SPEC | teste 4 → 17e | **MESCLADA** em `29cc2ce` (ADR 08e; G3 corrigir antes → correção → re-G3 APROVADO por outro fornecedor; dívida real de curva literal = ZERO; 894 testes na árvore mesclada) |
| F4-F | item 2 (F4: o Destaque cortado, o quadro de ofertas, as superfícies sem captura, o médio de uma linha) | TracoWidget, App/Intents | Air → teste 4 | **MESCLADA** em `494c0c6` (ADRs 08g e 08i; sete passadas, duas recusas, uma consulta obrigatória; a causa era o `lineLimit`, não o `minimumScaleFactor`; 910 testes) |
| L2 | item 4 (L1: o G4 reprovado) | Traco/Perfil, Tema.swift | iPhone 17 Pro | **MESCLADA** em `9a711eb` (ADR 08h; G3 corrigir antes → prova refeita no binário → G4 PASSA com Design 9 e Simplicidade 8 declarada teto honesto) |

**Dívidas que a rodada de 08/09 destapou, e viram volta própria:**
- **Um arquivo de teste viveu em `main` sem nunca rodar.** `TracoTests/ContinuidadeTrabalhoTests.swift` existia e estava fora do alvo de teste; nada acusou, e só apareceu porque o `xcodegen` da P1 o ligou de carona. Falta um portão que exija que todo `TracoTests/*.swift` esteja no alvo. Ciclo: melhorar (barateia toda volta seguinte, como o portão do movimento). Evidência: o teste falha quando alguém acrescenta um arquivo de teste fora do alvo.
- **A ficha de método tem três defeitos de copy que só a foto mostra** (achado do revisor da P1, `ferramentas/orca/revisao-p1-provas/`): a `aplicabilidade` do exameDaNoite mostra `(ADR 2026-09-06h)` ao autor, mistura "o autor" com "você" na mesma frase e usa aspas retas. A P1-B corrige esta; **as outras fichas do catálogo não foram olhadas** — vale uma varredura de copy nas 7.

**Dois fatos do dia que mudam o mapa:**
- **O simulador teste 2 `B91C8DEF` tem a conta Grok do dono conectada** (confirmada no Perfil em 08/09). É proibido a todo worker: `xcodebuild test` reinstala o app e apaga o contêiner. Cai a linha "nenhuma operação tem medição com Grok" — a base existe.
- ~~Outra sessão (Codex) trabalha no checkout principal~~ — **VENCIDO às 12h25**: o dono comitou os cinco itens (`f22a588`) e desistiu de pôr o Astra a implementar. O checkout está limpo, e o único Codex vivo é revisor. Da leitura dos cinco itens fica de pé a dívida: a jornada visual persistida, retorno → ajuste com provedor real e a revisão final continuam pendentes (`prova/cinco-itens.md`, "Limites e trabalho restante") — e a **volta Q** as paga.

## Em curso (05/09 à noite, modo Fable máximo)

| volta | tema | área | estado |
|---|---|---|---|
| V6 | prática no Trabalho (ADR 05r) | Traco/Trabalho | MESCLADA em main (G3, re-G3, G4) |
| V7 | integridade e selo nas rotas restantes (ADR 05s) | Sessao, Corpus/Indice/Holofote, Modelo | MESCLADA em main |
| V8 | acessibilidade real: VoiceOver, movimento reduzido, AX5 (ADR 05t) | views de Pagina/Notas/Caderno/Calendario/App, Tema | MESCLADA em main (G3, re-G3, G4, re-G4) |

**V12 — Página e Caderno até 9.** Ciclo: multiplicar (a porta de entrada da escrita). Intenção: escrever, vestir a forma e concluir sem que a ferramenta se imponha; quem usa AX consegue o mesmo. Obstáculo: nota base 6,7 (Design 7, Simplicidade 6, Movimento 7, Componentes 6, Acessibilidade 6, Estado honesto 8): o cartão da forma vestida cobre a régua e as ações e em AX esconde-as; botões com opacidade no press contra a ADR 02h; célula nova com mola errada; Camadas anima a camada Notas antes do binding; rótulos e cápsulas ainda fora de Componentes. Evidência: capturas antes/depois em large e AX5 nos estados G2 (vazio, escrevendo, forma vestida, campos, cartão da sábia, falha de gravação), vídeo de vestir/soltar com e sem RM, notas do G3/G4 ≥ 9 em todas as dimensões para a tela, shortstat líquido-negativo. Escopo: Traco/Pagina/*, Traco/Caderno/*, Traco/App/Camadas.swift, Traco/Componentes (só ligar o que já existe; novo componente só se repetido em 2+ telas), TracoTests; sem tela nova, sem texto novo além do necessário.

**V16 — Métodos com proveniência.** Ciclo: melhorar. Intenção: o autor sabe de onde vem cada método, o que o Traço adaptou e que evidência existe, e vê quando um método sumiu da pasta. Obstáculo: o catálogo (Metodos.json) traz só origem nominal; a eficácia é presumida; método ausente é silêncio (ADR 05o, Fora); VISAO exige distinguir fonte, adaptação e evidência. Evidência: campos fonte/adaptação/evidência/aplicabilidade no catálogo (aditivos), a Lente/Perfil mostrando isso por método sem certificar eficácia, linha "o método X saiu da pasta; a nota conserva os campos" na nota afetada, testes; sem tela nova. Escopo: Traco/Modelo/{Metodo,Metodos.json,Gesto}.swift, Traco/Pagina/LenteView.swift, Traco/Perfil/PerfilView.swift (seção métodos), TracoTests/CatalogoTests.swift. Disjunta de V10 (Tema/Componentes/Notas/Calendário/Recordar) e da trilha.

**F3 — Captar pensamento em um toque.** Ciclo: multiplicar. Intenção: uma frase na rua entra no Traço em um toque, sem abrir o app, ou abrindo já em ditado. Obstáculo: hoje só Siri/Atalhos (n/c no simulador) e traco://anotar exigem abrir/digitar; não há controle na tela bloqueada nem botão de Ação. Evidência: ControlWidget "Anotar" na Central/bloqueada que abre o app em rota tipada de captura com ditado solicitado (05a: entrada/ como fila), botão de Ação pelo mesmo intent, AnotarIntent com "anotado" só após depósito confirmado; capturas da Central/bloqueada e do app já em ditado; testes do intent; áudio preservado antes da transcrição (brief).

## Trilha própria: Fora do app (Fable permanente; brief em papeis/fora-do-app.md)

Sempre uma volta desta trilha em edição, em paralelo às voltas comuns, no próprio worktree e pelos mesmos portões. Dimensão "Fora do app" do scorecard.

| # | volta | superfície / entrega | estado |
|---|---|---|---|
| F1 | Auditoria fora do app | inventário com 24 capturas reais, nota base por superfície, lacunas F2-F11, conselho gravado (ferramentas/orca/auditoria-fora-do-app.md, consulta-fora-intents.md) | MESCLADA em main |
| F2 | Fundação | MESCLADA em main (ADR 05u); gate ao dono: confirmar no iPhone que instalar por cima preserva os dados (o simulador provou que sim) |
| F3 | Captar pensamento em um toque | MESCLADA (ADR 05w): controle Anotar na Central/bloqueada/botão de Ação abre o app com teclado pronto e microfone a um toque; F3b = ditado próprio com áudio preservado |
| F3b | Ditado próprio | áudio salvo antes de transcrever; falha preserva o áudio | MESCLADA (ADR 06c; G3, correção, re-G3 aprovado) |
| F4 | **Os widgets da tela de início prestam** (era "widget próxima volta interativo") | refresh que funciona, identidade do Traço, vazio que oferece ação, densidade do médio, botão de feito na própria superfície | **EM EDIÇÃO, PRIORIDADE MÁXIMA** (worktree f4-widgets; ordem do dono 06/09 13:04, com print do iPhone) |
| F5b | Ilha do compromisso vivo (era F5; a sigla F5 foi gasta pelos arquivos `f5-*` da F4-F, e "F6" já era dos widgets da tela bloqueada — o nome colidia duas vezes) | estados completos (compacta, expandida, mínima, fim). A mínima só aparece com DUAS atividades disputando a Ilha, e o StandBy não renderiza no simulador — as duas lacunas ficaram declaradas na F4-F | **EM EDIÇÃO** (worktree volta-f5b-ilha, ADR 08v) |
| F6 | Widgets da tela bloqueada | accessoryCircular e accessoryInline do dia | |
| F7 | Controle da Central de Controle | Recordar | |
| F8 | Widget configurável | por pasta ou método | |
| F9 | Spotlight | notas e trabalhos, com selo | |
| F10 | Extensão de compartilhar | texto, link e imagem com origem preservada | |
| F11 | Sugestões de Siri | por horário | |

**G0 de F1.** Ciclo: multiplicar (o Traço presente onde a pessoa está, sem abrir o app). Intenção: saber, com captura real, o que cada superfície fora do app entrega hoje e quanto vale. Obstáculo: há widgets, Live Activities, 12 atalhos e 10 intents sem inventário nem nota; captura só no preview do Xcode não conta. Evidência: ferramentas/orca/auditoria-fora-do-app.md com capturas simctl por superfície e estado, nota 0-10 nas dimensões Fora do app, Design, Simplicidade, Movimento, Acessibilidade, Privacidade e Estado honesto, lista do que falta, e a consulta ao conselho gravada em consulta-fora-intents.md. Escopo: nenhum arquivo de código.

## Trilha própria: Métodos (worker permanente; brief em papeis/pesquisador-metodos.md)

Ordem do dono de 06/09 13:10. Um pesquisador dedicado procura métodos que MEREÇAM entrar no catálogo dos 21, com `pesquisa-web` e fontes primárias. Método é DADO, não código: nada de Swift nesta trilha. Barra de entrada de QUATRO itens no brief (correção do dono de 06/09 13:25, que tirou as duas exigências limitantes — caber em dois a cinco campos e ter um passo que as pessoas pulam): serve um dos dois ciclos e diz qual; origem verificável com citação; não duplica nenhum dos 21, com a diferença no movimento e não no nome; honesto sobre evidência. A FORMA É LIVRE: o método pode ter quantos campos pedir e uma anatomia diferente dos 21, e isso é sinal de que vale olhar; forma que exige algo que o app não faz vira volta do laço, nunca rejeição. As proteções de escrita pessoal, Expressiva e nota selada seguem intactas. Cada rodada entrega três a cinco candidatos com o JSON completo no esquema do catálogo (roteamento em regex pt-BR testadas sem falso positivo nos outros 20) e a ficha em `ferramentas/orca/metodos/<id>.md` com fonte, citação literal, o que a fonte não afirma e as seis barras — mais pelo menos UM rejeitado com o motivo escrito, para o critério ficar visível. Nunca alegar eficácia comprovada.

| # | rodada | estado |
|---|---|---|
| M1 | primeira rodada de candidatos | EM EDIÇÃO (worktree metodos-m1) |
| M2 | segunda rodada + fonte primária de Ohno + achados para a colagem | EM EDIÇÃO (mesmo worktree metodos-m1) |
| M3 | colagem no catálogo dos SETE + conserto do roteamento + guarda de encadeamento morto | EM EDIÇÃO (a V16 mesclou em 968ba34) |
| M4 | terceira rodada: fato contrário (Darwin), ordem de grandeza (Fermi), começaria hoje? (Jevons); 2 rejeitados, um deles na barra 4 | ENTREGUE, aceitos, entram na leva seguinte |
| M5 | quarta rodada + proveniência do avisoWood + limpeza dos achados | EM EDIÇÃO |
| M6 | régua da proveniência em cinco graus + auditoria de origem dos 21: três declaram grau acima do real | ENTREGUE; as três correções foram para a M3 |
| M7 | a régua vira lei no brief; dois candidatos de grau A (Kant, Maimônides) | ENTREGUE, aceitos |
| M8 | pacote da leva 2 pronto para colar + auditoria de alegação de eficácia: seis frases em que o app afirma um fato sobre as pessoas na própria voz | ENTREGUE, aceitas |
| M9 | percepção com grau A + o mapa do que falta no catálogo | EM EDIÇÃO |
| MR | volta de app: os seis desvios de roteamento + as seis frases da voz do catálogo, com teste que trave o padrão | abre quando a M3 mesclar |
| M10 | colagem da leva 2 (os oito aceitos de M4 a M7), pelo pacote `metodos/leva-2.md` | abre depois da MR |

**A trilha está PARADA, com o trabalho fechado e pronto para retomar — e a parada é decisão minha, não fila vazia.** As rodadas M1 a M15 mescladas em main (`6c8e78e`, só documento) deixam: 14 métodos propostos com fonte primária, 8 rejeitados com o motivo escrito, a régua da proveniência em cinco graus com a emenda da ficção, a régua da voz do app, três auditorias (origem, alegação de eficácia, voz) e o pacote de execução completo em `ferramentas/orca/metodos/leva-3-e-fusao.md`. O que falta agora não é pesquisa: é o app alcançar o que já foi produzido — a M3 mescla, depois a volta de execução cola os catorze, funde a Inversão, aplica as duas frases de origem, as seis de voz e a higiene II.0. Retomar a trilha é dar a próxima rodada ao mesmo brief; ela nasce sabendo tudo, porque a régua está no brief e não na cabeça de ninguém.

**Achado do fecho, e ele PARA a fusão da Inversão se a volta não tocar Swift:** a lei do método ausente (ADR 05x) diz na tela "o método X saiu da SUA PASTA". É verdade quando o autor apagou um método da pasta dele, e é FALSA quando fomos NÓS que o tiramos do catálogo — e os dois casos não se distinguem depois do fato, porque o método some junto com a informação de onde vinha. Conserto: uma linha em `Gesto.swift:68` ("não está mais no catálogo", que serve aos dois casos) mais a string do teste. **Melhor adiar uma deleção do que publicar uma frase falsa para o autor.**

**G0 de M1.** Ciclo: melhorar (o catálogo é o repertório de instrumentos de pensamento do autor). Intenção: o autor encontra o instrumento certo para o movimento que está tentando fazer, e sabe de onde ele vem. Obstáculo: 21 métodos e nenhuma rotina de entrada; sem critério escrito, catálogo vira lista de produtividade. Evidência: três a cinco fichas com JSON completo e fonte primária citada literalmente, um rejeitado com a barra em que caiu, e a saída do teste das regex contra os outros 20. Quando a forma proposta pedir algo que o app ainda não faz, a ficha nomeia isso e eu abro a volta. Escopo: só `ferramentas/orca/metodos/`; `Traco/Modelo/Metodos.json` fica fechado até a V16 mesclar.

**G0 de M3 (colagem).** Ciclo: melhorar. Intenção: os quatro métodos novos entram no catálogo sem quebrar o roteamento nem a proteção da escrita pessoal. Decisão do dono, 06/09 13:40: **os quatro aprovados** — Subtração (simplificação), Coluna da esquerda (relação), Classe de referência (previsão) e Cinco porquês (causa), este último condicionado a a M2 fechar a citação de Ohno na fonte primária ou trocá-la por uma verificável; método do catálogo não carrega frase que ninguém do Traço leu no original. Colar no FIM do catálogo: a M1 mediu que colar antes da Especificação faz a Coluna da esquerda roubar o desabafo da Expressiva — a proteção da escrita pessoal depende da ordem. No mesmo passo, e por decisão do dono na mesma data, consertar o roteamento do Se–então (`sempre que|toda vez|não consigo parar` sem `\b`, que casa dentro de "sempre quebra" e "sempre queria") com teste que fixe a correção. Os cinco desvios pré-existentes que a M1 mediu ficam nomeados para uma volta de roteamento própria, se o dono quiser. Escopo: Traco/Modelo/Metodos.json, TracoTests/CatalogoTests.swift, ferramentas/orca/metodos/; só abre depois de a V16 mesclar em main.

### A ficha do Calendário herda a PromessaDoAviso (abre quando a V18 mesclar)

A V9 achou o mesmo defeito em dois lugares: a ficha do Calendário e o agendamento do Trabalho prometiam "Toca…" com avisos não autorizados (ADR 04a). A V18 resolveu o lado do Trabalho com `PromessaDoAviso`, um tipo puro e testado que distingue concedido, não perguntado, negado e hora já passada — e os dois revisores confirmaram que ele serve à ficha. **Três pré-requisitos foram achados enquanto a V18 fechava, e todos já estão feitos ou nomeados:** (1) `jaPassou` guardado por `!evento.repete`, senão "Correr toda terça 6:30" receberia "ficou sem alarme" enquanto o alarme toca — FEITO na 18-C; (2) `instante:` e `repete:` sem valor padrão, para ninguém consumir o tipo sem passar o instante certo — FEITO; (3) **`CalendarioAgenda.estadoDosAvisos` é não-opcional e nasce `.concedido`**, então a ficha nunca consegue expressar "leitura pendente" e afirmaria "Toca…" na janela antes de a leitura voltar — TORNAR OPCIONAL (ou `.naoPerguntado`) antes de consumir o tipo. Escopo: `Traco/Calendario/{CalendarioFicha,CalendarioAgenda}.swift` e TracoTests. Evidência: a ficha deixa de mostrar "Toca…" e "nada vai tocar" juntas, os quatro estados na tela, e o caso do compromisso que repete.

### A auditoria V9 está PARCIALMENTE DESATUALIZADA — leia isto antes de abrir V13, V15 ou qualquer volta por tela

Achado de processo da V19 (Recordar), confirmado pelo revisor com `git show` e quadros de vídeo: **três dos quatro defeitos que a auditoria V9 lista para o Recordar já tinham caído** em voltas posteriores (V8 e V10-B) — o `PrimarioStyle` local, o cross-fade do §21 (o vídeo do ANTES não tem um único quadro com dois textos legíveis) e a hifenização do cabeçalho. O quarto (o toast nascendo sobre a barra de ações) **está vivo**, e a ADR da volta o declarava morto: o revisor derrubou.

**A regra que sai daí, e vale para toda volta por tela daqui em diante:** a fase "auditar antes de tocar" do `design-router` não é ler a auditoria, é **conferir a auditoria na tela viva antes de escrever a primeira linha** — e escrever na ADR, defeito a defeito, qual continua vivo e qual já caiu, com a captura que prova. Sem isso, corre-se o risco de gastar uma volta consertando o que já está consertado, ou pior, de declarar morto o que está vivo. A V9 tem cinco dias e cinco voltas de código por cima.

### Dívida vinda dos portões de hoje

- **As quatro dívidas de `try!` que a volta A1 congelou** (ADR 08n; o portão está em `TracoTests/PortaoDoTryBangTests.swift` e fica vermelho se subirem). Medido, e a medida se refaz — `grep -rn 'try!' Traco/ TracoWidget/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//'` dá **9 em `main` e 8 no branch da A1** (o `grep` cru dá 10 hoje: a volta escreveu duas linhas de comentário que dizem `try!`; o portão conta com `codigoVisivel`, que apaga comentário e string, e chega ao mesmo 8). **Infalível por construção, não é dívida:** `Traco/Caderno/AnexoDisco.swift:48`, `Traco/Notas/Indice.swift:96` e `Traco/Notas/Corpus.swift:277` (`NSRegularExpression` de padrão literal); `Traco/Trabalho/ConferenciaTrabalho.swift:179` é literal **só enquanto todo chamador passar literal** — o padrão chega por argumento, e isso é o que fura primeiro. **Dívida real, serialização de valor vindo de fora:** `Traco/Analise/FonteNotas.swift:155` e `Traco/Trabalho/PraticaTrabalho.swift:529` (`JSONSerialization.data` sobre objeto montado em runtime), `Traco/Notas/Corpus.swift:144` (`encode` de campo do autor, com um `!` de dicionário na mesma linha) e `Traco/App/Sessao.swift:599` (`encode` do texto do autor). A A1 NÃO as consertou de propósito: `Analise` é da volta Q e `Trabalho` é da E1, as duas vivas em 08/09. Volta própria, pequena, quando as duas fecharem.
- **A recuperação que a A1 não entrega:** a tela do arranque falho oferece só "tentar de novo". Trazer o espelho em Markdown de volta para dentro do banco — o backup que a própria tela aponta — é volta própria, e tem de nascer com a regra da A1 na mão: preservar antes de voltar a funcionar, nada apaga para consertar.
- **AX5 sangra pelos dois lados** num documento COM versão da IA (`ConteudoTrabalhoView`), enquanto documento novo fica impecável. Pré-existente, achado no re-G3 da V18 — e o revisor assumiu que o próprio G3 dele validou AX5 num trabalho sem versão.
- **O teclado cobre a ação primária** depois do pedido, no Trabalho. Atrito igual antes e depois da V18.
- **O `.compacto` secundário com 17,0:1 contra 6,36:1 da primária** (achado do G4 da V11): a secundária tem mais contraste que a primária.
- **`IntercambioTrabalhoView` tem três ações que perdem a cápsula** quando bloqueadas — a V11-C está alinhando com o padrão da V18.
- **Prova de fala do VoiceOver não fechada** em duas voltas (o `Announcement` da V18 e o estado negado da promessa): exige simulador com VoiceOver ligado, que ninguém teve neste turno. Não é desculpa, é pendência de instrumento — e a única saída é um turno em que alguém rode VoiceOver de verdade.
- **A densidade da guarda de escrita pessoal cala nota de sistema** (dívida residual, NÃO regressão — vinda do re-G3 da A-5, achado MÉDIO-3). Duas palavras de dupla vida numa nota de trabalho são comuns ("o medo é o servidor cair" + "equipe cansada"; "time exausto" + "fila vazia") e `duasDeDuplaVida` as trata como o assunto. O revisor escreveu 20 notas de trabalho novas: **15 seguem caladas na A-5-B — e as mesmas 20 eram caladas em `main` também**, o que faz disto dívida antiga e não preço da volta. Das 15, oito chegariam a uma forma real sem a guarda (`spec` ×5, `premortem`, `decisao`, `leitura`). A A-5-B alargou essa mesma densidade em dois termos ao acrescentar `ansiedade` e `cansaço` à `lexicoDeDuplaVida`. Conserto provável: exigir do segundo termo a mesma prova de autoria que o primeiro tem (a densidade hoje não olha quem é o sujeito), ou pedir que uma das duas palavras venha com primeira pessoa. Escopo: `Traco/Analise/AnaliseLocal.swift` e `TracoTests/EscritaPessoalTests.swift`, com um bloco novo de notas de sistema na régua inversa.

### A curadoria dos 42 métodos — decisão do orquestrador (DIRETRIZ §6)

A trilha julgou os 41 (a Expressiva não conta: é superfície de proteção, campos vazios, movimento vazio) contra as nove capacidades e propôs núcleo de 32, três saindo e seis em observação. **Decido: sai UM, não três.**

- **Inversão → funde com o Pré-mortem: ACEITO.** Mesmo movimento, o Pré-mortem faz mais (falha já ocorrida, sinal precoce, data), e a Inversão tem a proveniência mais fraca dos 21 pela auditoria da M6. A pergunta dela vira a abertura do movimento do Pré-mortem — uma frase, não um campo. Sai só do JSON. É deleção, que conta como entrega.
- **Destaque: FICA.** O pesquisador se corrigiu com honestidade (foi ao código e viu que `Sessao.aplicarDestaque` publica de qualquer método com campo "unica", que o Dia tem, e portanto widget e tela bloqueada sobrevivem à fusão) e deixou a decisão como gosto. O gosto é este: o Destaque é a porta de entrada de UM CAMPO SÓ para a superfície mais usada do app — widget, tela bloqueada, Ilha. Fundir economiza uma entrada do array e custa o caminho mais barato que existe no produto. Caminho barato não é gordura.
- **Palavra: FICA, em observação.** Ela não duplica ninguém (o campo "onde NÃO se aplica" é só dela), e o próprio pesquisador não a defende com convicção nem defende o corte. Cortar um método que não duplica nada por um orçamento que a mesma rodada mostrou ser de MANUTENÇÃO, e não cognitivo, é cortar músculo com a régua errada.

**A correção que a rodada trouxe sobre o teto de ~40 vale mais que a curadoria:** o teto nunca foi limite do que o autor consegue escolher — o roteamento escolhe por ele, `detectarGesto` devolve uma forma e o cartão oferece uma, com "Deixar como nota" ao lado; a Hicks não morderia nem com 60. O teto é de MANUTENÇÃO: cada método novo disputa as mesmas frases no roteador, e os cinco desvios herdados são esse custo aparecendo. Onde a Hicks morde de verdade são três superfícies, e em nenhuma a saída é ter menos métodos: os chips da busca (20 hoje, 41 com tudo colado) pedem chip por CAPACIDADE, nove, com a forma dentro; a folha de formas do Perfil devia copiar o `MenuFormasView`, que já resolve um problema maior (124 formas em 13 famílias, com cabeçalho grudado, busca e contagem); e as duas listas fechadas de verdade — `GestoEscolha` e a análise de bordo — são volta de app, não curadoria.

**Achado de código que virou item da A2:** `Traco/App/Intents/Intencoes.swift:253`, `enum GestoEscolha`, tem NOVE formas escritas à mão — é o que a Siri e os Atalhos oferecem. Com 28 métodos no catálogo, quem usa a Siri alcança nove, e nada falha para avisar. Mesma doença do `GestoDeBordo` com dez, e foi para a mesma volta.

**Fica para uma volta de front-end, quando as telas de busca e Perfil abrirem:** chip por capacidade na busca (nove em vez de 41) e a folha de formas do Perfil no molde do `MenuFormasView`.

### Vindas do IDEIAS.md (conversa do dono, 06/09) — decisão do orquestrador, DIRETRIZ §6

Li `ferramentas/orca/IDEIAS.md` inteiro. **Aceito A, B (em duas partes), e C; adio D pelo motivo que o próprio texto dá, e acrescento um.** Ordem: a **A** entra alto — acima de V13, V14 e V15 — porque é a única proposta que mede o SEGUNDO ciclo com dado que já existe; a **B1** vem depois dela; a **C** é uma tarefa da trilha Métodos, sem código.

**A — APROVADA PELO DONO (06/09) E EM EDIÇÃO como volta L1, no topo da fila de código (worktree volta-l1-latencia).** * Ciclo: melhorar, e é a lacuna "modelo revisável do autor" do EVOLUCAO. Intenção: o autor vê quanto tempo leva para descobrir que estava errado, e vê essa distância encurtar ou não ao longo do tempo. Obstáculo: **o Traço já mede e não sabe que mede** — `Trabalho.Hipotese` guarda `data` e `avaliadaEm`, a Decisão tem "o que espero e quando eu confiro" e "o que aconteceu", e `Volta.devida` já cobra pela data; nada disso vira grandeza nem série na tela. É motor sem superfície, e função que o autor não vê não foi entregue. Evidência: por hipótese e por decisão, a distância entre afirmar e descobrir; a SÉRIE ao longo do tempo, que é o que interessa; a série real do dono na tela com pelo menos uma hipótese fechada e uma aberta; e uma hipótese antiga sem `avaliadaEm` mostrando "tempo desconhecido" sem inventar. **Estado honesto é o contrato desta volta:** afirmado, devido, descoberto e abandonado são estados distintos, abandonar é resultado legítimo, e hipótese nunca avaliada é informação, não falha moral. **Não vira placar, streak nem contagem** — a visão rejeita, e uma medida do segundo ciclo que vira cobrança destrói o que mede. Escopo: `Traco/Modelo` (leitura da série), a superfície onde ela aparece (Perfil ou Trabalho, a decidir na volta com `design-router`), TracoTests. **Abre quando a V11 e a V18 mesclarem**, porque as duas estão dentro de Traco/Trabalho.

**B1 — ADIADA pelo dono (06/09): "B espera".** Fica no IDEIAS.md e neste RUMO, sem abrir. Original: Ciclo: multiplicar. Intenção: antes de comprometer uma intenção, o autor escreve o experimento mais barato que responderia à mesma pergunta. Obstáculo: o Trabalho vai de intenção a artefato a ação sem nunca perguntar se existe uma versão menor da tentativa; errar barato é o que separa quem tem muitas tentativas de quem tem poucas. **Corte meu em relação ao IDEIAS:** entra só A LINHA, oferecida e dispensável, NUNCA portão — os quatro eixos de custo (tempo, dinheiro, exposição, reversibilidade) ficam para a **B2**, e a B2 só abre se a linha da B1 for usada de verdade. O risco que o próprio texto nomeia (virar formulário obrigatório antes de agir) é grande demais para entrar de uma vez, e a curva-zero manda o mesmo. Evidência: a linha existe, é dispensável sem custo, e uma tentativa real do dono passou por ela.

**C — APROVADA PELO DONO E JÁ ENTREGUE pela trilha na rodada M13:** os três de grau A, lidos no original, com duas correções de origem que a régua pegou — a distinção one-way/two-way door NÃO está na carta de 1997 de Bezos (está na de 2015), e a história dos aviões NÃO está em Wald (zero ocorrências de "hole", "diagram" ou "red dot" nos 113 mil caracteres do memorando de 1943; o que há são equações estimando vulnerabilidade a partir de quem voltou, e é melhor que a anedota). Fichas em `ferramentas/orca/metodos/{porta,transferencia,sobrevivente}.md`; entram na colagem da leva 3. Original: Vai para a trilha Métodos como tarefa da rodada M13, sem código: confirmar origem na fonte primária, escrever a ficha, ou rejeitar com motivo. A **Porta** (reversibilidade da decisão, Bezos 1997) preenche um buraco que a própria trilha não tinha visto: Decisão e Pré-mortem falam do CONTEÚDO da decisão e nenhum fala de QUANTO ELA MERECE DE DELIBERAÇÃO. **Transferência** e **Sobrevivente** servem diretamente ao que o dono quer fazer ao ler sobre quem realizou muito. Entram na leva 3.

**D — ADIADO pelo dono: "só depois de A provar".** E concordo com o motivo do próprio texto. Só depois de A e B provarem na tela, e com consulta ao conselho antes de qualquer contrato. **Acrescento um motivo:** um mapa de "onde eu estou por dentro" tende a virar uma imagem de si que o autor DEFENDE em vez de revisar — o oposto do modelo revisável que a visão pede. Se entrar um dia, tem de nascer com o mecanismo de ser contrariado pelos fatos do próprio corpus, não pela opinião do autor sobre si.

### A2 — as listas de métodos escritas à mão (FEITA; e a premissa estava meio errada)

**Correção do que eu escrevi aqui antes, e ela importa.** Eu registrei que `AnaliseDeBordo.GestoDeBordo`, a enum de dez casos, era o que fazia o modelo de bordo ignorar dois terços do catálogo. Estava errado, e o worker da A2 provou: **a enum estava MORTA desde a ADR 04l** — o esquema e o prompt já nasciam de `Catalogo.todos`, e o teste que trava isso já existia. O que a enum fazia era descrever um contrato falso, e código morto que descreve contrato falso enganou três leitores: o pesquisador da trilha, o revisor e eu. Foi apagada.

**O que estava vivo era o segundo achado**, o `AppEnum` de nove casos em `Traco/App/Intents/Intencoes.swift:253`: quem usava a Siri e os Atalhos alcançava NOVE formas de 21, e nada falhava para avisar. Virou `FormaEntity`/`FormaQuery` a partir de `Catalogo.todos` (AppEnum exige `caseDisplayRepresentations` estático; entidade com consulta, não). Custo medido do catálogo inteiro no `@Generable`, com Apple Intelligence, sete frases: dez ids 5,38 s (0,77 s por chamada), 21 ids 5,56 s (0,79 s) — **+3,3%, dentro do ruído**; e com dez, as cinco frases que convocavam método de fora não tinham como acertar. ADR 2026-09-06g.

**A lição de processo, que vale mais que a volta:** três leitores independentes leram uma enum e concluíram, todos, que ela governava o comportamento. Nenhum abriu o chamador. É a mesma regra que a trilha escreveu para a voz do app — *se a frase tem o app como sujeito de um verbo, abra a função antes de escrevê-la* — valendo para código: se o achado é sobre o que uma lista GOVERNA, abra quem a lê.

### MR — a voz do catálogo e o roteamento (abre quando a M3 mesclar)

Ciclo: multiplicar, e é fronteira da IA. Intenção: o catálogo cobra o passo sem afirmar um fato sobre as pessoas que ninguém mediu, e nenhuma frase de gatilho nasce inalcançável. Obstáculo, medido pela trilha: (a) seis campos `movimento` afirmam na voz do app — "todo mundo pula escrevendo obstáculo externo" (WOOP), "todo mundo responde à fraca" (Argumento), "todo mundo planeja como se o dia fosse obedecer" (Dia), "a maioria para na terceira" (Divergência), "quem só concorda não leu, copiou" (Leitura), "quem explica sem travar usou jargão no lugar da compreensão" (Feynman, que além de sentença é falsa como regra) — mais duas frases que o próprio pesquisador escreveu e corrigiu; o conserto é sempre trocar a afirmação sobre as pessoas pela COBRANÇA do método, e o modelo certo já existe lá dentro (a Inversão tempera, a Subtração atribui ao estudo); (b) seis desvios de roteamento, cinco pré-existentes (`(?m)^quero` do WOOP engolindo Pré-mortem, Feynman, Primeiros princípios e Prática deliberada; "ideia" da Nota permanente engolindo Destilar) e um nascido na leva 1 (`\bolhando o dia de hoje\b` do Exame da noite, inalcançável porque `\bo dia de hoje\b` do Dia casa antes). Evidência: as doze frases trocadas, um teste que falhe se voltar a entrar afirmação sobre as pessoas sem fonte, e a prova de roteamento sem desvio. Escopo: `Traco/Modelo/Metodos.json`, `TracoTests/CatalogoTests.swift`. As frases prontas estão em `ferramentas/orca/metodos/auditoria-eficacia.md`.

### Voltas que a trilha Métodos revelou (abrem depois que F4, F3b e V11 mesclarem, por causa de Sessao.swift)

- **Botão de encadeamento que acende e não faz nada.** Encadeamento cujo destino não está no catálogo desenha o botão do mesmo jeito; `Sessao.encadear` sai em silêncio. Estado desonesto na tela: o autor toca e nada acontece. Ciclo: multiplicar. Evidência: o botão não nasce quando o destino não existe, teste, e captura do estado. Escopo: `Traco/App/Sessao.swift` e a view que desenha o botão. A guarda de DADO (nenhum encadeamento apontando para id inexistente + teste) já entrou na M3; falta a tela.
- **A proveniência do aviso do app.** `AnaliseLocal.swift` interrompe o autor com `avisoWood` ("Afirmação sem prova não gruda") por regex, sem dizer de onde vem. A M5 escreve a ficha com a fonte primária e o texto que o aviso deveria mostrar; a volta troca o texto. É a fronteira da IA aplicada a um aviso: forma, informação e pergunta, nunca a sentença.
- **Volta de roteamento.** Os cinco desvios pré-existentes que a trilha mediu: o `(?m)^quero` do WOOP engolindo Pré-mortem, Feynman, Primeiros princípios e Prática deliberada; "ideia" da Nota permanente engolindo Destilar. Escopo: `Metodos.json` e `CatalogoTests`.
- **O que a forma livre pede do app** (seção 7 de `ferramentas/orca/metodos/achados-catalogo.md`, seis pedidos): duas colunas emparelhadas, cadeia de profundidade variável, campo repetível (serve a Cinco porquês, Divergência e Classe de referência), e o maior deles — a Classe de referência pedindo que o Traço leia o corpus e ofereça os casos parecidos que o autor já escreveu.

## Política de peso das evidências

PNG de captura ≤ 400 KB (reduzir com `sips -Z 1000` antes de commitar), vídeo ≤ 3 MB (≤ 20 s, `-crf 30`), hierarquias em texto. F1 somou 52 MB e V9 82 MB: a partir da V10 o G5 recusa evidência acima disso.

## Estado do laço — PARADO em 06/09 23h20, por ordem do dono

Parou por ordem, não por cota (semanal 4%, janela de sessão 1%) e não por falha. Nada em main sem passar pelos portões; os seis worktrees estão limpos, sem simulador ligado e com a trava do instrumento livre. O detalhe do que ficou em cada um, e o que falta para retomar, está na seção **PARADA** do LACO — leia de lá, não daqui.

**Mesclado em 06/09, seis voltas:** V16 métodos com proveniência · F3b ditado próprio · A1-A4 a voz do app e a proteção da escrita pessoal · V11 ambiente Markdown · A5 a guarda para de calar a nota comum · V18 Trabalho até 9.

### A limpeza de 07/09 — as seis mescladas por ordem do dono, e o que cada uma deixou

Ordem do dono de 07/09 à noite: limpeza geral do git, sem perder nada, só `main` local e remota. As seis voltas "a um passo do merge" foram mescladas em `main` NA ORDEM que o LACO pedia (A-6 → M3 → V12 → F4 → V19 → L1), com os conflitos de SPEC/EVOLUCAO costurados mantendo os dois lados em ordem cronológica, o projeto regenerado pelo xcodegen, e a suíte integral verde na árvore final (885 testes em 142 suítes). **Isto NÃO substitui os portões que faltavam**: o que cada volta ainda devia está aqui como dívida nomeada, e é o topo da fila quando o laço retomar.

1. **V12** — itens 2 (AX5) e 4 do re-G4 não julgados; o fantasma do `.sheet` (~110 ms sobre o texto do autor).
2. **F4** — o Destaque LONGO ainda termina em reticências quando o rodapé "Desatualizado." entra (é a repartição de altura, não a propriedade); o quadro de ofertas lê como lista de Ajustes; tela bloqueada, StandBy e Ilha sem captura; o médio mostra uma linha de agenda e não três.
3. **V19** — A1: o toast nasce sobre a barra de ações (`PaginaView`, `padding(.bottom, 88)` chutado); A3: `Pilula` sem estado desabilitado (1,53:1 para todos os chamadores) — dívida de Componentes; refotografar AX5 do "escrever".
4. **L1** — G4 NÃO PASSOU (Design 8, Simplicidade 7): `Tema.miudo` reservado a fora do app pela ADR 05u e usado duas vezes dentro; o cartão ocupa 6 a 7 telas em AX5 num Perfil com Simplicidade 6; a lista de meses sem teto. Depois: modo escuro, modo B cruzado com AX5, VoiceOver.
5. **A-6** — as quatro linhas de documento do G3 (a causa contada na ADR era falsa: contaminação, não rabo; a régua nova não cobra a exclusividade que a ADR lhe atribui; `olhando o dia de hoje` é porta morta; faltam dois números).
6. **M3** — a string `aplicabilidade` do `exameDaNoite` promete ao autor a matéria que a guarda recusa levar ao método; dois comentários mortos.
7. ~~**O portão que falta**~~ — **PAGA em 08/09** pela volta P1 (ADR 08e, `29cc2ce`): o teste existe, a dívida real de curva literal era ZERO, e o portão está em zero contra a árvore mesclada. Fica em pé o registro do porquê: a classe do cross-fade apareceu SEIS vezes na volta 12, com TRÊS causas distintas. O juiz do re-G4 concluiu, e eu assino: **falta um portão que impeça escrever `withAnimation` sem passar por `Tema`.** Um teste que varra o repositório, ou uma regra de lint.
8. Depois: **V13 Notas**, **V15 Calendário** (as duas começam conferindo a auditoria V9 na tela viva) e **V17 em Markdown** (G0 acima).

**Branches guardados como tag, não mescláveis:** `arquivo/feat-traco-folha` (03–05/09: a nota como folha sobre o tampo, share de entrada, arrasto na lista — 4 commits) e `arquivo/fix-furos-radiografia` (02/09: selo desde o primeiro caractere, arranque honesto com banco que não abre, uma porta só para o disco, apagar com desfazer, 70 fluxos com asserção — 12 commits). Os dois nasceram em `c1e1bbe`, 184 commits atrás; `main` reimplementou parte por outro caminho (ADRs 05h/05s). O que ainda vale deles é ideia a reler, não código a colar — o `try!` de `DiscoTraco.abrir` no arranque (`TracoApp.swift:13`), que a radiografia tratava, continua vivo em `main`.

### Vindas do fecho da L2 (08/09), para a volta do Perfil

- **A decisão que levaria a tela a 9 não é a extração dos cartões** — o juiz do G4 mediu e disse: extrair não muda um pixel (é dívida de Complexidade). O que muda a Simplicidade é **decidir o que o Perfil mostra por padrão**. Essa é a linha G0 da volta do Perfil.
- **A copy do horizonte está imprecisa:** os "12 últimos" são meses **com descobertas**, não os doze últimos meses do calendário.
- **VoiceOver do Perfil continua por ouvir** — ligar o leitor exige reiniciar o aparelho, o que é proibido no meio de uma rodada; precisa de uma janela própria.
- **O transbordo horizontal do Perfil em AX5** reproduz em `HEAD` sem o diff da volta, e o app Ajustes no mesmo aparelho não transborda: é de `Camadas`/`RaizView`.

### Vindas do fecho da F4-F (08/09): o que só o aparelho real fecha

O simulador não prova, e as quatro ficam para uma passada no iPhone do dono (item 12 da fila): **StandBy noturno** (não renderiza no simulador), **Ilha mínima** (só aparece com duas atividades disputando a Ilha, e não há segundo app com Live Activity), **VoiceOver ouvido** (o `ax` recusa e ligar o leitor exige reiniciar o aparelho) e **a Ilha compacta com duas atividades em AX5**, onde o juiz viu um quadro isolado com o "t" cortado. As três primeiras foram confirmadas como limite por dois revisores independentes — não são desculpa de implementador.

### Quatro P3 do G4 da V17 (não bloqueiam, ficam para a próxima volta do Trabalho)

O juiz listou e não descontou: `isHeader` faltando nas duas seções novas; o `id` do `DisclosureGroup` sombreando os filhos; as aspas de "A pedido seu."; e um `spacing` literal onde a convenção manda token. Nenhum é de tela quebrada — são acabamento de acessibilidade e de convenção, e entram na volta que tocar `TrabalhoView` de novo.

### Dois achados da V13 (08/09), com dono nomeado

- **[FECHADO em 09/09 pelas voltas C1 e C1-B — ADR 08w e 08x.]** ~~O caret do Caderno falha em AX XXXL no iPhone 17e.~~ A V13 rodou a suíte integral no `C7341E64` e o **único vermelho** é esse — e ela provou que é **pré-existente**, com as mesmas 18 ocorrências em `HEAD` sem o diff dela. É da invariante da escrita visível (V12, ADR 08f, já mesclada), que foi provada no Pro Max e no teste 2 mas **não neste aparelho neste tamanho**. Volta do Caderno, e a prova tem de incluir o 17e em AX XXXL.
- **A pergunta interrompida some ao trocar de aba**, porque `RaizView` **recria** a `NotasView`. É estado desonesto — a pessoa perde o que estava esperando sem que nada diga. Conserto na `Sessao`, área do arquiteto, não do front.

### Vindas do fecho da C1 (09/09): a barra de baixo, e o que o instrumento não alcança

**Escritas aqui porque a ADR 08w as prometeu ao RUMO e o re-G3 as cobrou. As duas
saem do mesmo lugar: o pé toma 275 dos 414 pt do 17e em AX XXXL.**

- **A BARRA DE BAIXO EM TAMANHOS DE ACESSIBILIDADE — volta própria, do front.**
  No iPhone 17e em AX XXXL o pé do encaixe toma **274,67 dos 413,67 pt** de tela
  com o teclado de pé, e **326,67 com o aviso**. Enquanto ela não encolher, o
  papel só cabe porque a 08w mandou o cartão ceder: com aviso E toast o encaixe
  fica com ~0 pt e a mensagem da sábia sai da tela. Isso é **decisão escrita**
  (08w), não descuido — e é a decisão que deixa de ser necessária no dia em que
  a barra couber. **Ciclo:** multiplicar. **Intenção:** o autor vê o que escreve
  E a saída do cartão, sem escolher entre os dois. **Evidência pedida:** a mesma
  sonda de `tetoDoEncaixe` no 17e em AX XXXL, com o pé abaixo de 200 pt e
  `EscritaVisivelTests` verde sem o encaixe ceder a zero.

- **O ORÁCULO DE PIXELS SOBRE A COMPOSIÇÃO NATIVA — herdada da 08f, agora com
  preço medido.** A C1-B provou a 08f **quadro a quadro** por dentro do processo
  (`CADisplayLink` + camadas de apresentação), e isso alcança a geometria: onde
  a linha e o papel estão em cada quadro entregue. **Não alcança o pixel**: uma
  camada que desenhe por cima com a mesma geometria passa. A varredura de
  camadas (`intrusos`) cobre o caso na medida discreta, e não corre por quadro
  porque custa a passada inteira da árvore. **Ciclo:** multiplicar.
  **Evidência pedida:** comparação de quadros nativos (`simctl io recordVideo` +
  `ffmpeg`) contra a geometria esperada, num alvo fora da suíte integral.

- **O SEGUIDOR NÃO GANHA DE UMA ALTURA ANIMADA — limite do instrumento, escrito
  para não ser redescoberto.** Medido na C1-B com três seguidores diferentes
  (adiado pelo runloop, síncrono, síncrono com a altura anunciada e com
  adiantamento de um passo): **os três deram os mesmos offsets, ao ponto.** De
  fora do layout do SwiftUI não há como pôr a correção da rolagem no MESMO
  quadro em que a altura muda, porque o quadro apresentado é sempre o modelo do
  anterior. Por isso a 08x proíbe a gaveta sobre a linha do autor em vez de
  tentar correr mais depressa. **Quem quiser reabrir** precisa de um gancho
  dentro do layout (um `UIScrollView` próprio, não o do SwiftUI), e isso é volta
  de arquitetura, não de acabamento.

### A RÉGUA DO VAZAMENTO, nos dois sentidos — volta própria, e ela vem antes de mexer no parser

A Q-D mediu 30 execuções e 9 recusas, **8 por vazamento e 1 por limite**, e em quatro delas a evidência exposta aponta para **nós**: as quatro palavras do trecho **já estavam no pedido do autor**. As quatro sem evidência ficaram **INDETERMINADAS e não foram contadas a favor**.

**O que falta escrever antes de tocar no código:** o que é vazar **quando o alvo é um exemplo** e não a resposta. No Recordar, a guarda `Prova.vaza` existe porque **o alvo É a resposta** — repetir o alvo entrega o exercício. Na preparação de prática, o alvo é **o exemplo**, que por contrato é **outro caso**, e o vocabulário estrutural da tarefa (o que o próprio pedido manda separar) **passa pelo exemplo antes de chegar ao critério**. Sem essa régua escrita, alargar o parser é abrir a porta para a IA entregar a resposta pronta, e apertá-lo é recusar trabalho bom.

Ciclo: melhorar. **Evidência:** a régua escrita nos dois sentidos, com casos que a guarda DEVE recusar e casos que ela NÃO deve, e a medida refeita contra ela.

### RESOLVIDO em 08/09 pela Q-C, e a resposta é contra nós: a guarda está no lugar errado

**3 das 15 execuções de `prepararPratica` não entregam — e não é teto nem provedor.** HTTP 200, conteúdo completo, `grok-4.6` confirmado, 3.777 a 6.865 tokens de raciocínio, e **recusadas pelo NOSSO contrato** (`PraticaTrabalho.parsePreparacao`/`validar`). Por entrega, a operação sai de 1/6 para **4/6**.

**A resposta veio com o texto na mão, não com a contagem.** Instrumentado o motivo, as cinco recusas caíram **todas na mesma guarda** — *"vazamento · o critério N repete quatro palavras seguidas do exemplo"* — e, com o quadrigrama exposto, o texto vazado é **"a dependência ainda aberta"**: **vocabulário estrutural da tarefa**, que o pedido do autor manda separar (concluído, a dependência, próximo passo) e que **está na instrução antes de estar no exemplo**.

**O defeito é NOSSO.** `Prova.vaza` veio do Recordar, onde **o alvo É a resposta**; aqui o alvo é o **exemplo**, que por contrato é outro caso. A guarda certa no lugar errado recusa trabalho bom. **A Q-C não alargou o parser** — ordem minha — e a régua nos dois sentidos fica para escrever antes de mexer: *o que é vazar quando o alvo é um exemplo, e não a resposta?*

**Correção de leitura minha, registrada:** eu havia concluído, com a categoria da recusa mas sem o texto, que o parser estava certo e o defeito era do provedor. Estava errado, e foi o worker que me corrigiu expondo o trecho.

A Q-B **não** moveu isso para a tabela de indisponibilidade, e o argumento é bom: recusa ocasional já tem superfície por pedido (`EstadoPedido.praticaIndisponivel`), enquanto **a tabela não sabe dizer "às vezes"**. Fica a pergunta que decide de quem é o defeito: **o parser está certo em recusar, ou está estreito demais?** Volta própria, e ela é do tipo que pode devolver uma operação inteira ao autor sem tocar no provedor.

### O que o conselho da Q fixou sobre a fila do dono (08/09)

- **Item 2 fecha com o MAPA**, não com dezesseis células preenchidas de Grok: atendimento, falhas, condições e a política correspondente, **declarando qualquer executor inacessível**.
- **Item 3 fica na Q-B** enquanto a ajuda não atender tentativas variadas. Corte honesto não o paga.
- **Item 9 exige jornada atual com IA real** — resposta ruim, interrupção, nova tentativa, estados e conteúdo preservados na UI. **A sonda isolada não o fecha.**
- **Indisponibilidade por qualidade não existe hoje na tabela:** as três regras da `Politica` não a distinguem de falta de conta, e por isso a tela manda conectar Grok quando a conta já existe. É contrato a criar, não texto a trocar.

### Vinda do conselho da V12 (08/09): o oráculo de pixels

**Volta própria, e cara.** O conselho respondeu que a prova geométrica da escrita visível cabe numa suíte hospedada (entra na V12-E), mas **a prova TEMPORAL do fantasma exige um oráculo de pixels sobre quadros nativos capturados**: detecta texto do papel na região exclusiva do cartão, perda de cobertura ou duas geometrias concorrentes, com e sem Reduzir Movimento, analisando **depois** da captura, sem juiz assistindo a vídeo. Custa instrumentação de renderização, é **amostrada** e **não certifica "nenhum quadro possível"** — captura externa ao caminho medido, localização das superfícies, tolerâncias calibradas e controle de quadros ausentes; lacuna de captura torna o intervalo inconclusivo. Ciclo: melhorar (barateia todo julgamento de movimento). **Avisos do conselho, para quem abrir:** `CADisplayLink` é temporizador sincronizado à tela, **não captura de pixels**; `presentation()` é aproximação da camada exibida; e **fotografar no callback altera o fenômeno** — a V12-D provou isso por outro caminho, ao descobrir que o quadro longo era o `fotografar()` do próprio teste.

## A fila do dono, 08/09 — as doze prioridades do Astra, mapeadas nas voltas

O dono pediu ao Astra uma leitura de prioridades e depois decidiu que o laço do Orca as resolve, todas, com mais qualidade por token. A tabela abaixo é a dele; a coluna da direita é a volta que a paga. Ordem de fila: a do Astra, exceto onde uma volta já em curso paga um item mais abaixo de graça. "Resolvido" é o critério da terceira coluna dele, provado na tela, não a volta mesclada.

| # | prioridade do Astra | resolvido quando | volta que paga |
|---|---|---|---|
| 1 | Completar uma jornada real, começando pelo espanhol: intenção, ajuda, tentativa, resultado e ajuste | o dono usa o Traço para avançar numa situação concreta e continua a partir do que aconteceu | **V17** (o artefato que se reescreve em Markdown) mais a jornada real de ponta a ponta com o caso do espanhol; depende do 2 e do 3 para a IA servir |
| 2 | Avaliar a IA nos provedores disponíveis, incluindo Grok, com pedidos reais e restrições explícitas | sabemos quais operações funcionam, onde falham e em que condições, com respostas completas examinadas | **volta Q** — a sonda `AvaliacaoIA` nas dezesseis operações com Grok (conta confirmada por `ContaGrok.ligada` no simulador de teste), lida contra `QUALIDADE-IA.md`; a tabela `Politica` (ADR 07b) ajustada pelo resultado |
| 3 | Corrigir as falhas de IA que impedem essa jornada: contexto, instruções, modelo, tratamento da resposta | a ajuda atende ao pedido, respeita as restrições e produz algo utilizável em tentativas variadas | **volta Q-B**, nascida do que a Q medir; Astra no G0 |
| 4 | Melhorar a continuidade do trabalho: retomar objetivo, versões, decisões e próximo passo sem reconstruir o contexto | o dono volta depois e continua com pouca explicação | **volta de retomada do Trabalho** — a folha abre no ponto certo com o resumo do que houve (ADR 06b §18-D já descreve a estrutura que falta) |
| 5 | Trazer o resultado da ação de volta ao trabalho, inclusive tentativas parciais e fracassos | o resultado informado muda a próxima orientação; agendado, feito e funcionou continuam distintos | **volta dos estados** — `EstadoAcao` ganha o observado, `cancelada` deixa de ser inalcançável, o relato muda a próxima orientação (a auditoria de 07/09 achou os três estados mortos em `Trabalho.swift:39-44`) |
| 6 | Tornar a revisão pela IA útil: identificar o que não serviu e revisar o artefato preservando origem e versões | uma correção do dono gera mudança pertinente sem apagar conteúdo nem repetir o erro | paga pela **V17** (a versão N+1 nasce da observação, com origem e motivo no documento) e pela **Q** (revisar medida com Grok) |
| 7 | Reduzir o esforço da jornada principal: navegação, controles ambíguos, excesso de decisões, recuperação de erros | iniciar, agir, corrigir e retomar sem entender a estrutura interna do app | **V12-B, V13, V15** com `curva-zero` medida em toques antes e depois |
| 8 | Verificar os riscos de estabilidade e dados, incluindo o `try!` do arranque | falhas previsíveis permitem recuperação e preservam o conteúdo | **volta do arranque honesto** — `TracoApp.swift:13` e os outros cinco `try!` de produção; a radiografia de 02/09 (tag `arquivo/fix-furos-radiografia`) já tratava disso e serve de leitura |
| 9 | Testar o percurso integrado com IA real, além dos testes isolados | provas atuais do percurso completo, com resposta ruim, interrupção e nova tentativa | **Q** mais um fluxo maestro do percurso com a sonda ligada; `prova/7.md` |
| 10 | Fazer o desenvolvimento de capacidades se apoiar em evidências: distinguir uso, satisfação e desempenho | o Traço ajusta a ajuda por uma dificuldade demonstrada e permite corrigir as hipóteses sobre o dono | **L2** (latência da descoberta, em curso) e a prática dentro da V17 |
| 11 | Fechar a dívida visual e de acessibilidade nas telas alteradas | hierarquia, animações, tamanho de texto, VoiceOver e controles funcionam na jornada real | **a dívida da limpeza de 07/09** (P1 já mesclada, V12-B e L2 em curso, V19 e F4 restantes) |
| 12 | Comprovar as entradas externas no aparelho: Siri, widgets, ditado | cada entrada inicia ou retoma a ação esperada, com contexto certo e falhas compreensíveis | **F5** (em curso) mais uma passada no iPhone do dono, porque o simulador não prova Siri nem tela bloqueada trancada |

### G0 da V17 — o artefato que se reescreve, em Markdown (decidido em 08/09, depois do conselho do Astra)

**Ciclo:** os dois, e é por isso que ela é a próxima. Multiplicar (o autor avança numa situação concreta) e melhorar (a versão seguinte ataca o que ele errou).
**Intenção que serve:** o autor pratica no artefato, erra, e o artefato **se reescreve para atacar aquilo** — guardando as versões, a origem e o motivo de cada mudança.
**Obstáculo que reduz:** o laço que falta é de **observação e versão, não de renderização** (DIRETRIZ §4). O Trabalho já tem versão com origem (05i, 05s), a tentativa do autor como evidência separada (05r), ida e volta pelo arquivo com conflito e retry (05l, 06a) e, desde a ADR 08a, a preparação já lê tentativas anteriores. **O que não existe é a causa do ajuste como dado vinculante**: hoje `pedidoDe` a INFERE por base e intenção, e inferência não pode ser a autoridade que explica ao autor por que o exercício dele mudou.
**Evidência que prova:** no caso concreto do espanhol — uma tentativa com erro gera atividade **diferente e pertinente**, preserva as restrições e **deixa a próxima resposta em branco**; uma correção do dono remove a interpretação equivocada do ajuste seguinte; fechar e reabrir conserva N, tentativa, causa e N+1, inclusive depois de falha de gravação, retry, conflito ou revogação.

**A decisão, minha, sobre o parecer do Astra (`ferramentas/orca/consulta-v17-markdown.md`) — aceito, e é a versão curta:**
1. **Dono único: o Trabalho.** O exercício é `DocumentoTrabalho.Artefato.pratica`; o bloco do Caderno (`BlocoCaderno.recipiente`) é **representação e porta de interação**, não um segundo agregado. A N+1 nasce pela rota que já existe (`OficinaTrabalho.gerar` → `MotorTrabalho.produzir` → `DocumentoTrabalho.receber`). **Nada de versões, corpus ou índice paralelos, e nenhuma tela nova.**
2. **Contrato mínimo, e só ele:** `Pedido.ajuste?` (gatilho **fechado**: `pedidoDoAutor` ou `necessidadePercebida`, mais motivo e referência à evidência que o sustenta) e `Artefato.pedidoID?` (o vínculo direto da versão à causa, no lugar da inferência). Ausência nos registros antigos significa **vínculo não registrado** — não se reconstrói causalidade histórica.
3. **Nenhum `EstadoExercicio` persistido.** Produzido vem da versão guardada; tentativa registrada vem da evidência do autor; desempenho demonstrado exige leitura sustentada com avaliador visível. **Sem `aprendido`, sem pontuação global, sem contador de domínio, sem promoção automática de hipótese.** "Reescrito" não é "aprendido".
4. **A causa não cabe no trecho descartável.** Hoje o histórico pode ser omitido por orçamento; a evidência causal, os critérios e as restrições vigentes são **núcleo obrigatório** — se não couber, **o ajuste fica indisponível** e diz isso.
5. **A fronteira da IA, no tipo e não no prompt:** a saída da adaptação aceita preparação e descrição da mudança, e **não tem campo de resposta nem comando que altere `Evidencia`**; `guardarTentativa` continua operação do autor; o campo de tentativa nasce vazio. Reconhecido e escrito: validação estrutural **não prova ausência de solução disfarçada no enunciado** — isso é leitura semântica, e a 05r já admite o limite.
6. **O ato visível é "Conferir e adaptar o exercício"**, novo e explícito, porque "Conferir minha tentativa" já promete uma operação e uma chamada por toque (05r). Conferência inconclusiva, ausência de resposta ou reabrir o documento **não disparam reescrita**; a mesma conferência não gera duas versões; nada em segundo plano, e o documento não troca enquanto a pessoa digita.
7. **O anúncio é uma seção só, no próprio documento**, escrita pelo app com os vínculos que ele conhece (o modelo não inventa ID nem decide qual pedido o produziu), dizendo o que mudou e por quê, sem repetir o histórico e sem declarar que a pessoa aprendeu.

**O que esta volta NÃO fecha, e eu prefiro dizer agora:** o item 1 da fila do dono só se resolve quando **o dono efetivamente usa e continua a situação real** — a demonstração técnica não o fecha. A V17 entrega o mecanismo e a jornada provada; o item 1 fecha no uso.

### G0 da RETOMADA DO TRABALHO — item 4 da fila do dono (escrito em 08/09, à espera de vaga)

**Ciclo:** multiplicar a mente. O autor volta ao Trabalho depois de um dia e
continua **sem reconstruir o contexto**.
**Critério de resolvido (do Astra, palavra dele):** *"o dono volta depois e
continua com pouca explicação"*.

**Intenção que serve:** retomar objetivo, versões, decisões e próximo passo.

**Obstáculo, nomeado no código e a conferir na tela viva antes de codar (a
auditoria é datada — metade dos defeitos já caiu):** existe uma
`TrabalhoView.retomada(_:)` (`Traco/Trabalho/TrabalhoView.swift:197`), e ela
entrega **duas** coisas: "Continuar: <ato pendente>" e "Último retorno ·
<atribuição>" com três linhas e um atalho para o histórico. O que ela **não**
entrega é o resto do critério do dono:

1. **A folha não abre no ponto certo.** `retomada` é o segundo bloco de uma
   pilha de quinze (`intencao`, `retomada`, `apoio`, `producao`, `praticar`,
   artefato, intercâmbio, `atos`, `retorno`, `dificuldade`, `historico`,
   `rodape`) — ela **oferece** rolagem (`rolarPara`), mas a abertura é sempre no
   topo. Quem volta cai na intenção, não no ponto onde parou.
2. **Não há resumo do que houve entre as duas visitas.** Versão N produzida,
   decisão tomada (o apoio marcado, o trecho delimitado no Combinar), ato
   agendado, resultado observado — nada disso é dito junto. Depois da **E1** o
   `ResultadoObservado` existe como eixo próprio e é candidato natural a entrar
   nesse resumo.
3. **"Último retorno" é a última evidência, não o que mudou.** Se o autor
   guardou a própria versão e não houve evidência nova, a retomada fala de algo
   antigo — ou não fala nada.

**Evidência que prova (a régua desta volta):** **curva-zero medida em toques**,
com o mesmo gesto nos dois builds, na jornada "voltei depois de um dia e
continuo de onde parei" — com estado plantado (há receita:
`plantar-trabalho-no-store`, o JSON no `ZTRABALHO` do App Group). Antes e
depois no **mesmo aparelho**, com captura e árvore de AX do mesmo instante. E o
teste que fica vermelho se a retomada voltar a apontar para o lugar errado.

**Fronteiras:** nada de tela nova e nada de agregado novo — é a folha do
Trabalho que já existe. Nada de `EstadoExercicio` persistido (decisão da V17,
item 3). Nada de resumo escrito pela IA: quem sabe o que mudou é o app, que tem
os vínculos; modelo não inventa o que a pessoa fez.

## Trilha própria: Mac (permanente; brief em papeis/trilha-mac.md; casos em ferramentas/grokbot/CASOS.md)

Ordem do dono de 08/09 à noite: os ONZE casos de uso do Traço no Mac pelo Grok Bot, todos. Sempre uma volta desta trilha em edição, dentro do teto de três.

| # | volta | casos | estado |
|---|---|---|---|
| MAC-1 | ler tudo e escrever com origem: `traco_agenda`, `traco_decisoes`, `traco_escrever` com origem/fontes, `agenda.md`, etiqueta de origem na nota | 1, 2 (leitura), 3, 8, 9, 11 | abre agora |
| MAC-2 | a porta de volta do Trabalho: `trabalhos/<id>.md`, `trabalhos/entrada/`, `traco_trabalho_escrever`, `traco_tentativa`, `traco_relatar` | 2 (escrita), 4, 5, 6 | depois da MAC-1; Astra no G0 |
| MAC-3 | web e briefing com citação obrigatória | 7, 10 | depois da Q mesclar |

## Próximas, em ordem

| # | volta | valor | esforço | ciclo | lacuna (EVOLUCAO) |
|---|---|---|---|---|---|
| 1 | V9 Auditoria de front-end: nota base por tela | MESCLADA (ferramentas/orca/auditoria-frontend.md) — médias: Página 6,7 · Notas 7,0 · Calendário 7,2 · Recordar 6,2 · Perfil 7,7 · Trabalho 6,0 · Padrões 7,5 · Camadas 7,5 | — | multiplicar | "Direção visual e uso simples" |
| 2 | V10 Fundação de design: tokens, Traco/Componentes com previews, biblioteca de movimento | MESCLADA (ADR 05v). Regra vigente: cada volta por tela é líquido-negativa ao migrar para Componentes | — | multiplicar + eixo 4 | idem |
| 3 | V11 Ambiente Markdown: conflitos e retry na UI real, revogação com seletor aberto | MESCLADA (ADR 06a; G3, G4, correções e re-portões) | M | multiplicar | "Ambiente Markdown compartilhado" |
| 4 | V12 Telas até 9: Página e Caderno (a porta de entrada) — EM EDIÇÃO; inclui: cartão da forma cobre régua/ações e em AX esconde ações (V9 alto); indicador de rolagem do cartão em AX (G4 V8); .primario/.compacto com opacidade no press (ADR 02h) e célula nova com mola de classe errada (G4 V10); crossfade de aba com quadro cinza; 'pular'/aba do arquivo estreitos; Camadas anima antes do binding (re-G3 V7); migrar Página/Caderno para Componentes líquido-negativo | alto | M | multiplicar | nota base 6,7 |
| 5 | V13 Telas até 9: Notas e barra de baixo | MESCLADA em 08/09 (ADR 2026-09-08t; G3 reprovou por prova que faltava, não por defeito; V13-B anexou a árvore de AX em AX5 e os vídeos da seta, e o re-G3 passou) | M | multiplicar | nota base da V9 |
| 6 | V14 Calendário: duração explícita e estados de navegação/acessibilidade | médio | M | multiplicar | "Calendário ligado à realização" |
| 7 | V15 Telas até 9: Calendário e ficha | médio | M | multiplicar | nota base da V9 |
| 8 | V16 Métodos com proveniência: fonte, adaptação, evidência; método ausente dito na tela | MESCLADA (ADR 05x; G3, G4, V16-C, re-G4) | M | melhorar | "Métodos e pesquisa com proveniência" |
| 9 | V17 O artefato que se reescreve, em Markdown (decisão do dono 07/09; HTML fica como faixa estreita, sem volta aberta) — G0 na seção própria abaixo | alto | M | melhorar + multiplicar | "Artefato que se transforma" (era "HTML útil e interativo") |
| 10 | V18 Telas até 9: Trabalho | MESCLADA (ADR 06b; G3, re-G3, G4, re-G4 — a curva-zero caiu de 6 toques para 5, medida à mão por dois revisores) | EM EDIÇÃO (worktree volta-18-trabalho) — subiu ao topo pela ordem do dono de 06/09: telas abaixo de 9 primeiro, Trabalho (6,0) na frente | M | multiplicar | nota base da V9 (Trabalho 6,0); Simplicidade |
| 11 | V19 Retrato/Trajetória recebem a prática (só se V6 provar prática real) | médio | M | melhorar | "Modelo revisável do autor" |
| 12 | V20 Domínios amplos: segundo caso real (criação ou organização) | alto, depende do dono | G | ambos | "Domínios amplos de realização" |

## Linha G0 das três primeiras

**V9 — Auditoria de front-end.** Ciclo: multiplicar (realizar com uso simples). Intenção: o autor escreve, acha e marca sem pensar na ferramenta. Obstáculo: não existe nota por tela; a última auditoria (ADR 05f) foi por captura do dono, não por scorecard. Evidência: ferramentas/orca/auditoria-frontend.md com, para cada tela (Página+Caderno, Notas+barra, Calendário+ficha, Recordar, Perfil, Trabalho, Padrões), capturas simctl nos estados do G2, nota 0-10 nas dimensões Design, Simplicidade, Movimento, Componentes, Acessibilidade, Estado honesto, com o defeito nomeado e a lei (design-router fase auditar; curva-zero). Escopo: nenhum arquivo de código; só relatório e capturas. Sem código, G1 é n/a; G3 confere a fidelidade das capturas e a calibragem das notas.

**V10 — Fundação de design.** Ciclo: multiplicar + eixo 4. Intenção: toda tela nasce dos mesmos tokens, componentes e movimentos. Obstáculo: Tema.swift tem tokens parciais, componentes repetidos por tela (cápsulas, chips, linhas de estado, disclosures), animações com curvas e durações soltas e reduce motion tratado em 10 arquivos. Evidência: Traco/Componentes/*.swift com preview por estado (normal, vazio, carregando, falha, desabilitado, AX5), Tema.swift com tokens nomeados (cor, tipo, espaço, raio, sombra, duração, curva), `Tema.movimento` que devolve o movimento certo sob reduce motion, e pelo menos três telas migradas sem mudança visual (captura antes = depois); suíte verde; shortstat com linhas líquidas ≤ 0. Escopo: Tema.swift, Traco/Componentes (novo), e as três telas migradas; duas frentes disjuntas (tokens+movimento em Tema / componentes+previews). Sistema: SISTEMA-CLARO.md.

**V11 — Ambiente Markdown: conflitos e retry.** Ciclo: multiplicar. Intenção: o autor edita o Trabalho fora do Traço e volta sem perder nada, mesmo quando as duas pontas mudaram. Obstáculo: ADR 05l provou o retorno feliz; conflito (base antiga com nova versão local), retry após recusa de commit e revogação da origem com o seletor/exportador aberto não têm prova na UI. Evidência: prévia de conflito com as duas versões e escolha explícita (nova versão, nunca sobrescrita), retry que confirma a mesma versão sem duplicar, seletor aberto + selar a origem → material recolhido com linha honesta; testes + capturas dos estados + fluxo maestro em simulador de teste. Escopo: Traco/Trabalho/{IntercambioTrabalho,IntercambioTrabalhoView}.swift e testes; depende da V6 mesclada.
