# CONVERSA-HERMES: o portão dos sete (ADR 2026-09-10l)

Cadeira do SISTEMA DA IA, 10/09, 20h15 a 21h. Branch `Vitorepf/sistema-ia`. Tudo medido no
**teste 4 (`A1DF082C`)** em `large` e `light`. O aparelho da conta não foi tocado.
Capturas e vídeo estão em `ferramentas/orca/conversa-hermes/`.

**Vídeo, 15,3 s, tela inteira com o pé:** `conversa-15s-large.mp4`. Mostra a resposta longa
com VOCÊ / fio / SÁBIA, a cápsula andando de 0:01 a 0:09 com a marca cintilando, a rolagem
até as fontes, o retorno sem caixa e a pergunta nova colada à cápsula, o toque em parar (a
falha vira a mensagem da SÁBIA e o botão some), e a próxima pergunta escrita (o botão vira
enviar). O vídeo saiu de uma gravação com `recordVideo` (26,0 s de parede, 26,2 s de vídeo,
portanto sem esticar), cortada a partir do quadro em que a marca verde aparece.

## As sete respostas

**1. Matar a folha branca flutuante da resposta: FEITO.**
`lado-a-lado-6-conversa.png` (Hermes à esquerda, Traço à direita). Cada mensagem tem uma
linha de autor (● VOCÊ em âmbar, ▬ SÁBIA em verde, versalete espaçado) e, embaixo, o texto
em largura inteira. Entre as mensagens há um fio de 0,5 pt, recuado pela margem e alinhado
com o texto. Não há caixa, corte nem "CONTINUA", e nada flutua por cima de nada. O último
cartão da conversa, o `.campo` do "serviu | não serviu", saiu
(`traco-06-retorno-sem-caixa-large.png`). A falha também é uma mensagem da SÁBIA, como o
`HTTP 401` sob `ARCHITECT` no Hermes (`lado-a-lado-falha-e-mensagem-da-sabia.png`). O vazio
é só a linha "?" no pé, sem cerimônia (`traco-05-vazio-large.png`).
*Diferença deliberada:* o fundo continua o papel do Traço; o preto do Hermes é o §1 e não
estava pedido.

**2. Trocar a espera pela cápsula com tempo, com o botão do campo virando parar: FEITO.**
`lado-a-lado-8-9-capsula-e-parar.png`. A cápsula é estreita (34 pt) e fica colada 8 pt acima
do campo: a marca da sábia cintila no segundo do relógio, depois vem "a sábia pensa…" e, à
direita, o tempo em `m:ss`. O botão do campo é um quadrado vermelho de parar enquanto ela
pensa e uma seta de enviar quando está livre e há texto (`traco-04-enviar-large.png`), no
mesmo lugar e com a mesma forma. Enquanto ela pensa, o texto do campo diz "escreva a próxima".
*Diferenças deliberadas:*
- O campo é uma linha, não a caixa escura do Hermes (lei da esteira: a hairline e o caret
  âmbar já dizem "escreva aqui").
- O botão tem a forma do enviar do Calendário, não um círculo.
- **Não há voz.** Clonou-se o botão que muda de estado, não o microfone.
- O Traço não enfileira: o Return não envia enquanto ela pensa. Por isso o texto é "escreva
  a próxima" e não "Queue a message…".

**3. Separar buscar de perguntar:** é de outra cadeira.

**4. Barra de baixo como pílula flutuante:** é de outra cadeira.

**5. Caixa alta só em cabeçalho de seção: FEITO NA CONVERSA.** Na conversa, a única caixa
alta são os nomes VOCÊ e SÁBIA, que dizem quem fala, como `USER` e `ARCHITECT`. "A SÁBIA,
SOBRE:" não existe, e o `EsperaComEstadoUITests` afirma isso. *Fora do escopo e ainda lá:*
na Lente, os parágrafos do Contrapor ("O OUTRO LADO", "FORA DA LISTA", "EM OUTRO CAMPO") e
os títulos de seção continuam em caixa alta. Não mexi.

**6. Três níveis de tipo e divisor recuado: FEITO NA CONVERSA.**
- Nível 1 é a linha de autor (`label`, na cor de quem é).
- Nível 2 é o texto (`corpo`, tinta).
- Nível 3 são os metadados ("leu 4 notas suas", o retorno, "Perguntar de novo"), em `meta`.

O fio fica na largura do texto. As linhas da LISTA de notas não foram tocadas.

**7. Cor com regra escrita: FEITO.** A regra está no `Tema` (comentário de `Tema.sabia`) e
na ADR 10j, item 2:
- O âmbar é VOCÊ, o acento do app, como o azul do `USER`.
- O verde `#1F6B5A` (5,8:1) é a SÁBIA, só na marca e no nome.
- O vermelho só aparece em parar, enquanto há o que parar.

*O ponto que um G4 pode pegar:* "Perguntar de novo" e os títulos das fontes continuam em
âmbar-tinta como AÇÃO (ADR 02h: o âmbar é a assinatura de ação), e o mesmo âmbar agora
também é a identidade de quem pergunta. Defendo que a ação é de quem pergunta, mas é uma
leitura, não uma prova.

## O que não mudou, e foi conferido

- O `switch` de **três** saídas da Lente, com `Sabia.nadaPassouNaGuarda`, está intacto em
  `LenteView.swift` (instigar e contrapor). Não toquei o arquivo.
- A `Espera` da Lente e da Página continua a mesma. A cápsula é só da conversa.
- Um Fechar, na topbar.

## Suíte

Suíte integral no teste 4, com
`com-trava.sh xcodebuild test -scheme Traco -destination id=A1DF082C… -parallel-testing-enabled NO`,
e os quatro testes de UI da conversa (`EsperaComEstadoUITests`, `PerguntaSobreviveUITests`)
pelo esquema `TracoUITests`, às 21h02, sobre o código final:
`✔ Test run with 1077 tests in 168 suites passed after 152.389 seconds.` e
`** TEST SUCCEEDED **` nos quatro testes de UI.
