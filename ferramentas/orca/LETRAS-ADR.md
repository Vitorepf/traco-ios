# O registro das letras de ADR

**Um lugar só.** Antes de qualquer volta escrever uma ADR, o orquestrador reserva
a letra **aqui** e o spec aponta para este arquivo. Reservar dentro do spec de
cada volta foi o que produziu três colisões em 08/09 — a letra fica espalhada e
ninguém consegue ler o conjunto.

**O registro se lê por comando, não de memória** (vale para TODAS as refs vivas:
um branch não mesclado já é dono da letra dele):

```
for ref in main origin/main $(git branch --list 'Vitorepf/*' | tr -d ' +*'); do
  echo "$ref: $(git grep -ho '2026-09-[0-9][0-9][a-z]' $ref -- SPEC.md | sort -u | tr '\n' ' ')"
done
```

**Buraco antigo não se reaproveita.** Uma letra que ficou vaga por uma ADR que
não nasceu continua vaga para sempre — reusá-la faz duas coisas diferentes terem
o mesmo nome na história.

**Quando duas voltas vivas colidem, muda quem é mais barato de mover**, não quem
chegou depois: uma volta com letras encadeadas e revisor que já as conferiu fica;
uma ADR sozinha, ou uma que ainda nem foi escrita, muda.

**A troca se prova do tamanho da alegação:** normalize a letra nos dois lados do
diff e mostre que os multiconjuntos de linhas removidas e adicionadas são
idênticos. Sobrou linha, a alegação "só a letra mudou" é falsa.

## 2026-09-08

| letra | dona | estado |
|---|---|---|
| 08a, 08b, 08e, 08f, 08g, 08h, 08i, 08j, 08k | voltas de 07–08/09 | em `main` |
| 08c, 08d | — | **buracos, ficam vagos** |
| 08l | volta Q (Perfil, a terceira linha) | no branch da Q |
| 08m, 08n, 08o | E1, E1-B, E1-C | em `main` |
| 08p, 08q, 08r | volta Q (Q-C/Q-D, Q, Q-B) | no branch da Q |
| 08s | A1 (arranque honesto) | em `main` — era 08n, renumerada |
| 08t | V13 (Notas) | em `main` — era 08p, renumerada |
| 08u | MAC-1 (Traço no Mac) | reservada, volta viva |
| 08v | F5b (Ilha do compromisso) | reservada, volta viva |
| 08w | Q-H (reconciliação da Q com o `main`) | no branch da Q |
| 08x | C1-B/C (a gaveta e a linha do autor) | reservada, volta viva — era 08w, trocada |
| 08y | R1 (retomada do Trabalho) | reservada, volta viva |
| 08z | Q2 (responder) | **no branch da Q2** — tomada sem passar por aqui, LIDA pelo comando em 09/09 na C1-D |
| 08x | C1 (caret do Caderno) | reservada, volta viva — era 08w, trocada |
| 08y | R1 (a retomada do Trabalho) | no branch da R1 |

**08 está CHEIA.** `08a`–`08z` estão todas tomadas ou são buracos (`08c`, `08d`).
A `08z` desmente o "próxima livre: 08z" que estava escrito aqui: quem lê de
memória em vez de rodar o comando dá a mesma letra duas vezes, que é o defeito
que este arquivo existe para impedir — e ele reincidiu no próprio arquivo.

## 2026-09-09

| letra | dona | estado |
|---|---:|---|
| 09a | — | **buraco, fica vaga** |
| 09b | MAC-1-B · a origem acompanha todo consumidor | em `main` |
| 09c | S1 · a pergunta interrompida | em `main` |
| 09d | S1-B · o vazio também rola | em `main` |
| 09e | C1-D · a reconciliação da C1 | em `main` |
| 09f | M1 e M1-B · a migração do caderno | em `main` |
| 09g | C1-A · era 08w, depois 09d | em `main` |
| 09h | Q3, Q3-B e Q3-C · responder nas Notas | em `main` (emendas vivas) |
| 09i | Q4, Q4-B e Q4-C · instigar e contrapor | em `main` (emendas vivas) |
| 09j | FUSÃO · o toast é gaveta; o piso empata | em `main` |
| 09k | D1 · as Notas sem slop | em `main` |
| 09l | K1 · o cofre do dono não é da suíte | em `main` |
| 09m | MAC-0-D · o Grok Bot recusa servidor local | em `main` |
| 09n | Q2-E adotou e foi REVERTIDA; Q2-F refez a medida | em `main` |
| 09o | B1 e B1-B · os `try!` e o portão que falha fechado | em `main` |
| 09p | MAC-0-E · o servidor chega por `--chamar` | em `main` |
| 09q | B2 · estados inalcançáveis e rotas que calam; a frase existia e nenhuma tela a dizia | em `main` |
| 09r | F6 · os widgets da tela bloqueada | em `main` |
| 09s | Q4-C · a guarda que apaga não pode virar silêncio num 200 | reservada, volta viva |
| 09t | MERGE-Q34 · o que foi medido entra em main, e a tela diz o que a medida leu | em `main` |
| 09u | MAC-2-A · o Trabalho chega ao Mac para ser lido | reservada, volta viva |
| 09v | Q3-C · o modelo se escolhe POR OPERAÇÃO, com a comparação pareada na mão | reservada, volta viva |
| 09w | Q3-D · o sinal de sobra: cartão com teto não corta calado | reservada, volta viva |
| 09x | Q4-E · o caso cego do `contrapor`, e o modelo desta rota | reservada, volta viva |
| 09y | P0-CRLF · o arquivo só se apaga quando o app delimitou tudo o que havia nele | em `main` |
| 09z | MERGE-Q3D · o Perfil fala a língua do autor (cartão CONTA e `semProvedor`) | em `main` |

**A SÉRIE 09 ACABA AQUI.** A `09z` é a última letra do dia 09. **A próxima volta usa
`2026-09-10a`**, e daí em diante a série do dia 10 — `10a`, `10b`, … Escrevo isto antes de
alguém tropeçar: a série 08 encheu sem aviso e custou três colisões numa tarde.

### Série do dia 10

| letra | dona | estado |
|---|---:|---|
| 10a | TEMPO · o teto vira margem declarada, e a espera ganha estado | reservada, volta viva |
| 10b | RESPONDER · o pedido condicionado à matéria (G0 da Astra) | **em `main`** — o prompt foi medido e NÃO fecha; `responder` fica cortada |
| 10c | INSTIGAR · a irmã: condicionar à matéria também nas perguntas | reservada, volta viva |
| 10d | CONTRAPOR · a alavanca é o ESQUEMA DA SAÍDA, e o join que decidia por cima dela reprovou | **em `main`** — G3 em `ferramentas/orca/g3-contrapor-responder-ctx.md`: forma fica, join sai como dívida nomeada, e o "controle SUBIU" virou "não caiu" (o mesmo braço oscila 5) |

| 10e | SUPERFÍCIE · falar com a sábia: um componente só, a pergunta como título, a resposta como folha | reservada, volta viva |
| 10f | SISTEMA-IA/conversa · a conversa com a sábia como folha do Traço | escrita; mesclada em `main` 10/09 (G4 `ferramentas/orca/g4-conversa.md`) |

| 10g | RESPONDER · o contexto como alavanca: a nota citada inteira, e o que não coube se DIZ | **em `main`** — G3 em `ferramentas/orca/g3-contrapor-responder-ctx.md`: a operação FICA cortada, o código entra; varredura do controle refeita (`lote-10c-declara-corte.py`), desconto do §3.3 retratado, e o **C5 (a nota que não existe) fica por medir** |

| 10h | A CAUDA · a prova que não se pode abrir não é prova; e a razão da tela é o defeito de HOJE (`recordar` suprime, não vaza; `calibragem` nem chama com um par só) | **em `main`** — as 5 citações órfãs corrigidas, portão novo, `recordar` e `calibragem` reescritas |
| 10i | ENTRADA · perguntar é a marca "?", a mesma em toda tela; a busca volta à lista; o pé fica livre | reservada, volta viva (worktree `superficie`, branch `Vitorepf/entrada`) |
| 10j | PÍLULA · os destinos numa pílula flutuante só de ícones; Escrever num círculo fora dela (Hermes §2) | reservada, volta viva (worktree `superficie`, branch `Vitorepf/entrada`) |
| 10k | SISTEMA · caixa alta só agrupa (cabeçalho com contagem e recolher), linha de três níveis com fio recuado, a regra da cor escrita no Tema (Hermes §4, §5, §10) | reservada, volta viva (worktree `superficie`, branch `Vitorepf/entrada`) |
| 10l | CONVERSA-HERMES · a conversa sem caixa (linha de autor, texto, fio recuado) e a espera como cápsula com tempo colada ao campo, cujo botão muda com o estado | escrita no branch `Vitorepf/sistema-ia` (portão dos sete em `ferramentas/orca/conversa-hermes.md`); o coordenador mescla |

**Próxima livre: 10m.** *(série 10; a série 12 está abaixo)*

## 2026-09-11

| letra | dona | estado |
|---|---|---|
| 11a | Ação no tempo e no próximo compromisso; a régua olha o alvo da recuperação | em `main` |

## 2026-09-12

| letra | dona | estado |
|---|---|---|
| 12a | Um caderno; a guarda de obra é local | esta volta |

**Próxima livre: 12b.**

**A 09s colidiu, e quem mudou fui eu** (09/09, ~02h). Tomei a `09s` porque o
"Próxima livre: 09s" que estava escrito aqui batia com o comando; no mesmo
intervalo o orquestrador a reservou para a **Q4-C**, em `main`. Mudou quem é mais
barato de mover, que é a regra: a minha ADR **nenhum revisor tinha conferido**, e
renumerá-la é um `sed` em quatro lugares; a da Q4-C já está no spec de uma volta
por despachar. E a lição, que é minha: **reservar é ato de quem despacha** — eu
devia ter pedido a letra, não me servido dela.

**A `09p` continua sem ADR.** `git grep '2026-09-09p'` não acha nada em
`origin/main`, em arquivo nenhum, embora a linha acima a dê à MAC-0-E. Ou a ADR
não nasceu, ou nasceu com outro nome. Fica **como está**, e ninguém a reaproveita
até que a MAC-0-E diga qual das duas é.

**A série 08 está CHEIA** — de `08a` a `08z`, com `08c` e `08d` como buracos.

**A regra:** quem despacha atualiza este arquivo **no mesmo ato em que reserva**.

**E a 09t colidiu logo depois, pela mesma causa.** Eu confirmei a `09t` à MAC-2-A no
mesmo intervalo em que a MERGE-Q34 renumerava a dela **para** a `09t` e empurrava.
Venceu quem já está em `main`; a MAC-2-A foi para a `09u`, com um `sed` de zero linha
além da letra. **Duas colisões em uma hora, as duas minhas, as duas pela mesma falha:**
eu confirmei letra por mensagem antes de escrevê-la aqui. A regra sobe de tom:
**reservar é ESCREVER neste arquivo — dizer "é sua" por mensagem não reserva nada.**

**Quatro linhas para duas letras, e o dono era eu** (09/09, 23h3x). O G5 da F6 achou o
arquivo com `09q` e `09r` **duplicadas** — o par de cima dizendo "reservada, volta viva"
e o de baixo o estado verdadeiro —, e com a `09q` ainda "no branch" embora a B2 esteja
em `main` desde `3123140`. Nasceu de uma resolução de conflito minha que colou um bloco
novo sem apagar o velho, e sobreviveu porque **ninguém lê uma tabela inteira; lê a linha
que procura**. Consertado aqui. **A lição é a mesma da caça cega:** o registro que
ninguém confere por inteiro apodrece em silêncio — quem escreve uma linha nova
**confere que a letra aparece UMA vez só**, com `grep -c "^| 09x"`.

## 2026-09-17

| letra | dona | estado |
|---|---|---|
| 17m | Auditoria de produção: integridade de anexos e cópia, selo, IA e portão | branch `producao-17-09` |
| 17n | Lista de compras é toggle list: tarefa debaixo de «Comprar», visto verde desenhado, nenhum método | branch `formatacao-lista-tarefas` |
