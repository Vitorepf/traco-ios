import Foundation
import Testing

/// O PORTÃO DO MOVIMENTO — a dívida 7 da limpeza de 07/09 (`ferramentas/orca/RUMO.md`),
/// que o juiz do re-G4 da volta 12 nomeou como o achado mais estrutural do dia 06.
///
/// A classe do cross-fade voltou SEIS vezes numa volta só, com TRÊS causas
/// distintas, porque nada impede escrever a curva no ponto de uso: quem digita
/// `withAnimation(.easeOut(duration: 0.25))` numa view escolhe sozinho a classe
/// de movimento, e a classe é justamente o que decide o comportamento sob
/// "Reduzir movimento" (ADR 05y) — que mora em `Tema`, num lugar só.
///
/// Esta varredura NÃO conserta arquivo nenhum: ela congela a dívida de hoje
/// para que ela não cresça. Quem zera é a volta por tela, nos seus arquivos.
struct PortaoDoMovimentoTests {
    /// A DÍVIDA CONGELADA em 08/09/2026 — um caminho por linha, com quantas
    /// vezes o arquivo move por conta própria hoje. Arquivo fora desta lista,
    /// ou número acima do congelado, é volta que criou dívida de movimento: o
    /// teste fica vermelho e diz o que fazer.
    ///
    /// COMO ZERAR (é a volta POR TELA quem faz, cada uma só nos seus arquivos):
    /// trocar a curva literal por um movimento nomeado em `Tema` e o
    /// `withAnimation` por `.animation(_:value:)` sobre
    /// `Tema.movimento(_:_:reduzido:)`; baixar o número aqui no mesmo commit;
    /// apagar a linha quando chegar a zero.
    ///
    /// `TracoWidget/` não aparece: fora do app não há dívida de movimento
    /// nenhuma, e esta lista existe para que continue assim.
    static let faltosos: [String: Int] = [
        "Traco/App/Camadas.swift": 3,
        "Traco/App/RaizView.swift": 6,
        "Traco/Caderno/CadernoView.swift": 4,
        "Traco/Caderno/EditorBlocoView.swift": 2,
        "Traco/Calendario/CalendarioEscalas.swift": 10,
        "Traco/Calendario/CalendarioView.swift": 6,
        "Traco/Confirmacao/FechoExpressivaView.swift": 4,
        "Traco/Ditado/DitadoProprioView.swift": 1,
        "Traco/Ditado/FolhaDeConfirmacao.swift": 2,
        "Traco/Notas/NotasView.swift": 5,
        "Traco/Notas/RedeView.swift": 2,
        "Traco/Padroes/PadroesView.swift": 2,
        "Traco/Pagina/CamposFormaView.swift": 3,
        "Traco/Pagina/LenteView.swift": 2,
        "Traco/Pagina/PaginaView.swift": 7,
        "Traco/Perfil/PerfilView.swift": 1,
        "Traco/Recordar/RecordarView.swift": 9,
        "Traco/Trabalho/IntercambioTrabalhoView.swift": 5,
        "Traco/Trabalho/TrabalhoView.swift": 2,
    ]

    /// O único isento: é onde a lei mora.
    static let ondeAsCurvasMoram = "Traco/Tema.swift"

    /// Mover por conta própria é uma destas coisas: chamar `withAnimation`,
    /// nomear uma curva do SwiftUI em vez de citar `Tema`, ou escrever duração
    /// em número cru. `Tema.Duracao.media` e `Tema.Mola.toque` não casam aqui —
    /// é exatamente o que se quer ler numa view.
    static let movimentoSolto =
        #"withAnimation\(|\.(easeInOut|easeIn|easeOut|linear|spring|interpolatingSpring|interactiveSpring|timingCurve)\(|\.(bouncy|smooth|snappy)\b|\bAnimation\.|\.repeatForever|duration:\s*[0-9]|\.delay\(\s*[0-9]"#

    /// A varredura é sobre TEXTO de fonte, então ela apaga antes o que não é
    /// código: o comentário depois de `//` e o miolo de `"…"`. Sem isso a linha
    /// 410 de `PerfilView.swift` — que fala de `withAnimation` em prosa — seria
    /// vermelha por escrever sobre o defeito. Teto conhecido: string de várias
    /// linhas (`"""`) fecha o resto da linha de abertura, o que erra para o lado
    /// de não acusar; nenhuma existe hoje nos fontes varridos.
    static func semComentarioNemTexto(_ linha: Substring) -> String {
        var fora = ""
        var dentroDeTexto = false
        var anterior: Character = " "
        for c in linha {
            if c == "\"" && anterior != "\\" {
                dentroDeTexto.toggle()
                anterior = c
                continue
            }
            if !dentroDeTexto && c == "/" && anterior == "/" {
                fora.removeLast()
                break
            }
            if !dentroDeTexto { fora.append(c) }
            anterior = c
        }
        return fora
    }

    static func fontes(_ raiz: URL) -> [String] {
        var achados: [String] = []
        for pasta in ["Traco", "TracoWidget"] {
            let base = raiz.appending(path: pasta)
            guard let caminhada = FileManager.default.enumerator(
                at: base, includingPropertiesForKeys: nil) else { continue }
            for caso in caminhada {
                guard let url = caso as? URL, url.pathExtension == "swift" else { continue }
                let relativo = pasta + "/"
                    + url.path.replacingOccurrences(of: base.path + "/", with: "")
                if relativo != ondeAsCurvasMoram { achados.append(relativo) }
            }
        }
        return achados.sorted()
    }

    @MainActor @Test func nenhumMovimentoNovoForaDeTema() throws {
        let raiz = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let fontes = Self.fontes(raiz)
        // sem esta linha, um caminho errado deixaria a varredura vazia e VERDE
        #expect(fontes.count > 100, "a varredura não achou os fontes: \(fontes.count) arquivos")
        #expect(FileManager.default.fileExists(
            atPath: raiz.appending(path: Self.ondeAsCurvasMoram).path),
                "o isento mudou de lugar: \(Self.ondeAsCurvasMoram)")

        let solto = try Regex(Self.movimentoSolto)
        var contagem: [String: Int] = [:]
        var vistas: [String] = []
        for caminho in fontes {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            for (n, linha) in texto.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                let codigo = Self.semComentarioNemTexto(linha)
                let quantos = codigo.matches(of: solto).count
                guard quantos > 0 else { continue }
                contagem[caminho, default: 0] += quantos
                vistas.append("\(caminho):\(n + 1): \(codigo.trimmingCharacters(in: .whitespaces))")
            }
        }

        var divergencias: [String] = []
        for caminho in Set(contagem.keys).union(Self.faltosos.keys).sorted() {
            let hoje = contagem[caminho] ?? 0
            let congelado = Self.faltosos[caminho] ?? 0
            guard hoje != congelado else { continue }
            divergencias.append("\(caminho): \(hoje) hoje, \(congelado) congelado"
                + (hoje > congelado ? "  ← SUBIU" : "  ← desceu"))
        }
        #expect(divergencias.isEmpty, Comment(rawValue: """
            movimento fora de Tema em desacordo com a dívida congelada:
            \(divergencias.joined(separator: "\n"))

            SUBIU: não escreva a curva no ponto de uso. `Tema.movimento(classe, curva,
            reduzido:)` é quem decide sob Reduzir Movimento, e a classe errada é o
            cross-fade que voltou seis vezes na volta 12 (ADR 05y).
            DESCEU: a migração está feita — baixe o número em `faltosos`, e apague a
            linha quando chegar a zero.

            o que a varredura viu:
            \(vistas.joined(separator: "\n"))
            """))
    }
}
