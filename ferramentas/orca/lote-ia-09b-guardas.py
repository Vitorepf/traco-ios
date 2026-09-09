#!/usr/bin/env python3
"""Só as guardas que a PRÓPRIA fixture escreveu e que uma regex decide.
O mérito em prosa não está aqui — é dos revisores."""
import json, re, sys, collections

ROTULO = re.compile(r'\bN\d+T\d+\b')
# termos SEM sentido comum em português corrente: só existem como jargão do app
JARGAO_DURO = re.compile(r'\bdegraus?\b|movimento b[áa]sico|passo que se pula|\bs[áa]bia\b|\brascunhos?\b', re.I)
# termos que a fixture também proíbe mas que têm uso corrente: contados à parte
JARGAO_MOLE = re.compile(r'\bm[ée]todos?\b|\bformas?\b', re.I)

def linhas(p): return [json.loads(l) for l in open(p) if l.strip()]

def guardas(p):
    tab = collections.defaultdict(lambda: {'exec': 0, 'passou': 0, 'falhas': []})
    mole = []
    for d in linhas(p):
        if d['evento'] != 'casoConcluido': continue
        op, cid, rep, s = d['operacao'], d['id'], d.get('repeticao'), d.get('saida')
        t = tab[op]; t['exec'] += 1
        ok, porque = True, []
        if d.get('erro'):
            ok = False; porque.append('semRetorno')
        elif op == 'responderNasNotas':
            txt = (s or {}).get('texto') or ''
            if (s or {}).get('escreveuRotuloInterno'): ok = False; porque.append('escreveuRotuloInterno=true')
            if ROTULO.search(txt): ok = False; porque.append('rotulo no texto: ' + ROTULO.search(txt).group())
            if not txt.strip(): ok = False; porque.append('texto vazio')
        elif op == 'instigar':
            ps = s or []
            if not (2 <= len(ps) <= 5): ok = False; porque.append('perguntas=%d (fora de 2..5)' % len(ps))
            # a fixture EXENTA este caso: nele 'método' e 'degrau' são palavras
            # DO AUTOR e o requisito é o inverso — a guarda não pode calar.
            if cid == 'q4-instigar-o-autor-escreve-metodo':
                # fora da guarda de jargão POR ORDEM DA FIXTURE, e o requisito
                # que lhe resta ("fala do método/degrau DELE") não é decidível
                # por regex: vai como observação, não como contagem.
                mole.append((cid, rep, 'palavra do autor no retorno',
                             'sim' if any(re.search(r'\bm[ée]todo|\bdegrau', q, re.I) for q in ps) else 'não'))
            else:
                for q in ps:
                    m = JARGAO_DURO.search(q)
                    if m: ok = False; porque.append('jargão %r em %r' % (m.group(), q[:70]))
                    m2 = JARGAO_MOLE.search(q)
                    if m2: mole.append((cid, rep, m2.group(), q[:90]))
        elif op == 'contrapor':
            s = s or {}
            c = (s.get('contra') or '').strip(); f = (s.get('foraDaLista') or '').strip()
            if not c and not f and not (s.get('outroCampo') or '').strip():
                ok = False; porque.append('os três campos vazios')
            elif cid == 'q4-contrapor-outro-campo-sem-fabricar' and not c and not f:
                ok = False; porque.append('contra e foraDaLista vazios ao mesmo tempo')
            elif not c: ok = False; porque.append('contra vazio')
        if ok: t['passou'] += 1
        else: t['falhas'].append((cid, rep, '; '.join(porque)))
    return tab, mole

for p in sys.argv[1:]:
    tab, mole = guardas(p)
    print('####', p.split('/')[-1])
    for op, t in tab.items():
        print('  %-20s %2d/%2d passaram nas guardas mecânicas' % (op, t['passou'], t['exec']))
        for f in t['falhas']: print('      ✗', f)
    if mole:
        print('  -- termo de uso corrente também proibido pela fixture (NÃO conta na guarda):')
        for m in mole: print('      ~', m)
