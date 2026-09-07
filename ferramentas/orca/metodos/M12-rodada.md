# Trilha Métodos — volta M12: segunda varredura da voz

06/09/2026 · worktree `metodos-m1`, mesmo branch. Sem candidato novo.

## O que entreguei

- **A segunda varredura**, no fim de [`auditoria-da-voz.md`](auditoria-da-voz.md):
  feita **pelo padrão** que a primeira revelou, não por tela.
- **[`a-voz-do-traco.md`](a-voz-do-traco.md)** — a régua da voz, irmã da régua da
  proveniência, para quem for escrever a próxima frase de tela.

## Como varri, desta vez

Filtrei as cadeias que chegam ao autor nos 149 arquivos por **o app como
sujeito** (o Traço, o app, ele) ou por **verbo de capacidade** (aprende, entende,
guarda, protege, sugere, calcula, decide, reconhece, analisa, garante,
sincroniza, ajuda, adapta…). Vinte e seis frases casaram, e **fui ao código
conferir cada uma que faz promessa verificável** — foi isso que fez o achado 1 da
M11 valer, e é o que separa opinião de achado.

Não há **onboarding** nem **texto de loja** no repositório. Se existirem fora
dele, são a superfície em que um app mais promete de si, e ninguém auditou.

## Três achados novos

**5. `PerfilView.swift:209` — "O app lê ao abrir." É o achado raro: promete MENOS
do que o app faz.** `Sessao.recolherEntrada` chama `Catalogo.recarregar()` e é
chamada em três lugares (`PaginaView:118, 198, 636`): no arranque, **a cada volta
à cena ativa** e na rota `anotar`. O comentário do próprio método já diz
"Chamado no arranque e ao voltar à cena". Consequência: quem larga um método novo
na pasta com o app aberto acha que precisa fechar e reabrir. Não precisa.
**Corrigido:** "O app lê ao abrir — e toda vez que você volta para ele."

**6. `CalendarioSistema.swift:77` — "ainda não perguntei. Abra o Calendário e eu
peço."** O app vira interlocutor com um EU, contra a regra escrita no próprio
código (`PadroesView`: *"'Li' dava um EU à IA — e o app não é interlocutor"*).
As outras três linhas da mesma função estão certas. **Corrigido:** "o Traço ainda
não pediu acesso. Abra o Calendário e ele pede."

**7. `TracoWidget.swift:463` — "e a que horas o Traço te avisa."** Promete o aviso
sem a condição — e o próprio app sabe dizer as duas em que ele não toca (avisos
desligados; teto de 64 do iOS ocupado). Mais o "te", quando o app trata o autor
por "você" em todo o resto. **Arquivo em obra pela volta dos widgets.**
**Corrigido:** "O que vem a seguir, e a hora do aviso — quando os avisos estão
ligados."

## Sete promessas conferidas no código, e verdadeiras

Metade do valor está aqui. Cada uma sobreviveu a alguém abrir o arquivo:

- **"o Traço nunca o edita nem o apaga"** e **"nunca escreve em nenhum"** (o
  calendário do sistema) — não há `.save(` nem `.remove(` sobre o `EKEventStore`
  em lugar nenhum; `CalendarioSistema` só tem `ler`.
- **"O iPhone guarda 64 avisos"** — é o teto do iOS, e a frase diz de quem é o
  limite.
- **"essa você queimou. ficou a data e o que você entendeu."** — conferido linha
  por linha: o texto é sobrescrito com espaços e esvaziado, campos limpos, e
  versões, marcas, índice, avisos e ações derivadas apagados. Sobrevivem
  `sentido` e `queimadaEm` — exatamente a linha e a data.
- **"A ligação é sua; o app só a segue."** — `Rede` lê `[[…]]` e o campo "Liga a".
- **"Vira nota na próxima vez que ele abrir."** (o Atalho Anotar) — verdadeiro, e
  é a mesma rota do achado 5: ali a frase acertou.
- **"Classifica o que você escreveu. Não escreve na nota."** — verdadeiro por
  contrato.

## A régua da voz

`a-voz-do-traco.md`, e a regra que resume todas é uma frase:

> **O app diz o que faz, não o que é.**

Ela se abre em três sujeitos — quando o app fala **de si** (onde ele erra: exige
abrir a função antes de escrever, e a condição faz parte da promessa), **do
autor** (só o que ele fez, contado; nunca o que ele é) e **do mundo** (cita ou
corta; e diz de quem é o limite). Mais o tom que as varreduras mostraram: **o app
não tem EU**, o autor é "você" e nunca "te", minúscula no estado e maiúscula na
ação, curto ganha, e **nenhuma frase do Traço elogia** — ausência deliberada, não
esquecimento.

Os padrões que ela usa como modelo são do app, não meus: o parágrafo dos degraus
no Perfil, o "quem lê é você" dos Padrões, as três negações do Trabalho, a frase
da queima, as notificações de corpo vazio e "A frase aqui é sua. O Traço não
escreve."

E o fecho, para quem revisa: **leia a frase como se fosse cobrar dela — se eu
abrir o arquivo, acho isto lá dentro?** É a mesma pergunta da régua da
proveniência, virada para o próprio app.
