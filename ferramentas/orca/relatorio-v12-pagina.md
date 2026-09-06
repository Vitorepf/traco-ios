# Volta 12 — Página e Caderno até 9 (relato do implementador)

Fable front-end (concluída em Opus 5 após a cota estourar às 5:40), 06/09/2026,
worktree `volta-12-pagina`, base main `0d0d007`. Commit `5937943`. Simulador:
**iPhone 17 Pro C2416CBC** — ligado por mim, restaurado (`content_size` large,
`appearance` dark, `ReduceMotionEnabled` 0, permissão de calendário revogada,
app desinstalado) e **desligado por mim**. Nenhum simulador alheio foi tocado.
Todo `xcodebuild` passou por `ferramentas/orca/com-trava.sh`. Maestro não rodou
(é do revisor).

## As seis fases do `design-router`

**1. Ancorar.** VISAO-PRODUTO: a escrita é o instrumento que torna o pensamento
examinável; esta tela é a porta de entrada da escrita (ciclo MULTIPLICAR).
Contrato lido antes de tocar: SPEC §3, §11, §20, §21, §22 e as ADRs 02h, 03a,
04a, 04r, 04u, 05f, 05t, 05v. A lei que mais restringe a volta é a 05f: **a
régua e o pé de ações são desenho do dono e não se redesenham** — só se corrige
o que a auditoria e os portões apontaram.

**2. Sistema.** Fechado desde a V10: `SISTEMA-CLARO.md` (§1.5 sombra só no que
flutua, §2.3 componentes por estado, §5 movimento), `Tema` (Duracao, Mola,
Raio, Sombra, a lei por classe) e `Traco/Componentes` com dez componentes e
preview por estado. Nesta volta **nenhum componente novo foi criado**: só liguei
o que já existia (`.rotulo`, `.cartao`, `Pilula`, `CabecalhoDeFolha`,
`.discreto`, `.primario`, `LinhaDeEstado`) e apaguei um estilo local
(`CartaoBotaoStyle`).

**3. Auditar antes de tocar (é redesenho parcial).** Reproduzi no meu simulador
os defeitos que a V9 e os G4 nomearam, com o build de main instalado: o cartão
da forma vestida tomando o rodapé inteiro (`v12-antes-large-vestida.png`), as
ações fora da vista em AX5 (`v12-antes-ax5-vestida.png`), e — a prova mais
clara — a tira de quadros `v12-pe-quadros.png`: na linha de cima (main) o pé
"Trabalhar nisto · Analisar · Recordar · Anexar · Lente" **desaparece** assim
que a análise começa e não volta sob o cartão; nas duas de baixo (branch, sem e
com Reduzir Movimento) ele está em todos os quadros.

**4. Construir.** Sete correções, todas com dono num portão anterior — estão na
ADR 2026-09-05y (SPEC). A estrutural: o cartão, o aviso e a linha "lendo…"
saíram do rodapé e passaram a viver **acima** da régua e das ações, dentro do
mesmo `safeAreaInset` (`CadernoView.acima`); o rodapé deixou de ter "um ocupante
por vez".

**5. Mover.** Quem anima é a **altura do container** (§21): `Tema.gaveta` no
encaixe, nenhum cross-fade entre irmãos. Célula nova da tabela passou de
`Mola.escala` sob `.deslocamento` para `Duracao.media` easeOut — a classe que
declara (G4 V10). Pressão só por escala em `.primario` e `.compacto`, e a
`.animation` foi para **depois** do `scaleEffect` (a pressão do primário não
animava — B3 do G3 da V10). Vídeos com e sem Reduzir Movimento nos dois builds:
`v12-{antes,depois}{,-rm}-{vestir,borda}.mp4`.

**6. Julgar e Portão.** São do G3 e do G4, em sessões próprias. O que entrego
aqui é a evidência com a lei ao lado, sem nota minha nas dimensões que outro
julga — a autoavaliação abaixo é declaração, não veredito.

## `curva-zero` — a jornada

- **Pessoa e contexto.** O autor abre o app e escreve; a forma veste sozinha
  (§17.3). Pode estar com pressa, com o dedo já a caminho da régua, ou usando
  corpo de texto AX5.
- **Resultado verificável.** A nota é guardada com a forma e os campos, e a
  régua e as ações continuam alcançáveis do primeiro caractere ao Concluir.
- **Atrito observado (evidência, não hipótese).** V9: o toque mirado em "Todas"
  caiu no texto do cartão porque o cartão substituiu a régua e a linha de ações
  entre um quadro e outro (`v9-caderno-menu-todas.png`, reproduzido no 17e pelo
  revisor). Em AX3/AX5 as ações da página ficavam fora da vista.
- **Recuperação.** "Deixar como nota" desfaz a forma sem tocar no texto; o
  cartão sai e a régua volta. "voltar" na folha grava antes de fechar. A linha
  de gravação recusada (ADR 05s) fica na tela até o disco dizer sim — e agora
  **não cobre mais a barra de ações**, porque vive no fluxo, acima do pé.
- **Passos e decisões, antes e depois.** Escrever e concluir: 2 toques, 0
  decisões — inalterado. Vestir: automático. Abrir os campos: +1 toque. Em AX o
  pé passou de duas linhas (uma delas truncada em "Mais ações d…") para **um**
  menu que abre cinco ações: menos ruído na tela, mesmo poder a um toque.

## Evidência

**Instrumento.** Build sem aviso novo (só os dois pré-existentes de
`ConferenciaTrabalhoTests.swift:381`). Suíte integral no C2416CBC:

```
✔ Test run with 714 tests in 125 suites passed after 7.584 seconds.
```

Uma passada anterior acusou `ForaDoAppTests` ("soneca negada… não anuncia hora
nenhuma"): era **contaminação do App Group** pelo meu próprio uso do app com
permissão de calendário concedida (o app publicou `superficie.json`, que o teste
lê). Apagado o arquivo, a suíte passa inteira. Não é regressão do diff — nenhum
arquivo de `Intents/`, `Widget` ou `ForaDoApp` foi tocado.

**Merge com main.** Enquanto a volta corria, a trilha Fora do app mesclou a F3
(ADR 05w) em main, que tocou `PaginaView.seguirRota`. Mesclei main aqui: o único
conflito foi o fim da SPEC (duas ADRs novas), resolvido mantendo as duas em ordem
cronológica — 05w e depois 05y; `PaginaView` casou sozinha. Na árvore mesclada:

```
✔ Test run with 716 tests in 125 suites passed after 9.349 seconds.
```

O worktree fica pronto para o G5, sem conflito pendente.

**Capturas** (`ferramentas/orca/v12-<build>-<tamanho>-<estado>.png`, 27 PNG,
maior 328 KB): antes (main) e depois, em `large` e AX5, nos estados **vazia,
escrevendo, forma vestida, campos abertos, cartão da sábia e arquivo aberto pela
borda**. O roteiro é o mesmo nos dois builds, com o app reinstalado do zero antes
de cada travessia.

**Diff de pixels** fora da barra de status (60 pt), em pixels reais:

| par (antes × depois) | diff | leitura |
|---|---|---|
| arquivo pela borda, `large` | **0 px** | `Camadas` não moveu desenho |
| arquivo pela borda, AX5 | **0 px** | idem |
| página vazia com a aba presente | **0 px** | o alvo de 44 pt não moveu a cápsula |
| escrevendo, `large` | 484 px = 0,016 % | o caret piscando (bbox 6×81) |
| forma vestida, `large` | 15,8 % | intencional: o cartão sai do pé |
| forma vestida, AX5 | 27,8 % | intencional: idem + menu único |
| campos abertos, `large` / AX5 | 3,6 % / 9,8 % | intencional: cabeçalho da folha |
| escrevendo, AX5 | 7,6 % | intencional: o pé virou um menu |

O **cartão da sábia** não se compara por pixel: a sábia do aparelho escreve uma
resposta diferente a cada abertura. As capturas dos dois builds estão lá para
leitura, não para subtração.

**Vídeos** (≤ 19 s, ≤ 193 KB): `v12-antes-vestir`, `v12-depois-vestir` e os pares
`-rm-` (vestir e soltar, com e sem Reduzir Movimento); `v12-antes-borda`,
`v12-depois-borda` e os pares `-rm-` (arquivo pela borda + troca de aba). A tira
`v12-pe-quadros.png` mostra, a 30 fps, o pé sumindo em main e permanecendo no
branch, com e sem RM.

**Complexidade.** Swift do app **+158 −213 = −55 linhas líquidas** medidas em
`git diff 0d0d007..5937943 -- 'Traco/*.swift'` (regra da ADR 05v: cada volta por
tela apaga mais do que o componente cresce). Testes +33 (uma guarda nova).
Nenhum arquivo novo de código. Contra o HEAD do merge o balanço bruto vira +18,
porque a F3 entrou junto: o número da volta é o do commit `5937943`.

## Autoavaliação (declaração, não veredito — o G3/G4 julga)

| dimensão | como está | evidência |
|---|---|---|
| Visão | ciclo multiplicar, a porta de entrada da escrita; fecha a lacuna "Direção visual e uso simples" | linha G0 do RUMO + diff do EVOLUCAO |
| Contrato | ADR 05y em 40 linhas, SPEC e EVOLUCAO coerentes com o código | diff dos três |
| Correção | 714/0 em 125 suítes; guarda nova impede o retorno do desenho à mão e da opacidade no press | linha literal acima |
| Jornada real | seis estados vistos na tela nos dois builds, em `large` e AX5, conteúdo conferido | 27 capturas |
| Design | tudo cita `Tema`/`Componentes`; nenhum literal de cor, raio ou duração novo | diff + teste `paginaECadernoCitam…` |
| Simplicidade | o pé não muda de conteúdo sob o dedo; em AX, cinco ações num menu em vez de duas linhas truncadas | curva-zero acima |
| Movimento | altura do container anima; classe = curva; RM filmado nos dois modos | 4 vídeos + tira de quadros |
| Componentes | seis estilos no repositório, não sete; `CartaoBotaoStyle` apagado; nenhum componente novo | diff |
| Acessibilidade | ações alcançáveis em AX5 sem rolar; degradê diz que o texto rola; aba do arquivo com 44 pt de alvo | capturas AX5 |
| Performance | n/a: nada de lista, parser ou editor novo; nenhuma medida feita | — |
| Privacidade e autoria | nenhuma rota de dados tocada; o texto do autor não muda em nenhum caminho | diff |
| Estado honesto | a linha de gravação recusada e o toast convivem com a barra sem cobri-la | `acimaDoPe` no diff |
| Complexidade | −55 linhas líquidas no app | shortstat |
| Fora do app | n/a: nada de widget, Ilha ou intent nesta volta | — |
| Relato | este arquivo + seis linhas no `worker_done` | — |

## O que ficou de fora (e por quê)

1. **Régua em AX com o cartão em cena**: cede e volta quando o cartão sai. Uma
   terceira barra não cabe em AX5; declarado como custo na ADR.
2. **Oscilação da aba do arquivo na página vazia**: presente em 1 de 3 lançamentos
   em main e 2 de 3 no branch, sempre na mesma faixa y — corrida do evento de
   teclado, anterior a esta volta. Vai à FILA, não é regressão.
3. **`BarraBotaoStyle`** (o pé da página) continua trocando a opacidade do FUNDO
   no press (0,85 → 1). É desenho do dono (05f) e não afeta contraste de texto;
   não toquei.
4. **VoiceOver real e `maestro hierarchy`**: não rodei maestro (é do revisor) e
   VoiceOver ligado exige humano.
5. **A sábia sem conta Grok**: o cartão "sem conta" não foi capturado — o
   simulador tem o modelo do aparelho e responde.
