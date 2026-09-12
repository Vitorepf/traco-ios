# FILA — registros históricos de investigação e entrega

**Todo o registro abaixo é histórico, datado por seção; não é a fila obrigatória atual.** “Aberto”, “fechado”, “garantido”, “lei”, “hoje” e contagens de testes referem-se à respectiva sessão, não certificam o candidato presente. Revalide ocorrência, autorização, prioridade e prova antes de reutilizar qualquer item. Falas e conclusões antigas são preservadas como evidência de evolução, não como instruções vigentes.

A autoridade de propósito é [VISAO-PRODUTO.md](VISAO-PRODUTO.md): intenção→realização→desenvolvimento, com IA autorizada a produzir trabalho delegado e origem preservada. Proibições antigas de toda geração, resposta/resumo, rede, busca semântica ou tema claro não podem ser extraídas deste histórico como veto global. Regras locais de prática, Expressiva e selo continuam conforme [SPEC](SPEC.md) e ADRs vigentes.

**Lei do dono (12/09/2026, fechada):** o app é só dele, em português, no iPhone. Linhas históricas deste arquivo sobre outro idioma, loja, outro aparelho ou leitor de tela estão mortas. Não reabrir, não listar, não “adiar”.

O estado operativo e a distância entre visão e implementação ficam em [EVOLUCAO.md](EVOLUCAO.md), confrontados com código e prova atuais. O processo vigente está em [META.md](META.md). Este arquivo não manda instalar CLI, autenticar conta, executar chamadas pagas, comitar WIP ou retomar campanhas antigas. Evidência científica, disponibilidade e comportamento de serviços citados abaixo não foram reverificados nesta revisão documental.

<details>
<summary>Registro integral das sessões anteriores — histórico, não instruções atuais</summary>

# FILA — varredura nº 2 (31/ago, pós-arrancada 2)

Saída do loop de COMPLETUDE (META-FINAL). Próxima varredura marca o que fechou.

## P1
1. **Motor de auto-forma local (§17)** — detectar lista/verso/desabafo/tarefa na pausa
   e vestir sozinho; "Soltar forma" de um toque; silêncio na dúvida; opt-out. **L**
2. **Parser incremental** — `Caderno.fatias` reparseia tudo a cada tecla
   (CadernoView.swift:25); 10k palavras fluidas exigem cache + reparse por bloco. **M**
3. **Roteador automático de métodos + confiança calibrada (§17)** — campos já abertos
   quando confiança alta; depende do item 1. **M**
4. **Export/backup .md + import** — única proteção do corpus (sem nuvem); trancadas
   nunca se expõem pela rota de export/restauro. **M**
5. **Revisões agendadas** — UserNotifications cobrando o Recordar no dia certo;
   hoje o Recordar só existe se o autor lembrar (viola §17). **M**

## P2
6. **ADR: IA real × SPEC §5** — §5 proíbe api.x.ai; META-FINAL exige. Emendar antes
   de qualquer código de rede. **S** (decisão; implementação L, bloqueada)
7. **pt/en** — zero .lproj; depois das P1 (strings ainda mudam). **M**
8. **App Store** — PrivacyInfo.xcprivacy, DEVELOPMENT_TEAM, metadata; conferir
   deployment target iOS 26.0. **M**
9. **Auditoria Dynamic Type AX1–AX5 + VoiceOver ponta a ponta** — fundação boa,
   falta o passe. **M**
10. **`try? context.save()` silencioso** — gravação da escrita do autor pode falhar
    sem aviso; tratar e testar o fracasso. **S**
11. **Onboarding mínimo** — decidir se o auto-forma JÁ É o onboarding (§17 sugere
    que sim). **S**

## P3
12. **Swipe-back nativo × custom** — Empilha funciona; decidir com ADR de 3 linhas. **S**
13. **Auto-forma com IA real** — bloqueado pelo item 6. **L**

## Fechado nesta arrancada (31/ago)
Reforma da linguagem atômica · 7 dívidas P0 · guarda §8.5 no motor · vazamento do
Recordar · Padrões sem repetição · fecho da expressiva testado · régua 136→12 ·
anexos com ciclo de vida · schema versionado · resíduos pt-PT e "CÓDICE"/"PUXAR" ·
oclusões de translucidez (barra/cartão/régua opacos) · ícone real · §17 na SPEC ·
aceite E2E §13 passando inteiro.


## Varredura nº 2 — atualização
Fechados: §17 fatia 1 (auto-análise) · P1.5 revisões v1 · P1.4 export · P1.2 memo ·
P2.10 save visível · loop r1. Corrigidos na própria varredura: trigger de revisão no
passado (base = max(criadaEm, agora)) · export sem I/O no body (gera no toque) ·
"puxar"→"recordar" na notificação.

Abertos (15): roteador automático §17 passos 3–4 (M) · parser incremental (M) ·
import .md (M) · rota da notificação à nota + permissão no momento certo (M) ·
opt-out por nota (S) · pt/en (M) · App Store (M) · auditoria AX/VoiceOver (M) ·
escada 3→7→21 (M) · IA real (L, bloqueada).

BLOQUEADOS NO DONO: ADR IA real × SPEC §5 · onboarding (nada ou toast) ·
nota apagável ou não (ADR) · swipe-back custom (ADR).


## Varredura nº 3 — atualização (fim da sessão 31/ago)
Fechados nesta rodada: §17 COMPLETO (auto-vestir + Soltar + opt-out por nota) ·
IA real padrão (ADR e) · apagar com atrito (ADR f) · import .md + roundtrip
completo (gesto E campos preservados; labels nunca viram voz) · notificação →
Recordar direto · escada 3→7→21 · corrida do veredito · memo de token · teto do
aviso · permissão honesta · PrivacyInfo.

Abertos (5): parser incremental por bloco (M) · pt/en (M) · auditoria Dynamic
Type/VoiceOver (M) · física nativa do swipe-back (P3, opcional) · App Store
signing/TestFlight (BLOQUEADO: conta Apple Developer do dono).


## Varredura nº 3 — fechamentos finais da sessão
+ Parser 22× (254→11.5ms debug; teste de desempenho permanente contra O(n²)).
+ Auditoria Dynamic Type AX5 no fluxo principal: cartão com teto+rolagem interna
  (não prende mais a UI); página/forma/notas escalam. VoiceOver ponta-a-ponta
  segue como passe manual pendente.

Abertos (4): pt/en (M) · passe manual de VoiceOver (M) · física nativa do
swipe-back (P3 opcional) · App Store signing/TestFlight (BLOQUEADO: conta
Apple Developer do dono).

+ pt/en fatia 1: String Catalog (77 chaves, base pt, en traduzido), developmentRegion
  pt, en.lproj no bundle — "Notes"/"Analyze" renderizando em inglês (evidencia-en.png).
  Teto: literais do SwiftUI localizam; strings dinâmicas (nomes de forma via variável,
  toasts, notificação) precisam de String(localized:) — fatia 2.

FILA FINAL DA SESSÃO — abertos (4): pt/en fatia 2 (strings dinâmicas, S/M) ·
passe manual de VoiceOver (M, requer humano) · física nativa do swipe-back
(P3 opcional, ADR h) · App Store signing/TestFlight (BLOQUEADO: conta Apple
Developer do dono).


## Varredura nº 4 — encerramento (31/ago)
**REGRAS DE FERRO: 5/5 GARANTIDAS** com evidência formal (auditoria no histórico
da sessão): (a) IA nunca escreve — Veredito é lista fechada, campos nascem vazios,
testes expressivaTrancaEAnalisarNaoEscreve/padroesNaoEntraNaNota; (b) trancada
selada em TODAS as rotas — busca, índice, recordar, padrões, export, import, rede,
notificação, apagar, processo morto — cada rota com teste ou guarda citada;
(c) um gesto por sessão — doisGestosAvisom/mesmaFormaESilencio; (d) silêncio
válido — 4 testes; (e) zero chat/streaks/XP/ouvinte/elogio/resumo — varrido.

Fechados na rodada final: prompt remoto responde no idioma do autor · anúncio de
VoiceOver quando a forma se veste sozinha.

ABERTOS (3): App Store signing/TestFlight (BLOQUEADO: conta Apple Developer do
dono) · passe manual de VoiceOver ponta-a-ponta (requer humano com o aparelho) ·
física nativa do swipe-back (P3 OPCIONAL por ADR h).
Nenhum item P1. Nenhum item executável por sessão autônoma.


## Campanha "barra de anos" (31/ago, tarde) — estado
- MOTION: **APROVADO** (rodada 3) — swipe com momentum, pressão assimétrica em
  tudo, cerimônias do vestir e do Revelar, piano de hápticos, chegada que assenta.
- VISUAL: **APROVADO** (rodada 2) — tipografia com música, materiais, timer-
  instrumento, véu material, chips lapidados; P3 aplicados.
- EXPERIÊNCIA dia-200: feitos — soltar preserva respostas · apagar com desfazer ·
  Padrões pelo Grok sem repetir · revisão cumpre-se no Revelar · chave testável ·
  backup automático no Arquivos · busca sem acento · atalhos ⌘ · medida de linha ·
  silêncio explicado 1ª vez.
  ABERTOS (M/L): app fora do app (widget + App Intent + share extension +
  Spotlight) · lista com seções por mês · registro discreto de revisões no
  cartão · contagem de palavras/busca na nota · iPad digno (família 2).

## Digitação viva (31/ago, manhã→meio-dia) — a lista digita como o Notes
FECHADOS:
- Lista numerada/simples digita fluida: `Caderno.continuar` herda o marcador no
  Enter, double-Enter sai da lista; parser tolerante ("3." solto é item).
- Arquitetura nova da edição una: **o campo sob o cursor nunca morre no meio da
  digitação** — prosa+lista edita CRUA num TextEditor só (modo grudento
  `unaCrua`), e a forma veste ao soltar o teclado (ProsaView com gutter).
- ListaViva (per-item TextField) deletada — foco programático por item era a
  raiz das perdas de digitação.
- Mobiliário NUNCA aparece cru: `soProsaELista` derruba o modo cru na hora em
  que o documento ganha código/tabela/citação/anexo (report do dono, 31/ago).
- Clobber de teardown: campo moribundo na troca de branch não reescreve mais o
  documento (guarda no binding da campoUna).
- Flows atualizados: lista-viva (E2E completo digitação→vestir), caderno-lista,
  caderno-numerada, caderno-toque-lista, caderno-tabela, caderno-codigo, aceite
  (pós-§17: a análise chega sozinha).

ABERTOS NOVOS (pedido do dono, 31/ago — prioridade alta):
- **Motor de formas sem fricção (P1)**: apertar "Tabela" na régua deve montar um
  construtor visual ultra-premium (colunas/linhas por toque), nunca exigir
  entender a forma; o mesmo padrão para TODOS os formatos da régua. Hoje a
  tabela abre grid vazio cru — funcional, não premium.
- **"Vestir a nota" (P1)**: um botão que transforma a nota inteira visualmente —
  o autor só escreve; a IA/motor aplica a estrutura visual (títulos, listas,
  destaques) num toque. Versos/estruturas manuais são "o básico"; isso é o
  próximo degrau.
- Vestir automático × dedo a caminho da régua: a forma vestindo no meio de um
  alcance do dedo desloca alvos (visto em E2E). Observar; talvez segurar o
  vestir enquanto há toque em voo.

## Varredura de flows (31/ago, tarde) — bloco 1
- 7 flows órfãos deletados (cena/chamada/duplo/epigrafe/formula/passos/pausa):
  testavam chips que a poda da régua (ADR 31b) removeu da UI.
- Menu das 136 formas (SPEC §12): porta **Todas** na régua (as 12 ficam);
  folha com o resto do catálogo, nomes em português, campos vazios, zero prosa
  da IA. `/tmp/traco-verify/menu-136.png` · `menuNasceFormaForaDaReguaVaziaSemProsaDaIA`.
  (31 ago, grok/menu-136)

## Pesquisa: pool da assinatura no app (31/ago) — CAMINHO EXISTE
Verificado direto no servidor da xAI (`https://auth.x.ai/.well-known/openid-configuration`):
- OAuth de primeira mão, oficial. authorize `/oauth2/authorize`, device code
  `/oauth2/device/code`, token `/oauth2/token`, revoke, userinfo.
- PKCE S256; `token_endpoint_auth_methods` inclui **"none"** → cliente PÚBLICO
  (app móvel) é suportado por design. Grants: authorization_code, refresh_token,
  **device_code**. Escopos: `api:access`, `grok-cli:access`, `offline_access`,
  `conversations:read/write`.
- **Sem `registration_endpoint`** → não dá para registrar client_id próprio; os
  apps usam o cliente compartilhado da xAI (consentimento aparece como Grok
  Build/CLI).
- Gate é por TIER DE CONTA, não por app: SuperGrok padrão ($30) toma 403;
  **Heavy passa** (o plano do dono é Heavy). X Premium+ não serve para API.
- Existe CLI OFICIAL da xAI (`x.ai/cli/install.sh`), `grok login` → token em
  `~/.grok/auth.json`, cobrado no POOL da assinatura, não por token.

IMPLICAÇÃO (P1, decisão do dono pendente): o Traço pode fazer OAuth com
ASWebAuthenticationSession/device-code, guardar token+refresh no Keychain
(Chave.swift já faz), e chamar api.x.ai com Bearer → debita o pool semanal.
Satisfaz ADR 31j (zero token pago). RISCOS: superfície sem doc pública para
devs (pode quebrar), consentimento mostra o cliente compartilhado, gate por
tier pode mudar → fallback local obrigatório em 401/403.
TESTE BARATO ANTES DE CODAR: instalar o CLI oficial e rodar `grok login` na
conta Heavy; se autenticar e inferir, o caminho está confirmado.

### PROVADO na conta do dono (31/ago, tarde)
CLI oficial instalado (grok 1.0.13, ~/.grok/bin, sem sudo). Conta já autenticada
via OIDC em auth.x.ai ("You are logged in with grok.com"), modelos grok-4.6/4.5.
- `grok -p` respondeu → **tier Heavy passa o gate** (nada de 403).
- **Token OAuth da assinatura chamando `https://api.x.ai/v1/chat/completions`
  direto → HTTP 200**, formato OpenAI-compatível idêntico ao que AnaliseRemota
  já usa. Só muda o header: Bearer <access token OIDC> em vez de xai-<chave>.
- Prova de que NÃO é crédito de API: o console do dono está em US$ 0,00 com
  recarga automática desligada — chamada metered seria recusada; retornou 200.
IMPLEMENTAÇÃO NO APP (pronta para decisão): device-code/PKCE em
ASWebAuthenticationSession → access+refresh no Keychain (Chave.swift) → Bearer
em api.x.ai → refresh por offline_access → queda para local em 401/403.
CAVEAT ABERTO: o client_id é o do Grok CLI (cliente público da xAI). O app se
apresentaria com essa identidade; a xAI não publicou registro de cliente próprio
(sem registration_endpoint). Decisão do dono.

## Varredura E2E completa (31/ago, tarde) — a suíte inteira verde
Depois do redesenho de navegação (§20), a varredura de TODOS os flows achou 15
quebrados. Triagem e conserto:
- **Órfãos deletados (2):** chave-grok (a tela de chave não existe mais — ADR 31k)
  e woop-abrir (o cartão manual virou vestir automático — §17).
- **Encadeados → autossuficientes (7):** busca-filtro, busca-foto,
  notas-e-recordar, recordar, recordar-revelar, expressiva-trancar/-fim/-dupla
  dependiam do estado deixado pelo flow anterior. Agora cada um planta o próprio
  estado. Determinismo vale para o teste também (§19.4).
- **Bug REAL encontrado pela varredura:** a confirmação (véu) morava dentro da
  PaginaView; com as duas camadas, sair para o arquivo levava a página — e a
  confirmação ia junto. Movida para a raiz, que é o nível dela.
- **Assert por identificador** onde o texto dependia da árvore de acessibilidade
  (timer-expressiva).
- **Texto de teste NEUTRO** onde a barra de ações precisa continuar viva: "a
  ideia…" casava a heurística de nota permanente, o cartão subia e comia a barra.

## Sessão 01/set (manhã) — auditoria com lei + motor de digitação do título
FECHADOS:
- Busca prendia o teclado (jakobs-law): scrollDismissesKeyboard nas notas.
- Vazio da busca centralizado contra tela de eixo esquerdo (law-of-continuity;
  precedente 9eb6124): agora nasce onde os resultados nasceriam. Glifo
  decorativo removido (critique-visual-hierarchy).
- "Spec" → "Especificação" (ADR 2026-09-01a): único nome de método em inglês;
  rawValue preservado, corpus antigo importa.
- SISTEMA.md emendado onde mentia sobre a tela real (aba âmbar do arquivo,
  âmbar de estado no §20, realce de busca em texto).
- MOTOR: digitação em volta do título consertada NA RAIZ (commit 43cb23a) —
  parser lia conteúdo da linha trimada (espaços morriam a cada tecla em
  título/citação/tarefa); nota só-título era armadilha sem corpo; Enter agora
  desce título→corpo, parágrafo→parágrafo e lista→prosa por adoção de foco.
  LEI MEDIDA: adoção de FocusState só é confiável dentro do branch multi;
  rearme por Task perde teclas; síncrono no onChange segura.
- Degrau de 5pt do TextEditor fora do eixo (Tema.sangriaEditor).
- 3 cenários novos permanentes: titulo-enter-desce, titulo-corpo-lista,
  titulo-nota-reaberta.

ABERTOS DA SESSÃO: rodadas limpas do Portão 1 (2× sem achado) · varredura E2E
3× (nº 1 rodando) · iPhone real (cert Apple Development de Vitor existe —
team W28WF9A5A2; build de aparelho em teste) · citação/editorLinhas fora da
compensação de eixo (auditar com captura antes de mexer).

## Mandato do dono (01/set, ao vivo): "sinto a página" — nota 7 ainda
Palavras dele: páginas como um caderno de folhas; arrastar a nota como quem
arrasta uma folha, fluido e ultra-sensível ("sem senso tático, eu sinto a
página"); queimar tem que ter a folha sendo destruída pelo fogo; estrutura
geral ainda fraca.
- FEITO nesta sessão (julgar em VÍDEO antes de dar por bom):
  · Queima em cena: frente de fogo irregular consome a folha de baixo para
    cima, brasa com tremor, fagulhas subindo (Queima.swift; 2,2s easeIn).
  · Folha no swipe-back da nota aberta: segue o dedo também no Y, inclina
    2,2° na pega, sombra aprofunda no lift (Empilha).
  · Pilha nas Camadas: a escrita RECUA (scale 0,955) sob o arquivo.
  · Toast na língua da casa: cartão raio 12 na margem (era cápsula centrada
    — report do dono).
- ABERTO (P1): folha-VISUAL da nota aberta (papel com borda/profundidade?) ·
  arrastar a nota NA LISTA como folha ("apenas visualizando" — desenho
  pendente) · elevar a estrutura geral (rodadas de crítica com o vídeo).

## Portões da meta (01/set, 11h15) — estado
- PORTÃO 1 (polimento): FECHADO — rodada 1 (página vazia, notas, busca,
  padrões) e rodada 2 (recordar, perfil, expressiva, formas) seguidas, sem
  achado novo com lei.
- PORTÃO 2 (simples e premium): FECHADO para as telas auditadas, capturas em
  scratchpad/rodadas/caps/.
- PORTÃO 3 (estabilidade): suíte 143/27 verde e fuzz verde na revisão; E2E
  3× em curso (varredura nº1 do ensaio: 53 flows, FALHAS: nenhuma); iPhone
  REAL: INSTALADO E LANÇADO (11h51 — devicectl launch app.traco no iPhone
  16 Pro Max do dono, team W28WF9A5A2).


## Varredura 04/set — o aviso invisível (ADR 04a/b/c/d)

**A lei nova, que vale para tudo:** função que o autor não vê, não confirma e
não controla NÃO FOI ENTREGUE. Motor sem superfície é dívida. A varredura passa
a procurar CHAMADA SEM TELA — foi assim que "o que se marca, avisa" (ADR 03d)
viveu cinco dias como promessa que só o código conhecia.

### Fechado nesta rodada
- **Aviso do compromisso com superfície** (ADR 04a): `avisoMinutos` em lista
  fechada (não avisa · na hora · 5/10/15/30 min · 1 h · 2 h · 1 dia), seção
  AVISO na ficha, a promessa dita na HORA REAL ("Toca hoje às 14:00"), sino na
  grade, estado honesto quando o iPhone está com avisos desligados + saída para
  os Ajustes, e o intent falando a promessa por voz.
- **A ficha nascia cortada** — `.presentationDetents([.large, .medium])` NÃO
  escolhe pela ordem; a captura mostrou o médio, com Notas, Apagar e o aviso
  inteiro fora da tela. Só `selection:` decide.
- **O compromisso fora do app** (ADR 04a): widget `TracoProximo` (casa e tela
  bloqueada) e Live Activity `CompromissoVivo` com contagem na Ilha, publicados
  a cada escrita no calendário e ao voltar à cena.
- **Orçamento de avisos** (ADR 04b): o teto de 64 do iOS deixou de ser silêncio
  — `Avisos.cabem` recusa antes, a ficha diz, e o Perfil mostra "n de 64".
- **A escada engolia o aviso** (ADR 04c): `remoto ?? local` matava as quinze
  regex num iPhone com Apple Intelligence e sem conta — os cinco avisos do §5
  eram inalcançáveis e o aceite do §13 falhava na configuração padrão.
  `Sessao.escolher` agora devolve a palavra ao algoritmo quando o modelo cala.
- **Contraste do terceiro cinza** (ADR 04d): `tintaFraca` 3,3:1 → 5,04:1.
- **Backup duplicado** em `trancarExpressivasVencidas` (escrevia o corpus
  inteiro duas vezes por selagem).
- **Divulgação da sábia**: o cartão dizia as 3 notas que voltaram enquanto o
  índice de até 40 viajava; agora conta as duas coisas.
- **Spotlight capado em 200** sem comentário nem fila → 5.000.
- **Teste dependente do relógio**: `conferenciaDevida` lia `.now` por dentro e
  reprovava no minuto das 9h da máquina. O relógio virou parâmetro.
- README: a regra de ferro nº 1 ainda dizia que TODA palavra da tela é do app,
  o que a ADR o revogou (a resposta da sábia é texto do modelo, num cartão).

### Aberto, com a medida que prova
- **Corpus inteiro na main thread** (P1, M): `Corpus.escrever` regrava um .md
  por nota + LEIA-ME + corpus + INDICE a cada conclusão, ×2 pastas, síncrono.
  Medido: 0,19 ms/arquivo no SSD do Mac → **190 ms a 1.000 notas**, e a pasta
  do autor (iCloud) é bem pior. Só a nota que mudou precisa ser reescrita. Não
  foi feito nesta rodada de propósito: é a rota do SELO, e refatorar a rota do
  selo com pressa é como se perde uma garantia.
- **Dois cinzas encostados** (P2, S): `tintaSuave` 5,77:1 e `tintaFraca` 5,04:1
  fazem quase o mesmo papel. Um deve morrer — trabalho de olho.
- **Schema V2 é alvo móvel** (P2, S): `TracoSchemaV2.models = [Nota.self]` e a
  `Nota` já ganhou cinco propriedades desde a versão. Hoje passa (todas com
  default); congelar V2 e bumpar antes do primeiro build de loja.
- **`slow_down` do device-code** ignorado (RFC 8628 §3.5) — FEITO nesta rodada.

### Modo férias (ADR 04e) — fechado nesta rodada
- Interruptor no Perfil com data de volta, "sem data", e "e nos feriados"
  (desligado por padrão). Expira sozinho no arranque e ao voltar à cena.
- Cala a fila do Recordar, a revisão de domingo e a série da expressiva; NÃO
  cala compromisso nem aviso do "Se" — férias não desmarca dentista.
- A fila vira enumerada (14 dias) só quando há silêncio no caminho; sem
  silêncio continua sendo uma repetente, um slot do orçamento.
- Achado do próprio fluxo: os ajustes de liga/desliga do Perfil só respondiam
  no interruptor de 51×31pt. A LINHA inteira passa a alternar (`fitts-law`) —
  e foi isso que deixou a varredura conseguir exercer um ajuste.
- Achado da captura: ligar mostrava "Até 11/09" (fallback do seletor) enquanto
  o estado dizia "sem data" — a tela exibia valor que não valia.
- O compromisso e o aviso do "Se" saem `timeSensitive` (atravessam o Foco);
  a fila, a revisão e a série ficam no nível normal. Mesma linha das férias.
- A fila enumerada também consulta o orçamento de 64 antes de agendar.
- Tocar no aviso do compromisso abre o calendário no dia (o `userInfo` não
  batia com rota nenhuma: o banner era um beco).
- O toast de falha ganhou a volta pelos Ajustes (ADR 03e no calendário).

### Tela bloqueada interativa (ADR 04f) — fechado nesta rodada
- Destaque: círculo que marca a única coisa de hoje na tela bloqueada e na
  Ilha (era botão só no widget da casa).
- Compromisso: "Lembrar em 10 min", com retorno na própria tela ("lembro às
  11:07") e recado honesto quando os avisos estão desligados.
- Os dois intents entram TAMBÉM no alvo do app: `LiveActivityIntent` roda no
  processo do app, e sem o tipo lá o toque falharia calado.
- Desenho refeito depois de "muito fraco" do dono: papel por baixo do material
  do sistema dava cinza sujo e âmbar ocre. Agora tinta semântica + acento
  âmbar, e a hierarquia com o compromisso maior que o relógio.

### Achados de design com lei, ainda abertos (não mexi sem poder julgar na tela)
- **Cabeçalho da ficha do compromisso** (P2, S): ✕ · chip de domínio · Pronto,
  três pesos disputando a mesma linha. O chip é ATRIBUTO e tem peso de AÇÃO
  (`critique-visual-hierarchy`); no editor de evento do iOS o cabeçalho tem só
  sair e concluir, e a taxonomia é uma linha do formulário (`jakobs-law`).
  Proposta: chip desce para uma linha própria acima de NOTAS.
- **Topo das Notas** (P2, S): "Mais recentes" e "Como contexto" são texto puro
  no canto superior — sem affordance (`critique-affordance`), na zona morta do
  polegar (`fitts-law`), e vestidos igual à navegação (`law-of-similarity`).
  Foi o mesmo defeito que o §20 corrigiu no rodapé e não corrigiu no topo.
- **Régua de chips da busca** corta no lado direito sem nenhum sinal de que
  rola (`law-of-continuity`).
- **Densidade do Perfil** (P2, S): o cartão CONTA gasta 60% da primeira tela
  com um parágrafo que se lê uma vez (`critique-information-density`); o
  primeiro AJUSTE só aparece rolando. Não mexi na cópia do dono sem ele.


## Report do dono (05/set, tarde) — "aparece tudo do placeholder" (ADR 05c)
- O campo do calendário copiava a recomendação para dentro ao tocar, e a
  primeira tecla devia substituí-la; na mão, autocorreção, ditado e cursor
  deixavam a frase, e o autor apagava tudo para escrever. Agora o campo
  nunca se preenche sozinho: a recomendação fica no cinza, como exemplo.
  Saíram o preenchimento no foco, a substituição pela primeira tecla e o
  estado `sugestaoNoCampo` (`jakobs-law`, `critique-affordance`).
- Prova: o simulador não tem calendário do sistema, então nenhum fluxo
  exercitava o preenchimento; a prova é a remoção do caminho (não existe
  mais escrita em `agenda.prosa` fora do teclado e do ditado) e os fluxos do
  calendário verdes. O dono confere no aparelho.

 (04/set, noite) — a volta que cobra (ADR 04v)

## Report do dono (05/set, tarde) — "clicar no chip remove? não faz sentido" (ADR 05d)
- Avaliação pedida: "chegar em casa … vou ler" era Casa por EMPATE
  desempatado pela ordem da lista (Casa e Estudo, um ponto cada). Agora
  empate é silêncio, como a ADR 02c já mandava.
- O domínio passa à IA do aparelho (FoundationModels, lista fechada de sete
  mais "nenhum", nunca a rede): o léxico responde na hora e o modelo corrige
  ao salvar, se o autor não travou. Motores desligados = só léxico.
- O chip não apaga mais: abre o menu (os sete, "Sem domínio", e "Devolver
  ao app" quando travado), na lista e no cartão da página. O menu longo da
  nota ganhou o mesmo submenu "Domínio". `ChipDominio` é um só para os dois
  lugares.
- Prova: `CalendarioTests` (empate → nil; `doModelo`), `ColheitaEixosTests`
  (escolher no menu trava e vale na página); `maestro/dominio-no-menu.yaml`
  (TRABALHO → menu → Estudo → ESTUDO); capturas 42 e 43. Suíte inteira 457
  verde.
- O que só o aparelho do dono prova: o modelo de bordo classificando de
  verdade (o simulador corre com os motores desligados).

## Meta do dono (05/set) — "acabamento ultra premium, anos de polimento" (ADR 05f)
### Rodada 1 — o que ele viu e o que a auditoria achou
- Fotografadas 28 telas pelos fluxos de auditoria (folhas de contato no
  scratchpad). Achados com lei e correção: a caixa cinza atrás dos menus
  (rótulo retangular de 44 pt realçado pelo iOS → rótulo é a cápsula, alvo
  no Menu); "Mais recentes"/"Como contexto" sem affordance → cápsula com
  seta e ícone de compartilhar; ficha do compromisso com três pesos no
  cabeçalho → domínio na seção própria; exemplo do campo cortado a meio
  → teto de 30 caracteres; cartão da sábia sem animação em dois estados.
- Prova: fluxos das Notas, do domínio, do calendário e da barra verdes;
  capturas 42, 43 (chip e topo novos) e nav/81 (ficha).
### Visto e não tocado (desenho do dono; decidir no olho)
- Calendário: três barras empilhadas no pé (escalas + Hoje, prosa,
  navegação) — `critique-information-density`. A barra é campanha do dono.
- Escrever: régua de formatação + quatro ações de peso igual + teclado —
  `hicks-law`, `von-restorff-effect`. "Sinto a página" é mandato dele.
- Perfil: o cartão CONTA gasta a primeira tela com um parágrafo que se lê
  uma vez — cópia do dono.
- A régua de chips das Notas cresceu para 29 itens (21 formas + 7 domínios
  + trancadas); a máscara de esmaecimento existe, mas a fila é longa.
  Proposta: formas e domínios em duas linhas, ou um menu "Filtrar".

## Report do dono (05/set, manhã) — "a busca no topo é design pobre; devia estar embaixo e perguntar" (ADR 05e)
- A busca desceu ao pé da tela (`safeAreaInset`), acima da navegação e do
  teclado, e virou "Buscar ou perguntar": escrever filtra (letras e sentido,
  como antes); enviar (seta ou Return) pergunta à sábia, e um cartão sobe
  sobre a barra só enquanto há conversa. As trocas seguintes levam a
  conversa junto. "Fechar" apaga.
- O que viaja: catálogo (nome e definição de cada forma, para dizer qual
  serve), vizinhas da pergunta pelo índice (inteiras até 1.200 caracteres,
  nunca fechada nem expressiva), retrato, últimas quatro trocas. Sistema
  próprio `sistemaResponderNasNotas`.
- Achados na primeira chamada real com o modelo de bordo: (1) ele REPETIA o
  contexto em vez de responder — a pergunta passou a ir primeiro e o pedido
  diz para não citar os blocos; (2) a resposta de 900 caracteres tomava a
  tela inteira — o cartão ganhou teto de 220 pt com rolagem por dentro;
  (3) a falha da sábia ia a um toast que sumia — fica no cartão, onde o
  autor olha.
- Lição do maestro: o `accessibilityIdentifier` num contêiner engole o id
  dos botões filhos na árvore; tocar o botão pelo texto.
- Prova: `PerguntarNasNotasTests` (catálogo, vizinhas, conversa, selo);
  `maestro/barra-de-baixo.yaml` com os motores desligados (filtra, envia,
  cartão diz por onde a sábia responderia, fecha); os nove fluxos de busca
  verdes; suíte 458 verde; capturas 44 e 45.
- Ao vivo, no modelo de bordo (captura 46): "que método uso para criar o
  hábito de correr de manhã?" → "Se–então. Sempre que acordar, quero correr
  de manhã antes do trabalho." — nomeia a forma e dá o exemplo, não escreve
  a nota. Uma palavra solta ("correr") ainda o faz repetir contexto: quem
  envia uma palavra quer buscar, e a busca já respondeu na lista.
- Aberto: "Mais recentes" e "Como contexto" seguem como texto no topo
  (achado antigo com lei); os chips de filtro no topo cortam à direita sem
  sinal de rolagem.

## Laço "Traço 2036" — volta 1 (04/set, noite) — a volta que cobra (ADR 04v)

### Imaginado
O app de 2036 abre o dia já sabendo o que a mente deixou marcado para
conferir: a decisão de há duas semanas, o dia de ontem, a crença de há sete
dias. A cobrança vem antes de ser pedida. As três maiores distâncias vistas:
(1) a volta dos campos `soDepois` só existia com a nota aberta; (2) nada
antecipa o dia pelo calendário + caderno; (3) o limiar de vestir e o teto de
notas que viajam continuam constantes. Escolhida a (1): é a segunda volta do
ciclo com o menor código.

### Fechado
- `Volta` (Modelo): a regra da conferência sai da Sessão e vira uma só para
  a página e para a lista (`devida`, `campoDevido`, `cobranca`).
- Notas abrem com a seção **A VOLTA** quando há campo devido e vazio; a
  linha é a cobrança ("O que roubou o dia?") e o título; um toque abre a
  nota com o campo à espera. Some ao responder. Selo: fechada e expressiva
  nunca entram.
- Prova: `VoltaTests` (Dia à noite/dia seguinte, Atualização aos 7 dias,
  Decisão pela data, selo, cobrança vira pergunta); `maestro/a-volta.sh`
  planta um Dia de ONTEM pela entrada (ADR 04p) e por isso passa em qualquer
  hora do dia; capturas 31 e 32.
- Achado da captura 31: a mesma nota aparecia na volta e no mês com o mesmo
  id dentro do `LazyVStack`, e o SwiftUI descartava a linha do mês. Id
  distinto resolve. Lição: seção que repete nota precisa de id próprio.
- Frase de prova: hoje o autor abre as Notas e vê o que ficou por conferir;
  ontem só via se lembrasse de reabrir a nota certa.

### Volta 2 — o caderno chega antes do compromisso (ADR 04w)
- `DoCadernoView`: a ficha do compromisso (do Traço e do iPhone) ganha
  DO CADERNO — até três notas vizinhas pelo índice de sentido, um toque abre
  a nota. Sem vizinha, sem seção. A ficha do iPhone sobe ao detente grande
  (regra da 04u: deixou de ser folha de uma linha).
- Prova: `DoCadernoTests` (a reunião de orçamento acha a nota do orçamento e
  não a da corrida); `maestro/do-caderno.yaml`; capturas 33 e 34.
- Achado da varredura: `a-volta` e `entrada-do-mac` falhavam a seco na
  varredura inteira porque dependem do `.sh` que planta arquivos. O
  `varrer.sh` passa a correr pelo `.sh` irmão (`entrada.sh` virou
  `entrada-do-mac.sh`), e os `.sh` devolvem o código do maestro.
- Achado do maestro: `centerElement: true` falha em folha curta (não há
  rolagem sobrando para centrar) mesmo com o elemento à vista.
- Frase de prova: hoje o autor abre a reunião e vê o que já pensou sobre
  ela; ontem entrava sem, a não ser que lembrasse e buscasse.

### Volta 3 — o degrau ouve o sinal (ADR 04x)
- `Degraus.instigar(_:sinais:)`: prática mais o ajuste dos dois últimos
  sinais de pergunta da forma (dois "não serviu" descem um, dois "serviu"
  sobem um, 0…4). A Sessão e a Lente passam por ele.
- Perfil, A SÁBIA E VOCÊ: "O que a sábia cobra, por forma: WOOP no degrau
  1 …" — o autor vê o que a IA vai cobrar dele.
- Prova: `DegrausTests.oDegrauOuveOSinal`; `maestro/degrau-no-perfil.yaml`;
  captura 35.
- Achado da varredura inteira (segunda desta noite): quatro fluxos de
  título/caderno falharam por teclas caídas na digitação — o simulador
  degrada depois de hora e meia de varredura; reiniciá-lo resolveu sem tocar
  em código. Lição: falha só em digitação, no fim de varredura longa, pede
  reinício do simulador antes de qualquer diagnóstico.
- Frase de prova: hoje duas "não serviu" mudam a próxima pergunta; ontem a
  sábia cobrava o mesmo degrau até o autor completar a contagem.

### Volta 4 — o anexo entra no sentido (ADR 04y)
- `Indice.expandirAnexos`: o marcador de PDF vira o texto das três
  primeiras páginas (PDFKit, no aparelho, teto 3.000) só para o vetor; a voz
  do autor vem primeiro. `AnexoDisco.pasta/url` viraram `nonisolated` para
  correr fora da main thread.
- Achado: a nota que vinha pela entrada (04p) só entrava no índice de
  sentido no arranque SEGUINTE (`sincronizarIndice` corria antes de
  `recolherEntrada` no `PaginaView`). Agora a entrada sincroniza na hora.
- Prova: `AnexoNoSentidoTests` (PDF gerado no teste; a nota que só diz "o
  relatório está no anexo" é achada por "reunião de orçamento com
  finanças" e a da corrida não); `maestro/anexo-no-sentido.sh` (cupsfilter
  planta o PDF; a busca por sentido acha a nota); captura 36.
- Lição do teste: `draw(at:)` corta a linha na borda da página e o PDFKit
  devolve o texto cortado; `draw(in:)` quebra linha.
- Frase de prova: hoje o autor acha o relatório pelo assunto do relatório;
  ontem só se tivesse escrito o assunto na nota.

### Volta 5 — as ilhas novas se encadeiam (ADR 04z)
- Oito encadeamentos só no `Metodos.json`: Feynman e Analogia → Nota
  permanente; Inversão → Pré-mortem e → Se–então; Steelman → Argumento;
  Divergência → Decisão; Primeiros princípios → Especificação; Prática
  deliberada → Se–então e → compromisso em 7 dias; Atualização → Decisão.
  Zero linhas de Swift: o mecanismo da 04k serviu inteiro.
- Prova: `CatalogoTests.nenhumMetodoEIlhaEOMapaFecha` (nenhum método fora
  das sete folhas terminais é ilha; todo mapa aponta para campos que existem
  dos dois lados); `maestro/ilhas-encadeadas.yaml` (Inversão → Pré-mortem
  com as palavras copiadas e a origem ligada); capturas 37 e 38.
- Frase de prova: hoje o autor leva a inversão ao pré-mortem num toque;
  ontem reescrevia à mão.

### Volta 6 — anotar de qualquer lugar (ADR 05a)
- `Entrada.depositar`: a frase cai em `entrada/` com a hora, pelo caminho
  do Mac. `AnotarIntent` (Siri, Atalhos, botão de Ação; não abre o app; frase
  "Anotar no Traço") e a rota `traco://anotar?texto=…` (recolhe na hora).
- Prova: `AnotarTests` (depósito vira item da entrada e some depois de lido;
  a rota lê o texto e recusa vazio); `maestro/anotar-de-fora.yaml`
  (a rota → "1 nota veio de fora." → a nota na lista); capturas 39 e 40.
  Fluxos da entrada e das rotas do widget repetidos, verdes.
- Frase de prova: hoje o autor diz "Anota no Traço: ligar para o dentista"
  fora do app e a frase vira nota; ontem esperava abrir o app e a página.
- Fora: extensão de compartilhamento (pede app group e provisionamento).

### Volta 7 — o dia diz o que espera (ADR 05b)
- `LinhaDaVolta` sob a data da página em branco: "1 volta a conferir", só
  quando há; um toque abre as Notas na seção A VOLTA. Some ao primeiro
  caractere, como a data.
- Prova: `VoltaTests` (a linha em palavras); `maestro/a-volta.sh` estendido
  (a página em branco mostra a linha, o toque leva a A VOLTA); captura 41.
- Varredura inteira (quarta desta noite, antes desta volta): uma falha,
  `ilhas-encadeadas`, que passou sozinha e passou de novo pelo `varrer.sh`
  junto de `a-volta` e `encadear` no build final. Teclas ou espera no
  simulador a meio da varredura; nenhum código mudou entre as duas.
- Frase de prova: hoje o autor abre o app e a data diz que há uma volta a
  conferir; ontem tinha de ir às Notas para saber.

### Aberto
- Teto de notas que viajam com a pergunta continua constante (40).
- `ilhas-encadeadas` falhou uma vez em varredura inteira e passou três vezes
  fora dela: vigiar; se repetir, subir o `extendedWaitUntil` do `abrir-campos`.
- Simplificação da volta 2: a busca de DO CADERNO subiu para as fichas e a
  seção só existe com vizinha (a versão anterior carregava um `Color.clear`
  que custava 24 pt de espaçamento quando vazia). A ficha do iPhone nasce
  no médio sem vizinha e no grande com (04u respeitada nos dois casos).
- DO CADERNO só olha o título e as notas do compromisso; o domínio do
  compromisso poderia filtrar (o autor liga domínio a compromisso na ficha).

## Varredura 04/set (tarde) — o ciclo da mente (ADRs 04g–04s)

**Palavra do dono:** *"multiplicar a mente do usuário de uma forma
extraordinária, e depois melhorar essa mente, e esse ciclo. Quanto mais a
mente se multiplica, mais a IA multiplica o poder da mente."* A auditoria
mediu o app contra isso e achou catorze buracos; todos fechados nesta rodada,
cada um com ADR, superfície (ADR 04a), teste e fluxo.

### Fechado
- **O sinal** (04h): `Sinais` no disco; "serviu / não serviu" em todo cartão
  com texto de modelo, no Recordar e no Contrapor; Soltar e concluir viram
  sinal; Perfil › "O que o Traço aprendeu de você" + "Esquecer tudo".
- **O retrato** (04i): `Retrato.ler` — formas, obstáculos, o que não voltou,
  calibragem em contagem, palavras, perguntas que não serviram; viaja em
  instigar, responder, contrapor e prova; Perfil mostra o texto EXATO e o
  interruptor. Selo: expressiva/fechada nunca entram.
- **Degraus** (04j): instigar sobe com as notas concluídas da forma (0..4);
  três Soltar seguidos viram SUGERIR em vez de vestir (Perfil diz; abrir uma
  devolve); o caderno que viaja vem do índice.
- **Encadeamentos** (04k): linha DEPOIS DISTO ao pé dos campos; WOOP→Se–então,
  Se–então→compromisso, Decisão→Pré-mortem, Pré-mortem→Se–então/compromisso,
  Spec→Pré-mortem, Argumento→Decisão, Leitura→Nota permanente, Dia→Destaque.
  Palavras copiadas, `[[origem]]` no destino, agenda com aviso.
- **Catálogo como dado** (04l): `Gesto` virou id sobre `Metodos.json`; 21
  métodos (11 novos: Argumento, Leitura, Feynman, Dia, Analogia, Inversão,
  Steelman, Divergência, Primeiros princípios, Prática deliberada,
  Atualização); `Documents/Traço/metodos/*.json` do autor entra ao abrir;
  inválido é dito no Perfil. Roteamento por regex do JSON; Recordar por spec.
- **Contrapor** (04m): `Sabia.contrapor` → {contra, foraDaLista, outroCampo},
  informação nunca instrução (parser recusa imperativo); botão na Lente.
- **Índice de sentido** (04n): `Indice` com NLEmbedding de PALAVRAS pt (a de
  frases não separa nada — medido); Notas › PELO SENTIDO; ecos pelas 40 mais
  próximas; a linha "?" leva as 6 mais próximas da pergunta; Perfil conta e
  refaz.
- **Corpus incremental** (04o): concluir grava só a nota + agregados, fora da
  main thread; as rotas do selo continuam síncronas e inteiras.
- **Entrada do Mac** (04p): `entrada/` lida no arranque e ao voltar à cena
  (Documents e pasta espelhada); MCP `traco_escrever` e
  `traco_metodo_escrever`; toast "n notas vieram de fora"; Perfil explica.
- **Trajetória** (04q): cartão nos Padrões, dois períodos lado a lado, sem
  seta; intent "Trajetória".
- **Doutrina** (04r): instigar só no ATO (primeiro caractere num campo, "Abrir
  os campos", cartão), nunca na pausa; aviso local vence gesto remoto; `aviso`
  saiu do contrato remoto; teto 900 no prompt e no parser.
- **Selo reafirmado** (04s) com teste por rota nova.

Suíte: 444 testes em 102 suítes, verde. Varredura completa (`varrer.sh`, 96
fluxos, os dois vivos incluídos): FALHAS: nenhuma. Fluxos novos: encadear,
metodos-novos, pelo-sentido, trajetoria, perfil-sabia, sinal-solto, e
`maestro/entrada-do-mac.sh` (planta `entrada/do-mac.md` e `metodos/cornell.json` no
contêiner e prova o toast, a nota na lista e "21 do app · 1 seu"). Capturas em
`/tmp/traco-verify/ciclo/`.

### Lições da varredura (para o maestro)
- Um swipe (ou `hideKeyboard`) que comece sobre um botão da folha VIRA TOQUE:
  o encadeamento disparou quatro vezes antes de o teste o ver. Quando o
  elemento já está na tela, não se rola.
- `repeat` parou na primeira volta; os fluxos desenrolam à mão.
- No pé da tela, `scrollUntilVisible` sem `centerElement` deixa a linha atrás
  da barra e o toque cai na barra.
- Perfil cresceu: `scrollUntilVisible` precisa de 25 s, não 8.
- **Defeito real achado pelo fluxo vivo** (`lente-instigar`): Soltar não
  cancelava o veredito em voo, e a forma voltava sozinha um segundo depois.
  `soltarForma` cancela as duas tarefas e o veredito automático respeita
  `autoSuprimidaNaNota` ao chegar.

### Fechado depois da primeira rodada (ADR 04t)
- O modelo do aparelho roteia o catálogo INTEIRO: esquema dinâmico gerado do
  `Metodos.json`, instruções do mesmo arquivo que o prompt remoto.
- A sábia desce ao aparelho sem conta: mesmo prompt, mesmo parser, janela
  menor. As sete superfícies deixam de calar; o cartão diz por onde respondeu.
- A calibragem lê o campo "saldo" (aquém · igual · além) que o autor responde
  na volta da Decisão; a leitura por palavras fica só para as decisões antigas.

### Report do dono ao vivo (04/set, noite) — "o card nasce cortado"
- A Lente abria no detente médio com as perguntas da sábia atrás da borda.
  ADR 04u: folha que se lê ou se preenche nasce no detente grande (Lente,
  Ligações, Versões, série da expressiva, folha dos campos). Lente sem ruído:
  Pronto em texto, título nos tokens, "nada a apontar" na linha de metadados.
  Captura `ciclo/15-lente-depois.png`; fluxos da Lente, Rede, Versões,
  expressiva e forma-folha verdes.

### Última rodada (04/set, noite)
- PDF/epub anexado com prosa ao lado roteia para Leitura (teste
  `pdfAnexadoComProsaViraLeitura`).
- Fluxo `formas-novas`: Argumento, Dia, Divergência, Steelman, Atualização e
  Leitura-com-PDF vestindo na tela, um por um (capturas 16–21).
- Fluxo `cadeia-completa`: WOOP → Se–então → "Conferir o hábito em 7 dias"
  → compromisso no calendário, num só percurso (capturas 22–23).
- Suíte: 446 testes em 103 suítes, verde.

### Aberto
- **O selo, sob prova, nas rotas novas**: cada rota tem teste, e a varredura
  passou; o passe manual de VoiceOver das superfícies novas segue pendente,
  como o das antigas (requer humano com o aparelho).

</details>
