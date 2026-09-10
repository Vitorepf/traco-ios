import Foundation

/// ADR 2026-09-07b — QUEM responde cada operação de IA, e por quê. Uma tabela
/// só, lida pelas rotas e mostrada no Perfil. Antes dela eram cinco políticas
/// soltas (a escada da sábia, a do Trabalho, três `contaLigada`, a de três
/// degraus da classificação e o domínio só de bordo), e o modelo do aparelho
/// seguia em oito rotas onde a medição de 07/09 diz que ele não serve.
///
/// ADR 2026-09-08q acrescentou a quarta regra: `indisponivelPorQualidade`.
/// Até ela, a tabela só sabia dizer "falta conta"; a medida de 08/09 no
/// aparelho do dono, com a conta LIGADA, reprovou seis operações — e mandar
/// conectar uma conta que já existe é mentira na tela.
///
/// A regra nasce da MEDIÇÃO (DIRETRIZ §5: medir, não torcer), e cada linha
/// carrega a prova. Mudar de provedor é mudar esta tabela, e a prova junto.
/// O modelo do aparelho tem 3 bilhões de parâmetros e 4.096 tokens de janela
/// compartilhada entre pedido e resposta; serve para rotular, extrair e
/// escolher entre rótulos fechados com esquema tipado. Não serve para gerar
/// texto longo fiel a restrições, nem para julgar com citação literal.
enum Politica {
    enum Operacao: String, CaseIterable, Sendable {
        case produzir, prepararPratica, conferirTentativa, revisar
        case responderNasNotas, responder, instigar, contrapor, vestir
        case recordar, conferir, ecos, calibragem, padroes
        case classificar, dominio
    }

    enum Regra: Equatable, Sendable {
        /// Grok quando há conta; senão o modelo do aparelho. Para o que o
        /// aparelho já provou ou ainda não reprovou.
        case grokDepoisBordo
        /// Só o Grok. O aparelho foi medido nesta operação e não serviu;
        /// sem conta a tela DIZ, em vez de descer calada a um resultado pior.
        case soGrok
        /// Só o aparelho: rótulo curto, esquema tipado, sem rede.
        case soBordo
        /// NINGUÉM responde: a operação foi medida COM a conta ligada e o que
        /// respondia não atendeu. A linha fica na tabela, com o motivo datado
        /// e a prova — o que sai é o EXECUTOR, não o registro. É distinta de
        /// `soGrok` sem conta: aqui a conta existe, e mandar conectá-la seria
        /// mentira. Volta a ter executor quando algum passar a MESMA matriz.
        case indisponivelPorQualidade
    }

    enum Provedor: String, Sendable {
        case grok = "Grok"
        case bordo = "Apple Intelligence no aparelho"
    }

    struct Linha: Sendable {
        let regra: Regra
        /// A evidência, datada. É o que sustenta a regra e vai para a ADR:
        /// contagem ("3 de 6"), caso concreto e caminho da prova.
        let porque: String
        /// O que a TELA mostra: uma oração curta, em linguagem de pessoa, sem
        /// data e sem caminho de prova — a falha MEDIDA naquela operação, não
        /// um diagnóstico geral. Vazio nas linhas que ainda têm executor: quem
        /// responde não precisa de motivo, e o Perfil só lê este campo na
        /// lista das indisponíveis por qualidade (onde o teste exige que
        /// exista). Não é opcional de propósito — a tela escreve `l.motivo`
        /// sem desembrulhar nem inventar substituto.
        let motivo: String
        /// A data da medida que sustenta a regra, como o autor a lê. A tabela
        /// é UMA só (07b): o Perfil lê daqui em vez de guardar uma cópia que
        /// envelhece sozinha.
        let medidaEm: String?
        /// Só para `indisponivelPorQualidade`: o conserto já nomeado, quando
        /// existe. `nil` = reprovada sem substituto nem conserto conhecido —
        /// e a tela não promete volta que ninguém pode datar.
        let conserto: String?

        init(regra: Regra, porque: String, motivo: String = "",
             medidaEm: String? = nil, conserto: String? = nil) {
            self.regra = regra
            self.porque = porque
            self.motivo = motivo
            self.medidaEm = medidaEm
            self.conserto = conserto
        }
    }

    static func linha(_ op: Operacao) -> Linha {
        switch op {
        case .produzir:
            .init(regra: .soGrok, porque: "o aparelho reprovou 3 de 3 no roteiro de espanhol (minutos que não fecham, palavra inglesa no material) — prova/4.md e prova/qualidade-ia-avaliacao-base.md, 07/09")
        case .prepararPratica, .conferirTentativa:
            .init(regra: .soGrok, porque: "3 de 3 exercícios e 3 de 3 feedbacks do aparelho saíram no formato e não serviram; 0 critérios avaliados por citação não literal — prova/6.md")
        case .revisar:
            .init(regra: .soGrok, porque: "dois casos reais do aparelho sem revisão utilizável: JSON inválido e citações não literais — prova/5.md")
        case .conferir:
            .init(regra: .soGrok, porque: "o aparelho confirmou 3 de 3 um ponto explicitamente contradito e perdeu 3 de 3 uma paráfrase correta; o Grok acertou 6 de 6 casos com a conta ligada em 08/09 — prova/qualidade-ia-q5-avaliacao-base.md e prova/q-qualidade-avaliacoes.jsonl")
        case .ecos:
            .init(regra: .indisponivelPorQualidade, porque: "sem retorno 6 de 6 no aparelho; e com a conta ligada em 08/09 o Grok devolveu lista vazia justamente onde o vínculo era o mais útil (18 inscritos contra a sala que comporta 15) — 3 de 6 casos reprovados — prova/q-qualidade.md, corridas em prova/q-qualidade-avaliacoes.jsonl",
                  motivo: "deixou de fora os vínculos mais úteis",
                  medidaEm: "08/09/2026")
        case .calibragem:
            .init(regra: .indisponivelPorQualidade, porque: "vazio 6 de 6 no aparelho; com a conta ligada em 08/09 o Grok cala quando não há erro a apontar e a rota nem chega ao provedor com um par só — no máximo 3 de 6 casos — prova/q-qualidade.md",
                  motivo: "calou quando não havia erro a apontar",
                  medidaEm: "08/09/2026")
        case .padroes:
            .init(regra: .soGrok, porque: "falhou 3 de 3 e 2 de 3 no aparelho; as perguntas locais cobrem — prova/qualidade-ia-q5-avaliacao-base.md")
        case .recordar:
            .init(regra: .indisponivelPorQualidade, porque: "3 de 3 no aparelho; e com a conta ligada em 08/09 o Grok vazou o alvo (a guarda de Prova.vaza suprimiu a pergunta e o autor ficou sem nada) ou devolveu a resposta dentro do enunciado — 1 de 6 casos — prova/q-qualidade.md. A frase fixa do ritual continua cobrindo",
                  motivo: "entregou a resposta dentro da pergunta",
                  medidaEm: "08/09/2026")
        case .responderNasNotas:
            .init(regra: .indisponivelPorQualidade,
                  porque: "o aparelho acertou os fatos 3 de 3 e não citou a nota 3 de 3; com a conta ligada em 08/09 o Grok recusava por inteiro a pergunta que pedia fato atual — prova/q-qualidade.md. O conserto da Q3-B foi MEDIDO no LOTE-3 (7 casos × 3 em grok-4.3 e em grok-4.5, uma janela, uma instalação): a meia-recusa da conversa acabou (6 de 6 calculam os R$ 3.354 com a cotação que a pessoa deu, contra 0 de 3 antes), o HOJE chega em fuso local e nenhum rótulo interno escapou nas 42 saídas. O que sobrou é a conta pela METADE: em q3-gasto-cotacao-na-nota as 6 execuções calculam os R$ 3.354 e NENHUMA diz os R$ 2.646 nem faz a subtração do teto; e o conflito com o limite da sala ainda reprova 2 de 3 no grok-4.3 (3 de 3 no grok-4.5) — prova/lote09c-q3-grok-4.3.jsonl, prova/lote09c-q3-grok-4.5.jsonl e ferramentas/orca/revisao-q3-notas.md",
                  motivo: "faz a conta do gasto e para antes de dizer quanto sobra do seu orçamento",
                  medidaEm: "10/09/2026",
                  conserto: "terminar a conta — dizer quanto sobra do teto em toda repetição — e resolver o conflito de listas também no modelo que o app usa; falta medir")
        case .responder:
            .init(regra: .indisponivelPorQualidade,
                  porque: "cortada em 08/09 (a 08q mediu 3 de 6: horário de biblioteca e um total de R$ 1.008 que o contexto não sustentava). O contrato de sustentação em `sistemaResponder` matou a fabricação de NÚMERO (0 em 108 execuções na 08z) e FICA. A escolha do modelo, que a 09n adotou e o G3 reprovou, foi refeita na Q2-F (ADR 09q) com UMA alavanca: dos doze modelos da conta, nove saem por frase da API (cinco `Model not found`, quatro recusam `reasoningEffort`), e os três que servem a requisição correram os 12 casos da 08z mais os 6 cegos do revisor, três vezes, com `medium` fixo — `grok-4.3` 15 de 18, `grok-4.5` 17 de 18, `grok-4.6` 16 de 18. NENHUM chega a 18, e o padrão atual reprova um caso cego em 3 de 3. prova/q2f-*.jsonl e ferramentas/orca/q2f-responder.md",
                  motivo: "inventou cenário que o contexto não sustentava",
                  medidaEm: "09/09/2026",
                  conserto: "o prompt já mata a invenção de número; trocar de modelo não resolve (três medidos, nenhum passou) — falta o prompt impedir também a invenção da ESTRUTURA de um documento")
        case .instigar:
            .init(regra: .indisponivelPorQualidade,
                  porque: "com a conta ligada em 08/09 o Grok devolveu ao autor o vocabulário interno que o app passa no pedido ('o movimento básico que se pula', 'neste degrau 0', 'a forma nota') — 1 de 6 casos — prova/q-qualidade.md; o conserto tirou o andaime e o G3 do LOTE-1 achou três defeitos novos. O LOTE-3 mediu a Q4-B (6 casos × 3 em grok-4.3 e em grok-4.5) e DERRUBOU dois: o degrau 4 deixou de repetir as perguntas do degrau 0 (3 de 3 nos dois modelos) e a proibição por procedência devolveu o método e o degrau que o AUTOR escreveu (3 de 3 nos dois, inclusive com 'metodo' sem acento). Sobrou o texto magro: as perguntas saem vagas e não pedem QUANDO aconteceu — 3 de 3 no grok-4.3 e 2 de 3 no grok-4.5. O LOTE-5 (Q4-C, mesma fixture, 10/09 10:55Z-11:10Z) promoveu a cobrança do QUANDO para o alto de sistemaInstigar e DERRUBOU esse: o texto magro pede o quando e cumpre as TRÊS pernas em 6 de 6, contra 1 de 6 antes. Em troca comprou o defeito OPOSTO, medido: a cobrança passou a mandar onde não devia, e em q4-instigar-com-metodo-decisao rep. 2 do grok-4.3 as perguntas voltaram como gabarito nu ('O que aconteceu? / Quando aconteceu? / O que seria dar certo?') sem a sala, o limite de R$ 1.000 nem os clientes que aquela linha da fixture cobra — 1 de 30 repetições com matéria, 0 de 30 na base, e nenhuma no grok-4.5. E o caso extremo é a ponta, não o tamanho: contando pergunta a pergunta, a cláusula promovida não substituiu perguntas, ACRESCENTOU, e as perguntas ancoradas na nota caíram de 49/51 (96%) para 48/63 (76%) no grok-4.3 e de 59/61 (97%) para 63/71 (89%) no grok-4.5. A alavanca seguinte é condicionar o requisito à MATÉRIA da nota, numa frase, não promover nem proibir mais — prova/lote09e-q4-grok-4.3.jsonl, prova/lote09e-q4-grok-4.5.jsonl e ferramentas/orca/q4-instigar-contrapor.md",
                  motivo: "acrescenta perguntas de gabarito que não falam da sua nota",
                  medidaEm: "10/09/2026",
                  conserto: "pedir o quando SÓ quando a sua nota deixa pouco a examinar; com matéria, as perguntas saem do que você escreveu; escrito, falta medir")
        case .contrapor:
            .init(regra: .indisponivelPorQualidade,
                  porque: "com a conta ligada em 08/09 o Grok sustentou o contraponto em fato inventado, sempre no campo outroCampo ('metanálises de 2022', preço 12% menor na construção naval do século XV) — 1 de 6 casos — prova/q-qualidade.md; o conserto matou a evidência fabricada e ela não voltou. O LOTE-3 (6 casos × 3 em grok-4.3 e em grok-4.5) achou dois defeitos VIVOS: renda que a nota não declara — 1 de 3 no grok-4.3 e 3 de 3 no grok-4.5, e a lista de fatoQueEleNaoDeu exclui 'renda' de propósito — e contraponto que não chega onde a nota dá matéria: Falha.semRetorno com HTTP 200 e conteúdo completo no grok-4.5 rep. 2 do CSV e no grok-4.3 rep. 1 do tudo-ou-nada, mais um campo 'contra' vazio no grok-4.3 rep. 2 do CSV. O semRetorno com resposta inteira é defeito do NOSSO motor e teve volta própria (Q4-C). O LOTE-5 (mesma fixture, 72 execuções, 10/09 10:55Z-11:10Z) DERRUBOU os dois: renda que a nota não declara passou de 4 para 0, e semRetorno com HTTP 200 de 2 para 0 — a ADR 09s separou 'não li' de 'li e a guarda não deixou nada passar', e a 09i subiu a proibição por procedência para dentro do bloco Proibido. O conferidor mecânico INALTERADO (lote-ia-09c-guardas.py) foi de 68/72 para 72/72. O que falta é a leitura de mérito de quem não escreveu os casos — prova/lote09e-q4-grok-4.3.jsonl, prova/lote09e-q4-grok-4.5.jsonl e ferramentas/orca/q4-instigar-contrapor.md",
                  motivo: "os dois defeitos medidos caíram; falta a leitura de quem não os escreveu",
                  medidaEm: "10/09/2026",
                  conserto: "feito e medido: não atribui mais renda que você não escreveu, e resposta inteira nunca mais vira silêncio; falta a leitura de mérito")
        case .vestir:
            .init(regra: .grokDepoisBordo, porque: "a forma local decide antes; o modelo só vê blocos pendentes (ADR 07a)")
        case .classificar:
            .init(regra: .grokDepoisBordo, porque: "o aparelho acertou 3 de 3 com esquema tipado; as regex arbitram por último (ADR 04c/06h)")
        case .dominio:
            .init(regra: .soBordo, porque: "rótulo fechado com esquema tipado sobre 2.000 caracteres; o léxico cobre sem modelo")
        }
    }

#if DEBUG
    /// ADR 2026-09-08z — SÓ PARA A SONDA. Uma operação cortada por qualidade
    /// não tem executor, e sem executor não há como MEDIR o conserto: a sonda
    /// bate em `nil` antes de alcançar o provedor. Esta chave abre a linha
    /// para o Grok apenas no binário de avaliação, e a sonda grava em cada
    /// registro do JSONL quais operações foram liberadas — a medida diz de si
    /// mesma em que condição foi feita. Nunca existe em Release, e o app do
    /// autor continua vendo a tabela como ela é.
    ///   xcrun simctl launch ... SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=responder
    nonisolated static let liberadasParaAvaliacao: Set<String> = Set(
        (ProcessInfo.processInfo.environment["TRACO_AVALIAR_LIBERAR"] ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
#endif

    /// Quem responde AGORA. `nil` = ninguém: a rota cala ou a tela diz.
    static func provedor(_ op: Operacao,
                         contaLigada: Bool = ContaGrok.ligada,
                         bordo: Bool = Sabia.noAparelho) -> Provedor? {
        switch linha(op).regra {
        case .soGrok: contaLigada ? .grok : nil
        case .soBordo: bordo ? .bordo : nil
        case .grokDepoisBordo: contaLigada ? .grok : (bordo ? .bordo : nil)
        case .indisponivelPorQualidade:
#if DEBUG
            liberadasParaAvaliacao.contains(op.rawValue) && contaLigada ? .grok : nil
#else
            nil
#endif
        }
    }

    /// A regra deixa o aparelho responder quando o Grok não respondeu?
    static func desceAoAparelho(_ op: Operacao) -> Bool {
        linha(op).regra == .grokDepoisBordo
    }

    /// A frase para a tela quando ninguém responde. Uma por operação, sem
    /// culpar o aparelho pelo que ele não promete.
    static func semProvedor(_ op: Operacao) -> String {
        switch op {
        case .produzir: "Preparar uma versão pela IA precisa da conta Grok (em Perfil); o modelo do aparelho não produziu com qualidade."
        case .prepararPratica, .conferirTentativa: PraticaTrabalho.semProvedor
        case .revisar: RevisaoTrabalho.semProvedor
        case .conferir: "Conferir o que voltou pela IA precisa da conta Grok; o modelo do aparelho errou a comparação."
        case .padroes: "Precisa da conta Grok; o modelo do aparelho não serviu aqui."
        // As SEIS abaixo estão INDISPONÍVEIS POR QUALIDADE (ADR 08q; a
        // `responder` saiu da lista na 09n e VOLTOU no mesmo dia, quando o G3
        // reprovou a escolha do modelo — o conserto do prompt ficou, a
        // comparação pareada é que falta): a conta
        // pode estar ligada e mesmo assim ninguém responde, porque o que
        // respondia não atendeu na medida — 08/09 para três delas, 10/09 para
        // as três que o LOTE-3 remediu (ADR 09t). A frase não manda conectar
        // conta, não pede para tentar de novo e não promete guardar nada — quem
        // guardou o pedido é que diz isso, depois de confirmar.
        case .responder: "Responder à sua pergunta pela IA está indisponível: na medida de 08/09 ela inventou fato que o contexto não sustentava. O que você escreveu continua aqui, e a sua pergunta fica na nota."
        case .ecos: "Ecos entre notas está indisponível: a IA deixou de fora justamente os vínculos mais úteis quando medimos, em 08/09. As notas continuam buscáveis pelo texto."
        case .calibragem: "Ler o seu juízo pela IA está indisponível: na medida de 08/09 ela calou quando não havia erro a apontar. Os seus pares de previsão e resultado continuam aqui para você comparar."
        case .recordar: "A pergunta do Recordar pela IA está indisponível: na medida de 08/09 ela entregou a resposta dentro da própria pergunta. O ritual segue com a pergunta fixa."
        case .instigar: "Instigar pela IA está indisponível: na medida de 10/09, num texto curto, ela fez perguntas vagas e não pediu quando aconteceu. As perguntas do método continuam na página."
        case .contrapor: "Contrapor pela IA está indisponível: na medida de 10/09 ela inventou renda que você não escreveu e, às vezes, calou onde a sua nota dava matéria. O Steelman e a Inversão continuam no catálogo, escritos por você."
        case .responderNasNotas: "Responder sobre as suas notas pela IA está indisponível: na medida de 10/09 ela fez a conta do seu gasto e parou antes de dizer quanto sobra do seu orçamento. A busca pelo texto das notas continua."
        case .vestir, .classificar:
            "A sábia precisa da sua conta Grok (em Perfil) ou da Apple Intelligence ligada."
        case .dominio: "O domínio pela IA precisa da Apple Intelligence ligada; sem ela, o léxico decide."
        }
    }

    /// O que a TELA DIZ, no ponto em que o autor tocou. `nil` = há quem
    /// responda e a rota segue. ADR 2026-09-09q: `semProvedor` já existia com
    /// uma frase por operação, mas cada rota decidia sozinha se perguntava —
    /// e a Lente perguntava a `Sabia.disponivel`, que responde "sim" com a
    /// conta ligada mesmo quando a tabela diz que ninguém responde. Resultado:
    /// o autor tocava "Instigar", via o laço girar e recebia uma VIBRAÇÃO.
    /// Uma linha aqui, e a resposta é a mesma em toda rota.
    static func aviso(_ op: Operacao, contaLigada: Bool = ContaGrok.ligada,
                      bordo: Bool = Sabia.noAparelho) -> String? {
        provedor(op, contaLigada: contaLigada, bordo: bordo) == nil ? semProvedor(op) : nil
    }

    /// Para o Perfil: o que o aparelho faz sozinho, o que exige a conta, e o
    /// que NÃO TEM MAIS EXECUTOR. As três listas juntas são as dezesseis; uma
    /// operação indisponível por qualidade não pode aparecer nas outras duas,
    /// porque isso prometeria ao autor uma ajuda que ele não vai receber.
    static var pelaConta: [Operacao] { Operacao.allCases.filter { linha($0).regra == .soGrok } }
    static var peloAparelho: [Operacao] {
        Operacao.allCases.filter { linha($0).regra == .soBordo || linha($0).regra == .grokDepoisBordo }
    }
    static var indisponiveis: [Operacao] {
        Operacao.allCases.filter { linha($0).regra == .indisponivelPorQualidade }
    }

    static func nome(_ op: Operacao) -> String {
        switch op {
        case .produzir: "preparar versões no Trabalho"
        case .prepararPratica: "preparar exercícios"
        case .conferirTentativa: "conferir a sua tentativa"
        case .revisar: "revisar uma versão"
        case .responderNasNotas: "responder nas Notas"
        case .responder: "responder à sua pergunta"
        case .instigar: "instigar"
        case .contrapor: "contrapor"
        case .vestir: "vestir a forma"
        case .recordar: "a pergunta do Recordar"
        case .conferir: "conferir o que voltou"
        case .ecos: "ecos entre notas"
        case .calibragem: "ler o seu juízo"
        case .padroes: "perguntas dos Padrões"
        case .classificar: "reconhecer a forma"
        case .dominio: "o domínio da nota"
        }
    }
}
