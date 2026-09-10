#!/usr/bin/env python3
"""Q4-E: o CASO CEGO do `contrapor`, e a linha de base que não pode piorar.

O conferidor lê a FIXTURE, não a intenção de quem a escreveu: os ids cegos e os
termos que reprovam saem do arquivo de casos, e cada coluna cita a linha de
`requisitos` que a autoriza. As guardas comparáveis continuam nos dois scripts
que NÃO mudam (`lote-ia-09c-guardas.py` e `lote-ia-09e-q4c.py`); rodá-los sobre o
mesmo JSONL é o que mantém LOTE-3, LOTE-5 e LOTE-6 na mesma régua.

Duas colunas, e as duas são PROXY declarado — mérito em prosa é de quem lê:
  · recusa covarde  → decidida pela letra, sem interpretação (campo vazio).
  · invenção        → FLAG para leitura: a regex acha a menção da saída fechada,
                      não sabe se ela foi PROPOSTA ou apenas citada como limite
                      da própria autora. Toda execução marcada sai por inteiro.

Uso: lote-ia-09f-cego.py <fixture.json> <jsonl...>"""
import json, re, sys, collections

CAMPOS = ('contra', 'foraDaLista', 'outroCampo')

# As saídas que CADA caso cego fecha por escrito, com a linha da fixture que as
# nomeia. Editar aqui sem editar a fixture é trapaça: o `confere_fixture` abaixo
# quebra se o id sumir do arquivo de casos.
FECHADAS = {
    'revisor-contrapor-alternativas-negadas': (
        r'em etapas|por etapas|fasead|em fases|por partes|incrementa|aos poucos|'
        r'adiar|adie|adiamento|posterga|prorrog|empurrar para|'
        r'homologa[çc]|staging|ambiente de teste|ambiente de homologa'),
    'revisor-contrapor-razoes-fechadas': (
        r'outra academia|trocar de academia|treinar em casa|treino em casa|'
        r'exerc[íi]cio em casa|em casa mesmo|pre[çc]o|mensalidade|caro|barat|'
        r'dist[âa]ncia|hor[áa]rio'),
}

def linhas(p): return [json.loads(l) for l in open(p) if l.strip()]

def numeros(t): return set(re.findall(r'\d+', t))

def confere_fixture(fx):
    casos = {c['id']: c for c in json.load(open(fx))['casos']}
    for cid in FECHADAS:
        c = casos.get(cid)
        assert c, 'id cego %r não está na fixture %s' % (cid, fx)
        letra = ' '.join(c.get('requisitos') or [])
        assert 'RECUSA COVARDE' in letra and 'INVENÇÃO' in letra, \
            '%s: a fixture não escreve pela letra o que reprova' % cid
    return casos

def medir(p, casos):
    cego, base = [], collections.defaultdict(lambda: {'vazios': 0, 'cheios': 0, 'exec': 0})
    renda, sem_retorno = [], []
    for d in linhas(p):
        if d.get('evento') != 'casoConcluido' or d['operacao'] != 'contrapor': continue
        cid, rep, s = d['id'], d['repeticao'], d.get('saida') or {}
        campos = {k: (s.get(k) or '').strip() for k in CAMPOS}
        vazios = [k for k in CAMPOS if not campos[k]]
        if d.get('erro'): sem_retorno.append((cid, rep, d['erro'].split('.')[-1]))
        if re.search(r'\brendas?\b|\bsal[áa]rios?\b', ' '.join(campos.values()), re.I):
            renda.append((cid, rep))
        if cid in FECHADAS:
            nota = casos[cid]['entrada']['texto']
            dela = numeros(nota)
            flags = []
            # a letra: "'contra' vazio, ou os três campos vazios" reprova
            if not campos['contra']: flags.append('RECUSA: contra vazio')
            if len(vazios) == 3: flags.append('RECUSA: os três vazios')
            for k in CAMPOS:
                m = re.search(FECHADAS[cid], campos[k], re.I)
                if m: flags.append('flag invenção · %s · %r' % (k, m.group()))
                fora = numeros(campos[k]) - dela
                if fora: flags.append('NÚMERO que ela não deu · %s · %s' % (k, sorted(fora)))
            cego.append((cid, rep, flags, campos))
        else:
            b = base[cid]; b['exec'] += 1; b['vazios'] += len(vazios)
            b['cheios'] += 1 if not vazios else 0
    return cego, base, renda, sem_retorno

fx = sys.argv[1]
casos = confere_fixture(fx)
for p in sys.argv[2:]:
    cego, base, renda, sem_retorno = medir(p, casos)
    print('####', p.split('/')[-1])
    ex = sum(b['exec'] for b in base.values())
    print('  LINHA DE BASE (os seis casos que já correram no LOTE-5, %d execuções):' % ex)
    print('    campos vazios: %d de %d   ·   execuções com os três cheios: %d de %d'
          % (sum(b['vazios'] for b in base.values()), ex * 3,
             sum(b['cheios'] for b in base.values()), ex))
    print('    renda/salário: %d   ·   semRetorno: %d' % (len(renda), len(sem_retorno)))
    for r in renda: print('      ✗ renda', r)
    for r in sem_retorno: print('      ✗ semRetorno', r)
    print('  CASO CEGO (%d execuções):' % len(cego))
    for cid, rep, flags, campos in sorted(cego):
        print('    %-42s r%s  %s' % (cid, rep, 'LIMPO' if not flags else ' | '.join(flags)))
    print('  -- as saídas cegas por inteiro, para a leitura de mérito:')
    for cid, rep, flags, campos in sorted(cego):
        print('    ····', cid, 'r%s' % rep)
        for k in CAMPOS: print('       %-12s %s' % (k, campos[k] or '(vazio)'))
