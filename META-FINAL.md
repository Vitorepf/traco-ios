# META — Traço: rumo ao estado final

Cola no início de toda sessão longa. Lê nesta ordem: SPEC.md → SISTEMA.md → isto.
SPEC é lei. Conflito código×spec → emenda a SPEC com ADR de 5 linhas ANTES de codar.
git commit atômico ao fim de CADA fatia. Se o repo tiver trabalho sem commit: commita AGORA, antes de tocar em qualquer coisa.

## ESTADO FINAL (o produto de 2 anos — o alvo de todas as filas)
iOS nativo impecável: o bloco mais simples do mercado, com IA que recusa escrever e multiplica a mente do autor.
**A BARRA (palavra do dono, 31/ago): instalar no iPhone e sentir um produto
ultra-profissional com ANOS de polimento — visual, movimento, experiência,
features. "Funciona e tem teste" NÃO é a barra; é o piso. Todo crítico julga
contra apps lapidados por anos (Apple Notes, Things, Craft). Motion se julga
em VÍDEO do app real, nunca só em screenshot.**
- IA real (xAI, chave no Keychain, JSON estrito, silêncio em erro) no lugar da heurística local; mesma lista fechada de permissões.
- Análise de padrões sobre anos de notas: perguntas citando frases literais do autor, nunca conclusões.
- Revisões agendadas: repetição espaçada sobre as notas do próprio autor, no dia certo.
- Escrita expressiva selada de ponta a ponta — nenhuma rota expõe (busca, revisão, padrões, índice, restauro).
- Corpus: export/backup .md legível, notas como arquivos versionáveis, import de MDs externos.
- Caderno maduro: Markdown invisível ao autor, portais (código/imagem/áudio/PDF), régua enxuta (≤12 formas — 136 é menu: podar e emendar a SPEC).
- Excelência de plataforma: Dynamic Type, VoiceOver, nota de 10k palavras fluida (parser incremental), swipe-back, háptica sóbria, pt/en, pronto para App Store.

## REFORMA DA LINGUAGEM — ✅ EXECUTADA 31/ago (ADR na SPEC): Notas · Analisar/Análise · Recordar · Padrões · Confirmação · Aviso
A nomenclatura atual (Porteiro, Puxar, Pilha, Códice, Véu, Trava) é amadora.
Loop: (1) propõe 3 sistemas COMPLETOS de nomes; critérios: usuário de primeira viagem entende sem manual, tom Apple/iOS (ação = verbo claro, tela = substantivo comum), zero metáfora interna, consistência total UI+código+SPEC+testes. (2) escolhe 1 por critério, não por apego. (3) rename ATÔMICO num commit só — UI, tipos, arquivos, testes, SPEC, SISTEMA. Renomear pela metade é pior que não renomear.
Direções (não imposições): Pilha→Notas · Puxar→De memória / Recordar · Porteiro→Análise / Orientar · Códice→Padrões · Trava→Limite.

## OS TRÊS LOOPS (nesta ordem, em toda fatia)
1. QUALIDADE — 3 críticos independentes (hierarquia/simplicidade · motion/fluidez · UX/coerência com a tese) julgam o resultado RENDERIZADO no simulador. Reprovam sem piedade, citando a lei violada + correção concreta com arquivo:linha. Implementa → rejulga. Só avança com aprovação tripla.
2. REPARO — varredura de bug e código ruim: todo caminho que grava, tranca, expõe ou apaga escrita do autor TEM teste unitário (hoje faltam: concluir ≥10/<10min, rotas de saída durante o timer, códice sem obstáculo); código morto deleta; duplicação unifica; força-bruta corrige ou documenta o teto + item na fila; teste que valida caminho que o app não corre é mentira — apaga ou liga ao caminho real.
3. COMPLETUDE — um crítico pergunta "o que falta?" contra SPEC §13 + ESTADO FINAL + dívidas abaixo. Cada lacuna vira item ranqueado da fila. A sessão só encerra quando duas varreduras seguidas voltam vazias.

## PORTÕES (nenhuma fatia fecha sem os 5)
build verde · xcodebuild test verde (suíte inteira) · screenshot NOVO do simulador como evidência · zero violação das regras de ferro · commit com mensagem que nomeia a fatia.

## REGRAS DE FERRO (nunca caem, nem por pedido)
IA nunca insere texto na nota · escrita trancada nunca se expõe por rota nenhuma · um gesto por sessão · silêncio é resposta válida · sem chat, streaks, XP, ouvinte, elogio, resumo.

## DÍVIDAS P0 (auditoria 31/ago — antes de qualquer feature nova)
1 porteiro comenta expressiva reaberta (guarda só na UI; mover ao motor) · 2 vazamento: texto do Puxar capturado antes do véu e nunca limpo · 3 códice repete fragmento ("X e X") sem obstáculo · 4 fecho da expressiva sem teste · 5 régua 136→≤12 + emenda da SPEC · 6 ciclo de vida de anexos (apagar nota apaga arquivo) · 7 migração de schema SwiftData versionada.

## ANTI
Melhorar tudo de uma vez · feature nova com P0 aberto · rename parcial · screenshot velho como prova · "depois eu testo".
