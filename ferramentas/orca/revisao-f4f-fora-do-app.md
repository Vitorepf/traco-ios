# Revisão independente G3 — F4-F fora do app

**Veredito: CORRIGIR ANTES.** O conserto visual da frase, do médio e do quadro
vazio passou na tela viva; a volta não pode fechar enquanto `f5-tocar.sh`
versionar `cliclick`, AppleScript e `AXRaise`, proibidos pela ordem vigente.
O sufixo `f5-` em arquivos de uma volta chamada F4-F é apenas o ruído de nome
declarado no brief, não um desconto.

## Método e limites

- Li `AGENTS.md`, `VISAO-PRODUTO.md`, `SPEC.md` (ADR 2026-09-08b),
  `EVOLUCAO.md`, `RUMO.md`, `ESTEIRA.md`, o relato do implementador e o diff
  `main...HEAD`. A referência de governança Atlas apontada pelo AGENTS não
  existe neste worktree e não há `artisan`; tratei os documentos do repositório
  como fonte canônica disponível.
- Rodei `ferramentas/orca/com-trava.sh xcodebuild test ... id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED ...`: xcresult com **893 passed, 0 failed,
  0 warnings**. Confirmei no dylib instalado os símbolos `FraseDoAutor` e
  `LinhasDoDestaque` antes da prova visual.
- Usei somente os UDIDs autorizados: iPhone 17 Pro teste 4
  `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED` e iPhone Air
  `64F7B8B4-CBBD-4449-A51E-19E1A1A077B4`. Plantei estado sintético, restaurei
  `IconState.plist`, tema e tamanho `large` e conferi as duas telas restauradas.
  Não usei maestro, `booted`, `cliclick`, computer-use, AXRaise ou AppleScript.

## Achados

### Alto — CORRIGIR ANTES

1. **Ferramenta proibida permanece no repositório.**
   [f5-tocar.sh](f5-tocar.sh#L12) chama `osascript`/`AXRaise` e
   [f5-tocar.sh](f5-tocar.sh#L26) chama `cliclick`. A declaração de que foi
   usada antes da ordem não retroage como nota da captura expandida, mas a lei
   vale para o artefato presente. **Conserto:** apagar `f5-tocar.sh`; futuras
   capturas devem usar `orca emulator attach` + `ax`/`tap`/`gesture` com UDID.

2. **A captura automatizada não é ainda prova reusável.**
   [f5-fotografar.sh](f5-fotografar.sh#L18) espera só 15 s após matar
   SpringBoard. Na revisão, sua primeira captura escura AX5 saiu com dois
   cartões totalmente em branco; 25 s depois, sem outra mutação, a mesma face
   apareceu completa. **Conserto:** a ferramenta deve esperar por prontidão
   observável/conteúdo não vazio antes de gravar a captura, ou não alegar que o
   arquivo imediato é evidência.

### Sem achado de produto

- **Causa e frase:** `FraseDoAutor` remove o `lineLimit` dos quatro chamadores
  e recebe somente a altura disponível ([TracoWidget.swift](../../TracoWidget/TracoWidget.swift#L450)).
  No teste 4, com a frase mais longa “terminar o capítulo do meio antes de
  dormir para manter a promessa feita a mim mesmo”, pequeno e médio ficaram
  inteiros, com `Desatualizado.`, normal e AX5, claro e escuro. O texto é
  visivelmente legível; o piso 0,35 não foi atingido como texto-formiga neste
  caso. As leis novas também estão cobertas por `LinhasDoDestaqueTests` e
  `EncolheTests`.
- **Médio:** em normal, o teste 4 mostra duas linhas reais de agenda e
  “+1 depois”, contra os atalhos que antes deixavam apenas “3 compromissos por
  vir”. A troca vale: remove duas entradas redundantes para preservar o único
  lugar onde a agenda aparece; o que ficou fora é contado. Em AX5 nenhuma
  linha cabe e a face honestamente cai em “3 compromissos por vir”, sem
  fingir agenda. A conta e seus limites estão explícitos em
  [TracoWidget.swift](../../TracoWidget/TracoWidget.swift#L851).
- **Quadro vazio e curva-zero:** no Air, normal, cada ação saiu como um
  controle separado na árvore AX (`Nova nota` e `Marcar compromisso`), com
  cápsula primária e alternativa discreta; não lê como lista de Ajustes. Em
  AX5 fica só a cápsula primária, sem ação ambígua ou texto cortado. Isso
  confirma “um toque, uma coisa”; a alternativa continua encontrável no app.
- **Fora do app:** a captura de Ilha expandida contém exatamente a linha
  semeada (“terminar o capítulo do meio antes de dormir”) e o círculo âmbar.
  Não a refiz porque o caminho declarado dependia de ferramenta hoje proibida.
  Confirmei que StandBy não foi produzido no teste 4 por `side`/rotação via
  Orca e a captura fornecida também cai na tela bloqueada comum. Ilha mínima
  segue sem segundo Live Activity disponível; o código reduz essa família ao
  mesmo ícone de `compactLeading` ([TracoWidget.swift](../../TracoWidget/TracoWidget.swift#L1009)).
  São lacunas instrumentais declaradas, não motivo para esconder a dimensão
  nem desconto adicional.
- **Privacidade, autoria e atualização:** o diff não cria rota de leitura nem
  toca o selo/expressivas/Recordar; o widget continua lendo apenas
  `SuperficieDisco`. `Relogio` e o provedor não mudaram, portanto permanecem
  a timeline de poucas entradas e a relevância declarada.
- **Design-router:** as seis fases estão citadas no relato e batem com a tela:
  ancoragem no defeito AX, sistema por `Tema`/cápsula existente, construção na
  view comum, nenhum movimento novo, julgamento da hierarquia e portão com
  estados/limites. A passagem de curva-zero também é verificável na forma e
  nos controles, não só na menção textual.

## Scorecard da ESTEIRA

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | Fecha a lacuna F4 do RUMO e EVOLUCAO registra a causa correta. |
| Contrato | 9 | ADR 2026-09-08b, SPEC, EVOLUCAO e diff coerentes. |
| Correção | 9 | `xcodebuild test` no teste 4: 893/893, 0 falhas e 0 warnings; leis novas cobertas. |
| Jornada real | 9 | Semeadura e captura independentes no Pro 4 e Air; conteúdo/estado lidos, não só arquivo existente. |
| Design | 9 | Seis fases verificáveis na implementação e nos estados observados. |
| Simplicidade | 9 | Quadro tem uma ação principal distinta; AX confirma dois destinos separados no normal e um no AX5. |
| Movimento | n/a | Nenhuma animação ou transição foi criada ou alterada. |
| Componentes | 9 | Quatro duplicatas da frase convergem em `FraseDoAutor`; sem dependência nova. |
| Acessibilidade | 9 | Pro 4: normal/AX5, claro/escuro, com rodapé; Air: painel vazio normal/AX5 e rótulos AX. |
| Performance | n/a | Não tocou lista, editor ou parser; timeline/provedor não mudaram. |
| Privacidade e autoria | 9 | Sem nova leitura/publicação; contrato de `Superficie` e proteções intactos. |
| Estado honesto | 9 | “Desatualizado.” permanece visível com o Destaque; contagem não inventa agenda. |
| Complexidade | **8** | Seis scripts entram; cinco têm valor de QA sob guarda, mas `f5-tocar.sh` é proibido e `f5-fotografar.sh` pode registrar cartão vazio como prova. |
| Fora do app | 9 | Widgets, bloqueada e Ilha expandida conferidos; StandBy e mínima permanecem lacunas instrumentais confirmadas, não n/a. |
| Relato | 9 | Relato do implementador é detalhado e declara as lacunas e o uso histórico de cliclick. |

Enquanto Complexidade estiver em 8, o veredito da volta é **CORRIGIR ANTES**.

## re-G3 — correção dos dois defeitos de ferramenta

**Veredito: CORRIGIR ANTES somente pela integridade de merge atual; Complexidade
agora é 9.** Os dois defeitos que sustentavam a reprovação original foram
eliminados: a ferramenta proibida saiu da árvore e a captura recusa uma face
sem o conteúdo esperado.

- **Instrumento:** `f5-tocar.sh` não existe em `HEAD`; a varredura de todos os
  scripts versionados (`*.sh`, `*.py`, `*.swift`) não encontrou `cliclick`,
  `osascript`, `AXRaise` ou `computer-use`. O substituto documentado,
  `orca emulator tap ... --device <UDID>`, é a linha nativa necessária.
- **Prontidão observável:** no iPhone Air `64F7B8B4-CBBD-4449-A51E-19E1A1A077B4`,
  pedi `f5-fotografar.sh` por `xyzzy-re-g3-ausente`. A chamada só chegou à
  restauração porque retornou `1`; não criou o PNG de saída e deixou apenas
  `/tmp/re-g3-ocr-deve-recusar.nao-pronta.png`. Após restaurar `light`/`large`,
  AX voltou a ler “terminar o capítulo do meio antes de dormir” na face. O
  OCR Vision é plataforma nativa, e o limite de 90 s com último quadro marcado
  é a menor prova que impede a evidência vazia anterior.
- **Demais scripts:** `f5-semear.sh` paga a espera pela publicação real de
  `superficie.json`; `f5-instalar.sh` paga a conferência de que o binário do
  widget instalado é o candidato; `f5-esquecer-faces.sh` paga o cache conhecido
  e agora aguarda `bootstatus`; `f5-plantar.py` preserva o backup do
  `IconState.plist` para a única rota disponível quando a galeria trava. Não
  há dependência adicionada, abstração especulativa ou outro corte a pedir.
- **Build e testes independentes:** por `com-trava.sh`, no mesmo Air e sempre
  com `-destination 'platform=iOS Simulator,id=64F7B8B4-CBBD-4449-A51E-19E1A1A077B4'`,
  o esquema construiu o grafo de dois alvos (`TracoWidget` e `Traco`) com
  `** BUILD SUCCEEDED **` e zero `warning:`; `xcodebuild test` terminou em
  `900 tests in 146 suites passed`, `** TEST SUCCEEDED **` e zero `warning:`.
- **ADR e merge:** a checagem inicial confirmou `main` ancestral de `HEAD`,
  `git log HEAD..main` vazio e ADRs `08b`, `08e`, `08g` nessa ordem. Porém,
  durante esta revisão `main` avançou para `7778687` e `211ce0e`; na checagem
  final `git log HEAD..main` não é zero. Portanto não posso certificar a
  integridade do merge do candidato atual, embora o merge `e1fb28c` não tenha
  perdido o `main` que existia quando foi feito.

| dimensão | nota | evidência |
|---|---:|---|
| Complexidade | **9** | A exclusão de `f5-tocar.sh`, a varredura limpa e a recusa OCR reproduzida removem os dois achados; os cinco utilitários restantes têm uma falha concreta de instrumento que evitam. |

Para aprovar a volta, mesclar o `main` atual e repetir `git log HEAD..main`
até ficar vazio; então o portão de Complexidade permanece em 9.
