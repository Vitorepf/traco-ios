# Correções da volta 6 — relato do implementador (05/09/2026)

Branch Vitorepf/volta-6-pratica. Commits: a9e3e82 (evidência da revisão, arquivos do revisor) e **ad99974** (correções).

## O que mudou
- P1 — `MotorTrabalho.produzir`: em `praticaPedida`, preparação que não sai lança `Erro.praticaIndisponivel`; NUNCA cai na produção delegada. `OficinaTrabalho.gerar` marca o pedido `EstadoPedido.praticaIndisponivel` (novo caso, aditivo; persiste no disco). Tela: linha "A preparação da prática não ficou disponível neste aparelho; o pedido foi guardado. Você pode escrever sua tentativa mesmo assim." com o campo "Minha tentativa". `guardarTentativa(artefatoID: UUID?)`: nil = tentativa sem exercício, ação própria "Praticar por conta própria" (não toma emprestado um ato da pessoa), sem feedback (validação recusa conferência sem prática).
- P2-B — bloco "Apoio para a próxima tentativa" removido de `retorno(o)`; hipótese só nasce por `proporHipotese` com `propostaPor`; hipóteses listadas uma vez.
- P2-C, decisão (b) — `PraticaTrabalho.oferta(contaLigada:)`; `prepararPratica` e `conferirTentativa` exigem `ContaGrok.ligada` (no motor, não só na tela); sem conta: nenhum botão de IA (seção "Preparar" e "Revisar com estes relatos" somem em prática), UMA linha; com conta: "Preparar exercício com IA" e "Conferir minha tentativa".
- Painel — ordem objetivo → material → tentativa → feedback → dificuldade; versão com prática não repete o Markdown ("O exercício está na seção Praticar, acima."); "O que aconteceu" só lista relatos; cartão diz "Preparado por <produtor>" e omite Situação quando igual à capacidade; linhas de recusa: última só.
- P3 — teto do aparelho no fallback (P3-D); mensagem "repete o exemplo ou passa do teto" (P3-E); `PraticaTrabalho.estado(_:)` em palavras (P3); `.autocorrectionDisabled()` sempre no campo da tentativa (o app não sabe o idioma praticado e o corretor pt-BR reescreveria a tentativa — o que se proíbe à IA); origem externa da tentativa em Fora (P3-F); warnings de PraticaTrabalhoTests.swift:135 zerados (P3-G); placeholder do pedido em prática.
- ADR 05r (SPEC.md) e EVOLUCAO.md linha 14: "material bruto" substituído pelo que o código faz; parágrafo "A decisão da volta 6"; jornada pela tela COM prova; Custo com (b) e P1; Fora com origem externa.

## Contagem de elementos (TrabalhoView, apoio praticar com exercício + tentativa + hipótese)
| | antes (f1d167a) | depois (ad99974) |
|---|---|---|
| campos de texto na tela | 13 | 12 |
| botões | 36 | 34 |
| listas de hipóteses | 2 | 1 |
| exercício exibido | 2× (cartão + Markdown da versão) | 1× |
| tentativa exibida | 2× (Praticar + "O que aconteceu") | 1× |
| botões de IA sem conta, em prática | 3 (Preparar, Conferir tentativa, Revisar com relatos) | 0 |

## Prova (linhas literais)
- `com-trava.sh xcodebuild test … -only-testing:TracoTests/PraticaTrabalhoTests` (UDID 6033B043): `✔ Test run with 42 tests in 1 suite passed after 0.128 seconds.` (36 antigos + 6 novos; 2 antigos ajustados ao novo contrato: mensagem P3-E e teto com conta)
- suíte integral (UDID 6033B043): `✔ Test run with 664 tests in 122 suites passed after 9.454 seconds.` / `** TEST SUCCEEDED **`
- build genérico incremental: `** BUILD SUCCEEDED **`, 0 warnings. Clean build: `** BUILD SUCCEEDED **`, 1 warning único e pré-existente, `Traco/Caderno/EditorBlocoView.swift:270` (Caderno, fora do meu escopo e anterior ao branch; contado 2× no log).
- `xcodegen generate`: pbxproj idêntico ao commitado após remover o teste temporário de captura.
- Capturas simctl (6033B043, dados de teste, `ferramentas/orca/v6-fix-*.png`): sem-conta(+2), tentativa-sem-exercicio(+2), preparacao-indisponivel(+2), tentativa-guardada(+2,+3), tentativa-com-conta(+2), dynamic-type(+2,+3, accessibility-extra-large; restaurado para `large`, o valor original). Feedback: n/a — sem conta Grok em nenhum simulador e, por (b), o aparelho não confere. Método: TrabalhoView real hospedada no app de teste (arquivo temporário, não commitado) com `scenePhase` forçado `.active`; conta Grok simulada por item no Keychain do simulador de teste, apagada ao fim com `ContaGrok.sair()`.

## Instrumento
Tudo via com-trava.sh. Simulador 6033B043 usado e DESLIGADO ao fim (estava Shutdown quando cheguei à restauração — alguém o desligou entre as rodadas; religuei só para restaurar o Dynamic Type e desliguei). iPhone 17 do dono não tocado; Trabalho de teste do dono intacto. Maestro não rodou.

## Autoavaliação (14 dimensões; nomes inferidos — ESTEIRA.md não está neste worktree)
1. Intenção/ciclo (melhorar): ✅ — quem pratica nunca recebe a resposta pronta (teste `preparacaoRecusadaNaoCaiNaProducaoDelegada…`, captura preparacao-indisponivel).
2. Obstáculo reduzido: ✅ — P1, P2-B, P2-C fechados com teste + captura.
3. Contrato (ADR/SPEC): ✅ — 05r reescrita onde inflava; decisão (b) e P1 em A decisão/Custo/Fora.
4. Teste por comportamento: ✅ — 6 novos, todos por efeito observável (estado do pedido, artefatos, ação criada, validação); nenhum toca detalhe interno.
5. Build sem aviso: ✅ nos arquivos tocados; ⚠️ 1 aviso pré-existente em Caderno (não é meu; registrado).
6. Capturas por estado: ✅ 5 estados + Dynamic Type; feedback n/a com motivo.
7. Simplicidade: ✅ — 3 duplicatas retiradas, 0 botão de IA sem conta, tela lê de cima para baixo; ⚠️ a seção "Versão N" da prática ainda mostra Conferir/Editar (não pedido).
8. Preservação de dados: ✅ — enum novo aditivo; formato 1; disco antigo lê (teste `jsonAntigoSemCampos…` verde); nada apagado.
9. Autoria/origem: ✅ — hipótese sempre com `propostaPor`; tentativa `.pessoa`; origem externa declarada em Fora.
10. Tela honesta (04a): ✅ — estado do pedido persistente (não linha transiente); "Preparado por <produtor>" no cartão; mensagem de recusa diz o que o código detecta.
11. Acessibilidade: ✅ Dynamic Type acessibilidade capturado e legível; ids mantidos (`pratica-*`), novo `pratica-preparacao-indisponivel`.
12. pt-BR: ✅ — sem rawValue na tela; textos revisados.
13. Instrumento compartilhado: ✅ — só com-trava; meu UDID; desligado ao fim; simulador do dono intocado.
14. Relato com evidência: ✅ — linhas literais acima; hash ad99974.
Limites: P3-D (teto no fallback) sem teste unitário (caminho exige Grok ligado e falhando; leitura só); rodapé de feedback com 6 recusas iguais não condensado (P3 de design, fora da lista mínima).
