# Prova — U1 · Share: o texto de fora vira nota

**Destino:** de outro app, Compartilhar texto abre o Traço numa nota com aquele texto. Sem prosa da IA. Trancada nunca entra.

## O que se construiu
- **Alvo Share Extension** (`TracoShare/ShareViewController.swift`): sem tela própria — o carteiro. Colhe o texto (`plainText`, `NSAttributedString` ou `Data`/utf8), monta `traco://criar?texto=…` e sobe a cadeia de responders pedindo `openURL:` (extensão não tem `UIApplication.shared`). Fecha com 400ms de respiro pra não engolir o open. Registrado em `project.yml` como `app-extension` (`com.apple.share-services`, `NSExtensionActivationSupportsText`) e dependência do alvo principal.
- **A porta do app** (`Rota.daURL`): `traco://criar?texto=…` → `.criar(texto:)`; sem texto, `.novaPagina` — o pouso não cai no vazio.
- **A entrega** (`Sessao.receberDeFora`): a página em voo grava e sai ANTES; o texto de fora nasce numa nota NOVA e destrancada. A expressiva em voo não herda o texto nem empresta o timer (regra 2: trancada/selada nunca entra por rota nenhuma).

## O conserto (1 de 3)
Sob `SWIFT_STRICT_CONCURRENCY: complete`, a versão `async` do `loadItem` mandava o `NSItemProvider` (não-Sendable) pro executor global → *"sending 'provedor' risks causing data races"*. Raiz, não sintoma: a chamada por completion-handler é SÍNCRONA, então o provedor nunca cruza o ator — só a `String` (Sendable) volta pelo continuation. Um lugar só, o do load.

## Barra (verde)
- **build 0** — `xcodebuild build` (Traco + TracoShare + TracoWidget) → **BUILD SUCCEEDED**. O alvo Share Extension compila.
- **texto vira nota** — `maestro/cenarios/share-criar.yaml` → **todos os passos COMPLETED**. Discriminante (não tautológico): digita "a nota que estava em voo", dispara `traco://criar?texto=chegou de fora`, e exige a de fora VISÍVEL, a em voo NÃO na página, e DEPOIS as DUAS no arquivo. Sem o `salvar`+`novaPagina` do `receberDeFora`, ou a em voo sumiria (engolida) ou a de fora entraria por cima → quebraria.
- **testes "a IA não escreve" + regra 2** — **154 testes, 0 falhas**. `RotaDoShareTests` (3): a query carrega o texto (`&` e `\n` sobrevivem); sem texto vira branco; o de fora nasce nota nova destrancada com a em voo guardada à parte; o Share não entra na expressiva em voo nem herda o timer.
- `prova/share.png` — o arquivo com as DUAS notas em HOJE: "chegou de fora" (virou nota) e "a nota que estava em voo" (guardada à parte, não engolida).

## O que a barra prova direto, o que fica por construção
Direto: o alvo compila (extensão válida) e o contrato do deep-link que a extensão emite — `traco://criar?texto=…` — cria a nota certa end-to-end (maestro + testes). Por construção: o `ShareViewController` só colhe o texto e abre EXATAMENTE essa URL; a peça com lógica (a entrega, a regra 2) é a que está testada. Dirigir a folha de compartilhar entre apps no simulador é frágil e não acrescenta ao que o contrato já prova.

## Nota de instrumento
Dois simuladores booted (iPhone 17 + iPhone 17 Pro). Não desliguei nenhum — podem ser do dono ou de outro job. Fixei tudo no MESMO aparelho por UDID (iPhone 17, `1A46…`): install, teste e maestro no mesmo alvo, o veredito não se divide (a lei do `varrer.sh` obtida sem apagar o simulador de ninguém).

## Crítico fresco
Subagent novo e cego (só viu captura + teste + barra, proibido de ler código): **VEREDITO PASS**. Viu na captura "chegou de fora" e "a nota que estava em voo" como duas notas separadas sob HOJE — o texto de fora virou nota própria sem engolir a em voo; os 3 testes de `RotaDoShareTests` passam, build 0 com TracoShare, e o maestro exige exatamente essa coexistência. Sem prosa da IA nos títulos; o teste da expressiva em voo cobre o não-vazamento da trancada.
