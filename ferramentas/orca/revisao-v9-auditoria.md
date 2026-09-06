# Revisão G3 — volta 9 (auditoria de front-end)

Fable revisor, 05/09/2026, sessão própria. Branch `Vitorepf/volta-9-auditoria` (1c6aa62) sobre main e51550e. Objeto: `ferramentas/orca/auditoria-frontend.md`, 89 capturas `v9-*.png`, 6 vídeos `v9-*-movimento.mp4`. Nenhum código no diff (96 arquivos novos: 1 md, 89 png, 6 mp4). Nada editado por mim; capturas de revisão em `ferramentas/orca/v9-rev-*.png` (untracked).

**Instrumento.** `xcodegen generate` + `com-trava.sh xcodebuild build` no iPhone 17e C7341E64: **BUILD SUCCEEDED, zero avisos** na minha build. `xcodebuild test` e maestro **não rodados**: o diff não tem código (RUMO, linha da V9: "sem código, G1 é n/a"). Simulador 17e ligado por mim, usado, restaurado (`appearance` light, `content_size` large, como estavam) e desligado; janela devolvida à posição original. Não toquei no iPhone 17 do dono, no Air nem nos Pro. Dados que deixei no 17e: uma nota "Quero correr de manha antes do trabalho" e um compromisso "7 de setembro" (05/09 09:00), ambos criados na reprodução; o app já tinha um "Dentista 21:30" de outra sessão, que não apaguei por não ser meu. `git merge-tree e51550e HEAD`: **sem conflito**.

## 1. Fidelidade (todas as capturas e vídeos abertos)

Abri as 89 capturas em folhas de contato (3 por folha, 520 px de largura cada) e os 6 vídeos a 1 fps, mais recortes a 10 fps nos trechos citados. **Todas as 89 mostram o estado que o relatório diz** onde são citadas. Vídeos: forma vestindo e cartão entrando (página); busca filtrando e cartão da sábia (notas); D→S→M→A→D com arrasto (calendário); esconder→escrever→revelar (recordar); gesto da borda e troca de aba (camadas); Reduzir Movimento com o título cruzando e o arquivo ainda deslizando. Confirmados quadro a quadro: `v9-recordar-prova.png` e o quadro 3,3 s do vídeo do Recordar têm os dois textos legíveis um sobre o outro (§21, literal); em `v9-reduce-motion-movimento.mp4` o arquivo desliza em ≥ 6 quadros consecutivos sob Reduzir Movimento.

Desvios de relato (nenhum muda uma nota):
- **Timestamp errado.** O cruzamento "Setembro 2026"/"2026" sob Reduzir Movimento está em **t≈1 s** do vídeo versionado (transição M→A), não em "t≈6,5 s" (aos 6,5 s o vídeo está na página Notas).
- **Evidência que não está na captura citada.** "o toast '1 nota veio de fora.' confirma a entrada (`v9-pagina-vazia.png` da sessão de semeadura)": a `v9-pagina-vazia.png` versionada não tem toast.
- **Afirmação contrariada pelo próprio vídeo.** "Não vi A VOLTA nem PELO SENTIDO": `v9-notas-movimento.mp4` mostra a seção PELO SENTIDO ("falam disto sem usar a palavra") nos quadros 9–10, ao perguntar "que metodo uso para decidir a viagem".
- **Três capturas órfãs** (não citadas): `v9-caderno-apos-menu.png`, `v9-calendario-vazio.png` (é a folha de permissão do calendário do sistema, útil para o estado "sem permissão" e não citada) e `v9-calendario-dia-11.png`, cujo nome mente: mostra **30 de agosto**, não o dia 11.

**Reprodutibilidade (3 amostras no 17e, main = base).**
1. Prosa "7 de setembro" → **reproduzido e pior**: criou o compromisso "7 de setembro" **no dia âncora (05/09) das 09:00 às 10:00**, com a promessa "Toca hoje às 09:00" às 20:53 — hora já passada, sem aviso disso (`v9-rev-prosa-misparse-ficha-17e.png`, `v9-rev-prosa-misparse-lista-17e.png`). Causa-raiz que o relatório não nomeia: `CalendarioFrase` **não conhece nome de mês** (nenhum "setembro/janeiro" em `Calendario.swift`; só "dia 15", dias da semana e relativos), então "7 de setembro" nunca é data — vira título e cai na âncora. Não é "desempate" da consulta; é padrão ausente. No Air caiu no dia 15 porque a âncora do auditor estava lá.
2. "Todas" com a nota preenchida → a manifestação foi outra, mas confirma a causa: 3 s depois de digitar, o cartão WOOP vestiu sozinho e **substituiu a régua e a linha de ações inteiras** (`v9-rev-pagina-cartao-toma-o-pe-17e.png`); o toque mirado em "Todas" (y≈677) caiu no texto do cartão. Chrome que some sob o dedo é a instabilidade de posição que o relatório suspeita (`fitts-law`); vale registrar assim, não como "alvo pequeno".
3. AX5 com o cartão → **reproduzido igual**: o cartão cobre "RESULTADO (O MELHOR…)" e "Abrir os campos / Deixar como nota" ficam fora da vista (`v9-rev-ax5-pagina-cartao-17e.png`).

## 2. Calibragem

Os 5 altos são altos: (1) verificado acima; (2) `CalendarioFicha.swift:166-176` só cala a promessa quando `estadoDosAvisos == .negado`, e `v9-calendario-ficha-aviso-estado.png` × `v9-calendario-dia.png` provam o par promessa/toast — **e o mesmo defeito existe no Trabalho**: `AgendamentoAcaoView.swift:136-143` usa `permissaoNegada` (só o negado cala) e `v9-trabalho-agendar.png` mostra "Toca hoje às 20:22 · na hora" na mesma sessão em que o iPhone dizia "avisos desligados"; (3) confirmado em três capturas e reproduzido; (4) confirmado quadro a quadro; (5) confirmado em `v9-trabalho-1.png`/`-versao-1.png` (cinza do sistema → cápsula marrom, `.borderedProminent` em `TrabalhoView.swift:209`, `AcaoTrabalhoStyle:678`).

Recalibro duas células, com motivo:
- **Tela 3, Estado honesto 7 → 6.** Além da promessa sob permissão não perguntada, a ficha promete "Toca hoje às 09:00" para uma hora que já passou (reprodução). Duas mentiras de aviso na mesma seção.
- **Tela 6, Estado honesto 9 → 8.** A mesma promessa não-autorizada em `v9-trabalho-agendar.png` (defeito 2 estendido). O resto da tela continua exemplar em produzido/agendado/executado.

As outras 46 células são defensáveis pela lei citada e pela captura; conferi cada evidência de arquivo:linha que sustenta uma nota (`PaginaView.swift:31-35` sem tinta, `CadernoView.swift:165-166` com `reduzido: false`, `PaginaView.swift:328` `repeatForever`, `TrabalhoView.swift:210` `.disabled`, `RecordarView.swift:392-395` `delay(0.08)` em irmãos, `CalendarioView.swift:505` "Nada marcado.").

### Tabela tela × dimensão FINAL (nota base do RUMO)

| tela | Design | Simplicidade | Movimento | Componentes | Acessibilidade | Estado honesto | média |
|---|---|---|---|---|---|---|---|
| 1 Página em branco + Caderno | 7 | 6 | 7 | 6 | 6 | 8 | 6,7 |
| 2 Notas + barra de baixo | 7 | 7 | 8 | 6 | 6 | 8 | 7,0 |
| 3 Calendário + ficha | 8 | 7 | 8 | 7 | 7 | **6** | 7,2 |
| 4 Recordar | 5 | 8 | 5 | 6 | 5 | 8 | 6,2 |
| 5 Perfil | 7 | 6 | 9 | 7 | 8 | 9 | 7,7 |
| 6 Trabalho | 5 | 5 | 7 | 4 | 7 | **8** | 6,0 |
| 7 Padrões | 7 | 8 | 8 | 7 | 6 | 9 | 7,5 |
| 8 Camadas / navegação | 8 | 8 | 7 | 7 | 6 | 9 | 7,5 |

## 3. Inventários (grep no branch)

**Componentes (10 linhas): batem.** 7 `ButtonStyle` exatos (`Tema:148`, `CalendarioTema:184`, `PaginaView:612`, `CartaoAnaliseView:291,302`, `TrabalhoView:678`, `RecordarView:467`); `RoundedRectangle(cornerRadius: Tema.raio…)` 30 em 12 arquivos (relatório: 29/12); `mostrarToast(` 32 chamadas (relatório: 30); `DisclosureGroup` 6 em `TrabalhoView` + 1 em `AgendamentoAcaoView` + 1 em `IntercambioTrabalhoView`; `ChipDominio` usado em 2 arquivos; `Traco/Componentes` não existe. Falta: `PerfilView.swift:237` tem um `.system(size: 9)` (o §22 diz "três tamanhos fixos"; há 11 ocorrências em 5 arquivos; o relatório lista 4 arquivos).

**Movimento (22 linhas): batem, com duas faltas.** 4 molas exatas; movimento reduzido tratado em 15 arquivos exatos; `repeatForever` só em `PaginaView:328`. Faltas: (a) a frase "onze durações distintas" conta menos do que existe — só em `duration:` literais há 0,7 · 0,9 · 1,0 além das onze, e `Tema.queima` 0,55 e `queimaCena` 3,0 (a tabela até cita algumas; a contagem não); (b) `CartaoAnaliseView.swift` e `CalendarioEscalas.swift` têm `withAnimation`/`.animation(` e não estão no inventário.

**Escopo da V10 (7 linhas): certo e cabe em 2 Fables.** As frentes são disjuntas por arquivo (Tema.swift + biblioteca de movimento / Traco/Componentes + previews + 3 telas migradas). Dois riscos a escrever no G0: a V8 traz `Tema.animacao/transicao` (ADR 05t) — a V10 **mescla a V8 antes** ou duplica; e "sem mudança de pixel" exige as capturas de base em resolução cheia, que é exatamente o que a V9 versionou.

**Linha G0 sugerida para a V10 (≤ 8 linhas):**
1. Ciclo: multiplicar + eixo 4. Intenção: toda tela nasce dos mesmos tokens, componentes e movimentos. Obstáculo: 7 estilos de botão, 6 pílulas, 32 rótulos à mão, 14+ durações e 4 molas soltas; Componentes 6,2 e Acessibilidade 6,4 de média na V9.
2. Pré-requisito: V8 mesclada (ADR 05t); `Tema.animacao/transicao` da V8 é a única lei de movimento reduzido — a V10 estende, não duplica.
3. Frente A (Fable 1): `Tema.swift` com `duracao.{curta,media,longa}`, `mola.{toque,camada,escala}`, `sombra`, `raio`; `CalendarioTema` cita `Tema`; tabela do inventário de movimento vira os tokens.
4. Frente B (Fable 2): `Traco/Componentes/` com `Pilula`, `ChipDominio`, `Rotulo`, `LinhaDeEstado`, `LinhaQueAbre`, `Cartao`, `Botao` (3 estilos), `CabecalhoDeFolha`, `Toast`, `Vazio`, preview por estado incluindo AX5.
5. Migração: Notas, ficha do Calendário, Recordar — captura antes = depois em `large` e AX5 (base: `v9-notas-lista`, `v9-calendario-ficha`, `v9-recordar-escrever`, `v9-ax5-*`).
6. Fora: Trabalho (V18), pé da página e barras do calendário (dono), qualquer texto, os 5 defeitos altos da V9 (voltas por tela).
7. Prova: suíte verde; `shortstat` líquido ≤ 0; previews no Xcode; diff de pixels das três telas; nenhum `.system(size:)` novo; `Tema.duracao` como único lugar de duração.
8. Critério: Componentes e Movimento ≥ 9 no scorecard da própria V10; nota das três telas migradas não desce em nenhuma dimensão.

## 4. Merge

`git merge-tree e51550e HEAD` limpo. Só docs e binários novos. Peso: as 89 capturas + 6 vídeos somam **82 MB** (F1 já tinha somado 52 MB em 24 capturas): o repositório dobra de novo. Não é critério do scorecard e há precedente aceito, mas o RUMO deveria fixar política (630 px para evidência; resolução cheia só para a base de diff da V10).

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Linha G0 da V9 no RUMO (frente de front-end: auditoria → fundação → telas); entrega exatamente a nota base que as V12–V18 citam. |
| Contrato | 9 | Sem código, sem ADR a escrever; toda lei citada existe e diz o que o relatório diz (§11/§20/§21/§22, ADR 02i, 04a, 04d, 04u, 05c–05f, 05t na V8). Uma imprecisão de causa (defeito 1) e uma extensão que faltou (defeito 2 no Trabalho). |
| Correção | n/a | Nenhum comportamento novo; build limpa; suíte e maestro não se aplicam (RUMO). |
| Jornada real | 9 | 89/89 capturas e 6/6 vídeos conferidos por conteúdo; 3/3 amostras reproduzidas no 17e (uma com manifestação diferente e causa confirmada). Três órfãs, uma com nome errado. |
| Design | 9 | Julgamento do julgamento: leis aplicadas com acerto; duas células recalibradas (−1 cada) por evidência que a própria sessão do auditor produziu. |
| Simplicidade | 9 | Curva-zero contada por tela; conferi Calendário (3 toques) e Trabalho (6 toques, 2 digitações) nas capturas. |
| Movimento | n/a | Nenhuma animação alterada; o inventário é avaliado em Relato. |
| Componentes | n/a | Nada construído; inventário conferido por grep, bate com duas faltas pequenas. |
| Acessibilidade | n/a | Nada alterado; AX3/AX5 capturados nas 7 telas. |
| Performance | n/a | Sem código. |
| Privacidade e autoria | n/a | Sem código; capturas só com dados plantados pelo auditor no aparelho dele. |
| Estado honesto | n/a | Sem código; o relatório declara limites (sem VoiceOver, falhas não provocadas, teclado físico). |
| Complexidade | 9 | Linhas líquidas de código 0; 82 MB de binários com precedente aceito na F1 — política pendente, não recusa. |
| Fora do app | n/a | Não é a trilha. |
| Relato | 8 | Legível e com evidência por célula, mas três apontadores errados (t≈6,5 s; toast que não está na captura; PELO SENTIDO "não visto" que o vídeo mostra), contagem de durações abaixo do real e uma captura com nome errado. |

## Veredito: CORRIGIR ANTES (lista mínima, sem recapturar, ~20 min)

1. Tabela: Calendário Estado honesto 6; Trabalho Estado honesto 8; médias 7,2 e 6,0.
2. Defeito 1: causa é `CalendarioFrase` sem nomes de mês ("N de <mês>" nunca é data; cai na âncora com o texto como título) e a promessa aceita hora passada ("Toca hoje às 09:00" às 20:53).
3. Defeito 2: acrescentar `AgendamentoAcaoView.swift:136-143` (`permissaoNegada`) e `v9-trabalho-agendar.png`.
4. Corrigir os três apontadores de evidência (t≈1 s; tirar a citação do toast ou versionar a captura com ele; PELO SENTIDO visto no vídeo das Notas).
5. Renomear `v9-calendario-dia-11.png` → `v9-calendario-dia-30-ago.png` (ou apagar) e citar ou apagar `v9-caderno-apos-menu.png` e `v9-calendario-vazio.png` (esta serve ao estado "sem permissão").
6. Inventário: durações "onze" → contar as 14+ (0,7 · 0,9 · 1,0 · 0,55 · 3,0); acrescentar `PerfilView.swift:237` aos fixos e `CartaoAnaliseView`/`CalendarioEscalas` ao movimento.

Feito isto, INTEGRAR sem novo G3 (o orquestrador confere as 6 linhas no diff). Nenhum achado alto contra a auditoria; os cinco altos do relatório ficam de pé e dois deles saem mais graves do que estavam.
