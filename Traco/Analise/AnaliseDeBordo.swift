import FoundationModels
import Foundation

/// A análise NO APARELHO (ADR 2026-09-03k): o modelo do sistema, sem conta,
/// sem rede, sem token, sem nada saindo do iPhone.
///
/// Por que isto muda a premissa: até aqui o cérebro do Traço era CONDICIONAL —
/// dependia de o autor ter ligado a conta Grok e de haver sinal. No avião, no
/// metrô, sem assinatura, ele caía nas quinze regex do motor local. Agora a
/// escada tem um degrau novo no meio, e ele é o padrão.
///
/// E o contrato fechado deixa de ser INSTRUÇÃO e vira TIPO. O `AnaliseRemota`
/// pede um rótulo de lista fixa e depois confere com `parseVeredito`, porque um
/// modelo por HTTP pode devolver o que quiser. Aqui o `@Generable` faz a
/// geração ser guiada pelo schema: o modelo não *pode* emitir um caso que não
/// existe. A classe inteira de falha que aquele parser existe para pegar —
/// rótulo inventado, chave extra, texto livre no lugar do JSON — some.
///
/// O que NÃO muda: a §2 continua de pé. Isto classifica, e só. Nenhuma palavra
/// deste modelo chega à tela; o que o autor lê é sempre do app ou dele.
@available(iOS 26.0, *)
nonisolated enum AnaliseDeBordo {
    /// ADR 06g: NÃO existe mais uma lista de formas escrita à mão aqui.
    /// Até esta volta conviviam neste arquivo um `@Generable enum GestoDeBordo`
    /// com dez casos e um `instrucoes` com dez definições — mortos desde a ADR
    /// 04l, que passou o esquema e o prompt para `Catalogo.todos`, e vivos o
    /// bastante para fazer três leitores (um deles o orquestrador) concluírem
    /// que o modelo de bordo só conhecia dez formas. Código morto que descreve
    /// um contrato falso é pior que código morto. O que vale é `esquema()` e
    /// `instrucoesDoCatalogo`, logo abaixo, e o teste que trava a divergência.

    /// Existe modelo neste aparelho? Falso no simulador sem Apple Intelligence,
    /// em aparelho antigo, e enquanto o modelo ainda está baixando.
    static var disponivel: Bool {
        SystemLanguageModel.default.isAvailable || nuvemPrivada != nil
    }

    /// iOS 27: o modelo maior da Apple na nuvem privada (Private Cloud
    /// Compute) — sem conta, sem cobrança, e o texto não vai a terceiros. Onde
    /// existe, é ele o executor "de bordo"; o modelo pequeno do aparelho fica
    /// para quando não há rede. Uma decisão só, aqui, para as quatro sessões.
    ///
    /// DESLIGADO na compilação (bandeira `NUVEM_PRIVADA`): o entitlement
    /// `com.apple.developer.private-cloud-compute` não é concedido à conta de
    /// desenvolvedor (15/09, a assinatura para o iPhone recusou), e sem ele o
    /// FoundationModels ABORTA o processo na primeira chamada. Quando a Apple
    /// liberar a capacidade: entitlement no `project.yml` e
    /// `SWIFT_ACTIVE_COMPILATION_CONDITIONS: NUVEM_PRIVADA`.
    #if NUVEM_PRIVADA
    @available(iOS 27.0, *)
    private enum Nuvem {
        static let modelo: PrivateCloudComputeLanguageModel? = {
            let m = PrivateCloudComputeLanguageModel()
            return m.isAvailable ? m : nil
        }()
    }

    static var nuvemPrivada: (any Sendable)? {
        if #available(iOS 27.0, *) { return Nuvem.modelo }
        return nil
    }

    /// A sessão de bordo: nuvem privada quando há, senão o modelo do aparelho.
    static func sessao(instructions: String) -> LanguageModelSession {
        if #available(iOS 27.0, *), let nuvem = Nuvem.modelo {
            return LanguageModelSession(model: nuvem, instructions: instructions)
        }
        return LanguageModelSession(instructions: instructions)
    }
    #else
    static var nuvemPrivada: (any Sendable)? { nil }

    /// A sessão de bordo: o modelo do aparelho.
    static func sessao(instructions: String) -> LanguageModelSession {
        LanguageModelSession(instructions: instructions)
    }
    #endif

    /// Verdadeiro quando a sessão de bordo corre na nuvem privada — quem conta
    /// tokens contra `SystemLanguageModel.default` não deve fazê-lo aí.
    static var naNuvemPrivada: Bool { nuvemPrivada != nil }

    /// Em uma linha, para o Perfil — honesto como o da conta Grok.
    static var estadoEmPalavras: String {
        if naNuvemPrivada { return "nuvem privada da Apple — sem conta, o texto não sai para terceiros" }
        return switch SystemLanguageModel.default.availability {
        case .available:
            "pronto — funciona sem conta e sem internet"
        case .unavailable(.deviceNotEligible):
            "este aparelho não tem o modelo do sistema."
        case .unavailable(.appleIntelligenceNotEnabled):
            "ligue a Apple Intelligence nos Ajustes para a análise funcionar sem rede."
        case .unavailable(.modelNotReady):
            "o modelo do sistema ainda está baixando."
        case .unavailable:
            "o modelo do sistema não está disponível agora."
        }
    }

    /// O esquema, gerado do CATÁLOGO (ADR 04l fechada de vez): a lista fechada
    /// continua sendo TIPO — o modelo não pode emitir um id que não existe —,
    /// mas o tipo nasce do `Metodos.json` em tempo de execução, não de um
    /// enum. Um método do autor entra aqui sem código.
    static func esquema() throws -> GenerationSchema {
        var ids = Catalogo.todos.map(\.id).filter { $0 != Gesto.expressiva.rawValue }
        ids.append("expressiva")
        ids.append("nenhum")
        let gesto = DynamicGenerationSchema(name: "GestoDeBordo", description: "A forma que o texto pede. 'nenhum' quando não é nenhuma delas.", anyOf: ids)
        // iOS 27: o tipo nomeado entra UMA vez, como dependência; a propriedade
        // o cita por referência. Inline e em `dependencies` ao mesmo tempo dava
        // "Duplicate type GestoDeBordo in schema Escolha" e a classificação de
        // bordo morria calada (suíte de 15/09).
        let raiz = DynamicGenerationSchema(name: "Escolha", properties: [
            DynamicGenerationSchema.Property(name: "gesto", description: "A forma que o texto pede.",
                                             schema: DynamicGenerationSchema(referenceTo: "GestoDeBordo")),
        ])
        return try GenerationSchema(root: raiz, dependencies: [gesto])
    }

    /// As definições, do catálogo — as mesmas do prompt remoto, palavra por
    /// palavra, porque vêm do mesmo arquivo. Ligar a conta não muda o roteamento.
    static var instrucoesDoCatalogo: String {
        let linhas = Catalogo.todos
            .filter { $0.id != Gesto.expressiva.rawValue }
            .map { "\($0.id) = \($0.paraRoteador)" }
        return """
        Você é a Análise de um bloco de notas em português. Você NUNCA escreve texto:
        você apenas CLASSIFICA em uma das formas abaixo.

        \(linhas.joined(separator: "\n"))
        expressiva = desabafo emocional longo
        nenhum = nada disso

        Na dúvida, nenhum. Silêncio é resposta válida.
        """
    }

    /// ADR 05d: o domínio da nota, pelo modelo de bordo. nil = falha (fica o
    /// léxico); .some(nil) = nenhum. Respeita o portão.
    static func dominio(texto: String) async -> Dominio?? {
        guard !Motores.desligados, disponivel else { return nil }
        let prosa = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prosa.isEmpty else { return nil }
        let ids = Dominio.allCases.map(\.rawValue) + ["nenhum"]
        let rotulo = DynamicGenerationSchema(name: "DominioDeBordo", description: "A área da vida de que o texto trata.", anyOf: ids)
        let raiz = DynamicGenerationSchema(name: "EscolhaDominio", properties: [
            DynamicGenerationSchema.Property(name: "dominio", description: "A área da vida.",
                                             schema: DynamicGenerationSchema(referenceTo: "DominioDeBordo")),
        ])
        let sessao = sessao(instructions: """
        Você classifica um texto em português numa ÁREA DA VIDA. Você nunca escreve texto.
        trabalho = emprego, clientes, projetos, prazos, colegas
        casa = a casa em si, contas da casa, reforma, compras da casa, vizinhos
        saude = corpo, sono, remédio, consulta, treino, terapia
        dinheiro = dinheiro, contas, investimento, dívida, imposto
        pessoas = família, amigos, relações, encontros
        estudo = aprender, ler, curso, aula, prova, livro
        ideias = uma ideia, um insight, uma hipótese, um conceito
        nenhum = nada disso, ou impossível dizer
        O lugar onde algo acontece não é a área: "chegar em casa e ler" é estudo, não casa.
        Na dúvida, nenhum.
        """)
        guard let esquema = try? GenerationSchema(root: raiz, dependencies: [rotulo]),
              let r = try? await sessao.respond(to: String(prosa.prefix(2000)), schema: esquema),
              let escolhido = try? r.content.value(String.self, forProperty: "dominio")
        else { return nil }
        return Dominio.doModelo(escolhido)
    }

    /// Classifica sem sair do aparelho.    /// Classifica sem sair do aparelho. Devolve nil em qualquer falha — e aí o
    /// chamador desce a escada, exatamente como faz com o remoto.
    ///
    /// Respeita o portão (ADR 03p): é isto que o app chama.
    static func classificar(texto: String, gestoAtual: Gesto?) async -> AnaliseLocal.Veredito? {
        guard !Motores.desligados else { return nil }
        return await classificarSemPortao(texto: texto, gestoAtual: gestoAtual)
    }

    /// O motor, sem o portão. Existe para os testes PROVAREM o modelo de
    /// verdade — o portão desliga tudo na suíte, e um motor que nunca roda é um
    /// motor que ninguém sabe se funciona. O app nunca chama esta.
    static func classificarSemPortao(texto: String, gestoAtual: Gesto?) async -> AnaliseLocal.Veredito? {
        guard disponivel, gestoAtual != .expressiva else { return nil }
        let prosa = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prosa.isEmpty else { return nil }
        let sessao = sessao(instructions: instrucoesDoCatalogo)
        guard let esquema = try? esquema(),
              let r = try? await sessao.respond(to: String(prosa.prefix(4000)), schema: esquema),
              let escolhido = try? r.content.value(String.self, forProperty: "gesto")
        else { return nil }
        if escolhido == "expressiva" { return .expressiva }
        guard escolhido != "nenhum", let g = Gesto(rawValue: escolhido), g.conhecido else { return .silencio }
        // a pergunta é do TEMPLATE, sempre — igual ao remoto (§19.4)
        return .gesto(g, pergunta: AnaliseLocal.pergunta(g))
    }
}
