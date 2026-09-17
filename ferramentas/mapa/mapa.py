#!/usr/bin/env python3
"""Mapa do Traço: a documentação conferida contra o código.

Lição do Atlas (análise de 16/09): todo mapa escrito à mão passou a mentir.
Este lê o SPEC.md e a tabela `Politica.swift` e só afirma o que está lá.

    python3 ferramentas/mapa/mapa.py              # escreve ferramentas/mapa/mapa.json
    python3 ferramentas/mapa/mapa.py --conferir   # sai 1 se a documentação desviou
    python3 ferramentas/mapa/mapa.py --autoteste  # a sonda que acusa e a irmã que não
"""
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]

# Letras que dois ramos reservaram ao mesmo tempo, antes deste conferidor.
# Não se renomeia a história (o código cita as duas pelo mesmo nome); só se
# declara. Uma duplicata NOVA fora desta lista reprova.
DUPLICATAS_HISTORICAS = {
    "2026-09-09q": "Q2-F (comparação pareada) e B2 (a rota que cala) reservaram a mesma letra em ramos paralelos",
}

ADR = re.compile(r"^## ADR (\d{4}-\d{2}-\d{2}[a-z]*) — (.+)$")
CASO = re.compile(r"^\s*case (\.[a-zA-Z]+(?:\s*,\s*\.[a-zA-Z]+)*):\s*$")
REGRA = re.compile(r"regra:\s*\.([a-zA-Z]+)")
PROVA = re.compile(r"\b((?:prova|ferramentas/orca)/[\w./-]*\w)")
ENUM = re.compile(r"enum Operacao[^{]*\{(.*?)\n    \}", re.S)


def adrs(spec: str):
    saida = []
    for n, linha in enumerate(spec.splitlines(), 1):
        m = ADR.match(linha)
        if m:
            saida.append({"id": m.group(1), "titulo": m.group(2).strip(), "linha": n})
    return saida


def operacoes(politica: str):
    enum = ENUM.search(politica)
    nomes = re.findall(r"\b([a-z][a-zA-Z]+)\b", enum.group(1).replace("case", "")) if enum else []
    inicio = politica.find("static func linha(")
    corpo = politica[inicio:]
    fim = corpo.find("\n    }\n")
    corpo = corpo[: fim if fim > 0 else len(corpo)]
    ops, atuais, bloco = {}, [], []

    def fechar():
        texto = "\n".join(bloco)
        r = REGRA.search(texto)
        for op in atuais:
            ops[op] = {"regra": r.group(1) if r else None, "provas": sorted(set(PROVA.findall(texto)))}

    for linha in corpo.splitlines():
        m = CASO.match(linha)
        if m:
            if atuais:
                fechar()
            atuais = [c.strip().lstrip(".") for c in m.group(1).split(",")]
            bloco = []
        elif atuais:
            bloco.append(linha)
    if atuais:
        fechar()
    return nomes, ops


def problemas(lista_adrs, nomes, ops, existe=lambda p: (RAIZ / p).exists()):
    achados = []
    vistos = {}
    for a in lista_adrs:
        if a["id"] in vistos and a["id"] not in DUPLICATAS_HISTORICAS:
            achados.append(f"ADR {a['id']} repetida (linhas {vistos[a['id']]} e {a['linha']})")
        vistos.setdefault(a["id"], a["linha"])
    for nome in nomes:
        if nome not in ops:
            achados.append(f"operação .{nome} sem linha na tabela da Politica")
        elif not ops[nome]["regra"]:
            achados.append(f"operação .{nome} sem regra")
    for nome, op in ops.items():
        if nome not in nomes:
            achados.append(f"linha .{nome} na tabela sem operação no enum")
        for p in op["provas"]:
            if not existe(p):
                achados.append(f"operação .{nome} cita prova que não existe: {p}")
    return achados


def autoteste():
    spec = "## ADR 2026-01-01a — um\n\n## ADR 2026-01-01b — dois\n"
    politica = (
        "    enum Operacao: String {\n        case um, dois\n    }\n"
        "    static func linha(_ op: Operacao) -> Linha {\n        switch op {\n"
        "        case .um:\n            .init(regra: .soGrok, porque: \"medido — prova/a.md\")\n"
        "        case .dois:\n            .init(regra: .soBordo, porque: \"ok\")\n"
        "        }\n    }\n"
    )
    nomes, ops = operacoes(politica)
    assert nomes == ["um", "dois"], nomes
    assert ops["um"] == {"regra": "soGrok", "provas": ["prova/a.md"]}, ops
    # a irmã que não acusa: tudo em ordem
    assert problemas(adrs(spec), nomes, ops, existe=lambda p: True) == []
    # a sonda que acusa: ADR repetida, prova que sumiu, operação sem linha
    ruim = spec + "## ADR 2026-01-01a — de novo\n"
    achados = problemas(adrs(ruim), nomes + ["tres"], ops, existe=lambda p: False)
    assert any("2026-01-01a repetida" in a for a in achados), achados
    assert any("prova/a.md" in a for a in achados), achados
    assert any(".tres sem linha" in a for a in achados), achados
    # a duplicata histórica declarada não acusa
    hist = "## ADR 2026-09-09q — a\n## ADR 2026-09-09q — b\n"
    assert problemas(adrs(hist), [], {}) == []
    print("autoteste ok")


def main():
    if "--autoteste" in sys.argv:
        autoteste()
        return 0
    spec = (RAIZ / "SPEC.md").read_text(encoding="utf-8")
    politica = (RAIZ / "Traco/Analise/Politica.swift").read_text(encoding="utf-8")
    lista, (nomes, ops) = adrs(spec), operacoes(politica)
    achados = problemas(lista, nomes, ops)
    por_regra = {}
    for nome, op in ops.items():
        por_regra.setdefault(op["regra"], []).append(nome)
    mapa = {
        "adrs": {"total": len(lista), "duplicatas_historicas": DUPLICATAS_HISTORICAS},
        "operacoes": {"total": len(nomes), "por_regra": {k: sorted(v) for k, v in sorted(por_regra.items())}, "linhas": ops},
        "achados": achados,
    }
    if "--conferir" in sys.argv:
        for a in achados:
            print("✘", a)
        print(f"{len(lista)} ADRs, {len(nomes)} operações, {len(achados)} desvio(s)")
        return 1 if achados else 0
    destino = RAIZ / "ferramentas/mapa/mapa.json"
    destino.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"escrito {destino.relative_to(RAIZ)}: {len(lista)} ADRs, {len(nomes)} operações, {len(achados)} desvio(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
