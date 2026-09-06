# G4 design — volta 8, acessibilidade real (ADR 2026-09-05t)

Julgador: Claude Fable 5.1, segundo Fable, sessão própria, 05/09/2026 ~20h30. Branch `Vitorepf/volta-8-acessibilidade` topo 5c71246 sobre main e51550e. Fases Mover, Julgar e Portão do design-router; leis: SISTEMA-CLARO §5 (movimento), SPEC §11/§20/§21/§22, ADRs 02h, 04d, 04f, 04u, 05f, 05t.

Instrumento: iPhone 17 Pro **C2416CBC** (encontrado desligado, texto `medium`, Reduce Motion 0, aparência dark; ligado por mim, build do branch via `com-trava.sh` em `-derivedDataPath` do scratch, `TRACO_SEM_MODELO=1`; ao fim: texto `medium`, Reduce Motion 0, env removido, status bar limpa, **desligado**). Nenhum outro simulador tocado; o iPhone 17 do dono não foi tocado. Nenhum código editado, nada commitado.

## Veredito: CORRIGIR ANTES — lista mínima de um item

A volta faz o que a ADR diz: uma lei de movimento reduzido num lugar, quem vê em tamanho normal não perde um pixel, AX5 legível nas cinco telas, alvos de 44 reais. O que impede o merge hoje é um só defeito de movimento que a volta introduziu no caminho principal do §20: com Reduce Motion, ao soltar o dedo depois de trazer o arquivo pela borda, **o arquivo inteiro some por um quadro e volta em fade** (`Camadas.swift:55-56`). Quem enjoa arrastou um painel até o lugar e vê o painel piscar. Correção de uma condição; não reabre o G3.

## Notas do G4

| dimensão | nota | evidência |
|---|---|---|
| Design | 9 | Tamanho normal: 0 px em Notas, mês, ano, Recordar e cartão; página 26 px (teclado, `v8-fix-diff-pagina.png`); dia/semana só a linha "agora" (relógio, não desenho). Conferi as capturas do implementador e do G3 contra o que vi no meu simulador (`g4-v8-xs-regua.png`: chips no mesmo x de `v8-normal-pagina.png`). AX5: hierarquia título > conteúdo > ações nas cinco telas (`v8-reg3-ax5-01..05.png`); régua e cabeçalhos em `xxxLarge` seguem a regra das barras do sistema (a barra de abas já parava em `xLarge`). Cartão da forma em AX: ações presas no pé é o padrão da ficha do sistema (texto rola, ações ficam), não remendo — mas o corte do texto rolável é seco (meio glifo de "obstáculo", sem indicador nem degradê; `v8-fix-ax5-pagina-cartao.png`), vai ao RUMO |
| Movimento | 8 | Lei coerente com SISTEMA-CLARO §5: `fadeReduzido` 0,15 s = "reduceMotion: fade 0,15s em tudo"; curvas normais intactas (morph 0,55/0,86, gaveta timingCurve, barra interpolatingSpring). Meu vídeo `g4-v8-rm.mp4` e quadros: escalas Dia→Semana→Mês→Ano em crossfade de ~2 quadros com o segmento D/S/M/A e o título dizendo onde se está (`g4-v8-rm-dia-semana-quadros.png`) — orientação preservada por âncora, não por deslocamento, é o certo em RM; fechar por "Escrever" corta seco e limpo (`…-camadas-fecha-quadros.png`); cartão da forma entra por fade (`…-cartao-quadros.png`). **Defeito:** abrir pela borda — o dedo arrasta (manipulação direta, legítima), ao soltar `arrastando` vira falso um quadro antes de `arquivoAberto`, a opacidade cai a 0 e o arquivo reaparece em fade sobre a página escurecida: `g4-v8-rm-camadas-pisca.png` quadros 2→3→4 (arquivo a 90 % → só página cinza → Notas). Pelo toque na aba o mesmo fade corre sobre a página já escurecida (`fracao` salta com o corte): flash cinza de 150 ms por construção |
| Simplicidade | 10 | Nenhum passo, decisão ou tela nova; ações de rotor são adicionais; `View.alvo()` tira 38 frames soltos e põe um nome |
| Acessibilidade | 9 | Alvos: medi no meu simulador em **extra-small** a régua toda ≥ 44 (`regua-lista` 44×44, `titulo` 49×44, `todas` 51×44, "Notas" 38×44) — o custo "42 abaixo de large" da ADR não se reproduziu no menor tamanho. "Deixar como nota" meio sob o teclado (achado médio do re-G3) é **transitório**: o app solta o foco ao vestir e o teclado desce em ≤ 0,3 s; em repouso as duas ações estão inteiras com e sem teclado (`g4-v8-ax5-cartao-repouso.png`, fluxo com `hideKeyboard` e asserts verdes). Aba do arquivo 23 pt: alvo de borda de tela, altura total (`frame(maxHeight: .infinity)`) — Fitts na borda é infinito num eixo; aceitável. "pular" com 44 de altura e ~34 de largura, fora do caminho principal; RUMO. Rotor e hints seguem sem prova por instrumento: VoiceOver real é do humano |

## Mover — respostas

1. **Curvas e durações**: coerentes. Um valor de fade (0,15 s), as curvas normais não mudaram; `Tema.cartao` morto saiu. Sem RM, nada mudou (diffs do implementador e do G3, dois instrumentos).
2. **Orientação com RM**: nas escalas e no fechar, sim — o segmento selecionado, o título e a aba acesa dizem onde se está. No abrir pela borda, não pela razão certa: o painel pisca (acima).
3. **Discordo do vídeo do implementador em um ponto**: `v8-fix-rm.mp4` abre o arquivo e mostra o quadro cinza como se fosse o fade previsto; nos meus quadros densos vê-se que é o arquivo sumindo depois de estar a 90 % sob o dedo.

## Julgar — respostas

- **Tamanho normal**: não mudou um pixel onde importa; os 26 px e a linha "agora" são relógio e teclado do sistema. Aceitável.
- **AX5, cinco telas**: legíveis; o único corte visível é "Numera…" sob a máscara da régua, que é rolável e tem "Todas" ao lado.
- **Cartão com ações no pé**: bom padrão (ficha do sistema), consistente com "ficha" de SISTEMA-CLARO §6. Falta o sinal de que o texto rola.
- **"Deixar como nota" sob o teclado**: não é defeito; é o quadro antes do teclado descer.
- **Custos da ADR**: chips 42 abaixo de large — não reproduzi (44 em extra-small); ADR pode dizer "≥ 44 medido de extra-small a large". "pular" estreito e aba de 23 pt: custo justo, não fluxo confuso.

## Portão

**Entra em main depois de um item:**
1. `Camadas.swift:55-56` — com RM, o arquivo não pode sumir ao soltar o dedo. Duas saídas coerentes com a lei: (a) corte total em RM (posição E opacidade, como o pé das Notas: "o corte é o outro lado permitido da lei") — remove a opacidade condicional e o `.animation(fadeReduzido)`; ou (b) manter o fade mas condicioná-lo a `!animandoPeloGesto` também, e animar o escurecimento (`fracao`) com o mesmo `fadeReduzido` para o fade não correr sobre cinza. Recomendo (a): menos código, zero quadro cinza. Prova: quadros densos do abrir pela borda e pela aba com RM ligado, sem quadro só-cinza.

**Vai ao RUMO (V12 Página / V10 fundação):**
- Cartão da análise em AX: indicador de rolagem ou degradê no pé do texto rolável (V12 Página).
- Crossfade de aba dentro do arquivo (§20, 0,18 s) mostra quadro acinzentado entre Notas e Calendário — pré-existente, ocorre sem RM; verificar em main e decidir se o fundo do crossfade deve ser o papel (V10 fundação).
- `alvo()` sem `minWidth`: "pular" e semelhantes ficam estreitos; um `minWidth: Tema.alvo` opcional em `alvo()` (V10 fundação).
- Confirmação, Padrões e Trabalho ainda com `frame` sem `contentShape` (já na ADR).
- `Tema.cartaoEntra/cartaoSai` órfãs (re-G3, baixa).
- Peso: 9,6 MB + 8,6 MB de binários nos dois commits; recortar as capturas AX5 do calendário.

## Três linhas para o LACO

- G4 da volta 8: Design 9, Movimento 8, Simplicidade 10, Acessibilidade 9 — CORRIGIR ANTES por um item.
- Com Reduce Motion, trazer o arquivo pela borda faz o painel piscar ao soltar o dedo (`g4-v8-rm.mp4`); correção de uma condição em `Camadas`, sem reabrir o G3.
- O resto passa: nenhum pixel mudou em tamanho normal, AX5 legível nas cinco telas, alvos 44 medidos de extra-small a large, "Deixar como nota" sob o teclado é transitório.

## Arquivos deste G4

`ferramentas/orca/g4-v8-design.md` (este), `g4-v8-rm.mp4` (abrir pela borda com o pisca, fechar por Escrever, Dia→Semana; 30 fps, 604 px), `g4-v8-rm-camadas-pisca.png` (os quatro quadros do defeito), `g4-v8-rm-camadas-abre-quadros.png`, `g4-v8-rm-camadas-fecha-quadros.png`, `g4-v8-rm-dia-semana-quadros.png`, `g4-v8-rm-cartao-quadros.png`, `g4-v8-ax5-cartao-repouso.png`, `g4-v8-xs-regua.png`. Vídeos brutos (22 MB + 12 MB), fluxos maestro e hierarquia em extra-small ficaram no scratch da sessão.

---

## Re-G4 — só o item corrigido (commit 4a118b1)

Julgador: Claude Fable 5.1, segundo Fable, sessão própria, 05/09/2026 ~21h. Topo 4a118b1 sobre 5c71246 sobre main e51550e. Instrumento: iPhone 17 Pro **C2416CBC** (encontrado desligado, RM 0, texto `medium`, dark; ligado por mim, build do branch e de main via `com-trava.sh` em `-derivedDataPath` do scratch, `TRACO_SEM_MODELO=1`; ao fim: RM 0, texto `medium`, env removido, status bar limpa, **desligado**). Nenhum outro simulador tocado; o iPhone 17 do dono não foi tocado. Nada editado, nada commitado. `git merge-tree --write-tree e51550e 4a118b1`: sem conflito.

### Veredito: PASSA — segue ao G5

| dimensão | G4 | Re-G4 | evidência |
|---|---|---|---|
| Movimento | 8 | **9** | Com RM, as quatro trocas pela borda (abrir, fechar, abrir, fechar) cortam em UM quadro, do arrasto direto para a tela final; nenhum quadro só-cinza em 1 332 quadros (`g4-v8-reg4-rm.mp4`, `g4-v8-reg4-rm-quadros.png`). Sem RM, a mola é a de main (código e vídeo, abaixo) |
| Design | 9 | 9 | Nada mudou fora de `Camadas`/`Tema`; capturas do G4 seguem válidas |
| Simplicidade | 10 | 10 | A correção APAGA duas linhas (opacidade condicional + `.animation`) e nomeia a lei (`Tema.corte`): menos código que antes |
| Acessibilidade | 9 | 9 | Inalterada; `accessibilityHidden(!arquivoAberto)` e `allowsHitTesting` continuam no mesmo lugar |

### O que conferi

1. **Diff `5c71246..4a118b1`**: saem `.opacity(reduceMotion && !arquivoAberto && !arrastando ? 0 : 1)` e `.animation(reduceMotion ? fadeReduzido : nil, value:)`; `mola` vira `Tema.corte(spring, reduzido:)`, que devolve `nil` em reduzido e o spring intacto (0,55/0,82) fora dele. É a saída (a) que o G4 recomendou. Teste `oQueSeArrastaCortaSecoEmReduzido` cobre os dois lados; rodei a suíte `TemaTests` no meu simulador: 3 testes, verde.
2. **Evidência do implementador** (`v8-fix2-rm.mp4`, 368 quadros a 30 fps): luma médio por quadro nunca cai abaixo do arrasto; as trocas vão 209→217 (abrir) e 211→220 (fechar) sem degrau intermediário. O quadro "só página cinza" do `g4-v8-rm-camadas-pisca.png` (quadro 3) não existe mais.
3. **Reproduzi no meu simulador com RM ligado**: fluxo maestro `swipe 1%→85%` / `99%→15%` duas vezes, gravado por `simctl io recordVideo`. Borda direita do painel medida por quadro (linha a 35 % da altura): abrir 1 — 500 px sob o dedo no quadro 407, tela inteira no 408; fechar 1 — 112 px no 458, página inteira no 459; idem nas repetições (569, 618). Luma por quadro: 209→217 e 211→220, nenhum quadro ≤ 204 fora do arrasto. Corte seco, posição e opacidade juntas, como a ADR agora diz.
4. **Sem RM, a mola é a mesma**: (a) contra main, `Camadas.swift` só muda a assinatura de `mola` — o spring é literalmente `.spring(response: 0.55, dampingFraction: 0.82)` nos dois; a opacidade condicional e o `.animation(nil)` que saem tinham nascido nesta volta (4689e25), não existem em main. (b) Gravei o mesmo fluxo sem RM com o branch e com **main e51550e** construído no mesmo simulador: o fechar tem a mesma cauda de mola de ~30 quadros nos dois (branch 594–625, main 623–655, com o mesmo sobe-e-desce 215/216/215/217 no pouso); o abrir tem o mesmo perfil nos dois.
5. **ADR 05t** (SPEC.md:2409-2410) agora diz "Camadas corta seco, posição e opacidade juntas, sem fade (o G4 viu o painel sumir um quadro sob o dedo ao soltar, 05/09)": é o que o código faz e o que o vídeo mostra. Verdade.

### Observação para o RUMO (pré-existente, igual em main; não é desta volta)

Sem RM, ao soltar o dedo no ABRIR pela borda (maestro solta a 85 %), o painel vai de ~83 % a 100 % da largura em um quadro nos dois builds — branch e main — enquanto o FECHAR mostra a cauda da mola inteira. Ou é o gravador do simulador engolindo o fim da mola, ou a troca de árvore ao virar `arquivoAberto` (16 ms depois do soltar) ainda crava a posição no abrir, como o comentário de `Camadas.onEnded` descreve que acontecia. Verificar no aparelho do dono com quadros densos; se for real, é a mesma pendência de "mola não acelera na chegada", agora no abrir (V10 fundação).

### Três linhas para o LACO

- Re-G4 da volta 8: Movimento 9, Design 9, Simplicidade 10, Acessibilidade 9 — **PASSA**, segue ao G5.
- Com Reduce Motion, o arquivo agora corta seco ao soltar o dedo, sem o quadro cinza; medido em dois instrumentos (vídeo do implementador e o meu, 4 trocas pela borda).
- Sem RM nada mudou: spring idêntico a main no código e no vídeo comparado com main construído no mesmo simulador; um possível crave no abrir é pré-existente e vai ao RUMO.

### Arquivos deste Re-G4

`g4-v8-reg4-rm.mp4` (9 s, 604 px, as quatro trocas com RM), `g4-v8-reg4-rm-quadros.png` (6 quadros em torno de cada soltar). Vídeos brutos (branch com RM, branch sem RM, main sem RM), builds e fluxos ficaram no scratch da sessão.
