import Foundation
import Testing
@testable import Traco

/// A regra do rascunho da folha do Trabalho, e o estado preso que ela desfaz.
///
/// O G4 da volta 18 recusou por isto: depois de o autor guardar a PRÓPRIA
/// versão, a folha afirmava para sempre uma edição pendente que não existia —
/// imprimia a versão duas vezes, travava "Preparar nova versão com IA" e a
/// importação, e sobrevivia a fechar, reabrir, descartar e reiniciar o
/// aparelho. A causa: `campoEmEdicao` julgava "versao" por NÃO-VAZIO, e o
/// próprio campo "Editar a versão" grava o rascunho quando o `TextField` sai
/// da tela devolvendo ao binding o texto que acabou de virar versão.
///
/// Estes testes exercitam a regra pura (`TrabalhoView.alterado`,
/// `TrabalhoView.campoEmEdicao`) e o caminho inteiro do achado, incluindo a
/// volta pelo `UserDefaults` com a chave que o app usa — que é o que "fechar
/// e reabrir" significa nesta folha.
@MainActor
struct RascunhoTrabalhoTests {
    /// Fecha e reabre a folha: o rascunho vai ao `UserDefaults` pela chave do
    /// app e volta de lá, como faz `.task` ao abrir.
    private func reabrindo(_ rascunhos: [String: String], _ trabalho: UUID) -> [String: String] {
        let chave = TrabalhoView.chaveRascunho(trabalho)
        UserDefaults.standard.set(rascunhos, forKey: chave)
        defer { UserDefaults.standard.removeObject(forKey: chave) }
        return UserDefaults.standard.dictionary(forKey: chave) as? [String: String] ?? [:]
    }

    /// O achado 1 inteiro: guardar a própria versão, fechar, reabrir — e a
    /// folha continua destravada.
    @Test func guardarAPropriaVersaoNaoDeixaEdicaoPendenteAoReabrir() throws {
        var d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        try d.guardarVersaoHumana("Minha versão, escrita por mim.")

        // O que o `TextField` grava ao sair da tela, depois do `limpar` do
        // salvamento: o rascunho idêntico ao texto que virou versão.
        let rascunhos = reabrindo(["versao": "Minha versão, escrita por mim."], d.id)

        #expect(rascunhos["versao"] != nil, "o rascunho fantasma sobrevive ao reabrir; é a regra que precisa ignorá-lo")
        #expect(TrabalhoView.alterado(rascunhos, "versao", em: d) == false)
        #expect(TrabalhoView.campoEmEdicao(rascunhos, em: d) == nil,
                "a folha não pode afirmar uma edição que ninguém fez: é o que travava Preparar e Importar")
    }

    /// O lado que precisa continuar bloqueando: versão de verdade em edição.
    @Test func versaoDiferenteDaGuardadaContinuaPendente() throws {
        var d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        try d.guardarVersaoHumana("Primeira versão.")
        let rascunhos = ["versao": "Primeira versão, com um parágrafo novo."]
        #expect(TrabalhoView.alterado(rascunhos, "versao", em: d))
        #expect(TrabalhoView.campoEmEdicao(rascunhos, em: d) == "versao")
    }

    /// Sem versão guardada, escrever a primeira ainda é edição pendente: o
    /// documento guarda "" e qualquer texto difere dele.
    @Test func primeiraVersaoEmEdicaoContinuaPendente() {
        let d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        #expect(TrabalhoView.campoEmEdicao(["versao": "Estou escrevendo."], em: d) == "versao")
        #expect(TrabalhoView.campoEmEdicao(["versao": ""], em: d) == nil)
    }

    /// O outro rascunho fantasma da mesma origem, e o que desfaz o aparelho
    /// já preso.
    ///
    /// Medido no simulador com o build desta volta: depois de "Guardar minha
    /// versão", o `plist` do app tinha `"versao" => ""`. O `TextField` que sai
    /// da tela devolve ao binding o que ele lê, e o `limpar` do salvamento já
    /// tinha apagado o rascunho — então o que voltou foi o `padrao` do campo
    /// "Sua versão", a string vazia. Julgada só por diferença, essa string
    /// vazia continuava travando a folha, agora por ser diferente da versão.
    /// Nenhum destes campos pode ser guardado vazio, então rascunho em branco
    /// não é edição pendente em campo nenhum — e é assim que um aparelho que
    /// já entrou no estado preso sai dele sozinho.
    @Test func rascunhoVazioNaoEEdicaoPendente() throws {
        var d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        try d.guardarVersaoHumana("Minha versão.")
        #expect(TrabalhoView.campoEmEdicao(["versao": ""], em: d) == nil)
        #expect(TrabalhoView.campoEmEdicao(["versao": "   "], em: d) == nil)
        #expect(TrabalhoView.campoEmEdicao(["intencao": ""], em: d) == nil)
    }

    /// A intenção já era julgada por diferença; a regra única não mudou isso.
    @Test func intencaoEResultadoSeguemJulgadosPorDiferenca() {
        let d = DocumentoTrabalho(intencao: "Apresentar minha ideia", resultado: "Explicar em um minuto")
        #expect(TrabalhoView.campoEmEdicao(["intencao": "Apresentar minha ideia"], em: d) == nil)
        #expect(TrabalhoView.campoEmEdicao(["intencao": "Apresentar em espanhol"], em: d) == "intencao")
        #expect(TrabalhoView.campoEmEdicao(["resultado": "Explicar em um minuto"], em: d) == nil)
        #expect(TrabalhoView.campoEmEdicao(["resultado": "Sem ler o papel"], em: d) == "resultado")
    }

    /// A ordem em que a folha lê os campos é a ordem do desvio: quem bloqueia
    /// primeiro é o primeiro que a pessoa encontra rolando.
    @Test func aOrdemDoDesvioEADaLeitura() throws {
        var d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        try d.guardarVersaoHumana("Primeira versão.")
        let tudo = ["intencao": "Outra intenção", "resultado": "Outro resultado", "versao": "Outro texto"]
        #expect(TrabalhoView.campoEmEdicao(tudo, em: d) == "intencao")
    }

    /// Campo livre não tem guardado de onde diferir: texto nele é edição,
    /// espaço em branco não é.
    @Test func campoLivreNaoTemGuardado() {
        let d = DocumentoTrabalho(intencao: "Apresentar minha ideia")
        #expect(TrabalhoView.guardado("pedido", em: d) == nil)
        #expect(TrabalhoView.alterado(["pedido": "Prepare uma apresentação"], "pedido", em: d))
        #expect(TrabalhoView.alterado(["pedido": "   "], "pedido", em: d) == false)
        // O rodapé pergunta exatamente isto para decidir se há rascunho a
        // descartar; com o fantasma da versão, ele oferecia descartar nada.
        var comVersao = d
        try? comVersao.guardarVersaoHumana("Minha versão.")
        let fantasma = ["versao": "Minha versão."]
        #expect(fantasma.keys.contains { TrabalhoView.alterado(fantasma, $0, em: comVersao) } == false)
    }
}
