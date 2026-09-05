import Foundation
import SwiftData

/// Uma leitura do agregado confirmado, nunca um segundo registro de agenda.
@MainActor
enum CalendarioTrabalho {
    static func eventos(_ trabalhos: [Trabalho], no context: ModelContext) -> [EventoCalendario] {
        trabalhos.flatMap { trabalho -> [EventoCalendario] in
            guard AcessoTrabalho.permitido(trabalho, no: context),
                  let documento = try? trabalho.ler() else { return [] }
            return documento.acoes.compactMap { acao in
                guard acao.estado == .pendente, let data = acao.agendadaEm else { return nil }
                return EventoCalendario(id: acao.id, titulo: acao.texto,
                    inicio: data, fim: data, origemTrabalho: trabalho.uuid,
                    avisoMinutos: nil)
            }
        }
    }
}
