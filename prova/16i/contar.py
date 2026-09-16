"""Conta a sonda da ADR 2026-09-16i pelo JSONL, não pela memória.

uso: python3 contar.py <avaliacoes.jsonl> <corrida> [gabarito.json]
- certa enviada: a seção do vídeo do gabarito está entre as seções de obra que viajaram
- citada: a resposta traz a Referência com o link desse vídeo (mestre, “vídeo”, minuto)
"""
import json, sys, collections, statistics

jsonl, corrida = sys.argv[1], sys.argv[2]
gab = json.load(open(sys.argv[3] if len(sys.argv) > 3 else __file__.rsplit("/", 1)[0] + "/gabarito.json"))
linhas = [json.loads(l) for l in open(jsonl) if corrida in l]
casos = [l for l in linhas if l.get("evento") == "casoConcluido"]
por_rep = collections.defaultdict(lambda: collections.Counter())
falhas, duracoes = [], []
for c in casos:
    rep, cid = c["repeticao"], c["id"]
    video = gab[cid]
    s = c.get("saida") or {}
    duracoes.append(float(c.get("duracaoSegundos", 0)))
    enviadas = s.get("secoesEnviadas", [])
    certa = any(k.startswith(video + "&") for k in enviadas)
    texto = s.get("texto", "")
    citada = video in texto and "minuto" in texto
    cita_obra = "Referência:" in texto and "minuto" in texto
    r = por_rep[rep]
    r["casos"] += 1
    r["certaEnviada"] += certa
    r["certaCitada"] += certa and citada
    r["citaObraComMinuto"] += cita_obra
    r["viaModelo"] += s.get("viaObra") == "modelo"
    r["erro"] += "erro" in c or not s
    if not certa:
        falhas.append(f"rep {rep} {cid}: via={s.get('viaObra')} enviadas={[k[32:43] for k in enviadas]} erro={c.get('erro', '')[:80]}")
for rep in sorted(por_rep):
    print(f"repetição {rep}: " + ", ".join(f"{k} {v}" for k, v in por_rep[rep].items()))
if duracoes:
    print(f"duração por caso: mediana {statistics.median(duracoes):.1f} s, pior {max(duracoes):.1f} s")
print("\n".join(falhas))
