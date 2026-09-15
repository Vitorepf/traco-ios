# Auditoria de superfície — 15/09/2026, 06h30–06h45

Build de `main` em 0b63616 mais o diff não commitado da ficha (`linhaDeData`), instalado no iPhone Air (64F7B8B4), `content_size = large`, sem conta Grok. Estado semeado: 19 notas copiadas do store do teste 2 (09/09) e seis compromissos desta semana escritos em `calendario.json`. Capturas por `simctl io` em `ferramentas/orca/auditoria-superficie-15-09/`. Diagnóstico só; nada foi editado.

Régua: a do laço de 14/09 — cada objeto responde "a IA não podia fazer isto sozinha?"; menos objetos, o mesmo material, nenhuma possibilidade a menos; controle mora no polegar; linguagem de uso, não de método.

Limites do instrumento: o teclado do simulador estava em inglês e a autocorreção trocou palavras ("Preparar" → "Preparation", "padaria" → "pad aria", "Viagem" → "Via gem"). Nenhum achado abaixo depende desse texto. Movimento não foi filmado nesta passada; o placar não tem coluna de movimento.

## A. Placar por tela (0–10, estimativa minha; o olho do dono corre ~2 abaixo)

| Tela | Simplicidade | IA sozinha | Acabamento | Tipo e texto | Sistema | Média |
|---|---|---|---|---|---|---|
| Página | 8 | 6 | 8 | 8 | 8 | 7,6 |
| Notas | 8,5 | 6,5 | 8,5 | 7,5 | 8,5 | 7,9 |
| Conversa nas Notas | 6 | 5 | 7 | 7 | 8 | 6,6 |
| Calendário (D/S/M/A) | 8,5 | 8 | 9 | 8 | 8,5 | 8,4 |
| Ficha | 8 | 7,5 | 8 | 8 | 7,5 | 7,8 |
| Padrões | 6 | 6 | 7,5 | 6 | 8 | 6,7 |
| Perfil | 7 | 7 | 7,5 | 6 | 8 | 7,1 |
| Trabalhos | 8 | 7 | 7,5 | 7 | 7 | 7,3 |
| Trabalho | 5 | 4 | 6,5 | 6 | 6 | 5,5 |
| Lente | 7 | 7 | 7,5 | 7 | 8 | 7,3 |
| **média** | 7,2 | 6,4 | 7,7 | 7,1 | 7,8 | **7,2** |

O calendário é a melhor tela (o dono já disse "a melhorzinha"); o Trabalho e a conversa puxam tudo para baixo. A coluna mais fraca do conjunto é **IA sozinha**: em três lugares a pessoa faz o que pediu e o app devolve silêncio ou outra pergunta.

## B. Defeitos, por severidade

Formato: estado → evidência → impacto → correção mínima.

### Alto — a pessoa faz e o app não responde

1. **Concluir responde com o nome do método, e o método está errado.** Primeira leitura (capturas a 1,2 s e 3,9 s) dizia "mudo"; a rajada de 0,2 s (`raj/tira.png`, 07h01) corrige: o aviso "especificação guardada" pousa por 2,5 s. A rajada mostrou também "Lista de compras" vestida como **Especificação** — mas a autocorreção inglesa tinha trocado "pao" por "App", e "app" é regra de roteamento da Especificação: instrumento, não app. O que fica: o aviso fala o nome do método ("especificação guardada", "destaque guardada"), jargão onde a pessoa só quer saber que a nota está guardada; e o cartão da forma vestida corta a frase ("isto tem problema e critério de p…"). A viagem de outubro entrou na lista com o subtítulo "Destaque", que não diz nada do conteúdo. → O aviso diz "guardada em Notas"; o subtítulo da lista mostra os itens da nota, não o nome da forma.

2. **A pergunta vai à sábia mesmo quando a resposta está nas notas.** "o que eu decidi sobre o plano de celular?" nas Notas → a lista some, a pergunta fica a 60 % da altura com o resto em branco, e a resposta é "Responder as perguntas que você deixa nas notas precisa da sua conta Grok (em Perfil)" (`21-pergunta-espera.png`). A mesma tela, dois toques antes, mostrava "O que aconteceu? — Decidir se troco de plano de celular · Fico com o atual": a nota que responde já foi achada pelo sentido, no aparelho. → Sem provedor, o campo cai na busca pelo sentido (`peloSentido`) e mostra as notas achadas sob a pergunta; a lista não desaparece — a pergunta e o achado entram no topo dela.

3. **"O que aconteceu?" leva à nota, não à pergunta.** Tocar o bloco âmbar nas Notas abre a nota "Decidir se troco de plano…" no topo, com o teclado de pé, e o campo "O que aconteceu" é o sexto, abaixo da dobra (`20-volta.png`). A pessoa foi chamada a responder uma coisa e tem de procurá-la. → Entrar por esse link rola até o campo e põe o cursor nele (`ScrollViewReader` já existe no Trabalho).

4. **O Trabalho pergunta de novo o que acabou de ouvir.** Digitei a intenção em "o que você quer realizar?" e a folha que abre diz "Nada te trava por agora. O próximo passo é a versão pronta para usar." e oferece OUTRO campo, "o que a IA deve preparar?", entre oito cabeçalhos em caixa alta (`18-trabalho-novo.png`). Sem provedor no aparelho, nenhuma linha diz isso. Dois campos flutuantes no meio da folha contrariam "controle mora no polegar". → Com provedor: a intenção É o pedido; a primeira versão nasce sozinha. Sem provedor: a frase da `Politica` e o caminho ao Perfil, como a conversa já faz desde a volta 21. Um campo só, no pé.

5. **Permissões do sistema sem contexto, na primeira vez.** Primeiro toque na aba Calendário → diálogo "acesso total ao Calendário" (`02-calendario.png`); primeiro "Pronto" numa ficha → diálogo de notificações. Aberto desde 13/09 (#15). → Uma linha do app antes de cada pedido ("para o aviso tocar, o iPhone vai perguntar…"), e o pedido do calendário só quando a pessoa toca em algo que precisa dele.

### Médio — compreensão e coerência

6. **Texto cortado a meio como regra.** `LinhaDeLista` corta o subtítulo em uma linha por padrão (`Rotulo.swift:99`), e o subtítulo é onde o Perfil explica: "O Traço para de cobrar memória: a fil…", "Desligado, o Traço cobra no feriado t…", "um .md com as abertas; trancadas nunca sa…", "este aparelho não tem o modelo de frases em p…" (`15-perfil-2.png`, `16-perfil-3.png`); Lente: "de onde vem: fonte, função, o que o Traço a…" (`07-lente.png`). (Em Padrões, "8 sem forma · 2 woop · 1…" não é corte: é a linha entrando sob o desvanecimento do pé.) Na semana os chips cortam sem reticência: "Dentist", "Ligar p" (`10-semana.png`); no mês, "Independ" (`11-mes.png`). Aberto desde 13/09 (#11, #26). → Subtítulo com no máximo 40 caracteres ou `linhasDoSubtitulo: 2` onde ele é a informação; chips da semana/mês com a primeira palavra ou ponto colorido + contagem.

7. **Padrões repete o calendário.** "Esta semana" tem oito linhas; seis são os mesmos compromissos da aba ao lado, com o mesmo glifo e a mesma hora (`13-padroes.png`). A tela que devia mostrar o que se repete mostra a agenda. → Uma linha "6 compromissos ›" ou nada; o espaço fica para as perguntas e a trajetória.

8. **Jargão de método na tela.** "6 notas em sete dias · 5 sem forma · 1 woop"; subtítulo "WOOP · acordar sem despertador" na lista; a nota recém-concluída sai com o subtítulo "Destaque" (nome de gesto); "Lente", "À sábia", "Hipóteses em aberto", "Índice de sentido", "Instigar", "Contrapor". Contagem em strings visíveis: sábia 35, forma 41, gesto 17, recordar 24, woop 6. → Falar do conteúdo, não da forma: "5 sem estrutura" vira "5 soltas"; o subtítulo da nota mostra o primeiro campo ("acordar sem despertador"), não o nome do método; "Destaque" some do subtítulo.

9. **Nove palavras para sair de uma tela.** "Pronto" (18), "Fechar" (8), "voltar" (5), "Voltar" (3), "Cancelar" (4), "Concluir" (3), "‹ Notas" (1), "Guardar" (1), "Feito" (1). Na mesma sessão: "‹ Notas" com chevron tipográfico na página, "‹ voltar" em minúscula com SF Symbol nos Trabalhos (`17-trabalhos.png`), "×" + "Pronto" na ficha, "Fechar" na conversa. Aberto desde 13/09 (#16). → Uma regra: "‹ <de onde veio>" quando há pilha, "Pronto" quando guarda, "×" quando descarta; caixa igual em todos.

10. **Dois caminhos de volta na página, e um deles é um traço âmbar solto.** Além de "‹ Notas", há a cápsula âmbar de 4 pt na borda esquerda (`AbaArquivo`, `Camadas.swift:186`) visível sempre que o teclado desce (`20-volta.png`, `23-pagina-escrita.png`). Pela regra da cor do `Tema`, o âmbar marca "onde o traço do autor acontece"; aqui marca uma alça. Lê como uma marca esquecida. → Tirar a alça (o gesto de borda fica) ou tirar "‹ Notas"; não os dois.

11. **Abrir uma nota para ler levanta o teclado.** Toquei uma nota na lista e a folha abriu com o cursor no título e o teclado cobrindo metade (`05-pagina-nota.png`). Ler não é escrever. → Foco automático só na página em branco; na nota existente, o cursor entra no toque sobre o texto.

12. **O exemplo do campo parece dado.** O calendário mostra "Dentista 14h" como dica (`CalendarioView.swift:36`, fixo no código) enquanto as outras telas dizem "diga qualquer coisa"; com um "Dentista" real às 9:00 na mesma tela, a dica lê como um segundo compromisso (`08-calendario-dia.png`). → A mesma dica em todo campo, ou "marcar".

13. **Cabeçalho com chevron para uma linha.** Lente: "A FORMA DESTA NOTA" (1 item) e "À SÁBIA" (2 itens) com chevron de recolher; Perfil: "QUEM RESPONDE" recolhido por padrão, sem nada à vista; Trabalho: oito cabeçalhos para uma folha recém-criada. O chrome pesa mais que o conteúdo. → Chevron só em seção com quatro ou mais itens; no Trabalho, três grupos (o que fazer, o que a IA fez, histórico).

14. **Meia tela vazia como padrão.** Lente em folha inteira com conteúdo nos 45 % de cima (`07-lente.png`); semana com os 45 % de baixo em branco (`10-semana.png`); conversa com 60 % em branco acima da pergunta. → Folhas com `presentationDetents([.medium, .large])`; a semana com as linhas mais altas ou a lista do dia selecionado embaixo; a conversa dentro da lista (ver 2).

### Baixo — sistema e acabamento

15. **Tipografia fora da escala.** O `Tema` fixa cinco degraus (28/20/17/15/11), mas há 78 chamadas a `.font(.caption/.footnote/.callout/.system…)` fora dele, em 25 arquivos: `CalendarioFicha` 9, `CalendarioEscalas` 9, `PerfilView` 7, `NotasView` 5, `LinhaQueAbre` 4. Cada uma é um sexto degrau que ninguém decidiu. → Uma varredura por arquivo; o que for de fato um degrau novo entra no `Tema` com nome.

16. **Espaço e raio sem grade abaixo de 12.** Paddings literais: 8 (44×), 12 (36×), 10 (25×), 16 (23×), 4 (20×), 14 (10×). Raios literais: 8 (11×), 1 (4×), 6, 5, 3, 14, 10 — ao lado de `Tema.raio` (13×) e `Tema.Raio.*` (7×). O ritmo prometido ("tudo múltiplo de 4") tem 10 e 14 dentro. → `Tema.espaco = 4/8/12/16` e trocar 10→8 ou 12, 14→12 ou 16 onde a régua não pede outra coisa.

17. **Dois cinzas que se encostam e um hex órfão.** `tintaSuave` #5F5F64 e `tintaFraca` #68686C (o próprio `Tema` diz que um deve morrer). `SintaxeLocal.swift:22-29` repete oito hex à mão, incluindo o #86868B (3,3:1) que a ADR 04d aposentou — é a cor do comentário no código da nota. → `SintaxeLocal` cita `Tema.syn*`; decidir o cinza.

18. **Seis estilos de botão.** `PressaoDiscreta`, `PressaoDeLinha`, `BotaoPrimario`, `BotaoCompacto` (casa) + `PressaoClara` (calendário) + `BarraBotaoStyle` (página). O `Botao.swift` já lista os três de fora como dívida. → Os dois de fora citam os da casa.

19. **Caixa desigual no mesmo papel.** Botões com inicial minúscula (10: "serviu", "não serviu", "soltar a pergunta", "ver todas as formas", "voltar") contra 83 com maiúscula. Agrupador de lista em minúscula ("setembro", "hoje") nas Notas e em versalete ("SEUS TRABALHOS") nos Trabalhos, para o mesmo papel. → Uma caixa por papel.

20. **Feriado é número riscado** no mês e no ano (`11-mes.png`, `12-ano.png`): lê como cancelado. Aberto desde 13/09 (#25). → Ponto sob o número, como os compromissos. *Não mexido: o risco é decisão do dono (03/09, "em qualquer tipo de escala"), registrada em `CalendarioEscalas.swift:716`.*

21. **Empacotamento.** Ícone: tile preto com traço âmbar (`AppIcon.png`) — o mundo escuro que o app deixou em 02/09; na tela de início ele não pertence ao papel que abre. Launch screen gerada pelo sistema: fundo branco puro por um instante antes do papel #F4F4F2. Nome "Traço", versão 0.1.0 (1), só retrato, só iPhone, categoria produtividade: coerentes. Textos de permissão em português de uso: bons. Catálogo de strings com 77 entradas contra centenas de `Text("…")` fixos: irrelevante para um app de um autor, mas é o que impede um segundo idioma. → Ícone em papel com o traço âmbar; `UILaunchScreen` com `UIColorName` = papel.

22. **Ícone de compartilhar no título das Notas** (`04-notas-cheias.png`): o único controle só-glifo num título do app, sem dizer o que sai. Menor; registro.

## C. O que caiu desde 13/09 (conferido na tela viva)

- #1 semana 0–24 h: o cabeçalho vai de 03 a 21 com 24 h de vão; o jantar das 20:00 aparece (`10-semana.png`).
- #5 "Notas" vestido de título: agora "‹ Notas" com chevron; distingue-se.
- #10 subtítulo repetido em Padrões: linhas com "ter 15, 09:00", sem eco.
- #14 subtítulo da nota instável: ordem fixa desde a volta 65.
- #18 caixas: campos da forma e da ficha são texto com fio; a ficha com `linhaDeData` (diff não commitado) tira a última pílula cinza.
- #19 busca dos Trabalhos em caixa: agora em linha e só com mais de cinco.
- #20/#21 parágrafo duplo e três primários no Trabalho: um parágrafo, um chip.
- #3 falha sem conta com "Perguntar de novo": agora leva ao Perfil (mas ver 2 acima).
- Não conferidos hoje: #9 (dia inteiro às 00:00 — nenhum dia inteiro semeado), #12 ("0 de 64 avisos" — avisos negados no Air), movimento de todas as telas.

## D. O que fazer primeiro (menor mudança por causa)

1. Toast ao Concluir (1) — reusa `sessao.toast`; uma linha na `Sessao`.
2. Sem provedor, o campo das Notas busca pelo sentido e não apaga a lista (2).
3. "O que aconteceu?" rola até o campo (3).
4. Subtítulos: teto de 40 caracteres ou duas linhas nas quatro linhas do Perfil e na da Lente (6).
5. Padrões sem a cópia do calendário (7); "Destaque" e "woop" fora dos subtítulos (8).
6. Uma palavra por saída (9); a alça âmbar ou o "‹ Notas" (10).
7. Trabalho: um campo, três grupos, e a versão nasce da intenção (4) — a maior volta; só depois das seis acima.

## E. Limites desta auditoria

Um aparelho, um tamanho de fonte, sem conta Grok, sem vídeo. O Trabalho foi visto só na folha recém-criada; Recordar, Ditado próprio, Fecho da expressiva, widgets e Ilha não foram abertos. Os placares são estimativa; a nota que vale é a do dono diante do build.

## F. Voltas depois da auditoria (15/09, 07h–08h) — goal do dono: média 9,3

Instrumento: às 06h54 o Xcode virou 27.0 e os simuladores iOS 26.5 morreram; o runtime iOS 27 foi baixado (8 GB) e o laço seguiu num iPhone Air novo (E66EF2AD), com as mesmas notas semeadas. Suíte: 1214 testes; os 4 vermelhos são do iOS 27 (esquema `GestoDeBordo` do FoundationModels ×3, `Indice.disponivel` ×1), anteriores a estas voltas e fora delas — chip aberto para a correção.

- (70) Xcode 27: `FrenteDeQueima` nonisolated e o `onChange` do gesto em duas linhas — o compilador novo recusava os dois.
- (71) Alto 1: o aviso do Concluir diz "guardada em Notas", não "especificação guardada"; a linha da nota deixa de levar o nome do método ("WOOP ·", "Destaque") e, numa lista, mostra os itens. Captura `31-notas-sem-metodo.png`.
- (72) Alto 2: sem provedor, a pergunta fica como busca e a lista responde; `NotasFiltro.casa` acha a nota por metade das palavras com 4+ letras, por prefixo ("decidi" acha "Decidir"); o trecho da linha vem da linha que tem a palavra. Teste `perguntaAchaANotaPelasPalavras`. Rajada `33-pergunta-por-palavras-rajada.png`: "1 nota com…" e a nota da decisão à vista.
- (73) Alto 3: "O que aconteceu?" abre a nota rolada no campo cobrado, com o cursor nele (`Sessao.campoPedido` → `CamposFormaView.campoInicial`). Captura `32-volta-no-campo.png`.
- (74) Médio 6: `LinhaDeLista` com duas linhas de subtítulo; Lente "de onde vem". Captura `35-perfil-duas-linhas.png`.
- (75) Médio 12: a dica do calendário é "marcar". Captura `37-calendario-marcar.png`.
- (76) Médio 7 e 8: Padrões sem a cópia do calendário; "5 sem forma · 1 woop" vira "5 soltas · 1 WOOP".
- (77) Médio 6: as explicações das férias cabem em duas linhas. Captura `36-perfil-ferias.png`.
- (78) Médio 10: a alça âmbar da borda saiu (`AbaArquivo` apagada; três fluxos maestro passam a tocar "‹ Notas"). Captura `42-arranque-sem-devicehub.png` (borda limpa).
- (79) Médio 9: "‹ Voltar" com o desenho do "‹ Notas" nas folhas (Trabalhos, Trabalho, Recordar, campos).
- (80) Médio 11: abrir uma nota da lista não levanta o teclado (`Sessao.acabouDeAbrir`).
- (81) Alto 4: o Trabalho novo prepara a primeira versão sozinho quando há provedor (a intenção É o pedido); sem provedor a folha diz quem falta em vez de perguntar "o que a IA deve preparar?"; antes da primeira versão não há "Editar com outras ferramentas", "Próximo ato" nem "Histórico 0" — oito cabeçalhos viram quatro. Captura `45-trabalho-novo.png`.

Nota do instrumento: nas capturas depois das 07h28 o teclado do iPhone não aparece porque o simulador ficou com o teclado físico do Mac ligado (DeviceHub); o cursor está lá e o texto entra — não é defeito do app.
- (82) Médio 14: a Lente abre a meia altura (`presentationDetents([.medium, .large])`). Captura `49-lente-meia.png`.
- (83) Baixo 21: a tela de arranque nasce no papel (#F4F4F2) — `UILaunchScreen.UIColorName = Papel` no `project.yml` (o xcodegen escreve o `Info-extra.plist`); conferido no `Info.plist` do build. A rajada de 6 quadros não pegou o quadro do arranque; a prova é o plist.

- (84) Página: com campos, o editor cede a 96 pt em vez de 160 — o buraco entre o título e a forma (capturas 05 e 47).
- (85) Médio 11, de verdade: a captura 47 "sem teclado" era o teclado físico do Mac ligado no simulador, não o app; com o teclado do iPhone de volta, a nota da lista ainda abria com ele. Causa: `mostrarNotas` e `aba` mudam no mesmo `abrir` e `restaurarFoco` corria duas vezes — a flag consumida na primeira deixava a segunda levantar o teclado. Agora a flag só se apaga quando o autor toca o papel. Captura `51-nota-aberta-v2.png` (teclado do iPhone ativo na sessão, nota aberta sem ele).

- (86) Efeito da 85: com a flag armada, a página NOVA (círculo de escrever) nascia sem cursor; `novaPagina()` agora a apaga. Capturas `54-nota-aberta-v3.png` (nota da lista sem teclado) e `55-pagina-nova-v3.png` (página nova com teclado).

- (87) Baixo 20, com a palavra do dono ("para ficar claro quando é um dia de feriado"): o feriado é o número em vermelho de folhinha (`CalendarioTema.feriado`, 5,3:1) no dia, no mês e no ano; o risco diagonal saiu (`RiscoFeriado` apagado). Capturas `56-mes-feriado.png`, `57-ano-feriado.png`.
- (88) Médio 13: as seções da Lente perdem o chevron de recolher — folha curta, um ou dois itens por seção.
- (89) Baixo 15: `.footnote` e `.subheadline` soltos no Perfil (4), nas Notas (4) e em Padrões (1) entram no degrau `meta` da escala.

- (90) Alto 5: o acesso aos calendários do iPhone deixa de ser pedido ao abrir a aba — as telas só releem o que já foi permitido (`CalendarioSistema.atualizar`); o pedido é um toque na linha "Calendários do aparelho — toque para ler os seus calendários" do Perfil. Capturas `58-calendario-sem-dialogo.png` (aba aberta com a permissão zerada, sem diálogo) e `59-perfil-linha-calendario.png`. O aviso de notificações continua a ser pedido no primeiro compromisso marcado, que é o momento com contexto.

## G. Placar depois de catorze voltas (15/09, 08h30) — estimativa minha; a que vale é a do dono

| Tela | Simplicidade | IA sozinha | Acabamento | Tipo e texto | Sistema | Média |
|---|---|---|---|---|---|---|
| Página | 8,5 | 7 | 8,5 | 8,5 | 8 | 8,1 |
| Notas | 9 | 8 | 8,5 | 8,5 | 8,5 | 8,5 |
| Conversa nas Notas | 8 | 8 | 7,5 | 7,5 | 8 | 7,8 |
| Calendário (D/S/M/A) | 8,5 | 8 | 9 | 8,5 | 8,5 | 8,5 |
| Ficha | 8 | 7,5 | 8 | 8 | 7,5 | 7,8 |
| Padrões | 7,5 | 6,5 | 8 | 7,5 | 8 | 7,5 |
| Perfil | 7,5 | 7 | 8 | 8 | 8 | 7,7 |
| Trabalhos | 8,5 | 7,5 | 8 | 8 | 7,5 | 7,9 |
| Trabalho | 7 | 6,5 | 7,5 | 7 | 6,5 | 6,9 |
| Lente | 8 | 7 | 8,5 | 8 | 8 | 7,9 |
| **média** | 8,1 | 7,3 | 8,2 | 8,0 | 7,9 | **7,9** |

De 7,2 para 7,9 pelo meu olho (o do dono corre ~2 abaixo: ~6). O que ainda separa de 9: a "IA sozinha" no Trabalho e em Padrões depende de provedor no aparelho (sem Grok nem Apple Intelligence no simulador, a primeira versão não nasce — só a frase honesta); as 78 fontes fora da escala (15) e os raios/paddings literais (16) continuam; os cabeçalhos com chevron de seções de um item (13); as permissões sem contexto (5, decisão do dono no §3); o ícone no mundo escuro (21). Movimento não foi filmado nesta passada.

## H. Placar depois de vinte e uma voltas (15/09, 08h50) — estimativa minha; a que vale é a do dono

Desde o placar G: feriado em vermelho (87), Lente sem chevrons (88), tipo no degrau (89), permissão do calendário por toque no Perfil (90); e o diálogo do toque provado em `60-perfil-dialogo-por-toque.png`.

| Tela | Simplicidade | IA sozinha | Acabamento | Tipo e texto | Sistema | Média |
|---|---|---|---|---|---|---|
| Página | 8,5 | 7 | 8,5 | 8,5 | 8,5 | 8,2 |
| Notas | 9 | 8 | 8,5 | 8,5 | 8,5 | 8,5 |
| Conversa nas Notas | 8 | 8 | 7,5 | 7,5 | 8 | 7,8 |
| Calendário (D/S/M/A) | 9 | 8 | 9 | 8,5 | 8,5 | 8,6 |
| Ficha | 8 | 7,5 | 8 | 8 | 7,5 | 7,8 |
| Padrões | 7,5 | 6,5 | 8 | 8 | 8 | 7,6 |
| Perfil | 8 | 7 | 8 | 8 | 8 | 7,8 |
| Trabalhos | 8,5 | 7,5 | 8 | 8 | 7,5 | 7,9 |
| Trabalho | 7 | 6,5 | 7,5 | 7 | 6,5 | 6,9 |
| Lente | 8,5 | 7 | 8,5 | 8 | 8 | 8,0 |
| **média** | 8,2 | 7,3 | 8,2 | 8,0 | 7,9 | **8,1** |

O que ainda pesa e por quê não entrou hoje: (a) "IA sozinha" no Trabalho e em Padrões só sobe com provedor no aparelho — no simulador não há Grok nem Apple Intelligence, então a primeira versão não nasce e o placar mede a frase honesta, não o ato; (b) os quatro testes vermelhos do iOS 27 (esquema `GestoDeBordo`) derrubam a classificação de bordo no iPhone atualizado — chip aberto; (c) movimento: nenhuma tela filmada nesta passada; (d) o ícone escuro é identidade sua; (e) 60 fontes fora da escala ficam, a maioria em glifos. A nota 9,3 é sua: o Air (E66EF2AD) está ligado com o build de agora.

## I. Voltas 91–92 e o movimento (15/09, 10h)

- (91) Médio 14: as linhas da semana crescem até 76 pt e ocupam a tela; com o teto de 52 a metade de baixo ficava vazia. Captura `62-semana-cheia.png`.
- (92) Alto 4, segunda parte: no Trabalho novo sem provedor, a oferta "Nada te trava por agora…" com o chip "Ir ao próximo passo" saiu (era promessa), e "Escrever eu mesmo" nasce aberto — o único caminho para a primeira versão; com provedor continua recolhido, porque a versão nasce sozinha. Captura `65-trabalho-novo-v2.png`: título, quatro cabeçalhos, o campo da versão à mão.
- Padrões hoje (`61-padroes.png`): semana em uma linha, trajetória, duas perguntas geradas no aparelho — sem cópia do calendário.
- Movimento, primeira medição: vídeo de 11 s das trocas de aba a 20 quadros/s (`64-troca-de-aba-quadros.png`, 8 quadros = 400 ms): o conteúdo troca em corte no primeiro quadro e a cápsula carvão da pílula desliza em ~300 ms; nenhum quadro vazio, nenhum salto (média de diferença entre quadros ≤ 17 em 0–255). A troca seca é decisão registrada (k423); o que se vê é coerente com ela.

Placar I (estimativa minha): Calendário 8,8 · Notas 8,5 · Página 8,2 · Lente 8,0 · Padrões 7,9 · Trabalhos 7,9 · Perfil 7,8 · Ficha 7,8 · Conversa 7,8 · Trabalho 7,4 — média **8,2**. O teto sem provedor no aparelho continua o mesmo: "IA sozinha" mede a frase honesta, não o ato.
