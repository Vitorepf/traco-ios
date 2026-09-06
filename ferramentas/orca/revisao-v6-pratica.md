# Revisão da volta 6 — a prática dentro do Trabalho (ADR 2026-09-05r)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026. Branch
`Vitorepf/volta-6-pratica`, commit f1d167a sobre main 41b2605. Só leitura e
prova; nenhum arquivo de código editado, nada commitado.

## Veredito: CORRIGIR ANTES (lista mínima de 3 itens), depois INTEGRAR

O contrato de dados e o parser estão sólidos e provados; o que falha é a
tela e a política de provedor. Lista mínima antes de integrar:

1. **P1 — Quem escolheu praticar recebe a resposta pronta quando a preparação
   não valida.** Provado na tela do dono (capturas
   `v6-preparacao-indisponivel-topo.png` e
   `v6-preparacao-indisponivel-versao-entregue.png`).
2. **P2 — Hipóteses em dois lugares com contratos diferentes:** a seção antiga
   "Apoio para a próxima tentativa" cria hipótese sem `propostaPor` (vira
   "autoria desconhecida" na seção nova) e aponta TODAS as evidências como
   pertinentes.
3. **P2 — "Conferir minha tentativa" aparece com o modelo de bordo, que
   avaliou zero critérios em 3 de 3 amostras** (2 em prova/6.md, 1 nesta revisão pela tela). Recomendação (b),
   igual à V5: só com provedor que serve.

Recomendação para a pergunta central (Eixo 4): **(b)** — ver seção 3.

---

## 1. Contratos (diff 41b2605..HEAD)

### O que está certo, com evidência

| Contrato | Onde | Verificado |
|---|---|---|
| Tentativa nunca é versão, nunca `guardarVersaoHumana` | `Trabalho.swift` `guardarTentativa`: `evidencias.append`, nunca `artefatos` | teste `tentativaNaoViraVersaoENaoMudaOrigemDoMaterial` |
| Tentativa nunca sobrescrita | `guardarTentativa` só acrescenta; nenhuma mutação de `evidencias[i].texto` no diff (`grep "evidencias\["` só acha `.tentativa`) | teste `novaTentativaLigaAAnteriorSemApagarAPrimeira`, `feedbackNaoSobrescreveARespostaDaPessoa` |
| Reavaliar não cria demonstração | `registrarConferenciaDaTentativa` faz `conferencias + [c]` na mesma evidência | teste `reavaliarAMesmaTentativaNaoCriaOutraDemonstracao` |
| Guardar não marca ação executada | ação nasce/permanece `.pendente`; `apoioUtilizado` vazio → `Erro.vazio` | teste `guardarTentativaNaoMarcaAcaoExecutadaNemConfirmaHipotese` |
| Callback atrasado descartado | `OficinaTrabalho.conferirTentativa`: depois do `await` compara `tentativaAtual`, `versaoAtual`, `apoio`, `hipoteses` e revalida acesso; `alterar` revalida de novo | 5 testes `retornoAtrasadoEDescartadoApos…` com corrida real (AsyncStream) |
| 05i/05j: acesso antes de ler/enviar, após await, em projeção | `guard !conferindoTentativa, verificarAcesso()`; `guard verificarAcesso()` antes do await e depois; `TrabalhoView` linha 38 troca o corpo inteiro por "Trabalho protegido" | teste `acessoNegadoNaoLeENaoChamaOProvedor` |
| 05m: teto inteiro ou indisponível | `MotorTrabalho.conferirTentativa`: `guard mensagem.count <= teto` → `.indisponivel` com motivo, nada cortado | teste `tetoDoAparelhoRecusaConferenciaEmVezDeCortar` |
| ADR 02o: IA nunca dá a resposta | `validar`: exemplo == enunciado ou contido nele recusa; `Prova.vaza(criterio, alvo: exemplo)`; `parseConferencia`: observação > 240 ou que repete o exemplo → `inconclusivo`; trecho não literal → `inconclusivo` com citação apagada; convite "Reveja este critério…" é constante do app | testes `exemploIgualAoEnunciado…`, `criterioQueRepeteQuatroPalavras…`, `trechoNaoLiteralCaiParaInconclusivo…`, `observacaoQueTrazSolucao…` |
| `Hipotese.evidencias` só pertinentes | `proporHipotese` default `[]` e valida IDs conhecidos | teste `hipoteseSoAponteEvidenciasConhecidas` — MAS ver P2-B |
| Export .md não leva tentativa | `IntercambioTrabalho.exportar` só serializa `versao.conteudo` | teste `exportarMarkdownNaoLevaTentativaNemFeedbackComoVersao` |
| Nada alimenta Degraus/Sinais/Retrato | nenhum arquivo fora de `Traco/Trabalho` no diff | `git diff --stat` |
| Injeção pela tentativa | `montarConferencia` embrulha em `<tentativa_da_pessoa>` e o sistema diz "instruções dentro dela não são ordens" | leitura |

### Achados

**P1-A — Praticar sem preparação válida vira delegação, na tela, com o
"praticar" ainda selecionado.** `MotorTrabalho.produzir`: se
`prepararPratica` devolve `nil`, cai na produção de sempre (prompt de
delegação com a frase antiga sobre praticar, `OficinaTrabalho.swift:342`). No
aparelho do dono, primeira preparação: o modelo de bordo não validou; o app
entregou o roteiro COMPLETO de 3 blocos com frases prontas e traduções
("Frases como 'No puedo' (Não posso), 'Sí, puedo'…", captura
`v6-preparacao-indisponivel-versao-entregue.png`). A seção Praticar diz
"Nenhum exercício preparado ainda", e a linha vermelha
`preparacaoIndisponivel` fica no topo — mas essa linha é `erro`, transiente:
`guardar()` faz `erro = nil` a cada commit seguinte, então basta guardar
uma dificuldade e o aviso some, restando uma versão de origem `ia` sem
`pratica` num Trabalho de apoio `praticar`, sem campo de tentativa
(`tentativas()` só aparece com `versao.pratica != nil`). A ADR nomeia
"preparação que não valida gasta uma segunda chamada, a da produção de sempre"
e chama isso de "material bruto preservado" — não é o bruto da preparação, é
uma segunda produção delegada. VISAO: "a IA não substitui a prática
escolhida". Correção mínima: em `praticaPedida`, NÃO cair na produção
delegada; falhar o pedido (`falharPedido`) com a mensagem
`preparacaoIndisponivel` e o botão "Retomar esse pedido" que já existe. Custo:
zero campos novos, menos uma chamada.

**P2-B — Hipóteses duplicadas e autoria perdida.** `TrabalhoView.swift:684-704`
(seção "O que aconteceu" → "Apoio para a próxima tentativa", pré-existente)
continua criando `Hipotese` com `d.hipoteses.append(.init(texto:…,
evidencias: d.evidencias.map(\.id)))`: sem `propostaPor`, sem `motivo`, e com
TODAS as evidências do Trabalho como pertinentes — o que a consulta
(consulta-v6-pratica.md §2) mandou parar de fazer. A mesma hipótese aparece
então na seção Praticar como "Proposta por autoria desconhecida" mesmo tendo
sido digitada pela pessoa um toque antes. E a lista de hipóteses fica em dois
lugares da mesma tela, com botões duplicados "Faz sentido neste contexto"/"Não
é essa a dificuldade". Correção mínima: apagar o bloco antigo (ou trocá-lo por
`proporHipotese(texto, propostaPor: "Você")` e remover a lista duplicada).

**P2-C — Botão "Conferir minha tentativa" com provedor que não serve.**
`botaoDoFeedback` usa `MotorTrabalho.disponivel` (= Grok OU aparelho). A V5
decidiu (b) com a condição no PROVEDOR: `RevisaoTrabalho.oferta()` só oferece
com `ContaGrok.ligada`. A V6 não seguiu a mesma decisão para o feedback, e
prova/6.md mostra o aparelho avaliando ZERO critérios em 2/2. Ver seção 3.

**P3-D — Teto errado quando o Grok está ligado e falha.**
`MotorTrabalho.conferirTentativa`: `teto = ContaGrok.ligada ? tetoRemoto :
tetoNoAparelho`; se o Grok responde `nil` (rede), cai no aparelho com a
mensagem já aprovada pelo teto REMOTO (18.000), acima do teto do aparelho. Não
corta (05m preservado: o modelo lança e vira "Nenhum provedor respondeu"),
mas o motivo registrado é falso — não foi "nenhum provedor", foi "não coube
no aparelho". Mesmo padrão de `RevisaoTrabalho.janelaPadrao`, então é dívida
herdada; registrar.

**P3-E — Mensagem de recusa promete detectar o que o código não detecta.**
`parseConferencia` recusa observação por `count > 240` ou `Prova.vaza(obs,
alvo: exemplo)`; a mensagem diz "trouxe solução, reescrita ou texto longo
demais". Uma reescrita da TENTATIVA (não do exemplo) passa — a ADR nomeia
"a validação lê forma", correto; a string da tela não. Trocar por "repete o
exemplo ou passa do teto".

**P3-F — `Tentativa.origem` só aceita `.pessoa`** (`validar()` exige). A
consulta pedia "conteúdo conhecido como copiado/externo mantém sua origem".
Não há caminho para isso; aceitável nesta fatia, mas a ADR diz "origem
pessoa" como decisão sem dizer que externa ficou fora. Adicionar ao **Fora**.

**P3-G — Dois warnings novos no alvo de teste.** `PraticaTrabalhoTests.swift:135:14`
e `:135:20` ("variable 'd'/'evidenciaID' was never mutated"). Os outros três
warnings do log (`EditorBlocoView.swift:270`, `ConferenciaTrabalhoTests.swift:381`)
são anteriores ao branch.

## 2. Caso real (prova/6.md)

A leitura do implementador está certa e é honesta:

- **Formato saiu, conteúdo não serve:** confirmado de forma independente na
  tela do dono (captura `v6-praticar-exercicio.png`): `capacidade` e
  `situacao` são a MESMA frase copiada do resultado ("Conseguir falar as
  frases em voz alta hoje" nos dois); o enunciado ("Escreva 3 frases em
  espanhol, usando as palavras e frases de exemplo abaixo") ignora os 3 blocos
  de 5 minutos; o primeiro critério manda "Usar as palavras e frases de
  exemplo" — o critério instrui a copiar o exemplo, e a regra `Prova.vaza`
  não pega porque não repete quatro palavras seguidas dele; "pronome
  correcto" está em espanhol. Terceira amostra de preparação no aparelho, mesma
  classe de defeito.
- **A citação literal salvou de um falso "6 atendidos":** sim. O JSON da
  amostra 2 traz seis `atendidoNoEscopo` com `"vivo em Sao Paulo"` para uma
  tentativa que diz `vivo en São Paulo`; `literal()` é `lowercased().contains`,
  e "em" ≠ "en" e "Sao" ≠ "São" → seis `inconclusivo`. Reproduzi o parser de
  cabeça contra o texto: a regra é a única barreira, e funcionou.
- **A linha "NÃO demonstrados" de EVOLUCAO é a honesta:** sim; ela diz o que
  saiu (formato), o que não serviu (blocos, pronúncia, citação) e nomeia o
  que falta (Grok, tela, aprendizagem). Nada inflado.
- **A ADR descreve o código sem inflar?** Em dois pontos não: (i) "Falha
  mantém o material bruto" — o que fica é uma segunda produção delegada
  (P1-A); (ii) "a jornada pela tela continua sem prova" — agora tem, e a
  jornada mostrou o P1-A. Ajustar as duas frases.
- **Limite que a prova declara e eu confirmo:** a sonda não foi commitada;
  não consigo reexecutar as 4 amostras. As capturas desta revisão são amostras
  independentes no aparelho do dono, PELA TELA (o que a prova dizia não ter):
  1 preparação falhou a validação e virou delegação (P1-A), 1 validou com o
  conteúdo acima, e 1 feedback sobre a tentativa "Hola, me llamo Vitor. Soy de
  Brasil y vivo en São Paulo. Me gustan los perros y el café." saiu
  **"Feedback: nada confirmado · 6 inconclusivos"**, os seis com "A IA citou um
  trecho que não aparece literalmente na sua tentativa" (`v6-feedback.png`).
  Terceira amostra de feedback no aparelho, terceira com zero critérios
  avaliados. A regra da citação literal segurou de novo; o provedor de bordo
  não serve para esta operação.

## 3. Eixo 4 e a pergunta central

**Campos/decisões que a seção "Praticar" acrescenta**, contados em
`TrabalhoView.praticar` (linhas 194-405): 5 campos de texto (trecho em
combinar, dificuldade, "Por quê?" por hipótese, tentativa, apoio usado) e 7
botões (guardar trecho, guardar dificuldade, faz sentido, não é essa, guardar
tentativa, conferir, nova tentativa), mais 4 textos explicativos. Em apoio
praticar, ANTES de qualquer exercício, a pessoa vê: 1 campo + 1 botão + 1
parágrafo, e o parágrafo manda "escrever abaixo e tocar em preparar" numa seção
que se chama "Preparar uma versão" com o botão "Preparar com IA" — a promessa
04a do que a IA vai fazer (exercício, não versão) fica dividida em duas seções.

**Recomendação: (b), só com provedor que serve — e a condição vale para a
preparação e para o feedback.** Por quê:

1. Evidência: 3/3 preparações no aparelho ignoraram o pedido, 2/2 feedbacks
   avaliaram zero critérios, e 1/3 preparações nem validou e virou delegação
   (P1-A). Com (a), a seção aparece inteira, a pessoa escreve a tentativa, toca
   em conferir e recebe "nada confirmado · 6 inconclusivos" — estado honesto,
   mas honesto DEPOIS do esforço dela, e a tentativa dela fica registrada
   contra um exercício que não serve.
2. Consistência com a V5: a decisão (b) já existe para "Conferir com IA"
   (`RevisaoTrabalho.oferta`), com a condição no provedor. Dois botões da
   mesma tela com políticas opostas é uma decisão a mais para a pessoa.
3. Custo de (b): em `botaoDoFeedback`, trocar `MotorTrabalho.disponivel` por
   `ContaGrok.ligada` (reusar `RevisaoTrabalho.oferta()`); em `praticar(o)`,
   quando `praticaPedida` e sem Grok, mostrar a linha `semProvedor` no lugar de
   "Nenhum exercício preparado ainda… toque em preparar" e não ramificar a
   preparação no aparelho. Uma condição, uma string. O que fica em (b): a
   dificuldade e o histórico de tentativas continuam visíveis (são dados da
   pessoa, não dependem de provedor).
4. Contra (a): a linha `preparacaoIndisponivel` é transiente e o fallback
   entrega a resposta (P1-A). (a) só seria honesto com P1-A corrigido E com
   estado persistente na versão ("esta versão não é exercício"), que é mais
   código que (b).

## 4. Design (julgar; capturas no iPhone 17 do dono, build f1d167a, md5 conferido antes de cada captura)

Capturas: `v6-praticar-secao.png` (seção sem exercício), `v6-praticar-exercicio.png`
(cartão do exercício), `v6-tentativa.png` (campo "Minha tentativa" e apoio,
antes de guardar), `v6-feedback.png` (estado do feedback — ver nota ao fim),
`v6-preparacao-indisponivel-*.png` (P1-A).

- **Hierarquia IA vs. autor: parcial.** O cartão do exercício
  (`Tema.superficie`) não diz que é da IA — só "Exercício: …"; o produtor
  ("Apple Intelligence no aparelho · exercício preparado") está longe, na seção
  "Versão 2" abaixo. O campo "Minha tentativa" e o texto "Guardar preserva a sua
  resposta como sua" deixam o lado do autor claro. Falta uma linha no cartão:
  "Preparado por <produtor>".
- **Repetição:** "O que você quer conseguir fazer: Praticar espanhol sozinho,
  do zero" repete o título da tela dois dedos acima (`v6-praticar-secao.png`).
  "Exercício: Conseguir falar…" e "Situação: Conseguir falar…" repetem a
  mesma frase (defeito do modelo, mas a tela não protege: quando
  `capacidade == situacao`, omitir a segunda). O mesmo exercício aparece duas
  vezes: no cartão e como Markdown na seção "Versão 2"; a tentativa aparece
  duas vezes: na seção Praticar e em "O que aconteceu" como "Tentativa de
  Você"; as hipóteses, duas vezes (P2-B).
- **Painel? Sim, virou.** TrabalhoView em apoio praticar com um exercício e
  uma tentativa: intenção → Praticar (dificuldade + hipótese com 1 campo + 2
  botões + aviso, cartão do exercício, 2 campos, 1 botão, aviso, tentativa
  guardada, feedback, 2 botões) → Preparar uma versão → Versão 2 (o mesmo
  exercício em Markdown + conferência + "Conferir com IA" + editar) → Editar
  com outras ferramentas → Próximo ato → O que aconteceu (tentativa de novo +
  Revisar com IA + hipóteses de novo) → Histórico. Doze superfícies
  empilhadas, cinco delas mostrando dados que já apareceram. A causa não é a
  V6 sozinha; é a V6 somada às V4/V5 sem tirar nada. Para esta volta: retirar
  as três duplicatas (exercício em Markdown, tentativa em "O que aconteceu",
  hipóteses antigas) já devolve a tela ao tamanho da V5.
- **Tokens de Tema:** todos do `Tema` (`meta`, `barra`, `tintaSuave`, `aviso`,
  `linha`, `raio`, `superficie`); nenhuma cor ou fonte solta. Botões de texto
  via `AcaoTrabalhoStyle`, sem cartaz. Sem medalha, sem streak, sem contador
  de acertos (a linha do feedback conta critérios, não pontos).
- **pt-BR:** "Proposta por Você · proposta" mostra `estado.rawValue` cru
  (P3); "Exemplo resolvido, de outro caso — não é a sua resposta" ok; o
  placeholder "Pode ser contexto, recursos, acesso ou divisão do trabalho"
  trunca em uma linha ("…acesso o…"): campo de uma linha com placeholder de
  duas.
- **Feedback expandido (`v6-feedback.png`, `v6-feedback-rodape.png`):** o
  rodapé "Lido por Apple Intelligence no aparelho · feedback da tentativa em
  5 de set. de 2026, 18:52. Lê a sua tentativa contra os critérios deste
  exercício; não avalia você, não corrige o texto e não prova aprendizagem"
  cumpre 04a (quem, quando, método, limite). Mas a mesma frase de recusa
  ("A IA citou um trecho que não aparece literalmente…") repete seis vezes,
  uma por critério, ocupando duas telas: quando todos os critérios caem pelo
  mesmo motivo, uma linha só ("6 critérios não conferidos: a IA não copiou a
  sua tentativa literalmente") diz o mesmo em um parágrafo. P3.
- **Entrada:** o campo "Minha tentativa" sublinha as palavras em espanhol
  como erro (corretor pt-BR, `v6-tentativa.png`): para um exercício de
  espanhol, `.autocorrectionDisabled()` no campo da tentativa evita que o
  corretor "corrija" a tentativa da pessoa — que é justamente o que a ADR
  proíbe a IA de fazer.

## 5. Prova

| Item | Resultado |
|---|---|
| `xcodegen generate` | pbxproj idêntico ao commitado (sem diff) |
| Suíte integral, UDID 6033B043-F436-41F9-B4F8-2D9E67761980 | 1ª execução: "The test runner hung before establishing connection" (simulador recém-ligado; nenhum teste rodou). 2ª execução: **658 testes em 122 suites, 0 falhas**, 8,0 s (log `test2.log`) |
| Warnings de build (Traco + TracoTests) | 5 no total; 2 NOVOS em `PraticaTrabalhoTests.swift:135` (P3-G); 3 pré-existentes |
| `git merge-tree --write-tree 41b2605 HEAD` | árvore 3ebcf455…, exit 0, sem conflito |
| Maestro `varrer.sh` | NÃO rodou: exige exatamente um simulador ligado e havia dois/três (o do dono e o do outro worker). Os fluxos desta revisão rodaram direto por `com-trava.sh ~/bin/maestro --device 1A46B6D3…`, sem `clearState` |
| Instalação no aparelho do dono | Reinstalada duas vezes: entre a minha primeira instalação (18:28) e a primeira captura, OUTRO processo instalou um build sem a V6 (container mudou, `Traço.debug.dylib` sem `pratica-objetivo`). Reinstalei e conferi md5 `155a4f78…` antes de cada captura |
| Simulador de teste ao fim | Desliguei o 6033B043 às 18:28 depois da minha suíte; às 18:43 outro worker o religou e rodou `xcodebuild test` nele. Não desligo simulador que não liguei: fica como o outro worker deixou |
| Estado deixado no aparelho do dono | Um Trabalho de teste "Praticar espanhol sozinho, do zero" com 2 versões, 1 hipótese (texto com resíduo de digitação do fluxo) e 1 tentativa. Sem `clearState`; nada apagado. O dono pode descartá-lo |

---

# Re-G3 — depois das correções (ad99974), 06/09/2026

Revisor: Claude Fable 5.1, sessão independente, 02:55–03:20 de 06/09/2026.
Diff conferido: `f1d167a..ad99974` (29 arquivos; código 5 arquivos,
+334/−117). Base main 41b2605; main hoje **2229031** (o G0 dizia 7c8a2e4; o
2229031 é só o LACO em cima dele). Nada editado além desta seção e das
capturas `v6-reg3-*.png`; nada commitado.

## Veredito: CORRIGIR ANTES — lista mínima de 1 item (cabe na rebase), depois INTEGRAR → rebase → G4

Os três itens do G3 anterior estão fechados com teste e captura (P1, P2-B,
P2-C), o painel encolheu de verdade e a ADR passou a dizer o que o código
faz. O que fica abaixo de 9 é UM contrato anterior que a limpeza do P2-B
levou junto sem nomear:

1. **P2-H — Em `delegar`, a hipótese sumiu da tela.** O bloco antigo "Apoio
   para a próxima tentativa" era o ÚNICO caminho para propor, confirmar ou
   contestar uma dificuldade num Trabalho com apoio `delegar` (o padrão). Ele
   saiu (correto, P2-B) e o substituto `dificuldade(o)` só é chamado dentro de
   `praticar(o)`, que exige `apoio != .delegar` (`TrabalhoView.swift:200-227`).
   Resultado: Trabalho delegado não registra dificuldade, e as hipóteses que
   já existem nele (V4/V5, ADR 05i "hipóteses de capacidade corrigíveis";
   "contestação participa do próximo pedido"; "delegar/praticar/combinar é
   escolha contextual sem penalidade") ficam invisíveis e incorrigíveis —
   `MotorTrabalhoContextoTests` prova que a contestada muda o pedido, mas em
   delegar ninguém consegue contestar. A ADR 05r não nomeia essa perda no
   **Fora**. Correção mínima (uma das duas): (a) chamar `dificuldade(o)` também
   em delegar (tirar a chamada de dentro do `if apoio != .delegar`, ~3 linhas,
   1 teste de tela ou captura em delegar); ou (b) decidir que dificuldade é só
   de prática e escrever isso no Fora da 05r, com o que acontece às hipóteses
   já gravadas em Trabalhos delegados. Recomendo (a): é menor que a prosa e
   não regride a 05i.

## Confirmações item a item (o que o G0 pediu)

| Pedido | Resultado | Evidência |
|---|---|---|
| P1: preparação recusada → nenhum artefato `.ia`, pedido `praticaIndisponivel`, campo de tentativa disponível | ✅ `MotorTrabalho.produzir` lança `praticaIndisponivel` quando `prepararPratica` devolve nil; nunca chega ao `pedido(d, p, teto:)` da delegação; `gerar` marca o pedido, `erro` fica nil | teste `preparacaoRecusadaNaoCaiNaProducaoDelegadaETentativaContinuaPossivel` (artefatos vazios, `pedidos.last?.estado == .praticaIndisponivel`, tentativa com `artefatoID == nil`, ação "Praticar por conta própria" pendente, `conferirTentativa == nil`); captura `v6-fix-preparacao-indisponivel.png` (linha vermelha + campo "Minha tentativa"); `praticaIndisponivelSobreviveAoDiscoENaoBloqueiaNovoPedido` |
| P2-B: hipóteses uma vez, sempre com `propostaPor` | ✅ bloco antigo removido de `retorno(o)`; único caminho `proporHipotese(texto, propostaPor: "Você")`; `estado(_:)` em palavras | teste `dificuldadePropostaPelaTelaTemAutoriaESemEvidenciasInventadas`; captura `v6-fix-tentativa-guardada-2.png` ("Proposta por Você · ainda não avaliada", uma lista só). Ver P2-H para o efeito colateral |
| P2-C: sem conta nenhum botão de IA e UMA linha; com conta, ambos | ✅ no motor (`prepararPratica`/`conferirTentativa` com `contaLigada`) e na tela (`oferta(contaLigada:)`; `producao(o)` e "Revisar com estes relatos" somem em prática sem conta) | testes `semContaGrokAPreparacaoDePraticaNaoUsaOAparelho`, `semContaGrokOFeedbackFicaIndisponivelSemLerATentativa`; capturas `v6-fix-sem-conta*.png` (uma linha, sem "Preparar", Praticar → Editar com outras ferramentas → Próximo ato), `v6-fix-tentativa-com-conta-2.png` ("Conferir minha tentativa" + "Nova tentativa"); minha `v6-reg3-sem-conta.png` |
| Painel: exercício/tentativa/hipóteses uma vez; ordem objetivo→material→tentativa→feedback→dificuldade | ✅ `praticar(o)`: objetivo, (delimitação), material ou linha, `tentativas(...)` (feedback dentro), `dificuldade(o)`; versão com prática mostra "O exercício está na seção Praticar, acima."; "O que aconteceu" filtra `tentativa == nil` | contagem por `grep` em TrabalhoView: `campo(` 14→13, `Button(` 36→34 (o relato diz 13→12: conta sem a definição da função; a variação é a mesma); capturas `v6-fix-tentativa-guardada-3.png` (Versão 1 sem Markdown) |
| P3-D teto no fallback | ✅ `naoCoube(Sabia.tetoNoAparelho)` depois do Grok falhar | leitura; sem teste (declarado no relato; caminho exige Grok ligado e falhando) |
| P3-E mensagem | ✅ "repete o exemplo ou passa do teto" | teste ajustado `observacaoQueTrazSolucao…` |
| P3-F origem externa | ✅ no Fora da 05r | diff SPEC |
| P3-G warnings | ✅ zerados; restam 3 pré-existentes (EditorBlocoView:270 no app; ConferenciaTrabalhoTests:381 ×2 no alvo de teste) | log da minha suíte |
| P3 rawValue, "Preparado por", situação repetida, autocorreção | ✅ | diff da tela; captura `v6-fix-tentativa-guardada.png` ("Preparado por Fake controlado…"); na minha `v6-reg3-tentativa-guardada.png` o texto em espanhol não é sublinhado pelo corretor |
| ADR 05r diz a verdade | ✅ "material bruto" saiu; parágrafo "A decisão da volta 6" nomeia (b), P1, o que foi provado na tela e o que o aparelho fez em 3/3; Custo e Fora coerentes. ⚠️ falta o P2-H no Fora (ou a correção) | diff SPEC |
| EVOLUCAO 14 honesta | ✅ mantém "**NÃO estão demonstrados**", diz "o único provedor oferecido está sem prova real", 664/0 literal | diff EVOLUCAO |
| Privacidade: tentativa/feedback/rascunho com origem protegida | ✅ `alterar` e `conferirTentativa` revalidam; `abrir()` só carrega os rascunhos do UserDefaults com `acesso.permitido`; o corpo inteiro vira "Trabalho protegido" | teste `acessoNegadoNaoLeENaoChamaOProvedor` (guardar recusado, provedor 0 chamadas, JSON intacto); `TrabalhoView.swift:39`, `:828-831` |

## Prova (meu instrumento: iPhone 17 Pro Max 6033B043, ligado por mim às 02:56, desligado ao fim; Dynamic Type restaurado para `large`)

| Item | Resultado |
|---|---|
| `xcodebuild clean build` (com-trava) | `** BUILD SUCCEEDED **`; **1 warning**, pré-existente: `Traco/Caderno/EditorBlocoView.swift:270` |
| `xcodebuild test` integral (com-trava) | **`✔ Test run with 664 tests in 122 suites passed after 6.857 seconds.`** / `** TEST SUCCEEDED **`; 2 warnings no alvo de teste, pré-existentes (`ConferenciaTrabalhoTests.swift:381`) |
| `xcodegen generate` | pbxproj idêntico ao commitado |
| Maestro | `varrer.sh` não roda (2 simuladores ligados: o do dono e o meu; não desligo o do dono). Nenhum flow do repositório toca a seção Praticar (`grep pratica- maestro/` vazio); o único de Trabalho, `trabalho-acao-aviso.yaml`, usa "Próximo ato", não alterado. Rodei 3 flows próprios com `--device` no meu UDID, `clearState`, dados de teste: criar Trabalho → apoio "Praticar com apoio" → seção sem conta; escrever e guardar tentativa; matar e reabrir o app até o Trabalho |
| Capturas minhas | `v6-reg3-sem-conta.png` (uma linha, campos, dificuldade, sem botão de IA); `v6-reg3-tentativa-guardada.png` ("Tentativas (1)", texto íntegro, "Apoio usado: nenhum, escrevi de cabeça", só "Nova tentativa"); `v6-reg3-reaberto.png` (após stop/launch, a tentativa continua); `v6-reg3-ax3.png` e `v6-reg3-ax3-2.png` (accessibility-extra-large, sem clipe, tentativa legível) |
| Capturas do implementador (conteúdo lido, 14) | batem com o relato. Dois reparos: `v6-fix-tentativa-com-conta.png` é o MESMO arquivo de `v6-fix-tentativa-guardada.png` (md5 `2a5c68e9…`, cartão do exercício; a prova do "com conta" está só na `-2`); `v6-fix-preparacao-indisponivel-2.png` mostra o campo "O que você quer que a IA prepare ou ajuste?" com placeholder "Prepare uma apresentação curta" sob o título "Preparar um exercício" — o código commitado diz "O que você quer praticar?" / "Quero praticar me apresentar em espanhol": captura de build intermediário, anterior ao último P3 |
| `git merge-tree --write-tree main HEAD` | **CONFLITO em `EVOLUCAO.md` e `SPEC.md`**; `project.pbxproj` auto-mescla; nenhum arquivo de código em conflito (main não tocou `Traco/Trabalho/*` desde 41b2605). EVOLUCAO: um hunk de 3 linhas da tabela — a linha "Desenvolvimento de capacidades" é da V6, "Direção visual" ganhou ADR05t em main; manter as duas versões linha a linha. SPEC: um hunk no fim — main anexou 05s/05t/05u onde a V6 anexa 05r; manter 05r **e** 05s/05t/05u em ordem. A rebase precede o G4 |

## Scorecard (ESTEIRA.md, mínimo 9)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | ciclo melhorar; fecha parte da lacuna "Desenvolvimento de capacidades relevantes" e deixa o "NÃO demonstrado" onde ainda é verdade (diff EVOLUCAO linha 14) |
| Contrato | **8** | ADR 05r, SPEC e EVOLUCAO coerentes com o código para P1, (b), P3-F; **P2-H**: perda da hipótese em `delegar` (05i) sem nome no Fora nem decisão |
| Correção | 9 | 664/122/0 literal; 6 testes novos por efeito observável; P3-D só por leitura (declarado); nenhum flow maestro tocado |
| Jornada real | 9 | sem conta, prática indisponível, tentativa (sem/com exercício), guardada, reaberta, AX3 vistos e lidos; feedback n/a com motivo (sem conta em simulador); dois reparos de captura acima, nenhum muda o veredito |
| Design | n/a | G4 é portão próprio e ainda não rodou (segue a rebase). Do que dá para julgar no G3: só tokens de `Tema`, "Preparado por <produtor>" no cartão, situação duplicada omitida, `AcaoTrabalhoStyle`; o rodapé com N recusas iguais continua (P3, herdado) |
| Simplicidade | 9 | `campo(` 14→13, `Button(` 36→34, 3 duplicatas fora, 0 botões de IA sem conta, 1 linha de recusa; a tela lê de cima para baixo; "Retomar esse pedido" e "Escrever minha própria versão" continuam encontráveis |
| Movimento | n/a | 0 ocorrências de animação/transição no diff da volta (grep) |
| Componentes | n/a | não há `Traco/Componentes` no repositório ainda (fundação prevista na ESTEIRA); a volta não cria componente reutilizável, só funções privadas da tela |
| Acessibilidade | 9 | ids `pratica-*` mantidos + `pratica-preparacao-indisponivel`; AX3 sem clipe em 5 capturas (3 do implementador, 2 minhas); alvos são botões de texto do sistema; VoiceOver real não passado (humano) |
| Performance | n/a | nenhuma lista, editor ou parser novo; a seção entra na `ScrollView` existente; nada mede pior por leitura |
| Privacidade e autoria | 9 | `alterar`/`conferirTentativa`/`abrir()` revalidam; rascunhos não carregam sem acesso; hipótese sempre com `propostaPor`; tentativa `.pessoa`; sem conta o motor não lê nada (teste); nada envia sem toque |
| Estado honesto | 9 | `praticaIndisponivel` persistente no pedido (não linha transiente), sobrevive ao disco; "Preparado por"; P3-I abaixo (botão some sem linha) não esconde falha, só omite o porquê |
| Complexidade | 9 | correções: +334/−117 em 5 arquivos, líquido +217, dos quais +141 são testes; volta inteira vs base: código +988/−49 em 4 arquivos (PraticaTrabalho.swift +350 novo), testes +764, docs +110/−1 — proporcional a modelo + motor + parser + tela novos; nenhuma dependência nova; `TrabalhoView` 687→931 linhas é o ponto a vigiar no G4 |
| Fora do app | n/a | a volta não toca widget, Ilha, StandBy nem intents (`git diff --stat` só em Traco/Trabalho) |
| Relato | 9 | `relatorio-v6-fix-pratica.md` com linhas literais, hash, contagem antes/depois e limites declarados; único desvio: 13→12 campos (grep dá 14→13, mesma variação) |

## Achados por severidade

- **P2-H** (Contrato) — hipótese invisível e incorrigível em `delegar`; ver lista mínima.
- **P3-I** (Estado honesto/Design) — exercício preparado e conta desligada depois: "Conferir minha tentativa" some sem linha nenhuma (`botaoDoFeedback` cai em `botaoNovaTentativa`), enquanto o cartão da versão (V5) mostra "Revisão pela IA precisa da conta Grok…". Uma linha `oferta(...)` ali fecha.
- **P3-J** (texto) — `preparacaoIndisponivel` diz "não ficou disponível neste aparelho" também quando a conta existe e o Grok não validou/não respondeu.
- **P3-K** (dados na tela) — tentativas guardadas em `praticar` ficam invisíveis se a pessoa muda o apoio para `delegar` (antes apareciam em "O que aconteceu"); os dados persistem.
- **P3-L** (evidência) — as duas capturas apontadas acima (arquivo duplicado; build intermediário).
- **P3** herdado — rodapé com N recusas iguais não condensado (declarado no relato).

## Instrumento

Tudo via `com-trava.sh`. Simulador 6033B043 ligado por mim às 02:56, Dynamic Type `large` → `accessibility-extra-large` → `large` (conferido), desligado às 03:20. iPhone 17 do dono (1A46B6D3, Booted) não tocado. Nenhum arquivo de código editado; nada commitado; esta seção e `v6-reg3-*.png` ficam untracked/modificado para o orquestrador.
