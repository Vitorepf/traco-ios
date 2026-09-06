import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-05x — o áudio antes da letra.
///
/// Nada aqui abre microfone: o que se prova é a ORDEM (o depósito acontece
/// antes de a transcrição ser sequer pedida) e o CAMINHO DE FALHA (a nota fica,
/// com o áudio dentro e uma linha honesta).
@MainActor
struct DitadoProprioTests {
    /// Um ditado com microfone e transcritor de mentira, e um caderno de bordo
    /// do que foi gravado, na ordem.
    private func aparelhar(_ transcrever: @escaping (URL) async -> DitadoProprio.Letra)
        -> (DitadoProprio, () -> [String]) {
        let d = DitadoProprio(comecouEm: Date(timeIntervalSince1970: 1_757_170_320))
        nonisolated(unsafe) var diario: [String] = []
        d.abrirMicrofone = { _ in nil }
        d.fecharMicrofone = {}
        d.gravarNota = { texto in diario.append(texto); return true }
        d.transcritor = { url in
            diario.append("PEDIU A LETRA")
            return await transcrever(url)
        }
        return (d, { diario })
    }

    @Test("o áudio antes da letra: a nota é depositada ANTES de a transcrição ser pedida")
    func depositoAntesDaLetra() async throws {
        let (d, diario) = aparelhar { _ in .veio("comprar pão amanhã") }
        await d.comecar()
        #expect(d.estado == .gravando)
        await d.concluir()

        let passos = diario()
        #expect(passos.count == 3)
        // 1º o depósito, sem uma letra; 2º o pedido; 3º a reescrita com a letra
        #expect(passos[0].contains("O áudio ficou guardado, sem transcrição."))
        #expect(!passos[0].contains("comprar pão"))
        #expect(passos[1] == "PEDIU A LETRA")
        #expect(passos[2].hasPrefix("comprar pão amanhã"))
        #expect(d.estado == .transcrito("comprar pão amanhã"))
        // o marcador do anexo sobrevive aos três estados: o áudio nunca some
        #expect(passos[0].contains("traco://audio/\(d.id.uuidString)"))
        #expect(passos[2].contains("traco://audio/\(d.id.uuidString)"))
        #expect(d.notaCriada)
    }

    @Test("falha de transcrição preserva o áudio e diz a verdade; nunca finge que transcreveu")
    func falhaPreservaOAudio() async throws {
        let (d, diario) = aparelhar { _ in .naoVeio("a transcrição falhou no aparelho.") }
        await d.comecar()
        await d.concluir()

        let passos = diario()
        #expect(passos.count == 3)
        let final = passos[2]
        #expect(final.contains("traco://audio/\(d.id.uuidString)"))
        #expect(final.contains("Não consegui transcrever"))
        #expect(final.contains("O áudio ficou."))
        #expect(d.estado == .semLetra("a transcrição falhou no aparelho."))
        #expect(d.notaCriada)
    }

    @Test("silêncio não é sucesso: sem palavra nenhuma a nota fica com o áudio e o estado é honesto")
    func silencioNaoEhSucesso() async throws {
        let (d, diario) = aparelhar { _ in .veio("   ") }
        await d.comecar()
        await d.concluir()
        #expect(d.estado == .semLetra("não ouvi palavra nenhuma."))
        // nada é reescrito: a nota fica com o áudio e a linha do depósito
        #expect(diario().count == 2)
        #expect(diario()[0].contains("O áudio ficou guardado, sem transcrição."))
        #expect(diario()[1] == "PEDIU A LETRA")
    }

    @Test("tentar de novo é a recuperação: o mesmo áudio, a letra que faltava")
    func tentarDeNovo() async throws {
        let d = DitadoProprio(comecouEm: Date(timeIntervalSince1970: 1_757_170_320))
        nonisolated(unsafe) var falhar = true
        nonisolated(unsafe) var ultimo = ""
        d.abrirMicrofone = { _ in nil }
        d.fecharMicrofone = {}
        d.gravarNota = { ultimo = $0; return true }
        d.transcritor = { _ in falhar ? .naoVeio("sem rede.") : .veio("a frase") }
        await d.comecar()
        await d.concluir()
        #expect(d.estado == .semLetra("sem rede."))
        falhar = false
        await d.tentarDeNovo()
        #expect(d.estado == .transcrito("a frase"))
        #expect(ultimo.hasPrefix("a frase"))
        #expect(ultimo.contains("traco://audio/\(d.id.uuidString)"))
    }

    @Test("disco recusa o depósito: nada se confirma na tela e a letra nem é pedida")
    func discoRecusa() async throws {
        let d = DitadoProprio()
        nonisolated(unsafe) var pediuALetra = false
        d.abrirMicrofone = { _ in nil }
        d.fecharMicrofone = {}
        d.gravarNota = { _ in false }
        d.transcritor = { _ in pediuALetra = true; return .veio("nunca") }
        await d.comecar()
        await d.concluir()
        #expect(!pediuALetra)
        #expect(!d.notaCriada)
        #expect(d.estado == .semMicrofone("não consegui guardar o áudio."))
    }

    @Test("microfone negado: nada é gravado e a tela diz por quê")
    func semMicrofone() async throws {
        let d = DitadoProprio()
        nonisolated(unsafe) var gravou = false
        d.abrirMicrofone = { _ in "o Traço precisa do microfone para gravar." }
        d.fecharMicrofone = {}
        d.gravarNota = { _ in gravou = true; return true }
        d.transcritor = { _ in .veio("nunca") }
        await d.comecar()
        #expect(d.estado == .semMicrofone("o Traço precisa do microfone para gravar."))
        await d.concluir()  // não há o que concluir
        #expect(!gravou)
        #expect(!d.notaCriada)
    }

    @Test("o corpo da nota: o marcador do anexo é uma linha só, e a origem é a última")
    func corpoDaNota() {
        let id = UUID()
        let quando = Date(timeIntervalSince1970: 1_757_170_320)
        let nome = TextoDoDitado.nomeDoArquivo(quando)
        #expect(nome.hasSuffix(".m4a"))  // sem a extensão o AnexoDisco não acha o arquivo

        for corpo in [TextoDoDitado.corpo(id: id, quando: quando),
                      TextoDoDitado.corpo(id: id, quando: quando, transcricao: "uma frase"),
                      TextoDoDitado.corpo(id: id, quando: quando, motivo: "sem rede.")] {
            let marcador = corpo.split(separator: "\n").filter { $0.contains("traco://audio/") }
            #expect(marcador.count == 1)
            #expect(marcador[0] == "[audio:\(nome)](traco://audio/\(id.uuidString))")
            #expect(corpo.split(separator: "\n").last?.hasPrefix("Ditado de") == true)
        }
    }

    @Test("o áudio mora no cofre de anexos, com a extensão que a nota vai procurar")
    func audioNoCofre() {
        let d = DitadoProprio(comecouEm: Date(timeIntervalSince1970: 1_757_170_320))
        #expect(d.urlDoAudio.pathExtension == "m4a")
        #expect(d.urlDoAudio.deletingPathExtension().lastPathComponent == d.id.uuidString)
        // é o MESMO caminho que o portal da nota abre a partir do marcador
        #expect(d.urlDoAudio == AnexoDisco.url(d.id.uuidString, nome: TextoDoDitado.nomeDoArquivo(d.comecouEm)))
    }

    @Test("traco://ditar não é Destino: anuncia o ditado e a Página não faz nada")
    func rotaDitar() {
        Rota.pendente = nil
        Rota.ditadoPendente = false
        let anunciarAntes = Rota.anunciar
        Rota.anunciar = {}
        defer { Rota.anunciar = anunciarAntes }
        #expect(Rota.daURL(URL(string: "traco://ditar")!) == nil)
        #expect(Rota.pendente == nil)
        #expect(Rota.consumirDitado())
        #expect(!Rota.consumirDitado())
    }
}
