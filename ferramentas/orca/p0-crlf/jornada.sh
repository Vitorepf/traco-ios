#!/bin/bash
# P0-CRLF, jornada real (ADR 09y): seis .md de fora na pasta `entrada/`, o app
# roda, e a pergunta é UMA — os arquivos do autor continuam no disco?
# Tudo dentro de UMA chamada de com-trava.sh: instalar, semear, lançar, fotografar.
set -u
U=34CC3F94-FDB5-4575-A4F5-80271829A18B
APP="$1"; SAIDA="$2"
mkdir -p "$SAIDA"

xcrun simctl install "$U" "$APP" || exit 1
C=$(xcrun simctl get_app_container "$U" app.traco data) || exit 1
E="$C/Documents/Traço/entrada"
rm -rf "$E"; mkdir -p "$E"

python3 - "$E" <<'PY'
import sys, pathlib
E = pathlib.Path(sys.argv[1])
selada = "---\ncriada: 2026-09-09T10:00:00Z\norigem: modelo\nestado: selada\n---\n\na dor que ninguém lê\n"
aberta = "---\ncriada: 2026-09-09T10:00:00Z\n---\n\ncorpo aberto\n"
casos = {
    "a-lf-selada.md":   selada,
    "b-tudo-crlf.md":   selada.replace("\n", "\r\n"),
    "c-cr-no-estado.md": selada.replace("estado: selada\n", "estado: selada\r\n"),
    "d-cr-na-origem.md": selada.replace("origem: modelo\n", "origem: modelo\r\n"),
    "e-prosa-antes.md": "# minhas notas de hoje\n\numa linha que só existe aqui\n\n" + aberta,
    "f-misto.md":       aberta + "\n---\ncriada: 2026-09-09T11:00:00Z\r\nestado: selada\n---\n\noutra dor\n",
    "g-md-solto.md":    "só uma ideia solta, sem cabeçalho nenhum\n",
}
for nome, texto in casos.items():
    (E / nome).write_bytes(texto.encode("utf-8"))
    print(nome, len(texto.encode("utf-8")), "bytes")
PY

R="$SAIDA/jornada.txt"
# O binário instalado É o candidato? A trava serializa COMANDO, não sessão: em
# 10/09 um install alheio entrou entre duas chamadas minhas e comeu quatro
# arquivos semeados. Confere-se aqui dentro, com a leitura, na MESMA trava.
{ echo "== $(date) — $U"; echo "== binário instalado bate com o candidato?";
  B=$(xcrun simctl get_app_container "$U" app.traco)
  cmp -s "$B/Traco" "$APP/Traco" && echo "SIM — cmp idêntico" || echo "NÃO — OUTRO BUILD, a medida abaixo não é minha"
  echo "== antes de lançar: entrada/"; ls -1 "$E"; } > "$R"

xcrun simctl terminate "$U" app.traco 2>/dev/null
xcrun simctl launch "$U" app.traco || exit 1
sleep 10
xcrun simctl io "$U" screenshot "$SAIDA/p0-01-depois-de-recolher.png" >/dev/null

C=$(xcrun simctl get_app_container "$U" app.traco data)   # pode ter trocado
{
  echo "== depois de o app recolher a entrada: entrada/ (o que SOBREVIVEU)"
  ls -1 "$C/Documents/Traço/entrada" 2>/dev/null
  echo "== o que virou nota (notas/, escrito pelo próprio app)"
  grep -rn "corpo aberto\|ideia solta" "$C/Documents/notas" 2>/dev/null | sed "s|$C/Documents/||"
  echo "== algum corpo SELADO entrou no caderno? (só entrada/ pode casar)"
  grep -rn "a dor que\|outra dor" "$C/Documents" 2>/dev/null | sed "s|$C/Documents/||"
  echo "== binário instalado ainda é o candidato, DEPOIS da corrida?"
  B=$(xcrun simctl get_app_container "$U" app.traco)
  cmp -s "$B/Traco" "$APP/Traco" && echo "SIM" || echo "NÃO — trocaram por baixo"
} >> "$R"
cat "$R"
