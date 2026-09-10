#!/bin/sh
# Confere o registro de letras de ADR. Existe porque em 10/09/2026 houve QUATRO
# colisões num dia, todas pela mesma causa: alguém confiou na linha de resumo
# "Próxima livre" em vez da tabela, e a linha estava velha.
#
# A tabela manda; a linha de resumo envelhece. Isto lê a TABELA.
#
#   sh ferramentas/orca/letras-conferir.sh [caminho]   (padrão: o do repositório)
#   rc=0 limpo · rc=1 letra repetida · rc=2 "Próxima livre" mente
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
