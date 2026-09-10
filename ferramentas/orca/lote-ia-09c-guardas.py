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

# --- LOTE-3: o que a Q3 consertou é a MEIA-RECUSA, e ela é exata, não interpretada.
# `limiteSemBase` é string literal de Traco/Analise/FonteNotas.swift:109. Comparar
# o texto entregue com ela é igualdade, não leitura. Fica em COLUNA SEPARADA: não
# entra na contagem das guardas acima, para que 09/09b e 09/09c continuem comparáveis.
LIMITE = ("Não tenho informação disponível nesta consulta para confirmar isso. "
          "Informe os dados necessários ou abra a nota que os contém para retomarmos a pergunta.")

def por_caso(p):
    """Uma linha por execução: transporte, retorno e os fatos que uma regex decide."""
    for d in linhas(p):
        if d['evento'] != 'casoConcluido': continue
        s = d.get('saida'); op = d['operacao']
        http = [c.get('statusHTTP') for c in d.get('chamadasGrok') or []]
        transporte = 'ok' if all(h == 200 for h in http) and http else ('sem chamada' if not http else str(http))
        col = ''
        if d.get('erro'): col = 'semRetorno'
        elif op == 'responderNasNotas':
            t = ((s or {}).get('texto') or '').strip()
            só_limite = (t == LIMITE)
            col = ('SÓ A FRASE DE LIMITE' if só_limite else
                   ('cita a frase de limite + mais texto' if LIMITE[:40] in t else '—'))
            col += '  fontesCitadas=%d  rotulo=%s' % (len((s or {}).get('fontesCitadas') or []),
                                                      (s or {}).get('escreveuRotuloInterno'))
        elif op == 'instigar':
            col = 'perguntas=%d' % len(s or [])
        elif op == 'contrapor':
            s = s or {}
            col = 'vazios: ' + (', '.join(k for k in ('contra','foraDaLista','outroCampo')
                                          if not (s.get(k) or '').strip()) or 'nenhum')
        yield (d['id'], d['repeticao'], '%.1fs' % (d.get('duracaoSegundos') or 0), transporte, col)


for p in sys.argv[1:]:
    tab, mole = guardas(p)
    print('####', p.split('/')[-1])
    for op, t in tab.items():
        print('  %-20s %2d/%2d passaram nas guardas mecânicas' % (op, t['passou'], t['exec']))
        for f in t['falhas']: print('      ✗', f)
    # A fixture NUNCA escreve "contra vazio reprova": o que ela escreve é "os três
    # campos vazios reprovam", "contra e foraDaLista vazios ao mesmo tempo" e
    # "retorno vazio". A regra 'contra vazio' acima é do CONFERIDOR do LOTE-2, mais
    # dura que a letra. Mantida para a contagem continuar comparável — e a leitura
    # pela LETRA sai ao lado, para quem quiser a fixture e não o conferidor.
    for op, t in tab.items():
        extra = [f for f in t['falhas'] if f[2] == 'contra vazio']
        if extra:
            print('  %-20s %2d/%2d pela LETRA da fixture (a regra "contra vazio" é do conferidor, não dela)'
                  % (op, t['passou'] + len(extra), t['exec']))
    print('  -- por execução (transporte e retorno em colunas separadas):')
    for r in por_caso(p): print('     %-42s r%s %7s  transporte=%-10s %s' % r)
    if mole:
        print('  -- termo de uso corrente também proibido pela fixture (NÃO conta na guarda):')
        for m in mole: print('      ~', m)
