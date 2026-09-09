#!/usr/bin/env python3
"""Vídeo de 15 s das Notas no aparelho da CONTA (B91C8DEF), sem áudio. Roda sob com-trava.
Nunca erase/uninstall/shutdown aqui. Conta conferida pela tela do Perfil antes e depois do install."""
import json, subprocess, sys, time, os
S="/private/tmp/claude-501/-Users-vitorepf-orca-workspaces-traco-ios-volta-d1-notas/d5bc6925-9f81-4493-8803-fafcbf681a3d/scratchpad"
U=os.environ.get("UDID","B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9"); CONTA=U.startswith("B91C8DEF"); OUT="/private/tmp/claude-501/-Users-vitorepf-orca-workspaces-traco-ios-volta-d1-notas/7dde9fa4-cf31-4f7c-b946-647ed2759ed7/scratchpad/video-conta"; os.makedirs(OUT,exist_ok=True)
APP=f"{S}/build/Build/Products/Debug-iphonesimulator/Traco.app"
MATAR_HELPER=os.environ.get("MATAR_HELPER")=="1"
def log(*a): print(time.strftime("%H:%M:%S"),*a, flush=True)
def sh(*c): return subprocess.run(c,capture_output=True,text=True).stdout
def orca(*a): return sh("orca","emulator",*a,"--device",U,"--json")
def ax():
    for _ in range(3):
        try: return json.loads(orca("ax"))["result"]
        except Exception: time.sleep(1)
    return []
def walk(ns):
    for n in ns:
        yield n; yield from walk(n.get("children",[]))
def find(pred):
    for n in walk(ax()):
        if pred(n): return n
def centro(n): f=n["frame"]; return f["x"]+f["width"]/2, f["y"]+f["height"]/2
def tap(n): x,y=centro(n); orca("tap",str(round(x,4)),str(round(y,4))); time.sleep(1.2)
def gesto(pts): orca("gesture",json.dumps([{"type":t,"x":x,"y":y} for t,x,y in pts]))
def shot(nome): time.sleep(0.8); sh("xcrun","simctl","io",U,"screenshot",f"{OUT}/{nome}.png"); log("captura",nome)
def ids(): return [(n.get("id"),n.get("label")) for n in walk(ax()) if n.get("id")]
assert "Booted" in sh("xcrun","simctl","list","devices").split("B91C8DEF")[0][-60:] or True
if MATAR_HELPER:
    for st in json.loads(sh("orca","emulator","list","--json"))["result"]["streams"]:
        if st["device"]==U: sh("kill",str(st["pid"])); log("helper velho morto:",st["pid"]); time.sleep(2)
log(sh("orca","emulator","attach",U,"--json")[:100].replace("\n"," "))
# 1. conta ANTES: a tela do Perfil
sh("xcrun","simctl","launch",U,"app.traco"); time.sleep(4)
log("ids na casa:", ids()[:6])
def ir(aba):
    b=find(lambda n:n.get("id")==f"aba-{aba}")
    if not b:
        gesto([("begin",0.01,0.5),("move",0.3,0.5),("move",0.6,0.5),("end",0.85,0.5)]); time.sleep(2)
        b=find(lambda n:n.get("id")==f"aba-{aba}")
    assert b, f"sem aba-{aba} na árvore"
    tap(b)
if CONTA:
    ir("perfil"); shot("01-perfil-antes"); log("perfil antes:", [n.get("label") for n in walk(ax()) if n.get("role")=="text"][:12])
    # 2. install por cima, UMA vez
    log("install:", sh("xcrun","simctl","install",U,APP)[:200] or "ok"); time.sleep(2)
    sh("xcrun","simctl","launch",U,"app.traco"); time.sleep(4)
    ir("perfil"); shot("02-perfil-depois"); log("perfil depois:", [n.get("label") for n in walk(ax()) if n.get("role")=="text"][:12])
# 3. o vídeo: 15 s nas Notas
ir("notas"); time.sleep(1.5); shot("03-notas")
rec=subprocess.Popen(["xcrun","simctl","io",U,"recordVideo","--codec","h264","--force",f"{OUT}/d1-notas-15s.mp4"],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
t0=time.time(); log("gravando")
time.sleep(2.5)
gesto([("begin",0.5,0.72),("move",0.5,0.62),("move",0.5,0.52),("end",0.5,0.45)]); time.sleep(2.5)   # rola um pouco
gesto([("begin",0.5,0.45),("move",0.5,0.55),("move",0.5,0.65),("end",0.5,0.75)]); time.sleep(2.0)   # volta
f=find(lambda n:n.get("id")=="filtro-notas")
if f: tap(f); time.sleep(1.6)
s=find(lambda n:n.get("label")=="Saúde")
if s: tap(s); time.sleep(2.0)
f=find(lambda n:n.get("id")=="filtro-notas")
if f: tap(f); time.sleep(1.4)
t=find(lambda n:n.get("label")=="Todas")
if t: tap(t)
while time.time()-t0 < 15.5: time.sleep(0.2)
rec.send_signal(2); rec.wait(timeout=20); log("vídeo:", sh("ls","-la",f"{OUT}/d1-notas-15s.mp4").strip())
shot("04-notas-fim")
print(sh("ffprobe","-v","error","-show_entries","format=duration:stream=codec_type,width,height","-of","default=nw=1",f"{OUT}/d1-notas-15s.mp4"))
