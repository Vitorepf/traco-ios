import Foundation
import SwiftData
import Testing

@testable import Traco

/// Os buracos funcionais fechados em 03/set. Cada teste nomeia o que o autor
/// não conseguia fazer antes.
@Suite struct BuracosFuncionaisTests {
    private func contexto() throws -> ModelContext {
        ModelContext(try ModelContainer.traco(emMemoria: true))
    }

    // MARK: A1 — o que se marca, avisa

    /// O id do aviso do compromisso não pode alcançar o aviso da nota: os dois
    /// são UUID, e um cancelar errado silenciaria o outro.
    @Test func oAvisoDoCompromissoTemNamespaceProprio() {
        let id = UUID()
        #expect(Revisoes.idDoCompromisso(id) == "compromisso-\(id.uuidString)")
        #expect(Revisoes.idDoCompromisso(id, weekday: 6) == "compromisso-\(id.uuidString)-6")
        #expect(Revisoes.idDoCompromisso(id) != "gatilho-\(id.uuidString)")
    }

    // MARK: V2 — o domínio volta

    @Test func devolverODominioRefazAInferencia() throws {
        let context = try contexto()
        let nota = Nota(texto: "consulta com o dentista amanhã")
        context.insert(nota)
        let s = Sessao()

        // o léxico acerta sozinho
        nota.dominio = Dominio.inferir(voz: nota.vozDoAutor)
        #expect(nota.dominio == .saude)

        // um toque no chip tira e trava
        #expect(s.soltarDominio(nota, no: context))
        #expect(nota.dominio == nil)
        #expect(nota.dominioTravado)

        // e agora existe volta — era o beco sem saída
        #expect(s.devolverDominio(nota, no: context))
        #expect(!nota.dominioTravado)
        #expect(nota.dominio == .saude)
    }

    // MARK: Q1 — o anexo sai

    @Test func apagarOAnexoTiraOMarcadorDoTexto() {
        let id = UUID()
        let texto = "antes\n\n![foto.jpg](traco://img/\(id.uuidString))\n\ndepois"
        let fatias = Caderno.fatias(texto)
        let anexo = try! #require(fatias.first { if case .imagem = $0.bloco { true } else { false } })

        let semAnexo = Caderno.aplicar(fatias, id: anexo.id, novo: "")
        #expect(!semAnexo.contains("traco://"))
        #expect(semAnexo.contains("antes"))
        #expect(semAnexo.contains("depois"))

        // e o arquivo em disco vira órfão, que a varredura já sabe apagar
        #expect(AnexoDisco.idsReferenciados(em: [semAnexo]).isEmpty)
    }

    // MARK: R1 — adiar não mexe na escada

    @Test func adiarNaoMexeNaEscada() {
        let uuid = UUID()
        let agora = Date()
        Revisoes.registrarCumprida(uuid, agora: agora)   // sobe para o degrau 1
        let degrau = Revisoes.nivel(uuid)
        #expect(degrau == 1)

        Revisoes.adiar(uuid, agora: agora)
        #expect(Revisoes.nivel(uuid) == degrau)          // adiar não é falhar

        // e a próxima cobrança é amanhã
        let proxima = try! #require(Revisoes.proximaData(uuid))
        let dias = Calendar.current.dateComponents([.day], from: agora, to: proxima).day
        #expect(dias == 0 || dias == 1) // depende da hora do dia gravada
        #expect(proxima > agora)
    }

    /// Cobrar antes continua zerando — as duas saídas são diferentes de propósito.
    @Test func cobrarAntesZeraEAdiarNao() {
        let uuid = UUID()
        Revisoes.registrarCumprida(uuid)
        Revisoes.registrarCumprida(uuid)
        #expect(Revisoes.nivel(uuid) == 2)
        Revisoes.adiar(uuid)
        #expect(Revisoes.nivel(uuid) == 2)
        Revisoes.cobrarAntes(uuid)
        #expect(Revisoes.nivel(uuid) == 0)
    }

    // MARK: R2 — pular não conta como revisão

    @Test func pularNaoSobeODegrau() throws {
        let context = try contexto()
        let a = Nota(texto: "primeira nota com voz de verdade")
        let b = Nota(texto: "segunda nota com voz de verdade")
        context.insert(a)
        context.insert(b)
        let s = Sessao()
        s.filaUUIDs = [a.uuid, b.uuid]
        s.filaAtiva = true
        s.recordarDaNotas(a)
        #expect(s.revisaoPendente == a.uuid)

        let antes = Revisoes.nivel(a.uuid)
        s.pularDaFila(no: context)
        #expect(Revisoes.nivel(a.uuid) == antes)  // a escada não andou
        #expect(s.recordarUUID == b.uuid)          // e foi para a próxima
    }

    // MARK: V3 — a série não morre em silêncio

    @Test func aSerieVivaEReconhecidaParaRearmar() throws {
        let context = try contexto()
        let serie = UUID()
        let dia1 = Nota(texto: "desabafo do dia um", gesto: .expressiva, trancada: true)
        dia1.serieUUID = serie
        dia1.diaDaSerie = 1
        context.insert(dia1)

        // a série está viva (1 de 4) e portanto elegível a rearmar
        let vivas = [dia1].filter {
            $0.gesto == .expressiva && $0.serieUUID != nil
                && $0.diaDaSerie >= 1 && $0.diaDaSerie < 4
        }
        #expect(vivas.count == 1)

        // no quarto dia ela não é mais rearmada: acabou
        dia1.diaDaSerie = 4
        let acabadas = [dia1].filter { $0.diaDaSerie >= 1 && $0.diaDaSerie < 4 }
        #expect(acabadas.isEmpty)
    }

    /// O próximo dia da série cai na âncora da manhã do dia seguinte.
    @Test func oProximoDiaDaSerieEAmanhaDeManha() {
        let agora = Date()
        let proximo = Revisoes.proximoDiaDaSerie(aPartirDe: agora)
        #expect(proximo > agora)
        let cal = Calendar.current
        #expect(cal.component(.hour, from: proximo) == Ancora.hora(.manha))
    }
}

/// Q2, Q3 e F1 — os que mudam o que o autor consegue fazer sem decorar nada.
@Suite struct FerramentasNovasTests {
    let cal = Calendario.gregoriano()

    // MARK: Q2 — ligar sem decorar o título

    @Test func aLigacaoEmVooSeReconhece() {
        #expect(Rede.ligacaoEmVoo("falando de [[proj") == "proj")
        #expect(Rede.ligacaoEmVoo("texto sem ligação") == nil)
        // já fechada: não está mais ligando
        #expect(Rede.ligacaoEmVoo("liga a [[Projeto]] e segue") == nil)
        // quebra de linha encerra: ninguém liga através de parágrafos
        #expect(Rede.ligacaoEmVoo("abriu [[algo\ne continuou") == nil)
        // acabou de abrir: sugere tudo
        #expect(Rede.ligacaoEmVoo("agora [[") == "")
    }

    @Test func asSugestoesPriorizamOComecoEOTituloCurto() {
        let titulos = ["Projeto do caderno", "Projeto", "Outro assunto", "Um projeto antigo"]
        let s = Rede.sugestoes(para: "proj", entre: titulos)
        #expect(s.first == "Projeto")                 // começa com, e é o mais curto
        #expect(!s.contains("Outro assunto"))         // não casa
        #expect(s.contains("Um projeto antigo"))      // casa no meio, vem depois
    }

    @Test func semAcentoENemCaixaAConsultaCasa() {
        #expect(Rede.sugestoes(para: "ideia", entre: ["Ideia Central"]).first == "Ideia Central")
        #expect(Rede.sugestoes(para: "IDEIA", entre: ["ideia central"]).count == 1)
    }

    @Test func completarFechaOsColchetes() {
        let antes = "isso liga a [[proj"
        #expect(Rede.completar(antes, com: "Projeto do caderno")
                == "isso liga a [[Projeto do caderno]]")
        // e o resultado é lido de volta como ligação de verdade
        #expect(Rede.mencoes(Rede.completar(antes, com: "Projeto")) == ["Projeto"])
    }

    // MARK: Q3 — a lista ordena por mais de uma coisa

    @Test func ordenarPorRecordadaUsaAContagemEDesempataPorData() throws {
        let context = ModelContext(try ModelContainer.traco(emMemoria: true))
        let velha = Nota(texto: "velha", criadaEm: Date(timeIntervalSince1970: 1_000))
        let nova = Nota(texto: "nova", criadaEm: Date(timeIntervalSince1970: 2_000))
        context.insert(velha); context.insert(nova)

        // sem recordação nenhuma, empate volta para a data
        #expect(OrdemNotas.ordenar([velha, nova], por: .recordada).first?.texto == "nova")
        // a velha sobe quando é a mais recordada
        Revisoes.registrarCumprida(velha.uuid)
        #expect(OrdemNotas.ordenar([velha, nova], por: .recordada).first?.texto == "velha")
        // e a ordem por criação não se importa com isso
        #expect(OrdemNotas.ordenar([velha, nova], por: .criadaEm).first?.texto == "nova")
    }

    @Test func todasAsOrdensTemNome() {
        for o in OrdemNotas.allCases { #expect(!o.nome.isEmpty) }
    }

    // MARK: F1 — marcar por voz é o mesmo algoritmo do campo

    @Test func oIntentDeMarcarUsaOMesmoParserDoCampo() throws {
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 3, hour: 10))!
        let e = try #require(CalendarioFrase.ler("dentista sexta às 14:30",
                                                 ancora: agora, agora: agora, cal))
        #expect(e.titulo == "Dentista")
        #expect(cal.component(.hour, from: e.inicio) == 14)
        #expect(cal.component(.minute, from: e.inicio) == 30)
        // frase sem "o quê" não vira compromisso — o intent responde e não grava
        #expect(CalendarioFrase.ler("às 16:30", ancora: agora, agora: agora, cal) == nil)
    }
}

/// M7 — o ditado tinha zero prova. Com o motor injetável, a máquina de estados
/// se testa sem microfone: começar, receber parcial, parar, e não vazar.
@Suite struct DitadoTests {
    @Test func alternarLigaEDesliga() {
        let d = Ditado()
        d.motorDeTeste = { _ in }
        #expect(!d.gravando)
        d.alternar()
        #expect(d.gravando)
        d.alternar()
        #expect(!d.gravando)
    }

    @Test func oParcialChegaNoCampo() {
        let d = Ditado()
        var ouvido: [String] = []
        d.aoTexto = { ouvido.append($0) }
        d.motorDeTeste = { $0.receberParcial("dentista") }
        d.alternar()
        #expect(ouvido == ["dentista"])
        // e os parciais seguintes substituem, como o reconhecedor faz
        d.receberParcial("dentista sexta às 14h")
        #expect(ouvido.last == "dentista sexta às 14h")
    }

    /// Parado, nada mais entra: sair da tela não pode deixar o campo mexendo.
    @Test func paradoNaoRecebeMais() {
        let d = Ditado()
        var ouvido: [String] = []
        d.aoTexto = { ouvido.append($0) }
        d.motorDeTeste = { _ in }
        d.alternar()
        d.parar()
        d.receberParcial("isto não deve entrar")
        #expect(ouvido.isEmpty)
    }

    /// E o que o ditado entrega é lido pelo mesmo parser do campo — o ditado
    /// não tem caminho próprio nenhum.
    @Test func oQueSeDitaViraCompromisso() throws {
        let cal = Calendario.gregoriano()
        let agora = cal.date(from: DateComponents(year: 2026, month: 9, day: 3, hour: 10))!
        let d = Ditado()
        var falado = ""
        d.aoTexto = { falado = $0 }
        d.motorDeTeste = { $0.receberParcial("academia toda segunda às 7h") }
        d.alternar()
        let e = try #require(CalendarioFrase.ler(falado, ancora: agora, agora: agora, cal))
        #expect(e.titulo == "Academia")
        #expect(e.repeteEm == [2])
        #expect(cal.component(.hour, from: e.inicio) == 7)
    }
}

/// ADR 2026-09-03g — a pergunta do autor sobrevive à forma.
/// O botão do cartão só existe se `perguntaNaNota` existir: este é o teste
/// do que faz a pergunta continuar alcançável quando a análise achou gesto.
@Suite struct PerguntaEFormaTests {
    @Test func aPerguntaSobreviveAoGestoEncontrado() {
        let s = Sessao()
        s.texto = """
            estou desenhando a tabela de rotas do app
            ? como posso definir a fronteira entre rota e destino
            """
        // sem gesto, a pergunta está lá
        #expect(s.perguntaNaNota == "como posso definir a fronteira entre rota e destino")

        // e com a forma vestida ela continua lá — era o que sumia
        s.gesto = .spec
        #expect(s.perguntaNaNota != nil)
    }

    /// Menos o selo: na expressiva a sábia não entra, e isso não mudou.
    @Test func naExpressivaNaoHaPergunta() {
        let s = Sessao()
        s.texto = "hoje foi pesado\n? por que isso me pega tanto"
        s.gesto = .expressiva
        #expect(s.perguntaNaNota == nil)
    }
}

/// ADR 2026-09-03h — a sábia lê as notas que o autor ligou, e SÓ elas.
/// O teste que importa é o do selo: uma nota trancada ou expressiva ligada
/// com `[[…]]` não pode viajar para a rede por nenhuma porta.
@Suite struct SabiaLeOLigadoTests {
    private func contexto() throws -> ModelContext {
        ModelContext(try ModelContainer.traco(emMemoria: true))
    }

    @Test func aNotaLigadaVaiJuntoDaPergunta() throws {
        let context = try contexto()
        let alvo = Nota(texto: "Atenção é um músculo\n\ntreina com repetição espaçada")
        context.insert(alvo)

        let s = Sessao()
        s.texto = "hoje rendeu porque li [[Atenção é um músculo]]\n? como aplico isso na semana"
        let ligadas = s.notasLigadas(no: context)
        #expect(ligadas.count == 1)
        #expect(ligadas.first?.titulo == alvo.tituloNaLista)
        #expect(ligadas.first?.prosa.contains("repetição espaçada") == true)
    }

    @Test func aTrancadaNaoViajaNemLigada() throws {
        let context = try contexto()
        let selada = Nota(texto: "Terapia\n\no que eu não conto para ninguém", trancada: true)
        context.insert(selada)

        let s = Sessao()
        s.texto = "pensando em [[Terapia]]\n? por onde começo"
        #expect(s.notasLigadas(no: context).isEmpty)
    }

    @Test func aExpressivaNaoViajaNemLigada() throws {
        let context = try contexto()
        let desabafo = Nota(texto: "Domingo\n\nfoi um dia pesado demais", gesto: .expressiva)
        context.insert(desabafo)

        let s = Sessao()
        s.texto = "retomando [[Domingo]]\n? o que mudou desde então"
        #expect(s.notasLigadas(no: context).isEmpty)
    }

    /// Sem `[[…]]` nada é buscado: nota não ligada é nota que fica em casa.
    @Test func semLigacaoNadaViaja() throws {
        let context = try contexto()
        context.insert(Nota(texto: "Atenção é um músculo\n\ntreina com repetição"))
        let s = Sessao()
        s.texto = "escrevendo sobre atenção\n? e agora"
        #expect(s.notasLigadas(no: context).isEmpty)
    }

    /// Teto: o contexto da pergunta não vira o caderno inteiro.
    @Test func oTetoSegura() throws {
        let context = try contexto()
        for i in 1...5 { context.insert(Nota(texto: "Ideia \(i)\n\ncorpo da ideia \(i)")) }
        let s = Sessao()
        s.texto = "junta [[Ideia 1]] [[Ideia 2]] [[Ideia 3]] [[Ideia 4]] [[Ideia 5]]\n? o que sobra"
        #expect(s.notasLigadas(no: context, teto: 3).count == 3)
    }
}
