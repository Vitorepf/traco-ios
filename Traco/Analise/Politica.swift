import Foundation

/// ADR 2026-09-07b — QUEM responde cada operação de IA, e por quê. Uma tabela
/// só, lida pelas rotas e mostrada no Perfil. Antes dela eram cinco políticas
/// soltas (a escada da sábia, a do Trabalho, três `contaLigada`, a de três
/// degraus da classificação e o domínio só de bordo), e o modelo do aparelho
/// seguia em oito rotas onde a medição de 07/09 diz que ele não serve.
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
    }

    enum Provedor: String, Sendable {
        case grok = "Grok"
        case bordo = "Apple Intelligence no aparelho"
    }

    struct Linha: Sendable {
        let regra: Regra
        /// A evidência, datada. É o que o Perfil mostra e o que uma volta
        /// futura tem de derrubar para mudar a regra.
        let porque: String
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
            .init(regra: .soGrok, porque: "o aparelho confirmou 3 de 3 um ponto explicitamente contradito e perdeu 3 de 3 uma paráfrase correta; o veredito vira sinal gravado — prova/qualidade-ia-q5-avaliacao-base.md")
        case .ecos:
            .init(regra: .soGrok, porque: "sem retorno 6 de 6 no aparelho — prova/qualidade-ia-q5-avaliacao-base.md")
        case .calibragem:
            .init(regra: .soGrok, porque: "vazio 6 de 6 no aparelho, com o positivo perdido — prova/qualidade-ia-q5-avaliacao-base.md")
        case .padroes:
            .init(regra: .soGrok, porque: "falhou 3 de 3 e 2 de 3 no aparelho; as perguntas locais cobrem — prova/qualidade-ia-q5-avaliacao-base.md")
        case .recordar:
            .init(regra: .soGrok, porque: "3 de 3 no aparelho: duas sem retorno e uma pergunta que revelava a resposta; a frase fixa do ritual cobre — prova/qualidade-ia-q5-avaliacao-base.md")
        case .responderNasNotas:
            .init(regra: .grokDepoisBordo, porque: "o aparelho acertou os fatos 3 de 3 e não citou a nota 3 de 3; o contrato de fontes está em revisão (ADR 07a)")
        case .responder, .instigar, .contrapor:
            .init(regra: .grokDepoisBordo, porque: "sem medição; pergunta e resposta curtas cabem na janela do aparelho")
        case .vestir:
            .init(regra: .grokDepoisBordo, porque: "a forma local decide antes; o modelo só vê blocos pendentes (ADR 07a)")
        case .classificar:
            .init(regra: .grokDepoisBordo, porque: "o aparelho acertou 3 de 3 com esquema tipado; as regex arbitram por último (ADR 04c/06h)")
        case .dominio:
            .init(regra: .soBordo, porque: "rótulo fechado com esquema tipado sobre 2.000 caracteres; o léxico cobre sem modelo")
        }
    }

    /// Quem responde AGORA. `nil` = ninguém: a rota cala ou a tela diz.
    static func provedor(_ op: Operacao,
                         contaLigada: Bool = ContaGrok.ligada,
                         bordo: Bool = Sabia.noAparelho) -> Provedor? {
        switch linha(op).regra {
        case .soGrok: contaLigada ? .grok : nil
        case .soBordo: bordo ? .bordo : nil
        case .grokDepoisBordo: contaLigada ? .grok : (bordo ? .bordo : nil)
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
        case .ecos: "Ecos entre notas precisam da conta Grok; o modelo do aparelho não os encontrou."
        case .calibragem: "Ler o seu juízo pela IA precisa da conta Grok."
        case .padroes, .recordar: "Precisa da conta Grok; o modelo do aparelho não serviu aqui."
        case .responderNasNotas, .responder, .instigar, .contrapor, .vestir, .classificar:
            "A sábia precisa da sua conta Grok (em Perfil) ou da Apple Intelligence ligada."
        case .dominio: "O domínio pela IA precisa da Apple Intelligence ligada; sem ela, o léxico decide."
        }
    }

    /// Para o Perfil: o que o aparelho faz sozinho e o que exige a conta.
    static var pelaConta: [Operacao] { Operacao.allCases.filter { linha($0).regra == .soGrok } }
    static var peloAparelho: [Operacao] { Operacao.allCases.filter { linha($0).regra != .soGrok } }

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
