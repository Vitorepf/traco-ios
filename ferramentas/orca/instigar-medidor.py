#!/usr/bin/env python3
"""LOTE-INSTIGAR (volta INSTIGAR) — SÓ as colunas que esta volta acrescenta.

As guardas comparáveis continuam sendo `lote-ia-09c-guardas.py` e
`lote-ia-09e-q4c.py`, que NÃO mudam: mudar o instrumento faz o LOTE-3, o LOTE-5
e o LOTE-INSTIGAR deixarem de se comparar.

Duas colunas novas, e as duas correm TAMBÉM sobre a base — régua nova que só
corre no candidato sempre "descobre" que o passado era melhor:

  1. ANCORADAS pergunta a pergunta (o relatório da Q4-C tinha esta tabela e não
     tinha o código dela). Sai POR CASO. Média entre casos esconde o caso que
     foi a zero, então a média vem depois da lista e nunca no lugar dela.
  2. O CASO CEGO do `instigar`, pelos dois polos: pergunta que a nota JÁ
     RESPONDEU ou JÁ NEGOU, e recusa covarde (vazio / menos de duas).

Uso: instigar-medidor.py <fixture.json> <jsonl...>
     instigar-medidor.py --vigia <fixture.json>   (prova que o vigia enxerga)
"""
import json, re, sys, collections, unicodedata

CEGOS = ('revisor-instigar-nota-que-ja-responde', 'revisor-instigar-fatos-negados')

# As regexes do `lote-ia-09e-q4c.py`, copiadas por VALOR de propósito: importar
# dele amarraria os dois instrumentos, e o dele é o que não pode mudar.
#
# `QUANDO` é a única que sai MAIS ESTREITA aqui, e o vigia é quem cobrou: o
# `\bquando\b` solto do 09e casa com a conjunção — "O que muda QUANDO você põe
# essa palavra?" não pergunta quando coisa nenhuma. No 09e isso não faz mal
# (lá a coluna só conta se ALGUMA pergunta pede o quando, e o falso positivo
# ajudaria o candidato); aqui ele REPROVA um caso cego, e falso positivo que
# reprova é o pior tipo. Só conta o `quando` que interroga.
QUANDO = re.compile(r'(?:^|[—–\-:;,?!(]\s*)[«"“\'(]*\s*quando\b|'      # "Quando …?" / "— quando …?"
                    r'\b(?:desde|at[ée]|para|de|em) quando\b|'          # "desde quando", "até quando"
                    r'\bfoi quando\b|'                                  # "…foi quando?"
                    r'\bque dia\b|\bque hora\b|em que momento|'
                    r'\bque semana\b|\bque m[êe]s\b|h[áa] quanto tempo', re.I)
DARCERTO = re.compile(r'dar certo|daria certo|deu certo|ficaria diferente|seria .{0,12}sucesso', re.I)
# estreita de propósito: o `OQUE` do 09e casa com "qual", que é meia língua.
# aqui só o gabarito nu — "o que aconteceu?", "o que houve?".
OQUEACONTECEU = re.compile(r'o que (foi que )?(aconteceu|houve|se passou)', re.I)
CAUSA = re.compile(r'\bpor qu[êe]\b|por causa de qu|o que causou|qual (foi )?o motivo', re.I)

VAZIAS = {'que','qual','quais','como','quando','onde','porque','para','pelo','pela','sobre',
          'seria','aconteceu','voce','seu','sua','isso','esse','essa','mais','menos','entre',
          'ainda','tem','ter','foi','era','dar','certo','nao','sim','com','sem','uma','uns',
          'dos','das','nos','nas','por','mas','dele','dela'}

def dobra(t):
    return ''.join(c for c in unicodedata.normalize('NFD', t.lower()) if unicodedata.category(c) != 'Mn')

def conteudo(t):
    return {w for w in re.findall(r'[a-z0-9]{4,}', dobra(t)) if w not in VAZIAS}

# O caso da nota magra não tem palavra de conteúdo: ali GENÉRICA é o desfecho
# certo e a coluna não se lê. Mesma exceção do `lote-ia-09e-q4c.py`.
SEM_MATERIA = ('q4-instigar-texto-magro', 'revisor-instigar-fatos-negados')


def letra(fixture):
    """A fixture manda, e este conferidor QUEBRA se ela perder a letra que ele lê."""
    casos = {c['id']: c for c in json.load(open(fixture))['casos']}
    for cid in CEGOS:
        c = casos.get(cid)
        if c is None:
            sys.exit('⛔ o caso cego %r sumiu de %s' % (cid, fixture))
        if c['operacao'] != 'instigar':
            sys.exit('⛔ %r deixou de ser instigar' % cid)
        reqs = c.get('requisitos') or []
        if not any(r.startswith('REPROVA POR ') for r in reqs):
            sys.exit('⛔ %r perdeu a letra REPROVA POR' % cid)
        if not any(r.startswith('PASSA') for r in reqs):
            sys.exit('⛔ %r perdeu a letra PASSA' % cid)
    return casos


def cego(cid, ps):
    """Os dois polos, só o que uma regex decide. O mérito é do revisor."""
    if len(ps) < 2:
        return ['RECUSA COVARDE: %d pergunta(s)' % len(ps)]
    faltas = []
    for q in ps:
        if QUANDO.search(q):
            faltas.append('JÁ %s o quando: %r' % ('RESPONDEU' if cid == CEGOS[0] else 'NEGOU', q))
        if DARCERTO.search(q):
            faltas.append('JÁ %s o "dar certo": %r' % ('RESPONDEU' if cid == CEGOS[0] else 'NEGOU', q))
        if cid == CEGOS[0] and OQUEACONTECEU.search(q):
            faltas.append('JÁ RESPONDEU o quê: %r' % q)
        if cid == CEGOS[1] and CAUSA.search(q):
            faltas.append('JÁ NEGOU a causa: %r' % q)
    return faltas


def perguntasNoBruto(d):
    """Quantas perguntas o modelo REALMENTE devolveu, antes de `parsePerguntas`.
    ADR 10c: sem o bruto, a guarda que derruba uma pergunta some sem rastro e a
    medida credita ao modelo o que foi a nossa tesoura. `None` = binário velho,
    sem o campo — e aí a coluna se cala em vez de mentir zero."""
    for c in d.get('chamadasGrok') or []:
        cru = c.get('bruto')
        if not cru:
            continue
        try:
            i, f = cru.index('{'), cru.rindex('}')
            return len(json.loads(cru[i:f + 1]).get('perguntas') or [])
        except (ValueError, json.JSONDecodeError, AttributeError):
            return None
    return None


def medir(p):
    anc = collections.defaultdict(lambda: [0, 0])   # cid -> [ancoradas, total]
    falhas = collections.defaultdict(list)
    vistos, shas, derrubadas, semBruto = set(), set(), [], [0]
    for l in open(p):
        d = json.loads(l)
        if d.get('evento') != 'casoConcluido' or d['operacao'] != 'instigar':
            continue
        cid, rep, ps = d['id'], d['repeticao'], (d.get('saida') or [])
        vistos.add(cid)
        if d.get('pedidoInstigarSHA256'):
            shas.add(d['pedidoInstigarSHA256'])
        veio = perguntasNoBruto(d)
        if veio is None:
            semBruto[0] += 1
        elif veio != len(ps):
            derrubadas.append((cid, rep, veio, len(ps)))
        if cid not in SEM_MATERIA:
            dela = conteudo(d['entrada'].get('texto') or '')
            anc[cid][0] += sum(1 for q in ps if conteudo(q) & dela)
            anc[cid][1] += len(ps)
        if cid in CEGOS:
            for f in cego(cid, ps):
                falhas[cid].append((rep, f))
    return anc, falhas, vistos, shas, derrubadas, semBruto[0]


def relatar(p, anc, falhas, vistos, shas, derrubadas, semBruto):
    print('####', p.split('/')[-1])
    # o braço se lê no SHA que o APP gravou, nunca no nome do arquivo
    print('  0. pedidoInstigarSHA256: %s' % (', '.join(sorted(shas)) if shas
          else 'AUSENTE — binário anterior à ADR 10c, o braço não é verificável'))
    if len(shas) > 1:
        print('     ⛔ MAIS DE UM PEDIDO no mesmo arquivo: a corrida mediu duas coisas')
    # zero SÓ vale se o bruto estava lá para ser lido. Vigia que reporta zero
    # sem enxergar não está provado, está mudo.
    if semBruto:
        print('  0b. a nossa tesoura (bruto → saída): NÃO VERIFICÁVEL em %d execução(ões) — '
              'sem `chamadasGrok[].bruto` (binário anterior à ADR 10c)' % semBruto)
    if not semBruto or derrubadas:
        print('  0b. a nossa tesoura (bruto → saída): %s'
              % ('nenhuma pergunta derrubada, e o bruto estava lá para ser lido'
                 if not derrubadas else '%d execução(ões)' % len(derrubadas)))
    for cid, rep, veio, ficou in derrubadas:
        print('      · %s r%s  o modelo devolveu %d, `parsePerguntas` deixou %d' % (cid, rep, veio, ficou))
    print('  A. ANCORADAS pergunta a pergunta, POR CASO (a média vem depois, nunca no lugar):')
    for cid, (a, t) in anc.items():
        print('      %-42s %2d/%-3d %s' % (cid, a, t, '%3.0f%%' % (100 * a / t) if t else 'sem perguntas'))
    sa, st = sum(a for a, _ in anc.values()), sum(t for _, t in anc.values())
    print('      %-42s %2d/%-3d %s  ← média, e ela esconde o caso que foi a zero'
          % ('TODOS os casos com matéria', sa, st, '%3.0f%%' % (100 * sa / st) if st else '—'))
    faltando = [c for c in CEGOS if c not in vistos]
    if faltando:
        print('  B. CASO CEGO: NÃO CORREU neste arquivo (%s) — é a base, ou a corrida usou outra fixture'
              % ', '.join(faltando))
    else:
        for cid in CEGOS:
            fs = falhas.get(cid, [])
            print('  B. %-42s %s' % (cid, 'PASSOU nas guardas mecânicas' if not fs else '%d falha(s)' % len(fs)))
            for rep, f in fs:
                print('        ✗ r%s %s' % (rep, f))


def vigia(fixture):
    """A caça que nunca acusou nada não está provada, está muda: seis execuções
    sintéticas, três que TÊM de acusar e três que NÃO PODEM."""
    letra(fixture)
    acusa = [
        (CEGOS[0], ['Quando isso aconteceu?', 'O que você vai mandar agora?'], 'quando já respondido'),
        (CEGOS[0], ['O que seria dar certo?', 'O que o aceite dele vale?'], 'dar certo já respondido'),
        (CEGOS[1], ['O que você fez?'], 'recusa covarde (1 pergunta)'),
    ]
    cala = [
        (CEGOS[0], ['O que você disse no telefonema?', 'O que o aceite dele vale sobre o preço errado?'], None),
        (CEGOS[1], ['De que você desistiu?', 'O que você nota agora que não notava antes?'], None),
        (CEGOS[1], ['Do que exatamente você desistiu?', 'O que muda quando você põe essa palavra?'], None),
    ]
    erros = 0
    for cid, ps, porque in acusa:
        f = cego(cid, ps)
        print('  ACUSA?  %-42s %s  (%s)' % (cid, 'sim ✓' if f else 'NÃO ✗', porque))
        if not f: erros += 1
    for cid, ps, _ in cala:
        f = cego(cid, ps)
        print('  CALA?   %-42s %s%s' % (cid, 'sim ✓' if not f else 'NÃO ✗', '' if not f else '  ' + str(f)))
        if f: erros += 1
    print('  vigia:', 'PROVADO nos dois sentidos' if not erros else '⛔ %d erro(s)' % erros)
    sys.exit(1 if erros else 0)


if __name__ == '__main__':
    if sys.argv[1] == '--vigia':
        vigia(sys.argv[2])
    letra(sys.argv[1])
    print('fixture %s: os %d casos cegos estão lá, com a letra REPROVA/PASSA intacta\n'
          % (sys.argv[1].split('/')[-1], len(CEGOS)))
    for p in sys.argv[2:]:
        relatar(p, *medir(p))
