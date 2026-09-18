#!/usr/bin/env python3
"""Confere o pacote da leva 3 contra o `main` de hoje, sem build e sem simulador.

Imita a regra de `AnaliseLocal.detectarGesto`: ordem do array, primeira regex que
casa vence, a Expressiva só acima de `tetoDoDesabafo`, e a guarda de escrita
pessoal (ADR 06h/06i) antes de tudo. Os léxicos da guarda são LIDOS do Swift, não
copiados — se o código mudar, esta sonda muda junto.

LIMITE DECLARADO: `re` do Python não é `NSRegularExpression` (ICU). Os padrões do
catálogo usam só alternância, grupo, classe, opcional e `\\b`, que se comportam
igual nos dois; ainda assim, a prova que vale é `swift test`. Isto aqui é a sonda
que diz onde olhar.

Uso:  python3 ferramentas/orca/metodos/conferir-leva-3.py
"""
import copy
import json
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[3]
CATALOGO = RAIZ / "Traco/Modelo/Metodos.json"
GUARDA = RAIZ / "Traco/Analise/AnaliseLocal.swift"
PACOTE = RAIZ / "ferramentas/orca/metodos/leva-3-e-fusao.md"

# A linha que o Pré-mortem herda da Inversão (passo 1.3 do pacote).
HERDADA = (
    r"\binvers[ãa]o\b|\bcomo garantir que (isso |ele |ela |o plano )?(falhe|d[êe] errado)\b"
    r"|\bo que evitar\b|\bpior jeito de\b|\bao contr[áa]rio\b"
)

ALCANCE = {
    "fatoContrario": "achei um estudo contra o que eu defendo",
    "ordemDeGrandeza": "nem imagino quanto isso daria",
    "comecariaHoje": "se eu não estivesse nisso, eu começaria hoje?",
    "combinado": "combinei com o joão que ele ia me mandar até sexta",
    "pontoQueDecide": "a gente discordamos sobre o preço e não sai do lugar",
    "oQueSeRepetiu": "olhando os últimos meses, o que eu de fato fiz",
    "regraQueEuFaco": "e se todos fizessem isso",
    # A frase do pacote era "magoei ela ontem e preciso reparar", e ela NÃO
    # chega: `lexicoDoSentimento` tem `mago[aeiou]`, a guarda acende antes do
    # roteador e abaixo do teto manda para o silêncio. O método está inteiro —
    # dez dos onze gatilhos chegam, e os outros estão em OUTRAS_PORTAS. O que
    # estava quebrado era a sonda, e uma sonda que não sonda dá verde falso.
    "reparacao": "como eu reparo isso com ela",
    "verAntesDeNomear": "está na cara que ele não quer fazer",
    "oQueNaoEsta": "o que está faltando nesse relatório",
    "estaBom": "será que está bom assim",
    "porta": "isso não tem volta",
    "transferencia": "funcionou para ele, será que serve para mim",
    "sobrevivente": "o segredo dele foi acordar às cinco",
}

ORFAS = ["o que evitar aqui", "pensar ao contrário", "o pior jeito de fazer isso",
         "inversão", "como garantir que isso falhe"]

# A lista `conhecidos` de `todoRamoDeRegexAlcancaOSeuMetodo`, copiada do teste.
# Cada entrada é um ramo que NÃO chega no próprio método, com o destino real, e
# está declarada lá por um destes dois motivos: regex larga comendo específica
# (desvio herdado, com volta própria) ou a guarda da escrita pessoal calando a
# sonda (ADR 2026-09-06h). Se as duas listas divergirem, o `swift test` grita e
# esta sonda não — por isso ela é sonda, e o teste é a prova.
CONHECIDOS = {
    "steelman|melhor argumento contra|argumento",
    "divergencia|dez ideias|notaPermanente",
    "divergencia|todas as ideias|notaPermanente",
    "colunaEsquerda|engoli|silencio",
    "colunaEsquerda|fiquei calado|silencio",
    "colunaEsquerda|deixei passar|silencio",
    "exameDaNoite|não devia ter feito|silencio",
    "exameDaNoite|não devia ter reagido|silencio",
    "exameDaNoite|não devia ter agido|silencio",
    "exameDaNoite|não devia ter tratado|silencio",
    "exameDaNoite|me arrependi|silencio",
    "exameDaNoite|fui injusto|silencio",
    "exameDaNoite|fui grosso|silencio",
    "exameDaNoite|fui duro demais|silencio",
    "exameDaNoite|fui ríspido|silencio",
    "exameDaNoite|perdi a paciência|silencio",
    "exameDaNoite|perdi a cabeça|silencio",
    # a leva 3
    "fatoContrario|derruba a minha ideia|notaPermanente",
    "fatoContrario|derruba minha ideia|notaPermanente",
    "reparacao|magoei|silencio",
    "porta|se eu me arrepender|silencio",
}

# Os outros gatilhos da `reparacao`: o método é alcançável, a sonda do pacote é que
# não era (conferência de 17/09).
OUTRAS_PORTAS = {
    "reparacao": ["preciso pedir desculpa pelo atraso", "como eu reparo isso com ela",
                  "prejudiquei o time com aquela escolha", "deixei ela na mão na semana passada",
                  "quebrei a confiança dele"],
    "porta": ["isso não tem volta", "dá para desfazer depois"],
}

DESABAFO = ("na reunião com o chefe eu senti uma raiva enorme, doeu ficar ali, fiquei calado "
            "o tempo todo e chorei depois no corredor, foi pesado demais para mim")


def lexico(src, nome):
    """Lê uma constante de léxico do Swift. Em Swift as partes são CONCATENADAS
    com `+`, e cada parte já traz o próprio `|` — juntar com `|` aqui criaria uma
    alternativa vazia, que casa tudo e faz a sonda mentir."""
    i = src.index("static let " + nome + " =")
    j = src.index("\n\n", i)
    return "".join(re.findall(r'#"(.*?)"#', src[i:j], re.S))


class Guarda:
    def __init__(self, src):
        nomes = ["lexicoDoSentimento", "lexicoDoSentimentoNoAutor", "lexicoDoJuizoSobreSi",
                 "lexicoDoNaoAguento", "lexicoDoAtoContraAlguem", "lexicoDaOmissao",
                 "lexicoDeDuplaVida"]
        self.lex = {n: lexico(src, n) for n in nomes}
        for n, p in self.lex.items():
            assert not re.search(p, ""), f"{n} casa a string vazia — a leitura quebrou"
        self.teto = int(re.search(r"tetoDoDesabafo = (\d+)", src).group(1))

    def pessoal(self, texto):
        low = texto.lower()
        for n in ("lexicoDoSentimento", "lexicoDoJuizoSobreSi", "lexicoDoNaoAguento",
                  "lexicoDoAtoContraAlguem"):
            if re.search(self.lex[n], low):
                return True
        if len(texto) > self.teto and re.search(self.lex["lexicoDaOmissao"], low):
            return True
        if not re.search(self.lex["lexicoDeDuplaVida"], low):
            return False
        if re.search(self.lex["lexicoDaOmissao"], low):
            return True
        if re.search(self.lex["lexicoDoSentimentoNoAutor"], low):
            return True
        return len(set(re.findall(self.lex["lexicoDeDuplaVida"], low))) >= 2


def rotear(texto, catalogo, guarda):
    low = texto.lower()
    p = guarda.pessoal(texto)
    for m in catalogo:
        if not m.get("roteamento"):
            continue
        if m["id"] == "expressiva" and len(texto) <= guarda.teto:
            continue
        if p and m["id"] != "expressiva":
            continue
        if any(re.search(r, low) for r in m["roteamento"]):
            return m["id"]
    if p:
        return None
    linhas = [x.strip() for x in texto.splitlines() if x.strip()]
    if len(linhas) >= 3 and all(len(x) < 60 for x in linhas):
        return "destaque"
    return None


def objetos_do_pacote():
    linhas = PACOTE.read_text().split("\n")
    i = linhas.index("## O array, pronto para colar")
    j = next(k for k, l in enumerate(linhas) if l.startswith("## Encadeamentos"))
    bloco = re.search(r"```json\n(.*?)\n```", "\n".join(linhas[i:j]), re.S).group(1)
    return json.loads("[" + bloco + "]")


def main():
    atuais = json.loads(CATALOGO.read_text())
    novos = objetos_do_pacote()
    guarda = Guarda(GUARDA.read_text())
    falhas = []

    # Dois modos, e o script escolhe sozinho: ANTES da colagem ele simula o
    # catálogo final; DEPOIS ele confere o que está no disco, que é o que o app
    # vai carregar. O mesmo arquivo serve para decidir se cola e para provar que
    # a colagem ficou de pé.
    colado = "inversao" not in {m["id"] for m in atuais}
    if colado:
        final = atuais
        print(f"modo: DEPOIS da colagem — conferindo o catálogo no disco ({len(final)} métodos)\n")
    else:
        final = []
        for m in atuais:
            if m["id"] == "inversao":
                continue
            m = copy.deepcopy(m)
            if m["id"] == "premortem":
                m["roteamento"] = m.get("roteamento", []) + [HERDADA]
            final.append(m)
        final += novos
        print(f"modo: ANTES da colagem — simulando "
              f"({len(atuais)} no disco · {len(novos)} no pacote · {len(final)} no fim)\n")

    if colado:
        faltam = sorted({m["id"] for m in novos} - {m["id"] for m in final})
        print(f"[{'ok' if not faltam else 'XX'}] os catorze do pacote no catálogo: "
              f"{'todos' if not faltam else 'faltam ' + ', '.join(faltam)}")
        if faltam:
            falhas.append("método do pacote fora do catálogo")
        pm = next(m for m in final if m["id"] == "premortem")
        herdou = any(HERDADA == r for r in pm.get("roteamento", []))
        print(f"[{'ok' if herdou else 'XX'}] o Pré-mortem herdou a regex da Inversão: {herdou}")
        if not herdou:
            falhas.append("herança")
    else:
        colisao = sorted({m["id"] for m in atuais} & {m["id"] for m in novos})
        print(f"[{'ok' if not colisao else 'XX'}] colisão de id: {colisao or 'nenhuma'}")
        if colisao:
            falhas.append("colisão de id")

    vivos = {m["id"] for m in final}
    mortos = [(m["id"], e["para"]) for m in final for e in m.get("encadeamentos", [])
              if e.get("para") and e["para"] not in vivos]
    print(f"[{'ok' if not mortos else 'XX'}] encadeamento para id inexistente: {mortos or 'nenhum'}")
    if mortos:
        falhas.append("encadeamento morto")

    ruins = []
    for m in novos:
        campos = {c["id"] for c in m.get("campos", [])}
        for e in m.get("encadeamentos", []):
            ruins += [(m["id"], v) for v in e.get("mapa", {}).values() if v not in campos]
            ruins += [(m["id"], x) for x in e.get("exige", []) if x not in campos]
            if e.get("compromisso") and e["compromisso"]["campo"] not in campos:
                ruins.append((m["id"], e["compromisso"]["campo"]))
    print(f"[{'ok' if not ruins else 'XX'}] mapa/exige/compromisso sem campo: {ruins or 'nenhum'}")
    if ruins:
        falhas.append("campo inexistente")

    print("\n-- a guarda de escrita pessoal (se falhar, PARE a colagem)")
    r = rotear(DESABAFO, final, guarda)
    print(f"[{'ok' if r == 'expressiva' else 'XX'}] o desabafo longo vai para: {r}")
    if r != "expressiva":
        falhas.append("guarda")

    print("\n-- alcance: cada método novo chega em si mesmo")
    erros = [(k, rotear(v, final, guarda)) for k, v in ALCANCE.items()
             if rotear(v, final, guarda) != k]
    for k, achou in erros:
        print(f"[XX] {k}: a frase do pacote vai para {achou or 'ninguém'} — «{ALCANCE[k]}»")
    print(f"[{'ok' if not erros else 'XX'}] alcance {len(ALCANCE) - len(erros)}/{len(ALCANCE)}")
    if erros:
        falhas.append("alcance")

    print("\n-- a herança da Inversão (passo 1.3): as cinco frases órfãs")
    orfas_ruins = [f for f in ORFAS if rotear(f, final, guarda) != "premortem"]
    for f in ORFAS:
        antes = "" if colado else f"{rotear(f, atuais, guarda) or '—'} → "
        print(f"    {antes}{rotear(f, final, guarda) or 'ninguém'}   «{f}»")
    print(f"[{'ok' if not orfas_ruins else 'XX'}] todas no Pré-mortem: "
          f"{'sim' if not orfas_ruins else orfas_ruins}")
    if orfas_ruins:
        falhas.append("herança")

    print("\n-- as frases dos testes vão para onde o teste declara")
    tst = "".join((RAIZ / p).read_text() for p in
                  ("TracoTests/EscritaPessoalTests.swift", "TracoTests/CatalogoTests.swift"))
    frases = re.findall(r'\("([^"]{15,})",\s*"(\w+)"\)', tst)
    frases += re.findall(r'id\("([^"]{15,})"\) == "(\w+)"', tst)
    if colado:
        # Só as frases cujo destino declarado é um método: as de `EscritaPessoal`
        # que declaram a PORTA (e roteiam para a Expressiva ou para o silêncio
        # de propósito) não são comparáveis aqui, e o `swift test` as cobre.
        ids_vivos = {m["id"] for m in final}
        alheias = [(f, e, rotear(f, final, guarda)) for f, e in frases
                   if e in ids_vivos and rotear(f, final, guarda) not in (e, "expressiva", None)]
        for f, e, r in alheias:
            print(f"    {e} declarado, {r} de fato\n      «{f[:95]}»")
        print(f"    {len(frases)} frases, {len(alheias)} divergem do declarado "
              "(a Expressiva e o silêncio não contam: é a guarda fazendo o trabalho dela)")
    else:
        mudam = [(f, rotear(f, atuais, guarda), rotear(f, final, guarda), e) for f, e in frases
                 if rotear(f, atuais, guarda) != rotear(f, final, guarda)]
        for f, a, b, e in mudam:
            print(f"    {a or '—'} → {b or '—'} (o teste espera {e})\n      «{f[:95]}»")
        print(f"    {len(frases)} frases, {len(mudam)} mudam")

    print("\n-- os outros gatilhos dos métodos que a guarda toca")
    for alvo, frases in OUTRAS_PORTAS.items():
        for f in frases:
            achou = rotear(f, final, guarda)
            print(f"    [{'ok' if achou == alvo else 'XX'}] {achou or 'ninguém':<12s} «{f}»")

    print("\n-- todo ramo de regex alcança o seu método (o `conhecidos` do teste)")
    rabo = " " + "." * 140
    total, fora = 0, []
    for m in final:
        for r in m.get("roteamento", []):
            for sonda in de_regex(r):
                total += 1
                chegou = rotear(sonda + rabo, final, guarda) or "silencio"
                if chegou != m["id"]:
                    fora.append(f'{m["id"]}|{sonda}|{chegou}')
    novas = [c for c in fora if c not in CONHECIDOS]
    for c in novas:
        print(f"    {c}")
    print(f"[{'ok' if not novas else 'XX'}] {total} sondas (o teste exige > 250), "
          f"{len(fora)} fora do próprio método, {len(novas)} ainda não declaradas")
    if novas:
        falhas.append("ramo inalcançável não declarado")

    print("\n" + ("FALHOU: " + ", ".join(falhas) if falhas else "tudo verde nesta sonda"))
    return 1 if falhas else 0


def de_regex(padrao):
    """Uma frase por ramo do padrão inteiro.

    Reimplementa `Sondas.deRegex` de `TracoTests/CatalogoTests.swift`, passo a
    passo e de propósito: é o expansor que alimenta
    `todoRamoDeRegexAlcancaOSeuMetodo`, e reproduzi-lo aqui é o que permite
    prever a lista `conhecidos` sem compilar. Se o expansor do Swift mudar, este
    tem de mudar junto — e a contagem de sondas denuncia a divergência.
    """
    saida = []
    for ramo in _alternativas(padrao):
        saida += _frases(ramo)
    return saida


def _frases(ramo):
    saidas = [""]

    def juntar(pedacos):
        nonlocal saidas
        saidas = [a + p for a in saidas for p in pedacos]

    i = 0
    while i < len(ramo):
        c = ramo[i]
        if c == "\\" and i + 1 < len(ramo):
            n = ramo[i + 1]
            i += 2
            if n == "b":
                continue
            if n == "d":
                if i < len(ramo) and ramo[i] == "{":
                    while i < len(ramo) and ramo[i] != "}":
                        i += 1
                    i += 1
                juntar(["7"])
            elif n == "w":
                if i < len(ramo) and ramo[i] in "+*":
                    i += 1
                juntar(["coisa"])
            elif n == "s":
                juntar([" "])
            else:
                juntar([n])
            continue
        if c in "^$":
            i += 1
        elif c == ".":
            i += 1
            if i < len(ramo) and ramo[i] in "*+":
                i += 1
            juntar([" isso "])
        elif c == "(":
            nivel, j, dentro = 1, i + 1, []
            while j < len(ramo) and nivel > 0:
                if ramo[j] == "(":
                    nivel += 1
                if ramo[j] == ")":
                    nivel -= 1
                if nivel > 0:
                    dentro.append(ramo[j])
                j += 1
            i = j
            opcional = i < len(ramo) and ramo[i] in "?*"
            if opcional:
                i += 1
            if dentro and dentro[0] == "?":
                continue                      # (?m), (?i): não é grupo
            if opcional:
                continue                      # ramo sem o opcional
            sub = []
            for p in _alternativas("".join(dentro)):
                sub += _frases(p)
            juntar(sub)
        elif c == "[":
            j, dentro = i + 1, []
            while j < len(ramo) and ramo[j] != "]":
                dentro.append(ramo[j])
                j += 1
            i = j + 1
            if i < len(ramo) and ramo[i] in "?*":
                i += 1
                continue
            juntar([dentro[0] if dentro else "a"])
        else:
            i += 1
            if i < len(ramo) and ramo[i] in "?*":
                i += 1
                continue
            if i < len(ramo) and ramo[i] == "+":
                i += 1
            juntar([c])
    return [s.strip() for s in saidas if s.strip()]


def _alternativas(padrao):
    """Quebra no `|` de nível zero, respeitando grupo, classe e escape."""
    saida, nivel, atual, i = [], 0, "", 0
    while i < len(padrao):
        c = padrao[i]
        if c == "\\":
            atual += padrao[i:i + 2]
            i += 2
            continue
        if c == "[":
            j = padrao.index("]", i)
            atual += padrao[i:j + 1]
            i = j + 1
            continue
        if c == "(":
            nivel += 1
        if c == ")":
            nivel -= 1
        if c == "|" and nivel == 0:
            saida.append(atual)
            atual = ""
            i += 1
            continue
        atual += c
        i += 1
    saida.append(atual)
    return saida


def _sonda(alt):
    """Uma frase literal aproximada da alternativa, para testar contra a guarda."""
    s = re.sub(r"\\b", "", alt)
    s = re.sub(r"\[([^\]])[^\]]*\]", r"\1", s)
    s = s.replace("(?m)", "")
    for _ in range(6):
        s = re.sub(r"\(([^()|]*)\|[^()]*\)\?", "", s)
        s = re.sub(r"\(([^()|]*)\|[^()]*\)", r"\1", s)
        s = re.sub(r"\(([^()]*)\)\?", "", s)
        s = re.sub(r"\(([^()]*)\)", r"\1", s)
    s = s.replace("\\w+", "coisa").replace("\\s*", " ").replace("^", "").replace("$", "")
    return re.sub(r"\s+", " ", re.sub(r"\\", "", s)).strip()


if __name__ == "__main__":
    sys.exit(main())
