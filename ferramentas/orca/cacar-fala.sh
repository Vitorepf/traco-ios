#!/bin/sh
# FALANTE: daemon do Mac (sai pelo alto-falante do dono). ESTOPIM: plugin dentro
# de um simulador ligado — não é fala, é a máquina que falaria; não se mata às cegas.
#
# O QUE ESTÁ PROVADO NESTA CAÇA, e o que não está (10/09, e a distinção é a lei):
#  - ESTOPIM: provado com ALVO PLANTADO. `exec -a MacinTalkAUSP-ISCA /bin/sleep` —
#    um sleep renomeado, zero áudio. Isca viva: acusa 1. Isca morta: acusa 0.
#  - FALANTE: NÃO foi possível plantar alvo, e isto se diz em vez de se fingir.
#    Copiar /bin/sleep para um arquivo chamado `sirittsd` faz o macOS matar o
#    processo no ato (rc=137: cópia de binário assinado perde a assinatura). O que
#    se pode afirmar é menos: o mecanismo `pgrep -x` foi conferido contra daemon
#    real (`pgrep -x loginwindow` → 405) e contra nome inexistente (rc=1), e a
#    perna pegou o `sirittsd` de verdade DUAS vezes — 23h20 de 09/09 e 07h36 de
#    10/09. Mecanismo provado e caça provada em campo, SEM alvo plantado.
#    Para fechar direito: isca assinada, ou um `--fingir` no próprio script.
#
#  - E O QUE ESTE ARQUIVO NÃO FAZIA, descoberto em campo às 19h42 de 10/09: ele
#    RELATAVA e não MATAVA. Eu li "FALA: 1" e o `sirittsd` continuou vivo, cinco
#    minutos, a sair pelo alto-falante do dono. **Vigia que vê e não age é pior
#    que vigia cego: o cego não dá falsa paz.** O `kill -9` abaixo fecha isso, e é
#    -9 de propósito — o `pkill` do dono usou SIGTERM em 09/09 e o `sirittsd`
#    IGNOROU-O, sobrevivendo 19 minutos.
f=$(pgrep -x sirittsd; pgrep -x speechsynthesisd); e=$(pgrep -f 'SiriAUSP|MacinTalkAUSP')
echo "FALA: $(echo "$f" | grep -c .)   (estopim no simulador: $(echo "$e" | grep -c .))"
if [ -n "$f" ]; then
  ps -p $(echo $f | tr ' ' ',') -o pid=,lstart=
  # SIGTERM não serve: o sirittsd ignora-o. VOZ É PROIBIDA — mata-se, não se pede.
  for p in $f; do kill -9 "$p" 2>/dev/null && echo "MORTO $p (kill -9)"; done
  sleep 1
  r=$(pgrep -x sirittsd; pgrep -x speechsynthesisd)
  if [ -n "$r" ]; then
    echo "⛔ AINDA FALA depois do kill -9: $r — ESCALAR AO DONO AGORA"
    exit 5
  fi
  echo "CALADO depois do kill."
fi
# O ESTOPIM não se mata: é plugin dentro de um simulador ligado, e matá-lo às
# cegas derruba o vizinho. Relata-se e vive-se com ele.
exit 0
