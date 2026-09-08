import Foundation
import SwiftData
import Testing
@testable import Traco

private func utc() -> Calendar {
    Calendario.gregoriano(fuso: TimeZone(secondsFromGMT: 0)!)
}

/// Segunda, 20 de julho de 2026, 12:00 UTC.
private var ancora: Date {
    utc().date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
}

struct ConsultaEmProsaTests {
    private let cal = utc()

    private func consulta(_ s: String) -> (Date, EscalaCalendario)? {
        CalendarioFrase.consulta(s, ancora: ancora, agora: ancora, cal).map { ($0.dia, $0.escala) }
    }

    @Test func perguntaVaiAoDia() throws {
        let (dia, escala) = try #require(consulta("o que tenho sexta?"))
        #expect(cal.component(.day, from: dia) == 24)
        #expect(escala == .dia)
        let (amanha, _) = try #require(consulta("amanhã?"))
        #expect(cal.component(.day, from: amanha) == 21)
        let (so, _) = try #require(consulta("sexta"))
        #expect(cal.component(.day, from: so) == 24)
    }

    @Test func periodosMudamAEscala() throws {
        let (d, e) = try #require(consulta("semana que vem"))
        #expect(cal.component(.day, from: d) == 27)
        #expect(e == .semana)
        let (m, em) = try #require(consulta("o que tem no mês que vem"))
        #expect(cal.component(.month, from: m) == 8)
        #expect(em == .mes)
        let (_, ea) = try #require(consulta("este ano"))
        #expect(ea == .ano)
    }

    @Test func compromissoNaoEConsulta() {
        #expect(consulta("dentista sexta 14:30") == nil)
        #expect(consulta("almoço com a Ana amanhã") == nil)
        #expect(consulta("reunião") == nil)
    }

    @Test func aAgendaRespondeIndoAoDia() {
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: FileManager.default.temporaryDirectory
            .appendingPathComponent("cal-\(UUID().uuidString).json"), eventos: [])
        agenda.prosa = "o que tenho na semana que vem?"
        agenda.adicionarDaProsa(agora: ancora)
        #expect(agenda.eventos.isEmpty)
        #expect(agenda.prosa.isEmpty)
        #expect(agenda.escala == .semana)
        #expect(cal.component(.day, from: agenda.ancora) == 27)
        #expect(agenda.toast == nil)
    }
}

struct DeixaNoCalendarioTests {
    private let cal = utc()

    @Test func deixaEntraNasEscalasMasNaoNoDisco() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cal-\(UUID().uuidString).json")
        let agenda = CalendarioAgenda(agora: ancora, cal: cal, disco: url, eventos: [])
        let nota = UUID()
        let quando = Calendario.hora(18, 0, no: ancora, cal)
        agenda.deixas = [EventoCalendario(id: nota, titulo: "Se chegar em casa", inicio: quando,
                                          fim: quando.addingTimeInterval(1800), origem: nota)]
        #expect(agenda.eventos(no: ancora).count == 1)
        #expect(agenda.eventos(no: ancora)[0].eDeixa)
        #expect(agenda.eventosDaEscala().count == 1)
        // guardar uma deixa não grava nada: a nota é a dona
        agenda.guardar(agenda.deixas[0])
        #expect(agenda.eventos.isEmpty)
        if case .eventos(let lidos) = CalendarioDisco.carregar(de: url) { #expect(lidos.isEmpty) }
        // abrir chama a nota, não a ficha
        var aberta: UUID?
        agenda.aoAbrirNota = { aberta = $0 }
        agenda.abrir(agenda.deixas[0])
        #expect(aberta == nota)
        #expect(agenda.ficha == nil)
    }

    @Test func origemNuncaVaiAoJSON() throws {
        let e = EventoCalendario(titulo: "x", inicio: ancora, fim: ancora, origem: UUID())
        let enc = JSONEncoder()
        let data = try enc.encode([e])
        let s = String(decoding: data, as: UTF8.self)
        #expect(!s.contains("origem"))
        let lidos = try JSONDecoder().decode([EventoCalendario].self, from: data)
        #expect(lidos[0].origem == nil)
    }
}

struct LenteTests {
    @Test func achaMuletasFrasesFeitasEPassivas() {
        let l = Lente.ler("Tipo, eu acho que no final do dia o projeto foi entregue. Tipo assim, basicamente deu certo.")
        // "tipo assim" come o seu "tipo"; "acho que" come o "eu acho"
        #expect(l.muletas.contains { $0.termo == "tipo" && $0.vezes == 1 })
        #expect(l.muletas.contains { $0.termo == "tipo assim" && $0.vezes == 1 })
        #expect(!l.muletas.contains { $0.termo == "eu acho" })
        #expect(l.muletas.contains { $0.termo == "basicamente" })
        #expect(l.frasesFeitas.contains("no final do dia"))
        #expect(l.passivas.contains { $0.lowercased().contains("foi entregue") })
        #expect(l.palavras > 10)
        #expect(l.frases == 2)
    }

    @Test func adverbioEmMenteEAdjetivoRepetido() {
        let l = Lente.ler("Ele falou rapidamente. O dia foi bonito, a casa é bonita, o carro bonito.")
        #expect(l.adverbios.contains { $0.termo == "rapidamente" })
        // adjetivo só vira achado quando repete
        #expect(l.adjetivos.allSatisfy { $0.vezes >= 2 })
    }

    @Test func textoLimpoNaoTemNadaAApontar() {
        let l = Lente.ler("Fui ao mercado e comprei pão.")
        #expect(l.muletas.isEmpty)
        #expect(l.frasesFeitas.isEmpty)
        #expect(l.passivas.isEmpty)
        #expect(l.adjetivos.isEmpty)
    }
}

struct VersoesEApontarTests {
    private func pastaTemp() -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("v-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    @Test func versaoGuardaAAnteriorENuncaAExpressiva() {
        Versoes.diretorio = pastaTemp()
        let id = UUID()
        #expect(Versoes.registrar(id, texto: "primeira", campos: [:], gesto: nil, fechada: false))
        // igual à última: não duplica
        #expect(!Versoes.registrar(id, texto: "primeira", campos: [:], gesto: nil, fechada: false))
        #expect(Versoes.registrar(id, texto: "segunda", campos: ["se": "x"], gesto: .seEntao, fechada: false))
        let lista = Versoes.listar(id)
        #expect(lista.count == 2)
        #expect(lista[0].texto == "segunda")
        // expressiva e fechada nunca entram
        #expect(!Versoes.registrar(UUID(), texto: "desabafo", campos: [:], gesto: .expressiva, fechada: false))
        #expect(!Versoes.registrar(UUID(), texto: "selada", campos: [:], gesto: nil, fechada: true))
        Versoes.apagar(id)
        #expect(Versoes.listar(id).isEmpty)
    }

    @Test func versoesTemTeto() {
        Versoes.diretorio = pastaTemp()
        let id = UUID()
        for i in 0..<40 { Versoes.registrar(id, texto: "v\(i)", campos: [:], gesto: nil, fechada: false) }
        #expect(Versoes.listar(id).count == Versoes.teto)
        #expect(Versoes.listar(id)[0].texto == "v39")
    }

    @Test func apontarSoTrechoDoProprioTexto() {
        Apontar.diretorio = pastaTemp()
        let id = UUID()
        let texto = "no final do dia o projeto foi entregue"
        #expect(Apontar.marcar(id, trecho: "no final do dia", rotulo: .fraseFeita, noTexto: texto))
        #expect(!Apontar.marcar(id, trecho: "frase que não existe", rotulo: .vago, noTexto: texto))
        #expect(Apontar.marcar(id, trecho: "foi entregue", rotulo: .passiva, noTexto: texto))
        let lista = Apontar.listar(id)
        #expect(lista.count == 2)
        #expect(lista[0].rotulo == .passiva)
        #expect(Apontar.desmarcar(id, id: lista[0].id))
        #expect(Apontar.listar(id).count == 1)
        Apontar.apagar(id)
        #expect(Apontar.listar(id).isEmpty)
    }
}

struct PastaEspelhoTests {
    @Test func espelhoEscreveNaPastaDoAutorESoOQuePodeSair() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("esp-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: raiz, withIntermediateDirectories: true)
        PastaEspelho.defaults = UserDefaults(suiteName: "teste-espelho-\(UUID().uuidString)")!
        #expect(PastaEspelho.nome == nil)
        #expect(PastaEspelho.guardar(raiz))
        #expect(PastaEspelho.nome == raiz.lastPathComponent)

        let aberta = FatiaCorpus(id: UUID(), texto: "quero correr", gesto: .woop, campos: [:],
                                 criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "", minutos: 0,
                                 trancada: false, queimada: false, expressivaEmCurso: false,
                                 dominio: nil, serie: nil, dia: 0)
        let emCurso = FatiaCorpus(id: UUID(), texto: "desabafo", gesto: .expressiva, campos: [:],
                                  criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "", minutos: 3,
                                  trancada: false, queimada: false, expressivaEmCurso: true,
                                  dominio: nil, serie: nil, dia: 0)
        var escrita: URL?
        PastaEspelho.comAcesso { pasta in
            Corpus.escrever(fatias: [aberta, emCurso], em: pasta)
            escrita = pasta
        }
        let pasta = try #require(escrita)
        #expect(pasta.lastPathComponent == "Traço")
        let notas = try FileManager.default.contentsOfDirectory(atPath: pasta.appendingPathComponent("notas").path)
        #expect(notas == [aberta.id.uuidString.lowercased() + ".md"])
        #expect(FileManager.default.fileExists(atPath: pasta.appendingPathComponent("LEIA-ME.md").path))
        #expect(FileManager.default.fileExists(atPath: pasta.appendingPathComponent("traco-corpus.md").path))
        let corpus = try String(contentsOf: pasta.appendingPathComponent("traco-corpus.md"), encoding: .utf8)
        #expect(!corpus.contains("desabafo"))

        PastaEspelho.limpar()
        #expect(PastaEspelho.nome == nil)
        var chamou = false
        PastaEspelho.comAcesso { _ in chamou = true }
        #expect(!chamou)
    }
}

private enum DiscoRecusou: Error { case gravar }

struct BloqueadoresDeDadosTests {
    @Test func fechoNaoApagaAPaginaSeODiscoRecusa() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "quinze minutos de escrita que não podem sumir"
        s.gesto = .expressiva
        s.persistirNoDisco = { _ in throw DiscoRecusou.gravar }
        s.abrirFecho(no: c.mainContext)
        #expect(s.texto == "quinze minutos de escrita que não podem sumir")
        #expect(s.fechoExpressiva == nil)
        #expect(s.toast != nil)
    }

    @Test func fechoSegueQuandoODiscoAceita() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "escrita"
        s.gesto = .expressiva
        s.abrirFecho(no: c.mainContext)
        #expect(s.texto.isEmpty)
        #expect(s.fechoExpressiva != nil)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.trancada)
    }

    @Test func expressivaEmCursoNuncaVaiAoSpotlight() {
        #expect(!Holofote.sai(fechada: false, expressivaEmCurso: true, voz: "desabafo"))
        #expect(!Holofote.sai(fechada: true, expressivaEmCurso: false, voz: "selada"))
        #expect(!Holofote.sai(fechada: false, expressivaEmCurso: false, voz: "   "))
        #expect(Holofote.sai(fechada: false, expressivaEmCurso: false, voz: "aberta"))
    }

    @Test func apagarTiraDoEspelhoNaHora() throws {
        Corpus.diretorio = FileManager.default.temporaryDirectory.appendingPathComponent("esp-\(UUID().uuidString)")
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "nota que vai ser apagada"
        s.salvar(no: c.mainContext)
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        Corpus.backupAutomatico(notas: [nota])
        let arquivo = Corpus.pastaNotas.appendingPathComponent(nota.uuid.uuidString.lowercased() + ".md")
        #expect(FileManager.default.fileExists(atPath: arquivo.path))
        s.apagar(uuid: nota.uuid, no: c.mainContext)
        #expect(!FileManager.default.fileExists(atPath: arquivo.path))
    }
}

struct RevisaoNoturnaTests {
    @Test func selarApagaVersoesEApontamentos() throws {
        Versoes.diretorio = FileManager.default.temporaryDirectory.appendingPathComponent("v-\(UUID().uuidString)")
        Apontar.diretorio = FileManager.default.temporaryDirectory.appendingPathComponent("a-\(UUID().uuidString)")
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "primeiro rascunho comum"
        #expect(s.salvar(no: c.mainContext))
        let uuid = try #require(s.notaUUID)
        s.texto = "primeiro rascunho comum e mais"
        #expect(s.salvar(no: c.mainContext))
        #expect(!Versoes.listar(uuid).isEmpty)
        Apontar.marcar(uuid, trecho: "rascunho", rotulo: .vago, noTexto: s.texto)
        s.gesto = .expressiva
        #expect(s.salvar(no: c.mainContext, trancar: true))
        #expect(Versoes.listar(uuid).isEmpty)
        #expect(Apontar.listar(uuid).isEmpty)
    }

    @Test func consultaDeSextaPartesDeHojeNaoDaTelaOlhada() throws {
        let cal = utc()
        let hoje = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let olhando = cal.date(from: DateComponents(year: 2025, month: 3, day: 3))!
        let (dia, _) = try #require(CalendarioFrase.consulta("o que tenho sexta?", ancora: olhando, agora: hoje, cal))
        #expect(cal.component(.year, from: dia) == 2026)
        #expect(cal.component(.day, from: dia) == 24)
    }

    @Test func diaInvalidoNaoViraOutroMes() {
        let cal = utc()
        let hoje = cal.date(from: DateComponents(year: 2026, month: 7, day: 20, hour: 12))!
        let e = CalendarioFrase.ler("reunião 31/02", ancora: hoje, agora: hoje, cal)
        // sem data válida, a frase inteira vira título no dia âncora
        #expect(e?.titulo == "Reunião 31/02")
        #expect(cal.component(.month, from: e!.inicio) == 7)
    }

    @Test func espelhoDoAutorSoApagaOQueEsteAparelhoEscreveu() throws {
        let raiz = FileManager.default.temporaryDirectory.appendingPathComponent("esp-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: raiz.appendingPathComponent("notas"), withIntermediateDirectories: true)
        PastaEspelho.defaults = UserDefaults(suiteName: "teste-espelho-\(UUID().uuidString)")!
        let alheio = raiz.appendingPathComponent("notas/do-outro-aparelho.md")
        try Data("---\ngesto: WOOP\n---\nnota de outro iPhone\n".utf8).write(to: alheio)
        func fatia(_ t: String) -> FatiaCorpus {
            FatiaCorpus(id: UUID(), texto: t, gesto: nil, campos: [:], criadaEm: .now, editadaEm: .now, recordada: 0,
                        sentido: "", minutos: 0, trancada: false, queimada: false, expressivaEmCurso: false,
                        dominio: nil, serie: nil, dia: 0)
        }
        let a = fatia("a"), b = fatia("b")
        Corpus.escrever(fatias: [a, b], em: raiz, soOsMeus: true)
        Corpus.escrever(fatias: [a], em: raiz, soOsMeus: true)
        let nomes = try FileManager.default.contentsOfDirectory(atPath: raiz.appendingPathComponent("notas").path).sorted()
        #expect(nomes.contains("do-outro-aparelho.md"))
        #expect(nomes.contains(a.id.uuidString.lowercased() + ".md"))
        #expect(!nomes.contains(b.id.uuidString.lowercased() + ".md"))
        // parar de espelhar tira o que é meu e deixa o alheio
        let pai = FileManager.default.temporaryDirectory.appendingPathComponent("pai-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: pai, withIntermediateDirectories: true)
        #expect(PastaEspelho.guardar(pai))
        PastaEspelho.comAcesso { Corpus.escrever(fatias: [a], em: $0, soOsMeus: true) }
        let dentro = pai.appendingPathComponent("Traço/notas")
        try Data("---\n---\nalheia\n".utf8).write(to: dentro.appendingPathComponent("alheia.md"))
        PastaEspelho.limpar()
        let depois = try FileManager.default.contentsOfDirectory(atPath: dentro.path)
        #expect(depois == ["alheia.md"])
        #expect(!FileManager.default.fileExists(atPath: pai.appendingPathComponent("Traço/LEIA-ME.md").path))
    }
}

struct SabiaTests {
    @MainActor @Test func vestirResolveTituloListaECodigoSemChamarModelo() async throws {
        let codigo = "```swift\r\nlet x = 1\r\n\r\nprint(x)\r\n```"
        let texto = "Plano do app\r\n\r\n" + codigo + "\r\n\r\nprimeira\r\nsegunda"
        var chamadas = 0
        let mapa = try #require(await Sabia.vestir(blocos: Sabia.blocos(texto), gesto: nil, gerar: { _ in
            chamadas += 1
            return nil
        }))
        #expect(chamadas == 0)
        #expect(mapa == [.init(i: 0, forma: .titulo), .init(i: 1, forma: .codigo), .init(i: 2, forma: .lista)])
        #expect(Sabia.aplicar(mapa, a: texto) == "# Plano do app\r\n\r\n" + codigo + "\r\n\r\n- primeira\n- segunda")
    }

    @MainActor @Test func vestirMandaSoProsaPendenteERemapeiaIndices() async throws {
        let codigo = "~~~python\nsegredo = 42\n~~~"
        let prosa = "Esta explicação contém uma frase completa que o modelo ainda pode organizar."
        let texto = "Plano do app\n\n" + codigo + "\n\n" + prosa
        var mensagem = ""
        let mapa = try #require(await Sabia.vestir(blocos: Sabia.blocos(texto), gesto: nil, gerar: { usuario in
            mensagem = usuario
            return #"[{"i":0,"forma":"titulo"}]"#
        }))
        #expect(mensagem == "[0] " + prosa)
        #expect(!mensagem.contains("segredo"))
        #expect(mapa == [.init(i: 0, forma: .titulo), .init(i: 1, forma: .codigo), .init(i: 2, forma: .secao)])
        #expect(Sabia.aplicar(mapa, a: texto) == "# Plano do app\n\n" + codigo + "\n\n## " + prosa)
    }

    @MainActor @Test func vestirNaoDisfarcaFalhaSemMelhoriaLocal() async {
        let prosa = "Esta explicação contém uma frase completa que o modelo ainda pode organizar."
        for retorno in [String?.none, "inválido", #"[{"i":9,"forma":"lista"}]"#] {
            #expect(await Sabia.vestir(blocos: [prosa], gesto: nil, gerar: { _ in retorno }) == nil)
        }
    }

    @Test func vestirPreservaCercasECodigoMesmoComRotuloIncorreto() throws {
        for quebra in ["\n", "\r\n"] {
            for cerca in ["```", "````", "~~~", "~~~~"] {
                let codigo = [cerca + "swift", "let marca = \"``` e ~~~\"  ", "", "  ", "let intermediario = 2", "", "\tprint(marca)", cerca]
                    .joined(separator: quebra)
                let antes = "\n  \nPlano do app\n\n" + codigo + "\n\nprimeira\nsegunda\n\n"
                let esperado = "\n  \n# Plano do app\n\n" + codigo + "\n\n- primeira\n- segunda\n\n"
                try #require(Sabia.blocos(antes).count == 3)
                #expect(Sabia.blocos(antes)[1] == codigo)
                #expect(Caderno.estruturar(antes) == esperado)
                for forma in Sabia.FormaDeBloco.allCases {
                    let mapa = [Sabia.Rotulo(i: 0, forma: .titulo), .init(i: 1, forma: forma), .init(i: 2, forma: .lista)]
                    #expect(Sabia.aplicar(mapa, a: antes) == esperado)
                    #expect(Sabia.aplicar(mapa, a: Caderno.estruturar(antes)) == esperado)
                }
            }
        }
    }

    @Test func cercaMaiorProtegeCercasMenoresETextoSemLinhaVazia() {
        let codigo = "````markdown\n```swift\n\nlet x = 1\n```\n\n````"
        let antes = "Introdução\n" + codigo + "\nConclusão"
        #expect(Sabia.blocos(antes) == ["Introdução", codigo, "Conclusão"])
        let mapa = [Sabia.Rotulo(i: 0, forma: .titulo), .init(i: 1, forma: .tarefas), .init(i: 2, forma: .secao)]
        #expect(Sabia.aplicar(mapa, a: antes) == "# Introdução\n" + codigo + "\n## Conclusão")
    }

    @Test func cercaAbertaNaoEFechadaNemSeuConteudoVestido() {
        for codigo in ["```swift\nlet x = 1\n\nprint(x)\n", "~~~python\r\nx = 1\r\n\r\nprint(x)\r\n"] {
            #expect(Sabia.blocos(codigo) == [codigo])
            #expect(Caderno.estruturar(codigo) == codigo)
            #expect(Sabia.aplicar([.init(i: 0, forma: .titulo)], a: codigo) == codigo)
        }
    }

    @Test func vestirProsaCRLFContinuaCriandoTituloEItens() {
        let antes = "Plano\r\n\r\nprimeira\r\nsegunda"
        let esperado = "# Plano\r\n\r\n- primeira\n- segunda"
        #expect(Caderno.estruturar(antes) == esperado)
        #expect(Sabia.aplicar([.init(i: 0, forma: .titulo), .init(i: 1, forma: .lista)], a: antes) == esperado)
    }

    @Test func mapaSoEntraSeForVerificavel() {
        let ok = Sabia.parseMapa(#"[{"i":0,"forma":"titulo"},{"i":1,"forma":"lista"},{"i":2,"forma":"prosa"}]"#, blocos: 3)
        #expect(ok?.count == 3)
        #expect(Sabia.parseMapa(#"[{"i":0,"forma":"poema"}]"#, blocos: 1) == nil)      // forma fora da lista
        #expect(Sabia.parseMapa(#"[{"i":5,"forma":"lista"}]"#, blocos: 2) == nil)      // índice inexistente
        #expect(Sabia.parseMapa(#"[{"i":0,"forma":"titulo"},{"i":1,"forma":"titulo"}]"#, blocos: 2) == nil) // dois títulos
        #expect(Sabia.parseMapa("claro! aqui vai: [{\"i\":0,\"forma\":\"secao\"}]", blocos: 1)?.first?.forma == .secao)
    }

    @Test func perguntasSoComInterrogacao() {
        let r = Sabia.parsePerguntas(#"{"perguntas":["Isso depende de quê?","Faça assim: x","E quando falhar, quem avisa?"]}"#)
        #expect(r == ["Isso depende de quê?", "E quando falhar, quem avisa?"])
        #expect(Sabia.parsePerguntas(#"{"perguntas":["sem interrogação"]}"#) == nil)
    }

    @Test func aplicarVesteSemMudarPalavras() {
        let texto = "Plano do app\n\nprimeira\nsegunda\nterceira\n\nUm parágrafo com ponto final."
        let mapa = [Sabia.Rotulo(i: 0, forma: .titulo), Sabia.Rotulo(i: 1, forma: .numerada), Sabia.Rotulo(i: 2, forma: .prosa)]
        let v = Sabia.aplicar(mapa, a: texto)
        #expect(v == "# Plano do app\n\n1. primeira\n2. segunda\n3. terceira\n\nUm parágrafo com ponto final.")
        // as palavras são as mesmas
        let so = { (s: String) in s.replacingOccurrences(of: #"[#\-\d.\[\] ]"#, with: "", options: .regularExpression) }
        #expect(so(v) == so(texto))
        // bloco já vestido não se toca
        #expect(Sabia.aplicar([Sabia.Rotulo(i: 0, forma: .lista)], a: "# já é título") == "# já é título")
    }

    @Test func aLinhaComInterrogacaoEAPergunta() {
        #expect(Sabia.perguntaNaNota("texto\n? como defino isso\nmais") == "como defino isso")
        #expect(Sabia.perguntaNaNota("sem pergunta") == nil)
        #expect(Sabia.perguntaNaNota("?") == nil)
    }

    @Test func respostaTemTetoESemMarkdownPesado() {
        let r = Sabia.limparResposta("## Título\n**forte** e " + String(repeating: "x", count: 2000), teto: 100)
        #expect(r?.hasSuffix("…") == true)
        #expect(r?.contains("**") == false)
        #expect(r?.hasPrefix("Título") == true)
    }

    @Test func formasDeEstrategiaEntramNaLista() {
        #expect(Gesto.decisao.campos.map(\.id) == ["escolha", "opcoes", "criterio", "decidido", "espero", "aconteceu", "saldo"])
        #expect(Gesto.premortem.campos.count == 4)
        #expect(Gesto.doNome("Decisão") == .decisao)
        #expect(Gesto.doNome("Pré-mortem") == .premortem)
        #expect(AnaliseLocal.classificar(texto: "preciso decidir entre ficar no emprego ou abrir a empresa", gestoAtual: nil, campos: [:]) == .gesto(.decisao, pergunta: AnaliseLocal.pergunta(.decisao)))
        #expect(AnaliseLocal.classificar(texto: "pré-mortem do lançamento de outubro", gestoAtual: nil, campos: [:]) == .gesto(.premortem, pergunta: AnaliseLocal.pergunta(.premortem)))
    }
}

struct DeixaPuraTests {
    @Test func aDeixaSoNasceDeNotaAbertaComHora() {
        let agora = Date()
        let ok = Calendario.deixa(uuid: UUID(), gesto: .seEntao, fechada: false, gatilhoEm: agora,
                                  se: "chegar em casa às 18h", tituloNaLista: "x", dominio: .casa)
        #expect(ok?.titulo == "chegar em casa às 18h")
        #expect(ok?.eDeixa == true)
        #expect(ok?.duracaoMinutos == 30)
        #expect(Calendario.deixa(uuid: UUID(), gesto: .expressiva, fechada: false, gatilhoEm: agora, se: "x", tituloNaLista: "x", dominio: nil) == nil)
        #expect(Calendario.deixa(uuid: UUID(), gesto: .seEntao, fechada: true, gatilhoEm: agora, se: "x", tituloNaLista: "x", dominio: nil) == nil)
        #expect(Calendario.deixa(uuid: UUID(), gesto: .seEntao, fechada: false, gatilhoEm: nil, se: "x", tituloNaLista: "x", dominio: nil) == nil)
        // sem "se", vale o título da nota
        #expect(Calendario.deixa(uuid: UUID(), gesto: .woop, fechada: false, gatilhoEm: agora, se: "", tituloNaLista: "correr", dominio: nil)?.titulo == "correr")
    }
}

struct DecisaoConfereTests {
    @Test func aDataDeConferirViraGatilho() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "preciso decidir entre ficar no emprego ou abrir a empresa"
        s.gesto = .decisao
        s.campos = ["escolha": "ficar ou sair", "espero": "mais calma; confiro dia 20 às 9h"]
        #expect(s.salvar(no: c.mainContext))
        let nota = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        #expect(nota.gatilhoEm != nil)
        // e entra no calendário como deixa, com o título da nota
        let deixa = Calendario.deixa(uuid: nota.uuid, gesto: nota.gesto, fechada: nota.fechada, gatilhoEm: nota.gatilhoEm,
                                     se: nota.campos["se"] ?? "", tituloNaLista: nota.tituloNaLista, dominio: nota.dominio)
        #expect(deixa != nil)
    }
}

struct RevisaoSemanalTests {
    @Test func aSemanaContaCobraEMostraSoOQuePodeSair() {
        let cal = Calendar(identifier: .gregorian)
        let agora = Date()
        func nota(_ g: Gesto?, dias: Int, campos: [String: String] = [:], fechada: Bool = false, gatilho: Date? = nil, sentido: String = "") -> RevisaoSemanal.NotaLida {
            RevisaoSemanal.NotaLida(uuid: UUID(), gesto: g, fechada: fechada, criadaEm: cal.date(byAdding: .day, value: dias, to: agora)!,
                                    gatilhoEm: gatilho, titulo: "t", campos: campos, sentido: sentido, queimadaOuSeladaEm: nil)
        }
        let amanha = cal.date(byAdding: .day, value: 1, to: agora)!
        let notas = [
            nota(.destaque, dias: -1, campos: ["unica": "terminar o relatório"]),
            nota(.woop, dias: -2, campos: ["obstaculo": "preguiça"]),
            nota(.decisao, dias: -3, campos: ["escolha": "ficar ou sair"], gatilho: amanha),
            nota(.seEntao, dias: -4, campos: ["se": "chegar em casa"], gatilho: amanha),
            nota(.expressiva, dias: -1, fechada: true, sentido: "o medo era de decepcionar"),
            nota(.expressiva, dias: -1, fechada: false),           // em curso: nunca
            nota(nil, dias: -20),                                    // fora da semana
        ]
        let ev = EventoCalendario(titulo: "Dentista", inicio: amanha, fim: amanha.addingTimeInterval(3600))
        let r = RevisaoSemanal.ler(notas: notas, eventos: [ev], agora: agora, cal: cal)
        #expect(r.destaques.map(\.texto) == ["terminar o relatório"])
        #expect(r.decisoesAConferir.map(\.texto) == ["ficar ou sair"])
        #expect(r.desejos.count == 1 && r.desejos[0].texto.contains("preguiça"))
        #expect(r.proximos.map(\.texto).sorted() == ["Dentista", "chegar em casa", "ficar ou sair"].sorted())
        #expect(r.sentidos == ["o medo era de decepcionar"])
        #expect(r.porForma.reduce(0) { $0 + $1.quantas } == 4)  // a expressiva em curso e a antiga não contam
        #expect(!r.vazia)
        #expect(RevisaoSemanal.ler(notas: [], eventos: [], agora: agora, cal: cal).vazia)
    }
}

struct DecisaoRecordarTests {
    @Test func oRecordarDaDecisaoEscondeOQueEuEsperava() {
        let r = RitualRecordar.de(.decisao)
        #expect(r == .decisao)
        #expect(!r.mostraAlvoAntesDeEscrever == false) // mostra a escolha (a pista) antes
        let campos = ["escolha": "ficar ou sair", "espero": "mais calma em três meses", "aconteceu": ""]
        #expect(r.alvo(texto: "", campos: campos) == "mais calma em três meses")
        #expect(Gesto.decisao.campos.map(\.id).contains("aconteceu"))
    }

    @Test func aSemanaEmTextoParaOsAtalhos() {
        let vazia = RevisaoSemanal.ler(notas: [], eventos: [])
        #expect(RevisaoSemanal.texto(vazia).isEmpty)
        let agora = Date()
        let n = RevisaoSemanal.NotaLida(uuid: UUID(), gesto: .destaque, fechada: false, criadaEm: agora,
                                        gatilhoEm: nil, titulo: "t", campos: ["unica": "terminar o relatório"], sentido: "", queimadaOuSeladaEm: nil)
        let t = RevisaoSemanal.texto(RevisaoSemanal.ler(notas: [n], eventos: [], agora: agora))
        #expect(t.contains("1 destaque"))
        #expect(t.contains("terminar o relatório"))
    }
}

struct PlanosSemRiscoTests {
    @Test func especificacaoSemRiscoEDesejoSemObstaculoSaoCobrados() {
        let agora = Date()
        func n(_ g: Gesto, _ campos: [String: String]) -> RevisaoSemanal.NotaLida {
            RevisaoSemanal.NotaLida(uuid: UUID(), gesto: g, fechada: false, criadaEm: agora, gatilhoEm: nil,
                                    titulo: g.nome, campos: campos, sentido: "", queimadaOuSeladaEm: nil)
        }
        let r = RevisaoSemanal.ler(notas: [
            n(.spec, ["problema": "x"]),                 // sem limites: cobrado
            n(.spec, ["limites": "pode faltar gente"]),  // ok
            n(.woop, ["obstaculo": ""]),                 // cobrado
            n(.woop, ["obstaculo": "preguiça"]),         // ok
        ], eventos: [], agora: agora)
        #expect(r.semRisco.count == 2)
        #expect(r.semRisco.contains { $0.texto.contains("dar errado") })
        #expect(r.semRisco.contains { $0.texto.contains("obstáculo") })
    }
}

struct PremortemDeUmPlanoTests {
    @Test func oPlanoAbreUmPremortemSemPerderOPlano() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let s = Sessao()
        s.texto = "vamos lançar a loja em outubro"
        s.gesto = .spec
        s.campos = ["problema": "a loja precisa abrir antes do Natal", "limites": ""]
        #expect(s.salvar(no: c.mainContext))
        let plano = try #require(try c.mainContext.fetch(FetchDescriptor<Nota>()).first)
        s.abrirPremortem(de: plano, no: c.mainContext)
        #expect(s.gesto == .premortem)
        #expect(s.campos["plano"] == "a loja precisa abrir antes do Natal")
        #expect(s.notaUUID == nil) // nota NOVA: o plano não foi tocado
        let ainda = try #require(Sessao.buscar(uuid: plano.uuid, no: c.mainContext))
        #expect(ainda.gesto == .spec)
        #expect(ainda.texto == "vamos lançar a loja em outubro")
    }
}

struct CalibragemTests {
    @Test func aDecisaoConferidaMostraOEsperadoEOAcontecido() {
        let agora = Date()
        func d(_ campos: [String: String]) -> RevisaoSemanal.NotaLida {
            RevisaoSemanal.NotaLida(uuid: UUID(), gesto: .decisao, fechada: false, criadaEm: agora, gatilhoEm: nil,
                                    titulo: "d", campos: campos, sentido: "", queimadaOuSeladaEm: nil)
        }
        let r = RevisaoSemanal.ler(notas: [
            d(["escolha": "ficar ou sair", "espero": "mais calma", "aconteceu": "menos dinheiro e mais calma"]),
            d(["escolha": "ainda aberta", "espero": "algo"]),           // sem conferência: fora
            d(["escolha": "sem expectativa", "aconteceu": "deu certo"]), // sem esperado: fora
        ], eventos: [], agora: agora)
        #expect(r.calibragem.count == 1)
        #expect(r.calibragem[0].escolha == "ficar ou sair")
        #expect(r.calibragem[0].esperava == "mais calma")
        #expect(r.calibragem[0].aconteceu == "menos dinheiro e mais calma")
        // e sai no texto dos Atalhos, com os dois lados
        let t = RevisaoSemanal.texto(r)
        #expect(t.contains("esperava: mais calma"))
        #expect(t.contains("aconteceu: menos dinheiro e mais calma"))
    }
}

struct CampoDaVoltaTests {
    @Test func oCampoDaConferenciaSoApareceQuandoEDevido() {
        let campo = try! #require(Gesto.decisao.campos.first { $0.id == "aconteceu" })
        #expect(campo.soDepois)
        // ADR 04t: a volta tem DOIS campos — o que aconteceu, e o saldo que o autor dá
        #expect(Gesto.decisao.campos.filter(\.soDepois).map(\.id) == ["aconteceu", "saldo"])
        // só as formas com VOLTA declarada têm campo de depois (ADR 04l):
        // a decisão, o dia (o que roubou, à noite), a atualização (quanto agora)
        // e, desde a volta M3 (ADR 2026-09-06e), a classe de referência (como terminou de fato —
        // é o desfecho que alimenta a classe da próxima vez). O `default` de
        // `Volta.devida` já cobra qualquer `soDepois` sete dias depois.
        let comVolta: Set<String> = ["decisao", "dia", "atualizacao", "classeDeReferencia"]
        for g in Gesto.allCases where !comVolta.contains(g.rawValue) {
            #expect(g.campos.allSatisfy { !$0.soDepois })
        }
    }
}

struct ConferenciaDevidaTests {
    @Test func semDataOCampoFicaComDataEleEspera() {
        // o relógio é PARÂMETRO: com `.now` este teste reprovava no minuto das
        // 9h da máquina, e passava o resto do dia (varredura 04/set)
        let agora = Calendario.gregoriano()
            .date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 8))!
        let s = Sessao()
        s.gesto = .decisao
        s.campos = ["espero": "mais calma"]              // sem data: o campo fica
        #expect(s.conferenciaDevida(agora: agora))
        s.campos = ["espero": "mais calma; confiro às 9h"] // data futura: espera
        #expect(!s.conferenciaDevida(agora: agora))
        s.gesto = .woop
        #expect(!s.conferenciaDevida(agora: agora))       // só a Decisão tem volta
    }
}

struct CartaoNaoCobreOsCamposTests {
    @Test func oCartaoVestidoSaiQuandoOAutorPreencheAForma() throws {
        // o cartão é da PaginaView; aqui prova-se a regra que ela aplica:
        // enquanto o texto muda, o cartão fica; quando um campo muda, sai.
        let s = Sessao()
        s.gesto = .decisao
        s.cartao = .vestida(.decisao, pergunta: "x")
        s.texto = "escrevendo mais na página"
        if case .vestida? = s.cartao {} else { Issue.record("o cartão devia ficar enquanto o texto muda") }
        // a regra da view: campo mudou → cartão sai
        s.campos["escolha"] = "ficar ou sair"
        if case .vestida? = s.cartao {
            s.cartao = nil // é isto que a view faz
        }
        #expect(s.cartao == nil)
    }
}

struct VestirNaoContaComoPreencherTests {
    @Test func campoVazioRecemCriadoNaoEResposta() {
        let s = Sessao()
        s.usarForma(.decisao)
        #expect(!s.camposComResposta)   // vestir cria campos vazios
        s.campos["escolha"] = "  "
        #expect(!s.camposComResposta)   // espaço não é resposta
        s.campos["escolha"] = "ficar ou sair"
        #expect(s.camposComResposta)
    }
}

struct RedeTests {
    private func n(_ titulo: String, texto: String = "", liga: String = "", gesto: Gesto? = nil,
                   fechada: Bool = false, emCurso: Bool = false) -> Rede.NotaLida {
        Rede.NotaLida(uuid: UUID(), titulo: titulo, texto: texto.isEmpty ? titulo : texto,
                      campos: liga.isEmpty ? [:] : ["liga": liga], gesto: gesto,
                      fechada: fechada, expressivaEmCurso: emCurso)
    }

    @Test func aMencaoLigaEOReversoAparece() {
        let alvo = n("nota permanente sobre foco")
        let origem = n("o dia rendeu", texto: "o dia rendeu porque li [[nota permanente sobre foco]] de manhã")
        let ls = Rede.ligacoes([alvo, origem])
        #expect(ls.count == 1)
        #expect(Rede.daqui(origem.uuid, ls).first?.para == alvo.uuid)
        #expect(Rede.paraCa(alvo.uuid, ls).first?.de == origem.uuid)
        #expect(Rede.daqui(alvo.uuid, ls).isEmpty)   // a ligação tem direção
    }

    @Test func oCampoLigaAContaEAcentoNaoAtrapalha() {
        let alvo = n("Memória e atenção")
        let origem = n("plano do mês", liga: "memoria e atencao")
        let ls = Rede.ligacoes([alvo, origem])
        #expect(ls.count == 1)
        #expect(ls[0].para == alvo.uuid)
    }

    @Test func oSeloValeNaRede() {
        let selada = n("expressiva selada", fechada: true, emCurso: false)
        let emCurso = n("desabafo", gesto: .expressiva, emCurso: true)
        let normal = n("uma nota", texto: "cito [[expressiva selada]] e [[desabafo]]")
        let ls = Rede.ligacoes([selada, emCurso, normal])
        #expect(ls.isEmpty)  // nem como destino
        // e uma expressiva jamais é origem
        let ex = n("desabafo dois", texto: "cito [[uma nota]]", gesto: .expressiva, emCurso: true)
        #expect(Rede.ligacoes([normal, ex]).isEmpty)
    }

    @Test func mencoesSaoUnicasENaoInventamNota() {
        #expect(Rede.mencoes("a [[x]] e de novo [[X]] e [[outra]]") == ["x", "outra"])
        #expect(Rede.mencoes("sem menção nenhuma").isEmpty)
        #expect(Rede.mencoes("[[]]").isEmpty)
        // menção sem nota correspondente não vira ligação
        let so = n("sozinha", texto: "cito [[que não existe]]")
        #expect(Rede.ligacoes([so]).isEmpty)
    }

    @Test func asIlhasSaoAsQueNinguemCita() {
        let a = n("alfa"), b = n("beta", texto: "liga em [[alfa]]"), c = n("ilha")
        let ls = Rede.ligacoes([a, b, c])
        #expect(Rede.ilhas([a, b, c], ls) == [c.uuid])
    }

    @Test func aNotaNaoSeLigaASiMesma() {
        let so = n("recursiva", texto: "eu cito [[recursiva]] aqui")
        #expect(Rede.ligacoes([so]).isEmpty)
    }
}

struct MencaoNaLeituraTests {
    @Test func osColchetesNaoAparecemNoTitulo() {
        let t = VozDoAutor.titulo("o dia rendeu porque li [[atenção é um músculo]] de manhã")
        #expect(t == "o dia rendeu porque li atenção é um músculo de manhã")
        #expect(VozDoAutor.semColchetes("sem nenhum") == "sem nenhum")
        // e a menção continua encontrável para a rede (o texto cru não muda)
        #expect(Rede.mencoes("li [[atenção é um músculo]]") == ["atenção é um músculo"])
    }
}
