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
# A janela de 17:49Z chamou este roteiro sem o 3º argumento, e o texto da nota
# caiu em `$LER`: cada `achar` virou "command not found" e a captura morreu com
# a medida já paga. Argumento posicional errado não pode custar uma janela.
[ -x "$LER" ] || { echo "⛔ 3º argumento tem de ser o BINÁRIO do f5-ler, e '$LER' não é executável"; exit 9; }
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
# Arrasto LENTO, com pontos intermediários e uma parada antes do `end`. O
# arrasto de UM ponto é um FLIQUE: a rolagem do simulador amplifica (6 a 24x
# pela medida de 09/09) e um flique de 0,02 já passava do cartão inteiro. E
# `orca emulator` não tem `swipe` — o verbo é `gesture`, e cada ponto exige
# `type`: um `swipe` inventado falha em silêncio e a captura sai de onde
# estava. Os dois custaram três ensaios; ficam escritos.
lento() { # lento <de> <ate>
  python3 -c '
import json,sys
de, ate = float(sys.argv[1]), float(sys.argv[2]); n = 6
p  = [{"type": "begin", "x": 0.5, "y": de}]
p += [{"type": "move", "x": 0.5, "y": de + (ate - de) * i / n} for i in range(1, n + 1)]
p += [{"type": "move", "x": 0.5, "y": ate}, {"type": "end", "x": 0.5, "y": ate}]
print(json.dumps(p))' "$1" "$2"; }
rolar() { orca emulator gesture "$(lento "$1" "$2")" --device "$D" >/dev/null 2>&1; espera 2; }

tocar() { # tocar <foto> <trecho>
  local xy; foto "$1"; xy=$(achar "$1" "$2")
  [ -z "$xy" ] && { echo "[$(hora)] NAO ACHEI [$2] em $1"; return 1; }
  orca emulator tap $xy --device "$D" >/dev/null 2>&1
  echo "[$(hora)] toquei [$2] em $xy"; espera 2; }

# helper do boot anterior diz "ok" e não toca: mata só o deste UDID e reata
pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }

# LIBERAR abre a rota na TELA, e não só na sonda: `Politica.aviso` delega a
# `Politica.provedor`, que em DEBUG consulta `liberadasParaAvaliacao`. Por isso
# a captura do cartão VIVO não exige virar a tabela antes de a medida decidir —
# o ensaio no teste 4 mostrou a tela dizendo a frase de indisponível sem ele.
# Sem `TRACO_AVALIAR_IA`: a sonda não roda aqui, quem pergunta é a tela.
xcrun simctl launch --terminate-running-process "$D" app.traco >/dev/null 2>&1
espera 2
env SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=instigar \
  xcrun simctl launch --terminate-running-process "$D" app.traco >/dev/null 2>&1
espera 5
foto "$PRE-00-abriu.png"

# ---- (1) o cartão do `instigar`, com as perguntas reais ------------------
# O aparelho de TRABALHO abre escrevendo, porque não tem nota nenhuma; o
# aparelho da CONTA abre na LISTA, porque o autor tem notas lá. A janela de
# 18:35Z tentou digitar sobre a lista e não achou a Lente. "Escrever" primeiro,
# e o caminho passa a ser o mesmo nos dois.
tocar "$PRE-00-abriu.png" "Escrever" || echo "[$(hora)] (sem aba Escrever: já estava no editor)"
espera 3
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
# A Lente é uma FOLHA e cobre a barra de abas: o ensaio no teste 4 procurou
# "Perfil" com ela aberta e não achou, porque não estava na tela. Fecha antes.
tocar "$PRE-04-cartao-instigar.png" "Pronto" || {
  orca emulator swipe 0.5 0.35 0.5 0.95 --device "$D" >/dev/null 2>&1; espera 2; }
espera 2
# e o EDITOR também esconde a barra de abas enquanto tem foco (`escondida`), e
# o app ABRE escrevendo. Três ensaios para achar a saída: "Concluir" cai numa
# nota NOVA, ainda no editor; a coordenada do glifo de abaixar o teclado colide
# com o botão "Lente" da barra de baixo quando o teclado já está abaixado, e
# num dos ensaios mandou o app para o fundo. O que sai do editor é o "Notas"
# do TOPO ESQUERDO — volta para a lista, e aí a barra de abas está na tela.
tocar "$PRE-05-lente-fechada.png" "Notas" || { echo "[$(hora)] sem o Notas do topo"; exit 4; }
espera 3
tocar "$PRE-05b-lista-de-notas.png" "Perfil" || { echo "[$(hora)] sem aba Perfil"; exit 4; }
espera 3
# A rolagem do Perfil GUARDA a posição entre visitas, então "abriu o Perfil"
# não é uma posição conhecida. Dois arrastos LONGOS para baixo levam ao topo
# (medido: a terceira linha vira "CONTA"), e daí UM arrasto de 0,08 põe a lista
# de indisponíveis inteira na tela — os dois grupos, das seis operações à do
# `contrapor`. Calibrado no aparelho de trabalho em 10/09; o `grep` abaixo é o
# que impede a captura cega de mentir sobre o que viu.
rolar 0.30 0.85; rolar 0.30 0.85
foto "$PRE-06-perfil-topo.png"
"$LER" "$OUT/$PRE-06-perfil-topo.png" | sed -n 3p | grep -qi "CONTA" \
  || echo "[$(hora)] ⚠ o topo do Perfil não é o cartão CONTA — a calibragem mudou"
rolar 0.70 0.62
foto "$PRE-07-cartao-conta.png"
"$LER" "$OUT/$PRE-07-cartao-conta.png" | grep -qE "ainda não faz|Não há nada que ela deixe" \
  || echo "[$(hora)] ⚠ a lista de indisponíveis NÃO está nesta captura"
echo "[$(hora)] === O QUE A TELA DIZ (cartão CONTA do Perfil), lido da captura ==="
"$LER" "$OUT/$PRE-07-cartao-conta.png"
echo "[$(hora)] === o instigar ainda esta na lista de indisponiveis? ==="
"$LER" "$OUT/$PRE-07-cartao-conta.png" | grep -i "instigar" || echo "  (nenhuma linha com 'instigar' na captura)"
