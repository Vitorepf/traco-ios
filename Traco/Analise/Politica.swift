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
            .init(regra: .indisponivelPorQualidade, porque: "sem retorno 6 de 6 no aparelho; e com a conta ligada em 08/09 o Grok devolveu lista vazia justamente onde o vínculo era o mais útil (18 inscritos contra a sala que comporta 15) — 3 de 6 casos reprovados — ferramentas/orca/q-qualidade.md, corridas em prova/q-qualidade-avaliacoes.jsonl",
                  motivo: "deixa de fora justamente as notas que mais tinham a ver",
                  medidaEm: "08/09/2026")
        case .calibragem:
            .init(regra: .indisponivelPorQualidade, porque: "vazio 6 de 6 no aparelho; com a conta ligada em 08/09 o Grok cala quando não há erro a apontar e a rota nem chega ao provedor com um par só — no máximo 3 de 6 casos — ferramentas/orca/q-qualidade.md",
                  motivo: "não diz nada quando você não errou",
                  medidaEm: "08/09/2026")
        case .padroes:
            .init(regra: .soGrok, porque: "falhou 3 de 3 e 2 de 3 no aparelho; as perguntas locais cobrem — prova/qualidade-ia-q5-avaliacao-base.md")
        case .recordar:
            .init(regra: .indisponivelPorQualidade, porque: "3 de 3 no aparelho; e com a conta ligada em 08/09 o Grok vazou o alvo (a guarda de Prova.vaza suprimiu a pergunta e o autor ficou sem nada) ou devolveu a resposta dentro do enunciado — 1 de 6 casos — ferramentas/orca/q-qualidade.md. A frase fixa do ritual continua cobrindo",
                  motivo: "entrega a resposta junto com a pergunta",
                  medidaEm: "08/09/2026")
        case .responderNasNotas:
            .init(regra: .soGrok,
                  porque: "VOLTOU em 10/09, com a comparação pareada que a DIRETRIZ §10 pede. O LOTE-09d correu a MESMA fixture nos dois modelos, na mesma janela (02:27:24Z–02:33:03Z), com uma instalação só e a conta conferida ligada nas três fumaças: `grok-4.5` passa os 7 casos × 3 (21 de 21) e `grok-4.3` passa 12 de 21 — calcula os R$ 3.354 e NÃO diz os R$ 2.646 em 3 de 3, e expõe os 18 inscritos contra a sala de 15 sem o próximo ato em 3 de 3. A linha de base ficou intacta nos DOIS (cotação na conversa, prazo, sem lastro e instrução hostil, 6 de 6 cada) e `escreveuRotuloInterno` é false nas 42 saídas, lidas inteiras. Por isso o executor é o Grok com o modelo MEDIDO desta rota (`Sabia.modeloMedido`), e não o padrão global — que fica no 4.3 porque o 4.5 é pior no `contrapor`. O aparelho continua fora: ele acertou os fatos 3 de 3 e não citou a nota 3 de 3 (ADR 09h) — prova/lote09d-q3-grok-4.3.jsonl, prova/lote09d-q3-grok-4.5.jsonl e ferramentas/orca/q3-responder-nas-notas.md")
        case .responder:
            .init(regra: .indisponivelPorQualidade,
                  porque: "cortada em 08/09 (a 08q mediu 3 de 6: horário de biblioteca e um total de R$ 1.008 que o contexto não sustentava). O contrato de sustentação em `sistemaResponder` matou a fabricação de NÚMERO (0 em 108 execuções na 08z) e FICA. A Q2-F (ADR 09q) refez a escolha do modelo com UMA alavanca e não achou substituto: `grok-4.3` 15 de 18, `grok-4.5` 17, `grok-4.6` 16, nenhum chega a 18. A ADR 2026-09-10b atacou a alavanca seguinte — o PROMPT — com o conserto que a Q2-F nomeara, e ele NÃO FECHA: duas reescritas medidas contra a base no MESMO binário, 20 casos × 3 cada, deram base **14 e 15 de 20** nas duas janelas, e candidato **12 de 20** nas duas. O defeito é simétrico e nenhuma das duas o separou: mandar ajudar traz de volta a estrutura inventada do documento ('abra o PDF', 'vá ao sumário'), e mandar não inventar faz o modelo parar em 'não consta X' sem o próximo ato (`revisor-orcamento-cotacao-datada` 3 de 3 → 0 de 3 no candidato 1). `revisor-responsavel-nao-definido` reprova 1 de 3 nas duas tentativas. Por isso o conserto do prompt saiu daqui: ele foi tentado e medido. A alavanca seguinte da ordem da Astra é o CONTEXTO. 240 saídas lidas uma a uma, mais 6 de uma pergunta REAL do aparelho da conta; prova/10b/, prova/10b2/ e ferramentas/orca/responder.md",
                  motivo: "inventa uma situação que você não escreveu, e às vezes só diz o que falta",
                  medidaEm: "10/09/2026")
        case .instigar:
            .init(regra: .indisponivelPorQualidade,
                  porque: "com a conta ligada em 08/09 o Grok devolveu ao autor o vocabulário interno que o app passa no pedido ('o movimento básico que se pula', 'neste degrau 0', 'a forma nota') — 1 de 6 casos — ferramentas/orca/q-qualidade.md; o conserto tirou o andaime e o G3 do LOTE-1 achou três defeitos novos. O LOTE-3 mediu a Q4-B (6 casos × 3 em grok-4.3 e em grok-4.5) e DERRUBOU dois: o degrau 4 deixou de repetir as perguntas do degrau 0 (3 de 3 nos dois modelos) e a proibição por procedência devolveu o método e o degrau que o AUTOR escreveu (3 de 3 nos dois, inclusive com 'metodo' sem acento). Sobrou o texto magro: as perguntas saem vagas e não pedem QUANDO aconteceu — 3 de 3 no grok-4.3 e 2 de 3 no grok-4.5 — prova/lote09c-q4-grok-4.3.jsonl, prova/lote09c-q4-grok-4.5.jsonl e ferramentas/orca/revisao-q4-instigar.md",
                  motivo: "quando você escreveu pouco, pergunta vago e não pergunta quando aconteceu",
                  medidaEm: "10/09/2026",
                  conserto: "falta ela perguntar quando aconteceu mesmo quando você escreveu pouco")
        case .contrapor:
            .init(regra: .indisponivelPorQualidade,
                  porque: "com a conta ligada em 08/09 o Grok sustentou o contraponto em fato inventado, sempre no campo outroCampo ('metanálises de 2022', preço 12% menor na construção naval do século XV) — 1 de 6 casos — ferramentas/orca/q-qualidade.md; o conserto matou a evidência fabricada e ela não voltou. O LOTE-3 (6 casos × 3 em grok-4.3 e em grok-4.5) achou dois defeitos VIVOS: renda que a nota não declara — 1 de 3 no grok-4.3 e 3 de 3 no grok-4.5, e a lista de fatoQueEleNaoDeu exclui 'renda' de propósito — e contraponto que não chega onde a nota dá matéria: Falha.semRetorno com HTTP 200 e conteúdo completo no grok-4.5 rep. 2 do CSV e no grok-4.3 rep. 1 do tudo-ou-nada, mais um campo 'contra' vazio no grok-4.3 rep. 2 do CSV. O semRetorno com resposta inteira é defeito do NOSSO motor e tem volta própria (Q4-C) — prova/lote09c-q4-grok-4.3.jsonl, prova/lote09c-q4-grok-4.5.jsonl e ferramentas/orca/revisao-q4-instigar.md",
                  motivo: "inventa uma renda que você não escreveu, e às vezes não responde",
                  medidaEm: "10/09/2026",
                  conserto: "falta ela não inventar renda sua, e nunca voltar em branco quando tem o que dizer")
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
        // ADR 09v: a `responderNasNotas` SAIU desta lista em 10/09 e virou
        // `.soGrok` — a frase dela agora é a de quem só precisa de conta.
        // As SEIS abaixo continuam INDISPONÍVEIS POR QUALIDADE (ADR 08q; a
        // `responder` saiu da lista na 09n e VOLTOU no mesmo dia, quando o G3
        // reprovou a escolha do modelo): a conta pode estar ligada e mesmo
        // assim ninguém responde, porque o que respondia não atendeu.
        //
        // ADR 09z — a LÍNGUA destas seis é a do autor, e este é o pior lugar
        // possível para o nosso jargão: ele lê isto NO MOMENTO em que toca a
        // operação e ela não acontece. Sem data, sem "medida", sem causa
        // nossa: o que ela ainda não faz por ele, no presente, e o que ele
        // pode fazer agora. A frase não manda conectar conta, não pede para
        // tentar de novo e não promete guardar nada — quem guardou o pedido é
        // que diz isso, depois de confirmar.
        case .responder: "Responder à sua pergunta pela IA está indisponível: ela ainda inventa uma situação que você não escreveu e, às vezes, só diz o que falta em vez de ajudar. O que você escreveu continua aqui, e a sua pergunta fica na nota."
        case .ecos: "Ecos entre notas está indisponível: a IA ainda deixa de fora justamente as notas que mais tinham a ver. As suas notas continuam buscáveis pelo texto."
        case .calibragem: "Ler o seu juízo pela IA está indisponível: ela ainda não diz nada quando você não errou. Os seus pares de previsão e resultado continuam aqui para você comparar."
        case .recordar: "A pergunta do Recordar pela IA está indisponível: ela ainda entrega a resposta junto com a pergunta. O ritual segue com a pergunta fixa."
        case .instigar: "Instigar pela IA está indisponível: quando você escreveu pouco, ela ainda pergunta vago e não pergunta quando aconteceu. As perguntas do método continuam na página."
        case .contrapor: "Contrapor pela IA está indisponível: ela ainda inventa uma renda que você não escreveu e, às vezes, não responde. O Steelman e a Inversão continuam no catálogo, escritos por você."
        case .responderNasNotas: "Responder as perguntas que você deixa nas notas precisa da sua conta Grok (em Perfil)."
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
