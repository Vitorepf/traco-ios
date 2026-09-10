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
f=$(pgrep -x sirittsd; pgrep -x speechsynthesisd); e=$(pgrep -f 'SiriAUSP|MacinTalkAUSP')
echo "FALA: $(echo "$f" | grep -c .)   (estopim no simulador: $(echo "$e" | grep -c .))"
[ -n "$f" ] && ps -p $(echo $f | tr ' ' ',') -o pid=,lstart=
exit 0
