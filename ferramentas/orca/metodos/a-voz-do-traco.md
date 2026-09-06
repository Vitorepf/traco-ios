# A voz do Traço — a régua da voz

Trilha Métodos · escrita na M12, de duas varreduras · 06/09/2026.

Para quem for escrever a próxima frase de tela do Traço — worker ou dono.

Esta régua não foi inventada: ela foi **lida** nas centenas de frases que o app
já diz. A maior parte delas já está certa, e os padrões abaixo são de vocês, não
meus. O que eu fiz foi varrer os 149 arquivos duas vezes, conferir no código as
promessas verificáveis, e escrever o que separa as frases que sobreviveram das
sete que não sobreviveram.

Ela é irmã da [régua da proveniência](regua-da-proveniencia.md): aquela vale para
o que o catálogo diz sobre um método; esta, para o que o app diz sobre qualquer
coisa.

---

## A regra que resume todas

> **O app diz o que faz, não o que é.**

"Guarda e abre uma página nova" sobrevive a qualquer auditoria. "Ele aprende com
você" não sobrevive a abrir o arquivo. As duas descrevem a mesma família de
coisas; a primeira é uma operação, a segunda é uma qualidade.

---

## Os três sujeitos, e o que cada um exige

### 1. Quando o app fala DE SI

**É aqui que ele erra.** Foi o resultado das duas varreduras: nas centenas de
frases sobre o autor ou sobre o mundo, o padrão é rigoroso; os sete achados estão
quase todos em frases sobre a própria capacidade.

**Pode dizer:** o que grava, o que lê, o que apaga, o que envia, o que não envia,
quando acontece, e como se desfaz.

**Não pode dizer:** que aprende, entende, percebe, cuida, se adapta, personaliza,
melhora ou ajuda. São qualidades, e nenhuma delas tem função implementada com
esse nome.

**Exige, sem exceção:** **abrir a função antes de escrever a frase.** Se a frase
tem o app como sujeito de um verbo, o verbo tem um arquivo. Os dois achados que
mais valeram das duas rodadas nasceram assim — "ele aprende com você" virou achado
quando eu abri `Degraus.swift` e vi um contador com memória de duas respostas; "o
app lê ao abrir" virou achado quando eu vi `recolherEntrada` sendo chamada em
três lugares, um deles a cada volta à cena.

**E a condição faz parte da promessa.** Se o app faz X quando Y, a frase diz o Y.
O widget promete "a que horas o Traço te avisa" e o aviso depende de duas coisas
que o próprio app sabe dizer quando falham.

**Promessa a menos também é erro.** Uma frase que promete menos do que o app faz
cobra do autor um passo que o app não pede. É mais rara e mais difícil de achar,
porque ninguém reclama dela.

### 2. Quando o app fala DO AUTOR

**Pode dizer** o que ele fez, contado: *"Você soltou três vezes seguidas: X."*
Isso é observação, e é verificável pelo próprio autor.

**Não pode dizer** o que ele é, o que costuma fazer, o que sente ou o que sabe.
Contagem não vira disposição, e três notas não fazem um veterano. O
`VISAO-PRODUTO` já resolve isto: *"O modelo deve distinguir observação, relato e
hipótese"* — e a frase de tela mostra observação.

**A fronteira, palavra por palavra:** forma, informação e pergunta — **nunca a
resposta do autor**. Esta parte está defendida por contrato em quatro lugares do
código, e a auditoria da M11 mostrou onde. Quem escrever frase nova não precisa
inventar a defesa: precisa não furá-la.

### 3. Quando o app fala DO MUNDO

**Exige fonte, e a fonte aparece na tela.** É a régua da proveniência aplicada à
voz: se a frase afirma como as pessoas são, o que funciona ou o que a ciência
diz, ou ela cita, ou ela não é dita. Um estudo não vira "comprovado"; vira "um
estudo de 2009 mediu isto, com este resultado".

**Nunca "todo mundo", "a maioria", "as pessoas".** Foram seis frases assim no
catálogo (M8) e nenhuma tinha fonte. Onde a intenção era instruir, o conserto foi
sempre o mesmo: **trocar a afirmação sobre as pessoas pela cobrança do método**.

**De quem é o limite, se diz.** *"O iPhone guarda 64 avisos"* — o teto é do iOS e
a frase diz isso. Não empurre para o autor um limite que não é dele, nem tome
para o app um limite que é do sistema.

---

## Os padrões que já existem, e são o modelo

Estes não são invenção da régua. Estão no app, escritos antes dela.

**O parágrafo dos degraus, no Perfil** — fato, regra e como desfazer, em três
frases:

> "Você soltou três vezes seguidas: X. Por isso o Traço passou a sugerir em vez
> de vestir. Abrir uma por vontade própria devolve o vestir."

**Os Padrões, devolvendo a conclusão:**

> "Dois períodos, lado a lado. Sem nota, sem seta: quem lê é você."

**O Trabalho, negando o que não faz** — três frases que dizem exatamente o que a
auditoria procura:

> "Não é o app avaliando você, nem prova de que você aprendeu."
> "não avalia você, não corrige o texto e não prova aprendizagem."
> "Delegar não exige aprender a executar tudo."

**A queima, descrevendo o próprio estrago com precisão:**

> "essa você queimou. ficou a data e o que você entendeu."

**As notificações, que não dizem nada:** `body = ""` em todas. O título é uma
palavra fixa ou o texto do próprio autor. É a fronteira aplicada onde ninguém
olha.

**E o aviso que é a fronteira em oito palavras:**

> "A frase aqui é sua. O Traço não escreve."

---

## Tom: o que as duas varreduras mostraram

- **O app não tem EU.** Ele não é interlocutor. A regra está escrita no código —
  *"'Li' dava um EU à IA — e o app não é interlocutor"* — e foi furada uma vez
  ("ainda não perguntei… eu peço").
- **O autor é "você", nunca "te".** Uma frase do widget escapou.
- **Minúscula no que é estado, maiúscula no que é ação.** "nada aqui ainda." ·
  "Abrir os campos". O app sussurra o estado e fala o comando.
- **Curto ganha.** As melhores frases do app têm menos de dez palavras.
- **Sem simpatia.** Nenhuma frase do Traço elogia, encoraja ou celebra — e é uma
  ausência deliberada, não um esquecimento. Não a quebre.

---

## Antes de escrever a frase, cinco perguntas

1. **O app é sujeito de um verbo?** Abra a função. Se você não achar a função, a
   frase está descrevendo uma qualidade — reescreva como operação.
2. **Existe condição em que isso não acontece?** Ela faz parte da frase.
3. **A frase diz algo sobre o autor?** Só o que ele fez, contado. Nunca o que ele
   é, sente ou costuma.
4. **A frase diz algo sobre o mundo?** Cite, ou corte.
5. **A frase promete MENOS do que o app faz?** Também é erro, e ninguém vai
   reclamar dela por você.

## E uma última, para quem revisa

**Leia a frase como se fosse cobrar dela.** A pergunta é sempre a mesma: *se eu
abrir o arquivo, acho isto lá dentro?* É a mesma pergunta da régua da
proveniência, virada para o próprio app — e as duas varreduras mostraram que ela
é a única que separa a frase que sobrevive da que não sobrevive.
