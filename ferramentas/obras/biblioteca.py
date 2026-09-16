#!/usr/bin/env python3
"""A biblioteca de regras conferidas (ADR 2026-09-16b).

Lê `regras.json` (a curadoria: qual frase de qual seção de qual dossiê), confere
cada regra contra o dossiê e contra a fala do vídeo, e escreve um `.md` por
mestre em `biblioteca/`, com `origem: obra` no cabeçalho — o app importa como
obra, fora da voz do autor e fora da lista de Notas.

Nada aqui gera texto. Regra, condição e caso são TRECHOS LITERAIS do dossiê; o
script só recorta, confere e carimba minuto e data vindos do próprio vídeo.

Portões (uma regra que falha em qualquer um não entra, e o script sai 1):
  literal     regra/condição/caso existem na seção citada do dossiê
  duplicação  a mesma regra (ou quase: Jaccard ≥ 0,6) não entra duas vezes
  inglês cru  o texto não é inglês colado (palavras funcionais inglesas)
  instrução   nem o texto nem a seção trazem instrução vazada ("Densificar…")
  corrompido  nenhum caractere fora do alfabeto latino colado no texto ("já投i")
  link        o link da seção é um vídeo, o título bate e a âncora está na fala
  conta       número de multiplicação/percentual declara a conta, e ela fecha
  saúde       afirmação de saúde tem etiqueta `saúde` e é atribuída, não fato
  tamanho     a seção inteira cabe em 1.000 caracteres
  total       50 a 100 regras, dos dois mestres

Uso:
  python3 biblioteca.py --checar            confere e diz o que caiu
  python3 biblioteca.py --gerar             confere e escreve biblioteca/*.md
  python3 biblioteca.py --sortear 10 [N]    sorteia regras com a fonte ao lado
  python3 biblioteca.py --autoteste         os portões contra casos conhecidos
  REGRAS=outro.json python3 biblioteca.py --checar   confere outro arquivo de curadoria

A fala vem do `yt-dlp` (legenda automática em inglês, com tempo por palavra) e
fica em cache fora do repositório (~/Library/Caches/traco-obras).
"""
import ast
import datetime
import json
import operator
import os
import random
import re
import subprocess
import sys
import time
import unicodedata
from pathlib import Path

AQUI = Path(__file__).resolve().parent
REGRAS = Path(os.environ.get("REGRAS", AQUI / "regras.json"))
SAIDA = AQUI / "biblioteca"
DOSSIES = Path(os.environ.get("DOSSIES", Path.home() / "Desktop/negocios-dossies"))
CACHE = Path(os.environ.get("CACHE_OBRAS", Path.home() / "Library/Caches/traco-obras"))
ETIQUETAS = ("mecanismo", "relato", "crença", "saúde")
NEGA = re.compile(r"\b(n[ãa]o|nunca|jamais|nem|sem)\s*[\"'(]?\s*$", re.I)
TETO_SECAO = 1000
PAUSA = float(os.environ.get("PAUSA_YT", "3"))  # segundos entre vídeos fora do cache


# --- texto

def normal(s: str) -> str:
    s = unicodedata.normalize("NFC", s)
    s = s.replace("**", "").replace("*", "")
    for a, b in (("“", '"'), ("”", '"'), ("‘", "'"), ("’", "'"), ("–", "-"), ("—", "-")):
        s = s.replace(a, b)
    return re.sub(r"\s+", " ", s).strip()


def limpo(s: str) -> str:
    """Para ESCREVER: tira só a ênfase e o espaço repetido; aspas e travessões ficam."""
    return re.sub(r"\s+", " ", unicodedata.normalize("NFC", s).replace("**", "").replace("*", "")).strip()


def palavras(s: str):
    return re.findall(r"[a-zà-ÿ0-9]+", normal(s).lower())


def secoes(dossie: Path) -> dict:
    """número → {titulo, link, corpo} de um dossiê `## N. Título\\nlink\\n\\ncorpo`."""
    texto = dossie.read_text(encoding="utf-8")
    saida = {}
    partes = re.split(r"(?m)^## (\d+)\. (.*)$", texto)
    for i in range(1, len(partes), 3):
        numero, titulo, resto = int(partes[i]), partes[i + 1].strip(), partes[i + 2]
        linhas = resto.strip().splitlines()
        link = linhas[0].strip() if linhas else ""
        saida[numero] = {"titulo": titulo, "link": link, "corpo": "\n".join(linhas[1:]).strip()}
    return saida


# --- a fala do vídeo

def id_do_link(link: str):
    m = re.fullmatch(r"https://www\.youtube\.com/watch\?v=([A-Za-z0-9_-]{11})", link)
    return m.group(1) if m else None


def fala(video: str) -> dict:
    """{titulo, data, palavras: [(ms, palavra)]} do vídeo, com cache."""
    CACHE.mkdir(parents=True, exist_ok=True)
    arq = CACHE / f"{video}.json"
    if arq.exists():
        return json.loads(arq.read_text(encoding="utf-8"))
    pasta = CACHE / "tmp"
    pasta.mkdir(exist_ok=True)
    url = f"https://www.youtube.com/watch?v={video}"
    # sem cookies nem conta de ninguém; uma pausa entre vídeos e, no 429, para
    time.sleep(PAUSA)
    meta = subprocess.run(
        ["yt-dlp", "--no-update", "--skip-download", "--write-auto-subs", "--sub-langs", "en", "--sub-format", "json3",
         "--print", "%(upload_date)s\t%(title)s", "--no-simulate", "-o", str(pasta / "%(id)s.%(ext)s"), url],
        capture_output=True, text=True, timeout=180)
    if "429" in meta.stderr or "Too Many Requests" in meta.stderr:
        raise SystemExit(f"YouTube devolveu 429 em {video}: parei. Tente de novo mais tarde; nada foi gravado.")
    linha = next((l for l in meta.stdout.splitlines() if "\t" in l), "")
    data, _, titulo = linha.partition("\t")
    legenda = pasta / f"{video}.en.json3"
    pal = []
    if legenda.exists():
        for ev in json.loads(legenda.read_text(encoding="utf-8")).get("events", []):
            base = ev.get("tStartMs", 0)
            for seg in ev.get("segs", []):
                for p in palavras(seg.get("utf8", "")):
                    pal.append((base + seg.get("tOffsetMs", 0), p))
        legenda.unlink()
    d = {"titulo": titulo.strip(), "data": data.strip(), "palavras": pal}
    if d["data"] and pal:  # só guarda o que veio inteiro
        arq.write_text(json.dumps(d), encoding="utf-8")
    return d


def achar_ancora(pal, ancora: str, janela: int = 25):
    """Primeiro ms em que as palavras da âncora aparecem em ordem numa janela."""
    alvo = palavras(ancora)
    if not alvo or not pal:
        return None
    so = [p for _, p in pal]
    for i, p in enumerate(so):
        if p != alvo[0]:
            continue
        j, k = i + 1, 1
        while k < len(alvo) and j < min(len(so), i + janela):
            if so[j] == alvo[k]:
                k += 1
            j += 1
        if k == len(alvo):
            return pal[i][0]
    return None


def minuto(ms: int) -> str:
    s = ms // 1000
    return f"{s // 3600}:{s // 60 % 60:02d}:{s % 60:02d}" if s >= 3600 else f"{s // 60}:{s % 60:02d}"


# --- portões

INGLES = set("the and you your is are that this it for with what if be have will can they we not how than get "
             "make when just don't doesn't i'm it's there their would should could about because which who".split())
INSTRUCAO = re.compile(r"densific|ignore (as|all|previous|the)|instru[cç][õoã]|system prompt|\bprompt\b|"
                       r"voc[eê] [ée] (um|uma) (assistente|modelo)|responda (apenas|s[oó])|as an ai|reescreva|"
                       # a nota do pipeline que resumiu o vídeo, vazada no dossiê (Hormozi §114–193, §232, §245)
                       r"claims ancorados|nota: a semente|\bajustei\b|sem inventar fora d|\btranscript\b", re.I)
MULTIPLICA = re.compile(r"\bdobr|\btriplic|\bquadruplic|\bmultiplic|\bmetade\b|\b\d+(,\d+)?\s*(x|vezes)\b|\d\s*%|"
                        # "três vezes por semana" e "nove em cada dez vezes" são frequência, não multiplicação
                        r"(?<!cada )\b(duas|tr[eê]s|quatro|cinco|seis|sete|oito|nove|dez|cem|mil) vezes\b(?!\s+(por|ao|na|no|em)\b)|"
                        r"\bo (dobro|triplo)", re.I)
POR_EXTENSO = {2: r"dobr|dobro|duas vezes|metade", 3: r"tripl|tr[eê]s vezes", 4: r"quadrupl|quatro vezes",
               5: r"cinco vezes", 10: r"dez vezes", 0.5: r"metade", 100: r"\bcem\b", 1000: r"\bmil\b"}


def afirmado_no_texto(afirma: float, t: str) -> bool:
    """O valor que o curador declarou está escrito no texto — senão a conta
    fecha sobre outra afirmação e o portão não prova nada."""
    numeros = {float(sinal.replace("−", "-") + n.replace(".", "").replace(",", "."))
               for sinal, n in re.findall(r"([-−]?)(\d+(?:[.,]\d+)*)", t)}
    if any(abs(n - afirma) <= max(0.05 * abs(afirma), 1e-9) for n in numeros):
        return True
    return any(abs(v - afirma) < 1e-9 and re.search(p, t, re.I) for v, p in POR_EXTENSO.items())
SAUDE = re.compile(r"sa[uú]de|saud[aá]v|doen[cç]|\bcura|c[aâ]ncer|dieta|\bsono\b|\bdormi|horm[oô]n|testosteron|"
                   r"suplement|jejum|glicose|insulin|colesterol|\bdor\b|ansiedade|depress|estresse|medica[cç]|"
                   r"rem[eé]dio|emagrec|peso corporal|exerc[ií]cio f[ií]sico", re.I)
# "segundo" só como atribuição ("segundo ele"), nunca o ordinal ("segundo passo")
ATRIBUI = re.compile(r"\b(diz|disse|segundo (ele|ela|o|a)\b|afirma|relata|acredita|conta que|defende|sustenta|"
                     r"na vis[aã]o d)", re.I)

OPS = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul, ast.Div: operator.truediv,
       ast.USub: operator.neg}


def calcular(expr: str) -> float:
    def ev(n):
        if isinstance(n, ast.Expression):
            return ev(n.body)
        if isinstance(n, ast.Constant) and isinstance(n.value, (int, float)):
            return n.value
        if isinstance(n, ast.BinOp) and type(n.op) in OPS:
            return OPS[type(n.op)](ev(n.left), ev(n.right))
        if isinstance(n, ast.UnaryOp) and type(n.op) in OPS:
            return OPS[type(n.op)](ev(n.operand))
        raise ValueError("só aritmética")
    return float(ev(ast.parse(expr, mode="eval")))


ROTULO = re.compile(r"^(A regra é:?|(Regra|Lição|Lei)[^:\n]{0,25}:)\s*")


def regra_escrita(r: dict) -> str:
    """A regra como vai ao arquivo: sem o rótulo do dossiê, maiúscula inicial.
    Os portões de conteúdo leem ESTA — não a que o curador colou."""
    regra = ROTULO.sub("", limpo(r.get("regra", "")))
    return regra[:1].upper() + regra[1:]


def texto_da_regra(r: dict) -> str:
    return " ".join([regra_escrita(r)] + [r.get(c, "") for c in ("condicao", "caso")])


# Palavra de conteúdo inglesa: está no dicionário inglês do macOS, é só ASCII,
# não é palavra portuguesa curta comum e não tem sufixo português.
# ponytail: dicionário local em vez de detector de idioma; erra para o lado de
# acusar ("tempo", "passo"), por isso o teto é 30 % das palavras de 4+ letras.
try:
    DICIONARIO = {w.strip().lower() for w in open("/usr/share/dict/words", encoding="utf-8") if w.strip().isascii()}
except OSError:
    DICIONARIO = set()
PORTUGUES = set("para como quando mais isso essa esse elas eles voce seus suas pelo pela depois mesmo entre sobre "
                "caso regra venda vende preço custo cliente valor time total base plano teste dado fase meta tipo lado "
                "tempo passo nome mesa sabe antes nova sinal carga real site paga cede caro ponto cargo dobra".split())


def ingles_de_conteudo(t: str) -> float:
    ws = [w.lower() for w in re.findall(r"[A-Za-zÀ-ÿ]+", t) if len(w) >= 4]
    if len(ws) < 5 or not DICIONARIO:  # frase curta demais para medir proporção
        return 0.0
    ing = [w for w in ws if w.isascii() and w in DICIONARIO and w not in PORTUGUES
           and not re.search(r"(ar|er|ir|ado|ada|mente|oso|osa|ista|ivo|iva)$", w)]
    return len(ing) / len(ws)


def portoes_locais(r: dict, secao: dict | None) -> list:
    """Os portões que não precisam de rede. Devolve a lista do que caiu."""
    caiu = []
    if secao is None:
        return ["literal: a seção não existe no dossiê"]
    corpo = normal(secao["corpo"])
    for campo in ("regra", "condicao", "caso"):
        v = normal(r.get(campo, ""))
        if campo == "regra" and not v:
            caiu.append("literal: regra vazia")
        elif v and v not in corpo:
            caiu.append(f"literal: {campo} não está na seção {r['secao']}")
        elif v and not any(not NEGA.search(corpo[:m.start()]) for m in re.finditer(re.escape(v), corpo)):
            # "cobre caro" recortado de "Não cobre caro" é o conselho ao contrário
            caiu.append(f"literal: {campo} recortado logo depois de uma negação")
    t = texto_da_regra(r)
    ps = palavras(t)
    inglesas = [p for p in ps if p in INGLES]
    if len(inglesas) >= 2 or (ps and len(inglesas) / len(ps) > 0.08):
        caiu.append(f"inglês cru: {', '.join(inglesas[:5])}")
    elif ingles_de_conteudo(t) >= 0.30:
        caiu.append(f"inglês cru: {ingles_de_conteudo(t):.0%} das palavras são jargão inglês")
    # texto corrompido: escrita fora do alfabeto latino colada no português ("já投i", seção 177 do Lenny)
    if re.search(r"[\u0400-\u04ff\u0590-\u06ff\u0e00-\u0e7f\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af\ufffd]", t):
        caiu.append("texto corrompido: caractere fora do alfabeto latino")
    if INSTRUCAO.search(t) or INSTRUCAO.search(secao["corpo"]) or INSTRUCAO.search(secao["titulo"]):
        caiu.append("instrução vazada no texto ou na seção")
    if r.get("etiqueta") not in ETIQUETAS:
        caiu.append(f"etiqueta fora de {'|'.join(ETIQUETAS)}")
    if MULTIPLICA.search(t):
        conta = r.get("conta")
        if not conta:
            caiu.append("conta: número de multiplicação/percentual sem a conta declarada")
        else:
            try:
                vale = calcular(conta["expressao"])
                afirma = float(conta["afirma"])
                if abs(vale - afirma) > max(0.05 * abs(afirma), 1e-9):
                    caiu.append(f"conta não fecha: {conta['expressao']} = {vale:g}, o texto afirma {afirma:g}")
                elif not afirmado_no_texto(afirma, t):
                    caiu.append(f"conta: o valor afirmado ({afirma:g}) não está escrito no texto")
            except (KeyError, ValueError, SyntaxError, ZeroDivisionError) as e:
                caiu.append(f"conta ilegível: {e}")
    # a atribuição tem de estar NA REGRA escrita: "ele diz" no caso não atribui a regra
    if SAUDE.search(t) and (r.get("etiqueta") != "saúde" or not ATRIBUI.search(regra_escrita(r))):
        caiu.append("saúde como fato: etiqueta `saúde` e atribuição na regra (diz/segundo ele/afirma) obrigatórias")
    elif r.get("etiqueta") == "saúde" and not ATRIBUI.search(regra_escrita(r)):
        caiu.append("saúde como fato: sem atribuição na regra")
    return caiu


def duplicadas(regras: list) -> dict:
    """índice → índice da anterior que ela repete."""
    vistos, saida = [], {}
    for i, r in enumerate(regras):
        a = set(palavras(r.get("regra", "")))
        for j, b in vistos:
            if a and b and len(a & b) / len(a | b) >= 0.6:
                saida[i] = j
                break
        vistos.append((i, a))
    return saida


def parecido(a: str, b: str) -> float:
    x, y = set(palavras(a)), set(palavras(b))
    return len(x & y) / max(1, len(x | y))


def secao_md(n: int, r: dict, sec: dict, f: dict, ms: int) -> str:
    video = id_do_link(sec["link"])
    data = f["data"]
    data = f"{data[:4]}-{data[4:6]}-{data[6:]}" if len(data) == 8 else data
    # o rótulo do dossiê ("Regra operacional:", "A regra é") não se repete sob
    # "Regra:"; "A lição de priorização não é…" fica inteira (o "não" é o conteúdo)
    regra = regra_escrita(r)
    titulo = regra if len(regra) <= 90 else regra[:88].rsplit(" ", 1)[0] + "…"
    linhas = [f"## {n}. {titulo}", f"Regra: {regra}"]
    # a condição é campo do formato: quando a fala não disse, a lacuna fica escrita
    linhas.append(f"Condição: {limpo(r['condicao']) if r.get('condicao') else 'não dita'}")
    if r.get("caso"):
        linhas.append(f"Caso: {limpo(r['caso'])}")
    linhas += [f"Mestre: {r['mestre']}",
               f"Vídeo: {limpo(f.get('titulo') or sec['titulo'])} — https://www.youtube.com/watch?v={video}&t={ms // 1000}s",
               f"Minuto: {minuto(ms)}", f"Data: {data}", f"Etiqueta: {r['etiqueta']}"]
    return "\n".join(linhas)


def conferir(regras: list, com_rede: bool = True):
    """(aprovadas [(regra, seção_md, arquivo)], quedas [(índice, motivos)])."""
    cache_dossie = {}
    dup = duplicadas(regras)
    aprovadas, quedas = [], []
    for i, r in enumerate(regras):
        if r["dossie"] not in cache_dossie:
            cache_dossie[r["dossie"]] = secoes(DOSSIES / r["dossie"])
        sec = cache_dossie[r["dossie"]].get(r["secao"])
        caiu = portoes_locais(r, sec)
        if i in dup:
            caiu.append(f"duplicação: repete a regra {dup[i] + 1}")
        md = None
        if sec is not None and com_rede:
            video = id_do_link(sec["link"])
            if not video:
                caiu.append(f"link: a seção {r['secao']} não aponta um vídeo ({sec['link'][:60]})")
            else:
                f = fala(video)
                if not f["palavras"]:
                    caiu.append("link: o vídeo não tem fala legível")
                elif parecido(f["titulo"], sec["titulo"]) < 0.5:
                    caiu.append(f"link: o título do vídeo ({f['titulo'][:50]}) não é o da seção")
                elif INSTRUCAO.search(f["titulo"]):
                    caiu.append("instrução vazada no título do vídeo")
                else:
                    ms = achar_ancora(f["palavras"], r.get("ancora", ""))
                    if ms is None:
                        caiu.append(f"link: a âncora “{r.get('ancora', '')}” não está na fala do vídeo")
                    else:
                        md = secao_md(0, r, sec, f, ms)
                        if len(md) > TETO_SECAO:
                            caiu.append(f"tamanho: {len(md)} caracteres")
        if caiu:
            quedas.append((i, caiu))
        elif md is not None or not com_rede:
            aprovadas.append((r, md, r["dossie"]))
    return aprovadas, quedas


def arquivo_do_mestre(dossie: str) -> str:
    return dossie.replace("-videos.md", "").replace("-podcast", "") + ".md"


CABECALHO = {"hormozi-videos.md": "Alex Hormozi — regras conferidas",
             "lenny-podcast-videos.md": "Lenny's Podcast — regras conferidas"}


def gerar(aprovadas):
    SAIDA.mkdir(exist_ok=True)
    por_arquivo = {}
    for r, md, dossie in aprovadas:
        por_arquivo.setdefault(dossie, []).append(md)
    criada = "2026-09-16T12:00:00Z"
    for dossie, mds in por_arquivo.items():
        corpo = [re.sub(r"^## 0\.", f"## {n}.", md, count=1) for n, md in enumerate(mds, 1)]
        texto = (f"---\ncriada: {criada}\norigem: obra\n---\n\n# {CABECALHO.get(dossie, dossie)}\n\n"
                 + "\n\n".join(corpo) + "\n")
        (SAIDA / arquivo_do_mestre(dossie)).write_text(texto, encoding="utf-8")
        print(f"biblioteca/{arquivo_do_mestre(dossie)}: {len(mds)} regras")


def principal():
    regras = json.loads(REGRAS.read_text(encoding="utf-8"))
    if "--sortear" in sys.argv:
        i = sys.argv.index("--sortear")
        n = int(sys.argv[i + 1])
        semente = int(sys.argv[i + 2]) if len(sys.argv) > i + 2 else 16
        aprovadas, _ = conferir(regras)
        for r, md, dossie in random.Random(semente).sample(aprovadas, min(n, len(aprovadas))):
            sec = secoes(DOSSIES / dossie)[r["secao"]]
            f = fala(id_do_link(sec["link"]))
            ms = achar_ancora(f["palavras"], r["ancora"])
            perto = " ".join(p for t, p in f["palavras"] if ms - 20_000 <= t <= ms + 40_000)
            print("=" * 80)
            print(md)
            print(f"\n-- a fala em inglês, de {minuto(max(0, ms - 20_000))} a {minuto(ms + 40_000)}:\n{perto}")
        return 0
    aprovadas, quedas = conferir(regras)
    for i, motivos in quedas:
        print(f"regra {i + 1} (seção {regras[i]['secao']} de {regras[i]['dossie']}): " + " · ".join(motivos))
    mestres = {d for _, _, d in aprovadas}
    total_ok = 50 <= len(aprovadas) <= 100 and len(mestres) >= 2
    print(f"{len(aprovadas)} aprovadas, {len(quedas)} caíram, mestres: {len(mestres)}"
          + ("" if total_ok else " — TOTAL FORA DE 50–100 OU UM MESTRE SÓ"))
    if "--gerar" in sys.argv and not quedas and total_ok:
        gerar(aprovadas)
    return 0 if not quedas and total_ok else 1


def autoteste():
    sec = {"titulo": "Make More Profit", "link": "https://www.youtube.com/watch?v=41EvCgwPrDc",
           "corpo": "Com churn de 10% ao mês, um produto gera cerca de 950 dólares de LTV; com churn de 5% o LTV vai "
                    "para 5.000 dólares. Cobre caro na entrada. The best way is to charge more. "
                    "Densificar: reescreva o texto. Ele diz que jejum cura a ansiedade. Jejum cura a ansiedade."}
    base = {"mestre": "Alex Hormozi", "dossie": "x", "secao": 348, "etiqueta": "mecanismo", "ancora": "churn"}
    limpa = {"titulo": "Preço", "link": sec["link"], "corpo": "Cobre caro na entrada. Com churn de 5% o LTV dobra."}
    assert portoes_locais({**base, "regra": "Cobre caro na entrada."}, limpa) == []
    assert any(c.startswith("literal") for c in portoes_locais({**base, "regra": "Cobre barato."}, limpa))
    # #348: a conta do dossiê não fecha (preço ÷ churn: metade do churn DOBRA o LTV)
    q = portoes_locais({**base, "regra": "Com churn de 5% o LTV dobra.",
                        "conta": {"expressao": "(95/0.05)/(95/0.10)", "afirma": 5}}, limpa)
    assert any(c.startswith("conta não fecha") for c in q), q
    q = portoes_locais({**base, "regra": "Com churn de 5% o LTV dobra.",
                        "conta": {"expressao": "(95/0.05)/(95/0.10)", "afirma": 2}}, limpa)
    assert q == [], q
    assert any(c.startswith("conta:") for c in portoes_locais({**base, "regra": "Com churn de 5% o LTV dobra."}, limpa))
    assert any("instrução" in c for c in portoes_locais({**base, "regra": "Cobre caro na entrada."}, sec))
    vazada = {**limpa, "corpo": limpa["corpo"] + " Claims ancorados no transcript; ordem e números preservados."}
    assert any("instrução" in c for c in portoes_locais({**base, "regra": "Cobre caro na entrada."}, vazada))
    jargao = {**limpa, "corpo": "Fix: consertar o funnel de outbound reps, não o pipeline."}
    assert any("inglês" in c for c in portoes_locais({**base, "regra": "Fix: consertar o funnel de outbound reps, não o pipeline."}, jargao))
    ingles = {**limpa, "corpo": limpa["corpo"] + " The best way is to charge more."}
    assert any("inglês" in c for c in portoes_locais({**base, "regra": "The best way is to charge more."}, ingles))
    saude = {**limpa, "corpo": "Ele diz que jejum cura a ansiedade. Jejum cura a ansiedade."}
    assert any("saúde" in c for c in portoes_locais({**base, "regra": "Jejum cura a ansiedade."}, saude))
    assert any("saúde" in c for c in portoes_locais({**base, "etiqueta": "saúde", "regra": "Jejum cura a ansiedade."}, saude))
    assert portoes_locais({**base, "etiqueta": "saúde", "regra": "Ele diz que jejum cura a ansiedade."}, saude) == []
    assert any("corrompido" in c for c in portoes_locais({**base, "regra": "quanto já投i"}, {**limpa, "corpo": "quanto já投i"}))
    assert duplicadas([{"regra": "cobre caro na entrada"}, {"regra": "cobre caro na entrada sempre"}]) == {1: 0}
    assert id_do_link("https://www.youtube.com/watch?v=41EvCgwPrDc") == "41EvCgwPrDc"
    assert id_do_link("https://www.youtube.com/@AlexHormozi") is None
    pal = [(1000, "you"), (2000, "cut"), (2500, "the"), (3000, "churn"), (9000, "in"), (9100, "half")]
    assert achar_ancora(pal, "cut churn in half") == 2000 and achar_ancora(pal, "raise prices") is None
    assert minuto(312_400) == "5:12" and minuto(3_723_000) == "1:02:03"
    assert calcular("(95/0.05)/(95/0.10)") == 2.0
    try:
        calcular("__import__('os')")
        raise AssertionError("expressão não aritmética passou")
    except ValueError:
        pass
    sec_md = secao_md(1, {**base, "regra": "A regra é: foco com guardrails.", "condicao": ""},
                      {**limpa, "titulo": "Preço"}, {"data": "20211004"}, 312_000)
    assert "## 1. Foco com guardrails." in sec_md and "\nCondição: não dita\n" in sec_md, sec_md
    assert "Regra: A lição de priorização não é" in secao_md(1, {**base, "regra": "A lição de priorização não é pequena."},
                                                             limpa, {"data": ""}, 0)
    # revisão E1: rótulo tirado depois do portão, atribuição no caso, ordinal
    saude2 = {**limpa, "corpo": "Lição que ele defende: jejum cura a ansiedade. Ele diz que dormiu mal. Segundo passo: jejum cura a ansiedade."}
    assert any("saúde" in c for c in portoes_locais({**base, "etiqueta": "saúde", "regra": "Lição que ele defende: jejum cura a ansiedade."}, saude2))
    assert any("saúde" in c for c in portoes_locais({**base, "etiqueta": "saúde", "regra": "jejum cura a ansiedade.", "caso": "Ele diz que dormiu mal."}, saude2))
    assert any("saúde" in c for c in portoes_locais({**base, "etiqueta": "saúde", "regra": "Segundo passo: jejum cura a ansiedade."}, saude2))
    negada = {**limpa, "corpo": "Não cobre caro na entrada."}
    assert any("negação" in c for c in portoes_locais({**base, "regra": "cobre caro na entrada."}, negada))
    assert any("não está escrito" in c for c in portoes_locais(
        {**base, "regra": "O LTV triplica.", "conta": {"expressao": "2*1", "afirma": 2}}, {**limpa, "corpo": "O LTV triplica."}))
    assert any(c.startswith("conta:") for c in portoes_locais({**base, "regra": "fica dez vezes maior."}, {**limpa, "corpo": "fica dez vezes maior."}))
    freq = {**limpa, "corpo": "compra três vezes por semana; nove em cada dez vezes é não."}
    assert portoes_locais({**base, "regra": "compra três vezes por semana; nove em cada dez vezes é não."}, freq) == []
    print("autoteste ok")


if __name__ == "__main__":
    if "--autoteste" in sys.argv:
        autoteste()
    else:
        sys.exit(principal())
