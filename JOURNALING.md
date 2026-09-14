# Journaling — o que o Traço já sabe, o que a ciência diz, o que o mercado faz (14/09/2026)

Levantamento em três camadas: o que já está no repositório (SPEC, DOSSIÊ, COLHEITA, CATÁLOGO, VIZINHANÇA, código), o que a literatura mede, e o estado do mercado em setembro de 2026. Termina com perguntas abertas, não com respostas.

---

## 1. O que o Traço já tem

O Traço não é um "app de diário". Journaling entra por **um método com posologia**, a Expressiva, e por decisões de spec que recusam o que os diários fazem por padrão.

| Onde | O que está decidido |
|---|---|
| [SPEC.md §8](SPEC.md) | Timer de 15 min; instrução única (fato E sentimento sobre o mesmo evento); ao fim **grava e sela** antes do fecho; fecho com dois métodos validados — **Selar** (Pennebaker) e **Queimar** (Briñol 2013); linha de sentido escrita pelo autor, pulável, única coisa que sai; queimar tem de ser verdade em todas as rotas; a Análise nunca comenta uma expressiva; **série de quatro dias** (ADR 02f) |
| [SISTEMA.md](SISTEMA.md) "Expressiva" | Contradição §8 × §15 resolvida: sair durante o timer tranca; Concluída após ≥10 min tranca direto; fim do timer grava e tranca |
| [Metodos.json](Traco/Modelo/Metodos.json) `expressiva` | Proveniência (Pennebaker e Beall 1986; Opening Up 1990); evidência declarada como "efeitos pequenos e heterogêneos (Frattaroli 2006)"; aplicabilidade: "um evento com peso ainda não posto em palavras; não serve como diário diário" |
| [Nota.swift](Traco/Modelo/Nota.swift) | `trancada` = selada, `queimada` = destruída; `serieRaw` e `diaDaSerie` (1–4); título "Expressiva · dia N" |
| [FechoExpressivaView.swift](Traco/Confirmacao/FechoExpressivaView.swift) | Pergunta "o que ficou claro?"; no dia 4 mostra as quatro linhas de sentido, uma embaixo da outra |
| [Revisoes.swift](Traco/Recordar/Revisoes.swift) | `agendarSerie` respeita férias (a série espera, não morre); `rearmarSeries` reagenda no arranque uma série que perdeu o aviso; expressiva nunca entra no Recordar |
| Métodos vizinhos | **Exame da noite** (Sêneca) e **Coluna da esquerda** (Argyris) são explicitamente "não desabafo" e roteiam desabafo para a Expressiva |

Recusas de spec que definem a posição diante do journaling comum: sem streak, medalha ou estatística (§12); sem prompt ocupando o vazio (§3); sem registro de humor (§19.1 vizinho); a IA nunca resume, intitula nem analisa (§2); a lista de cartões não é o altar (§3).

Limite declarado e aberto: **Queimar apaga no modelo, não na mídia.** SQLite pode guardar o texto no WAL até um vacuum. Garantia física pediria chave por nota; está na FILA.

---

## 2. O que o repositório já pesquisou

A VIZINHANÇA classifica 41 apps em cinco eixos; o eixo "método e forma" tem 12, e o DOSSIÊ julga 71. Os diários que importam, no juízo já escrito:

| App | Compartilha com o Traço | Onde diverge | Lição registrada |
|---|---|---|---|
| **Rescript Journal** | O §8 inteiro: 4 dias, 15–20 min, sem streak por decisão de design | A IA analisa tom, tema e "arco emocional" da pior noite do autor | Vizinho mais próximo e contraexemplo mais útil. A COLHEITA já pegou a posologia (série de 4) e a forma "Carta" |
| **Zenpen** | Timer e texto que some em 30 s: o Queimar em produção | Destrói tudo, inclusive o sentido | Apagar é vendável; a diferença do Traço é separar a linha de sentido antes |
| **Reflection** | Devolve UMA pergunta tirada do texto | Depois escreve padrões, resumos semanais, revisão anual | Prova de mercado de que o público aceita pergunta em vez de resposta |
| **Rosebud** | Memória entre entradas (o Padrões do §9) | É chat; consola e elogia; "melhor que terapeuta" como marketing | Só a memória é compatível |
| **Mindsera** | Catálogo de 52 frameworks como valor do produto | A IA escreve o retorno | Os 52 frameworks são listas de perguntas: lidos como formulário são o §6 |
| **Day One** | Arquivo mais maduro do iOS, export sério, E2E | Sem método; a lista é o altar; streak e mapa | COLHEITA propôs o degrau 365 no Recordar e a pista de contexto (dia, hora, cidade) |
| **Stoic** | Duas âncoras no dia (manhã, noite) sem streak | Prompt ocupa o vazio; humor, respiração e citação disputam com a escrita | A âncora temporal é a alternativa honesta ao streak |
| **Grid Diary** | Ataca a fricção do começo | Por prompt pronto | O §17 responde ao mesmo problema vestindo a forma depois |
| **750 Words** | Escrita privada sem recurso além do espaço | Vive de streak e medalha | Esquecer um dia não pode virar falha moral |
| **MindScribber** | Escrita expressiva como intervenção com literatura | Afogada em mood tracker, jogos, citações | Existe demanda para o §8 como produto |

Síntese do DOSSIÊ que se repete: *quem tem o método bom entrega a análise ao modelo* (Rescript, Mindsera, Reflection cruzam a linha no mesmo ponto: o retorno) e *streak entra por último e estraga o resto*.

---

## 3. O que a ciência mede

### Escrita expressiva (Pennebaker)

- **Frattaroli 2006**, 146 ensaios controlados: efeito global positivo e significativo, mas pequeno (r ≈ 0,075, d ≈ 0,15). Moderadores que aumentam o efeito: mais sessões, sessões mais longas, instrução mais diretiva com tema específico. [ResearchGate](https://www.researchgate.net/publication/6721971_Experimental_Disclosure_and_its_moderators_A_meta-analysis)
- **Reinhold e col. 2018**, 39 ensaios com adultos saudáveis: **sem efeito de longo prazo sobre sintomas depressivos**; efeitos maiores com mais sessões e tema mais específico. [Wiley](https://onlinelibrary.wiley.com/doi/abs/10.1111/cpsp.12224)
- **Pavlacic e col. 2019**: meta-análise sobre estresse pós-traumático, crescimento pós-traumático e qualidade de vida. [SAGE](https://journals.sagepub.com/doi/abs/10.1177/1089268019831645)
- Adolescentes: revisão meta-analítica própria. [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0272735815000161)

O que isto confirma no Traço: a **série de quatro dias** e a **instrução única sobre um evento** são exatamente os dois moderadores que a literatura aponta. O que isto cobra: a frase da Metodos.json ("efeitos pequenos e heterogêneos") está correta, e a spec não deve prometer melhora clínica.

### Queimar (Briñol, Gascó, Petty e Horcajo 2013)

Participantes escreveram sobre o corpo; o papel foi rasgado e jogado fora ou guardado e conferido. Quem descartou fisicamente usou menos aquele pensamento nos julgamentos seguintes. *Psychological Science* 24, 41–47. [SAGE](https://journals.sagepub.com/doi/abs/10.1177/0956797612449176) · Trabalhos posteriores do mesmo grupo sobre "separar o pensamento do eu". [SAGE 2019](https://journals.sagepub.com/doi/10.1080/02134748.2019.1649891)

Observação: o estudo mede impacto de um pensamento sobre uma avaliação, em laboratório e no curto prazo. Não é evidência de bem-estar. O Traço apresenta Queimar como método com objetivo próprio, e a proveniência já diz o limite.

### Gratidão (o que o Traço não tem)

- Meta-análise de 25 ensaios com 6.745 participantes: efeito significativo sobre bem-estar, g = 0,22. [Springer](https://link.springer.com/article/10.1007/s41042-023-00086-6)
- Meta-análise transcultural no PNAS: efeitos maiores quando se mede afeto positivo e quando se combinam tipos de intervenção. [PNAS](https://www.pnas.org/doi/10.1073/pnas.2425193122)
- Revisões mais céticas: evidência limitada para efeito pequeno, com a explicação de que a maioria dos estudos dura 1–2 semanas. [Taylor & Francis](https://www.tandfonline.com/doi/full/10.1080/17439760.2025.2502483)

### Quando escrever faz mal

- Escrita expressiva **piora o humor imediatamente depois** de forma confiável, mesmo quando melhora medidas de longo prazo em pessoas saudáveis.
- Quem tem ruminação negativa alta e ruminação positiva baixa pode piorar com exercícios breves e autodirigidos; pesquisadores avisam que escrita expressiva breve não é tratamento autônomo para depressão. [Simply Psychology](https://www.simplypsychology.com/articles/journaling-for-mental-health) · [Steps](https://steps.org/articles/does-journaling-work/)
- A **APA emitiu aviso em 13/11/2025**: chatbots de IA generativa e apps de bem-estar não substituem profissional, podem ser adjunto. [Lound](https://lound.ai/blog/ai-journaling-apps-2026-buyers-guide/)

Onde isto toca o Traço: a Metodos.json já diz "não substitui acompanhamento profissional". A spec não diz nada sobre o autor que sai do fecho pior do que entrou. A Expressiva é o lugar mais sensível do app e o único sem porta de saída para fora dele.

---

## 3b. Os benefícios, ditos sem enfeite

**O benefício não vem de escrever. Vem de construir sentido.** Pennebaker mediu isso nas palavras: quem melhora é quem, de uma sessão para a outra, passa a usar mais palavras de causa e de insight ("porque", "percebi", "entendi"). Desabafar sem reorganizar a história não muda nada e pode piorar. A série de quatro dias e a linha de sentido são o método; o timer é só o recipiente.

Ganhos medidos, por ordem de força da evidência:

1. **Sentido e fechamento de um evento pesado.** Menos intrusão do pensamento, menos visitas ao médico, melhor função imune em alguns estudos. Efeito pequeno na média, maior com mais sessões e um evento específico.
2. **Afeto positivo e satisfação com a vida**, via gratidão. Efeito pequeno a médio, sustentado quando dura mais de duas semanas.
3. **Redução do peso de um pensamento** ao descartá-lo fisicamente. Efeito de laboratório, curto prazo. É o Queimar.
4. **Memória autobiográfica e reencontro consigo.** Não é medido como saúde, mas é o motivo pelo qual as pessoas continuam (Day One vive disso).
5. **Metacognição.** Ver o próprio percurso, como as quatro linhas lado a lado. Ninguém mediu; é a aposta do Traço.

**O que não é benefício, embora pareça:** a sensação de alívio logo depois. A literatura diz o contrário: sai-se pior no momento e melhor semanas depois. Streak, humor registrado e resumo da IA vendem o alívio, não o sentido.

**Aplicado ao Traço:** o app já implementa os dois moderadores que importam (série e tema único) e recusa o que dilui. Falta decidir o que fazer com o autor que sai do fecho pior do que entrou: hoje o app cala.

---

## 4. O mercado em setembro de 2026

- **Apple Journal** chegou ao iPad e ao Mac no iOS/iPadOS 26 com Pencil, múltiplos diários e vista de mapa; iOS 27 traz mais. As Journaling Suggestions são o prompt ocupando o vazio, feitas no aparelho. [9to5Mac iPad](https://9to5mac.com/2026/01/05/ipados-26-adds-new-journal-app-and-ive-been-using-it-almost-every-day/) · [9to5Mac iOS 27](https://9to5mac.com/2026/06/11/heres-everything-new-for-journal-in-ios-27/) · [App Store](https://apps.apple.com/us/app/journal/id6447391597)
- **Day One** lançou em abril o plano **Gold** (US$ 74,99/ano) com Daily Chat, resumos, Go Deeper, títulos sugeridos e imagem por IA; Premium virou Silver (US$ 49,99/ano). [9to5Mac](https://9to5mac.com/2026/04/08/day-one-journaling-app-introduces-gold-plan-with-ai-summaries-and-daily-chat/) · [Day One](https://dayoneapp.com/releases/2026-7/) · [Planos](https://dayoneapp.com/plans/)
- Mercado de apps de diário estimado em US$ 7,3 bi em 2026, crescendo 11,4% ao ano; apps com IA cobram 2 a 3 vezes mais que os só-texto. [Future Market Insights](https://www.futuremarketinsights.com/reports/digital-journal-apps-market) · [Lound](https://lound.ai/blog/ai-journaling-apps-2026-buyers-guide/)
- A categoria "AI journaling" se consolidou (Rosebud, Reflection, Mindsera, Life Note, Mindspace); todos os rankings são escritos pelos próprios concorrentes. [Reflection](https://www.reflection.app/blog/ai-journaling-apps-compared) · [Mindsera](https://mindsera.com/articles/the-7-best-ai-journaling-apps-in-2026-tested) · [Rosebud](https://www.rosebud.app/blog/top-6-ai-journaling-app-for-mental-wellness)
- **Rescript Journal** (iOS 1.0.1, jul/2026) ainda sem avaliações; "no card needed, no trial that auto-charges". [rescriptjournal.com](https://rescriptjournal.com/)

Leitura: o mercado inteiro converge para IA que **responde** ao diário. A Apple ocupa o diário gratuito de fotos e lugares. O que ninguém vende é método com posologia e IA que cala. Isso continua sendo o espaço do Traço, e continua sendo estreito.

---

## 5. Perguntas abertas (o dono responde)

1. **Saída piorada.** A literatura diz que se sai pior do fecho. O app não faz nada com isso. Deve haver uma frase no fecho, uma porta para fora, ou nada, por decisão?
2. **Gratidão.** É o segundo método de journaling com mais evidência e o Traço não o tem. Entra como forma (três coisas, lista de três campos) ou fica de fora por ser "diário diário", que a Metodos.json exclui?
3. **Contexto como pista.** A COLHEITA propôs dia, hora e cidade no Recordar (Day One). Continua "depois"?
4. **Queimar físico.** Chave por nota está na FILA desde 03/09. A frase ao autor hoje é "apagado do modelo". Basta?
5. **Uma sessão avulsa.** A série de quatro é o método. Uma expressiva sem série ainda faz sentido, ou toda expressiva abre série?

---

## 6. Lista completa dos métodos da família (ordem: evidência, depois benefício)

Os sete primeiros são clínicos ou de automonitoramento, e o Traço recusa cinco por decisão (medir o autor, diagnosticar). Com evidência forte e dentro do molde do app: Se–então, WOOP e Expressiva (já estão) e monitoramento de progresso de metas (pela metade). Na faixa ★★, os que cabem sem tela nova: benefit finding, três coisas boas, autodistanciamento, autocompaixão e reflexão de aprendizado. A evidência mais forte da família inteira é a Written Exposure Therapy, cinco sessões de trinta minutos; o Traço faz quatro de quinze.

Escala: ★★★ meta-análise ou padrão clínico · ★★ ensaios controlados · ★ estudo pequeno ou mecanismo · — prática sem ensaio.

| # | Método | Origem | Dose | Benefício principal | Evid. | Limite ou risco | Traço |
|---|---|---|---|---|---|---|---|
| 1 | Written Exposure Therapy | Sloan e Marx 2012–19 | 5 × 30 min, trauma, com instrução | TEPT; não inferior à CPT | ★★★ | Só com clínico | Não |
| 2 | Relato de trauma e impact statement (CPT) | Resick 1992 | Sessões escritas na terapia | TEPT, primeira linha | ★★★ | Só com clínico | Não |
| 3 | Registro de pensamento | Beck 1979; Burns 1980 | Situação, pensamento, emoção, evidência, resposta | Núcleo da TCC | ★★★ | Encosta em diagnóstico | Não (registrado) |
| 4 | Intenção de implementação | Gollwitzer 1999 | Se X, então Y | d ≈ 0,65 | ★★★ | Gatilho na hora | Sim |
| 5 | Monitoramento de progresso de metas | Harkin 2016 | Registrar avanço | d ≈ 0,40 | ★★★ | Vira métrica | Parcial |
| 6 | Automonitoramento (alimentar, sono, álcool, fumo) | Burke 2011; Carney 2012 | Log diário | Peso, insônia, consumo | ★★★ | Mede o autor | Recusado §19.1 |
| 7 | Monitoramento de atividade e humor (BA) | Lewinsohn; Martell 2001 | Hora a hora | Depressão | ★★★ | Mede o autor | Recusado |
| 8 | Escrita expressiva | Pennebaker 1986 | 15–20 min, 3–4 dias | Sentido; efeito pequeno | ★★★ | Piora imediata | Sim |
| 9 | Contraste mental / WOOP | Oettingen 2014 | Desejo, resultado, obstáculo, plano | Compromisso | ★★★ | — | Sim |
| 10 | Imagery Rehearsal Therapy | Krakow 2001 | Reescrever o pesadelo | Pesadelos | ★★★ | Clínico | Não |
| 11 | Diary card (DBT) | Linehan 1993 | Cartão diário | Regulação emocional | ★★★ | Mede; clínico | Não |
| 12 | Reminiscência / life review | Butler 1963; Pinquart 2007 | Vida por períodos | Depressão em idosos | ★★★ | Reabre luto | Não |
| 13 | Três coisas boas | Seligman 2005 | 3 coisas e por quê, 1 semana | Afeto a 6 meses | ★★ | Pequeno | Não |
| 14 | Diário de gratidão | Emmons 2003 | Lista semanal | g ≈ 0,22 | ★★ | Satura | Não |
| 15 | Autodistanciamento | Kross e Ayduk | Terceira pessoa | Menos ruminação | ★★ | — | Não |
| 16 | Benefit finding | King e Miner 2000 | Só o que se ganhou | Ajuste sem piora imediata | ★★ | Forçar positivo | Não |
| 17 | Escrita de autocompaixão | Neff; Leary 2007 | Carta a si | Humor | ★★ | — | Não |
| 18 | Best possible self | King 2001 | Futuro indo bem | Otimismo | ★★ | Devaneio | Não |
| 19 | Afirmação de valores | Steele; Cohen 2014 | 10 min sobre um valor | Desempenho sob ameaça | ★★ | Replicação mista | Não |
| 20 | Escrita antes da prova | Ramirez e Beilock 2011 | 10 min sobre a ansiedade | Desempenho | ★★ | Alta pressão | Não |
| 21 | Pendências antes de dormir | Scullin 2018 | 5 min de lista | Adormecer | ★★ | Um ensaio | Não |
| 22 | Reflexão diária de aprendizado | Di Stefano, Gino 2014 | 15 min | +23% desempenho | ★★ | Um contexto | Não |
| 23 | After Action Review | Ellis e Davidi 2005 | Esperado, ocorrido, por quê | Aprender | ★★ | Ritual vazio | Não |
| 24 | Reescrita narrativa | Wilson 2011 | Outro ângulo, dias depois | Longo prazo | ★★ | — | Parcial (série) |
| 25 | Perdão por escrito (REACH) | Worthington; Wade 2014 | Recordar, empatizar, decidir | Menos raiva | ★★ | — | Não |
| 26 | Worry postponement | Borkovec 1983 | Anotar e adiar | TAG | ★★ | — | Não |
| 27 | Narrative Exposure Therapy | Schauer 2005 | Linha de vida | TEPT | ★★ | Clínico | Não |
| 28 | Defusão (ACT) | Hayes 1999 | "Estou tendo o pensamento…" | Menos fusão | ★★ | Componente | Não |
| 29 | Self-authoring | Schippers 2015 | Passado, falhas, futuro | 22% menos evasão | ★★ | Um ensaio | Não |
| 30 | Work diary / progress principle | Amabile 2011 | Progresso do dia | Motivação | ★★ | Observacional | Não |
| 31 | Carta de gratidão | Seligman 2005 | Carta a alguém | Grande, curto | ★★ | 1 mês | Não |
| 32 | Escrita de metas | Morisano 2010 | Metas e obstáculos | Notas | ★ | — | Parcial |
| 33 | Descarte físico | Briñol 2013 | Escrever e destruir | Menos peso | ★ | Lab | Sim (Queimar) |
| 34 | Affect labeling | Lieberman 2007 | Nomear a emoção | Menos amígdala | ★ | Mecanismo | Não |
| 35 | Positive data log | Padesky 1994 | Provas contra a crença | Crença central | ★ | Clínico | Não |
| 36 | Pré-mortem | Klein 2007 | Imaginar o fracasso | Mais causas | ★ | — | Sim |
| 37 | Contar gentilezas | Otake 2006 | Contar as feitas | Felicidade | ★ | — | Não |
| 38 | Savoring | Bryant 2007 | Momento bom em detalhe | Afeto | ★ | — | Não |
| 39 | Diário de forças | Seligman 2005 | Força de modo novo | Bem-estar | ★ | — | Não |
| 40 | Perspectiva temporal | Bruehlman-Senecal 2015 | "Daqui a dez anos" | Afeto | ★ | — | Não |
| 41 | Diário de sonhos | LaBerge 1985 | Ao acordar | Recall, lucidez | ★ | — | Não |
| 42 | Interactive journaling | The Change Companies | Cadernos guiados | Adição; SAMHSA | ★ | Programa | Não |
| 43 | Poetry therapy / bibliotherapy | Mazza; Adams | Poema, leitura, escrita | Expressão | ★ | — | Não |
| 44 | Mood tracking | apps | Escala diária | Medida | ★ | Mede | Recusado |
| 45 | Reflexão antes do app (One Sec) | 2020 | 25 palavras | Menos abertura automática | ★ | — | Proposto |
| 46 | Journal therapy (Adams) | 1990 | Stems, sprint, lista de 100, diálogo, carta | Autoconhecimento | — | Casos | Não |
| 47 | Intensive Journal | Progoff 1975 | Cadernos por seção | Fundador | — | Longo | Não |
| 48 | Carta não enviada | Pennebaker; Worden | Carta a quem não lê | Luto, conflito | — | — | Proposto |
| 49 | Exame da noite | Sêneca | Dia em revista, regra | Caráter | — | — | Sim |
| 50 | Exame de consciência | Inácio 1548 | Cinco passos | Caráter | — | — | Não |
| 51 | Diário estoico | Marco Aurélio; Epicteto | Premeditatio, vista de cima | Equanimidade | — | — | Parcial |
| 52 | Inventário 4º/10º passo | AA 1939 | Ressentimentos, balanço | Recuperação | — | — | Não |
| 53 | Daily Questions | Goldsmith 2015 | "Fiz o melhor para…?" | Comportamento | — | Pontua | Não |
| 54 | Decisão | Bevelin; Kahneman | Decisão, expectativa, revisita | Calibragem | — | — | Sim |
| 55 | Coluna da esquerda | Argyris 1974 | Dito e pensado | Relação | — | — | Sim |
| 56 | Ciclos reflexivos (Gibbs, Kolb, Rolfe, Johns, Schön) | 1983–2001 | Descrição, análise, plano | Ensino | — | Formulário | Não |
| 57 | Parallel chart | Charon 2001 | Sobre o paciente em língua comum | Empatia | — | — | Não |
| 58 | Hansei | Japão | Sobre o próprio erro | Melhoria | — | — | Parcial |
| 59 | Retrospectiva / postmortem | agile | Bem, mal, muda | Time | — | — | Não |
| 60 | Dia (Ivy Lee) | 1918 | Seis tarefas | Foco | — | — | Sim |
| 61 | Destaque | Keller 2013 | Uma coisa | Foco | — | — | Sim |
| 62 | Nota permanente | Luhmann | Ideia própria, ligada | Pensar | — | — | Sim |
| 63 | Commonplace book | Erasmo; Locke | Trecho comentado | Leitura | — | — | Parcial |
| 64 | Revisão semanal | Allen 2001 | Varrer aberto | Controle | — | — | Não |
| 65 | Done list | Amabile | Feito hoje | Motivação | — | — | Não |
| 66 | Time log | Drucker 1967 | Tempo por bloco | Consciência | — | Mede | Não |
| 67 | Idea journal / spark file | Johnson | Toda ideia, reler | Criação | — | — | Parcial |
| 68 | Lab notebook | ciência | Registro datado | Reprodutibilidade | — | — | Não |
| 69 | Diário pessoal datado | tradição | Por data | Memória | — | Altar | Recusado §3 |
| 70 | Journaling reflexivo genérico | Progoff; Moon | Escrever para entender | Autoconhecimento | — | Difuso | Parcial |
| 71 | Morning pages | Cameron 1992 | 3 páginas | Desbloqueio | — | Cota | Não |
| 72 | Free writing | Elbow 1973 | 10 min sem parar | Desbloqueio | — | — | Não |
| 73 | Escrita com apagamento | Zenpen; Write or Die | Parar apaga | Fluxo | — | Destrói tudo | Não |
| 74 | Five Minute Journal | 2013 | Gratidão, intenção, 3 boas | Empacota 13 e 14 | — | — | Não |
| 75 | One line a day | formato | Uma linha, 5 anos | Reencontro | — | — | Não |
| 76 | Bullet journal | Carroll 2013 | Log rápido | Organização | — | — | Não |
| 77 | Interstitial | Stubblebine 2017 | Linha entre tarefas | Transição | — | — | Não |
| 78 | Guided / prompt | Stoic, Grid, Apple | Pergunta no vazio | Começar | — | Formulário | Recusado §3 |
| 79 | Journaling com IA | Rosebud, Reflection, Day One | IA responde | Retenção | — | APA 11/2025 | Recusado §2 |
| 80 | Habit tracker / streak | Seinfeld; Franklin | Corrente | Constância | — | Culpa | Recusado §12 |
| 81 | Kakeibo | Hani Motoko 1904 | Gastos com reflexão | Finanças | — | — | Não |
| 82 | Training log | esporte | Treino, carga | Desempenho | — | Mede | Não |
| 83 | Diários por domínio | tradição | Viagem, leitura, natureza, oração, luto | Memória | — | — | Parcial |
| 84 | Legacy letter / carta ao futuro | tradição | A quem fica ou a si | Sentido | — | — | Não |
| 85 | Art, photo, áudio, vídeo journal | formato | Outro meio | Expressão | — | — | Parcial (ditado) |
| 86 | Shadow work, scripting, manifestation | populares | Prompts, desejo como fato | Nenhum medido | — | Sem evidência | Não |
