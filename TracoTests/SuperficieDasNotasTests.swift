import Foundation
import SwiftData
import Testing
@testable import Traco

/// Auditoria 17/09, superfície das Notas: o que o toque longo OFERECE (o
/// «Recordar» só quando o ritual existe) e o que a seção «pelo sentido»
/// continua a desenhar depois de o autor apagar a nota.
@MainActor @Suite(.serialized)
struct SuperficieDasNotasTests {
    /// O menu olhava só o SELO, e selo não é fecho: a expressiva em curso, a
    /// queimada e a nota sem alvo recebiam um item que abre o que não pode
    /// abrir — ou que não abre nada e cala.
    @Test func oRecordarDoMenuSoApareceQuandoORitualExiste() {
        // expressiva EM CURSO: `trancada == false`, e o item abria o desabafo
        // inteiro na folha de releitura — o §8 só reabre com dupla confirmação
        // e Face ID
        let emCurso = Nota(texto: "Hoje foi pesado. Fiquei com raiva do que ouvi.",
                           gesto: .expressiva)
        #expect(!emCurso.fechada, "em curso não está selada — é por isso que passava")
        #expect(!NotasView.podeRecordar(emCurso))

        // queimada: `queimar` zera `trancada`, então ela também passava, para
        // morrer calada no `guard` da `Sessao` (§8.7: queimada não abre)
        let queimada = Nota(texto: "", gesto: .expressiva, queimada: true,
                            sentido: "ficou claro que eu precisava dormir")
        #expect(!queimada.trancada)
        #expect(!NotasView.podeRecordar(queimada))

        // Decisão sem «espero»: o alvo do rito é vazio (§15, "Recordar:
        // desabilitado sem alvo") — o toque não abria folha, toast nem háptico
        let semAlvo = Nota(texto: "Trocar de plano de celular", gesto: .decisao,
                           campos: ["escolha": "o de 30 GB", "decidido": "hoje"])
        #expect(!NotasView.podeRecordar(semAlvo))

        // as irmãs que NÃO acusam: com «espero» o rito existe, e a nota livre
        // escrita é o próprio alvo
        let comAlvo = Nota(texto: "Trocar de plano de celular", gesto: .decisao,
                           campos: ["escolha": "o de 30 GB", "espero": "gastar menos no fim do mês"])
        #expect(NotasView.podeRecordar(comAlvo))
        #expect(NotasView.podeRecordar(Nota(texto: "Comprei a geladeira à vista.")))
    }

    /// A seção era um retrato congelado: a nota apagada continuava desenhada e
    /// abrir o cartão punha na página um modelo já removido do contexto, que o
    /// `salvar` seguinte reinseria como nota nova.
    @Test func aSecaoPeloSentidoLargaANotaQueSaiuDoCaderno() throws {
        let c = try ModelContainer.traco(emMemoria: true)
        let ctx = c.mainContext
        let viva = Nota(texto: "Decidir se troco de plano\nO de 30 GB sai mais barato.")
        let selada = Nota(texto: "Desabafo\nselado.", trancada: true)
        for n in [viva, selada] { ctx.insert(n) }
        try ctx.save()

        let apagada = Nota(texto: "Conta do celular\nCaiu para 60 reais.")
        let ids = [apagada.uuid, viva.uuid, selada.uuid]

        // com as três no caderno: a ordem do índice de sentido se mantém e a
        // selada cai — o selo corta na resolução, não só na busca
        #expect(NotasView.resolverPeloSentido(ids: ids, entre: [apagada, viva, selada]).map(\.uuid)
                == [apagada.uuid, viva.uuid])

        // apagar tira do `@Query`; a seção tem de sair no MESMO quadro
        ctx.delete(viva)
        try ctx.save()
        let restantes = try ctx.fetch(FetchDescriptor<Nota>())
        #expect(!restantes.contains { $0.uuid == viva.uuid })
        #expect(NotasView.resolverPeloSentido(ids: ids, entre: restantes).isEmpty)
    }
}
