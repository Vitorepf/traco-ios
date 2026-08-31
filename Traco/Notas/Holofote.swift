import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

/// Spotlight (exp 3): as notas ABERTAS aparecem na busca do iOS.
/// O selo tem a regra pronta: trancada JAMAIS entra no índice do sistema.
enum Holofote {
    private static let dominio = "app.traco.notas"

    static func indexar(notas: [(uuid: UUID, voz: String, trancada: Bool)]) {
        let indice = CSSearchableIndex.default()
        // reconstrução simples: apaga o domínio e regrava as abertas
        indice.deleteSearchableItems(withDomainIdentifiers: [dominio]) { _ in
            let itens = notas
                .filter { !$0.trancada && !$0.voz.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .prefix(200)
                .map { nota -> CSSearchableItem in
                    let attr = CSSearchableItemAttributeSet(contentType: .text)
                    let linhas = nota.voz.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
                    attr.title = String(linhas.first ?? "nota")
                    attr.contentDescription = linhas.count > 1 ? String(linhas[1].prefix(120)) : nil
                    return CSSearchableItem(
                        uniqueIdentifier: nota.uuid.uuidString,
                        domainIdentifier: dominio,
                        attributeSet: attr
                    )
                }
            guard !itens.isEmpty else { return }
            indice.indexSearchableItems(Array(itens))
        }
    }
}
