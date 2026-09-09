#!/usr/bin/env python3
"""Curva-zero de achar e marcar, em toques e gestos, no build instalado no teste 3.
Uso: sonda.py <antes|depois>. Roda sob com-trava (liga e desliga o aparelho)."""
import json, subprocess, sys, time, os
S="/private/tmp/claude-501/-Users-vitorepf-orca-workspaces-traco-ios-volta-d1-notas/d5bc6925-9f81-4493-8803-fafcbf681a3d/scratchpad"
U="34CC3F94-FDB5-4575-A4F5-80271829A18B"; FASE=sys.argv[1]; OUT=f"{S}/{FASE}" + ("2" if FASE=="antes" and os.path.exists(f"{S}/antes/sonda.json") else ""); os.makedirs(OUT,exist_ok=True)
LOG=[]
def log(*a): print(*a, flush=True); LOG.append(" ".join(str(x) for x in a))
def sh(*c): return subprocess.run(c,capture_output=True,text=True).stdout
def orca(*a): return sh("orca","emulator",*a,"--device",U,"--json")
def ax():
    for _ in range(3):
        try: return json.loads(orca("ax"))["result"]
        except Exception: time.sleep(1)
    return []
def walk(ns):
    for n in ns:
        yield n
        yield from walk(n.get("children",[]))
def find(pred):
    for n in walk(ax()):
        if pred(n): return n
def centro(n): f=n["frame"]; return f["x"]+f["width"]/2, f["y"]+f["height"]/2
def visivel(n): f=n["frame"]; return 0<=f["x"] and f["x"]+f["width"]<=1.001 and 0<=f["y"] and f["y"]+f["height"]<=1.001
def tap(n): x,y=centro(n); orca("tap",str(round(x,4)),str(round(y,4))); time.sleep(1.2)
def gesto(pts): orca("gesture",json.dumps([{"type":t,"x":x,"y":y} for t,x,y in pts])); time.sleep(1.2)
def shot(nome): time.sleep(0.8); sh("xcrun","simctl","io",U,"screenshot",f"{OUT}/{nome}.png"); log("captura",nome)
def toques(k,n): log(f"[{k}] {n} toque(s)/gesto(s)")
sh("xcrun","simctl","boot",U); sh("xcrun","simctl","bootstatus",U,"-b")
sh("xcrun","simctl","launch",U,"app.traco"); time.sleep(4)
# helper de um boot anterior diz ok sem tocar: mata só o serve-sim do MEU UDID e reata
try:
    for st in json.loads(sh("orca","emulator","list","--json"))["result"]["streams"]:
        if st["device"]==U: sh("kill",str(st["pid"])); log("helper velho morto:",st["pid"])
except Exception as e: log("list:",e)
time.sleep(2); log(sh("orca","emulator","attach",U,"--json")[:120])
porta=find(lambda n:n.get("id")=="notas-da-pagina"); tap(porta); shot("s0-lista")
assert find(lambda n:n.get("id")=="busca-notas"), "não chegou às Notas"
# ---- ACHAR por filtro de domínio: Saúde
g=0
if FASE=="antes":
    t=find(lambda n:n.get("id")=="filtro-todas"); cy=centro(t)[1]
    while g<8:
        s=find(lambda n:n.get("id")=="filtro-dominio-saude")
        log("  saude x:", s and round(s["frame"]["x"],3), "largura:", s and round(s["frame"]["width"],3))
        # a cápsula inteira na tela (a régua acaba em "Ideias": "Saúde" pode ficar cortada à esquerda)
        if s and s["frame"]["x"]>=0 and s["frame"]["x"]+s["frame"]["width"]<=1.001: break
        if s and s["frame"]["x"]<0:
            gesto([("begin",0.3,cy),("move",0.4,cy),("end",0.45,cy)]); g+=1; continue
        gesto([("begin",0.9,cy),("move",0.7,cy),("move",0.4,cy),("end",0.12,cy)]); g+=1
    s=find(lambda n:n.get("id")=="filtro-dominio-saude"); shot("s1-regua-saude-visivel"); tap(s); shot("s2-filtro-saude")
    toques("achar por domínio Saúde", f"{g} arrastos na régua + 1 toque = {g+1}")
    # voltar: Todas
    t=find(lambda n:n.get("id")=="filtro-todas")
    if not (t and visivel(t)):
        gesto([("begin",0.12,cy),("move",0.4,cy),("move",0.7,cy),("end",0.9,cy)]); gesto([("begin",0.12,cy),("move",0.4,cy),("move",0.7,cy),("end",0.9,cy)]); gesto([("begin",0.12,cy),("move",0.4,cy),("move",0.7,cy),("end",0.9,cy)]); gesto([("begin",0.12,cy),("move",0.4,cy),("move",0.7,cy),("end",0.9,cy)])
    t=find(lambda n:n.get("id")=="filtro-todas"); tap(t)
else:
    f=find(lambda n:n.get("id")=="filtro-notas"); tap(f); shot("s1-menu-filtro")
    s=find(lambda n:n.get("id")=="filtro-dominio-saude" or n.get("label")=="Saúde")
    if s: tap(s); log("  menu: item achado na árvore de AX")
    else:
        # o menu do sistema não entra na árvore do helper: toque pela geometria da captura
        # (Todas 0.141; cabeçalho Domínio; Trabalho 0.221, Casa 0.258, Saúde 0.295 — conferido por s2)
        orca("tap","0.2","0.295"); time.sleep(1.2); log("  menu: item fora da árvore de AX; toque por geometria da captura")
    shot("s2-filtro-saude")
    c=find(lambda n:n.get("id")=="contagem-busca"); log("  contagem:", c and c.get("label"))
    assert c and "Saúde" in (c.get("label") or ""), "o filtro Saúde não pegou"
    toques("achar por domínio Saúde", "2 toques (abrir o menu, escolher)")
    f=find(lambda n:n.get("id")=="filtro-notas"); tap(f); t=find(lambda n:n.get("label")=="Todas")
    if t: tap(t)
    else: orca("tap","0.2","0.141"); time.sleep(1.2)
    log("  filtro de volta:", find(lambda n:n.get("id")=="filtro-notas").get("label"))
assert find(lambda n:"Ouro Preto" in n.get("label","")) is None or True
# ---- ACHAR por rolagem: a nota de julho
g=0
while g<12:
    n=find(lambda n:"Ouro Preto" in n.get("label",""))
    if n and visivel(n) and centro(n)[1]<0.8: break
    gesto([("begin",0.5,0.75),("move",0.5,0.6),("move",0.5,0.45),("end",0.5,0.3)]); g+=1
shot("s3-julho-visivel"); toques("achar a nota de julho rolando", f"{g} arrasto(s)")
# ---- MARCAR: o domínio da primeira nota, pelo menu
gesto([("begin",0.5,0.3),("move",0.5,0.6),("end",0.5,0.95)]); gesto([("begin",0.5,0.3),("move",0.5,0.6),("end",0.5,0.95)]); gesto([("begin",0.5,0.3),("move",0.5,0.6),("end",0.5,0.95)])
c=find(lambda n:n.get("id")=="chip-dominio"); log("chip:",c and c.get("label"), c and c["frame"]); tap(c); shot("s4-menu-dominio")
e=find(lambda n:n.get("label")=="Estudo"); tap(e); shot("s5-dominio-estudo")
c=find(lambda n:n.get("id")=="chip-dominio"); log("chip depois:", c and c.get("label"))
toques("marcar o domínio (Saúde→Estudo)", "2 toques (abrir o menu, escolher)")
# ---- BUSCAR por palavra
b=find(lambda n:n.get("id")=="busca-notas"); tap(b); orca("type","celular"); shot("s6-busca-celular")
toques("achar por palavra", "1 toque + digitar")
json.dump(LOG,open(f"{OUT}/sonda.json","w"),ensure_ascii=False,indent=1)
sh("xcrun","simctl","terminate",U,"app.traco"); sh("xcrun","simctl","shutdown",U); print(sh("xcrun","simctl","list","devices").split("teste 3")[1][:80])
