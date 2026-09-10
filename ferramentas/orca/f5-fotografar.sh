#!/bin/bash
# Uma captura da casa, com o ambiente que a face precisa — e só dada por boa
# quando o CONTEÚDO esperado está na tela, lido por OCR.
# Uso: f5-fotografar.sh <UDID> <saida.png> [tema] [—] [texto] [vezes]
#   tema: light | dark
#   O 4º lugar era o TAMANHO e agora é IGNORADO (DIRETRIZ §12, dono, 10/09):
#   o tamanho é sempre `large`. Acessibilidade máxima está PROIBIDA — nada de
#   AX1..AX5 nem XXXL. O lugar fica vazio de propósito, para não deslocar o
#   texto e o número de vezes nos chamadores que já existem.
#   texto: trecho curto que a face tem de mostrar (padrão: as duas primeiras
#          palavras de $LINHA, a mesma que f5-semear.sh planta)
#   vezes: quantas faces têm de mostrá-lo (padrão 1; com o plantio padrão de
#          f5-plantar.py o Destaque aparece em 2 cartões — passe 2)
#
# O `chronod` guarda o tamanho de tipo, o tema E o desenho pronto de cada
# entrada: sem matá-lo ANTES do SpringBoard a face volta do cache, com o
# ambiente velho e às vezes com o código velho (visto na tela, 08/09).
#
# Espera fixa não é prova: o G3 da F4-F pegou dois cartões em branco 15 s depois
# do SpringBoard renascer, e a mesma face inteira 25 s mais tarde. Por isso a
# captura é repetida até o OCR achar o texto `vezes` vezes; se em 90 s não
# achou, o script FALHA e guarda o último quadro como *.nao-pronta.png.
set -e
U="$1"; SAIDA="$2"; TEMA="${3:-light}"; TAM=large  # DIRETRIZ §12: o 4º parâmetro foi removido; acessibilidade máxima é proibida
LINHA="${LINHA:-terminar o capítulo do meio antes de dormir}"
TEXTO="${5:-$(echo "$LINHA" | cut -d' ' -f1-2)}"; VEZES="${6:-1}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
LER="${TMPDIR:-/tmp}/f5-ler"
[ "$LER" -nt "$AQUI/f5-ler.swift" ] || swiftc -O -o "$LER" "$AQUI/f5-ler.swift"

xcrun simctl ui "$U" appearance "$TEMA" >/dev/null
xcrun simctl ui "$U" content_size "$TAM" >/dev/null
sleep 1
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.chronod 2>/dev/null || true
sleep 2
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.SpringBoard 2>/dev/null || true

T0=$(date +%s); QUADRO="${SAIDA%.png}.nao-pronta.png"
while :; do
  sleep 3
  xcrun simctl io "$U" screenshot "$QUADRO" >/dev/null 2>&1 || continue
  # ponytail: OCR junta as linhas com espaço; um trecho curto sobrevive à quebra de linha
  N=$("$LER" "$QUADRO" | tr '\n' ' ' | tr -s ' ' | grep -o -F -i -- "$TEXTO" | wc -l | tr -d ' ')
  if [ "$N" -ge "$VEZES" ]; then
    mv "$QUADRO" "$SAIDA"
    echo "$(date +%H:%M:%S)  $SAIDA  ($TEMA, $TAM) — pronta em $(( $(date +%s) - T0 )) s, '$TEXTO' ×$N"
    exit 0
  fi
  if [ $(( $(date +%s) - T0 )) -ge 90 ]; then
    echo "f5-fotografar: a face NÃO ficou pronta em 90 s ('$TEXTO' ×$N, precisava ×$VEZES); último quadro em $QUADRO — isto não é evidência" >&2
    exit 1
  fi
done
