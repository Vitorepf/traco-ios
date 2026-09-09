# Laço de evolução contínua — registro

Uma linha por volta: data · volta · o que mudou · evidência · commit · cotas (Claude semanal / Fable semanal / Codex semanal).

- 2026-09-05 · checkpoint · WIP do dono congelado antes do laço · — · 9ad639e · 8% / 14% / 62%
- 2026-09-05 · V1 a sábia preserva o que precisa ler · Sabia.swift: montagem com orçamento (pergunta/alvo/memória nunca cortados; retrato e candidatas saem primeiro), transporte recusa em vez de truncar, `conferir` cala sobre evidência cortada em qualquer caminho, `parseVoltaram` estrito; ADR 05m; EVOLUCAO · 17 focados verdes (SabiaOrcamentoTests), suíte integral 565/0 no sim de teste (revisor Fable); revisão: 0 P1, 2 P2 corrigidos (P2.1 código, P2.2 nomeado na ADR), 5 P3 abertos (montagens de instigar/contrapor/recordar/ecos sem teste, cabeçalhos vazios no aparelho); qualidade semântica do modelo sem prova · b9efef3 · 10% / 15% / 63%
  - Processo: implementado pelo Codex antes da ordem do dono de aposentá-lo como implementador; correção P2.1 pelo Opus. Dois workers no mesmo checkout: o build de um quebrou no meio da edição do outro (OficinaTrabalho) e o worker da V2 desligou o simulador de teste da V1 para rodar maestro, matando duas rodadas da suíte — regra reforçada: nunca desligar simulador alheio.
- 2026-09-05 · V2 a ação do Trabalho avisa · Acao.avisoMinutos, seletor em cápsula na folha, promessa em hora real, estado lido do centro ao abrir, Revisoes.agendarAcao/cancelarAcoes (namespace acao-<id>), Sessao cala ao selar/queimar/apagar a origem, toque na notificação abre o Trabalho; ADR 05n; EVOLUCAO · suíte 576/0, fluxo maestro/trabalho-acao-aviso.yaml, capturas antes/depois/reaberta (ferramentas/orca/v2-*.png); revisão Fable: 1 P1 + 2 P2 corrigidos pelo Opus, P3s feitos; limite: "sem permissão" na folha reaberta não encenável no simulador · 39f00cc · 12% / 15% / 63%
- 2026-09-05 · V3 o método volta com a nota · Gesto.doNome aceita id gravado com cara de id, corpus leva metodo:, import prefere id, bloco de campos pelo marcador; sábia no aparelho por seções inteiras, rótulo "não a reescreva" no local, ecos ≥ 2 candidatas; ADR 05o; EVOLUCAO · suíte 578/0, 10 testes novos; revisão Fable: 0 P1, 2 P2 (reescrita do espelho nomeada na ADR; cerca no id corrigida pelo Opus), P3 import id>nome corrigido · 6de6b2a · 12% / 15% / 63%
  - Processo: colisão de V1/V2 no checkout compartilhado levou o dono a exigir worktree por volta e com-trava.sh (V4 em diante). Consulta única do Astra para a V4 gravada em ferramentas/orca/consulta-v4-conferencia.md.
- 2026-09-05 · V4 a conferência do artefato delegado (fatia 1) · Artefato.conferencias aditivo; critérios extraídos do pedido com trecho literal (idioma explícito, distribuição de tempo, léxico único dígitos/extenso); NLLanguageRecognizer por trecho de prosa; conferência num 2º commit após a versão e sob demanda ("Conferir de novo"); linha expansível em TrabalhoView e no histórico que nunca aprova; acesso revalidado; export/import sem conferência; ADR 05p; EVOLUCAO; prova/4.md com caso real (Apple Intelligence no aparelho) lido contra o pedido: pegou o tempo, deixou passar a ausência de traduções — "qualidade ainda insuficiente" se confirma · suíte 602/0, jornada real na tela capturada pelo revisor (ferramentas/orca/v4-*.png), maestro de regressão da folha OK; revisão Fable: 0 P1, 1 P2 corrigido pelo Opus (leitor de tempo só dígitos), P3s parciais; consulta única do Astra guiou o contrato · 5b685ea (ff em main) · 14% / 15% / 65%
  - Processo: primeira volta em worktree próprio (volta-4-conferencia) com com-trava.sh; o worktree nasceu em 2ca50c5 (base antiga) e precisou de fast-forward para main antes de editar — conferir a base de todo worktree novo. Fora para a V5: "Conferir com IA" (segunda passada sob demanda), destinatário/semântica, versão sem conferência é silêncio, label do disclosure centralizada.
- 2026-09-05 · V5 o laço fecha: Conferir com IA e Pedir ajuste · Sabia.chamarComProveniencia; RevisaoTrabalho (sessão nova, JSON estrito, citações literais, teto 05m sem corte, proveniência efetiva gravada); "Pedir ajuste" preenche o pedido com as divergências e a origem; "não feita · Conferir"; linha nunca favorável sem critério confirmado; pedidoDe exige origem IA; DECISÃO (b): "Conferir com IA" só com conta Grok, sem ela uma linha diz por quê; ADR 05q; EVOLUCAO; prova/5.md com DOIS casos reais negativos (modelo de bordo: limite 3.977>3.500 e, quando cabe, JSON inválido/citações não literais — nada utilizável) · suíte 622/0, jornada real na tela pelo revisor (ferramentas/orca/v5-*.png, v5-caso-real.json), maestro de regressão OK; revisão Fable: 0 P1, 2 P2 corrigidos pelo Opus; as linhas pós-correção não foram vistas na tela (V6 toca a mesma view e o revisor dela confere) · 0fcdf16 (merge em main) · 16% / 15% / 66%
  - Incidente: o fluxo maestro de regressão tem clearState e apagou o estado do app no iPhone 17 do dono — regra nova para revisores: fluxo com clearState só em simulador de teste; se o do dono é o único booted, não rodar e dizer. Descoberta: worker-start aceita --base-branch main (evita o worktree nascer em base antiga). Pedido do dono: --display-name "<Modelo> · <papel> V<n>" em todo worker.
- 2026-09-05 · V7 integridade e selo nas rotas restantes · Sessao: 6 violações de "commit precede anúncio" corrigidas (salvar, trancarESair, trancarExpressivasVencidas, apagar/desfazerApagar, importarCorpus, restaurar) + relógio parado só depois do commit; relógio lógico (Geracao) em Corpus/Indice/Holofote contra escrita atrasada; matriz selo × projeção completa; linha fixa de recusa que sobrevive ao toast; Perfil diz espelho/iCloud indisponível; ADR 05s; EVOLUCAO 7 e 16 · 20 testes novos (IntegridadeRotasTests), suíte 642/0, maestro busca/caderno-gravar/aba-arquivo/auditoria-nav/expressiva-trancar OK, recusa encenada com store só-leitura (v7-rev-*.png); G3 Fable: Privacidade 8 → correções → re-G3 tudo ≥ 9 · 3168f6d (merge em main) · 25% / 15% / 66% · 3 voltas em paralelo (V6, V7, V8) + trilha F1
  - Achado pré-existente em main registrado pelo re-G3: Camadas.swift anima a camada Notas antes de o binding pegar (v7-reg3-continuar-camada.png) — vai ao RUMO. Instrumento: cada worker com o próprio simulador de teste (17 Pro, 17 Pro Max, 17e, Air) funcionou; o do dono só para jornada real, um por vez.
- 2026-09-05 · F1 (trilha Fora do app) auditoria · inventário completo (2 widgets × 4 famílias, 2 Live Activities, 12 intents, 10 atalhos, 5 rotas traco://, Spotlight, 8 famílias de aviso) com 24 capturas reais no iPhone Air (início claro/escuro/AXL, bloqueada, Ilha compacta/expandida, Spotlight, Atalhos, estados vazios e fim das atividades) e nota base por superfície; defeitos: D1 App Shortcuts não executam no simulador (defeito do INSTRUMENTO: build adhoc sem team-identifier; produto não provado), D2 Spotlight sem destino do toque, D3 Dynamic Type ignorado nos widgets, D4 widget promete sino com avisos desligados, D6 widget serve compromisso apagado, D7 flip timer/relativo, Live Activity stale não encerra; não capturável no simulador: accessory na bloqueada, StandBy, Ilha mínima, Siri por voz, banner; conselho do Astra gravado (consulta-fora-intents.md); G3 Fable: 6 correções de texto aplicadas · 37f7a66 (merge em main) · 26% / 15% / 66% · 3 voltas em paralelo (V6, V8, F1)
- 2026-09-05 · V8 acessibilidade real · lei única de movimento em Tema (animacao/transicao/fadeReduzido/corte) aplicada a Camadas, barra, Página, Caderno, Notas, Rede, Calendário, Recordar; View.alvo() (frame+contentShape) em 38 pontos → alvos 44 pt medidos; chips dia/semana lidos uma vez, ano agrupado por mês; cartão da forma em AX com ações no pé; anúncios VoiceOver (forma vestida, sábia); ações de rotor no calendário; ax5.yaml com Calendário e Perfil; ADR 05t; EVOLUCAO 15 · suíte 645/0; ax5.yaml PASSA em AX5 e large; hierarquias maestro em 8 telas; diff de pixels 0 em tamanho normal; vídeos com Reduce Motion; G3 (Acess. 6 → correções) → re-G3 tudo ≥ 9 → rebase sobre main → G4 (Movimento 8: arquivo piscava em RM → corte seco) → re-G4 PASSA (Movimento 9, Design 9, Simplicidade 10, Acess. 9) · f9bd1a7 (ff em main) · 34% / 15% / 66% · 4 frentes em paralelo (V6, V8, V9, F2)
  - Ao RUMO: indicador de rolagem do cartão em AX; quadro acinzentado do crossfade de aba (pré-existente); Confirmação/Padrões/Trabalho sem contentShape; constantes órfãs; 'pular' e aba do arquivo estreitos; abrir pela borda cobre a tela em um quadro (pré-existente, verificar no aparelho). Processo: primeiro G4 da esteira; rebase de docs (SPEC/EVOLUCAO) exigido por voltas paralelas que apendam ADRs — regra: cada volta anexa a sua ADR no fim e o rebase mantém as duas.
- 2026-09-05 · V9 auditoria de front-end (sem código) · 8 telas, 93 capturas nos estados G2 e 6 vídeos no iPhone Air; nota base por tela (média 7,0; melhor Perfil 7,7; piores Trabalho 6,0 e Recordar 6,2; dimensões mais fracas: Componentes 6,2 e Acessibilidade 6,4); 5 defeitos altos com lei (prosa "7 de setembro" cria compromisso — parser sem nome de mês, ADR 02i; ficha e Trabalho prometem "Toca…" com avisos não autorizados, ADR 04a; cartão da forma cobre régua/ações e em AX esconde ações; Recordar cruza dois textos na troca de fase, §21; Trabalho fora do sistema visual), 10 médios, 8 baixos; inventário de 10 componentes repetidos e 16 durações/4 molas soltas; escopo da V10 · G3 Fable: fidelidade das 89 capturas confirmada, 3 amostras reproduzidas, 2 células recalibradas, 6 edições de texto; commits esmagados em um (82 MB → 26 MB) · e56326b (merge em main) · 34% / 15% / 66% · 4 frentes em paralelo (V6, V8, V9, F2)
- 2026-09-05 21:41 → 2026-09-06 02:52 · PAUSA · a janela de sessão do Claude chegou a 100% às 21:41 (reset 22:50) com o re-G3 da V6 e o G3 da F2 em curso; os dois revisores pararam no meio ("You've hit your session limit") sem worker_done; o orquestrador estava em espera desde 21:50. Retomada às 02:52 de 06/09 pelo dono: janela nova (2%), Fable semanal 15%, Codex 66%; os dois revisores retomados no mesmo terminal com o contexto intacto. Nada foi perdido: branches volta-6-pratica (ad99974) e fora-2-fundacao (4abe09c) intactos, main em 7c8a2e4.
- 2026-09-06 · V6 a prática dentro do Trabalho · Artefato.pratica, Evidencia.tentativa (origem pessoa, apoio obrigatório, nunca versão), Hipotese com autoria/data/motivo, PraticaTrabalho.swift (montagem, parser estrito, geração guiada tipada no aparelho), preparação e feedback pela IA só com conta Grok (decisão b), preparação recusada nunca cai na produção delegada, seção Praticar lida de cima para baixo, dificuldade e tentativas também em delegar; ADR 05r; EVOLUCAO 14 ("prática textual e feedback contextual NÃO demonstrados": o modelo de bordo produz formato mas não conteúdo útil — prova/6.md) · suíte 688/0; G3 (P1 fallback, P2s) → correções → re-G3 tudo ≥ 9 (P2-H em delegar) → rebase → G4 (Design 8: 3 linhas de tela) → correção conferida por captura ·  (ff em main) · 46% / 15% / 66% (sessão 51%) · 3 frentes (V6, V10, F2)
- 2026-09-06 · F2 (trilha Fora do app) fundação · Traco/App/Intents/ (catálogo, entidades com selo, TracoAtalhos; Compartilhado/ nos dois alvos), snapshot público versionado no App Group (revisão/geradoEm/validoAte, atômico, só o app escreve, reload só dos kinds afetados, "desatualizado"/"indisponível"/vazio ditos), DestaqueFeito/LembrarDepois com identidade do item e confirmação real, reconciliação e stale, tipografia por Tema nos widgets (D3), fim do reload por minuto (D6), SuperficieDisco isolada nos testes; causa real do A1: chronod recusava reload por NFD×NFC no executável → PRODUCT_NAME "Traco" (bundle id e nome exibido inalterados); ADR 05u; EVOLUCAO linha "Fora do app" · suíte 665/0, dois alvos sem aviso; re-G3 provou no simulador que instalar por cima PRESERVA notas e compromissos (f2-reg3-02..05); gate gate_d56d8eb56bb1 ao dono fica aberto para ele confirmar no iPhone antes de instalar ·  (merge em main; pbxproj regenerado) · 46% / 15% / 66% (sessão 51%) · 3 frentes
  - Peso: PNGs de V6 e F2 reduzidos a 1000 px antes do commit (F2 chegou com 69 MB). D1 (App Shortcuts) segue n/c por instrumento (build de simulador sem team-identifier).
- 2026-09-06 · V10 fundação de design (2 Fables) · A: Tema com Duracao/Mola/Raio/Sombra nomeados, Tema.movimento por classe sob Reduzir Movimento (deslocamento → fade/corte, escala nada, opacidade mantém, laço para), 16 durações e 4 molas migradas em 14 views, CalendarioTema cita Tema; B: Traco/Componentes (Pilula, ChipDominio, Rotulo, LinhaDeEstado, LinhaQueAbre, Cartao, Botao 3 estilos, CabecalhoDeFolha, Vazio) com 27 previews, Notas + ficha do Calendário + Recordar migradas sem mudar pixel; C: código morto fora, frases corrigidas; D: queima como opacidade; ADR 05v (com a decisão: +570 líquidas são custo declarado da fundação; cada volta por tela tem de ser líquido-negativa); EVOLUCAO 15 e design-router · suíte 713/0; diffs de pixel 0 (caret/anti-aliasing onde houve); maestro busca/recordar/calendário OK; G3 (Contrato 8, Componentes 8, Complexidade 7 → correções) → re-G3 tudo ≥ 9 → G4 (Movimento 8 por um item que o vídeo desmentiu: sob RM a queima nem começa) → PASSA · 5b97818 (ff em main) · 50% / 15% / 66% (sessão 75%) · 3 frentes (V10, V16, F3)
  - Dívida nomeada (RUMO): Pilula de seis para duas formas (V13/V15); Componentes citam CalendarioTema 14× (V15); .primario/.compacto com opacidade no press contra ADR 02h e célula nova com mola de classe errada (V12); Toast e LinhaQueAbre.abaixo voltam quando tiverem tela (V12/V15); 24 rótulos, 4 estilos por tela, 3 toasts e 4 vazios ainda fora de Componentes.
- 2026-09-06 · F3 (trilha Fora do app) captar pensamento em um toque · controle "Anotar" (ControlWidget) para Central de Controle, tela bloqueada e botão de Ação, executando CapturarIntent compartilhado com rota tipada .captura(ditado:) consumida uma vez quando a cena está pronta (arranque frio provado por log com PID novo); o app abre na Página em branco com teclado pronto e o microfone a um toque (o iOS não dispara ditado por API — "já em ditado" foi corrigido na ADR); AnotarIntent confirma só após depósito; sem AppShortcut novo (limite de 10 do iOS); ADR 05w; EVOLUCAO "Fora do app" · suíte 715/0, dois alvos sem aviso; G3 Fable: tudo ≥ 9 menos Correção por um teste da F2 (sonecaRecusada dependia da permissão do simulador → injetada); G4 não se aplica (controle é do sistema, toast existente) · d15ffd1 (ff em main) · 53% / 15% / 66% (sessão 90%) · 3 frentes (V12, V16, F3)
  - Ditado próprio (áudio salvo antes de transcrever) vira F3b. Tela bloqueada trancada não renderiza controles no simulador: prova no aparelho do dono.
- 2026-09-06 05:40 → 12:48 · QUEDA E RETOMADA · a cota SEMANAL do Fable 5.1 bateu 100% às 5:40 (reset 20:00) e derrubou no meio os dois workers vivos — o front-end da V12 (evidências do G2 em curso) e o juiz do G4 da V16 (nove capturas feitas, vídeo e veredito faltando) — e depois o próprio orquestrador Fable. Nada foi perdido: os dois terminais seguiram vivos com o contexto inteiro e voltaram com `/model opus`; volta-12-pagina tinha 11 arquivos modificados (+190/-212, líquido-negativo) e volta-16-metodos estava em ab5c052 com as capturas g4-v16-*. Retomada às 12:48 por orquestrador Opus 5; o vigia (launchd app.traco.vigia, ferramentas/orca/vigia.sh) sobe outro se este cair. CORREÇÃO DE LEITURA DE COTA: `orca account list --json` não mente — são TRÊS campos e todos importam, `rateLimits.claude.session` (1%), `.weekly` (55%) e `.fableWeekly` (100%, o que bate com o rodapé do Orca e a tela do Claude). Ordem do dono: todo worker em Opus 5 até as 20:00, nenhum `--model fable`, e rodar até acabar o pote semanal de todos os modelos. Frentes reabertas: V12 (front-end), V16 (G4), V11 (ambiente Markdown) e F3b (ditado próprio) · — · 55% / 100% Fable / 71% Codex · 4 frentes
- 2026-09-06 14:10 · DECISÕES DO ORQUESTRADOR (DIRETRIZ §6: reversível e em git decide-se sozinho) · (1) V11 (ambiente Markdown) continuou aberta quando o dono priorizou as telas abaixo de 9, em vez de ser trocada pela V18: já tinha worker rodando, é disjunta de tudo e a tese da continuidade entre ferramentas vale mais do que o worktree custou; a V18 Trabalho entrou como frente a mais, não no lugar dela. (2) F4 (widgets) abriu como volta nova da trilha em vez de sequestrar a F3b, que já tinha meia hora de contexto no ditado — duas voltas da trilha em paralelo, com fronteira escrita entre elas (F3b não toca TracoWidget nem a política de timeline). (3) O conserto do roteamento do Se–então (regex sem `\b`) foi para a M3, a volta que abre o Metodos.json de qualquer jeito, em vez de entrar na V16-C, que o G4 já tinha julgado: um assunto por volta. (4) A colagem dos métodos novos vai no FIM do catálogo, e isso é decisão de proteção e não de gosto — a M1 mediu que colar antes da Especificação faz a Coluna da esquerda roubar o desabafo da Expressiva. (5) Perguntei ao dono o gosto sobre os quatro métodos antes de a DIRETRIZ §6 chegar; ele aprovou os quatro. Daqui em diante gosto de catálogo também é meu, e o registro é este arquivo · — · 57% / 100% Fable / 71% Codex · 7 frentes
- 2026-09-06 · V16 métodos com proveniência · fonte, função, adaptação, evidência e aplicabilidade nos 21 métodos do catálogo (campos aditivos); "De onde vem" na Lente da nota e na folha Métodos do Perfil, com um componente só (LinhasDeProveniencia, 3 previews) e sem um selo sequer — rótulo e valor no mesmo peso, zero cor, e a evidência que se delimita a si mesma ("não há estudo do uso dentro do Traço"); método que saiu da pasta é dito em tinta neutra, estado e não erro; ADR 05x; EVOLUCAO · G3 Fable INTEGRAR (21/21 fontes conferidas uma a uma, 3 reparos de texto, suíte 712 com 1 falha alheia da F2); ajustes do G3 (lista compacta no Perfil, tinta neutra, LinhasDeProveniencia em Componentes) fizeram a lista do Perfil crescer 7 pt em doze métodos contra o main, não os ~920 pt temidos; G4 CORRIGIR ANTES por Movimento 8 — a mesma "de onde vem" abria em 267 ms na Lente e em 33 ms no Perfil, corte seco, com 414 pt saltando no meio de 21 linhas; V16-C escolheu ANIMAR em vez de mudar a ADR e descobriu medindo que withAnimation não atravessa a fronteira de apresentação do .sheet (a lei entra por .animation(_:value:) na folha, dito na ADR); re-G4 PASSA com Movimento 9 medido no vídeo do juiz: 233 ms para abrir, 267 para fechar, 200/133 sob Reduzir Movimento, e a seta girando em nove quadros · 968ba34 (merge em main; conflito da SPEC resolvido mantendo 05w e 05x em ordem cronológica, build limpo depois) · 59% / 100% Fable / 71% Codex · 7 frentes
  - Dívida ao RUMO (do juiz): o app fica com dois mecanismos para uma lei só de movimento — a LinhaQueAbre da V12 fecha isso; em AX5 a linha do método quebra a origem no meio da palavra e o cabeçalho encosta "Métodos" em "Pronto"; o Perfil continua com a Simplicidade 6 da V9 (o cartão CONTA gasta a primeira tela); na Lente, com a proveniência aberta, Apontar sai da primeira tela; a bibliografia dos 21 vive só no Metodos.json.
- 2026-09-06 · F3b (trilha Fora do app) ditado próprio: o áudio antes da letra · o controle Anotar abre GRAVANDO (Rota.ditar, canal próprio que a Página ignora); o AVAudioRecorder escreve o m4a direto no destino final do anexo; a nota entra no disco SEM UMA LETRA e só então o SFSpeechURLRecognitionRequest com requiresOnDeviceRecognition é pedido; falha, silêncio ou app morto deixam a nota com o áudio TOCÁVEL dentro dela pelo marcador que o Caderno já renderiza — zero campo novo no modelo, zero código de renderização novo; FolhaDeConfirmacao + Folha viraram uma casca só para o ditado e a ConfirmacaoView (−55 linhas de duplicata); ADR 2026-09-06c; EVOLUCAO "Fora do app" · suíte 727/126, dois alvos e Release sem aviso, instrumento de ensaio provado AUSENTE do Release com controle positivo no dylib de debug; G3 CORRIGIR ANTES com três altos — a tela dizia "Sem microfone." quando o disco recusava (e o teste `discoRecusa` FIXAVA a mentira), dois ditados sobrepostos deixavam uma nota órfã dizendo "sem transcrição" para sempre, e a ADR colidia de número com a F4 — os três fechados na causa (estado `.semDeposito` que oferece redepositar o mesmo arquivo; `Sessao.notaDoDitado` deixou de ser variável única e cada ditado carrega a sua nota); re-G3 APROVADO com as 15 dimensões em 9 ou mais · 628bf8d (merge em main; conflito da SPEC resolvido mantendo 05x e 06c) · 65% / 100% Fable / 71% Codex · 8 frentes
  - Achado de instrumento que virou lei na ESTEIRA: `maestro --device` NÃO isola — o driver residente de outro simulador segura a porta 7001 e o maestro lê a hierarquia do vizinho (provado às 16h54: o maestro jurava que "Gravando." não estava na tela enquanto o simctl do UDID certo mostrava). Com mais de um simulador ligado, evidência de maestro não sustenta nota. E a máquina, com seis a sete simuladores, derruba simulador sozinha por pressão de memória: o iPhone 17 do dono caiu assim, sem ninguém tocar nele.
- 2026-09-06 · A1 a A4, a voz do app e a proteção da escrita pessoal · A1: o `avisoWood` afirmava o que o estudo NÃO mediu — "Afirmação sem prova não gruda" é sentença sobre o mundo, e Wood, Perunovic e Lee (2009) mediram HUMOR depois de repetir uma frase dada, não fixação; texto novo diz o que a fonte sustenta, com proveniência no formato da 05x; A2: o `AppEnum` dos Atalhos oferecia NOVE formas de 21 a quem usa a Siri e nada falhava para avisar → `FormaEntity`/`FormaQuery` de `Catalogo.todos`, com o custo do catálogo inteiro no `@Generable` medido em +3,3% (dentro do ruído); a enum de dez da análise de bordo estava MORTA desde a ADR 04l e foi apagada — código morto descrevendo contrato falso enganou três leitores independentes, o orquestrador incluído; A3: a proteção da escrita pessoal estava furada em duas metades (o teto de 120 caracteres e a falta de vocabulário nos desabafos longos e factuais) e, pior, PERDIA PARA O MODELO — a guarda devolvia `.silencio`, que tem precedência zero em `Sessao.escolher`, então com Grok ou Apple Intelligence ligados a proteção era NULA exatamente no caso que ela existe para impedir; agora a escrita pessoal tem uma porta só, a Expressiva, independente da posição no catálogo, e a regra ganhou a quarta linha: escrita pessoal reconhecida pelo algoritmo CALA o modelo; A4: três frases em que o app afirmava o que não observou; ADRs 06f, 06g e 06h; EVOLUCAO · suíte 747/128, 0 avisos em Release, Debug e teste; o `TRACO_MODELO_FALSO` da prova não vaza para Release (0 ocorrências contra 1 no dylib de debug, com controle positivo); G3 CORRIGIR ANTES com quatro altos, todos medidos pelo revisor com frases inventadas por ele; re-G3 MESCLAR · 33e3ed3 (merge em main) · 67% / 100% Fable / 71% Codex · 8 frentes
  - Regressão nomeada e já em conserto (A5): a família 1 do léxico ficou larga demais — contém "vazio", "sozinho", "cansado", "pesa", "ansioso" e "medo" —, e de dez notas comuns de trabalho NOVE mudam de destino, OITO em regressão limpa. O caso que dói: "Quero correr de manhã, mas o medo de me machucar me trava" deixou de receber WOOP, num app cujo campo do WOOP se chama "obstáculo interno (o seu hábito/medo)". Faltava a régua inversa — havia 57 frases provando que desabafo não vira método e nenhuma provando que nota comum continua achando a forma. O revisor mandou mesclar assim mesmo, e eu concordei: segurar o branch mantinha o buraco do modelo aberto em main, e silêncio numa nota custa um toque enquanto vestir um desabafo carimba quatro campos.
- 2026-09-06 · V11 o ambiente Markdown quando as duas pontas mudaram · conflito, retry e revogação da origem provados na UI real, e não só no caminho feliz da ADR 05l; o contrato duro se sustenta — conflito NUNCA sobrescreve, a escolha sempre gera versão nova (`aplicarVersaoExterna` só faz append); `jaGuardado` virou a regra única que a mutação e a tela consultam; `RecusaDoCommit` separa disco de base divergente; selar a origem com o seletor aberto recolhe o material e a tela DIZ o que recolheu, por fiação reativa real; ADR 2026-09-06a; EVOLUCAO · suíte 722/125, build sem aviso em recompilação integral, fluxo maestro rodando sozinho em duas partes com o .sh fazendo a edição externa; G3 CORRIGIR ANTES por um CONFLITO INVENTADO (exportar → guardar a intenção → importar o MESMO arquivo faziam a tela afirmar "o trabalho mudou dos dois lados" com os dois cartões mostrando a mesma versão, e qualquer escolha caía em `.semNovidade`) e por um "Tentar guardar de novo" que nunca poderia dar certo; re-G3 aprovado; G4 CORRIGIR ANTES pelo achado que derrubou a premissa de todos nós — os dois cartões mostravam a MESMA cadeia de caracteres porque a truncagem mostrava o COMEÇO e a edição de ida-e-volta acontece no FIM, e não era só em AX5, reaparecia no corpo normal com documento longo; agora a comparação ancora na primeira divergência (`recorteDaDiferenca`, contexto 48 no corpo normal e 12 em AX5, calibragem provada fora do SwiftUI); re-G4 PASSA com Design, Simplicidade, Movimento e Componentes em 9, e o toque na ação bloqueada medido em 211 vezes mais pixels que antes · e95a687 (merge em main) · 72% (janela semanal virou às 20:00) / 100% Fable / 71% Codex · 8 frentes
  - Dívida ao RUMO: memoizar o `recorteDaDiferenca`, que é O(n) e roda duas vezes por body (28,9 ms a 100 KB, 608 ms no teto de 2 MiB); o `min(16, contexto)`, segunda constante que não saiu da conta do 48/12; o recado que não é zerado por atos não relacionados; e a inversão do `.compacto` (secundária com 17,0:1 contra 6,36:1 da primária).
- 2026-09-06 · A5 a guarda da escrita pessoal para de calar a nota comum · a ADR 06h fechou o buraco grave com uma família de léxico larga demais — continha "medo", e "Quero correr de manhã, mas o medo de me machucar me trava" deixou de receber WOOP, num app cujo campo do WOOP se chama "obstáculo interno (o seu hábito/medo)"; a família virou duas (sentimento de uma vida só dispara sozinho; palavra de dupla vida só decide com companhia — o autor no meio, densidade, ou a omissão ao lado) e nasceram DUAS réguas que faltavam: a INVERSA (58 frases de trabalho, no mínimo duas por porta do catálogo, provando que nota comum continua achando a forma) e a do DESABAFO COM GANCHO (dez, uma por gancho de roteamento) — o cruzamento que nenhuma das duas exercitava e o caso mais comum na vida real; ADR 2026-09-06i; EVOLUCAO · suíte 752/128; CINCO passadas do revisor, cada uma com o binário que copia o núcleo da guarda VERBATIM do código: ele achou 18 de 20 desabafos com gancho vestidos depois do primeiro estreitamento, concedeu contra si mesmo duas vezes (retirou o item do "dá medo" e admitiu ter sido generoso em quatro casos), corrigiu-se ao afirmar que a ADR não tinha arbitragem — tem uma, e é o braço do infinitivo, agora declarada com a tabela das três saídas —, e **baixou Estado honesto de 9 para 8 de propósito** porque a frase "a classe está fechada" ia entrar neste registro: virou "a classe foi VARRIDA, 62 alternativas uma a uma, medida contra os candidatos que soubemos nomear", com a família do adjetivo sem cópula nomeada como resíduo. A classe da borda de palavra apareceu OITO vezes (senti, vazi[oa], ando dentro de gerúndio, bate em combate, tratei mal dentro de contratei/retratei mal, descansado, "pensou o problema", odiado/desculpado/abriguei) · e3cb718 (merge em main) · 2% (janela nova) / 100% Fable / 71% Codex · 7 frentes
  - Processo: dois dos três defeitos da última rodada saíram de sugestões do próprio revisor, implementadas mais largas do que ele havia medido — ele registrou isso e disse que "muda a leitura do relatório". Fechei a volta na condição que ele mesmo escreveu ("última lista, mecânica, nenhuma decisão de projeto"), sem uma quarta passada, e as duas linhas foram medidas por ele antes e depois.
- 2026-09-06 · V18 o Trabalho até 9, a pior tela da auditoria · 6,0 na V9 (Design 5, Simplicidade 5, Componentes 4) → ordem de leitura passa a ser a do ciclo com a Dificuldade fora da frente; a decisão delegar/praticar/combinar sai do disclosure e vira trilho de pílulas no caminho, com o padrão já marcado e empilhado em AX5; a folha entra na família do mundo claro (CabecalhoDeFolha, rótulo de seção, campo em névoa, cartão de papel; AcaoTrabalhoStyle apagado; oito DisclosureGroup em cinco); nenhuma ação bloqueada usa `.disabled()` — continua cápsula, com o motivo ao lado e no hint, e tocar leva ao que falta (contraste 1,53:1 → 13,94:1); `PromessaDoAviso` distingue concedido, não perguntado, negado e hora já passada, e não mente sobre compromisso que repete; ADR 2026-09-06b; EVOLUCAO · **a curva-zero CAIU de 6 toques e 2 digitações para 5 e 2**, medida à mão por dois revisores diferentes, com captura depois de cada toque; suíte 735/127, build sem aviso; G3 CORRIGIR ANTES (a curva-zero não tinha caído e a ADR afirmava que sim; o relógio prometia hora passada; o desabilitado perdia a cápsula a 1,53:1) → re-G3 achou que a folha ENUNCIAVA uma regra que não cumpria (dizia "guarde antes de pedir" e disparava a IA assim mesmo, porque a remoção do `.disabled()` portou só metade do guarda) → re-G3 APROVADO → G4 achou um ESTADO PRESO: depois de guardar a própria versão a folha afirmava para sempre uma edição pendente inexistente, imprimia a versão duas vezes e travava a preparação, **sobrevivendo a fechar, reabrir e reiniciar o aparelho** — a causa tinha duas metades, o predicado julgando por não-vazio e o `TextField` devolvendo o padrão ao binding ao sair da tela (o plist tinha `"versao" => ""`) → re-G4 PASSA com os quatro eixos em 9, e o juiz SEMEOU o rascunho fantasma no plist, matou o cfprefsd e viu a folha nova desfazer o estado · 1007547 (merge em main) · 2% / 100% Fable / 71% Codex · 6 frentes
  - A resposta à pergunta central, que vale mais que a nota: o Trabalho ganhou IDENTIDADE (a frase do autor é o título em 28 pt, a ordem é a do ciclo) e ainda não ganhou ESTRUTURA — "o ciclo nunca se mostra como ciclo, e a forma repetida rótulo/pergunta/campo/botão ainda é a de um formulário bem vestido". A leitura do que precisaria mudar está na ADR 06b §18-D e o juiz a assinou com três emendas; vira a próxima volta do Trabalho.

- 2026-09-07 · DECISÃO DO DONO · o artefato que se transforma nasce em MARKDOWN, não em HTML — depois de uma verificação rigorosa do estado do app (main íntegro: build limpo, 779 testes verdes, cinco abas vivas; zero WebKit; `FormatoArtefato.html` morto; a distância real está nas rotas de IA e nos estados do Trabalho, não na base). O laço que falta é de observação e versão, não de renderização: Caderno, versões com origem, tentativa como evidência, selo, corpus e MCP já cobrem `.md`, e o modelo de bordo produz Markdown com mais confiança do que HTML com script. HTML fica como faixa estreita para protótipo e simulação, sem volta aberta. DIRETRIZ §4 reescrita, V17 do RUMO trocada e com G0, linha do EVOLUCAO renomeada · branch `Vitorepf/volta-17-md-artefato` (só documentos) · —
- 2026-09-07 · POLÍTICA DO PROVEDOR (ordem do dono: "entenda quando usar o Apple Intelligence e quando usar o Grok") · `Traco/Analise/Politica.swift`, a tabela única das 16 operações com regra e prova datada; nove só-Grok pela medição de 07/09, seis Grok-depois-aparelho, uma só-aparelho; a escada da sábia, o conferir, as Notas, o produzir e os Padrões consultam a tabela e a falha do Grok não desce onde o aparelho reprovou; três seções que calavam ganham `LinhaDeEstado`; Perfil lista quem responde o quê; teto medido em tokens; ADR 07b; EVOLUCAO · suíte 826/134; captura do Perfil no 17 Pro de teste · branch `Vitorepf/politica-provedor` sobre `codex/qualidade-ia` (145e73f, o trabalho do Astra commitado) · sem medição com Grok ainda: login iniciado no simulador de teste, à espera do dono

- 2026-09-07 · LIMPEZA GERAL DO GIT, por ordem do dono ("nada de valor se perder; só main local e remota") · as seis voltas a um passo do merge mescladas em main na ordem do LACO (A-6, M3, V12, F4, V19, L1), conflitos de SPEC/EVOLUCAO costurados com os dois lados em ordem cronológica, `RecordarView` fundido à mão (a guarda de reentrada da V19 com a tabela da 07b), projeto regenerado; suíte integral 885/142 na árvore final · o que cada volta ainda devia está no RUMO como dívida nomeada, porque mesclar não é passar no portão · `feat/traco-folha`, `fix/furos-radiografia` e o stash do Cursor viraram tags `arquivo/*` (locais e no origin); o branch do Cursor tinha o mesmo conteúdo que já estava em main e foi apagado · oito worktrees removidos, todos os branches apagados, `origin` só com `main` e as tags · —

## PARADA — 06/09/2026, 23h20, por ordem do dono

O laço parou por ordem, não por cota (semanal em 4%, janela de sessão em 1%) e não por falha. Mandei aos cinco workers vivos a mesma ordem: terminar o passo em curso, commitar no branch do próprio worktree o que estivesse pronto e coerente, não começar fase nova, não mesclar nada em main, desligar o simulador e devolver a trava. **Os cinco pararam limpos**: nenhum simulador ligado, trava do instrumento livre, nenhum worktree com arquivo sujo, nada mesclado em main sem passar pelos portões. O vigia foi desligado pelo dono.

**Mesclado hoje, seis voltas, todas pelos portões completos:** V16 (métodos com proveniência), F3b (ditado próprio), A1-A4 (a voz do app e a proteção da escrita pessoal), V11 (ambiente Markdown), A5 (a guarda para de calar a nota comum) e V18 (Trabalho até 9, com a curva-zero caindo de 6 toques para 5).

### O que ficou em cada worktree, e o que falta para retomar

| worktree | topo | estado | o que falta, na ordem |
|---|---|---|---|
| `volta-12-pagina` | 83f655d | **re-G4 PASSA nos itens 1 e 3** — o papel foi de 33 pt para 141 pt e os 37 caracteres que o juiz digitou às cegas aparecem; a lei de `Tema.movimento` sob Reduzir Movimento passou a CORTAR, e a penalidade absurda acabou (124 ms com RM contra 110 sem; era 370 contra 215) | itens 2 (AX5) e 4 do G4 não julgados; a **SEXTA ocorrência da classe A1**, com causa TERCEIRA (`TrabalhoView.swift:80` faz `withAnimation` sem argumento e a palavra `reduceMotion` não existe no arquivo) — o juiz conclui que **falta um portão que impeça escrever `withAnimation` sem Tema**, não mais um conserto; e o fantasma do `.sheet` (~110 ms sobre o texto do autor, não sobre o fundo como a ADR diz) |
| `volta-19-recordar` | b32629a | **G3 CORRIGIR ANTES**; a 19-B fechou M1, M2, M3, M4, B1, B2, B3 e escreveu as seis fases e a curva-zero; o vão morto caiu (caret de 46,2% para 22,0% da altura) e a frase falsa saiu da ADR | **A1**: o toast nasce sobre a barra de ações e mora em `PaginaView.swift:303` (`padding(.bottom, 88)` chutado) — dono é quem estiver na volta 12; **A3**: `Pilula` não tem estado desabilitado (`Pilula.swift:52` devolve `tintaMorta` #C7C7CC = **1,53:1** sobre o papel, para TODOS os chamadores) — é dívida de Componentes; refotografar AX5 do "escrever" |
| `volta-l1-latencia` | (revisão commitada) | **G3 e re-G3 PASSA** (Privacidade 4→10 com prova aritmética, Estado honesto 6→10); **G4 NÃO PASSA**: Design 8 e Simplicidade 7 | quatro correções de uma linha cada, escritas no relatório: `Tema.miudo` é reservado pela ADR 05u a fora do app e esta volta trouxe os dois únicos usos dentro do app; o cartão ocupa 6 a 7 telas em AX5 dentro de um Perfil que já tinha Simplicidade 6; a lista de meses não tem teto. Depois: modo escuro, MODO B cruzado com AX5, VoiceOver escutado |
| `f4-widgets` | a2f90a0 | **G3 aprovado na 3ª passada; G4 RECUSOU** (maior nota 8, Fora do app 7). A F4-E matou o achado principal na raiz: o instantâneo passou a carregar quantos ficaram FORA da lista, o corte migrou para quem publica, e com cinco no calendário a face imprime "+4 depois" e não "+2" | o Destaque LONGO ainda termina em reticências quando o rodapé "Desatualizado." entra — **e não é a propriedade, é a repartição de altura**; o quadro de ofertas ainda lê como lista de Ajustes; tela bloqueada, StandBy e Ilha não capturados; o médio do Traço mostra uma linha de agenda e não três |
| `volta-a6-familia` | 18b6cc2 | **G3 CORRIGIR ANTES por quatro linhas de DOCUMENTO**, nenhuma em `Traco/Analise` — o conserto está provado (a confissão de 36 caracteres fica nota livre, as quatro réguas não mudaram de lado, os 17 ramos do Exame dão o mesmo resultado nos dois lados do teto) | as quatro linhas: a CAUSA que a ADR conta é falsa (46 das 57 protegidas já eram curtas; o buraco era de contaminação, não de rabo), a régua nova não cobra a exclusividade que a ADR lhe atribui, `olhando o dia de hoje` é porta morta, e faltam dois números |
| `volta-m3-colagem` | 2612244 | **re-G3: o achado ALTO está FECHADO** — 22 de 22 frases de desabafo caladas contra o catálogo de 28, com o controle na tela | duas linhas que o revisor confirma e que cabem no commit de merge: a string `aplicabilidade` do `exameDaNoite` (hoje **promete ao autor exatamente a matéria que a guarda recusa levar ao método**) e dois comentários mortos. **Ordem de mescla: A-6 ANTES da M3** — o defeito da A-6 só existe depois da M3 |
| `metodos-m1` | mesclado | trilha Métodos parada com o trabalho fechado (M1 a M15 em main) | a colagem da leva 3 pelo pacote `metodos/leva-3-e-fusao.md`, quando alguém abrir o `Metodos.json` |

### O que este dia ensinou, e não é sobre código

Três leis de instrumento nasceram medindo, e estão na ESTEIRA: **o `maestro --device` não isola** (o driver do vizinho responde pela porta 7001 — provado por dimensão de pixel e por uma tela que ele jurava não existir); **a trava do instrumento prende** (duas vezes, por motivos diferentes — driver pendurado com processo vivo, e dono morto sem soltar; o `com-trava.sh` agora retoma nos dois casos e escreve o dono dentro dela); e **a galeria de widgets trava** (três revisões perdidas nela, até um juiz plantar pelo `IconState.plist` do SpringBoard). A quarta, do último worker: `simctl ui content_size medium` NÃO aplica, e o `chronod` guarda tipo e tema em cache — capturas inteiras vinham do ambiente velho.

E a lição de método, que vale mais: **a auditoria V9 está parcialmente desatualizada** — três dos quatro defeitos que ela lista para o Recordar já tinham caído, e o quarto estava declarado morto e estava vivo. Auditar antes de tocar passou a significar conferir a auditoria na tela viva e escrever na ADR, defeito a defeito, qual continua vivo.

## PAUSA de 07/09 e RETOMADA de 08/09 — o que aconteceu no meio

**A pausa não foi de cota nem de falha.** O laço ficou parado desde 23h20 de 06/09 por ordem do dono. No dia 07/09 o dono trabalhou fora do laço e deu duas ordens que mudaram o mapa:

- **Limpeza geral do git** (07/09 à noite): só `main` local e remota. As seis voltas que estavam a um passo do merge (A-6 → M3 → V12 → F4 → V19 → L1) foram mescladas NA ORDEM que este registro pedia, **sem o último portão de cada uma**; os oito worktrees e todos os branches foram apagados; `arquivo/feat-traco-folha` e `arquivo/fix-furos-radiografia` ficaram como tag. Suíte integral verde na árvore final (885 em 142). A dívida de cada volta está nomeada na seção "A limpeza de 07/09" do RUMO e é o topo da fila.
- **Duas decisões de rumo:** a política do provedor (ADR 07b, `Traco/Analise/Politica.swift` — quem responde cada operação de IA, medido) e o artefato que se transforma nasce em **Markdown**, não em HTML (DIRETRIZ §4; a V17 ganhou G0 e o HTML virou faixa estreita).

**A retomada foi do vigia, às 10h20 de 08/09**, com a janela de sessão em 9% e — o que o brief não sabia — **a semanal do Fable de volta em 6%** desde o reset de domingo. Ao ler o estado antes de despachar, duas coisas apareceram que nenhum documento registrava:

1. **A conta Grok existe.** Está conectada no simulador `iPhone 17 Pro (teste 2)` `B91C8DEF`, confirmada no Perfil em 08/09. Cai a frase "nenhuma operação tem medição com Grok" da ADR 07b. A base medida está em `prova/cinco-itens.md`, e é dura: com conta, preparar prática 0/3, instigar 0/3 e contrapor 0/3. **Regra nova: esse simulador é proibido a todo worker** — `xcodebuild test` reinstala o app e apaga o contêiner onde a conta mora.
2. **Outra sessão (Codex) trabalha no checkout principal neste momento**, nos "cinco itens": raciocínio explícito nas quatro operações de Trabalho, modelo `grok-4.3` no lugar do alias aposentado, ADR 2026-09-08b escrita em `SPEC.md`, tudo **sem commit**. O orquestrador rodou só o build para saber se `main` serve de base (`** BUILD SUCCEEDED **`, zero avisos), **não comitou nada disso**, e comitou apenas o RUMO por caminho (`a63da33`). Quem fecha esse trabalho é aquela sessão.

**O inbox tinha uma só mensagem viva** — o `worker_done` da F4-E de 07/09, cujo conteúdo já é a dívida da F4 no RUMO — e uma tarefa em `ready` que virou impossível (`task_d32819a85e9c`, o G3 da A-6 e o fecho da M3: os dois worktrees não existem mais e as duas voltas já estão em main). Marcada `failed` com o motivo, não silenciada.

**Três voltas abertas às 10h25**, cada uma em worktree filho nascido de `main`, áreas disjuntas, todas tirando dívida da limpeza — duas comuns mais a trilha fora do app, como o brief manda:

| volta | worktree | dívida que fecha | simulador |
|---|---|---|---|
| P1 | `volta-p1-portao-movimento` | o **portão que impede `withAnimation` fora de `Tema`** (item 7, o achado mais estrutural do dia 06: a classe do cross-fade apareceu 6 vezes com 3 causas; há 39 ocorrências soltas hoje) + as quatro linhas do A-6 + a `aplicabilidade` do exameDaNoite da M3 | teste 4 `A1DF082C` |
| F4-F | `volta-f5-fora-do-app` | o Destaque longo cortado pelo rodapé "Desatualizado.", o quadro de ofertas, tela bloqueada/StandBy/Ilha sem captura, o médio de uma linha | teste 3 `34CC3F94` |
| L2 | `volta-l2-latencia-g4` | o **G4 reprovado** da L1 (Design 8, Simplicidade 7): teto de 12 meses, `Tema.miudo` dentro do app contra a ADR 05u, frase-resumo em duas linhas, `quantas == 1`; mais escuro, B×AX5 e VoiceOver | iPhone 17 Pro `C2416CBC` |

**Lei de instrumento acrescentada nesta rodada:** com três simuladores ligados, `booted` é ambíguo e maestro não vale nada — todo worker recebeu ordem de usar `xcrun simctl io <UDID>` explícito e nenhum maestro. Primeiro achado devolvido, às 10h33, pela F4-F: a causa do corte do Destaque é **`lineLimit` impedindo o `minimumScaleFactor` em tamanho normal** — repartição de altura, como a F4-E suspeitava, agora nomeada.

### 08/09 11h16 — EQUIPE NOVA, por ordem do dono (vale da próxima task em diante)

O dono leu as duas sessões anteriores de orquestração (`ferramentas/orca/ORCA-LICOES.md`, `8e3a1a5`) e trocou o time (briefs em `f22a588`): **o revisor do G3 passa a ser outro fornecedor** — `codex --model gpt-5.6-terra` (quem escreveu foi Claude, quem revisa não é), com o re-G3 no mesmo terminal; **o juiz de design do G4 é Fable 5.1** em sessão própria; **o Astra (`gpt-6-astra`) entra em três momentos e só neles** — G0 de toda volta que toca IA, a SEGUNDA recusa na mesma volta, e arquitetura ou contrato difícil, no máximo duas consultas por volta; **front-end e fora do app voltam a Fable** (Opus só acima de 90% da semanal do Fable); **teto de TRÊS voltas em edição ao mesmo tempo**; **nenhum Grok como agente**. Ordem de fila depois da dívida: **V17** (o artefato que se reescreve em Markdown) e depois **a qualidade da IA pela sonda `AvaliacaoIA` com Grok**, esta só depois de confirmar `ContaGrok.ligada` no simulador de teste.

No mesmo commit o dono fechou o trabalho dos "cinco itens" que estava sem commit no checkout principal (55 arquivos, +4.955), então **`main` está com a árvore limpa** e as voltas voltam a poder mesclar. Um segundo orquestrador subiu por engano às 11h00 e foi fechado — e ele é o suspeito mais provável da instalação por cima que custou 25 min à F4-F, porque quem builda do checkout principal instala o código de `main`.

Estava com **quatro voltas em edição** quando a ordem chegou (P1-B em correção de G3, L2, F4-F, V12-B); não interrompi nenhuma, não abri a quinta, e volto a três no próximo fecho.

### 08/09 12h20 — MESCLADA a volta P1: o portão do movimento

Primeira volta fechada pelos portões completos desde a limpeza de 07/09, e a primeira revisada por **outro fornecedor** (GPT 5.6 Terra), como a equipe nova manda.

- **O que mudou:** `TracoTests/PortaoDoMovimentoTests` varre os 126 fontes de `Traco/` e `TracoWidget/`, apaga comentário, string e o **miolo das chamadas a `Tema.`**, e fica vermelho quando alguém escreve curva ou duração **literal** fora da casa. Mais as três dívidas de documento da limpeza: as quatro linhas da A-6 refeitas com número medido (a causa era contaminação, não rabo; a porta morta `olhando o dia de hoje` apagada, desvios de 18 para 17) e a `aplicabilidade` do `exameDaNoite`, que parou de prometer ao autor a matéria que a guarda recusa levar ao método.
- **O ciclo do portão, que é a lição:** a primeira versão contava como dívida **a forma que a própria ADR manda escrever** — 69 das 76 ocorrências congeladas já citavam `Tema.` — e por isso ficava vermelha até quando alguém migrava uma tela. O G3 recusou; medida a violação certa, **a dívida real é ZERO**: as 38 chamadas de `withAnimation(` já passam todas por `Tema`. Um portão que fica vermelho quando se faz a coisa certa é pior que portão nenhum.
- **Lista vazia é o estado perigoso de um portão**, e o implementador viu isso sozinho: `aVarreduraAindaEnxerga` impede que vazio vire verde falso. O revisor confirmou apontando a varredura para um diretório inexistente — **ficou vermelha**.
- **Evidência:** re-G3 APROVADO, nenhuma dimensão abaixo de 9, com seis ataques ao portão (curva literal, arquivo novo fora do `pbxproj`, forma prescrita, migração para baixo, comentário e string). Árvore **mesclada** provada no iPhone 17e: `894 tests in 144 suites passed`, 0 aviso, e o portão em **zero** contra o código novo que veio de `main` (a única curva em `Traco/Trabalho` é a forma prescrita).
- **Commit:** `29cc2ce`. Cotas no fecho: janela 30%, semanal 14%, Fable 6%, Codex 2%.
- **Duas quebras declaradas, nenhuma escondida:** o implementador e a volta F4-F dirigiram tela por `cliclick` antes de a ordem do dono das 11h35 existir; o re-G3 julgou o que importava — nenhuma evidência ficou contaminada.
- **Limite novo do instrumento, achado pelo primeiro revisor a usar `orca emulator`:** o `ax` perde a árvore de acessibilidade assim que o Traço abre (`ERR_CONNECTION_REFUSED` / `ERR_EMPTY_RESPONSE`); reiniciar o helper recupera a AX da tela inicial e a perde de novo ao abrir o app. Ele não fez a segunda captura e **não apresentou a alheia como sua**.
- **Colisão de letra de ADR, resolvida por reserva:** a sessão dos cinco itens ocupou `08a`–`08d` em `main` e três voltas escreveram por cima. Reserva vigente: **P1 = 08e (mesclada), V12 = 08f, F4-F = 08g, L2 = 08h**.

### 08/09 12h25 — A FILA DO DONO entra, e o Astra deixa de implementar

O dono pediu ao Astra uma leitura de prioridades, pôs o Astra a resolver as cinco primeiras sozinho e **desistiu disso**: o laço do Orca resolve as doze, com mais qualidade por token. A tabela está no RUMO (`7778687`, seção "A fila do dono, 08/09"), com o critério de "resolvido" do Astra em cada linha — e resolvido é **provado na tela**, não a volta mesclada.

**O que muda para mim, em uma linha cada:**
- **Não há sessão do Astra editando o checkout.** O checkout principal está limpo em `7778687`; o único Codex vivo é o revisor GPT 5.6 Terra da F4-F, já usando `orca emulator`. Cai o aviso que eu tinha escrito às 10h25 sobre uma sessão paralela no checkout — ele valia e deixou de valer.
- **Toda volta nasce com a linha G0 E o critério de resolvido do Astra colado no spec.**
- **Ordem de fila:** a do Astra, exceto onde uma volta em curso paga um item mais abaixo de graça. Do que está aberto agora: **L2 paga o item 10** (capacidades apoiadas em evidência), **V12-B e F4-F pagam parte dos itens 7, 11 e 12**.
- **Depois das voltas em curso, nesta ordem:** **V17** (itens 1 e 6 — o artefato que se reescreve em Markdown e a jornada real do espanhol), **Q com Grok** (2, 3 e 9 — a sonda `AvaliacaoIA` nas dezesseis operações; confirmar `ContaGrok.ligada` antes de gastar), **estados da ação** (5 — `EstadoAcao` ganha o observado e `cancelada` deixa de ser inalcançável; os três estados mortos estão em `Trabalho.swift:39-44`), **retomada do Trabalho** (4 — a folha abre no ponto certo, ADR 06b §18-D descreve a estrutura que falta), **arranque honesto** (8 — o `try!` de `TracoApp.swift:13` e os outros cinco).
- **Pré-condição da Q já conferida por mim, para não gastar volta à toa:** `ContaGrok.ligada` existe (`Traco/Analise/ContaGrok.swift:55`, verdadeiro quando há token de renovação ou de acesso guardado) e a sonda `AvaliacaoIA` já registra `contaGrokLigada` em cada medição. A confirmação é leitura barata.

### 08/09 13h55 — MESCLADA a volta L2: a latência da descoberta paga o G4 reprovado

Segunda volta fechada pelos portões completos desde a limpeza, e a primeira que passou por **G3 de outro fornecedor + G4 de juiz próprio**.

- **O que mudou:** as quatro correções do juiz da L1 — teto de doze meses com o horizonte na copy; `Tema.miudo` fora de dentro do app (a ADR 05u o reserva a fora do app, e a L1 tinha trazido os dois únicos usos internos do produto); a frase-resumo em duas linhas **sem perder um número**, feita com duas leituras da mesma `Latencia.emPalavras` para não tocar no modelo; e `quantas == 1` sem chamar de "tempo do meio" o único valor que existe.
- **A lição não é o conserto, é a prova.** As capturas "depois" da primeira passada mostravam **copy anterior à do commit julgado** — o revisor de outro fornecedor pegou lendo o `HEAD` contra a imagem. A volta refez tudo no binário final, com `uninstall` antes de cada `install` e o dylib conferido por string, e os números de modo A e B saíram **idênticos**: *a foto estava errada, o número não*. O de vinte meses mudou porque a semente era outra, não a altura.
- **A compactação foi implementada, medida e recusada**, com capturas lado a lado: recupera 180 dos 341 pt em AX5 e **piora a leitura em `large`**, porque em AX5 a altura mora no parágrafo (833 pt) e no embrulho de cada registro. O G4 confirmou a recusa.
- **Simplicidade 8 é o teto honesto desta tela, e o juiz corrigiu a minha hipótese:** não é a extração dos nove cartões inline (isso não muda um pixel, é dívida de Complexidade) — é uma decisão da **volta do Perfil sobre o que ele mostra por padrão**. Mesclei com a lacuna nomeada: prefiro um 8 defendido por dois modelos independentes a um 9 comprado piorando o tamanho comum.
- **Evidência:** G4 PASSA com Design 9; árvore **mesclada** provada no iPhone 17 Pro: `894 tests in 144 suites`, 0 aviso, e `PortaoDoMovimentoTests` verde contra o diff de `PerfilView` com a lista congelada **vazia**. Capturas do G4 reduzidas de 9,8 MB para 2,8 MB pela política de peso da ESTEIRA.
- **Commit:** `9a711eb`. Cotas no fecho: janela 67%, semanal 22%, Fable 6%, Codex 2%.
- **Fica para a fila:** a copy do horizonte (os "12 últimos" são meses **com** descobertas), o VoiceOver que o juiz não pôde ouvir (ligar exige reiniciar o aparelho, proibido), o transbordo horizontal do Perfil em AX5 (pré-existente, reproduz em HEAD, é de `Camadas`/`RaizView`) e a decisão do que o Perfil mostra por padrão.
- **O incidente do login continua preservado no `C2416CBC`:** as abas do Safari estão intactas e o Perfil segue "sem conta — recursos locais disponíveis" (`ferramentas/orca/l2c-merge-perfil-sem-conta.png`). A revogação do lado da x.ai é do dono.

### 08/09 14h35 — MESCLADA a volta F4-F: a frase do autor, e o corte honesto como lei

Terceira volta fechada pelos portões completos, e a que mais andou: **G3 → F4-G → re-G3 → G4 recusou → conselho → F4-H → re-G4 PASSA → F4-I**. Sete passadas, duas recusas, uma consulta obrigatória.

- **A causa que três passadas anteriores erraram:** não era `minimumScaleFactor`, era o **`lineLimit`** — com teto de linhas a `Text` nunca excede a proposta, o SwiftUI conclui que já cabe e **corta em vez de encolher**. Por isso só aparecia em AX5, e por isso a F4 declarou o defeito fechado olhando o tamanho normal.
- **O G4 recusou a primeira correção com dois fatos medidos**, e eram o certo a medir: com 103 caracteres em AX5 a frase saía **no mesmo corpo de quem não ligou acessibilidade**, e com 247 (porque `VozDoAutor.titulo` não tinha teto) o pequeno desenhava **onze linhas a ~7 pt** e voltava a cortar. O "pior caso real" de 43 caracteres que a ADR declarava não era o que o app publicava.
- **O conselho achou o que ninguém tinha visto:** `reconciliar` usa a **mesma** `projecao` para o `ContentState` da Live Activity — limitar só a escrita do `superficie.json` deixaria Ilha e tela bloqueada com **outro contrato**. O teto de 140 grafemas entra uma vez, antes da distribuição.
- **A lei nova, que vale para toda face:** *reticência é honestidade quando indica continuação realmente omitida por um limite público declarado ou pelo espaço restante depois de retirar o dispensável, preservando leitura no tamanho escolhido e acesso ao original; é falha quando encobre corte evitável, texto ilegível ou promessa de integralidade.* E "evitável" ganhou número, proposto pelo juiz: **cabe uma linha inteira do corpo no espaço ao lado do marcador**.
- **A frase deixou de encolher e passou a ceder QUANTIDADE**, com `Sacrificio` declarando por teste que "Nova nota" cede antes de uma linha e que "Desatualizado." nunca cede. E o toque no pequeno passou a **abrir a nota certa** — provado com nota real e com a **mesma nota selada**, que diz "Essa nota não está disponível." e some da superfície.
- **Evidência:** re-G4 PASSA (Design 9, Simplicidade 9, Movimento 9, Fora do app 9 com lacuna dita); árvore mesclada com **910 testes em 148 suítes**, dois alvos sem aviso, portão do movimento verde.
- **Commit:** `494c0c6`. **Fica para o aparelho real:** StandBy noturno, Ilha mínima, VoiceOver ouvido, e a Ilha compacta com duas atividades em AX5 com o "t" cortado.
- **Duas escolhas de método que valem registro:** o worker **decidiu não mover** os componentes para `Traco/Componentes` porque o alvo do widget não compila o app (ADR 05u) — e disse por quê em vez de mover e quebrar; e, sobre as **duas gramáticas do "…"** (palavra no publicador, grafema na face), escolheu **descrevê-las com honestidade na ADR** em vez de unificar, com o argumento de que unificar seria "reproduzir o motor de texto e errar onde ele acerta".

### 08/09 14h36 — A CONTA GROK EXISTE, e o foco vira a IA

Ordem do dono: **foque na IA**. A volta **Q (qualidade da IA)** abre como frente prioritária ao lado da V17; V12-E e F4-I terminam a passada em curso e só reabrem quando Q e V17 fecharem. O teto de três voltas continua.

**Onde a conta está, e como ela apareceu — porque isto merece ser dito inteiro.** O dono autorizou o dispositivo, e o Perfil do **iPhone 17 Pro de teste `C2416CBC`** mostra "Grok — conectada: o Grok é o motor, pago pela sua assinatura". **É o mesmo aparelho do incidente das 11h21**, quando toques em coordenada fixa, com o layout do Perfil transbordando em AX5, caíram sobre "Entrar com a conta Grok" e abriram o fluxo *device-code* da x.ai várias vezes. Na hora eu tratei aquilo como risco e mandei preservar a evidência sem desfazer nada; o dono olhou e **autorizou**. A evidência preservada (`ferramentas/orca/l2-incidente-grok-perfil-sem-conta.png` e as abas do Safari) é o que permitiu ele decidir com o quadro na mão em vez de adivinhar.

**Correção do meu registro anterior:** eu tinha escrito às 10h25, lendo `prova/cinco-itens.md`, que a conta estava no `teste 2 B91C8DEF`. **A conta que vale agora é a do `C2416CBC`**, e é a única. O `teste 2` e o `teste 3` deixam de ser proibidos (a sessão que os usava foi fechada pelo dono).

**LEI DO SIMULADOR DO GROK, no spec de todo worker daqui em diante:** o `C2416CBC` é o único aparelho com a conta. **Ninguém roda `erase`, `clearState`, `uninstall` ou `xcodebuild test` nele.** Workers de outras voltas usam outros UDIDs. A volta Q **instala por cima** e confere `ContaGrok.ligada` **antes de cada corrida**. Se a conta cair, **o dono tem de reautorizar — diga em vez de contornar**.

### 08/09 16h40 — A V17 pronta e o merge SEGURADO: outra sessão escreve em `main` ao vivo

A volta V17 passou em todos os portões (G3 → V17-B → re-G3 PASSA → G4 PASSA) e a V17-C fechou a parte dela do G5: prova dos portões comitada (capturas de 3,7 MB para 1,8 MB, nenhuma acima do teto do RUMO), `main` trazida em ordem cronológica (21 commits, conflito só de lugar no SPEC) e **árvore mesclada provada: 928 testes em 149 suítes, 0 aviso, portão do movimento com a lista de divergências vazia**.

**Não mesclei, e a razão é a segunda colisão do dia com uma sessão externa.** Às 16h39 o checkout principal estava sujo, escrito naquele minuto: `Traco/Trabalho/ConferenciaTrabalho.swift`, `OficinaTrabalho.swift`, `TrabalhoView.swift`, `TracoTests/ConferenciaTrabalhoTests.swift` e `prova/cinco-itens-grok46-validacao.jsonl` — pelo nome, a continuação dos cinco itens. **`OficinaTrabalho.swift` e `TrabalhoView.swift` são exatamente os arquivos que a V17 reescreveu.**

Não toquei em nada — nem `stash`, nem commit, nem reset —, como na primeira vez, de manhã. Perguntei ao dono e a volta espera no branch, sem risco de perder nada.

**A lição, que já é padrão e vai para a ESTEIRA quando eu tiver a resposta:** worktree isola a EDIÇÃO, não o MERGE. Uma sessão que trabalha direto no checkout principal bloqueia o G5 de qualquer volta que toque os mesmos arquivos, e o orquestrador não pode resolver isso sozinho sem passar por cima de trabalho vivo. Da primeira vez (10h25) o dono comitou e destravou; desta vez ele decide de novo.

### 08/09 17h10 — MESCLADA a volta V17, e `main` volta a ter dono no origin

**A árvore suja era WIP parado, não escrita ao vivo.** Eu tinha lido os cinco arquivos como sessão viva porque a hora de modificação era do minuto anterior; o dono conferiu e mostrou que a thread do Astra no app do Codex não escrevia desde 11h14 e que os arquivos não mudavam desde 16h39:32. O conteúdo ficou inteiro no branch `wip/cinco-itens-grok46-16h39` (`d26310e`) e os cinco arquivos voltaram ao estado de `main`. **Segurar o merge foi certo; o que eu errei foi a leitura da causa** — mtime recente não prova sessão ativa, e eu deveria ter comparado duas leituras separadas por alguns minutos antes de chamar de "escrita ao vivo".

**V17 mesclada em `67974dc`.** O laço que faltava era de observação e versão, não de renderização: a causa do ajuste virou dado vinculante (`Pedido.ajuste` com gatilho fechado e `Artefato.pedidoID`), no lugar de uma inferência que não podia ser a autoridade que explica ao autor por que o exercício dele mudou. Nenhum estado de exercício persistido, a causa como núcleo obrigatório, a fronteira da IA no tipo, e o anúncio escrito pelo app sem dizer que a pessoa aprendeu. G3 reprovou duas garantias que viviam só na UI; a V17-B moveu as duas para invariante do agregado. G4 PASSA. Árvore mesclada: **928 testes em 149 suítes**, 0 aviso.

**E `main` foi para o `origin`**: estava **35 commits atrás** porque ninguém deu push no dia inteiro. Ordem nova do dono, em vigor: **todo fecho termina com `git push origin main`**.

**Lacuna declarada da V17, que não se esconde:** a jornada com provedor real é da frente Q; o item 1 da fila do dono só fecha quando ele **usar e continuar** a situação real.

### 08/09 18h10 — o estado das três voltas vivas, e o que a tarde ensinou

Nada mesclado desde a V17 (`67974dc`); as três voltas estão em ciclo de portão, e é onde elas devem estar. `main` limpa e sincronizada com o `origin` a cada fecho, como o dono ordenou às 17h05.

**Q — a qualidade da IA, medida com a conta ligada.** 297 execuções de rota, 96 casos, três lançamentos. **Das dezesseis operações, só três atenderam 6 de 6**: `conferir`, `padroes` e `conferirTentativa`. **Sete saíram da execução** pela regra nova `indisponivelPorQualidade`, em dois grupos — sem substituto medido (ecos, calibragem, recordar, instigar, contrapor) e com conserto nomeado (`responder`, `responderNasNotas`). A terceira linha do Perfil diz isso ao autor em linguagem de gente, sem número e sem caminho de prova, e **nunca manda conectar conta que já existe**. A Q-B corrigiu o candidato (`acdfcb4`, provado por símbolo no dylib), reconciliou 20 contra 12 nos quatro documentos, e **subiu o teto de 90 s para 240 s** com prova: 30 chamadas, zero falhas de transporte, contra 20 de 72 antes.

**A lição da Q, que vale mais que a tabela:** três casos mediram uma **rota sem chamador de produção** — a "atribuição genérica do provedor" era um título que o **nosso app** fabricava. E a Q-B achou o irmão disso: **3 de 15 preparações são recusadas pelo NOSSO parser**, com HTTP 200 e conteúdo completo do outro lado. Duas vezes seguidas, o que parecia defeito do provedor era nosso.

**V12 — a escrita visível.** O conselho ditou a invariante (*a linha ativa e o caret pertencem à área livre do papel, em todo quadro*), a V12-E a pôs **no contêiner** e achou a causa raiz que cinco passadas erraram: o `.safeAreaInset` deixava o papel correr sob o encaixe. **Duas refilmagens independentes** fecharam o A1 e o A2 — zero quadros com par legível, caret 343/295/431/313 pt acima do encaixe contra **zero pixels em 11 amostras** antes. Falta o pé em AX5 acima do teclado.

**E1 — o resultado da ação.** `ResultadoObservado` virou eixo próprio, `cancelada` ganhou gesto, e a orientação seguinte muda pelo relato **reusando o mecanismo da V17** em vez de um segundo paralelo. O G3 achou o de sempre: **a invariante olhava um eixo e o mundo tem dois** — dava para cancelar o que a pessoa já disse que aconteceu.

**O padrão do dia, agora com seis casos:** o quadro longo que era o `fotografar()` do teste; o `ax --device` lendo o aparelho vizinho; a rota sem chamador; o teste que passava sem visitar o defeito; a `String` que não vira `Bool` no plantio de estado; e o `test-without-building` que troca o contêiner. **Em todos, o instrumento dizia mais do que mostrava.** Está na ESTEIRA como lei: o teste declara o estado que exige como **pré-condição que falha**, e todo portão nasce com a prova do vermelho.

### 08/09 18h45 — MESCLADA a volta V12: o autor não escreve às cegas

Quinta volta do dia, e a mais teimosa: **cinco passadas seguidas com a mesma classe de defeito e causas diferentes** — o cartão cobrindo a régua, o `withAnimation` sem `Tema`, o encaixe sem alinhamento, a caixa opaca sem ocupante, e o caret por baixo do encaixe. À segunda recusa o conselho entrou e ditou a lei que faltava: **a linha ativa e o caret pertencem à área livre do papel, em cada quadro apresentado, e nenhuma outra superfície desenha ali — no CONTÊINER**, não num tipo novo que um ancestral possa ignorar.

- **A causa raiz que cinco passadas erraram:** o `.safeAreaInset` deixava o papel **correr sob o encaixe**. O `CadernoView` virou pilha de irmãos sem pixel em comum; `seguirCaret` rola até a linha ativa; `abrirCampos` tira cartão, pé e régua **por corte, antes de a folha subir**.
- **A prova, e ela é dupla:** caret em **343/295/431/313 pt acima do encaixe** contra **zero pixels em 11 amostras** antes; **zero quadros com par legível** em 69 e depois em 222, refilmados por **dois juízes independentes**; o pé em AX5 terminando a 630,0 pt contra o teclado em 638. O par que resta é a **`UIMenu` do sistema** (~65 ms), declarado como limite.
- **O portão que quase mentiu:** o teste hospedado passou verde **sem visitar o defeito** — aceitava o estado sem cartão. Virou **pré-condição que falha com motivo**, e a prova do vermelho está colada. Foi o quarto de **seis** instrumentos que neste dia disseram mais do que mostravam.
- **A ADR 08f mentiu duas vezes** — "nenhum par legível" e "a folha cobre a tela nos dois instantes" — e as duas frases foram trocadas pelo medido, a segunda achada pelo juiz no último portão. **ADR é contrato, não narrativa.**
- **Commit:** `e58b0ee`, empurrado para o `origin`. Árvore mesclada: **933 testes em 152 suítes**, 0 aviso, portão do movimento verde. Evidência dos portões comitada e reduzida com honestidade: 58 PNG de 34,5 MB para 10,3 MB, 8 vídeos de 15,8 MB para 0,6 MB **com a contagem de quadros conferida igual por `ffprobe`**.
- **Fica para o RUMO:** os 15 pt que o cartão recolhido perde no aparelho de 874 pt (custo dito, não escondido) e o oráculo de pixels, que o conselho já dimensionou como volta própria.

### 08/09 19h15 — MESCLADA a volta E1: agendado, feito e funcionou são três coisas

Sexta volta do dia, e a primeira do item 5 da fila do dono. A auditoria de 07/09 tinha achado os três `EstadoAcao` **mortos**: não havia como dizer que uma ação foi **observada**, `cancelada` era inalcançável, e o relato não mudava a orientação seguinte.

- **`ResultadoObservado` virou eixo próprio**, no relato, com `nil` = **não observado** inclusive em registro antigo — nenhum registro velho vira "deu certo" por releitura. **Executar é ato, observar é resultado**, e um existe sem o outro.
- **Fracasso e parcial são de primeira classe:** as três cápsulas têm o mesmo peso na tela, e **parcial e fracasso geram orientações diferentes** — o juiz confirmou, senão o eixo seria decorativo.
- **A orientação muda reusando o mecanismo da V17** (ADR 08j), com o gatilho `resultadoInformado`, sem inventar um segundo — e dizendo o que **não** serviu.
- **O G3 achou a doença do dia:** a invariante olhava **um** eixo e o mundo tem **dois** — dava para cancelar o que a pessoa já tinha dito que aconteceu. Conserto no **modelo**: `podeCancelar` exige pendente **e** sem observação, `registrarRelato` recusa a ordem inversa, e `validar()` recusa o par para fechar importação, migração e chamador novo. **Com contraprova na mesma captura:** ação pendente e não observada continua com o gesto.
- **E o G4 pegou o que faria a promessa funcionar por acaso:** a orientação seguia o último relato **sem nomear a ação** — com três ações e três resultados, mandava "propor caminho diferente" num Trabalho cuja ação principal funcionou. A contraprova são **três pedidos gravados no mesmo documento**: dois sem a ação, o terceiro com ela.
- **Commit:** `7691e45`, no `origin`. Árvore mesclada: **947 testes em 153 suítes**, 0 aviso, portão verde. Evidência reduzida: 4.576 KB → 2.372 KB e 1.493 KB → 840 KB, maior arquivo 187 KB.
- **Aberto de propósito e dito:** `causaDoRelato` ainda diz "desta ação" sem nomeá-la, porque ali o motivo **disputa o teto** com o relato inteiro — é decisão de orçamento, não uma linha.

### 08/09 19h35 — duas perguntas do dono, respondidas com o estado da máquina

**(1) VoiceOver.** Conferi os sete simuladores: **está desligado em todos**, e o macOS também. Um só tem a chave escrita — o `6033B043`, com valor **0**. Quem a tocou foi o worker da A1, e **por ordem minha**: eu tinha mandado "ouvir o VoiceOver" na tela do arranque falho. **Revoguei a ordem**: ninguém liga VoiceOver, Speak Screen ou síntese de voz na máquina do dono; a acessibilidade daquela tela passa a ser provada **pela árvore de AX conferida contra captura do mesmo UDID**, com o VoiceOver falado declarado como **limite** — o mesmo tipo de limite que o juiz da L2 declarou hoje.

**(2) Sete simuladores ligados, e a lei diz um por worker.** Mapeei dono a dono e **desliguei os três sem dono vivo**: `A1DF082C` (teste 4), `C7341E64` (17e) e `64F7B8B4` (Air) — as voltas que os usavam (E1 e P1) já mesclaram e os worktrees foram removidos. Sobraram **quatro, um por frente viva**: `C2416CBC` (volta Q, **e ninguém o desliga**), `B91C8DEF` (V13), `34CC3F94` (Q, build e teste) e `6033B043` (A1-B). Abaixo do teto de cinco em que o macOS começa a derrubar sozinho.

**O que eu levo disto:** o teto de simuladores não é regra de higiene, é a mesma família dos achados do dia — aparelho ligado sem dono é estado que ninguém conferiu, e foi assim que o `ax --device` passou a ler a árvore do vizinho.

### 08/09 19h25 — a voz era a Siri DENTRO do simulador, e a lei nova

O dono achou o que eu não tinha achado: **não era VoiceOver, era a síntese de voz da Siri dentro dos simuladores**, saindo pelas caixas do Mac — `sirittsd`/`SiriAUSP`/`MacinTalk` vivos no **teste 4** desde as 18h03 e no **teste 2** desde as 19h22. Ele matou os processos para silenciar.

**Quem foi:** no teste 4, a volta **E1-B**, que rodou ali por volta das 18h e já mesclou (worker morto, e eu desliguei o aparelho às 19h30 por não ter dono vivo). No teste 2, a volta **V13**, viva — avisada na hora, com ordem de dizer no relato o que acionou e a que horas, **não para se justificar, mas para a lei nascer do caso real**, como nasceram a do `cliclick` e a do `booted`.

**Lei nova, no preâmbulo de todo spec e na ESTEIRA:** nenhum worker aciona Siri, ditado por voz ou síntese de fala em simulador enquanto o dono está na máquina — inclui `orca emulator button siri`, Speak Screen e ditado do teclado. E a razão que a torna fácil de aceitar: **prova de Siri é no iPhone do dono, com ele**; no simulador ela não é evidência, então acioná-la não produz prova, só barulho na sala de quem trabalha.

**A conta do dia sobe para nove leis de instrumento**, e esta é a segunda em que o incômodo do dono na própria máquina é o sintoma — a primeira foi o mouse disputado às 11h35.

### 08/09 19h35 — O MAC DO DONO ESTAVA FALANDO. Os quatro itens, feitos

Ordem com o dono furioso, e com razão: ele já proibiu **comando por voz, VoiceOver e iPad** inúmeras vezes. Ele matou os processos de fala e desligou o teste 2 e o teste 4.

**(1) Avisados os SEIS terminais vivos** — as três voltas (Q, A1, V13) e os terminais de apoio de cada uma —, com a ordem de **parar a passada e reportar** quem estivesse acionando voz.
**(2) Quem acionou, com nome de volta:** no **teste 2 `B91C8DEF`, às 19h22, foi a V13** (viva, avisada na hora); no **teste 4 `A1DF082C`, às 18h03, foi a E1-B** — volta já mesclada, worker morto, aparelho que eu havia desligado às 19h30 por não ter dono vivo. A cadeia que levou a isso é minha: **eu mandei "ouvir o VoiceOver"** no spec da A1, e a chave `VoiceOverTouchEnabled` só aparece escrita no aparelho dela. Ordem revogada por mim antes de o dono cobrar, mas o estrago já estava feito.
**(3) A proibição está EM LETRAS GRANDES** no preâmbulo de todo spec e no topo da seção de instrumento da ESTEIRA: voz, VoiceOver e iPad proibidos; prova de Siri só no iPhone do dono, com ele; acessibilidade por árvore e captura, nunca com VoiceOver ligado.
**(4) Um simulador por worker:** ficaram **dois booted** — `C2416CBC` (volta Q, o da conta, que ninguém desliga) e `6033B043` (A1-B). Desliguei o `34CC3F94`; o teste 2 e o teste 4 o dono já tinha desligado, e o 17e e o Air eu havia desligado antes. De sete, sobraram dois.

**A lição, e ela é minha:** duas das nove leis de instrumento do dia nasceram do **incômodo do dono na própria máquina** — o mouse disputado às 11h35 e a voz agora. Nenhuma das duas apareceu em teste, log ou revisão: apareceram porque **uma pessoa estava sentada ali**. Quando o laço roda na máquina de alguém, o corpo dessa pessoa é parte do instrumento, e eu não estava medindo isso.

### 08/09 19h45 — NÃO BASTOU: a fala voltou, e a cadeia era minha

Depois do meu aviso das 19h35, **a V13 religou o teste 2 e a fala voltou às 19h4x**; e havia síntese rodando também no Pro Max, na volta **A1-B — cujo próprio nome de terminal carregava a palavra que eu tinha mandado** no spec. O dono interrompeu as duas voltas pelo terminal, desligou o teste 2 de novo, forçou a chave de leitura de tela para `false` nos dois aparelhos e matou a fala. Ele disse, com estas palavras, que **a próxima voz encerra o laço**.

**A cadeia inteira sai do meu texto.** Eu escrevi "ouça a leitura de tela" no spec da A1; o worker obedeceu; o Mac do dono passou a falar. Não foi iniciativa de worker, foi ordem minha mal pensada — e eu a repeti no spec da A1-B mesmo depois de já ter revogado a ideia, porque reaproveitei o texto anterior sem reler o item.

**O que fiz, e é o que vale como conserto:**
1. **O spec da A1 foi REESCRITO** (A1-C) sem a palavra proibida em lugar nenhum: a acessibilidade da tela do arranque se prova **pela árvore de acessibilidade conferida contra captura do mesmo instante**, e o falado é **limite declarado, não tarefa**. O terminal foi renomeado.
2. **A V13 está em PARADA CONDICIONAL:** só continua se o worker confirmar por escrito que não aciona voz e não religa o aparelho sem avisar, e disser o que acionou às 19h22 e às 19h4x. Se houver nova fala, **paro a volta e recomeço com outro worker**.
3. **O esperador do laço passou a caçar fala antes de qualquer outra coisa:** todo ciclo de espera roda `pgrep -f 'sirittsd|SiriAUSP|MacinTalk|speechsynthesisd'` e, se achar, **mata os processos e recusa a esperar**, obrigando-me a parar o worker dono do simulador **antes** de acusar qualquer batimento. A verificação virou parte do laço, não lembrança minha.
4. **Dois simuladores ligados**, um por worker vivo com dono nomeado.

**A lição, e ela é sobre mim:** eu escrevi nove leis de instrumento hoje lendo o que os workers mediram, e **duas nasceram do corpo do dono** — o mouse disputado e a voz. Nas duas, o sintoma chegou pela pessoa e não pelo log; e nesta segunda **a causa fui eu**. Reaproveitar spec sem reler cada item é a mesma família do "verde que não visitou o lugar do defeito": texto que parece cumprido porque já esteve certo alguma vez.

### 08/09 20h00 — o caçador de fala casava com ele mesmo

O verificador que eu instalei às 19h45 para rodar em toda espera usava `pgrep -f`, que casa com a **linha de comando inteira** — e a linha de comando dele **contém os nomes que ele procura**. Resultado: ele acusava fala viva olhando para si mesmo, e um `ps aux | grep` no mesmo instante mostrava **zero** processos de síntese. Quase parei um worker por causa disso.

Corrigido: o caçador passou a olhar o **nome do executável** (`comm`), nunca a linha de comando, e a lista ficou restrita ao que o dono nomeou por **ouvir** — `sirittsd`, `SiriAUSP`, `MacinTalk`, `speechsynthesisd`. Tirei `assistantd` e `siriactionsd`, que são daemons de sistema do macOS, sempre vivos e **não são fala**: mantê-los na lista faria o caçador acusar silêncio como barulho para sempre.

**É o sétimo instrumento do dia que diz mais do que mostra** — e o primeiro que eu mesmo escrevi. A régua que eu cobrei a tarde inteira dos workers (*todo portão nasce com a prova do vermelho, e o teste precisa visitar o lugar do defeito*) eu não apliquei ao meu próprio verificador: instalei sem nunca tê-lo visto **acusar de verdade** nem **ficar quieto de verdade**. Agora os dois estados estão vistos.

### 08/09 20h20 — a hipótese da voz CAIU, e a causa continua desconhecida

Eu tinha proposto que os processos de fala subiam porque **a sábia responde pelo Apple Intelligence do aparelho**, que no iOS 26 roda sobre a infraestrutura da Siri. A V13 testou no 17e, do jeito que pedi — `ps` antes, 1 s depois, 10 s depois e ao fim de uma pergunta pelo caminho do aparelho: **zero processos de fala, sempre**. **A hipótese caiu.**

E a mesma volta confirmou, comando a comando, que **nunca usou Siri, `button`, ditado, leitura de tela nem `say`** — só `attach/ax/tap/type/gesture` e `simctl` —, e que o plist de acessibilidade do teste 2 não tinha nada ligado.

**Então a causa da voz continua desconhecida**, e é assim que fica registrado. O que resta em pé são as defesas, que não dependem de saber a causa: a proibição de voz em letras grandes no preâmbulo de todo spec, o caçador de fala rodando antes de cada espera do laço, e um simulador por worker com dono nomeado. **Nenhum processo de síntese apareceu desde as 19h45.**

A tentação aqui seria fechar a investigação com a hipótese bonita que eu mesmo escrevi. Ela foi testada e não se sustentou; escrever "provavelmente era o Apple Intelligence" seria exatamente o tipo de conclusão sem evidência que este dia inteiro recusou nas medidas da IA.

## 08/09, 20h — dois workers da A1 morreram calados; a volta não morreu com eles

O `worker-read` dos dois despachos da A1 (`ctx_73f170be81ae`, A1-B, e
`ctx_72fba36e5103`, A1-C) volta `status: failed`, terminal `exited`, **sem
`worker_done` e sem saída capturada**. O inbox não tinha nada: eles não
falharam contando, falharam calando.

O que sobreviveu está no disco, e é bom: o worktree `volta-a1-arranque` tem o
commit `8f2c671` mais **quatro arquivos modificados e não comitados** — a
medida do `try!` reescrita para se reproduzir (o `grep` cru conta 10 hoje,
porque a própria volta escreveu comentários que dizem `try!`; o comando com
filtro dá 9 em `main` e 8 no candidato), o pior caso da frase do meio já
fotografado (`a1-08-espelho-vazio.png`, 19h26, espelho sem nenhum `.md`) e a
lacuna do VoiceOver escrita com a formulação certa: **não é pendência de
instrumento, é ordem do dono**, e por lei da ESTEIRA não desconta nota.

**Lição para a esteira:** worker morto não é volta perdida — a primeira coisa a
fazer é `git status` e `git diff` no worktree dele, antes de decidir qualquer
coisa. Refazer do zero teria jogado fora as três correções.

Despachei a **A1-D** (`task_1506bf7b6420`, Opus 5): conferir os números em vez
de acreditar neles, pôr a captura no relatório, build e suíte integral na árvore
final no `6033B043`, e comitar. Nada de mérito novo — o G3 já passou nele.

## 08/09, 20h — o terceiro re-G3 da Q: CORRIGIR ANTES, e as duas frases grandes demais

O revisor de outro fornecedor (`gpt-5.6-terra`) confirmou o que a Q-E entregou —
as letras `08q`/`08r` não colidem em nenhuma ref viva, a ADR 08p aponta o RUMO
pelo nome sem prometer conserto, o aviso do build era **nosso** (`git blame` põe
`PerfilView.swift:637` em `42c0c20`, desta volta, não da A1) e a suíte 918/149
reproduz limpa — e reprovou duas afirmações:

1. **A prova de escopo é falsa.** A Q-E disse que desfazer as letras devolve o
   lado velho caractere por caractere e que o commit não trouxe nada além da
   renumeração. Repetida a transformação sobre a árvore inteira, **sobram 8
   hunks**, e `git show --stat` dá 16 arquivos, 223/56. As outras mudanças são
   legítimas e pedidas; a **frase** é que é grande demais.
2. **A varredura de privacidade não é o que o relato diz.** O teste filtra
   `$0.count >= 5`, então palavra de 1 a 4 letras não tem asserção — "palavra a
   palavra" é mais do que ele faz. O caminho certo é **estrutural**: o que
   protege o autor é que `Recusa.redigida` não tem campo nenhum que carregue o
   trecho.

Isto é a mesma família dos sete instrumentos que disseram mais do que mostraram:
desta vez o instrumento era **uma frase de prova**. Despachei a **Q-F**
(`task_67876c84f1f0`, Opus 5) com as duas correções e nada mais; a foto do
cartão CONTA segue lacuna declarada.

## 08/09, 20h — três voltas, três simuladores, um dono cada

Com os dois workers da A1 mortos, o **Pro Max `6033B043` ficou órfão ligado** e
eu o desliguei. Ficam ligados apenas o `C2416CBC` (conta Grok do dono, que
ninguém toca) e o `A1DF082C` (revisor da V13, vivo). A Q-F liga o `34CC3F94` e a
A1-D religa o `6033B043` — **um por worker**, como o dono mandou. Caçador de
fala rodado antes deste ciclo: **zero processos**.

## 08/09, 20h30 — o G3 da V13: tudo confirmado na tela, e ainda assim NÃO PASSA

O revisor de outro fornecedor conferiu a V13 no aparelho dele e **viu com os
próprios olhos** o que a volta afirmou: a linha `Trabalhos` deixou de parecer
link, some no filtro e na busca, a seta aparece com chip omitido e **some no
fim da régua** — ele inclusive fechou, na revisão, a captura que a volta tinha
declarado em aberto. Build verde, 7/7 no focado, caret igual no candidato e no
pai. Onze dimensões em 9.

Mesmo assim: **NÃO PASSA**, por duas provas que faltam, não por defeito.
**Acessibilidade 8** — o conserto de `Repetir pergunta` em AX5 só tem PNG, e a
imagem mostra que nada se sobrepõe mas não prova o rótulo inteiro nem a ordem de
leitura; a ESTEIRA pede árvore de AX **e** captura do mesmo instante.
**Movimento 8** — a seta é animação nova com `.opacity` e não tem vídeo, nem
normal nem sob Movimento Reduzido.

Duas frases do revisor que ficam: *"não desconto pela voz, que era proibida"* —
a lei do dono entrou na régua sem virar prejuízo para quem obedece; e *"não
capturar a seta no fim seria lacuna, mas foi fechada nesta revisão"* — revisor
que fecha lacuna em vez de só apontá-la.

Despachei a **V13-B** (`task_32591f5f21cd`, Opus 5, no 17e `C7341E64`): só as
duas provas, nada de conserto novo. Caçador de fala antes do ciclo: zero.

## 08/09, 20h45 — a A1 mesclada, e o registro das letras vira lei

A A1-D fechou as três correções **sobre o diff do worker morto**, sem refazer
nada: refez a medida do `try!` nas duas árvores (`git archive` para ler o `main`
sem tocar no checkout principal), abriu a captura do espelho vazio e confirmou a
frase palavra por palavra em vez de tirar outra, e reescreveu a lacuna do
VoiceOver como **ordem do dono**. 934/152 e zero aviso na árvore final.

E devolveu um achado **meu**: a ADR 08n já era da E1-B em `main`. Fui ao
registro completo — não à memória — e havia **duas** colisões vivas: A1 × E1-B em
`08n`, e V13 × Q em `08p`. Decidi por **quem é mais barato mover**, não por quem
chegou depois: a Q fica com `08p` (três letras encadeadas, já conferidas letra a
letra por um revisor — mexer nela invalidaria prova conferida), a V13 recebeu
`08t` por mensagem, a A1 virou **`08s`** pela minha mão, e a MAC-1 nasce com
`08u`. Nove ocorrências em oito arquivos; normalizando a letra, os dois lados do
diff ficam idênticos linha a linha.

A causa é minha e está agora na ESTEIRA: eu reservava **uma letra por volta**,
quando uma volta escreve quantas ADRs precisar. O registro se lê por comando,
vale para **todas as refs vivas** (branch não mesclado já é dono da letra dele),
e buraco antigo não se reaproveita.

Suíte na árvore **mesclada** — que nenhum dos dois lados tinha testado —
**948 testes em 153 suítes, verde**. Mesclada em `6da0df1`.

## 08/09, 20h50 — a Q-F fechou as duas frases grandes demais

Conserto 1 pelo caminho (a): a alegação de equivalência passa a valer para o
**artefato** de renumeração, com 49 linhas e 55 ocorrências enumeradas uma a uma,
as 12 linhas não-puras listadas, e a mesma frase nomeando as outras cinco
mudanças que entram no commit. Sem reescrever história — o SHA que o veredito
cita continua de pé.

Conserto 2, e este é melhor do que eu pedi: o teste novo varre a **serialização
inteira** de um caso de **cada uma das doze guardas** contra um exercício em que
toda palavra é um marcador inventado (oito de 1 a 4 letras, três com acento), por
igualdade de token — e o worker **provou que ele morde, por mutação**, desfeita
antes do build de fecho. 919 testes, zero aviso.

Despachei o **quarto** re-G3 (`task_cda75349b44b`), curto por desenho: as duas
correções e **a foto do cartão CONTA**, que é a única coisa segurando
`Jornada real` em 6 — e nada mescla abaixo de 9.

## 08/09, 20h20 — TRILHA NOVA POR ORDEM DO DONO: o Traço no Mac pelo Grok Bot

O dono pôs em `main` (`8d9ce62`) o contrato dos **onze casos de uso**
(`ferramentas/grokbot/CASOS.md`) e o brief da trilha
(`ferramentas/orca/papeis/trilha-mac.md`), com três voltas: MAC-1 (ler tudo e
escrever com origem), MAC-2 (a porta de volta do Trabalho, Astra no G0) e MAC-3
(web e briefing com citação obrigatória, só depois da Q mesclar). Ordem: abrir a
**MAC-1 agora**, como uma das três frentes, implementador Opus e revisor GPT 5.6
Terra, e **o revisor exercita cada caso de verdade com o MCP ligado**.

Abri a MAC-1 (`task_32b0b3e6a622`, worktree novo `volta-mac-1`, ADR reservada
`08u`). Ela paga os casos 1, 2-leitura, 3, 8, 9 e 11: `traco_agenda`,
`traco_decisoes`, `traco_escrever` com `origem` e `fontes`, o `agenda.md`
exportado, e a nota `origem: grokbot` com etiqueta no iPhone, **fora do
Retrato**. A etiqueta é tela, então o spec manda carregar o `design-router` e
começar pela fase de auditar.

**A lei que mais importa nesta trilha** já estava escrita pelo dono e eu a repeti
no spec: *o bot nunca redige como o autor*. Origem obrigatória em toda escrita
que não seja da pessoa, nada em nota pronta, expressiva e selada nunca chegam ao
bot, nada automático — e voz, VoiceOver e iPad proibidos como em toda parte.

**As três frentes agora:** MAC-1 (nova), V13-B (as duas provas) e a Q (quarto
re-G3). A A1 saiu por mescla.

## 08/09, 21h — a pausa da cota, a retomada, e o observador que eu mesmo matava

Pausa e retomada do laço registradas por ordem permanente do vigia: a janela de
sessão do Claude voltou (uso 19%) e o laço seguiu sem perder volta — as três
frentes continuaram vivas durante a janela.

**E achei um erro meu de instrumento, do tipo que este dia inteiro vem
colecionando.** `check --wait` é um **consumidor da caixa**: cada vez que eu
rodava um `check` simples para responder ao aviso de mensagem, eu **derrubava o
observador de fundo** — ele morria com `consumer_fenced` e saída vazia, e eu lia
aquele silêncio como "nada chegou". Perdi dois assim. O `worker-start` seguinte
chegou a falhar por o terminal coordenador ter perdido o vínculo com o Run
(`run-use` reata).

O conserto é apagar o instrumento, não consertá-lo: **o observador de fundo é
dispensável**, porque o próprio ambiente avisa quando há mensagem. Um leitor de
cada vez. Está na ESTEIRA, junto com a regra de ler o código de saída antes de
concluir que o silêncio quer dizer alguma coisa.

**Quarta frente aberta: F5b**, a trilha fora do app (`task_c556899450c1`, Fable
5.1, Pro Max `6033B043`, ADR `08v`). Ela fecha os estados da Ilha do compromisso
que **ninguém nunca viu**: a mínima — que a F4 deixou por fotografar dizendo que
"exige outra atividade viva ao mesmo tempo", o que é estado a **plantar**, não
impossibilidade —, o fim da atividade, e a compacta com duas atividades em AX5,
onde a F4 registrou um "t" cortado. O StandBy fica declarado: não renderiza no
simulador, e perseguir limite de instrumento não é trabalho.

A volta também nasceu com o nome consertado: era F5, virou F6, e **F6 já era dos
widgets da tela bloqueada** — colidia duas vezes. Fica **F5b**, e é a mesma
lição das letras de ADR, aplicada a número de volta: o registro se lê, não se
lembra.

## 08/09, 21h05 — dois orquestradores no mesmo laço, e a queda que eu tinha acabado de documentar veio de fora

O dono abriu às 20h34 uma segunda sessão de orquestrador. Às 20h36 ela rodou
`run-use` no mesmo Run sem saber que eu estava vivo: o coordenador passou para
outro terminal e a geração foi de 3 para 4. **É exatamente a queda que eu
documentei em `ec7dc18` uma hora antes** — `consumer_fenced` com saída vazia —
só que desta vez a causa não era minha.

Isso melhora a lei em vez de contradizê-la: a mesma queda tem **duas** causas —
um `check` avulso meu por cima do meu próprio `--wait`, e **outro terminal
assumindo o Run**. Nos dois casos o silêncio não quer dizer "nada chegou", o
conserto é `run-use` de novo, e **os workers não param**: conferi os quatro
despachos (V13-B, MAC-1, Q re-G3, F5b) e os quatro seguem `dispatched`. A
ESTEIRA passa a dizer isso.

A outra sessão não tocou em mais nada além de remover o worktree
`volta-a1-arranque`, que estava limpo e mesclado em `6da0df1` — remoção correta.
Ela está parada e vai perguntar ao dono qual das duas conduz. **Até a resposta
dele, o laço é meu**, e sigo com as quatro frentes.

## 08/09, 21h20 — a Q PASSA no quarto re-G3, e a mescla abre um sexto problema

O revisor recomputou tudo **sem usar a contagem do implementador**: as 49 linhas
e 55 ocorrências são puras, as 12 linhas mistas declaradas estão completas, e
nenhuma frase sobrevivente diz que o commit inteiro só renomeia. Na guarda
estrutural ele foi além de conferir — **fez a própria mutação**
(`nome` → `valor` em `.campoAcimaDoTeto`), viu o vermelho nomeando
`["gorrenita"]`, desfez, e confirmou os 54 testes verdes com a árvore limpa. E
foi ao Perfil no `34CC3F94`: captura e árvore de AX do mesmo instante mostram as
três listas, os dois grupos, o quê/por quê/conserto por operação, e **nenhuma
linha mandando conectar a conta**. Todas as dimensões em 9. **PASSA.**

Fui mesclar e **abortei**. Cinco conflitos, e dois deles em Swift de mérito:
enquanto a Q trabalhava, a **V17 mesclou** e mexeu nas MESMAS funções —
`OficinaTrabalho.preparacaoRemota` e `PraticaTrabalho.parsePreparacao/validar`.
O `main` exige a chave `mudanca` no contrato quando há ajuste e derruba a
preparação se ela vier vazia; a Q trocou o mesmo corpo por `lerPreparacao` com
`Result<Preparada, Recusa>`, que nomeia a guarda que recusou. **Os dois estão
certos e os dois têm de caber na mesma função.**

Não resolvi. Escolher qual `Recusa` a `mudanca` merece é decisão de semântica de
quem escreveu as duas regras, e um diff pequeno e limpo teria posto no `main`
uma semântica que ninguém escolheu. Despachei a **Q-H**
(`task_1b67bbdd2a79`, Opus 5): traz o `main` para dentro do branch, funde sem
que nenhuma regra desapareça, **declara cada escolha por escrito**, e prova na
**árvore mesclada** — com a instrução de que um teste que fique vermelho na
fusão **é o achado**, não um estorvo.

Vira lei na ESTEIRA: **o G5 tem dois passos. Aprovado não é mesclável.**

## 08/09, 21h35 — a V13-B anexou as duas provas, e trouxe o oitavo instrumento

As duas provas que o G3 segurou entraram, **sem tocar em uma linha de
`Traco/`**: o cartão da sábia em falha alcançado pela rota real e capturado em
AX5 com árvore e screenshot a um segundo de distância (rótulo inteiro, 117 pt =
duas linhas, ordem pergunta → estado → ação, vãos de ~10 pt, nenhuma
sobreposição), e dois vídeos sem áudio do mesmo trajeto da seta, medidos quadro a
quadro: **nove quadros de meio-tom (~150 ms) sem Movimento Reduzido, um quadro
só com ele, sem meio-tom e sem piscar.**

E o achado que vale mais que a volta: **o leitor de AX do serve-sim devolve no
máximo três dos quatro elementos do cartão, e qual some muda com o tamanho de
letra.** Ela não parou no sintoma — provou que é do leitor e não do app, porque
em `medium` some "Fechar" e em AX5 sumia "Repetir pergunta"; refeito com
pergunta curta, os três vieram com frames que batem pixel a pixel com a captura.

Eu já tinha avisado as outras duas frentes por batimento, sem prova. Agora tem
prova e virou lei: **ausência na árvore não é prova de ausência na tela**;
presença continua valendo. É o oitavo instrumento do dia a dizer menos do que
mostra, e o primeiro em que a diferença entre "o app não expõe" e "o leitor não
devolveu" só apareceu porque alguém mediu a mesma tela de dois jeitos.

Renumerei a ADR da V13 de `08p` para **`08t`** (a `08p` é da Q, que já teve as
letras conferidas uma a uma) — duas ocorrências, e normalizando a letra os dois
lados do diff ficam idênticos. Commit `4e8bc40`. Despachei o **re-G3 segundo**
(`task_99b2222e5719`) para o mesmo revisor confirmar as duas provas e,
principalmente, **conferir a atribuição do limite** — se ele discordar, aquilo é
defeito do app e não limite do instrumento.

## 08/09, 21h50 — a V13 PASSA, e o revisor me corrige na dose da minha própria lei

Movimento e Acessibilidade subiram a 9: ele foi ao **vídeo bruto** e contou os
quadros (nove intermediários no normal, um com Movimento Reduzido), e o par AX5
prova rótulo, ordem e ausência de sobreposição. **PASSA**, commit `3eff3bd` no
branch.

E ele fez comigo o que eu venho cobrando de todo mundo: **cortou a minha
alegação no tamanho da prova.** Eu tinha escrito na ESTEIRA que o leitor de AX
"devolve no máximo três dos quatro elementos, e qual some muda com o tamanho de
letra". Ele confirma o que a evidência sustenta — *"Fechar ausente da árvore mas
presente na captura é limite do leitor"* — e nomeia o que falta: **sem a árvore
bruta em `medium`, o "máximo de três" e a variação por tamanho não viram regra
geral.**

Corrigi a ESTEIRA para separar as duas coisas: o que está provado (a árvore pode
omitir um elemento que está na tela; presença vale, ausência não prova ausência)
e o que não está (o teto de três, a dependência do tamanho de letra). Quem
precisar da generalização, mede e guarda as duas árvores brutas.

É a terceira vez hoje que eu escrevo uma frase maior que a prova — a primeira foi
a recusa de vazamento que eu atribuí ao provedor, a segunda o achado de perda de
dados da A1. Desta vez quem pegou foi o revisor, e no mesmo dia em que eu reprovei
a Q por exatamente isso.

## 08/09, 22h — pausa e retomada (uso 26%); a V13 mesclada e a C1 aberta

Pausa e retomada do laço registradas por ordem permanente do vigia. Nenhuma
volta se perdeu na janela: as três frentes continuaram trabalhando.

**V13 mesclada** (`70ba8e6`), suíte na árvore mesclada em **949 testes / 153
suítes, verde**, worktree removido e RUMO marcado. Ela fecha com a frase que
merece ficar: **foi reprovada por prova que faltava, não por defeito.**

**Terceira frente reaberta: C1**, o caret do Caderno em AX XXXL no 17e
(`task_f3a396a8b66a`, Opus 5, ADR `08w`). É o **único vermelho** da suíte
integral naquele aparelho e a V13 provou que é **pré-existente** — a invariante
da escrita visível (ADR 08f) foi provada no Pro Max e no teste 2 e **não neste
aparelho neste tamanho**, que é justamente onde a tela é menor e a letra maior.

Escolhi esta e não a `RaizView`/`NotasView`, que também está na fila, por dois
motivos: o vermelho **já existe** (é a evidência mais forte que uma volta pode
nascer tendo), e a área é **disjunta** das três frentes vivas — a `Sessao`, onde
mora o conserto da outra, encosta no que a MAC-1 está mexendo. Depois do que a
mescla da Q me ensinou hoje, abrir duas voltas no mesmo arquivo é comprar
conflito de mérito.

O spec nasce com duas leis do dia: **começar reproduzindo** (se o vermelho já
tiver caído sozinho, isso é o relato) e **conserto na causa, não no teste** —
afrouxar a asserção ou excluir o 17e da medida seria apagar o instrumento, e a
resposta certa aí é dizer e parar.

**As frentes:** MAC-1 (Traço no Mac), Q-H (reconciliar a Q com o `main`), C1 (o
caret) e a trilha fora do app com a F5b (a Ilha).

## 08/09, 22h20 — a volta Q MESCLADA, depois de quatro re-G3 e uma reconciliação

A Q-H fundiu os dois contratos sem que nenhuma regra sumisse, e a decisão que ela
tomou é melhor do que a que eu teria tomado: **`lerPreparacao` passa a conhecer
`comMudanca`** — chave ausente, tipo errado ou vazia continuam derrubando a
preparação, como a V17 exige, mas agora por **guarda nomeada em vez de `nil`
mudo** —, `provar` prova a `mudanca` pelo mesmo teto e pela mesma régua dos
critérios e **depois** deles, e um único `ajustando` governa esquema, leitura e
rótulo.

**Uma única decisão de caso novo, e a justificativa é a que eu queria ouvir:**
`mudancaVazaOExemplo` nasce porque reaproveitar `criterioVazaOExemplo` obrigaria
a **inventar um índice de critério para um campo que não é critério** — e aí a
recusa mentiria sobre qual guarda reprovou. Os outros quatro casos são
reaproveitados, com a razão de cada um escrita: treze decisões, uma por linha.

Suíte integral **na árvore mesclada**, duas execuções idênticas: 957 testes,
956 passados, 0 falhos, 1 pulado. E como o `main` andou durante o trabalho (a
V13 entrou), ela trouxe o `ea182a0` também — auto-merge limpo, sem conflito e sem
colisão de letra, verde de novo em 958/957/0/1.

Mesclei sem re-rodar a suíte, e digo por quê em vez de pedir confiança:
`git diff 543561d HEAD -- '*.swift' '*.pbxproj' Traco/ TracoTests/ TracoWidget/`
**volta vazio** — o código da árvore mesclada é idêntico ao que ela provou
verde; o que difere são dois arquivos de documento.

**Item 2 da fila do dono, pago.**

## 08/09, 22h20 — a terceira colisão de letra, e desta vez eu colidi comigo mesmo

Dei a **`08w`** à Q-H e à C1 **no mesmo turno**, porque eu vinha reservando letra
**dentro do spec de cada volta** — espalhada assim, ninguém consegue ler o
conjunto, eu inclusive. A Q-H já tinha comitado e mesclado; a C1 ainda nem
escreveu a ADR, então a C1 é quem move: **`08x`**, avisada, com o registro
completo na mensagem.

O conserto não é lembrar melhor: é tirar o registro dos specs. Criei
`ferramentas/orca/LETRAS-ADR.md` — um lugar só, com o comando que lê todas as
refs vivas, a regra de não reaproveitar buraco antigo, a de mover quem é mais
barato quando duas voltas vivas colidem, e a forma de provar a troca. Os specs
passam a apontar para lá.

E ficou mais uma lei da Q-H: **o runner que trava antes de conectar não é
resultado.** Ela pegou dois "hung before establishing connection" com 0 de 957 e
não os contou nem como vermelho nem como verde — provou que a árvore sobe no
aparelho e repetiu, mostrando as duas saídas.

## 08/09, 22h35 — a MAC-1 entrega, e desenterra um engano que durava desde sempre

Os seis casos pagos (1, 2-leitura, 3, 8, 9, 11): `traco_agenda` e
`traco_decisoes` novos, `traco_escrever` com `origem`, `motivo` e `fontes` e
**recusa que diz o que falta**, `agenda.md` exportado, a etiqueta "feito pelo
bot" na lista e na página — com a `Pilula .etiqueta` **que já existia**, sem cor
nem componente novo —, a nota do bot fora do Retrato e da Trajetória **nem como
contagem**, e as instruções coláveis dos seis casos. Suíte 953/0 em 153 suítes,
0 aviso.

**Três defeitos de passagem, e o primeiro é o achado do dia:** `traco_semana`
lia os campos da forma no **cabeçalho**, e eles vivem no **corpo** — a revisão da
semana **devolvia decisões vazias desde sempre**, e **a fixture do autoteste
sustentava o engano**. É o teste que concordava com o defeito, a versão mais cara
dessa família: ninguém desconfia de um verde. Importa duas vezes, porque
`traco_decisoes` nasce dessa mesma leitura. Os outros dois: um `TracoSchemaV5`
com a lista de classes da V4 derruba o arranque ("Duplicate version checksums
detected"), pego por **dois testes de migração e não pelo aparelho**; e a cápsula
de origem quebrava em duas linhas com gesto + domínio juntos.

**Um limite declarado, honesto:** a prova de que a nota do bot não está no
Retrato é **por teste, não por captura** — a `ScrollView` do Perfil não rolou com
o gesto do helper (`orca emulator exec` responde `unknown option '-d'`).

**E uma pergunta de contrato que ela teve o cuidado de não responder sozinha:**
a inferência de domínio rodou sobre a nota do bot e pôs "TRABALHO" nela. O bot
não redigiu como o autor e a nota está fora do Retrato — mas o texto do bot passa
a **moldar o mapa de domínios do autor**. Mandei o revisor dar a leitura dele; se
disser que fere o contrato de origem, levo ao dono, porque é decisão de contrato
e não conserto.

O revisor (`task_2072a1006345`) vai com a ordem do dono colada: **exercitar cada
caso de verdade com o MCP ligado num cliente, e ler o retorno inteiro** — uma
instrução que só funciona na cabeça de quem a escreveu não está entregue.

## 08/09, 23h — pausa e retomada (uso 38%); a R1 abre o item 4 da fila do dono

Pausa e retomada registradas. Inbox vazio, os três despachos conferidos vivos —
nada se perdeu na janela.

**Terceira frente reaberta: R1, a retomada do Trabalho** (`task_80cb1e43fc7b`,
Opus 5, ADR `08y`, teste 3). É o **item 4 da fila do dono** e a área ficou livre
com a mescla da Q — o G0 dela já estava escrito no RUMO desde as 20h, à espera de
vaga, e é por isso que ela nasceu pronta.

O que ela ataca é uma **meia entrega**, não uma ausência: `TrabalhoView.retomada`
já dá "Continuar: \<ato pendente\>" e "Último retorno", mas a folha **abre sempre
no topo** de quinze blocos — ela *oferece* rolagem e nunca a usa na abertura —,
não há resumo do que houve entre duas visitas, e "último retorno" é a última
evidência, não o que mudou: se o autor guardou a própria versão e nada mais
aconteceu, a retomada fala de algo velho ou cala.

A fronteira que mais importa está no spec em letras próprias: **nada de resumo
escrito pela IA**. Quem sabe o que mudou é o app, que tem os vínculos. Um resumo
gerado seria bonito e seria mentira — e é exatamente o tipo de coisa que este
projeto existe para não fazer.

**As frentes:** revisor da MAC-1 (exercitando os seis casos com o MCP ligado), C1
(caret já verde no 17e, nas capturas), R1 (nova) e a trilha fora do app com a
F5b.

## 08/09, 23h15 — a C1 leva o único vermelho do 17e a zero, e a causa é uma conta

Fez o caminho na ordem certa: **reproduziu as 18 issues antes de consertar**, e
mediu a causa com sonda em vez de adivinhar. No 17e com teclado de pé sobram
413,67 pt; o pé toma 274,67 (326,67 com o aviso); e a regra `min(piso, sobra/2)`
dava **69,5 pt — depois 43,5 — de papel para uma linha de corpo de 67**. Somado
a isso, `EscritaVisivel.seguirCaret` perseguia o **`caretRect` (45 pt)** e não a
**linha visual (67 pt)**, pedindo a folga inteira num papel curto.

O conserto é nas **duas funções compartilhadas e sem tocar no teste** — que era
exatamente o que eu tinha proibido no spec: o piso do papel nunca desce abaixo de
uma linha, a folga cede antes da letra, e a nova `linhaDoCaret` mede pelo TextKit
2. **18 → 0**, AX5 31/31, large 44/44, suíte integral **949 em 153 suítes verde
no 17e**, zero aviso, `content_size` restaurado.

**Uma contradição que mandei o revisor desempatar:** o assunto do `worker_done`
diz "AX XXXL" e o corpo diz que as 18 issues são **todas AX5**. Eu escrevi
"AX XXXL" no spec porque foi assim que a V13 relatou, e pode ser que eu tenha
propagado um erro de leitura. Importa: **AX5 é um tamanho que muito mais gente
usa que o XXXL**.

Dois limites declarados e não corrigidos, que o revisor julga se ficam como
dívida: um resíduo de ~0,11 s na gaveta do cartão a chegar, e a barra de baixo,
que em AX XXXL toma **275 dos 414 pt** do 17e.

E uma nota de instrumento: **o `orca emulator` parou de entregar toque no meio da
passada**, e a saída foi varrer **220 quadros com `simctl io`** enquanto o teste
hospedado dirigia a Página real. Não vira lei ainda — mandei o revisor conferir
se a evidência assim obtida sustenta o que ela afirma.

## 08/09, 23h25 — MAC-0 aberta por ordem do dono, e a lei do mouse suspensa por uma volta só

Ordem literal: *"tem o Astra e o Fable 5.1, dois modelos excepcionais para
controlar meu computador, e no Orca todos têm permissão total; deixe totalmente
configurado"*. O dono suspendeu a **lei do mouse** — a mesma que ele criou às
11h35 de hoje, com raiva, ao ver agentes disputando o cursor — **para esta volta
e só para ela**, e escreveu a exceção na ESTEIRA em `main` (`6613a72`).

Pus os limites em letras próprias no spec, porque uma exceção mal lida vira a
regra: **só o app "Grok Bot"** (`com.anysphere.sand`) e, se preciso para a
primeira tarefa, o **"Espelhamento do iPhone"**; nenhum outro app, nem navegador,
nem Ajustes, nem Finder; **aviso ao dono no comentário do worktree ao começar e
ao terminar**, e o mouse devolvido no fim; **nenhum simulador**; e **voz,
VoiceOver e iPad continuam proibidos sem exceção nenhuma** — a suspensão é do
mouse e só do mouse.

**A tarefa 1 é a que decide o resto:** a pasta espelhada
`~/Library/Mobile Documents/com~apple~CloudDocs/Traço` **não existe no Mac**, e
sem ela o servidor não tem o que ler. Ela nasce pelo caminho do produto — no
Traço do iPhone do dono, Perfil › Dados › Espelhar numa pasta › iCloud Drive —,
com a instrução de **não tocar em nada mais no iPhone** e de **reportar e seguir**
se o aparelho não estiver alcançável.

E a prova que pedi é de uso, não de configuração: **"bom dia"** tem de chamar
`traco_agenda`, e **"o que eu já pensei sobre o Traço?"** tem de chamar
`traco_buscar` **citando ids**. Com uma saída honesta escrita no spec: **se a
pasta ainda não existir, a prova válida é a mensagem do servidor dizendo isso** —
uma configuração que responde "não achei a pasta" está mais entregue do que uma
que inventa.

**Teto:** o dono mandou segurar a próxima abertura até a MAC-0 fechar. Em edição
ficam R1 e MAC-0; MAC-1 e C1 estão em G3 (revisão, não edição) e a F5b é a trilha
fora do app. Não abro mais nada até ela voltar.

## 08/09, 23h35 — DIRETRIZ §7: a lei do mouse cai, e o foco vira a IA até a nota 9

Palavras do dono: *"todos os modelos no Orca têm total liberdade de controlar meu
computador e evoluir o Traço iOS. Foco número um: levar o Traço a 9/10; está em 7
e demorou o dia inteiro. Foquem na melhoria da IA, testem a IA, têm total
controle do computador. Elevem ao extremo design e experiência: curva-zero,
design-router, gate-loop."*

**O que muda, e já pus no preâmbulo de todo spec:**

1. **A lei do mouse foi substituída** — controle do computador liberado para todo
   worker, com **aviso no comentário do worktree ao começar e ao terminar** e
   **nunca dois workers no mesmo app**. No simulador, `orca emulator` continua
   preferido, porque toca pelo UDID sem disputar o cursor. **Voz, VoiceOver e
   iPad seguem proibidos** — essa não se toca.
2. **Foco 1 é a IA:** as **sete** operações `indisponivelPorQualidade` (`ecos`,
   `calibragem`, `recordar`, `responderNasNotas`, `responder`, `instigar`,
   `contrapor`) voltam **uma por uma**, cada uma com volta própria, medidas com o
   Grok pela sonda **antes e depois**, e só saem da lista com **9 nas cinco
   dimensões**. Alavancas: contexto, prompt, esquema de saída e teto. **A régua é
   a saída inteira lida.**
3. **Foco 2:** toda volta visual cita as seis fases do design-router, curva-zero
   medida em toques, gate-loop dono do ciclo; **tela abaixo de 9 antes de função
   nova**.
4. **Cada fecho diz o que mudou na NOTA da dimensão tocada, com prova.**

Aproveitei o preâmbulo aberto para acrescentar as duas leis de instrumento que
nasceram hoje: **ausência na árvore de AX não prova ausência na tela**, e
**runner travado antes de conectar não é resultado**.

**Abri a consulta de G0 ao Astra para a Q2** (`task_6d119a00ab8f`), que é
`responder` — a primeira da fila do dono, escolhida por valer mais para a jornada
do espanhol e para a sábia na página. O defeito medido: *o Grok inventou fato
quando o contexto não sustentava* (horário de biblioteca que ele não podia saber,
um total de R$ 1.008 sem distância, consumo nem preço), **3 de 6 casos — e o
mesmo caso acertou numa execução e fabricou na seguinte**.

Fiz três perguntas e a terceira é a que me preocupa: apertar contra a invenção
compra facilmente **a recusa covarde** — calar onde o contexto sustentava. Isso
já aconteceu com a irmã `responderNasNotas`. Pedi ao Astra **a forma da prova de
que a volta não comprou esse defeito**, não a promessa de cuidado. E avisei que
"N de 6" sozinho não decide, porque o mesmo caso deu os dois resultados.

## 08/09, 23h55 — pausa e retomada (uso 44%); quatro entregas de uma vez, e duas reprovações que valem

Pausa e retomada registradas. Quatro despachos voltaram `completed` **sem
`worker_done` na caixa** — fui direto ao `git log` de cada worktree, como a lei
de hoje manda, e todos os quatro tinham entregado.

**G3 da MAC-1: RECUSADA.** E os três achados são bons:
- **P0 de autoria:** `PerfilView.lerRetrato` passa `doAutor:` certo, mas
  `Sessao.responderNasNotas` — **a rota de produção** — cria `Retrato.NotaLida`
  **sem esse argumento**, e o padrão é `true`. Uma nota `grokbot` aberta **entra
  no retrato mandado à IA**. O teste novo exercitava `Retrato.ler` isolado, **não
  esse chamador**: é o teste que não visitou o lugar do defeito, de novo.
- **P1:** o caso 8 **não é executável como prometido** — com o MCP ligado num
  cliente real, `traco_contrato` devolve só contrato e corpus, **sem os métodos e
  as perguntas** que a instrução manda o bot buscar. É exatamente por isto que o
  dono mandou o revisor exercitar cada caso de verdade.
- **P2:** as duas correções não deixaram replay do vermelho.

**G3 da C1: CORRIGIR ANTES**, e a régua dele é dura do jeito certo. Ele
**reproduziu as 18 no pai com as próprias mãos** e confirmou o verde
(31/31, 44/44, 949 integral). Mas a ADR 08f escreve a invariante como *"em cada
quadro apresentado"*, e a captura `c1-04` mostra a linha ativa cortada pelo
cartão **durante a gaveta**. Declarar como resíduo é honesto — **e não torna
mesclável uma violação conhecida de uma regra sem exceção**. Ele acrescenta que
os 0,11 s **não são verificáveis**: há captura e a alegação de 220 screenshots,
mas sem timestamps, sequência ou vídeo versionado.

**F5b entregou, e é a melhor volta da trilha até aqui.** Ela achou o defeito
**antes** do acabamento: com Destaque e compromisso vivos, o iOS mostra um e
empilha o outro — **era o Destaque escondendo o compromisso que está
acontecendo**; conserto por `relevanceScore`. Plantou a **Ilha mínima** subindo
um segundo app descartável, porque duas atividades do mesmo app não a produzem.
Mediu o fim: o "acabou" sai sozinho da Ilha em **menos de 12 min** e fica na tela
bloqueada **além dos 14**. E **removeu um item do RUMO**: o "t" cortado da F4
**não se reproduz**, porque **a Ilha não escala com Dynamic Type** — mandei o
revisor conferir essa afirmação, porque ela apaga uma dívida.

**Astra entregou o G0 da Q2** e o parecer tem a qualidade que se paga por ele: o
critério de resolvido em uma frase (**um único descumprimento reprova**), a
alavanca (**prompt primeiro**, adaptando o contrato de sustentação do
`MotorTrabalho.sistema`, que já proíbe inventar fato e manda nomear o dado
ausente), e — o que mais importa — **o aviso de que a comparação com `produzir`
é hipótese e não prova causal**, porque as corridas usam modelos e esforços
diferentes. Ele também derrubou a régua antiga: **"3 de 6" não é gabarito
semântico**, porque casos contados como bons inventam coisas também.

**Despachei:** a **Q2** (`ctx_b3298d891b2b`), com o critério do Astra e a tabela
de pares que muda só a evidência — a prova de que apertar contra a invenção não
comprou a **recusa covarde** —, e o **revisor da F5b** (`ctx_a51788690b90`).

**Seguro a MAC-1-B e a C1-B**: em edição já estão R1, MAC-0 e Q2, e o dono
mandou que a próxima abertura fosse a Q2 e mais nada. Elas entram quando abrir
vaga.

## 09/09, 00h — pausa e retomada (uso 46%); a Q2 mede, e recusa aprovar a si mesma

**A Q2 é a melhor volta de IA do laço até aqui, e o motivo não são os números.**
Cinco corridas na sonda, **no aparelho do dono com a conta ligada**, 12 casos × 3
execuções, saídas inteiras guardadas. Duas alavancas medidas **separadamente**:

- **prompt sozinho no `grok-4.3`:** base 5/12 → candidato **8/12**. A **fabricação
  de NÚMERO morreu** — os R$ 1.008 e o horário da biblioteca **não voltaram em
  108 execuções**. Mas sobrou **fabricação de cenário**, que **sobrevive a uma
  proibição escrita com todas as letras**;
- **o mesmo prompt no `grok-4.6` com esforço `medium`:** **12/12 e 36/36, nenhum
  descumprimento**.

**E ela não aprovou a si mesma.** Escreveu: *"eu escrevi os doze casos e eu os li;
aprovar a operação com a minha própria leitura seria usar a nota do gerador como
aprovação — o que `QUALIDADE-IA.md` proíbe na mesma página"*. Também não
implementou a habilitação: *"não implementei o que não posso aprovar"*. E mediu o
preço em vez de escondê-lo: a espera vai de **1,4 s para 36,1 s de média, pior
caso 77,5 s**, dizendo que a régua do aceitável ali é do dono.

**O dono decidiu: vale a espera, e a tela tem de avisar.** Isso resolve o preço;
**a qualidade quem decide é o revisor independente**, que despachei
(`ctx_e79573532c4a`) com a exigência que o conselho fixou: **casos NOVOS, dele**,
atacando a fabricação de cenário — a que sobreviveu — e a recusa covarde, que é o
defeito oposto; cada saída inteira lida; **um único descumprimento reprova**.

**MAC-0 ficou duas horas cega** e o worker fez o certo: a tela do Mac estava
trancada desde as 21h23, a acessibilidade não expunha janela nenhuma, e ele
**não tentou destrancar** — registrou tudo e parou (`c0155fe`). O dono
desbloqueou; a MAC-0-B (`ctx_9287c38942ea`) retoma com duas respostas dadas: o
servidor aponta para o **caminho estável do `main`**, nunca para um worktree que
vai sumir, e o **"bom dia" fica declarado em aberto** — `traco_agenda` só nasce
quando a MAC-1 mesclar, e uma configuração honesta que diz o que não tem vale
mais do que uma que parece completa.

**O revisor da F5b também recusou** ("a Ilha sem prova reprodutível") e a R1
entregou com um achado que me interessa: **o defeito que a minha auditoria
acusava já tinha caído** — a terceira vez hoje que a régua "a auditoria é datada"
se paga sozinha.

## 09/09, 00h30 — pausa e retomada (uso 0%); o revisor da Q2 parou pelo motivo certo

**O revisor da Q2 escreveu "NÃO APROVAR" e a razão honra a esteira:** *"a conta
do único aparelho autorizado caiu depois do install por cima, e não a
contornei"*. A lei do simulador do Grok diz **"se a conta cair, diga em vez de
contornar"** — ele disse. O dono reautorizou, e a **Q2-B** (`ctx_8700c898fcf6`)
retoma **só o que falta**: as três inferências novas em **casos que o
implementador não escreveu**.

O que a leitura dele já estabeleceu, e não se refaz: leu **as 36 saídas inteiras**
do `grok-4.6` e **não achou** fabricação de número, horário, terceiro, suporte
nem ação já realizada, **nem recusa integral de pedido atendível**; e conferiu
que **a sonda e o cartão de produção chamam a MESMA função** — *não é a sobrecarga
fantasma que invalidou a medição anterior de `responderNasNotas`*. Fica também a
ressalva dele, que é justa: a sonda abre `responder` **só em DEBUG**, então isto
**mede motor, não entrega superfície**.

**O Mac continuou trancado** e a MAC-0-B fechou pelo mesmo motivo da primeira,
sem configurar nada e sem desfazer nada. O dono está destrancando; a MAC-0-C
espera a confirmação.

**Duas leis novas de instrumento, as duas vindas da R1:**

1. **`orca emulator kill` derruba o vizinho.** A R1 matou o helper para o
   `34CC3F94` e **o `6033B043` de outra volta desligou no mesmo segundo** — o
   helper é um só e derruba o que ele gerencia, não só o `--device` pedido. Para
   encerrar o próprio aparelho, `simctl shutdown`, que é escopado.
2. **O `ask` expira, e o laço tem de contar com isso.** Duas perguntas morreram
   por timeout na mesma noite, porque eu só olho a caixa quando sou avisado. O
   worker da R1 fez o certo: com a pergunta expirada, **religou o simulador para
   restaurar o estado em que encontrou a máquina** — voltar ao que estava é a
   decisão certa quando o coordenador não responde. Está no preâmbulo agora.

Despachei também a **MAC-1-B** (`ctx_b365f76d3509`) com o P0 de autoria e a
decisão de contrato do dono: **a origem acompanha todo consumidor**, o campo vira
`vozDoAutor` para a incompatibilidade morar no tipo, e **o padrão não pode ser
permissivo** — o defeito nasceu de um `default true`.

## 09/09, 01h — pausa e retomada (uso 2%); a lei do Grok estava errada, e quem a derrubou foi a fumaça

**A conta caiu por causa do INSTALL POR CIMA — que a lei permitia.** A fumaça do
revisor mediu `contaGrokLigada=true` com **12 modelos** às 03:20:38Z e, **89
segundos depois do install**, `false` com **0 modelos** às 03:22:07Z. Ele parou
na hora, não reautorizou, não limpou, não usou outro aparelho — e foi **por não
contornar** que o gatilho apareceu. Se ele tivesse dado um jeito, a lei
continuaria errada e a conta continuaria caindo sem ninguém saber por quê.

**A lei está corrigida:** no `C2416CBC` **ninguém instala nada, nem por cima**.
E ficou escrito **como rodar IA sem instalar**, que é o que destrava o trabalho:
a sonda lê a fixture pelo nome em `TRACO_AVALIAR_IA` **no Documents do app**
(`AvaliacaoIA.swift:58`) — escreve-se a fixture no contêiner de dados, relança-se
com a variável, e **usa-se o binário que já está lá**, dizendo no relato qual
candidato é (medir com binário alheio é o erro irmão). Fumaça obrigatória antes e
depois de cada corrida.

Despachei a **Q2-C** (`ctx_...`) com esse método e com os **seis casos
independentes que ele já tinha escrito** — eles voltaram `semRetorno` por causa
da conta; não se reescrevem, rodam-se.

**O Mac nunca foi destrancado**, e o worker provou em vez de reclamar: o carimbo
`CGSSessionScreenLockedTime` continua **21:23:03 de 08/09**, e o macOS o reescreve
a cada bloqueio novo — logo a tela não abriu em momento nenhum. Ele escalou às
21h46, repetiu a pergunta três vezes, esperou o prazo e **fechou como falha por
bloqueio sem tomar o mouse e sem alterar nada**. A observação dele para o dono é
prática: **destrancar e avisar no momento**, porque o Mac trava sozinho por
inatividade.

O que ele apurou sem a tela vale: a pasta espelhada **não existe** e o servidor
responde a **mensagem honesta** ("A pasta do Traço não está em …"); o
`.cursor/mcp.json` aponta para o caminho estável; `tools/list` do `main` traz **10
ferramentas, sem `traco_agenda` nem `traco_decisoes`**; `settings.json` intocado.

## 09/09, 01h30 — pausa e retomada (uso 3%); a conta segue caída e eu paro de perguntar

A fumaça da Q2-C às **04:30:19Z** gravou `contaGrokLigada:false` e
`Falha.semRetorno`. O revisor **não instalou candidato e não rodou os casos
cegos** — a fronteira nova respeitada à risca. `responder` continua **não
aprovada**, e a razão está escrita: falta o dono reautorizar **de forma
verificável**.

**Pedi duas vezes e as duas coisas não aconteceram** (o Mac nunca destrancou, a
conta não voltou). Registro e **paro de perguntar**: repetir a pergunta não
produz trabalho, e o dono responde quando estiver na máquina. As duas ficam
esperando, com a evidência guardada — a Q2 tem a medida inteira em `prova/`, e a
MAC-0 tem o roteiro de retomada pronto.

**A MAC-1-B entregou** (`8bdc591`, ADR **2026-09-09b**) e a frase do commit diz o
que interessa: *"o corte da 08u estava no LEITOR, e o CHAMADOR de produção o
esquecia"*. `vozDoAutor` **sem padrão**, o caso 8 exercitado no cliente real, e os
dois vermelhos que faltavam. Foi ao re-G3 com o mesmo revisor.

Também despachei a **C1-B** — que tem de **escolher um caminho e escrever a
razão**: consertar a gaveta, ou **contratualizar** a exceção na ADR 08f de forma
nomeada, delimitada e medida. Escrever exceção larga para caber o que hoje falha
seria enfraquecer a invariante em vez de dizer a verdade sobre ela. E a **revisão
da R1**, onde a pergunta que mais me interessa é se **a recusa dela em implementar
a rolagem automática** — porque conferiu na tela viva que a retomada já nasce a
0,36 tela do topo, e o que está acima é a intenção — está certa ou deixou de
entregar o critério.

## 09/09, 02h — pausa e retomada (uso 5%); a MAC-1 aprovada, e o conserto que calou quatro rotas de uma vez

**A MAC-1-B passou no re-G3** e o conserto é do tipo que eu gosto de registrar:
o P0 não era um esquecimento a remendar num lugar — `Nota.vozDoAutor` passa a
devolver **vazio quando a nota não é do autor**, e isso **calou de uma vez o
léxico, o classificador de bordo e as perguntas dos Padrões**, com `Nota.dominio`
calando o chip `TRABALHO` **sem migração**. As seis conversões espalhadas viraram
quatro (`paraRetrato`, `paraTrajetoria`, `paraSemana`, `paraRede`), e o campo
**não tem padrão** — a incompatibilidade mora no tipo, como o dono decidiu.

O revisor conferiu do jeito certo: **injetou o mesmo teste de rota no commit
velho num checkout temporário** e viu o vermelho (o retrato enviado continha
`2 WOOP` e *"o bot achou isto"*), depois viu o verde no candidato. E exercitou o
**caso 8 num cliente MCP de verdade**: o `traco_contrato` agora traz "Métodos,
campos e a PERGUNTA de cada um", e o cliente fez **somente** a pergunta do WOOP,
sem escrever arquivo.

Um achado de brinde que corrige a nossa própria ADR: o replay da V5 mostrou que
**o checksum duplicado só reclama quando um estágio RODA**, e que a falha é uma
`NSException` **que nenhum `do/catch` pega**.

**Mesclada** (`6d1c90d`), com os conflitos de vizinhança resolvidos e o projeto
**regerado por `xcodegen`** em vez de concatenado à mão — concatenar `pbxproj` é
como concatenar um banco. Suíte na árvore mesclada, que ninguém dos dois lados
tinha rodado: **973 testes em 156 suítes, verde**.

**A R1 recebeu CORRIGIR ANTES, e a recusa dela foi confirmada:** o revisor
escreveu que **o contrato determinístico é bom e que não rolar automaticamente
está CORRETO**. O que trava é a régua nova do dono: **as seis fases do
design-router citadas**, a **curva-zero em toques e gestos** (ela mediu em telas
de rolagem, que é distância percorrida e não esforço), e a **Complexidade 8 que
ela mesma marcou** — honestidade boa, que agora tem de virar 9 ou descer o diff.

**A Q2-C parou de novo**: a fumaça às 05:42:01Z gravou `contaGrokLigada:false`,
zero chamadas, e ela **não instalou nada**. `responder` segue não aprovada, e as
cinco dimensões ficam **inconclusivas** — que é a palavra certa, e não "reprovada".

Despachei **R1-B** e **F5b-B**. A F5b-B tem a régua do revisor: **teste de
request/update** (o que falha se alguém parar de passar o `relevanceScore` na
publicação), **semeadura que de fato publica** para qualquer um reproduzir, e os
pares `large`/AX5 com **log versionado**, não citado.

## 09/09, 03h — pausa e retomada (uso 9%); a S1 abre, e a C1-B já reproduziu o resíduo

Pausa e retomada registradas. As três frentes seguem, e a **C1-B fez o certo logo
de saída**: em vez de aceitar a alegação dos 220 screenshots, montou uma **sonda
por quadro** e **reproduziu o resíduo da gaveta**. Medir o fenômeno antes de
decidir entre consertar e contratualizar é a única ordem que sustenta a decisão.

**Quarta frente aberta: S1**, a pergunta interrompida que some ao trocar de aba
(`task_797fb1e2bf64`, Opus 5, ADR `09c`). É o segundo achado da V13, e o RUMO já
nomeava o dono: *"é estado desonesto — a pessoa perde o que estava esperando sem
que nada diga"*, com o conserto na `Sessao` e não na view, porque `RaizView`
**recria** a `NotasView` ao trocar de aba.

O spec nasce com duas coisas que o dia ensinou. A primeira: **conferir na tela
viva antes de codar**, porque hoje já foi três vezes que um defeito anotado tinha
caído sozinho — a última na R1, que achou o defeito 1 do próprio G0 dela já morto.
A segunda: **a honestidade é a entrega, não só a persistência** — se em algum
caminho a pergunta não puder sobreviver, a tela **diz**; o que não pode é sumir em
silêncio.

Escolhi esta e não outra da fila porque **as voltas de IA estão todas travadas na
conta caída** — `responderNasNotas`, `instigar`, `contrapor`, `ecos`, `calibragem`
e `recordar` precisam do Grok, e ele só volta com o dono. A S1 não precisa de
nada além do aparelho.

## 09/09, 04h — pausa e retomada (uso 14%); as três correções voltaram, e a C1 escolheu consertar

Pausa e retomada registradas. **A C1-B escolheu o caminho (a): consertou** —
*"nenhuma gaveta corre sobre a linha do autor"*. Ela podia ter escrito uma exceção
na ADR 08f, que era o caminho (b) e o mais barato; preferiu **medir primeiro com
uma sonda por quadro, reproduzir o resíduo, e então tirá-lo**. É a ordem certa, e
o resultado que ela relata é o único que fecha a invariante escrita sem exceção:
**0 quadros fora nos dois tamanhos**.

A **R1-B** voltou com a régua do dono (as seis fases, a curva-zero em toques e a
Complexidade resolvida) e a **F5b-B** com as três provas que o revisor nomeou —
teste que **morde o wiring**, semeadura que **publica pela rota real**, e os pares
`large`/AX5 com **log versionado**.

Mandei os três de volta ao **mesmo revisor** que os recusou, cada um com a lista
ponto a ponto do que ele mesmo exigiu, e com a instrução de **quebrar o teste do
wiring com as próprias mãos** em vez de aceitar que ele morde.

Um detalhe de máquina que funcionou sozinho: a F5b-B avisou no batimento que
**outro worker estava rodando `xcodebuild test` no `6033B043`** — era a C1-B
fazendo a prova do Pro Max que eu autorizei — e **esperou a trava** em vez de
disputar. Foi a primeira vez no dia que duas voltas dividiram um aparelho sem
incidente, e o que fez a diferença foi o aviso no comentário do worktree, que a
DIRETRIZ §7 tornou obrigatório.

**As duas travadas em você continuam paradas:** a conta Grok caída segura a Q2 e
as outras seis operações; a tela do Mac trancada segura a MAC-0.

## 09/09, 05h — pausa e retomada (uso 15%); o vídeo que mostrava a Tela Inicial

**O revisor da C1 abriu o vídeo.** A C1-B versionou um MP4 anunciado como "a
gaveta consertada" e ele contém **44,04 s da Tela Inicial, sem o Traço**. A
sequência textual carimbada da mesma passada é boa; o vídeo era **prova falsa**, e
o que separou uma coisa da outra foi alguém **abrir o arquivo**. Virou lei:
**prova que ninguém olhou não é prova** — caminho de arquivo no relatório é
promessa, não evidência.

Ele também achou que **a sonda nova mede metade da invariante**: `E ⊆ P` sim,
`P ∩ O = ∅` não. Uma sonda que só reprova metade da regra **dá um verde** para a
outra metade, o que é pior do que não ter sonda. Também virou lei.

**E ainda assim a C1-B fez a coisa mais bonita da noite:** o instrumento por
quadro que ela montou (`CADisplayLink` sobre as camadas de apresentação)
**corrigiu duas medidas dela contra ela mesma** — o resíduo é de 0,098 s (AX5) e
0,100 s (large), 6 quadros cada, e **não era só de AX XXXL**, como a C1 e eu
vínhamos repetindo desde o relato da V13. Construir o instrumento que te desmente
é o oposto de escrever a frase que te convém.

**A R1-B trocou de instrumento por um motivo que vira lei irmã:** o helper do
`orca emulator` devolveu **`ok:true` sem mover a tela**. Ela mediu a curva-zero
por XCUITest e a medida ficou boa: antes **3 toques + 5 arrastos + 6 paradas** de
leitura para saber sete coisas; depois **3 toques + 0 arrastos + 1 parada**, com
os sete fatos na primeira tela. E resolveu a Complexidade com número: o código de
produção **desceu de 82 para 81 linhas**, com a migração para Componentes
**medida e recusada** porque acrescentaria 25–30 linhas para um chamador só.

**A F5b-B ganhou um grupo de controle sem pedir:** o `xcodebuild test` de outro
worker instalou no `6033B043` um binário **sem a 08v**, e a Ilha voltou ao
Destaque **com a mesma projeção**. Prova por ausência, que vale mais que uma
captura a mais. O senão é de processo: aquele worker usou o aparelho **sem avisar
no comentário do worktree**, que a DIRETRIZ §7 tornou obrigatório — fica
registrado, sem culpa da F5b, que anotou.

Os dois re-G3 recusaram de novo (C1 pela prova temporal, F5b pelo corte em AX5 e
pelas seis fases), e despachei **C1-C**, **F5b-C** e a **revisão da S1**, que
entregou a pergunta que não some mais ao trocar de aba.

## 09/09, 06h — pausa e retomada (uso 2%); a S1 pegou o próprio verde falso

**A S1 fechou, e o que ela achou sobre si mesma vale mais que o conserto.** O
conserto é pequeno e certo: a `ConversaNotas` sai do `@State` da `NotasView` e vai
para a `Sessao` — **3 linhas de código, +14 −2** — e com ela vieram junto a
pergunta guardada, as trocas, o aviso de "sem conta" e a busca em edição.

Mas o achado é este: **a primeira corrida do teste dela passou VERDE sem visitar
o defeito.** Com o campo de busca em foco, **a barra de navegação some inteira**,
e o toque do teste caiu numa tecla do teclado. Ela percebeu, nomeou o colateral, e
consertou o teste — que agora **solta o teclado por arrasto e exige
`calendario-titulo` como pré-condição**. É a lei do "verde que não visitou o lugar
do defeito" **pega pelo próprio autor**, que é a única forma barata de pegá-la.

Ela também declarou o que **não** consertou, na classe certa: filtro, domínio,
ordem e lote **também** morrem na recriação, **mas a tela mostra isso no mesmo
quadro** — outra classe de problema, anotada e não remendada.

E a suíte dela travou antes de conectar na primeira corrida: **mostrou as duas
saídas** e não contou a travada como resultado, exatamente como a lei de ontem
manda. 973 testes em 156 suítes na repetida.

**Uma pergunta de revisor virou regra.** Ele perguntou se podia montar um checkout
descartável do pai em `/tmp` para reproduzir o vermelho, porque *"só no seu
worktree"* deixava isso ambíguo. **Pode, e deve** — foi assim que o revisor da C1
produziu a melhor prova da noite, trazendo **só a sonda** do candidato para o pai.
Está na ESTEIRA e no preâmbulo, com as condições. Perguntar em vez de supor é o
que faz uma regra melhorar em vez de ser contornada em silêncio.

Os dois re-G3 recusaram com prova reexecutada — a C1 pela sonda que mede metade e
pelo vídeo vazio, a F5b pelo corte em AX5 e pelas seis fases —, e a **C1-C**,
a **F5b-C** e a **revisão da S1** já estão em curso.

## 09/09, 07h — pausa e retomada (uso 2%); a R1 aprovada, e o verde que só era verde numa máquina

**A R1 PASSOU no re-G3**, e o revisor não acreditou na medida dela: **mediu de
novo por conta própria** — antes **3 toques + 5 arrastos**, depois **3 + 0**, com
**7 de 7 fatos na tela inicial** — e reexecutou os testes de teto, reabertura,
primeira visita e AX5. **9 em toda dimensão aplicável.** O que falta é
integração: `main` está **25 commits à frente** com quatro caminhos alterados dos
dois lados. Despachei a **R1-C** com a lei que a Q-H fixou: **aprovado não é
mesclável**, e teste que fica vermelho na fusão **é o achado**.

**A S1 foi reprovada por um vermelho que ela não vê.** Ela relatou 973 verdes; o
revisor rodou **o mesmo candidato** e os dois testes novos dela deram **3
falhas**. Nenhum dos dois mentiu — o teste depende de estado que um tinha e o
outro não, e a causa provável é a que ela mesma nomeou: **com a busca em foco a
barra de navegação some inteira**, e o toque cai numa tecla. Ela já tinha
consertado por esse caminho uma vez; **voltou a falhar para outra pessoa**.

Virou lei: **teste de jornada nova roda dez vezes seguidas, do zero, e as dez
saídas vão no relato** — um teste que passa 9 de 10 **não passa**, é um teste que
mente uma vez em dez. E toda pré-condição de estado mora **dentro** do teste, em
vez de o teste tocar às cegas. A S1-B saiu com isso, e com a proibição explícita
de afrouxar a asserção para ficar verde.

**A F5b-C consertou o corte em AX5** (o `Text` de data guloso, domado por um teto
de 92 pt que saiu) e fez três coisas que valem nota: versionou **o passo
intermediário que não serviu**, nomeou o **grupo de controle** acidental como
prova por ausência, e **disse que nada de unidade prova alinhamento de `Text`** —
declarar o limite do instrumento em vez de fabricar um teste que não mede nada.

Quatro frentes rodando: **R1-C**, **S1-B**, e os **terceiros re-G3 da C1 e da
F5b**.

## 09/09, 08h — pausa e retomada (uso 4%); duas aprovações, e a sonda que se desmentiu duas vezes

**A C1 e a F5b passaram no mérito.** A F5b **mesclou** (`d5f77e2`), com a suíte na árvore mesclada em **974 testes em 156 suítes, verde**; a C1 ficou
"aprovada e **não mesclável**", e foi para a C1-D reconciliar — a mesma lei da
Q-H, agora aplicada sem eu precisar redescobri-la.

**O relato da C1-C é o melhor exemplo do dia da régua funcionando por dentro.**
Ela achou **duas coisas contra si mesma** e escreveu as duas:

- **o primeiro vermelho da metade nova era FALSO** — uma camada sem
  `presentation()` **ainda não foi entregue ao render**, e lê-la pelo modelo é
  lê-la na geometria de destino;
- **`E` saía com 2 pt de largura**, porque no fim do documento o TextKit 2 não
  devolve fragmento e a linha ativa ficava só com o `caretRect` (agora 322 pt em
  AX5).

E plantou **uma camada adversarial dentro do próprio teste** para provar que o
portão sabe reprovar (35 de ~51 quadros acusados). Com a sonda inteira, o pai fica
vermelho **nas duas metades**: o cartão **desenhava por cima** da linha, não só a
cortava — coisa que a metade que faltava nunca teria visto.

O MP4 falso foi **removido**, não corrigido no texto: entrou um vídeo novo,
gravado na corrida verde e **assistido quadro a quadro antes de versionar**.

**A S1 foi reprovada com o defeito nomeado:** a pré-condição diz que o Calendário
não abriu e o hit point foi `{-1,-1}`, enquanto a captura mostra o cartão **sem a
barra de abas**. É a barra que some com a busca em foco, de novo — a S1-B está
nela, com a regra nova das dez corridas.

**O `ask` da C1 expirou aos 600 s** perguntando se o Pro Max estava livre, e ela
seguiu pelo caminho menos destrutivo: **declarou a prova como herdada** em vez de
tomar o aparelho de outra volta. Foi a decisão certa; e agora que a F5b mesclou, a
C1-D fecha essa ponta.

## 09/09, 09h — pausa e retomada (uso 6%); o vermelho da fusão entregou o defeito mais grave do laço

Eu escrevi no spec da R1-C que **"teste que fica vermelho na fusão É O ACHADO, não
um estorvo"**. Foi literalmente isso: os quatro testes de tela da R1 ficaram
vermelhos na árvore mesclada, ela **não afrouxou nada** — mediu **no mesmo store e
no mesmo aparelho, em três builds** — e o que saiu de lá é o defeito mais grave
que este laço achou:

**um caderno gravado antes da ADR 08u não abre mais.** `e72dd85` abre; **`main`
sozinho e a árvore mesclada param no arranque honesto da A1** com
`loadIssueModelContainer`. **Não é da fusão. É do `main`.**

Duas coisas ao mesmo tempo, e as duas verdadeiras: **a rede da A1 funcionou** —
nada foi destruído, o arranque recusou abrir e disse o que houve, que é
exatamente para isso que ela existe — **e a porta está fechada**, o que não é
aceitável.

O dono mandou **abrir a migração como topo da fila, acima da IA e do resto**.
Abri a **M1** (`ctx_b7108b4acac5`, ADR `09f`), com três exigências: **reproduzir o
vermelho com um store real pré-08u antes de consertar**, **confirmar ou derrubar a
hipótese** do comentário da `Migracao.swift` (que `VersionedSchema` apontando para
a classe viva não congela nada), e **deixar o portão que faltava** — um teste que
abre um **store congelado de cada versão**.

**Por que nenhum teste pegou**, e isso é a lição: os testes de `DiscoTraco`
**injetam closures** e **nunca abriram um store antigo de verdade**. Um portão que
nunca viu o passado não guarda o passado.

A **S1-B** e a **C1-D** também entregaram — a S1-B com um achado próprio ("o vazio
também rola: quem filtrava as Notas até zero ficava preso atrás do teclado") e a
C1-D com a reconciliação e a ADR `09e`.

## 09/09, 10h — pausa e retomada (uso 7%); a M1 achou a frase que explica tudo

**"Um `VersionedSchema` que aponta para a CLASSE VIVA não congela nada: é um
apelido para 'o código de hoje', e o checksum dele anda junto com o código."**

É isso. O store guarda o checksum do dia em que foi gravado (`4.0.0`,
`ImY8W7hR8jJH+…`); quando a 08u pôs `origemRaw` na `Nota`, a V4 passou a valer
`2AijN0DBwZ…`, **nenhuma versão do plano casou com o caderno do autor**, e o
CoreData recusou tudo — `NSCocoaErrorDomain 134504, "Cannot use staged migration
with an unknown model version"`. A frase que fecha o diagnóstico:
**"o erro da 08u não foi acrescentar atributo com padrão: foi acrescentá-lo sem
abrir versão"**.

O conserto: V2, V3 e V4 passam a declarar **cópias congeladas**; a **V5 é a única
com as classes vivas**; estágio V4→V5 leve. Provado com um **store REAL** gravado
pelo build `8d9ce62`. Despachei a revisão com o peso que ela tem: **se aprovar
errado, o caderno do dono fica fechado** — e com a exigência de **reproduzir o
vermelho com store próprio** e de **quebrar o portão novo** para vê-lo reprovar.

**A escalação da R1-C tinha a causa exata antes de mim:** *"o `ZNOTA` daquele
store não tem `ZORIGEMRAW` (`PRAGMA table_info`)"*. Ela mediu, escalou, **e não
consertou** — porque o mandato dela era integração e *"migração de esquema com o
caderno do dono em jogo é volta própria"*. Saber onde parar é o que fez o defeito
chegar inteiro à volta certa.

**A S1-B fechou o caso do teste que mentia**, e a causa é melhor que a hipótese: a
busca terminava valendo `o que eu aprendi ontem**gggd**` — os quatro toques na aba
viraram **quatro letras**, porque `NotasView.lista` tem dois ramos e **só o CHEIO
tinha `.scrollDismissesKeyboard`**. Os testes filtram até zero e caem sempre no
ramo **VAZIO**, que era um `VStack` sem gesto. *"O teste passava para quem tinha
notas no aparelho e falhava para quem abria o app limpo — media o lixo da corrida
anterior."* Ela **consertou no produto, não no teste**, com a razão certa:
**filtrar até zero com o teclado em pé PRENDE a pessoa**. 10 de 10 corridas do
zero, com `shutdown`+`boot`+`uninstall` a cada uma.

**A C1-D fechou as duas pendências** — o Pro Max reexecutado (a ressalva de "prova
herdada" sai) e o teclado emulado explicado — e achou o que eu não tinha visto:
**a etiqueta de origem que o `main` pôs acima do editor come 30 pt de papel em
AX5**, exatamente onde a invariante mede o aperto. Ela passou a medir esse estado,
com portão que reprova se a cápsula não desenhar.

**E a terceira colisão de letra do laço foi minha de novo:** reservei `09d` para a
S1-B e a C1-D tomou a mesma letra no mesmo turno, porque eu **não atualizei o
`LETRAS-ADR.md` no ato**. A C1 passa a `09g`. O arquivo também **estava errado
sobre si mesmo** — dava `08z` como livre quando ela está no branch da Q2 —, o que
a própria C1-D pegou. Corrigi as duas coisas e escrevi a regra que faltava:
**quem despacha atualiza o registro no mesmo ato em que reserva**.

## 09/09, 10h30 — o dono está indignado, e ele tem razão na conta

*"Esse tempo todo e ainda é 7."* Ele mede **a nota do produto**, não voltas
mescladas — e pela conta dele a noite rendeu pouco. Vale escrever por quê, sem
desculpa e sem enfeite:

**cinco voltas mescladas** (A1, V13, Q, MAC-1, F5b) moveram Estado honesto,
Contrato, Design e Fora do app — **nenhuma delas move a nota da IA**, que é a
dimensão que ele quer ver subir. **As sete operações da IA continuam
indisponíveis.** A Q2 mediu o conserto e **não pôde fechar**: a conta caiu duas
vezes, e caiu porque **a lei que eu escrevi permitia instalar por cima**. Essa
parte é minha: a lei era minha, o gatilho apareceu por medição de um revisor, e
entre uma coisa e a outra passou uma noite.

**As três ordens dele, registradas:**

1. **Nada de reinstalar por cima no `C2416CBC`.** A sonda roda **no build já
   instalado**; binário novo entra **uma vez por volta**, com `ContaGrok.ligada`
   conferido **antes e depois**. Reescrevi a lei na ESTEIRA e no preâmbulo com
   essas palavras.
2. **Assim que a M1 mesclar, as três frentes são IA:** **Q2** (responder), **Q3**
   (responder nas Notas) e **Q4** (instigar + contrapor), em paralelo, **cada uma
   com o seu simulador sem conta** para tudo que não seja a medição, e o
   `C2416CBC` **só para a corrida da sonda, serializada pela trava**. Os specs da
   Q3 e da Q4 já estão escritos e as letras reservadas (`09h`, `09i`) — abrem no
   minuto em que a M1 entrar.
3. **Cada fecho de IA termina com a linha do Perfil atualizada e a captura do
   cartão com a resposta real na tela.** *"O dono quer VER a IA funcionando"* —
   JSONL não é tela. Está na ESTEIRA como parte do portão, não como pedido.

**A M1 é o que segura tudo agora**, e ela segura pelo motivo certo: enquanto o
caderno gravado antes da 08u não abrir, nenhuma nota importa. A revisão dela está
em curso com o peso escrito no spec: **se aprovar errado, o caderno do dono fica
fechado**.
