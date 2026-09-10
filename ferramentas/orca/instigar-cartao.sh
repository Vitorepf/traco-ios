#!/bin/bash
# INSTIGAR (ADR 10c) — as DUAS capturas que a volta deve ao dono, na ordem em
# que ele lê: (1) o cartão do `instigar` com as PERGUNTAS REAIS na tela, e
# (2) o cartão CONTA do Perfil, que é a tela que ele mandou mudar.
#
# Roda DENTRO da janela (mesma trava), depois da medida. Sempre em `large`:
# tamanho de letra de acessibilidade é PROIBIDO (§12) e ninguém mexe nele aqui.
#
# Dirigido por OCR, e não pela árvore de AX: neste simulador o helper devolve a
# árvore VAZIA com o app claramente desenhado na captura — ausência na árvore
# não é ausência na tela (achado da Q4-E, e a razão do `--xy` no `f5-ler`).
set -u
D="${1:?udid}"; OUT="${2:?diretorio de saida}"; LER="${3:?binario do f5-ler}"
# sem acento de propósito: `orca emulator type` é US-ASCII e o corretor do iOS
# devolve os acentos ("espanhol" fica igual, "quinze" fica igual).
NOTA="${4:-Nao deu certo de novo.}"
PRE="${5:-i10c}"

hora()   { date -u +%Y-%m-%dT%H:%M:%SZ; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
# achar <foto> <trecho> → "x y". A ordem de preferência é MEDIDA, não teórica
# (Q4-E): 1) igual com a MESMA caixa — o rótulo da seção é "INSTIGAR" e o botão
# é "Instigar"; 2) igual ignorando caixa; 3) o MENOR trecho que contém.
achar()  {
  "$LER" "$OUT/$1" --xy | ALVO="$2" python3 -c '
import os,sys
alvo=os.environ["ALVO"]; a=alvo.lower(); cand=[]
for l in sys.stdin:
    p=l.rstrip("\n").split("\t",1)
    if len(p)==2 and a in p[1].lower():
        t=p[1].strip()
        cand.append((0 if t==alvo else 1 if t.lower()==a else 2, len(t), p[0]))
if cand: print(sorted(cand)[0][2])'; }
tocar() { # tocar <foto> <trecho>
  local xy; foto "$1"; xy=$(achar "$1" "$2")
  [ -z "$xy" ] && { echo "[$(hora)] NAO ACHEI [$2] em $1"; return 1; }
  orca emulator tap $xy --device "$D" >/dev/null 2>&1
  echo "[$(hora)] toquei [$2] em $xy"; espera 2; }

# helper do boot anterior diz "ok" e não toca: mata só o deste UDID e reata
pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }

xcrun simctl launch --terminate-running-process "$D" app.traco >/dev/null 2>&1
espera 5
foto "$PRE-00-abriu.png"

# ---- (1) o cartão do `instigar`, com as perguntas reais ------------------
orca emulator tap 0.35 0.18 --device "$D" >/dev/null 2>&1   # foco no corpo da página
espera 2
orca emulator type "$NOTA" --device "$D" >/dev/null 2>&1
espera 3
foto "$PRE-01-nota-escrita.png"

# a Lente vive na barra de baixo, e só aparece com o teclado abaixado
tocar "$PRE-01-nota-escrita.png" "Lente" || {
  orca emulator tap 0.893 0.9317 --device "$D" >/dev/null 2>&1; espera 2
  tocar "$PRE-01b-teclado-abaixado.png" "Lente" || { echo "[$(hora)] sem Lente: paro"; exit 2; }; }
espera 3
tocar "$PRE-02-lente.png" "Instigar" || { echo "[$(hora)] sem botão Instigar"; exit 3; }

# a espera é do Grok: a DIRETRIZ §10 mede 36 s de média e 77 s de pior caso, e a
# §13 registra 241 s medidos. O laço vai a ~240 s e diz o que leu a cada passo.
CHEGOU=nao
for s in 6 6 8 10 12 15 20 20 25 30 30 30 30; do
  espera $s
  foto "$PRE-03-esperando.png"
  # o cartão do instigar são PERGUNTAS: toda linha termina em "?". Procuro isso,
  # e não um rótulo — o rótulo da seção fica na tela com cartão ou sem ele.
  if "$LER" "$OUT/$PRE-03-esperando.png" | grep -qE '\?[[:space:]]*$'; then
    echo "[$(hora)] O CARTÃO CHEGOU"; CHEGOU=sim; break; fi
done
foto "$PRE-04-cartao-instigar.png"
echo "[$(hora)] === O QUE A TELA DIZ (cartão do instigar), lido da captura ==="
"$LER" "$OUT/$PRE-04-cartao-instigar.png"
[ "$CHEGOU" = sim ] || echo "[$(hora)] ⚠ o cartão NÃO chegou no tempo do laço — a captura acima é o que havia"

# ---- (2) o cartão CONTA do Perfil, que é a tela que o dono mandou mudar ----
tocar "$PRE-04-cartao-instigar.png" "Perfil" || {
  orca emulator tap 0.893 0.9317 --device "$D" >/dev/null 2>&1; espera 2
  tocar "$PRE-05-sem-teclado.png" "Perfil" || { echo "[$(hora)] sem aba Perfil"; exit 4; }; }
espera 3
foto "$PRE-06-perfil-topo.png"
# o cartão CONTA fica abaixo: desce até a palavra aparecer, e diz em que passo
for i in 1 2 3 4 5 6; do
  "$LER" "$OUT/$PRE-06-perfil-topo.png" | grep -qiE "^CONTA$|Indispon" && { echo "[$(hora)] CONTA visível no passo $i"; break; }
  orca emulator swipe 0.5 0.75 0.5 0.35 --device "$D" >/dev/null 2>&1
  espera 2; foto "$PRE-06-perfil-topo.png"
done
foto "$PRE-07-cartao-conta.png"
echo "[$(hora)] === O QUE A TELA DIZ (cartão CONTA do Perfil), lido da captura ==="
"$LER" "$OUT/$PRE-07-cartao-conta.png"
echo "[$(hora)] === o `instigar` ainda está na lista de indisponíveis? ==="
"$LER" "$OUT/$PRE-07-cartao-conta.png" | grep -i "instigar" || echo "  (nenhuma linha com 'instigar' na captura)"
