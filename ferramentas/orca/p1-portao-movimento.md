# Volta P1 — o portão do movimento e as três dívidas curtas de 07/09

Branch `Vitorepf/volta-p1-portao-movimento`, worktree próprio. Implementador
(Claude Opus 5). Simulador **iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`**,
08/09/2026. Nada tocado no checkout principal; nada mesclado em `main`.
ADR desta volta: **2026-09-08a** em `SPEC.md`.

## G0 — a linha da volta, como ela ficou

**Ciclo:** melhorar para multiplicar mais depois — eixo 4, diminuir
complexidade. Esta volta barateia todas as seguintes.
**Intenção:** o autor nunca vê duas animações diferentes para a mesma coisa, e a
ficha de um método não lhe promete matéria que a guarda recusa levar.
**Obstáculo:** as dívidas 7, 5 e 6 da seção "A limpeza de 07/09" do `RUMO.md`.
**Evidência:** abaixo, com as linhas coladas.

`design-router` não foi carregado: nenhuma view, nenhum token, nenhuma copy de
tela nova. As duas strings de produto tocadas (a `aplicabilidade` do
`exameDaNoite` e o cabeçalho do fluxo maestro) são correções de VERDADE, não
direção visual — o brief do implementador dispensa o roteador em motor puro, e é
o caso. `gate-loop` é do orquestrador, no G0. `curva-zero` não se aplica: zero
jornada tocada.

---

## 1. O portão do movimento — `TracoTests/PortaoDoMovimentoTests.swift`

**O que ele varre.** Todo `.swift` de `Traco/` e `TracoWidget/` (126 arquivos),
menos `Traco/Tema.swift`, que é o isento porque é onde a lei mora. Conta por
arquivo as ocorrências de: `withAnimation(`, curva nomeada do SwiftUI
(`.easeInOut(`, `.easeIn(`, `.easeOut(`, `.linear(`, `.spring(`,
`.interpolatingSpring(`, `.interactiveSpring(`, `.timingCurve(`, `.bouncy`,
`.smooth`, `.snappy`), `Animation.`, `.repeatForever`, `duration: <número>` e
`.delay(<número>)`.

**Como não dá falso positivo em comentário ou string.** Antes de casar a regex,
cada linha passa por `semComentarioNemTexto`, que apaga o miolo de `"…"` e tudo
depois de `//` fora de string. Isto não é hipotético: `PerfilView.swift:410`
escreve `` `withAnimation` do PerfilView não atravessa `` num comentário — está a
um parêntese de virar vermelho. **Medido, honestamente: hoje a filtragem não
muda nenhuma contagem** (76 com e sem ela), porque a menção do PerfilView não
tem `(` colado. Ela está lá para a próxima linha de prosa, não para uma de hoje.
Teto conhecido e escrito no código: string de várias linhas (`"""`) fecha o
resto da linha de abertura, o que erra para o lado de NÃO acusar; nenhuma existe
hoje nos fontes varridos.

**A lista congelada.** Um caminho por linha com o número de hoje, e um
comentário que a nomeia dívida e diz como zerá-la (a volta por tela troca a
curva literal por movimento nomeado em `Tema`, baixa o número no mesmo commit,
apaga a linha quando chega a zero). **19 arquivos, 76 ocorrências.**
`TracoWidget/` não aparece: tem zero, e a lista existe para que continue assim.

| arquivo | hoje | arquivo | hoje |
|---|---|---|---|
| Calendario/CalendarioEscalas.swift | 10 | Notas/NotasView.swift | 5 |
| Recordar/RecordarView.swift | 9 | Caderno/CadernoView.swift | 4 |
| Pagina/PaginaView.swift | 7 | Confirmacao/FechoExpressivaView.swift | 4 |
| App/RaizView.swift | 6 | App/Camadas.swift | 3 |
| Calendario/CalendarioView.swift | 6 | Pagina/CamposFormaView.swift | 3 |
| Trabalho/IntercambioTrabalhoView.swift | 5 | Caderno/EditorBlocoView.swift, Ditado/FolhaDeConfirmacao.swift, Notas/RedeView.swift, Padroes/PadroesView.swift, Pagina/LenteView.swift, Trabalho/TrabalhoView.swift | 2 cada |
| Ditado/DitadoProprioView.swift, Perfil/PerfilView.swift | 1 cada | | |

**Não refatorei nenhuma das 76.** É das voltas por tela, e a maioria mora em
views de outros donos nesta rodada.

**Por que contagem por arquivo, e não só a lista de caminhos.** Com só o
caminho, acrescentar um quinto `withAnimation` a `RecordarView` passaria verde —
e o defeito da volta 12 nasceu exatamente assim, dentro de arquivos que já
animavam. A contagem custa o mesmo (um `: 9` na linha) e pega o caso.

### As duas linhas que o critério pede

**Verde no repositório de hoje:**

```
✔ Test nenhumMovimentoNovoForaDeTema() passed after 0.618 seconds.
✔ Test run with 1 test in 1 suite passed after 0.620 seconds.
** TEST SUCCEEDED **
```

**Vermelho com violação plantada.** Plantei `static let plantadaP1: Animation =
.easeInOut(duration: 0.3)` em DOIS lugares de propósito: um arquivo FORA da
lista (`Traco/App/BarraNavegacao.swift`) e um DENTRO dela
(`Traco/Padroes/PadroesView.swift`), para provar os dois modos de falha:

```
✘ Test nenhumMovimentoNovoForaDeTema() recorded an issue at PortaoDoMovimentoTests.swift:135:9:
  Expectation failed: (divergencias → ["Traco/App/BarraNavegacao.swift: 2 hoje, 0 congelado  ← SUBIU",
                                       "Traco/Padroes/PadroesView.swift: 4 hoje, 2 congelado  ← SUBIU"]).isEmpty → false
✘ Test run with 1 test in 1 suite failed after 0.635 seconds with 1 issue.
** TEST FAILED **
```

As duas plantas foram removidas em seguida (`git status` limpo nos dois arquivos,
conferido). A mensagem de falha diz o que fazer nos dois sentidos — SUBIU (cite
`Tema`) e desceu (baixe o número, apague a linha) — e imprime as linhas que a
varredura viu.

**Guarda contra o falso verde:** o teste exige `fontes.count > 100` e que
`Traco/Tema.swift` exista no caminho isento. Caminho errado deixaria a varredura
vazia e VERDE, que é o modo de falha silenciosa deste tipo de teste.

**Relação com o que já existia.** `TemaTests.nenhumLiteralDeDuracaoOuMolaNosArquivosDaV10A`
cobre número cru em 16 arquivos escolhidos a dedo. O portão novo cobre os 126,
inclui `withAnimation` e curva nomeada, e congela a dívida em vez de exigir zero.
Não os fundi: um é lista fechada de arquivos já migrados, o outro é varredura
aberta com dívida datada. Fundi-los perderia a asserção de "estes 16 estão
limpos".

---

## 2. A-6 — as quatro linhas de documento, com o número na mão

Todas as quatro medidas contra a implementação real, num teste descartável
(`MedidaP1Tests`, criado, rodado e apagado), não estimadas.

**(a) A causa contada na ADR era falsa.** A 06i-E dizia: "as 57 protegidas
carregavam um rabo de ~140 caracteres: quase toda sonda ficava ACIMA do teto".
**Medido: 46 das 57 já estavam ABAIXO do teto.** O rabo de 140 é da régua de
ALCANCE (`todoRamoDeRegexAlcancaOSeuMetodo`), não das protegidas. A causa
verdadeira é **contaminação**: das 57, 17 tocam a família 4 e 11 dessas são
curtas, mas a única curta que carregava o token do defeito —
`«Não devia ter feito isso, senti muito.»` (38 caracteres, famílias `1a` e `4`)
— é presa pela 1a por causa de `senti`, antes de a 4 ou a 5 opinarem. A ADR
passa a dizer isso, com a frase e o número.

**(b) A régua não cobrava a exclusividade que a ADR lhe atribuía.**
`cadaFamiliaTemUmaSondaAbaixoDoTeto` agora cobra: o conjunto de famílias que
reconhecem a sonda tem de ser exatamente `{família declarada} ∪ alem`. A tupla
de `curtasPorFamilia` ganhou um quarto campo, `alem`, vazio em seis das sete; a
sonda da família 5 declara `["1b"]` — a companhia que a ADR 06i exige, agora à
vista da régua e não só do comentário. Medido antes de escrever: seis das sete
eram exclusivas por sorte do texto, a sétima aciona 1b+5.

**(c) A porta morta: APAGADA, não descrita.** `olhando o dia de hoje` sai do
roteamento do `exameDaNoite` em `Metodos.json`. **Por quê:** `Meu dia` tem
`\bo dia de hoje\b` e está no índice 13 do catálogo contra o 27 do Exame — a
frase nunca chegava ao Exame, em nenhum tamanho (medido: `longa=dia curta=dia`).
Descrevê-la a manteria como promessa que a ficha não cumpre; apagá-la é
comportamento-neutro e tirou um desvio congelado da régua de alcance, que passou
de **18 para 17** conhecidos. Atualizei junto o comentário do
`todoRamoDeRegexAlcancaOSeuMetodo` (DEZOITO→DEZESSETE, QUATRO→TRÊS) e a cópia
congelada em `EscritaPessoalTests.novos`.

**(d) Os dois números, medidos com controle negativo.** Refiz o experimento da
A-6 nesta árvore: `não devia ter` de volta à família 5, nada mais trocado, medir,
restaurar (`AnaliseLocal.swift` conferido limpo depois).

| medida | com o token na família 5 (antes) | na família 4 (hoje) |
|---|---|---|
| notas de trabalho do revisor com o token | `classeDeReferencia`, `primeirosPrincipios`, `cincoPorques`, `argumento`, `vistoNaoVisto`, `destilar` | **6 de 6 em silêncio** |
| ramos do Exame que CHEGAM ao método, frase curta | 9 de 17 | **5 de 17** |
| ramos que MUDAM de lado com o teto | 4 | **0** |

E o rótulo: pela mesma expansão que a ADR usa, o Exame tinha **17** ramos e 11 é
o subconjunto de confissão — "os 11 ramos do Exame" estava errado. Depois de (c)
são 16: 11 calados pela guarda, 5 vivos (`exame da noite`,
`passei o dia em revista`, `hoje eu fiz|reagi|tratei`).

**Um número velho a mais, de lambuja.** O comentário de
`asDuasReguasValemAoMesmoTempo` ainda dizia "a guarda que protege as 57 não pode
calar as 47". Medido hoje: **64 protegidas, 13 com gancho, 6 legítimas, 72 de
trabalho** (as 58 do relatório do revisor eram antes da colagem da M3, que
acrescentou 14 frases de trabalho pelas sete portas novas). Corrigido com a data
ao lado, porque número em comentário envelhece.

---

## 3. M3 — a ficha que mentia e os dois comentários mortos

**A `aplicabilidade` do `exameDaNoite`.** O campo que o app rotula **SERVE PARA**
(`Metodo.swift:88`, desenhado na Lente e no Perfil) dizia: *"Serve para o fim de
um dia em que o autor fez algo que não quer repetir."* É exatamente a matéria que
a guarda da 06h se recusa a levar ao método. Passa a dizer o que a guarda de
fato leva:

> Serve para o fim de um dia em que o autor fez algo que não quer repetir — e
> você o abre pelo nome, ou escrevendo "passei o dia em revista". O Traço não
> oferece esta forma sobre a sua escrita pessoal: quando o texto é confissão, a
> nota fica sua e não vira exercício (ADR 2026-09-06h). Não serve para julgar os
> outros, nem para ruminar — se o texto vira desabafo, a forma é a Expressiva.

Nomeia as duas portas vivas que sobraram, para o autor saber COMO chegar, e
declara a recusa em vez de a esconder. Nenhum código de view mudou.

**Comentário morto 1 — `TracoTests/EscritaPessoalTests.swift`, cabeçalho do
`comOsNovos`.** Dizia "os dois entram pela pasta do autor — o `Metodos.json` é da
volta M3 e não se toca". Morreu na colagem de 07/09: o bundle passou a ter os 28
e `Catalogo.recarregar` recusa id repetido, então `comOsNovos` é um no-op. O
cabeçalho novo diz isso e diz onde as réguas leem os métodos hoje.

**A armadilha que o revisor chamou de latente, fechada.** Ele avisou que as regex
congeladas em `novos` podiam divergir do bundle sem nada acusar. Acrescentei
`osSeteCongeladosBatemComOBundle`: compara ramo a ramo. **Ela acusou esta própria
volta** na primeira corrida, quando apaguei o ramo morto do `Metodos.json` e
esqueci a cópia — é a prova de que precisava existir. Não deletei `comOsNovos`
(9 chamadores) nem reescrevi `osDoisMetodosEntramMesmoPelaPastaDoAutor`: isso é
outra volta, e o revisor pediu duas linhas dizendo, não o conserto.

**Comentário morto 2 — `maestro/metodos-m3-tom.yaml`, cabeçalho.** Fora do meu
escopo declarado; **perguntei por `ask` antes** e o orquestrador estendeu a
fronteira só ao cabeçalho, com duas condições que cumpri: o texto novo diz o que
é verdade hoje (o conserto está feito, duas vezes, e onde: `eEscritaPessoal` pela
06h, o token da família pela 06i-E, prova em `EscritaPessoalTests`), e o arquivo
está citado nos modificados. **Nenhuma linha de fluxo mudou; o fluxo NÃO foi
rodado** — com três simuladores ligados o maestro lê a hierarquia do vizinho.

---

## 4. Sem regressão de sentido — as quatro réguas

Nenhuma mudou de lado.

| régua | frases | resultado |
|---|---|---|
| protegidas | 64 | silêncio ou Expressiva |
| com gancho | 13 | silêncio ou Expressiva |
| legítimas | 6 | no método delas |
| de trabalho | 72 | na porta delas |

```
✔ Test run with 31 tests in 3 suites passed after 0.857 seconds.
** TEST SUCCEEDED **
```
(`EscritaPessoalTests` + `PortaoDoMovimentoTests` + `TemaTests`, 0 `warning:` no log.)

## 5. Suíte integral e build

```
✔ Test run with 889 tests in 144 suites passed after 11.005 seconds.
** TEST SUCCEEDED **
```
```
** BUILD SUCCEEDED **
```
Os dois no **iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`**,
sob `ferramentas/orca/com-trava.sh`, **0 `warning:`** no log inteiro dos dois.

## 6. Complexidade

```
7 files changed, 211 insertions(+), 49 deletions(-)     (com o project.pbxproj)
6 files changed, 203 insertions(+), 49 deletions(-)     (sem ele)
```

**Código de produção: 2 linhas trocadas, líquido ZERO** — só
`Traco/Modelo/Metodos.json` (`+2 −2`: o ramo morto e a `aplicabilidade`). Nenhum
arquivo de produção novo, nenhuma dependência. O crescimento é teste (+62/−22 em
`EscritaPessoalTests`, +11/−7 em `CatalogoTests`, +141 no arquivo novo do
portão) e documento. A regra da volta era exatamente essa.

## 7. Instrumento — o que eu garanti

- Todo `xcodebuild` por `ferramentas/orca/com-trava.sh`.
- **UDID explícito em toda invocação**, nunca `booted`: há três simuladores
  ligados.
- O **iPhone 17 Pro (teste 2) `B91C8DEF`** não foi tocado, nem para build, nem
  para instalar, nem para desligar — é onde a conta Grok está conectada.
- Nenhum simulador ligado ou desligado por mim.
- **Sem maestro.** Nenhuma nota desta volta se apoia nele.
- **Sem captura de tela.** Zero código de view nesta volta; a única mudança que
  o autor vê é uma string de `Metodos.json` num campo que uma view existente já
  desenha. É honesto dizer: **a ficha nova não foi fotografada**. Fotografá-la
  pede abrir a proveniência do Exame no Perfil — sem valor de prova acima do que
  o próprio JSON e o `Metodo.linhas` já dizem, mas fica registrado como limite,
  não descontado como se fosse feito.
- Nada editado, commitado ou mesclado no checkout principal.

## 8. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| **Visão** | 9 | entra no ciclo "melhorar para multiplicar" pelo eixo 4; fecha a lacuna do design-router no EVOLUCAO ("as telas fora das três migradas ainda desenham por conta própria") trocando um relatório por um portão executável |
| **Contrato** | 9 | ADR 08a curta; a 06i-E corrigida nos quatro pontos onde ela mora; EVOLUCAO coerente com o código; a ficha do `exameDaNoite` deixa de prometer o que a guarda recusa |
| **Correção** | 9 | 889/144 verde, 0 aviso; o portão provado nos DOIS sentidos, com violação plantada fora e dentro da lista; a régua nova de exclusividade e a de cópia-vs-bundle, esta acusando a própria volta |
| **Jornada real** | n/a | zero código de view; nenhuma tela alterada. A única mudança visível é uma string num campo já desenhado, e ela não foi fotografada (§7) |
| **Design / Movimento / Componentes / Acessibilidade / Fora do app** | n/a | nada tocado. O portão é sobre movimento, mas não muda movimento nenhum: congela |
| **Simplicidade** | 9 | nenhuma tela, passo ou decisão a mais; a ficha do método passa a dizer COMO se chega ao Exame, o que o revisor da M3 pediu como poder avançado encontrável |
| **Performance** | n/a | nada no caminho quente; a varredura é de teste |
| **Privacidade e autoria** | 9 | as quatro réguas verdes, nenhuma mudou de lado; a guarda continua em código, não no JSON; o ramo apagado é morto e provado morto |
| **Estado honesto** | 9 | a causa falsa da ADR corrigida com a medida; os números medidos com controle negativo, não herdados; o teto da varredura e o limite da captura escritos aqui em vez de omitidos |
| **Complexidade** | 10 | produção com líquido ZERO (2 linhas trocadas num JSON); o crescimento é teste e documento; a volta apaga um ramo, um desvio congelado e dois comentários mortos |
| **Relato** | 9 | seis linhas de fecho abaixo, com as linhas de resultado coladas e o que NÃO foi feito dito por nome |

## Fecho — seis linhas

1. O movimento ganhou portão: `PortaoDoMovimentoTests` varre 126 fontes e
   congela a dívida em 19 arquivos e 76 ocorrências; quem escrever a próxima
   curva fora de `Tema` fica vermelho.
2. Provado nos dois sentidos — verde hoje, vermelho com uma violação plantada
   fora da lista e outra dentro dela, as duas removidas depois.
3. A ADR 06i-E parou de contar uma causa falsa: eram 46 das 57 já curtas, e o
   buraco era contaminação, não rabo — com a régua passando a cobrar a
   exclusividade que a ADR lhe atribuía.
4. A porta morta `olhando o dia de hoje` foi apagada, não descrita: nunca
   roteava, e sair tirou um desvio congelado da régua de alcance (18 → 17).
5. A ficha do Exame da noite parou de prometer ao autor a matéria que a guarda
   recusa levar, e diz agora as duas portas vivas que sobraram.
6. 889 testes em 144 suítes verdes e build sem aviso no `A1DF082C`, com produção
   em líquido ZERO — 2 linhas trocadas num JSON, o resto é teste e documento.
