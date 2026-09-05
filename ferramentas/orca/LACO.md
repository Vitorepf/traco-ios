# Laço de evolução contínua — registro

Uma linha por volta: data · volta · o que mudou · evidência · commit · cotas (Claude semanal / Fable semanal / Codex semanal).

- 2026-09-05 · checkpoint · WIP do dono congelado antes do laço · — · 9ad639e · 8% / 14% / 62%
- 2026-09-05 · V1 a sábia preserva o que precisa ler · Sabia.swift: montagem com orçamento (pergunta/alvo/memória nunca cortados; retrato e candidatas saem primeiro), transporte recusa em vez de truncar, `conferir` cala sobre evidência cortada em qualquer caminho, `parseVoltaram` estrito; ADR 05m; EVOLUCAO · 17 focados verdes (SabiaOrcamentoTests), suíte integral 565/0 no sim de teste (revisor Fable); revisão: 0 P1, 2 P2 corrigidos (P2.1 código, P2.2 nomeado na ADR), 5 P3 abertos (montagens de instigar/contrapor/recordar/ecos sem teste, cabeçalhos vazios no aparelho); qualidade semântica do modelo sem prova · b9efef3 · 10% / 15% / 63%
  - Processo: implementado pelo Codex antes da ordem do dono de aposentá-lo como implementador; correção P2.1 pelo Opus. Dois workers no mesmo checkout: o build de um quebrou no meio da edição do outro (OficinaTrabalho) e o worker da V2 desligou o simulador de teste da V1 para rodar maestro, matando duas rodadas da suíte — regra reforçada: nunca desligar simulador alheio.
