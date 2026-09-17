#!/usr/bin/env python3
"""Mapa do Traço: a documentação conferida contra o código.

Lição do Atlas (análise de 16/09): todo mapa escrito à mão passou a mentir.
Este lê o SPEC.md e a tabela `Politica.swift` e só afirma o que está lá.

    python3 ferramentas/mapa/mapa.py              # escreve ferramentas/mapa/mapa.json
    python3 ferramentas/mapa/mapa.py --conferir   # sai 1 se a documentação desviou
    python3 ferramentas/mapa/mapa.py --pagina     # escreve ferramentas/mapa/mapa.html (ver sem ler)
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
MOTIVO = re.compile(r'motivo:\s*"([^"]*)"')
NOME = re.compile(r'case \.([a-zA-Z]+): "([^"]+)"')

# A ESTRUTURA é escolhida à mão (os seis tipos da VISAO-PRODUTO); o ESTADO sai
# do código. Operação nova sem tipo reprova no --conferir.
TIPOS = [
    ("Caderno", "A página que veste a forma certa", ["vestir", "classificar", "dominio"]),
    ("Segundo cérebro", "A memória que responde e traz de volta", ["responderNasNotas", "ecos", "padroes", "recordar"]),
    ("Biblioteca dos mestres", "A regra certa, com a fonte", ["escolherRegra"]),
    ("Diário de decisões", "O que você esperava contra o que aconteceu", ["conferir", "calibragem"]),
    ("Tutor", "A IA que pergunta e contrapõe", ["responder", "instigar", "contrapor"]),
    ("Fazer", "Trabalho e Calendário", ["produzir", "prepararPratica", "conferirTentativa", "revisar"]),
]
ESTADO = {
    "soGrok": ("com a conta Grok", "conta"),
    "soBordo": ("no aparelho", "aparelho"),
    "grokDepoisBordo": ("aparelho e conta", "aparelho"),
    "indisponivelPorQualidade": ("cortada", "cortada"),
}
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
        mo = MOTIVO.search(texto)
        for op in atuais:
            ops[op] = {"regra": r.group(1) if r else None, "provas": sorted(set(PROVA.findall(texto))),
                       "motivo": mo.group(1) if mo else ""}

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
    tipados = {o for _, _, lista in TIPOS for o in lista}
    for nome in nomes:
        if nome not in tipados:
            achados.append(f"operação .{nome} sem tipo no mapa (ferramentas/mapa/mapa.py, TIPOS)")
    for nome, op in ops.items():
        if nome not in nomes:
            achados.append(f"linha .{nome} na tabela sem operação no enum")
        for p in op["provas"]:
            if not existe(p):
                achados.append(f"operação .{nome} cita prova que não existe: {p}")
    return achados


def pagina(mapa, nomes_legiveis):
    from html import escape
    from datetime import date
    linhas = mapa["operacoes"]["linhas"]
    blocos = []
    for tipo, frase, lista in TIPOS:
        itens = []
        for op in lista:
            l = linhas.get(op)
            if not l:
                continue
            rotulo, classe = ESTADO.get(l["regra"], (l["regra"] or "sem regra", "cortada"))
            motivo = f'<p class="motivo">{escape(l["motivo"][:1].upper() + l["motivo"][1:])}</p>' if l["motivo"] else ""
            itens.append(f'<li><div class="op"><span class="nome">{escape(nomes_legiveis.get(op, op)[:1].upper() + nomes_legiveis.get(op, op)[1:])}</span>'
                         f'<span class="estado {classe}">{escape(rotulo)}</span></div>{motivo}</li>')
        cortadas = sum(1 for op in lista if linhas.get(op, {}).get("regra") == "indisponivelPorQualidade")
        resumo = f'{len(lista) - cortadas} de {len(lista)} funcionando' if lista else ""
        blocos.append(f'<section class="tipo"><header><h2>{escape(tipo)}</h2><p>{escape(frase)}</p><span class="resumo">{resumo}</span></header><ul>{"".join(itens)}</ul></section>')
    desvios = "".join(f"<li>{escape(a)}</li>" for a in mapa["achados"]) or "<li>Nenhum: a documentação bate com o código.</li>"
    return f"""<title>Mapa do Traço</title>
<style>
:root{{--papel:#F4F4F2;--cartao:#FFFFFF;--tinta:#1C1C1E;--suave:#5F5F64;--fraca:#68686C;--linha:rgba(28,28,30,.08);--ambar:#7A5A16;--aviso:#B5432F;--verde:#2F6B3F}}
@media (prefers-color-scheme: dark){{:root:not([data-theme="light"]){{--papel:#131312;--cartao:#1E1E1D;--tinta:#F2F2EF;--suave:#B0B0AB;--fraca:#9A9A95;--linha:rgba(242,242,239,.1);--ambar:#D9A542;--aviso:#E07A66;--verde:#7CC08E}}}}
:root[data-theme="dark"]{{--papel:#131312;--cartao:#1E1E1D;--tinta:#F2F2EF;--suave:#B0B0AB;--fraca:#9A9A95;--linha:rgba(242,242,239,.1);--ambar:#D9A542;--aviso:#E07A66;--verde:#7CC08E}}
*{{box-sizing:border-box}}
body{{margin:0;background:var(--papel);color:var(--tinta);font:15px/1.5 -apple-system,BlinkMacSystemFont,"SF Pro Text",system-ui,sans-serif;-webkit-font-smoothing:antialiased}}
main{{max-width:1080px;margin:0 auto;padding-inline:20px;padding-block:40px 64px}}
h1{{font-size:34px;letter-spacing:-.02em;margin:0 0 6px}}
.sub{{color:var(--suave);margin:0 0 28px;max-width:62ch}}
.grade{{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:12px}}
.tipo{{background:var(--cartao);border-radius:14px;border:.5px solid var(--linha);padding:16px 18px;box-shadow:0 .5px 1px rgba(28,28,30,.05),0 4px 10px rgba(28,28,30,.04)}}
.tipo header{{display:grid;grid-template-columns:1fr auto;align-items:baseline;gap:0 12px;padding-bottom:10px;border-bottom:.5px solid var(--linha)}}
.tipo h2{{font-size:19px;margin:0;letter-spacing:-.01em}}
.tipo header p{{grid-column:1;margin:2px 0 0;color:var(--suave);font-size:14px}}
.resumo{{grid-row:1;grid-column:2;color:var(--fraca);font-size:13px;font-variant-numeric:tabular-nums}}
ul{{list-style:none;margin:0;padding:0}}
li{{padding:10px 0;border-bottom:.5px solid var(--linha)}}
li:last-child{{border-bottom:0;padding-bottom:0}}
.op{{display:flex;flex-wrap:wrap;justify-content:space-between;gap:2px 12px;align-items:baseline}}
.nome{{font-weight:600;flex:1 1 14ch}}
.estado{{font-size:13px;white-space:nowrap}}
.estado.conta{{color:var(--verde)}} .estado.aparelho{{color:var(--suave)}} .estado.cortada{{color:var(--aviso)}}
.motivo{{margin:2px 0 0;color:var(--suave);font-size:14px}}
.rodape{{margin-top:28px;color:var(--fraca);font-size:13px}}
.rodape ul{{margin-top:6px}} .rodape li{{border:0;padding:2px 0}}
</style>
<main>
<h1>Mapa do Traço</h1>
<p class="sub">Os seis tipos de app que o Traço junta e o estado de cada função de IA, lidos direto do código. Nada nesta página é escrito à mão.</p>
<div class="grade">{"".join(blocos)}</div>
<div class="rodape"><strong>Conferência:</strong> {mapa["adrs"]["total"]} decisões no SPEC, {mapa["operacoes"]["total"]} funções de IA. Gerado em {date.today().strftime("%d/%m/%Y")} por ferramentas/mapa/mapa.py.<ul>{desvios}</ul></div>
</main>
"""


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
    assert ops["um"] == {"regra": "soGrok", "provas": ["prova/a.md"], "motivo": ""}, ops
    # a irmã que não acusa: tudo em ordem (as operações do teste não têm tipo; só isso acusa)
    assert [a for a in problemas(adrs(spec), nomes, ops, existe=lambda p: True) if "sem tipo" not in a] == []
    assert any(".um sem tipo" in a for a in problemas(adrs(spec), nomes, ops, existe=lambda p: True))
    # a sonda que acusa: ADR repetida, prova que sumiu, operação sem linha
    ruim = spec + "## ADR 2026-01-01a — de novo\n"
    achados = problemas(adrs(ruim), nomes + ["tres"], ops, existe=lambda p: False)
    assert any("2026-01-01a repetida" in a for a in achados), achados
    assert any("prova/a.md" in a for a in achados), achados
    assert any(".tres sem linha" in a for a in achados), achados
    # a duplicata histórica declarada não acusa
    hist = "## ADR 2026-09-09q — a\n## ADR 2026-09-09q — b\n"
    assert problemas(adrs(hist), [], {}) == []
    assert "<title>" in pagina({"adrs": {"total": 2}, "operacoes": {"total": 0, "linhas": {}}, "achados": []}, {})
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
    nomes_legiveis = dict(NOME.findall(politica[politica.find("static func nome("):]))
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
    if "--pagina" in sys.argv:
        destino = RAIZ / "ferramentas/mapa/mapa.html"
        destino.write_text(pagina(mapa, nomes_legiveis), encoding="utf-8")
        print(f"escrito {destino.relative_to(RAIZ)}")
        return 0
    destino = RAIZ / "ferramentas/mapa/mapa.json"
    destino.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"escrito {destino.relative_to(RAIZ)}: {len(lista)} ADRs, {len(nomes)} operações, {len(achados)} desvio(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
