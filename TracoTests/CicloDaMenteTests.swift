import Foundation
import SwiftData
import Testing
import UIKit
@testable import Traco

/// ADRs 2026-09-04h a 04r — o ciclo da mente. Cada suíte prova uma peça e
/// a rota do selo que ela poderia furar.
@MainActor private func contextoDeTeste() throws -> ModelContext {
    ModelContext(try ModelContainer.traco(emMemoria: true))
}

private func temp(_ nome: String) -> URL {
    let u = FileManager.default.temporaryDirectory.appendingPathComponent("\(nome)-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
    return u
}

@Suite(.serialized) struct SinaisTests {
    init() { Sinais.url = temp("sinais").appendingPathComponent("sinais.json") }

    @Test func oSinalFicaNoDiscoEEsquecerApaga() {
        Sinais.solto(.woop)
        Sinais.pergunta("qual é o obstáculo interno?", forma: .woop, serviu: false)
        let lidos = Sinais.todos()
        #expect(lidos.count == 2)
        #expect(lidos.last?.tipo == .pergunta)
        #expect(lidos.last?.serviu == false)
        #expect(Sinais.emPalavras().hasPrefix("2 sinais"))
        Sinais.esquecerTudo()
        #expect(Sinais.todos().isEmpty)
    }

    @Test func tresSoltosSeguidosViramSugestaoEUmFicouDevolveOVestir() {
        let tres = [Sinal(tipo: .solto, forma: "woop"), Sinal(tipo: .solto, forma: "woop"), Sinal(tipo: .solto, forma: "woop")]
        #expect(Sinais.sugerirEmVezDeVestir(.woop, sinais: tres))
        #expect(!Sinais.sugerirEmVezDeVestir(.spec, sinais: tres))
        #expect(!Sinais.sugerirEmVezDeVestir(.woop, sinais: tres + [Sinal(tipo: .ficou, forma: "woop")]))
        #expect(!Sinais.sugerirEmVezDeVestir(.woop, sinais: Array(tres.prefix(2))))
    }

    @Test func oTetoSegura() {
        for i in 0..<(Sinais.teto + 20) { Sinais.registrar(Sinal(tipo: .ficou, forma: "n\(i)")) }
        let lidos = Sinais.todos()
        #expect(lidos.count == Sinais.teto)
        #expect(lidos.last?.forma == "n\(Sinais.teto + 19)")
    }
}

@Suite struct DegrausTests {
    @Test func oDegrauSobeComAPratica() {
        #expect(Degraus.instigar(concluidas: 0) == 0)
        #expect(Degraus.instigar(concluidas: 2) == 1)
        #expect(Degraus.instigar(concluidas: 5) == 2)
        #expect(Degraus.instigar(concluidas: 10) == 3)
        #expect(Degraus.instigar(concluidas: 40) == 4)
        let s = [Sinal(tipo: .ficou, forma: "spec"), Sinal(tipo: .ficou, forma: "spec"), Sinal(tipo: .solto, forma: "spec")]
        #expect(Degraus.concluidas(.spec, sinais: s) == 2)
        // ADR 09i: o degrau muda o que se cobra e NÃO se nomeia — a redação
        // anterior ("DEGRAU 0", "o passo que se pula") voltava citada.
        #expect(Degraus.instrucaoDeInstigar(0).contains("passo mais básico"))
        #expect(Degraus.instrucaoDeInstigar(9) == Degraus.instrucaoDeInstigar(4))
        #expect(Degraus.instrucaoDeInstigar(9).contains("LIMITE"))
        // ADR 09i·2: a medida de 09/09 leu o degrau 4 repetindo o degrau 0. O
        // degrau é o único parâmetro da operação: cada nível diz o que cobra E
        // o que não conta como cumprido, e nenhum é igual a outro.
        #expect(Set((0...4).map { Degraus.instrucaoDeInstigar($0) }).count == 5)
        for d in 1...4 { #expect(Degraus.instrucaoDeInstigar(d).contains("NÃO cumpre isto")) }
        #expect(Degraus.instrucaoDeInstigar(4).contains("deixa de valer"))
        for d in 0...4 {
            #expect(!Sabia.vazaAlheio(Degraus.instrucaoDeInstigar(d), termos: Sabia.andaimeDoPedido, texto: ""))
        }
    }

    /// ADR 04x — dois "não serviu" descem, dois "serviu" sobem, misto fica.
    @Test func oDegrauOuveOSinal() {
        let tres = Array(repeating: Sinal(tipo: .ficou, forma: "woop"), count: 3) // base 2
        #expect(Degraus.instigar(.woop, sinais: tres) == 2)
        let naoServiu = tres + [Sinal(tipo: .pergunta, forma: "woop", serviu: false), Sinal(tipo: .pergunta, forma: "woop", serviu: false)]
        #expect(Degraus.instigar(.woop, sinais: naoServiu) == 1)
        let serviu = tres + [Sinal(tipo: .pergunta, forma: "woop", serviu: true), Sinal(tipo: .pergunta, forma: "woop", serviu: true)]
        #expect(Degraus.instigar(.woop, sinais: serviu) == 3)
        let misto = tres + [Sinal(tipo: .pergunta, forma: "woop", serviu: true), Sinal(tipo: .pergunta, forma: "woop", serviu: false)]
        #expect(Degraus.instigar(.woop, sinais: misto) == 2)
        // nunca abaixo de 0 nem acima de 4; sinal de outra forma não conta
        #expect(Degraus.instigar(.spec, sinais: [Sinal(tipo: .pergunta, forma: "spec", serviu: false), Sinal(tipo: .pergunta, forma: "spec", serviu: false)]) == 0)
        #expect(Degraus.instigar(.spec, sinais: naoServiu) == 0)
        #expect(Degraus.emPalavras(sinais: []) == "")
        #expect(Degraus.emPalavras(sinais: naoServiu) == "WOOP no degrau 1 (desceu: duas perguntas não serviram).")
    }
}

@Suite struct RetratoTests {
    private func nota(_ g: Gesto?, _ campos: [String: String], fechada: Bool = false, dias: Int = 0) -> Retrato.NotaLida {
        Retrato.NotaLida(gesto: g, fechada: fechada, expressiva: g == .expressiva,
                         criadaEm: Date.now.addingTimeInterval(-Double(dias) * 86_400), campos: campos,
                         vozDoAutor: true)
    }

    @Test func oRetratoSoTemAsPalavrasDoAutorEContagens() {
        let notas = [
            nota(.woop, ["obstaculo": "o celular na cama"]),
            nota(.woop, ["obstaculo": "a preguiça das 6h"]),
            nota(.palavra, ["minhas": "sofrer por antecipação"]),
            nota(.decisao, ["espero": "vender em 2 semanas", "aconteceu": "demorou um mês"]),
            // ADR 04t: o saldo do autor manda sobre a leitura por palavras
            nota(.decisao, ["espero": "10 clientes", "aconteceu": "vieram menos, uns 10", "saldo": "igual"]),
        ]
        let sinais = [
            Sinal(tipo: .pergunta, forma: "spec", serviu: false, texto: "o que fica de fora?"),
            Sinal(tipo: .naoVoltou, forma: "woop", faltaram: 2, deQuantos: 5),
        ]
        let r = Retrato.ler(notas: notas, sinais: sinais)
        #expect(r.contains("o celular na cama"))
        #expect(r.contains("a preguiça das 6h"))
        #expect(r.contains("sofrer por antecipação"))
        #expect(r.contains("2 de 5 pontos não voltaram"))
        #expect(r.contains("aquém do esperado em 1, igual em 1, além em 0"))
        #expect(!r.contains("o que fica de fora?")) // sinal sem dependências não autoriza reenviar a pergunta
        #expect(!r.contains("melhor") && !r.contains("pior"))
        #expect(r.count <= Retrato.teto + 1)
    }

    @Test func oSeloCortaAntes() {
        let notas = [
            nota(.expressiva, [:], fechada: true),
            nota(.woop, ["obstaculo": "isto NÃO pode sair"], fechada: true),
        ]
        let r = Retrato.ler(notas: notas, sinais: [])
        #expect(r.isEmpty)
    }

    @Test func perguntaDerivadaSemOrigemNaoVoltaPeloRetratoAposSeloOuExclusao() {
        let pergunta = "Como comunicar à Marina o fim da sociedade em dezembro?"
        for serviu in [true, false] {
            let sinal = Sinal(tipo: .pergunta, forma: "spec", serviu: serviu, texto: pergunta)
            for notas in [[], [nota(.spec, [:], fechada: true)], [nota(.expressiva, [:])]] {
                let r = Retrato.ler(notas: notas, sinais: [sinal])
                #expect(r.isEmpty)
            }
            let r = Retrato.ler(notas: [nota(.woop, ["obstaculo": "O celular na cama"])], sinais: [sinal])
            #expect(r.contains("O celular na cama"))
            #expect(!r.contains("Marina") && !r.contains("sociedade"))
        }
    }

    @Test func retratoVazioNaoViaja() {
        #expect(Retrato.ler(notas: [], sinais: []).isEmpty)
        #expect(Sabia.blocoDoRetrato("").isEmpty)
        #expect(Sabia.blocoDoRetrato("Formas: 2 WOOP.").contains("SOBRE QUEM ESCREVE"))
    }
}

@Suite struct ContraparteTests {
    @Test func tresChavesInformacaoNuncaInstrucao() {
        let ok = Sabia.parseContraparte(#"{"contra":"A tese oposta sustenta que o custo de trocar supera o ganho de velocidade.","foraDaLista":"Adiar a escolha um mês e medir o uso real.","outroCampo":"Na aviação, a lista de verificação nasceu de um acidente, não de uma reunião."}"#)
        #expect(ok?.contra.hasPrefix("A tese oposta") == true)
        #expect(ok?.outroCampo.contains("aviação") == true)
        // instrução é descartada; chave extra derruba tudo; sem conteúdo = nil
        let instrucao = Sabia.parseContraparte(#"{"contra":"Você deve reconsiderar a opção A com calma.","foraDaLista":"","outroCampo":""}"#)
        #expect(instrucao == nil)
        #expect(Sabia.parseContraparte(#"{"contra":"Uma frase honesta e longa o bastante.","resumo":"x"}"#) == nil)
        #expect(Sabia.parseContraparte("claro! aqui vai") == nil)
    }
}

/// ADR 2026-09-09i — as duas caras do mesmo defeito medido em 08/09: o modelo
/// enche o espaço com material que não veio do autor. No `instigar` era o NOSSO
/// andaime voltando como assunto da pergunta; no `contrapor`, evidência
/// fabricada. As frases abaixo são as SAÍDAS REAIS da corrida de 08/09
/// (`prova/q-qualidade-avaliacoes.jsonl`), não paráfrases.
@Suite struct AndaimeNaoVoltaAoAutorTests {
    /// O rascunho do caso `continuidade-instigar`, palavra por palavra.
    let rascunho = "Quero começar a praticar espanhol, mas sempre espero ter uma hora livre. Hoje tenho quinze minutos e estou sozinho."

    @Test func aPerguntaSobreONossoAndaimeNaoVolta() {
        let vazadas = [
            "Qual é o movimento básico que se pula ao esperar ter uma hora livre?",
            "O que significa 'passo que se pula' neste contexto?",
            "Como a nota 'DEGRAU 0' se relaciona com o método que você menciona?",
            "Quais passos do método foram executados e quais foram ignorados?",
            "O que deveria ter acontecido se o movimento básico tivesse sido feito?",
        ]
        for p in vazadas {
            let json = #"{"perguntas":["\#(p)","O que exatamente significa praticar espanhol em quinze minutos?"]}"#
            #expect(Sabia.parsePerguntas(json, texto: rascunho) == ["O que exatamente significa praticar espanhol em quinze minutos?"])
        }
        // só andaime = nada volta; a página fica com as perguntas do método
        let sóAndaime = #"{"perguntas":["Qual é o movimento básico que foi pulado?","Qual é o degrau em que você está?"]}"#
        #expect(Sabia.parsePerguntas(sóAndaime, texto: rascunho) == nil)
    }

    /// O par que muda só a EVIDÊNCIA: a mesma palavra, escrita pelo AUTOR.
    /// A guarda sabe de onde a palavra veio, não se ela é feia.
    @Test func aPalavraQueOAutorEscreveuPodeVoltar() {
        let dele = "Sigo um método de estudo em degraus e travei no segundo degrau."
        let json = #"{"perguntas":["O que define a passagem de um degrau para o próximo no seu método?"]}"#
        #expect(Sabia.parsePerguntas(json, texto: dele)?.count == 1)
        #expect(Sabia.parsePerguntas(json, texto: rascunho) == nil)
    }

    /// O defeito OPOSTO reprova igual: perguntas boas passam inteiras.
    @Test func aPerguntaBoaPassaInteira() {
        let json = #"{"perguntas":["Qual é o critério objetivo que vai decidir entre alugar ou atender em casa?","Que evidência faria você mudar de ideia depois de escolher?","Quanto custa errar para cada opção em reais e em tempo?"]}"#
        #expect(Sabia.parsePerguntas(json, texto: "Preciso decidir entre alugar uma sala por R$ 900 ou atender de casa.")?.count == 3)
    }

    @Test func oContratoDeInstigarDizDeQuemEOAssunto() {
        for pedaço in ["nunca as cite", "é DELA, seja qual for", "Não suponha nenhum fato",
                       "MANDA nas perguntas", "Não devolva vazio"] {
            #expect(Sabia.sistemaInstigar.contains(pedaço))
        }
        // ADR 09i·2: proibir por NOME comprou mudez sobre a palavra do autor.
        // O contrato não lista mais palavra proibida — ele diz de onde ela vem.
        for nome in ["sobre o degrau", "sobre o método", "sobre a forma da nota"] {
            #expect(!Sabia.sistemaInstigar.contains(nome))
        }
    }

    /// A medida que o G3 pediu: o degrau CHEGA (ele entra na mensagem de
    /// sistema em toda chamada, com rótulo e por último) — o que faltava era
    /// mandar. Dois degraus, duas mensagens diferentes, sem aparelho.
    @Test func oDegrauChegaEMandaNaMensagemDeSistema() {
        let zero = Sabia.sistemaDeInstigar(gesto: nil, degrau: 0)
        let quatro = Sabia.sistemaDeInstigar(gesto: nil, degrau: 4)
        #expect(zero != quatro)
        #expect(quatro.hasSuffix("O QUE ESTAS PERGUNTAS COBRAM:\n" + Degraus.instrucaoDeInstigar(4)))
        #expect(zero.hasSuffix(Degraus.instrucaoDeInstigar(0)))
        // o método é nosso e vai nas instruções; o pedido leva só o do autor
        let comMetodo = Sabia.sistemaDeInstigar(gesto: .decisao, degrau: 2)
        #expect(comMetodo.contains(Gesto.decisao.metodo))
        #expect(comMetodo.hasSuffix(Degraus.instrucaoDeInstigar(2)))
    }

    /// O caso `q4-instigar-o-autor-escreve-metodo`, palavra por palavra: a nota
    /// é DELE e usa as duas palavras que mais se parecem com o nosso andaime.
    /// A guarda tem de derrubar um lado e não encostar no outro.
    @Test func aGuardaDerrubaONossoENaoEncostaNoDele() {
        let dele = "Sigo um método de estudo em degraus e travei no segundo degrau: consigo ler, mas não consigo escrever nada sem consultar a gramática."
        let sobreOMetodoDele = "O que exatamente o seu método pede no segundo degrau que você ainda não consegue fazer?"
        #expect(Sabia.parsePerguntas(#"{"perguntas":["\#(sobreOMetodoDele)"]}"#, texto: dele) == [sobreOMetodoDele])
        // o mesmo par, mudando SÓ a procedência: quem não escreveu não ouve
        #expect(Sabia.parsePerguntas(#"{"perguntas":["\#(sobreOMetodoDele)"]}"#, texto: rascunho) == nil)
        // e o acento não é procedência: quem digitou sem ele continua dono
        let semAcento = "Sigo um metodo de estudo em degraus e travei no segundo degrau."
        #expect(Sabia.parsePerguntas(#"{"perguntas":["\#(sobreOMetodoDele)"]}"#, texto: semAcento) == [sobreOMetodoDele])
        // "sabia" é verbo de todo dia e saiu da lista: a pergunta não cai por isso
        let comVerbo = "Como você sabia que quinze minutos não bastariam?"
        #expect(Sabia.parsePerguntas(#"{"perguntas":["\#(comVerbo)"]}"#, texto: rascunho) == [comVerbo])
    }

    /// `contrapor`: a evidência que o autor não deu cai, e só ela.
    @Test func oContrapontoNaoSeApoiaEmEvidenciaFabricada() {
        let nota = "Não adianta eu correr se não for pelo menos cinco quilômetros; menos que isso não conta."
        let cru = #"""
        {"contra":"Corridas curtas e frequentes elevam o VO2máx e reduzem risco de lesão mais que sessões longas esporádicas, segundo metanálises de 2022.",
         "foraDaLista":"Caminhada em esteira inclinada a 12 % por 30 min, que ativa os mesmos sistemas aeróbicos sem impacto.",
         "outroCampo":"Na aviação, a lista de verificação nasceu de um acidente, não de uma reunião."}
        """#
        let r = Sabia.parseContraparte(cru, texto: nota)
        #expect(r?.contra.isEmpty == true)
        #expect(r?.foraDaLista.isEmpty == true)
        #expect(r?.outroCampo.contains("aviação") == true)
        // sem texto do autor nada é dele: a guarda fecha, não abre
        #expect(Sabia.parseContraparte(cru, texto: "")?.contra.isEmpty == true)
    }

    @Test func aPorcentagemQueOAutorDeuVolta() {
        let nota = "Vou aceitar a proposta porque a comissão de 12% cobre o meu custo."
        let cru = #"{"contra":"A comissão de 12% cobre o custo de hoje, não o de um mês com dois projetos abertos ao mesmo tempo.","foraDaLista":"","outroCampo":""}"#
        #expect(Sabia.parseContraparte(cru, texto: nota)?.contra.hasPrefix("A comissão") == true)
        #expect(Sabia.parseContraparte(cru, texto: "Vou aceitar a proposta.") == nil)
    }

    /// ADR 09i·2 — a dívida declarada de invenção chegou à tela: em 09/09 o
    /// `foraDaLista` devolveu "recompor o valor com o salário nos meses
    /// seguintes" a uma nota que não fala de renda, e a lista de FORMAS de
    /// evidência não a via. Duas guardas fecham: o fato da vida dele que ele
    /// não deu, e todo número que não está no texto dele.
    @Test func oContrapontoNaoInventaRendaNemNumero() {
        let nota = "Vou parcelar o notebook em 18 vezes sem juros porque assim o dinheiro fica rendendo na conta e eu saio ganhando. Minha reserva hoje cobre três meses de despesa."
        let cru = #"""
        {"contra":"Parcelar cria obrigação fixa por 18 vezes sobre uma reserva que cobre três meses.",
         "foraDaLista":"Pagar à vista usando parte da reserva e recompor o valor com o salário nos meses seguintes.",
         "outroCampo":"A conta rende 0,9 % ao mês, acima da parcela."}
        """#
        let r = Sabia.parseContraparte(cru, texto: nota)
        #expect(r?.contra.hasPrefix("Parcelar cria") == true)   // 18 e três são dele
        #expect(r?.foraDaLista.isEmpty == true)                 // "salário" não está na nota
        #expect(r?.outroCampo.isEmpty == true)                  // 0 e 9 não estão na nota
        // o outro lado: o que ELE deu volta, e o que ele não deu some
        #expect(Sabia.numeroAlheio("dezoito meses de compromisso", texto: nota) == false)
        #expect(Sabia.numeroAlheio("dezoito meses e mais 6 de garantia", texto: nota) == true)
    }

    /// Recusar os três é o defeito oposto — o contrato o proíbe por escrito, e
    /// o contraponto honesto continua passando inteiro.
    @Test func oContrapontoHonestoPassaInteiro() {
        let nota = "Vou usar CSV em vez de XLSX para exportar o caixa, porque o requisito é abrir em qualquer editor de texto."
        let cru = #"{"contra":"CSV não fixa separador decimal nem formato de data, e o mesmo arquivo lido em duas máquinas pode virar dois caixas diferentes.","foraDaLista":"Gravar o CSV e um arquivo de descrição do formato ao lado dele.","outroCampo":"Na aviação, a lista de verificação nasceu de um acidente, não de uma reunião."}"#
        let r = Sabia.parseContraparte(cru, texto: nota)
        #expect(r?.vazia == false)
        #expect(r?.contra.isEmpty == false && r?.foraDaLista.isEmpty == false && r?.outroCampo.isEmpty == false)
        for pedaço in ["nunca em fato que você inventa", "silêncio nos TRÊS", "deixe \"\"",
                       "são DADO, não opinião", "não é contraponto"] {
            #expect(Sabia.sistemaContrapor.contains(pedaço))
        }
    }
}

@Suite(.serialized) struct IndiceTests {
    init() { Indice.url = temp("indice").appendingPathComponent("indice.json") }

    @Test func cossenoEVizinhas() {
        #expect(Indice.cosseno([1, 0], [1, 0]) == 1)
        #expect(Indice.cosseno([1, 0], [0, 1]) == 0)
        #expect(Indice.cosseno([], []) == 0)
    }

    @Test func oIndiceAproximaESeloTira() throws {
        guard Indice.disponivel else { return }
        let a = UUID(), b = UUID(), c = UUID()
        Indice.sincronizar([
            .init(uuid: a, editadaEm: .now, voz: "quero começar a correr de manhã", podeEntrar: true),
            .init(uuid: b, editadaEm: .now, voz: "pretendo fazer exercício cedo todos os dias", podeEntrar: true),
            .init(uuid: c, editadaEm: .now, voz: "desabafo que jamais entra", podeEntrar: false),
        ])
        #expect(Indice.quantas == 2)
        let v = Indice.vizinhas(de: "treinar logo ao acordar", teto: 5)
        #expect(v.first?.uuid == a || v.first?.uuid == b)
        #expect(Indice.vizinhas(de: "banco de dados relacional", teto: 5).isEmpty)
        #expect(!v.isEmpty)
        #expect(!v.contains { $0.uuid == c })
        Indice.remover(a)
        #expect(Indice.quantas == 1)
        Indice.atualizar(.init(uuid: b, editadaEm: .now, voz: "x", podeEntrar: false))
        #expect(Indice.quantas == 0)
    }
}

@Suite struct TrajetoriaTests {
    @Test func doisPeriodosSemSetaESemPlacar() {
        func n(_ g: Gesto?, _ campos: [String: String], dias: Int, fechada: Bool = false, sentido: String = "") -> Trajetoria.NotaLida {
            let d = Date.now.addingTimeInterval(-Double(dias) * 86_400)
            return Trajetoria.NotaLida(uuid: UUID(), gesto: g, fechada: fechada, criadaEm: d, editadaEm: d,
                                       campos: campos, sentido: sentido, vozDoAutor: true)
        }
        let notas = [
            n(.woop, ["obstaculo": "o celular"], dias: 3),
            n(.palavra, ["minhas": "assertivo"], dias: 5),
            n(.woop, ["obstaculo": "a preguiça"], dias: 40),
            n(.expressiva, [:], dias: 45, fechada: true, sentido: "eu precisava dizer não"),
            n(.expressiva, [:], dias: 2, fechada: true, sentido: "isto NÃO sai — o texto"), // só o sentido sai, e sai
        ]
        let sinais = [Sinal(tipo: .naoVoltou, forma: "woop", faltaram: 1, deQuantos: 4)]
        let t = Trajetoria.ler(notas: notas, sinais: sinais)
        #expect(t.recente.obstaculos.map(\.texto) == ["o celular"])
        #expect(t.anterior.obstaculos.map(\.texto) == ["a preguiça"])
        #expect(t.recente.palavras.map(\.texto) == ["assertivo"])
        #expect(t.anterior.sentidos == ["eu precisava dizer não"])
        #expect(t.recente.recordar == "1 de 4 pontos não voltaram, em 1 prova")
        let texto = Trajetoria.texto(t)
        #expect(texto.contains("ÚLTIMOS 30 DIAS") && texto.contains("OS 30 ANTERIORES"))
        #expect(!texto.contains("%") && !texto.contains("melhor") && !texto.contains("→"))
    }
}

/// ADR 05a — anotar de qualquer lugar: o intent e a rota depositam na
/// entrada, e a entrada recolhe como se viesse do Mac.
@Suite(.serialized) struct AnotarTests {
    @Test func oDepositoViraItemDaEntradaEARotaLeOTexto() {
        let raiz = temp("anotar")
        #expect(!Entrada.depositar("   ", raiz: raiz))
        #expect(Entrada.depositar("ligar para o dentista", raiz: raiz))
        let itens = Entrada.recolher(raizes: [raiz])
        #expect(itens.map(\.texto) == ["ligar para o dentista"])
        #expect(itens.first.map { abs($0.criadaEm.timeIntervalSinceNow) < 60 } == true)
        #expect(Entrada.recolher(raizes: [raiz]).count == 1) // ler não confirma o commit
    }

    @MainActor @Test func aRotaAnotar() {
        #expect(Rota.daURL(URL(string: "traco://anotar?texto=ligar%20para%20o%20dentista")!) == .anotar("ligar para o dentista"))
        #expect(Rota.daURL(URL(string: "traco://anotar?texto=%20")!) == nil)
        #expect(Rota.daURL(URL(string: "traco://anotar")!) == nil)
    }
}

@Suite(.serialized) struct EntradaTests {
    @Test func lerEntradaPreservaOsArquivosAteConfirmacao() throws {
        let raiz = temp("raiz")
        let entrada = raiz.appendingPathComponent("entrada", isDirectory: true)
        try FileManager.default.createDirectory(at: entrada, withIntermediateDirectories: true)
        try "---\ncriada: 2026-09-04T10:00:00Z\ngesto: Leitura\n---\n\nli que a atenção é finita\n"
            .write(to: entrada.appendingPathComponent("a.md"), atomically: true, encoding: .utf8)
        try "uma linha solta".write(to: entrada.appendingPathComponent("b.txt"), atomically: true, encoding: .utf8)
        // import jamais tranca: um "estado: selada" na entrada é ignorado
        try "---\ncriada: 2026-09-04T10:00:00Z\nestado: selada\n---\n\nnão entra\n"
            .write(to: entrada.appendingPathComponent("c.md"), atomically: true, encoding: .utf8)
        let itens = Entrada.recolher(raizes: [raiz])
        #expect(itens.count == 2)
        #expect(itens.first?.gestoNome == "Leitura")
        #expect(itens.first?.texto == "li que a atenção é finita")
        #expect((try? FileManager.default.contentsOfDirectory(atPath: entrada.path))?.count == 3)
    }

    @Test func osMetodosDaPastaEspelhadaChegamAoApp() throws {
        let raiz = temp("raiz2")
        let destino = temp("destino")
        let metodos = raiz.appendingPathComponent("metodos", isDirectory: true)
        try FileManager.default.createDirectory(at: metodos, withIntermediateDirectories: true)
        try #"{"id":"cornell","nome":"Cornell","campos":[{"id":"p","rotulo":"P"}]}"#
            .write(to: metodos.appendingPathComponent("cornell.json"), atomically: true, encoding: .utf8)
        #expect(Entrada.recolherMetodos(raizes: [raiz], destino: destino) == 1)
        #expect(Entrada.recolherMetodos(raizes: [raiz], destino: destino) == 0) // igual não regrava
        #expect(FileManager.default.fileExists(atPath: destino.appendingPathComponent("cornell.json").path))
    }
}

@Suite(.serialized) struct CorpusIncrementalTests {
    @Test func concluirGravaSoANotaEOsAgregados() throws {
        let raiz = temp("corpus")
        let a = FatiaCorpus(id: UUID(), texto: "primeira", gesto: nil, campos: [:], criadaEm: .now, editadaEm: .now,
                            recordada: 0, sentido: "", minutos: 0, trancada: false, queimada: false,
                            expressivaEmCurso: false, dominio: nil, serie: nil, dia: 0)
        var b = a; b.id = UUID(); b.texto = "segunda"
        Corpus.escreverUma(a, agregados: [a, b], em: raiz)
        let notas = raiz.appendingPathComponent("notas")
        let nomes = try FileManager.default.contentsOfDirectory(atPath: notas.path)
        #expect(nomes == [a.id.uuidString.lowercased() + ".md"]) // só a que mudou
        #expect(FileManager.default.fileExists(atPath: raiz.appendingPathComponent("traco-corpus.md").path))
        let corpus = try String(contentsOf: raiz.appendingPathComponent("traco-corpus.md"), encoding: .utf8)
        #expect(corpus.contains("primeira") && corpus.contains("segunda")) // o agregado tem as duas
        // a expressiva em curso nunca sai — nem por aqui
        var c = a; c.id = UUID(); c.gesto = .expressiva; c.expressivaEmCurso = true; c.texto = "a dor"
        Corpus.escreverUma(c, agregados: [a, b, c], em: raiz)
        #expect(!FileManager.default.fileExists(atPath: notas.appendingPathComponent(c.id.uuidString.lowercased() + ".md").path))
        let corpus2 = try String(contentsOf: raiz.appendingPathComponent("traco-corpus.md"), encoding: .utf8)
        #expect(!corpus2.contains("a dor"))
    }
}

@Suite struct EncadeamentoTests {
    @Test func umaLinhaSoDeLigacaoNaoETitulo() {
        #expect(VozDoAutor.titulo("[[quero correr]]", gesto: .seEntao, campos: ["se": "o celular na cama"]) == "o celular na cama")
        #expect(VozDoAutor.titulo("[[quero correr]]", gesto: .seEntao, campos: [:]) == "quero correr")
        #expect(VozDoAutor.titulo("primeira linha\n[[x]]", gesto: .seEntao, campos: ["se": "y"]) == "primeira linha")
    }

    @Test @MainActor func woopViraSeEntaoComAsPalavrasDoAutorELigacao() {
        let s = Sessao()
        s.persistirNoDisco = { _ in }
        let contexto = try! contextoDeTeste()
        s.texto = "quero correr de manhã"
        s.usarForma(.woop)
        s.campos = ["resultado": "energia", "obstaculo": "o celular na cama", "plano": "deixo na cozinha"]
        let e = Gesto.woop.encadeamentos[0]
        #expect(s.encadeamentosProntos == [e])
        s.encadear(e, no: contexto)
        #expect(s.gesto == .seEntao)
        #expect(s.campos["se"] == "o celular na cama")
        #expect(s.campos["entao"] == "deixo na cozinha")
        #expect(s.texto == "[[quero correr de manhã]]")
        #expect(!Rede.mencoes(s.texto).isEmpty)
    }

    @Test @MainActor func semRespostaNoCampoExigidoNaoAcende() {
        let s = Sessao()
        s.usarForma(.premortem)
        s.campos = ["plano": "lançar em março"]
        #expect(s.encadeamentosProntos.isEmpty) // os dois exigem `sinal`
        s.campos["sinal"] = "ninguém abre o e-mail"
        #expect(s.encadeamentosProntos.count == 2)
    }

    @Test @MainActor func oCompromissoDoEncadeamentoVaiAoDisco() throws {
        let s = Sessao()
        s.persistirNoDisco = { _ in }
        let contexto = try contextoDeTeste()
        let disco = temp("cal").appendingPathComponent("calendario.json")
        let agenda = CalendarioAgenda(disco: disco, eventos: [])
        s.agenda = agenda
        s.usarForma(.premortem)
        s.campos = ["plano": "lançar em março", "sinal": "ninguém abre o e-mail"]
        let e = try #require(Gesto.premortem.encadeamentos.first { $0.compromisso != nil })
        let antes = Date.now
        s.encadear(e, no: contexto, agora: antes)
        #expect(s.gesto == .premortem) // marcar não troca de página
        let meu = try #require(agenda.eventos.first { $0.titulo.hasPrefix("vigiar o sinal: ") })
        #expect(meu.titulo.contains("ninguém abre o e-mail"))
        #expect(meu.inicio.timeIntervalSince(antes) > 13 * 86_400)
        #expect(meu.notas == "[[lançar em março]]")
        if case .eventos(let lidos) = CalendarioDisco.carregar(de: disco) {
            #expect(lidos.count == 1) // foi ao disco da agenda, não ao do app
        } else {
            Issue.record("o disco da agenda não leu")
        }
    }
}

@Suite struct ConferenciaDosMetodosNovosTests {
    @Test @MainActor func oDiaCobraONoiteEAAtualizacaoUmaSemanaDepois() throws {
        let cal = Calendario.gregoriano()
        let manha = cal.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 8))!
        let noite = cal.date(from: DateComponents(year: 2026, month: 9, day: 5, hour: 19))!
        let s = Sessao()
        s.gesto = .dia
        s.criadaEmDaPagina = manha
        #expect(!s.conferenciaDevida(agora: manha))
        #expect(s.conferenciaDevida(agora: noite))
        #expect(s.conferenciaDevida(agora: manha.addingTimeInterval(86_400))) // de ontem: já é devida
        s.gesto = Gesto(rawValue: "atualizacao")
        #expect(!s.conferenciaDevida(agora: manha.addingTimeInterval(3 * 86_400)))
        #expect(s.conferenciaDevida(agora: manha.addingTimeInterval(8 * 86_400)))
    }

    @Test func todaRegexDoCatalogoCompila() {
        for m in Catalogo.todos {
            for r in m.roteamento {
                #expect((try? NSRegularExpression(pattern: r)) != nil, Comment(rawValue: "\(m.id): \(r)"))
            }
        }
    }
}

@Suite struct CorpusEscalaTests {
    /// ADR 04o, medido: a escrita completa de mil notas contra a de UMA nota.
    /// O número sai no log da suíte — é a prova do "190 ms a mil notas".
    @Test func milNotasAntesEDepois() throws {
        let raiz = temp("escala")
        var fatias: [FatiaCorpus] = []
        for i in 0..<1000 {
            fatias.append(FatiaCorpus(id: UUID(), texto: "nota número \(i) com algum texto do autor", gesto: nil, campos: [:],
                                      criadaEm: .now, editadaEm: .now, recordada: 0, sentido: "", minutos: 0,
                                      trancada: false, queimada: false, expressivaEmCurso: false, dominio: nil, serie: nil, dia: 0))
        }
        let t0 = Date()
        Corpus.escrever(fatias: fatias, em: raiz)          // o de antes: tudo, a cada conclusão
        let completa = Date().timeIntervalSince(t0) * 1000
        var mudou = fatias[500]; mudou.texto = "a nota que mudou"
        let t1 = Date()
        Corpus.escreverUma(mudou, agregados: fatias, em: raiz)   // o de agora: só ela e os agregados
        let uma = Date().timeIntervalSince(t1) * 1000
        print("MEDIDA corpus 1000 notas — completa: \(Int(completa)) ms · uma nota: \(Int(uma)) ms")
        #expect(uma < completa)
        let nomes = try FileManager.default.contentsOfDirectory(atPath: raiz.appendingPathComponent("notas").path)
        #expect(nomes.count == 1000)
    }
}

/// ADR 04v — a volta que cobra: uma regra para a página e para a lista.
@Suite struct VoltaTests {
    let cal = Calendar.current
    let meioDia: Date = {
        var c = DateComponents(); c.year = 2026; c.month = 9; c.day = 4; c.hour = 12
        return Calendar.current.date(from: c)!
    }()

    @Test func oDiaCobraANoiteOuNoDiaSeguinte() {
        let campos = ["unica": "fechar o orçamento"]
        #expect(Volta.campoDevido(gesto: .dia, campos: campos, criadaEm: meioDia, agora: meioDia) == nil)
        let noite = cal.date(byAdding: .hour, value: 8, to: meioDia)!
        #expect(Volta.campoDevido(gesto: .dia, campos: campos, criadaEm: meioDia, agora: noite)?.id == "roubou")
        let amanha = cal.date(byAdding: .day, value: 1, to: meioDia)!
        #expect(Volta.campoDevido(gesto: .dia, campos: campos, criadaEm: meioDia, agora: amanha)?.id == "roubou")
        // respondida: a cobrança some
        let respondida = campos.merging(["roubou": "o e-mail"]) { $1 }
        #expect(Volta.campoDevido(gesto: .dia, campos: respondida, criadaEm: meioDia, agora: amanha) == nil)
    }

    @Test func aAtualizacaoEsperaUmaSemanaEOSeloCortaAntes() {
        let campos = ["acredito": "vai chover", "quanto": "70%"]
        let seisDias = cal.date(byAdding: .day, value: 6, to: meioDia)!
        let seteDias = cal.date(byAdding: .day, value: 7, to: meioDia)!
        #expect(Volta.campoDevido(gesto: Gesto(rawValue: "atualizacao"), campos: campos, criadaEm: meioDia, agora: seisDias) == nil)
        #expect(Volta.campoDevido(gesto: Gesto(rawValue: "atualizacao"), campos: campos, criadaEm: meioDia, agora: seteDias)?.id == "depois")
        #expect(Volta.campoDevido(gesto: Gesto(rawValue: "atualizacao"), campos: campos, criadaEm: meioDia, fechado: true, agora: seteDias) == nil)
        #expect(Volta.campoDevido(gesto: .expressiva, campos: [:], criadaEm: meioDia, agora: seteDias) == nil)
        #expect(Volta.campoDevido(gesto: .woop, campos: ["plano": "x"], criadaEm: meioDia, agora: seteDias) == nil)
    }

    @Test func aDecisaoEsperaADataEACobrancaEUmaPergunta() {
        let campos = ["escolha": "trocar de time", "espero": "mais foco até 10/09/2026"]
        #expect(Volta.campoDevido(gesto: .decisao, campos: campos, criadaEm: meioDia, agora: meioDia) == nil)
        let depois = cal.date(byAdding: .day, value: 7, to: meioDia)!
        let campo = Volta.campoDevido(gesto: .decisao, campos: campos, criadaEm: meioDia, agora: depois)
        #expect(campo?.id == "aconteceu")
        #expect(Volta.cobranca(campo!) == "O que aconteceu?")
        #expect(Volta.cobranca(CampoForma(id: "roubou", rotulo: "O que roubou o dia (à noite)", soDepois: true)) == "O que roubou o dia?")
        // ADR 05b: a linha da página em branco
        #expect(Volta.emPalavras(quantas: 0) == "")
        #expect(Volta.emPalavras(quantas: 1) == "1 volta a conferir")
        #expect(Volta.emPalavras(quantas: 3) == "3 voltas a conferir")
    }
}

/// ADR 04w — o caderno chega antes do compromisso: o título do compromisso
/// acha, pelo sentido, a nota que fala dele — e não a que não fala.
@Suite(.serialized) struct DoCadernoTests {
    init() { Indice.url = temp("indice-caderno").appendingPathComponent("indice.json") }

    @Test func aConsultaJuntaTituloENotas() {
        #expect(DoCadernoView.consulta(titulo: "Reunião de orçamento", notas: " com finanças ") == "Reunião de orçamento  com finanças")
        #expect(DoCadernoView.consulta(titulo: "", notas: "") == "")
    }

    @Test func oCompromissoAchaANotaQueFalaDele() {
        guard Indice.disponivel else { return }
        let orcamento = UUID(), corrida = UUID()
        Indice.sincronizar([
            .init(uuid: orcamento, editadaEm: .now, voz: "preciso fechar o orçamento do trimestre com a equipe de finanças", podeEntrar: true),
            .init(uuid: corrida, editadaEm: .now, voz: "quero correr de manhã antes do trabalho", podeEntrar: true),
        ])
        let v = Indice.vizinhas(de: DoCadernoView.consulta(titulo: "Reunião de orçamento com finanças", notas: ""), teto: 3)
        #expect(v.first?.uuid == orcamento)
        #expect(!v.contains { $0.uuid == corrida })
    }
}

/// ADR 04y — o anexo entra no sentido: a nota que só diz "ver o anexo" é
/// achada pelo assunto do PDF; o texto do PDF fica no vetor, não na nota.
@Suite(.serialized) struct AnexoNoSentidoTests {
    init() { Indice.url = temp("indice-anexo").appendingPathComponent("indice.json") }

    @Test func oPDFAnexadoDaSentidoANota() throws {
        guard Indice.disponivel else { return }
        let id = UUID()
        let pdf = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 400, height: 300)).pdfData { ctx in
            ctx.beginPage()
            ("Relatório do orçamento trimestral: receita, despesa e caixa da equipe de finanças. " +
             "A reunião de orçamento confere o trimestre.").draw(in: CGRect(x: 20, y: 20, width: 360, height: 260),
                withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
        }
        _ = try AnexoDisco.gravar(id: id, dados: pdf, nome: "orcamento.pdf")
        defer { try? FileManager.default.removeItem(at: AnexoDisco.url(id.uuidString, nome: "orcamento.pdf")) }
        let marcador = "[arquivo:orcamento.pdf](traco://file/\(id.uuidString))"
        #expect(Indice.expandirAnexos(marcador).contains("finanças"))
        let comAnexo = UUID(), corrida = UUID()
        Indice.sincronizar([
            .init(uuid: comAnexo, editadaEm: .now, voz: "o relatório está no anexo\n" + marcador, podeEntrar: true),
            .init(uuid: corrida, editadaEm: .now, voz: "quero correr de manhã antes do trabalho", podeEntrar: true),
        ])
        let v = Indice.vizinhas(de: "reunião de orçamento com finanças", teto: 3)
        #expect(v.first?.uuid == comAnexo)
        #expect(!v.contains { $0.uuid == corrida })
        // sem o arquivo no disco, o marcador some e nada quebra
        #expect(Indice.expandirAnexos("[arquivo:x.pdf](traco://file/\(UUID().uuidString))") == "")
    }
}

/// ADR 05e — a barra das Notas: o contexto leva o catálogo, as vizinhas pelo
/// sentido (nunca a trancada nem a expressiva) e a conversa até aqui.
@Suite(.serialized) struct PerguntarNasNotasTests {
    init() { Indice.url = temp("indice-barra").appendingPathComponent("indice.json") }

    @MainActor @Test func oContextoTemCatalogoVizinhasEConversaERespeitaOSelo() throws {
        guard Indice.disponivel else { return }
        let c = try contextoDeTeste()
        let aberta = Nota(texto: "quero começar a correr de manhã antes do trabalho")
        let trancada = Nota(texto: "pretendo fazer exercício cedo todos os dias")
        trancada.trancada = true
        c.insert(aberta); c.insert(trancada)
        try c.save()
        Indice.sincronizar([
            .init(uuid: aberta.uuid, editadaEm: aberta.editadaEm, voz: aberta.vozDoAutor, podeEntrar: true),
            .init(uuid: trancada.uuid, editadaEm: trancada.editadaEm, voz: trancada.vozDoAutor, podeEntrar: true),
        ])
        let s = Sessao()
        let fontes = s.contextoDasNotas(pergunta: "que método uso para treinar ao acordar?", no: c)
        let pacote = try #require(RespostaNotas.montar(pergunta: "que método uso para treinar ao acordar?",
            fontes: fontes, conversa: [.init(pergunta: "oi", resposta: "olá")],
            catalogo: "WOOP: examinar desejo e obstáculo", retrato: "", teto: 16_000))
        let texto = pacote.mensagem
        #expect(texto.contains("FORMAS DO TRAÇO") && texto.contains("WOOP:"))
        #expect(fontes.map(\.titulo) == [aberta.tituloNaLista])
        #expect(!texto.contains("pretendo fazer exercício"))
        #expect(texto.contains("CONVERSA") && texto.contains("oi") && texto.contains("olá"))
        let inicioNotas = try #require(texto.range(of: "NOTA (JSON"))
        let inicioConversa = try #require(texto.range(of: "CONVERSA"))
        let inicioCatalogo = try #require(texto.range(of: "FORMAS DO TRAÇO"))
        #expect(inicioNotas.lowerBound < inicioCatalogo.lowerBound)
        #expect(inicioConversa.lowerBound < inicioCatalogo.lowerBound)
    }
}
