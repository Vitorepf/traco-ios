# G3 — revisão independente: V13 Notas e barra inferior

**Veredito: NÃO PASSA — 8/10 em Acessibilidade e Movimento; é preciso anexar prova do estado AX5 e do novo movimento antes do merge.** O comportamento principal está correto no candidato `ae48727`, mas captura estática sem a árvore AX pareada não satisfaz o contrato da ESTEIRA para o cartão da sábia em AX5, e a nova transição da seta não tem vídeo nem prova de Movimento Reduzido.

## Escopo e instrumento

- Revisei o diff `a8d2c93..ae48727`, a ADR 2026-09-08t, `EVOLUCAO.md`, `RUMO.md`, `v13-notas.md` e as capturas entregues. Não alterei código.
- Liguei exclusivamente o iPhone 17 Pro teste 4 `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, instalei o candidato por UDID, e usei `com-trava.sh` para build, teste e `orca emulator`. Não usei voz, Siri, ditado, VoiceOver, iPad ou simuladores proibidos.
- Prova viva própria: árvore AX e `xcrun simctl io A1DF… screenshot` no mesmo instante. Artefatos temporários: `/tmp/v13-g3-ax-notas.json` + `/tmp/v13-g3-notas-2.png`, `/tmp/v13-g3-ax-woop.json` + `/tmp/v13-g3-woop.png`, `/tmp/v13-g3-ax-regua-final.json` + `/tmp/v13-g3-regua-final.png`, `/tmp/v13-g3-ax-trabalhos.json` + `/tmp/v13-g3-trabalhos.png`.
- Desliguei o A1DF082C ao final; `simctl list devices` confirmou `Shutdown`.

## Conferência da auditoria V9

| item | veredito | evidência |
|---|---|---|
| Trabalhos era link âmbar no chrome | **estava vivo** | `v13-antes-01-lista.png` mostra a linha âmbar sob o título. No candidato, a minha árvore lista `abrir-trabalhos` como botão no arquivo (frame y 0,2372–0,3188), e a captura correspondente mostra linha, ícone e chevron; o toque abriu a folha `Trabalhos` (`trabalhos-voltar`, `trabalho-nova-intencao`). |
| Régua escondia continuação sem sinal | **estava vivo** | `v13-antes-01-lista.png` mostra a máscara apagando o chip seguinte; no candidato a árvore/captura inicial tem `chevron.forward` = “Avançar”. Após três arrastos horizontais, a captura final mostra `Estudo`/`Ideias` até a borda e a árvore não contém “Avançar”: a seta some no fim. |
| Falha recolhida guardava vão e AX5 truncava a ação | **estava vivo nas capturas entregues** | Antes `v13-antes-13` tem o vão; `v13-antes-14` corta “Repetir pergu…”. Depois `v13-depois-13` remove o vão e `v13-depois-14` quebra “Repetir pergunta” em duas linhas sem sobreposição visível. **Não há árvore AX pareada entregue nem consegui reproduzir este estado sem fabricar fonte/conversa; a prova de acessibilidade fica insuficiente.** |
| `## ` aparecia como linha muda | **estava vivo** | `v13-antes-01-lista.png` tem a linha sem título; a mudança em `NotasFiltro.visiveis` a exclui e `paginaSemNomeNaoViraLinhaEmBranco` passou na minha execução (7/7 `NotasFiltroTests`). |
| Menu de ordem AX5 | **meio morto, como declarado** | A própria captura antes já é ícone, não “M…”. Não houve gasto indevido para esse pedaço. |
| Cápsulas locais | **meio morto, como declarado** | `rg 'Capsule\\(' Traco/Notas` não devolveu ocorrência no candidato; a mudança só migra os restos em Versões/Rede para `Pilula(.acao)`. |

## Checagens técnicas e de produto

- Build do candidato: `** BUILD SUCCEEDED **` no A1DF082C.
- Regressão V13: `NotasFiltroTests`: **7 testes, 1 suíte, verde**, incluindo `paginaSemNomeNaoViraLinhaEmBranco`.
- Caret apontado como vermelho alheio: `EscritaVisivelTests` passou no candidato e no pai `a8d2c93`, ambos no mesmo A1DF082C: **1 teste, 2 casos, verde** em cada. `git diff a8d2c93..ae48727 -- Traco/Caderno TracoTests/EscritaVisivelTests.swift` é vazio. Portanto o resultado falho relatado no 17e é pré-existente/ambiente-específico, não regressão desta volta; não o reexecutei no 17e proibido.
- Curva-zero: a medida declarada é suficiente para a exigência: 2 arrastos antes/depois e 1 toque + digitar antes/depois, sem nova decisão; o repouso melhorou ~48 pt. Empate de toques **não reprova**, pois o requisito era medir e não prometia reduzi-los.
- Complexidade: `5 files changed, 119 insertions(+), 50 deletions(-)` no código/testes (69 linhas líquidas). Não é líquido-negativo, mas a seta determinística, a linha de destino e a prova do vermelho pagam os defeitos confirmados; não há dependência nem camada nova. Aceitável.
- Estado interrompido que some: confirmado no RUMO como dívida de `Sessao`; fica fora desta volta, como solicitado.

## Scorecard

| dimensão | nota | evidência / limite |
|---|---:|---|
| Visão | 9 | A intenção de localizar/retomar nota reduz um obstáculo real da V9; `EVOLUCAO` e ADR 08p atualizados. |
| Contrato | 9 | SPEC 08p, EVOLUCAO e diff estão coerentes; não afrouxa origem, selo ou acesso. |
| Correção | 9 | Build e 7/7 focado independentes; quatro correções ligadas a defeitos confirmados. A suíte integral 947/948 é evidência do autor, não repetida nesta passada. |
| Jornada real | 9 | Lista, filtro, busca vazia, régua completa e abertura de Trabalhos observados; estado da falha usa captura entregue, não nova execução. |
| Design | 9 | `Trabalhos` deixou de parecer ação/link e a régua agora comunica omissão sem mascarar conteúdo; usa tokens/componentes existentes. |
| Simplicidade | 9 | Curva-zero medida sem piora e sem decisão adicional; ganho espacial de ~48 pt. |
| Movimento | **8** | A seta nova usa `.opacity`, mas não há vídeo `simctl` nem evidência de corte sob Movimento Reduzido. **CORRIGIR ANTES:** vídeo curto da seta entrando/saindo, normal e RM, com UDID e estado. |
| Componentes | 9 | `Capsule()` local zerado em `Traco/Notas`; reutiliza `Pilula`. |
| Acessibilidade | **8** | A árvore/captura própria prova rótulos, Trabalhos, filtro e fim da régua. Para o conserto AX5 de `Repetir pergunta`, só há PNG; falta a árvore AX do mesmo instante exigida pela ESTEIRA. Não desconto pela voz, que era proibida. **CORRIGIR ANTES:** anexar árvore AX + screenshot simultâneos em AX5 mostrando rótulo inteiro, ordem e ausência de sobreposição. |
| Performance | n/a | Não há algoritmo, IO ou volume novo e não foi produzido trace; não avaliei desempenho como entrega desta volta. |
| Privacidade e autoria | 9 | Leitura do diff: nenhuma rota protegida, origem ou publicação foi tocada. |
| Estado honesto | 9 | Linha inexistente não é mais afirmada; filtro e seta informam o que está/ não está visível; dívida da conversa interrompida está declarada. |
| Complexidade | 9 | +69 líquidas justificadas, sem dependências/abstrações especulativas; remoções reais de máscara/cápsulas. |
| Fora do app | n/a | Nenhuma superfície fora do app pertence ao escopo. |
| Relato | 8 | Relato legível e honesto sobre captura sobrescrita e fim da régua, mas não preserva a árvore AX da captura AX5 nem vídeo do movimento novo. |

## Limites julgados

- A captura sobrescrita de “3 notas · WOOP” não fura sozinha a prova: a montagem equivalente mostra o texto, e a lógica/contagem foram lidas no diff. Minha tela estava vazia, logo não pude repetir a contagem numérica.
- O ANTES refeito no mesmo aparelho é a correção adequada para a troca de aparelho; não é falha.
- Não capturar a seta no fim originalmente **seria** lacuna, mas foi fechada nesta revisão no A1DF082C pela captura e árvore simultâneas.
- Sem vídeo não é aceitável para a animação nova da seta; isso segura Movimento. A ausência de VoiceOver falado é limite permitido e não entra na nota.
