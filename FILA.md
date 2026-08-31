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
