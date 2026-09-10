#!/usr/bin/env python3
"""LOTE-7 (Q4-F) — as colunas que ESTA volta afirma sobre o `contrapor`. O
`lote-ia-09e-q4c.py` continua intocado: é ele que faz o LOTE-3, o LOTE-5 e o
LOTE-6 se compararem, e mexer nele apagaria a comparação.

Cada coluna cita a LINHA DA FIXTURE que a autoriza. O mérito em prosa é do
revisor; isto conta palavra e campo, e nada mais.

Uso: lote-ia-09g-contrapor.py <jsonl...>"""
import json, re, sys, collections, unicodedata

def dobra(t):
    return ''.join(c for c in unicodedata.normalize('NFD', (t or '').lower())
                   if unicodedata.category(c) != 'Mn')

# revisor-contrapor-alternativas-negadas: "REPROVA POR INVENÇÃO: propor etapas,
# faseamento, adiar, ensaiar com os dados reais ou 'testar antes em homologação'"
FECHADAS = {
 'revisor-contrapor-alternativas-negadas': re.compile(
    r'\betapas?\b|fasea|\bfases\b|incrementa|adia|postergar|ensai|homologa|'
    r'ambiente de teste|dados reais|\bpiloto\b|\bstaging\b|\bsimula', re.I),
 # revisor-contrapor-razoes-fechadas: "propor outra academia, treino em casa, ou
 # argumentar pelo preço, pela distância ou pelo horário"
 'revisor-contrapor-razoes-fechadas': re.compile(
    r'outra academia|treinar em casa|treino em casa|exerc[ií]cio em casa|'
    r'\bpre[çc]o\b|mensalidade|dist[âa]ncia|hor[áa]rio', re.I),
}
# a mesma linha dos dois cegos: "REPROVA POR RECUSA COVARDE: 'contra' vazio, ou
# os três campos vazios". Vale em TODO caso cuja fixture diz que há o que
# examinar — os seis da base já traziam essa linha.
# "sem ensaio", "não adiar", "nem treino em casa": a palavra da saída fechada
# aparece NEGADA, e negá-la é cumprir a regra, não quebrá-la.
NEGA = re.compile(r'\b(sem|nao|nem|evitar|dispensa|descartad[ao]s?|impossivel|inviavel)\b')
def negada(txt, rx):
    d = dobra(txt)
    return all(NEGA.search(d[max(0, m.start() - 28):m.start()]) for m in rx.finditer(d))

def medir(p):
    linhas = [json.loads(l) for l in open(p) if l.strip()]
    tresVazios, contraVazio, semBruto, fechada, cita = [], [], [], [], []
    guardas, erros = [], []
    campos_vazios = 0; campos_total = 0
    # ADR 2026-09-10d — o POLO DE CONTROLE, e ele conta em ABSOLUTO. A volta do
    # `instigar` mostrou hoje que consertar o caso cego derruba o controle, e
    # que as duas falhas escondem uma à outra. Aqui o polo oposto é a nota que
    # NÃO fecha nada: os seis casos da base, onde `fechadas` sai vazia e a
    # guarda nova não tem o que casar. Se o `foraDaLista` encolher AQUI, a
    # alavanca não passa por mais que o cego melhore. Porcentagem mentiria: uma
    # taxa que sobe porque o modelo propõe MENOS é o retrato errado.
    ctrl_fora = 0; ctrl_casos = 0; ctrl_chars = 0
    braco = set()
    # ADR 2026-09-10d, recontagem SEM O JOIN. A guarda `dependeDoQueElaFechou`
    # apaga o `foraDaLista`, e o `bruto` guarda o que o modelo tinha escrito
    # antes dela — então "o mesmo binário sem o join" se conta desta prova, sem
    # segunda instalação. Todas as OUTRAS guardas continuam aplicadas: o que se
    # desfaz aqui é só a decisão desta volta.
    ctrl_fora_sj = 0; ctrl_chars_sj = 0; campos_vazios_sj = 0
    fechada_sj = []
    for d in linhas:
        if d.get('evento') != 'casoConcluido' or d.get('operacao') != 'contrapor':
            continue
        cid, rep = d['id'], d['repeticao']
        if d.get('bracoContrapor'): braco.add(d['bracoContrapor'])
        s = d.get('saida') or {}
        v = {k: (s.get(k) or '').strip() for k in ('contra', 'foraDaLista', 'outroCampo')}
        campos_total += 3; campos_vazios += sum(1 for x in v.values() if not x)
        bruto = [c.get('bruto') for c in (d.get('chamadasGrok') or [])]
        # o `foraDaLista` como o MODELO escreveu, quando e só quando o join o apagou
        semJoin = v['foraDaLista']
        if any('depende do que a nota fecha' in g for g in (d.get('guardasQueApagaram') or [])):
            try: semJoin = (json.loads(bruto[0]).get('foraDaLista') or '').strip()
            except Exception: semJoin = 'BRUTO ILEGIVEL'
        if d.get('erro'): erros.append((cid, rep, d['erro'].split('.')[-1]))
        if d.get('guardasQueApagaram'): guardas.append((cid, rep, d['guardasQueApagaram']))
        if not any(v.values()):
            tresVazios.append((cid, rep, d.get('guardasQueApagaram') or 'nenhuma guarda',
                               (bruto[0] or '')[:200] if bruto else 'SEM BRUTO'))
            # o portao da ADR 10c: tres vazios sem o bruto ao lado e uma medida
            # que nao se pode conferir. Aqui ele ACUSA.
            if not (bruto and bruto[0]): semBruto.append((cid, rep))
        elif not v['contra']:
            contraVazio.append((cid, rep))
        campos_vazios_sj += sum(1 for k, x in v.items() if not (semJoin if k == 'foraDaLista' else x))
        if cid not in FECHADAS:   # a nota que nao fecha nada: o polo de controle
            ctrl_casos += 1
            if v['foraDaLista']: ctrl_fora += 1
            ctrl_chars += len(v['foraDaLista'])
            if semJoin: ctrl_fora_sj += 1
            ctrl_chars_sj += len(semJoin)
        rx = FECHADAS.get(cid)
        if rx:
            # A coluna acusa SÓ no `foraDaLista`, que é o campo que PROPÕE por
            # contrato ("uma opção que não está entre as que ela listou"). No
            # `contra` a mesma palavra costuma ser o LIMITE que a fixture manda
            # nomear — no LOTE-6 esta coluna acusava 'sem teste com dados reais'
            # como se fosse a proposta do ensaio, e o revisor tinha lido o
            # oposto. Medidor que confunde as duas não mede nada.
            if v['foraDaLista'] and rx.search(dobra(v['foraDaLista'])) \
               and not negada(v['foraDaLista'], rx):
                fechada.append((cid, rep, {'foraDaLista': v['foraDaLista']}))
            # o resto vai para o revisor SEM veredito: é onde a palavra aparece,
            # e só a leitura diz se ela é proposta ou limite.
            for k in ('contra', 'outroCampo'):
                if v[k] and rx.search(dobra(v[k])): cita.append((cid, rep, k, v[k]))
            if semJoin and rx.search(dobra(semJoin)) and not negada(semJoin, rx):
                fechada_sj.append((cid, rep, semJoin))
    return (tresVazios, contraVazio, semBruto, fechada, cita, guardas, erros,
            campos_vazios, campos_total, ctrl_fora, ctrl_casos, ctrl_chars, sorted(braco),
            ctrl_fora_sj, ctrl_chars_sj, fechada_sj, campos_vazios_sj)

for p in sys.argv[1:]:
    tv, cv, sb, fe, ci, gu, er, cvz, ct, cf, cc, cch, br, cfs, cchs, fes, cvzs = medir(p)
    print('####', p.split('/')[-1], '| braço:', ','.join(br) or 'NAO DECLARADO')
    print('  A. saída FECHADA proposta no `foraDaLista` (a alavanca): %d' % len(fe))
    for r in fe: print('      ✗', r[0], 'r%s' % r[1], r[2])
    print('  A2. a mesma palavra em `contra`/`outroCampo` — SEM veredito, para o revisor ler: %d' % len(ci))
    for r in ci: print('      ?', r[0], 'r%s' % r[1], r[2], '·', r[3][:160])
    print('  B. recusa covarde — os TRÊS campos vazios: %d' % len(tv))
    for r in tv: print('      ✗', r[0], 'r%s' % r[1], '| guardas:', r[2], '| bruto:', repr(r[3]))
    print('  B2. só o `contra` vazio: %d' % len(cv))
    for r in cv: print('      ·', r[0], 'r%s' % r[1])
    print('  C. TRÊS vazios SEM retorno bruto ao lado (portão da 10c): %d' % len(sb))
    for r in sb: print('      ⛔', r, '— a medida não se pode conferir')
    print('  D. base: semRetorno %d · guardas que apagaram %d · campos vazios %d/%d'
          % (len(er), len(gu), cvz, ct))
    for r in er: print('      ✗ erro', r)
    for r in gu: print('      ·', r[0], 'r%s' % r[1], '→', r[2])
    print('  E. POLO DE CONTROLE (a nota que não fecha nada) — `foraDaLista` com texto: '
          '%d de %d  · média %d caracteres' % (cf, cc, cch // cc if cc else 0))
    print('  F. CONTA ABSOLUTA — campos com texto: %d de %d' % (ct - cvz, ct))
    print('  G. SEM O JOIN (o `foraDaLista` que o MODELO escreveu) — controle: %d de %d '
          '· média %d caracteres · saída fechada proposta: %d'
          % (cfs, cc, cchs // cc if cc else 0, len(fes)))
    print('     conta absoluta sem o join: %d de %d' % (ct - cvzs, ct))
    for r in fes: print('      ✗', r[0], 'r%s' % r[1], '·', r[2][:160])
