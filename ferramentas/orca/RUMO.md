# Rumo — as próximas voltas do laço, por valor

Mantido pelo orquestrador a cada fecho (ESTEIRA.md). Volta que não está aqui não abre. Ordem = valor para a visão (dois ciclos) ÷ esforço, com a regra da frente de front-end: auditoria → fundação → telas. Notas de tela no scorecard só existem depois da V9.

## Em curso (05/09 à noite, modo Fable máximo)

| volta | tema | área | estado |
|---|---|---|---|
| V6 | prática no Trabalho (ADR 05r) | Traco/Trabalho | G3 em curso (revisor Fable); G4 depois |
| V7 | integridade e selo nas rotas restantes (ADR 05s) | Sessao, Corpus/Indice/Holofote, Modelo | MESCLADA em main |
| V8 | acessibilidade real: VoiceOver, movimento reduzido, AX5 (ADR 05t) | views de Pagina/Notas/Caderno/Calendario/App, Tema | editando; G4 obrigatório |

## Trilha própria: Fora do app (Fable permanente; brief em papeis/fora-do-app.md)

Sempre uma volta desta trilha em edição, em paralelo às voltas comuns, no próprio worktree e pelos mesmos portões. Dimensão "Fora do app" do scorecard.

| # | volta | superfície / entrega | estado |
|---|---|---|---|
| F1 | Auditoria fora do app | inventário com 24 capturas reais, nota base por superfície, lacunas F2-F11, conselho gravado (ferramentas/orca/auditoria-fora-do-app.md, consulta-fora-intents.md) | MESCLADA em main |
| F2 | Fundação | conforme o conselho: sem framework; Traco/App/Intents/ nos dois alvos; app como único escritor de domínio; snapshot público versionado no App Group com generatedAt/validUntil e "desatualizado"; entidades mínimas com selo; DestaqueFeito/LembrarDepois com identidade do item e confirmação real; reload só dos kinds afetados; stale neutraliza ação | abrindo |
| F3 | Captar pensamento em um toque | controle na tela bloqueada + botão de Ação que abre o app já em ditado, ou anota por Siri sem abrir | |
| F4 | Widget "próxima volta" interativo | botão de feito na própria superfície | |
| F5 | Ilha do compromisso vivo | estados completos (compacta, expandida, mínima, fim) | |
| F6 | Widgets da tela bloqueada | accessoryCircular e accessoryInline do dia | |
| F7 | Controle da Central de Controle | Recordar | |
| F8 | Widget configurável | por pasta ou método | |
| F9 | Spotlight | notas e trabalhos, com selo | |
| F10 | Extensão de compartilhar | texto, link e imagem com origem preservada | |
| F11 | Sugestões de Siri | por horário | |

**G0 de F1.** Ciclo: multiplicar (o Traço presente onde a pessoa está, sem abrir o app). Intenção: saber, com captura real, o que cada superfície fora do app entrega hoje e quanto vale. Obstáculo: há widgets, Live Activities, 12 atalhos e 10 intents sem inventário nem nota; captura só no preview do Xcode não conta. Evidência: ferramentas/orca/auditoria-fora-do-app.md com capturas simctl por superfície e estado, nota 0-10 nas dimensões Fora do app, Design, Simplicidade, Movimento, Acessibilidade, Privacidade e Estado honesto, lista do que falta, e a consulta ao conselho gravada em consulta-fora-intents.md. Escopo: nenhum arquivo de código.

## Próximas, em ordem

| # | volta | valor | esforço | ciclo | lacuna (EVOLUCAO) |
|---|---|---|---|---|---|
| 1 | V9 Auditoria de front-end: nota base por tela | alto: sem ela toda volta visual é palpite | M (1 Fable, sem código) | multiplicar (uso simples) | "Direção visual e uso simples"; linha design-router |
| 2 | V10 Fundação de design: tokens, Traco/Componentes com previews, biblioteca de movimento | alto: cada tela depois sobe sobre isto | G (2 Fable: tokens+movimento / componentes) | multiplicar + eixo 4 | idem; Componentes e Movimento do scorecard |
| 3 | V11 Ambiente Markdown: conflitos e retry na UI real, revogação com seletor aberto | alto: continuidade entre ferramentas é a tese | M (1 Fable) | multiplicar | "Ambiente Markdown compartilhado" |
| 4 | V12 Telas até 9: Página e Caderno (a porta de entrada); inclui o achado do re-G3 da V7: Camadas anima a camada Notas antes do binding (fix de 2 linhas no onEnded do trilho) | alto | M | multiplicar | nota base da V9 |
| 5 | V13 Telas até 9: Notas e barra de baixo | alto | M | multiplicar | nota base da V9 |
| 6 | V14 Calendário: duração explícita e estados de navegação/acessibilidade | médio | M | multiplicar | "Calendário ligado à realização" |
| 7 | V15 Telas até 9: Calendário e ficha | médio | M | multiplicar | nota base da V9 |
| 8 | V16 Métodos com proveniência: fonte, adaptação, evidência; método ausente dito na tela | médio | M | melhorar | "Métodos e pesquisa com proveniência" |
| 9 | V17 HTML útil e interativo (consulta ao conselho antes) | alto, incerto | G | multiplicar | "HTML útil e interativo" |
| 10 | V18 Telas até 9: Trabalho (versão, conferência, prática num cartão só) | alto | M | multiplicar | nota base da V9; Simplicidade |
| 11 | V19 Retrato/Trajetória recebem a prática (só se V6 provar prática real) | médio | M | melhorar | "Modelo revisável do autor" |
| 12 | V20 Domínios amplos: segundo caso real (criação ou organização) | alto, depende do dono | G | ambos | "Domínios amplos de realização" |

## Linha G0 das três primeiras

**V9 — Auditoria de front-end.** Ciclo: multiplicar (realizar com uso simples). Intenção: o autor escreve, acha e marca sem pensar na ferramenta. Obstáculo: não existe nota por tela; a última auditoria (ADR 05f) foi por captura do dono, não por scorecard. Evidência: ferramentas/orca/auditoria-frontend.md com, para cada tela (Página+Caderno, Notas+barra, Calendário+ficha, Recordar, Perfil, Trabalho, Padrões), capturas simctl nos estados do G2, nota 0-10 nas dimensões Design, Simplicidade, Movimento, Componentes, Acessibilidade, Estado honesto, com o defeito nomeado e a lei (design-router fase auditar; curva-zero). Escopo: nenhum arquivo de código; só relatório e capturas. Sem código, G1 é n/a; G3 confere a fidelidade das capturas e a calibragem das notas.

**V10 — Fundação de design.** Ciclo: multiplicar + eixo 4. Intenção: toda tela nasce dos mesmos tokens, componentes e movimentos. Obstáculo: Tema.swift tem tokens parciais, componentes repetidos por tela (cápsulas, chips, linhas de estado, disclosures), animações com curvas e durações soltas e reduce motion tratado em 10 arquivos. Evidência: Traco/Componentes/*.swift com preview por estado (normal, vazio, carregando, falha, desabilitado, AX5), Tema.swift com tokens nomeados (cor, tipo, espaço, raio, sombra, duração, curva), `Tema.movimento` que devolve o movimento certo sob reduce motion, e pelo menos três telas migradas sem mudança visual (captura antes = depois); suíte verde; shortstat com linhas líquidas ≤ 0. Escopo: Tema.swift, Traco/Componentes (novo), e as três telas migradas; duas frentes disjuntas (tokens+movimento em Tema / componentes+previews). Sistema: SISTEMA-CLARO.md.

**V11 — Ambiente Markdown: conflitos e retry.** Ciclo: multiplicar. Intenção: o autor edita o Trabalho fora do Traço e volta sem perder nada, mesmo quando as duas pontas mudaram. Obstáculo: ADR 05l provou o retorno feliz; conflito (base antiga com nova versão local), retry após recusa de commit e revogação da origem com o seletor/exportador aberto não têm prova na UI. Evidência: prévia de conflito com as duas versões e escolha explícita (nova versão, nunca sobrescrita), retry que confirma a mesma versão sem duplicar, seletor aberto + selar a origem → material recolhido com linha honesta; testes + capturas dos estados + fluxo maestro em simulador de teste. Escopo: Traco/Trabalho/{IntercambioTrabalho,IntercambioTrabalhoView}.swift e testes; depende da V6 mesclada.
