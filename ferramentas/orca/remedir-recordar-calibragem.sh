#!/bin/bash
# Remedição pareada de `recordar` e `calibragem` (Fase 0.2 / itens 9–10).
# NÃO instala. NÃO reabre rota. Fumaça primeiro: se a conta não estiver
# ligada, ou se faltar o carimbo da 11a (porta de um par + régua Lisboa),
# aborta sem gastar e sem fabricar JSONL.
#
# Uso (simulador coordenado, padrão):
#   D=<udid-sim> OUT=/tmp/traco-remedir ./ferramentas/orca/remedir-recordar-calibragem.sh
#
# Uso (iPhone do dono, binário JÁ instalado — sem install):
#   VIA=devicectl D=<identificador-coredevice> OUT=/tmp/traco-remedir \
#     ./ferramentas/orca/remedir-recordar-calibragem.sh
#
# Só fumaça (lê 11a e conta; não gasta a matriz):
#   SO=1 VIA=devicectl D=<identificador-coredevice> OUT=/tmp/traco-id \
#     ./ferramentas/orca/remedir-recordar-calibragem.sh
#
# VIA=devicectl exige D explícito. Não há identificador de iPhone no padrão.
# Só toca os três nomes da sonda. Nunca apaga o conteúdo do container.
#
# O binário já precisa estar no aparelho (Debug, com AvaliacaoIA). A sonda
# grava `bruto` em chamadasGrok e `operacoesLiberadasParaAvaliacao` em cada
# linha. Quem decide volta é a leitura da saída, não este script.
set -u
VIA="${VIA:-simctl}"
SO="${SO:-}"
BID=app.traco
RAIZ="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${OUT:-${1:-}}"
[ -n "$OUT" ] || { echo "OUT=diretorio (ou argumento 1)"; exit 2; }
mkdir -p "$OUT"
FIX=12-recordar-calibragem-casos.json
FUM=q2-fumaca.json
LIB=recordar,calibragem
SONDA_JSONL=avaliacoes-ia.jsonl

case "$VIA" in
  simctl)
    D="${D:-1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF}"
    ;;
  devicectl)
    [ -n "${D:-}" ] || { echo "VIA=devicectl exige D=<identificador do iPhone>"; exit 2; }
    ;;
  *)
    echo "VIA=simctl|devicectl (recebi '$VIA')"
    exit 2
    ;;
esac

hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }

# --- simctl ---

docs_sim() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }

# --- devicectl: só Documents da sonda, nunca o caderno ---

# `copy to` salta arquivo do mesmo tamanho (conteúdo novo não entra).
# Esvaziar antes muda o tamanho e força a cópia. Prova no domínio
# temporário: v1→v2 do mesmo byte não substitui; vazio→v2 substitui.
copy_to_aparelho() { # local remoto-em-Documents
  : > "$OUT/.vazio-envio"
  xcrun devicectl device copy to --device "$D" \
    --domain-type appDataContainer --domain-identifier "$BID" \
    --source "$OUT/.vazio-envio" --destination "Documents/$2" \
    --quiet || true
  xcrun devicectl device copy to --device "$D" \
    --domain-type appDataContainer --domain-identifier "$BID" \
    --source "$1" --destination "Documents/$2" \
    --quiet
}

enviar_fixture() { # local nome-em-Documents
  copy_to_aparelho "$1" "$2" || return 3
  rm -f "$OUT/.fix-volta"
  copy_from_aparelho "$2" "$OUT/.fix-volta" || return 3
  if [ "$(sha "$OUT/.fix-volta")" != "$(sha "$1")" ]; then
    echo "[$(hora)] fixture no Documents não é a desta árvore — aborto. Sem remedição."
    return 7
  fi
}

copy_from_aparelho() { # remoto-em-Documents local
  xcrun devicectl device copy from --device "$D" \
    --domain-type appDataContainer --domain-identifier "$BID" \
    --source "Documents/$1" --destination "$2" \
    --quiet
}

env_sonda() { # fixture liberar modelo
  python3 - "$1" "$2" "$3" <<'PY'
import json, sys
fix, lib, mod = sys.argv[1], sys.argv[2], sys.argv[3]
d = {"TRACO_AVALIAR_IA": fix}
if lib:
    d["TRACO_AVALIAR_LIBERAR"] = lib
if mod:
    d["TRACO_AVALIAR_MODELO"] = mod
print(json.dumps(d, separators=(",", ":")))
PY
}

zerar_jsonl_aparelho() {
  : > "$OUT/.vazio-$SONDA_JSONL"
  copy_to_aparelho "$OUT/.vazio-$SONDA_JSONL" "$SONDA_JSONL" || return 0
  rm -f "$OUT/.jsonl-antes"
  copy_from_aparelho "$SONDA_JSONL" "$OUT/.jsonl-antes" 2>/dev/null || return 0
  if grep -q '"evento":"fim"' "$OUT/.jsonl-antes" 2>/dev/null; then
    echo "[$(hora)] JSONL antigo no Documents — apague só $SONDA_JSONL no Files. Não apago o caderno."
    return 6
  fi
}

limpar_docs() {
  case "$VIA" in
    simctl)
      local DOCS; DOCS="$(docs_sim)"
      rm -f "$DOCS/$SONDA_JSONL" "$DOCS/$FIX" "$DOCS/$FUM" \
            "$DOCS/12-identidade-regua-porta.json"
      ;;
    devicectl)
      : > "$OUT/.vazio-$SONDA_JSONL"
      copy_to_aparelho "$OUT/.vazio-$SONDA_JSONL" "$SONDA_JSONL" 2>/dev/null || true
      # A sonda já apaga a fixture depois do `fim`. Não tento apagar o caderno.
      ;;
  esac
}

encerrar() {
  case "$VIA" in
    simctl) xcrun simctl terminate $D $BID 2>/dev/null || true ;;
    # No iPhone não caço PID: o próximo launch usa --terminate-existing.
    # Encerrar por PID errado é pior que deixar a sonda acabada.
    *) ;;
  esac
}

rodar() { # saida fixture liberar modelo timeout
  local saida="$1" fix="$2" lib="${3:-}" mod="${4:-}" tmo="${5:-600}"
  local src="$RAIZ/prova/$fix"
  [ -f "$src" ] || { echo "fixture ausente: $src"; return 3; }
  echo "[$(hora)] INICIO $saida  via=$VIA fixture=$fix ($(sha "$src" | cut -c1-12)) liberar='$lib' modelo='${mod:-<padrao>}'"

  case "$VIA" in
    simctl)
      local DOCS; DOCS="$(docs_sim)"
      rm -f "$DOCS/$SONDA_JSONL"
      cp "$src" "$DOCS/$fix" || return 3
      local -a MODENV=()
      [ -n "$mod" ] && MODENV=(SIMCTL_CHILD_TRACO_AVALIAR_MODELO="$mod")
      env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
        ${MODENV[@]+"${MODENV[@]}"} \
        xcrun simctl launch --terminate-running-process $D $BID || echo "launch FALHOU"
      local i=0
      while [ $i -lt $((tmo/2)) ]; do
        grep -q '"evento":"fim"' "$DOCS/$SONDA_JSONL" 2>/dev/null && break
        sleep 2; i=$((i+1))
      done
      cp "$DOCS/$SONDA_JSONL" "$OUT/$saida" 2>/dev/null
      ;;
    devicectl)
      zerar_jsonl_aparelho || return $?
      enviar_fixture "$src" "$fix" || return $?
      local ENVJSON
      ENVJSON="$(env_sonda "$fix" "$lib" "$mod")"
      xcrun devicectl device process launch --device "$D" \
        --terminate-existing \
        --environment-variables "$ENVJSON" \
        "$BID" || echo "launch FALHOU"
      local i=0
      while [ $i -lt $((tmo/2)) ]; do
        rm -f "$OUT/$saida"
        copy_from_aparelho "$SONDA_JSONL" "$OUT/$saida" 2>/dev/null || true
        grep -q '"evento":"fim"' "$OUT/$saida" 2>/dev/null && break
        sleep 2; i=$((i+1))
      done
      ;;
  esac
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null)"
}

conta_ligada() {
  python3 - "$1" <<'PY'
import json, sys
p = sys.argv[1]
ligada = False
for line in open(p):
    o = json.loads(line)
    if o.get("evento") == "casoIniciado":
        ligada = bool(o.get("contaGrokLigada"))
        break
print("true" if ligada else "false")
raise SystemExit(0 if ligada else 1)
PY
}

carimbos_11a() {
  python3 - "$1" <<'PY'
import json, sys
porta = None
regua = None
for line in open(sys.argv[1]):
    o = json.loads(line)
    if "portaCalibragemAceitaUmPar" in o or o.get("evento") in ("inicio", "casoIniciado"):
        porta = o.get("portaCalibragemAceitaUmPar", porta)
        regua = o.get("reguaLisboaNaoVaza", regua)
        if porta is not None and regua is not None:
            break
print(f"portaCalibragemAceitaUmPar={porta} reguaLisboaNaoVaza={regua}")
raise SystemExit(0 if porta == "true" and regua == "true" else 1)
PY
}

# --- presença do app: se faltar, NÃO instalo ---

case "$VIA" in
  simctl)
    APP="$(xcrun simctl get_app_container $D $BID 2>/dev/null)" || { echo "app ausente em $D — não instalo"; exit 3; }
    echo "[$(hora)] binario: $(sha "$APP/Traco")"
    echo "[$(hora)] dylib:   $(sha "$APP/Traco.debug.dylib")"
    ;;
  devicectl)
    [ -f "$RAIZ/prova/$FUM" ] || { echo "fixture ausente: $FUM"; exit 3; }
    enviar_fixture "$RAIZ/prova/$FUM" "$FUM" || { echo "app ausente em $D — não instalo"; exit 3; }
    echo "[$(hora)] via=devicectl D=$D — identidade pelo carimbo da fumaça, não pelo sha do .app"
    ;;
esac

rodar fumaca-conta.jsonl "$FUM" "" "" 180
# Os dois portões, nesta ordem: binário velho com conta ligada gastaria.
# Conta desligada não pode esconder que a 11a não está no binário.
if ! carimbos_11a "$OUT/fumaca-conta.jsonl"; then
  echo "[$(hora)] 11a no binário: NÃO — aborto. Sem remedição."
  limpar_docs
  encerrar
  exit 5
fi
echo "[$(hora)] 11a no binário: SIM (porta e régua)"
if ! conta_ligada "$OUT/fumaca-conta.jsonl"; then
  echo "[$(hora)] CONTA DESLIGADA — aborto. Sem remedição, sem JSONL inventado."
  limpar_docs
  encerrar
  exit 4
fi
if [ -n "$SO" ]; then
  echo "[$(hora)] SO=1 — só fumaça. Sem remedição."
  limpar_docs
  encerrar
  exit 0
fi

rodar recordar-calibragem-grok-4.3.jsonl "$FIX" "$LIB" grok-4.3 1800
rodar recordar-calibragem-grok-4.5.jsonl "$FIX" "$LIB" grok-4.5 1800
rodar fumaca-fim.jsonl "$FUM" "" "" 180

limpar_docs
encerrar
echo "[$(hora)] JANELA ENCERRADA (sem instalação)"
