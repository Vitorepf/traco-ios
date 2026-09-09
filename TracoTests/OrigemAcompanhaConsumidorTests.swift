import Foundation
import SwiftData
import Testing
@testable import Traco

/// ADR 2026-09-09b — a origem acompanha TODO consumidor.
///
/// A volta anterior provou o LEITOR (`Retrato.ler` isolado) e deixou o
/// CHAMADOR passar: `Sessao.responderNasNotas`, a rota de produção que monta o
/// retrato para a IA, montava `Retrato.NotaLida` sem a origem e o padrão `true`
/// mandava a nota do bot embora. Cada teste aqui exercita o chamador de um
/// consumidor que declara voz, retrato, trajetória ou mapa do autor.
@MainActor
struct OrigemAcompanhaConsumidorTests {
    private func nota(_ texto: String, gesto: Gesto? = nil, campos: [String: String] = [:],
                      origem: OrigemNota = .autor, sentido: String = "",
                      criadaEm: Date = .now) -> Nota {
        let n = Nota(texto: texto, gesto: gesto, campos: campos, criadaEm: criadaEm)
        n.origem = origem
        n.sentido = sentido
        return n
    }

    // MARK: o P0 — a rota de produção das Notas

    /// VERMELHO em `2f0749b`: `responderNasNotas` chamava `.init(…)` sem
    /// `doAutor`, o padrão era `true`, e "o bot achou isto" ia no retrato
    /// mandado ao provedor.
    @Test func retratoDaRotaDeProducaoDasNotasNaoLevaOTextoDoBot() async throws {
        let c = try ModelContainer.traco(emMemoria: true)
        c.mainContext.insert(nota("meu desejo", gesto: .woop, campos: ["obstaculo": "deixo para depois"]))
        c.mainContext.insert(nota("resumo do bot", gesto: .woop,
                                  campos: ["obstaculo": "o bot achou isto"], origem: .grokbot))
        try c.mainContext.save()

        let ligadoAntes = Retrato.ligado
        Retrato.ligado = true
        defer { Retrato.ligado = ligadoAntes }

        let s = Sessao()
        var retratoEnviado: String?
        s.responderContextoNotas = { _, _, _, _, retrato, _ in
            retratoEnviado = retrato
            return .init(texto: "não sei.", enviadas: [], citadas: [])
        }
        _ = await s.responderNasNotas("o que me trava?", conversa: [], no: c.mainContext)
        let retrato = try #require(retratoEnviado)
        #expect(retrato.contains("deixo para depois"))
        #expect(!retrato.contains("o bot achou isto"))
        // nem como CONTAGEM: duas notas WOOP no disco, uma forma no retrato
        #expect(retrato.contains("1 WOOP"))
    }

    /// A citação continua possível — a nota do bot está no caderno —, mas a
    /// origem viaja no título, para o provedor e para a tela.
    @Test func aNotaDoBotCitadaChegaComAOrigemNoTitulo() throws {
        let doAutor = try #require(Sessao.fonteParaPergunta(nota("Prazo 12/09.")))
        #expect(!doAutor.titulo.contains("bot"))
        let doBot = try #require(Sessao.fonteParaPergunta(nota("Prazo 12/09.", origem: .grokbot)))
        #expect(doBot.titulo.contains("feito pelo bot"))
    }

    // MARK: o Perfil e a página (mesma conversão, um lugar só)

    @Test func oRetratoDoPerfilEDaPaginaUsaAMesmaConversaoComOrigem() {
        let campos = ["obstaculo": "deixo para depois"]
        let minhas = nota("meu", gesto: .woop, campos: campos)
        let dele = nota("dele", gesto: .woop, campos: ["obstaculo": "o bot achou isto"], origem: .grokbot)
        #expect(minhas.paraRetrato.vozDoAutor && !dele.paraRetrato.vozDoAutor)
        let texto = Retrato.ler(notas: [minhas, dele].map(\.paraRetrato), sinais: [])
        #expect(texto.contains("deixo para depois") && !texto.contains("o bot achou isto"))
        #expect(Retrato.ler(notas: [dele].map(\.paraRetrato), sinais: []).isEmpty)
    }

    // MARK: a trajetória (Padrões e o intent)

    @Test func aTrajetoriaNaoMedeAMenteComTextoQueNaoEDela() {
        let agora = Date()
        let ontem = agora.addingTimeInterval(-86_400)
        let minha = nota("minha palavra", gesto: .palavra, campos: ["minhas": "coragem é minha"],
                         criadaEm: ontem)
        let dele = nota("do bot", gesto: .palavra, campos: ["minhas": "o bot inventou esta"],
                        origem: .grokbot, criadaEm: ontem)
        let sentidoDele = nota("", gesto: .expressiva, origem: .grokbot,
                               sentido: "o sentido que o bot escreveu", criadaEm: ontem)
        sentidoDele.trancada = true
        let t = Trajetoria.ler(notas: [minha, dele, sentidoDele].map(\.paraTrajetoria),
                               sinais: [], agora: agora)
        #expect(t.recente.notas == 1)
        #expect(t.recente.palavras.contains { $0.texto.contains("coragem") })
        #expect(!t.recente.palavras.contains { $0.texto.contains("o bot inventou") })
        // a linha de sentido também é da mente do autor
        #expect(!t.recente.sentidos.contains("o sentido que o bot escreveu"))
    }

    // MARK: a revisão da semana (Padrões, o intent e o cartão)

    @Test func aSemanaNaoContaNemDestacaAQuiloQueOBotEscreveu() {
        let agora = Date()
        let ontem = agora.addingTimeInterval(-86_400)
        let meu = nota("meu destaque", gesto: .destaque, campos: ["unica": "entreguei o relatório"],
                       criadaEm: ontem)
        let dele = nota("do bot", gesto: .destaque, campos: ["unica": "o bot achou isto"],
                        origem: .grokbot, criadaEm: ontem)
        let r = RevisaoSemanal.ler(notas: [meu, dele].map(\.paraSemana), eventos: [], agora: agora)
        #expect(r.destaques.map(\.texto) == ["entreguei o relatório"])
        #expect(r.porForma.first?.quantas == 1)
    }

    // MARK: a rede (ligar é ato de pensamento do autor)

    @Test func aRedeNaoLigaDoQueOBotEscreveuMasDeixaOAutorLigarAEle() {
        let alvo = nota("Segunda clínica")
        let minha = nota("penso em [[Segunda clínica]] de novo")
        let dele = nota("o bot cita [[Segunda clínica]]", origem: .grokbot)
        let ligacoes = Rede.ligacoes([alvo, minha, dele].map(\.paraRede))
        #expect(ligacoes.contains { $0.de == minha.uuid && $0.para == alvo.uuid })
        #expect(!ligacoes.contains { $0.de == dele.uuid })
        // e o autor pode ligar À nota do bot: ela continua sendo destino
        let paraOBot = nota("li o [[o bot cita]] hoje")
        #expect(Rede.ligacoes([dele, paraOBot].map(\.paraRede))
            .contains { $0.de == paraOBot.uuid && $0.para == dele.uuid })
    }

    // MARK: o domínio — a inferência é uma afirmação sobre a mente do autor

    /// VERMELHO em `2f0749b`: `Nota.vozDoAutor` devolvia o texto do bot, e o
    /// léxico chamava a nota `grokbot` de TRABALHO — uma afirmação derivada
    /// dele moldando o mapa do autor (achado de domínio do G3).
    @Test func oDominioNaoENemInferidoNemClassificadoDoTextoDoBot() {
        let texto = "reunião com o cliente sobre o contrato do escritório"
        let minha = nota(texto)
        let dele = nota(texto, origem: .grokbot)
        #expect(Dominio.inferir(voz: minha.vozDoAutor) != nil)
        #expect(minha.vozDoAutor == minha.textoDeQualquerOrigem)
        #expect(dele.vozDoAutor.isEmpty)
        #expect(Dominio.inferir(voz: dele.vozDoAutor) == nil)
        // mas a BUSCA continua achando a nota do bot: ela está na pasta
        #expect(dele.textoDeQualquerOrigem.contains("escritório"))
        #expect(dele.temVoz)

        // e o rótulo que o léxico gravou ANTES desta ADR cala na tela, sem
        // migração — foi o chip TRABALHO na nota `grokbot` que o G3 viu
        dele.dominioRaw = Dominio.trabalho.rawValue
        #expect(dele.dominio == nil)
        // salvo o que o AUTOR escolheu no menu: aí a afirmação é dele
        dele.dominioTravado = true
        #expect(dele.dominio == .trabalho)
    }

    // MARK: o caso 8 — a pergunta do método tem de estar no contrato

    @Test func oContratoDaPastaTrazOsCamposEAPerguntaDeCadaMetodo() throws {
        let contrato = Corpus.contrato
        let woop = try #require(Catalogo.metodo("woop"))
        #expect(contrato.contains(woop.pergunta))
        #expect(contrato.contains("campos: resultado · obstaculo · plano"))
        // todo método com pergunta aparece com ela: o bot não tem de adivinhar
        for m in Catalogo.todos where !m.pergunta.isEmpty {
            #expect(contrato.contains(m.pergunta), "faltou a pergunta de \(m.nome)")
        }
        // e o id viaja quando difere do nome (o cabeçalho da nota usa `metodo:`)
        #expect(contrato.contains("(`seEntao`)"))
    }
}
