#!/usr/bin/env python3
"""Semeia o simulador de teste com registros datados de verdade.

Não há como escrever, em 06/09, uma hipótese proposta em junho pela tela: o
simulador não viaja no tempo. Isto escreve NO FORMATO QUE O APP JÁ GRAVA —
mesma tabela, mesmo JSON, mesmo histórico de versões — e nada mais.
"""
import json, sqlite3, uuid, os, datetime, sys

SIM = os.environ.get("SIM_UDID", "").strip()
if not SIM:
    sys.exit("uso: SIM_UDID=<udid do SEU simulador> python3 semear-latencia.py")


def container(qual):
    import subprocess
    saida = subprocess.run(["xcrun", "simctl", "get_app_container", SIM, "app.traco", qual],
                           capture_output=True, text=True).stdout.strip()
    # `groups` devolve "group.app.traco\t<caminho>"
    return saida.split("\t")[-1]


STORE = os.path.join(container("groups"), "Library/Application Support/default.store")
DOCS = os.path.join(container("data"), "Documents")

REF = datetime.datetime(2001, 1, 1, tzinfo=datetime.timezone.utc)
TZ = datetime.timezone(datetime.timedelta(hours=-3))


def t(y, m, d, h=10):
    return (datetime.datetime(y, m, d, h, tzinfo=TZ) - REF).total_seconds()


def iso(y, m, d, h=10):
    return datetime.datetime(y, m, d, h, tzinfo=TZ).isoformat()


def U():
    return str(uuid.uuid4()).upper()


def blob(u):
    return uuid.UUID(u).bytes


def hip(texto, data, avaliadaEm=None, estado="proposta", por="você"):
    h = {"id": U(), "data": data, "texto": texto, "contexto": "", "evidencias": [],
         "estado": estado, "propostaPor": por}
    if avaliadaEm is not None:
        h["avaliadaEm"] = avaliadaEm
        h["avaliadaPor"] = por
    return h


def doc(intencao, hipoteses, encerrado=False):
    i = U()
    return {"formato": 1, "id": i, "apoio": "delegar", "encerrado": encerrado,
            "intencoes": [{"id": U(), "data": hipoteses[0]["data"], "texto": intencao,
                           "resultado": ""}],
            "artefatos": [], "acoes": [], "evidencias": [], "hipoteses": hipoteses,
            "pedidos": []}


TRABALHOS = [
    doc("Apresentar minha ideia em espanhol", [
        # descoberto, 21 dias
        hip("o problema é vocabulário, não pronúncia", t(2026, 6, 12), t(2026, 7, 3), "confirmada"),
        # o registro ANTIGO: avaliado antes de `avaliadaEm` existir (ADR 05r)
        hip("consigo improvisar se souber o roteiro", t(2026, 6, 20), None, "contestada"),
        # aberta hoje
        hip("gravar em voz alta expõe o que eu pulo", t(2026, 9, 2)),
    ]),
    doc("Traduzir o roteiro para o espanhol", [
        hip("15 minutos é longo demais para um take só", t(2026, 7, 10), t(2026, 7, 19), "confirmada"),
        hip("o portunhol aparece quando eu leio, não quando eu falo", t(2026, 8, 14),
            t(2026, 8, 19), "contestada"),
        hip("dá para ensaiar sem roteiro escrito", t(2026, 5, 30)),  # trabalho encerrado
    ], encerrado=True),
    doc("Montar a rotina de estudo da manhã", [
        hip("estudar antes do café rende mais", t(2026, 9, 3), t(2026, 9, 5), "confirmada"),
        hip("preciso de 40 minutos por dia para avançar", t(2026, 6, 1), t(2026, 9, 4), "contestada"),
        hip("três blocos de 5 minutos batem meia hora seguida", t(2026, 8, 25),
            t(2026, 8, 28), "confirmada"),
    ]),
]

# decisões: (campos, criadaEm, versões anteriores)
NOTA_RESPONDIDA = U()
NOTAS = [
    (NOTA_RESPONDIDA,
     {"escolha": "gravar em casa ou alugar estúdio",
      "opcoes": "gravar em casa\nalugar estúdio por hora",
      "criterio": "quanto o áudio atrapalha a atenção de quem assiste",
      "decidido": "gravar em casa com o microfone que já tenho",
      "espero": "áudio bom o bastante para não comentarem; confiro em 30/06/2026",
      "aconteceu": "dois comentaram do eco. resolvi com cobertor na parede.",
      "saldo": "aquém"},
     t(2026, 6, 5), t(2026, 7, 2),
     [(iso(2026, 6, 5, 11), {"escolha": "gravar em casa ou alugar estúdio"}),
      (iso(2026, 7, 2, 21), {"escolha": "gravar em casa ou alugar estúdio",
                             "opcoes": "gravar em casa\nalugar estúdio por hora",
                             "criterio": "quanto o áudio atrapalha a atenção de quem assiste",
                             "decidido": "gravar em casa com o microfone que já tenho",
                             "espero": "áudio bom o bastante para não comentarem; confiro em 30/06/2026",
                             "aconteceu": ""})]),
    (U(),
     {"escolha": "publicar o vídeo ou refazer o roteiro",
      "decidido": "publicar e medir",
      "espero": "20 respostas na primeira semana; confiro em 05/09/2026"},
     t(2026, 8, 20), t(2026, 8, 20), []),
    (U(),
     {"escolha": "estudar sozinho ou com professor",
      "decidido": "professor uma vez por semana",
      "espero": "menos travadas na conversa; confiro em 25/09/2026"},
     t(2026, 9, 4), t(2026, 9, 4), []),
]


def main():
    con = sqlite3.connect(STORE)
    c = con.cursor()
    c.execute("delete from ZNOTA")
    c.execute("delete from ZTRABALHO")
    pk = 0
    for d in TRABALHOS:
        pk += 1
        c.execute("insert into ZTRABALHO (Z_PK,Z_ENT,Z_OPT,ZATUALIZADOEM,ZTITULO,ZUUID,ZCONTEUDOJSON)"
                  " values (?,3,1,?,?,?,?)",
                  (pk, t(2026, 9, 5), d["intencoes"][0]["texto"], blob(d["id"]),
                   json.dumps(d).encode()))
    c.execute("update Z_PRIMARYKEY set Z_MAX=? where Z_ENT=3", (pk,))

    npk = 0
    for u, campos, criada, editada, versoes in NOTAS:
        npk += 1
        c.execute("insert into ZNOTA (Z_PK,Z_ENT,Z_OPT,ZDIADASERIE,ZDOMINIOTRAVADO,"
                  "ZMINUTOSESCRITOS,ZQUEIMADA,ZTRANCADA,ZCRIADAEM,ZEDITADAEM,ZCAMPOSJSON,"
                  "ZDOMINIORAW,ZGESTORAW,ZSENTIDO,ZSERIERAW,ZTEXTO,ZUUID)"
                  " values (?,1,1,0,0,0,0,0,?,?,?,'','decisao','','','',?)",
                  (npk, criada, editada, json.dumps(campos, ensure_ascii=False), blob(u)))
        if versoes:
            d = os.path.join(DOCS, "Traço", "versoes")
            os.makedirs(d, exist_ok=True)
            lista = [{"data": data, "texto": "", "campos": cs} for data, cs in versoes]
            lista.sort(key=lambda v: v["data"], reverse=True)
            with open(os.path.join(d, u.lower() + ".json"), "w") as f:
                json.dump(lista, f, ensure_ascii=False)
    c.execute("update Z_PRIMARYKEY set Z_MAX=? where Z_ENT=1", (npk,))
    con.commit()
    con.close()
    print("trabalhos:", pk, "notas:", npk)


if __name__ == "__main__":
    main()
