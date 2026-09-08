#!/usr/bin/env python3
"""Planta os widgets do Traço na primeira página da casa escrevendo o
IconState.plist do SpringBoard — a galeria "Adicionar Widget" trava (ESTEIRA),
e este é o caminho que o juiz do G4 abriu na F4.

Uso: f5-plantar.py <UDID> [pares kind:gridSize ...]
Padrão: TracoWidget:small TracoProximo:small TracoWidget:medium TracoProximo:medium
"""
import plistlib, subprocess, sys, uuid, os

UDID = sys.argv[1]
PARES = sys.argv[2:] or ["TracoWidget:small", "TracoProximo:small",
                         "TracoWidget:medium", "TracoProximo:medium"]
CAMINHO = (f"/Users/{os.environ['USER']}/Library/Developer/CoreSimulator/Devices/"
           f"{UDID}/data/Library/SpringBoard/IconState.plist")

with open(CAMINHO, "rb") as f:
    estado = plistlib.load(f)

if not os.path.exists(CAMINHO + ".bak-f5"):
    with open(CAMINHO + ".bak-f5", "wb") as f:
        plistlib.dump(estado, f)

def widget(kind, grid):
    return {
        "allowsExternalSuggestions": True, "allowsSuggestions": True,
        "bundleIdentifier": "app.traco.widget",
        "containerBundleIdentifier": "app.traco",
        "displayIdentifier": str(uuid.uuid4()).upper(),
        "elementType": "widget", "gridSize": grid, "iconType": "custom",
        "uniqueIdentifier": str(uuid.uuid4()).upper(),
        "widgetIdentifier": kind,
    }

estado["iconLists"] = [[widget(*p.split(":")) for p in PARES]] + estado.get("iconLists", [])[1:]

with open(CAMINHO, "wb") as f:
    plistlib.dump(estado, f)

subprocess.run(["xcrun", "simctl", "spawn", UDID, "launchctl", "kill", "9",
                "system/com.apple.SpringBoard"], check=False,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print("plantado:", " ".join(PARES))
