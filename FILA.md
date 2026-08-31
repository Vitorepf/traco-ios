# FILA — varredura de completude (31/ago, pós-P0)

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
