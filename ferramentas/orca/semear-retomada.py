#!/usr/bin/env python3
"""Semeia a jornada da R1: "voltei depois de um dia e continuo de onde parei".

Escreve NO FORMATO QUE O APP JÁ GRAVA (ZTRABALHO do App Group, mesmo JSON) o
trabalho de um autor que trabalhou no dia 7 e volta no dia 8. O que ele fez no
dia 7 fica datado no registro; o app é quem sabe o que houve, e a retomada lê
daqui — nada é escrito por modelo.

Uso: SIM_UDID=<udid> python3 ferramentas/orca/semear-retomada.py
"""
import datetime
import json
import os
import subprocess
import sqlite3
import sys
import uuid

SIM = os.environ.get("SIM_UDID", "").strip()
if not SIM:
    sys.exit("uso: SIM_UDID=<udid do SEU simulador> python3 semear-retomada.py")

REF = datetime.datetime(2001, 1, 1, tzinfo=datetime.timezone.utc)
TZ = datetime.timezone(datetime.timedelta(hours=-3))


def t(y, m, d, h=10, mi=0):
    return (datetime.datetime(y, m, d, h, mi, tzinfo=TZ) - REF).total_seconds()


def U():
    return str(uuid.uuid4()).upper()


def blob(u):
    return uuid.UUID(u).bytes


def container(qual):
    saida = subprocess.run(["xcrun", "simctl", "get_app_container", SIM, "app.traco", qual],
                           capture_output=True, text=True).stdout.strip()
    return saida.split("\t")[-1]


INTENCAO = U()
V1, V2 = U(), U()
P1, P2 = U(), U()
ATO_FEITO, ATO_PENDENTE = U(), U()
RELATO = U()

# 05/09: a intenção. 06/09: a primeira versão. 07/09: o dia de trabalho — a
# segunda versão preparada, o ato marcado como realizado, o resultado informado
# e a dificuldade registrada. 08/09: ele volta.
DOC = {
    "formato": 1,
    "id": U(),
    "apoio": "combinar",
    "trechoExercitado": "a abertura de trinta segundos",
    "encerrado": False,
    "intencoes": [{"id": INTENCAO, "data": t(2026, 9, 5, 9),
                   "texto": "Apresentar minha ideia para a diretoria",
                   "resultado": "Explicar a proposta em cinco minutos sem ler o slide"}],
    "pedidos": [
        {"id": P1, "data": t(2026, 9, 6, 11), "instrucao": "Um roteiro de cinco minutos",
         "intencaoID": INTENCAO, "estado": "pronto"},
        {"id": P2, "data": t(2026, 9, 7, 16, 10), "instrucao": "Encurtar a abertura",
         "intencaoID": INTENCAO, "artefatoID": V1, "estado": "pronto"},
    ],
    "artefatos": [
        {"id": V1, "data": t(2026, 9, 6, 11, 30), "conteudo": "# Roteiro\n\nAbertura longa.",
         "formato": "markdown", "origem": "ia", "produtor": "Grok",
         "intencaoID": INTENCAO, "pedidoID": P1},
        {"id": V2, "data": t(2026, 9, 7, 16, 20),
         "conteudo": "# Roteiro\n\nAbertura de trinta segundos e tres blocos.",
         "formato": "markdown", "origem": "ia", "produtor": "Grok",
         "intencaoID": INTENCAO, "anteriorID": V1, "pedidoID": P2},
    ],
    "acoes": [
        {"id": ATO_FEITO, "texto": "Ler a abertura em voz alta para a Ana",
         "responsavel": "pessoa", "artefatoID": V2, "estado": "executada",
         "executadaEm": t(2026, 9, 7, 19, 0)},
        {"id": ATO_PENDENTE, "texto": "Ensaiar os tres blocos com o cronometro",
         "responsavel": "pessoa", "artefatoID": V2, "estado": "pendente",
         "agendadaEm": t(2026, 9, 9, 15, 0), "avisoMinutos": 30},
    ],
    "evidencias": [
        {"id": RELATO, "data": t(2026, 9, 7, 19, 30), "tipo": "relato",
         "texto": "A abertura ficou boa, mas o segundo bloco arrastou e ela perdeu o fio.",
         "atribuidaA": "Você", "acaoID": ATO_FEITO, "artefatoID": V2, "resultado": "parcial"},
    ],
    # DECISOES=1 acrescenta as datas de decisão do contrato da ADR 08y. Sem
    # elas o documento é REGISTRO ANTIGO: o app não sabe quando o apoio foi
    # marcado e cala, em vez de inventar a data.
    **({"apoioMarcadoEm": t(2026, 9, 7, 16, 5),
        "trechoDelimitadoEm": t(2026, 9, 7, 16, 6)}
       if os.environ.get("DECISOES") == "1" else {}),
    "hipoteses": [
        {"id": U(), "data": t(2026, 9, 7, 19, 40),
         "texto": "eu explico o problema duas vezes e o meio fica longo",
         "contexto": "", "evidencias": [RELATO], "estado": "proposta", "propostaPor": "Você"},
    ],
}


def main():
    store = os.path.join(container("groups"), "Library/Application Support/default.store")
    con = sqlite3.connect(store)
    c = con.cursor()
    c.execute("delete from ZTRABALHO")
    c.execute("insert into ZTRABALHO (Z_PK,Z_ENT,Z_OPT,ZATUALIZADOEM,ZTITULO,ZUUID,ZCONTEUDOJSON)"
              " values (1,3,1,?,?,?,?)",
              (t(2026, 9, 7, 19, 40), DOC["intencoes"][0]["texto"], blob(DOC["id"]),
               json.dumps(DOC).encode()))
    c.execute("update Z_PRIMARYKEY set Z_MAX=1 where Z_ENT=3")
    con.commit()
    con.close()

    # A visita anterior, no formato que a folha grava (chave por trabalho).
    # Sem ela o dia 8 seria a PRIMEIRA visita e não haveria "desde então".
    if os.environ.get("VISITA", "1") == "1":
        import plistlib
        prefs = os.path.join(container("data"), "Library/Preferences/app.traco.plist")
        # Escrito no arquivo, e não por `defaults`: o `defaults` do Mac guarda o
        # valor no cfprefsd do HOST e o app lê pelo cfprefsd do SIMULADOR — o
        # arquivo ficava com zero byte e a visita nunca chegava na folha.
        atual = {}
        if os.path.exists(prefs):
            with open(prefs, "rb") as f:
                atual = plistlib.load(f)
        # plistlib grava o instante como UTC e ignora o fuso do objeto: sem
        # converter, a folha exibia 7:00 para uma visita das 10:00.
        atual["trabalho.visita." + DOC["id"]] = (
            datetime.datetime(2026, 9, 7, 10, 0, tzinfo=TZ)
            .astimezone(datetime.timezone.utc).replace(tzinfo=None))
        with open(prefs, "wb") as f:
            plistlib.dump(atual, f)
        subprocess.run(["xcrun", "simctl", "spawn", SIM, "launchctl", "kickstart", "-k",
                        "system/com.apple.cfprefsd.xpc.daemon"], check=True)
    print("trabalho:", DOC["id"])


if __name__ == "__main__":
    main()
