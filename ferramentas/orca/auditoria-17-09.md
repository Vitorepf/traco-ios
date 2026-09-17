# Auditoria de experiência — 16→17/09 (segunda, independente)

Estado por item: [ ] aberto · [x] corrigido (commit) · [→] motor (executora) · [=] mantido por decisão do dono (motivo).
Capturas em `auditoria-17-09/NN-*.jpg`.

**Mantidos por decisão do dono (não mexer):** D/S/M/A do calendário e o título com maiúscula (aprovados); abas só com ícone no Dock; a linha do «agora» do calendário (`CalendarioTema.agora`, sancionada); «Hoje» contextual.


**Aparelho:** iPhone 17e `8A5B6500`, com os dados de exemplo.
**Capturas:** estão nesta pasta, em 390×844 pt. Os originais em 3x ficam em `full/` e os vídeos em `video/`. As medidas foram tiradas por pixel dos originais e divididas por 3.
**Perguntas à Sábia:** usei 2 das 3. A segunda foi "Perguntar de novo", porque a primeira resposta foi recolhida.

**O que aconteceu antes de começar:** o app não abria (`spawn failed, error=163: Security policy issue`). O binário instalado às 21:06 estava sem assinatura. Ele é idêntico, byte a byte, ao `.../356e4c2b-.../scratchpad/dd14/Build/.../Traco.app`, que também está sem assinatura. Instalei por cima o build assinado `.../2ff6584d-.../scratchpad/dd-lider/...Traco.app`, das 21:01. Não desinstalei nem apaguei nada, e os dados ficaram intactos. Portanto, **a auditoria vale para o build dd-lider das 21:01**.

**Estado deixado:** separei a «Compras» e juntei de novo; ela voltou a ter «3 versões». Escrevi duas notas de teste: «Reunião com o fornecedor amanhã às 10h…» e «Ideia: testar o café…». Nenhum compromisso foi marcado à mão.

---

## ALTA

### [x] 1. A resposta da Sábia some depois de só abrir uma fonte — 7999e99c (executora): conferido no 17e, abrir a fonte e voltar mantém a resposta
- **Onde:** Conversa. Capturas `49-sabia-fontes.png` → `51-sabia-fonte-nota.png` → `52-volta-da-fonte.png`.
- **Evidência:** a resposta levou cerca de 35 s. Toquei na fonte «Subir o preço do plano anual», só li e toquei em voltar, sem editar nada. A resposta tinha virado «A resposta foi recolhida porque uma fonte mudou ou deixou de estar acessível.» e um botão «Perguntar de novo».
- **Reincidência:** a segunda resposta (`54-resposta-2.png`) também sumiu. Isso aconteceu depois de navegar por Calendário, Padrões e Perfil, sem abrir fonte nenhuma. Vi na tela às 21:44, mas a captura foi sobrescrita.
- **Impacto:** o autor perde a resposta que esperou e paga outra consulta. A regra ensina a não abrir as fontes, justamente o gesto de conferir.
- **Correção:** só recolher quando o hash do texto da fonte mudar de verdade. Abrir sem editar não pode gravar nada. Se a fonte mudou, manter a resposta com uma linha «Uma fonte mudou depois desta resposta · Atualizar».
- **Como verificar:** perguntar, abrir as 3 fontes, voltar. A resposta tem de estar lá, idêntica.

### [x] 2. Índices internos aparecem nas perguntas dos Padrões — executora: título no pedido + guarda de «NOTA n» — dd189095 (executora)
- **Onde:** Padrões › Perguntas. Capturas `67-padroes-perguntas.png` e `68-padroes-rolada.png`.
- **Evidência:** as perguntas trazem textos como «Na NOTA 3 você escreveu…», «…da NOTA 6?» e «NOTA 1 traz… e NOTA 12 menciona…».
- **Impacto:** o autor não sabe qual é a «NOTA 6». A pergunta vira ruído e mostra a costura do prompt.
- **Correção:** trocar os índices pelo título da nota entre aspas antes de exibir. Se sobrar algum índice, descartar a pergunta.
- **Como verificar:** nenhuma pergunta exibida casa com `/\bNOTA\s*\d+/i`.

### [x] 3. A nota vira compromisso sem aviso — executora: toast «Guardada em Notas · marcado …» — a293fbac (executora): toast; «Desfazer» e «Veio da nota» abertos
- **Onde:** página de escrever → Calendário. Capturas `05-digitando-2.png`, `10-concluir-toast.png`, `61-cal-lista.png` e `62-ficha-compromisso.png`.
- **Evidência:** às 21:16 concluí a nota «Reunião com o fornecedor amanhã as 10h…». O único retorno foi «guardada em Notas». No Calendário apareceu «Reunião com o fornecedor», 17/09, das 10:00 às 11:00, com o domínio Trabalho. O arquivo `superficie.json` do App Group foi regravado às 21:16:41 (`geradoEm` 1789604201) já com esse compromisso.
- **Impacto:** um efeito colateral invisível. O autor não sabe que marcou algo, nem como desfazer. A ficha também não liga de volta à nota de origem.
- **Correção:** o retorno do Concluir diz «Guardada em Notas · Marcado qui., 17 set., 10:00», com «Desfazer» e «Ver». A ficha ganha uma linha «Veio da nota «Reunião…»».
- **Como verificar:** concluir uma nota com data e hora. O retorno cita o compromisso, e «Desfazer» remove só o compromisso.

### [x] 4. «3 versões» no cartão, «Nenhuma ainda» nas Alterações — a61099b4
- **Onde:** Notas › toque longo em «Compras» › Alterações. Capturas `15-compras-cartao.png` e `21-alteracoes.png`.
- **Evidência:** o cartão diz «3 versões · 9:00». A folha Alterações diz «Nenhuma ainda. Uma versão nasce a cada gravação que muda o texto.». A mesma palavra, «versão», nomeia duas coisas: notas juntadas e histórico de edição.
- **Impacto:** contradição direta. O autor não confia em nenhuma das duas.
- **Correção:** um nome para cada conceito. Por exemplo, «3 datas» ou «3 listas» para as juntadas, e «Alterações» só para edições. Ou então Alterações mostra também as datas juntadas.
- **Como verificar:** em nenhuma tela a palavra «versão» se refere a duas coisas.

### [x] 5. A IA tem cinco nomes — a61099b4 + 0edadb7c (executora)
- **Onde:** app inteiro. Capturas `11-notas-lista.png`, `46-sabia-espera-1.png`, `34-busca-vazia.png`, `07-lente-a.png` e `73-perfil-3.png`.
- **Evidência:**
  - o campo diz «Fale com o Traço»;
  - a conversa tem o título «Suas notas»;
  - o link diz «Perguntar às suas notas»;
  - a Lente tem a seção «À SÁBIA»;
  - o Perfil diz «A sábia conhece você», com minúscula.
  - O placeholder muda entre «Continue a conversa» e «Pergunte às suas notas» na mesma tela (`47` e `52`).
- **Impacto:** o autor não sabe com quem fala, nem se é a mesma coisa.
- **Correção:** um nome só, por exemplo «Sábia», com maiúscula. O título da conversa é o assunto ou «Sábia», e o campo diz «Pergunte à Sábia».
- **Como verificar:** a busca de strings na UI não acha «Suas notas» como título nem «Fale com o Traço».

### [x] 6. Uma pergunta digitada recebe «Nenhuma nota com…» — a61099b4
- **Onde:** Notas, campo único. Captura `45-pergunta-digitada.png`.
- **Evidência:** digitei «Por que eu sempre adio decidir sobre preço?». A lista sumiu e apareceu, em cinza de 20 pt, «Nenhuma nota com "Por que eu sempre adio decidir sobre preço?"». O caminho certo fica num link âmbar menor abaixo.
- **Impacto:** parece erro antes de o autor enviar, e a lista inteira desaparece.
- **Correção:** quando o texto é pergunta (termina em «?» ou tem 4 palavras ou mais), a primeira linha passa a ser «Perguntar à Sábia: …». As notas que batem ficam abaixo, e «Nenhuma nota» nunca aparece para pergunta.
- **Como verificar:** digitar a mesma frase. A primeira linha é a ação de perguntar.

### [x] 7. Notas ligadas mostram a justificativa da engenharia — a61099b4 + 9a56382a: sem a razão da engenharia e com «Ligar a uma nota…»
- **Onde:** toque longo › Notas ligadas. Captura `22-notas-ligadas.png`.
- **Evidência:** a folha diz «Sugerir notas parecidas está indisponível: a IA deixava de fora justamente as que mais tinham a ver.» e ensina a sintaxe «[[Título]]».
- **Impacto:** é conversa de bastidor e sintaxe de programador num app premium. O estado vazio não tem nenhuma ação.
- **Correção:** apagar a frase. Colocar um botão «Ligar a uma nota…», que abre o mesmo seletor do «Juntar com…». A dica de colchetes vai para Métodos, se for mesmo necessária.
- **Como verificar:** a folha vazia tem 1 título, 1 frase e 1 botão.

### [x] 8. O Perfil fala a língua do código — a61099b4 + Retrato em língua de gente
- **Onde:** Perfil. Capturas `71-perfil.png`, `72-perfil-2.png`, `73-perfil-3.png` e `76-perfil-4.png`.
- **Evidência:**
  - «Formas nos últimos 30 dias (contagem): 12 sem forma · 5 Decisão.»
  - «O que a sábia cobra, por forma: Decisão no degrau 2.»
  - «6 sinais desde 16 de setembro»
  - «vestir a forma»
  - «Notas trancadas e expressivas»
  - «acesso negado — o campo mostra um exemplo»
  - «Arquivos › Traço › metodos», sem acento
  - «Das suas 12 notas abertas», nos Padrões
- **Impacto:** o autor não entende o que controla. «Degrau», «sinal», «forma» e «aberta» são termos internos.
- **Correção:** reescrever com o que o autor vê. Exemplos: «12 notas livres e 5 decisões neste mês», «A Sábia pede mais detalhe nas decisões». Cada seção fica com uma frase de no máximo 2 linhas.
- **Como verificar:** nenhuma das palavras «degrau», «sinais», «forma(s)», «contagem», «trancadas», «expressivas» ou «abertas» aparece na UI.

### [x] 9. «Sair da conta» em vermelho na segunda linha do Perfil — a61099b4
- **Onde:** Perfil › Conta. Captura `71-perfil.png`.
- **Evidência:** a ação destrutiva está em y≈250 pt, logo abaixo da linha de status, no caminho natural do polegar ao rolar.
- **Impacto:** um toque acidental desliga a IA com conta. O Ajustes da Apple põe «Sair» no fim, isolado.
- **Correção:** mover para o fim do Perfil, num grupo próprio, com confirmação em folha de ação.
- **Como verificar:** «Sair da conta» é o último item rolável.

---

## MÉDIA

### [x] 10. «Concluir», «Pronto» e «Fechar» em cinco estilos — b31171b2
- **Evidência:**
  - «Concluir» é preto na nota (`05`) e âmbar na Decisão (`38` e `41`).
  - «Pronto» aparece em pílula preta (`07`, `21`, `62` e `77`) e em texto âmbar no Desenhar (`83`).
  - «Fechar» é uma pílula de vidro na obra (`50`).
  - A ficha do compromisso tem «X» e «Pronto» juntos (`62`).
  - Os Trabalhos têm só «X» (`79`).
- **Impacto:** o mesmo gesto com cara diferente em cada folha, sem previsibilidade.
- **Correção:** confirmar é sempre «Pronto» no mesmo estilo e na mesma posição (canto superior direito). Fechar sem salvar é sempre «X» à esquerda. «Concluir» tem uma cor só.
- **Como verificar:** comparar as 7 capturas lado a lado.

### [x] 11. O botão de voltar tem dois estilos e às vezes mente — b31171b2: só a seta
- **Evidência:**
  - «‹ Notas» é texto fino (`05`), enquanto a conversa usa um círculo de vidro (`46`).
  - Vindo dos Padrões, a pergunta mostra «‹ Notas», mas volta para Padrões (`69` → `70`).
  - Vindo da conversa, a fonte mostra «‹ Notas», mas volta para a conversa (`51` → `52`).
- **Impacto:** o autor perde a noção de onde está.
- **Correção:** um componente de voltar só, com o rótulo da tela de origem, ou só a seta.
- **Como verificar:** entrar por Padrões e por Conversa. O rótulo bate com o destino.

### [~] 12. Âmbar fora da regra — b31171b2: «+», Desfazer, Depois disto, Concluir; ficam o realce da busca, o «agora» e o botão de escrever (aprovados)
- **Evidência:**
  - ícones do menu «+» (`03` e `06`);
  - realce da busca (`33`);
  - linha e pílula do «agora» no Calendário (`57`);
  - «Desfazer» (`25` e `30`);
  - «Perguntar às suas notas» (`34`);
  - «Pré-mortem do que decidi» (`41`);
  - «NAOMI IONITA» (`50`);
  - botão de compor na barra (`11`);
  - «Concluir» na Decisão (`38`);
  - «Pronto» no Desenhar (`83`).
- **Impacto:** o âmbar deixa de sinalizar «seu traço» e «hora de conferir». O sinal se dilui.
- **Correção:** ações, realce e «agora» vão para a cor de ação neutra (tinta ou cinza forte), e a linha do agora fica vermelha como no Calendário da Apple. O âmbar fica só no traço do autor e em «Hora de conferir».
- **Como verificar:** amostrar a cor âmbar em todas as capturas. Ela só aparece nesses dois usos.

### [~] 13. O retorno do Concluir é fraco — b31171b2: ✓ e sombra; a transição da página fica
- **Onde:** capturas `09-concluir-quadros.png` e `10-concluir-toast.png`.
- **Evidência:**
  - O texto some num único quadro de 0,1 s, sem transição.
  - «guardada em Notas» começa com minúscula e não tem ícone nem ação.
  - O toast tem a mesma forma, altura e cor do campo «Fale com o Traço», 16 pt acima dele, e parece um segundo campo.
- **Impacto:** a sensação é de que o texto foi apagado, não guardado.
- **Correção:** animar a página até o ícone de Notas (ou um fade de 250 ms). Toast com elevação, ícone ✓, «Guardada em Notas» e a ação «Abrir».
- **Como verificar:** filmar o Concluir. Há pelo menos 6 quadros de transição.

### [x] 14. Os toasts de Juntar e Separar ficam por cima do conteúdo e somem num corte — a61099b4
- **Onde:** capturas `25-separar.png`, `27-separar-quadros.png`, `30-juntou.png` e `26-desfazer.png`.
- **Evidência:**
  - «Separada das versões» e «Juntada a «Compras»» ficam planos e sem sombra, com o texto do cartão de baixo aparecendo em volta.
  - Somem sem fade depois de cerca de 6 s.
  - Toquei em «Desfazer» logo depois de ele sumir, e o toque abriu a nota «Quero dormir mais cedo…» que estava embaixo.
- **Impacto:** o desfazer é curto e arriscado, e o toque atravessa para abrir outra coisa.
- **Correção:** a cápsula fica acima da barra, não sobre a lista, com sombra, fade de 200 ms e 8 a 10 s de duração (que se renovam ao tocar na tela).
- **Como verificar:** filmar. O toast não cobre nenhum cartão e some com fade.

### [x] 15. «Juntar com…» não mostra as parecidas primeiro — a61099b4 + 63c5e497: parecidas primeiro, prévia e busca
- **Onde:** capturas `23-juntar-com.png` e `29-juntar-apos-separar.png`.
- **Evidência:**
  - Para «Compras», o primeiro item é «Ideia: testar o café…».
  - Quando existem duas «Compras», elas aparecem só com título e data, sem prévia, e ficam indistinguíveis.
  - Não há busca.
  - O botão de sair diz «Pronto», não «Cancelar».
  - A data aparece como «16 de setembro», enquanto a lista usa «21:17».
- **Impacto:** a promessa «as mais parecidas primeiro» não se cumpre, e cresce o risco de juntar a nota errada.
- **Correção:** ordenar por semelhança de título e itens. Mostrar uma linha de prévia. Adicionar busca no topo e o botão «Cancelar».
- **Como verificar:** com duas «Compras» e outras notas, as «Compras» vêm primeiro e têm prévia.

### [~] 16. A busca afirma o que não é verdade — «para» em vez de «com»; a capitalização fica (campo é busca e pergunta)
- **Onde:** capturas `33-busca-resultado.png` e `34a-busca-pilates.png`.
- **Evidência:**
  - «1 nota com "Academia de pilates"», mas a nota não contém «pilates», e o realce some.
  - A consulta é capitalizada («academia» vira «Academia»).
  - A prévia do resultado é «A nova», um fragmento cortado sem reticências.
- **Impacto:** a busca parece imprecisa e a prévia não ajuda a escolher.
- **Correção:** «1 nota parecida» quando o resultado é aproximado. Desligar a autocapitalização do campo. A prévia mostra a frase em volta do termo, com «…».
- **Como verificar:** repetir as duas buscas.

### [x] 17. A busca não tem saída — «x» e compartilhar fixo; falta tocar na aba limpar — a61099b4 + b31171b2: «x» e aba acesa limpa
- **Onde:** capturas `34-busca-vazia.png` e `33`.
- **Evidência:**
  - O campo não tem «x» nem «Cancelar».
  - Tocar na aba Notas já ativa não limpa nem sobe a lista.
  - Só apagando letra por letra ou relançando o app.
  - Com zero resultados, o botão de compartilhar some e a pílula da barra encolhe de 2 para 1 ícone.
- **Impacto:** fica preso num estado de busca e a barra pula.
- **Correção:** «x» de limpar dentro do campo. Tocar na aba ativa limpa a busca e rola ao topo. A barra mantém os mesmos ícones.
- **Como verificar:** buscar e tocar na aba. A lista volta ao estado inicial.

### [x] 18. Compartilhar na lista exporta «traco-contexto» sem explicar — a61099b4
- **Onde:** captura `80-compartilhar.png`.
- **Evidência:** um toque no ícone de compartilhar da lista abre a folha do sistema com «traco-contexto · Documento de Texto · 12 KB». O ícone não diz o que é exportado.
- **Impacto:** o autor não sabe que está levando o contexto das notas para outro lugar. O nome do arquivo é jargão.
- **Correção:** um menu com rótulo claro («Exportar notas para outra IA…») e uma linha explicando o conteúdo. Arquivo com nome legível, por exemplo «Traço — notas 16-09-2026.txt».
- **Como verificar:** o menu tem texto antes da folha do sistema.

### [x] 19. A Decisão abre com o teclado no último campo e a escala vira texto livre — b31171b2 + 63c5e497: escala num toque, abre no topo sem teclado
- **Onde:** capturas `38-decisao.png` e `42-decisao-aquem.png`.
- **Evidência:**
  - Ao abrir uma Decisão para conferir, o foco já está em «O que aconteceu». O teclado cobre metade da tela, e o título e as opções ficam fora de vista.
  - «Ficou aquém, igual ou além do que eu esperava?» é um campo de texto livre.
  - O cursor fica em y≈497 pt, com o teclado começando em y≈517 pt: 20 pt de folga.
- **Impacto:** o autor não relê o que decidiu antes de responder. Três respostas possíveis viram digitação.
- **Correção:** abrir no topo e sem teclado, com «Hora de conferir» rolando para a vista. A escala vira um controle de 3 opções (Aquém · Igual · Além) com alvos de 44 pt. Manter pelo menos 64 pt entre o cursor e o teclado.
- **Como verificar:** abrir a Decisão a conferir. Não há teclado e o título está visível.

### [=] 20. Decisão sem título deixa 80 pt em branco — o espaço é o papel onde se escreve (ADR 09d, piso do papel)
- **Onde:** captura `43-decisao-futura.png`.
- **Evidência:** em «Subir o preço do plano anual», a primeira coisa na página é o rótulo «O que estou decidindo», em y≈203 pt. Entre y≈95 e y≈185 fica um vazio. «As opções» mostra uma só opção («Manter em 90»; em `39`, «Dar o desconto»).
- **Impacto:** a página parece quebrada e a palavra «opções» não bate com o que aparece.
- **Correção:** sem título, usar «O que estou decidindo» como título ou colapsar o espaço. Conferir se as opções guardadas estão todas sendo exibidas.
- **Como verificar:** abrir as duas decisões. Não há espaço vazio e o número de opções bate.

### [~] 21. Datas em seis formatos — Padrões, revisão da semana e hipóteses com o mês (dcd50cb6); o título do calendário com maiúscula é do dono
- **Evidência:**
  - «Quarta-feira, 16 de setembro» (`02`)
  - «16 de Setembro», com maiúscula (`57`)
  - «qua 14, 12:00», sem mês (`66`)
  - «14 de out. de 2026» (`76`)
  - «QUARTA-FEIRA, 14 DE OUTUBRO» (`61`)
  - «qui., 17 de set.» (`62`)
  - «16 de setembro» versus «21:17» para o mesmo dia (`23` e `11`)
- **Impacto:** o autor lê cada tela de um jeito, e «qua 14» é ambíguo.
- **Correção:** um formatador único com três tamanhos (longo, médio, curto), sempre com mês em minúscula e mês presente quando não for a semana atual.
- **Como verificar:** passar todas as capturas por regex. Não há «Setembro» com maiúscula nem dia sem mês fora da semana.

### [~] 22. A resposta da Sábia é um bloco único e as fontes se repetem — alvos de 44 e maiúscula; parágrafos e glossário vão com a executora (E9)
- **Onde:** capturas `47-sabia-resposta-a.png`, `48-sabia-resposta-b.png`, `49-sabia-fontes.png` e `54-resposta-2.png`.
- **Evidência:**
  - A resposta tem mais de 20 linhas sem parágrafo, com «trade-off» e «O material desta consulta não traz…» (meta-linguagem).
  - As fontes aparecem duas vezes: «De "…"» abaixo do texto e de novo na lista «leu 3 notas suas e 1 obra», que começa com minúscula.
  - A obra se chama «Lenny's Podcast — regras conferidas».
  - Os ícones copiar, gostei e não gostei não têm rótulo e têm centros em x≈30, 69 e 106 pt: passo de 38 pt, menor que 44.
- **Impacto:** é difícil de ler no iPhone, a lista de fontes tem ruído e os alvos são pequenos.
- **Correção:** parágrafos de 2 a 3 frases e glossário proibido na saída. Um único bloco de fontes. Barra de ações com passo de 44 pt ou mais, ou num menu «…».
- **Como verificar:** medir o passo dos ícones. A resposta tem pelo menos 2 parágrafos.

### [x] 23. O menu de toque longo tem 9 itens sem grupos — a61099b4
- **Onde:** capturas `20-toque-longo-compras.png` e `24-dominio.png`.
- **Evidência:**
  - Recordar, Enviar para outra IA, Alterações, Notas ligadas, Domínio, Juntar com…, Separar das versões, Selecionar e Apagar ficam numa só pilha.
  - O submenu Domínio não marca o atual: «Casa» sem ✓.
  - «Recordar» e «Enviar para outra IA» não dizem o que fazem.
- **Impacto:** a varredura é lenta, o autor não sabe o estado atual e os itens assustam.
- **Correção:** separadores em 4 grupos (Recordar/Enviar · Alterações/Ligadas/Juntar/Separar · Domínio/Selecionar · Apagar), ✓ no domínio atual e nomes que dizem o resultado.
- **Como verificar:** o menu tem 3 divisórias e o domínio atual tem ✓.

### [ ] 24. Trabalho está escondido e tem nome ambíguo
- **Onde:** capturas `11-notas-lista.png`, `79-trabalhos.png` e `24-dominio.png`.
- **Evidência:**
  - Um dos seis tipos do app fica atrás de uma maleta sem rótulo no topo da lista de Notas.
  - «Trabalhos» (folha), «Trabalhar nisto» (menu +) e «Trabalho» (domínio) são três usos da mesma palavra.
- **Impacto:** o autor não acha o «fazer» e confunde o tipo com a categoria.
- **Correção:** dar lugar próprio ao Trabalho (aba ou seção nomeada) e renomear o domínio, por exemplo para «Profissional».
- **Como verificar:** chegar a Trabalho em 1 toque a partir de um rótulo legível.

### [=] 25. As abas não têm rótulo e a barra muda de lugar — dono aprovou o Dock só com ícones
- **Onde:** capturas `11`, `57`, `66` e `71`.
- **Evidência:**
  - As 4 abas são só ícones, e o de Padrões (flor de pontos) não se explica.
  - A barra «Fale com o Traço» existe em Notas e no Calendário, mas some em Padrões e Perfil.
  - Na página de escrever, a mesma barra tem «+», e na lista não tem.
- **Impacto:** exige memorizar, e a entrada principal da IA aparece e some.
- **Correção:** rótulos curtos nas abas (Notas · Calendário · Padrões · Perfil) e uma barra com a mesma forma e presença em toda raiz.
- **Como verificar:** comparar as 4 raízes.

### [~] 26. Calendário: D/S/M/A ambíguo, alvos pequenos e «Marcar» sem prévia — prévia do Marcar (b31171b2); D/S/M/A mantido pelo dono
- **Onde:** capturas `57`, `58`, `64`, `65` e `82-cal-retorno.png`.
- **Evidência:**
  - «S» é Semana e também Segunda e Sábado na faixa de dias logo acima.
  - Os segmentos têm cerca de 24 pt de largura e 32 pt de altura.
  - «Marcar» não mostra o que entendeu: «Almoço com Ana sexta 13h» não vira nenhuma prévia de dia e hora.
  - O rascunho não enviado continua depois de trocar de aba e fica espremido em duas linhas, com cerca de 120 pt, ao lado de D/S/M/A.
- **Impacto:** o autor erra a visão, erra o toque e manda o compromisso sem saber o dia.
- **Correção:** «Dia · Semana · Mês · Ano», ou um menu com o nome da visão atual. Segmentos de 44 pt. Prévia ao vivo acima do campo («Sex., 18 set. · 13:00–14:00»). O rascunho abre o campo em largura total, ou é descartado com aviso.
- **Como verificar:** digitar o exemplo e ver a prévia. Medir os segmentos.

### [x] 27. Padrões: pergunta aberta desalinhada e hierarquia invertida nas hipóteses — margem e «Descartar pergunta»; falta a ordem título/estado nas hipóteses — a61099b4 + b31171b2
- **Onde:** capturas `69-padroes-pergunta-aberta.png` e `76-perfil-4.png`.
- **Evidência:**
  - O cartão «Pergunta dos Padrões» começa em x=10 pt, enquanto o texto da página está em x=21 pt. O topo do cartão (y=143) fica 3 pt abaixo de «4 para conferir».
  - «soltar a pergunta» é um link cinza em minúscula.
  - Nas hipóteses, o status («esperando · há 1 dia · conferir em 14 de out. de 2026») é o título e a decisão é o subtítulo.
  - «hora de conferir» aparece em cinza minúsculo, não no âmbar «Hora de conferir».
- **Impacto:** fica desalinhado, apertado e com o sujeito errado em destaque.
- **Correção:** margem de 20 pt e 16 pt de espaço acima. «Descartar pergunta» como botão. O título da hipótese é a decisão, o status fica abaixo e «Hora de conferir» fica igual em todo o app.
- **Como verificar:** medir x do cartão = x do texto.

### [x] 28. Versões: o corpo pula ao trocar de data e os chips são pequenos — a61099b4
- **Onde:** capturas `16-compras-pagina.png`, `17-compras-10set.png` e `18-compras-28ago.png`.
- **Evidência:**
  - O título «Compras» fica em y=223, 203 e 175 pt conforme a data: salto de até 48 pt.
  - Os chips de data têm 32 pt de altura (medido de 109 a 141).
  - «Desde 10 de setembro: + Detergente · + Pão de forma · + Maçã · – Leite · – Banana» vem em texto corrido de duas linhas, com + e − sem cor nem estrutura.
- **Impacto:** a leitura salta a cada troca e as diferenças são difíceis de ver.
- **Correção:** reservar altura fixa para a linha «Desde…» (ou colapsá-la numa linha com «+3 −2 ›»). Chips de 44 pt. Adições e remoções em linhas ou com marca visual própria.
- **Como verificar:** trocar as 3 datas. O título não se move.

### [~] 29. Lente: quebra ruim e folha meio vazia — subtítulo e menu; altura da folha fica — a61099b4
- **Onde:** capturas `07-lente-a.png`, `03-mais-menu.png` e `06-mais-com-texto.png`.
- **Evidência:**
  - «24 palavras · 3 frases · nada / a apontar» quebra com cerca de 130 pt livres à direita.
  - A folha média tem cerca de 180 pt vazios abaixo das duas linhas.
  - No menu «+», «Ler como está escrito» ocupa 2 linhas.
  - Com a página vazia, o item está desativado, mas o ícone continua âmbar e com cara de ativo (`03`).
- **Impacto:** o primeiro contato com a Lente parece mal-acabado.
- **Correção:** subtítulo em largura total, folha com altura do conteúdo e menu com largura para uma linha. Item desativado com ícone cinza.
- **Como verificar:** a captura da folha e do menu mostra cada rótulo numa linha só.

### [x] 30. A página nova pula na primeira tecla — a61099b4
- **Onde:** capturas `02-escrever-vazia.png` → `04-digitando.png`.
- **Evidência:** o cabeçalho «Quarta-feira, 16 de setembro / 4 para conferir» some ao primeiro caractere. O cursor, que estava em y≈165 pt, passa a y≈124 pt: um salto de 41 pt.
- **Impacto:** o texto foge do olho no instante de começar a escrever.
- **Correção:** manter o cabeçalho e rolá-lo naturalmente, ou esmaecê-lo sem mudar o layout.
- **Como verificar:** filmar a primeira tecla. A primeira linha não muda de y.

---

## BAIXA

### [x] 31. As decisões a conferir aparecem duas vezes — b31171b2
Os 4 cartões «Hora de conferir» (`37`) reaparecem como cartões comuns na lista «Hoje» (`12` e `13`). **Correção:** omitir da lista quem está no topo, ou marcar o cartão da lista.

### [x] 32. Seções da lista pulam direto para o mês — 08fc2da4
Depois de «Hoje» vem «Setembro» (`14`), sem «Ontem» nem «7 dias anteriores». As Notas da Apple usam esses intervalos. **Correção:** Hoje · Ontem · 7 dias · 30 dias · mês.

### [ ] 33. O título grande não recolhe
«Notas» continua grande ao rolar (`12`), e os cartões passam por baixo com fade. Na Decisão rolada, o conteúdo encosta em «‹ Notas» sem fundo (`41`, em y≈100). **Correção:** título que recolhe para a barra e efeito de borda de rolagem.

### [x] 34. Ficha do compromisso — b31171b2
Linhas com passo de 40 pt, medido em 269, 309, 349 e 390 (`62`). «X» e «Pronto» aparecem juntos. «Abrir os Ajustes» é texto preto sem cara de botão, e «não repete» está em minúscula. **Correção:** linhas de 44 pt, um só botão de fechar e link com cor de ação.

### [~] 35. Visão Ano — 08fc2da4: sem os vizinhos; a faixa da semana fica (aprovada)
Os dias têm cerca de 9 pt, os dias dos meses vizinhos aparecem esmaecidos em todos os meses e há uma faixa azul na semana atual (`60`). **Correção:** tirar os dias vizinhos, usar números maiores e marcar a semana com a cor do sistema.

### [x] 36. Visão Mês — 08fc2da4
A sexta linha inteira é de dias esmaecidos de outubro (`59`). **Correção:** mostrar só as semanas do mês.

### [~] 37. Modo lista do Calendário — ce14a763: lembra a visão; o «A» aceso na lista fica
O modo lista mantém «A» aceso e o título «2026» (`61`). Depois de relançar, o app volta ao modo «D» sem lembrar a escolha (`84`). **Correção:** estado próprio para lista e lembrar a última visão.

### [=] 38. Métodos — «Expressiva» não tem campos para abrir
«Expressiva» não tem chevron, ao contrário das outras linhas (`77`). O conteúdo aberto usa rótulos em caixa-alta colados com 4 pt no parágrafo anterior e começa em x=20, enquanto o título da linha está em x=60 (`78`). O caminho «metodos» aparece sem acento (`76`). **Correção:** chevron em todas as linhas, 12 pt antes de cada rótulo e recuo alinhado ao título.

### [=] 39. Detalhes do Perfil — a medida de 45 caracteres dos parágrafos é deliberada (leitura)
O número no cabeçalho de seção muda de sentido: Calendário 3 são compromissos, Perguntas 3 são perguntas, Métodos 28 são arquivos (`74`, `68` e `76`). As divisórias têm recuos diferentes (`74`). Os parágrafos param em x≈300 pt, enquanto as linhas vão até 370 (`71`). **Correção:** tirar ou rotular os contadores, usar recuo único e texto em largura total.

### [x] 40. Transição de compor — ce14a763
No push da página nova, o teclado sobe ao mesmo tempo e a barra de composição atravessa a tela solta, a meio caminho, em 2 quadros (`81-compor-transicao.png`). **Correção:** subir o teclado depois do fim do push (cerca de 350 ms).

### [x] 41. Fonte aberta a partir da conversa — 63c5e497 (sem foco automático): conferido no 17e, a nota da fonte abre no topo
A fonte abre rolada no meio da Decisão, não no topo (`51`). **Correção:** abrir no topo, ou no trecho citado com destaque.

### [x] 42. «Concluir» sem edição — 828a24cd (executora) + este commit do líder
Abrir uma nota existente já mostra «Concluir» sem nenhuma edição (`16`). As Notas da Apple mostram «OK» só durante a edição. **Correção:** mostrar só com o foco no texto.

### [x] 43. Folha da obra — b31171b2
O título aparece truncado, «Lenny's Podcast — regras conf…», com espaço sobrando embaixo (`50`). **Correção:** título em até 2 linhas, ou o nome da obra no lugar de «regras conferidas».

---

## O que já está excelente
- «Continuar a conversa» no topo das Notas, com «x», retoma sem atrito (`55` → `56`).
- O fio da Decisão e a linha quieta «Conferir em 14 de outubro» (`44`) são claros e elegantes.
- Juntar e Separar têm «Desfazer», e a lista preserva a rolagem ao voltar de uma nota (`19`).
- A Semana em linhas horizontais (`58`) e o Mês com feriado em vermelho (`59`) são originais e legíveis.
- A base visual é calma e coerente: papel cinza-quente, cartões brancos e tipografia do sistema sem enfeite.

## Totais
- **Alta:** 9 (itens 1–9)
- **Média:** 21 (itens 10–30)
- **Baixa:** 13 (itens 31–43)
- **Total:** 43
