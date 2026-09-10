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
# As duas saem MAIS ESTREITAS aqui, e quem cobrou foi a corrida: o conferidor
# do 09e conta se ALGUMA pergunta PEDE o quando — ali um falso positivo ajuda o
# candidato e não faz mal. Aqui ele REPROVA um caso cego, e **falso positivo que
# reprova é o pior tipo**. Duas formas apareceram na BASE, e as duas são
# perguntas legítimas que o proxy solto derrubava:
#
#   "Quando você diz que não foi por nada específico, o que ainda ficou sem
#    definição?"                        → o `quando` é conjunção, não pergunta
#   "Sem saber o que seria dar certo, o que a desistência resolveu de fato?"
#                                       → o "dar certo" é premissa, não o pedido
#
# Regra, e ela é simétrica: o alvo só conta quando (1) está COLADO ao
# interrogativo, (2) não vem precedido de subordinador, e (3) não é seguido de
# vírgula mais outro interrogativo — que é a marca de que o pedido é o de
# depois. O aperto favorece a BASE, não o candidato: ele tira reprovações do
# braço antigo. `--vigia` prova as duas direções nas frases REAIS da corrida.
QUANDO_ALVO = re.compile(r'(?:^|[—–:;(]\s*)[«"“\'(]*\s*quando\b|'
                         r'\b(?:desde|at[ée]|para|de|em) quando\b|\bfoi quando\b|'
                         r'\bque dia\b|\bque hora\b|em que momento|'
                         r'\bque semana\b|\bque m[êe]s\b|h[áa] quanto tempo', re.I)
# "o que seria/é/significa dar certo", com no máximo uma aspa ou preposição
# curta no meio. "o que é o 'aqui' em que algo deveria dar certo" fica de fora
# pelo tamanho do vão — ali o pedido é o "aqui", e a nota não o deu.
DARCERTO_ALVO = re.compile(r'o que (?:seria|é|e|significa|significaria|era|'
                           r'voc[êe] (?:quis dizer|chama|entende|considera))'
                           r'[^?]{0,12}?dar certo', re.I)
CAUSA_ALVO = re.compile(r'(?:^|[—–:;(]\s*)por qu[êe]\b|por causa de qu|'
                        r'o que causou|qual (?:foi )?o motivo', re.I)
OQUEACONTECEU = re.compile(r'o que (?:foi que )?(?:aconteceu|houve|se passou)', re.I)

# "não sabe/não sei/não consigo dizer" entram porque são a NEGAÇÃO DELA sendo
# citada de volta como premissa — e examinar a própria negação é o que a linha
# PASSA da fixture autoriza: "O que é o aqui em que você NÃO SABE o que seria
# dar certo?" pede o *aqui*, que a nota nunca deu.
SUBORDINADOR = re.compile(r'sem saber|sem nomear|sem definir|sem dizer|j[áa] que|'
                          r'n[ãa]o sabe|n[ãa]o sei|n[ãa]o consigo dizer|nem sabe|'
                          r'embora|porque|depende|caso\b', re.I)
DEPOIS_PEDE_OUTRA = re.compile(r',[^?]*\b(?:o que|que\b|quem|como|qual|quanto|onde|por qu[êe])', re.I)

def pede(q, alvo):
    """A pergunta PEDE isto, ou só menciona? Três testes, e o print do medidor
    mostra a frase inteira para o revisor conferir o proxy."""
    for m in alvo.finditer(q):
        antes = q[max(0, m.start() - 25):m.start()]
        if SUBORDINADOR.search(antes):
            continue
        if DEPOIS_PEDE_OUTRA.search(q[m.end():]):
            continue
        return True
    return False

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
    ja = 'RESPONDEU' if cid == CEGOS[0] else 'NEGOU'
    for q in ps:
        if pede(q, QUANDO_ALVO):
            faltas.append('JÁ %s o quando: %r' % (ja, q))
        if pede(q, DARCERTO_ALVO):
            faltas.append('JÁ %s o "dar certo": %r' % (ja, q))
        if cid == CEGOS[0] and pede(q, OQUEACONTECEU):
            faltas.append('JÁ RESPONDEU o quê: %r' % q)
        if cid == CEGOS[1] and pede(q, CAUSA_ALVO):
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
    """A caça que nunca acusou nada não está provada, está muda: 13 execuções
    sintéticas, 6 que TÊM de acusar e 7 que NÃO PODEM. Não são metades iguais, e
    nunca precisaram ser — o que o portão cobra é que ele acuse E cale."""
    letra(fixture)
    # As frases são REAIS: saíram do braço da BASE desta mesma corrida
    # (`prova/instigar-lote/instigar-lote-base-grok-4.*.jsonl`). Umas têm de ser
    # acusadas e outras têm de passar — vigia que só acusa reprova tudo, e vigia
    # que só se cala não enxerga nada.
    acusa = [
        (CEGOS[0], ["O que você quis dizer com 'dar certo' nesse caso?", "E agora?"],
         'a nota DIZ o que seria dar certo'),
        (CEGOS[0], ['O que aconteceu?', 'O que você vai mandar agora?'],
         'a nota DIZ o que aconteceu'),
        (CEGOS[1], ['Quando começou isso?', 'De que você desistiu?'],
         'a nota NEGA o quando com todas as letras'),
        (CEGOS[1], ['O que seria dar certo aqui?', 'De que você desistiu?'],
         'a nota NEGA o "dar certo"'),
        (CEGOS[1], ['O que seria dar certo, na sua cabeça?', 'De que você desistiu?'],
         'o pedido é o mesmo com um aposto no fim'),
        (CEGOS[1], ['O que você fez?'], 'recusa covarde (1 pergunta)'),
    ]
    cala = [
        # as três primeiras vieram da BASE e o proxy solto as derrubava
        (CEGOS[1], ['Quando você diz que não foi por nada específico, o que ainda ficou sem definição?',
                    'De que você desistiu?'], 'o "quando" é conjunção'),
        (CEGOS[1], ['Sem saber o que seria dar certo, o que a desistência resolveu de fato?',
                    'De que você desistiu?'], 'o "dar certo" é premissa, não o pedido'),
        (CEGOS[1], ["O que é o 'aqui' em que algo deveria dar certo?",
                    'De que você desistiu?'], 'o pedido é o "aqui", que a nota não deu'),
        (CEGOS[0], ['O que você disse no telefonema?',
                    'O que o aceite dele vale sobre o preço errado?'], None),
        (CEGOS[0], ['O que fica em aberto quando "dar certo" depende dele aceitar o preço certo?',
                    'O que você manda agora?'], 'menciona sem pedir'),
        (CEGOS[1], ['Do que exatamente você desistiu?',
                    'O que muda quando você põe essa palavra?'], None),
        (CEGOS[1], ['O que é o aqui em que você não sabe o que seria dar certo?',
                    'De que você desistiu?'], 'cita a negação DELA e pede o "aqui"'),
    ]
    erros = 0
    for cid, ps, porque in acusa:
        f = cego(cid, ps)
        print('  ACUSA?  %-42s %s  (%s)' % (cid, 'sim ✓' if f else 'NÃO ✗', porque))
        if not f: erros += 1
    for cid, ps, porque in cala:
        f = cego(cid, ps)
        print('  CALA?   %-42s %s  (%s)%s' % (cid, 'sim ✓' if not f else 'NÃO ✗', porque or '—',
                                              '' if not f else '  ' + str(f)))
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
