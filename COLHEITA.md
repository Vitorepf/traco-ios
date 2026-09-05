# Colheita — o que cada app dá ao Traço, e como entra

**Classificação — propostas de pesquisa de 02/09/2026, com prioridades e premissas históricas.** A finalidade e a divisão de trabalho vigentes estão em [VISAO-PRODUTO.md](VISAO-PRODUTO.md); contratos aceitos, proteções e capacidades implementadas devem ser conferidos na [SPEC.md](SPEC.md) e no [README.md](README.md). Notas de esforço, “agora/depois/nunca”, “como entra” e pedidos de ADR não comprovam aprovação nem implementação. A concordância entre agentes sob o mesmo brief não equivale a validação independente da tese ou evidência científica.

> O `DOSSIE.md` registra juízos; o `CATALOGO.md` inventaria; este arquivo reúne PROPOSTAS. Para cada
> um dos 71 apps, um bloco diz o que vale pegar, como entra no Traço, que poder
> da mente multiplica, que estrutura traz e o quanto eleva o produto.
> A pergunta que manda em cada bloco não é "que recurso é este?" e sim
> "QUE PODER DA MENTE ISTO MULTIPLICA, E COMO?". É por ela que um app de
> palavra-do-dia vira ferramenta de pensar, um app de tarefas vira ordem na
> cabeça, e um segundo cérebro vira contexto perfeito para as IAs do autor.
> Escrito por dez agentes: oito lotes de apps pensando com o mesmo brief, um
> agente com tarefa de pesquisa cognitiva (capítulo dos poderes) e um com tarefa de arquitetura (capítulo do segundo
> cérebro). A síntese do fim é do editor. Fatos de app vêm do catálogo; nada aqui
> inventa função. Data: 2026-09-02.

## Como ler

Cada bloco de app começa com uma linha de metadados:
`poderes: <quais dos dez toca>` · `eleva: N/5` · `esforço: S/M/L` · `quando: agora/depois/nunca`.

| Eleva | Significa |
|---|---|
| **5** | abre um poder da mente que o Traço hoje não multiplica, ou muda a tese |
| **4** | salto grande num poder que já existe, ou dois poderes de uma vez |
| **3** | fortalece um poder existente de forma que o autor sente no primeiro dia |
| **2** | polimento que se sente, sem mudar o que o app faz pela mente |
| **1** | detalhe; entra se sobrar |

Esforço: **S** dias · **M** semanas · **L** meses ou depende de ADR.
Quando: **agora** cabe na FILA como P1 · **depois** P2/P3 · **nunca** o bloco existe para registrar o porquê.

**Critério operativo atual de adoção:** servir à intenção e à realização, preservar origem e privacidade, escolher apoio ou prática conforme o objetivo e verificar resultados proporcionalmente. IA pode produzir trabalho delegado; escrita pessoal e exercício escolhido não podem ser substituídos silenciosamente. A forma de entrada pode começar por uma intenção, não somente por uma nota nua. Conferir decisões aceitas na SPEC antes de tratar uma proposta como requisito.

**Premissa usada na pesquisa original:** os blocos foram escritos sob as antigas “cinco regras de ferro”, página nua e lista fechada de usos da IA. Suas referências numéricas e proibições documentam aquela configuração. Não transferir a recusa de geração na nota pessoal para artefatos de Trabalho, nem inferir que gerar código ou resumos sempre causa dívida cognitiva.

## Os dez poderes da mente — enquadramento de pesquisa

As associações entre métodos, cognição e produtos abaixo são interpretações do levantamento, com fontes preservadas. Não constituem diagnóstico, prescrição clínica, garantia de ganho ou validação experimental do Traço. A definição operacional atual de dívida cognitiva é contextual: importa a capacidade ainda necessária à autonomia pretendida, não a quantidade de trabalho delegada.

Cada app deste documento é lido duas vezes: uma pelo que diz que é, outra pelo que faz com a mente de quem usa. Este capítulo fixa a segunda leitura. Dez poderes, e para cada um: o mecanismo que o faz crescer de verdade, a armadilha que só parece fazê-lo crescer, quem executa melhor entre os 71, o que o Traço já faz, e o salto que falta.

### Memória

**O que é.** Reter o que se decidiu não perder, e trazer de volta sem pista. A memória que vale não é a que reconhece; é a que reconstrói.

**O mecanismo que multiplica.** Recuperação ativa e espaçamento. Tentar lembrar fortalece mais que reler: o efeito de teste (Roediger e Karpicke, 2006) dá retenção maior uma semana depois a quem foi cobrado do que a quem releu, e o intervalo crescente entre cobranças é o que fixa (Cepeda e col., 2006). O esforço é o treino — a dificuldade desejável de Bjork (1994). Recordar sem pista (recall livre) exige mais que responder a uma pergunta, e por isso forma mais.

**O que parece multiplicar e cria dependência.** Releitura passiva: o cartão bonito que passa na frente do olho e dá sensação de saber. Readwise ressurge destaques de outros todo dia; RemNote gera os flashcards por IA — o cartão que o autor não fez perde o efeito de geração (Slamecka e Graf, 1978) antes de ser revisado. Fabric vende achar por significado: quem sabe que a máquina lembra, lembra menos (Sparrow, Liu e Wegner, 2011). E o streak de revisão do RemNote e do Readwise transforma memória em obrigação.

**Quem faz melhor hoje.** Anki: SM-2 e FSRS, um cartão por tela, tipo de nota "type in the answer", nenhuma gamificação. Mochi: resposta binária Remembered/Forgot, FSRS, local-first, sem streak encontrado. SuperMemo: SM-18 e a Algorithm Arena, onde cinco algoritmos competem nos dados da própria pessoa.

**Estado do Traço descrito na pesquisa original.** Recordar (§7): a nota some, o autor escreve de memória, Revelar põe os dois lado a lado; sem nota da IA, sem score — o olho compara. Escada de revisão 3→7→21 e notificação sem conteúdo da nota (§19.2); a notificação abre direto no Recordar; o widget tem um atalho para ele (traco://recordar). Busca é arquivo, não memória (§16).

**O que falta.** A escada é fixa e cega: não sabe se o autor lembrou, e cobra toda nota igual, quando poucas merecem ser lembradas. O espaçamento ainda não reage ao que a comparação mostrou.

### Atenção

**O que é.** Uma coisa por vez, sustentada até acabar. Não é força de vontade: é o ambiente que não oferece fuga.

**O mecanismo que multiplica.** Remoção de alternativas e atrito na saída. O celular na mesa, mesmo desligado, reduz a capacidade de trabalho disponível (Ward e col., 2017); cada troca de tarefa deixa resíduo na seguinte (Leroy, 2009). O que funciona é o pré-compromisso: prazo auto-imposto que custa quebrar (Ariely e Wertenbroch, 2002) e a pausa forçada antes da fuga — a intervenção do one sec reduziu aberturas dos apps-alvo em estudo de campo (Grüning e col., 2023).

**O que parece multiplicar e cria dependência.** O app de foco que pede foco para si. Forest tem loja de espécies, moedas, ranking mundial, eventos sazonais e 859 MB: a atenção que ele protege vira atenção nele. TickTick dá medalha "Mindfulness" por minutos de Pomodoro; Duolingo tem Energy, Streak Freeze e widget que muda de humor. Recompensa externa por atividade que já tinha valor próprio corrói a motivação intrínseca (Deci, Koestner e Ryan, 1999).

**Quem faz melhor hoje.** one sec: pausa antes de abrir o app-alvo, Re-Intervention que expulsa depois de X minutos, lógica toda local. Flowstate: cinco segundos sem digitar apagam tudo; o texto só é salvo quando o timer termina. TIDE: timer com modo imersivo e lista de apps permitidos, sem streak encontrado.

**Estado do Traço descrito na pesquisa original.** A página abre nua, escura, cursor pronto, sem placeholder (§3). Na escrita não há chrome nenhum (§20). Nada anima enquanto o autor digita (§11). Um gesto por sessão (§4). A Expressiva tem timer de 15 minutos e a Análise cala durante ele (§8, §15). O Destaque é uma forma de um campo só: a única coisa de hoje (§6).

**O que falta.** O atrito contra a fuga só existe dentro da Expressiva. Fora dela, a página nua não segura o autor que sai do app, e o Destaque escrito não acompanha o dia — fica na nota.

### Ordem

**O que é.** Pôr o caos em harmonia: saber onde cada coisa da vida mora, e não precisar decidir isso a cada vez. Ordem é a mente livre do que já foi decidido.

**O mecanismo que multiplica.** Offloading cognitivo e redução de escolha. Anotar um plano para o que está pendente elimina a intrusão do pendente (Masicampo e Baumeister, 2011): o que está guardado num lugar confiável para de rodar na cabeça. A memória de trabalho segura cerca de quatro unidades (Cowan, 2001); mais opções visíveis pioram a decisão (Iyengar e Lepper, 2000). Estrutura boa é a que aparece sozinha — chunking que o autor não precisa montar.

**O que parece multiplicar e cria dependência.** A ordem que vira trabalho. Notion tem mais de 50 tipos de bloco e 22 tipos de propriedade: organizar substitui fazer. TickTick tem Achievement Score em 12 níveis, seis medalhas e mais de 40 temas — a ordem ganha placar. Fabric e Evernote organizam sozinhos por IA, e o autor nunca sabe o que tem. Menu de template é a mesma armadilha: exige lembrar o nome da forma para usá-la.

**Quem faz melhor hoje.** Things 3: Inbox, Today com This Evening, Upcoming, Anytime, Someday, Logbook; Área > Projeto > Cabeçalho; nenhuma gamificação. TickTick: caixa única, Smart Recognition da data dentro do texto, Matriz de Eisenhower, e Pasta > Lista > Seção para separar trabalho de vida — o exemplo do dono de pôr a cabeça em harmonia.

**Estado do Traço descrito na pesquisa original.** Auto-forma (§17): a IA veste o texto sem tocá-lo, um toque solta. Régua de 12 como atalho opcional (ADR 31b); digitação viva com a forma vestindo ao soltar o teclado (ADR 31i). Notas com busca, filtros por gesto e seções por mês (§16, §19.2). Três destinos e uma ação (§20).

**O que falta.** A ordem do Traço é dentro da nota, não entre notas: não há domínio de vida, e a nota concluída não tem destino além do arquivo por mês.

### Linguagem

**O que é.** Ter a palavra exata, e saber cortar até sobrar a que vale. Vocabulário é resolução de pensamento: quem tem mais palavras vê mais diferenças.

**O mecanismo que multiplica.** Especificidade lexical e processamento profundo. Dizer nas próprias palavras retém mais que transcrever (Mueller e Oppenheimer, 2014); elaborar o significado fixa mais que repetir a forma (Craik e Lockhart, 1972). Nomear a emoção com precisão reduz a resposta da amígdala (Lieberman e col., 2007), e quem distingue emoções com mais granularidade regula melhor (Kashdan, Barrett e McKnight, 2015). Destilar é o exercício: cada corte obriga a escolher.

**O que parece multiplicar e cria dependência.** A IA que reescreve. Evernote AI Edit reescreve, encurta, expande e muda o tom; Notion melhora a escrita; Raycast tem "Change Tone"; Apple Notes traz Writing Tools dentro da nota. A frase fica melhor e a pessoa, não: dívida cognitiva (Kosmyna/MIT 2025). Do outro lado, o Vocabulary é um feed de palavras raras para rolar — releitura passiva com streak — e o Duolingo troca vocabulário por XP.

**Quem faz melhor hoje.** Signal vs Noise: texto bruto → 200 → 100 → 50 caracteres → uma frase, Hard Mode irreversível, sem IA por princípio. iA Writer: Syntax Highlight pinta adjetivos, substantivos, advérbios e verbos, Style Check acha fillers e clichês localmente, Authorship marca o que veio de IA. Vocabulary: uma palavra por tela, com etimologia, exemplos e sinônimos, em ritmo diário.

**Estado do Traço descrito na pesquisa original.** Quase nada — mas protege o material: a IA nunca completa, resume ou melhora (§2, §19.1). A busca indexa só a voz do autor (§16), Padrões cita fragmento literal (§9), a Nota permanente pede "uma ideia nas suas palavras" (§6), e o aviso de afirmação vazia exige escrever por que um valor importa (§5).

**O que falta.** Tudo que treina, e não só preserva: uma forma que corta em vez de acrescentar, a palavra da emoção na Expressiva, e o vocabulário do próprio autor como material — as palavras que ele usa e as que nunca usa.

### Sentido

**O que é.** Fazer sentido do vivido: transformar o que aconteceu numa história que fecha. Não é aliviar; é entender — e o que foi entendido pode ser deixado.

**O mecanismo que multiplica.** Escrita expressiva. Escrever 15–20 minutos sobre fato e sentimento do mesmo evento, em poucas sessões, melhora saúde e humor meses depois (Pennebaker e Beall, 1986). O ganho vem da construção de sentido, não do desabafo: quem aumenta palavras de causa e insight ao longo das sessões é quem melhora (Pennebaker, Mayne e Francis, 1997). Descartar o papel com o pensamento escrito reduz o peso dele (Briñol e col., 2013). Reler à toa desfaz: é ruminação (Nolen-Hoeksema, 1991).

**O que parece multiplicar e cria dependência.** O sentido pronto. Rescript tem o protocolo certo e, ao fim, a IA analisa tom emocional, temas e "padrões cognitivos" e monta o arco de 4 dias. Mindsera devolve Entry Analysis, Minds que comentam, arte da entrada e Big Five. Reflection tem AI Coach em tempo real; Rosebud tem "Dig deeper" e Guiding Light para quando o autor trava — o prompt que ocupa o vazio. Em todos, a máquina termina a frase que o autor precisava terminar.

**Quem faz melhor hoje.** Zenpen: escrever sem parar, o texto desaparece em 30 segundos, sem conta, e a orientação de não escrever todo dia. Rescript: sessões cronometradas de 15–20 min por quatro dias, e ao fim selar, queimar ou deixar na mesa — sem streak por decisão de design. MindScribber: 15 minutos por dia, três dias, com jogo de vocabulário emocional.

**Estado do Traço descrito na pesquisa original.** Expressiva (§8): timer de 15 min, instrução única (fato e sentimento), grava e sela antes do fecho; fecho com dois métodos validados, Selar (Pennebaker) e Queimar (Briñol), Queimar verdadeiro em toda rota. A linha de sentido é do autor, pulável, e é a única coisa que sai. A Análise nunca comenta uma expressiva. Pedido de consolo recebe aviso (§5); reabrir trancada exige dupla confirmação e Face ID.

**O que falta.** O protocolo original é de três a quatro sessões; o Traço sela uma e não volta. E a linha de sentido, uma vez escrita, não tem retorno — entra na busca, mas nada a traz de volta no momento certo.

### Intenção

**O que é.** Transformar querer em fazer: nomear o obstáculo, ligar o gatilho à ação, escolher uma coisa. A intenção que vale é a que sobrevive ao momento em que o obstáculo aparece.

**O mecanismo que multiplica.** Implementação de intenção e contraste mental. "Se X, então eu Y" cria ligação automática entre pista e ação e fecha a distância entre intenção e comportamento (Gollwitzer, 1999; 94 estudos em Gollwitzer e Sheeran, 2006). Contrastar o desejo com o obstáculo interno separa meta viável de fantasia (Oettingen, 2000); fantasia positiva sozinha reduz a energia para agir (Kappes e Oettingen, 2011). Afirmação vazia piora quem se estima pouco (Wood, Perunovic e Lee, 2009).

**O que parece multiplicar e cria dependência.** O plano que o app escreve, e o streak que cobra. Rosebud sugere metas por IA (Happiness Recipe) e Notion tem Custom Agents a US$ 10 por mil créditos: a intenção deixa de ser do autor. TickTick tem medalha "Self-Discipline"; Duolingo vende Streak Freeze por gems — a intenção vira dívida com o app. E o WOOP app tem o método sem página em branco: formulário no lugar do gesto.

**Quem faz melhor hoje.** WOOP app: quatro passos guiados, "se [obstáculo], então eu [ação]", lembretes recorrentes, grátis, sem IA. one sec: o autor declara a intenção antes de o app-alvo abrir. Things 3: Today e This Evening como recorte do dia, sem placar.

**Estado do Traço descrito na pesquisa original.** Quatro formas de intenção (§6): WOOP com obstáculo interno, Se–então com substituto e não negação, Especificação com "o que eu NÃO vou fazer", Destaque com a única coisa de hoje. Campos nascem vazios (§2, §4); a pergunta é sempre o próximo campo vazio (§19.4). Plano sem obstáculo recebe aviso (§5). A forma é roteada sozinha (§17).

**O que falta.** Escrever a intenção é metade. O Traço não volta para perguntar se o gatilho disparou: o WOOP salvo nunca é cobrado, o Se–então não sabe a hora nem o lugar, o Destaque não sabe se aconteceu.

### Metacognição

**O que é.** Ver os próprios padrões e perguntar-se sobre eles. Saber o que se sabe, o que se repete, e onde a própria estimativa erra — sem que ninguém dê a nota.

**O mecanismo que multiplica.** Metamemória calibrada por evidência própria. Monitorar o que se sabe é o que decide o que rever (Flavell, 1979; Nelson e Narens, 1990), e o monitor erra por fluência: o que parece fácil de ler parece sabido (Koriat e Bjork, 2005). A calibração vem de comparar o que se achava com o que se tinha — o olho, não o placar. E a pergunta feita com a palavra literal do autor obriga a gerar a explicação; explicação gerada é a que fica (Chi e col., 1989).

**O que parece multiplicar e cria dependência.** O diagnóstico pronto e o placar. Reflection entrega Insights (sentimento, paisagem emocional, crescimento) e um AI Coach que celebra progresso; Mindsera devolve Big Five e Thinking Traps; Rosebud gera relatório semanal com humor e tópicos. Whoop dá Recovery de 1 a 99% e WHOOP Age, Oura dá Readiness: medir a si mesmo por número tira o prazer e a motivação da atividade medida (Etkin, 2016). A máquina descrevendo quem você é, a partir do que você acabou de confessar, é o §2 violado no ponto mais sensível.

**Quem faz melhor hoje.** Whoop e Oura acertam a parte honesta: o autor marca comportamentos no Journal e o app cruza com o medido e mostra correlação (Discovery Hub, Monthly Performance Assessment) — o erro é a nota. Rosebud responde com links às entradas: a citação é o certo, a resposta é a armadilha. 750 Words mede o próprio processo — tempo até 750 palavras, distrações, palavras por minuto — sem LLM.

**Estado do Traço descrito na pesquisa original.** Padrões (§9): só quando pedido, lê as últimas ~12 notas não-trancadas, devolve 2–3 perguntas citando fragmento literal; a pergunta vira cartão fixo e o autor responde na página vazia; proibido conclusão, diagnóstico e dashboard. Verificação dura (§19.4): tem "?" e cada trecho entre aspas existe literalmente, ou é descartada. Recordar é o outro espelho: comparação lado a lado, sem nota (§7).

**O que falta.** Padrões não tem memória de si: a pergunta feita, a resposta dada e o que mudou não se ligam. E o Recordar mostra a comparação uma vez e ela some — o autor nunca vê onde a própria estimativa costuma errar.

### Captura

**O que é.** Não perder o traço no instante em que aparece, de onde a pessoa estiver. A ideia tem segundos de vida; a captura é o que a transforma em coisa.

**O mecanismo que multiplica.** Offloading no instante certo. A memória de trabalho segura pouco e por pouco tempo (Cowan, 2001); "anotar depois" é memória prospectiva, e ela falha quando a pista não aparece (Einstein e McDaniel, 1990). Capturar tira a carga e devolve a atenção (Risko e Gilbert, 2016) — desde que o guardado seja reprocessado depois. O que se captura sem processar não é lembrado: fotografar o objeto piora a memória dele (Henkel, 2014).

**O que parece multiplicar e cria dependência.** Capturar tudo e lembrar nada. Otter promete que você nunca mais tome nota — o gesto inteiro terceirizado. Fabric e Evernote engolem página, print, áudio e PDF sem pedir nada: a coleção cresce e o processamento nunca acontece. Readwise captura os destaques dos outros. O segundo produto também é armadilha: a captura que exige escolher pasta, tag e formato antes de escrever já perdeu o instante.

**Quem faz melhor hoje.** Shazam: um toque, Central de Controle, botão de Ação, Siri sem o app instalado, fila offline — o resultado chega depois. Drafts: abre em rascunho novo com o teclado pronto, captura pelo Watch, folha de compartilhamento com Quick Capture sem interação. Câmera na tela bloqueada: ação de sistema sem desbloquear — o teto de ambição. Obsidian: "Capture to Daily Note" roda em segundo plano, sem abrir o app.

**Estado do Traço descrito na pesquisa original.** Widget de dois atalhos (U4): um toque abre a página em branco (traco://nova), outro o Recordar (traco://recordar). Atalhos, Siri, traco:// e Spotlight (§19.2). A página abre com cursor em menos de um segundo (§13). Trocar de tela salva; navegar nunca custa uma palavra (§20).

**O que falta.** O widget abre a página, mas nada entra por ela de fora: sem folha de compartilhamento, sem voz, sem captura da tela bloqueada. O traço ainda precisa do teclado e do app aberto.

### Arquivo

**O que é.** A nota é do autor, dura décadas e sai em texto. Arquivo é a condição de confiança: só se descarrega da cabeça o que se sabe que não vai sumir.

**O mecanismo que multiplica.** Sistema externo confiável. A mente só solta o pendente quando confia no lugar onde ele foi posto (Masicampo e Baumeister, 2011); memória transativa funciona quando se sabe onde está e que estará lá (Wegner, 1987). O formato decide a década: texto puro sobrevive ao app, ao aparelho e à empresa. E o arquivo serve a duas funções do mesmo corpus — a busca acha para agir, o Recordar cobra para lembrar.

**O que parece multiplicar e cria dependência.** A nuvem que parece infinita e cobra pela saída. Evernote Free tem 50 notas e um aparelho, e a exportação no celular é limitada; Notion guarda 7 dias de histórico no Free e não importa pelo celular; Fabric exporta sem metadados, tags ou comentários, e sem reimportação; Rosebud encerra o plano grátis em setembro de 2026 e manda exportar; Readwise Lite não exporta para apps. Evernote, Bear 2 e Kindle já apagaram, migraram ou quebraram material de quem pagava. E saber que está salvo faz lembrar menos (Sparrow, Liu e Wegner, 2011): sem o Recordar, arquivo é esquecimento organizado.

**Quem faz melhor hoje.** Obsidian: uma pasta local de arquivos Markdown, Importer de mais de dez fontes, File recovery, sync ponta a ponta opcional. iA Writer: arquivos de texto simples em iCloud ou Files, "iA Inc does not have access to any of the user's content", Style Check e Authorship processados no aparelho. Drafts: backups .draftsExport periódicos, histórico de versões, Advanced Data Protection ponta a ponta.

**Estado do Traço descrito na pesquisa original.** SwiftData local, sem nuvem, sem conta (§10, §12). Export e import Markdown com gesto e campos preservados; backup automático; busca sem acento; seções por mês (§19.2). Nota antiga nunca quebra: o catálogo completo de formas permanece no formato de arquivo (ADR 31b). Selo em toda rota de saída, Queimar verdadeiro por rota (§8, §19.2). Apagar com atrito (ADR f). Exportar e importar moram no Perfil (§20).

**O que falta.** O .md ainda é backup do SwiftData, não a fonte: o arquivo não sobrevive ao app por si. E não há histórico de versões — a nota editada perde a anterior.

### Segundo cérebro

**O que é.** O corpus inteiro como contexto perfeito: para o autor, que reencontra o que pensou; e para as IAs que ele usa, que passam a trabalhar com quem ele é, não com a média. É o poder que leva os outros nove para fora do app.

**O mecanismo que multiplica.** Mente estendida com material próprio. Um sistema externo confiável e sempre à mão faz parte do processo cognitivo (Clark e Chalmers, 1998); a memória transativa distribui o saber entre quem lembra o quê (Wegner, 1987). A condição é a origem do material: contexto escrito pelo autor, nas palavras dele, carrega o efeito de geração para dentro da IA — a resposta sai calibrada à mente que escreveu. Contexto escrito por IA sobre o autor é contexto de ninguém.

**O que parece multiplicar e cria dependência.** A máquina que lembra no seu lugar. Fabric cobra créditos de pensamento e organiza sozinho; Rosebud vende memória de longo prazo; Evernote tem AI Memory; Notion Agent age sobre o workspace. Otter, Raycast e Craft ensinam o mercado a chamar de segundo cérebro o arquivo que pensa por você. O resultado é memória transativa com a máquina: sabe-se onde está, não o quê (Sparrow, Liu e Wegner, 2011) — e a IA recebe contexto de um corpus que o autor não formou.

**Quem faz melhor hoje.** Obsidian: o corpus é a pasta, o CLI cobre cerca de 30 áreas de comando, e não há IA nativa no app. Drafts: servidor MCP e CLI, ações que chamam os modelos com a chave do próprio usuário, Apple Intelligence no aparelho para resumo e tags. Fabric: a ambição completa — MCP, CLI, API, agents, memória — na nuvem, com créditos.

**Estado do Traço descrito na pesquisa original.** Não tem seção na SPEC: é direção nova do dono (02/set). O que já serve a ela: corpus local em Markdown exportável (§19.2); só a voz do autor viaja, sem mobiliário nem anexos (§19.1); nota trancada e expressiva jamais saem do aparelho (§19.1); zero servidor próprio, zero conta obrigatória, zero cobrança por token (§5, README).

**O que falta.** Uma porta de saída que não seja exportar à mão — o corpus chegar às IAs do autor com o selo valendo — e o ADR que isso exige: §12 lista sync, nuvem e busca semântica como não-objetivos, e §19 diz que só a voz do autor viaja.

### Como os poderes se somam

- Atenção é condição de todos: sem uma coisa por vez não há escrita, e sem escrita não há corpus.

- Captura alimenta Arquivo: o traço que não entra não existe.

- Arquivo alimenta Memória (o Recordar só cobra o que está guardado) e Segundo cérebro (o corpus é o arquivo em texto).

- Linguagem alimenta Memória: o que foi dito nas próprias palavras é o que o Recordar consegue cobrar.

- Linguagem multiplica Sentido (a palavra de insight é o sentido encontrado) e Metacognição (Padrões cita a palavra literal; sem precisão não há padrão).

- Ordem sustenta Intenção (o Destaque é uma escolha; a forma é ordem dentro da nota) e barateia a Captura (caixa única, nenhuma decisão na entrada).

- Intenção depende de Memória: o Se–então precisa ser lembrado na hora do gatilho.

- Ordem serve à Memória: texto vestido é chunking, e o que tem forma se reconstrói melhor que o que é bloco.

- Atenção sustenta Sentido: a Expressiva são 15 minutos sem fuga, ou não há construção nenhuma.

- Captura serve à Intenção: o Se–então que vale nasce no momento em que o obstáculo aparece, não na revisão de domingo.

- Metacognição fecha o ciclo: lê o Arquivo, devolve pergunta, e a resposta vira nota nova — Captura de novo.

- Sentido é a exceção que confirma Memória: a única nota que não deve ser lembrada, e por isso o selo vale em toda rota.

- Segundo cérebro é a soma: só vale se os outros nove estiverem vivos. Corpus escrito por IA é contexto de ninguém.

### O que nenhum dos 71 faz — hipótese histórica de diferenciação

A exclusividade e a certeza de “100% autor” abaixo não são garantias vigentes. Origem precisa de registro verificável por conteúdo; ter um corpus de notas não prova autoria integral nem representação completa da pessoa.

Os 71 dividem os dez poderes em 71 produtos: o Anki guarda a memória, o TickTick a ordem, o Rescript o sentido, o Fabric o segundo cérebro — cada um com o próprio cofre, cada um exigindo que o autor fabrique um segundo artefato (cartão, tarefa, entrada) para servir àquele poder. O Traço aposta que a mesma nota, escrita uma vez, serve aos dez: é o que foi capturado, arquivado, vestido, cobrado, perguntado e entregue como contexto. A mesma regra de ferro governa os dez — a IA nunca escreve — e isso faz do corpus a única coisa no mercado que uma IA pode receber como contexto com a certeza de que é 100% o autor. Nenhum dos 71 tem uma nota que o próprio produto se recusa a ler; o Traço tem, e é ela que torna o resto confiável.

### O critério para cada adoção — proposta da pesquisa original

**Uso atual:** não aplicar os itens 2 e 3 como veto à delegação. A realização pode depender legitimamente de ferramentas; preservar autonomia não exige reproduzir sozinho tudo que foi delegado. O limite é substituir uma capacidade ou prática ainda necessária ao objetivo sem reconhecer essa escolha.

1. A pergunta não é "que recurso é este?", é "que poder da mente isto multiplica, e como?" — com o mecanismo nomeado, ou não entra.

2. Multiplicar é o autor sair da sessão mais capaz sem o app; substituir é sair mais dependente dele. O teste: tira o app — o que sobra na cabeça?

3. Se o mecanismo exige que o app faça o gesto (escrever, resumir, lembrar por ele), é substituição, por melhor que o app seja.

4. A IA sugere, o algoritmo garante (§19.3): nada que o autor perca se a IA sumir mora do lado da IA, e o que ela devolve é rótulo de lista fechada, verificável.

5. O que contradiz a SPEC não se descarta: escreve-se o ADR com o § afetado. O segundo cérebro é o primeiro deles.

---

## O segundo cérebro: proposta histórica de corpus como contexto

“Contexto perfeito” e “mente inteira”, no texto original abaixo, são formulações da pesquisa de 02/09, não propriedades demonstradas. O capítulo continua preservado como fonte de propostas; o limite vigente está explicitado a seguir.

`poder: Segundo cérebro (novo) · toca Arquivo, Intenção, Sentido, Captura` · direção declarada pelo dono em 02/set/2026 · ainda sem seção na SPEC

### A direção do dono, em uma frase — interpretação registrada em 02/09

Esta formulação do levantamento não substitui a explicação direta do criador consolidada em VISAO-PRODUTO em 05/09.

O Traço não guarda só a mente do autor: entrega essa mente, inteira e
estruturada, a cada IA que ele usa — Claude, ChatGPT, Grok, Raycast — para que
todas trabalhem com contexto perfeito sobre ele.

Isto não fere a regra de ferro. O §2 proíbe a IA de escrever NA nota. A direção
nova é a seta contrária: a nota do autor sai para alimentar a IA dele, por
ordem dele. Hoje a voz já viaja para o Grok na Análise (§5, §19.1); passa a
viajar também para as outras IAs, pelas rotas de export que o §19.2 já chama
de algoritmo ("Arquivo", "Sistema"). Nada volta; nenhuma IA ganha porta de
escrita. A regra 10 fica de pé: sem servidor, o corpus vai direto ao autor.

### Limite vigente do capítulo de segundo cérebro

O corpus de notas é uma fonte parcial de contexto. Não representa a mente inteira nem fornece contexto perfeito. O modelo da pessoa deve distinguir observação, relato e hipótese, com fonte e correção possível. O fluxo atual admite produção delegada em Trabalho e intercâmbio Markdown com proveniência; não se reduz a exportação de notas nem a “nada volta”. O MCP de notas conserva permissões próprias: consulte [seu contrato operativo](ferramentas/traco-mcp/README.md), sem deduzir delas os limites de todo o produto. Os desenhos de canal e ADRs a seguir são propostas históricas, não autorização para ampliar rotas de dados privados.

### O que a pesquisa chamou de "contexto perfeito"

O não-óbvio: a IA não precisa de mais prosa sobre o autor. Precisa de DADOS
sobre a intenção dele — e as formas do §6 já são isso. Um WOOP exportado
carrega `resultado`, `obstaculo`, `plano`; um Se–então, gatilho e substituto;
uma Especificação, `problema`, `pronto`, `nao`, `restricoes`, `limites`; uma
Nota permanente, `ideia`, `liga`, `fonte`; um Destaque, a única coisa do dia.
Campos com id fixo (`Gesto.campos`), preenchidos pelo autor, nunca pelo modelo:
um esquema de intenção, obstáculo, plano e critério de pronto. Nenhum app do
CATALOGO exporta isso: Reflection e Fabric exportam prosa; Notion, blocos;
Readwise, grifos de outros.

Quatro sinais que só o Traço tem, e que valem mais que o texto:

- **O gesto por nota** (`gesto:`): desejo, hábito, projeto, ideia, dia ou
  desabafo. Rótulo nosso, determinístico.
- **A linha de sentido** das expressivas (`Nota.sentido`): a frase que o autor
  escreveu depois de 15 minutos de peso. Sobrevive ao selo e à queima (§8.5).
- **A data** (`criada:`, ISO 8601): o corpus é série temporal. A IA vê o WOOP
  de março e o Se–então de junho sobre o mesmo obstáculo.
- **As revisões do Recordar** (`Revisoes.contagem`): quantas vezes o autor
  recordou a nota de memória — o único sinal do que ele de fato reteve.

**O formato já existe.** `Corpus.arquivoMd` grava Markdown com front matter
(`criada:`, `gesto:`), o texto do autor e um bloco `— Gesto —` com
`Rótulo: resposta` por campo; o import faz o roundtrip (`separarCampos`, teste
`importaOProprioExport`). Não precisa de JSON: Markdown com front matter é o
que Obsidian lê, o que Claude e ChatGPT ingerem, e o que o autor abre com os
olhos daqui a vinte anos (§10).

**O que falta, sem inventar campo:** `id:` (o `uuid`, para a IA citar a nota
de forma estável), `editada:`, `recordada: N`, e, para expressivas fechadas, um
bloco SEM corpo com `estado: selada|queimada`, `minutos:` e `sentido:`. Hoje
`corpoDoCorpus` filtra por `fechada` e a linha de sentido não sai — o §8.5 diz
que ela "entra no export". É lacuna, não ADR. As chaves dos campos podem usar o
`campo.id` (`obstaculo:`); o import já aceita os dois nomes (`Gesto.doNome`).

### O que sai, o que nunca sai

Lista fechada, válida para toda rota deste capítulo:

- **Sai:** só a voz do autor — `Caderno.prosa` mais as respostas dos campos,
  como `VozDoAutor` já monta — e os metadados acima.
- **Nunca sai:** nota trancada, expressiva (mesmo aberta, com timer), o corpo
  de uma queimada (sobram `sentido`, `minutos`, data), mobiliário (labels,
  `traco://`, cercas, anexos — `semReferenciaInterna` é a fronteira), e nada
  que a IA tenha devolvido (Veredito, perguntas de Padrões).
- **Nunca sem gesto:** cada saída é um toque do autor (Concluída, Exportar,
  Compartilhar, um Atalho dele). Nada sai por timer, por abertura do app ou
  por pedido de uma IA.
- **Nunca para servidor do Traço:** não existe servidor (README). O arquivo vai
  do aparelho ao Arquivos, à folha, ao Atalho — e dali à IA que o autor escolheu.

**Como se testa.** Doutrina do §8.6, teste por rota: toda saída nova ganha um
teste com o mesmo corpus-fixture de quatro notas — aberta com WOOP, selada,
expressiva com timer correndo, queimada com linha de sentido. Aceite único: a
saída contém a voz da aberta e o `sentido` da queimada; nenhuma palavra da
selada nem da expressiva; nenhum rótulo como voz; nenhum `traco://`.
`trancadaNuncaSaiNoExport` e `queimadaNuncaSaiNoExportNemNoBackup` já cobrem a
rota de arquivo; cada canal replica o par. Sem o teste, o canal não entra.

### Os canais possíveis no iOS sem servidor

**(1) A pasta de backup no app Arquivos, lida por Obsidian e pelos conectores
de arquivo do Claude/ChatGPT no desktop.**
O que existe: `Corpus.backupAutomatico` grava `traco-corpus.md` em Documents a
cada Concluída e a cada queima; com `UIFileSharingEnabled` e
`LSSupportsOpeningDocumentsInPlace` ligados no `project.yml`, o arquivo aparece
em Arquivos › No meu iPhone › Traço e, com cabo, no Finder do Mac. O que
falta: (a) a pasta no iCloud Drive — container ubiquity, exige entitlement e
conta Apple Developer paga, hoje BLOQUEADA na FILA; (b) um `.md` por nota, que
é o que Obsidian e os conectores de pasta preferem; (c) os metadados do
formato. Esforço: (b)+(c) S; (a) M mais ADR. Risco: iCloud é nuvem da Apple
(§12); o arquivo fica em claro no disco do Mac como um vault do Obsidian; e se
outro app editar a pasta, o Traço não obedece — o arquivo é espelho, não fonte
(só o Import traz de volta, nunca trancada). Precedente: Drafts grava
`.draftsExport` em iCloud Drive sem conta própria.

**(2) Folha de compartilhamento: "Compartilhar como contexto".**
A nota aberta, ou o resultado de um filtro das Notas, sai pela folha do
sistema como o bloco `.md` de (1). O que existe: `UIActivityViewController`
para o export inteiro (NotasView.swift:395) e `ShareLink` para anexos. O que
falta: a ação na nota aberta e no toque longo do cartão; o conjunto (o filtro
por gesto do §16 já é a seleção — "estes 8 WOOPs"); o bloco por nota. Esforço
S. Risco: §12 lista "Compartilhamento" como não-objetivo — aquilo é com gente;
isto é export para a própria IA, e pede uma linha de ADR.

**(3) App Intents e Atalhos: "notas por gesto" e "linhas de sentido" para
Raycast, Siri e Atalhos.**
Intents que DEVOLVEM texto, sem abrir o app, para o Atalho encadear com a IA
que o autor usa. O que existe: `NovaNotaIntent` e `AbrirNotasIntent`, os dois
com `openAppWhenRun`, sem parâmetro e sem retorno; `traco://nova|notas|
recordar`. O que falta: um `AppEntity` de Nota (só abertas) com `EntityQuery`;
`NotasPorGestoIntent(gesto) -> String`; `LinhasDeSentidoIntent -> [String]`;
`DestaqueDeHojeIntent -> String`. Com isso o autor monta "Traço: WOOPs →
Raycast: Ask AI" (o Raycast iOS tem ações de Atalhos, CATALOGO) ou pede à Siri
"minhas linhas de sentido no Traço" — o padrão do `Search Vault` do Obsidian.
Esforço M. Risco: rota de saída nova (`fechada` na query, teste por rota); a
Siri lendo em voz alta é exposição — só abertas, nunca a expressiva.

**(4) Spotlight.**
O que existe: `Holofote.indexar` grava título e 120 caracteres das 200 abertas
mais recentes; trancada nunca entra. O que falta: a rota do toque no resultado
até a nota (não há `CSSearchableItemActionType` no app — hoje abre o Traço,
não a nota). Esforço S. Risco: nenhum novo. Leitura honesta: Spotlight serve ao
autor, não às IAs dele — é Captura e Arquivo, não canal de contexto.

**(5) O pacote de contexto: o corpus inteiro para um projeto do Claude/ChatGPT.**
O que existe: `Corpus.exportar` já gera `traco-corpus-AAAA-MM-DD.md` com todas
as abertas — é o pacote, cru. O que falta: um cabeçalho fixo do app no topo (o
que é este arquivo, o que cada `gesto:` e cada campo significa, e que
trancadas não estão aqui), um índice determinístico (contagem por gesto,
primeira e última data, quantas linhas de sentido) e os metadados do formato.
O cabeçalho é template do app (§2: labels nossos), nunca prosa do modelo; um
só `.md`, `.zip` só se (1b) virar um arquivo por nota. Esforço S. Risco: o
pacote envelhece — é fotografia; (1) e (6) tiram do autor o gesto repetido (§17).

**(6) Servidor MCP.**
Reflection, Readwise, Drafts, Otter e Fabric expõem MCP para Claude e ChatGPT:
a IA consulta o app por ferramenta, com dado fresco. Por que não roda no
iPhone: um servidor MCP é um processo que fica de pé esperando o cliente; o
iOS suspende o app ao sair da tela, não permite daemon, e o Claude Desktop no
Mac não alcança um processo dentro do telefone. O Raycast iOS CONSOME MCP por
HTTP; nenhum app do inventário HOSPEDA MCP no iOS. O que resolve: um
companheiro no Mac — binário sem interface que lê a pasta de (1) e expõe
`buscar`, `notas_por_gesto`, `linhas_de_sentido`, `nota(id)` para Claude
Desktop, Claude Code e ChatGPT. Só leitura: não há ferramenta `escrever` (o
Reflection separa chave de leitura e de escrita; o Traço emite só leitura, sem
chave — é arquivo local). Não é servidor do Traço (regra 10): roda no Mac do
autor, só em localhost. Esforço L (produto novo, distribuição própria). Risco:
depende de (1a) ou do cabo para o arquivo estar fresco; e o companheiro aplica
o mesmo teste por rota ao que lê (`.md` importado à mão com `traco://` não
passa adiante).

**(7) O inverso: a Análise lendo mais do corpus do que as ~12 notas dos Padrões.**
Hoje `PadroesView` toma as 12 abertas mais recentes e `PadroesRemoto` manda
800 caracteres de cada, 9.000 no total; as perguntas citam só o que coube. Dois
degraus: (a) pertinência LEXICAL — índice invertido local sobre `vozDoAutor`,
que escolhe as 12 mais parecidas com a página atual ou com o mês; é busca, não
interpretação, cabe no §16 sem ADR; (b) semelhança SEMÂNTICA com `NLEmbedding`
do NaturalLanguage, offline — é "busca semântica", não-objetivo do §12: pede
ADR. O §19.4 exige dos dois: seleção é algoritmo, determinística e testada; a
IA segue devolvendo só perguntas; a prova literal de cada trecho entre aspas
roda sobre o corpus INTEIRO, não sobre a janela. O §19.1 exige: trancada e
expressiva nunca entram na janela; o teto de 9.000 caracteres fica — a
pertinência gasta melhor a janela, não a aumenta. Esforço: (a) M; (b) M mais
ADR. Risco: mais notas, mais tentação de conclusão e placar — §9.4 proíbe.

### O que isto pede de ADR

1. **§12 "Sync/nuvem/conta" e §10 "Sem nuvem" × pasta no iCloud Drive (1a).**
   "Sem servidor e sem conta do Traço, sempre. A pasta de backup pode viver no
   iCloud Drive do autor: é a nuvem dele, nenhum byte passa por nós; sem iCloud
   ela fica em No meu iPhone. Sync entre aparelhos continua não-objetivo."
2. **§12 "Compartilhamento" × "Compartilhar como contexto" (2).** "Compartilhar
   com pessoas continua fora. Entregar a própria nota à própria IA pela folha
   do sistema é export — e export é algoritmo desde o §19.2."
3. **§12 "Busca semântica" × janela dos Padrões (7b).** "A busca do autor segue
   lexical (§16). A escolha das 12 notas dos Padrões pode usar semelhança local
   e offline; nada interpretado chega à tela; a prova literal vale no corpus."
4. **§19.1 "só a voz do autor viaja".** "A voz viaja para a IA do autor — o
   Grok pela Análise, e qualquer outra pelas rotas que o autor dispara. Sempre
   `Caderno.prosa` mais campos; trancada, expressiva e queimada não saem por
   rota nenhuma. Toda rota nova nasce com o teste do selo."
5. **§18 perfil mínimo.** "A seção DADOS ganha o interruptor da pasta no iCloud
   Drive, com linha de estado honesta como a da conta Grok. Nada de lista de
   IAs, conectores ou chave."
6. **§10 modelo × export.** "O export ganha `id:`, `editada:`, `recordada:` e,
   para expressivas fechadas, `estado:`, `minutos:` e `sentido:` sem corpo. O
   modelo não muda; o import ignora `id:`."
7. **§9 "as últimas ~12 notas".** "As 12 mais pertinentes, por algoritmo
   local; o teto de 12 fica — é o que cabe na verificação e no pool."

### A armadilha do Fabric — interpretação histórica

A oposição abaixo entre máquinas “fora” e mente “dentro” não rege o propósito vigente. Recuperação assistida, prática e produção podem coexistir no Traço; a divisão depende da intenção. A antiga ausência de retorno/MCP de escrita/chat não deve ser tratada como estado atual.

Recuperar não é formar (VIZINHANCA, "O vão" 4): Fabric vende achar por
significado para nunca precisar lembrar — o adversário conceitual do §7. O
Traço serve as IAs do autor para FORA, nunca para DENTRO: nenhum canal tem
volta, o MCP não escreve, e não existe "pergunte às suas notas" no app (§12).
O Recordar continua cobrando do autor, de memória e sem pista, a nota que o
Claude já leu: a IA fica mais capaz no trabalho dele; a mente treina aqui.

### Ordem de ataque

1. **Completar o export** — `id:`, `editada:`, `recordada:`, o bloco sem corpo
   das expressivas fechadas com `sentido:`, e o cabeçalho fixo com índice.
   Transforma `traco-corpus.md` no pacote de contexto (5) e fecha a lacuna do
   §8.5. Esforço S. Multiplica Segundo cérebro e Sentido hoje: o autor sobe o
   arquivo num projeto do Claude ou do ChatGPT e a IA conhece a intenção dele.
2. **"Compartilhar como contexto"** na nota aberta e no filtro das Notas (2).
   Esforço S, uma linha de ADR. Multiplica Intenção: um WOOP chega à IA já como
   plano com obstáculo, não como pedido vago.
3. **App Intents com retorno** — `AppEntity` de Nota, notas por gesto, linhas
   de sentido, destaque de hoje (3). Esforço M. Multiplica Captura e Segundo
   cérebro fora do app: Raycast, Siri e Atalhos leem o Traço sem abri-lo.
4. **Um `.md` por nota e a pasta no iCloud Drive** (1). Esforço M, ADR e conta
   Apple Developer (bloqueada). Multiplica Arquivo: Obsidian e os conectores de
   pasta do Mac veem o corpus fresco sem gesto além de Concluída.
5. **Companheiro Mac com MCP só de leitura** (6). Esforço L, depende do 4.
   Multiplica tudo de uma vez: Claude Code e Claude Desktop consultam o corpus
   por ferramenta, sem o autor colar nada.

O canal 7 fica depois: é o único que melhora o Traço por dentro, e pede ADR antes.

---

## Os 71, um por um

[1Password](#1password) · [750 Words](#750-words) · [Amplenote](#amplenote) · [Anki](#anki) · [Apple Books](#apple-books) · [Apple Notes](#apple-notes) · [Apple Photos](#apple-photos) · [Apple Reminders (Lembretes)](#apple-reminders-lembretes) · [Apple Wallet](#apple-wallet) · [Atalhos (Apple)](#atalhos-apple) · [Bear](#bear) · [Beaver Notes](#beaver-notes) · [BeReal](#bereal) · [Calm](#calm) · [Câmera na tela bloqueada](#camera-na-tela-bloqueada) · [Clear](#clear) · [Clover](#clover) · [Craft](#craft) · [Day One](#day-one) · [Drafts](#drafts) · [Duolingo](#duolingo) · [Edda](#edda) · [Evernote](#evernote) · [Fable](#fable) · [Fabric](#fabric) · [Family](#family) · [Flowstate](#flowstate) · [Forest](#forest) · [Freewrite](#freewrite) · [Google Photos](#google-photos) · [Grid Diary](#grid-diary) · [Halide](#halide) · [iA Writer](#ia-writer) · [Instapaper](#instapaper) · [Just Write](#just-write) · [Kindle](#kindle) · [Life Reset](#life-reset) · [MindScribber](#mindscribber) · [Mindsera](#mindsera) · [Mochi](#mochi) · [monday.com](#monday-com) · [Notion](#notion) · [Numbers](#numbers) · [NYT Games](#nyt-games) · [Obsidian](#obsidian) · [One Sec](#one-sec) · [Otter.ai](#otter-ai) · [Paper (FiftyThree)](#paper-fiftythree) · [Raycast (iOS)](#raycast-ios) · [Readwise](#readwise) · [Reflection](#reflection) · [RemNote](#remnote) · [Rescript Journal](#rescript-journal) · [Rosebud](#rosebud) · [Runestone](#runestone) · [Shazam](#shazam) · [Signal](#signal) · [Signal vs Noise](#signal-vs-noise) · [Stoic](#stoic) · [Strava](#strava) · [SuperMemo](#supermemo) · [Taio](#taio) · [The Most Dangerous Writing App](#the-most-dangerous-writing-app) · [Things 3](#things-3) · [TickTick](#ticktick) · [TIDE](#tide) · [Vocabulary](#vocabulary) · [Whoop / Oura](#whoop-oura) · [WOOP app](#woop-app) · [Write or Die](#write-or-die) · [Zenpen](#zenpen)

---

### 1Password
`poderes: Sentido · Arquivo` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O selo só vale se vale em toda rota — inclusive nas que o sistema abre sem o app saber: o trocador de apps, a área de transferência, a sessão que fica aberta depois de um Face ID. O 1Password trata cada uma como porta, e fecha.

**A função, como existe lá.** "Bloqueio automático ao sair do app com tempo configurável" e "bloquear quando o aparelho bloqueia": o cofre fecha sozinho, e a tela trancada não vaza nem o nome do item. "Limpa a área de transferência após 90 segundos". "Desbloquear com o dispositivo" vale só até 10 minutos após um desbloqueio separado — a sessão aberta tem prazo. "Preenche só nos sites onde o item foi salvo": o segredo só aparece no contexto em que nasceu. "Ordenação por frequência de uso". "Histórico de senhas por item e restauração de versões anteriores".

**Como entra no Traço.**
1. **Cortina no trocador de apps.** Com o timer da expressiva rodando, ou com uma selada reaberta, `scenePhase != .active` cobre a página com o fundo `#0B0B0D` puro antes de o iOS tirar o snapshot. O trocador mostra uma página preta, sem texto. Algoritmo; `onChange(of: scenePhase)` na raiz, onde já mora a confirmação (§15). Muda §8.6: a lista de rotas do Queimar/Selar ("arquivo, Spotlight, backup, revisão") ganha "trocador de apps". Teste por rota, como as outras.
2. **Reabrir tem prazo.** Hoje reabrir uma selada é dupla confirmação + Face ID; falta o fim. Ao sair da nota, ou depois de N minutos em segundo plano, ela volta a selar sozinha — nenhum estado "aberta" é persistido. Muda §8: "reabrir" passa a ser "reabrir por esta leitura".
3. **Área de transferência.** Selada reaberta não oferece Copiar: a folha é para reler, não para levar. Menos código do que limpar o pasteboard, e mais honesto.

**O poder que traz.** Sentido pelo mecanismo de Pennebaker: o ganho da expressiva vem da construção de sentido, e reler desfaz. Um selo com furo no trocador de apps é um selo que mente — e o autor que sabe que ele mente não escreve com a mesma entrega. A confiança no cofre é a condição do desabafo inteiro.

**A estrutura que traz.** Nenhum campo novo. Uma view de cortina na raiz, ligada a `scenePhase` e a `expressivaAtiva || seladaReaberta`. Um `Task` de re-selar com prazo. O flow `expressiva-trancar` ganha um passo: mandar o app para o fundo e voltar.

**O quanto eleva.** 3: não abre poder novo, mas o selo é o mecanismo do Sentido, e mecanismo com furo não é polimento — é método quebrado. O autor sente na primeira vez que troca de app no meio de um desabafo.

**O que fica de fora — proposta histórica.** Cofres, coleções, tags. Watchtower com "pontuação de segurança": placar (regra 5). Histórico de versões por item: no Traço a nota é o que o autor deixou, e guardar rascunhos é convidar a reler — §3 diz que reler é o anti-padrão. Travel Mode (esconder cofres por contexto) pede domínios de vida que o Traço não tem.

**O não-óbvio.** O 1Password é um app de NÃO lembrar: existe para a cabeça largar o que pode ser confiado ao cofre — e só funciona porque a recuperação é instantânea e nunca falha. O Traço tem as duas metades e precisa deixá-las claras: Notas/busca é o cofre (offloading — o que está lá, a cabeça pode soltar), Recordar é o treino (o que o autor decidiu carregar). A escada 3→7→21 precisa de um critério para saber qual nota é qual, e o 1Password sugere o critério sem perguntar nada: ele ordena por frequência de uso. A nota que o autor nunca reabriu depois de Concluída é cofre; a que ele reabriu é candidata a memória.


---

### 750 Words
`poderes: Atenção · Sentido · Metacognição` · `eleva: 2/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** Dois princípios, e nenhum deles é a cota: o texto do autor vira dado sem IA e sem formulário — uma linha `CHAVE: valor` no meio da prosa é estrutura suficiente; e um dicionário de palavras classifica tom emocional sem modelo, offline, determinístico.

**A função, como existe lá.** "Metadados por linha em maiúsculas com dois-pontos (ex.: HAPPINESS: 8, WATCHED: filme, TODO: tarefa) viram dados rastreáveis". "Análise de emoções, temas e 'mindset' das entradas por dicionário de imagens regressivas (Regressive Imagery Dictionary), sem LLM". "A página rola como máquina de escrever conforme se digita". "Lock: palavra ou frase secreta pedida ao entrar e após 10 minutos sem uso". "Estatísticas coletadas: ritmo de digitação, pausas, número de distrações".

**Como entra no Traço.**
1. **Dicionário como roteador de reserva.** O motor local roteia "desabafo longo" por heurística (§19.2). Um léxico pequeno em português (afeto negativo, primeira pessoa, verbos de estado), embarcado no app, dá ao roteador um sinal de tom que hoje não existe — para vestir Expressiva sem rede com mais acerto, e para calar com mais segurança quando não há afeto. Nada aparece na tela; é confiança calibrada (§17). Algoritmo, S. Nenhuma mudança de SPEC; fortalece "Roteamento de reserva" do §19.2.
2. **Linha-registro.** `HUMOR: 4` ou `SONO: 6h` no meio da prosa veste como par rótulo·valor discreto — forma nova no catálogo que serve à IA, não à memória do autor (§17.1). Não vira gráfico nem média. Serve à busca (achar "SONO") e a Padrões, que já cita fragmentos literais: "você escreveu 'HUMOR: 3' nas quatro segundas deste mês — o que as segundas têm?". S para o parser, M para a forma.
3. **Rolagem de máquina de escrever** na expressiva: a linha atual fica na altura dos olhos, o texto sobe. S.

**O poder que traz.** Atenção e Sentido pela via da rota certa: a expressiva só funciona se o app a reconhece na hora, sem rede; um roteador de tom offline garante que o método chega a quem precisa no instante em que precisa. Metacognição pela linha-registro: o autor se mede nas próprias palavras, e a única devolução é uma pergunta (§9) — nunca um placar.

**A estrutura que traz.** Um léxico no bundle e uma função pura `tom(texto) -> Sinal` no motor local, com fuzz. Uma forma "Registro" (`CHAVE: valor`) no parser do Caderno; no .md sobrevive como texto cru — nota antiga nunca quebra.

**O quanto eleva.** 2: roteia melhor e mede sem placar, mas não muda o que o app faz pela mente. O que o 750 Words faz de melhor — a cota como único mecanismo — o Traço já tem como timer, na versão com mais evidência (Pennebaker, 15 minutos).

**O que fica de fora — proposta histórica.** Pontos, streaks, badges de animais, Wall of Shame, tempo até 750 palavras, contagem de distrações, palavras por minuto — §12 e regra 5, por nome. Silly Robot (prompts diários da IA a partir da entrada de ontem): §3 proíbe prompt no vazio e §2 proíbe a IA propor tema. O "daily nudge": o Traço cobra memória, não presença — notificação para escrever é streak disfarçado.

**O não-óbvio.** O 750 Words é o único app do lote que provou um classificador de afeto SEM modelo, por dicionário, e vendeu isso por quinze anos. É a doutrina do §19.4 num produto vivo: o que fecha em regra é regra. O erro deles é mostrar o resultado (gráfico de emoções); o acerto do Traço é usar o mesmo sinal calado, só para decidir se veste Expressiva ou fica em silêncio.


---

### Amplenote
`poderes: Segundo cérebro · Memória · Ordem · Metacognição` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A nota como fonte de tudo o que vem depois: o corpus é lido pelas IAs do autor de fora, sem servidor próprio; a memória nasce de um trecho, não de um cartão fabricado à parte; a nota que o autor reabre é a que importa — e o app sabe disso sem perguntar.

**A função, como existe lá.** "Backups locais para uso com ferramentas de IA externas" e "backup automático contínuo para pasta local com imagens e anexos". "Exportação: ZIP com um arquivo Markdown por nota, front matter YAML com metadados e links". "Servidor MCP desktop para Claude e Codex lerem e escreverem notas". "Vault Notes: não podem ser compartilhadas, publicadas, buscadas por conteúdo nem incluídas na exportação". "Caso de uso de repetição espaçada documentado" — a cobrança nasce de dentro da nota. "Referências não vinculadas" e "backlinks bidirecionais". "Task Score: soma pontos com base em dias em que a nota foi aberta". "Jots futuros".

**Como entra no Traço.**
1. **A pasta que as IAs do autor leem.** O backup automático no Arquivos já existe (31/ago). Falta torná-lo o contexto: (a) front matter YAML em cada .md — `gesto`, `criadaEm`, `editadaEm`, `revisoes`, `linha_de_sentido`, `fonte` — metadados, nunca prosa; (b) a pasta no iCloud Drive do autor ("Traço/"), que o Mac e qualquer ferramenta dele enxergam — é o drive dele, não servidor nosso (regra 10); (c) um `INDICE.md` gerado por algoritmo: uma linha por nota — data, gesto, primeira linha do autor — zero resumo. Trancada e queimada NUNCA entram (a regra das Vault Notes deles já é a nossa: §8, §19.2). Sentido único: o Traço exporta; nada entra sem o autor importar à mão no Perfil. ADR: §12 lista sync/nuvem como não-objetivo — a pasta não é sync, é o arquivo do autor onde ele já o guarda; §19 ("só a voz viaja") ganha uma cláusula para a pasta local. S para o front matter; o MCP fica de fora (iPhone não hospeda servidor; a pasta resolve o mesmo).
2. **Recordar por trecho.** O autor seleciona um parágrafo → "Recordar este". A nota inteira some, como hoje; ele escreve de memória só o trecho marcado; Revelar mostra os dois lado a lado. Recall livre continua — sem pista (O vão 1); o que muda é o tamanho do alvo. Uma Especificação de três páginas não se recorda inteira; a frase que importa, sim. A escada cobra o trecho. M.
3. **"Liga a" que se acha sozinho.** Ao concluir uma Nota permanente, o algoritmo (n-gramas raros em comum, sem IA) lista até três notas que contêm a mesma frase distintiva; o autor toca uma e ela entra em "Liga a" como link. Zero prosa; lista fechada de notas existentes. M.
4. **Reaberta como sinal.** `struct Nota` ganha `aberturas: [Date]`. Não aparece em lugar nenhum; alimenta Padrões com um fato verificável: "você abriu 'X' cinco vezes sem mudar uma palavra — o que ela ainda pede?". S.

**O poder que traz.** Segundo cérebro: cada IA que o autor usa passa a trabalhar com o que ele de fato pensa, nas palavras dele, com data e gesto — contexto que nenhum chat acumula. Memória pelo trecho: o efeito de teste é maior quando o alvo é a unidade que o autor escolheu reter, e escolher já é o ato metacognitivo. Ordem pelas ligações: o Zettelkasten funciona pela rede, e a rede só se forma quando ligar custa um toque.

**A estrutura que traz.** Front matter no export/import (roundtrip já existe; labels continuam fora da voz). `INDICE.md` regravado a cada save, como o backup. Marcador de trecho no .md (`::recordar::`, mobiliário invisível ao autor, nunca cru). `aberturas` no SwiftData, schema versionado. Rota `traco://nota/uuid` para "Liga a".

**O quanto eleva.** 5: abre o poder que o Traço hoje não multiplica — o corpus como contexto perfeito para as IAs do autor — com o que já existe (backup .md) mais um cabeçalho. E dá à Memória o alvo certo.

**O que fica de fora — proposta histórica.** Agenda e calendário (§12). Task Score exibido, Victory Value, rastreador de humor correlacionado, badges, coins, grupos de metas: placar. O Ample Agent que "refina linguagem, resume, limpa": regra 1. MCP com escrita: nenhuma IA escreve no corpus, nem de fora — a pasta é só leitura. Markdown cru na cara do autor (lei do dono, 31/ago). Jots futuros: nota entregue numa data é agenda disfarçada; o gatilho por nota vive no bloco do Lembretes.

**O não-óbvio.** O Amplenote descobriu que a atenção dada a uma nota (dias em que foi aberta) é sinal mais honesto de importância do que qualquer tag — e escondeu isso dentro de um placar. Tirado o placar, sobra um fato que Padrões cita sem inventar nada. E a segunda leitura da pasta: quando as IAs do autor leem o corpus, o Traço deixa de ser um app de notas e vira a memória de trabalho de todas as ferramentas dele. O poder multiplicado não é só o do autor — é o de tudo o que ele usa.


---

### Anki
`poderes: Memória · Metacognição` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O intervalo não é fixo: responde ao que aconteceu na última cobrança e cresce sem teto enquanto a lembrança segura. E o único trabalho do aluno é julgar — o calendário é da máquina (Tesler: alguém absorve a complexidade; que seja o algoritmo).

**A função, como existe lá.** Agendamento "SM-2 ou FSRS": o intervalo seguinte depende da resposta (Again reinicia; Good cresce). "Leeches": cartão que falha repetidas vezes é suspenso e marcado. "Notificação diária no horário escolhido com quantidade de revisões". "Easy Days": dias da semana com menos revisões. "Enterrar irmãos": cartões da mesma nota não caem no mesmo dia. "Basic (type in the answer)": o aluno digita e o app compara. "Tabela revlog em SQLite": cada revisão fica no arquivo. "9 zonas da tela" para responder sem botão visível.

**Como entra no Traço.**
1. **A escada responde.** Depois de Revelar, um toque opcional e discreto: "cobrar antes". Silêncio = a escada segue. Toque = volta ao degrau 3. E a escada não acaba em 21: 3→7→21→60→180→365, enquanto o autor não pedir "antes". Sem quatro botões — o Anki tem quatro porque cobra milhares de cartões; o Traço cobra dezenas de notas, e decidir também é fricção (§17.3). Algoritmo, S/M. Muda §7 e §19.2: "escada 3→7→21" vira escada aberta com reinício.
2. **Notificação com contagem.** "3 notas esperam" — número, nunca conteúdo (§19.2 mantido). S.
3. **Leech vira pergunta.** Nota que volta ao degrau 3 três vezes sai da escada e entra em Padrões como fato: "'X' escapou três vezes — o que nela não é sua?". Não é tag, não é aviso; é a pergunta que §9 já sabe fazer. S.
4. **Irmãs e dias leves.** Duas revisões no mesmo dia se espalham; Perfil ganha "sem revisão aos domingos". S.

**O poder que traz.** Memória por espaçamento adaptativo: o intervalo que cresce com o acerto é o que separa reter por três semanas de reter por anos (Cepeda e col., 2006: o espaçamento ótimo cresce com o prazo desejado). Metacognição pelo julgamento: dizer "antes" é um julgamento de aprendizagem — e julgar a própria lembrança é treino em si, não só entrada do algoritmo.

**A estrutura que traz.** `Revisao` ganha `degrau: Int` e `reinicios: Int`; a tabela de degraus vira array aberto. A notificação lê a contagem. Padrões recebe fatos algorítmicos além de texto (a leech e as `aberturas` do Amplenote são o mesmo canal). No .md, `revisoes:` no front matter — o revlog do Anki, em texto.

**O quanto eleva.** 4: a Memória do Traço hoje para no dia 21; com a escada aberta, a nota que o autor decidiu reter fica retida por anos, e o julgamento dele passa a contar. Salto grande num poder que já existe.

**O que fica de fora — proposta histórica.** O diff de "type in the answer": o olho comparando é o método (§7) — a máquina marcando o que faltou tira do autor justamente o ato de notar. Cloze: pista é o que O vão 1 recusa. Quatro botões, retenção desejada, fator de facilidade, dezenas de opções por baralho: §17 chama isso de fricção. Estatísticas e gráficos: placar.

**O não-óbvio.** O revlog do Anki, em texto no front matter, transforma o arquivo num mapa do que está DE FATO na cabeça do autor — não só do que ele escreveu. Para o segundo cérebro isso muda tudo: a IA que lê a pasta distingue a ideia que o autor tem de cor da que ele anotou uma vez e nunca mais viu. Nenhum app de notas dá esse sinal às IAs; o Anki tem o dado e não tem as notas.


---

### Apple Books
`poderes: Captura · Memória · Linguagem · Atenção` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O destaque num livro é o gesto mais comum de aprendizado falso — sublinhar sente como reter e não retém. O Books entrega o trecho com link da fonte pela folha de compartilhamento; o Traço transforma esse gesto passivo no ativo que funciona: reescrever nas próprias palavras.

**A função, como existe lá.** "Destacar com cores ou sublinhar. Adicionar nota a trecho." "Compartilhar seleção de texto com link do livro (AirDrop, Mail, Mensagens, Notas)" e "compartilhar destaques e notas (individualmente ou em lote)". "Traduzir, buscar e copiar seleção". "Line Guide com nível de escurecimento ajustável". "Posição de leitura salva automaticamente"; "voltar ao local anterior". Temas de página nomeados ("Quiet, Bold e outras").

**Como entra no Traço.**
1. **Destaque vira Nota permanente.** A extensão de compartilhamento (aberta na FILA) recebe texto + link do livro. A nota nasce com o trecho vestido como citação (portal, nunca `>` cru), `Fonte` preenchido com o link (metadado, não prosa) e a forma Nota permanente aberta com "Uma ideia nas suas palavras" vazio e o cursor nele. Roteamento por regra, sem IA: origem = Books ⇒ Nota permanente com confiança alta (§17.3). A busca indexa a citação como fonte, não como voz — §16 precisa dessa cláusula. M; o custo é a extensão, que já está na fila.
2. **Guia de linha na expressiva.** O que já foi escrito acima do cursor escurece um degrau — estático, nada anima ao digitar (§11). Reler o próprio desabafo enquanto escreve é editar; Pennebaker pede fluxo. S. Opcional em Perfil.
3. **Temas nomeados para o §22** (o DOSSIE já disse): "Leitura" escala tudo, "Escrita" trava o chrome. O nome carrega o pacote. S, depois da decisão do dono.
4. **Reabrir onde parou.** Nota longa reaberta volta ao ponto do cursor, não ao topo. S.

**O poder que traz.** Memória pelo efeito de geração: reescrever a ideia nas próprias palavras retém mais do que reler ou sublinhar (Dunlosky e col., 2013: sublinhar é baixa utilidade; recuperação e elaboração são altas). Linguagem pela tradução forçada: dizer com as suas palavras é o exercício de precisão lexical que o Traço hoje quase não tem. Captura: o trecho chega sem abrir o app. Atenção na expressiva: o texto que some atrás empurra para a frente.

**A estrutura que traz.** Extensão de compartilhamento com um App Intent "Nova nota com citação e fonte". Campo `fonte: URL?` em `struct Nota` e no front matter. O parser já tem citação; a busca ganha a distinção voz × fonte. `cursorEm: Int` persistido para reabrir no lugar.

**O quanto eleva.** 4: dois poderes de uma vez — Captura de fora do app e Memória pelo ato certo — e a primeira ferramenta de Linguagem do Traço nasce sem uma linha de IA.

**O que fica de fora — proposta histórica.** Metas de leitura, streaks, notificações de coaching (§12). O destaque como fim em si: o trecho nunca entra sem o campo vazio abaixo dele. A loja.

**O não-óbvio.** "Traduzir, buscar e copiar seleção" é menu do sistema: Look Up e Translate existem em qualquer campo de texto do iOS, de graça. O Traço não tem dicionário — e não precisa de um; precisa não suprimir o menu nativo na seleção. Linguagem entra por omissão de código. Segunda leitura: o Books nunca pergunta o que o leitor achou; só guarda o que ele marcou. O Traço é a pergunta que falta — e a Fonte com link dá ao segundo cérebro a proveniência de cada ideia.


---

### Apple Notes
`poderes: Captura · Arquivo · Ordem · Linguagem` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O custo zero de capturar — da tela bloqueada, pela câmera, por voz — e uma decisão que a Apple já tomou por nós: "sempre criar nota nova" é padrão legítimo de sistema. E a porta de saída que finalmente existe: o Notes exporta Markdown, logo anos de notas do autor podem entrar no Traço.

**A função, como existe lá.** "Tela bloqueada: acesso configurável (sempre criar nota nova, retomar última, ou desligado)". "Quick Note na Central de Controle". "Scan Text insere texto reconhecido"; "gravar áudio com transcrição automática ao vivo", em português, no aparelho. "Links entre notas por `>>` com título que atualiza". "Exportar como Markdown". "Detectores de dados: endereços, e-mails, telefones, datas". "Seções recolhíveis por cabeçalho". "Bloquear notas… título permanece visível; abrir uma nota bloqueada abre todas por alguns minutos". "Busca global por texto… manuscrito, objetos em imagens e texto de documentos escaneados".

**Como entra no Traço.**
1. **Importar o passado.** O import .md já existe; falta aceitar o dialeto que o Notes exporta (primeira linha = título, anexos ao lado). Um passe de compatibilidade no importador, com teste de roundtrip sobre uma exportação real. S. O corpus deixa de começar no dia da instalação.
2. **Intent "Continuar a última nota".** O widget U4 e o `traco://` abrem o app; a Apple mostra que a continuação é caso legítimo. Um Intent para Siri/Atalhos/botão de Ação abre a última nota editada com o cursor no fim, sem tela intermediária. S. (O controle na Central de Controle é o bloco do Lembretes.)
3. **"Liga a" como link de verdade.** Na Nota permanente, o campo "Liga a" busca títulos ao digitar (substring, local) e toca-se para ligar; renderiza como título que atualiza. Nunca `>>` nem `[[` — lei do dono. Junta com o "acha sozinho" do Amplenote. M.
4. **O menu nativo intacto.** Scan Text, ditado, Look Up e Translate já moram no menu de seleção e no teclado do iOS. Critério de aceite: o editor do Traço não os suprime. Zero código.
5. **Texto nas fotos anexadas.** `ImageAnalyzer` (Vision, no aparelho) extrai texto dos anexos para a busca — trancada nunca indexa. S/M.

**O poder que traz.** Captura por offloading: a cabeça larga o traço no instante em que aparece porque o custo é zero — e cada segundo entre a ideia e o campo é uma ideia a menos. Arquivo: importar o Notes faz o segundo cérebro nascer com dez anos de contexto em vez de zero. Ordem pela ligação: a rede de ideias que custa um toque se forma; a que custa sintaxe, não.

**A estrutura que traz.** Importador tolerante ao dialeto do Notes. Um `AppIntent` a mais. Rota `traco://nota/uuid` renderizada como link com título vivo. Índice de texto de anexos ao lado do índice de texto.

**O quanto eleva.** 3: o autor sente no primeiro dia — as notas antigas dentro, a captura sem abrir o app — sem mudar o que o Traço faz pela mente.

**O que fica de fora — proposta histórica.** Writing Tools (resumir, revisar, reescrever) e Image Wand: a antítese da regra 1, e a maior ameaça do produto por vir de graça. Math Notes: a página é para pensar, não calcular — e um resultado inserido pelo app é texto que não é do autor. O bloqueio do Notes como contraexemplo: título visível e "abrir uma abre todas" são os dois furos que o §8 fecha. Smart Folders e tags: Notas não é o altar (§3); um filtro por vez.

**O não-óbvio.** O Notes provou que "nota nova a cada abertura" é o padrão certo para captura — o §3 do Traço tem precedente no sistema, e o autor de primeira viagem já foi treinado por ele. Segunda leitura: a transcrição de áudio no aparelho, em português. Pennebaker testou a expressiva falada e ela funciona. Uma expressiva por voz — timer rodando, o autor fala, o texto é dele — seria a versão para quem não consegue digitar quinze minutos. É ADR (§8 diz "escreve"), e é depois.


---

### Apple Photos
`poderes: Sentido · Memória · Arquivo` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O controle sobre a memória involuntária: o Fotos decide sozinho o que trazer de volta, e por isso precisou dar ao dono o "não me mostre mais isto" — por dia, por lugar, por pessoa. O Traço cobra memória de propósito; precisa da mesma saída, por nota, num toque.

**A função, como existe lá.** "Feature Less (dia, lugar, pessoa); Reset Suggested Memories; desligar conteúdo em destaque e feriados". "Coleções Hidden e Recently Deleted bloqueadas por padrão com Face ID… opção de esconder o álbum Hidden". "Duplicatas: mesclar". "Utilities (Documents, Receipts, Handwriting…)" categorizadas no aparelho. "Análise feita no aparelho".

**Como entra no Traço.**
1. **"Não cobrar mais".** Na tela de Revelar e no menu da nota: um toque tira a nota da escada, sem confirmação, com desfazer. Vale para a nota sobre o luto que o algoritmo cobraria no dia 21. Hoje a escada só se cancela ao apagar ou queimar. Muda §7/§19.2: a escada tem saída por nota. S.
2. **Esconder as trancadas.** Perfil ganha "mostrar trancadas nas Notas" (padrão ligado). Desligado, o chip "Trancadas" e os cartões com cadeado somem da lista — a existência do desabafo também é dado. Muda §16: o chip vira condicional. S.
3. **Duplicatas.** Duas notas com o mesmo texto (widget tocado duas vezes): o algoritmo oferece mesclar ao concluir a segunda. S.
4. **Revisões: desligar tudo.** Perfil, uma chave: "revisões" — o "desligar conteúdo em destaque" deles. S.

**O poder que traz.** Sentido: a escada de memória é boa para a ideia e pode ser cruel para o vivido; a saída num toque é o que permite cobrar por padrão sem ferir. Memória: uma cobrança que o autor pode recusar sem culpa é uma cobrança que ele aceita mais vezes. Arquivo: sem duplicata, a busca acha uma nota, não duas.

**A estrutura que traz.** `Revisao` ganha `cancelada: Bool` (ou some). Duas chaves em Perfil. Detecção de duplicata por hash do texto normalizado, na conclusão.

**O quanto eleva.** 3: fecha o buraco que a escada abriu ao virar automática — o autor sente na primeira revisão que não quer.

**O que fica de fora — proposta histórica.** Memórias com música (a máquina decidindo que a dor virou conteúdo — §2 proíbe o equivalente). Busca em linguagem natural (§12). Anos e Meses "curados" para a lista de Notas: um algoritmo escondendo notas "parecidas" decide o que importa — é a conclusão que §9 proíbe. Clean Up: edita conteúdo.

**O não-óbvio.** O Fotos é a maior máquina de memória involuntária do telefone; o Traço é a de memória voluntária. A lição não é o cadeado (o DOSSIE já disse) — é que a Apple precisou de quatro controles de opt-out (dia, lugar, pessoa, feriado) porque a escolha do que ressurgir era inteligente. A escada do Traço é burra de propósito (§19.4: regra, não modelo) e por isso precisa de UM controle, não quatro. Burro é mais seguro quando o assunto é o passado de alguém.


---

### Apple Reminders (Lembretes)
`poderes: Intenção · Captura` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O "Se" do Se–então pode ser entregue ao telefone: chegar em casa, sair do trabalho, 7h30, entrar no carro. O Lembretes não é um app de tarefas — é uma máquina de intenções de implementação executadas por sensor. O Traço escreve o se–então; falta o telefone ser o "se".

**A função, como existe lá.** "Local: chegar ou sair de casa, trabalho, local personalizado com raio, ou ao entrar no carro com Bluetooth". "Remind me… when I get home / when I leave here" pela Siri. "When Messaging: lembra ao conversar com a pessoa". "Controle de Lembretes na Central de Controle e botão de Ação (iOS 26)". "Localização precisa só para lembretes de local". "Notificação na tela bloqueada com 'Mark as Completed'". "Sugestões de itens repetidos ao digitar texto de lembrete já concluído".

**Como entra no Traço.**
1. **Armar o Se–então.** Ao concluir uma nota Se–então (ou WOOP) cujo campo "Se" contém hora ou lugar — hora por `NSDataDetector`, lugar por escolha do autor num mapa; nunca por IA — a forma mostra um toque: "armar". O app registra `UNCalendarNotificationTrigger` ou `UNLocationNotificationTrigger` com o texto do campo "Então eu", verbatim. Sem EventKit, sem app Lembretes, sem servidor: notificação nossa, local. A permissão de localização é pedida só ali (permissão no momento certo, já lei da FILA). Tocar a notificação abre a nota. ADR obrigatório: §12 diz "agenda/calendário" — isto não é agenda, é um gatilho por nota, sem vista de calendário; §19.2 diz "notificação sem conteúdo da nota" — a regra protege o selo; aqui o conteúdo é o campo que o autor armou de propósito, e trancada nunca arma. M.
2. **Controle na Central de Controle + botão de Ação.** `ControlWidget` (iOS 18+) "Nova nota": da tela bloqueada à página nua com cursor pronto — o Quick Note do Traço. O botão de Ação corre o mesmo Intent. S. Estende U4.

**O poder que traz.** Intenção pelo mecanismo de Gollwitzer: a intenção de implementação funciona porque liga a ação a uma pista concreta, e a pista precisa ser percebida no momento — o telefone que vibra ao chegar em casa é a pista tornada impossível de não perceber (Gollwitzer & Sheeran, 2006: efeito médio-alto sobre alcançar metas, maior quando a pista é específica). Captura: da tela bloqueada ao cursor, sem tela no meio.

**A estrutura que traz.** `struct Nota` ganha `gatilho: Gatilho?` (`.hora(DateComponents)` | `.lugar(CLCircularRegion, aoChegar: Bool)`), persistido e exportado no front matter. Registro e cancelamento de notificação ligados ao ciclo da nota (apagar cancela, como a revisão). Um `ControlWidget` sobre o Intent existente. Flow: `se-entao-armar`.

**O quanto eleva.** 4: Intenção existe no Traço como texto; com o gatilho, a forma vira o dispositivo que o método pede. E a captura ganha a porta mais curta do sistema.

**O que fica de fora — proposta histórica.** Listas, seções, tags, Smart Lists, modelos de lista (templates em menu, §12), lista de compras. "Sugestões de tarefas a partir de texto com Include All": IA extraindo o que fazer do texto do autor é IA escrevendo. When Messaging: API fechada da Apple. A notificação que reaparece até marcar feito: cobrança sem consequência ensina a ignorar — o gatilho do Traço dispara uma vez.

**O não-óbvio.** "Sugestões de itens repetidos ao digitar texto já concluído" é o Lembretes lembrando o que você já quis antes — um Padrões de uma linha, algorítmico, no momento da escrita. No Traço a versão honesta não é sugerir: é o fato para Padrões citar — "você armou 'ler à noite' três vezes e desarmou duas". Segunda leitura: o Lembretes prova que o sistema operacional aceita ser o "se" de qualquer app. O Traço não precisa virar agenda para que o telefone execute o que o autor escreveu.


---

### Apple Wallet
`poderes: Atenção · Intenção · Ordem` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** O objeto certo aparece na tela bloqueada na hora certa, sem ninguém procurar — e o que expirou some sozinho da pilha. O Destaque do Traço ("a única coisa de hoje, primeiro, até acabar") é um cartão de embarque: só vale hoje, e só vale se estiver à vista.

**A função, como existe lá.** "Live Activities na tela bloqueada". "Pass aparece na tela bloqueada na hora e local certos com Automatic Selection". "Passes expirados ocultos e arquivados (Hide Expired Passes) com lista Expired para ver, restaurar ou apagar". "Pilha de cartões reordenável por arrastar; cartão na frente vira o padrão" — e a pilha respira (DOSSIE). "Express Mode… funciona sem internet e possivelmente com bateria baixa". "Duplo clique no botão lateral".

**Como entra no Traço.**
1. **Destaque na tela bloqueada.** Ao concluir uma nota Destaque, o app inicia uma Live Activity (ActivityKit) com o campo "A única coisa de hoje" — palavras do autor, verbatim, nada mais. Fica na tela bloqueada e na Dynamic Island até o autor tocar "acabou" (na Activity ou na nota) ou até a meia-noite, quando expira sozinha. Sem contagem, sem progresso, sem check diário. Algoritmo puro. Muda §6: Destaque ganha ciclo de vida (aberta → acabou/expirou) e pede a mesma cláusula de ADR do Lembretes para conteúdo na tela bloqueada. M.
2. **Destaque expira.** Passado o dia, o Destaque sai da frente da lista de Notas, como o passe expirado — ainda existe, não disputa atenção. S.
3. **O peek de folha** (DOSSIE; P1 do dono na FILA): a pilha que respira — o de trás encolhe e escurece — é a régua para o arrasto da nota como folha. Para a mente é polimento (2); para a barra do dono é obrigação.

**O poder que traz.** Atenção pelo mecanismo mais antigo: o que está à vista ocupa a mente, o que está dentro do app não. A tela bloqueada é vista dezenas de vezes por dia; o Destaque vivendo ali é a única coisa de hoje de fato à frente das outras. Intenção pelo efeito Zeigarnik: a tarefa aberta e visível permanece ativa até fechar — e fechar é um toque. Ordem: o dia de ontem não disputa com o de hoje.

**A estrutura que traz.** `Destaque` ganha `acabouEm: Date?`. Um `ActivityAttributes` com um único campo de texto. Um Intent "acabou" na Activity. Na lista, "hoje" separa Destaques vivos dos expirados. O front matter exporta `acabouEm`.

**O quanto eleva.** 4: Atenção e Intenção de uma vez, e o Destaque deixa de ser um campo que ninguém vê depois de fechar a nota. Fica em "depois" porque depende do ADR de conteúdo na tela bloqueada, que o Lembretes abre primeiro.

**O que fica de fora — proposta histórica.** Pagamento, chaves, ingressos — nada. O duplo clique no botão lateral é reservado ao sistema; o botão de Ação (Lembretes) é o equivalente aberto. O rastreamento de pedidos por IA a partir do Mail: IA lendo e escrevendo por você.

**O não-óbvio.** O Wallet é o único app da Apple sem gordura porque só faz uma coisa por vez, no momento certo, e depois some — e o "depois some" é a parte esquecida. Expirar é uma função de Ordem: a pilha fica limpa porque o tempo remove, não o usuário. O Destaque que expira sozinho é a única forma do Traço que deveria ter data de validade — e é o que o distingue de uma lista de tarefas: não acumula.


---

### Atalhos (Apple)
`poderes: Intenção · Captura` · `eleva: 4/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** A automação pessoal do Atalhos é uma intenção de implementação executada pelo sistema: "quando X acontecer, faça Y". O Traço já faz o autor escrever o Se–então; o Atalhos pode entregar o "Se" na hora em que ele acontece.

**A função, como existe lá.** Automações pessoais com gatilhos de Evento (Hora do Dia, Alarme parado, Sono: Despertar, Treino no Watch terminou), Viagem (Chegar num local com raio, Sair, Antes de Deslocar), Ajuste (Foco ligar/desligar, App abrir/fechar, Wi-Fi, Carregador) — com opção de rodar sem confirmar. Apps de terceiros expõem ações via App Intents com parâmetros; a ação "Ask for Input" e a variável "Ask Each Time" recebem texto ou ditado dentro do atalho, inclusive pelo Watch e pelo botão de Ação.

**Como entra no Traço.**
1. **A nota como entidade do Atalhos.** Hoje `Intencoes.swift` tem só `NovaNotaIntent` e `AbrirNotasIntent`, sem parâmetro. Entra um `AppEntity` "Nota" (título = primeira linha da voz do autor, gesto como propriedade) com `EntityQuery` que **exclui trancadas e queimadas** (Bear faz o mesmo: notas cifradas não saem por Siri/Atalhos/widgets), e dois intents com parâmetro: **Abrir nota** e **Recordar nota**. O autor monta no Atalhos: "Quando chegar na academia → Abrir nota 'correr de manhã'"; "Quando o alarme parar → Recordar nota X". Quem faz: algoritmo (§19.2, linha Sistema). Nada de IA.
2. **Nova nota com texto, sem abrir o app.** Intent `openAppWhenRun = false` que grava uma nota a partir de um parâmetro de texto (o que veio de "Ask for Input"/ditado) e devolve silêncio. A nota nasce em Notas com `criadaEm` e sem gesto; a auto-análise (§17) roda quando o autor a abrir. É a captura pelo botão de Ação e pelo Watch sem tela intermediária.
3. SPEC: §19.2 linha Sistema ganha "intents com parâmetro de nota (só abertas) e criação sem abrir o app"; §16/§19.2 selo: a `EntityQuery` é rota nova e entra na lista de rotas seladas com teste.

**O poder que traz.** Implementação de intenção funciona porque o gatilho dispara a resposta sem deliberação (Gollwitzer); o plano escrito no Traço vira pista entregue pelo telefone no lugar e na hora certos — o "Se" deixa de depender da memória do autor. E a captura sem tela intermediária evita a perda do traço no trajeto até a página.

**A estrutura que traz.** Sem campo novo em `Nota`. Novo: `NotaEntity` + `NotaQuery` (filtra `fechada == false`), `AbrirNotaIntent(nota:)`, `RecordarNotaIntent(nota:)`, `NovaNotaComTextoIntent(texto:)`. `Rota.Destino` ganha `.nota(UUID)` e `.recordar(UUID)`. Teste obrigatório: trancada não aparece na query nem por UUID direto.

**O quanto eleva.** 4 — o Se–então hoje é frase que o autor tem de lembrar; com a pista entregue pelo sistema ele vira gatilho de verdade, e a captura ganha o Watch e o botão de Ação sem tela.

**O que fica de fora — proposta histórica.** A Galeria de atalhos prontos (template em menu, §12). As ações "Use Model", Fazer Lista, Fazer Tabela, Resumir e Reescrever: o Traço não expõe nenhuma ação que passe por modelo. O que o autor encadeia por conta própria fora do app é dele — a regra do §2 é sobre a IA do Traço, e ela continua não escrevendo.

**O não-óbvio.** O Atalhos parece ferramenta de automação. Visto pela pergunta certa, a tela de gatilhos dele é a lista de "Se" do §6 pronta e operável pelo sistema: local, hora, alarme, Foco, fim de treino. O Traço nunca precisará de agenda (§12) — o relógio e o mapa do autor já estão no Atalhos; basta o Traço ser um "Então" endereçável por nota.


---

### Bear
`poderes: Segundo cérebro · Memória · Arquivo` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O autor decide QUAL parte da mente a IA vê — e o corpus sai com essa borda desenhada. E a "nota aleatória" invertida: em vez de reler, recordar.

**A função, como existe lá.** No Mac, o CLI `bearcli` alimenta um conector Claude e um servidor MCP para Claude Code, Cursor e outros clientes; em 2.9 o MCP tem escopo por "Only tags" e "Exclude tags". Widgets de Tela de Início e Tela Bloqueada incluem "Nota Aleatória"; widgets não mostram notas protegidas. Notas cifradas não vão ao Watch nem a Siri/Atalhos/widgets.

**Como entra no Traço.**
1. **Export com escopo, para as IAs do autor.** O export .md já existe (FILA, roundtrip com gesto e campos). Entra, no Perfil, "Contexto para as minhas IAs": uma pasta em Arquivos, regravada a cada Concluída, com escopo escolhido pelo autor em uma linha — **por gesto** (só Notas permanentes e Especificações, por exemplo) e **por idade** (últimos 90 dias). Trancadas e queimadas nunca entram (regra 2 já vale no export; o escopo é uma peneira a mais, nunca a menos). Um `INDICE.md` no topo lista data, gesto, primeira linha e linha de sentido de cada arquivo — o mapa que uma IA lê antes dos arquivos. Quem faz: algoritmo. Sem servidor, sem conta (regra 10): a pasta é lida por Claude Code, Cursor ou qualquer cliente que leia disco. SPEC: seção nova "Segundo cérebro" por ADR; §10 e §12 intocados — não é nuvem nossa, é arquivo do autor.
2. **Recordar ao acaso.** Rota `traco://recordar?aleatoria` e terceiro atalho no widget U4: sorteia uma nota aberta com mais de 21 dias (fora da escada) e abre direto no Recordar — a nota some, o autor escreve de memória, revela. Nunca mostra o conteúdo no widget (o widget é atalho, não painel — decisão do U4 mantida).

**O poder que traz.** (1) Um corpus com borda é o que torna possível dar a mente a uma IA sem violar o selo — e contexto de qualidade é o que faz a IA do autor trabalhar sobre o que ele de fato pensa, não sobre o que ela supõe. (2) Recuperação espaçada sem cronograma: a cauda longa do arquivo (depois do degrau 21) volta a ser treinada; o esforço de gerar a lembrança é o mecanismo (testing effect), e a nota sorteada é a que o autor menos esperava.

**A estrutura que traz.** `Preferencias.contexto: {gestos: Set<Gesto>, dias: Int?}` fora do schema da nota. Pasta `Traço/Contexto/` no container de Arquivos, com `INDICE.md` gerado. Rota nova no `Rota.daURL`. Nenhuma notificação nova.

**O quanto eleva.** 5 — abre o poder que o Traço hoje não multiplica (segundo cérebro para as IAs do autor) pela via que a regra 2 exige: escopo antes de exposição.

**O que fica de fora — proposta histórica.** Tags e Workspace: o Traço não tem tag por decisão (a forma nasce da palavra, §17), e "domínio de vida" é assunto de outro bloco. Sync por CloudKit (§12). Bear Web. O widget "última nota editada" mostrando conteúdo: reler cartões é o anti-padrão do §3.

**O não-óbvio.** O MCP do Bear parece integração para programador. Visto pela pergunta certa, "Only tags / Exclude tags" é a primeira interface de consumo em que o dono desenha a borda do que a IA pode saber dele. É exatamente a peça que falta para o Traço virar segundo cérebro sem virar vazamento — e ela é regra, não modelo.


---

### Beaver Notes
`poderes: Arquivo · Segundo cérebro` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A pasta é do autor, e ele escolhe onde ela fica. Onde a pasta mora decide quais ferramentas leem a mente dele.

**A função, como existe lá.** Sincronização por pasta escolhida dentro de iCloud, OneDrive, Dropbox ou Syncthing, com autosync em Ajustes ou sync manual pela barra lateral; tudo no dispositivo por padrão, sem conta, sem telemetria. O cliente homônimo da App Store traz bloqueio por Face ID com auto-lock e **ocultar preview no seletor de apps**. Plano publicado (ago/2026): modelos no dispositivo (embeddings, reconhecimento de fala, < 100 MB).

**Como entra no Traço.**
1. **Pasta escolhida pelo autor.** Hoje o backup .md vai para o container do app em Arquivos. Entra, no Perfil, "Guardar em…": um `UIDocumentPicker` de pasta com bookmark de escopo de segurança, e o backup automático passa a regravar ali — o cofre do Obsidian, a pasta que o Claude Code lê, o Syncthing do autor. Trancadas continuam fora (regra 2, já testada na rota de export). Quem faz: algoritmo. SPEC: §10 "sem nuvem" permanece verdadeiro — a nuvem, se houver, é a do autor; §19.2 Arquivo ganha "pasta de destino escolhida".
2. **Selo no seletor de apps.** Expressiva em curso e trancada reaberta ficam visíveis no snapshot do multitarefa — rota de exposição que a regra 2 não lista. Entra: em `scenePhase == .inactive` com nota fechada ou timer rodando, a página recebe véu opaco; o mesmo véu cobre a captura de tela. S, teste por rota, o mesmo buraco que o DOSSIE aponta no 1Password.
3. **Embeddings locais para Padrões — só por ADR.** §9 lê as últimas ~12 notas; embeddings no aparelho escolheriam as 12 mais próximas do que o autor acabou de escrever. Contradiz §12 (busca semântica). Registrar, não fazer: o que o modelo devolveria é seleção, não texto — cabe no §19.4 — mas a decisão é do dono.

**O poder que traz.** (1) Offloading só vale se o que foi descarregado está onde as ferramentas do autor olham; a pasta escolhida põe o corpus no caminho das IAs sem servidor nem API. (2) O selo é garantia, e garantia com um buraco não é garantia.

**A estrutura que traz.** `Preferencias.pastaBookmark: Data?`. O backup automático resolve o bookmark a cada gravação e cai no container padrão quando o acesso falha (aviso em uma linha no Perfil, como o estado da conta). Véu em `TracoApp` por `scenePhase`. Nenhum campo em `Nota`.

**O quanto eleva.** 4 — Arquivo e Segundo cérebro de uma vez: a nota do autor passa a morar onde a mente dele já trabalha, e o selo fecha a última fresta visível.

**O que fica de fora — proposta histórica.** BeaverSync com conta e histórico pago (§12, regra 10). Colaboração em tempo real e plugins com "Core Access". Bases de dados estilo Notion. Comando `/` e paleta: o autor nunca lembra código (ADR 31i).

**O não-óbvio.** A promessa do Beaver ("sem nuvem, sem IA") lê como ausência — o DOSSIE já disse. Mas a pasta escolhida é a peça mais barata de todo o segundo cérebro: não exige MCP, servidor nem protocolo. Uma pasta no lugar certo já é contexto perfeito para qualquer IA que leia disco.


---

### BeReal
`poderes: Metacognição · Sentido · Captura` · `eleva: 3/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A amostra em hora aleatória. O que o autor escreve quando escolhe escrever é uma coisa; o que está na cabeça dele às 15h47 de uma terça é outra — e é ali que os padrões moram.

**A função, como existe lá.** Notificação diária "Time to BeReal" em horário aleatório; janela de dois minutos; sem filtros, sem upload de galeria; retakes ilimitados antes de postar; postar atrasado é permitido e marcado como atrasado; Memories é arquivo pessoal só do dono. Site declara "no AIs allowed".

**Como entra no Traço.**
1. **Amostra do dia (opt-in no Perfil).** O autor liga "uma amostra por dia" e escolhe a faixa (9h–21h). O app agenda uma notificação em hora sorteada dentro da faixa, sem conteúdo: "Agora. O que está na sua cabeça? Dois minutos." Tocar abre a página nua com o **cartão fixo não-editável** do §9 (precedente: a pergunta dos Padrões) e o timer discreto do §8 em 2 min. Ao fim, a nota vai a Notas como Concluída, com `amostraEm` gravado; se o autor abriu 40 min depois, o cartão da nota mostra "amostra · respondida 40 min depois" como fato de arquivo (mesmo estatuto de "recordada 3×"), nunca como falta. Ninguém cobra: sem notificação de "você perdeu". Quem faz: algoritmo (sorteio, agenda, timer).
2. **Padrões sobre amostras.** As amostras entram nas ~12 notas do §9 como qualquer outra; o filtro "Amostra" nas Notas (§16) permite ler só elas — e a IA, quando o autor pede, pergunta sobre o que se repete nelas.
3. SPEC: §17 ganha a amostra como método opt-in; §3 intocado (a página continua nua; o cartão fixo é precedente do §9).

**O poder que traz.** É o método de amostragem de experiência (Csikszentmihalyi/Larson): a sonda aleatória captura o estado vivido sem o viés da lembrança e sem a curadoria de quem decide o que vale anotar. Para a metacognição, a matéria-prima honesta vale mais do que qualquer pergunta bem feita sobre matéria escolhida.

**A estrutura que traz.** `Nota.amostraEm: Date?`. `FiltroNotas.amostra`. Preferência `amostraFaixa: (Int, Int)?`. Uma `UNCalendarNotificationTrigger` por dia, reagendada ao abrir o app; identificador `amostra-AAAA-MM-DD`. Export: front matter `amostra: <ISO>`.

**O quanto eleva.** 3 — fortalece Metacognição com um insumo que hoje não existe; o autor sente no primeiro dia a diferença entre o que escolheu escrever e o que estava lá.

**O que fica de fora — proposta histórica.** Feed, amigos, Discovery, RealMoji, Bonus, streaks, anúncios, mapa: tudo que existe para audiência. A proibição de editar depois — sem leitor, o carimbo de hora já faz o trabalho; trancar edição na nota do autor é atrito sem função.

**O não-óbvio.** O BeReal parece rede social de honestidade. Visto pela pergunta certa, é o único produto de massa que implementou amostragem de experiência — e a honestidade dele não vem da câmera dupla, vem do sorteio da hora. A audiência foi o que corrompeu; retire a audiência e sobra o instrumento.


---

### Calm
`poderes: Sentido · Metacognição · Arquivo` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** O programa de N dias com fim conhecido: um passo por dia, mesmo tema, e acaba. É o recipiente que falta ao §8.

**A função, como existe lá.** Programas de 7 e 21 dias por tema ("Dia 1" grátis de cada um); Daily Calm de 10 minutos; meditações não guiadas com timer; lembretes de mindfulness por dia da semana e horário; sessões gravadas no app Saúde da Apple como Mindfulness Minutes; a tela de citação com um único Continuar (Mobbin).

**Como entra no Traço.**
1. **Expressiva em série de 4 dias.** Ao selar ou queimar o dia 1, o fecho oferece — pulável — "Continuar amanhã, o mesmo evento?". Se sim, o app agenda três notificações, mesma hora, sem conteúdo: "Dia 2 de 4. O mesmo evento, 15 minutos." Cada dia é uma nota expressiva própria, selada por si (§8.3 intocado); a linha de sentido de cada dia sai; no dia 4 acaba e nada mais é oferecido. Faltar não gera cobrança nem reagendamento. Quem faz: algoritmo. SPEC: §8 ganha a série por ADR (hoje é uma sessão).
2. **Minutos de escrita no Saúde.** Ao selar/queimar, gravar `HKCategoryType.mindfulSession` com `minutosEscritos`, opt-in no Perfil. Não é placar do app: é o arquivo de saúde do autor, ao lado do sono e do humor que ele já registra lá.
3. **Uma pergunta por tela nos Padrões.** As 2–3 perguntas do §9 deixam de ser lista: cada uma ocupa a tela como a citação do Calm — serifa, centro, fundo do tema — com uma saída, "Responder", que abre a página nua com o cartão fixo. Passa-se à próxima por arrasto.

**O poder que traz.** (1) O protocolo estudado de escrita expressiva é de 3–4 dias consecutivos sobre o mesmo evento; a sessão única é a versão fraca. A série é onde a construção de sentido acontece — a narrativa muda entre o dia 1 e o dia 4. (2) Uma pergunta por tela obriga a responder em vez de navegar (hicks-law).

**A estrutura que traz.** `Nota.serie: UUID?` e `Nota.diaDaSerie: Int` (1–4). Notificações `serie-<uuid>-<dia>`, canceladas se a série for interrompida pelo autor no Perfil. `HealthKit` com entitlement e pedido de permissão no momento do primeiro selo. Export: `serie:` e `dia:` no front matter; o texto continua fora (selado).

**O quanto eleva.** 4 — salto grande em Sentido: o Traço passa a carregar o protocolo inteiro, não o primeiro dia dele.

**O que fica de fora — proposta histórica.** Streak com anel e Safety Net (regra 5). Check-Ins de humor com histórico: painel (§9 proíbe dashboards). Paywall e catálogo de celebridades. Respiração guiada antes de escrever: um passo a mais no caminho principal (regra 6).

**O não-óbvio.** O Calm vende conteúdo. Visto pela pergunta certa, a estrutura "Dia 1 de 21" é um contrato com fim: diferente da streak, ele termina — e terminar é o que o §8 precisa para a série de Pennebaker não virar hábito de reler dor. O DOSSIE marcou "sequência de dias" como lixo; a distinção é o fim conhecido.


---

### Câmera na tela bloqueada
`poderes: Captura` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O caminho mais curto do bolso ao instrumento, e o resultado esperando do outro lado. O que o Traço já tem de widget (U4) mora atrás do desbloqueio; o piso da Câmera é a tela trancada.

**A função, como existe lá.** Da Tela Bloqueada, deslizar para a esquerda ou segurar o botão de câmera no canto inferior abre a Câmera sem desbloquear; os dois controles inferiores (lanterna e câmera) podem ser trocados por outros controles; Central de Controle com controle da Câmera; botão de Ação com "Câmera" ou "Atalho"; Controle da Câmera: clicar abre, clicar de novo tira a foto; Siri "Abrir Câmera". Ponto verde indica câmera em uso.

**Como entra no Traço.**
1. **Controle na Tela Bloqueada e na Central de Controle.** `ControlWidget` (WidgetKit) "Nova nota" ligado ao `NovaNotaIntent` que já existe. O autor põe o Traço no lugar da lanterna: segurar → Face ID passivo → página nua. Um segundo controle, "Recordar". Sem configurar nada no Atalhos: aparece na galeria de controles. Quem faz: algoritmo. SPEC: §19.2 Sistema ganha "controles de Tela Bloqueada e Central de Controle".
2. **O resultado espera do outro lado.** Critério de aceite novo no §13: trancar o iPhone com uma nota a meio caminho — sem tocar Concluída — e reabrir: a nota está em Notas, inteira. Hoje "trocar de tela salva" (§20); falta o teste explícito para `scenePhase` inativo e processo morto na página nua.
3. O botão de Ação já chega pelo Atalhos (`Intencoes.swift`): documentar no Perfil em uma linha, sem tutorial.

**O poder que traz.** O traço de quem escreve com TDAH (§17) dura segundos; cada tela entre o impulso e o cursor é uma chance de perdê-lo. Reduzir a captura a um gesto físico sem decisão é o que faz a captura acontecer.

**A estrutura que traz.** Alvo `TracoWidget` ganha `ControlWidget` com `ControlWidgetButton` para os dois intents. Nenhum campo, nenhuma rota nova (as rotas `nova` e `recordar` existem). Teste de aceite de gravação em `scenePhase`.

**O quanto eleva.** 3 — Captura que o autor sente no primeiro dia: um aperto, sem desbloquear conscientemente, sem tela de home.

**O que fica de fora — proposta histórica.** Inteligência Visual (IA no botão). Abrir o Traço pelo Controle da Câmera: ele abre apps de câmera, e o Traço não é um. E a honestidade do limite: app de terceiro não roda na tela trancada; o piso do Traço é o Face ID passivo, não o zero da Câmera.

**O não-óbvio.** A Câmera trancada roda em modo restrito: mostra só as fotos daquela sessão, nunca a fototeca. É o desenho do selo em recurso de sistema — capturar sem expor o arquivo. A página nua do Traço aberta pelo controle já obedece a isso: nasce vazia, e as Notas ficam atrás de um gesto (§3).


---

### Clear
`poderes: Intenção · Atenção · Ordem` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A posição é a estrutura: a linha de cima é a mais quente, e a cor diz isso sem rótulo. E a tarefa que se marca do widget, sem abrir o app.

**A função, como existe lá.** Mapa de calor por posição na lista; widgets interativos na Tela de Início e na Tela Bloqueada permitem marcar tarefa tocando na borda esquerda sem abrir o app; puxar para baixo cria item; pinçar abre espaço entre duas linhas para inserir; adição rápida em sequência com o teclado aberto; sacudir para desfazer; Daily Kanban Hoje/Amanhã/Depois; nota musical por tarefa concluída, som desligado por padrão.

**Como entra no Traço.**
1. **O Destaque na cara do telefone.** Widget (Tela Bloqueada retangular + Tela de Início pequeno) que mostra a linha do campo "A única coisa de hoje" do Destaque mais recente — palavras do autor, nota aberta, nunca expressiva — e um toque na borda a risca, sem abrir o app (`AppIntent` interativo no widget). Riscada, o widget fica vazio até o próximo Destaque; sem cobrança. Exige App Group para o widget ler a nota. Quem faz: algoritmo. SPEC: §6 Destaque ganha estado "feita"; §19.2 Sistema ganha widget com dado (o U4 era atalho puro; este é o primeiro painel, e mostra UMA linha).
2. **A primeira linha é a única coisa.** Numa lista roteada como Destaque, arrastar uma linha para o topo é responder ao campo: a primeira linha veste âmbar decrescendo para as demais (gradiente estático, nada anima), e o campo não duplica texto — a posição é a resposta. O autor move; o app veste. É o §17 aplicado à ordem, não à forma.
3. **Pinçar para nascer bloco no meio.** O construtor da régua (feito, feat/traco-1a5) nasce no ponto onde os dedos abriram, em vez de na posição do cursor. Polimento.

**O poder que traz.** (1) Intenção: a meta visível o dia inteiro é saliência sem esforço — o "Destaque" que mora dentro do app compete com tudo; o que mora na tela trancada é visto vinte vezes por dia. (2) Ordem por posição tira uma decisão da cabeça: não há prioridade a nomear, há uma linha a mover.

**A estrutura que traz.** App Group entre `Traco` e `TracoWidget`; leitura do SwiftData pelo widget (só `gesto == .destaque && !fechada`). `Nota.campos["unica_feita"]` ou `Nota.destaqueFeitoEm: Date?`. `RiscarDestaqueIntent`. Export: `feita:` no front matter.

**O quanto eleva.** 4 — Intenção e Atenção de uma vez: a única coisa deixa de ser frase guardada e passa a ser o rosto do aparelho.

**O que fica de fora — proposta histórica.** Loot, colecionáveis, conquistas, 398 temas, pacotes de som e a melodia ascendente ao limpar a lista (regra 5: recompensa é placar com outro nome; os hápticos já fazem a confirmação). Lembretes com Adiar/Reagendar e tarefas repetidas (§12: agenda). Compartilhar lista por link.

**O não-óbvio.** O Clear parece aula de gesto — o DOSSIE já cobriu. Visto pela pergunta certa, o mapa de calor é um sistema de prioridade sem vocabulário: ninguém escolhe "alta/média/baixa", só arrasta. É a régua do §17 para a Ordem — o autor nunca precisa saber o nome de um nível de prioridade.


---

### Clover
`poderes: Memória · Linguagem · Intenção` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Dois templates que eram método disfarçado de layout: Cornell Notes (pistas + notas + resumo nas próprias palavras) e o rollover da tarefa que ficou.

**A função, como existe lá.** Templates Cornell Notes, Matriz de Eisenhower, Timelines e Crazy Eights; Daily Notes por dia com rollover automático de tarefas incompletas; Surfaces (canvas infinito com o mesmo editor); Quick Note por voz ou texto com datas em linguagem natural; atalho global para adicionar às Daily Notes sem abrir o app.

**Como entra no Traço.**
1. **Forma "Estudo" (Cornell).** Roteada quando o texto parece anotação de aula, leitura ou reunião (heurística local: nomes próprios + datas + termos definidos; IA devolve o rótulo quando a regra não fecha). Campos vazios abaixo do texto: **Pistas (perguntas para me testar)** · **Resumo, nas minhas palavras**. O Recordar dessa forma muda: em vez de esconder tudo, esconde as notas e mostra só as pistas — o autor responde pista a pista, Revelar mostra lado a lado. Quem faz: algoritmo (forma, Recordar por pistas); IA só roteia (§19.1 item 1, lista fixa ganha "Estudo").
2. **O que ficou, fica à vista — não na página.** Rollover sem tarefa nova e sem culpa: a "única coisa" não riscada de ontem continua no widget do Destaque (bloco Clear) até ser riscada ou substituída. A página nua permanece nua (§3): o Zeigarnik mora no widget, não no vazio.
3. Crazy Eights entra no catálogo do §17 como forma cronometrada ("oito, em oito minutos") — mesma mecânica do timer da expressiva, sem selo. Registrar; roteamento depois.

**O poder que traz.** (1) Cornell é o método que junta os dois efeitos que o Traço já persegue: as pistas são perguntas de recuperação escritas pelo próprio autor (efeito de geração; testar > reler, Roediger & Karpicke), e o resumo nas próprias palavras é o exercício de Linguagem que o Traço quase não tem — destilar até a frase que vale. (2) A tarefa que sobrevive ao dia sem ser reescrita mantém a intenção viva sem cobrar.

**A estrutura que traz.** `Gesto.estudo` com campos `pistas` e `resumo`; `FiltroNotas.estudo`. Recordar ganha modo por pistas (uma tela por pista, Revelar ao fim). `doNome` aceita "Estudo"/"Cornell" no import. Export: os campos já viajam. Rollover: nenhum campo — é leitura do widget sobre o último Destaque não riscado.

**O quanto eleva.** 4 — abre Linguagem (resumo nas próprias palavras como campo obrigatório de um método validado) e dá ao Recordar um modo guiado pelo próprio autor.

**O que fica de fora — proposta histórica.** Surfaces: a nota do Traço é texto que sobrevive em .md por décadas; posição no canvas não sobrevive. Nuvem, colaboração, planner com calendário (§12). Matriz de Eisenhower como grade manual: template em menu; se entrar, entra pela palavra (§17).

**O não-óbvio.** O Clover vendia Cornell como template de layout — e morreu. Visto pela pergunta certa, Cornell não é layout: é o único método de anotação cujo desenho já contém o teste (a coluna de pistas). O Traço tem Recordar e tem formas; Cornell é a forma que nasce com o Recordar dentro.


---

### Craft
`poderes: Ordem · Intenção · Segundo cérebro` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Um modelo local que não conta na cota e não edita — a prova de que o roteador do Traço pode rodar no aparelho, sem conta, para todo mundo. E a borda do que a IA vê, escolhida por documento.

**A função, como existe lá.** Craft Assistant com modelo **Local (Apple Foundation Model com Apple Intelligence)**: não conta na cota e **não edita**; modos Explore (propõe) e Execute (aplica). MCP com conexão por Space inteiro ou por documentos escolhidos, busca com filtros de tag, data e regex. External Locations (iOS: iCloud Drive) e "Keep on Device". Folha Editar tabela com verbos e glifo por eixo (REFERENCIAS). Lock Screen: Create Document, Open today's daily note. Unsorted como caixa de entrada.

**Como entra no Traço.**
1. **Terceiro motor: modelo no aparelho.** §5 tem dois motores: Grok (conta) e heurísticas locais. Entra, entre eles, o Foundation Models framework do iOS 26 com geração guiada: `@Generable enum` que só pode devolver um gesto da lista fixa ou nada — o contrato `{gesto, aviso}` do §19.4 como tipo, não como JSON a validar. Sem conta, sem rede, sem custo (regra 10); rótulo de lista fechada (regra 7); temperatura 0; silêncio em qualquer falha. Quem faz: algoritmo escolhe o motor; o modelo só rotula. SPEC: §5 ganha o terceiro motor por ADR; §19.1 tabela "Se falhar" ganha o degrau intermediário.
2. **Escopo por nota, não só por gesto.** Complementa o bloco Bear: no cartão de cada nota (segurar), um toque "Fora do contexto" tira aquela nota da pasta de contexto sem trancá-la. Selada e queimada já estão fora; isto é a borda fina, escolhida uma a uma. `Nota.foraDoContexto: Bool`.
3. **Editar tabela por verbos** — já P1 e feito no construtor (feat/traco-1a5); o que falta é estender o mesmo padrão a lista e citação, um verbo por linha com glifo do eixo. Registrar como polimento.

**O poder que traz.** (1) O auto-forma do §17 é a diretriz TDAH; hoje, sem conta, ele depende de heurística por palavra. Um roteador que entende o texto no aparelho leva a Ordem (vestir sozinho) e a Intenção (WOOP e Se–então abertos quando a confiança é alta) a quem nunca ligou conta — e sem introduzir texto de modelo, porque o tipo não deixa. (2) Contexto com borda fina é o que faz o segundo cérebro ser confiável o bastante para ser usado.

**A estrutura que traz.** `AnaliseLocalModelo` ao lado de `AnaliseLocal` e `AnaliseRemota`; `@Generable struct Veredito { gesto: Gesto?; aviso: Aviso? }`; ordem de motores: Grok → modelo local → heurística. `Nota.foraDoContexto`. Testes: rótulo desconhecido = silêncio; trancada nunca chega ao modelo (mesmo guarda da rede).

**O quanto eleva.** 4 — salto grande em Ordem e Intenção: o §17 passa a funcionar sem conta, offline, para todo autor, sem quebrar a regra 1.

**O que fica de fora — proposta histórica.** Execute, Document Review, Smart Search, Help Agent, prompts customizados, BYOK: tudo que escreve, resume ou responde dentro do documento (§2). Email to Craft (exige servidor, regra 10). Spaces, Coleções com vistas, publicação, colaboração, histórico de versões pago (§12).

**O não-óbvio.** O Craft vende assistente que escreve. Visto pela pergunta certa, a linha mais importante do catálogo é a menos vendida: "Local não conta na cota e não edita". Eles construíram, por acidente de custo, o modo que o Traço tem por doutrina — e provaram que ele roda no iPhone. O Traço pega o motor e deixa o assistente.


---

### Day One
`poderes: Memória · Sentido · Segundo cérebro` · `eleva: 3/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** O reencontro com o que se escreveu há um ano, e o contexto do instante (hora, lugar) como pista que não vaza conteúdo. O Day One faz a vida voltar; o Traço faz a mente ir buscá-la.

**A função, como existe lá.** "On This Day" (entradas do mesmo dia em anos anteriores, com vista e widget próprios). Metadados automáticos por entrada: hora, data, clima, fase da lua, local, atividade. Lembrete diário "em hora fixa ou aleatória dentro de um intervalo". Servidor MCP no Mac (List Journals, Get Entries, Create Entry, Update Entry), local, com controle de acesso por diário.

**Como entra no Traço.**
1. **Degrau 365 da escada.** A escada 3→7→21 (`Revisoes.escada`) ganha um quarto degrau: um ano. A notificação chega como as outras — sem conteúdo — e cai direto no Recordar da nota, rota que já existe. Nunca abre a nota para reler: o §3 continua valendo, o altar não volta. Algoritmo puro. Trancadas e queimadas não agendam (`podeAgendar` já guarda).
2. **Contexto como pista no Recordar.** Na criação, o app grava uma linha de contexto (dia da semana, hora, cidade — sem mapa, sem coordenada persistida). No Recordar, quando o texto some, essa linha é a única coisa que fica: "terça, 14h, Curitiba". Pista de contexto, não de conteúdo. Algoritmo (geocodificação reversa uma vez; opcional no Perfil, desligado por padrão). Muda §7 (o que permanece visível) e §10 (campo novo).
3. **Hora aleatória na janela.** A notificação de revisão sai em hora aleatória dentro de uma janela escolhida no Perfil, não em hora fixa. Algoritmo; muda `Revisoes.agendar`, não a SPEC.
4. Sobre o MCP: o Day One prova que servidor de contexto local, com acesso por diário, é produto real. O Traço não tem Mac; a lição vai para o bloco do Fabric — a superfície é o export, e trancada nunca sai dela.

**O poder que traz.** Espaçamento no horizonte de anos: recuperar depois de um ano é o esforço máximo de geração, e é onde a diferença entre reler e recordar mais pesa. A pista de contexto é reinstauração de contexto — o que a entrevista cognitiva usa para destravar lembrança sem sugerir conteúdo: lembrar onde e quando puxa o quê. Hora imprevisível impede o autor de "se preparar" e evita habituação ao horário.

**A estrutura que traz.** `Revisoes.escada = [3, 7, 21, 365]`; o nível por nota sai do UserDefaults e vira campo (`revisaoNivel`) — quatro degraus e um ano pedem persistência de verdade. `Nota.contexto: String?` (uma linha, gravada uma vez). No .md: `contexto:` no frontmatter. Notificação: categoria "ano".

**O quanto eleva.** 3: a escada já existe; o Traço passa a cobrar memória na escala em que promete durar (décadas) e o Recordar ganha uma pista honesta — mas o degrau 365 só se sente depois de um ano.

**O que fica de fora — proposta histórica.** Streaks com calendário (§12). Daily Chat, Go Deeper, Multi-Entry Summary, Entry Highlights, Title Suggestions, geração de imagem (regra 1: a IA não escreve, não resume, não intitula). Journaling Suggestions da Apple: prompt ocupando o vazio (regra 8). Diários compartilhados (§12). Mapa das entradas: o DOSSIE já chamou de métrica; a pista de contexto não é o mapa — é uma linha, e serve só ao Recordar. Create/Update Entry do MCP: IA escrevendo no diário é o que a regra 1 proíbe.

**O não-óbvio.** O produto cognitivo do Day One não é escrever, é o reencontro — On This Day e o livro impresso são máquinas de reexposição autobiográfica. O Traço recusa a reexposição como altar e a converte em recuperação: o mesmo evento, um ano depois, vira o degrau mais longo do Recordar. E o Day One grava clima e lugar sem dizer por quê; a razão é que contexto é a pista mais forte da memória episódica — por isso parece "memória", sendo só arquivo.


---

### Drafts
`poderes: Captura · Ordem · Atenção` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Captura de qualquer superfície com a decisão adiada, e a ideia de que reordenar um texto arrastando é pensar com as mãos.

**A função, como existe lá.** Extensão de compartilhamento com opção de "anexar/prefixar a rascunho existente" e "Quick Capture", que salva sem interação. Apple Watch com botão Capture (ditado, Scribble) e complicações. Ditado com interface própria: troca de idioma na sessão, sessões longas, tempo limite de silêncio. Arrange Mode: reordenar blocos, linhas ou frases por arrastar. Rolagem tipo máquina de escrever. Controle na Central de Controle (iOS 18+).

**Como entra no Traço.**
1. **Folha de compartilhamento com dois destinos.** Texto, link ou foto de qualquer app → "Nova nota" ou "Juntar à nota de hoje" (a última aberta, ou o Destaque do dia). Nenhuma tela além dessas duas linhas. É o item "app fora do app" da FILA; isto define o comportamento. Algoritmo. Muda §3 (a porta tem uma segunda entrada, de fora) e `traco://` (rota `juntar`).
2. **Watch: um botão.** App de relógio com uma ação: ditar → nota nova. Transcrição pelo reconhecimento de fala da Apple, no aparelho (algoritmo; as palavras são do autor). Sem lista, sem leitura no pulso.
3. **Ditado no iPhone, com tempo limite de silêncio.** Toque longo em "Nova" abre a página com o microfone; para ao silêncio. O texto entra cru e a forma veste ao soltar (§17), como se digitado.
4. **Reordenar itens da lista arrastando.** Na lista viva, item com pega (`onMove` nativo). Algoritmo. §19.2 "Escrita".
5. **Rolagem máquina de escrever.** A linha do cursor fica fixa a dois terços da tela; o olho não viaja. Polimento em `PaginaView`.

**O poder que traz.** Captura: o custo de começar cai a zero porque nenhuma decisão (pasta, destino, título) precede o texto — o traço é gravado no instante em que aparece, do pulso ou de outro app. Ordem: arrastar uma frase é operar sobre a estrutura do próprio pensamento; texto que não se reordena congela o primeiro rascunho. Atenção: cursor fixo é menos deslocamento do olho, menos quebra de foco.

**A estrutura que traz.** Share Extension (target novo) escrevendo no mesmo SwiftData via App Group; rota `traco://juntar`. Watch target com `SFSpeechRecognizer` no aparelho. Nenhum campo novo em `Nota`. No .md nada muda: texto ditado é texto.

**O quanto eleva.** 4: Captura hoje é um widget de dois atalhos; com folha, pulso e voz o Traço passa a pegar o traço onde ele nasce — e a lista ganha a operação de ordenar que a mente faz sozinha.

**O que fica de fora — proposta histórica.** Biblioteca de ações em JavaScript, workspaces, badge de "não processados" (pressão de inbox; o Traço não tem inbox — §3). Mail Drop e Web Capture (servidor: regra 10). Ações de IA com chave própria (regra 10; regra 1). Writing Tools no editor (reescreve: regra 1). Sintaxes e markdown cru (lei do dono: nunca lembrar código).

**O não-óbvio.** O Drafts não é um app de texto; é um app de adiamento de decisão. Ele descobriu que "para onde vai" custa mais que "o que é" — e tirou a pergunta do começo. O Traço já faz isso na página nua; o que falta é fazê-lo de fora do app. E o Arrange Mode diz o que nenhum app de notas diz: a ordem das frases é conteúdo, e quem só digita nunca a revisita.


---

### Duolingo
`poderes: Memória · Linguagem` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A unidade de um: uma pergunta ocupa a tela, cabe em dois minutos, e o que se cobra muda de forma a cada vez. E a cota diária, que impede revisão em massa.

**A função, como existe lá.** Lição em exercícios de um item por tela (toque, digitação, fala, escuta, tradução). Aba Practice com "Mistakes" (prática personalizada de erros) e "Words". Teste de nivelamento ao iniciar. Energy: cota diária que limita quantas lições cabem num dia.

**Como entra no Traço.**
1. **Recordar por unidade.** Hoje o Recordar cobra a nota inteira. Passa a cobrar por unidade quando a nota tem forma: no degrau 3, a nota inteira; no degrau 7, um campo ("qual era o seu obstáculo interno?" — rótulo do template; o algoritmo sabe qual campo está preenchido); no degrau 21, só a frase que vale ("desta nota, o que sobrou?"). Uma pergunta por tela, nada mais. Revelar mostra a resposta ao lado do original, como hoje. Algoritmo puro (§7, §19.2 Memória). Muda §7: três formatos, escolhidos pelo degrau.
2. **Escada que desce.** Depois do Revelar, uma escolha de um toque, sem placar: "de novo em 3 dias" ou "seguir". O autor decide; o app não avalia. "De novo" desce um degrau. Sem nota, sem contagem além do "recordada ×N" que já existe.
3. **Cota, não sequência.** Nunca mais de três Recordar cobrados num dia; o excedente rola para o dia seguinte. Não é limite de assinatura — é o que impede revisão massificada, que espaçamento nenhum sobrevive.

**O poder que traz.** Memória: recuperação ativa em unidade pequena mantém a taxa de acerto alta o bastante para o esforço não virar fuga (dificuldade desejável, não impossível). Formatos alternados exercitam a mesma lembrança por rotas distintas. Linguagem: o degrau 21 pede destilação — dizer em uma frase o que a nota dizia em vinte é o exercício de precisão que o Traço ainda não tem. Espaçamento de verdade exige cota diária; sem ela o autor faz dez de uma vez e joga fora o efeito.

**A estrutura que traz.** `Revisoes` ganha formato por degrau (`inteira · campo · frase`); `registrarCumprida` aceita subir ou descer. A frase do degrau 21 grava-se em `Nota.sentido` quando vazio — é o autor escrevendo, então pode entrar; converge com o bloco do Fable. No .md: `sentido:` no frontmatter. Notificação: o texto muda por formato ("um campo" / "uma frase"), nunca o conteúdo.

**O quanto eleva.** 4: o Recordar existe, mas em peça única; ganha tamanho certo, direção nos dois sentidos e um último degrau que é exercício de linguagem — dois poderes de uma vez.

**O que fica de fora — proposta histórica.** Streak, XP, gems, ligas, Daily Quests, Friends Quests, coruja chantageando na notificação (§12 por nome). Explain My Answer, Video Call, Roleplay (IA escreve e conversa: regras 1 e 5). Teste de nivelamento (o Traço não nivela pessoas). Energy como moeda de assinatura.

**O não-óbvio.** O Duolingo é acusado de otimizar retenção e não fluência — e é verdade — mas o mecanismo que retém é o mesmo que ensina: uma pergunta, agora, curta. Tire a coruja e sobra a melhor máquina de recuperação ativa do mercado. E o degrau 21 pedindo "uma frase" não é atalho: é o que a memória faz sozinha depois de três semanas — guarda o essencial e perde o detalhe. Cobrar a essência é cobrar o que ficou.


---

### Edda
`poderes: Linguagem · Metacognição` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Um crítico que aponta e nunca escreve: regra, offline, sem modelo. E a prova de que 120 perguntas escritas à mão, combinadas com o material do autor, rendem mais que um gerador.

**A função, como existe lá.** "The Skald": assistente determinístico, baseado em regras, offline — mais de 120 prompts escritos à mão, 160.000 combinações de premissas, nove categorias de sinalização de estilo (voz passiva, mais de 270 clichês e outras), seis índices de legibilidade, correção ortográfica; não escreve prosa. Sprints cronometrados de 15, 30 e 60 minutos.

**Como entra no Traço.**
1. **Apontar.** Ao soltar o teclado — o instante em que a forma veste (§17) — o app sublinha em âmbar fraco trechos de três rótulos de lista fechada: **frase feita**, **vago**, **passiva**. Toque no sublinhado → uma linha com o rótulo, nada mais. Nenhum substituto sugerido. Nada = silêncio. Quem faz: frase feita é lista local pt-BR (regra: bate ou não bate); vago e passiva são heurística local primeiro (regex "foi/foram + particípio"; quantificadores vazios); onde a heurística não fecha, a IA devolve `{trecho, rótulo}` com trecho LITERAL, verificado como nos Padrões (§19.4 regra 3) — trecho que não existe na nota é descartado. Muda §2: a lista fechada ganha o item 7, **Apontar** (marcar trecho do autor com rótulo, sem substituto), e §19.1 ganha a linha 6. Pede ADR. Opt-out por nota e global, como o auto-forma. A metade algorítmica (lista de frases feitas + regex) entra sem ADR; a metade da IA espera por ele.
2. **Banco local de perguntas dos Padrões.** O fallback local do Padrões (§19.1 linha 4) vira o que o Skald é: perguntas escritas à mão, por gesto, com o fragmento literal do autor encaixado pelo algoritmo ("você escreveu '{X}' em três notas — o que fez diferente na vez que funcionou?"). Zero modelo, zero rede, verificação trivial. Esforço S.

**O poder que traz.** Linguagem: a frase feita é palavra que o autor não escreveu — só repetiu. Apontá-la sem substituir força o efeito de geração no vocabulário: o autor tem de achar a palavra dele. Especificidade lexical é precisão de pensamento — "vago" é o Aviso de "plano sem obstáculo" aplicado à palavra. Metacognição: ver o próprio tique ("passiva" três vezes na mesma nota) é padrão sem placar.

**A estrutura que traz.** Sem campo novo em `Nota`: as marcas são derivadas, recalculadas, nunca persistidas, nunca exportadas. Lista `FrasesFeitas.pt` no bundle. Contrato remoto ganha `apontar: [{trecho, rotulo}]` opcional, rótulo de enum. Caderno: um decorador de sublinhado por intervalo.

**O quanto eleva.** 5: Linguagem é o poder que o Traço hoje não multiplica; isto abre a porta sem ferir a regra de ferro, porque aponta e não escreve.

**O que fica de fora — proposta histórica.** Os seis índices de legibilidade: índice é placar (regra 5). Metas de palavras, mapas de calor, sprints com histórico, modo desafio (§12). Worldbuilding, EPUB, beta-readers: outro produto. Blindwrite: o Traço já não tem chrome. Os 120 prompts como prompts: nenhum prompt ocupa o vazio (regra 8) — entram só como perguntas de Padrões, citando o autor.

**O não-óbvio.** A frase feita é o ChatGPT de dentro: texto pronto que entrou pela mão do autor. A regra de ferro recusa o texto pronto que vem de fora; o Skald mostra como recusar o que vem de dentro — sem escrever uma palavra. E a Edda vende isso por US$ 39, sem assinatura, sem nuvem: prova de mercado de que "aponta e não escreve" é produto, não limitação.


---

### Evernote
`poderes: Arquivo · Captura` · `eleva: 3/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Achar o que se fotografou, e aparecer na hora em que o autor costuma escrever — sem notificar.

**A função, como existe lá.** Busca em texto de imagens, PDFs, escaneamentos e manuscrito, com tolerância a erro de digitação. Sugestões do Spotlight por hora, local e frequência. Ações rápidas na Central de Controle e na Tela Bloqueada. Importar .md, .txt, .html e .docx como notas editáveis. Criptografia de texto selecionado dentro da nota.

**Como entra no Traço.**
1. **Busca dentro do anexo.** Ao anexar foto, o app roda Vision no aparelho (algoritmo) e guarda o texto reconhecido num índice à parte — nunca no `texto` da nota, nunca na voz do autor (§16: mobiliário não indexa como voz; texto de foto é de outro, não do autor). A busca acha a nota pelo que está na foto e o resultado diz "na foto" em vez de trecho. Trancada: anexo não indexa (regra 2). Muda §16 em uma frase: a busca alcança o texto dentro do anexo, que não é voz do autor.
2. **Aparecer na hora certa.** Doar as intents `NovaNota` e `Recordar` ao sistema a cada uso; o iOS passa a sugerir o Traço na Tela Bloqueada e no Spotlight na hora e no lugar em que o autor costuma escrever. Zero notificação, zero tela nova. Algoritmo. §19.2 "Sistema". Esforço S.
3. **Central de Controle.** Um controle "Nova nota" (iOS 18+) ao lado do widget de dois atalhos. Esforço S.

**O poder que traz.** Arquivo: a foto do quadro, da página do livro, do recibo vira achável — buscar para agir (§16) sem transcrever e sem que texto alheio contamine o corpus. Captura: a sugestão do sistema na hora habitual reduz o caminho até a página a um toque, quando a mente já está no gesto — é gatilho de contexto (o se–então do próprio sistema), não lembrete.

**A estrutura que traz.** Índice de OCR por anexo (`TextoDeAnexo`: id do anexo + texto; apagado com o anexo no ciclo de vida que já existe). Não entra no .md — o export segue sendo só a voz do autor. Doação de intents em `Intencoes.swift`. Control Widget no target do widget.

**O quanto eleva.** 3: o arquivo passa a achar o que o autor viu, não só o que digitou; e o app chega sozinho na hora do hábito — sente-se no primeiro dia, sem mudar o que o Traço faz pela mente.

**O que fica de fora — proposta histórica.** AI Assistant, Semantic Search, AI Edit, AI Meeting Notes, resumos, legendas automáticas, AI Memory (regra 1, §12). Tarefas e calendário (§12). Home com widgets e Scratch Pad: a home é altar (§3). Colaboração e espaços (§12). Criptografia de trecho selecionado: selo parcial vaza em alguma rota — busca, Padrões, export — e o Traço só sabe selar a nota inteira em todas elas (regra 2).

**O não-óbvio.** "Remember everything" produziu o contrário no usuário: quando a mente sabe que está guardado, guarda menos e lembra só onde está (efeito Google, Sparrow 2011). O Evernote é o experimento em escala do que o §16 evita ao separar busca (arquivo) de Recordar (memória). Pegue a busca dentro da foto, que é arquivo puro; deixe a promessa, que é o adversário.


---

### Fable
`poderes: Sentido · Metacognição · Segundo cérebro · Atenção` · `eleva: 4/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** Um momento de reflexão no fim de cada unidade — e uma folha de leitura com um único controle.

**A função, como existe lá.** Clubes com marcos automáticos por capítulo e "sala de reflexão ao final". Folha de leitura do e-reader (REFERENCIAS §3): claro e escuro separados, quatro tipos por nome, UM controle de tamanho de Aa a Aa, dois interruptores. Registro diário de progresso.

**Como entra no Traço.**
1. **"O que ficou claro?" em toda nota.** A linha de sentido (§8.5) hoje só existe na expressiva. Passa a existir em toda nota concluída com forma ou com mais de ~150 palavras: ao tocar Concluída a nota fecha como hoje e, no rodapé dela, nasce uma linha fraca — "o que ficou claro?" — que o autor preenche quando quiser, ou nunca. Zero passo a mais no caminho principal (§17.4): Concluída não espera por ela. Algoritmo; template nosso; a IA nunca a toca. Muda §8.5 (a linha sai do fecho e vira propriedade de qualquer nota), §9 (Padrões citam linhas de sentido), §16 (já entra na busca) e o export.
2. **Folha de ajuste de leitura.** Resolve o §22 pela saída 2: um controle de tamanho (Aa → Aa) que escala o CONTEÚDO (texto do autor, cartões, notas) e trava o chrome (régua, barra). Folha efêmera do Perfil, morre ao toque fora. Nada de temas: tema escuro único (regra 9).

**O poder que traz.** Sentido: fechar uma unidade com uma frase é construção de sentido — o mecanismo que Pennebaker mede na expressiva — aplicado ao pensamento comum. Metacognição: doze linhas de sentido são os padrões do autor ditos por ele mesmo, matéria melhor para os Padrões do que doze notas inteiras. Segundo cérebro: cada linha é o resumo que a IA está proibida de escrever — escrito pelo autor, na voz dele; o corpus exportado ganha uma camada de essência com proveniência total. Atenção: letra do tamanho certo sustenta a leitura.

**A estrutura que traz.** Nada no modelo: `Nota.sentido` já existe para todas. UI: campo de rodapé pós-Concluída em `PaginaView`. `Corpus.arquivoMd` grava `sentido:` no frontmatter de qualquer nota. Padrões: a voz enviada inclui a linha de sentido (já é voz do autor). `Tema` migra para fontes que escalam (`relativeTo:`) no conteúdo; `system(size:)` fica no chrome.

**O quanto eleva.** 4: Sentido deixa de ser exclusivo do desabafo e vira o fecho de qualquer pensamento — e o mesmo gesto alimenta Padrões e o segundo cérebro sem uma linha de IA.

**O que fica de fora — proposta histórica.** Streaks, metas anuais, Reading Wraps, BookAura, badges, estatísticas (§12). Clubes, feed, mensagens, Social Mode (§12). Scout e recomendação (IA decidindo pelo leitor). Marcos com ritmo sugerido: o Traço não dá ritmo a ninguém.

**O não-óbvio.** No Fable, o leitor só escreve num lugar: a sala de reflexão do fim. O app inteiro é social, e o único ato solitário é o que fica. O Traço já tem esse lugar — a linha de sentido — mas o trancou atrás dos 15 minutos da expressiva. Soltá-lo para toda nota é a mudança de uma linha com maior alcance deste lote: o autor passa a escrever, ele mesmo, o índice do próprio corpus.


---

### Fabric
`poderes: Segundo cérebro · Arquivo · Captura` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O corpus atrás de uma superfície que os agentes do autor leem — e a lição do que NÃO exportar. O Fabric põe a biblioteca à disposição das IAs por MCP, CLI, API e pasta local; o Traço faz o mesmo sem servidor, com a pasta de .md que já existe.

**A função, como existe lá.** Servidor MCP e API OpenAPI (busca, criação e edição de notas, favoritos, pastas, tags, tarefas e memórias). CLI "para agentes como Claude Code" (`save`, `note`, `link`, `file`). Sincronização de pasta local em duas vias (desktop). Memória do assistente. Exportação: notas viram HTML com pasta de assets; metadados, tags, comentários e chats NÃO são exportados; sem reimportação. Captura sem pasta e sem nome (folha de compartilhamento, extensão, voz). Créditos de pensamento.

**Como entra no Traço.**
1. **A pasta é a API.** O backup automático no Arquivos (iCloud Drive) deixa de ser um .md único (ponytail v1 do `Corpus`) e vira uma pasta `Traço/` com um arquivo por nota e um `LEIA-ME.md` de template. Claude Code, Claude Desktop, Cursor, ChatGPT com acesso a arquivos leem a pasta como leem qualquer projeto: sem MCP nosso, sem CLI nosso, sem servidor (regra 10). Regravada a cada Concluída e a cada Queimar, como hoje.
2. **Frontmatter que serve à IA.** O cabeçalho ganha o que o Fabric perde no export: `gesto`, cada campo como chave (`obstaculo:`, `plano:`), `sentido:`, `criada`, `editada`, `recordada: N`. Tudo algoritmo; tudo voz do autor ou rótulo nosso. Um agente que lê cem WOOPs do autor sabe os obstáculos internos e os planos se–então dele — contexto que nenhum chat acumula.
3. **`LEIA-ME.md`: o contrato com as IAs do autor.** Texto fixo do app, não do modelo: o que é a pasta, o que cada forma significa, que tudo é voz do autor, e a regra: "leia; não reescreva; cite literalmente; nunca escreva aqui". É o único "prompt" que o Traço produz, e não ocupa vazio nenhum — mora fora do app.
4. **Só leitura, por construção.** Trancada e queimada nunca entram na pasta (`Corpus` já filtra; a regra 2 vale para a rota nova). Nenhuma IA escreve na pasta pela mão do Traço: a rota inversa é o import, ato do autor. Nada de "memórias" do assistente (§19.1: a IA não escreve o perfil do autor).
5. **No telefone.** App Intent `LerNotas` (só leitura, filtra trancadas) para Atalhos passarem notas a qualquer app de IA no iPhone; e "Compartilhar como contexto" na nota aberta (folha do sistema com o .md da nota).
6. Captura sem pasta e sem nome já é o §3; a folha de compartilhamento fica no bloco do Drafts.

Pede ADR: §23 novo ("Segundo cérebro": a pasta como superfície, layout, LEIA-ME, selo, só-leitura) e emenda ao §12 (o não-objetivo "sync/nuvem" continua para o APP; a pasta no iCloud do autor é backup, não sync).

**O poder que traz.** Segundo cérebro: contexto com proveniência — cada linha do corpus é do autor, sem resumo de máquina misturado, com intenção estruturada (obstáculo, plano, critério de pronto) e essência (linha de sentido) escritas por ele. Uma IA que trabalha em cima disso trabalha com o autor de verdade, não com uma média. Arquivo: um arquivo por nota é o formato que Obsidian, git e grep entendem — dura décadas. E a formação não paga a conta: o Recordar fica dentro do app, onde agente nenhum chega; as IAs leem fora. Os dois usos do mesmo corpus não se atrapalham.

**A estrutura que traz.** `Corpus.exportar` → pasta com um .md por nota + `LEIA-ME.md`; nome de arquivo estável (data + uuid curto — renomear quando a primeira linha muda quebraria links; o título pelo algoritmo `VozDoAutor.titulo` vai no frontmatter). Frontmatter estendido; `separarCampos`/`importar` leem o formato novo e o antigo. Intent `LerNotas` em `Intencoes.swift`. Nenhum campo novo em `Nota`.

**O quanto eleva.** 5: abre o poder que ainda não tem seção na SPEC — e o abre sem uma linha de rede, porque o export bem feito já é o segundo cérebro.

**O que fica de fora — proposta histórica.** Chat com o corpus dentro do app e busca semântica (§12: a IA da casa devolve rótulo, não conversa). Organização automática, renomeação automática, sugestão de tag (§19.1: a IA não intitula nem etiqueta). Memória do assistente escrita pela IA (regra 1). Agents com agenda, trabalhos agendados, Email-to-Fabric, conexões com Drive/Notion (servidor próprio: regra 10). Créditos de pensamento (ADR 31j). Nuvem própria e export sem reimportação: o anti-modelo do §10.

**O não-óbvio.** O segundo cérebro para as IAs do autor não é uma feature a construir; é o export feito direito. O Fabric precisa de MCP, CLI e API porque o corpus dele mora num servidor; o do Traço mora numa pasta — e pasta é a interface que todo agente já fala. Segundo: o Fabric resolve recuperação e o Traço resolve proveniência, e para uma IA a proveniência vale mais que o volume — um corpus onde nada foi escrito por máquina é o único que não devolve à IA o eco dela mesma. Terceiro: a promessa do Fabric ("nunca precise lembrar") é o que o Traço recusa para o autor e concede às IAs — a mente treina dentro, as máquinas leem fora.


---

### Family
`poderes: Intenção · Atenção` · `eleva: 2/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** Mostrar o resultado antes do ato irreversível, e esconder com um gesto físico.

**A função, como existe lá.** Simulação de transações e alertas de ações nocivas antes de assinar. Stealth Mode ao tocar no saldo ou virar o telefone. Molas interrompíveis, "um objeto por driver", sistema de trays dinâmicos (ensaio "Family Values"). Háptica com opção de reduzir. Backup manual da frase com teste de confirmação.

**Como entra no Traço.**
1. **Queimar mostra o resíduo antes.** Na confirmação do Queimar, em vez de só uma frase de aviso, o cartão que VAI sobrar — "Expressiva — queimada · 14 min · [a linha de sentido]" — aparece como prévia, e o fogo vem depois. O autor confirma vendo exatamente o que fica. Algoritmo; muda §8.6 (a confirmação é simulação, não texto). O mesmo para Apagar: o card some da lista em prévia antes do desfazer.
2. **Virar o telefone esconde.** Com a expressiva aberta, virar o aparelho de bruços escurece a página (não tranca, não sai: só esconde). Desvirar volta. Sensor de orientação, algoritmo. Para escrever no ônibus.
3. **Reduzir háptica** no Perfil: o piano de hápticos ganha volume.

**O poder que traz.** Intenção: decidir vendo o desfecho é decisão informada — a prévia do resíduo faz o autor perceber que a linha de sentido é tudo o que sobra, o que dá peso à frase. Atenção: esconder por gesto físico tira a vigilância do ambiente do meio da escrita.

**A estrutura que traz.** Nada no modelo. `Confirmacao` ganha um modo "prévia" que renderiza o card da lista. `CMMotionManager` (gravidade z) na expressiva.

**O quanto eleva.** 2: polimento que se sente na cerimônia mais grave do app; as leis de movimento do Family já estão no §21.

**O que fica de fora — proposta histórica.** Tudo que é carteira: chat, contatos, notificações por atividade, badges. O domínio inteiro, como o DOSSIE já disse.

**O não-óbvio.** O Family é o único app deste lote que pratica recuperação ativa: o backup manual exige que a pessoa prove que lembra as doze palavras. Faz isso porque é a única memória que importa no domínio dele. O Traço faz o mesmo com a nota — e a lição é a forma: um teste curto, sem placar, no momento em que esquecer custaria caro.


---

### Flowstate
`poderes: Atenção · Sentido` · `eleva: 3/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** Não há volta: separar gerar de avaliar tirando do autor a possibilidade de voltar atrás enquanto escreve. Sem destruir nada.

**A função, como existe lá.** Sessão cronometrada de 5, 15 ou 30 minutos com regra única: sair antes do fim ou ficar mais de cinco segundos sem digitar perde todo o progresso; o texto só é salvo ao fim do timer. Filosofia "flow, then react". Nada de streaks ou estatística.

**Como entra no Traço.**
1. **Expressiva só para frente.** Durante os 15 minutos a página aceita só acrescentar: apagar, selecionar e mover o cursor para trás não fazem nada. Erro de digitação fica. É a instrução de Pennebaker ("não pare para corrigir") virada regra da página, não conselho. Algoritmo (guarda no binding: texto novo mais curto que o velho → restaura). Opt-out no Perfil. Muda §8.2 (a instrução ganha a regra) e §19.2 "Selo".
2. **O timer sente a pausa.** Sem punição: depois de ~20 s sem tecla, o timer da expressiva ganha um pulso lento de opacidade — atrito contra a fuga, não ameaça. Some à primeira tecla. Não fere §11: a pausa não é digitação.

**O poder que traz.** Atenção: o crítico interno é a fuga mais comum na escrita expressiva; sem tecla de apagar ele não tem onde agir, e a geração corre. Sentido: a expressiva funciona pela construção de sentido em fluxo; editar no meio interrompe o fluxo e reduz o ganho. O Flowstate prova que "só para frente" sustenta 15 minutos de escrita — o excesso era a punição, não a regra.

**A estrutura que traz.** Nada no modelo. `PaginaView` em modo expressiva: binding com guarda de comprimento; timer com estado "pausado". Opt-out por chave no Perfil.

**O quanto eleva.** 3: a expressiva já existe e já cala a Análise; passa a calar também o editor de dentro — o autor sente na primeira sessão.

**O que fica de fora — proposta histórica.** Apagar o texto por pausa: destruição como pedagogia fere o §8 (o texto se sela ou se queima por escolha, nunca por castigo). "Salvar só ao fim do timer": o Traço salva a cada trânsito (§20). Escolha de 5/30 minutos: o protocolo da expressiva é 15. E um fato do CATALOGO: em 2026 não há versão iOS na loja e o site está fora do ar — a referência é histórica.

**O não-óbvio.** Flowstate e Traço concordam no essencial: avaliar tem de esperar. O Flowstate impõe isso pelo medo; o Traço, pelo silêncio da Análise durante a escrita. O que faltava ver é que o autor também avalia — com a tecla de apagar — e que dá para tirar essa tecla sem tirar o texto.


---

### Forest
`poderes: Atenção · Intenção` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A aposta fica visível no lugar exato da fuga: o telefone. O Forest não vende foco; vende uma consequência que o autor vê enquanto foge. O Traço já tem consequência (sair tranca, o timer sela), mas ela só existe dentro do app, e a fuga acontece fora dele.

**A função, como existe lá.** Sessão de foco com etiqueta ("Estudo", "Escrita") e árvore que murcha se o usuário sair. "Live Activities que acompanham a sessão" na tela bloqueada e na Ilha; "live session view" no Apple Watch; widgets de Tela de Início que iniciam sessão; Forest Timeline com o histórico. Deep Focus "guia de volta" ao app.

**Como entra no Traço.**
1. **Destaque vivo.** Quando uma nota com a forma Destaque é Concluída, o algoritmo abre uma Live Activity com o texto do campo "A única coisa de hoje" na tela bloqueada e na Ilha Dinâmica. Cada vez que o autor pega o telefone para fugir, lê a própria frase. Toque abre a nota. Termina à meia-noite ou quando o autor a descarta (o sistema já permite). Sem botão novo, sem nome de recurso: a forma já é o gatilho (§17.3, "aparece pronta"). ActivityKit, na extensão de widget que a U4 criou. Muda §6 (Destaque ganha a linha "sai para a tela bloqueada até o fim do dia") e §19.2 (a regra "notificação sem conteúdo da nota" vale para o Recordar; o Destaque é a exceção declarada, por escolha do autor, e Destaque nunca é trancada).
2. **Timer da expressiva na Ilha.** Durante os 15 minutos, a Live Activity mostra só o tempo e a consequência: "expressiva · 6:12 · ao fim, sela". Nada do texto. O autor que sai para o Instagram vê o relógio correr. É a árvore murchando, sem árvore. Muda §8 (o timer continua fora do app, e o autor vê).

**O poder que traz.** Intenção de implementação funciona quando o plano está disponível no momento do gatilho (Gollwitzer); o Forest prova que o gatilho da distração é o próprio aparelho. Pôr a frase do Destaque na tela bloqueada é pôr o "se–então" onde o "se" acontece. E aversão à perda: consequência visível pesa mais que consequência lembrada.

**A estrutura que traz.** Nenhum campo novo em Nota: a Activity nasce da forma Destaque e morre à meia-noite. A extensão de widget ganha ActivityKit. Nenhuma notificação nova: Live Activity não é push. Arquivo .md intocado.

**O quanto eleva.** 4 — o Traço passa a multiplicar Atenção e Intenção FORA do app, onde hoje não faz nada; dois poderes num mecanismo só.

**O que fica de fora — proposta histórica.** Árvore, moedas, loja, ranking, Plant Together, Focus Challenge, streaks: §12 por nome. Deep Focus e Allow List (bloquear outros apps): exige entitlement FamilyControls e põe o app policiando o dono; o atrito do Traço mora na escrita, não no sistema. Time Guard: agenda, §12. Mindful Space (respiração, paisagens sonoras): não escreve nada; fora do escopo.

**O não-óbvio.** A etiqueta da sessão do Forest ("para que é esta sessão?") é o Destaque. Só que o Forest pergunta antes, e o Traço já tem a resposta nas palavras do autor. O que falta não é a pergunta; é tirá-la do arquivo. A Live Activity é o único chrome que o §3 permite, porque fica do lado de fora da página.


---

### Freewrite
`poderes: Sentido · Atenção` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** Separar gerar de editar no hardware: enquanto se rascunha, não se volta. O aparelho impõe o que o protocolo de Pennebaker só instrui ("escreva sem parar, não corrija").

**A função, como existe lá.** "By design, there is no copy/paste function"; sem seleção; backspace funciona; mover o cursor exige combinação de teclas (só Gen3). [pg up]/[pg dn] para reler. Telas de status alternáveis, uma delas em branco; HUD do Alpha só ao segurar espaço 3 s. Shred com confirmação digitada. Sync de uma via: aparelho → Postbox.

**Como entra no Traço.**
1. **Expressiva só para a frente.** Ao abrir a forma Expressiva (§8), a página perde seleção, copiar/colar e toque-para-posicionar-cursor. Backspace fica: corrigir a última palavra não é editar, e o Just Write erra ao tirá-lo. O cursor vive no fim. Algoritmo: UITextView com `canPerformAction` fechado e cursor preso ao fim; zero IA. Ao selar, a nota volta ao normal; selada não reabre sem Face ID, então na prática o texto nunca é editado. Muda §8 (a instrução única ganha a regra "sem volta enquanto o timer corre"). Opt-out por nota, como no §17.
2. **Contagem fora da página.** A FILA tem "contagem de palavras na nota" aberta. A lição do Freewrite: o número nunca mora na página; mora numa tela que o autor vira para ver. No Traço, o número aparece no cartão da nota nas Notas, depois de Concluída. Nunca enquanto se escreve.

**O poder que traz.** A escrita expressiva rende pela construção de sentido em fluxo, não pelo polimento; cada volta ao texto para corrigir é o crítico interrompendo a divulgação. Sem seleção, o olho fica à frente e a mão não para. É o mesmo atrito deliberado da confirmação (§15): fricção que é método, não bug.

**A estrutura que traz.** Nenhum campo. Um estado de edição (`soParaFrente`) ligado a `gesto == .expressiva && timer ativo`. Nada muda no .md.

**O quanto eleva.** 3 — a expressiva fica mais fiel ao protocolo no primeiro dia; Sentido e Atenção já existem e ganham corpo.

**O que fica de fora — proposta histórica.** Pastas A/B/C escolhidas por chave antes de escrever: o Traço veste depois da palavra, nunca pede domínio antes (§17). Streaks e "Writing Days" do Postbox (§12). Sprinter com meta de palavras: placar. Nuvem própria (§12). Shred com confirmação digitada: o Queimar já tem o atrito certo; digitar "queimar" depois de 15 minutos de peso é atrito na hora errada (§8.5).

**O não-óbvio.** O sync do Freewrite é de UMA via: do aparelho para fora, nunca de volta. É a direção exata que o segundo cérebro do dono precisa: o corpus sai para as IAs do autor, e nada volta para dentro da nota. Vale como frase de ADR. E a chave A/B/C prova que Ordem pode ser posição em vez de nome; o Traço responde com a auto-forma, mas a lição é a mesma: o autor não nomeia.


---

### Google Photos
`poderes: Arquivo · Captura · Memória · Metacognição` · `eleva: 3/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Organizar pelo que está DENTRO, sem o autor marcar nada: o princípio do §17 aplicado ao que a busca encontra. E o degrau de tempo mais longo: o passado volta na data certa.

**A função, como existe lá.** Busca por texto dentro da foto e Google Lens ("identify text and objects"), sem etiqueta. Photo Stacks agrupam duplicadas e similares. Aba Documents separa capturas de tela, recibos e notas sozinha. Memories: destaques por data de anos anteriores e memórias mensais, com notificação. Locked Folder tira o item da grade, da busca, dos álbuns e dos outros apps. Ask Photos: Gemini conversa sobre a biblioteca, opt-in.

**Como entra no Traço.**
1. **Texto do anexo entra na busca.** Ao anexar foto, o algoritmo roda OCR local (Vision, pt) e guarda o texto reconhecido. A busca do §16 acha a nota pela foto do quadro branco ou da página do livro. O resultado marca "no anexo", não no texto do autor. O texto do anexo nunca é voz: não vai à rede (§19.1), não entra em Padrões, não é alvo do Recordar, não sai no .md como prosa. Só a busca vê. Trancada: anexo selado junto.
2. **Degrau de um ano.** A escada 3→7→21 ganha o degrau 365 para notas que o autor recordou: notificação sem conteúdo ("uma nota de setembro de 2025 espera o Recordar"), fluxo idêntico ao §7. É o Memories sem mostrar a foto: o Photos exibe, o Traço esconde e cobra.
3. **Quase-iguais alimentam Padrões locais.** Photo Stacks é agrupamento por similaridade, local. O algoritmo mede sobreposição de frases entre notas (n-gramas, sem modelo) e, quando três notas repetem a mesma sentença, fabrica a pergunta de reserva do §19.1 linha 4: "você escreveu ‘X’ em três dias diferentes — o que muda entre o primeiro e o último?" O fragmento é literal por construção; a verificação dura do §19.4 passa sozinha.

**O poder que traz.** Offloading honesto: o autor fotografa em vez de transcrever e ainda acha depois; a carga sai da memória de trabalho sem sair do arquivo. Espaçamento longo: intervalo longo consolida para prazo longo (Cepeda 2008), e o degrau de um ano é o que nenhuma escada curta dá. E a repetição vista de fora é metacognição sem placar.

**A estrutura que traz.** Anexo ganha `textoReconhecido: String?` (indexado, nunca exportado como voz). Agenda de revisão ganha o degrau 365. Um índice local de n-gramas por nota, recomputado ao Concluída.

**O quanto eleva.** 3 — Arquivo e Memória ficam mais fundos no primeiro dia; nenhum poder novo se abre.

**O que fica de fora — proposta histórica.** Ask Photos: chat dentro do arquivo, §12 duas vezes (chat, busca semântica). Memories como carrossel: mostra o conteúdo; é o "reler cartões à noite" do §3 com música. O botão azul da Locked Folder (o par com o Apple Photos já está nas REFERENCIAS). Partner sharing, álbuns, nuvem. Free up space não tem análogo: nota não pesa.

**O não-óbvio.** O Google Photos é o segundo cérebro visual mais poderoso que existe, e mostra a armadilha inteira: o corpus mora no servidor deles e a IA mora DENTRO do arquivo. O segundo cérebro do Traço inverte os dois: o corpus no .md do autor, a IA do lado de fora, alimentada por exportação. O que se copia do Photos não é a IA; é a regra "zero esforço de organização", que já é o §17.


---

### Grid Diary
`poderes: Memória · Metacognição · Sentido` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Duas coisas que o DOSSIE não olhou: o diário tem PERÍODO (dia, semana, mês, ano, e revisão por período), e o modelo "gratidão" é a versão popular de um método validado. O prompt continua fora.

**A função, como existe lá.** Entradas por dia, semana, mês e ano; "revisão por semana/mês/ano". Modelos de grade: gratidão, metas, planejador semanal. Mandala de 9 células com centro fixo. Dados do Saúde (passos, energia) inseridos na entrada; tempo de escrita gravado como minutos de meditação. Lembretes de escrita.

**Como entra no Traço.**
1. **Recordar o período.** As Notas vão ganhar seções por mês (FILA). No cabeçalho de cada seção, segurar abre o Recordar do §7 sobre o período: os cartões somem, o autor escreve o que lembra ter escrito naquela semana ou mês, Revelar mostra os cartões. Sem placar: o olho vê o que sumiu da cabeça. Trancadas não entram (aparecem só como "uma expressiva selada"). Algoritmo puro. Muda §7 (Recordar tem duas unidades: a nota e o período). Notificação opcional no domingo, sem conteúdo.
2. **Três coisas boas.** O "modelo gratidão" do Grid Diary é o "three good things" de Seligman (2005): três coisas que foram bem hoje e POR QUE aconteceram. Entra como forma do §6, roteada da palavra do autor ("hoje foi bom porque", "o melhor de hoje"), campos vazios: "Três coisas que foram bem · Por que cada uma aconteceu". Cumpre o ADR 31l: método com resultado comprovado, nada inventado. Roteador local por verbo; a IA só confirma o rótulo.

**O poder que traz.** Recuperação ativa na escala da semana treina a memória do vivido, não só do escrito; e o que o autor NÃO lembra é o dado metacognitivo mais honesto que existe, sem gráfico. O "três coisas boas" move a atenção do autor para o que deu certo e sua causa; o ganho de bem-estar durou seis meses no estudo original, e o "por quê" é parte do protocolo, não enfeite.

**A estrutura que traz.** `Gesto.tresCoisas` com dois campos. O Recordar do período não guarda nada: é computado sobre `criadaEm`. Uma notificação opcional a mais na agenda.

**O quanto eleva.** 4 — Memória ganha uma unidade nova (o período), Metacognição ganha a via sem IA, Sentido ganha um segundo método validado.

**O que fica de fora — proposta histórica.** O prompt no vazio (§3, decisão mantida). Dados do Saúde dentro da nota: o Traço só guarda o que o autor escreveu. Minutos de meditação no Saúde: é streak por procuração; o gráfico mora no app da Apple, mas é o mesmo placar. Figurinhas de humor, citações, eventos do calendário (§12 agenda), sync próprio.

**O não-óbvio.** A grade não é prompt: é CHUNKING. Nove células pequenas baixam o custo da primeira frase, o mesmo que os campos do WOOP fazem, só que o Grid Diary chunka antes da palavra e o Traço depois. E o centro fixo da Mandala é o Destaque: uma coisa no meio, oito em volta. A leitura que fica: o Traço tem escada para a nota e nenhum período para o autor; o Recordar do período dá o período sem dar o dashboard.


---

### Halide
`poderes: Captura · Atenção · Intenção` · `eleva: 3/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Capturar sem abrir o app e sem expor o arquivo. E ensinar o ofício no ponto de uso, numa frase, nunca num curso.

**A função, como existe lá.** Câmera na tela bloqueada e na Central de Controle (iOS 18): dispara com o telefone bloqueado e "não guarda ajustes entre sessões bloqueadas". Botão de Ação com In-App Trigger (faz uma coisa fora do app, outra dentro). Camera Control do iPhone 16. Siri Shortcuts com frases próprias. Widgets que abrem num modo. Curso de 10 dias "Learn As You Go" e microcópia curta nos controles. Process Zero: "zero AI and zero computational photography".

**Como entra no Traço.**
1. **Nova nota da tela bloqueada.** Controle da Central de Controle e da tela bloqueada (ControlWidget, iOS 18) que abre a página nua. A regra do Halide vira regra do Traço: a página nascida do bloqueio é SÓ ESCRITA. Grava, veste, Concluída; as Notas, o Padrões e o Perfil não existem até o Face ID. Captura sem exposição, como a câmera do sistema. Muda §3 (segunda porta, com a mesma página) e §19.2 Sistema. A extensão da U4 recebe o controle.
2. **Botão de Ação com dois papéis.** Fora do app: Nova (App Intent que já existe pela U4). Dentro, com a página aberta: Recordar. Botão físico para esconder a nota e escrever de memória; a barra [Analisar · Recordar · Anexar] ganha um atalho sem ganhar chrome. In-App Trigger é o mesmo Intent observado enquanto o app está em primeiro plano.
3. **Microcópia no rótulo.** Segurar um rótulo de campo ("Obstáculo interno") mostra uma frase nossa, de template, sobre por que ele existe ("o que em você atrapalha, não o mundo"). Texto do app, não da IA (§2: labels são nossas). Nada no fluxo principal: só quem segura vê.

**O poder que traz.** Captura: o traço entra no instante em que aparece, sem custo de abrir, sem custo de ver a lista (o anti-altar do §3). Intenção: quem entende que o obstáculo do WOOP é interno escreve um contraste mental que funciona; a versão "o mundo atrapalha" é a que Oettingen mostra não mover nada.

**A estrutura que traz.** Um ControlWidget e um App Intent a mais na extensão. Um dicionário estático `porque[rotulo]` nas formas. Nenhum campo em Nota. Rota nova: nota nascida do bloqueio marca `origem = .bloqueio` só para o teste de que o arquivo não abriu.

**O quanto eleva.** 3 — Captura fica completa (widget, controle, botão físico) e o autor sente no primeiro dia; sem poder novo.

**O que fica de fora — proposta histórica.** O curso de 10 dias: onboarding é nenhum (ADR 31g), e o Traço não pode virar o Halide das notas; a curva de aprendizado é a IA que cobre (§17). Histograma, waveform, zebras: instrumentos sobre a imagem; no Traço não há medidor sobre o autor (§19.1). Looks como menu (§12 templates), embora RAW + Look seja exatamente texto cru + forma vestida do §17.

**O não-óbvio.** Process Zero é "zero IA" vendido como a feature premium de um app pago e premiado. É a prova de mercado de que a recusa do §2 é produto, não limitação, e de que dá para cobrar por ela. E o "não guarda ajustes entre sessões bloqueadas" é um selo de outro tipo: a captura que não abre o cofre.


---

### iA Writer
`poderes: Linguagem · Segundo cérebro · Arquivo · Atenção · Ordem` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Um painel de instrumentos da língua, local e por regra: o autor VÊ os próprios adjetivos, advérbios e muletas e corta sozinho. E um corpus honesto: o que é voz dele e o que ele colou ficam distintos para sempre.

**A função, como existe lá.** Syntax Highlight: adjetivos marrom, substantivos vermelho, advérbios roxo, verbos azul, conjunções verde (En De Fr Es It Ru; sem pt). Style Check: fillers, redundâncias e clichês, padrões próprios por regex, local, "no AI". Authorship: humano em tons por autor, IA em gradiente, referência esmaecida; metadados no fim do arquivo; removidos ao exportar; detecção automática de conversa do ChatGPT ao colar. Focus Mode por frase, parágrafo ou máquina de escrever. Wikilinks `[[ ]]` com autocompletar. URL commands `read` e `write` com auth-token. Atalhos "Open Clipboard", "Dictate Text". Stats por seleção.

**Como entra no Traço.**
1. **A lente da língua.** Na nota aberta a partir das Notas (leitura, não digitação), um glifo discreto abre uma folha efêmera (morre ao toque fora, lição do Instapaper) com três interruptores: adjetivos · advérbios · muletas. A página colore as palavras; nada anima, nada muda no texto. Algoritmo: `NLTagger` com `.lexicalClass` (tem português) e uma lista nossa de muletas pt-BR ("basicamente", "realmente", "meio que", "tipo", "na verdade", "muito", "bastante") mais regex de redundância. Zero IA (§19.4: fecha em regra). Nunca durante a escrita (§11). Nunca em trancada. Esforço M.
2. **Colado não é voz.** Texto que entra por colar ou pela folha de compartilhamento veste-se sozinho como citação (portal que já existe; `>` no arquivo) e recebe fonte quando o payload traz URL ou título. Regras que decorrem: `Caderno.prosa` tira citação junto com o mobiliário, só a voz viaja (§19.1); Padrões nunca cita citação como "você escreveu"; Recordar esconde e não cobra; busca acha, marcando "na citação". Colar do ChatGPT: o mesmo, esmaecido, sem sermão; o esmaecimento já diz. Esforço S.
3. **Máquina de escrever na expressiva.** Cursor no centro vertical, parágrafos anteriores esmaecidos. Junta-se ao "só para a frente" do Freewrite. Um estado de layout. Esforço S.
4. **"Liga a" com autocompletar.** No campo "Liga a" da Nota permanente, digitar mostra títulos das notas do autor (busca local do §16) e o toque grava `traco://nota/<id>`. O autor nunca vê `[[`. O corpus vira grafo. Esforço M.
5. **Ler as notas de fora, com chave.** O `read` com auth-token do iA vira App Intent "Minhas notas" para Atalhos: devolve a voz do autor em .md, sem trancadas, sem queimadas, sem citações (item 2), sem anexos. O autor monta o atalho que alimenta o ChatGPT, o Claude, o Grok dele com o próprio corpus. Sem servidor (regra 10), sem chat dentro (§12). Esforço L, porque EXIGE ADR: §12 (compartilhamento: é para as IAs do autor, não para pessoas), §19.1 (a voz viaja para onde o autor manda, não só para a Análise) e a seção nova do segundo cérebro.

**O poder que traz.** Linguagem: ver o advérbio é o que faz cortá-lo; efeito de geração aplicado à revisão, o autor reescreve, o app nunca. Precisão lexical é poder de pensar. Segundo cérebro: uma IA alimentada com corpus onde citação e pensamento se misturam aprende uma voz falsa; o Authorship é o que torna o corpus utilizável como contexto. Atenção: a frase acesa e o resto apagado é o foco em escala de parágrafo.

**A estrutura que traz.** Citação ganha atributo opcional de fonte no .md (`> ... — fonte`), roundtrip preservado. `Caderno.prosa` exclui citação. Muletas: lista estática, editável no Perfil. `ligaA` da Nota permanente passa de texto a lista de ids, exportada como links `traco://`. App Intent "Minhas notas" com filtro por gesto e por mês. Nada de metadado de autoria no fim do arquivo: a citação É a marca.

**O quanto eleva.** 5 — abre Linguagem, que hoje é "quase nada", por algoritmo puro; e dá o primeiro mecanismo concreto do segundo cérebro sem servidor.

**O que fica de fora — proposta histórica.** A marcação à mostra (o autor digita `#`): lei do dono. Os atalhos que chamam o ChatGPT (Proofread, Shorten, Change Tone): §2, sem exceção. Publicar em WordPress/Medium (§12). Smart Folders, operadores AND/OR/NEAR, Command Palette: power-user; a página nua não tem onde pôr isso. Fontes iA Mono/Duo/Quattro: SF é a âncora (§11).

**O não-óbvio.** O iA Writer se vende como "nada entre você e o texto", e o que ele tem de único é o contrário: instrumentos ENTRE o autor e o texto, que mostram sem tocar. Um histograma da prosa. É o §19.4 com anos de prova: regra, local, sem modelo, e o autor faz o corte. E o Authorship não é ética: é higiene de corpus, a condição para que o segundo cérebro não minta.


---

### Instapaper
`poderes: Captura · Memória · Linguagem · Segundo cérebro` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A leitura do autor só entra no corpus quando ele a reescreve. O grifo é matéria-prima, não nota. E o arquivo antigo volta ao acaso: o Instapaper faz isso com artigos alheios, o Traço faz com a memória do autor.

**A função, como existe lá.** Folha de compartilhamento do iOS ("send to Instapaper"). Grifos e notas em qualquer artigo; 5 notas por mês no grátis. "Abrir artigo aleatório". Exportação por etiqueta em RSS, PDF ou ePub. Busca em texto completo. Summaries (IA). Painel de leitura que morre ao toque fora.

**Como entra no Traço.**
1. **Grifo vira Nota permanente, ou não vira nada.** A extensão de compartilhamento (FILA, "app fora do app") recebe o trecho grifado no Instapaper, no Safari ou no Kindle. Não grava o trecho como nota: abre a página com o grifo em CARTÃO FIXO não-editável (o mesmo do §9/§15) e o cursor no campo "Uma ideia nas suas palavras" da Nota permanente; "Fonte" já vem com a URL ou o título do payload. Se o autor fecha sem escrever, o cartão fica esmaecido como referência (iA Writer, item 2): não entra em Padrões, não viaja, não é cobrado no Recordar. Só a frase DELE vira corpus. Muda §6 (Nota permanente pode nascer de fora) e pede uma linha de ADR em §2: "Fonte" é preenchida pelo payload do sistema; metadado, não prosa de IA.
2. **Recordar ao acaso.** Recordar é desabilitado com a página vazia (§15). Passa a fazer outra coisa: com a página vazia, Recordar sorteia uma nota não-trancada com mais de 21 dias, e o autor escreve o que lembra dela sem nunca a ter visto na sessão. Revelar mostra. Nenhum botão novo, nenhum nome: é o "artigo aleatório" aplicado à cauda longa que a escada 3→7→21 abandona no dia 22. Muda §7 e §15.
3. **Exportar por filtro.** O export .md ganha o filtro das Notas (gesto, mês): "todas as Notas permanentes de agosto" saem num arquivo só. É o pacote de contexto para as IAs do autor antes do Intent do iA Writer (item 5).

**O poder que traz.** Efeito de geração: a ideia lida só se retém quando é reescrita, e reescrever é o único caminho de entrada, então a fricção certa está no lugar certo. Paráfrase é Linguagem: dizer com as próprias palavras força escolher a palavra. Recuperação sem pista da cauda longa é o que a escada não cobre: o corpus antigo deixa de ser arquivo morto.

**A estrutura que traz.** Extensão de compartilhamento com um alvo: Nota permanente com cartão fixo. O campo "Fonte" (já existe na forma) aceita URL. Sorteio do Recordar: query local `criadaEm < hoje-21 && !trancada && !queimada`. Export com predicado.

**O quanto eleva.** 4 — Captura ganha o canal da leitura, Memória ganha a cauda longa; Segundo cérebro ganha o corpus digerido em vez de colecionado.

**O que fica de fora — proposta histórica.** Summaries: resumo é §12 e §19.1 "proibido para sempre". E-mail de captura: exige servidor (regra 10). Etiquetas: organização à mão é fricção (§17). AI Voices, playlists, speed reading: consumo. Entrega no Kindle: sem correspondente. Busca em texto completo do arquivo alheio: o Traço só indexa a voz do autor.

**O não-óbvio.** O Instapaper vende leitura e entrega adiamento: tira a decisão "leio agora?" da frente e protege a atenção de hoje; a pilha de amanhã é onde ele morre (o DOSSIE já viu). O Traço não pode ter pilha porque a unidade não é o artigo, é a frase reescrita: sem a frase do autor não há nada para acumular. E o limite de 5 notas por mês, que é paywall, funciona como método: escassez de anotação melhora a anotação, a mesma aposta do Destaque e das 2–3 perguntas do Padrões.


---

### Just Write
`poderes: Atenção · Sentido` · `eleva: 2/5` · `esforço: S` · `quando: nunca`

**O que vale pegar.** Tirar a OPÇÃO de ajuda é o que desliga o reflexo de pedir ajuda. O Just Write faz isso com um manifesto e uma regra; o Traço já faz com o §2 e o aviso "A frase aqui é sua".

**A função, como existe lá.** "You can't edit or delete what you've already written." Timer de sessão com meta de palavras. "Clear text" para recomeçar; download em texto. Sem IA: "no AI assistant, no autocomplete, no 'continue writing' button". Texto em localStorage, nunca sai do aparelho. Sons de máquina de escrever liga/desliga. Focus Mode só nos apps de desktop.

**Como entra no Traço.** Nada entra por aqui. O que o Just Write tem de bom entra pelo Freewrite (expressiva só para a frente, COM backspace): a variante do Just Write, sem apagar nem a última letra, é a que o DOSSIE já chamou de regra sem propósito. O som de tecla como feedback de continuidade, a versão sonora do "não pare" de Pennebaker, o iOS já dá no ajuste de som do teclado do sistema: nada a construir. O manifesto `/no-ai` vale como referência de tom para a descrição na App Store e para o "silêncio explicado 1ª vez" (FILA): três parágrafos, sem citação, sem sermão.

**O poder que traz.** Redução de escolha (Hick a zero): sem botão de completar, o autor não gasta atenção decidindo se pede. Esse mecanismo já está no Traço por construção. O Just Write acrescenta a prova de que a recusa TOTAL, sem a parte multiplicadora, não sustenta um produto; é só ausência.

**A estrutura que traz.** Nenhuma.

**O quanto eleva.** 2 — confirma decisões tomadas; não muda o que o app faz pela mente.

**O que fica de fora — proposta histórica.** Meta de palavras: placar (§12). localStorage: o oposto do §10; limpar o navegador apaga a obra. Sem backspace: erro de digitação não é edição. "Clear text" sem arquivo: o Queimar sem a linha de sentido, ou seja, a dor sem o ganho (§8.5).

**O não-óbvio.** O Just Write chegou ao fecho do §8 por acidente: ou você fica com tudo (download) ou joga tudo fora (Clear text), sem meio. É o Selar/Queimar sem o método. A diferença é o que sobrevive: no Traço, a linha de sentido sai do fecho e entra em tudo; no Just Write, nada sai. O que vale registrar é a confirmação, por um app que só recusa, de que recusa sozinha é zero.


---

### Kindle
`poderes: Linguagem · Memória · Metacognição · Atenção` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O dicionário no ponto de encontro com a palavra, a custo zero, e então fechar o ciclo que o Kindle deixa aberto: a palavra só cresce quando o autor a PRODUZ numa frase sua. E a leitura em voz alta como instrumento de revisão que não é IA.

**A função, como existe lá.** Toque longo em palavra abre dicionário, X-Ray, Wikipedia, tradução, busca no livro. Grifos, notas, marcadores; "My Notebook" reúne tudo. Assistive Reader: TTS do sistema com destaque em tempo real, velocidade, iniciar de uma palavra. Reading Ruler (cor, opacidade, estilo, tamanho). Temas salvos por nome, presets Compact/Standard/Large/Low Vision, OpenDyslexic. Reading Challenges com streaks. Word Wise (Android).

**Como entra no Traço.**
1. **Palavra encontrada vira forma.** O "Look Up" do menu de edição do iOS já é o dicionário do Kindle, offline, com pt-BR: nada a construir. O Traço acrescenta UMA ação ao menu: "Guardar palavra". Abre página nova com a definição do sistema (UIReferenceLibrary) em cartão fixo não-editável, nunca na nota, e a forma Palavra vazia: "A palavra · Numa frase minha". A nota entra na escada 3→7→21 como qualquer outra: o Recordar esconde e o autor tem de reescrever a frase, ou fazer outra. Muda §6 (forma nova, a sétima) e §19.2 Sistema. Funciona no texto do autor e no cartão de citação (Instapaper, item 1); o Kindle alimenta pelo compartilhar do grifo. Esforço M.
2. **Ler em voz alta.** Na nota aberta das Notas, uma ação (junto do glifo da lente do iA Writer) lê a nota com `AVSpeechSynthesizer` pt-BR e acende a palavra sendo lida (`willSpeakRange`, nativo). Nunca trancada, nunca durante a escrita. O autor ouve a própria frase torta. Esforço S.
3. **Índice de nomes (X-Ray local).** `NLTagger` com `.nameType` extrai pessoas, lugares e organizações das notas não-trancadas, em cache. Nas Notas, um nome vira filtro como o chip de gesto (§16): tocar "Marina" lista as notas onde ela aparece. E alimenta as perguntas LOCAIS do Padrões (§19.1 linha 4): "‘Marina’ aparece em seis notas — o que muda entre a primeira e a última?" Literal por construção. Esforço M.
4. **Régua de leitura.** Em notas longas abertas para ler: uma faixa que segue o dedo, guia de linha. É o critério de acessibilidade cognitiva do §17.4 numa tela. Esforço S.

**O poder que traz.** Vocabulário é poder de pensar (a tese do Vocabulary); e vocabulário se fixa por produção, não por reconhecimento: a definição lida evapora, a frase feita fica (efeito de geração, e o espaçamento faz o resto). Ouvir a própria prosa é o teste de revisão mais antigo que existe, e não precisa de modelo. O índice de nomes é metacognição em forma de índice de livro: quem se repete na sua vida, sem gráfico.

**A estrutura que traz.** `Gesto.palavra` com dois campos; no .md, nota comum com a forma. Cache de entidades por nota, refeito ao Concluída, excluído para trancadas. Nenhuma notificação nova: a Palavra usa a escada existente.

**O quanto eleva.** 4 — Linguagem abre pela via do vocabulário (a outra via é a lente do iA Writer), e Memória ganha um tipo de nota feito para ser cobrado.

**O que fica de fora — proposta histórica.** My Notebook: a pilha de palavras alheias para reler é o §3 negado; no Traço só existe o que o autor reescreveu. Reading Challenges, streaks, conquistas (§12). Sync de posição (§12). Word Wise: definição passiva sobre a palavra, reconhecimento sem produção, o oposto do item 1. Immersion Reading: Audible. DRM: o argumento do §10 já está no DOSSIE.

**O não-óbvio.** O Kindle põe o dicionário exatamente onde a palavra aparece e depois não faz nada com ela: o grifo fica preso, a palavra evapora. É captura sem multiplicação. O ciclo que falta é curto (encontrar, dizer numa frase minha, ser cobrado em 3, 7 e 21 dias) e cada peça já existe no Traço, menos a forma.


---

### Life Reset
`poderes: Intenção · Atenção` · `eleva: 1/5` · `esforço: S` · `quando: nunca`

**O que vale pegar.** Nada de mecanismo. O que vale é a régua negativa completa: Life Reset é o catálogo de tudo que troca o esforço do autor por consumo — programa gerado por questionário, carta motivacional, XP, penalidade. Serve para nomear o que o Traço recusa.

**A função, como existe lá.** "Life Reset: 66 Day Habit": onboarding por questionário gera avaliação pessoal e programa de hábitos; quests diárias com XP, níveis e streak; Hard Mode com "penalidades por dias perdidos"; cartas motivacionais colecionáveis (Confidence, Strength, Discipline, Wisdom, Focus); Focus Timer/Pomodoro como mini ferramenta; Screen Blocker; Book Summary; diário com voz e emoções; widget de quests e streak.

**Como entra no Traço.** Não entra. Duas tentações ficam registradas para não voltarem: (1) um timer no Destaque ("a única coisa de hoje, primeiro, até acabar") — o Destaque acaba quando a coisa acaba, não quando o relógio acaba; pôr relógio ali reabre a negociação que o §8 fechou. (2) Screen Blocker durante a expressiva — exigiria FamilyControls (entitlement sob aprovação da Apple, L) e o §8 já tem o atrito certo: sair tranca. Na SPEC: nada muda; o DOSSIE já o marca como contraexemplo do timer, e este bloco estende a régua negativa ao §5 (as cartas são a afirmação vazia industrializada) e ao §12.

**O poder que traz.** Nenhum. O mecanismo é o inverso: o programa gerado tira do autor o ato de planejar (efeito de geração zero); as cartas entregam a afirmação pronta que o aviso Wood do §5 recusa; XP e penalidade trocam motivo próprio por placar, e recompensa externa corrói interesse (Deci e Ryan). O Book Summary é a mesma troca no eixo da leitura: o resumo no lugar do livro.

**A estrutura que traz.** Nenhuma.

**O quanto eleva.** 1 — não há poder que o Traço passe a multiplicar; o ganho é saber, com nome, o que a barra do timer nunca vai ter.

**O que fica de fora — proposta histórica.** Tudo: XP, níveis, streak, Hard Mode, cartas, Book Summary (resumo, §12), AI Calorie Tracker, pedidos de amizade (compartilhamento, §12) e os quatro controles do timer — mais um minuto, pular, pausar, barra arrastável.

**O não-óbvio.** Life Reset é o Traço invertido no eixo da Intenção. Onde o WOOP obriga o autor a escrever o próprio obstáculo, o questionário escreve o programa por ele; onde o §5 recusa "eu sou um vencedor", o app vende a frase em carta colecionável. É a prova de que o atalho tem mercado de 1,5 milhão — e de que o Traço não compete com ele. Compete com o Apple Notes.


---

### MindScribber
`poderes: Sentido · Linguagem` · `eleva: 4/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O protocolo, não a sessão. A escrita expressiva com efeito medido é uma sequência de dias consecutivos de cerca de 15 minutos; o Traço hoje implementa o dia 1 e para. E a palavra exata para o sentimento como parte do método, não como jogo.

**A função, como existe lá.** "Exercícios de Expressive Writing (escrever cerca de 15 minutos por dia, 3 dias consecutivos)". "Orientação para inteligência emocional (rotular e comunicar emoções)" e os jogos "Emotion Game" e "Walls Down Game" (vocabulário emocional, rotulagem de emoções).

**Como entra no Traço.**
1. **Ciclo de três dias.** Quando a expressiva fecha (selar ou queimar), o algoritmo agenda duas notificações sem conteúdo: D+1 e D+2, na hora em que o autor começou a escrever. Texto: "Ontem você escreveu 15 minutos. Hoje é o segundo dia." Tocar abre uma expressiva NOVA — página nua, timer já armado, instrução única do §8.2. Nunca reabre a nota fechada: `Revisoes.podeAgendar` continua excluindo a expressiva do Recordar; isto é outra rota, com outro identificador. Se o autor não vem, silêncio: sem "dia perdido", sem contagem; a notificação do dia 3 ainda chega. Depois do dia 3, nada. Opt-out no Perfil (§18). Quem faz: algoritmo (UserNotifications, o mesmo padrão de `Revisoes`). Na SPEC: §8 ganha o item 9 — "a expressiva é um ciclo de três dias; o app cobra os dias 2 e 3 sem conteúdo e sem placar". O ADR 31l (só método comprovado) é o próprio argumento: o resultado publicado é do ciclo, não da noite única.
2. **A palavra do sentimento.** A instrução do §8.2 é "fato E sentimento". Léxico local fechado de palavras de emoção (pt/en, nosso, no bundle). Se aos 7 minutos o texto não tem nenhuma, a linha única sob o timer troca uma vez para "e o que você sentiu?" — texto do app, sem animação (§11), sem lista, sem chip. A Análise continua calada (§8.8); isto é o timer falando, não a IA. Na SPEC: §8.2.

**O poder que traz.** Sentido pelo mecanismo de Pennebaker: o ganho vem da construção de narrativa ao longo das sessões, e os estudos medem dias consecutivos, não um desabafo. No item 2, rotular o afeto com a palavra certa reduz a ativação (affect labeling, Lieberman 2007) — é Linguagem a serviço do Sentido, e a primeira vez que o poder Linguagem cabe no Traço sem virar dicionário.

**A estrutura que traz.** Nada no struct Nota. Um registro pequeno fora do schema, como o nível da escada: `cicloExpressivo {inicio: Date, dia: Int}` em UserDefaults. Duas notificações `expressiva-dia2-<uuid>` e `expressiva-dia3-<uuid>`, canceladas se o dia acontece antes. As notas dos dias 2 e 3 são notas normais de gesto expressiva; a lista pode mostrar "dia 2 de 3" como dado de arquivo (some no dia 4), nunca como sequência. Léxico: arquivo estático.

**O quanto eleva.** 4 — o Traço deixa de ter uma versão inventada (sessão única) do método que o ADR 31l exige comprovado; o mesmo timer, três vezes.

**O que fica de fora — proposta histórica.** Mood tracker e inventário TASI (placar, §12); 365 prompts (§3: nada ocupa o vazio); citações e vídeos relaxantes (consolo, §5); os jogos como jogo (§12); Firebase (regra 10); ditado por voz (o teclado do iOS já dita — nada a construir).

**O não-óbvio.** O app vende o método a quem tem trauma e o enterra em acessórios; mas a única função que ele leva a sério é justamente a que o Traço ainda não fez: contar os dias. E o léxico mostra que vocabulário não é só palavra difícil — a palavra exata para o que se sente é precisão, e precisão é poder de pensar.


---

### Mindsera
`poderes: Ordem · Metacognição · Intenção` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O catálogo de modelos mentais como catálogo de FORMAS. Cada framework é uma sequência fixa de perguntas — exatamente o que um gesto do Traço é: campos com rótulo, vazios. Entra como gesto roteado na pausa da escrita, nunca como prosa da IA, nunca como menu.

**A função, como existe lá.** "Templates de frameworks (52+): First Principles Thinking, Anti-Goals, Regret Minimization, Ikigai, Daily Review, Energy Audit, CBT, ansiedade, overthinking, gratidão, produtividade, decisão, resolução de problemas. Frameworks customizados." Também "Smart Highlights (marcar linhas; reunidas numa vista)" e "Copiar entrada como Markdown".

**Como entra no Traço.**
1. **Métodos como gestos.** `Gesto` cresce com casos novos — nome, reconhecimento, campos, heurística local. Primeiros cinco, escolhidos porque fecham em pergunta fixa e têm origem nomeada: *Decisão sem arrependimento* (Regret Minimization: "A decisão · Aos 80 anos, eu lamentaria · Então"); *Primeiros princípios* ("O que dou por certo · O que sei que é verdade · Refeito do zero"); *Anti-metas* (Anti-Goals: "O que eu não quero que aconteça · O que causa isso · O que evito, então"); *Auditoria de energia* (Energy Audit: "O que me deu energia · O que tirou · Uma troca"); *Revisão do dia* (Daily Review: "O que fiz · O que aprendi · Amanhã, primeiro"). Roteamento: a Análise devolve o rótulo (a lista fechada cresce; rótulo desconhecido = silêncio, §19.4); a heurística local roteia por verbo ("devo ou não", "em dúvida entre", "o que me cansou"). Campos nascem vazios (§6); um gesto por sessão (§4). Sem menu: a folha "Todas" (ADR 31b) ganha os nomes como atalho manual; o caminho é a pausa (§17). Os chips de filtro (§16) não podem virar onze: agrupar por família — Planos (WOOP, Se–então, Destaque), Decisões (os novos), Ideias, Especificações, Trancadas. Na SPEC: §6 (tabela cresce), §19.1 (lista do roteador), §16 (filtros por família).
2. **Marcar a linha.** Toque longo numa linha → "Marcar": a linha fica âmbar e o campo `sentido` — que hoje só a expressiva preenche — recebe a linha literal, copiada pelo algoritmo. O cartão em Notas mostra essa linha em vez da primeira; o filtro "Marcadas" lista só as linhas, uma por nota. Os Padrões locais começam pelas marcadas: o autor já disse o que importa. Selada não se abre, logo não se marca. Na SPEC: §8.5 generaliza — a linha de sentido passa a existir para toda nota; §9.
3. **Copiar como texto.** Ação na nota aberta: copia a nota em Markdown com cabeçalho (gesto e campos por rótulo). É a ponte mais curta entre o Traço e qualquer IA: colar. S. Na SPEC: §23 (Segundo cérebro, novo).

**O poder que traz.** Ordem — o caos de uma decisão entra em três campos. Metacognição — "aos 80, eu lamentaria" e "o que dou por certo" fazem o autor olhar o próprio pensamento. Intenção — cada modelo termina num "então". O mecanismo é o mesmo do §6: a pergunta certa estrutura; a resposta continua sendo geração do autor. Marcar é destilar até a frase que vale — Linguagem — sem que ninguém escreva.

**A estrutura que traz.** `Gesto` +5 casos (rawValue estável; `doNome` cobre o corpus antigo); `FiltroNotas` por família; `sentido` deixa de ser exclusivo da expressiva; heurísticas em `AnaliseLocal`; prompt remoto com a lista nova; um teste de silêncio por gesto; export com `sentido:` no cabeçalho.

**O quanto eleva.** 4 — o §17 promete "catálogo de métodos vasto" e o Traço tem seis; passa a cobrir decisão e revisão, que hoje caem em silêncio. Dois poderes de uma vez.

**O que fica de fora — proposta histórica.** Entry Analysis, Minds, Ask Your Journal, Story View, Memory Profile, Big Five, Plutchik, arte, resumos, sugestões (regra 1); tags por IA (§19.1 proíbe tag); habit tracker, streak, e-mail semanal (§12); rituais com prompts (§3); Call Mode (chat, §12); nuvem (regra 10).

**O não-óbvio.** Os 52 frameworks são todos listas de perguntas. A Mindsera os usa como prompt para a IA responder; lidos como formulário, eles são o Traço — e a prova de que o §6 escala sem uma linha de prosa do modelo. Segundo: a "Mind" Thinking Traps é uma lista fechada de distorções (Burns). Daria o primeiro Aviso (§5) sobre COMO o autor pensa, não sobre o que ele pede ao app — mas encosta em diagnóstico (§9.4). Fica registrado, não proposto.


---

### Mochi
`poderes: Memória · Intenção · Segundo cérebro` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A escada que aprende com o esquecimento — dois resultados bastam — e a percepção de que os rótulos das formas já são o cloze do Traço: o Recordar pode esconder a voz e deixar a estrutura.

**A função, como existe lá.** "Avaliação binária: Remembered/Forgot (sem 4 botões)"; agendador padrão que "multiplica intervalo por fatores fixos ao lembrar/esquecer"; "Cloze `{{texto}}` com grupos indexados; cloze digitável"; "Limite de cartões novos por dia" com fila "Add to reviews"; "Exportação Markdown (zip, um .md por cartão, subdecks viram pastas)".

**Como entra no Traço.**
1. **Esqueci · lembrei.** Depois do Revelar, sob a comparação, duas palavras discretas. "lembrei" sobe o degrau (3→7→21, como hoje); "esqueci" volta ao degrau 0; sem toque, sobe (comportamento atual — silêncio é resposta). Nada vira número; a comparação não muda. Algoritmo: `Revisoes.registrarCumprida(uuid, lembrou:)`. Na SPEC: §7 ganha o item 4; §19.2 Memória.
2. **Recordar com os rótulos.** Nota com forma: o Recordar esconde só a voz do autor (prosa e respostas) e deixa os rótulos — que são mobiliário, não conteúdo (§15/§16). Um campo por rótulo; Revelar compara campo a campo. Nota sem forma: recall livre, como hoje. A escada muda o modo: degraus 3 e 7 com rótulos, degrau 21 livre. Na SPEC: §7.1 ("o conteúdo some" — conteúdo é a voz).
3. **Nem toda nota entra na fila.** Hoje toda nota aberta agenda D+3. Regra: entra quem tem gesto de plano ou ideia (WOOP, Se–então, Especificação, Permanente, os novos da Mindsera) e nota nua com 40+ palavras; Destaque não (é de hoje). Na SPEC: §7, §19.2.

**O poder que traz.** O esquecimento vira dado: o intervalo encolhe onde a memória falhou, e é isso que separa espaçamento de calendário. Intenção: o plano Se–então é lembrado na estrutura em que vai disparar — ensaiar "se X, então eu Y" sob o rótulo é ensaio da implementação de intenção (Gollwitzer: o efeito vem do vínculo gatilho→resposta, e o vínculo se fortalece por repetição). Fila curta: cada cobrança vale.

**A estrutura que traz.** `revisaoNivel` ganha o retorno a 0; `registrarCumprida` com `lembrou`; `RecordarView` com modo "rótulos"; `podeAgendar` mais estreito; `recordada: N` no cabeçalho do export (já contado em `revisaoConta`).

**O quanto eleva.** 4 — Memória dá salto (a escada passa a descer) e Intenção ganha ensaio; dois poderes.

**O que fica de fora — proposta histórica.** Fabricar cartão a partir da nota (o segundo momento, bug do §17); FSRS por cartão (dificuldade e estabilidade são medidor — a escada de três degraus basta e é legível); cramming; dashboard de retenção (placar); sync (regra 10); campos de IA — TTS, tradução, gerador (regra 1); publicar deck (§12); texto oculto manual (o Recordar esconde tudo).

**O não-óbvio.** O Traço já tem cloze e não sabe: toda forma é um cloze em que os rótulos são a parte visível. E `recordada: N` no corpus diz às IAs do autor o que ele de fato retém, contra o que só escreveu — a IA que sabe o que o autor lembra fala com ele de outro jeito.


---

### monday.com
`poderes: Ordem · Segundo cérebro` · `eleva: 1/5` · `esforço: S` · `quando: nunca`

**O que vale pegar.** Nada da tela. Dois fatos do inventário valem como referência para outros blocos: o MCP (o quadro lido pelas IAs do usuário) e as "AI columns".

**A função, como existe lá.** Grade densa com adicionar coluna, adicionar grupo, novo item e busca rápida, tudo visível no telefone. Quadros, itens, subitens, grupos; vistas Table, Kanban, Gantt, Timeline, Calendar, Chart, Workload, Map, Files, Form. "My Work sincroniza com o calendário do iPhone." "MCP com Claude, ChatGPT, Copilot, Gemini e Perplexity." "AI columns." "Modo offline no celular: cerca de 70% das ações."

**Como entra no Traço.** Não entra. (1) A grade: régua negativa do construtor de tabela (FILA P1) — o do Traço nasce com zero controle visível e um só ponto de crescimento (ver Numbers). (2) My Work ↔ calendário: §12, agenda. (3) MCP: o padrão certo — a IA do usuário lê o dado do usuário — pela via errada para o Traço: servidor deles, conta, créditos (regra 10). A versão do Traço mora nos blocos Notion e Obsidian: pasta de .md e Atalhos, sem servidor. (4) "70% offline": contraexemplo do §19.2 — o Traço é 100% sem rede ou é bug.

**O poder que traz.** Nenhum para um autor. Para um time, monday descarrega o estado compartilhado da cabeça de todos; o Traço serve uma mente.

**A estrutura que traz.** Nenhuma.

**O quanto eleva.** 1 — o Traço não deixa de não ter nada.

**O que fica de fora — proposta histórica.** Tudo.

**O não-óbvio.** "AI columns": a coluna que a IA preenche. O Traço já tem uma — `gesto`, rótulo de lista fechada devolvido pela IA (§19.1, Rotear). A tentação seria uma segunda: domínio da vida (trabalho, casa, saúde, gente), que é a harmonia que o brief atribui ao TickTick e cabe no poder Ordem. Mas §19.1 proíbe à IA "gerar tag", e domínio não fecha em regra (§19.4). Se o dono quiser domínios, é ADR: ou emenda §19.1 para admitir domínio como rótulo fechado, ou o autor não tem domínios. Registrado, não proposto.


---

### Notion
`poderes: Segundo cérebro · Ordem · Arquivo` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A propriedade tipada. As formas do Traço já são registros com esquema — gesto mais campos com id estável — e o corpus exportado hoje os achata em prosa. Escrevê-los como propriedades faz cada nota virar dado que qualquer IA, base ou planilha lê sem adivinhar. E o corpus ganha a legenda que explica o próprio esquema.

**A função, como existe lá.** "Bancos de dados com 22 tipos de propriedade: Text, Number, Select, Status, Multi-select, Date, Formula, Relation, Rollup, ... Created time, Last edited time..."; "Exportação Markdown e CSV"; "Notion MCP"; "Limitar fontes com @"; "Skills (instruções customizadas)"; "Autofill de propriedades"; "Ações de Atalhos: criar página, buscar no Notion, adicionar texto a uma página, abrir um doc".

**Como entra no Traço.**
1. **Cabeçalho tipado.** `Corpus.arquivoMd` passa a escrever `gesto: woop` (rawValue estável) e cada campo pelo id: `resultado`, `obstaculo`, `plano` (WOOP); `se`, `entao`; `problema`, `pronto`, `nao`, `restricoes`, `limites`; `ideia`, `liga`, `fonte`; `unica`. Mais `criada`, `editada`, `sentido` (quando houver), `minutos` (expressiva), `recordada: N`. Os rótulos humanos deixam de ir — são mobiliário (§15/§16). Import lê os dois formatos (`Corpus.importar` e `separarCampos` ficam como fallback). Trancada: fora (ADR 31d). **Defeito achado no caminho:** `corpoDoCorpus` filtra por `fechada`, então a queimada sai inteira do export — e o §8.5 diz que o sentido "é a única coisa que sai daqui" e entra no export. Corrigir: a queimada vira uma entrada só de cabeçalho — `gesto: expressiva`, `queimada: true`, `minutos`, `sentido` — sem corpo. Algoritmo. Na SPEC: §10 (formato do arquivo); §8.5 vira critério de aceite do export.
2. **Legenda do corpus.** O arquivo começa com um bloco fixo do app — template determinístico, não prosa de modelo (§2): o que é cada gesto em uma linha, o que são os campos, o que é `sentido`, o que é `recordada`, e a frase "cada palavra aqui é do autor; nada foi escrito por IA". É a "Skill" do Notion invertida: em vez de instruir a IA deles, instrui qualquer IA que receba o arquivo. Na SPEC: §23, Segundo cérebro (novo).
3. **O corpus como fonte.** App Intent "Corpus do Traço" devolve o arquivo (`IntentFile`); o autor monta um Atalho "pergunte à minha IA com o meu corpus" com a ação de Atalhos do ChatGPT, Claude ou Grok que já tem no telefone. Sem servidor, sem conta nossa (regra 10). Na nota aberta, "Copiar como texto" (Mindsera). Na SPEC: §19.2 Sistema; §12 segue proibindo compartilhamento — isto é o autor levando o próprio arquivo, não o app publicando.

**O poder que traz.** Segundo cérebro: a IA que recebe `obstaculo: celular na cama` sabe o que é obstáculo sem inferir de prosa; recebe quarenta WOOPs e vê o padrão que o autor não vê. Ordem: dado tipado é a caixa única com gavetas. Arquivo: um .md com cabeçalho abre em Obsidian, importa no Notion, vira CSV no Numbers — o autor nunca fica preso.

**A estrutura que traz.** `Corpus.swift` escreve e lê cabeçalho por id; `Nota.sentido`, `minutosEscritos` e `Revisoes.contagem` entram no export; legenda em Strings (localizável); `CorpusIntent` em `Intencoes.swift`; teste de roundtrip — gesto E campos preservados, rótulo nunca vira voz.

**O quanto eleva.** 5 — abre o poder Segundo cérebro, hoje sem seção na SPEC: o corpus deixa de ser backup e vira contexto.

**O que fica de fora — proposta histórica.** Banco de dados dentro do app — Table, Board, Calendar, Gallery (§3: reler cartões é o anti-padrão; §12: agenda); Relation, Rollup, Formula (planilha); Autofill de propriedades pela IA (§19.1, tag); Notion AI, Agents, Research Mode (regra 1); nuvem obrigatória e histórico por plano (regra 10); a barra invertida (§17); publicação web e comentários (§12).

**O não-óbvio.** O banco do Notion vale não pelas vistas, e sim porque a propriedade É o esquema que um agente lê — o Notion MCP prova isso. O Traço ganhou a metade difícil de graça: a forma que nasce da palavra do autor já é um registro tipado — a IA roteou o tipo, o autor escreveu os valores. Falta só o formato. Segundo: um corpus que se explica vale mais que um corpus maior.


---

### Numbers
`poderes: Ordem · Segundo cérebro · Metacognição` · `eleva: 3/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A estrutura que cresce pelo contorno do objeto. E o Formulário↔Tabela: uma forma é uma linha; N formas são uma tabela.

**A função, como existe lá.** Tabelas: "redimensionar, mover, travar" — pela alça na borda (arrastar a alça cria coluna, sem menu). "Formulários (iPhone/iPad): cada linha vira um registro, cada coluna um campo; bidirecional com a tabela; campos adicionáveis, reordenáveis". Exportação CSV/TSV; importação CSV. Senha por planilha com Face ID. Magic Fill.

**Como entra no Traço.**
1. **Alça na borda** (FILA P1, "motor de formas sem fricção"). A tabela vestida, quando focada, mostra duas alças: borda direita (coluna) e borda inferior (linha). Toque cria uma; arrastar cria quantas couberem, com um háptico por célula. Apagar e mover: folha de verbos com glifo no toque longo na célula (Craft, REFERENCIAS §1). Zero controle visível fora do foco; nada de "adicionar coluna" em barra — monday é a régua negativa. Algoritmo, no `EditorBlocoView` (o trilho-fantasma já existe). Na SPEC: §19.2 Escrita — "tabela que cresce por toque" ganha a alça como especificação.
2. **Corpus por gesto em CSV.** No Perfil, ao lado de "Exportar todas as notas (.md)": "Exportar como tabela (.csv)" — um arquivo por gesto, uma linha por nota, uma coluna por campo (id), mais `criada` e `sentido`. Abre no Numbers; cola em qualquer IA como tabela. Trancadas fora. S. Na SPEC: §10, §23.

**O poder que traz.** Ordem — comparar é pôr lado a lado, e a tabela é a forma da comparação; a alça tira a última memória exigida (§17). O CSV é o Padrões feito a olho: doze obstáculos numa coluna, sem modelo — Metacognição por contraste visual.

**A estrutura que traz.** `EditorBlocoView` (alças, arrasto, verbos); `Corpus.exportarCSV(gesto:)`; nada no modelo.

**O quanto eleva.** 3 — a tabela deixa de ser grid cru (P1 aberto) e o autor sente no primeiro toque; o CSV é bônus de um dia.

**O que fica de fora — proposta histórica.** Magic Fill (IA escreve células, regra 1); fórmulas, tabelas dinâmicas e gráficos (placar, §12); controles em célula — estrelas e sliders (placar); categorias com resumo (resumo, §12); colaboração e Creator Studio.

**O não-óbvio.** O Formulário↔Tabela do Numbers enuncia a verdade escondida do Traço: a forma é a vista móvel de uma linha de tabela. Cada WOOP preenchido é uma linha numa tabela que o autor nunca vê — e a tabela dos próprios obstáculos é o único Padrões que o algoritmo consegue mostrar sem modelo. Se ela aparece no app (§3 diz que não há altar) ou só sai como CSV é ADR do dono; o export é o primeiro passo seguro.


---

### NYT Games
`poderes: Memória · Atenção · Metacognição · Linguagem` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** Uma unidade por dia e a coragem de acabar. Na segunda leitura: a dificuldade que sobe pela semana, e o formato de uma pergunta em que o jogador acha o padrão.

**A função, como existe lá.** "Puzzle diário por jogo"; tela final que agradece e manda voltar amanhã; "Crossword (dificuldade cresce ao longo da semana)"; "Connections (16 termos em 4 grupos)"; "Spelling Bee (7 letras, pontos por palavra)"; "Arquivo de mais de 10.000 puzzles antigos (assinantes)"; streaks, badges, leaderboard, Wordle Bot.

**Como entra no Traço.**
1. **Uma cobrança por dia, e acaba.** A escada agenda hoje uma notificação por nota; passa a existir uma fila: no máximo UMA notificação de Recordar por dia, a nota mais vencida primeiro; as outras esperam. Ao Revelar (e ao "esqueci · lembrei" do Mochi), a tela termina — "Por hoje é isso." — sem "próxima", sem lista, de volta à página nua. Algoritmo em `Revisoes`: fila em UserDefaults, identificador diário `revisao-<dia>`. Na SPEC: §7; §19.2 Memória.
2. **Dificuldade que sobe.** O eixo do Crossword (segunda→sábado) aplicado à escada: degraus 3 e 7 com rótulos, degrau 21 livre (Mochi, item 2). Mesma nota, mais difícil a cada vez.
3. **Ligações** (depois). Um terceiro tipo de pergunta nos Padrões: cartão fixo com seis a oito fragmentos literais das notas — verificados letra a letra, §19.4.3 — e a pergunta "o que liga estes?"; o autor responde na página vazia. Local: `PadroesLocal` já acha fragmento repetido e obstáculos; remoto: a IA devolve só a lista de fragmentos e o algoritmo verifica cada um. Na SPEC: §9.2.

**O poder que traz.** Escassez protege a Atenção — uma coisa por vez — e a cobrança única faz o esforço de recuperação valer: cinco Recordar no mesmo dia viram leitura, não recuperação. Acabar recusa o anti-padrão do §3. Ligações é Metacognição com Linguagem: nomear a categoria escondida entre as próprias frases é efeito de geração sobre os padrões — a IA não conclui, o autor conclui.

**A estrutura que traz.** Fila diária em `Revisoes`; tela de fim em `RecordarView`; tipo de pergunta `ligacoes` nos Padrões (cartão com lista de fragmentos).

**O quanto eleva.** 3 — Memória e Atenção ganham uma forma que o autor sente no terceiro dia; as Ligações são degrau a mais, depois.

**O que fica de fora — proposta histórica.** Streaks, badges, leaderboard, Wordle Bot (placar, §12); arquivo de 10.000 (catálogo infinito é o oposto do dia único); compartilhar pontuação (§12); fóruns de dica.

**O não-óbvio.** NYT Games é uma academia de Linguagem disfarçada de jogo: Spelling Bee é geração de vocabulário, Connections é categorização semântica, Crossword é recall por definição. O Traço não vai ter jogos — mas Connections mostra o formato de uma pergunta de Padrões em que o autor faz o trabalho de achar o padrão. E a lição maior: o Wordle original funcionava sem streak; o "recordada 3×" do cartão é arquivo do esforço, não sequência — nunca deixar virar "7 dias seguidos".


---

### Obsidian
`poderes: Segundo cérebro · Arquivo · Captura · Memória` · `eleva: 5/5` · `esforço: L` · `quando: agora`

**O que vale pegar.** A pasta de .md como verdade e como interface universal: uma pasta é o único formato de contexto que TODAS as IAs do autor leem — Claude Code, Cursor, upload no ChatGPT/Claude/Grok, o próprio Obsidian. E a captura em segundo plano.

**A função, como existe lá.** "Local-first: arquivos Markdown na pasta do dispositivo; iCloud vaults no iOS." "Propriedades em YAML." "Links internos, backlinks." "Bases: vistas de banco de dados sobre as propriedades das notas." Atalhos "Capture to Daily Note, Capture to Bookmark — capturas rodam em segundo plano". "Obsidian URI: new, daily, com parâmetros content, append, prepend, silent." "Folha de compartilhamento iOS 18+." "Require Face ID" (widgets indisponíveis com ele). "File recovery (snapshots regulares)." "Nota única com título por timestamp." "Contagem de palavras."

**Como entra no Traço.**
1. **Uma pasta, um .md por nota.** Hoje: um arquivo `traco-corpus.md` em Documents. Passa a: pasta `Traço/` em Documents (visível no Arquivos), um arquivo por nota aberta, nome `AAAA-MM-DD HHmm — <título>.md` (título = `VozDoAutor.titulo`, truncado; índice uuid→nome para renomear sem duplicar), cabeçalho tipado (bloco Notion), regravado a cada save (`Sessao.irPara` já grava). Trancada: não existe arquivo. Queimada: arquivo só de cabeçalho. Apagar nota apaga o arquivo. Fatia 1 = Documents, sem ADR, S. Fatia 2 = container iCloud Documents (`NSUbiquitousContainers`): a pasta aparece no Mac do autor, onde Claude Code e Cursor a leem como pasta de projeto. Pede ADR contra §12 ("sync/nuvem") e §10 ("sem nuvem na v1"), dentro da regra 10: iCloud é da Apple, conta que o autor já tem, opcional — sem iCloud, fica local. A regra 2 vale por construção: trancada nunca é escrita, logo nunca sobe.
2. **Ligações entre notas.** O campo "Liga a" da Nota permanente: enquanto o autor digita, o algoritmo busca títulos (o motor da busca §16, sem acento) e oferece uma completação discreta; um toque vira ligação, mostrada como chip com o título — nunca `[[ ]]` na tela (ADR 31i). No arquivo: `liga: "[[2026-08-30 — título]]"`, wikilink que o Obsidian resolve e que uma IA lê como aresta. Trancada não aparece na busca de títulos (§16). A nota ligada mostra "ligada por" no rodapé (backlink, algoritmo). M. Na SPEC: §6 (Nota permanente), §16.
3. **Capturar sem abrir.** `CapturarIntent(texto)` cria a nota em segundo plano (`openAppWhenRun = false`); `traco://nova?content=` faz o mesmo; folha de compartilhamento (extensão, FILA aberto) leva o trecho selecionado e a URL — se a auto-forma vestir Permanente, a URL cai em `fonte`. Sem nota diária: a unidade do Traço é o traço, não o dia. S/M. Na SPEC: §19.2 Sistema; FILA "app fora do app".

**O poder que traz.** Segundo cérebro — contexto perfeito não é um chat com o corpus; é o corpus na pasta onde a IA já trabalha. Arquivo — décadas: um .md por nota sobrevive ao app, ao SwiftData e à Apple. Captura — o traço não se perde entre o pensamento e o app. Memória — ligar uma ideia nova a uma antiga é codificação elaborativa (a memória guarda o que se conecta); o "Liga a" hoje é texto solto, e virar ligação obriga o autor a achar a nota antiga — achar é recuperação.

**A estrutura que traz.** `Corpus` vira escritor de pasta (URL por nota); cabeçalho tipado; `liga` guarda uuids no `camposJSON` (string livre continua válida — compat); `CapturarIntent` em `Intencoes.swift`; extensão de compartilhamento com app group para o container — a única exceção ao "sem app group" que o `Intencoes.swift` comemora; `NSUbiquitousContainers` (ADR).

**O quanto eleva.** 5 — abre Segundo cérebro (a pasta é o contexto) e sela Arquivo (a nota vira arquivo, não linha de banco).

**O que fica de fora — proposta histórica.** Markdown cru na tela (ADR 31i); plugins e configuração (§17: o Traço monta os eixos, o autor não); o grafo como tela (belíssimo, inútil sem ligação); Canvas, Slides, web viewer; Sync e Publish pagos (regra 10 — iCloud é a única nuvem, e é do autor); Web Clipper com Interpreter (IA escreve, regra 1); nota diária (§3); "Require Face ID" no app inteiro — mata os widgets, como o próprio Obsidian admite; o selo do Traço é por nota, e o U4 continua vivo.

**O não-óbvio.** O grafo do Obsidian é inútil porque as arestas são manuais. O Traço tem um algoritmo que já acha fragmentos literais repetidos entre notas (`PadroesLocal.fragmentoRepetido`): as arestas existem como subproduto. Se elas vão para o arquivo (`relacionadas:`) é ADR — é algoritmo, não IA, mas é o app decidindo sentido; por ora ficam nos Padrões. O mais fundo: uma pasta do Obsidian é contexto ruim para uma IA porque é prosa que o usuário estruturou à mão ao longo de meses. A pasta do Traço é estruturada pela forma que a IA roteou e o autor preencheu — legível na nota um.


---

### One Sec
`poderes: Atenção · Captura · Intenção` · `eleva: 3/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** O instante entre o impulso e o ato é um lugar — e dá para pôr uma página nele. O One Sec vende só isso: uma pausa onde o dedo já ia sozinho.

**A função, como existe lá.** A intervenção "Journaling", que pede 25 palavras antes de abrir rede social de manhã ou à noite. As "Intenções personalizadas" (o autor declara por que está abrindo o app; histórico por app). A "Re-Intervention", que expulsa depois de X minutos e cobra intervenção nova. O modo "Delayed". Tudo montado sobre automação do app Atalhos ("Initial one sec Shortcuts Setup") e a API de Tempo de Uso, com integrações em que outro app entra na intervenção (Structured; LENGO — aprender vocabulário desbloqueia a rede).

**Como entra no Traço.**
1. **O traço antes da fuga (S).** O Traço já expõe `NovaNotaIntent` e `traco://nova`. Falta empacotar: um atalho pronto (o Raycast entrega "atalhos pré-empacotados"), instalável do Perfil, que o autor liga a uma automação pessoal do iOS "ao abrir [app]": a página nua abre antes do app que ele ia abrir. Quem faz: o sistema (automação de Atalhos) + o intent que já existe. O autor vê a página em branco, escreve ou não, e o iOS segue para o app. Nada de contagem de palavras, nada de bloqueio: o Traço não é porteiro de app, é uma folha no caminho. SPEC: §19.2 "Sistema" ganha "atalho pré-empacotado"; §12 não muda (não é agenda nem bloqueio).
2. **O Se–então que chega no gatilho (M).** A forma Se–então tem o campo "Se (hora/lugar/obstáculo)". Quando o autor escreve hora ("às 7h", "de manhã"), o algoritmo — não a IA — lê a hora como o TickTick lê "amanhã 9h" e agenda uma notificação sem conteúdo ("Seu se–então de hoje"), que abre a nota. É a intervenção do One Sec aplicada ao plano do próprio autor: o método funciona quando o "se" encontra o "então" na hora certa, e hoje a nota fica no arquivo, longe do gatilho. SPEC: §6 (Se–então ganha gatilho de hora), §19.2 "Memória" ganha "notificação de gatilho"; toca o §12 "agenda" — pede ADR de três linhas: não é calendário, é o gatilho de UMA nota, sem conteúdo.

**O poder que traz.** Atenção e Captura no item 1: o impulso de abrir a rede é quase sempre fuga de um pensamento; a página no caminho pega o pensamento antes que ele evapore, e a pausa por si só devolve a decisão ao autor (o One Sec mostra que a pausa reduz a abertura automática sem proibir nada). Intenção no item 2: implementação de intenção (Gollwitzer) depende de o plano "se X, então Y" ser evocado no momento X; ligar a nota ao momento é o que separa o método de uma frase bonita.

**A estrutura que traz.** Item 1: um arquivo .shortcut no bundle + link no Perfil; nada muda na `Nota`. Item 2: `Nota` ganha `gatilhoEm: Date?` derivado do campo "Se" (recalculado ao editar); notificação `gatilho-<uuid>` ao lado de `revisao-<uuid>`, mesma regra do selo (sem conteúdo; trancada e expressiva jamais agendam); o .md exporta `gatilho:` no cabeçalho.

**O quanto eleva.** 3 — fortalece Atenção, Captura e Intenção que já existem, e o autor sente no primeiro dia em que a página aparece antes do Instagram; não abre poder novo.

**O que fica de fora — proposta histórica.** O placar de "tempo economizado", estatísticas e comparações de progresso (regra 5). O rastreamento de emoções. O bloqueio em si e a expulsão do app: o Traço não vigia nem castiga — a Re-Intervention viraria atrito do lado errado (regra 6). A dependência de automação frágil fica do lado do iOS, não no código do Traço: se a automação quebrar, o app continua inteiro (§19.3).

**O não-óbvio.** O One Sec não é app de tempo de tela. É o único app da lista cujo produto é o instante ANTES de outro app — e esse instante é onde o pensamento que ia para a fuga pode virar traço. O Traço já tem a porta (`traco://nova`); o One Sec ensina que a porta rende mais no corredor da fuga do que na tela inicial. E o mecanismo dele é o inverso do Se–então: ele interpõe uma pausa no gatilho para desfazer um hábito; o Traço pode interpor a nota no gatilho para instalar um.


---

### Otter.ai
`poderes: Memória · Captura · Intenção` · `eleva: 3/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A gravação como gabarito, não como nota. O Otter guarda tudo o que foi dito para que ninguém precise lembrar; o Traço pode guardar o mesmo áudio para cobrar que o autor lembre — e só então deixar ouvir.

**A função, como existe lá.** "Gravar com um toque", "widget de tela inicial para gravar" e "Siri Shortcut para iniciar/parar gravação". Na reprodução, "palavra destacada acompanhando o áudio" e "tocar em qualquer palavra para saltar o áudio". No pós-reunião, o resumo com "decisões, itens de ação e insights", os "Takeaways" e o "destacar frases com um toque" durante a transcrição.

**Como entra no Traço.**
1. **Recordar sobre áudio (M).** O Caderno já anexa áudio (`traco://audio/<id>`). Hoje o Recordar esconde texto. Estende-se: numa nota com áudio, o Recordar esconde o áudio também; o autor escreve de memória o que foi dito; Revelar põe a memória ao lado do player. Quem faz: algoritmo (§19.2 "Memória"); nenhuma transcrição, nenhuma IA. O autor vê a mesma cerimônia do §7, com o player onde estaria a nota. SPEC: §7 ganha uma linha ("nota com áudio: o áudio se esconde junto e volta no Revelar").
2. **A forma "Conversa" (S).** Os campos que o Otter preenche por IA — o que ficou decidido, o que cabe a mim, o próximo passo — viram uma forma do catálogo do §17, com campos VAZIOS: "O que ficou combinado · O que cabe a mim · Próximo passo · O que eu não disse". Roteada pelo texto ("reunião com…", "falei com…"), como as outras; a IA só devolve o rótulo. Quem faz: template nosso; roteamento local primeiro, IA de reserva. SPEC: §6 ganha a forma; §17 já autoriza catálogo sem teto.
3. **Gravar de fora (S).** `traco://gravar` como destino em `Rota`, para Atalhos e botão de Ação — não para o widget (o widget fica com duas intenções, decisão da casa). A gravação nasce como nota com o anexo e a página nua abaixo.

**O poder que traz.** Memória por recuperação ativa sobre o que se viveu: escrever de memória o que foi dito, e só depois ouvir, é o testing effect aplicado a uma conversa — e a comparação com o áudio é o feedback mais honesto que existe, sem nota, sem IA. Intenção em "Próximo passo" e "O que cabe a mim": o compromisso escrito à mão logo depois da conversa é o que o resumo automático rouba de quem só o lê. Captura no item 3.

**A estrutura que traz.** Item 1: `RecordarView` aceita `Nota` com anexos de áudio; o parser já lista os anexos; nada muda no schema. Item 2: um `Gesto` novo (`conversa`) com quatro campos, rawValue estável, export "— Conversa —". Item 3: `Rota.Destino.gravar`, App Intent "Gravar no Traço".

**O quanto eleva.** 3 — o Recordar já existe; o áudio lhe dá um gabarito que o texto não tem (a memória confere contra o que foi dito, não contra o que foi escrito), e a forma Conversa põe um gesto novo no catálogo. Sente-se na primeira reunião.

**O que fica de fora — proposta histórica.** A transcrição, o resumo, os itens de ação por IA, o chat sobre a reunião, o Notetaker que entra nas chamadas, o vocabulário personalizado e a nuvem que treina "on de-identified audio recordings and on transcriptions". Tudo isso é a IA fazendo o gesto pelo autor (§2), e o áudio de terceiros no servidor de alguém é o oposto do selo. Transcrever a PRÓPRIA voz do autor é outra pergunta — está no bloco do Reflection, como ADR.

**O não-óbvio.** O Otter não é o polo invertido só por resumir. Ele mostra qual conteúdo é o mais perecível da vida do autor — o que foi dito numa conversa — e resolve a perecibilidade guardando. O Traço resolve a mesma perecibilidade cobrando: a conversa é o melhor material de Recordar que existe, porque o gabarito está gravado e ninguém precisa reler cartão à noite para conferir. O que o Otter chama de Takeaways, o Traço chama de campos vazios.


---

### Paper (FiftyThree)
`poderes: Ordem · Atenção · Memória` · `eleva: 3/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Vestir um traço torto sem tocar no traço. O Paper reconhece a forma que a mão quis e a entrega limpa — na pausa do gesto, de uma lista fechada de formas. É o §17 em outro meio, e existia antes do §17.

**A função, como existe lá.** "Diagram (Pro: formas inteligentes, reconhece triângulos/quadrados/círculos, preencher, mesclar, setas ao parar no fim do traço)" — vendido como "Paper Essentials" até 2015, e mantido para os usuários Legacy. "Undo/Rewind (botões, toque duplo com dois dedos)". "Notas de texto por página (meia folha ou quadrado no canto)" e "agrupar nota de texto a um desenho". "Clean Canvas Mode (esconde botões)". A folha com peso, que o mandato de 01/set já tomou como alvo.

**Como entra no Traço.**
1. **Bloco de desenho no Caderno (M).** Um portal vestido, como código e tabela (ADR 31i): o autor toca "Desenho" na régua e desenha com o dedo numa área do Caderno; PencilKit é nativo — nada de motor próprio. O desenho persiste como anexo, `![desenho](traco://desenho/<id>)`, igual às fotos. Quem faz: sistema.
2. **Vestir o traço (M).** Sobre o desenho, um reconhecedor determinístico de formas — lista fechada: linha, seta, círculo, retângulo, triângulo; um reconhecedor unistroke clássico cabe em poucas centenas de linhas e é testável — veste a forma limpa quando o dedo PARA no fim do traço, exatamente como o Paper. Soltar forma desfaz, como no texto. Silêncio na dúvida. Quem faz: algoritmo (§19.4 — fecha em regra, então é regra). SPEC: §17 ganha "auto-forma vale para o desenho: lista fechada, na pausa do traço, um toque desfaz".
3. **Desfazer por gesto (S).** Toque duplo com dois dedos desfaz, sem botão. Serve ao texto também: hoje Soltar forma e apagar-com-desfazer têm alvo; um gesto de sistema cobre sem chrome (regra 6).

**O poder que traz.** Ordem: um esquema com setas e caixas é o pensamento posto no espaço — relações que a prosa esconde ficam visíveis. Memória: código dual (Paivio) — o que se escreve E se desenha lembra-se melhor, e o Recordar ganha um gabarito de segunda modalidade. Atenção: o traço torto vestido na pausa tira da mão a preocupação de "ficar bonito", que o §17 chama de fricção; o Paper provou que o autor aceita a forma vestida quando ela vem de lista pequena e chega no instante certo.

**A estrutura que traz.** Bloco `desenho` no parser do Caderno (anexo com o mesmo ciclo de vida da imagem: apagar varre, queimar sobrescreve); chip na régua ou entrada em "Todas"; reconhecedor de formas em módulo próprio, sem rede; `PKDrawing` serializado no anexo para reeditar, PNG para o export. Nada muda no schema da `Nota`.

**O quanto eleva.** 3 — o Traço hoje só multiplica Ordem por forma de texto; o desenho com vestir dá ao autor uma segunda linguagem de organizar, e o efeito se sente no primeiro esquema. Não abre poder novo. A folha com massa (mandato de 01/set) é polimento (2) e já está na FILA — não é item deste bloco.

**O que fica de fora — proposta histórica.** O skeuomorfismo do papel com grão e da tinta molhada (o dossiê já decidiu: física sim, textura não). Journals com capa, loja de cadernos com prompts, colagem, pincéis — o Traço tem uma página. Aquarela, mixer de cor, paletas: o desenho aqui é esquema, não arte.

**O não-óbvio.** A VIZINHANCA diz que o auto-forma do §17 "não tem precedente comercial". Tem — no desenho. O Diagram do Paper é vestir-sem-tocar de uma década atrás, e ensina duas regras que valem para o texto: a lista de formas reconhecidas é pequena e fechada (rótulo, não prosa — §19.4), e o gatilho é a PAUSA do gesto, nunca o meio dele (§11: nada anima enquanto o autor digita). O Paper é a prova de que vestir na pausa parece mágica e vestir no meio parece autocorretor.


---

### Raycast (iOS)
`poderes: Segundo cérebro · Captura` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O corpus do autor chegando a qualquer campo de texto do iPhone — inclusive o campo do Claude e do ChatGPT — sem servidor, por ordem do autor, uma nota por vez. O Raycast fez do teclado e das superfícies do sistema o caminho de ENTRADA; o Traço faz delas o caminho de SAÍDA.

**A função, como existe lá.** O "teclado customizado (Full Access) com ditado, AI Commands sobre o texto do campo, Snippets, Quicklinks, símbolos e tile de recentes". As "ações de Atalhos (Ask AI, AI Commands, Open Voice, abrir nota específica) também localizáveis no Spotlight" e os "atalhos pré-empacotados". "Controles do iOS 18 na Central de Controle e tela bloqueada (… Create Note)". "Botão de Ação". "Extensão de compartilhamento". "Servidores MCP via HTTP" com "@menção do servidor no chat". "Cloud Sync" criptografado.

**Como entra no Traço.**
1. **O canal (ADR nova: seção "Segundo cérebro" na SPEC).** Regras, antes de qualquer código: (a) só sai a voz do autor e os rótulos nossos (gesto, data, linha de sentido, "recordada n×"); (b) fechadas — trancada e queimada — e expressivas jamais saem, por nenhuma rota, como no §19.1; (c) sai só por ordem do autor, num toque, nunca em segundo plano; (d) o canal tem UMA direção, do Traço para fora — a IA de fora nunca escreve no Traço (a única exceção possível é uma pergunta: bloco do Reflection); (e) sem servidor nosso, sem conta nossa: o que viaja, viaja pelo aparelho do autor ou pelo iCloud Drive do autor. Toca o §12 ("sync/nuvem", "compartilhamento") — a ADR redefine: não é sync nem compartilhamento; é o autor entregando o próprio arquivo a si mesmo em outro app.
2. **Intent "Nota do Traço" (S, primeiro).** App Intent que devolve o texto de uma nota (busca por título ou trecho, sem fechadas) e outro que devolve o corpus inteiro como arquivo. Com isso Atalhos, Spotlight e botão de Ação viram canal de graça (o código já diz: "Atalhos, Siri e Action Button chegam de graça com App Intents"). Atalho pré-empacotado "Contexto do Traço": no botão de Ação, dentro do app do Claude, o autor escolhe a nota e ela vai para a área de transferência; ele cola. Dois toques, zero Full Access.
3. **Teclado do Traço (M, o canal premium).** Extensão de teclado com uma tecla: abre a busca das notas (voz do autor, sem fechadas) e insere a nota escolhida no campo onde o cursor está — o composer do Claude, do ChatGPT, do Mail. É o Snippet do Raycast com o corpus do autor como snippet. Exige Full Access (o do Raycast também); o aviso do iOS é honesto porque o teclado não tem rede — dizer isso no Perfil, uma linha. Regra 6: um toque no globo, um na tecla, um na nota.
4. **O arquivo no iCloud Drive do autor (S, ADR).** `traco-corpus.md` já é gravado no Documents a cada salvar. Gravá-lo também no container iCloud do app faz o Claude Desktop e o Claude Code no Mac lerem o corpus do disco — sem MCP, sem servidor. O que vai no arquivo e como ele se explica está no bloco do Readwise.
5. **Superfícies de captura (S).** Controle na Central de Controle e na tela bloqueada, botão de Ação e extensão de compartilhamento, todos convergindo em `Rota` (que já existe). Extensão de compartilhamento: texto ou link de outro app entra como o traço do autor na página nua; se a Análise rotear Nota permanente, o link entra em "Fonte" — dado do sistema, não prosa do modelo; o §2 "campos nascem vazios" precisa de uma linha dizendo que o campo nasce vazio DA IA, não do ato do autor de compartilhar.

**O poder que traz.** Segundo cérebro: o valor de um modelo é limitado pelo contexto que recebe; o corpus do Traço é o melhor contexto que existe sobre o autor — nas palavras dele, com o gesto que cada nota carrega (o que quis, o que o trava, o que está construindo, o que aprendeu). Entregue à IA no momento da pergunta, ele multiplica a IA e, por ela, tudo o que o autor faz com IA. Captura: cada superfície do iOS que o Raycast usa é um instante em que o traço não se perde.

**A estrutura que traz.** App Group entre app, widget e teclado (hoje nada usa app group; o teclado exige o banco compartilhado ou um espelho .md no container comum); `Rota.Destino` ganha `.gravar` e `.compartilhado`; `Corpus` ganha `arquivoDaNota(_:)` para o intent e a gravação no container iCloud; alvos novos de extensão de teclado e de compartilhamento; ControlWidget no alvo do widget. Nenhum campo novo na `Nota`.

**O quanto eleva.** 5 — abre o poder que o Traço hoje não multiplica: o corpus como contexto perfeito para as IAs do autor, dentro das regras 1, 2 e 10. É a direção nova do dono, e o Raycast é o mapa técnico de como um app de iPhone chega a todo campo de texto do sistema.

**O que fica de fora — proposta histórica.** O AI Chat com dezenas de modelos, os AI Commands que reescrevem texto selecionado ("Fix Spelling", "Change Tone"), o ditado com pós-processamento por IA (estilos "Email", "Notes") — §2 e §19.1. O Cloud Sync com servidor deles (§12). O papel de cliente MCP: o Traço não conversa com servidores; entrega arquivo. E um servidor MCP no próprio iPhone: possível por HTTP na rede local, mas morre em segundo plano e vira superfície de exposição — a regra 2 não sobrevive a um processo que responde sozinho.

**O não-óbvio.** O teclado do Raycast é lido como recurso de produtividade. Visto pela pergunta certa, é o único lugar do iOS onde um app fala dentro de OUTRO app sem que ninguém tenha combinado nada — nem a Apple, nem a Anthropic, nem a OpenAI. Para um app sem servidor, que se recusa a ter conta própria, o teclado é o MCP do soberano: o contexto vai onde o autor manda, e só quando ele manda. E há um segundo não-óbvio: o Raycast prova, com as Notes que "viraram o conteúdo que a base mais cria", que a nota nascida de uma superfície do sistema é a que mais se escreve — captura não é conveniência, é volume de corpus, e volume de corpus é qualidade de contexto.


---

### Readwise
`poderes: Segundo cérebro · Memória · Linguagem` · `eleva: 4/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O arquivo que vai até a pessoa — e, no Traço, o arquivo que vai até as IAs da pessoa levando junto a regra de como lê-lo. E a curadoria: o Readwise deixa o autor decidir o que merece continuar voltando.

**A função, como existe lá.** "Servidor MCP (Claude, ChatGPT, Cursor) e CLI (Claude Code, Codex) com fluxos prontos (triagem de inbox, resumo semanal, quiz)". "Exportação Readwise: Markdown, CSV, Notion, Evernote, Obsidian, Roam, Logseq" e a "API pública com token". Na revisão: "Keep, Discard, Master", "frequência por documento ajustável", "Mastery (repetição espaçada por meia-vida de recall: 7, 14 e 28 dias; ressurge ao cair a 50%)", a Daily Review como uma sessão por dia. No Reader, "definição de palavras e termos no sentido do autor (Lookup por toque longo)".

**Como entra no Traço.**
1. **O contrato de leitura viaja com o corpus (S).** `traco-corpus.md` hoje abre em `---\ncriada:\ngesto:\n---`. Passa a abrir com um cabeçalho fixo, mobiliário nosso, que diz a qualquer IA o que está lendo e como tratar: "Estas são notas do autor, nas palavras dele. `gesto:` é o método que a nota carrega (WOOP = desejo · obstáculo · plano; Se–então = gatilho · resposta; …). `sentido:` é a frase que o autor escreveu ao fechar um desabafo — o desabafo não está aqui e não deve ser pedido. Não reescreva, não resuma, não elogie; cite as palavras dele; quando puder, devolva uma pergunta." É o "fluxo pronto" do Readwise, só que embutido no arquivo: a regra de ferro do §2 passa a valer dentro do Claude e do ChatGPT. Quem faz: template determinístico; o autor não escreve nada. SPEC: seção nova "Segundo cérebro" (ADR do bloco Raycast); §10 ganha o formato do cabeçalho.
2. **O cabeçalho por nota fica completo (S).** Acrescentar `sentido:`, `minutos:` e `recordada:` ao front matter de cada nota. Hoje `Corpus.arquivoMd` não escreve a linha de sentido, e as fechadas ficam de fora inteiras — com a linha junto; o §8.5 diz que ela "entra no export". Consertar: a fechada sai como bloco só de cabeçalho (`criada`, `gesto: Expressiva`, `minutos`, `sentido`), sem corpo. É o §8 cumprido, e é o que faz o corpus contar o que o autor aprendeu sem contar o que doeu.
3. **Curar a escada (S).** No cartão da nota e ao fim do Revelar, um toque "Não cobrar mais" (Discard) e um "Sei de cor" (Master): ambos tiram a nota da escada 3→7→21. Sem isso, cada nota concluída agenda revisão, e quem escreve todo dia recebe cobrança de tudo — e para de atender. Regra 5: não é placar, é o autor escolhendo o que merece a própria memória. E uma cobrança por dia, no máximo (a Daily Review é UMA sessão): o agendador junta notas do mesmo dia numa notificação. Quem faz: algoritmo (`Revisoes`).
4. **Concordância por toque longo (S).** Toque longo numa palavra da nota → "onde mais eu a usei": trechos do corpus com aquela palavra (a busca já existe, sem acento). É o "Lookup no sentido do autor" feito em regra: o sentido do autor é o uso do autor. Definição de dicionário fica com o "Consultar" nativo do iOS — nada a construir.

**O poder que traz.** Segundo cérebro: contexto sem contrato vira matéria-prima para a IA escrever pelo autor; com contrato, a IA de fora se comporta como a de dentro — cobra, cita, pergunta. Memória: espaçamento só funciona com carga suportável; a curadoria e o teto diário são o que mantém o autor voltando ao Recordar (o Readwise mediu isso: a base "realmente lê" porque é uma sessão, com filtro de qualidade). Linguagem: ver a própria palavra em dez contextos é o caminho mais curto para a precisão lexical — o autor descobre que usa "clareza" para três coisas diferentes.

**A estrutura que traz.** `Corpus`: cabeçalho fixo + `sentido:`/`minutos:`/`recordada:` por nota + bloco sem corpo para fechadas; `Revisoes`: estados `descartada`/`dominada` (UserDefaults como hoje, ou campo `revisao: String?` na `Nota` quando migrar) e agrupamento por dia; `RecordarView` e cartão das Notas ganham os dois toques; toque longo na `PaginaView` chama a busca.

**O quanto eleva.** 4 — salto grande no Segundo cérebro (o corpus deixa de ser dado e vira contexto com lei) e dois outros poderes de carona, cada um em dias.

**O que fica de fora — proposta histórica.** O e-mail diário (regra 10: sem servidor); o destaque aleatório no widget e a releitura passiva em geral (§3: reler cartões é o anti-padrão); streak e tela de conclusão (§12); o Ghostreader que resume, simplifica e redige; busca semântica e "Find Similar Highlights" (§16); o OCR de livro físico — a foto anexada já tem Live Text nativo, e a palavra de outro entra em "Fonte", não como voz do autor.

**O não-óbvio.** O Readwise se vende como memória e é, na verdade, um canal: leva o arquivo até onde a pessoa está (e-mail, Kindle, Obsidian, Claude Code). Para o Traço, a lição não é a revisão — é que o arquivo precisa de um formato que EXPLIQUE a si mesmo para valer como contexto. Um .md com `gesto:` e `sentido:` é dado; o mesmo .md com o contrato no topo é um segundo cérebro que ensina a IA a não ser o primeiro. E a inversão: o fluxo "quiz" do Readwise é a IA de fora cobrando memória — o Traço pode entregar o corpus e pedir exatamente isso, sem que nenhuma palavra volte para dentro.


---

### Reflection
`poderes: Segundo cérebro · Sentido · Captura` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A pergunta como a única coisa que uma IA de fora pode mandar para dentro. O Reflection abriu o diário para o Claude ler E escrever; o Traço abre para ler, e recebe de volta só o que o §9 já sabe verificar: uma pergunta citando o autor.

**A função, como existe lá.** "MCP com leitura e escrita" e "chaves MCP (Premium, acesso de leitura/escrita) em Settings › MCP Key Management". "AI Coach com perguntas de acompanhamento em tempo real". "Foto de página manuscrita convertida em entrada digitada e pesquisável" e "voz para texto". "Iniciar entrada pelo Spotlight do iOS", "compartilhar texto para o app", "quick action de Busca no ícone". "Insights: … domínios de vida".

**Como entra no Traço.**
1. **A pergunta que entra (M, ADR).** Uma rota `traco://pergunta?q=…`. Quando o autor está no Claude com o corpus como contexto e o modelo devolve uma pergunta, ele a toca (link) e ela abre no Traço como cartão fixo não-editável sobre a página vazia — o mecanismo do §9, item 3, sem mudar uma linha da regra. A prova do §19.4 vale igual e é dura: tem "?", e todo trecho entre aspas existe LITERALMENTE nas notas abertas; falhou, a rota cala. Quem faz: algoritmo (verificação); a IA de fora só propõe. O autor vê o cartão e responde na página nua. SPEC: §9 ganha "pergunta de fora"; a seção "Segundo cérebro" ganha a direção de volta, com o único tipo permitido.
2. **A voz e a mão do autor (ADR sobre §2/§19.1).** Ditado e foto de manuscrito são as palavras do AUTOR chegando à página por outra via. O §19.1 proíbe "qualquer texto que entre na nota" — escrito para a prosa do modelo, não para a transcrição do que o autor disse. ADR proposta: transcrever é VESTIR (§17) — o texto é do autor, o app só o muda de meio; vale só com motor no aparelho (Speech e Vision, sem rede), nunca com pós-processamento ("estilo", "correção"), e nunca em expressiva (a expressiva se escreve). Se o dono recusar, o áudio continua anexo e o Recordar sobre áudio (bloco Otter) faz o resto.
3. **Entrar pelo Spotlight (S).** O Traço já indexa notas abertas (Holofote). Falta a AÇÃO no Spotlight: "Nova nota" e "Recordar" como resultados, via os App Intents que já existem. Um passo, sem abrir o app antes.

**O poder que traz.** Sentido e Metacognição na pergunta que entra: o Reflection provou que o público aceita pergunta em vez de resposta, e a pergunta boa vem de quem viu o corpus inteiro — a IA de fora, com o contexto do bloco Readwise, faz a pergunta que o Padrões faz com 12 notas, com todas. O esforço de responder por escrito é o ganho (efeito de geração); a IA que só pergunta multiplica sem substituir. Captura na transcrição e no Spotlight: a fala é mais rápida que o polegar, e a folha manuscrita é onde muita gente pensa.

**A estrutura que traz.** `Rota.Destino.pergunta(String)`; `PadroesLocal` ganha `validar(pergunta:notas:)` reutilizado pela rota; `Nota` ganha `perguntaOrigem: String?` (a pergunta fica no cartão fixo, não no texto — como hoje no Padrões); no .md, `pergunta:` no cabeçalho. Item 2: `SFSpeechRecognizer` com reconhecimento no aparelho, `VNRecognizeTextRequest` para manuscrito; ambos entram como texto cru no campo único, para a forma vestir ao soltar.

**O quanto eleva.** 4 — dá ao Segundo cérebro a volta que faltava sem abrir a porta (só pergunta, verificada), e a transcrição no aparelho é um salto de Captura; depende de duas ADRs, por isso depois.

**O que fica de fora — proposta histórica.** A escrita por MCP (a IA de fora criando entradas — regra 1, sem exceção). Ask Your Journal e a busca semântica (§16). Insights de sentimento, paisagem emocional, "celebração de progresso", revisões semanais/mensais/anuais geradas, streak e vista de consistência (§12, regra 5). O Voice Call de duas vias (chat). A pergunta "em tempo real" enquanto o autor escreve: o §19.4 tirou a pergunta livre do contrato da Análise por decisão recente; trazê-la de volta exigiria reabrir essa consequência com a mesma prova dura do Padrões — fica registrado, não proposto.

**O não-óbvio.** O Reflection é lido como "a IA que pergunta". Visto pelo canal, ele é o primeiro diário que virou ferramenta de um agente — e o fez com escrita, o que o transforma em caixa de entrada para prosa alheia. O Traço pode ser o segundo, com a regra invertida: o único verbo que entra é perguntar. Isso muda o que o Claude do autor É para ele: deixa de ser quem responde e passa a ser quem, tendo lido tudo, faz a pergunta que o autor ainda não se fez — e o Traço é onde ele responde por escrito. É o Padrões com o corpus inteiro e um modelo melhor, sem cobrar um token a mais (regra 10: o autor já paga o Claude).


---

### RemNote
`poderes: Memória · Intenção · Metacognição` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A forma é o cartão. O RemNote faz o cartão nascer do texto; o Traço já tem estrutura suficiente na nota — os campos da forma, os itens da lista — para o Recordar cobrar sem segundo momento, sem sintaxe, e com a dose de pista que cada MÉTODO pede, não a que o autor escolhe.

**A função, como existe lá.** Tipos de cartão: "pergunta/resposta, cloze (…), multilinha (lista e conjunto), descritores, (…) direção reversível". "Algoritmos Anki SM-2 e FSRS", "pausar", "desativar cards", "leeches", "novos cards por dia". "Widget Quick Add". "Extra Card Detail" e "Edit Later". O cartão criado no próprio outliner, sem app à parte.

**Como entra no Traço.**
1. **Recordar por forma (M).** Hoje o Recordar esconde a nota inteira, para qualquer gesto — recall livre, que é o certo para Nota permanente ("uma ideia nas suas palavras") e para prosa curta, e impossível para uma nota de mil palavras. O algoritmo já conhece os campos (labels são nossos, §19.2) e a lista (parser). Então: **Se–então** esconde só o "Então" e mostra o "Se" — é pergunta→resposta, e aqui a pista é o método: implementação de intenção é exatamente o elo gatilho→resposta, e treinar o elo é treinar o método. **WOOP** esconde os três campos e mostra os rótulos (mobiliário, não conteúdo). **Especificação** esconde "Pronto quando" e "O que eu NÃO vou fazer" — os dois que se esquecem. **Lista** vira "multilinha (conjunto)": esconde os itens, o autor escreve os que lembra, Revelar mostra lado a lado. **Nota permanente e prosa** seguem como hoje: tudo some. Nenhuma sintaxe, nenhum segundo momento, nenhum "criar cartão": a forma que vestiu a nota decide o que se esconde. Quem faz: algoritmo; a IA não entra. SPEC: §7 ganha a tabela "o que se esconde, por gesto".
2. **"Esqueci" (S).** Depois do Revelar, um toque opcional: "Esqueci — cobrar de novo". Volta ao degrau 0 da escada. Silêncio = sobe. É o mínimo do FSRS — um bit, do autor, sem nota, sem "Again/Hard/Good/Easy". Regra 5 preservada: nenhum número na tela.
3. **A nota que não gruda (S).** Três "Esqueci" seguidos é o leech do Anki. O Traço não suspende em silêncio: o Padrões local ganha uma pergunta de regra, citando a nota — "você tentou lembrar '<primeiras palavras>' três vezes; o que nela não é seu?". Pergunta verificável (tem "?", cita literal). O autor reescreve ou solta; reescrever é o efeito de geração em dobro.

**O poder que traz.** Memória: recuperação ativa com a dificuldade calibrada pelo método, não pela sorte do tamanho da nota — o testing effect é maior quando a recuperação é difícil mas possível (Bjork, dificuldades desejáveis); hoje o Recordar é impossível para notas longas e fácil demais para curtas. Intenção: o Se–então recordado pelo "Se" é o ensaio do gatilho — Gollwitzer mostra que o plano funciona quando o elo se torna automático, e o ensaio é o que automatiza. Metacognição no item 3: a nota que não gruda diz algo sobre a nota, não sobre o autor — e a pergunta devolve isso sem diagnóstico.

**A estrutura que traz.** `RecordarView` recebe um `PlanoDeRecordar` derivado de `Gesto` + parser (campos a esconder, itens de lista); `Revisoes` ganha `reiniciar(uuid)` e `falhas[uuid]`; `PadroesLocal` ganha a pergunta de regra para `falhas >= 3`; nada no schema (UserDefaults como hoje; migra para a `Nota` se a escada crescer). Notificação inalterada (sem conteúdo).

**O quanto eleva.** 4 — o Recordar passa a servir a toda nota, e o Se–então ganha o treino que o método pede: salto grande em Memória e Intenção ao mesmo tempo, sem uma tela nova.

**O que fica de fora — proposta histórica.** A sintaxe de cartão no texto (`::`, cloze com marcação) — o autor jamais digita marcação (ADR 31i). Geração de cartão, quiz, resumo, explicação e tutor por IA (§2). Streaks, metas, widget de streak, estatísticas, "Flashcard Insights" (§12). Exam Scheduler e agendadores customizados — o autor não configura memória; a escada é uma. Oclusão de imagem e múltipla escolha: pista demais para o que o Traço quer.

**O não-óbvio.** O dossiê diz que o RemNote "cobra com pista" e o Traço "sem pista", como se fosse uma escolha entre dois. Não é: a pista certa depende do MÉTODO. Recall livre é o treino para uma ideia; recall com o gatilho é o treino para um plano se–então — dar pista ali não é facilitar, é ensaiar o elo que o método existe para criar. O RemNote fez o autor escolher o tipo de cartão; o Traço já sabe o tipo, porque sabe o gesto. O cartão sem segundo momento que o dono pediu não é recurso novo: é o Recordar lendo a forma que já vestiu a nota.


---

### Rescript Journal
`poderes: Sentido · Metacognição` · `eleva: 4/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** O protocolo inteiro, não um dia dele. Pennebaker validou sessões seguidas sobre o mesmo evento; o §8 implementa uma. E o arco que o Rescript manda a IA escrever ao fim dos quatro dias, o Traço já tem quem escreva: o autor, uma linha de sentido por dia.

**A função, como existe lá.** "Ciclo de 4 dias consecutivos, uma sessão por dia, 15–20 min com timer; sem duração mínima obrigatória, sem streaks nem gamificação por decisão de design". "Um prompt por sessão e mais um ao terminar". "Ao terminar, a entrada pode ser selada, queimada ou deixada 'na mesa'". "Thoughts Journal (cartas, Premium)" e a trilha "Unsayable (Things You Can't Say)". "Resumo de tendência de 4 dias (arco emocional)" — por IA.

**Como entra no Traço.**
1. **A série de quatro (M).** Ao selar ou queimar uma expressiva, o app agenda o dia seguinte: notificação sem conteúdo ("Dia 2 de 4 — a mesma coisa, de novo"), que abre direto uma página nua já em modo Expressiva, ligada à série. Cada dia tem timer, fecho e linha de sentido próprios; a nota do dia anterior continua selada ou queimada — a série não reabre nada. A instrução única do §8 passa a ser uma por dia (texto fixo nosso, template: dia 1 o evento; dias 2–3 o mesmo evento por outro ângulo; dia 4 o que fica), como o Rescript tem "um prompt por sessão". No dia 4, ao fechar, o app mostra as quatro linhas de sentido, uma embaixo da outra, e nada mais. Quem faz: algoritmo. Pular um dia não quebra nada: a série espera (regra 4). SPEC: §8 ganha "série de quatro dias"; §19.2 "Memória" ganha "notificação de série (sem conteúdo)".
2. **A carta (S).** O aviso "Pedido de ouvinte/consolo → Quem é a pessoa de verdade que deveria receber isto?" hoje termina na pergunta. O Rescript tem a forma da resposta: a carta que não vai ser enviada. Forma "Carta" no catálogo: uma linha "Para" (do autor) e a página; fecha como expressiva (sela ou queima). Roteada pelo texto ("queria te dizer", "você nunca…") ou oferecida pelo próprio aviso, um toque. Template nosso.
3. **Cumprir o §8.5 (S).** A linha de sentido de uma fechada não chega ao export nem à voz que o Padrões lê (`Corpus.arquivoMd` não a escreve; `vozDoAutor` não a inclui). A série de quatro só vale se as quatro linhas viverem fora do selo, como o §8.5 promete: entram em `vozDoAutor`, no cabeçalho do .md (bloco Readwise) e no corpus do Padrões.

**O poder que traz.** Sentido: o ganho da escrita expressiva vem da construção de sentido ao longo dos dias — a narrativa que se reorganiza entre a sessão 1 e a 4 (Pennebaker e col.: quem muda as palavras de causa e insight de um dia para o outro é quem melhora). Uma sessão é o começo; quatro são o método. Metacognição: as quatro linhas de sentido lado a lado são o arco visto pelo próprio autor — o que o Rescript entrega como "tendência" de IA, aqui é o autor lendo a própria mudança de frase, sem adjetivo de ninguém.

**A estrutura que traz.** `Nota` ganha `serie: UUID?` e `diaDaSerie: Int` (1–4); `Revisoes` ganha o agendador de série (identificador `serie-<uuid>-<dia>`, sem conteúdo); `Rota.Destino.expressiva(serie:dia:)`; `FechoExpressivaView` mostra as linhas anteriores no dia 4; `Gesto.carta`; `vozDoAutor` e `Corpus` passam a levar `sentido`. No .md: `serie:` e `dia:` no cabeçalho, corpo ausente para fechadas.

**O quanto eleva.** 4 — o §8 deixa de ser um dia de um método de quatro; Sentido dá um salto que o autor sente na primeira série, e Metacognição ganha o único "padrão" que não precisa de IA: o autor comparando as próprias frases.

**O que fica de fora — proposta histórica.** Toda a IA do Rescript: tom emocional, temas recorrentes, padrões cognitivos, análise de sentimento, o "arco emocional" escrito pelo modelo — o §8.8 diz "nunca", e é o ponto mais sensível do produto. As trilhas por situação (Breakup, Grief, Job Loss…): template em menu (§12) e especialização que o Traço não tem; o desabafo se roteia pela palavra (§17). "Na mesa" como terceira saída: o Traço sela antes do fecho por regra (§8.3) — na mesa é selada, e não precisa de nome.

**O não-óbvio.** O Rescript é lido como "o §8 com IA". A leitura que interessa é outra: ele é o único app que trata o desabafo como MÉTODO com posologia — quatro doses, uma por dia, sem streak. O Traço herdou a dose e perdeu a posologia, e a parte cara do método está na repetição. E a segunda leitura: o "arco de 4 dias" do Rescript prova que o público quer ver o próprio percurso — o Traço pode dar isso sem uma palavra de IA, porque já pede ao autor a frase que resume cada dia. A linha de sentido, vista quatro vezes, é o relatório que a regra de ferro permite.


---

### Rosebud
`poderes: Intenção · Metacognição · Ordem` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** Fechar o dia que se abriu. O Rosebud pergunta de manhã o que você pretende e à noite o que aconteceu; o Traço tem a manhã (Destaque) e não tem a noite. E a memória entre entradas — que no Rosebud é da IA e no Traço pode ser regra.

**A função, como existe lá.** "Check-ins Morning Intention (3h–12h, três perguntas) e Evening Reflection". "Memória de longo prazo entre entradas (Bloom)". "Lembretes inteligentes que pulam sessões feitas". "Auto-tagging de humor, relações e temas" (e, no Reflection, "domínios de vida"). "Ask Rosebud (perguntas respondidas com links às entradas)".

**Como entra no Traço.**
1. **A noite do Destaque (S).** A forma Destaque ("a única coisa de hoje") agenda, no mesmo dia à noite, uma notificação sem conteúdo ("A única coisa de hoje — aconteceu?"), que abre a nota em Recordar: o autor escreve de memória o que era a coisa e o que fez; Revelar mostra a intenção da manhã ao lado. Sem check, sem "feito", sem placar: o olho compara, como no §7. Se o autor já abriu a nota à noite, a notificação não dispara (o Rosebud pula sessões feitas). Quem faz: algoritmo (`Revisoes`, um degrau especial de 0 dias). Toca o §12 "agenda" da mesma forma que o gatilho do Se–então (bloco One Sec): uma ADR cobre os dois — notificação de UMA nota, sem conteúdo, não é calendário.
2. **Memória entre notas, por regra (M).** O Padrões lê as últimas 12 notas. O Rosebud lembra tudo. O caminho do §19.4: antes da IA, a regra — para a nota aberta, o algoritmo acha as 8 notas mais próximas por sobreposição de palavras (voz do autor, sem acento, sem fechadas; um índice de frequência de termos cabe em cinquenta linhas e é determinístico) e manda ESSAS ao Padrões, com a atual. A IA continua devolvendo só perguntas verificadas; o motor local devolve a concordância como pergunta de regra ("você escreveu 'X' em 3 notas: <datas> — é a mesma coisa?"). O autor toca "Ler os padrões" na nota e recebe perguntas sobre o que esta nota ecoa. SPEC: §9 ganha "Padrões desta nota" e a seleção por afinidade.
3. **Domínios da vida (M, rótulo fechado).** O exemplo do dono no brief é o TickTick separando trabalho e vida. O Rosebud etiqueta "relações e temas" por IA; o Reflection chama de "domínios de vida". No Traço: lista FECHADA de domínios (trabalho · casa · corpo · gente · dinheiro · ideias · nenhum), atribuída por regra local primeiro (vocabulário) e pela IA como rótulo de reserva (§19.4: ela devolve só o que o algoritmo verifica; rótulo fora da lista = silêncio). Aparece como chip nos filtros das Notas, ao lado dos gestos; um toque troca; nunca entra no texto.

**O poder que traz.** Intenção: a intenção sem fecho é desejo; o monitoramento do próprio progresso é um dos efeitos mais robustos da literatura de metas (Harkin e col., 2016: monitorar e registrar aumenta a realização), e o Recordar noturno faz isso sem transformar o app em cobrador. Metacognição: a pergunta que só faz sentido se a conexão existir (o que o dossiê pede) exige achar a conexão — e achar é trabalho de regra, não de modelo. Ordem: o chip de domínio é o TickTick do brief — a cabeça desorganizada vendo trabalho e vida em pilhas separadas, sem ter classificado nada à mão.

**A estrutura que traz.** `Revisoes` com degrau "hoje à noite" para `gesto == .destaque`; módulo `Afinidade` (índice invertido local, recalculado ao salvar); `PadroesView` com entrada por nota; `Nota.dominio: String?`, chip nos filtros, rótulo no contrato remoto (`{gesto, aviso, dominio}`), `dominio:` no .md.

**O quanto eleva.** 4 — dois poderes de uma vez que o Traço mal toca (Ordem por domínio; Intenção fechada à noite) e o Padrões com memória de corpus inteiro, sem IA nova.

**O que fica de fora — proposta histórica.** O chat dentro da entrada, "Dig deeper", "Reflect", Guiding Light (a IA sugerindo ângulos quando o autor trava — é a IA ocupando o vazio, regra 8), personas, tom e voz da IA, relatório semanal, rastreador de humor, Happiness Recipe (metas sugeridas pela IA), streaks e "frases diárias (afirmações, haicais, provérbios)" — a afirmação diária é exatamente o que o aviso Wood do §5 recusa. A memória de longo prazo como a do Rosebud (servidor, histórico no modelo) fere as regras 2 e 10; a versão do Traço é seleção local e chamada sem histórico.

**O não-óbvio.** O Rosebud é lido como "diário com chat". Visto pela pergunta certa, o que retém a base dele não é a conversa — é ser lembrado: a IA que "lembra do que você já disse" faz o autor sentir que o próprio passado conta. O Traço pode dar a mesma sensação sem a IA lembrar nada: a regra acha o eco, a pergunta cita a data, e quem lembra é o autor. E o par manhã/noite revela um buraco no Destaque: o Traço pede a única coisa de hoje e nunca pergunta o que houve com ela — o método está pela metade, como a expressiva sem os quatro dias.


---

### Runestone
`poderes: Atenção · Ordem` · `eleva: 2/5` · `esforço: S` · `quando: depois`

**O que vale pegar.** A ergonomia do texto longo: a linha em que se escreve fica onde o olho descansa, nunca colada ao teclado; e achar um trecho dentro da nota sem perder a nota de vista. Nada acima disso — o resto do app é chrome de código.

**A função, como existe lá.** "Overscroll vertical" (Premium): a última linha pode rolar até o meio da tela. "Buscar e substituir enquanto o arquivo continua visível", com regex (NSRegularExpression, `$1`). "Ir para uma linha específica". "Lembrar a linguagem por arquivo". "Destaque da linha selecionada". Liga/desliga de autocorreção, capitalização e pontuação inteligente. Construído sobre o framework aberto Runestone (parser incremental por tree-sitter). Sem coleta de dados.

**Como entra no Traço.**
1. Overscroll na página: inset inferior de meia altura visível, para que a linha do cursor possa descansar no terço superior mesmo no fim de uma nota de 10 mil palavras. Algoritmo. §11 intocado: é rolagem do sistema, não animação nossa.
2. Buscar dentro da nota (a FILA já tem "busca na nota" aberta): campo que desce do topo sem cobrir a página, termo em âmbar como no §16, próximo/anterior. Sem substituir, sem regex — o autor não edita por padrão de texto. Algoritmo. §16 ganha uma linha: "busca dentro da nota é a mesma busca, sem sair da página".
3. "Ir para linha" não entra; o equivalente digno é o esboço por títulos (ver Taio, item 5).
4. O framework Runestone fica anotado como saída de emergência: se o TextEditor bater no teto com nota gigante, é um editor UIKit com parser incremental pronto, licença aberta. Hoje o parser (22×, FILA) dispensa.

**O poder que traz.** Atenção: a linha ativa numa posição fixa da tela poupa o olho de perseguir o cursor no rodapé — menos micro-reorientação, mais permanência na frase. Ordem: achar o trecho na nota longa sem sair dela evita a fuga para a lista. Sem evidência a citar; é ergonomia.

**A estrutura que traz.** Nenhuma no modelo. Um inset na PaginaView; um estado de busca local à nota. Trancada não abre, logo não busca — rota coberta por construção.

**O quanto eleva.** 2/5 — polimento que se sente na nota longa; não muda o que o app faz pela mente.

**O que fica de fora — proposta histórica.** Números de linha, guia de página, invisíveis, temas por escopo, regex na substituição, encoding: chrome de editor de código, contra o §3 e o §11 (tema único). "Lembrar linguagem por arquivo" já existe no Traço como `gesto` na nota.

**O não-óbvio.** O Runestone é um motor vestindo uma UI mínima: o app é o parser, o resto é régua. O Traço tomou a mesma decisão sem dizer (o parser 22× foi o item mais caro da FILA). A leitura que fica: toda função acima do motor tem de ser régua, não chrome — e o overscroll, vendido lá como opção Premium de programador, é a única função de Atenção do app inteiro.


---

### Shazam
`poderes: Captura · Atenção` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** Uma intenção, uma ação, zero decisão — e essa ação acessível por todas as portas físicas do aparelho, não só pelo ícone. O widget (U4) abriu a primeira porta; o Shazam mostra as outras quatro.

**A função, como existe lá.** Controle "Reconhecer Música" na Central de Controle (resultado chega como notificação; segurar mostra o histórico). Botão de Ação (iOS 18+) com a ação "Reconhecer Música". Siri "What song is this?" sem abrir o app. Widgets de Tela de Início e Tela Bloqueada. Atalho da Galeria rodável por Toque Traseiro duplo/triplo. "Identify songs on app start". Offline: pedido fica na fila e resolve quando volta a rede. Auto Shazam contínuo.

**Como entra no Traço.**
1. Um único App Intent, `NovaNota` (o mesmo `traco://nova` do widget), exposto como AppShortcut. Com ele nascem de graça: Botão de Ação, Toque Traseiro (via Atalhos), Siri por frase ("nova nota no Traço") e o atalho na Galeria. Algoritmo, zero rede. §19.2 "Sistema" já lista Atalhos/Siri.
2. ControlWidget na Central de Controle: um botão, abre a página nua. Segurar não mostra histórico — a lista é anti-altar (§3).
3. Widget de Tela Bloqueada (accessoryCircular): o glifo, um toque, a página. Se o U4 é só Tela de Início, este é o complemento.
4. "Identify songs on app start" é o §3 já feito: o app abre no ato. Nada a fazer; vale como confirmação da porta.
Nenhuma dessas portas pergunta nada. Uma tela intermediária na captura seria imposto sobre o pensamento que se está salvando.

**O poder que traz.** Captura como guarda-costas da Atenção: um pensamento não capturado ou se perde ou fica sendo ensaiado na cabeça até ser anotado — e o ensaio custa atenção. Escrever a intenção libera a mente do ciclo aberto (Masicampo e Baumeister, 2011: planejar a meta pendente desfaz a intrusão). Cada porta física a menos é uma fração dos pensamentos que morre no caminho.

**A estrutura que traz.** Nenhuma no modelo. Um `AppIntent` + `AppShortcutsProvider`; um `ControlWidget` na extensão do U4; um widget accessory. Rota nova é rota que o selo cobre por construção: o intent só abre página NOVA, nunca reabre nota.

**O quanto eleva.** 3/5 — fortalece Captura de um jeito que se sente no primeiro dia (o botão físico vira o Traço), sem abrir poder novo.

**O que fica de fora — proposta histórica.** Auto Shazam (escuta contínua): vigilância, e o Traço não capta nada sem o autor apertar. Fila offline com notificação de resultado: a Análise em silêncio no erro é regra (§5); nada "resolve depois" e muda a nota pelas costas. Abas de conteúdo, iCloud Sync (§12), Watch (alvo novo, L, fora do "iOS puro").

**O não-óbvio.** O Shazam não é um app de música: é um fechador de ciclo aberto. A coceira "que música é essa?" some em um toque antes de cobrar atenção. É por isso que "zero opção" não é estética: qualquer escolha na hora da captura taxa exatamente o pensamento que está sendo salvo. E a porta mais barata de todas é a que não tem tela — Toque Traseiro e Botão de Ação capturam de olhos fechados.


---

### Signal
`poderes: Sentido · Arquivo` · `eleva: 3/5` · `esforço: S · M (cifra, ADR)` · `quando: agora`

**O que vale pegar.** Privacidade como propriedade dos bytes, não das telas — e invisível para quem usa. O selo do §8 hoje é um booleano e um conjunto de portões de UI; o Signal aponta duas rotas que ninguém listou.

**A função, como existe lá.** "Hide Screen in App Switcher": tela azul com logo no seletor de apps. Mensagens ficam apenas no aparelho; backups do iCloud/iTunes não contêm histórico. Secure Backups: chave de 64 caracteres gerada no aparelho, nunca enviada. Mensagens temporárias com o timer visível na bolha e no cabeçalho; "View Once Media". Screen Lock com Face ID e tempo limite.

**Como entra no Traço.**
1. Cobrir a página ao ir para o fundo (`sceneWillResignActive`): a captura que o iOS guarda para o seletor de apps vira o fundo `#0B0B0D` e o glifo. Sem isso, uma expressiva em curso fica legível no seletor — e gravada em disco na cache de snapshots do sistema. É rota do selo (§8.6) não coberta. Algoritmo, S.
2. Texto trancado cifrado em repouso com chave no Keychain `ThisDeviceOnly`: o SwiftData guarda cifra; o backup do iCloud leva cifra sem chave. "Fora de tudo" (§8, Selar) passa a ser literal. Custo declarado no ADR: restaurar backup em aparelho novo perde o texto trancado — a linha de sentido não, porque vive fora do selo por desenho (§8.5). Migração direta aparelho-a-aparelho: testar. ADR sobre §8 e §10.
3. "Ver uma vez": nota trancada reaberta (dupla confirmação + Face ID) volta a selar ao sair da página. O selo é estado, não portão de uma vez. §8.4 ganha a frase. S.
4. O timer no cabeçalho já é o timer do §8. Nada a copiar.

**O poder que traz.** Sentido: a escrita expressiva só rende quando o autor escreve sem plateia — a garantia tem de ser verdadeira para o censor interno baixar a guarda (Pennebaker: a instrução "ninguém vai ler" é parte do método). Uma fresta no seletor de apps é uma plateia. Arquivo: o corpus fica do autor até no backup da Apple.

**A estrutura que traz.** `Nota.texto` de trancada passa a ser cifra (ou campo paralelo `textoSelado: Data`), chave por aparelho no Keychain (Chave.swift já é a casa). Rotas de teste novas: snapshot do seletor, restauro de backup, reabrir-e-sair. Queimar sobrescreve a cifra e apaga a chave da nota.

**O quanto eleva.** 3/5 — fortalece o poder que a expressiva já tem, e o autor sente no primeiro dia em que troca de app com o timer rodando e vê o seletor escuro.

**O que fica de fora — proposta histórica.** Face ID na abertura do app com timeout: fricção na porta da captura (§3, §17); o bloqueio do iPhone cobre. Secure Backups com chave de 64 caracteres: a trancada não precisa sobreviver ao aparelho — reler desfaz o ganho. Username, número, Stories, grupos: outro produto.

**O não-óbvio.** O Signal ensina que a garantia que funciona é a que o usuário não sabe que existe. O Traço fez o inverso no lugar certo (a cerimônia de trancar é visível, é método) e o mesmo no lugar errado: o selo é visível na UI e inexistente nos bytes. O par certo é cerimônia na tela, criptografia embaixo — e nenhuma das duas pede que o autor aprenda algo.


---

### Signal vs Noise
`poderes: Linguagem · Sentido · Memória` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** A escada que encolhe. Não é "escreva a essência" — é um degrau de cada vez, com o orçamento à vista, até sobrar a frase que vale. A única forma do catálogo que corta em vez de acrescentar.

**A função, como existe lá.** Fluxo em estágios: texto bruto → 200 caracteres → 100 → 50 → uma frase final. "Hard Mode": progressão irreversível. Três modos de entrada (ideia, letra, nota). Arquivo de "sinais" com busca local. Exporta Markdown e texto. Sem IA, offline, sem conta.

**Como entra no Traço.**
1. Forma **Destilar** no catálogo (§6): campos vazios abaixo do texto do autor — `Em 200` · `Em 100` · `Em 50` · `Numa frase` — cada um com o contador do orçamento na margem, em cinza; ao estourar, o contador vira aviso (`#C4614D`) e o campo para de aceitar. Contador e teto são algoritmo; a IA não toca. Mesma língua da régua: o autor escreve, o app mede.
2. Roteamento: v1 manual (régua/"Todas" e toque longo no cartão, onde o Recordar mora). Vontade de cortar não se adivinha por pausa; o roteador (§17) entra depois com um só gatilho verificável: prosa longa sem gesto, reaberta pelo autor.
3. **A frase vira o cartão.** No arquivo, a nota destilada mostra `Numa frase` como preview em vez da primeira linha. §15 exige "só a voz do autor" — é a voz do autor. A IA nunca gera título (§19.1); esta é a única forma de título honesta que o Traço pode ter.
4. **Recordar de destilada cobra a frase.** A escada 3→7→21 de uma nota longa é impossível por recall livre do todo; de uma destilada, o alvo é a frase. §7 ganha a variante: some tudo, o autor escreve a frase de memória, Revelar põe as duas lado a lado.
5. Chip `Destilar` nos filtros (§16), na mesma regra dos outros gestos.

**O poder que traz.** Linguagem: o orçamento força escolher a palavra que carrega mais — precisão lexical por pressão, não por dicionário. Sentido: a frase final é o que a nota significa, escrita por quem a escreveu. Memória: gerar o resumo (em vez de ler um) é das estratégias mais fortes de retenção (Fiorella e Mayer, 2016 — aprender por sumarização; Bjork — dificuldade desejável), e a frase é a pista de recuperação que o próprio autor fabricou.

**A estrutura que traz.** `Gesto.destilar` com quatro campos; tetos por campo no template (caracteres, como na origem — em português 200 é curto, e é por isso que funciona). Preview da lista lê o último campo quando preenchido. Recordar por gesto. Arquivo .md: labels como as demais formas; nada novo no roundtrip. Trancada nunca destila (não abre).

**O quanto eleva.** 5/5 — abre Linguagem, que o Traço hoje não multiplica em nada, e de quebra torna o Recordar viável para a nota longa.

**O que fica de fora — proposta histórica.** Hard Mode como irreversibilidade: os degraus continuam editáveis; sem volta é só o Queimar (§8). Os três modos: uma forma só. Toggle de qualquer coisa. A frase não vai para a IA remota como "resumo" — só viaja como voz do autor, igual ao resto (§19.1).

**O não-óbvio.** O Traço já pede a frase duas vezes — "o que ficou claro?" na expressiva e "uma ideia nas suas palavras" na Nota permanente — e nunca dá a escada para chegar nela. Para a mente que o §17 descreve, "diga numa frase" é um muro; quatro caixas que encolhem são degraus. E o arquivo de frases que se acumula é o índice da própria cabeça, escrito pelo dono dela — o único índice que a regra de ferro permite.


---

### Stoic
`poderes: Intenção · Sentido · Metacognição` · `eleva: 4/5` · `esforço: M` · `quando: agora (1 e 2) · depois (3)`

**O que vale pegar.** O relógio como pista. Duas âncoras no dia — manhã e noite — fazem o hábito sem sequência de dias, e fecham um ciclo que o Traço deixa aberto: o Destaque de hoje nasce de manhã e morre sem ser cobrado.

**A função, como existe lá.** "Preparação da Manhã + Reflexão da Noite" ou check-in único. Notificação diária em horário preferido, aproximado "para surpreender". Widget "Your Day Plan" na Tela de Início. "Journey": ver como as respostas ao mesmo prompt mudaram no tempo. Modelos de TCC ("thought dumps", preparar terapia). Check-in de humor ao abrir, streaks com recuperação, Trends, calendário de consistência, dez mentores de IA.

**Como entra no Traço.**
1. **Duas âncoras, sem placar.** No Perfil (§18), dois horários opcionais, desligados por padrão. A da manhã notifica só com o nome do app e abre a página nua — o roteador (§17) veste Destaque quando o autor escreve "hoje…". A da noite é um **Recordar do Destaque do dia**: a nota some, o autor escreve o que lembra, Revelar põe a intenção da manhã ao lado do que a noite escreveu. Sem pergunta, sem campo "fez?", sem contagem — o olho compara o pretendido com o vivido. Sem Destaque hoje, silêncio. Muda a escada (§7, §19.2): Destaque tem horizonte de um dia — degrau 1 = hoje à noite, sem 3/7/21.
2. **O Destaque na Tela de Início.** O widget do U4 ganha um estado: quando há Destaque de hoje, mostra "a única coisa de hoje" nas palavras do autor, o dia inteiro; sem Destaque, volta aos dois atalhos. Trancada nunca (não é Destaque). Algoritmo.
3. **Um campo no tempo** (Journey). Em Padrões, além das perguntas da IA, uma lista determinística: escolher um campo (Obstáculo interno, Se–então, Numa frase…) e ver as respostas do autor em ordem, com data. Só a voz, só não-trancadas, sem gráfico, sem número. Precisa de ADR em §9.4 ("dashboards" proibidos) — isto é releitura de um fio, não painel — e convive com o §3 (reler à toa é anti-padrão) por ser leitura de padrão, sob pedido, no lugar dos padrões.
4. O catálogo de métodos (§17) pode carregar o registro de pensamento da TCC como forma de campos vazios — o Stoic prova que cabe num diário. Só se o dono validar; é método de outros, entra como os demais.

**O poder que traz.** Intenção: a hora é o "se" da implementação de intenção (Gollwitzer) — a mente precisa de pista externa para o plano disparar, e o relógio é a mais barata. A cobrança da noite é recuperação ativa da própria intenção, que fortalece o vínculo pista→ação. Metacognição: o fio de um campo mostra o padrão sem que ninguém o nomeie.

**A estrutura que traz.** Dois horários em ajustes; regra de escada por gesto (Destaque: noite); widget com estado; consulta por label de campo nas notas não-trancadas. Notificação sem conteúdo, como hoje.

**O quanto eleva.** 4/5 — dá salto em Intenção (o Destaque passa a ser cobrado) e abre uma peça de Metacognição sem placar.

**O que fica de fora — proposta histórica.** Humor ao abrir, métricas 1–5, hábitos, streaks com recuperação, Trends, calendário de consistência: medir o autor (§19.1) e gamificar (§12). Prompt semanal e sugestões por fotos/Health: ocupam o vazio (§3). Mentores de IA e "Go Deeper": prosa e chat (§2, §12). Stoic Shield e respiração: não é escrita.

**O não-óbvio.** O Stoic vende duzentos exercícios e o que funciona são dois horários. E o segundo horário faz algo que nenhum app de tarefas faz: transforma a lista de hoje em experimento sobre si — o que eu disse de manhã contra o que aconteceu, visto por mim, sem nota. É Metacognição feita com a peça mais antiga do Traço, o Recordar, apontada para o dia em vez de para a memória.


---

### Strava
`poderes: Segundo cérebro · Metacognição · Arquivo` · `eleva: 5/5` · `esforço: M (ADR + contrato) · L (se pedir mais que arquivo)` · `quando: agora (ADR)`

**O que vale pegar.** Duas coisas. O conector de leitura: a Strava entrega os dados do atleta às IAs dele, só leitura, revogável. E a tese de que registro acumulado vira identidade — resolvida sem plateia: no Traço, a audiência que lê é a IA do autor, e ela nunca aplaude.

**A função, como existe lá.** "Strava MCP Connector": acesso conversacional, somente leitura, a atividades, tendências e metas via Claude.ai, Cowork e Claude Code; revogável nos ajustes. Visibilidade por atividade (Todos / Seguidores / Só você); zonas de privacidade; ocultar horário. Exportação por atividade e em massa. "Athlete Intelligence": resumos por IA, só o dono vê, sem desligar. Training Log, heatmap pessoal, Matched Activities, kudos, segmentos.

**Como entra no Traço.**
1. **ADR "Segundo cérebro" (seção nova).** Sem servidor (regra 10), o conector é o arquivo: o backup automático no Arquivos/iCloud Drive vira contrato público — um .md por nota, nome estável, front matter com gesto, datas e campos (o roundtrip da FILA já preserva tudo). Um `LEIA-ME.md` escrito pelo algoritmo descreve o formato — documentação, não nota. Qualquer IA com acesso a arquivos (Claude Code no Mac pelo iCloud Drive; upload em projeto) lê o corpus inteiro como contexto. Revogar = apagar a pasta ou desligar o backup no Perfil.
2. **Só leitura, nos dois sentidos.** A regra 1 estendida para fora: nenhuma IA escreve no corpus. O Traço nunca importa mudança feita na pasta por terceiros; importar segue sendo ato manual do autor (§19.2 Arquivo). Resumir e responder sobre o corpus acontece na casa da IA, a pedido do autor — fora do app; a regra do §19.1 vale para a IA do Traço, não para a do autor.
3. **Zona de privacidade.** Trancadas nunca saem (regra 2, já). Novo: marca "só aqui" por nota (o "Só você" da Strava) — fora do backup e da rede, sem ser expressiva. Um toque no menu da nota, raro, opt-in. §10 ganha `soAqui: Bool`.
4. **Identidade por acumulação, sem número.** A lista com seções por mês (FILA aberta) é o heatmap do Traço: o arquivo como paisagem, mês vazio é só ausência. E o índice de frases do Destilar (ver Signal vs Noise) é o perfil de atleta que o autor escreveu sozinho. Nada de estatística no Perfil (§18: "nada de medidor").

**O poder que traz.** Segundo cérebro: a mente do autor passa a existir também onde ele trabalha com IA — contexto perfeito, sem recontar a própria vida a cada chat. Metacognição por uso: a pessoa infere quem é observando o que faz (Bem, autopercepção); quando a IA responde "como você escreveu em março…", o corpus vira identidade por ser usado, não por ser exibido. Arquivo: o formato estável é a garantia de décadas.

**A estrutura que traz.** Contrato de arquivo versionado (nome, front matter, pasta); `LEIA-ME.md` gerado; flag `soAqui`; teste de que trancada e só-aqui nunca aparecem na pasta; §12 emendado: compartilhar com pessoas segue fora; a IA do autor lendo os arquivos do autor é Arquivo, não compartilhamento.

**O quanto eleva.** 5/5 — é a direção nova do dono (02/set) ganhando forma: o poder que o Traço não multiplica ainda, com o modelo de conector mais bem resolvido do mercado.

**O que fica de fora — proposta histórica.** Kudos, seguidores, clubes, segmentos, leaderboards, desafios, badges: audiência e placar (§12). Athlete Intelligence: resumo por IA dentro do app, sem desligar — o contraexemplo exato do §19.1. Fitness Score, Relative Effort, metas no widget: medir o autor. Beacon, Live Activities de treino: outro esporte.

**O não-óbvio.** A Strava fabrica identidade com o olhar dos outros. O Traço não pode ter plateia — mas pode ter leitor: a IA do autor lê tudo e não devolve kudos, devolve contexto. É a única audiência compatível com a nota que se sela. E o conector deles é somente leitura por acaso comercial; no Traço é somente leitura por lei — a mesma regra que proíbe a IA de escrever na nota proíbe qualquer IA de escrever no corpus.


---

### SuperMemo
`poderes: Memória · Intenção · Ordem` · `eleva: 4/5` · `esforço: M` · `quando: agora (1 e 3) · depois (2 e 4)`

**O que vale pegar.** Três lições de quarenta anos, sem o algoritmo: o intervalo tem de responder ao resultado; nem tudo merece a mesma fila; e a unidade de memória é o trecho, não o documento.

**A função, como existe lá.** Algoritmo SM-18: dificuldade dinâmica por item, estabilidade e recuperabilidade estimadas, primeira curva de esquecimento e curva de estabilização. SM-20: "Algorithm Arena" com cinco algoritmos competindo nos dados pessoais. Leitura incremental: material → extratos → clozes → memória estabilizada, com prioridade por item. Cloze deletion. "Active Final Drill" (cramming). Importa PDF, EPub, web, YouTube.

**Como entra no Traço.**
1. **Fila por forma, não por nota.** Se hoje toda Concluída sobe a escada 3→7→21 igual, o SuperMemo mostra que fila sem prioridade afoga. A prioridade que fecha em regra é a forma: Nota permanente e Destilar sobem sempre; WOOP e Se–então sobem (intenção precisa de recuperação); Destaque tem horizonte de um dia (ver Stoic); lista e prosa só sobem se o autor pedir (toque longo → Recordar inicia a escada). Algoritmo. §19.2 Memória ganha a tabela.
2. **Extrato como unidade.** Numa nota longa, selecionar um trecho → "Recordar este trecho": o extrato vira unidade com escada própria; a nota segue inteira (Arquivo). O extrato guarda o texto, não a posição; se o texto sumir da nota, o extrato morre calado. É a leitura incremental apontada para o próprio corpus — o único material que o §19 deixa viajar. M.
3. **Recordar por campo** (cloze). Para formas com campos, o Recordar esconde só as respostas e mantém os labels e o Resultado: o autor recupera "Se [obstáculo], então eu…" de memória. Para intenção, a pista é o ponto: na vida real o obstáculo aparece e a mente tem de puxar o plano. Recall livre continua para ideia (Nota permanente, prosa); recall com pista para plano. Algoritmo: os campos são nossos. §7 ganha a variante.
4. **Intervalo sensível ao resultado, sem nota.** v1: revisão cumprida (Revelar) sobe o degrau; revisão não feita repete o degrau em vez de pular. v2, para ADR: o algoritmo mede em silêncio a razão entre o tamanho da memória escrita e o da nota e encurta o próximo intervalo quando é pequena — nunca mostra, só agenda. Beira "medir progresso" (§19.1); por isso é ADR, não FILA.

**O poder que traz.** Memória: o efeito de teste e o espaçamento são os dois achados mais replicados da área (Roediger e Karpicke, 2006; Cepeda e col., 2006) — e o intervalo que responde ao resultado é o que separa espaçamento de calendário. Intenção: recuperar o vínculo se–então com a pista é ensaiar o disparo (Gollwitzer). Ordem: fila que cabe no dia.

**A estrutura que traz.** Regra de escada por gesto; entidade `Extrato` (texto, notaId, escada); Recordar com modo por campo; notificação continua sem conteúdo (§19.2). Trancada: nunca tem extrato nem escada.

**O quanto eleva.** 4/5 — salto grande em Memória (fila, unidade, resposta) e Intenção de uma vez.

**O que fica de fora — proposta histórica.** SM-18, Arena, curvas visíveis: painel (§9.4) e complexidade que a barreira de uso já derrotou. Cramming: anti-tese. Importar PDF, EPub, YouTube: palavras de outros — o Readwise da vizinhança; se o segundo cérebro um dia quiser leitura, é ADR separado. Explicações por IA ao extrair: prosa (§2).

**O não-óbvio.** O SuperMemo diz que agenda uniforme está errada para tudo — e a resposta do Traço não é um algoritmo, é a forma: ela já sabe o horizonte da memória (um dia, semanas, para sempre) antes de qualquer curva. E o Anki venceu o SuperMemo sendo pior porque abria mais rápido: o Recordar vence se ficar a um toque da notificação, e perde no dia em que ganhar uma tela de opções.


---

### Taio
`poderes: Captura · Intenção · Ordem · Arquivo` · `eleva: 3/5` · `esforço: S (1 e 2) · M (3 e 4)` · `quando: agora (1 e 2) · depois (3–5)`

**O que vale pegar.** As portas de entrada que não passam pelo app, e o texto fixado na Ilha. O resto do Taio é o §17 de cabeça para baixo: mesmo motor, cara oposta.

**A função, como existe lá.** Atalhos "Create Document", "Save Clipping", "Run Actions" sem abrir o app; Toque Traseiro. `taio://` com `new`, `append`, `prepend`, `overwrite`, `search`, `tag` e x-callback-url. "Live Notes" e "Quick Drafts"; Live Activity/Dynamic Island para fixar trechos de texto. Clipboard como fonte. Outline por títulos, estatísticas do documento, histórico local com diff, wiki links e backlinks, TextBundle, busca fuzzy/regex, paleta `/`, ações em JavaScript.

**Como entra no Traço.**
1. **Nota por Atalhos, sem abrir o app.** App Intent `NovaNotaComTexto(texto)`: ditado pela Siri, texto vindo de outro atalho, ou o clipboard — vira nota no SwiftData e o roteador (§17) veste na próxima abertura. `traco://nova?texto=` com `x-success`. Nada de `append/prepend/overwrite`: nota só se edita pela mão na página, e isto fecha também a porta para IA externa escrever (regra 1). §19.2 Sistema.
2. **O Destaque na Ilha.** Live Activity com "a única coisa de hoje", nas palavras do autor, da Concluída até a âncora da noite (ou o teto de 8 h). Não é notificação: é a intenção parada na vista. Complementa o widget (ver Stoic). ActivityKit na extensão do U4.
3. **"Liga a" vira ligação.** No campo da Nota permanente (§6), tocar oferece a lista de Notas; o app grava mobiliário `traco://nota/<id>` — nunca visto cru (ADR 31i) — e mostra um chip com a primeira linha ou a frase destilada da alvo. Backlinks aparecem na nota alvo por varredura local. Trancada: chip com cadeado, sem texto. Sem `[[`, sem sintaxe: o autor escolhe, não escreve. M.
4. **Histórico local da nota.** Versões por gravação, com diferença. Arquivo: navegar nunca custa palavra (§20) e agora editar também não. Queimar tem de varrer o histórico — rota nova para o teste do §8.6.
5. Contagem de palavras e esboço por títulos na nota longa (FILA aberta): algoritmo, discreto, no rodapé da página.

**O poder que traz.** Captura por descarga cognitiva: o pensamento nascido fora — ditado no carro, frase escrita numa conversa — entra sem que a mente o segure até chegar ao app (Risko e Gilbert, 2016: descarregar libera capacidade). Intenção: pista visual permanente. Ordem: ligação sem sintaxe é a rede de ideias que o segundo cérebro lê como grafo.

**A estrutura que traz.** App Intent com parâmetro; esquema `traco://` documentado; Live Activity; parser aceita `traco://nota/` como mobiliário; consulta de backlinks; tabela de versões (varrida no Queimar).

**O quanto eleva.** 3/5 — Captura e Intenção sentidas no primeiro dia; Ordem cresce depois.

**O que fica de fora — proposta histórica.** Ações em JavaScript, galeria de ações, paleta `/`, barra de marcação, TextExpander, Working Copy: tudo que exige aprender o app (§17). Clipboard como aba: as palavras de outros não são o corpus. "Open in place" para outros apps editarem o .md: o SwiftData é a verdade; conflito seria ADR. Exportar PDF/HTML: o autor já tem o .md.

**O não-óbvio.** A aba de clipboard do Taio é uma caixa de entrada para tudo que a pessoa copia — o custo de "onde ponho isto" cai a zero. A página nua do Traço é essa caixa, mas só para o que se digita nela; o Atalho com texto abre a caixa para o que nasceu em outro lugar. E o Taio prova por contraste o que o §17 afirma: todo poder que ele expõe na barra é o mesmo poder que o Traço esconde atrás do vestir.


---

### The Most Dangerous Writing App
`poderes: Atenção · Sentido` · `eleva: 3/5` · `esforço: S` · `quando: depois (ADR §8)`

**O que vale pegar.** As instruções de Pennebaker feitas físicas: não parar e não reler. O MDWA obriga as duas com ameaça; o Traço pode obrigar sem perder uma letra.

**A função, como existe lá.** Sessão por minutos (3–60) ou por palavras (150–1667). Indicador de perigo: o texto esmaece conforme o tempo desde a última tecla cresce; mais de 5 segundos = "You failed", perda total. Modo Hardcore: mostra só a última letra digitada (original) ou esconde o texto e desliga o backspace (Squibler). Ao completar, "Download N words". Prompt aleatório. Tuíte da falha.

**Como entra no Traço.**
1. **Escuridão atrás** (Hardcore sem punição): na expressiva (§8), só o parágrafo em curso fica legível; o que subiu escurece num gradiente ancorado na linha do cursor. Rolar para cima não revela. O texto está salvo o tempo todo. É "não reler durante" somando-se ao "não reler depois" que o Selar já garante. Backspace fica: corrigir a palavra na linha não é reler. Algoritmo, UI só. ADR em §8 porque muda o modo, não um ajuste.
2. **O esmaecer sem perda**: na expressiva, parada acima de ~10 s (não 5 — sentir leva mais tempo que escrever) esmaece devagar o pouco que está visível; a próxima tecla devolve na hora. Nunca há "falhou", nunca há perda. Um parâmetro, um teste. Fora da expressiva não existe: a página comum tem a Análise na pausa (§5), e a pausa é dela.
3. Sessão por tempo já é o timer do §8; por palavras não entra.

**O poder que traz.** Atenção: só a frase atual existe, o censor interno perde o objeto que edita; é o mecanismo do fluxo (Csikszentmihalyi) sem a ameaça. Sentido: a escrita expressiva rende quando é contínua e sem edição — é instrução literal do protocolo de Pennebaker ("escreva sem parar; não se preocupe com gramática; se acabar, repita") — e o app assume o trabalho de sustentar isso em vez de pedir força de vontade a quem está com peso.

**A estrutura que traz.** Nada no modelo. Máscara na PaginaView em modo expressiva; o temporizador de inatividade que já existe para a Análise, reaproveitado com outro limiar; o §8 descreve o modo com as duas regras novas.

**O quanto eleva.** 3/5 — fortalece Sentido e Atenção na expressiva, e o autor sente no primeiro desabafo.

**O que fica de fora — proposta histórica.** Perda total e "You failed": destruição sem escolha — no Traço, destruir é método do autor (Queimar), nunca castigo. Prompt aleatório (§3). Tuíte (§12). Meta por palavras: placar. Backspace desligado: briga com o teclado, não com o censor.

**O não-óbvio.** O MDWA é a expressiva do Traço com a memória arrancada: mesma sessão cronometrada, contínua, sem edição — mas o texto morre por falha. O Traço já converteu o estado de falha em método (Queimar, Briñol). O que falta é o contrário: a parte do MDWA que funciona antes do fim, o fluxo, hoje depende só da disciplina do autor. A escuridão atrás entrega o fluxo, e a vontade de não parar deixa de ser tarefa do autor — passa a ser do app (Tesler: a complexidade não some, muda de lado).


---

### Things 3
`poderes: Segundo cérebro · Ordem · Captura` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A porta da frente. O Things não tem API e ainda assim é o app de tarefas que as IAs do autor mais leem bem — porque tudo o que entra e sai passa por Atalhos, URL scheme e Mail to Things, nunca pelo banco. E o gesto de criar a coisa no lugar onde ela vai viver, em vez de criar e depois arquivar.

**A função, como existe lá.** (1) As ações de Atalhos *Find Items* (filtros por tipo, título, pai, datas, tags, status, notas; ordenação; limite de 500), *Get Items*, *Get Selected Items* e *Show Items*, mais a página oficial sobre IA de terceiros: métodos seguros são URL scheme, Atalhos, AppleScript e Mail to Things; escrever no banco ou dar as credenciais do Things Cloud é inseguro; ChatGPT "evitar" por corromper o banco. (2) O *Magic Plus*: arrastar o botão até o ponto da lista onde o a-fazer nasce; soltar na borda esquerda de um projeto cria cabeçalho; soltar no alvo Inbox captura sem destino. (3) O *Quick Find* em dois níveis: primeiro nomes de a-fazeres, projetos, áreas e tags; "Continue Search" só então entra em notas, checklists e Logbook.

**Como entra no Traço.**
1. **Ler notas como App Intent** (Segundo cérebro · Ordem). O Traço ganha as intents `Buscar notas` (termo, gesto, domínio, período; limite fixo) e `Abrir nota` — só leitura, resultado em texto puro, a voz do autor (`Caderno.prosa`), nunca mobiliário. Trancada e queimada não existem para a intent (§8, §19.2). Quem faz: algoritmo, sobre o índice que a busca do §16 já tem. O autor liga isso a um Atalho e o Atalho à IA que usar — o app não chama rede nenhuma (§5). É a doutrina do Things: a IA entra pela porta da frente; o SwiftData nunca é aberto por fora. Muda: §19.2, linha Sistema, ganha "intents de leitura"; a direção segundo cérebro pede seção nova (ADR: não contradiz §12 — não é sync nem nuvem; o dado sai porque o autor o puxou).
2. **Nova arrastada sobre um cartão** (Ordem). Na tela Notas, arrastar a pílula Nova (§20) e soltar sobre uma nota abre página nova com um cartão fixo não-editável "Em resposta a: <título>" — o mesmo cartão do §9.3 e do §15, que nunca entra no texto. Algoritmo puro. A nota-resposta vira "Liga a" de fato sem o autor digitar título nenhum. Soltar fora de qualquer cartão = nota nua, como hoje.
3. **Busca em dois tempos** (Arquivo, polimento). O campo do §16 bate primeiro em títulos e linhas de sentido; "procurar no texto" só ao pedir. Reduz ruído quando o corpus passa de mil notas. Um toque a mais, só no caminho secundário.

**O poder que traz.** (1) Segundo cérebro: contexto perfeito para as IAs do autor sem entregar a chave do arquivo — o que sai é o que a busca devolveria a ele mesmo, e o selo vale para a intent como vale para o Spotlight. (2) Ordem por encadeamento: ligar notas no gesto, não no texto, é offloading — a rede de notas se forma sem que o autor mantenha índice (Nota permanente pede "Liga a"; hoje isso é digitação de memória). (3) Redução de carga na busca.

**A estrutura que traz.** `AppIntent` de leitura com `AppEntity` Nota (id, título, gesto, criadaEm, texto sem mobiliário); filtro obrigatório `trancada == false`. Campo `respondeA: UUID?` em Nota (persistido; sai no .md como `responde_a:` no front matter). Gesto de arrasto na pílula Nova com alvo nos cartões. Nenhuma notificação nova.

**O quanto eleva.** 4 — dá ao segundo cérebro a forma mais segura possível (a que o app mais bem desenhado do iOS escolheu) e liga notas por gesto; não é 5 porque a porta é uma peça, não a direção inteira.

**O que fica de fora — proposta histórica.** Writing Tools da Apple nas notas (reescrever, resumir — §2, §19.1). Things Cloud e sync (§12). Datas, prazos, repetição, calendário (§12). Tortas de progresso e anel de percentual (§19.1). Áreas e projetos como hierarquia mantida à mão (ver TickTick: a divisão entra inferida, não arquivada).

**O não-óbvio.** O Things é o único da lista que publicou uma posição sobre IA de terceiros, e ela é o §19.3 dito ao contrário: o que a IA pode fazer com os seus dados é o que o app deixa fazer pela frente. O Traço não precisa de API, MCP nem servidor (regra 10) para ser segundo cérebro — precisa que as intents de leitura devolvam exatamente o que a busca devolve, com o selo dentro.


---

### TickTick
`poderes: Ordem · Intenção · Segundo cérebro · Metacognição · Captura` · `eleva: 5/5` · `esforço: L` · `quando: agora`

**O que vale pegar.** A harmonia de uma cabeça separada em trabalho, casa, saúde, dinheiro — sem o autor ser o bibliotecário. O TickTick entrega a separação e cobra manutenção; a conta do dono mostra o que acontece em semanas. O Traço pega a separação e tira a manutenção: o domínio é lido, nunca arquivado. E a outra metade, que o dossiê viu de relance: o TickTick já é o segundo cérebro das IAs do dono (o conector MCP está ligado nesta conta), e faz isso com servidor.

**A função, como existe lá.** (1) Hierarquia Pasta > Lista > Seção > Tarefa; listas inteligentes All, Today, Inbox derivadas sem pasta; tags com pai e cor; fundos por lista. (2) *Smart Recognition*: data, hora, repetição e lembrete lidos de dentro do texto, com opção de tirar a data do título; "#" vira tag; lembrete por localização. (3) Hábitos com três seções criadas na abertura da conta — manhã, tarde, noite — antes de existir hábito algum (visto pela API). (4) *Suggested Tasks* na Today: "adiada 2/3/5+ vezes". (5) TickTick MCP (`mcp.ticktick.com`, OAuth ou token; clientes Claude, ChatGPT, Gemini, Grok, Claude Code, Cursor), CLI, Open API, backup e CSV: a conta inteira legível de fora. (6) Controles da Central de Controle no iOS 18: Add Task. (7) "Won't Do" como estado terminal ao lado de Concluída.

**Como entra no Traço.**
1. **Domínio inferido, nunca arquivado** (Ordem). O contrato remoto `{gesto, aviso}` (§19.4) ganha `dominio`, enum fechado: Trabalho · Casa · Saúde · Dinheiro · Pessoas · Estudo · Ideias · nenhum. Rótulo desconhecido = nenhum. Antes da IA, a regra: léxico local por domínio (reunião, cliente, deploy → Trabalho; consulta, dor, remédio → Saúde) quando a nota bate forte; senão a IA como algoritmo dinâmico; senão silêncio — nota sem domínio é válida. O autor vê: um chip discreto no cartão da nota (cor por domínio, `law-of-similarity`) e chips de filtro nas Notas ao lado dos gestos (§16). Errou? Um toque no chip troca ou tira (§17.2: um toque desfaz). O Perfil renomeia ou esconde domínios; nenhum precisa ser criado. Trancada e expressiva não são classificadas: o texto não viaja (§5, §19.1). Muda: §6 ganha o eixo "domínio", transversal às formas; §16 ganha chips; §19.1, linha 1, passa a devolver dois rótulos. O "#palavra" digitado pelo autor vira filtro por regex (`jakobs-law`: todo mundo sabe o que é hashtag) — caminho opcional, não principal.
2. **O "Se" com hora vira o aviso do gatilho** (Intenção). Nas formas Se–então e WOOP o campo "Se" muitas vezes carrega hora ("se às 7h", "amanhã de manhã"). `NSDataDetector` (stdlib, determinístico) lê a data; o app agenda UMA notificação naquele instante com o título da nota e nada mais (§19.2: notificação sem conteúdo). Não é agenda: é a deixa da intenção de implementação chegando na hora dela. Algoritmo puro; sem confiança = nada. Tirar o aviso = um toque no cartão. Muda: §6/§7 ganham "gatilho com hora"; §12 mantém "agenda/calendário" e ganha uma linha: aviso de gatilho não é calendário (ADR curta). Lugar ("quando chegar em casa") fica para depois: geocodificar sem perguntar não fecha em regra.
3. **Manhã, tarde, noite como âncora** (Intenção). Quando o "Se" tem período e não hora ("de manhã", "à noite"), o algoritmo mapeia para uma das três âncoras; o aviso do item 2 sai na hora da âncora. As três horas nascem com valores padrão e se ajustam no Perfil, uma vez, como a conta. É a alternativa honesta à sequência de dias: o hábito não tem contador, tem hora.
4. **"Adiada 5+ vezes" vira pergunta** (Metacognição). O Recordar já tem escada 3→7→21 e notificação. Quando uma nota é cobrada N vezes sem o autor recordar, o Padrões (parte local, algoritmo) ganha uma pergunta-modelo citando o título literal: "'<título>' foi cobrada três vezes sem resposta — ela ainda importa, ou já se resolveu?" Passa na prova dura do §19.4 (tem "?", cita literal). Só aparece quando o autor abre o Padrões (§9). Nenhum contador na tela.
5. **O corpus legível pelas IAs do autor, sem servidor** (Segundo cérebro — depois, ADR). O que o MCP faz por HTTP o Traço faz por arquivo e por intent: (a) o backup .md (§10, FILA) vira uma pasta uma-nota-por-arquivo com front matter fixo — `gesto`, `dominio`, `criada`, `revisada`, `linha_de_sentido`, `responde_a` — mais um `INDICE.md` gerado por algoritmo (título, domínio, data; sem resumo, sem prosa), na pasta do app em Arquivos; o autor decide se essa pasta vive no iCloud Drive dele e aponta o Claude Code, o Grok ou o que usar; (b) as intents de leitura do bloco Things 3. Trancada e queimada não existem em nenhuma das duas rotas. ADR: seção nova "Segundo cérebro" — não contradiz a regra 10 (nenhum servidor nosso), toca §12 (não é sync: é o export existente, mais estruturado) e §19.1 (a IA de fora lê; a de dentro continua só rotulando).
6. **Controle na Central de Controle** (Captura). `ControlWidget` "Nova" e "Recordar", ao lado do widget U4. S.

**O poder que traz.** (1) Ordem por redução de carga: a cabeça que separa "isto é trabalho, isto é casa" gasta atenção; quando a separação chega pronta e só pede confirmação por toque, a harmonia do TickTick fica e a manutenção some. (2–3) Intenção de implementação: o "se X, então Y" funciona quando a deixa é percebida (Gollwitzer); a deixa que o próprio aparelho traz na hora certa fecha o elo que o papel não fecha. (4) Metacognição sem placar: a pergunta sobre o que se adia. (5) Segundo cérebro: domínio + gesto + linha de sentido no front matter é o contexto mais barato e mais útil que uma IA pode receber — sabe o que é trabalho, o que é saúde e o que ficou claro, sem ler o desabafo, que nunca sai.

**A estrutura que traz.** `Nota.dominio: Dominio?` (enum persistido, rawValue estável); contrato remoto `{gesto, aviso, dominio}`; léxico local por domínio em arquivo de recurso; `Nota.gatilhoEm: Date?` e `Nota.ancora: Ancora?` (manhã/tarde/noite) com as três horas no Perfil; contador interno de cobranças sem resposta (não exibido); export em pasta com front matter e índice; intents de leitura; controle da Central de Controle. Chips de domínio nas Notas e no cartão.

**O quanto eleva.** 5 — o Traço passa a organizar a vida do autor em domínios sem que ele arquive nada, e o corpus passa a servir às IAs dele: um poder novo (Segundo cérebro) e a Ordem que hoje só existe por gesto.

**O que fica de fora — proposta histórica.** A suíte: calendário, Kanban, Timeline, matriz de Eisenhower, contagens regressivas, Pomodoro com estatística (§12; e o dossiê: suíte compete pela barra). Achievement Score, medalhas, mapa de calor, taxa de conclusão (§12 por nome). Constant Reminder e alarme que ignora o silencioso (a notificação que insiste). Summary (texto gerado), AI Voice Add (reestrutura a fala do autor), transcrição com resumo — §2, §19.1. Colaboração, atribuição, comentários (§12). Conta obrigatória, e-mail-para-tarefa e bot do Telegram (exigem servidor — regra 10). 40 temas (tema único, §11). Modelos de tarefa e de nota (§12: templates em menu).

**O não-óbvio.** Três. Primeiro: o TickTick organiza a mente fazendo do autor o bibliotecário — e a conta do dono prova que o bibliotecário pede demissão. A harmonia é real; a manutenção é o que mata. Separar sem arquivar é o §17 aplicado à Ordem. Segundo: o único calendário que o Traço pode ter sem virar agenda é o das intenções — não o evento, mas a deixa do "se" chegando na hora. Terceiro: a matriz de Eisenhower e o Destaque respondem à mesma pergunta por caminhos opostos — a matriz pede que o autor classifique quatro quadrantes; o Destaque pede uma coisa. O Traço já escolheu.


---

### TIDE
`poderes: Atenção · Captura` · `eleva: 2/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** O instrumento absorve a decisão de quando parar. O TIDE não tem pausa, não tem barra de progresso e não apaga a tela: o tempo é a única coisa viva, e o autor entrega o relógio ao app para não ter de olhá-lo.

**A função, como existe lá.** Timer de foco em modo imersivo "contra o celular", com tela sempre ligada e lembretes em tela cheia; timer personalizável por cenário; Pomodoro com sons de natureza; *Siri Shortcuts* ("Shortcut portal") para iniciar sessões de foco, soneca, sono e respiração de fora do app; uma palavra abaixo dos números dizendo o que está acontecendo.

**Como entra no Traço.**
1. **Tela acesa durante a expressiva** (Atenção). Enquanto o timer do §8 corre, `isIdleTimerDisabled = true`; volta ao normal no fecho. Uma linha. Hoje o autor para dez segundos para pensar e o iPhone escurece — e pensar é parte dos 15 minutos.
2. **"Desabafar" como intent** (Captura). App Intent `Começar expressiva`: abre a página nua já no modo do §8, timer correndo, sem passar pela Análise. Entra no widget U4 como terceiro atalho e na Siri. O momento em que a expressiva serve é o momento em que abrir o app, escrever e esperar a Análise rotear é longo demais.
3. **Um som, desligado por padrão** (Atenção, depois). Um único loop (chuva) durante a expressiva, ligado no Perfil uma vez, nunca perguntado na sessão. Sem catálogo, sem mixagem.

**O poder que traz.** Atenção sustentada: a complexidade de "quando eu paro?" tem de morar em alguém (Tesler), e mora no timer. A tela que não apaga e o som que mascara o ambiente tiram dois motivos de sair da página. O intent tira o custo de chegar nela.

**A estrutura que traz.** Nada no modelo. Um flag de sessão; um `AppIntent` que cria nota com `gesto = .expressiva` e dispara o timer; um `Bool` de som no Perfil; um recurso de áudio.

**O quanto eleva.** 2 — polimento que se sente na primeira expressiva; o poder (o timer que não negocia) o §8 já tem.

**O que fica de fora — proposta histórica.** Modo imersivo com lista de apps permitidos (Screen Time API — pesado, e o §8 já tranca ao sair). Sono, soneca, alarme, respiração 4-7-8 e meditações: método fora do §8, e o ADR 31l proíbe método sem prova dentro do fluxo. Tide Diary com relatório e cartão de compartilhamento (§12). Citação diária (§3: nada ocupa o vazio). Cenas e catálogo de sons (§12: menu).

**O não-óbvio.** O TIDE separa sono, foco e meditação por cena, não por ajuste: uma cena é uma intenção. O Traço tem uma cena só — a expressiva — e é por isso que o intent vale mais que o som: entrar já na cena certa é o que o TIDE faz com um toque na tela inicial.


---

### Vocabulary
`poderes: Linguagem · Memória · Atenção · Metacognição` · `eleva: 5/5` · `esforço: M` · `quando: agora`

**O que vale pegar.** Vocabulário é poder de pensar: só se pensa com as palavras que se consegue produzir. O Vocabulary aumenta o vocabulário com uma unidade por tela, uma hora por dia e prática — e dá as ferramentas para entender cada palavra. O Traço pega a estrutura inteira e troca a matéria-prima: as palavras não vêm de um feed, vêm do que o autor lê, escreve e repete.

**A função, como existe lá.** (1) Feed de uma palavra por tela, serifada no centro, chrome em pílulas nas bordas; deslizar traz a próxima. (2) Cada palavra com definição, pronúncia em áudio, etimologia, exemplos de uso e sinônimos. (3) Favoritos (coração), coleções personalizadas, histórico *Past* das palavras vistas. (4) Lembretes diários com horários e categorias configuráveis; palavra do dia no widget com frequência ajustável. (5) Quizzes e jogos de prática; revisão de palavras salvas. (6) Nível (iniciante a especialista) e categorias temáticas escolhidos pelo autor.

**Como entra no Traço.**
1. **A fila do Recordar, uma nota por tela** (Memória · Atenção). Hoje o Recordar (§7) é por nota, a partir da nota ou do cartão, e a escada 3→7→21 notifica uma a uma. Passa a existir a fila do dia: as notas vencidas, uma por tela, nada mais na tela; a nota some, o autor escreve de memória, Revelar, deslizar → próxima; acabou = página nua, sem "parabéns", sem contagem. UMA notificação por dia, na hora que o autor escolhe no Perfil ("Recordar às 8h"), em vez de uma por nota. O widget U4 ganha o atalho "Recordar" (só o atalho; nunca título nem trecho). Algoritmo puro. Muda: §7 ganha "fila do dia"; a FILA "revisões agendadas" passa a agrupar.
2. **A forma Palavra** (Linguagem · Memória). O §6 ganha uma linha: **Palavra** — roteada quando o autor escreve uma palavra e o que ela quer dizer, ou "não conhecia essa palavra"; campos: *Nas minhas palavras* · *Uma frase minha com ela* · *Onde a encontrei*. Campos nascem vazios (§2); a IA só devolve o rótulo `palavra` (enum do contrato, §19.4); heurística local: linha curta seguida de travessão ou dois-pontos, ou "significa". Dicionário, etimologia e sinônimos não se constroem: o *Look Up* do sistema já vive no menu de seleção de todo campo de texto do iOS — a ferramenta para entender a palavra é nativa. O Recordar de uma Palavra corre na direção produtiva: mostra *Nas minhas palavras* sozinho no centro da tela, sem chrome, e esconde a palavra; o autor escreve a palavra; Revelar. É o contrário do quiz do Vocabulary, e é a direção que vira pensamento.
3. **O léxico do autor** (Linguagem · Ordem). Chip "Palavras" nas Notas (§16), ao lado dos gestos. A coleção se monta sozinha a partir da forma; sem coração, sem "adicionar à coleção". Sai no export como `gesto: Palavra`.
4. **As ferramentas para entender o próprio vocabulário** (Linguagem · Metacognição). Algoritmo local, sobre a voz do autor (`Caderno.prosa`), sem trancadas: contagem de palavras por mês fora das stopwords. O Padrões (§9) ganha dois modelos de pergunta locais: a muleta — "você escreveu 'basicamente' catorze vezes este mês — o que ela está substituindo?" — e a rara — "'sobranceiro' apareceu uma vez, em março — ainda é sua?". Prova dura do §19.4: fragmento literal, "?", nenhum número fora da pergunta. Nada de índice de riqueza lexical na tela: a pergunta é a ferramenta.

**O poder que traz.** (1) Espaçamento e recuperação ativa num ritual de uma vez por dia — o ritmo diário é o que faz o Vocabulary ser aberto, e o Traço tem a escada mas não o ritual. (2) Efeito de geração na direção produtiva: recordar a palavra a partir da própria definição é o que transforma vocabulário passivo em vocabulário disponível para pensar — o teste que fortalece é o que exige produzir, não reconhecer. Escrever a definição "nas minhas palavras" é elaboração: a palavra fica ligada à rede do autor, não ao dicionário. (4) Especificidade lexical por metacognição: ver a própria muleta é o que faz procurar a palavra exata.

**A estrutura que traz.** `Gesto.palavra` (rawValue novo; `doNome` aceita); três labels de template; regra de roteamento local; contrato remoto com `palavra` no enum de gesto. Fila do Recordar: consulta das notas com revisão vencida, ordenada por vencimento; uma notificação diária agrupada (`UNCalendarNotificationTrigger` na hora do Perfil) substitui as por nota; hora no Perfil. Contagem de palavras por mês como índice local (não persistido na nota). Atalho "Recordar" no widget. Front matter `gesto: Palavra`.

**O quanto eleva.** 5 — Linguagem é o poder que a tabela dos dez marca como "quase nada hoje"; a forma Palavra e a pergunta sobre a muleta abrem esse poder, e a fila diária dá à Memória o ritual que a escada ainda não tem.

**O que fica de fora — proposta histórica.** Streaks, coroa, paywall, jogos gamificados, temas e fundos (§12, §11). A serifa no centro: §11 é SF, e a tela do Recordar de uma Palavra fica em SF. O feed de palavras alheias: o Traço nunca põe conteúdo no vazio (§3) — a palavra entra porque o autor a trouxe. Widget com "palavra do dia" e complicação de Watch com conteúdo: mostrariam texto do autor fora do app (o selo e o §3 falam contra). Rastreamento e publicidade.

**O não-óbvio.** Três. Primeiro: o Vocabulary vende palavras de fora; a ferramenta que faltava ao autor é entender as de dentro — a muleta que ele repete catorze vezes é mais reveladora que qualquer palavra rara do feed. Segundo: o quiz do Vocabulary é receptivo (vê a palavra, escolhe o sentido); poder de pensar é produtivo (tem o sentido, acha a palavra). O Recordar invertido é a única "prática" que serve à tese. Terceiro: o ritual diário do Vocabulary não vem do streak — vem de o app ter absorvido a decisão "o que eu estudo hoje?" (Tesler). A fila do dia faz o mesmo pelo Recordar, e é por isso que dispensa a ofensiva.


---

### Whoop / Oura
`poderes: Metacognição · Sentido · Atenção` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A linha de base própria. Whoop e Oura não comparam o autor com a média — comparam com ele mesmo, semanas contra semanas, e avisam quando ele sai do próprio normal. O Traço tem o material para isso sem sensor: hora, gesto, tamanho e ritmo de cada nota. O que muda é a moeda: onde eles devolvem nota de 0 a 100, o Traço devolve pergunta.

**A função, como existe lá.** (1) Oura: *Reports* semanal, mensal, trimestral, anual (exige 60+ noites) e de aniversário a cada seis meses; *Trends* por período. (2) Oura: *Chronotype/Body Clock* inferido dos dados; *Discovery Hub* com correlações entre tags e biometria; Whoop: *Monthly Performance Assessment* com correlações do *Journal* (140–160 comportamentos). (3) Oura: *Smart Tags* sugeridas quando o sono foge do normal; *Symptom Radar* por desvio da linha de base; Whoop: alertas de desvio de vitais. (4) Oura: *Rest Mode*, que pausa a Activity sem culpa. (5) Whoop: *Weekly Plan* com intenções semanais e avaliação às segundas.

**Como entra no Traço.**
1. **Padrões com janela** (Metacognição · Sentido). O §9 lê "as últimas ~12 notas". Passa a ler por janela escolhida pelo algoritmo conforme o corpus aguenta — como o Oura só emite o anual com 60 noites: mês com poucas notas; trimestre com dezenas; e, a partir de um ano de uso, a janela "há um ano". A IA recebe o conjunto e devolve as 2–3 perguntas de sempre; o local tem modelos por janela: "há um ano, em setembro, você escreveu '…' — ainda é verdade?" (o relatório de aniversário reescrito como pergunta). Prova dura do §19.4. Sem seletor na tela: a janela é escolhida, não oferecida (`hicks-law`).
2. **O relógio do autor** (Metacognição). Algoritmo local sobre `criadaEm` × gesto: bandas madrugada/manhã/tarde/noite (as mesmas âncoras do bloco TickTick). Quando o padrão é forte (limiar), uma pergunta local entra no Padrões: "as notas de madrugada são quase todas desabafos; as da manhã, planos — o que isso diz?" Sem limiar, silêncio. É o cronotipo do Oura sem gráfico.
3. **Pergunta no desvio** (Metacognição). A linha de base é do autor: notas por semana, expressivas por mês, tamanho médio. Um desvio (três semanas sem escrever; três expressivas numa semana) não dispara notificação nenhuma — deixa uma pergunta esperando para quando o autor abrir o Padrões (§9: só quando pede). Nunca sobre o conteúdo de expressiva (§8.8): frequência não é conteúdo.
4. **Pausa** (Atenção). No Perfil: "pausar revisões por 7 ou 30 dias". A escada 3→7→21 congela e retoma sem acumular cobrança — nada de "12 notas atrasadas" ao voltar. É o Rest Mode: o app que para de pedir quando o autor diz.

**O poder que traz.** Metacognição longitudinal: o que se repete em semanas é invisível no dia, e o §9 hoje só vê dias. Sentido: reencontrar a própria frase de um ano atrás e ser perguntado se ainda vale é fechar ou reabrir uma linha de sentido com material que o autor esqueceu que tinha. A linha de base própria evita a comparação com norma, que é onde o placar dos dois apps vira ansiedade.

**A estrutura que traz.** Consulta por janela no Padrões (o algoritmo escolhe); modelos locais de pergunta por janela e por banda de hora; índice local de linha de base (notas/semana, expressivas/mês, tamanho médio — não exibido); `pausadoAte: Date?` no Perfil, respeitado pelo agendador de revisões. Nenhum campo novo na Nota.

**O quanto eleva.** 4 — salto grande na Metacognição (de doze notas para anos) e toca Sentido; não abre poder novo.

**O que fica de fora — proposta histórica.** Toda nota: Sleep Score, Readiness, Recovery, Strain 0–21, Stress 0–3, Healthspan e "idade" (§19.1: pontuar, medir progresso e dar nota são proibidos para sempre). Mostradores, anéis, mapas de calor, relatórios em PDF (§9.4: dashboards). Coach e Advisor em chat com memória (§12). Notificações de hora de dormir e de inatividade (a insistência). Teams e Circles (§12). Weekly Plan como revisão semanal obrigatória: sistema que pede manutenção morre.

**O não-óbvio.** A nota de 0 a 100 cria ansiedade não porque é número, mas porque é *recebida* — o autor consome um veredito sobre si. A pergunta é *respondida*: o autor produz. É a mesma distinção da regra de ferro (texto pronto × texto escrito), aplicada ao retorno. E a biometria do Traço já existe: a hora em que se escreve e a forma que se veste são sinais tão longitudinais quanto HRV, e não precisam de anel.


---

### WOOP app
`poderes: Intenção · Atenção` · `eleva: 3/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** A ordem é o método. Resultado antes do obstáculo (contraste mental só funciona nessa sequência), obstáculo interno e não externo, e o plano só depois. O app da Oettingen não deixa burlar. O Traço tem os campos certos e os abre todos de uma vez, em qualquer ordem — e aceita "não tenho tempo" como obstáculo.

**A função, como existe lá.** Fluxo guiado em quatro passos com texto livre, na ordem fixa desejo → melhor resultado → obstáculo interno → plano "se [obstáculo], então eu [ação]"; lista de WOOPs salvos com acompanhamento de progresso; lembretes recorrentes para criar o hábito de fazer WOOP; orientação de fazer WOOP quando calmo e ligá-lo a rotinas (café, almoço); *WOOP Kit* com guia de revisão e refinamento de planos.

**Como entra no Traço.**
1. **Campos em sequência** (Atenção · Intenção). Os três campos do WOOP (§6) nascem um de cada vez: *Resultado* aparece vazio; *Obstáculo interno* só quando Resultado tem texto; *Se… então eu* só quando o obstáculo tem. Algoritmo puro (visibilidade por campo não-vazio). Continua "campo vazio já aberto" (§17.3) — só que um. Vale também para Se–então (Se antes de Então). Muda: §6 ganha "campos nascem em ordem".
2. **Aviso "obstáculo de fora"** (Intenção). O enum de aviso (§5, §19.4) ganha `obstaculoExterno`. Heurística local: campo Obstáculo começando por terceiro ("o chefe", "minha mãe", "o trânsito") ou por falta de recurso ("não tenho tempo/dinheiro"); a IA cobre o resto como algoritmo dinâmico, devolvendo só o rótulo. Frase nossa, do template: "Esse obstáculo é de fora. Qual é o seu, por dentro — o que em você trava?" Sem forma nova, sem texto na nota.
3. **O que já está feito.** O "acompanhamento de progresso" do app é o Recordar (§7) sobre a nota WOOP: recordar o plano no dia 3, 7 e 21 é ensaiar o elo se–então, que é exatamente o mecanismo pelo qual o plano dispara. Nada a construir; registrar no §7 que WOOP e Se–então entram na escada por padrão.

**O poder que traz.** Contraste mental (Oettingen): imaginar o resultado e só então o obstáculo é o que converte desejo em energia para agir — na ordem inversa o efeito some. Intenção de implementação (Gollwitzer): o obstáculo interno é a deixa que o autor controla; "o chefe" não é deixa, é desculpa. A sequência é também uma coisa por tela.

**A estrutura que traz.** Estado de visibilidade por campo na forma (derivado, não persistido); `Aviso.obstaculoExterno` no enum e no system prompt; linha nova na tabela de avisos do §5; regra local no roteador de reserva (§19.2).

**O quanto eleva.** 3 — o WOOP do Traço passa a ser fiel ao método no primeiro uso; o autor sente na primeira nota "quero…".

**O que fica de fora — proposta histórica.** O formulário como porta (§3, §17: o texto vem antes da forma). Lembretes recorrentes "para criar o hábito de fazer WOOP" — cobrança sem deixa, o mesmo erro do Lembretes; a deixa com hora entra pelo bloco TickTick. Lista de WOOPs com progresso (§19.1: medir progresso). WOOP em grupo (§12).

**O não-óbvio.** O app da Oettingen "acompanha o progresso" de um WOOP olhando se o plano se cumpriu. O Traço faz o progresso acontecer: cobrar o plano de memória é o ensaio que deixa o elo se–então acessível na hora em que o obstáculo aparece. O Recordar não é só memória — para as formas de intenção, é o mecanismo de execução.


---

### Write or Die
`poderes: Atenção · Sentido` · `eleva: 2/5` · `esforço: S` · `quando: agora`

**O que vale pegar.** A consequência da pausa, calibrada pelo autor — e a ideia de tirar do texto qualquer motivo para voltar atrás. O Write or Die punia a pausa com som e apagava palavras; o que serve à expressiva é o princípio: continuidade é o método, e nada na tela pode convidar à edição.

**A função, como existe lá.** Modos de consequência Gentle (caixa de aviso), Normal (som até voltar a escrever) e Kamikaze (apaga as palavras de trás para frente); períodos de graça Forgiving, Strict e Evil; desativar o backspace; tela cheia forçada; meta de palavras e limite de tempo. Tudo histórico e de fonte terceira — o produto não está à venda.

**Como entra no Traço.**
1. **Sem juiz na página** (Atenção · Sentido). Durante o timer do §8: `.autocorrectionDisabled()` e verificação ortográfica desligada. Uma linha. O sublinhado vermelho é o app julgando a frase no meio do desabafo — e é o convite para voltar e consertar. A instrução de Pennebaker é não se preocupar com ortografia; o app cumpre tirando o motivo, não bloqueando a tecla.
2. **A pausa visível, sem som** (Atenção). Modo Gentle traduzido: 20 segundos sem tecla e os dígitos do timer perdem contraste (`Tema.tintaFraca`); a primeira tecla os acende. Nenhum toast, nenhum som, nenhuma palavra apagada. Período de graça único. A severidade que o autor calibra é UMA chave no Perfil — "o tempo só conta enquanto escrevo" — desligada por padrão; ligada, a pausa não desconta o timer (o Strict do Write or Die, sem castigo). Muda: §8.1 ganha a nota sobre a pausa.

**O poder que traz.** Escrita expressiva sem auto-edição: o benefício vem de sustentar o fluxo sobre o mesmo evento; parar para corrigir é sair do evento. Atrito calibrável: quem quer o tempo cheio de escrita escolhe uma vez, e o app não pergunta de novo.

**A estrutura que traz.** Dois modificadores no editor sob `gesto == .expressiva && timerAtivo`; um `Bool` no Perfil; o timer passa a contar "tempo escrevendo" quando a chave está ligada (marca de última tecla). Nada na Nota, nada no .md.

**O quanto eleva.** 2 — polimento que se sente na primeira expressiva; o poder está no §8.

**O que fica de fora — proposta histórica.** Som estridente e cor (§15: tom sóbrio). Kamikaze: apagar palavras de trás para frente. Meta de palavras (placar, §19.1). Modo Reward (§12). Word wars (§12). Backspace bloqueado: no teclado do iPhone é castigo, não método.

**O não-óbvio.** A ameaça do Kamikaze — perder o texto — é vazia na expressiva: o texto vai ser selado ou queimado de qualquer jeito; o autor não perde nada que fosse guardar. A única moeda que a sessão tem é continuidade, então a consequência tem de agir sobre o relógio, não sobre o texto. E o jeito mais barato de "não voltar" não é travar o backspace: é tirar o sublinhado que chama de volta.


---

### Zenpen
`poderes: Sentido · Intenção · Metacognição` · `eleva: 4/5` · `esforço: M` · `quando: depois`

**O que vale pegar.** A dose. O Zenpen não vende só o apagar; vende o protocolo de Pennebaker inteiro: 10–15 minutos, por quatro dias, e não todo dia. O Traço fez a sessão e o fecho melhor do que ele — e parou na sessão. A construção de sentido acontece ao longo dos dias, não numa noite.

**A função, como existe lá.** Escrever sem parar por 10–15 minutos, "por 4 dias"; o texto desaparece 30 segundos depois, "inclusive da memória do aparelho"; orientação explícita de não escrever todo dia (citação de Pennebaker); sem login, sem conta, sem nada guardado; timer na tela (05:00 e um segundo contador).

**Como entra no Traço.**
1. **A série de quatro** (Sentido · Intenção). Depois do fecho de uma expressiva (§8.4), uma linha, uma vez: "Amanhã, à mesma hora?" — um toque agenda; ignorar é resposta. Aceito, o app manda no dia seguinte, à mesma hora, uma notificação sem conteúdo ("Continuar — dia 2 de 4"), que abre direto no modo do §8 (o intent do bloco TIDE). No quarto fecho, o que sobrou das quatro — as linhas de sentido, únicas coisas que saem (§8.5); as puladas simplesmente não aparecem — surge junto numa página nova, em cartão fixo não-editável (§9.3, §15), e o autor escreve embaixo o que vê. Cada expressiva continua selada ou queimada por conta própria; a série não abre nenhuma. Faltou um dia: a série segue de onde parou, sem contagem de falha, e morre sozinha após sete dias. Muda: §8 ganha "série de quatro, opcional, pulável"; §12 ganha uma linha: série com fim não é streak (ADR curta); notificação continua sem conteúdo (§19.2).
2. **Não todo dia** (Metacognição). Algoritmo local sobre frequência de expressivas — nunca conteúdo (§8.8). Acima de um limiar (nove em duas semanas, fora de série), uma pergunta local espera no Padrões: "você desabafou nove vezes em duas semanas — o que está pedindo outra coisa que não escrever?" Sem notificação, sem ouvinte (§12): a pergunta devolve o autor ao mundo, como o aviso de pedido de consolo do §5.
3. **O apagar já está feito.** O Queimar do §8.6 destrói por rota e o Zenpen apaga em memória; o que fica de registrar é que "inclusive da memória do aparelho" é o critério de aceite do Queimar: sobrescrever antes de esvaziar, backup regravado, Spotlight refeito. O teste por rota já existe; a frase do Zenpen vale como aceite.

**O poder que traz.** Escrita expressiva na dose em que foi validada: os estudos de Pennebaker são de três a quatro sessões em dias consecutivos sobre o mesmo evento, e o ganho aparece entre as sessões, quando a narrativa se reorganiza. Quatro linhas de sentido lado a lado são a linha de sentido do evento — o que o §8 chama de "o sentido se multiplica", feito visível. Metacognição sobre a frequência protege do lado ruim do mesmo método: ruminar por escrito.

**A estrutura que traz.** `Nota.serie: UUID?` e `Nota.diaDaSerie: Int?` (1–4), persistidos; uma notificação por dia da série com trigger na mesma hora; regra de expiração; página de encerramento com cartão fixo montado pelo algoritmo a partir das `linhaDeSentido` existentes; front matter `serie:` e `dia:` no .md. Índice local de frequência (não exibido).

**O quanto eleva.** 4 — o poder Sentido existe no Traço e dá um salto: da sessão para o arco; a linha de sentido deixa de ser um resíduo e vira o material do quarto dia.

**O que fica de fora — proposta histórica.** Apagar tudo sem separar (o Zenpen destrói a linha de sentido junto — o dossiê já disse). O apagamento em 30 segundos enquanto se escreve: o catálogo não confirma se é fade progressivo ou limpeza; não se constrói sobre o não verificado. O timer de 05:00 (o §8 tem 15). PWA e web (§12).

**O não-óbvio.** O Zenpen erra o que guardar e acerta o que o Traço não viu: a unidade do método não é a sessão, é a série. Selar e queimar resolvem a noite; o sentido se faz entre as noites — e as quatro linhas juntas são a única "releitura" que o método permite, porque não releem a dor, releem o que ficou claro.


---

## A síntese do editor — propostas históricas

Esta síntese conserva prioridades e conclusões de 02/09. “Segundo cérebro é o export” e “único calendário possível” são formulações superadas pela visão de realização e desenvolvimento: exportar é uma capacidade do ambiente; calendário liga intenção, ação e retorno. Não transformar esta lista em backlog aprovado sem verificar SPEC, evidência e necessidades atuais.

Oito lotes escreveram os 71 blocos sem se ler. O que apareceu em vários deles ao
mesmo tempo é o sinal mais forte deste documento: convergência sem combinação.

### Os números

71 blocos: 12 com nota 5, 30 com nota 4, 21 com nota 3, 6 com nota 2, 2 com nota 1.
Quando: 45 "agora", 23 "depois", 3 "nunca" (Just Write, Life Reset, monday.com).

| Poder | Blocos que tocam | Os 5/5 que o abrem |
|---|---|---|
| **Memória** | 22 | Amplenote, Bear, Obsidian, Signal vs Noise, Vocabulary |
| **Atenção** | 26 | iA Writer, Vocabulary |
| **Ordem** | 18 | Amplenote, iA Writer, Notion, TickTick |
| **Linguagem** | 13 | Edda, iA Writer, Signal vs Noise, Vocabulary |
| **Sentido** | 21 | Signal vs Noise |
| **Intenção** | 22 | TickTick |
| **Metacognição** | 22 | Amplenote, Edda, Strava, TickTick, Vocabulary |
| **Captura** | 22 | Fabric, Obsidian, Raycast (iOS), TickTick |
| **Arquivo** | 15 | Bear, Fabric, iA Writer, Notion, Obsidian, Strava |
| **Segundo cérebro** | 20 | Amplenote, Bear, Fabric, iA Writer, Notion, Obsidian, Raycast (iOS), Strava, TickTick |

Os doze de nota 5, por esforço:

| App | Poderes | Esforço |
|---|---|---|
| Obsidian | Segundo cérebro · Arquivo · Captura · Memória | L |
| TickTick | Ordem · Intenção · Segundo cérebro · Metacognição · Captura | L |
| Amplenote | Segundo cérebro · Memória · Ordem · Metacognição | M |
| Bear | Segundo cérebro · Memória · Arquivo | M |
| Edda | Linguagem · Metacognição | M |
| Fabric | Segundo cérebro · Arquivo · Captura | M |
| Notion | Segundo cérebro · Ordem · Arquivo | M |
| Raycast (iOS) | Segundo cérebro · Captura | M |
| Signal vs Noise | Linguagem · Sentido · Memória | M |
| Strava | Segundo cérebro · Metacognição · Arquivo | M |
| Vocabulary | Linguagem · Memória · Atenção · Metacognição | M |
| iA Writer | Linguagem · Segundo cérebro · Arquivo · Atenção · Ordem | M |

### O que vários agentes acharam sem se falar

1. **O segundo cérebro é o export feito direito.** Amplenote, Bear, Craft,
   Fabric, Notion, Obsidian, Raycast, Readwise, Strava, TickTick, Beaver, Mochi
   e o capítulo do arquiteto chegaram, cada um por seu caminho, à mesma
   arquitetura: uma pasta com um `.md` por nota, cabeçalho legível por máquina
   (gesto, cada campo pelo id, linha de sentido, datas, quantas vezes foi
   recordada) e um arquivo-contrato fixo do app dizendo o que a pasta é e o que
   a IA pode fazer com ela: ler, citar literalmente, nunca escrever. Sem
   servidor, sem MCP próprio, sem conta. Vinte blocos pedem o cabeçalho; quinze
   pedem o contrato. Nenhum pediu chat com o corpus.
2. **App Intents que devolvem texto.** Vinte e três blocos querem que Atalhos,
   Siri, Raycast e o botão de Ação leiam o Traço sem abri-lo: uma entidade de
   Nota só com abertas, "notas por gesto", "linhas de sentido", "destaque de
   hoje". Hoje os dois intents que existem abrem o app e não devolvem nada.
3. **Linguagem abre por quatro portas independentes.** Destilar (Signal vs
   Noise: 200, 100, 50, uma frase), Apontar (Edda: frase feita, vago, passiva,
   sem substituto), a lente da língua (iA Writer: adjetivos, advérbios e muletas
   por regra local) e a forma Palavra com a pergunta da muleta (Vocabulary e
   Kindle). Quatro agentes, quatro mecanismos, nenhum com a IA escrevendo. É o
   poder que a tabela marcava como "quase nada hoje" e que sai deste documento
   com o caminho mais claro de todos.
4. **A expressiva em série.** Calm, MindScribber, Rescript, Zenpen, Rosebud e o
   capítulo dos poderes dizem a mesma coisa: o protocolo validado é de três a
   quatro sessões sobre o mesmo evento, e o Traço faz uma. Pela lei do dono na
   ADR 31l, a sessão única é que é o método inventado. A proposta comum: uma
   notificação sem conteúdo abrindo direto em Expressiva nos dias seguintes, e
   no último fecho as linhas de sentido lado a lado, no lugar do "arco
   emocional" que a IA do Rescript escreve.
5. **O Recordar cresce em três direções que não se atrapalham.** A fila do dia
   com uma notificação (Vocabulary), a escada que responde ao silêncio e ao
   toque "cobrar antes" (Anki), e o alvo certo por forma: a destilada cobra a
   frase (Signal vs Noise), o Se–então mostra o Se e cobra o Então (RemNote).
6. **O Destaque sai da nota.** Forest, Apple Wallet, Clear, Taio e Stoic põem a
   única coisa de hoje na tela bloqueada ou na Ilha, como Live Activity ou
   widget interativo, e a âncora da noite a cobra de memória. O texto é do
   autor, uma linha, e nunca a expressiva.
7. **Domínio e âncora de hora.** Dez blocos falam em domínio de vida; o do
   TickTick fecha o desenho: inferido como rótulo de lista fechada, nunca
   arquivado à mão, um toque desfaz. E as três âncoras, manhã, tarde e noite,
   aparecem em TickTick, Stoic e Rosebud como a alternativa honesta ao streak.
8. **O "Se" armado no telefone.** Lembretes, TickTick e Atalhos: quando o campo
   "Se" traz hora ou período, um detector de datas da plataforma agenda UM
   aviso com o título da nota. Não é agenda; é a deixa da intenção de
   implementação chegando na hora dela.
9. **Um furo de código achado três vezes.** Os lotes 5 e 6 e o capítulo do
   arquiteto viram, sem se falar, que o export não leva a linha de sentido e
   que a queimada some inteira, contra o §8 item 5. Já está registrado como
   tarefa separada.

### As dez que eu puxaria primeiro

Ordenadas por poder por esforço, com as dependências respeitadas. As quatro
primeiras cabem numa semana.

1. **Completar o export.** `sentido:`, `id:`, `editada:`, `recordada:`, o
   bloco sem corpo das expressivas fechadas, e o cabeçalho-contrato fixo do
   app. Esforço S. Fecha o furo do §8 e transforma o backup no pacote de
   contexto que o autor sobe num projeto do Claude ou do ChatGPT hoje.
2. **Um `.md` por nota em Documents.** Sem ADR, visível no Arquivos, lido por
   Obsidian e por qualquer conector de pasta com cabo. Esforço S/M.
3. **"Compartilhar como contexto"** na nota aberta e no filtro das Notas. A
   folha do sistema com o `.md` da nota ou do conjunto. Esforço S, uma linha de
   ADR no §12.
4. **A forma Destilar.** Quatro campos com orçamento à vista, contador por
   algoritmo, a frase final vira o cartão e o alvo do Recordar. Esforço M, sem
   ADR. É a primeira porta de Linguagem.
5. **A forma Palavra** com o Look Up nativo do iOS como dicionário e o Recordar
   na direção produtiva: mostra a definição do autor, esconde a palavra.
   Esforço M, emenda ao §6.
6. **A fila do dia do Recordar** com uma notificação na hora do Perfil, uma nota
   por tela, sem contagem. Esforço M, emenda ao §7.
7. **Domínio inferido, nunca arquivado.** Léxico local primeiro, IA como
   algoritmo dinâmico depois, silêncio na dúvida; chip no cartão e nos filtros.
   Esforço M/L; o contrato remoto ganha `dominio`.
8. **O "Se" com hora vira aviso do gatilho**, com as três âncoras. Esforço M,
   ADR curta: aviso de gatilho não é calendário.
9. **A expressiva em série de quatro dias**, com as linhas de sentido reunidas
   no último fecho. Esforço M, emenda ao §8.
10. **App Intents com retorno** e o Destaque na tela bloqueada. Esforço M; a
    rota de saída nova nasce com o teste do selo.

Depois, na ordem: Apontar (Edda, pede o item 7 na lista fechada do §2), a lente
da língua (iA Writer), a escada que responde (Anki), esconder por forma no
Recordar (RemNote), a pasta no iCloud Drive do autor (ADR e conta Apple
Developer, hoje bloqueada), e o companheiro no Mac com MCP só de leitura (L).

### Os ADRs que este documento pede

1. **Seção nova "Segundo cérebro".** A pasta como superfície, o cabeçalho, o
   contrato, só-leitura por construção, e a lista fechada do que sai e do que
   nunca sai. Toca §10, §12 e §19.1.
2. **§12 "sync/nuvem" × iCloud Drive do autor.** Sem servidor e sem conta do
   Traço, sempre; a pasta pode viver no iCloud do autor porque é a nuvem dele.
3. **§12 "compartilhamento" × compartilhar como contexto.** Com pessoas continua
   fora; entregar a própria nota à própria IA é export, e export é algoritmo.
4. **§19.1 "só a voz do autor viaja".** Viaja para a IA do autor por rota que
   ele dispara; trancada, expressiva e queimada não saem por rota nenhuma.
5. **§12 "busca semântica" × pertinência local dos Padrões.** A busca do autor
   segue lexical; a escolha das 12 notas pode usar semelhança local e offline.
6. **§2 lista fechada, item 7: Apontar.** Marcar trecho do autor com rótulo de
   enum, sem substituto. Metade algorítmica entra antes do ADR.
7. **§6 formas novas: Destilar e Palavra; eixo transversal "domínio".**
8. **§12 "agenda" × aviso de gatilho.** O Se com hora agenda um aviso; não é
   calendário.
9. **§8 série de dias.** A expressiva volta nos dias seguintes por notificação
   sem conteúdo; o fecho do último dia reúne as linhas de sentido.
10. **§10 export.** O cabeçalho ganha `id`, `editada`, `recordada`, `estado`,
    `minutos` e `sentido`; o modelo não muda.

### Onde os agentes discordaram, e como fica

- **Recordar com pista ou sem.** O bloco do RemNote pede esconder "por gesto",
  a Vizinhança diz que o diferencial do Traço é cobrar sem pista. Fica assim:
  recall livre é o padrão; a pista só entra quando ela É o método, não uma
  ajuda: o Se–então mostra o Se porque a intenção de implementação é
  justamente ligar a deixa à ação, e a destilada cobra a frase porque a frase
  foi o que o autor fabricou para lembrar.
- **Domínio × "a ordem que vira trabalho".** O capítulo dos poderes avisa; o
  bloco do TickTick responde: inferido, nunca arquivado, um toque desfaz, e a
  conta do dono como prova de que o bibliotecário pede demissão.
- **Texto do autor fora do app.** Live Activity e widget mostram só o Destaque,
  uma linha, por opção; expressiva e trancada nunca. O selo vale para a tela
  bloqueada como vale para o Spotlight.
- **Dicionário próprio ou do sistema.** O Vocabulary tem etimologia e áudio;
  o Traço não constrói nada disso: o Look Up do iOS já mora no menu de seleção
  de todo campo de texto.

### O não-óbvio que fica

**Vocabulary.** A ferramenta que faltava não é a palavra rara de um feed; é
entender as palavras de dentro: a muleta que o autor repete catorze vezes por
mês revela mais que qualquer palavra do dia. E o quiz do Vocabulary é receptivo,
vê a palavra e escolhe o sentido; poder de pensar é produtivo, tem o sentido e
acha a palavra. Por isso o Recordar de uma Palavra corre invertido. O ritual
diário deles não vem do streak, vem de o app ter absorvido a decisão "o que eu
estudo hoje". A fila do dia faz o mesmo pelo Recordar.

**TickTick.** A harmonia de separar trabalho, casa e saúde é real; o que mata é
o autor ser o bibliotecário, e a conta do dono mostra em quantas semanas ele
pede demissão. Separar sem arquivar é o §17 aplicado à Ordem. E o único
calendário que o Traço pode ter sem virar agenda é o das intenções: não o
evento, a deixa do "se" chegando na hora.

**Segundo cérebro.** Não é uma feature a construir; é o export feito direito.
O Fabric precisa de servidor, MCP e API porque o corpus dele mora na nuvem; o
do Traço mora numa pasta, e pasta é a interface que todo agente já fala. O que
o Traço tem e nenhum dos 71 exporta é intenção estruturada: um WOOP é
`resultado`, `obstaculo`, `plano` escritos pelo autor; uma Especificação é
`problema`, `pronto`, `nao`, `restricoes`. Para uma IA, proveniência vale mais
que volume: um corpus onde nada foi escrito por máquina é o único que não
devolve à IA o eco dela mesma. A promessa do Fabric, nunca precisar lembrar, o
Traço recusa para o autor e concede às IAs dele: a mente treina dentro, as
máquinas leem fora, e o Recordar continua cobrando do autor, sem pista, a nota
que o Claude já leu.
