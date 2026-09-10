#!/bin/sh
# Confere o registro de letras de ADR. Existe porque em 10/09/2026 houve QUATRO
# colisões num dia, todas pela mesma causa: alguém confiou na linha de resumo
# "Próxima livre" em vez da tabela, e a linha estava velha.
#
# A tabela manda; a linha de resumo envelhece. Isto lê a TABELA.
#
#   sh ferramentas/orca/letras-conferir.sh [caminho]   (padrão: o do repositório)
#   rc=0 limpo · rc=1 letra repetida · rc=2 "Próxima livre" mente
# --todos: varre o registro de TODOS os worktrees e acusa a letra que duas voltas
# reservaram em branches diferentes. É o modo que importa: as quatro colisões de
# 10/09 foram TODAS cruzadas, e cada arquivo passava sozinho — porque a colisão
# não vive dentro de um arquivo, vive ENTRE eles, e só aparece na mescla.
if [ "$1" = --todos ]; then
  tmp=$(mktemp); : > "$tmp"
  git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}' | while read -r w; do
    r="$w/ferramentas/orca/LETRAS-ADR.md"
    [ -f "$r" ] || continue
    grep -oE '^\| [0-9]{2}[a-z] ' "$r" | tr -d '| ' | sed "s|\$|	$(basename "$w")|" >> "$tmp"
  done
  # SÓ a série aberta. A primeira versão varria tudo e acusou VINTE E UMA letras:
  # branches parados há dias têm a redação ANTIGA da mesma linha, e comparar
  # descrição entre pontos diferentes da história acusa diferença onde há só
  # tempo. O sinal ficou afogado no ruído do próprio conferidor.
  # Colisão acontece na série que se está a escrever AGORA; é lá que ele olha.
  aberta=$(cut -f1 "$tmp" | sort -u | tail -1 | cut -c1-2)
  echo "letras da série $aberta reservadas em MAIS DE UM worktree:"
  achou=0
  for l in $(cut -f1 "$tmp" | sort -u | grep "^$aberta"); do
    onde=$(awk -F'\t' -v L="$l" '$1==L{print $2}' "$tmp" | sort -u)
    n=$(echo "$onde" | grep -c .)
    [ "$n" -le 1 ] && continue
    # a mesma volta em vários worktrees não é colisão: compara o TEXTO da linha
    textos=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}' | while read -r w; do
      r="$w/ferramentas/orca/LETRAS-ADR.md"; [ -f "$r" ] || continue
      grep -E "^\| $l " "$r" | cut -d'|' -f3 | sed 's/^ *//;s/ *$//'
    done | sort -u | grep -c .)
    [ "$textos" -le 1 ] && continue
    # Se a letra JÁ ESTÁ em `main`, `main` é a verdade e a diferença é só branch
    # parado com a redação velha — resolve-se sozinha na mescla. Colisão VIVA é a
    # letra que duas voltas escreveram e que `main` ainda não conhece.
    if git show origin/main:ferramentas/orca/LETRAS-ADR.md 2>/dev/null | grep -qE "^\| $l "; then
      echo "  · $l já está em \`main\` — a diferença é branch parado, some na mescla"
      continue
    fi
    echo "  ⛔ $l VIVA em dois lugares, e \`main\` não a conhece: $(echo $onde | tr '\n' ' ')"
    achou=1
  done
  [ $achou -eq 0 ] && echo "  nenhuma."
  rm -f "$tmp"
  exit $achou
fi

A="${1:-ferramentas/orca/LETRAS-ADR.md}"
[ -f "$A" ] || { echo "não achei $A"; exit 3; }

todas=$(grep -oE '^\| [0-9]{2}[a-z] ' "$A" | tr -d '| ' | sort)
serieAberta=$(echo "$todas" | tail -1 | cut -c1-2)
dup=$(echo "$todas" | uniq -d)
falha=0
for l in $dup; do
  if [ "$(echo "$l" | cut -c1-2)" = "$serieAberta" ]; then
    echo "⛔ LETRA REPETIDA na série ABERTA: $l"; falha=1
  else
    # Série fechada: renumerar quebraria as ADRs e o SPEC que já a citam.
    # Diz-se e vive-se com ela — mas NÃO se cala.
    echo "· repetida em série fechada (histórica, não se renumera): $l"
  fi
  grep -nE "^\| $l " "$A" | cut -c1-110 | sed 's/^/    /'
done
[ $falha -eq 1 ] && exit 1

ultima=$(grep -oE '^\| [0-9]{2}[a-z] ' "$A" | tr -d '| ' | sort | tail -1)
[ -n "$ultima" ] || { echo "tabela vazia?"; exit 3; }
serie=$(echo "$ultima" | cut -c1-2); letra=$(echo "$ultima" | cut -c3)
prox=$(printf "%s%s" "$serie" "$(echo "$letra" | tr 'a-y' 'b-z')")
[ "$letra" = z ] && prox="$(printf '%02d' $((serie + 1)))a"

# SÓ a linha autoritativa, que começa por `**Próxima livre:`. O arquivo cita a
# frase dentro de um parágrafo de história ("...que estava escrito aqui...") e a
# primeira versão disto leu a CITAÇÃO e acusou 09s — o oráculo a casar com o texto
# errado, que é o defeito que esta casa passa o dia a apanhar nos outros.
diz=$(grep -oE '^\*\*Próxima livre: [0-9]{2}[a-z]' "$A" | tail -1 | awk '{print $3}')
echo "última na tabela: $ultima   ·   próxima livre de facto: $prox   ·   o arquivo diz: ${diz:-nada}"
if [ "$diz" != "$prox" ]; then
  echo "⛔ a linha 'Próxima livre' MENTE — diz ${diz:-nada}, devia dizer $prox"
  exit 2
fi
echo "registro limpo."
exit 0
