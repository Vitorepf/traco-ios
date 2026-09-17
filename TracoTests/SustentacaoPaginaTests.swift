import Foundation
import Testing
@testable import Traco

/// A Página: documento inventado cai; obra fantasma cai sem chamar o modelo.
@MainActor
struct SustentacaoPaginaTests {
    @Test func pdfInventadoCaiEDocumentoNaNotaPassa() {
        let nota = "Reservei R$ 6.000. O prazo é 12/09."
        #expect(SustentacaoPagina.inventouDocumento(
            "Abra o PDF e vá ao sumário para achar o prazo.", material: nota))
        #expect(SustentacaoPagina.filtrar(
            "Abra o PDF e vá ao sumário.", pergunta: "qual o prazo?", contexto: nota)
            == SustentacaoPagina.recusaDocumento)
        #expect(!SustentacaoPagina.inventouDocumento(
            "O prazo que você anotou é 12/09.", material: nota))
        let comPdf = nota + " O PDF do banco está em Arquivos."
        #expect(!SustentacaoPagina.inventouDocumento(
            "O PDF do banco que você citou tem a cotação.", material: comPdf))
    }

    /// E8: a frase que supõe o documento sai; o resto da resposta fica. Só o que é
    /// todo documento inventado vira recusa. E o "pdf" que o material traz passa.
    @Test func aGuardaTiraAFraseENaoCalaARespostaInteira() {
        let nota = "Relatório de setembro: 1. Contexto; 2. Metodologia; 3. Resultados por praça. Tenho 30 minutos."
        let resposta = "Leia primeiro 3. Resultados por praça, que traz as filas de cada uma.\nAbra o PDF e vá ao sumário.\nDepois anote as três decisões em uma linha cada, dentro dos 30 minutos."
        let r = SustentacaoPagina.filtrar(resposta, pergunta: "como organizo a leitura?", contexto: nota)
        #expect(r == "Leia primeiro 3. Resultados por praça, que traz as filas de cada uma.\nDepois anote as três decisões em uma linha cada, dentro dos 30 minutos.")
        let misturada = "Comece pelas filas da praça Leste. Abra o PDF na página 3. Anote as três decisões antes dos 30 minutos acabarem."
        #expect(SustentacaoPagina.filtrar(misturada, pergunta: "como organizo?", contexto: nota)
                == "Comece pelas filas da praça Leste. Anote as três decisões antes dos 30 minutos acabarem.")
        let comPdf = nota + " Está no PDF que o banco mandou."
        #expect(SustentacaoPagina.filtrar("O PDF que o banco mandou traz a cotação; comece pela seção 3.", pergunta: "e agora?", contexto: comPdf)
                == "O PDF que o banco mandou traz a cotação; comece pela seção 3.", "o PDF que o material cita não é inventado")
    }

    /// E8: o pedido proíbe supor o que quem escreve anota ou usa, manda fechar a conta
    /// de data, dizer tudo o que falta, remeter a profissional em saúde, e não presume gênero.
    @Test func oPedidoDaPaginaNaoSupoeEFechaAConta() {
        let p = Sabia.sistemaResponder
        #expect(p.contains("Não suponha o que ela anota, usa ou tem") && p.contains("\"até 23/09\""))
        #expect(p.contains("com quantidade e unidade") && p.contains("o sinal é para o profissional"))
        #expect(p.contains("que você já observou") && p.contains("se você já mediu"))
        #expect(p.contains("dito COMO geral e condicional") && p.contains("só entram se o material os der"))
        #expect(p.contains(Sabia.semGenero))
    }

    /// E8 volta 4: as três respostas que a guarda da volta 2 quebrou no Air (T012, T057,
    /// S027) — sai o item ou o parágrafo inteiro, a lista renumera, nada fica vazio.
    @Test func aGuardaTiraOItemInteiroERenumera() throws {
        let casos: [(String, String, String, String)] = [
            (#"""
Com 30 min no celular, não leia em ordem. Abra o sumário (se existir) e vá direto a: resumo executivo, conclusões, recomendações e trechos que falem em decisão, alternativa ou próximo passo.

No app de PDF, use a busca por: decisão, recomenda, propõe, aprovar, opção, risco, prazo. Leia só o que cerca esses achados.

Para cada uma das três decisões que o relatório pede, fixe mentalmente (ou cole num bloco de notas do celular): o que está em jogo, o que o texto recomenda e o motivo principal. O restante descritivo fica de fora.

Ordem prática: 5 min mapear estrutura + buscas → 20 min nas três decisões → 5 min reler só o que fecha cada uma.
"""#,
             "Tenho 30 minutos hoje, só o celular na mão e não posso imprimir nem anotar em papel. Preciso sair com as três decisões que o relatório pede.", "Como eu organizo a leitura do relatório de 40 páginas?", "Para cada uma das três decisões que o relatório pede"),
            (#"""
Com 30 min e só o celular, não leia as 40 páginas em ordem. Trate o PDF como mapa de decisões, não como texto corrido.

1. Abra o arquivo e role rápido (1–2 min) só para achar: capa/sumário visual, seções numeradas, caixas de “recomendação/decisão/próximos passos”, tabelas e conclusões no fim de cada bloco. Anote mentalmente em que “faixa” de páginas cada uma está (ex.: início, meio, fim).

2. Nos ~25 min restantes, vá só a esses trechos. Em cada um, leia o parágrafo de abertura e o de fechamento; ignore o miolo descritivo. Para cada uma das três decisões, fixe: o que pede, opções ou critérios citados, prazo/responsável se aparecer.

3. No celular, use o que já tem: bloquinho de notas do sistema ou app de voz — grave ou digite em três linhas curtas (Decisão 1 / 2 / 3 + o essencial). Sem copiar do PDF, você reformula do que leu.

4. Se o sumário for só imagem, a rolagem rápida no começo e no fim costuma bastar; relatórios longos concentram pedido de decisão no resumo executivo (se houver), nas recomendações e na conclusão.

Saia com as três linhas; o resto fica para depois.
"""#,
             "Tenho 30 minutos hoje e só o celular na mão. O arquivo me chegou como imagem digitalizada: não tem busca, não tem índice clicável e não dá para copiar texto. Não posso imprimir nem anotar em papel. Preciso sair com as três decisões que o relatório pede.", "Como eu organizo a leitura do relatório de 40 páginas?", "1. Nos ~25 min restantes"),
            (#"""
Com 30 min no celular, não leia as 40 páginas em ordem. Vá direto ao que fecha as três decisões.

1. Abra o PDF e use a busca (lupa): “decisão”, “recomend”, “conclus”, “próximos passos”, “opção”, “proposta”. Anote mentalmente as páginas que batem.

2. Vá primeiro ao sumário (se houver), ao resumo executivo e às últimas seções — é onde o relatório costuma listar o que pede de quem lê.

3. Em cada trecho útil: leia só o parágrafo da decisão + 1–2 de contexto. Ignore anexos, gráficos longos e histórico até sobrar tempo.

4. Particione o relógio: ~5 min mapear onde estão as três; ~20 min extrair o enunciado de cada uma (o que escolher, critérios, prazo se estiver escrito); ~5 min reler só esses três pontos e gravar/foto de tela ou nota no próprio app do PDF.

5. Se o app permitir, marque ou destaque só essas frases; no fim você sai com as três decisões legíveis na tela, sem papel.

O que falta para afinar: o formato do arquivo (PDF pesquisável ou imagem) e se já sabe os títulos das seções. Com o que você tem, o caminho acima basta.
"""#,
             "Tenho 30 minutos hoje, só o celular na mão e não posso imprimir nem anotar em papel. Preciso sair com as três decisões que o relatório pede.", "Como eu organizo a leitura do relatório de 40 páginas?", "1. Em cada trecho útil")
        ]
        for (bruto, contexto, pergunta, fica) in casos {
            let r = try #require(SustentacaoPagina.filtrar(bruto, pergunta: pergunta, contexto: contexto))
            #expect(!SustentacaoPagina.inventouDocumento(r, material: pergunta + "\n" + contexto), "\(r)")
            let linhas = r.components(separatedBy: "\n")
            #expect(!linhas.contains { $0.wholeMatch(of: /\s*\d+[.)]\s*/) != nil }, "item vazio: \(r)")
            let numeros = linhas.compactMap { $0.prefixMatch(of: /\s*(\d+)[.)]/).flatMap { Int($0.output.1) } }
            #expect(numeros == Array(1...max(1, numeros.count)).prefix(numeros.count).map { $0 }, "\(numeros)")
            #expect(r.contains(fica) && !r.contains("Leia só o que cerca esses achados"), "\(r)")
        }
    }

    /// E8 volta 4: 200 sem conteúdo do provedor ganha uma nova tentativa, uma vez.
    @Test func respostaVaziaDoProvedorTentaDeNovoUmaVez() async {
        var chamadas = 0
        let r = await Sabia.responder(pergunta: "Como divido 15 minutos de espanhol?", contexto: "Tenho 15 minutos por dia.", gesto: nil,
                                      gerar: { _ in
            chamadas += 1
            if chamadas == 1 { Grok.registrarFalha(.transporte); return nil }
            return "Divida em três blocos de cinco minutos: ouvir, repetir em voz alta e escrever três frases."
        })
        Grok.limparFalha()
        #expect(chamadas == 2 && r?.hasPrefix("Divida em três blocos") == true)
        var outra = 0
        _ = await Sabia.responder(pergunta: "Como divido 15 minutos de espanhol?", contexto: "Tenho 15 minutos por dia.", gesto: nil,
                                  gerar: { _ in outra += 1; Grok.registrarFalha(.transporte); return nil })
        Grok.limparFalha()
        #expect(outra == 2, "só uma nova tentativa")
    }

    /// E8 volta 3: a guarda de gênero troca, não cala; e o que não presume gênero fica como está.
    @Test func aGuardaDeGeneroTrocaSemCalar() {
        #expect(SustentacaoPagina.semGeneroPresumido("Some o que você mesmo listou; Você mesma anotou 12/09.")
                == "Some o que você listou; Você anotou 12/09.")
        let neutra = "Mesmo assim, some o que você listou. O mesmo vale para o gelo."
        #expect(SustentacaoPagina.semGeneroPresumido(neutra) == neutra)
    }

    @Test func obraFantasmaNaPaginaNaoChamaOModelo() async {
        var chamou = false
        let r = await Sabia.responder(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            contexto: "Reservei R$ 6.000 para a viagem.",
            gesto: nil,
            gerar: { _ in
                chamou = true
                return "Abra o PDF. Voss defende um decreto."
            })
        #expect(!chamou, "a guarda da Página tem de calar o modelo")
        #expect(r?.contains(GuardaDeObra.fraseNaoEstaNoCaderno) == true)
        #expect(r?.contains("plantar") == true)
        #expect(r?.contains("decreto") != true)
        #expect(r?.contains("PDF") != true)
    }

    @Test func obraNaPaginaDeixaOModeloResponderEDocumentoInventadoCai() async {
        var chamou = false
        let r = await Sabia.responder(
            pergunta: "O que defende o Tratado das Nuvens Invertidas de Mélanie Voss?",
            contexto: "Tratado das Nuvens Invertidas de Mélanie Voss: a tese é esperar.",
            gesto: nil,
            gerar: { _ in
                chamou = true
                return "Abra o PDF e vá ao sumário."
            })
        #expect(chamou)
        #expect(r == SustentacaoPagina.recusaDocumento)
    }
}
