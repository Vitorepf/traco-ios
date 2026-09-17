import Foundation
import SwiftData
import Testing
@testable import Traco

/// Achados altos da auditoria de experiência do líder (16/09), um por suíte.

/// A resposta das Notas era recolhida sem ninguém mexer: `salvar` mudava a data
/// de uma nota só aberta, e a conversa depende da data de cada fonte.
@MainActor @Suite(.serialized)
struct GravarSemMudancaTests {
    @Test func abrirESairSemEditarNaoMudaADataNemRecolheAResposta() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let antes = Date(timeIntervalSince1970: 1_780_000_000)
        let nota = Nota(texto: "# Proposta do cliente", gesto: .decisao,
                        campos: ["escolha": "Dar desconto", "opcoes": "Dar desconto\nOferecer bônus", "decidido": "Oferecer bônus"],
                        criadaEm: antes, editadaEm: antes)
        ctx.insert(nota)
        try ctx.save()
        let fontes = [try #require(Sessao.fonteParaPergunta(nota))]

        let s = Sessao()
        s.abrir(nota)
        #expect(s.salvar(no: ctx))
        #expect(nota.editadaEm == antes, "abrir e sair sem editar não é edição")
        #expect(Sessao.dependenciasValidas(fontes, no: ctx), "a resposta que leu a nota continua de pé")

        s.texto = "# Proposta do cliente, revista"
        #expect(s.salvar(no: ctx))
        #expect(nota.editadaEm > antes)
        #expect(!Sessao.dependenciasValidas(fontes, no: ctx), "editar de verdade ainda recolhe")
    }
}

/// Os Padrões mostravam "Na NOTA 3 você escreveu… da NOTA 6?": o endereço do
/// pedido chegava ao autor. O pedido leva o título; a guarda recusa o número.
struct PadroesSemEnderecoTests {
    @Test func oPedidoLevaOTituloEOSistemaPedeCitarPorEle() {
        let pedido = PadroesRemoto.montarPedido(vozes: ["Subir para R$ 90", "Treinar de manhã"],
                                                titulos: ["Subir o preço do plano anual", ""])
        #expect(pedido.contains("NOTA 1 — «Subir o preço do plano anual»:\nSubir para R$ 90"))
        #expect(pedido.contains("NOTA 2:\nTreinar de manhã"), "sem título, só o endereço")
        #expect(PadroesRemoto.sistema.contains("nunca o número"))
        #expect(!PadroesRemoto.sistema.contains("ele mesmo") && !PadroesRemoto.sistema.contains("por ele"))
    }

    @Test func aPerguntaQueTrazONumeroDaNotaCaiEAMesmaSemEleFica() {
        let vozes = ["Subir para R$ 90 no plano anual", "Adiar o aumento para janeiro"]
        let comNumero = #"{"perguntas":["Na NOTA 1 você escreveu “Subir para R$ 90”; o que mudou na NOTA 2?"]}"#
        let comTitulo = #"{"perguntas":["Em «Subir o preço do plano anual» você escreveu “Subir para R$ 90”; o que mudou depois?"]}"#
        #expect(PadroesRemoto.parsePerguntas(comNumero, vozes: vozes) == [])
        #expect(PadroesRemoto.parsePerguntas(comTitulo, vozes: vozes)?.count == 1)
        #expect(PadroesRemoto.citaEndereco("o que diz a nota 12?") && !PadroesRemoto.citaEndereco("o que dizem as notas?"))
    }
}

/// Concluir uma nota com dia e hora marcava o compromisso em silêncio: o aviso
/// dele era trocado na hora por "guardada em Notas".
@MainActor @Suite(.serialized)
struct ConcluirDizOQueMarcouTests {
    @Test func oAvisoDizODiaEAHoraOuSoOndeANotaFoi() throws {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let quinta = try #require(cal.date(from: DateComponents(year: 2026, month: 9, day: 17, hour: 10)))
        let evento = EventoCalendario(id: UUID(), titulo: "Dentista", inicio: quinta, fim: quinta.addingTimeInterval(3600),
                                      dominio: nil, notas: "", diaInteiro: false)
        #expect(Sessao.toastDoConcluir(marcados: [evento]) == "Guardada em Notas · marcado qui., 17 set., 10:00")
        #expect(Sessao.toastDoConcluir(marcados: []) == "Guardada em Notas")
        #expect(Sessao.toastDoConcluir(marcados: [evento, evento]) == "Guardada em Notas · 2 compromissos marcados")
    }

    @Test func concluirComDiaEHoraAvisaQueMarcou() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let disco = FileManager.default.temporaryDirectory.appendingPathComponent("cal-\(UUID().uuidString)/calendario.json")
        let agenda = CalendarioAgenda(agora: .now, cal: Calendario.gregoriano(), disco: disco, eventos: [])
        let s = Sessao()
        s.agenda = agenda
        s.texto = "Dentista amanhã 10h"
        s.concluir(no: c.mainContext)
        #expect(agenda.eventos.count == 1)
        #expect(s.toast?.hasPrefix("Guardada em Notas · marcado ") == true, "\(s.toast ?? "sem aviso")")

        let semHora = Sessao()
        semHora.agenda = agenda
        semHora.texto = "Comprar pão e café"
        semHora.concluir(no: c.mainContext)
        #expect(semHora.toast == "Guardada em Notas")
        withExtendedLifetime(agenda) {}
    }
}

/// A IA se chama «Sábia», com maiúscula, em toda frase que o autor lê.
struct SabiaComMaiusculaTests {
    @Test func asFrasesDaTelaDizemSabiaComMaiuscula() {
        let frases = [Sabia.nadaPassouNaGuarda, Sabia.nadaVestiu, Grok.avisoDaFalha()]
            + Politica.Operacao.allCases.map { Politica.semProvedor($0) }
        for frase in frases {
            #expect(!frase.contains("sábia"), "\(frase)")
        }
        #expect(Sabia.nadaPassouNaGuarda.contains("Sábia") && Sabia.nadaVestiu.contains("Sábia"))
    }
}

/// «Concluir» aparecia numa nota só aberta (auditoria 17/09, #42): a Sessão diz se
/// algo mudou desde que a nota foi aberta; a página nova sempre pode concluir.
@MainActor @Suite(.serialized)
struct MudouDesdeAbrirTests {
    @Test func soAberturaNaoMudaEditarMuda() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let nota = Nota(texto: "# Compras", gesto: .decisao, campos: ["escolha": "Mercado ou feira"])
        c.mainContext.insert(nota)
        try c.mainContext.save()
        let s = Sessao()
        #expect(s.mudouDesdeAbrir, "página nova")
        s.abrir(nota)
        #expect(!s.mudouDesdeAbrir, "só abriu")
        s.campos["escolha"] = "Feira"
        #expect(s.mudouDesdeAbrir, "mudou um campo")
        s.campos["escolha"] = "Mercado ou feira"
        #expect(!s.mudouDesdeAbrir, "voltou ao que era")
        s.texto = "# Compras da semana"
        #expect(s.mudouDesdeAbrir, "mudou o texto")
        s.novaPagina()
        #expect(s.mudouDesdeAbrir, "página nova de novo")
    }
}
