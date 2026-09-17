"""Conta a remedida da E7 pelo JSONL: vazias, tamanho do pedido, catálogo, retrato e o que ficou fora.

uso: python3 contar_e7.py <avaliacoes.jsonl> <corrida>
A 16i conta `prova/16i/contar.py`; a precedência, `prova/16k/contar_v2.py` (ids fora do lote dela são pulados aqui).
"""
import json, sys, collections, statistics

jsonl, corrida = sys.argv[1], sys.argv[2]
casos = [json.loads(l) for l in open(jsonl) if corrida in l]
casos = [c for c in casos if c.get("evento") == "casoConcluido"]
por_rep = collections.defaultdict(collections.Counter)
tamanhos = collections.defaultdict(list)
fora = collections.Counter()
for c in casos:
    s = c.get("saida") or {}
    r = por_rep[c["repeticao"]]
    r["casos"] += 1
    r["erro"] += "erro" in c
    r["vazia"] += not (s.get("texto") or "").strip()
    r["catalogoFoi"] += bool(s.get("catalogoFoi"))
    r["retratoFoi"] += (s.get("retratoChars") or 0) > 0
    for k in ("pacoteChars", "pacoteCharsInteiros", "pacoteCharsPelaPergunta", "retratoChars", "retratoCompletoChars"):
        if isinstance(s.get(k), int) and s[k] >= 0:
            tamanhos[k].append(s[k])
    for f in s.get("foraDoPacote") or []:
        fora[f] += 1
for rep in sorted(por_rep):
    print(f"repetição {rep}: " + ", ".join(f"{k} {v}" for k, v in por_rep[rep].items()))
for k, v in tamanhos.items():
    print(f"{k}: média {statistics.mean(v):.0f}, mediana {statistics.median(v):.0f}, n {len(v)}")
if tamanhos["pacoteCharsInteiros"] and tamanhos["pacoteCharsPelaPergunta"]:
    a, d = statistics.mean(tamanhos["pacoteCharsInteiros"]), statistics.mean(tamanhos["pacoteCharsPelaPergunta"])
    print(f"pedido médio: inteiros {a:.0f} → pela pergunta {d:.0f} ({(d - a) / a:+.1%})")
print("fora do pacote:", dict(fora) or "nada")
