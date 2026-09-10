#!/usr/bin/env python3
"""Q4-C: só o que ESTA volta afirma. As guardas comparáveis continuam sendo as
do `lote-ia-09c-guardas.py`, que não muda — mudar o instrumento faz o LOTE-3 e o
LOTE-5 deixarem de se comparar. Aqui ficam as três colunas novas, cada uma com a
linha da fixture que a autoriza.

Uso: lote-ia-09e-q4c.py <jsonl...>"""
import json, re, sys, collections

# fixture, q4-instigar-texto-magro: "Devolve pergunta que faz o autor nomear o
# quê, quando e o que era 'dar certo'." PROXY mecânico do "quando" — o mérito
# em prosa é do revisor; isto só conta a palavra que a fixture nomeia.
# "última vez" NÃO entra: "o que você tentou da última vez?" pede O QUÊ, não
# QUANDO — a fixture cobra que a pergunta faça o autor NOMEAR o quando. Com ela
# dentro o medidor dava 2/3 ao grok-4.5 onde o revisor leu 1/3, e o errado era
# o medidor (lei de 09/09: o conferidor lê a fixture, não a intenção).
QUANDO = re.compile(r'\bquando\b|\bque dia\b|\bque hora\b|em que momento|desde quando|'
                    r'\bque semana\b|\bque m[êe]s\b|h[áa] quanto tempo', re.I)
# as outras duas pernas da mesma linha da fixture
OQUE = re.compile(r'\bo qu[êe]\b|\bo que\b|\bqual\b', re.I)
DARCERTO = re.compile(r'dar certo|daria certo|deu certo|ficaria diferente|seria .{0,12}sucesso', re.I)
# fixture, q4-contrapor-outro-campo-sem-fabricar: "Não inventa taxa de
# rendimento, valor do notebook, renda nem inflação."
RENDA = re.compile(r'\brendas?\b|\bsal[áa]rios?\b', re.I)

def linhas(p): return [json.loads(l) for l in open(p) if l.strip()]

def medir(p):
    sem_retorno, apagou = [], []
    quando = collections.defaultdict(list)
    renda = []
    degrau = collections.defaultdict(list)
    for d in linhas(p):
        if d.get('evento') != 'casoConcluido': continue
        cid, rep, s = d['id'], d['repeticao'], d.get('saida')
        http = [c.get('statusHTTP') for c in d.get('chamadasGrok') or []]
        if d.get('erro'):
            sem_retorno.append((cid, rep, d['erro'].split('.')[-1], 'HTTP %s' % http))
        if d.get('guardasQueApagaram'):
            apagou.append((cid, rep, d['guardasQueApagaram']))
        if d['operacao'] == 'instigar':
            ps = s or []
            quando[cid].append((rep, len(ps), bool([q for q in ps if QUANDO.search(q)]), ps,
                                bool([q for q in ps if OQUE.search(q)]),
                                bool([q for q in ps if DARCERTO.search(q)])))
            degrau[cid].append((rep, ps))
        if d['operacao'] == 'contrapor':
            s = s or {}
            campos = {k: (s.get(k) or '').strip() for k in ('contra', 'foraDaLista', 'outroCampo')}
            achou = {k: v for k, v in campos.items() if RENDA.search(v)}
            if achou: renda.append((cid, rep, achou))
    return sem_retorno, apagou, quando, renda, degrau

for p in sys.argv[1:]:
    sem_retorno, apagou, quando, renda, degrau = medir(p)
    print('####', p.split('/')[-1])
    print('  1. semRetorno (item 1 do despacho): %d' % len(sem_retorno))
    for r in sem_retorno: print('      ✗', r)
    print('  1b. a guarda que apagou, por execução (campo novo da ADR 09s): %d execuções' % len(apagou))
    for r in apagou: print('      ·', r[0], 'r%s' % r[1], '→', r[2])
    print('  2. renda/salário no contrapor (item 2): %d' % len(renda))
    for r in renda: print('      ✗', r[0], 'r%s' % r[1], r[2])
    print('  3. as três pernas da fixture no instigar (item 3), por caso:')
    for cid, rs in quando.items():
        alvo = (cid == 'q4-instigar-texto-magro')   # só o magro é cobrado pela letra
        pede = sum(1 for r in rs if r[2])
        tres = sum(1 for r in rs if r[2] and r[4] and r[5])
        print('      %-42s quando %d/%d · as TRÊS %d/%d%s  (perguntas: %s)'
              % (cid, pede, len(rs), tres, len(rs), '  ← o caso da fixture' if alvo else '',
                 ', '.join(str(r[1]) for r in rs)))
        if not alvo: continue
        for rep, _, q, ps, oq, dc in rs:
            print('         r%s  quando=%s  oquê=%s  darcerto=%s'
                  % (rep, 'sim' if q else 'NÃO', 'sim' if oq else 'NÃO', 'sim' if dc else 'NÃO'))
            for x in ps: print('            -', x)
    # linha de base da Q4-B: o degrau 4 não repete as perguntas do degrau 0
    z = {tuple(ps) for _, ps in degrau.get('q4-instigar-sem-metodo-degrau-0', [])}
    q = {tuple(ps) for _, ps in degrau.get('q4-instigar-mesmo-texto-degrau-4', [])}
    iguais = [x for x in q if x in z]
    print('  4. base Q4-B — degrau 4 repete o degrau 0? %s' % ('SIM (regressão)' if iguais else 'não'))
