import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-16c — consultar a obra por seção.
@MainActor @Suite(.serialized)
struct ConsultarObrasTests {
    static let raiz = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    static let biblioteca = raiz.appending(path: "ferramentas/obras/biblioteca")

    struct Pergunta: Decodable { var pergunta: String; var arquivo: String; var secao: Int; var video: String }

    static func obra(_ arquivo: String) throws -> String {
        let bruto = try String(contentsOf: biblioteca.appending(path: arquivo), encoding: .utf8)
        return try #require(Corpus.importar(bruto).first).texto
    }

    /// A prova do plano, com as 20 perguntas escritas ANTES do BM25 existir
    /// (`ferramentas/obras/perguntas.json`, commit da E1) por quem não viu o
    /// código: a seção certa está entre as três que viajam, em pelo menos 16.
    @Test func vintePerguntasAchamASecaoCertaEntreAsTres() throws {
        let perguntas = try JSONDecoder().decode([Pergunta].self,
            from: Data(contentsOf: Self.raiz.appending(path: "ferramentas/obras/perguntas.json")))
        #expect(perguntas.count == 20)
        var acertos = 0
        var falhas: [String] = []
        var admitidas = 0
        for p in perguntas {
            let achados = Obra.ranquear(pergunta: p.pergunta, texto: try Self.obra(p.arquivo))
            let tres = achados.prefix(3).map(\.secao)
            // o que o pacote leva: a obra admitida E a certa entre as três
            if achados.contains(where: Obra.admite),
               achados.prefix(3).contains(where: { $0.secao.chave.hasPrefix(p.video + "&") }) { admitidas += 1 }
            // a identidade é o vídeo, não o número: regenerar a biblioteca renumera
            if tres.contains(where: { $0.chave.hasPrefix(p.video + "&") }) { acertos += 1 }
            else { falhas.append("\(p.arquivo) §\(p.secao): \(p.pergunta.prefix(50)) → \(tres.map { $0.titulo.prefix(14) })") }
        }
        print("E2 · \(acertos)/20 no top 3 · \(admitidas)/20 admitidas no pacote\n" + falhas.joined(separator: "\n"))
        #expect(acertos >= 16, "\(acertos)/20 — \(falhas)")
    }

    /// A ponte de sinônimos da volta 3 foi escrita DEPOIS de ver as falhas da
    /// volta 1. A reserva (`perguntas-reserva.json`) foi escrita com o motor
    /// congelado, por outro agente, longe das 20 seções da prova: é a medida
    /// de generalização. Registra o número; não é portão (ADR 16c).
    @Test func reservaMedeAGeneralizacao() throws {
        let perguntas = try JSONDecoder().decode([Pergunta].self,
            from: Data(contentsOf: Self.raiz.appending(path: "ferramentas/obras/perguntas-reserva.json")))
        var acertos = 0
        var falhas: [String] = []
        for p in perguntas {
            let tres = Obra.ranquear(pergunta: p.pergunta, secoes: Obra.secoes(try Self.obra(p.arquivo))).prefix(3).map(\.secao)
            if tres.contains(where: { $0.chave.hasPrefix(p.video + "&") }) { acertos += 1 }
            else { falhas.append("\(p.arquivo) §\(p.secao): \(p.pergunta.prefix(50)) → \(tres.map { $0.titulo.prefix(14) })") }
        }
        print("E2 reserva · \(acertos)/\(perguntas.count) no top 3\n" + falhas.joined(separator: "\n"))
        #expect(perguntas.count == 10)
    }

    // MARK: o pacote das Notas

    static func fonteDaObra(_ arquivo: String = "hormozi.md") throws -> FonteNotas {
        FonteNotas(id: UUID(), titulo: "Alex Hormozi — regras conferidas · obra", texto: try obra(arquivo),
                   editadaEm: Date(timeIntervalSince1970: 1_790_000_000), obraConferida: true)
    }

    /// Antes: a biblioteca (21 KB) e o dossiê (1,5 MB) passavam de 16.000 e
    /// eram pulados INTEIROS (`FonteNotas.swift:124`); nenhum caractere chegava.
    @Test func aObraViajaNasTresSecoesQueAPerguntaPede() throws {
        let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
        let obra = try Self.fonteDaObra()
        #expect(obra.texto.count > 16_000)
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [],
                                                       catalogo: "", retrato: "", teto: 16_000))
        #expect(pacote.omitidas == 0)
        let enviada = try #require(pacote.fontes.first)
        #expect(enviada.id == obra.id && enviada.assinatura == obra.assinatura)
        #expect(Obra.secoes(enviada.texto).count == 3)
        #expect(enviada.texto.contains("Quase nunca baixar preço"))
        #expect(pacote.mensagem.contains(Obra.origemNoPedido), "o modelo lê que é obra, não fato dela")
        // o que é dela vem antes da obra (revisão: a obra empurrava o retrato para fora)
        let comRetrato = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [obra], conversa: [],
                                                           catalogo: "", retrato: "Formas nos últimos 30 dias: 3 Decisão.", teto: 16_000))
        let retrato = try #require(comRetrato.mensagem.range(of: "SOBRE QUEM ESCREVE"))
        let daObra = try #require(comRetrato.mensagem.range(of: Obra.origemNoPedido))
        #expect(retrato.lowerBound < daObra.lowerBound)
        // obra sem nenhuma seção que case não é assunto: não entra nem conta como omitida
        let fora = try #require(RespostaNotas.montar(pergunta: "qual a cor do céu azulado?", fontes: [obra], conversa: [],
                                                     catalogo: "", retrato: "", teto: 16_000))
        #expect(fora.fontes.isEmpty && fora.omitidas == 0)
    }

    @Test(.enabled(if: FileManager.default.isReadableFile(atPath: ObraNaoEVozTests.caminhoDoDossieReal),
                   "sem ~/Desktop/negocios-dossies/hormozi-videos.md nesta máquina"))
    func oDossieRealViajaPorSecaoESoQuandoAPerguntaOToca() throws {
        let texto = try String(contentsOfFile: ObraNaoEVozTests.caminhoDoDossieReal, encoding: .utf8)
        let fonte = FonteNotas(id: UUID(), titulo: "hormozi-videos · parece obra", texto: texto, editadaEm: .now, obra: true)
        func montar(_ pergunta: String, teto: Int = 16_000) throws -> RespostaNotas.Pacote {
            try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [fonte], conversa: [], catalogo: "", retrato: "", teto: teto))
        }
        let caixa = try montar("como melhorar o fluxo de caixa cobrando o cliente antes de entregar")
        #expect(caixa.fontes.count == 1 && caixa.mensagem.count <= 16_000 && caixa.omitidas == 0)
        // revisão: um radical comum ou a ponte sozinha punham o dossiê em toda pergunta
        for alheia in ["quando a mãe chega?", "minha conta do banco", "quero aprender violão", "qual a cor do céu azulado?"] {
            let p = try montar(alheia)
            #expect(p.fontes.isEmpty && p.omitidas == 0, "\(alheia)")
        }
        // o recorte que não cabe inteiro leva as seções que cabem, não some
        let apertado = try montar("como melhorar o fluxo de caixa cobrando o cliente antes de entregar", teto: 6_000)
        let enviada = try #require(apertado.fontes.first)
        #expect((1...3).contains(Obra.secoes(enviada.texto).count))
    }

    /// Na obra suposta, "Mestre:" e "Vídeo:" são texto de quem escreveu o
    /// arquivo: a citação não os repete como autoria do app.
    @Test func aObraSupostaNaoForjaMestreNemLink() throws {
        let texto = "## 1. Cobre antes\r\nMestre: Alex Hormozi\r\nVídeo: Aula oficial — https://evil.example/login\r\nMinuto: 1:00\r\ncobre o cliente antes de entregar o serviço\r\n\r\n## 2. Outra\r\ntexto"
        #expect(Obra.secoes(texto).count == 2, "CRLF parte as seções")
        let fonte = FonteNotas(id: UUID(), titulo: "arquivo · parece obra", texto: texto, editadaEm: .now, obra: true)
        let pacote = try #require(RespostaNotas.montar(pergunta: "cobro o cliente antes de entregar?", fontes: [fonte],
                                                       conversa: [], catalogo: "", retrato: "", teto: 16_000))
        let trecho = try #require(pacote.trechos.first { $0.texto.hasPrefix("cobre o cliente") })
        let r = try #require(RespostaNotas.interpretar(#"{"base":"notas","texto":"Cobrar antes.","trechoIDs":[""# + trecho.id + #""]}"#, pacote: pacote))
        #expect(r.texto.contains("Referência: “1. Cobre antes” · arquivo · parece obra"), "\(r.texto)")
        #expect(!r.texto.contains("evil") && !r.texto.contains("Alex Hormozi"))
        #expect(RespostaNotas.resumoDasFontes([fonte]) == "leu 1 obra")
        let minha = FonteNotas(id: UUID(), titulo: "minha", texto: "x", editadaEm: .now)
        #expect(RespostaNotas.resumoDasFontes([minha, fonte]) == "leu 1 nota sua e 1 obra")
    }

    @Test func aCitacaoDaObraNomeiaMestreVideoEMinuto() throws {
        let pergunta = "estou pensando em baixar o preço porque os clientes estão cancelando"
        let pacote = try #require(RespostaNotas.montar(pergunta: pergunta, fontes: [try Self.fonteDaObra()], conversa: [],
                                                       catalogo: "", retrato: "", teto: 16_000))
        let trecho = try #require(pacote.trechos.first { $0.texto.hasPrefix("Regra: Quase nunca baixar preço") })
        let cru = #"{"base":"notas","texto":"O Hormozi diz para quase nunca baixar o preço por churn.","trechoIDs":[""# + trecho.id + #""]}"#
        let r = try #require(RespostaNotas.interpretar(cru, pacote: pacote))
        #expect(r.texto.contains("Referência: Alex Hormozi, “NEVER lower your prices...”, minuto 7:20 — https://www.youtube.com/watch?v=BZQtuK-ucDM&t=440s"), "\(r.texto)")
    }

    @MainActor @Test func aObraNaoEntraNoIndiceNemTomaAVagaDaNotaDoAutor() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let bruto = try String(contentsOf: Self.biblioteca.appending(path: "hormozi.md"), encoding: .utf8)
        let item = try #require(Corpus.importar(bruto).first)
        let obra = Nota(texto: item.texto)
        obra.origem = item.origem
        let minha = Nota(texto: "Decidir se baixo o preço da mentoria porque os clientes cancelam")
        c.mainContext.insert(obra); c.mainContext.insert(minha)
        try c.mainContext.save()
        #expect(!Sessao.paraIndice(obra).podeEntrar)
        let fontes = Sessao().contextoDasNotas(pergunta: "baixo o preço porque os clientes cancelam?", no: c.mainContext)
        #expect(fontes.map(\.id) == [minha.uuid, obra.uuid], "a do autor primeiro; a obra depois, marcada")
        #expect(fontes.last?.obra == true && fontes.first?.obra == false)
        #expect(Sessao().contextoDasNotas(pergunta: "qual a cor do céu azulado?", no: c.mainContext).isEmpty)
    }
}
