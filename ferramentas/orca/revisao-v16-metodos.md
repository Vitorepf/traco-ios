# Revisão G3 — volta 16: métodos com proveniência (ADR 2026-09-05x)

Revisor: Claude Fable 5.1, sessão independente, 06/09/2026 04:20–04:50.
Branch `Vitorepf/volta-16-metodos`, commit `94aad4a` sobre main `59e5833`.
Instrumento: iPhone 17 Pro Max de teste `6033B043-…` (ligado, usado, Dynamic Type restaurado para `large`, desligado ao fim); tudo via `com-trava.sh`. Sem edição, sem commit.

## Veredito: INTEGRAR

Nenhum achado ALTO. Um achado MÉDIO fora do escopo da volta (teste de F2 dependente do simulador) e nove BAIXOS, nenhum bloqueante. Lista mínima para o orquestrador: **nada obrigatório antes do merge**; recomendado antes do G5: B1 e B2 (dois textos do JSON, cinco minutos) e encaminhar M1 ao dono da F2.

## Scorecard (ESTEIRA, 14 dimensões)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 10 | Ciclo melhorar. Fecha a lacuna nomeada no EVOLUCAO ("distinguir fonte, adaptação, aplicabilidade e evidência; evitar eficácia presumida; método ausente ainda não é dito na tela"): a linha da tabela "Métodos e pesquisa com proveniência" foi reescrita com ADR05x e lacuna nova honesta (texto ≠ verificação; não viaja no prompt; sem aviso ao autor). Sem tela nova. |
| Contrato | 9 | ADR 05x (SPEC.md:2676–2708), EVOLUCAO e código coerentes: campo aditivo `proveniencia` opcional (Metodo.swift:81), função inválida → nil → "não informada" (Metodo.swift:112,123), Lente recolhida por padrão (`deOndeVem = false`), Perfil com a mesma proveniência, método ausente dito sem bloquear (Gesto.swift:65, LenteView.swift:90). Metodos.json idêntico ao de main fora do campo novo (conferido por script: ids, campos, regex, encadeamentos iguais). Fica em 9 e não 10 pelo B9: a bibliografia que a ADR invoca ("literatura citada") não existe em documento nenhum do repositório além do próprio JSON. |
| Correção | 9 | Build sem aviso (`grep -c "warning:"` = 0 no log). Suíte integral no meu simulador: **712 testes em 125 suítes, 711 passam, 1 falha** — `ForaDoAppTests.sonecaRecusada` (ForaDoAppTests.swift:336), reproduzida isolada (20/1), causa ambiental e alheia à V16 (M1). Os 4 testes novos cobrem exatamente o pedido: os 21 com função válida e sem campo vazio; decode com/sem campo, função inválida e roundtrip; método do autor com e sem campo; estado do método ausente. Maestro no meu simulador: `busca`, `lente`, `metodos-novos` passam; `caderno-tarefa` falhou por tecla perdida do simulador ("abr" em vez de "abrir", captura do maestro), flake documentado em leis-do-instrumento, não regressão. |
| Jornada real | 9 | 7 capturas do implementador abertas e conferidas (conteúdo bate com o diff: Lente recolhida/expandida com o texto do WOOP, nota Cornell ausente, AX5 Lente e Perfil sem clipe, Perfil com Se–então aberto). Faltavam dois estados que reproduzi: método do autor SEM campo na Lente ("proveniência: não informada — o arquivo do método não tem o campo", `v16-rev-lente-nao-informada.png`) e no Perfil (assert maestro `.*não tem o campo.*` em `de-onde-vem-cornell`), e método do autor COM campo no Perfil ("proveniência: a que você escreveu" + FONTE, `v16-rev-perfil-autor.png`). O estado "saiu da sua pasta" foi reproduzido de ponta a ponta: JSON plantado → nota vestida e concluída → JSON apagado → relançar → reabrir → Lente (`v16-rev-lente-metodo-ausente.png`, e em AX5 `v16-rev-ax5-metodo-ausente.png`). Sem vídeo do movimento (ver Movimento). |
| Design | 9 | Só tokens de Tema (`meta`, `barra`, `label`, `tinta*`, `aviso`, `ambarTinta`, `alvo`, `cartaoEntra`, `trackingLabel`); `PressaoDiscreta` reaproveitado; a linha "De onde vem" é informação recolhida, sem cor, selo ou ícone de aprovação (04a: informação, não selo). Nenhuma decisão nova de linguagem. Para o G4: B7 (21 botões de 44 pt na folha do Perfil) e B8 (vermelho `aviso` num estado que não é erro). |
| Simplicidade | 9 | Caminho comum não muda: quem não toca "De onde vem" vê a Lente como antes, mais uma linha. Um toque abre, um recolhe; sem tela, sem passo, sem decisão nova. Contagem: telas 0 → 0; passos até a proveniência: 1 (Lente) / 3 (Perfil › Métodos › de onde vem). Custo: a folha Métodos cresce ~920 pt (B7). |
| Movimento | 9 | Expansão na Lente com `Tema.animacao(.easeOut(Tema.cartaoEntra), reduzido:)` e `Tema.transicao(.opacity, reduzido:)` (LenteView.swift:101,125): lei da casa, interrompível (toggle de estado), reduce motion vira `fadeReduzido`. Perfil abre sem animação (aceitável numa lista rolável). **Sem vídeo simctl** no G2; nota dada por leitura do código, não por vídeo — o G4 pode exigir o vídeo. |
| Componentes | n/a | V10 (fundação de Componentes) ainda não mesclou. Anotado para a V12: `proveniencia(_:)` está duplicada em LenteView.swift:242 e PerfilView.swift:320 com o mesmo conteúdo (B4) — é o primeiro candidato a `Traco/Componentes/LinhasDeProveniencia`. |
| Acessibilidade | 9 | Alvo 44 pt nos dois botões (`minHeight: Tema.alvo` + `contentShape`); `accessibilityValue` aberto/recolhido e `accessibilityHint` na Lente; identificadores estáveis (`de-onde-vem`, `proveniencia`, `metodo-ausente`, `de-onde-vem-<id>`). AX5 sem clipe em 4 capturas (2 do implementador, 2 minhas); textos com `fixedSize(vertical)`. B6: chevron sem `accessibilityHidden` (VoiceOver não verificado em aparelho). |
| Performance | n/a | Não toca lista pesada, editor nem parser: 23 itens num ScrollView e um `if` na Lente. Sem trace, sem motivo para um. |
| Privacidade e autoria | 10 | Nada sai do aparelho: `proveniencia` só aparece em Metodo.swift, Metodos.json, LenteView, PerfilView e CatalogoTests (grep); não entra em Sabia/prompt/Intents/widget. Arquivo do autor é lido, nunca reescrito; "SEU" + "a que você escreveu" distinguem autoria; "não informada — o arquivo do método não tem o campo" atribui a lacuna a quem a tem. Método do app com id repetido continua ignorado (recarregar não mudou). |
| Estado honesto | 10 | Três estados distintos na tela e reproduzidos: proveniência do catálogo, do autor, não informada; método ausente DITO na Lente sem bloquear Instigar/Contrapor/Apontar (captura). Função inválida não derruba o método nem inventa função. |
| Complexidade | 9 | `git diff --shortstat`: Swift +256/−5 em 5 arquivos (modelo 62, Lente 79, Perfil 51, Gesto 5, testes 64); JSON +147 (conteúdo, 21×5 linhas); MD +36. Zero arquivos novos, zero dependências. As 130 linhas de vista pagam duas cópias da mesma coisa (B4). |
| Fora do app | n/a | Nenhuma superfície fora do app tocada. |
| Relato | 9 | ADR fecha em seis linhas com prova e "Fora" honesto; EVOLUCAO atualizado. LACO ainda não (é do G5). Número da suíte na ADR (712/0) só vale no simulador do implementador — anotar "711/1 no simulador do revisor, falha alheia (F2)". |

## Item 1 — os 21 textos de `proveniencia`, um a um

Critério: `fonte` verificável (obra/autor/ano ou tradição nomeada); `funcao` coerente com a VISAO ("prática", "lente", "estudo com evidência delimitada"); `evidencia` só afirma o que a literatura sustenta e diz "sem evidência específica conhecida" onde não há estudo; nenhuma superioridade universal nem melhora clínica sem estudo nomeado. Conferido por conhecimento geral das obras (revisor), sem inventar; onde a memória do revisor não alcança o detalhe, está dito.

| # | método | fonte confere? | função | evidência | veredito |
|---|---|---|---|---|---|
| 1 | woop | Oettingen, *Rethinking Positive Thinking* (2014) — existe; MCII é dela | evidencia ✓ | "efeitos … em geral modestos e dependentes de a meta ser viável; não há estudo do uso dentro do Traço" — coerente com a literatura de MCII | OK |
| 2 | seEntao | Gollwitzer (1999, *American Psychologist*); Gollwitzer & Sheeran (2006), meta-análise com 94 testes independentes — existem | evidencia ✓ | "efeito médio" (a meta-análise reporta d≈.65, médio-a-grande): conservador, correto; aviso no telefone "não medido aqui" | OK |
| 3 | spec | tradição de engenharia, sem autor — honesto | pratica ✓ | "sem evidência específica conhecida" | OK |
| 4 | notaPermanente | Luhmann (Zettelkasten); Ahrens, *How to Take Smart Notes* (2017) — existem | pratica ✓ | "sem estudo controlado conhecido"; elaboração "estudada à parte" — delimitado | OK |
| 5 | destaque | Keller & Papasan, *The ONE Thing* (2013) — existe | pratica ✓ | "livro de prática, não estudo" | OK |
| 6 | expressiva | Pennebaker & Beall (1986, *J. Abnormal Psychology*); *Opening Up* (1990); Frattaroli (2006, *Psych. Bulletin*, meta-análise, efeito pequeno); Briñol e colegas (2013, *Psych. Science*, "thoughts as material objects") — todos existem | evidencia ✓ | "efeitos pequenos e heterogêneos … Não há prova de melhora clínica pelo Traço" — exatamente o que a VISAO exige. Único reparo: "O ganho não vem de reler" é afirmação sem estudo nomeado (o paradigma não inclui reler; não há evidência de que reler anule) — rebaixar para "o paradigma não inclui reler" (BAIXO) | OK, texto a suavizar |
| 7 | destilar | tradição editorial, sem autor | pratica ✓ | "sem evidência específica conhecida" | OK |
| 8 | palavra | tradição escolar | pratica ✓ | efeito de teste "estudado à parte" — delimitado | OK |
| 9 | decisao | Kahneman & Klein, *Conditions for Intuitive Expertise: A Failure to Disagree* (2009, *American Psychologist*) — existe. O "diário de decisão" NÃO está nesse artigo; é recomendação de Kahneman em entrevistas (Farnam Street) e prática de investidores. O texto diz "base em", o que é defensável (o artigo trata das condições de feedback que o diário tenta criar) | pratica ✓ | "sem estudo específico do diário conhecido … não medida aqui" | OK; anotar que "base em" é derivação, não citação (BAIXO) |
| 10 | premortem | Klein, *Performing a Project Premortem*, HBR (2007); Mitchell, Russo & Pennington (1989, *J. Behavioral Decision Making*, prospective hindsight, ~30 % mais razões) — existem e dizem isso | evidencia ✓ (o estudo de 1989 é experimental) | "aumenta as razões geradas; uso em equipe é relato de prática; não medido para uma pessoa só" | OK |
| 11 | argumento | Toulmin, *The Uses of Argument* (1958) — existe | lente ✓ | "sem evidência de eficácia conhecida; estrutura de análise" | OK. Reparo de precisão: das seis partes de Toulmin (claim, grounds, warrant, backing, qualifier, rebuttal) o texto lista como remanescentes "a resposta" e "o que faria mudar de ideia", que não são partes de Toulmin — a adaptação é maior do que "garantia e qualificador não são cobrados" (BAIXO) |
| 12 | leitura | Adler (1940); Adler & Van Doren (1972) — existem | pratica ✓ | "livro de método" | OK |
| 13 | feynman | "técnica atribuída; sem texto do próprio autor" — honesto e correto; Chi e colegas (1989, *Cognitive Science*, self-explanation) — existe | pratica ✓ | "sem estudo da técnica conhecido; aproxima-se de autoexplicação, estudado em outro formato" | OK |
| 14 | dia | Ivy Lee (1918), anedota de Charles Schwab, "sem fonte primária" — correto | pratica ✓ | "a origem é anedota" | OK |
| 15 | analogia | Gentner (1983, structure-mapping, *Cognitive Science*); Gentner, Loewenstein & Thompson (2003, *J. Educational Psychology*, analogical encoding) — existem | evidencia ✓ | "comparar dois casos melhora a transferência; o formato de nota não foi medido" | OK |
| 16 | inversao | Munger, discursos; Jacobi "man muss immer umkehren" — correto | lente ✓ | "heurística de prática" | OK |
| 17 | steelman | Dennett, *Intuition Pumps* (2013), regras de Rapoport — existe | lente ✓ | "sem evidência específica conhecida" | OK |
| 18 | divergencia | Osborn, *Applied Imagination* (1953); Diehl & Stroebe (1987, *JPSP*, perda de produção em grupo) — existem | pratica ✓ | evidência contra o formato em grupo citada, individual "não sofre dela", adiar julgamento "mista" — honesto | OK |
| 19 | primeirosPrincipios | Aristóteles, *Física* e *Metafísica* — existem; "divulgado como prática de engenharia" | lente ✓ | "sem evidência específica conhecida" | OK |
| 20 | praticaDeliberada | Ericsson, Krampe & Tesch-Römer (1993, *Psych. Review*); Ericsson & Pool, *Peak* (2016); Macnamara, Hambrick & Oswald (2014, *Psych. Science*: 26 % jogos, 21 % música, <1 % profissões) — existem e dizem isso | evidencia ✓ | cita a meta-análise CRÍTICA, não só a favorável — o melhor texto do lote | OK |
| 21 | atualizacao | Tetlock & Gardner, *Superforecasting* (2015); Good Judgment Project — existem | evidencia ✓ | "atualizações pequenas e frequentes acompanham maior acurácia nos melhores previsores; um só número numa nota não foi medido" — correlacional, dito como tal | OK |

**Saldo:** 21/21 fontes existem e dizem o que o texto diz; 21/21 funções coerentes (10 prática, 7 evidência, 4 lente); 0 afirmações de eficácia sem estudo nomeado; 0 superioridade universal; 0 melhora clínica (a expressiva nega explicitamente). Nenhum achado ALTO no item 1. Três reparos BAIXOS de texto (6, 9, 11) que não bloqueiam.

Nota sobre CATALOGO.md e REFERENCIAS.md: são levantamentos de mercado (71 apps / 33 apps), não bibliografia; nenhum dos autores citados aparece em REFERENCIAS.md e só Oettingen, Pennebaker e Chi aparecem no CATALOGO como nomes de app/função. A afirmação do implementador de que eles "não sustentam estudo" é verdadeira: a bibliografia acadêmica do Traço hoje existe SÓ dentro do `Metodos.json`. Não é defeito da volta, é lacuna a nomear no EVOLUCAO (a ADR já diz "texto do catálogo, não verificação").

## Achados por severidade (leitura do diff)

### ALTO
Nenhum. Os 21 textos não afirmam eficácia sem estudo nomeado; contrato, autoria e estado honesto batem com a ADR 05x.

### MÉDIO
- **M1 · Teste de F2 dependente do simulador.** `ForaDoAppTests.sonecaRecusada` (TracoTests/ForaDoAppTests.swift:336) assume que a permissão de notificação do processo de teste é `notDetermined`; num simulador onde a permissão já foi decidida (o meu, iPhone 17 Pro Max de teste), `LembrarDepoisIntent.perform()` agenda e o teste falha. Não é da V16 (nada do diff toca `ProximoCompromisso`), mas derruba a prova "suíte 712/0" em qualquer máquina que não a do implementador. Dono: F2. Correção: injetar `Centro.fake(estado: .naoDeterminado)` em vez de `.real`, ou resetar a permissão no `isolado`.

### BAIXO
- **B1 · `expressiva.evidencia`: "O ganho não vem de reler."** Afirmação sem estudo nomeado. O paradigma de Pennebaker não inclui reler; não há evidência de que reler anule o efeito. Trocar por "o paradigma não inclui reler" (Metodos.json).
- **B2 · `argumento.adaptacao`.** "A resposta" e "o que me faria mudar de ideia" não são partes do modelo de Toulmin (claim, grounds, warrant, backing, qualifier, rebuttal); o texto sugere que cinco das seis ficaram, quando ficaram três (tese, evidência, objeção≈rebuttal). Reescrever: "de Toulmin ficam tese, evidência e a objeção; resposta e 'o que me faria mudar' são do Traço".
- **B3 · `decisao.fonte`.** O diário de decisão não está em Kahneman & Klein (2009); é recomendação posterior de Kahneman (entrevistas) e prática de investidores. "Base em" é aceitável, mas "Diário de decisão (prática divulgada por Kahneman; base em …)" seria mais honesto.
- **B4 · Duplicata de vista.** `proveniencia(_:)` existe duas vezes com o mesmo conteúdo (LenteView.swift:242 e PerfilView.swift:320): mesmas cinco linhas, mesmos rótulos, mesmas frases de "não informada". Candidato óbvio para `Traco/Componentes` na V12 (após V10). Não bloqueia: a V10 ainda não mesclou.
- **B5 · Copy de tela no modelo.** `Gesto.estadoDoMetodo` (Gesto.swift:65) e `Proveniencia.linhas` (rótulos "FONTE", "SERVE PARA") são frases de interface dentro de `Traco/Modelo`. Já era o padrão da casa em `funcaoEmPalavras`; anotar, não corrigir agora.
- **B6 · Chevron sem `accessibilityHidden`.** Na Lente o `Image(systemName: "chevron.down")` está dentro do rótulo do botão; o VoiceOver pode ler "De onde vem, seta para baixo" (não verificado em aparelho). Um `.accessibilityHidden(true)` resolve.
- **B7 · Custo de altura no Perfil.** Cada um dos 21 métodos ganhou um botão de 44 pt ("de onde vem"), ~920 pt a mais na folha que já pedia `scrollUntilVisible` de 25 s. A ADR assume "uma linha por método"; assumiu, mas é a folha inteira que dobra. Para o G4 julgar: tornar a linha do método tocável (sem botão) manteria o alvo e não somaria altura.
- **B8 · Cor do estado "método ausente".** `Tema.aviso` (vermelho) é a cor de falha nos cartões e da soneca; o método que saiu da pasta é estado, não erro (ADR 04a: estado, não bloqueio). `Tema.tintaSuave` ou `ambarTinta` dizem "atenção" sem dizer "quebrou". Para o G4.
- **B9 · Bibliografia só no JSON.** CATALOGO.md e REFERENCIAS.md são levantamentos de mercado; nenhuma obra acadêmica citada nos 21 textos consta em documento do repositório. Não é defeito desta volta (a ADR diz "texto do catálogo, não verificação"), mas vale uma linha no EVOLUCAO: "as fontes dos métodos vivem só em Metodos.json".

## Item 2 — superfície (04a)

- "De onde vem" é uma linha recolhida, tipografia `barra`, chevron cinza, sem cor de aprovação, sem número, sem estrela: informação, não selo. ✓
- Estado "o método X saiu da sua pasta; os campos continuam na nota" aparece de fato (reproduzido: `v16-rev-lente-metodo-ausente.png`), no lugar do botão (não há proveniência a mostrar) e sem bloquear o resto da Lente. ✓
- Perfil: método do autor sem proveniência diz "proveniência: não informada — o arquivo do método não tem o campo." (assert maestro em `de-onde-vem-cornell`); com proveniência diz "a que você escreveu" (`v16-rev-perfil-autor.png`). ✓

## Item 3 — correção

Números literais: `Test run with 712 tests in 125 suites failed after 8.501 seconds with 1 issue` (falha: `ForaDoAppTests.swift:336`, `ProximoCompromisso.lido()?.lembrarEm → 2026-09-06 07:41:52 +0000) == nil`); re-teste isolado `20 tests in 1 suite failed … with 1 issue` (mesma). Build: 0 `warning:`. Maestro (meu UDID, `TRACO_SEM_MODELO=1`): busca ✓, lente ✓, metodos-novos ✓, caderno-tarefa ✗ (tecla perdida, não código).

## Item 5 — complexidade e merge

- `git merge-tree --write-tree 59e5833 94aad4a`: limpo (base = main atual; origin/main está atrás do main local, nada novo lá).
- `git merge-tree --write-tree Vitorepf/volta-10-fundacao 94aad4a`: **CONFLITO em SPEC.md** (as duas ADRs anexam no fim do arquivo); EVOLUCAO.md auto-merge OK; Gesto.swift não é tocado pela V10 (V10 mexe em Tema.swift, CalendarioTema.swift, TemaTests.swift). Se a V10 mesclar antes (05v), a V16 precisa de um rebase trivial: mover a ADR 05x para depois da 05v.
- `git merge-tree` contra `Vitorepf/fora-3-captar`: limpo.

## Efeitos colaterais desta revisão

- `busca.yaml` grava `busca-celular.png` na raiz do repo; restaurei com `git checkout`.
- Capturas novas (não commitadas, reduzidas para 1400 px): `ferramentas/orca/v16-rev-lente-nao-informada.png`, `v16-rev-perfil-autor.png`, `v16-rev-lente-metodo-ausente.png`, `v16-rev-ax5-metodo-ausente.png`.
- Fluxos de reprodução no scratchpad da sessão (`v16-rev-a/b/c.yaml`, `v16-rev-c-ax5.yaml`); vale trazer o `c` para `maestro/metodo-ausente.yaml` numa volta futura — hoje nenhum fluxo cobre o método que sumiu.
- Maestro 1.39.13 devolve exit 0 mesmo com passo FAILED quando chamado com `--udid`; quem automatizar deve ler o log, não o código de saída.
