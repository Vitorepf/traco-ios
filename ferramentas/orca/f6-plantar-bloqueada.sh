#!/bin/bash
# F6: planta os widgets do Traço na TELA BLOQUEADA do simulador — o inline
# no topo e os dois retangulares na fileira — pelo editor real do iOS.
#
# A F1 concluiu que "o simulador não expõe Personalizar": a CAPTURA é cega ao
# chrome do editor (só o pôster sai no simctl screenshot), mas a árvore de AX
# (`orca emulator ax`) o enxerga inteiro e responde — e aqui o PosterBoard é o
# app da frente, então a árvore não devolve 503. Cada passo abaixo procura o
# botão pelo RÓTULO na árvore e toca no centro; nada por coordenada fixa.
#
# Uso: f6-plantar-bloqueada.sh <UDID> [inline: traco|proximo]
# Pré-condição: app instalado, tela DESTRANCADA na casa; cada toque passa por
# f5b-emu.sh (trava + reatar). Ao fim a tela fica bloqueada com os widgets.
set -e
U="$1"; INLINE="${2:-traco}"
AQUI="$(cd "$(dirname "$0")" && pwd)"; EMU="$AQUI/f5b-emu.sh"
PY=$(cat <<'PYEOF'
import sys, json
d = json.load(sys.stdin)
def walk(n):
    f = n.get('frame', {}); lab = n.get('label') or n.get('value') or ''
    cx = f.get('x', 0) + f.get('width', 0) / 2; cy = f.get('y', 0) + f.get('height', 0) / 2
    print('%s\t%s\t%s\t%.3f\t%.3f' % (n.get('type', ''), lab, n.get('id', ''), cx, cy))
    for c in n.get('children', []): walk(c)
r = d.get('result', d)
for n in (r if isinstance(r, list) else [r]): walk(n)
PYEOF
)
arvore() { "$EMU" "$U" ax | python3 -c "$PY"; }
# achar <regex-do-rótulo> -> "x y" do primeiro nó que casa (vazio se não há)
achar() { arvore | awk -F'\t' -v re="$1" '$2 ~ re || $3 ~ re {print $4, $5; exit}'; }
tocar() {  # tocar <regex> [tentativas]: procura, toca, falha alto se não achou
  local xy; for _ in $(seq 1 "${2:-8}"); do xy=$(achar "$1"); [ -n "$xy" ] && break; sleep 1; done
  [ -n "$xy" ] || { echo "f6-plantar: não achei '$1' na árvore" >&2; arvore >&2; exit 1; }
  "$EMU" "$U" tap $xy >/dev/null; echo "  toquei '$1' em ($xy)"; sleep 2
}
esperar_n() {  # esperar_n <regex> <n>: ao menos n nós com o rótulo (a fileira mostra "Traço" sem id)
  for _ in $(seq 1 8); do [ "$(arvore | awk -F'\t' -v re="$1" '$2 ~ re' | wc -l)" -ge "$2" ] && return 0; sleep 1; done
  echo "f6-plantar: esperava $2× '$1' e não veio" >&2; arvore >&2; exit 1
}
esperar() {  # esperar <regex>: falha alto se o rótulo não aparecer em ~8 s
  for _ in $(seq 1 8); do [ -n "$(achar "$1")" ] && return 0; sleep 1; done
  echo "f6-plantar: esperava '$1' e não veio" >&2; arvore >&2; exit 1
}
rolar_ate() {  # rolar_ate <regex>: rola a lista da folha para cima até o rótulo aparecer
  local G='[{"type":"begin","x":0.5,"y":0.9},{"type":"move","x":0.5,"y":0.85},{"type":"move","x":0.5,"y":0.75},{"type":"move","x":0.5,"y":0.65},{"type":"end","x":0.5,"y":0.6}]'
  sleep 1.5   # a folha ainda anima: um arrasto cedo demais vira toque num app da lista
  for _ in $(seq 1 8); do
    [ -n "$(achar "$1")" ] && return 0
    # caiu no detalhe de um app (tem "fechar" e não o título da lista): volta
    if [ -n "$(achar '^fechar$')" ] && [ -z "$(achar '^Adicionar Widgets$')" ]; then tocar '^fechar$'; fi
    "$EMU" "$U" gesture "$G" >/dev/null; sleep 1.5
  done
  [ -n "$(achar "$1")" ] || { echo "f6-plantar: '$1' não apareceu ao rolar" >&2; exit 1; }
}
# 1. trancar e entrar no editor: toque longo no pôster, depois "Personalizar"
# helper velho por boot: o serve-sim do boot anterior responde ok sem tocar e a
# árvore vem vazia — matar só o PID do MEU UDID e reatar (lição da F5b-B)
if [ -z "$(arvore | head -1)" ]; then
  PID=$(orca emulator list --json 2>/dev/null | python3 -c "
import sys, json; d = json.load(sys.stdin); r = d.get('result', d)
for s in (r.get('streams') if isinstance(r, dict) else []):
    if s.get('device') == '$U': print(s.get('pid'))" | head -1)
  [ -n "$PID" ] && { echo "  helper velho ($PID): matando e reatando"; kill "$PID"; sleep 2; }
fi
# `button lock` numa tela JÁ trancada acorda/destranca: confira pela árvore antes
for _ in 1 2 3; do
  xcrun simctl terminate "$U" app.traco 2>/dev/null || true
  if [ -n "$(achar 'Passe o dedo para cima para desbloquear')" ] && [ -z "$(achar 'posterboard')" ]; then break; fi
  "$EMU" "$U" button home >/dev/null; sleep 1.5
  "$EMU" "$U" button lock >/dev/null; sleep 2.5
done
[ -n "$(achar 'Passe o dedo para cima para desbloquear')" ] || { echo "f6-plantar: a tela não trancou" >&2; exit 1; }
# no pôster, entre o relógio (y 0,18) e o cartão da atividade viva (0,57–0,84):
# em 0,5 o toque longo caía no cartão e abria o app
P='[{"type":"begin","x":0.5,"y":0.4}'; for _ in $(seq 1 40); do P="$P"',{"type":"move","x":0.5,"y":0.4}'; done; P="$P"',{"type":"end","x":0.5,"y":0.4}]'
"$EMU" "$U" gesture "$P" >/dev/null; sleep 2.5
tocar 'posterboard-customize-button'
# 2. a fileira: os dois retangulares do Traço
tocar 'grouped-widgets-reticle-view'
rolar_ate '^Traço$'; tocar '^Traço$'
esperar 'A única coisa de hoje'
tocar '^Traço, Traço$'; esperar_n '^Traço$' 2   # o app da lista + o cartão na fileira
"$EMU" "$U" gesture '[{"type":"begin","x":0.85,"y":0.6},{"type":"move","x":0.7,"y":0.6},{"type":"move","x":0.5,"y":0.6},{"type":"move","x":0.3,"y":0.6},{"type":"end","x":0.15,"y":0.6}]' >/dev/null
esperar 'página 2 de 2'
tocar '^Traço, Próximo compromisso$'; esperar_n '^Traço$' 3
tocar '^fechar$'; esperar '^Adicionar Widgets$'
# 3. o inline do topo: com a folha aberta o reticle SOME da árvore mas continua
# tocável no lugar onde estava (0.5, 0.093 no 17 Pro) — o único toque cego daqui
"$EMU" "$U" tap 0.5 0.093 >/dev/null; sleep 2.5
[ -n "$(achar '^Escolha um Widget$')" ] || { echo "f6-plantar: a galeria do inline não abriu" >&2; exit 1; }
case "$INLINE" in proximo) R='^Traço, Próximo compromisso, Widget Superior$' ;; *) R='^Traço, Traço, Widget Superior$' ;; esac
rolar_ate "$R"; tocar "$R"
# 4. OK — o botão do topo continua alcançável com a folha aberta
tocar 'editing-done'
sleep 3
arvore | awk -F'\t' '$2 ~ /Par de Fundos|Personalizar Tela|Concluído|OK/ {print "  diálogo: " $2}'
echo "plantado; árvore da bloqueada:"; arvore | grep -i "traco\|Traço" || true
