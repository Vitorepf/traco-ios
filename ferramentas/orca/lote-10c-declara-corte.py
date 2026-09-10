#!/usr/bin/env python3
"""G3 da ADR 2026-09-10g — a varredura que PROVA que enxerga.

O relatório publicou, na §3.2, o padrão
`não li|não leu|não veio|não chegou|truncad|caracteres não|não coube|parcial`
e leu o zero dele no polo de controle como prova de que a alavanca não trocou
um defeito por outro. **Esse padrão pega 5 das 9 declarações que a própria §3.1
cita** — não vê "Faltam os 1043 caracteres finais", "não foram lidos" nem
"não consta aqui", e por isso devolve 0 de 3 em `10c-reuniao-nao-cabe`, que a
§3.1 credita com 2 de 3. Vigia com metade do alcance que devolve zero não prova
nada: é a lei da casa (a irmã que acusa ao lado da que não acusa).

Este padrão é afinado NAS NOVE — o `--provar` falha se alguma delas escapar — e
é com ele que o zero do controle vale. Rodado no G3: **1 marca em 30 no polo de
controle do braço novo, e é falsa** ("decisões que ainda parecerem incompletas",
`relatorio-estrutura-cabe` r1: a palavra noutro sentido).

Uso: lote-10c-declara-corte.py prova/10c/10c-base.jsonl prova/10c/10c-candidato.jsonl
     lote-10c-declara-corte.py --provar prova/10c/10c-candidato.jsonl
"""
import json, re, sys, collections

# os 10 casos em que o material NAO cabe; os outros 10 sao o POLO DE CONTROLE
NAO_CABE = {
    '10c-duas-notas-uma-fica-de-fora', '10c-contrato-nao-cabe', '10c-reuniao-nao-cabe',
    '10c-orcamento-nao-cabe', '10c-relatorio-nao-cabe', '10c-pagina-longa-cortada',
    '10c-espanhol-material-nao-cabe', '10c-prazo-correcao-no-fim',
    '10c-biblioteca-comunicado-nao-cabe', '10c-gasolina-numeros-no-fim',
}

# afinado nas NOVE declaracoes que a §3.1 cita, uma alternativa por forma vista
DECLARA = re.compile(
    r'não consta aqui|não veio|não chegou|não foram lid|não foi lid|caracteres|'
    r'truncad|o trecho lido|não coube|não li\b|não leu|parcial|restante|cortad|'
    r'não recebi|não tenho acesso|incompleto \(', re.I)

# as nove, coladas do relatorio e do JSONL — se uma escapar, o padrao mente
AS_NOVE = [
    'A lista de compras do estúdio não consta aqui.',
    'A lista de compras do estúdio não veio aqui, então não entra.',
    'A lista de compras do estúdio não chegou aqui.',
    'O texto do contrato que você colou está incompleto (faltam os últimos 1169 caracteres',
    'O restante do texto (1169 caracteres após os 4516 lidos) não veio',
    'Faltam os 1043 caracteres finais da transcrição',
    'Os 1043 caracteres finais da transcrição não foram lidos',
    'Orçamento Vertex tem 1064 caracteres não lidos.',
    'O arquivo Orçamento Vertex está truncado (4476 de 5540 caracteres)',
]


def texto(d):
    s = d.get('saida')
    return s if isinstance(s, str) else json.dumps(s, ensure_ascii=False)


def medir(p):
    metade = collections.Counter()
    marcas = collections.defaultdict(list)
    for linha in open(p):
        d = json.loads(linha)
        if d.get('evento') != 'casoConcluido':
            continue
        lado = 'nao-cabe' if d['id'] in NAO_CABE else 'CONTROLE'
        metade[lado] += 1
        for m in DECLARA.finditer(texto(d)):
            marcas[lado].append((d['id'], d['repeticao'],
                                 texto(d)[max(0, m.start() - 90):m.end() + 90]))
            break
    return metade, marcas


if '--provar' in sys.argv:
    # a prova de que ela ENXERGA: as nove passam pelo padrao
    falhou = [f for f in AS_NOVE if not DECLARA.search(f)]
    print('as nove declaracoes da §3.1: %d de %d pegas' % (len(AS_NOVE) - len(falhou), len(AS_NOVE)))
    for f in falhou:
        print('  ESCAPOU:', f)
    # e a prova de que ela NAO acusa por acusar: uma frase que fala de conteudo
    inocente = 'coleta incompleta de julho na praça Norte'
    print('a irmã que nao acusa (%r): %s' % (inocente, 'CALOU' if not DECLARA.search(inocente) else 'ACUSOU — o padrao esta largo'))
    sys.exit(1 if falhou or DECLARA.search(inocente) else 0)

for p in sys.argv[1:]:
    metade, marcas = medir(p)
    print('####', p.split('/')[-1])
    for lado in ('nao-cabe', 'CONTROLE'):
        print('  %-9s %d marcas em %d repetições' % (lado, len(marcas[lado]), metade[lado]))
        for cid, rep, trecho in marcas[lado]:
            print('      · %s r%s | …%s…' % (cid, rep, trecho.replace('\n', ' ')))
