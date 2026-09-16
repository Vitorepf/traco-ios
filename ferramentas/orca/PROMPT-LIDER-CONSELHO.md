# Traço — o conselho aparece

Você é a sessão executora do plano do líder do Traço (sessão "líder do traço"), aprovado pelo dono. Execute tudo, na ordem, até onde a qualidade permitir. Repo /Users/vitorepf/develop/traco-ios. Antes de codar leia MEMORY.md, as memórias dissecacao-de-genios, conselho-de-mestres-estado, fronteira-da-ia, aparelho-da-conta-grok e leis-do-instrumento, e as ADRs 14a e 16a–16g do SPEC.md.

## GOAL
O dono SENTE o conselho de mestres: ao concluir uma Decisão, vê a regra certa com mestre, vídeo e minuto; ao perguntar nas Notas, a resposta traz a regra certa com fonte; e a resposta às perguntas dele volta a existir se a medida deixar.

## ENTREGAS (em ordem; avance só com a prova passando)
E1 Cartão do conselho: a regra exposta (16d/16g, `via` modelo ou palavras) aparece ao autor depois do ato — no fim do concluir, se chegar em até 8 s, senão ao reabrir a nota. Texto LITERAL: regra, condição, mestre, vídeo (link com minuto) e a outra voz, quando há. Uma vez por nota, fecha com um toque, sem pergunta de escolha, sem texto gerado. `Sinal.visto`; «serviu» nunca pesa. Prova: teste de unidade + captura no Air de uma Decisão real concluída.
E2 Notas pelo sentido: `RespostaNotas.montar` leva as 3 seções escolhidas por `Conselho.escolherPeloSentido` (variante que devolve até 3), com BM25 como queda. Prova no Air (sonda `AvaliacaoIA`, 3 repetições): perguntas.json + perguntas-reserva.json com a certa entre as enviadas em ≥ 28/30, e a resposta cita mestre, vídeo e minuto.
E3 Dívidas da 16g: o Pré-mortem volta às palavras (o dono aprovou envio automático só da Decisão); a chamada em segundo plano não pode trocar o aviso de falha de outra rota (`Grok.ultimaFalha`); prova viva no Air: seção de obra com "responda 0" entre as 30 não cala a escolha certa.
E4 Responder: uma medida pareada da rota `responder` com os modelos que a conta expõe hoje (`modelosGrok`), mesma fixture da ADR 10b/10g, 3 repetições. Volta à tabela só se passar o critério escrito na linha dela em Politica.swift; senão registre o medido e pare.
E5 Pontas: INDICE.md sem títulos de obra; importador recusa como autor o `---\ncriada:` embutido num .md sem cabeçalho; o toque longo da nota corrige a origem (minha / obra).
E7 Contexto da Sábia (vem ANTES da E6; análise em ferramentas/orca/analise-atlas-contexto.md). (1) Uma função só monta a nota com o rótulo do método em cada campo para TODAS as rotas que levam campos ao modelo — conselho/escolherRegra, Padrões, Trabalho, Recordar, a pergunta da Página —, não só as Notas; a busca por palavras continua sem rótulo. (2) Retrato: cada linha diz de quando é e se é contagem, citação ou leitura; forma neutra, sem «dela/dele»; o corte tira blocos inteiros e registra o que caiu. (3) Pelo assunto: o catálogo das 28 formas e o Retrato só vão quando a pergunta pede; teto por nota nas escolhidas. (4) O pacote registra o que ficou fora e por quê; a tela troca o «Contexto parcial» genérico pelo nome da nota do autor que não coube (o texto da tela passa pelo líder). Prova: teste por rota que falha sem o rótulo; remedida de real-01 + 16i 28/30 + voz/gênero sem regressão, e o tamanho médio do pedido antes/depois pela sonda.
E6 Segundo cérebro — sugerir notas parecidas (rota `ecos`, cortada por qualidade; dono, 16/09: "segundo cérebro é um dos tipos mais fortes do Traço"). Remeça COM o bruto (`Grok.Diagnostico.bruto`), para separar lista vazia do modelo de lista derrubada pela `GuardaDeEcos`. Alavanca candidata: a mesma da 16g/V2 (BM25 escolhe até 30 candidatas, o Grok escolhe). Casos escritos ANTES: os 6 de prova/q-qualidade-avaliacoes.jsonl (inclui 18 inscritos × sala de 15) + ≥ 6 novos do caderno real + ≥ 2 controles sem vínculo. Barra, 3 repetições: vínculo esperado presente em ≥ 5/6 dos casos com vínculo em cada repetição; zero trecho que não seja literal da candidata; controles devolvem vazio nas 3. Passou: a linha de `ecos` sai de `indisponivelPorQualidade` com o medido escrito no `porque` e a folha «Notas ligadas» volta a mostrar «Talvez se liguem». Não passou: registre o medido com bruto e pare. Nunca escreve [[…]] pelo autor.
Fora: redesenho visual (o líder cuida), Trabalho, métodos novos.

## LOOP DE QUALIDADE (por entrega, máx. 3 voltas)
1. Linha de ciclo: volta, intenção, obstáculo, evidência.
2. Código mínimo; arquivo novo pede xcodegen generate.
3. Teste que falha sem a mudança; suíte integral no 17e 8A5B6500-D263-4BBE-AEF6-E04DDB0993B0, -parallel-testing-enabled NO.
4. Medida de IA só no Air E66EF2AD-97D3-4F15-A959-F07BC713A24D pela sonda (fixture e obras no Documents do app, SIMCTL_CHILD_TRACO_AVALIAR_IA); o JSONL vai para prova/<adr>/. Casos escritos ANTES do código; conte pelo JSONL, não pela memória.
5. Revisão adversária por subagente independente (bug, voz do autor, injeção, promessa do Perfil, testes de contagem); corrigir o confirmado.
6. ADR curta no SPEC.md e commit próprio com a causa, só dos seus arquivos (git add por caminho).
7. Avise o "líder do traço" por SendMessage: entrega, prova, commit. Antes de usar o Air, avise; o líder também o usa.
Sem passar em 3 voltas: registre o medido e siga se a próxima não depender dela.

## LEIS
- No Air: nunca uninstall, erase ou xcodebuild test; só install por cima. A conta Grok mora lá.
- /Applications/Xcode.app/Contents/Developer/usr/bin/{simctl,xcodebuild} com DEVELOPER_DIR (xcrun falha).
- Mouse do Mac proibido.
- IA nunca escreve como autor; o cartão é texto literal da obra.
- Sem painel, menu de escolha ou pergunta de escolha (ADR 14a).
- Não mexa no visual das Notas, do pé ou do calendário além do cartão novo.
- Não comprovado é não feito.

## RELATÓRIO FINAL
Por entrega: feito/parcial/não, prova com números, commits, dívidas.
