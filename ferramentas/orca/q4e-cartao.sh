#!/bin/bash
# Q4-E — a captura do cartão do `contrapor` com a RESPOSTA REAL. Roda DENTRO da
# janela (mesma trava), depois da medida.
#
# Dirigido por OCR, e não pela árvore de AX: neste simulador o helper devolve a
# árvore VAZIA com o app claramente desenhado na captura — ausência na árvore
# não é ausência na tela. `f5-ler.swift --xy` dá o centro do trecho em 0..1, que
# é o que `orca emulator tap` espera. Cada passo imprime ONDE tocou e fotografa.
#
# O caminho foi ENSAIADO no aparelho de trabalho antes de gastar a janela da
# conta (`q4e-01-sem-conta-a-lente-diz.png`): digitar na página, abrir a Lente,
# tocar Contrapor. O `traco://anotar` foi tentado e ABANDONADO — abre diálogo
# do sistema e, depois de um "Cancelar", o iOS para de reabri-lo.
set -u
D="${1:?udid}"; OUT="${2:?diretorio de saida}"; LER="${3:?binario do f5-ler}"
# sem acento de propósito: `orca emulator type` é US-ASCII, e o corretor do iOS
# devolve os acentos ("sabado" → "sábado", "versoes" → "versões").
NOTA="${4:-Vou virar o banco de dados de uma vez no sabado a noite. Fazer em etapas ja descartei: o esquema muda inteiro e as duas versoes nao rodam juntas. Adiar tambem nao da, o contrato vence neste mes. Nao sei quanto tempo a virada leva e nao tenho ambiente de teste com os dados reais.}"

hora()   { date -u +%Y-%m-%dT%H:%M:%SZ; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
# achar <foto> <trecho> → "x y". A ordem de preferência é MEDIDA, não teórica:
# 1) igual com a MESMA caixa — o rótulo da seção é "CONTRAPOR" e o botão é
#    "Contrapor", e o ensaio tocou o rótulo, que não faz nada;
# 2) igual ignorando caixa;  3) o MENOR trecho que contém — o ensaio tocou o
#    título `Abrir com "Traço"?` em vez do botão `Abrir`.
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
foto q4e-00-abriu.png
orca emulator tap 0.35 0.18 --device "$D" >/dev/null 2>&1   # foco no corpo da página
espera 2
orca emulator type "$NOTA" --device "$D" >/dev/null 2>&1
espera 3
foto q4e-01-nota-escrita.png

# a Lente vive na barra de baixo, e só aparece com o teclado abaixado
tocar q4e-01-nota-escrita.png "Lente" || {
  orca emulator tap 0.893 0.9317 --device "$D" >/dev/null 2>&1; espera 2
  tocar q4e-01b-teclado-abaixado.png "Lente" || { echo "[$(hora)] sem Lente: paro"; exit 2; }; }
espera 3
tocar q4e-02-lente.png "Contrapor" || { echo "[$(hora)] sem botão Contrapor"; exit 3; }

# a espera é do Grok: a ADR 09s e a DIRETRIZ §10 medem 36 s de média, 77 s de pior caso
for s in 6 6 8 10 12 15 20 20; do
  espera $s
  foto q4e-03-esperando.png
  # CAIXA ALTA e sem -i, de propósito: os rótulos do cartão são "O OUTRO LADO",
  # "FORA DA LISTA" e "EM OUTRO CAMPO", e o subtítulo da seção — sempre na tela,
  # cartão ou não — é "o outro lado, a opção que faltou…". Com `-i` o ensaio
  # anunciou "O CARTÃO CHEGOU" 8 s depois do toque, sobre uma tela sem cartão.
  if "$LER" "$OUT/q4e-03-esperando.png" | grep -qE "O OUTRO LADO|FORA DA LISTA|EM OUTRO CAMPO"; then
    echo "[$(hora)] O CARTÃO CHEGOU"; break; fi
done
foto q4e-04-cartao.png
echo "[$(hora)] === O QUE A TELA DIZ, lido da captura ==="
"$LER" "$OUT/q4e-04-cartao.png"
