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
| F3 | Captar pensamento em um toque | MESCLADA (ADR 05w): controle Anotar na Central/bloqueada/botão de Ação abre o app com teclado pronto e microfone a um toque; F3b = ditado próprio com áudio preservado |
| F3b | Ditado próprio | áudio salvo antes de transcrever; falha preserva o áudio | EM EDIÇÃO (worktree f3b-ditado, 06/09 12:55) |
| F4 | **Os widgets da tela de início prestam** (era "widget próxima volta interativo") | refresh que funciona, identidade do Traço, vazio que oferece ação, densidade do médio, botão de feito na própria superfície | **EM EDIÇÃO, PRIORIDADE MÁXIMA** (worktree f4-widgets; ordem do dono 06/09 13:04, com print do iPhone) |
| F5 | Ilha do compromisso vivo | estados completos (compacta, expandida, mínima, fim) | |
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
| M3 | colagem no catálogo dos SETE + conserto do roteamento | EM EDIÇÃO (a V16 mesclou em 968ba34) |

**G0 de M1.** Ciclo: melhorar (o catálogo é o repertório de instrumentos de pensamento do autor). Intenção: o autor encontra o instrumento certo para o movimento que está tentando fazer, e sabe de onde ele vem. Obstáculo: 21 métodos e nenhuma rotina de entrada; sem critério escrito, catálogo vira lista de produtividade. Evidência: três a cinco fichas com JSON completo e fonte primária citada literalmente, um rejeitado com a barra em que caiu, e a saída do teste das regex contra os outros 20. Quando a forma proposta pedir algo que o app ainda não faz, a ficha nomeia isso e eu abro a volta. Escopo: só `ferramentas/orca/metodos/`; `Traco/Modelo/Metodos.json` fica fechado até a V16 mesclar.

**G0 de M3 (colagem).** Ciclo: melhorar. Intenção: os quatro métodos novos entram no catálogo sem quebrar o roteamento nem a proteção da escrita pessoal. Decisão do dono, 06/09 13:40: **os quatro aprovados** — Subtração (simplificação), Coluna da esquerda (relação), Classe de referência (previsão) e Cinco porquês (causa), este último condicionado a a M2 fechar a citação de Ohno na fonte primária ou trocá-la por uma verificável; método do catálogo não carrega frase que ninguém do Traço leu no original. Colar no FIM do catálogo: a M1 mediu que colar antes da Especificação faz a Coluna da esquerda roubar o desabafo da Expressiva — a proteção da escrita pessoal depende da ordem. No mesmo passo, e por decisão do dono na mesma data, consertar o roteamento do Se–então (`sempre que|toda vez|não consigo parar` sem `\b`, que casa dentro de "sempre quebra" e "sempre queria") com teste que fixe a correção. Os cinco desvios pré-existentes que a M1 mediu ficam nomeados para uma volta de roteamento própria, se o dono quiser. Escopo: Traco/Modelo/Metodos.json, TracoTests/CatalogoTests.swift, ferramentas/orca/metodos/; só abre depois de a V16 mesclar em main.

## Política de peso das evidências

PNG de captura ≤ 400 KB (reduzir com `sips -Z 1000` antes de commitar), vídeo ≤ 3 MB (≤ 20 s, `-crf 30`), hierarquias em texto. F1 somou 52 MB e V9 82 MB: a partir da V10 o G5 recusa evidência acima disso.

## Estado do laço

Retomada 06/09 12:48 (queda por cota do Fable às 5:40; ver LACO). Fable semanal em 100% até as 20:00: TODO worker em Opus 5, nenhum `--model fable`. Pote que vale: semanal de todos os modelos, 55% usado. Ordem do dono: rodar até acabar essa cota; prioridade para as telas abaixo de 9 da auditoria V9, Trabalho (6,0) e Recordar (6,2) na frente, depois as superfícies fora do app, depois o resto desta lista. Skills viraram portão (ESTEIRA, "Skills obrigatórias por portão").

Sete frentes: **V12** Página e Caderno até 9 (FECHADA no worktree, topo 337a22e, −55 linhas líquidas, suíte 716/0 — em G3); **V16** métodos com proveniência (G3 INTEGRAR, G4 CORRIGIR ANTES por Movimento 8 — V16-C corrige a abertura do Perfil); **V18** Trabalho até 9 (front-end); **V11** ambiente Markdown (implementador); trilha fora do app: **F4** os widgets da tela de início (PRIORIDADE MÁXIMA do dono) e **F3b** ditado próprio; trilha métodos: **M1** primeira rodada. Próxima a abrir quando uma fechar: Recordar até 9 (6,2), a segunda pior da auditoria.

**F3b — Ditado próprio: o áudio antes da letra.** Ciclo: multiplicar. Intenção: falar uma frase na rua e ela entrar no Traço mesmo que a transcrição falhe. Obstáculo: a F3 entregou o controle Anotar com o teclado pronto e o microfone a um toque, mas quem transcreve é o ditado do teclado do iOS — falha, morte do app ou falta de rede não deixam nada; a ADR 05a manda o contrário: áudio depositado primeiro, letra depois, falha preserva o áudio. Evidência: gravação depositada antes de qualquer transcrição; nota com a transcrição marcada com origem "ditado" e o áudio localizável a partir dela; falha encenada mostrando a nota com o áudio e uma linha honesta; microfone/reconhecimento negados ditos na tela; capturas de cada estado em large e AX5, vídeo com e sem Reduzir Movimento, testes do depósito e do caminho de falha. Escopo: Traco/App/Intents/*, ponto de entrada da captura, áudio no App Group, TracoTests; campo de modelo só o mínimo aditivo (referência ao arquivo, nunca blob).

**V18 — Trabalho até 9.** Ciclo: multiplicar (é onde a intenção vira artefato e ação). Intenção: pedir, acompanhar, conferir e praticar num caminho só, sem decisões antes da hora e sem parecer outro aplicativo. Obstáculo: 6,0, a pior da auditoria V9 (§6) — Design 5 (formulário cru, o mesmo botão com duas roupas), Simplicidade 5 (cinco telas, oito DisclosureGroup, "Preparar com IA" desabilitado sem parecer), Componentes 4 (AcaoTrabalhoStyle próprio, zero tokens), Acessibilidade 7 (alvo por reserva), Estado honesto 8 (promessa de aviso não autorizada, ADR 04a); curva-zero: 6 toques e 2 digitações até a versão, com a decisão de apoio escondida num disclosure. Evidência: capturas antes/depois em large e AX5 de todos os estados do G2, vídeo com e sem RM, contagem de toques antes/depois, shortstat líquido-negativo, suíte verde. Escopo: as views de Traco/Trabalho (sem Intercambio*, que é da V11) e TracoTests; consome Traco/Componentes e Tema sem editá-los (V12 está dentro deles).

## Próximas, em ordem

| # | volta | valor | esforço | ciclo | lacuna (EVOLUCAO) |
|---|---|---|---|---|---|
| 1 | V9 Auditoria de front-end: nota base por tela | MESCLADA (ferramentas/orca/auditoria-frontend.md) — médias: Página 6,7 · Notas 7,0 · Calendário 7,2 · Recordar 6,2 · Perfil 7,7 · Trabalho 6,0 · Padrões 7,5 · Camadas 7,5 | — | multiplicar | "Direção visual e uso simples" |
| 2 | V10 Fundação de design: tokens, Traco/Componentes com previews, biblioteca de movimento | MESCLADA (ADR 05v). Regra vigente: cada volta por tela é líquido-negativa ao migrar para Componentes | — | multiplicar + eixo 4 | idem |
| 3 | V11 Ambiente Markdown: conflitos e retry na UI real, revogação com seletor aberto | EM EDIÇÃO (worktree volta-11-markdown) | M | multiplicar | "Ambiente Markdown compartilhado" |
| 4 | V12 Telas até 9: Página e Caderno (a porta de entrada) — EM EDIÇÃO; inclui: cartão da forma cobre régua/ações e em AX esconde ações (V9 alto); indicador de rolagem do cartão em AX (G4 V8); .primario/.compacto com opacidade no press (ADR 02h) e célula nova com mola de classe errada (G4 V10); crossfade de aba com quadro cinza; 'pular'/aba do arquivo estreitos; Camadas anima antes do binding (re-G3 V7); migrar Página/Caderno para Componentes líquido-negativo | alto | M | multiplicar | nota base 6,7 |
| 5 | V13 Telas até 9: Notas e barra de baixo | alto | M | multiplicar | nota base da V9 |
| 6 | V14 Calendário: duração explícita e estados de navegação/acessibilidade | médio | M | multiplicar | "Calendário ligado à realização" |
| 7 | V15 Telas até 9: Calendário e ficha | médio | M | multiplicar | nota base da V9 |
| 8 | V16 Métodos com proveniência: fonte, adaptação, evidência; método ausente dito na tela | MESCLADA (ADR 05x; G3, G4, V16-C, re-G4) | M | melhorar | "Métodos e pesquisa com proveniência" |
| 9 | V17 HTML útil e interativo (consulta ao conselho antes) | alto, incerto | G | multiplicar | "HTML útil e interativo" |
| 10 | V18 Telas até 9: Trabalho (versão, conferência, prática num cartão só); do G4 da V6: porta da prática escondida, Dificuldade antes de Preparar em delegar, AcaoTrabalhoStyle sem estado desabilitado visível | EM EDIÇÃO (worktree volta-18-trabalho) — subiu ao topo pela ordem do dono de 06/09: telas abaixo de 9 primeiro, Trabalho (6,0) na frente | M | multiplicar | nota base da V9 (Trabalho 6,0); Simplicidade |
| 11 | V19 Retrato/Trajetória recebem a prática (só se V6 provar prática real) | médio | M | melhorar | "Modelo revisável do autor" |
| 12 | V20 Domínios amplos: segundo caso real (criação ou organização) | alto, depende do dono | G | ambos | "Domínios amplos de realização" |

## Linha G0 das três primeiras

**V9 — Auditoria de front-end.** Ciclo: multiplicar (realizar com uso simples). Intenção: o autor escreve, acha e marca sem pensar na ferramenta. Obstáculo: não existe nota por tela; a última auditoria (ADR 05f) foi por captura do dono, não por scorecard. Evidência: ferramentas/orca/auditoria-frontend.md com, para cada tela (Página+Caderno, Notas+barra, Calendário+ficha, Recordar, Perfil, Trabalho, Padrões), capturas simctl nos estados do G2, nota 0-10 nas dimensões Design, Simplicidade, Movimento, Componentes, Acessibilidade, Estado honesto, com o defeito nomeado e a lei (design-router fase auditar; curva-zero). Escopo: nenhum arquivo de código; só relatório e capturas. Sem código, G1 é n/a; G3 confere a fidelidade das capturas e a calibragem das notas.

**V10 — Fundação de design.** Ciclo: multiplicar + eixo 4. Intenção: toda tela nasce dos mesmos tokens, componentes e movimentos. Obstáculo: Tema.swift tem tokens parciais, componentes repetidos por tela (cápsulas, chips, linhas de estado, disclosures), animações com curvas e durações soltas e reduce motion tratado em 10 arquivos. Evidência: Traco/Componentes/*.swift com preview por estado (normal, vazio, carregando, falha, desabilitado, AX5), Tema.swift com tokens nomeados (cor, tipo, espaço, raio, sombra, duração, curva), `Tema.movimento` que devolve o movimento certo sob reduce motion, e pelo menos três telas migradas sem mudança visual (captura antes = depois); suíte verde; shortstat com linhas líquidas ≤ 0. Escopo: Tema.swift, Traco/Componentes (novo), e as três telas migradas; duas frentes disjuntas (tokens+movimento em Tema / componentes+previews). Sistema: SISTEMA-CLARO.md.

**V11 — Ambiente Markdown: conflitos e retry.** Ciclo: multiplicar. Intenção: o autor edita o Trabalho fora do Traço e volta sem perder nada, mesmo quando as duas pontas mudaram. Obstáculo: ADR 05l provou o retorno feliz; conflito (base antiga com nova versão local), retry após recusa de commit e revogação da origem com o seletor/exportador aberto não têm prova na UI. Evidência: prévia de conflito com as duas versões e escolha explícita (nova versão, nunca sobrescrita), retry que confirma a mesma versão sem duplicar, seletor aberto + selar a origem → material recolhido com linha honesta; testes + capturas dos estados + fluxo maestro em simulador de teste. Escopo: Traco/Trabalho/{IntercambioTrabalho,IntercambioTrabalhoView}.swift e testes; depende da V6 mesclada.
