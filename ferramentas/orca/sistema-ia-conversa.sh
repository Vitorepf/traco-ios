#!/bin/bash
# SISTEMA-IA / CONVERSA — a jornada real de perguntar à sábia nas Notas, no
# aparelho da CONTA, em `large`, numa chamada só de com-trava.sh:
# conta ANTES → cmp do binário → UMA instalação por cima → cmp → conta DEPOIS →
# Notas → "perguntar" → escrever → enviar → espera (pensando, tempo) → resposta
# inteira → fontes → retorno → conta DEPOIS DA MEDIDA. Vídeo do trecho todo.
# NUNCA xcodebuild test, erase, uninstall ou clearState aqui.
# Uso: sistema-ia-conversa.sh <UDID> <saida> <Traco.app> "<pergunta em US-ASCII>"
set -u
D="${1:?udid}"; OUT="${2:?saida}"; APP="${3:?Traco.app}"; PERGUNTA="${4:?pergunta}"
BID=app.traco
LER=/Users/vitorepf/orca/workspaces/traco-ios/instigar/build/f5-ler
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
sha()    { shasum -a 256 "$1" | awk '{print $1}'; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
achar()  { "$LER" "$OUT/$1" --xy | ALVO="$2" python3 -c '
import os,sys
alvo=os.environ["ALVO"]; a=alvo.lower(); cand=[]
for l in sys.stdin:
    p=l.rstrip("\n").split("\t",1)
    if len(p)==2 and a in p[1].lower():
        t=p[1].strip(); cand.append((0 if t==alvo else 1 if t.lower()==a else 2, len(t), p[0]))
if cand: print(sorted(cand)[0][2])'; }
tocar()  { local xy; foto "$1"; xy=$(achar "$1" "$2"); [ -z "$xy" ] && { echo "[$(hora)] NAO ACHEI [$2] em $1"; return 1; }
           orca emulator tap $xy --device "$D" >/dev/null 2>&1; echo "[$(hora)] toquei [$2] em $xy"; espera 1.5; }
lento()  { python3 -c '
import json,sys
de, ate = float(sys.argv[1]), float(sys.argv[2]); n = 6
p  = [{"type": "begin", "x": 0.5, "y": de}]
p += [{"type": "move", "x": 0.5, "y": de + (ate - de) * i / n} for i in range(1, n + 1)]
p += [{"type": "move", "x": 0.5, "y": ate}, {"type": "end", "x": 0.5, "y": ate}]
print(json.dumps(p))' "$1" "$2"; }
rolar()  { orca emulator gesture "$(lento "$1" "$2")" --device "$D" >/dev/null 2>&1; espera 1.5; }
conta()  { # conta <prefixo>: vai ao Perfil e lê o cartão CONTA por OCR.
  # O app abre na Página (a casa, sem barra de abas): "Notas" no alto leva ao
  # arquivo, e só lá a barra tem o Perfil.
  foto "$1-a.png"
  if [ -z "$(achar "$1-a.png" "Perfil")" ]; then tocar "$1-n.png" "Notas" || return 1; fi
  tocar "$1-p.png" "Perfil" || return 1
  espera 1.5; foto "$1-perfil.png"
  local l; l=$("$LER" "$OUT/$1-perfil.png" | grep -i -m1 "conectada\|precisa da sua conta\|sem conta")
  echo "[$(hora)] CONTA ($1): ${l:-<nao li o cartao>}"
  tocar "$1-b.png" "Notas" >/dev/null || true
}

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl bootstatus "$D" -b >/dev/null || { echo "BOOT FALHOU"; exit 2; }
echo "[$(hora)] APARELHO DE CONTA: $D  tamanho: $(xcrun simctl ui "$D" content_size 2>/dev/null)"

INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
echo "[$(hora)] binario ANTES : $(sha "$INST")"
echo "[$(hora)] a instalar    : $(sha "$APP/Traco")"
xcrun simctl launch "$D" $BID >/dev/null 2>&1; espera 2
conta 00 || exit 1

if cmp -s "$INST" "$APP/Traco"; then
  echo "[$(hora)] o binario instalado JA E O MEU — sem instalar de novo (uma instalacao por volta)"
else
  echo "[$(hora)] INSTALL (unico da volta, por cima): xcrun simctl install $D $APP"
  xcrun simctl install "$D" "$APP" || { echo "INSTALL FALHOU"; exit 3; }
fi
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: o binario instalado E O MEU" || { echo "[$(hora)] cmp: BINARIO DIFERENTE"; exit 3; }
xcrun simctl launch --terminate-running-process "$D" $BID >/dev/null 2>&1; espera 3
conta 01 || exit 1

# a jornada
xcrun simctl io "$D" recordVideo --codec h264 -f "$OUT/sistema-ia-conversa.mp4" >/dev/null 2>&1 & VID=$!
espera 1
foto 02-notas-large.png
tocar 03-a.png "perguntar" || { kill -INT $VID; exit 4; }
espera 1; foto 03-modo-perguntar-large.png
orca emulator type "$PERGUNTA" --device "$D" >/dev/null 2>&1; espera 1
foto 04-escrita-large.png
# a seta de enviar fica à direita do texto, na linha do pé (x=0,77, medido em
# 04-escrita-large.png de 15h11); o y é o da linha escrita — que mostra o FIM
# da pergunta, porque o campo rola com o caret
Y=$(achar 04-escrita-large.png "${PERGUNTA: -12}" | awk '{print $2}')
[ -z "$Y" ] && { echo "[$(hora)] NAO ACHEI a linha escrita"; kill -INT $VID; exit 4; }
orca emulator tap 0.77 $Y --device "$D" >/dev/null 2>&1; echo "[$(hora)] enviei (tap 0.77 $Y)"
T0=$(date +%s)
espera 1.2; foto 05-pensando-large.png
espera 4.5; foto 06-pensando-tempo-large.png
i=0; while [ $i -lt 150 ]; do
  espera 2; i=$((i+1)); foto 07-espera.png
  "$LER" "$OUT/07-espera.png" | grep -qi "nota sua\|notas suas\|nao respondeu\|não respondeu" && break
done
echo "[$(hora)] resposta em $(( $(date +%s) - T0 )) s"
cp "$OUT/07-espera.png" "$OUT/07-resposta-large.png"
rolar 0.75 0.30; foto 08-resposta-rolada-large.png
tocar 09-a.png "nota" && { espera 1; foto 09-fontes-large.png; }
tocar 10-a.png "serviu" && { espera 1; foto 10-anotado-large.png; }
kill -INT $VID 2>/dev/null; wait $VID 2>/dev/null
:
conta 11
rm -f "$OUT"/*-a.png "$OUT"/*-b.png "$OUT"/*-n.png "$OUT"/*-p.png "$OUT"/07-espera.png
echo "[$(hora)] FIM"
