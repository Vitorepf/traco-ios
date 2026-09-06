# F4 — Os widgets da tela de início prestam (ADR 2026-09-06d)

Worker: Claude Opus 5 (trilha Fora do app), 06/09/2026, worktree `f4-widgets`
sobre main `d1248ce`. Simulador desta volta: **iPhone 17 Pro (teste 3)**
`34CC3F94-FDB5-4575-A4F5-80271829A18B` (ligado, usado e desligado por esta
volta). Instrumento: todo `xcodebuild` por `com-trava.sh`; sem maestro —
`cliclick` na janela do meu aparelho, com `AXRaise` antes de cada toque.

**G0.** Ciclo MULTIPLICAR. Intenção: olhar a tela de início e saber o que vem
agora, e agir dali. Obstáculo: os widgets existiam, mas não informavam, não se
atualizavam e não pareciam o Traço — veredito do dono às 13:04, com print do
iPhone real: os dois widgets diziam "atualizado às 04:14", nove horas parados.

---

## design-router — as seis fases

### 1. Ancorar (é redesenho: auditar ANTES de tocar)

Antes de uma linha de SwiftUI, os três widgets foram plantados na casa do meu
simulador e capturados com dado e vazio. O que a captura mostrou, item a item
da lista do dono — e o que ela ACRESCENTOU:

| # | achado | evidência |
|---|---|---|
| 1 | `TracoWidget.swift:349` `policy: .never` no Próximo; `:45` `.atEnd` só com mais de uma entrada. Sem o app abrir, o WidgetKit nunca mais pede nada | `f4-antes-inicio-claro.png`: relógio **13:30**, rodapé **"atualizado às 13:23"** nos três widgets |
| 2 | "atualizado às HH:MM" em `:75` e `:211`, sempre — um terço do pequeno | mesma captura |
| 3 | Médio inteiro para "nada marcado"; pequeno vazio = dois links e um filete | `f4-antes-inicio-vazio.png` |
| 4 | Sem cor, sem ícone, sem hierarquia; o pequeno parece menu de sistema | todas |
| 5 | O médio do Próximo gasta 4×2 em quatro linhas curtas | `f4-antes-inicio-claro.png` |
| **6** | **(meu)** a linha do Destaque **trunca** no pequeno: "Terminar o / capítulo do…" — o widget existe para mostrá-la inteira | `f4-antes-inicio-claro.png`, widget do meio |
| **7** | **(meu)** `Sessao.encadear` grava compromisso no disco pela rota sem agenda em cena e **não republica**: o widget só o via na volta seguinte ao app | leitura de `Traco/App/Sessao.swift:742` |
| **8** | **(meu)** o AX5 do pequeno já cabia, mas o médio não tinha plano para tamanho de acessibilidade | `f4-antes-inicio-ax5.png` |

Invariantes preservadas: a superfície da 05u (um documento no App Group escrito
só pelo app), o botão de feito com identidade, a soneca, as Live Activities, o
selo (nada selado, queimado ou expressivo sai do app), a tipografia por `Tema`.

### 2. Sistema

Nenhum token novo. O que já existia e a casa não usava: o **ponto âmbar**, a
marca que a tela bloqueada carrega desde a 05u (`DestaqueVivo`,
`CompromissoVivo`). Trazê-lo para o widget é o que faz as quatro superfícies
pertencerem ao mesmo app. Consumidos de `Tema.swift` (não editado, V12 está
dentro dele): `ambar`, `ambarTinta`, `tinta`, `tintaSuave`, `tintaFraca`,
`linha`, `aviso`, `fundo`, `label`/`trackingLabel`, `miudo`, `meta`, `chrome`,
`tituloTela`/`trackingTitulo`. O widget segue **papel no escuro** (D11): o app
é `preferredColorScheme(.light)` e a casa não mente sobre isso.

### 3. Construir

Quatro peças novas, todas dentro de `TracoWidget/`:

- `Selo` — ponto âmbar + rótulo + o estado, **só quando é verdade**.
- `AtalhoTraco` — glifo + palavra numa linha (era texto de largura inteira com
  filete no meio). O `corpo` é reusado sem `Link` no pequeno, onde o sistema
  honra um destino só.
- `LinhaProximo` — hora | assunto | sino, para largura inteira.
- `BlocoProximo` — hora como manchete, para 155 pt.
- `Oferta` — o estado numa linha e, quando a ação não está dita ali perto, UMA
  ação.

E `TracoWidget/Relogio.swift`, só aritmética de datas de propósito: a lei da
linha do tempo (entradas do dia, teto, piso) fora do WidgetKit, para caber numa
suíte.

### 4. Mover

**Nenhuma animação acrescentada, de propósito.** A única transição destes
widgets é a do estado do feito, e quem a desenha é o WidgetKit ao trocar de
timeline — animação decorativa por cima disso é o que a ESTEIRA chama de
acabamento que compensa fluxo. Vídeo da transição real:
`f4-um-toque-feito.mp4` (marca → desmarca → marca, sem abrir o app).

### 5. Julgar

Duas correções nasceram de olhar a própria captura, não do código:

- o médio em **duas colunas** cortava "Dentista" em "De…" e quebrava a hora do
  sino em quatro linhas. Virou **faixas de largura inteira**.
- o pequeno sem Destaque usava `LinhaProximo` e a hora do sino descia em
  coluna ("1/4/3/3"). Virou `BlocoProximo`.
- o pequeno vazio mostrava **"Nova nota" duas vezes** (na oferta e no rodapé).
  `Oferta` ganhou rótulo opcional.

### 6. Portão

Build dos dois alvos sem aviso; suíte integral verde; capturas por estado,
antes e depois; prova do refresh; limites do instrumento declarados abaixo.

---

## curva-zero — o roteiro do vazio

- **Jornada.** O autor olha a tela de início entre duas coisas. Não vem
  "usar o Traço": vem saber se há algo agora. Quando não há, a superfície tem
  de dizer isso e deixar UM caminho aberto, sem ele ter de lembrar de qual
  aplicativo abrir nem de qual gesto usar.
- **Resultado verificável.** Da tela de início, sem abrir o app: ou ele lê o
  que vem, ou ele marca a única coisa de hoje como feita, ou ele chega numa
  página em branco. Um toque, uma coisa.
- **Atrito observado.** `f4-antes-inicio-vazio.png`: um widget médio inteiro
  ocupado por "nada marcado" e "atualizado às 13:31". Duas informações, e a
  segunda é sobre o próprio widget. Nada a fazer ali; nada a aprender ali.
- **Recuperação.** Vazio deixou de ser um beco: sem Destaque, o widget do
  Traço mostra o próximo compromisso (mesmo instantâneo, dado nenhum novo);
  sem compromisso, o do Próximo mostra a única coisa de hoje **com o círculo
  que a marca** — a recuperação é a própria ação. Só quando não há nada é que
  aparece a oferta, uma só: "Nova nota" / "Marcar um compromisso". O poder não
  sumiu: "Recordar" continua no médio e no app.

---

## Antes e depois, lado a lado

| estado | antes | depois |
|---|---|---|
| casa com dado, claro | `f4-antes-inicio-claro.png` — relógio 13:30, "atualizado às 13:23" nos três; Destaque truncado no pequeno; médio do Próximo com quatro linhas curtas | `f4-depois-inicio-claro.png` — Destaque inteiro; médio do Traço com a linha + dois compromissos; médio do Próximo com **três** (hora, assunto, hora do alarme); hora do iminente em âmbar; nenhum rodapé |
| casa com dado, escuro | **as três capturas `-escuro` da F4 NÃO estavam em modo escuro** (G3, A4: brilho médio idêntico ao do claro na primeira decimal). Refeitas na F4-B: `f4b-casa-escuro.png`, brilho médio **140,1** contra **187,5** de `f4b-casa-claro.png` | `f4b-casa-escuro.png` — papel branco sobre casa escura, D11 provado |
| casa vazia | `f4-antes-inicio-vazio.png` — "nada marcado" + "atualizado às 13:31"; pequeno = dois links e um filete | `f4-depois-inicio-vazio.png` — "Nada em destaque hoje." + uma ação; "Nada marcado." + "Marcar um compromisso" |
| só Destaque (agenda vazia) | n/a (não existia esse desenho) | `f4-depois-inicio-so-destaque.png` — o widget do Próximo traz a única coisa de hoje, com o círculo |
| só compromissos (sem Destaque) | n/a | `f4-depois-inicio-so-proximos.png` — o widget do Traço traz o que vem, em bloco |
| Dynamic Type grande | `f4-antes-inicio-ax5.png` (+ `-escuro`) | `f4-depois-inicio-ax5.png` (AX5) e `f4-depois-inicio-ax3.png` (AX3) — sem clipe; o médio abre mão dos atalhos e da agenda, a única coisa vem primeiro |
| tela bloqueada | `f4-antes-bloqueada.png` | `f4-depois-bloqueada.png` — Live Activity do compromisso intacta (fora do escopo desta volta) |
| StandBy | — | `f4-standby-indisponivel-simulador.png` — **limite do instrumento**, ver abaixo |

## Prova do refresh (item 1, sem a qual nada disto conta)

1. `f4-refresh-1-antes.png` — casa com Dentista, Revisão e Jantar.
2. `f4-refresh-2-app.png` — no app, pela prosa do calendário: "Padel hoje 18h";
   a ficha abre com 18:00–19:00 e "Toca hoje às 18:00".
3. `f4-refresh-3-depois.png` — **de volta à casa, sem reinstalar nada**, o
   médio do Próximo mostra `18:00 Padel 🔔 18:00` no lugar do Jantar, e os
   sinos dos outros dois viraram hora real (14:37 / 16:47) porque os avisos
   foram autorizados no mesmo minuto.
4. `f4-chronod-releitura.txt` — o `chronod` do simulador, no minuto da
   instalação: `Scheduling staleness check in 11687s: roughly
   2026-09-06T17:18:58-03:00` para `TracoWidget:systemMedium`,
   `:systemSmall` e `TracoProximo:systemMedium`. Três horas à frente, que é o
   teto de `Relogio.releitura`. Com `policy: .never` não havia releitura
   agendada nenhuma — era exatamente o defeito.

## Limites do instrumento (fato registrado, nunca sucesso simulado)

- **StandBy não renderiza no simulador.** Trancado e girado para paisagem, o
  aparelho continua na tela bloqueada comum (`f4-standby-indisponivel-simulador.png`).
  Mesmo limite da F1 §7. Pendente no aparelho do dono.
- **Accessory na tela bloqueada trancada** também não renderiza (F1 §7). As
  famílias `accessoryRectangular`/`accessoryInline` **não foram alteradas por
  esta volta** — seguem como a 05u as deixou.
- **Ilha mínima** exige outra atividade viva ao mesmo tempo; não capturada.
  A Ilha compacta aparece nas capturas (o Destaque e o compromisso vivos).
- O relógio do meu simulador anda ~44 min atrás do relógio do Mac; por isso as
  horas dos compromissos (semeados pelo relógio do Mac) e o relógio da barra
  não batem entre si nas capturas. Não afeta nenhuma das provas.
- **RETIRADO (F4-B).** Eu havia escrito que não consegui pôr o pequeno do
  Próximo na casa por limite da galeria do iOS 26. Era falso: a página do app
  é um carrossel de quatro, e o pequeno do Próximo é a terceira. O revisor
  plantou-o em três minutos; eu plantei os quatro de novo na F4-B. Um limite
  que não existe é desculpa, não fato — e sai do relato.
  Prova: `f4b-casa-claro.png`, `f4b-casa-escuro.png`.

## Dívida nomeada

- `Relogio.swift` entrou nas fontes do alvo de testes em `project.yml` (duas
  linhas). É a única maneira de a lei da linha do tempo ter teste sem mover
  código para `Traco/App/Intents/Compartilhado/`, que é escopo da F3b.
- O médio do Traço com um compromisso só ainda usa `LinhaProximo` e sobra
  espaço; com dois ou três ele fica cheio. Nada quebrado, só menos denso do
  que poderia.
- **RESOLVIDO (F4-B).** O `Selo` não diz mais o estado, e `Tema.aviso` saiu
  do widget: o estado desceu para a linha do conteúdo, onde cabe inteiro.
