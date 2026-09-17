#!/usr/bin/env python3
"""E9: casos sintéticos de responderNasNotas com uma nota ENORME por caderno.

Determinístico (semente fixa, só biblioteca padrão). Gera casos.json ao lado.
Uso: python3 gerar_casos.py
"""
import datetime as dt
import json
import os
import random

rng = random.Random(20260916)
AQUI = os.path.dirname(os.path.abspath(__file__))


def nota(texto):
    return {"texto": texto, "gesto": None, "campos": {}}


def encher(alvo, frase):
    """Frases até passar do alvo (ao menos uma)."""
    saida, total = [], 0
    while not saida or total < alvo:
        f = frase()
        saida.append(f)
        total += len(f) + 1
    return saida


def meio(lista, item):
    lista.insert(len(lista) // 2, item)
    return lista


def dias(inicio, fim, semana):
    d, saida = inicio, []
    while d <= fim:
        if d.weekday() in semana:
            saida.append(d)
        d += dt.timedelta(days=1)
    return saida


def orcamento(alvo, feito, i, n, fator=1.0):
    return max(60, (alvo - feito) / (n - i) * (fator if i < n - 1 else 1.0))


# ---------------------------------------------------------------- caderno A
PESSOAS = ["Rodrigo", "Tânia", "Otávio", "Lívia", "Caio", "Marta", "Heitor",
           "Sílvia", "Nuno", "Priscila", "Wagner", "Estela"]
TEMAS_A = [("o", "cronograma do treinamento de integração"), ("o", "relatório de visitas às filiais"),
           ("a", "pauta do comitê de segurança"), ("o", "painel de indicadores do trimestre"),
           ("o", "boletim interno"), ("o", "inventário do almoxarifado"), ("a", "escala de plantão"),
           ("a", "agenda da feira regional"), ("o", "manual de procedimentos"),
           ("a", "migração das pastas compartilhadas"), ("a", "pesquisa de clima"),
           ("o", "roteiro de auditoria interna"), ("o", "calendário de manutenção dos veículos"),
           ("a", "base de contatos das filiais"), ("o", "formulário de reembolso")]
FRASES_A = [
    "Reunião curta com {p} sobre {o_t}; {p} ficou de mandar a versão nova {quando}.",
    "Revisei {o_t} e deixei comentários para {p}.",
    "{p} pediu ajuda com {o_t}; resolvemos em meia hora.",
    "Manhã quase toda em e-mails atrasados e {no_t}.",
    "Chamado {n} aberto no suporte: {problema}. {status}",
    "Daily das 9h sem novidade; {p} segue {no_t}.",
    "Passei a tarde ajustando {o_t}, que ainda tem pendências de formatação.",
    "Liguei para {p} para confirmar os dados {do_t}.",
    "Organizei a caixa de entrada e arquivei o que era do mês passado.",
    "Almoço rápido; a tarde rendeu {no_t}.",
    "{p} e {p2} mostraram o andamento {do_t}; nada travado.",
    "Atualizei a planilha {do_t} com os números da semana.",
    "Remarquei a conversa com {p}: fica {quando}, por conflito de agenda.",
    "Para amanhã: retomar {o_t} e responder {p}.",
    "Treinamento online obrigatório de {curso} feito na hora do almoço.",
    "Sala do terceiro andar sem projetor de novo; a reunião foi pelo notebook.",
    "Dia picado: muitas interrupções e pouco avanço {no_t}.",
    "Mandei para {p} a lista de dúvidas sobre {o_t}.",
    "Videochamada com a filial de {cidade} para tirar dúvidas {do_t}.",
    "Conversa de corredor com {p} sobre os prazos {do_t}; tudo como estava.",
]


def frase_a():
    g, nome = rng.choice(TEMAS_A)
    p, p2 = rng.sample(PESSOAS, 2)
    return rng.choice(FRASES_A).format(
        p=p, p2=p2, o_t=f"{g} {nome}", do_t=f"d{g} {nome}", no_t=f"n{g} {nome}",
        quando=rng.choice(["amanhã", "na sexta", "na segunda", "na quarta", "na semana que vem"]),
        n=rng.randint(4100, 9899),
        problema=rng.choice(["impressora do segundo andar sem conexão", "acesso bloqueado ao sistema de ponto",
                             "lentidão na VPN", "planilha compartilhada corrompida",
                             "senha do e-mail expirada", "monitor piscando"]),
        status=rng.choice(["Resolvido no mesmo dia.", "Ainda sem retorno.", "Técnico vem amanhã.",
                           "Fechado depois de reiniciar."]),
        curso=rng.choice(["proteção de dados", "ergonomia", "prevenção de incêndio", "ética"]),
        cidade=rng.choice(["Barreiras", "Itajubá", "Pato Branco", "Crato"]))


PLANTADOS_A = {
    "2026-02-11": "Reunião com a diretoria financeira: ficou decidido que o fechamento mensal deixa de ser "
                  "no quinto dia útil e passa para o terceiro dia útil, a partir de março. Avisar as filiais "
                  "até o fim da semana.",
    "2026-04-22": "A Gráfica Pontal mandou comunicado: o milheiro do folder institucional sobe de R$ 380 "
                  "para R$ 440 a partir de maio. Vou tentar negociar.",
    "2026-05-20": "Comunicado do RH: a Débora Quintela sai do atendimento e assume a coordenação de compras "
                  "a partir de 1º de junho. Pedidos de material passam a ir direto para ela.",
    "2026-07-15": "Retorno da Gráfica Pontal depois da negociação: o milheiro do folder institucional fica "
                  "em R$ 410, e não mais R$ 440, valendo a partir de agosto. Atualizei a planilha de custos.",
}


def caderno_a(alvo=60000):
    datas = dias(dt.date(2026, 1, 5), dt.date(2026, 9, 11), {0, 1, 2, 3, 4})
    titulo = "# Diário de trabalho 2026"
    blocos, feito = [titulo], len(titulo)
    for i, d in enumerate(datas):
        cab = f"## {d.isoformat()}"
        frases = encher(orcamento(alvo, feito, i, len(datas), rng.uniform(0.6, 1.4)) - len(cab), frase_a)
        if d.isoformat() in PLANTADOS_A:
            meio(frases, PLANTADOS_A[d.isoformat()])
        bloco = cab + "\n" + " ".join(frases)
        blocos.append(bloco)
        feito += len(bloco) + 2
    return "\n\n".join(blocos)


# ---------------------------------------------------------------- caderno B
AFIRMACOES = [
    "a memória de trabalho segura poucos itens ao mesmo tempo",
    "o esquecimento é mais rápido nas primeiras horas depois do contato com o conteúdo",
    "dormir bem depois de estudar ajuda a consolidar o que foi visto",
    "alternar tipos de exercício deixa a prática mais difícil na hora e mais duradoura depois",
    "exemplos resolvidos ajudam quem está começando mais do que problemas soltos",
    "feedback rápido evita que um erro vire hábito",
    "a atenção dividida entre duas telas custa mais do que parece",
    "explicar um assunto em voz alta revela lacunas que a leitura esconde",
    "misturar conteúdos parecidos na mesma sessão ajuda a distinguir um do outro",
    "ligar um conceito novo a algo já conhecido facilita a recuperação",
    "desenhar um esquema obriga a escolher o que é central",
    "metas vagas de estudo tendem a ser trocadas por tarefas mais fáceis",
    "estudar em lugares diferentes reduz a dependência do ambiente na hora de lembrar",
    "a curiosidade despertada antes do conteúdo melhora a retenção do que vem depois",
    "perguntas feitas antes da leitura direcionam a atenção",
    "anotações em palavras próprias são mais úteis do que cópias literais",
    "ansiedade alta atrapalha a recuperação na hora da prova",
    "a prática deliberada pede tarefas um pouco acima do nível atual",
    "o esforço mental aparece antes nas tarefas que exigem decisão constante",
    "variar os exemplos ajuda a levar a ideia para situações novas",
]
CONCEITOS = [("memória de trabalho", "o espaço curto em que a informação fica enquanto é usada"),
             ("consolidação", "o processo que torna uma lembrança mais estável com o tempo"),
             ("interferência", "quando um conteúdo parecido atrapalha a lembrança de outro"),
             ("carga cognitiva", "o esforço mental exigido por uma tarefa num dado momento"),
             ("recuperação", "o ato de trazer à mente algo guardado"),
             ("transferência", "usar o que foi aprendido num contexto diferente"),
             ("metacognição", "a capacidade de avaliar o próprio entendimento")]
EXEMPLOS = ["um estudante de música aprendendo escalas", "um grupo decorando capitais",
            "uma turma de enfermagem treinando procedimentos", "um aprendiz de xadrez revendo partidas",
            "um curso de idiomas com listas de vocabulário", "uma equipe de suporte aprendendo um sistema novo"]
PARES = [("reconhecer", "lembrar"), ("desempenho durante o treino", "aprendizagem duradoura"),
         ("atenção sustentada", "atenção seletiva"), ("prática em bloco", "prática intercalada"),
         ("memória episódica", "memória semântica")]
TEMAS_B = ["esquecimento", "sono e memória", "atenção", "prática intercalada", "exemplos resolvidos",
           "feedback", "anotações", "motivação", "carga cognitiva", "transferência"]
FRASES_B = [
    "O capítulo sobre {tema} começa com o caso de {exemplo}.",
    "Segundo o texto, {af}.",
    "Anotei a definição de {conceito}: {definicao}.",
    "O exemplo de {exemplo} mostra bem que {af}.",
    "O material separa {a} de {b}, o que organiza as leituras anteriores.",
    "Na página {n}, o texto volta à ideia de que {af}.",
    "Copiei o esquema da página {n} sobre {tema} para rever depois.",
    "Um trecho repete que {af}, agora com o caso de {exemplo}.",
    "A leitura de {dia} foi sobre {tema}.",
    "Há uma tabela comparando {a} e {b}.",
    "O texto insiste que {af}, e dá como exemplo {exemplo}.",
    "Também aparece a noção de {conceito}, descrita como {definicao}.",
    "Em outro ponto, lê-se que {af}.",
]


def frase_b():
    conceito, definicao = rng.choice(CONCEITOS)
    a, b = rng.choice(PARES)
    return rng.choice(FRASES_B).format(
        tema=rng.choice(TEMAS_B), exemplo=rng.choice(EXEMPLOS), af=rng.choice(AFIRMACOES),
        conceito=conceito, definicao=definicao, a=a, b=b, n=rng.randint(12, 348),
        dia=rng.choice(["segunda", "terça", "quarta", "quinta", "sexta", "sábado"]))


B_C1 = ("Conclusão minha depois de três semanas testando no curso de estatística: reler os grifos me dá a "
        "impressão de que sei a matéria, mas na semana seguinte quase nada ficou. O que ficou foi o que tentei "
        "lembrar de cabeça, com o caderno fechado, antes de conferir.")
B_C2 = ("E aqui registro uma conclusão minha, não do texto: os blocos de 25 minutos com pausa de 5 não "
        "funcionaram para mim, porque a pausa quebrava o raciocínio no meio das demonstrações; o que funcionou "
        "foi estudar até terminar uma demonstração inteira e parar já no meio do exercício seguinte, porque no "
        "outro dia é muito mais fácil recomeçar de onde parei.")
B_C3 = ("Para fechar este estudo, a conclusão que mais muda a minha rotina: dez minutos de revisão toda manhã, "
        "antes de abrir o e-mail, valem mais do que a revisão longa de domingo, que eu sempre acabava adiando.")


def caderno_b(alvo=120000, n=100):
    titulo = "# Estudo: como a gente aprende e lembra"
    blocos, feito = [titulo], len(titulo)
    for i in range(n):
        if i == 52:  # parágrafo único enorme, sem quebra de linha, com a conclusão no meio
            frases = meio(encher(9200, frase_b), B_C2)
        else:
            frases = encher(orcamento(alvo, feito, i, n, rng.uniform(0.4, 1.6)), frase_b)
            if i == 25:
                frases.append(B_C1)
            if i == 88:
                frases.insert(0, B_C3)
        bloco = " ".join(frases)
        blocos.append(bloco)
        feito += len(bloco) + 2
    return "\n\n".join(blocos)


# ---------------------------------------------------------------- caderno C
ACOES_C = ["lixei as ripas do banco de jardim", "afiei os formões", "colei as pernas do banquinho",
           "desmontei a estante velha para tirar as tábuas", "passei óleo de linhaça na tábua de corte",
           "marquei os encaixes da caixa de ferramentas", "varri e organizei as prateleiras",
           "cortei no serrote as travessas da prateleira", "aplainei à mão a tampa da caixa",
           "testei um encaixe meia-madeira em sobra de pinus", "limpei a cola seca dos grampos",
           "refiz o encaixe que ficou folgado", "montei o gabarito de corte a 45 graus",
           "tirei farpas das tábuas de demolição", "organizei os parafusos por tamanho em potes de vidro"]
OBS_C = ["Ficou torto na primeira tentativa.", "Rendeu menos do que esperava.",
         "Choveu e a madeira empenou um pouco.", "Bom dia de trabalho.", "Faltou grampo.",
         "Música alta na rua, mas deu para trabalhar.", "Precisei refazer uma peça.", "Nada a reclamar."]
PECAS = [("o", "banquinho"), ("a", "caixa de ferramentas"), ("a", "prateleira da cozinha"),
         ("a", "tábua de corte"), ("o", "banco de jardim"), ("o", "porta-temperos"), ("o", "suporte de plantas")]
MADEIRAS = ["pinus", "cedro", "cumaru de demolição", "eucalipto"]
TECNICAS = ["o encaixe rabo de andorinha", "a união com cavilhas", "o acabamento com cera",
            "a afiação em pedra d'água", "a colagem com grampos em cruz"]
FRASES_C = [
    "Fiquei um tempo olhando {o_p} e pensando que {reflexao}.",
    "A parte mais difícil de fazer {o_p} é {dificuldade}.",
    "Vi um vídeo sobre {tecnica} e testei numa sobra de {madeira}; {resultado}.",
    "{Tecnica} pede paciência: {detalhe}.",
    "Anotei as medidas {do_p}: {x} por {y} cm.",
    "Lembrei da oficina do meu avô, onde {memoria}.",
    "O cheiro do {madeira} recém-cortado é o que mais gosto dessas manhãs.",
    "Nem tudo precisa ficar perfeito; {o_p} saiu com marcas e continua útil.",
    "Hoje o trabalho foi mais de arrumação do que de marcenaria: {arrumacao}.",
    "Com a luz da tarde entrando, dá para ver cada irregularidade da superfície.",
    "Medir duas vezes ainda é pouco; marquei errado {o_p} e perdi uma tábua.",
    "Rodei a lixa do grão 80 até o 180 e o toque da madeira mudou completamente.",
    "Deixei a cola secando de um dia para o outro com os grampos bem apertados.",
]


def frase_c():
    g, peca = rng.choice(PECAS)
    tecnica = rng.choice(TECNICAS)
    return rng.choice(FRASES_C).format(
        o_p=f"{g} {peca}", do_p=f"d{g} {peca}", madeira=rng.choice(MADEIRAS),
        tecnica=tecnica, Tecnica=tecnica[0].upper() + tecnica[1:],
        reflexao=rng.choice(["cada peça ensina alguma coisa que a anterior escondeu",
                             "o tempo na garagem desacelera a semana",
                             "a madeira reage à umidade de um jeito que não controlo"]),
        dificuldade=rng.choice(["manter o esquadro", "não arrancar lascas no fim do corte",
                                "esperar a cola secar sem mexer", "segurar o serrote reto"]),
        resultado=rng.choice(["saiu melhor que o anterior", "ficou folgado e vou repetir",
                              "precisa de mais treino", "deu certo na terceira vez"]),
        detalhe=rng.choice(["cada passada tira menos do que parece", "com pressa a peça racha",
                            "o fio precisa estar perfeito antes de começar",
                            "o brilho só aparece depois da terceira camada"]),
        memoria=rng.choice(["o chão vivia coberto de maravalha", "tudo tinha um lugar na parede",
                            "o rádio ficava ligado o dia inteiro"]),
        arrumacao=rng.choice(["separei retalhos por tamanho", "pendurei os serrotes na parede",
                              "etiquetei as gavetas"]),
        x=rng.randint(12, 90), y=rng.randint(8, 45))


def linha_c(data):
    acao = rng.choice(ACOES_C)
    if rng.random() < 0.5:
        return f"{data} — {acao}, {rng.choice(['1', '1,5', '2', '3', '4'])} h."
    return f"{data} — {acao}. {rng.choice(OBS_C)}"


# (fração da posição, tipo, texto; {d} = data do bloco)
PLANTADOS_C = [
    (0.08, "linha", "{d} — Pensando em fazer a bancada de MDF naval, que é mais barato. Ver depois."),
    (0.15, "linha", "{d} — Decidido: a garagem vira oficina só nos fins de semana; durante a semana o carro "
                    "continua dormindo lá dentro. Guardo tudo num carrinho com rodízio para liberar a vaga no "
                    "domingo à noite."),
    (0.40, "paragrafo", "Decidido: a bancada vai ser de peroba reaproveitada das portas antigas da casa, com "
                        "1,80 m por 70 cm; o MDF naval sai da lista porque não aguentaria a plaina nem a umidade "
                        "da garagem."),
    (0.55, "linha", "{d} — Em aberto: instalar um exaustor na janela da garagem ou continuar trabalhando de "
                    "portão aberto? O pó da lixa incomoda a vizinha do lado, e o exaustor que vi custa caro. "
                    "Não resolvi."),
    (0.70, "linha", "{d} — Decidido: nenhuma ferramenta elétrica nova até terminar três peças inteiras só com as "
                    "manuais que já tenho (serrote, plaina e formões)."),
    (0.90, "paragrafo", "Voltei a pensar no exaustor contra o portão aberto e continuo sem resposta; a vizinha "
                        "não reclamou mais, mas o pó da lixa segue igual."),
]


def caderno_c(alvo=200000):
    datas = dias(dt.date(2025, 9, 6), dt.date(2026, 9, 13), {5, 6})
    n = len(datas)
    plantados = {round(f * n): (tipo, texto) for f, tipo, texto in PLANTADOS_C}
    titulo = "# Projeto marcenaria na garagem — registro"
    blocos, feito = [titulo], len(titulo)
    for i, d in enumerate(datas):
        data = f"{['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'][d.weekday()]} {d.day:02d}/{d.month:02d}"
        alvo_bloco = orcamento(alvo, feito, i, n, rng.choice([0.15, 0.3, 1.0, 1.6, 2.0]))
        linhas = [linha_c(data) for _ in range(rng.randint(1, 3))]
        tipo, texto = plantados.get(i, (None, None))
        if tipo == "linha":
            meio(linhas, texto.format(d=data))
        bloco = "\n".join(linhas)
        resto = alvo_bloco - len(bloco)
        if resto > 300 or tipo == "paragrafo":
            frases = encher(max(resto, 600), frase_c)
            if tipo == "paragrafo":
                meio(frases, texto)
            bloco += "\n\n" + " ".join(frases)
        blocos.append(bloco)
        feito += len(bloco) + 2
    return "\n\n".join(blocos)


# ---------------------------------------------------------------- casos
ITENS = ["hormozi.md", "lenny.md"]
GENERO = "Não presume o gênero de quem escreve (nada de «ele», «ela», «o autor» nem adjetivos flexionados para a pessoa)."


def caso(id_, pergunta, caderno, grande, deve, nao_pode, requisitos):
    return {"id": id_, "operacao": "responderNasNotas",
            "entrada": {"pergunta": pergunta, "fontes": [], "itens": ITENS, "caderno": caderno},
            "esperadas": [grande], "resposta_deve": deve, "resposta_nao_pode": nao_pode,
            "requisitos": requisitos, "sintetico": True}


def main():
    a, b, c = caderno_a(), caderno_b(), caderno_c()

    # conferências: tamanho, plantios contados uma vez, nenhum eco no enchimento
    faixas = {"A": (a, 60000), "B": (b, 120000), "C": (c, 200000)}
    for nome, (texto, alvo) in faixas.items():
        assert 0.9 * alvo <= len(texto) <= 1.1 * alvo, (nome, len(texto))
    for texto, trecho, vezes in [
        (a, "Gráfica Pontal", 2), (a, "milheiro", 2), (a, "Débora", 1), (a, "fechamento", 1), (a, "decidido", 1),
        (b.lower(), "conclu", 3), (b, "25 minutos", 1), (b, "dez minutos", 1), (b, "grifos", 1),
        (c.lower(), "decid", 3), (c, "exaustor", 3), (c, "peroba", 1), (c, "bancada", 2), (c, "MDF", 2),
        (c, "elétric", 1), (c.lower(), "em aberto", 1)]:
        assert texto.count(trecho) == vezes, (trecho, texto.count(trecho))
    linhas_b = b.split("\n")
    assert not any(l.startswith("#") for l in linhas_b[1:]), "B tem cabeçalho além do título"
    longo = max(linhas_b, key=len)
    assert len(longo) > 8000 and B_C2 in longo, len(longo)
    assert [d for d in PLANTADOS_A if f"## {d}" not in a] == [], "data plantada fora do diário"
    ordem_c = [c.index(t.split("— ")[-1][:40]) for _, _, t in PLANTADOS_C]
    assert ordem_c == sorted(ordem_c), "plantios de C fora de ordem"

    curtas_a = [nota("Comprar: café, detergente, papel-toalha, pilha AAA, pão de forma"),
                nota("Convites do aniversário da Nina: a Gráfica Estrela cobrou R$ 2,10 por unidade para 150 "
                     "convites. Pagar metade na encomenda."),
                nota("Dentista na quinta, 16h40. Levar o raio-x antigo."),
                nota("Documentário sobre faróis para ver no fim de semana.")]
    curtas_b = [nota("Ideia para a rotina: ler 20 minutos antes de dormir, celular carregando fora do quarto."),
                nota("Mercado: aveia, banana, iogurte natural, café, sabão em pó"),
                nota("Aula de estatística: prova remarcada para 6 de outubro, sala 204."),
                nota("Renovar o seguro do carro até o dia 30.")]
    curtas_c = [nota("Ver preço de verniz marítimo e lixa 220 na loja de ferragens do bairro."),
                nota("Ideia: uma estante de livros para a sala quando a oficina estiver redonda."),
                nota("Levar a cachorra para vacinar sábado de manhã."),
                nota("Bolo de fubá: 3 ovos, 2 xícaras de fubá, 1 de açúcar, 1 de leite, meia de óleo, 1 colher de "
                     "fermento.")]
    cad_a = curtas_a[:1] + [nota(a)] + curtas_a[1:]   # enorme no índice 1
    cad_b = curtas_b[:2] + [nota(b)] + curtas_b[2:]   # índice 2
    cad_c = curtas_c[:3] + [nota(c)] + curtas_c[3:]   # índice 3
    for cad in (cad_a, cad_b, cad_c):
        for n in cad:
            baixo = n["texto"].lower()
            for marca in ["cansad", "sozinh", "eu mesm", "obrigad", "animad", "preocupad", "convencid",
                          "satisfeit", "frustrad", "ocupad"]:
                assert marca not in baixo, marca

    concisa = "Concisa: no máximo umas 6 linhas curtas, sem transcrever trechos longos da nota."
    casos = [
        caso("e9-a-especifica", "Quanto a Gráfica Pontal está cobrando hoje pelo milheiro do folder?", cad_a, 1,
             "Diz que hoje o milheiro do folder institucional na Gráfica Pontal custa R$ 410, valor renegociado "
             "em 15/07/2026 e válido desde agosto (antes tinha sido anunciado R$ 440, e era R$ 380), citando o "
             "Diário de trabalho 2026.",
             "Dar R$ 440 ou R$ 380 como o preço atual, usar o preço de convites da Gráfica Estrela, dizer que não "
             "há registro, inventar condição ou desconto, ou ignorar o diário por ser enorme.",
             ["Responde R$ 410 como o valor vigente do milheiro do folder na Gráfica Pontal.",
              "Não contradiz o diário: R$ 440 e R$ 380 só aparecem como histórico, nunca como preço de hoje.",
              "Não inventa prazo, desconto ou condição que o diário não traz, nem mistura a Gráfica Estrela.",
              concisa,
              "Cita o «Diário de trabalho 2026» como fonte.",
              GENERO]),
        caso("e9-a-ampla", "Quais mudanças importantes eu registrei no diário de trabalho este ano?", cad_a, 1,
             "Resume as três mudanças: o fechamento mensal passou do quinto para o terceiro dia útil a partir de "
             "março (decidido em 11/02); a Débora Quintela saiu do atendimento para a coordenação de compras a "
             "partir de 1º de junho; e o milheiro do folder da Gráfica Pontal, anunciado a R$ 440 em abril, ficou "
             "em R$ 410 desde agosto após negociação.",
             "Dar R$ 440 como valor atual, omitir alguma das três mudanças, encher a resposta com rotina "
             "(reuniões, chamados), inventar mudança, transcrever entradas longas ou dizer que não há registro.",
             ["Traz as três mudanças: fechamento no terceiro dia útil, Débora Quintela em compras e o novo preço "
              "do milheiro na Gráfica Pontal.",
              "Não contradiz: o preço vigente é R$ 410 (o R$ 440 foi corrigido depois).",
              "Não inventa mudança nem data; rotina do diário não vira mudança importante.",
              concisa,
              "Cita o «Diário de trabalho 2026» como fonte.",
              GENERO]),
        caso("e9-b-especifica", "O que eu concluí sobre estudar em blocos de 25 minutos?", cad_b, 2,
             "Diz que os blocos de 25 minutos com pausa de 5 não funcionaram para quem escreve, porque a pausa "
             "quebrava o raciocínio no meio das demonstrações, e que funcionou estudar até terminar uma "
             "demonstração inteira e parar no meio do exercício seguinte, para recomeçar fácil no outro dia.",
             "Dizer que os blocos de 25 minutos funcionaram, dizer que não há conclusão registrada (ela está no "
             "parágrafo enorme), atribuir a conclusão ao texto lido, inventar outro tempo de pausa ou transcrever "
             "o parágrafo.",
             ["Diz que os blocos de 25 minutos não funcionaram e por quê (a pausa quebrava o raciocínio).",
              "Traz o que funcionou: terminar a demonstração e parar no meio do exercício seguinte.",
              "Não inventa nem atribui ao material lido o que é conclusão de quem escreve.",
              concisa,
              "Cita a nota «Estudo: como a gente aprende e lembra» como fonte.",
              GENERO]),
        caso("e9-b-ampla", "Resume o que eu concluí nesse estudo sobre aprender e lembrar.", cad_b, 2,
             "Resume as três conclusões de quem escreve: reler grifos dá impressão de saber mas não fica, o que "
             "fica é tentar lembrar de cabeça com o caderno fechado; os blocos de 25 minutos não funcionaram e "
             "parar no meio do exercício seguinte funcionou; e dez minutos de revisão toda manhã valem mais que a "
             "revisão longa de domingo.",
             "Resumir os capítulos lidos como se fossem conclusões próprias, omitir alguma das três conclusões, "
             "inventar conclusão, transcrever parágrafos ou ignorar a nota enorme.",
             ["Traz as três conclusões: lembrar de cabeça em vez de reler grifos; parar no meio do exercício em "
              "vez de blocos de 25 minutos; dez minutos toda manhã em vez da revisão de domingo.",
              "Separa o que quem escreve concluiu do que os textos lidos dizem.",
              "Não inventa nem contradiz nenhuma das conclusões.",
              concisa,
              "Cita a nota «Estudo: como a gente aprende e lembra» como fonte.",
              GENERO]),
        caso("e9-c-especifica", "De que madeira eu decidi fazer a bancada e com que medida?", cad_c, 3,
             "Diz que a bancada vai ser de peroba reaproveitada das portas antigas da casa, com 1,80 m por 70 cm, "
             "e que o MDF naval saiu da lista.",
             "Dizer que a bancada é de MDF naval (era só uma ideia anterior), inventar outra madeira ou medida, "
             "confundir com o verniz da nota curta, dizer que não há registro ou transcrever o parágrafo.",
             ["Responde peroba reaproveitada das portas antigas.",
              "Responde a medida 1,80 m por 70 cm.",
              "Não contradiz: o MDF naval foi descartado, não escolhido.",
              concisa,
              "Cita a nota «Projeto marcenaria na garagem — registro» como fonte.",
              GENERO]),
        caso("e9-c-ampla", "Quais decisões eu já tomei no projeto da marcenaria e o que ficou em aberto?", cad_c, 3,
             "Lista as três decisões (garagem como oficina só nos fins de semana com o carro lá durante a semana; "
             "bancada de peroba reaproveitada de 1,80 m por 70 cm; nenhuma ferramenta elétrica nova até terminar "
             "três peças com as manuais) e diz que segue sem resposta a dúvida entre instalar exaustor na janela "
             "ou trabalhar de portão aberto por causa do pó.",
             "Dar a questão do exaustor como resolvida, contar a ideia do MDF naval como decisão, inventar uma "
             "quarta decisão, omitir alguma decisão, transcrever trechos longos ou ignorar a nota enorme.",
             ["Traz as três decisões: oficina só nos fins de semana, bancada de peroba 1,80 m × 70 cm e nenhuma "
              "ferramenta elétrica nova até três peças prontas.",
              "Diz que a escolha entre exaustor e portão aberto continua sem resposta.",
              "Não inventa decisão nem trata a ideia do MDF naval como decidida.",
              concisa,
              "Cita a nota «Projeto marcenaria na garagem — registro» como fonte.",
              GENERO]),
    ]
    with open(os.path.join(AQUI, "casos.json"), "w", encoding="utf-8") as f:
        json.dump({"repeticoes": 3, "casos": casos}, f, ensure_ascii=False, indent=1)
        f.write("\n")

    print(f"A  Diário de trabalho 2026: {len(a)} caracteres (alvo 60.000 ±10%)")
    for d, t in PLANTADOS_A.items():
        print(f"   {d} @ {a.index(t) * 100 // len(a)}%: {t}")
    print(f"B  Estudo: {len(b)} caracteres (alvo 120.000 ±10%); parágrafo mais longo {len(longo)}")
    for t in (B_C1, B_C2, B_C3):
        print(f"   @ {b.index(t) * 100 // len(b)}%: {t}")
    print(f"C  Marcenaria: {len(c)} caracteres (alvo 200.000 ±10%)")
    for _, _, t in PLANTADOS_C:
        pedaco = t.split("— ")[-1]
        print(f"   @ {c.index(pedaco[:40]) * 100 // len(c)}%: {pedaco}")
    print("casos:", ", ".join(k["id"] for k in casos))


if __name__ == "__main__":
    main()
