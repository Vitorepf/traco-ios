import Foundation
import SwiftData

/// A cópia no Trabalho conserva a proteção da origem. Consultar nunca altera
/// nem apaga o agregado; toda superfície usa o mesmo resultado antes de expor.
@MainActor
enum AcessoTrabalho {
    enum Motivo: Equatable {
        case origemAusente, origemProtegida, indisponivel
    }

    enum Estado: Equatable {
        case permitido
        case restrito(Motivo)

        var permitido: Bool { self == .permitido }
        var mensagem: String {
            switch self {
            case .permitido: ""
            case .restrito(.origemAusente):
                "A nota de origem não está disponível. Este trabalho e seus rascunhos foram preservados, com acesso restrito."
            case .restrito(.origemProtegida):
                "A nota de origem está protegida. Este trabalho e seus rascunhos também ficam restritos; nada foi apagado."
            case .restrito(.indisponivel):
                "Não consegui verificar o acesso a este trabalho. O registro foi preservado e seu conteúdo não foi aberto."
            }
        }
    }

    /// Só metadados necessários à autorização; não carrega intenção, versões,
    /// evidências ou rascunhos para decidir se podem ser mostrados.
    private struct Vinculo: Decodable {
        var formato: Int
        var id: UUID
        var notaOrigemID: UUID?
    }

    static func estado(_ trabalho: Trabalho, no context: ModelContext) -> Estado {
        guard let vinculo = try? JSONDecoder().decode(Vinculo.self, from: trabalho.conteudoJSON),
              vinculo.formato == 1, vinculo.id == trabalho.uuid else {
            return .restrito(.indisponivel)
        }
        guard let origemID = vinculo.notaOrigemID else { return .permitido }
        do {
            var consulta = FetchDescriptor<Nota>(predicate: #Predicate { $0.uuid == origemID })
            consulta.fetchLimit = 1
            guard let nota = try context.fetch(consulta).first else { return .restrito(.origemAusente) }
            guard !nota.fechada, nota.gesto != .expressiva else { return .restrito(.origemProtegida) }
            return .permitido
        } catch {
            return .restrito(.indisponivel)
        }
    }

    static func permitido(_ trabalho: Trabalho, no context: ModelContext) -> Bool {
        estado(trabalho, no: context).permitido
    }

    /// Juízos no mundo só depois da tesoura. O Retrato não busca disco:
    /// o chamador passa o que esta função já autorizou.
    static func juizosObservados(de trabalhos: [Trabalho],
                                 no context: ModelContext) -> [Retrato.JuizoObservado] {
        trabalhos.filter { permitido($0, no: context) }
            .compactMap { try? $0.ler() }
            .flatMap(\.juizosObservados)
    }

    /// Os Trabalhos que nasceram desta nota. Só o vínculo é decodificado: selar
    /// a origem não é motivo para abrir o conteúdo de ninguém.
    static func derivados(daNota nota: UUID, no context: ModelContext) -> [UUID] {
        guard let todos = try? context.fetch(FetchDescriptor<Trabalho>()) else { return [] }
        return todos.filter {
            (try? JSONDecoder().decode(Vinculo.self, from: $0.conteudoJSON))?.notaOrigemID == nota
        }.map(\.uuid)
    }
}
