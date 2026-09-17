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
        #expect(Sinais.emPalavras().hasPrefix("2 registros"))
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
        #expect(Degraus.emPalavras(sinais: naoServiu) == "WOOP: pergunta como as ideias se ligam (desceu: duas perguntas não serviram).")
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
            nota(.woop, ["obstaculo": "o celular na cama", "plano": "se eu pegar o celular, então deixo ele na sala"]),
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
        #expect(r.contains("se eu pegar o celular, então deixo ele na sala"))
        #expect(r.contains("Próximas que já escreveu"))
        #expect(r.contains("sofrer por antecipação"))
        #expect(!r.contains("Juízos que já cortou"))
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

    /// Fase 2: colheita de juízo — Destilar e ResultadoObservado, sem enum novo.
    @Test func oRetratoColheOJuizoDestiladoEOresultadoInformado() {
        let destilada = nota(.destilar, ["frase": "o plano cabe nesta semana"])
        let pesquisa = Retrato.NotaLida(gesto: .destilar, fechada: false, expressiva: false,
                                        criadaEm: .now, campos: ["frase": "tese inventada do bot"],
                                        vozDoAutor: false)
        let r = Retrato.ler(notas: [destilada, pesquisa], sinais: [],
                            observados: [.init(rotulo: DocumentoTrabalho.ResultadoObservado.parcial.rotulo,
                                               relato: "a conversa com a Ana adiou")])
        #expect(r.contains("o plano cabe nesta semana"))
        #expect(r.contains("Juízos que já cortou numa frase"))
        #expect(r.contains("a conversa com a Ana adiou"))
        #expect(r.contains("Funcionou em parte"))
        #expect(!r.contains("tese inventada do bot"))
        #expect(Set(DocumentoTrabalho.ResultadoObservado.allCases.map(\.rawValue))
            == Set(["funcionou", "parcial", "naoFuncionou"]))
    }
}

@Suite struct ContraparteTests {
    @Test func tresChavesInformacaoNuncaInstrucao() {
        let ok = Sabia.parseContraparte(#"{"contra":"A tese oposta sustenta que o custo de trocar supera o ganho de velocidade.","foraDaLista":"Adiar a escolha um mês e medir o uso real.","outroCampo":"Na aviação, a lista de verificação nasceu de um acidente, não de uma reunião."}"#)
        #expect(ok?.contra.hasPrefix("A tese oposta") == true)
        #expect(ok?.outroCampo.contains("aviação") == true)
        // instrução é descartada; chave extra e não-JSON derrubam tudo.
        // ADR 09s: esvaziada pela guarda é VAZIA, não `nil` — `nil` ficou só
        // para o que não deu para ler.
        let instrucao = Sabia.parseContraparte(#"{"contra":"Você deve reconsiderar a opção A com calma.","foraDaLista":"","outroCampo":""}"#)
        #expect(instrucao?.vazia == true)
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
        #expect(Sabia.parsePerguntas(sóAndaime, texto: rascunho) == [])  // ADR 09s: leu e não sobrou nada
    }

    /// O par que muda só a EVIDÊNCIA: a mesma palavra, escrita pelo AUTOR.
    /// A guarda sabe de onde a palavra veio, não se ela é feia.
    @Test func aPalavraQueOAutorEscreveuPodeVoltar() {
        let dele = "Sigo um método de estudo em degraus e travei no segundo degrau."
        let json = #"{"perguntas":["O que define a passagem de um degrau para o próximo no seu método?"]}"#
        #expect(Sabia.parsePerguntas(json, texto: dele)?.count == 1)
        #expect(Sabia.parsePerguntas(json, texto: rascunho) == [])
    }

    /// O defeito OPOSTO reprova igual: perguntas boas passam inteiras.
    @Test func aPerguntaBoaPassaInteira() {
        let json = #"{"perguntas":["Qual é o critério objetivo que vai decidir entre alugar ou atender em casa?","Que evidência faria você mudar de ideia depois de escolher?","Quanto custa errar para cada opção em reais e em tempo?"]}"#
        #expect(Sabia.parsePerguntas(json, texto: "Preciso decidir entre alugar uma sala por R$ 900 ou atender de casa.")?.count == 3)
    }

    @Test func oContratoDeInstigarDizDeQuemEOAssunto() {
        // ADR 10c·2: dobrar a quebra de linha antes de comparar. O literal
        // quebra onde a coluna acaba, e a frase que o MODELO lê é a mesma —
        // acoplar a asserção ao ponto de quebra faz o teste ficar vermelho por
        // reformatação, que é ruído, e é o que aconteceu na 2ª redação.
        let pedido = Sabia.sistemaInstigar.replacingOccurrences(of: "\n", with: " ")
        for pedaço in ["nunca as cite", "é DELA, seja qual for", "Não suponha nenhum fato",
                       "MANDA nas perguntas", "Não devolva vazio",
                       // ADR 10c: as DUAS pernas da condição. Uma sozinha é o
                       // defeito que a outra comprou — a nota magra sem o
                       // quando, ou a nota farta somando o gabarito.
                       "se ela quase não dá", "se ela dá matéria",
                       "só entra a que a nota deixou sem resposta"] {
            #expect(pedido.contains(pedaço))
        }
        // ADR 09i·2: proibir por NOME comprou mudez sobre a palavra do autor.
        // O contrato não lista mais palavra proibida — ele diz de onde ela vem.
        // ADR 10c: e "Aí MANDA o vazio" é a cláusula INCONDICIONAL do LOTE-5,
        // que o G3 mediu a diluir a nota farta. Quem a trouxer de volta fica
        // vermelho aqui antes de gastar uma janela do aparelho da conta.
        for nome in ["sobre o degrau", "sobre o método", "sobre a forma da nota",
                     "Aí MANDA o vazio"] {
            #expect(!pedido.contains(nome))
        }
    }

    /// ADR 10c — a duplicação do pedido base é segura porque isto a vigia. Os
    /// dois braços rodam no MESMO binário e a ÚNICA diferença permitida é o
    /// DESFECHO: um espaço a mais no meio faria a corrida medir duas coisas e
    /// chamar de uma alavanca só.
    @Test func aBaseEOCandidatoDiferemSoNoDesfecho() {
        let comum = "ela nomeie — pergunta que já traz o fato suposto não é pergunta, é palpite.\n"
        func ate(_ s: String) -> String {
            guard let f = s.range(of: comum)?.upperBound else { return "" }
            return String(s[..<f])
        }
        #expect(!ate(Sabia.sistemaInstigar).isEmpty)
        #expect(ate(Sabia.sistemaInstigarBase) == ate(Sabia.sistemaInstigar))
        // e o desfecho MUDA, senão não há alavanca nenhuma para medir
        #expect(Sabia.sistemaInstigarBase != Sabia.sistemaInstigar)
        #expect(Sabia.sistemaInstigarBase.hasSuffix("mesmo uma linha só dá o que perguntar — o quê, quando, o que era."))
        #expect(!Sabia.sistemaInstigarBase.contains("depende da MATÉRIA"))
        // em Release o braço da base não existe; em DEBUG, sem a variável, o
        // pedido vigente é o candidato — a sonda é que troca, nunca a produção.
        #expect(Sabia.pedidoDeInstigar == Sabia.sistemaInstigar)
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
        #expect(Sabia.parsePerguntas(#"{"perguntas":["\#(sobreOMetodoDele)"]}"#, texto: rascunho) == [])
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
        #expect(Sabia.parseContraparte(cru, texto: "Vou aceitar a proposta.")?.vazia == true)
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
        // ADR 09s: "renda" entrou na lista. O LOTE-3 pegou o grok-4.5 escrevendo
        // renda nas TRÊS repetições desta mesma nota, que não declara nenhuma.
        #expect(Sabia.parseContraparte(#"{"contra":"Parcelar em 18 vezes compromete renda futura que hoje você não tem garantida.","foraDaLista":"","outroCampo":""}"#, texto: nota)?.contra.isEmpty == true)
        // e a procedência continua mandando: quem escreveu "renda" ouve de volta
        let declarou = nota + " Minha renda é fixa e entra todo dia 5."
        #expect(Sabia.parseContraparte(#"{"contra":"A parcela fixa por 18 meses aposta que a renda de hoje continua igual.","foraDaLista":"","outroCampo":""}"#, texto: declarou)?.contra.isEmpty == false)
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
        #expect(Volta.emPalavras(quantas: 1) == "1 para conferir")
        #expect(Volta.emPalavras(quantas: 3) == "3 para conferir")
        // Padrões conta a forma como se lê (auditoria 16/09 noite: "4 decisão")
        #expect(Trajetoria.contagem(4, "Decisão") == "4 decisões")
        #expect(Trajetoria.contagem(1, "Decisão") == "1 decisão")
        #expect(Trajetoria.contagem(2, "Leitura") == "2 leituras")
        #expect(Trajetoria.contagem(2, "WOOP") == "2 WOOP")
        #expect(Trajetoria.contagem(1, nil) == "1 solta")
        #expect(Trajetoria.contagem(5, nil) == "5 soltas")
        // o Retrato no Perfil, em língua de gente (auditoria 17/09)
        #expect(PerfilView.retratoParaTela("Formas nos últimos 30 dias (contagem): 12 sem forma · 5 Decisão.")
                == "Nos últimos 30 dias: 12 soltas · 5 decisões.")
        #expect(PerfilView.retratoParaTela("Próximas que já escreveu (citações): “ligar” (02/09).")
                == "Próximos passos que você escreveu: “ligar” (02/09).")
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

/// A GUARDA QUE APAGA NÃO PODE VIRAR SILÊNCIO — ADR 2026-09-09s.
///
/// O LOTE-3 devolveu `Falha.semRetorno` com HTTP 200 e "conteúdo completo" em
/// `grok-4.5` rep. 2 do CSV e em `grok-4.3` rep. 1 do tudo-ou-nada
/// (`prova/lote09c-q4-grok-4.5.jsonl`, `prova/lote09c-q4-grok-4.3.jsonl`). A
/// resposta chegava inteira; as três chaves caíam nas guardas; `Contraparte`
/// ficava vazia; o parser devolvia `nil`; a Lente escrevia "a sábia não
/// respondeu." sobre uma resposta que existiu.
///
/// A prova é a distinção, não o texto: `nil` é NÃO LI, vazio é LI E NÃO SOBROU.
/// Os dois irmãos — `parseContraparte` e `parsePerguntas` — passam pela mesma
/// régua, porque o defeito era da FORMA, não de uma rota.
@Suite struct GuardaQueApagaNaoEhSilencioTests {

    /// O caso `q4-contrapor-tudo-ou-nada`, com a nota palavra por palavra. Ela
    /// escreve "cinco quilômetros" por extenso, então TODO algarismo da
    /// resposta é alheio: as três chaves caem, e é este o desfecho medido.
    @Test func respostaInteiraEsvaziadaNaoEhSemRetorno() {
        let nota = "Não adianta eu correr se não for pelo menos cinco quilômetros; menos que isso não conta."
        let cru = #"""
        {"contra":"Sessões de 20 minutos já elevam a capacidade aeróbica, segundo estudos de treinamento intervalado.",
         "foraDaLista":"Correr 2 km três vezes por semana em vez de 5 km uma vez.",
         "outroCampo":"Na natação, 30 % do ganho vem de séries curtas."}
        """#
        let r = Sabia.parseContraparte(cru, texto: nota)
        // ANTES: nil — e a tela dizia "a sábia não respondeu."
        #expect(r != nil)
        #expect(r?.vazia == true)
        // o mesmo cru sem JSON legível continua sendo ausência de resposta
        #expect(Sabia.parseContraparte("desculpe, não posso ajudar com isso", texto: nota) == nil)
    }

    /// O irmão: `parsePerguntas` tinha a mesma forma e o mesmo desfecho.
    @Test func oIrmaoDoInstigarDistingueOsMesmosDoisDesfechos() {
        let magro = "Não deu certo de novo."
        let sóAndaime = #"{"perguntas":["Qual é o movimento básico que se pula?","Em que degrau você está?"]}"#
        #expect(Sabia.parsePerguntas(sóAndaime, texto: magro) == [])
        #expect(Sabia.parsePerguntas("claro! seguem as perguntas", texto: magro) == nil)
    }

    /// O MESMO defeito uma função adiante, e desta vez numa rota VIVA:
    /// `vestir` é `.grokDepoisBordo` na tabela `Politica`, ao contrário de
    /// `instigar` e `contrapor`. `Sabia.vestir` devolvia `nil` tanto para o
    /// provedor mudo quanto para o 200 que o NOSSO contrato recusou, e
    /// `Sessao.vestirTudo` escrevia "a sábia não respondeu. o texto ficou como
    /// estava." sobre uma resposta que existiu.
    ///
    /// Os três `cru` são JSON legível, lido até o fim, na forma exata do mapa
    /// que a sonda gravou em `prova/q-qualidade-avaliacoes.jsonl`
    /// (`qn-vestir-tabela-e-lista`): a lista VAZIA — o modelo dizendo
    /// honestamente que não há o que vestir —, a lista mais CURTA que os
    /// blocos pendentes, e a lista com DOIS títulos. Nenhum deles é "não deu
    /// para ler", e os três caíam na mesma frase do provedor mudo.
    @MainActor @Test func vestirComRespostaInteiraNaoEhSemRetorno() async throws {
        let dois = "Esta explicação contém uma frase completa que o modelo ainda pode organizar."
            + "\n\nEsta segunda explicação também é uma frase completa e segue em prosa corrida."
        // sem melhoria local o desfecho é inteiramente da sábia: é o caso do defeito
        try #require(Caderno.estruturar(dois) == dois)
        let blocos = Sabia.blocos(dois)
        try #require(blocos.count == 2)
        for cru in ["[]",
                    #"[{"i":0,"forma":"titulo"}]"#,
                    #"[{"i":0,"forma":"titulo"},{"i":1,"forma":"titulo"}]"#] {
            // ANTES: nil — e o toast dizia "a sábia não respondeu."
            #expect(await Sabia.vestir(blocos: blocos, gesto: nil, gerar: { _ in cru }) == [])
        }
        // o provedor mudo continua sendo ausência de resposta
        #expect(await Sabia.vestir(blocos: blocos, gesto: nil, gerar: { _ in nil }) == nil)
    }

    /// A tela do `vestir` tem a frase do terceiro desfecho, e ela não convida a
    /// repetir: `vestir` MEMOIZA (`memoPor: "vestir…"`), então "peça de novo"
    /// seria falso ali — pedir de novo devolve o mesmo cru, do memo.
    @Test func aTelaDoVestirDizQueHouveRespostaSemMandarPedirDeNovo() {
        #expect(Sabia.nadaVestiu != "a sábia não respondeu. o texto ficou como estava.")
        #expect(Sabia.nadaVestiu.contains("respondeu"))
        #expect(!Sabia.nadaVestiu.contains("não respondeu"))
        #expect(!Sabia.nadaVestiu.lowercased().contains("de novo"))
    }

    /// A sonda distingue as duas quedas do `vestir`. Sem isto o LOTE seguinte
    /// lê `Falha.semRetorno` e não sabe dizer se o provedor calou ou se fomos
    /// nós — que é exatamente o que a corrida de 07/09 deixou sem resposta
    /// (6 `semRetorno` em `prova/qualidade-ia-contexto-vestir-20260907.jsonl`).
    @MainActor @Test func aSondaSabeQuandoFoiOVestirQueApagou() async throws {
        let dois = "Esta explicação contém uma frase completa que o modelo ainda pode organizar."
            + "\n\nEsta segunda explicação também é uma frase completa e segue em prosa corrida."
        let blocos = Sabia.blocos(dois)
        _ = Sabia.retirarGuardasQueApagaram()
        _ = await Sabia.vestir(blocos: blocos, gesto: nil, gerar: { _ in "claro! aqui vai" })
        #expect(Sabia.retirarGuardasQueApagaram() == ["vestir · mapa fora do contrato"])
        _ = await Sabia.vestir(blocos: blocos, gesto: nil, gerar: { _ in #"[{"i":0,"forma":"titulo"}]"# })
        #expect(Sabia.retirarGuardasQueApagaram() == ["vestir · mapa menor que os blocos pendentes"])
    }

    /// A convenção da casa, congelada: `parseCalibragem`, `parseEcos` e
    /// `PadroesRemoto.parsePerguntas` já separavam os dois desfechos, e é por
    /// isso que o conserto da Lente foi nos parsers e não em cada chamador.
    ///
    /// Emenda (Q4-D): os dois da Lente NÃO eram os únicos fora do passo — a
    /// frase original da ADR 09s dizia isso e o código a contradizia. `vestir`
    /// tinha a mesma queda em rota viva, e está aqui em cima. Os que sobram
    /// (`parsePerguntaDeRecordar`, `parseVoltaram`, `RespostaNotas.interpretar`)
    /// estão na tabela da emenda, com dono para o único que mentiria numa tela.
    @Test func todosOsParsersDeListaSeguemAMesmaRegra() {
        let ilegivel = "claro! aqui vai"
        #expect(Sabia.parseCalibragem(ilegivel, pares: ["escolha: x"]) == nil)
        #expect(Sabia.parseCalibragem(#"{"perguntas":["Inventada sem citação?"]}"#, pares: ["escolha: x"]) == [])
        #expect(Sabia.parseEcos(ilegivel, candidatas: ["uma nota"]) == nil)
        #expect(Sabia.parseEcos(#"{"ecos":[{"i":9,"trecho":"não existe"}]}"#, candidatas: ["uma nota"]) == [])
        #expect(PadroesRemoto.parsePerguntas(ilegivel) == nil)
        #expect(PadroesRemoto.parsePerguntas(#"{"perguntas":[]}"#) == [])
    }

    /// A tela só tem a frase certa se ela existir. Três desfechos, três frases
    /// distintas — e nenhuma delas manda conectar conta que já está ligada.
    @Test func aTelaTemUmaFraseParaCadaUmDosTresDesfechos() {
        let naoRespondeu = "a sábia não respondeu."
        #expect(Sabia.nadaPassouNaGuarda != naoRespondeu)
        #expect(Sabia.nadaPassouNaGuarda != Politica.semProvedor(.contrapor))
        #expect(Sabia.nadaPassouNaGuarda != Politica.semProvedor(.instigar))
        // ela DIZ que houve resposta — é a única informação nova que o autor tem
        #expect(Sabia.nadaPassouNaGuarda.contains("respondeu"))
        #expect(!Sabia.nadaPassouNaGuarda.contains("não respondeu"))
    }

    /// A sonda passa a nomear a guarda. Sem isto o LOTE-3 seguinte só saberia
    /// dizer "vazio" de novo, e a volta depois dele recomeçaria cega.
    @Test func aSondaSabeQualGuardaApagou() {
        _ = Sabia.retirarGuardasQueApagaram()
        let nota = "Vou parcelar o notebook em 18 vezes sem juros. Minha reserva cobre três meses."
        _ = Sabia.parseContraparte(#"{"contra":"Parcelar em 18 vezes compromete a renda dos meses seguintes.","foraDaLista":"","outroCampo":""}"#, texto: nota)
        let guardas = Sabia.retirarGuardasQueApagaram()
        #expect(guardas == ["contra · fato que ele não deu"])
        #expect(Sabia.retirarGuardasQueApagaram().isEmpty)  // retirar esvazia
    }

    /// O contrato do `contrapor` promoveu a proibição por procedência para o
    /// alto, ao lado da que já matou a evidência fabricada (Q4-B, 3/3).
    @Test func oContratoDeContraporProibeORecursoQueElaNaoEscreveu() {
        for pedaço in ["Proibido também o que é DELA e ela não", "renda, salário, dívida",
                       "apagada inteira"] {
            #expect(Sabia.sistemaContrapor.contains(pedaço))
        }
        // saiu do fim: era a penúltima linha e não mandava em nada
        #expect(!Sabia.sistemaContrapor.contains("Não atribua a ela recurso"))
    }

    /// ADR 2026-09-10c — a alavanca do LOTE-7, e é UMA. O caso cego do revisor
    /// derrubou as duas famílias em PONTAS OPOSTAS na Q4-E: o `grok-4.5`
    /// propôs, 3 de 3, o ensaio com os dados reais que a nota fecha por
    /// escrito; o `grok-4.3` fechou uma base com os três campos vazios. A
    /// frase antiga só dava por DADO o requisito, a restrição e o motivo — e
    /// uma saída DESCARTADA não é nenhum dos três, então o modelo a lia como
    /// opinião a rebater ou lacuna a preencher.
    ///
    /// A regra nova é uma só e fecha as duas de uma vez, condicionada à
    /// MATÉRIA: o que ela descartou é dado (fecha a invenção) e, quanto mais
    /// ela fecha, mais o contraponto se aperta no que SOBRA (fecha a recusa
    /// covarde). Sem promover lista, sem exigir número de campos, sem pedir
    /// autocertificação — foi assim que a Q4-C comprou o defeito oposto.
    @Test func oContratoDeContraporFechaASaidaQueElaMesmaDescartou() {
        for pedaço in ["é DADO também",
                       "o que ela já descartou, recusou ou disse não ter",
                       "nem como alternativa no foraDaLista, nem como etapa antes",
                       "Saída que ela mesma fechou não é contraponto, é troca de assunto",
                       "Quanto mais saídas ela fecha, mais o contraponto se aperta no que SOBRA",
                       // tentativa 2: as duas pontas que sobraram na primeira
                       "O que ela pôs fora da conta fica fora, a favor e contra",
                       "não ofereça",
                       "substituto para o recurso que ela disse não ter"] {
            #expect(Sabia.sistemaContrapor.contains(pedaço))
        }
        // A guarda que acusa precisa da irmã que NÃO acusa: a regra é abstrata
        // e não pode carregar as palavras do caso cego, ou passa por decorar.
        for doCegoQueNaoEntra in ["homologação", "faseamento", "academia", "banco de dados"] {
            #expect(!Sabia.sistemaContrapor.contains(doCegoQueNaoEntra))
        }
    }

    /// ADR 2026-09-10d — a TERCEIRA alavanca: o esquema da saída. Não é uma
    /// terceira redação do pedido, e este par prova isso — o CORPO das
    /// instruções é byte a byte o mesmo nos dois braços; o que muda é a FORMA
    /// que a resposta tem de ter, e essa a API aplica.
    @Test func osDoisBracosDoContraporPedemAMesmaCoisaEDiferemSoNaForma() throws {
        let corpo = "Cada valor em português, até 280 caracteres"
        let iA = try #require(Sabia.sistemaContrapor.range(of: corpo))
        let iB = try #require(Sabia.sistemaContraporComEsquema.range(of: corpo))
        #expect(Sabia.sistemaContrapor[iA.lowerBound...] == Sabia.sistemaContraporComEsquema[iB.lowerBound...],
                "o esquema virou uma terceira redação do pedido")
        // A ORDEM é a alavanca: `fechadas` sai ANTES da proposta existir, e o
        // modelo escreve da esquerda para a direita. Um esquema montado por
        // dicionário de Swift perderia isto sem erro nenhum.
        let e = Sabia.esquemaContrapor
        let pos = try ["fechadas", "contra", "foraDaLista", "dependeDe", "outroCampo"].map {
            try #require(e.range(of: "\"\($0)\":")).lowerBound
        }
        #expect(pos == pos.sorted(), "a ordem das chaves do esquema não é a da geração")
        let j = try #require(try JSONSerialization.jsonObject(with: Data(e.utf8)) as? [String: Any])
        #expect(j["additionalProperties"] as? Bool == false)
        #expect((j["required"] as? [String])?.count == 5, "strict exige TODAS as chaves em required")
    }

    /// ADR 2026-09-10d — o esquema é lido, e o JOIN não decide.
    ///
    /// Este teste guarda a decisão medida no LOTE-9, não uma intenção. O join
    /// `dependeDoQueElaFechou` foi escrito, medido (5 disparos, 1 acerto, 4
    /// erros) e RETIRADO do caminho: `fechadas` e `dependeDe` continuam no
    /// esquema — porque a FORMA medida é esta — e nenhum dos dois apaga nada.
    @Test func oEsquemaEhLidoEOJoinNaoDecideMais() {
        let nota = "Vou virar o banco de dados de uma vez no sábado à noite. Fazer em etapas eu já descartei: "
            + "o esquema muda inteiro e as duas versões não rodam juntas. Não tenho ambiente de teste com os dados reais."
        _ = Sabia.retirarGuardasQueApagaram()
        // O caso que o join MATAVA no LOTE-9 (`4.5`, razões fechadas r1):
        // "pausar a matrícula" depende da matrícula que ela TEM. Chega ao autor.
        let boa = Sabia.parseContraparte(#"""
        {"fechadas":["não quero trocar por outra academia","não quero treinar em casa"],"contra":"Manter a assinatura preserva o acesso a cinco minutos para o dia em que a vontade voltar.","foraDaLista":"pausar ou congelar a matrícula por um período, em vez de cancelar de vez","dependeDe":"a academia permitir pausa da matrícula sem trocar de unidade","outroCampo":""}
        """#, texto: "Vou cancelar a assinatura da academia. Não quero trocar por outra academia nem treinar em casa.")
        #expect(boa?.foraDaLista.isEmpty == false, "o join voltou e matou a proposta que o LOTE-9 mediu como boa")
        #expect(Sabia.retirarGuardasQueApagaram().isEmpty, "alguma guarda se declarou dona deste silêncio")

        // As duas chaves novas são LIDAS e não derrubam o contrato do parser.
        let cego = Sabia.parseContraparte(#"""
        {"fechadas":["fazer em etapas","ambiente de teste com os dados reais"],"contra":"O corte único concentra o risco na única noite em que o contrato ainda admite entrega.","foraDaLista":"virada em modo somente leitura, com retorno por restore se não fechar na madrugada","dependeDe":"uma cópia restaurável recente","outroCampo":""}
        """#, texto: nota)
        #expect(cego?.foraDaLista.isEmpty == false)
        #expect(cego?.contra.isEmpty == false)
        // O braço ANTIGO passa pelo MESMO parser sem as duas chaves.
        let antigo = Sabia.parseContraparte(#"{"contra":"O corte único concentra o risco na noite do contrato.","foraDaLista":"virada em janela de manutenção fora do sábado à noite","outroCampo":""}"#, texto: nota)
        #expect(antigo?.foraDaLista.isEmpty == false)
        #expect(Sabia.retirarGuardasQueApagaram().isEmpty)
    }

    /// A DÍVIDA, com a prova de por que ela é dívida. O join continua no código
    /// sem chamador, e este teste é o motivo: ele mostra, com os dois casos
    /// MEDIDOS lado a lado, que casar palavra não separa "o recurso que ela não
    /// tem" de "o recurso que ela tem, usado de outro jeito". Apagar a função
    /// apagaria a prova, e a próxima volta recomeçaria pela mesma ideia.
    @Test func oJoinPorPalavraNaoSeparaOQueElaNaoTemDoQueElaUsaDeOutroJeito() {
        let fechadasDaAcademia = ["não quero trocar por outra academia", "não quero treinar em casa"]
        // ACERTO (LOTE-9, `4.5`, alternativas negadas r2): o recurso é o que ela NÃO tem.
        #expect(Sabia.dependeDoQueElaFechou("espelho ou cópia isolada dos dados reais só para medir a duração",
                                            fechadas: ["fazer em etapas", "ambiente de teste com os dados reais"]))
        // ERRO (LOTE-9, `4.5`, razões fechadas r1): o recurso é o que ela TEM.
        #expect(Sabia.dependeDoQueElaFechou("a academia permitir pausa da matrícula sem trocar de unidade",
                                            fechadas: fechadasDaAcademia),
                "se este deixou de acusar, o desenho mudou e a dívida pode ser revista")
        // A nota que não fecha nada não paga preço nenhum, e nunca pagou.
        #expect(!Sabia.dependeDoQueElaFechou("um relógio ou o próprio tempo do percurso", fechadas: []))
    }

    /// ADR 2026-09-10c — o portão que vem ANTES do prompt. Três campos vazios
    /// sobre HTTP 200 têm DUAS causas possíveis, e a tela e a ADR dependem de
    /// saber qual: o modelo calou, ou a nossa guarda apagou. `guardasQueApagaram`
    /// separa as duas — e este par prova que ela ENXERGA: a irmã que acusa e a
    /// irmã que não acusa, sobre a mesma nota e a mesma forma de retorno.
    @Test func tresVaziosDoModeloNaoSaoTresVaziosDaGuarda() {
        let nota = "Vou parcelar o notebook em 18 vezes sem juros. Minha reserva cobre três meses."
        _ = Sabia.retirarGuardasQueApagaram()
        // o MODELO calou: vem vazio, nenhuma guarda tem o que apagar
        let calou = Sabia.parseContraparte(#"{"contra":"","foraDaLista":"","outroCampo":""}"#, texto: nota)
        #expect(calou?.vazia == true)
        #expect(Sabia.retirarGuardasQueApagaram().isEmpty, "o modelo calou e uma guarda se declarou dona do silêncio")
        // a GUARDA apagou: veio conteúdo, e nada dele era sobre a nota dela
        let apagada = Sabia.parseContraparte(
            #"{"contra":"Parcelar em 18 vezes compromete a renda dos meses seguintes.","foraDaLista":"","outroCampo":""}"#,
            texto: nota)
        #expect(apagada?.vazia == true)
        #expect(Sabia.retirarGuardasQueApagaram() == ["contra · fato que ele não deu"])
    }
}
