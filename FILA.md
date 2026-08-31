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
- BURACO REVELADO (soma ao P1 do motor de formas): o §12 prevê "menu de
  templates" para o catálogo completo (136 formas) e essa porta AINDA NÃO
  EXISTE na UI — hoje só as 12 da régua têm entrada. O formato de arquivo
  aceita todas (import), mas o autor não tem como criá-las.

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
