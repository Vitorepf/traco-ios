#!/bin/bash
# Avaliação da rota iOS `responderNasNotas` com conferência.
# NÃO instala, NÃO apaga o caderno, NÃO pede login, NÃO usa Grok Build.
# UDID padrão: test4. Conta desligada aborta antes de gastar casos.
# Identidade: compara carimbosDoPedido com SHA desta árvore (Sabia.swift).
#
# Uso:
#   OUT=/tmp/traco-sustentacao ./ferramentas/orca/avaliar-sustentacao-notas.sh
#   D=<udid> OUT=... ./ferramentas/orca/avaliar-sustentacao-notas.sh
set -u
RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
D="${D:-A1DF082C-FC87-4DF9-9F56-F2DA1C084DED}"
BID=app.traco
OUT="${OUT:-${1:-}}"
[ -n "$OUT" ] || { echo "OUT=diretorio (ou argumento 1)"; exit 2; }
mkdir -p "$OUT"

export TRAVA="${TRAVA:-/tmp/traco-${D}.lock}"
if [ -z "${TRACO_SOB_TRAVA:-}" ]; then
  exec env TRACO_SOB_TRAVA=1 "$RAIZ/ferramentas/orca/com-trava.sh" "$0" ${1+"$@"}
fi

FUM=q2-fumaca.json
SONDA_JSONL=avaliacoes-ia.jsonl

hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }

docs() { echo "$(xcrun simctl get_app_container "$D" "$BID" data)/Documents"; }

preservar_jsonl() {
  local DOCS; DOCS="$(docs)"
  [ -n "$DOCS" ] && [ -f "$DOCS/$SONDA_JSONL" ] || return 0
  cp "$DOCS/$SONDA_JSONL" "$OUT/anterior-$SONDA_JSONL"
  echo "[$(hora)] preservei JSONL anterior em $OUT/anterior-$SONDA_JSONL"
}

rodar() { # saida fixture timeout
  local saida="$1" fix="$2" tmo="${3:-180}"
  local src="$RAIZ/prova/$fix"
  [ -f "$src" ] || { echo "fixture ausente: $src"; return 3; }
  local DOCS; DOCS="$(docs)"
  [ -n "$DOCS" ] && [ -d "$DOCS" ] || { echo "Documents ausente no $D — app não instalado neste simulador. Sem install daqui."; return 3; }
  preservar_jsonl
  : > "$DOCS/$SONDA_JSONL"
  cp "$src" "$DOCS/$fix" || return 3
  echo "[$(hora)] INICIO $saida  udid=$D fixture=$fix ($(sha "$src" | cut -c1-12))"
  if ! env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" \
      xcrun simctl launch --terminate-running-process "$D" "$BID"; then
    echo "launch FALHOU"
    return 3
  fi
  local i=0
  while [ $i -lt $((tmo/2)) ]; do
    grep -q '"evento":"fim"' "$DOCS/$SONDA_JSONL" 2>/dev/null && break
    sleep 2; i=$((i+1))
  done
  cp "$DOCS/$SONDA_JSONL" "$OUT/$saida" 2>/dev/null || true
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null)"
  grep -q '"evento":"fim"' "$OUT/$saida" 2>/dev/null || { echo "sem evento fim — corrida incompleta"; return 3; }
}

echo "[$(hora)] test4 D=$D  trava=$TRAVA"
echo "[$(hora)] identidade: fumaça modelosGrok, sem gastar os casos da conferência"

rodar fumaca-sustentacao.jsonl "$FUM" 180 || exit $?

python3 - "$OUT/fumaca-sustentacao.jsonl" "$RAIZ/Traco/Analise/Sabia.swift" <<'PY'
import hashlib, json, sys
jsonl, swift = sys.argv[1], sys.argv[2]
src = open(swift, encoding="utf-8").read()

def extract(name):
    needle = f'static let {name} = """'
    i = src.index(needle) + len(needle)
    if src[i] == "\n":
        i += 1
    j = src.index('"""', i)
    indent = src[src.rfind("\n", 0, j) + 1:j]
    body = src[i:j]
    out = []
    for line in body.split("\n"):
        out.append(line[len(indent):] if line.startswith(indent) else line)
    return "\n".join(out)

esperado = {
    "pedidoResponderNasNotasSHA256": hashlib.sha256(extract("sistemaResponderNasNotas").encode()).hexdigest(),
    "pedidoConferenciaNotasSHA256": hashlib.sha256(extract("sistemaConferirNasNotas").encode()).hexdigest(),
}
try:
    linhas = [json.loads(l) for l in open(jsonl) if l.strip()]
except FileNotFoundError:
    print("JSONL de fumaça ausente — aborto. Sem casos.")
    raise SystemExit(5)
inicio = next((o for o in linhas if o.get("evento") == "inicio"), {})
caso = next((o for o in linhas if o.get("evento") in ("casoIniciado", "casoConcluido")), {})
for k, exp in esperado.items():
    v = inicio.get(k) or caso.get(k)
    print(f"esperado {k}={exp}")
    if not v:
        print(f"binário sem {k} — não é o candidato desta árvore. Causa: carimbo ausente. Sem casos.")
        raise SystemExit(5)
    print(f"binário  {k}={v}")
    if v != exp:
        print(f"divergência de {k}: binário ≠ snapshot desta árvore. Sem casos.")
        raise SystemExit(5)
if esperado["pedidoResponderNasNotasSHA256"] == esperado["pedidoConferenciaNotasSHA256"]:
    print("geração e conferência com o mesmo sha — aborto. Sem casos.")
    raise SystemExit(5)
print("contaGrokLigada=", caso.get("contaGrokLigada"))
print("modeloPadraoGlobal=", caso.get("modeloPadraoGlobal"))
print("motoresDesligados=", caso.get("motoresDesligados"))
saida = caso.get("saida") or {}
if isinstance(saida, dict) and "modelosDisponiveis" in saida:
    print("modelos=", ",".join(saida.get("modelosDisponiveis") or []))
if not caso.get("contaGrokLigada"):
    print("contaGrokLigada=false neste UDID. Aborto antes de gastar. Não peço login.")
    raise SystemExit(4)
PY
ident=$?
if [ "$ident" -eq 5 ]; then exit 5; fi
if [ "$ident" -eq 4 ]; then exit 4; fi
if [ "$ident" -ne 0 ]; then exit "$ident"; fi

echo "[$(hora)] identidade ok; conta ligada. Gastar casos: três inferências novas por caso, sem memo, sem aprovação automática."
rodar sustentacao-notas.jsonl sustentacao-notas-casos.json 10800 || exit $?

python3 - "$OUT/sustentacao-notas.jsonl" "$RAIZ/prova/sustentacao-notas-casos.json" <<'PY'
import json, sys
jsonl, fix = sys.argv[1], sys.argv[2]
linhas = [json.loads(l) for l in open(jsonl) if l.strip()]
lote = json.load(open(fix))
ids = [c["id"] for c in lote["casos"]]
reps = int(lote.get("repeticoes") or 1)
req = {c["id"]: c.get("requisitos") or [] for c in lote["casos"]}
if not any(o.get("evento") == "fim" for o in linhas):
    print("sem evento fim")
    raise SystemExit(3)
faltou = []
for i in ids:
    for r in range(1, reps + 1):
        ok = any(o.get("evento") == "casoConcluido" and o.get("id") == i and o.get("repeticao") == r for o in linhas)
        if not ok:
            faltou.append(f"{i}#{r}")
if faltou:
    print("matriz incompleta:", ", ".join(faltou))
    raise SystemExit(3)
print("--- leitura humana; sem aprovação automática ---")
print("Grok.teto=300s por chamada; caminho = geração + conferência (teto possível 600s, não medido neste script).")
erros = 0
for o in linhas:
    if o.get("evento") != "casoConcluido":
        continue
    i = o.get("id")
    print(f"\n# {i} rep={o.get('repeticao')} dur={o.get('duracaoSegundos')} erro={o.get('erro')}")
    if o.get("erro"):
        erros += 1
    print("contaGrokLigada", o.get("contaGrokLigada"), "modeloPadraoGlobal", o.get("modeloPadraoGlobal"))
    print("chamadasGrok", json.dumps(o.get("chamadasGrok") or [], ensure_ascii=False))
    print("saida", json.dumps(o.get("saida"), ensure_ascii=False))
    print("requisitos:")
    for r in req.get(i, []):
        print(" -", r)
print(f"\ncasos concluídos gravados: {len(ids)*reps}. erros nomeados: {erros}. Critérios acima; nenhuma nota automática.")
if erros:
    raise SystemExit(3)
PY
status=$?
echo "[$(hora)] ENCERRADO. JSONL anterior copiado se existia; não apaguei o caderno."
exit $status
