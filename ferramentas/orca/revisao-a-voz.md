# G3 — revisão das voltas A1 a A4: a voz do app e a proteção da escrita pessoal

Branch `Vitorepf/volta-a1-aviso` (8883d33, 3c4ff6c) · revisor Claude Opus 5 em
sessão própria · 06/09/2026 · simulador **iPhone 17 Pro (teste 4)**
`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, tudo sob `ferramentas/orca/com-trava.sh`.
Nada foi editado nem commitado no código do implementador.

**Veredito: CORRIGIR ANTES.** Oito dimensões abaixo de 9 — Contrato 6,
Design 6, Correção 7, Acessibilidade 7, Privacidade e autoria 7, Jornada real 8,
Estado honesto 8, Fora do app 8 — e quatro achados ALTOS. Nenhum deles derruba o que a volta ganhou — a
guarda funciona, o aviso ficou honesto, o enum morto era mesmo morto —, mas dois
deles são a mesma doença que a volta veio curar, aparecendo um passo ao lado, e
um terceiro é um número errado no contrato que decide a ordem de mescla.

---

## 1. O que eu confirmei do que ele afirma

| afirmação dele | veredito | prova |
|---|---|---|
| 730 testes em 127 suítes verdes no teste 4 | **confirmado** | `Test run with 730 tests in 127 suites passed after 7.599 seconds`, `** TEST SUCCEEDED **`, corrida minha no A1DF082C |
| build sem aviso dele | **confirmado** | build do zero em `-derivedDataPath` novo: `** BUILD SUCCEEDED **`, 149 compilações Swift, **0 avisos** |
| as 22 frases passam com a guarda, e sem ela o mesmo arquivo acusa as 22 | **confirmado, e refeito por mim fora do app** | banco de sondas em `/tmp/claude-501/rev-a` reproduzindo `detectarGesto` palavra por palavra sobre o `Metodos.json` real + os SETE da M3: com guarda 22/22 em `silencio`; sem guarda 22/22 vestidas — 14 `exameDaNoite` + 8 `colunaEsquerda` |
| as 6 frases legítimas continuam dos dois métodos | **confirmado** | mesmo banco: 6/6 chegam ao método esperado |
| 287 sondas | **confirmado** | port literal do expansor `Sondas` da M3 + `Metodos.json` da M3: `sondas totais: 287`; controle sem a guarda dá 0 falhas além das 4 já `conhecidas` — o port reproduz o teste verde da M3 exatamente |
| **15 ramos fecham (3 Coluna + 12 Exame)** | **ERRADO: são 14 (3 + 11)** | ver A-4 |
| `GestoDeBordo` e `instrucoes` mortos desde a 04l | **confirmado** | `git grep` no merge-base: nenhuma referência fora da própria declaração; o runtime usa `DynamicGenerationSchema(name: "GestoDeBordo")` — uma *string*, não o tipo — e `instrucoesDoCatalogo`. Os três leitores (você incluído) leram um contrato que o código não executava |
| o texto do `avisoWood` bate com a ficha | **confirmado, palavra por palavra** | `ferramentas/orca/metodos/aviso-wood.md` (em main, ainda não neste branch), seção "Texto proposto (recomendado)"; a EVIDÊNCIA da proveniência também é literal da ficha |
| os 5 testes novos falham contra o texto antigo (4 issues) | **confirmado por leitura** | `nenhumAvisoAlegaEficacia` acusa `"não gruda"` e `"gruda"` (2), `oAvisoDaAfirmacaoDizOQueOEstudoMediu` acusa a ausência de `"2009"` e `"autoestima"` (2) = 4 issues em 2 testes. Não rodei contra o texto antigo porque isso exigiria editar o código dele |
| D1: o simulador não executa App Shortcuts | **é limite de instrumento, não falha** | build de simulador sem team-identifier; a lista por voz não é verificável aqui, e ele diz isso |
| os hunks não se sobrepõem com a volta 12 / F3b | **confirmado no Swift, com uma correção de fato** | ver §5 |

**As quatro capturas dele: conteúdo real, conferido, não só o arquivo.**
`a3-antes-exame-da-noite.png` mostra "Perdi a paciencia com ela hoje. Me
arrependi e chorei." com o cartão EXAME DA NOITE e "Que defeito você conteve?";
`a3-depois-a-nota-fica-do-autor.png` é o mesmo texto, sete minutos depois, sem
cartão; `a3-o-exame-continua-alcancavel.png` mostra "Passei o dia em revista"
chegando ao Exame; `a1-aviso-cartao.png` mostra o cartão AVISO com as sete
linhas do texto novo, sem corte. As três da A3 são do mesmo aparelho e da mesma
hora que ele declara.

---

## 2. Achados ALTOS

### A-1 · A guarda vale só para a CAUDA do catálogo. 15 de 20 desabafos novos meus continuam vestidos de exercício.

`detectarGesto` pula o método quando `pessoal && i > iExpressiva`. A Expressiva é
o índice **5** de 21 no `Metodos.json`. Os cinco que vêm antes — `woop`,
`seEntao`, `spec`, `notaPermanente`, `destaque` — **não são cobertos**. E o
`return .destaque` do rodapé (3+ linhas curtas), que fecha a mesma função,
calcula `pessoal` e **nunca o usa**.

Inventei 20 desabafos meus, do jeito que alguém escreve às onze da noite. **15
foram vestidos:**

```
seEntao        Chorei muito hoje. Sempre que ele fala assim eu me calo e depois passo a noite inteira remoendo.
seEntao        Não consigo parar de pensar no que eu disse pra ela. Doeu ver a cara dela quando eu falei aquilo.
notaPermanente Percebi hoje que eu magoei a minha filha e estou me odiando por isso desde a hora do almoço.
seEntao        Toda vez que a minha mãe liga eu fico com raiva e depois com culpa, e hoje não foi diferente.
woop           Quero parar de ser assim. Hoje eu perdi a paciência de novo e senti vergonha na frente de todo mundo.
woop           Meu objetivo era não chorar hoje e eu chorei antes das dez da manhã, sozinho no carro.
destaque       "Chorei. / Fui grosso com ela. / Estou pesado."          ← pelo rodapé, sem regex nenhuma
destaque       "Doeu muito. / Nao falei nada. / Hoje foi horrivel."     ← idem
spec           Hoje eu não sirvo pra nada. Passei o dia olhando a TELA sem conseguir fazer nada, e à noite a conversa com o meu pai só piorou tudo.
colunaEsquerda Estou exausto e vazio. Não durmo há três dias e hoje na reunião com o time eu simplesmente desliguei…
notaPermanente A IDEIA de que eu estraguei aquela amizade não sai da minha cabeça, chorei no banho de novo.
notaPermanente Entendi que eu sou o problema. Fui grosso com ela sem motivo nenhum e agora ela nem responde.
seEntao        Sempre que eu penso naquela conversa eu travo. Engoli tudo de novo…
woop           Preciso parar de fazer isso comigo. Hoje eu me odiei o dia inteiro.
seEntao        Estou sozinho nisso. Sempre que eu preciso de alguém não tem ninguém…
```

"sempre que", "toda vez", "percebi", "ideia", "quero parar", "tela" são as regex
mais largas do catálogo, e são exatamente as palavras de quem está desabafando
sobre um padrão que se repete. **É o mesmo dano da A3 — o desabafo recebendo
cartão de exercício — pela porta da frente em vez da porta dos fundos.**

Isto **não é regressão**: os cinco de antes da Expressiva já faziam isso ontem.
O que muda é a ALEGAÇÃO. O título da ADR é "A escrita pessoal é da Expressiva,
**e de mais ninguém**", e a linha nova do EVOLUCAO diz "a escrita pessoal deixa
de ser matéria de exercício". O código diz outra coisa, e o comentário no fonte
("passada a Expressiva, nenhum método leva") é a versão honesta que não subiu
para o contrato. Uma das duas tem de ceder.

**O que o autor da correção decide:** (a) mover a guarda para antes do laço
inteiro, e aí o teto de 120 volta a ser a única defesa da nota curta; (b) manter
o desenho e **reescrever ADR, SPEC e EVOLUCAO** para dizer "os métodos depois da
Expressiva"; (c) no mínimo, e sai de graça, aplicar `pessoal` também ao rodapé
do Destaque — está dentro da função que ele já editou e fecha os dois casos de
três linhas acima.

*Nota a favor do desenho dele:* a ordem do catálogo **é** confiável para o que
ele queria proteger. `Catalogo.recarregar` sempre faz `novos.append` dos
arquivos do autor DEPOIS do bundle, e recusa um arquivo com id `expressiva`.
Então todo método do autor cai depois da Expressiva e fica coberto. O `?? -1`
falha fechada de verdade. A parte que ele resolveu, resolveu bem.

### A-2 · O buraco do degrau de bordo não é "pode contradizer": ele **vence sempre**.

`Sessao.escolher` (`Traco/App/Sessao.swift:198`):

```swift
if case .aviso = local { return local }        // só o AVISO local tem precedência
switch remoto {
case .none, .some(.silencio): return local
case .some(let v): return v                    // qualquer FORMA do modelo manda
}
```

A guarda produz `.silencio`, não `.aviso`. **`.silencio` tem precedência zero.**
Então, com conta Grok ou com Apple Intelligence ligada, basta o modelo devolver
uma forma para a nota protegida ser vestida — e no caminho automático `aplicar`
VESTE, não sugere. O modelo recebe `instrucoesDoCatalogo`, que descreve o Exame
da noite inteiro; "Me arrependi e chorei" é o caso que ele foi ensinado a
classificar.

**Tamanho do buraco, respondendo à pergunta:** não é uma quina, é a configuração
padrão de um iPhone moderno. A guarda protege exatamente uma configuração — sem
conta E sem Apple Intelligence, isto é, o caminho puramente regex. Não é
mensurável neste instrumento (o simulador não tem Apple Intelligence, D1), mas
não precisa de medição: são cinco linhas de precedência e elas são explícitas.

Ele declarou o buraco e apontou o conserto para a volta seguinte, o que é
correto — `Sessao.swift` está com a volta 12. O que peço é que a ADR **não diga
"pode contradizer"**: diga "contradiz sempre que o modelo responder uma forma".
A diferença importa para quem for decidir a fila.

### A-3 · `maestro/perfil-sabia.yaml:19` afirma uma frase que este branch apagou.

```yaml
- assertVisible: "O que o Traço aprendeu de você"
```

O título passou a ser "O que o Traço registrou — contagem, não conclusão". A
frase antiga sobrevive no app **só** como título do `confirmationDialog`
(`PerfilView.swift:108`), que não está visível até o diálogo abrir. O fluxo vai
vermelho na mescla. Nenhum dos dois commits toca `maestro/`, e nem a ADR nem o
EVOLUCAO citam o fluxo.

*Ressalva honesta:* eu **não** consegui rodar `perfil-sabia.yaml` até a linha 19
no meu simulador — ele falha antes, em `tapOn: aba-notas`, por estado velho de
outro fluxo (ver §7). O fato é estático e conclusivo: `git grep` da frase no
branch inteiro devolve `maestro/perfil-sabia.yaml:19` e `PerfilView.swift:108`,
e mais nada.

### A-4 · O número do contrato está errado: são **14** ramos, não 15 — e "12 do Exame" são 11.

Portei o expansor `Sondas` do branch `Vitorepf/volta-m3-colagem` literalmente e
rodei o `todoRamoDeRegexAlcancaOSeuMetodo` fora do app, sobre o `Metodos.json`
da M3 (28 métodos):

```
sondas totais: 287                         ← número dele, confirmado
sem a guarda:  0 falhas além das 4 conhecidas   ← o port reproduz o teste verde da M3
com a guarda:  14 falhas novas
```

Resposta à sua pergunta de ordem de mescla: **é isso e só isso** — um único
teste, `todoRamoDeRegexAlcancaOSeuMetodo` de `TracoTests/CatalogoTests.swift` no
branch da M3, e as entradas exatas para o `conhecidos` dele, citando a ADR 06h,
são estas catorze:

```swift
"colunaEsquerda|deixei passar|silencio",
"colunaEsquerda|engoli|silencio",
"colunaEsquerda|fiquei calado|silencio",
"exameDaNoite|fui duro demais|silencio",
"exameDaNoite|fui grosso|silencio",
"exameDaNoite|fui injusto|silencio",
"exameDaNoite|fui ríspido|silencio",
"exameDaNoite|me arrependi|silencio",
"exameDaNoite|não devia ter agido|silencio",
"exameDaNoite|não devia ter feito|silencio",
"exameDaNoite|não devia ter reagido|silencio",
"exameDaNoite|não devia ter tratado|silencio",
"exameDaNoite|perdi a cabeça|silencio",
"exameDaNoite|perdi a paciência|silencio",
```

(`hoje eu tratei` continua chegando ao Exame: a sonda é "tratei", não "tratei
mal". Talvez seja daí que veio o 12º.) SPEC e EVOLUCAO precisam do 14.

---

## 3. Achados MÉDIOS

### M-1 · O atalho do corpus devolve o CADERNO INTEIRO quando a forma escolhida sumiu da pasta.

```swift
// antes:  if let forma { fatias = fatias.filter { $0.gesto == forma.gesto } }
// agora:  if let g = forma?.gesto { fatias = fatias.filter { $0.gesto == g } }
```

`FormaEntity.gesto` devolve `nil` quando o método saiu da pasta entre montar o
atalho e rodá-lo — e aí **o filtro simplesmente desaparece**. O autor pediu uma
forma e recebe o corpus completo, pronto para colar na IA dele. O `AppEnum`
antigo nunca podia ser nil; a troca criou o caminho. O teste novo só verifica
que `gesto == nil`, não o que o intent faz com isso. A porta certa é falhar
(`throw`) ou devolver vazio — nunca alargar em silêncio. É a dimensão
Privacidade e autoria.

### M-2 · A A4 arrumou o título e deixou o diálogo destrutivo com a voz velha.

`PerfilView.swift:108`: `"Esquecer tudo o que o Traço aprendeu de você?"` — a
mesma frase que a ADR condena, no mesmo arquivo, cinquenta linhas acima do
conserto, e num diálogo que apaga dados. Ele achou sozinho o quarto caso
(`RotuloApontar.muleta`) que a auditoria não viu; este é o quinto.

### M-3 · O rótulo de VoiceOver contradiz a tela.

`PaginaView.swift:488`:
`.accessibilityHint("Muletas, frases feitas, passivas e adjetivos repetidos.")`
— é a dica do próprio botão que abre a tela agora intitulada **"Palavras de
apoio"**. Quem enxerga lê uma palavra, quem ouve lê a outra. Trocar a palavra na
tela e deixá-la no leitor de tela é acessibilidade de segunda classe.

### M-4 · Motor sem superfície: a proveniência do aviso não tem chamador.

`AnaliseLocal.proveniencia(doAviso:)` e `provenienciaDosAvisos` são referenciados
**só pelos testes** (`git grep`, nenhum uso em `Traco/`). Ele declara isso como
custo assumido e aponta `CartaoAnaliseView` (volta 12) como motivo, o que é
verdade e é honesto. Mas pela sua própria lei, função que o autor não vê não foi
entregue — e nesta volta o cartão **cresceu de 79 para 214 caracteres** citando
"um estudo de 2009" sem nenhum caminho para saber qual. O texto novo é melhor
que o velho de qualquer jeito; o registro é para a fila, não para desfazer.

### M-5 · O portão de skills não foi cumprido (`design-router`).

A A4 e o texto do aviso mexem em copy de `LenteView`, `PerfilView` e
`Versoes.swift`. Nem os dois commits, nem as três ADRs, nem qualquer relato no
branch citam as seis fases (Ancorar, Sistema, Construir, Mover, Julgar, Portão).
Pela ESTEIRA ("Skills obrigatórias por portão"), volta que toca copy sem as fases
citadas é CORRIGIR ANTES. Conferi contra a tela e o resultado visual está certo
(§4) — o que falta é o relato, não o desenho. `curva-zero` não se aplica: não há
jornada, folha, formulário nem primeiro uso aqui.

---

## 4. O que eu vi na tela (capturas minhas, teste 4)

| captura | o que prova |
|---|---|
| `a-rev-lente-large.png` | Lente em `large`: **PALAVRAS DE APOIO / contadas por palavra inteira**, com "acho que", "basicamente", "na verdade", "tipo", "um pouco". Nada corta. Fluxo verde com `assertVisible` nas duas frases |
| `a-rev-perfil-large.png` | Perfil em `large`: **"O que o Traço registrou — contagem, não conclusão"** em duas linhas, sobre "nenhum sinal ainda — eles nascem quando você solta uma forma…". Nada corta |
| `a-rev-perfil-ax5.png` | O mesmo título em **AX5** (`accessibility-extra-extra-extra-large`): quebra em quatro linhas, sem corte e sem truncamento |

**Lente em AX5 não foi possível:** `tapOn: {id: abrir-lente}` falha com "Element
not found" no tamanho AX — a mesma classe de defeito que ele declarou para o
botão Analisar ("defeito de view da volta 12"). Registro como limite conhecido
do instrumento, não como falha desta volta; mas são agora **dois** botões da
barra de baixo inalcançáveis em AX, e isso pertence à volta 12.

Observação de desenho, baixa: o subtítulo passou de "o que se diz para ganhar
tempo" (função, e a função estava errada) para "contadas por palavra inteira"
(método de contagem). É honesto e é uma perda de orientação — a seção deixa de
dizer por que aquelas palavras estão ali. Não peço conserto; peço que fique dito.

---

## 5. Ordem de mescla: o fato que você pediu

`git merge-tree --write-tree HEAD <branch>`:

| contra | conflito |
|---|---|
| `Vitorepf/volta-12-pagina` | **só** `SPEC.md` e `EVOLUCAO.md` |
| `Vitorepf/volta-m3-colagem` | **só** `SPEC.md` e `EVOLUCAO.md` |
| `Vitorepf/f3b-ditado` | `SPEC.md`, `EVOLUCAO.md` e `Traco.xcodeproj/project.pbxproj` |

**Nenhum conflito em Swift, com nenhum dos três.** A afirmação dele está certa —
mas duas premissas dele não estão, e você pediu o fato:

- **`PerfilView.swift` e `LenteView.swift` não são da volta 12.** A volta 12 não
  toca nenhum dos dois (ela mexe em `CartaoAnaliseView`, `PaginaView`,
  `Cartao`, `Camadas`, `Tema`, `CadernoView`…). Risco zero, não risco medido.
- **`Intencoes.swift` é da F3b, e a F3b realmente o toca** (+33 linhas) — e
  mesmo assim o git mescla limpo: a F3b adiciona intents novos, ele reescreve
  as linhas 154-161 e 249-283.

A única fricção mecânica real é `project.pbxproj` contra a F3b (os dois
adicionam arquivos às mesmas três listas) e o SPEC/EVOLUCAO contra todo mundo,
que é o de sempre. **A ordem é sua; o instrumento não impõe nenhuma.** O que
impõe ordem é o A-4: se a M3 entrar antes, `todoRamoDeRegexAlcancaOSeuMetodo`
fica vermelho até as 14 entradas subirem.

---

## 6. Instrumento

- Suíte integral, minha corrida, teste 4:
  `✔ Test run with 730 tests in 127 suites passed after 7.599 seconds` ·
  `** TEST SUCCEEDED **` · `grep -c "warning:"` = 0.
- **Build limpo do zero** (`xcodebuild clean build`, `-derivedDataPath` novo):
  `** BUILD SUCCEEDED **`, **149 tarefas de compilação Swift, 0 avisos**. A
  corrida de teste sozinha não provava isso (era incremental e não compilou
  nada); esta prova.
- Fluxos maestro: `perfil-sabia.yaml` (ver A-3) e dois fluxos meus de captura,
  todos com `maestro --device A1DF082C…` sob `com-trava.sh`, porque `varrer.sh`
  se recusa a rodar com sete simuladores ligados — e ele está certo em se
  recusar.
- **Achado de instrumento, para todo mundo:** `launchApp: clearState: true`
  **não esvazia o caderno**. O `default.store` do SwiftData mora no App Group
  (`…/Containers/Shared/AppGroup/<id>/Library/Application Support/default.store`),
  que sobrevive ao `clearState` **e** ao `xcrun simctl uninstall`. Meu
  simulador abria num Trabalho de outro fluxo depois de desinstalar e reinstalar
  o app. Todo fluxo que diz `clearState` está rodando sobre sobra. Apaguei o
  store à mão para conseguir as capturas.
- O teste 4 já estava ligado quando comecei; **não desliguei** o que não liguei.
  Devolvi o `content_size` para `large`.

---

## 7. Scorecard (ESTEIRA.md)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | **9** | fecha lacuna nomeada em três linhas do EVOLUCAO (Privacidade e autoria, Métodos com proveniência, Fora do app); as três voltas são a mesma matéria — o que o Traço afirma |
| Contrato | **6** | ADR/SPEC/EVOLUCAO dizem "15 ramos" e "12 do Exame" quando são 14 e 11 (A-4); o título "e de mais ninguém" e "deixa de ser matéria de exercício" não descrevem o que o código faz (A-1); "pode contradizer" subestima o buraco do bordo (A-2). O resto do contrato é exemplar — custo assumido, medido, e "Fora" explícito |
| Correção | **7** | 730/127 verdes conferidos por mim, testes novos para cada comportamento novo, régua das 22 refeita fora do app e reproduzida; mas `maestro/perfil-sabia.yaml` vai vermelho na mescla e não foi tocado (A-3), e o `conhecidos` da M3 está com o número errado |
| Jornada real | **8** | as quatro capturas dele têm conteúdo real e conferido; faltou qualquer captura da A4 (as duas telas que ele mudou) — eu fiz as três que faltavam |
| Design | **6** | resultado na tela está certo em `large` e AX5, mas nenhuma das seis fases do `design-router` é citada em commit, ADR ou relato, e a volta mexe em copy de duas views e de um rótulo (M-5). Portão da ESTEIRA não cumprido |
| Simplicidade | **9** | a guarda tira um cartão da tela em vez de somar um passo; nenhuma decisão nova para o autor; `curva-zero` não se aplica (não há jornada, folha nem primeiro uso) |
| Movimento | **9** | nenhuma animação tocada; nada a julgar |
| Componentes | **9** | `FormaEntity`/`FormaQuery` num arquivo só, sem duplicata; `Metodo.Proveniencia` reusada em vez de um tipo novo — a escolha certa |
| Acessibilidade | **7** | AX5 do Perfil conferido por mim, sem corte (`a-rev-perfil-ax5.png`); mas a dica de VoiceOver do botão da Lente ainda diz "Muletas" (M-3), e a Lente é inalcançável por AX (limite da volta 12) |
| Performance | **9** | roteamento é regex sobre o mesmo laço, com uma chamada a mais por texto; o custo do esquema maior foi MEDIDO (+3,3%) em vez de suposto |
| Privacidade e autoria | **7** | a guarda é a própria dimensão e ela funciona onde alcança; mas o atalho do corpus alarga em silêncio para o caderno inteiro quando a forma some (M-1), e a proteção não sobrevive ao veredito do modelo (A-2) |
| Estado honesto | **8** | é o coração da volta e ele acertou o essencial — o aviso diz o que a fonte mediu, o Perfil diz contagem e não conclusão, o método ausente vira `nil` e não gesto de mentira; desconta o diálogo que ficou com a voz velha (M-2) e o filtro que some sem dizer (M-1) |
| Complexidade | **9** | +505 −88, e a maior parte é teste e ADR; DUAS listas fechadas apagadas, uma delas morta — simplificação conta como entrega |
| Fora do app | **8** | `FormaEntity` do catálogo é o conserto certo e está travado por teste; o D1 (sem team-identifier no simulador) é limite de instrumento declarado, não falha; desconta M-1 |
| Relato | **9** | as três ADRs são curtas, com distância, decisão, custo medido e "Fora"; os commits explicam a causa e não só a mudança |

**Abaixo de 9: Contrato (6), Correção (7), Design (6), Acessibilidade (7),
Privacidade e autoria (7), Jornada real (8), Estado honesto (8), Fora do app (8).**

---

## 8. As duas perguntas que você fez de propósito

**"A guarda em código e não no `Metodos.json` — julgue o argumento, não só o
resultado."** O argumento está certo, e por uma razão mais forte do que a que
ele deu. Ele diz "a pasta do autor reescreve o catálogo". Reescreve mesmo:
`Catalogo.recarregar` lê `Documents/Traço/metodos/*.json` sem pedir licença, e
um método do autor pode trazer qualquer regex. Se a fronteira morasse no
`Metodos.json`, o autor poderia — sem querer, escrevendo um método sobre
conversas difíceis — desarmar a proteção da própria escrita. Uma fronteira que o
usuário pode apagar por acidente não é fronteira. **E há a razão que ele mediu e
não sublinhou:** alargar a Expressiva por dado tornaria os dois métodos novos
inalcançáveis — a Expressiva vem antes deles e engoliria tudo. Ou seja, os dados
não conseguem expressar "isto é da Expressiva **e** aquilo continua do Exame";
só código consegue. O argumento se sustenta. A crítica que faço não é ao lugar
da guarda, é ao alcance dela (A-1).

**"Perder uma pergunta de Hamming para proteger um desabafo é o lado certo do
erro?"** Sim, e sem hesitação. As duas frases — "tenho medo de estar trabalhando
na coisa errada", "sinto que o esforço não está indo pro lugar certo" — têm
"medo" e "sinto" porque **são** as duas coisas ao mesmo tempo: uma dúvida de
carreira dita como angústia. Errando para o silêncio, o Traço devolve a nota e o
autor abre a forma que quiser com um toque: custo, um toque. Errando para a
forma, ele carimba quatro campos de exercício em cima de "tenho medo", e o custo
é o autor sentir que o caderno não entendeu o que ele acabou de dizer — a
sensação que faz alguém fechar o app e não voltar. Silêncio é resposta válida
(§19.4) e é a mais barata de desfazer. A assimetria é grande e é a favor dele.
Registro só uma consequência que a ADR não diz: **8 dos 22 desabafos protegidos
não vão para a Expressiva, vão para o SILÊNCIO** (os longos e factuais, que não
têm nenhuma das dez palavras dela). O título "a escrita pessoal é da Expressiva"
descreve a intenção; o comportamento é "a escrita pessoal fica do autor". O
segundo é melhor. É só dizê-lo assim.
