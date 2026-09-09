#!/usr/bin/env python3
"""Semeia a lista das Notas com um arquivo realista (D1). Mesmo estado no antes e no depois.
Escreve no formato que o app grava (ZNOTA do App Group); colunas lidas do PRAGMA."""
import json, sqlite3, uuid, os, datetime, sys, subprocess
SIM = os.environ.get("SIM_UDID", "").strip()
if not SIM: sys.exit("uso: SIM_UDID=<udid> python3 semear-notas.py")
def container(q):
    s = subprocess.run(["xcrun","simctl","get_app_container",SIM,"app.traco",q],capture_output=True,text=True).stdout.strip()
    return s.split("\t")[-1]
STORE = os.path.join(container("groups"), "Library/Application Support/default.store")
REF = datetime.datetime(2001,1,1,tzinfo=datetime.timezone.utc)
TZ = datetime.timezone(datetime.timedelta(hours=-3))
def t(y,m,d,h=10,mi=0): return (datetime.datetime(y,m,d,h,mi,tzinfo=TZ)-REF).total_seconds()
def U(): return uuid.uuid4().bytes
# (texto, gesto, campos, dominio, origem, criada, minutos, trancada)
N = [
 ("Quero dormir mais cedo esta semana","woop",{"resultado":"acordar sem alarme","obstaculo":"o celular na cama","plano":"se eu pegar o celular, então deixo na cozinha"},"saude","autor",t(2026,9,9,8,10),6,0),
 ("Plano da semana\n\nsegunda: revisar o orçamento\nterça: ligar para o contador","","{}","dinheiro","autor",t(2026,9,9,7,30),3,0),
 ("Se eu abrir o e-mail antes das 9, então fecho e volto ao texto","seEntao",{"se":"abrir o e-mail antes das 9","entao":"fecho e volto ao texto"},"trabalho","autor",t(2026,9,9,6,50),2,0),
 ("conversar com a Ana sobre a viagem de outubro","", "{}","pessoas","autor",t(2026,9,8,19,0),1,0),
 ("Estou desenhando a tabela de rotas do app","woop",{"resultado":"tabela pronta","obstaculo":"reunião longa","plano":"se a reunião passar das 11, então saio"},"trabalho","autor",t(2026,9,7,9,0),8,0),
 ("Resumo do artigo sobre sono e memória\n\nO sono consolida o que foi aprendido no dia; a privação corta a formação de memória.","", "{}","estudo","grokbot",t(2026,9,5,21,0),0,0),
 ("Uma coisa hoje: terminar o capítulo 3","destaque",{"unica":"terminar o capítulo 3"},"estudo","autor",t(2026,9,3,7,0),1,0),
 ("Ideia: um caderno que cobra a volta","", "{}","ideias","autor",t(2026,9,2,23,10),4,0),
 ("O aluguel sobe em janeiro","", "{}","casa","autor",t(2026,9,1,12,0),2,0),
 ("","expressiva",{},"","autor",t(2026,8,30,22,0),12,1),
 ("Correr três vezes por semana","woop",{"resultado":"correr 5 km sem parar","obstaculo":"frio de manhã","plano":"se estiver frio, então corro à tarde"},"saude","autor",t(2026,8,28,6,40),5,0),
 ("Ligar para o dentista","", "{}","saude","autor",t(2026,8,25,10,0),1,0),
 ("Decidir se troco de plano de celular","decisao",{"escolha":"Decidir se troco de plano de celular","opcoes":"ficar\ntrocar para o pré","criterio":"gastar menos de 60 por mês","decidido":"trocar para o pré","espero":"conta menor; confiro em 05/09/2026"},"dinheiro","autor",t(2026,8,22,18,0),7,0),
 ("Proposta para o cliente da padaria","spec",{"problema":"o site não vende","pronto":"pedido pelo WhatsApp em um toque"},"trabalho","autor",t(2026,8,20,15,0),15,0),
 ("Como explicar o projeto para minha mãe","", "{}","pessoas","autor",t(2026,8,14,20,0),6,0),
 ("Atenção é o que se gasta, não tempo","notaPermanente",{"ideia":"atenção é o recurso que se gasta, não tempo","fonte":"Newport"},"estudo","autor",t(2026,8,10,9,0),9,0),
 ("Orçamento da reforma da cozinha","", "{}","casa","autor",t(2026,8,6,11,0),10,0),
 ("Viagem a Ouro Preto","", "{}","pessoas","autor",t(2026,7,19,16,0),3,0),
 ("Aprender a fazer pão de fermentação natural","", "{}","casa","autor",t(2026,7,5,9,30),4,0),
]
con = sqlite3.connect(STORE); c = con.cursor()
ent = c.execute("select Z_ENT from Z_PRIMARYKEY where Z_NAME='Nota'").fetchone()[0]
cols = [r[1] for r in c.execute("pragma table_info(ZNOTA)")]
c.execute("delete from ZNOTA")
pk = 0
for texto,gesto,campos,dom,orig,criada,minutos,tranc in N:
    pk += 1
    row = {"Z_PK":pk,"Z_ENT":ent,"Z_OPT":1,"ZDIADASERIE":0,"ZDOMINIOTRAVADO":0,"ZMINUTOSESCRITOS":minutos,
           "ZQUEIMADA":0,"ZTRANCADA":tranc,"ZCRIADAEM":criada,"ZEDITADAEM":criada,
           "ZCAMPOSJSON":campos if isinstance(campos,str) else json.dumps(campos,ensure_ascii=False),
           "ZDOMINIORAW":dom,"ZGESTORAW":gesto,"ZSENTIDO":"","ZSERIERAW":"","ZTEXTO":texto,"ZUUID":U(),"ZORIGEMRAW":orig}
    faltam = [k for k in row if k not in cols]
    if faltam: print("colunas ausentes no store, ignoradas:", faltam)
    ks = [k for k in row if k in cols]
    c.execute(f"insert into ZNOTA ({','.join(ks)}) values ({','.join('?'*len(ks))})", [row[k] for k in ks])
c.execute("update Z_PRIMARYKEY set Z_MAX=? where Z_ENT=?", (pk, ent))
con.commit(); con.close()
print("notas:", pk, "| colunas:", cols)
