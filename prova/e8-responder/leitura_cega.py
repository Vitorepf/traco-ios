"""Monta a leitura cega da E8/responder: as respostas dos dois braços, embaralhadas e sem o modelo.

uso: python3 leitura_cega.py <grok45.jsonl> <grok43.jsonl> <saida-leitura.json> <saida-chave.json>
A chave (item → braço, caso, repetição) fica fora do alcance do leitor; a contagem junta as duas depois.
"""
import json, sys, random
lote = {c["id"]: c for c in json.load(open(__file__.rsplit("/", 1)[0] + "/lote.json"))["casos"]}
itens, chave = [], {}
for braco, arq in (("A", sys.argv[1]), ("B", sys.argv[2])):
    for l in open(arq):
        d = json.loads(l)
        if d.get("evento") != "casoConcluido":
            continue
        c = lote[d["id"]]
        e = c["entrada"]
        material = {k: e[k] for k in ("contexto", "pagina", "gesto", "campos", "vizinhas") if k in e}
        itens.append({"pergunta": e["pergunta"], "material": material, "requisitos": c["requisitos"],
                      "resposta": d.get("saida") if isinstance(d.get("saida"), str) else "", "_k": (braco, d["id"], d["repeticao"])})
random.Random(20260917).shuffle(itens)
saida = []
for i, it in enumerate(itens, 1):
    chave[f"R{i:03d}"] = it.pop("_k")
    saida.append({"item": f"R{i:03d}", **it})
json.dump(saida, open(sys.argv[3], "w"), ensure_ascii=False, indent=1)
json.dump(chave, open(sys.argv[4], "w"), ensure_ascii=False, indent=1)
print(len(saida))
