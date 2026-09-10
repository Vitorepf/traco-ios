#!/bin/sh
# FALANTE: daemon do Mac (sai pelo alto-falante do dono). ESTOPIM: plugin dentro
# de um simulador ligado — não é fala, é a máquina que falaria; não se mata às cegas.
f=$(pgrep -x sirittsd; pgrep -x speechsynthesisd); e=$(pgrep -f 'SiriAUSP|MacinTalkAUSP')
echo "FALA: $(echo "$f" | grep -c .)   (estopim no simulador: $(echo "$e" | grep -c .))"
[ -n "$f" ] && ps -p $(echo $f | tr ' ' ',') -o pid=,lstart=
exit 0
