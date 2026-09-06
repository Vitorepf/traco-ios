# Rumo — as próximas voltas do laço, por valor

Mantido pelo orquestrador a cada fecho (ESTEIRA.md). Volta que não está aqui não abre. Ordem = valor para a visão (dois ciclos) ÷ esforço, com a regra da frente de front-end: auditoria → fundação → telas. Notas de tela no scorecard só existem depois da V9.

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
| F3 | Captar pensamento em um toque | controle na tela bloqueada + botão de Ação que abre o app já em ditado, ou anota por Siri sem abrir | EM EDIÇÃO |
| F4 | Widget "próxima volta" interativo | botão de feito na própria superfície | |
| F5 | Ilha do compromisso vivo | estados completos (compacta, expandida, mínima, fim) | |
| F6 | Widgets da tela bloqueada | accessoryCircular e accessoryInline do dia | |
| F7 | Controle da Central de Controle | Recordar | |
| F8 | Widget configurável | por pasta ou método | |
| F9 | Spotlight | notas e trabalhos, com selo | |
| F10 | Extensão de compartilhar | texto, link e imagem com origem preservada | |
| F11 | Sugestões de Siri | por horário | |

**G0 de F1.** Ciclo: multiplicar (o Traço presente onde a pessoa está, sem abrir o app). Intenção: saber, com captura real, o que cada superfície fora do app entrega hoje e quanto vale. Obstáculo: há widgets, Live Activities, 12 atalhos e 10 intents sem inventário nem nota; captura só no preview do Xcode não conta. Evidência: ferramentas/orca/auditoria-fora-do-app.md com capturas simctl por superfície e estado, nota 0-10 nas dimensões Fora do app, Design, Simplicidade, Movimento, Acessibilidade, Privacidade e Estado honesto, lista do que falta, e a consulta ao conselho gravada em consulta-fora-intents.md. Escopo: nenhum arquivo de código.

## Política de peso das evidências

PNG de captura ≤ 400 KB (reduzir com `sips -Z 1000` antes de commitar), vídeo ≤ 3 MB (≤ 20 s, `-crf 30`), hierarquias em texto. F1 somou 52 MB e V9 82 MB: a partir da V10 o G5 recusa evidência acima disso.

## Estado do laço

Retomada 06/09 02:55 (janela nova). Em edição: V10 fundação de design (Fable A tokens+movimento, Fable B componentes+migração, worktree volta-10-fundacao); F2 correções + rebase; V6 re-G3. Próxima a abrir quando um simulador de teste liberar: V16 métodos com proveniência (Modelo + Perfil + LenteView, disjunta de V10 e V6).

## Próximas, em ordem

| # | volta | valor | esforço | ciclo | lacuna (EVOLUCAO) |
|---|---|---|---|---|---|
| 1 | V9 Auditoria de front-end: nota base por tela | MESCLADA (ferramentas/orca/auditoria-frontend.md) — médias: Página 6,7 · Notas 7,0 · Calendário 7,2 · Recordar 6,2 · Perfil 7,7 · Trabalho 6,0 · Padrões 7,5 · Camadas 7,5 | — | multiplicar | "Direção visual e uso simples" |
| 2 | V10 Fundação de design: tokens, Traco/Componentes com previews, biblioteca de movimento | MESCLADA (ADR 05v). Regra vigente: cada volta por tela é líquido-negativa ao migrar para Componentes | — | multiplicar + eixo 4 | idem |
| 3 | V11 Ambiente Markdown: conflitos e retry na UI real, revogação com seletor aberto | alto: continuidade entre ferramentas é a tese | M (1 Fable) | multiplicar | "Ambiente Markdown compartilhado" |
| 4 | V12 Telas até 9: Página e Caderno (a porta de entrada) — EM EDIÇÃO; inclui: cartão da forma cobre régua/ações e em AX esconde ações (V9 alto); indicador de rolagem do cartão em AX (G4 V8); .primario/.compacto com opacidade no press (ADR 02h) e célula nova com mola de classe errada (G4 V10); crossfade de aba com quadro cinza; 'pular'/aba do arquivo estreitos; Camadas anima antes do binding (re-G3 V7); migrar Página/Caderno para Componentes líquido-negativo | alto | M | multiplicar | nota base 6,7 |
| 5 | V13 Telas até 9: Notas e barra de baixo | alto | M | multiplicar | nota base da V9 |
| 6 | V14 Calendário: duração explícita e estados de navegação/acessibilidade | médio | M | multiplicar | "Calendário ligado à realização" |
| 7 | V15 Telas até 9: Calendário e ficha | médio | M | multiplicar | nota base da V9 |
| 8 | V16 Métodos com proveniência: fonte, adaptação, evidência; método ausente dito na tela | EM EDIÇÃO | M | melhorar | "Métodos e pesquisa com proveniência" |
| 9 | V17 HTML útil e interativo (consulta ao conselho antes) | alto, incerto | G | multiplicar | "HTML útil e interativo" |
| 10 | V18 Telas até 9: Trabalho (versão, conferência, prática num cartão só); do G4 da V6: porta da prática escondida, Dificuldade antes de Preparar em delegar, AcaoTrabalhoStyle sem estado desabilitado visível | alto | M | multiplicar | nota base da V9 (Trabalho 6,0); Simplicidade |
| 11 | V19 Retrato/Trajetória recebem a prática (só se V6 provar prática real) | médio | M | melhorar | "Modelo revisável do autor" |
| 12 | V20 Domínios amplos: segundo caso real (criação ou organização) | alto, depende do dono | G | ambos | "Domínios amplos de realização" |

## Linha G0 das três primeiras

**V9 — Auditoria de front-end.** Ciclo: multiplicar (realizar com uso simples). Intenção: o autor escreve, acha e marca sem pensar na ferramenta. Obstáculo: não existe nota por tela; a última auditoria (ADR 05f) foi por captura do dono, não por scorecard. Evidência: ferramentas/orca/auditoria-frontend.md com, para cada tela (Página+Caderno, Notas+barra, Calendário+ficha, Recordar, Perfil, Trabalho, Padrões), capturas simctl nos estados do G2, nota 0-10 nas dimensões Design, Simplicidade, Movimento, Componentes, Acessibilidade, Estado honesto, com o defeito nomeado e a lei (design-router fase auditar; curva-zero). Escopo: nenhum arquivo de código; só relatório e capturas. Sem código, G1 é n/a; G3 confere a fidelidade das capturas e a calibragem das notas.

**V10 — Fundação de design.** Ciclo: multiplicar + eixo 4. Intenção: toda tela nasce dos mesmos tokens, componentes e movimentos. Obstáculo: Tema.swift tem tokens parciais, componentes repetidos por tela (cápsulas, chips, linhas de estado, disclosures), animações com curvas e durações soltas e reduce motion tratado em 10 arquivos. Evidência: Traco/Componentes/*.swift com preview por estado (normal, vazio, carregando, falha, desabilitado, AX5), Tema.swift com tokens nomeados (cor, tipo, espaço, raio, sombra, duração, curva), `Tema.movimento` que devolve o movimento certo sob reduce motion, e pelo menos três telas migradas sem mudança visual (captura antes = depois); suíte verde; shortstat com linhas líquidas ≤ 0. Escopo: Tema.swift, Traco/Componentes (novo), e as três telas migradas; duas frentes disjuntas (tokens+movimento em Tema / componentes+previews). Sistema: SISTEMA-CLARO.md.

**V11 — Ambiente Markdown: conflitos e retry.** Ciclo: multiplicar. Intenção: o autor edita o Trabalho fora do Traço e volta sem perder nada, mesmo quando as duas pontas mudaram. Obstáculo: ADR 05l provou o retorno feliz; conflito (base antiga com nova versão local), retry após recusa de commit e revogação da origem com o seletor/exportador aberto não têm prova na UI. Evidência: prévia de conflito com as duas versões e escolha explícita (nova versão, nunca sobrescrita), retry que confirma a mesma versão sem duplicar, seletor aberto + selar a origem → material recolhido com linha honesta; testes + capturas dos estados + fluxo maestro em simulador de teste. Escopo: Traco/Trabalho/{IntercambioTrabalho,IntercambioTrabalhoView}.swift e testes; depende da V6 mesclada.
