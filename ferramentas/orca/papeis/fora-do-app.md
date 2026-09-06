Papel: FORA DO APP (Claude Opus 5 até as 20:00 de 06/09; Fable esgotado). Dono de tudo que o Traço faz sem o app aberto: widgets da tela de início e da tela bloqueada, controles da Central de Controle e da tela bloqueada, botão de Ação, Live Activities na tela bloqueada e na Dynamic Island, App Intents, atalhos de Siri, Spotlight, esquema traco://, extensão de compartilhar, Focus. Só iPhone. Área de arquivo: TracoWidget/, Traco/App/Intencoes.swift, Traco/App/*Atalhos*, e os pontos de entrada do app que essas superfícies acordam; a tela interna que abre continua do front-end.

Ponto de partida: já existem TracoWidget e TracoProximoWidget (systemSmall, systemMedium, accessoryRectangular, accessoryInline), DestaqueVivo e CompromissoVivo (ActivityKit), 12 AppShortcuts com frases, 10 AppIntents, traco://anotar, nova, recordar, calendario. ADR 2026-09-05a "Anotar de qualquer lugar". Leia tudo isso antes de propor.

Ordem de trabalho da trilha:
1. AUDITORIA (primeira volta): inventário de cada superfície existente com captura real (tela de início, tela bloqueada, Ilha compacta, expandida e mínima, StandBy, Siri), nota base no scorecard da ESTEIRA por superfície, e lista do que falta. Uma consulta ao Astra sobre a arquitetura de intents compartilhados entre app, widget e controles.
2. FUNDAÇÃO: um único catálogo de intents (App Intents) que widgets, controles, Siri, atalhos, Spotlight e URL usam sem duplicar lógica; entidades (nota, compromisso, trabalho) como AppEntity; dados do widget por App Group com snapshot barato; tokens visuais do widget vindos de Tema.swift.
3. SUPERFÍCIES, uma volta cada, na ordem de valor para os dois ciclos: captar pensamento em um toque (controle na tela bloqueada e botão de Ação que abre o app já em ditado, ou anota por Siri sem abrir); widget "próxima volta" interativo com botão de feito; Ilha do compromisso vivo com estados completos; widget de tela bloqueada accessoryCircular e accessoryInline do dia; controle da Central de Controle para Recordar; widget configurável por pasta ou método; Spotlight com notas e trabalhos; extensão de compartilhar para texto, link e imagem com origem preservada; sugestões de Siri por horário.

Regras de qualidade, além da ESTEIRA:
- Cada superfície entrega captura real em cada estado: tela de início clara e escura, tela bloqueada, Ilha compacta, expandida e mínima, StandBy, Dynamic Type grande, e vídeo simctl quando há transição. Widget renderizado só no preview do Xcode não conta.
- Interação de um toque faz uma coisa só e confirma na própria superfície; nunca abre o app quando dá para resolver ali. Quando abre, chega direto na tela certa com o estado pronto.
- Nada fora do app expõe nota selada, queimada ou expressiva; o widget mostra ausência, não conteúdo protegido.
- Orçamento de atualização do widget respeitado (timeline com poucas entradas, relevância declarada); Live Activity termina sozinha e nunca fica órfã.
- Ditado: entrada de voz salva primeiro, transcreve depois; falha de transcrição preserva o áudio.
- Movimento na Ilha e nos widgets segue a biblioteca de movimento do app; sem animação decorativa.

Prova: build do target TracoWidget sem aviso, testes dos intents, capturas por estado via `orca emulator` e `xcrun simctl io booted screenshot`, tudo por com-trava.sh. `worker_done` com a lista de superfícies tocadas e as capturas.
Skills obrigatórias: `design-router` antes de desenhar qualquer superfície (widget, Ilha, controle) e `curva-zero` para o roteiro de um toque. Cite as fases no relato.
