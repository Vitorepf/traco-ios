import Foundation
import Testing

/// O PORTÃO DO MOVIMENTO — a dívida 7 da limpeza de 07/09 (`ferramentas/orca/RUMO.md`),
/// que o juiz do re-G4 da volta 12 nomeou como o achado mais estrutural do dia 06.
///
/// A classe do cross-fade voltou SEIS vezes numa volta só, com TRÊS causas
/// distintas, porque nada impede escrever a curva no ponto de uso: quem digita
/// `.easeOut(duration: 0.25)` numa view escolhe sozinho a classe de movimento,
/// e a classe é justamente o que decide o comportamento sob "Reduzir
/// movimento" (ADR 05y) — que mora em `Tema`, num lugar só.
///
/// O que o portão conta é **curva ou duração LITERAL escrita fora de `Tema`**.
/// Passar uma `Animation` DENTRO de uma chamada a `Tema.…(…)` /
/// `CalendarioTema.…(…)` é a forma que a própria ADR manda escrever — a
/// assinatura `Tema.movimento(_:_:reduzido:)` exige a curva no ponto de
/// chamada — e por isso a varredura apaga o miolo dessas chamadas antes de
/// contar. O que ela NÃO apaga lá dentro é número cru: `Tema.Duracao.*` existe
/// para isso, e `duration: 0.25` continua sendo a decisão tomada na view.
struct PortaoDoMovimentoTests {
    /// A DÍVIDA CONGELADA em 08/09/2026 — e ela nasce **VAZIA**, porque foi isso
    /// que a medição deu: nenhum fonte de `Traco/` ou `TracoWidget/` escreve
    /// curva ou duração literal fora de `Tema` hoje. As 38 chamadas de
    /// `withAnimation(` do repositório passam todas por `Tema.*` ou
    /// `CalendarioTema.morph`. O portão existe para que continue assim.
    ///
    /// Se um arquivo aparecer aqui um dia, é porque alguém decidiu conviver com
    /// a dívida por uma volta: o número desce no mesmo commit da migração e a
    /// linha sai quando zera.
    static let faltosos: [String: Int] = [:]

    /// O único isento: é onde a lei mora.
    static let ondeAsCurvasMoram = "Traco/Tema.swift"

    /// Curva do SwiftUI nomeada no ponto de uso. Medida no texto **sem** o miolo
    /// das chamadas a `Tema.`/`CalendarioTema.`: dentro delas a curva é o
    /// argumento que a assinatura pede.
    static let curvaLiteral =
        #"\.(easeInOut|easeIn|easeOut|linear|spring|interpolatingSpring|interactiveSpring|timingCurve)\(|\.(bouncy|smooth|snappy)\b|\bAnimation\.|\.repeatForever"#

    /// Número cru de tempo ou de mola. Medida no texto **com** o miolo das
    /// chamadas a `Tema.` — `Tema.movimento(.opacidade, .easeOut(duration: 0.25),
    /// reduzido:)` é a curva decidida na view, e o portão a acusa.
    static let numeroCru =
        #"(duration|response|dampingFraction|stiffness):\s*[0-9]|\.delay\(\s*[0-9]"#

    /// A varredura é sobre TEXTO de fonte, então ela apaga antes o que não é
    /// código: o comentário depois de `//` e o miolo de `"…"`. Sem isso a linha
    /// 410 de `PerfilView.swift` — que fala de `withAnimation` em prosa — seria
    /// vermelha por escrever sobre o defeito. Com `apagandoTema`, apaga também o
    /// que estiver entre os parênteses de uma chamada a `Tema.`/`CalendarioTema.`,
    /// inclusive quando ela ocupa várias linhas.
    ///
    /// Tetos conhecidos, os dois errando para o lado de NÃO acusar: string de
    /// várias linhas (`"""`) fecha o resto da linha de abertura; e parêntese
    /// desbalanceado dentro de string, dentro de chamada a `Tema.`, engole
    /// o resto. Nenhum dos dois existe hoje nos fontes varridos.
    static func codigoVisivel(_ texto: String, apagandoTema: Bool) -> String {
        var fora = ""
        var dentroDeTexto = false
        var escapado = false
        var emComentario = false
        var profundidade = 0
        var anterior: Character = " "
        var token = ""
        for c in texto {
            if c == "\n" {
                fora.append("\n")
                dentroDeTexto = false; escapado = false; emComentario = false
                anterior = "\n"; token = ""
                continue
            }
            if emComentario { fora.append(" "); continue }
            if dentroDeTexto {
                if escapado { escapado = false }
                else if c == "\\" { escapado = true }
                else if c == "\"" { dentroDeTexto = false }
                fora.append(" "); anterior = c; continue
            }
            if profundidade > 0 {
                if c == "(" { profundidade += 1 } else if c == ")" { profundidade -= 1 }
                fora.append(" "); anterior = c; continue
            }
            if c == "\"" {
                dentroDeTexto = true; fora.append(" "); anterior = c; token = ""; continue
            }
            if c == "/" && anterior == "/" {
                fora.removeLast(); fora.append("  ")
                emComentario = true; anterior = c; token = ""; continue
            }
            if apagandoTema && c == "("
                && (token.hasPrefix("Tema.") || token.hasPrefix("CalendarioTema.")) {
                profundidade = 1; fora.append(" "); anterior = c; token = ""; continue
            }
            fora.append(c)
            if c.isLetter || c.isNumber || c == "_" || c == "." { token.append(c) } else { token = "" }
            anterior = c
        }
        return fora
    }

    /// Quantas vezes cada linha do fonte move por conta própria.
    static func porLinha(_ texto: String, _ curva: Regex<AnyRegexOutput>,
                         _ numero: Regex<AnyRegexOutput>) -> [(Int, String, Int)] {
        let semTema = codigoVisivel(texto, apagandoTema: true)
            .split(separator: "\n", omittingEmptySubsequences: false)
        let comTema = codigoVisivel(texto, apagandoTema: false)
            .split(separator: "\n", omittingEmptySubsequences: false)
        var achados: [(Int, String, Int)] = []
        for n in semTema.indices {
            let quantos = semTema[n].matches(of: curva).count
                + comTema[n].matches(of: numero).count
            guard quantos > 0 else { continue }
            achados.append((n + 1, comTema[n].trimmingCharacters(in: .whitespaces), quantos))
        }
        return achados
    }

    static func fontes(_ raiz: URL) -> [String] {
        var achados: [String] = []
        for pasta in ["Traco", "TracoWidget"] {
            // links resolvidos dos dois lados: numa árvore sob /tmp o enumerador
            // devolve /private/tmp e o relativo saía com o caminho inteiro dentro
            let base = raiz.appending(path: pasta).resolvingSymlinksInPath()
            guard let caminhada = FileManager.default.enumerator(
                at: base, includingPropertiesForKeys: nil) else { continue }
            for caso in caminhada {
                guard let url = (caso as? URL)?.resolvingSymlinksInPath(), url.pathExtension == "swift" else { continue }
                let relativo = pasta + "/"
                    + url.path.replacingOccurrences(of: base.path + "/", with: "")
                if relativo != ondeAsCurvasMoram { achados.append(relativo) }
            }
        }
        return achados.sorted()
    }

    /// A lista congelada nasce vazia, então o teste fica verde se a varredura
    /// parar de enxergar. Estas quatro sondas são o contra-veneno: duas que
    /// TÊM de acusar e duas que NÃO podem acusar, medidas pelo mesmo caminho
    /// que os fontes.
    @MainActor @Test func aVarreduraAindaEnxerga() throws {
        let curva = try Regex(Self.curvaLiteral)
        let numero = try Regex(Self.numeroCru)
        func conta(_ s: String) -> Int {
            Self.porLinha(s, curva, numero).reduce(0) { $0 + $1.2 }
        }
        #expect(conta("private let x: Animation = .easeInOut(duration: 0.42)") > 0,
                "curva literal deixou de ser vista")
        #expect(conta("Tema.movimento(.opacidade, .easeOut(duration: 0.25), reduzido: rm)") > 0,
                "número cru dentro de Tema deixou de ser visto")
        #expect(conta(".animation(Tema.movimento(.opacidade,\n"
                      + "    .easeOut(duration: Tema.Duracao.media),\n"
                      + "    reduzido: rm), value: x)") == 0,
                "a forma que a ADR manda escrever ficou vermelha")
        #expect(conta("// não escreva .easeOut(duration: 0.3)\nlet s = \".spring(\"") == 0,
                "comentário ou string virou vermelho")
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

        let curva = try Regex(Self.curvaLiteral)
        let numero = try Regex(Self.numeroCru)
        var contagem: [String: Int] = [:]
        var vistas: [String] = []
        for caminho in fontes {
            let texto = try String(contentsOf: raiz.appending(path: caminho), encoding: .utf8)
            for (linha, codigo, quantos) in Self.porLinha(texto, curva, numero) {
                contagem[caminho, default: 0] += quantos
                vistas.append("\(caminho):\(linha): \(codigo)")
            }
        }

        // descer NUNCA é vermelho: quem migra uma tela não pode precisar editar
        // este teste para ficar verde. Só subir acusa.
        var divergencias: [String] = []
        for caminho in Set(contagem.keys).union(Self.faltosos.keys).sorted() {
            let hoje = contagem[caminho] ?? 0
            let congelado = Self.faltosos[caminho] ?? 0
            guard hoje > congelado else { continue }
            divergencias.append("\(caminho): \(hoje) hoje, \(congelado) congelado  ← SUBIU")
        }
        #expect(divergencias.isEmpty, Comment(rawValue: """
            curva ou duração LITERAL nova fora de Tema:
            \(divergencias.joined(separator: "\n"))

            A classe de movimento é quem decide o comportamento sob Reduzir
            Movimento (ADR 05y), e ela mora em `Tema`, num lugar só. Escreva
            `.animation(Tema.movimento(.classe, curva, reduzido: reduceMotion), value: x)`
            com a curva vinda de `Tema.Mola.*` / `Tema.Duracao.*` — passar a
            curva DENTRO da chamada a `Tema` é a forma certa e não conta aqui.
            O que conta é a curva solta na view e o número cru de tempo.

            o que a varredura viu:
            \(vistas.joined(separator: "\n"))
            """))
    }
}
