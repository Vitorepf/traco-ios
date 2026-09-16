import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-16b — a biblioteca de regras conferidas.
///
/// `ferramentas/obras/biblioteca.py` escreve um `.md` por mestre; aqui se
/// confere o que o APP faz com eles: cada arquivo entra como UMA obra, cada
/// seção traz regra, mestre, vídeo, minuto, data e etiqueta dentro do teto, e a
/// obra não aparece na lista de Notas.
@MainActor
struct BibliotecaObrasTests {
    static let pasta = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "ferramentas/obras/biblioteca")

    @Test func cadaArquivoEntraComoUmaObraDeRegrasConferidas() throws {
        let arquivos = try FileManager.default.contentsOfDirectory(at: Self.pasta, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "md" }
        #expect(arquivos.count == 2, "um arquivo por mestre: Hormozi e Lenny")
        var total = 0
        for arquivo in arquivos {
            let conteudo = try String(contentsOf: arquivo, encoding: .utf8)
            let itens = Corpus.importar(conteudo)
            #expect(itens.count == 1 && itens.first?.origem == .obra, "\(arquivo.lastPathComponent)")
            let secoes = conteudo.components(separatedBy: "\n## ").dropFirst()
            for secao in secoes {
                let texto = "## " + secao.trimmingCharacters(in: .whitespacesAndNewlines)
                #expect(texto.count <= 1_000, "\(texto.prefix(60))")
                // a condição é campo do formato: a lacuna honesta é "não dita"
                for rotulo in ["Regra: ", "Condição: ", "Mestre: ", "Vídeo: ", "Minuto: ", "Data: ", "Etiqueta: "] {
                    #expect(texto.contains("\n" + rotulo), "\(rotulo) em \(texto.prefix(60))")
                }
                #expect(texto.range(of: #"Vídeo: .+ — https://www\.youtube\.com/watch\?v=[A-Za-z0-9_-]{11}&t=\d+s"#,
                                    options: .regularExpression) != nil)
                #expect(texto.range(of: #"\nEtiqueta: (mecanismo|relato|crença|saúde)"#, options: .regularExpression) != nil)
            }
            total += secoes.count
        }
        #expect((50...100).contains(total), "\(total) regras")
    }

    /// Revisão adversária da E1: esconder a obra DEDUZIDA apagava da vista a
    /// nota "## 1. Metas de 2027" do próprio autor, sem tela para achá-la.
    @Test func soAObraDeclaradaSaiDaListaEDaBusca() {
        let declarada = Nota(texto: "# Alex Hormozi — regras conferidas\n\n## 1. Cobre antes de entregar\nRegra: cobre antes")
        declarada.origem = .obra
        let suposta = Nota(texto: "## 1. Metas de 2027\n- cobrar antes de entregar")
        suposta.origem = .obraSuposta
        let minha = Nota(texto: "Cobrar antes de entregar o projeto")
        let lista = NotasFiltro.visiveis([declarada, suposta, minha], busca: "", filtro: nil)
        #expect(lista.map(\.uuid) == [suposta.uuid, minha.uuid], "a deduzida fica à vista, com «parece obra»")
        #expect(suposta.origem.etiqueta == "parece obra" && suposta.vozDoAutor.isEmpty)
        #expect(NotasFiltro.visiveis([declarada, minha], busca: "cobre antes", filtro: nil).map(\.uuid) == [minha.uuid])
        declarada.trancada = true
        #expect(NotasFiltro.visiveis([declarada], busca: "", filtro: .trancadas).map(\.uuid) == [declarada.uuid])
    }
}
