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
| 08x | C1 (caret do Caderno) | reservada, volta viva — era 08w, trocada |
| 08y | R1 (retomada do Trabalho) | reservada, volta viva |

**Próxima livre: 08z.**

## 2026-09-09

| letra | dona | estado |
|---|---:|---|
| 09a | — | **buraco, fica vaga** |
| 09b | MAC-1-B (a origem acompanha todo consumidor) | em `main` |
| 09c | S1 (a pergunta interrompida) | no branch da S1 |
| 09d | S1-B (o vazio também rola) | no branch da S1 |
| 09e | C1-D (a reconciliação da C1) | no branch da C1 |
| 09f | M1 (a migração do caderno) | no branch da M1 |
| 09g | C1-A (era 08w, depois 09d) | no branch da C1 |
| 09h | Q3 (responder nas Notas) | reservada, a abrir quando a M1 mesclar |
| 09i | Q4 (instigar e contrapor) | reservada, a abrir quando a M1 mesclar |

**Próxima livre: 09j.**

**A 08 está CHEIA** — de `08a` a `08z`, com `08c` e `08d` como buracos que ficam
vagos. Quem precisar de letra hoje usa a série `09`.

**Aviso que a C1-D deixou e que eu confirmei:** este arquivo **estava errado sobre
si mesmo**, dando `08z` como livre quando ela está no branch da Q2. O registro só
vale se quem despacha o atualiza **no mesmo ato** em que reserva — foi assim que
a `09d` saiu duas vezes no mesmo turno.
