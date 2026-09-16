"""Conta a V2 (precedência) pelo JSONL: as notas esperadas entre as enviadas.

uso: python3 contar_v2.py <jsonl> <corrida>
- entrou: todas as `esperadas` do caso estão em `notasEnviadas` (o controle sem esperadas conta se nenhuma nota
  do caderno for dada como decisão — isso o leitor cego confere; aqui só se registra o que foi enviado)
O uso da nota na resposta e o "não inventa" do controle ficam com o leitor cego (leitura-v2.md).
"""
import json, sys, collections, statistics

jsonl, corrida = sys.argv[1], sys.argv[2]
casos = {c["id"]: c for c in json.load(open(__file__.rsplit("/", 1)[0] + "/precedencia-casos.json"))}
placar = collections.defaultdict(collections.Counter)
linhas, duracoes = [], []
for linha in open(jsonl):
    if corrida not in linha:
        continue
    d = json.loads(linha)
    if d.get("evento") != "casoConcluido":
        continue
    s = d.get("saida") or {}
    esperadas = set(casos[d["id"]]["esperadas"])
    enviadas = set(s.get("notasEnviadas", []))
    entrou = esperadas <= enviadas and "erro" not in d
    p = placar[d["repeticao"]]
    p["casos"] += 1
    p["entrou"] += entrou
    p["erro"] += "erro" in d
    duracoes.append(float(d.get("duracaoSegundos", 0)))
    linhas.append(f"rep {d['repeticao']} {d['id']}: esperadas {sorted(esperadas)} enviadas {sorted(enviadas)} "
                  f"candidatas {s.get('candidatasDoAutor')} {'ok' if entrou else 'FALTA'} {str(d.get('erro', ''))[-40:]}")
for rep in sorted(placar):
    print(f"repetição {rep}: " + ", ".join(f"{k} {v}" for k, v in placar[rep].items()))
if duracoes:
    print(f"duração por caso: mediana {statistics.median(duracoes):.1f} s, pior {max(duracoes):.1f} s")
print("\n".join(linhas))
