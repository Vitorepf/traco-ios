# Q-PERFIL — a terceira linha: o que a medida reprovou, dito ao autor

**Papel:** FRONT-END E DESIGN (Fable 5.1). **Worktree:** `volta-q-qualidade`, segunda frente da volta Q, em cima do trabalho do implementador (dono de `Traco/Analise/**` e `prova/**`; eu só de `Traco/Perfil/**`). **Aparelho:** iPhone Air `64F7B8B4-CBBD-4449-A51E-19E1A1A077B4` (420 × 912 pt), ligado por mim às 15h45 — o orquestrador me pediu o Air e não o Pro Max, e eu não cheguei a instalar no Pro Max. O `C2416CBC` (conta do dono) não foi tocado. Skills carregadas antes da primeira linha de SwiftUI: `design-router` (redesenho: comecei por auditar antes de tocar, e li o `g4-l2-design.md`) e `curva-zero` (a leitura da seção).

## Ancorar

- **Pessoa e situação:** o autor, no Perfil, no cartão CONTA, onde já lê duas listas — o que o aparelho faz sem conta e o que só faz com a conta Grok. A volta Q mediu com a conta ligada e reprovou operações; a regra nova `indisponivelPorQualidade` (ADR 08k, do implementador) as tira da execução.
- **Obstáculo:** sem uma terceira lista, a operação reprovada simplesmente sumia das duas — o autor via menos coisa e nenhuma explicação; e a frase de "sem provedor" mandava conectar a conta que ele já tem (o defeito que o conselho nomeou).
- **Resultado observável:** uma terceira lista no mesmo cartão, dizendo por operação o quê, por quê em uma oração de pessoa, e quando foi medido; dois estados distintos (sem substituto / em correção com conserto nomeado); lista que muda de tamanho, com um estado dito quando estiver vazia; nunca manda conectar conta; nunca promete prazo.
- **Restrições:** nada de tela nova; nada de painel de notas; tokens de `Tema`; Dynamic Type até AX5 sem clipe; um idioma.

## Sistema

Tudo o que o cartão já usava: `Tema.meta` + `Tema.tintaFraca` para a letra miúda, `Tema.tintaSuave` para o nome da operação (um degrau mais escuro — a coluna varrível que o G4 da L2 elogiou), `Tema.entreItens` entre grupos, `spacing: 4` dentro do grupo (o mesmo literal que a linha de cima já usava). Um token novo, local: `medidaMiuda`, `@ScaledMetric` relativo a `.subheadline`, que substitui três `maxWidth: 280` literais do cartão — ver Julgar, porque não é enfeite.

## Construir

Um bloco só, no cartão CONTA, logo abaixo das duas listas de "quem responde" (`indisponiveis-por-qualidade`), lendo da mesma tabela que elas (`Politica.indisponiveis` → `Politica.linha(op)`: `motivo`, `medidaEm`, `conserto`). A view formata e não redige: o motivo é de quem mediu.

- **Dois grupos, na ordem do peso:** primeiro o que não tem substituto, depois o que está em correção. Cada grupo tem uma abertura que diz o estado e a data; cada operação, UMA linha: `nome — motivo`, e `· conserto: …` quando existe.
- **A data** vai na abertura quando o grupo inteiro a compartilha (o caso de hoje: "a medida de 08/09"); se um dia as datas divergirem, ela desce a cada linha (`dataDe` / `restoDa`, testados).
- **Vazio é um estado dito:** "Nenhuma operação indisponível por qualidade." — a linha não some quando a lista some.
- **Hierarquia sem badge:** o nome da operação em `Tema.tintaSuave`, o motivo em `Tema.tintaFraca` — a margem esquerda vira a coluna de nomes que se varre (a mesma decisão que o G4 da L2 defendeu para a latência). Nada tocável, nada colorido, nenhum número de acerto: boletim fica no `porque` e no `prova/`.
- **A largura da letra miúda** (`medidaMiuda`) é a única mudança fora do bloco novo: os três `maxWidth: 280` do cartão viraram um `@ScaledMetric`. Não é enfeite — ver Julgar.
- **Acessibilidade:** o bloco é `children: .contain`; cada abertura e cada linha é um elemento, na ordem visual; o nome e o motivo são um `Text` só (concatenado), então o VoiceOver lê "ecos entre notas — deixou de fora…" de uma vez.

Arquivos: `Traco/Perfil/PerfilView.swift` (+~110 linhas), `TracoTests/PerfilQualidadeTests.swift` (novo, 3 testes), `SPEC.md` (ADR 08l), `EVOLUCAO.md`, este relatório.

## Mover

Nada se move, e está dito: o diff não tem `withAnimation`, `.animation` nem `.transition`. Nada a respeitar em Reduzir Movimento.

## Julgar — como o autor olharia

**As três coisas por operação estão na linha?** O quê (nome de `Politica.nome`, não o símbolo), por quê (uma oração), quando (a data na abertura do grupo). Conferido na árvore de acessibilidade do Air no mesmo instante da captura: cada linha é um elemento "nome — motivo", a abertura traz "a medida de 08/09".

**Os dois estados se distinguem?** Sim, por estrutura e não por badge: dois grupos com abertura própria ("Indisponível mesmo com a conta Grok — … não há outro caminho:" × "Em correção, com conserto nomeado e sem data — …:"), e a linha do segundo grupo termina em "· conserto: …". Quem lê de cima para baixo vê primeiro o que não tem saída e depois o que está em conserto.

**Manda conectar conta?** Não: a abertura começa por "mesmo com a conta Grok". Nenhuma linha diz "precisa da conta". **Promete prazo?** Não: "sem data" está na abertura do grupo em correção; "não há outro caminho" no outro.

**Boletim?** Procurei na árvore: nenhum "N de 6", nenhum caminho `prova/`, nenhum nome de modelo. A evidência ficou em `Politica.Linha.porque`, para a ADR.

**O texto final de cada linha, como está na tabela e na tela** (`q-perfil-large-secao.png`, 17:01; árvore lida no mesmo instante com "Indispon…" em y=0,221):

- Abertura 1: *Indisponível mesmo com a conta Grok — a medida de 08/09 reprovou, e não há outro caminho:*
  - *instigar — devolveu o vocabulário interno do app*
  - *contrapor — sustentou o contraponto em fato inventado*
  - *a pergunta do Recordar — entregou a resposta dentro da pergunta*
  - *ecos entre notas — deixou de fora os vínculos mais úteis*
  - *ler o seu juízo — calou quando não havia erro a apontar*
- Abertura 2: *Em correção, com conserto nomeado e sem data — a medida de 08/09 reprovou:*
  - *responder nas Notas — recusou por inteiro perguntas que as suas notas ajudavam a responder · conserto: usar o material disponível quando o fato atual falta, como produzir já faz, e manter os rótulos internos fora do texto*
  - *responder à sua pergunta — inventou fato que o contexto não sustentava · conserto: recusar o fato que o contexto não sustenta e entregar o caminho, como produzir já faz*
- Vazio (não fotografado, a tabela de hoje não está vazia; coberto por código e teste): *Nenhuma operação indisponível por qualidade.*

**Um reparo que não é meu, para a FILA:** os dois `conserto` são frases de 15 a 22 palavras, e cada linha do grupo em correção vira seis linhas em `large` e mais de uma tela em AX5. Conserto nomeado é um NOME ("fonte para todo fato", "material disponível em vez de recusa"), não a descrição do conserto — a descrição mora no `porque` e na ADR. Três palavras por conserto devolvem ao grupo a forma de lista. É dado da tabela (`Traco/Analise`), não da view; não toquei.

**O custo em altura, medido no Air (912 pt de tela; a medida é da árvore, conferida contra a captura do mesmo UDID):**

| estado | bloco novo (da abertura 1 ao rótulo PERMISSÕES, descontado o vão do cartão) | antes → depois do `@ScaledMetric` na letra miúda |
|---|---|---|
| `large` | **≈ 0,65 tela**: abertura 0,064, cinco linhas de 0,042–0,046, abertura 2 de 0,064, e as duas linhas com conserto de 0,13 e 0,11 | igual: 280 pt já cabia em ~45 caracteres |
| AX5 | **≈ 4,0 telas** (`Indispon…` em −0,03 → `PERMISSÕES` em 4,03): abertura 0,446, linhas de 0,26–0,32, e as duas com conserto de 1,0+ cada | abertura 0,509 → **0,446**; linha de operação 0,32–0,38 → **0,26** (`22-ax5-secao-a` × `24-ax5-secao-a`, no scratch); a lista "Pelo aparelho / Só com a conta" caiu de 2,04 para 1,53 tela; o parágrafo da conta, de 2,0+ para 1,40 |

Metade da altura em AX5 está nas duas linhas com conserto — daí o reparo acima.

O achado de AX5 é o mesmo mal da L2 (medida fixa em pontos onde a letra cresce), numa parte do cartão que ninguém tinha medido: `maxWidth: 280` dava DOZE caracteres por linha em AX5 e deixava um terço da tela em branco, em três blocos. Um `@ScaledMetric` relativo a `.subheadline` resolve os três de uma vez, e em `large` não muda um pixel.

**Modo escuro:** o app força `light` (`RaizView.swift`, `.preferredColorScheme(.light)`, como o G4 da L2 já registrou). Com o aparelho em `dark` a seção sai idêntica e clara (`q-perfil-ax5-escuro-sistema.png`: cartão a 255, fundo a 234). Não se aplica; registrado.

**O que fica sem prova:** VoiceOver não foi ouvido (ligar no simulador pede reiniciar o aparelho); a árvore mostra ordem e agrupamento certos. Alvo de 44 pt: n/a, nada tocável na seção.

## Portão — scorecard preenchido por mim (a nota final é do revisor)

| dimensão | minha nota | evidência |
|---|---|---|
| Visão | 9 | ciclo "multiplicar": o autor sabe o que a IA não faz por ele e por quê, sem ser mandado a uma conta que já tem; fecha a lacuna nomeada na 08k ("o Perfil precisa de uma terceira linha") |
| Contrato | 9 | ADR 08l no SPEC depois da 08k; EVOLUCAO; código lê a tabela, não a copia |
| Correção | 9 | 3 testes novos verdes (`PerfilQualidadeTests`); suíte integral no Air, `-parallel-testing-enabled NO`: `✔ Test run with 914 tests in 149 suites passed after 9.109 seconds.` / `** TEST SUCCEEDED **` (17:00 de 08/09); build sem aviso em `PerfilView` |
| Jornada real | 9 | capturas do Air em `large` e AX5, com árvore do mesmo instante; vazio coberto por teste e por estado dito (não fotografado: a tabela de hoje não está vazia) |
| Design | 9 | seis fases cumpridas; tokens de `Tema`; um `@ScaledMetric` novo com motivo medido; nenhum literal de cor ou fonte |
| Simplicidade | 8 | curva-zero: a seção lê-se de cima para baixo sem decisão; mas o cartão CONTA cresce ~0,45 tela em `large` e ~2,3 telas em AX5 — custo inerente a dizer sete coisas, e o Perfil já era a tela mais longa. O que reduziria: a volta do Perfil decidir o que ele mostra por padrão (mesma lacuna que o G4 da L2 nomeou) |
| Movimento | n/a | nada se move, dito |
| Componentes | 9 | nada novo em `Traco/Componentes`; helpers privados no padrão do arquivo |
| Acessibilidade | 8 | AX5 sem clipe e com a largura corrigida; VoiceOver não ouvido (limite do instrumento) |
| Performance | n/a | sete `Text` estáticos; nada de lista ou parser |
| Privacidade e autoria | 9 | nada publica, nada envia; a seção só lê a tabela |
| Estado honesto | 9 | indisponível ≠ erro ≠ sem conta; conserto sem data; vazio dito |
| Complexidade | 9 | +~110 linhas em `PerfilView` (que já era a dívida de 983 linhas, nomeada pela L2); zero dependências; os três 280 viraram um token |
| Fora do app | n/a | não toca widget nem Ilha |
| Relato | — | este arquivo e as seis linhas do `worker_done` |

## Instrumento, declarado

- **Trava:** todo `xcodebuild`, `xcodebuild test` (com `-parallel-testing-enabled NO`: havia cinco simuladores ligados) e TODA sessão do `orca emulator` (attach + ax + tap/gesture, em scripts curtos: `sequencia.sh`, `capturar.sh`) passaram por `ferramentas/orca/com-trava.sh`.
- **Aparelho:** iPhone Air `64F7B8B4`, ligado por mim (`simctl boot`, sem janela do Simulator — o Simulator.app tinha zero janelas, e assim ninguém precisa do mouse). Instalações por `simctl install <UDID>`, nunca `booted`; o dylib instalado conferido por string antes de cada captura (`strings` corta em "ç": conferir por trecho ASCII). Capturas por `xcrun simctl io <UDID> screenshot`. Zero maestro. Zero mouse do Mac. O `C2416CBC` não foi tocado; o Pro Max `6033B043` também não (fotografei-o uma vez, só leitura, para provar que um toque meu não tinha caído nele).
- **Toques que não chegavam:** os primeiros `tap` no Air voltaram `ok` sem efeito nenhum (três tentativas, capturas 03/04 iguais). O botão `home` funcionou e um toque no ícone do Traço na tela inicial também; a partir daí os toques no app passaram a chegar. Não sei a causa; registro o fato e o remédio que funcionou (tocar primeiro fora do app).
- **`ax --device` e o vizinho:** conferi toda árvore contra a captura do mesmo UDID no mesmo instante (o Pro Max estava numa nota com o cartão WOOP, e a minha árvore mostrou o mesmo cartão — mas era o MEU aparelho, que também tinha uma nota "Q" com WOOP: a foto desempatou).
- **Rolagem:** gesto de 24 pontos + 8 parados antes de soltar; ganho medido 2,1 pt rolados por pt arrastado em `large`, 1,0 em AX5 (`ir.py` corrige pela árvore em até cinco passos).
- **Estado do aparelho:** `content_size` era `large` e `appearance` era `light` antes; AX5 e `dark` foram temporários e restaurados — eco do `simctl ui` às 17:01: `content_size=large appearance=light`. O Air continua ligado (ninguém me pediu para desligar; o helper foi encerrado ao fim de cada sessão).
- **Escuro:** `q-perfil-ax5-escuro-sistema.png` — aparelho em `dark`, seção idêntica e clara (cartão 255, fundo 234): o app força claro.

## Capturas (build das 16:5x de 08/09, dylib conferido por string antes de cada uma)

| arquivo | o que prova |
|---|---|
| `q-perfil-large-topo.png` | o Perfil como abre, `large` |
| `q-perfil-large-secao.png` | `large`: as duas aberturas, as cinco linhas sem substituto e as duas em correção, inteiras |
| `q-perfil-large-em-correcao.png` | `large`: o grupo em correção e a fronteira com PERMISSÕES |
| `q-perfil-ax5-secao.png` | AX5: abertura 1 e as primeiras linhas, largura inteira do cartão (a correção do `@ScaledMetric`) |
| `q-perfil-ax5-em-correcao.png` | AX5: abertura 2 e a linha de responder nas Notas |
| `q-perfil-ax5-fim.png` | AX5: o fim do cartão CONTA e PERMISSÕES |
| `q-perfil-ax5-escuro-sistema.png` | AX5 com o aparelho em `dark`: idêntica e clara |

## Seis linhas para o LACO

- O Perfil ganhou a terceira lista, lida da mesma tabela: sete operações que a medida de 08/09 reprovou com a conta ligada, cinco sem substituto e duas em correção com conserto nomeado, cada uma em `nome — motivo` com a data na abertura; vazio é estado dito.
- A regra que faltava está na tela: a abertura diz "mesmo com a conta Grok", nada manda conectar conta, nada promete prazo, nenhum número de acerto ou caminho de prova.
- A letra miúda do cartão CONTA tinha três `maxWidth: 280` fixos que davam doze caracteres por linha em AX5; um `@ScaledMetric` corrigiu os três, e a linha de uma operação caiu de 0,32–0,38 tela para 0,26.
- Custo honesto: o cartão cresce ~0,65 tela em `large` e ~4 telas em AX5, metade disso nas duas frases de conserto de 15–22 palavras — conserto é nome, não descrição; reparo na tabela, para a FILA.
- Instrumento: Air `64F7B8B4` ligado por mim, tudo sob `com-trava.sh`, zero mouse, zero maestro; os primeiros toques no app não chegavam e passaram a chegar depois de um toque na tela inicial (registrado, sem causa).
- 3 testes novos, suíte 914/149 verde, ADR 08l depois da 08k, EVOLUCAO com a linha.
