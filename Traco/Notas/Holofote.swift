import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

/// Spotlight (exp 3): as notas ABERTAS aparecem na busca do iOS.
/// O selo tem a regra pronta: trancada JAMAIS entra no índice do sistema.
enum Holofote {
    private static let dominio = "app.traco.notas"

    /// O que pode ir ao Spotlight: só a aberta que não é expressiva em curso.
    /// Fechada (selada ou queimada) e expressiva em curso nunca (§19.1, §8.8).
    nonisolated static func sai(fechada: Bool, expressivaEmCurso: Bool, voz: String) -> Bool {
        !fechada && !expressivaEmCurso && !voz.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func indexar(notas todas: [Nota]) {
        indexar(notas: todas.map { n in
            (n.uuid, n.vozDoAutor, !sai(fechada: n.fechada, expressivaEmCurso: n.gesto == .expressiva && !n.fechada, voz: n.vozDoAutor))
        })
    }

    /// Os itens são montados ANTES do salto: a versão com closure lia
    /// `dominio` (isolado no MainActor) e capturava o `CSSearchableIndex`
    /// (não-Sendable) dentro de uma closure `@Sendable`.
    static func indexar(notas: [(uuid: UUID, voz: String, trancada: Bool)]) {
        let alvo = dominio
        let itens = notas
            .filter { !$0.trancada && !$0.voz.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            // era 200, sem comentário e sem fila: da nota 201 em diante o
            // arquivo simplesmente não existia para a busca do iPhone, e nada
            // no app dizia isso (varredura 04/set)
            .prefix(5000)
            .map { nota -> CSSearchableItem in
                let attr = CSSearchableItemAttributeSet(contentType: .text)
                let linhas = nota.voz.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
                attr.title = String(linhas.first ?? "nota")
                attr.contentDescription = linhas.count > 1 ? String(linhas[1].prefix(120)) : nil
                return CSSearchableItem(
                    uniqueIdentifier: nota.uuid.uuidString,
                    domainIdentifier: alvo,
                    attributeSet: attr
                )
            }
        Task {
            let indice = CSSearchableIndex.default()
            // reconstrução simples: apaga o domínio e regrava as abertas.
            // A ordem importa — apagar DEPOIS de indexar limparia o que acabou
            // de entrar, e o selo depende deste apagar acontecer.
            try? await indice.deleteSearchableItems(withDomainIdentifiers: [alvo])
            guard !itens.isEmpty else { return }
            try? await indice.indexSearchableItems(Array(itens))
        }
    }
}
