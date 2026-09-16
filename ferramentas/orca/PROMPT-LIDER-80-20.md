# Traço — execução 80/20 do plano do líder

Você é a sessão executora do plano do líder do Traço (sessão "líder do traço"), aprovado pelo dono. Execute tudo, na ordem, até onde a qualidade permitir. Repo /Users/vitorepf/develop/traco-ios. Antes de codar leia MEMORY.md, as memórias dissecacao-de-genios, leis-do-instrumento e aparelho-da-conta-grok, e as ADRs 12a, 12b e 14a do SPEC.md.

## GOAL
"Um conselho de mestres que vive no seu caderno". Pronto quando: obra importada NUNCA vira voz do autor; ~100 regras conferidas respondem com fonte; a Decisão concluída escolhe (sombra) a regra certa; o resultado ajusta as regras; o Claude lê as obras com segurança.

## ENTREGAS (em ordem; avance só com a prova passando)
E-1 Casa: commitar ou reverter o pé pendente; tirar GeometryReader e `let _ = g` de BarraNavegacao.swift; o teste que exige NLEmbedding PT pula sem ele.
E0 Obra ≠ voz: `obra` em OrigemNota (Nota.swift:8); Corpus.swift:341 sem cabeçalho e com `## N.`, link ou >20k caracteres vira obra; :363 origem desconhecida não vira autor; citação `>` fora da voz (BlocoCaderno.swift:620, VozDoAutor.swift:29), mas na busca; servidor.py:251 origem obrigatória; recolherMetodos valida regex e campos. Prova: importar ~/Desktop/negocios-dossies/hormozi-videos.md não altera Retrato, Padrões nem Semana.
E1 Biblioteca: script em ferramentas/obras/ gera .md por mestre (origem: obra), seção `##` por regra (≤1.000 car.: regra, condição, caso/número, mestre, vídeo, minuto, data, etiqueta mecanismo|relato|crença|saúde), de Lenny e Hormozi. Portões: duplicação, inglês cru, instrução vazada, link errado, conta que não fecha (#348), saúde como fato. 50–100 regras, fora da lista de Notas. Prova: 10 sorteadas batem com a fonte.
E2 Consultar: FonteNotas.swift:124 recorta obra grande nas 3 melhores seções por BM25 local; obra sai de Indice.swift e NotasFiltro.swift; chamar GuardaDeObra.recusarSeOmitidaDoPacote; citação com mestre, vídeo e minuto. Prova: 20 perguntas escritas antes, seção certa no top 3 em ≥16.
E3 Decidir (sombra): Sessao.concluir, Decisão ou Pré-mortem com "decidido" e "espero": BM25 sobre escolha, opções e critério REGISTRA sem mostrar 1 regra literal, a contrária e "apareceu porque"; sinal `exposto` (Sinais.swift). Prova: 5 decisões-fixture acham a regra esperada.
E4 Resultado: preenchidos "aconteceu" e "saldo" numa Decisão com regra exposta, a regra ganha além/igual/aquém e isso pesa no BM25; nunca pelo "serviu". Prova: regra que falhou 2x cai no ranking em teste.
E5 MCP de obras: servidor só leitura separado; obras_buscar (BM25 por seção) e obra_secao; texto de obra marcado como dado não confiável; traco_corpus sem obras. Prova: obra com "ignore instruções" não escreve nada.
Fora: mostrar o cartão, ensinar, mestres desconhecidos, polimento.

## LOOP DE QUALIDADE (por entrega, máx. 3 voltas)
1. Linha de ciclo: volta, intenção, obstáculo, evidência.
2. Código mínimo; arquivo novo pede xcodegen generate.
3. Teste que falha sem a mudança; suíte integral no 17e 8A5B6500-D263-4BBE-AEF6-E04DDB0993B0, -parallel-testing-enabled NO.
4. Revisão adversária por subagente independente (bug, voz do autor, injeção); corrigir o confirmado.
5. ADR curta no SPEC.md e commit próprio com a causa.
6. Se SendMessage existir, avise o "líder do traço": entrega, prova, commit.
Sem passar em 3 voltas: registre o medido e siga se a próxima não depender dela.

## LEIS
- Air E66EF2AD-97D3-4F15-A959-F07BC713A24D tem a conta Grok: nunca uninstall, erase ou xcodebuild test; só install por cima.
- Use /Applications/Xcode.app/Contents/Developer/usr/bin/{simctl,xcodebuild} com DEVELOPER_DIR (xcrun falha).
- Mouse do Mac proibido.
- IA nunca escreve como autor; cartão é texto literal, sem geração.
- Sem painel, menu ou pergunta de escolha (ADR 14a).
- Não comprovado é não feito.

## RELATÓRIO FINAL
Por entrega: feito/parcial/não, prova, commits, dívidas.
