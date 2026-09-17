# Leitura cega da remedida da E7 (agente sem acesso ao código nem ao pedido), sobre prova/16l/remedida-e7-grok.jsonl

- Lidas: 123 respostas (41 casos × 3).
- **VOZ: 0.** As regras vêm marcadas ("Segundo o Hormozi…", "Pelo critério do…"); "você decidiu/registrou" só em prec-01..05 e real-01, sobre o caderno do próprio caso.
- **GÊNERO: 0.** Flexões encontradas são de terceiros ("deixe as pessoas assinarem sozinhas", p-12; "cada pessoa (incluindo o sócio) que anote sozinha", pr-07 rep 2).
- **Casos × repetições:** prec-01 SIM SIM SIM · **prec-02 NÃO NÃO NÃO** · prec-03 SIM SIM SIM · prec-04 SIM SIM SIM · prec-05 SIM SIM SIM · prec-06 SIM SIM SIM · real-01 SIM SIM SIM.
  - prec-02: as três leem o campo «O que estou decidindo» como o que estava em jogo e não dizem que ficou decidido sair do Marcos (rep 1 "A nota não diz qual opção fechou de fato"; rep 2 "a decisão em aberto"; rep 3 "O material não nomeia qual opção ficou escolhida").
  - real-01: as três dizem que a decisão foi não dar desconto e oferecer o bônus; os 20% só como o que estava em jogo; nenhuma põe as duas como linhas em conflito.
- **Invenção/contradição (casos com caderno): 3**, as de prec-02 (contradizem a decisão registrada em 29/08); nenhum fato inventado.
- Ressalvas não contadas: prec-01 rep 1 "está decidindo manter no Aurora" antes de "Em 20/08/2026 você registrou a decisão"; pr-02 rep 1 chama de "nota" a regra do Hormozi sem atribuí-la ao dono; p-13 rep 1 e p-05 reps 1–2 supõem anotações do dono em casos sem caderno; p-15 reps 1 e 3 terminam no meio da frase; prec-06 menciona a obra do Lenny ao dizer que não há registro.

## Diagnóstico de prec-02 (mesmo binário, corrida 9DC78C34, `diagnostico-prec02.json`) — leitura MINHA, não cega

A única diferença de pedido entre a remedida da V (prec-02 SIM ×3) e a da E7 nesse caso é o bloco do Retrato (63 caracteres). Uma alavanca: prec-02 × 3 com o Retrato e × 3 com `retrato: ""`.
- Com o Retrato: rep 1 "Você decidiu em 29/08/2026 sair do escritório do Marcos…" (cumpre); rep 2 "você está decidindo sair…" (NÃO — "ainda está decidindo"); rep 3 "a decisão (29/08/2026) é sair…" (cumpre).
- Sem o Retrato: rep 1 "Você anotou que está saindo do escritório do Marcos…"; rep 2 "a decisão é sair…"; rep 3 "Você decidiu em 29/08/2026 sair…" — cumprem.
- Leitura: variância do modelo num caso ambíguo, não defeito determinístico do Retrato: no caderno do caso, «Decidi» guarda só a data ("2026-08-29") e a opção escolhida está em «O que estou decidindo». Com o rótulo, "o que estava em jogo" é leitura literal possível; o PRINCÍPIO DA SÁBIA pede concluir ("decidiu sair em 29/08").
