import SwiftUI

/// ONDE O AUTOR MORA (ADR 2026-09-17c).
///
/// A 02h fixou `.preferredColorScheme(.light)` na raiz com a frase "um mundo
/// só, nunca dois". O que ela proibia era o app virar claro numa aba e escuro
/// noutra — a lei da coerência, não uma proibição de escolher. Aqui a escolha
/// é UMA, do autor, e vale para o app inteiro: a raiz, as folhas do calendário
/// e a tela de arranque leem o mesmo valor. A lei de um mundo só POR VEZ
/// continua de pé.
///
/// O padrão é `.claro` de propósito, e não `.sistema`: hoje o app força claro
/// seja qual for a aparência do aparelho, e quem nunca abrir este ajuste tem de
/// ver exatamente o app de ontem. Um padrão `.sistema` mudaria o Traço, sem
/// pedido, para todo mundo que anda com o iPhone no escuro.
nonisolated enum Aparencia: String, CaseIterable, Sendable {
    case claro
    case escuro
    case sistema

    static let chave = "aparencia"

    /// O que a raiz entrega ao SwiftUI. `nil` é "não opine": a janela segue o
    /// aparelho, e os tokens do `Tema` se resolvem pelos traços dela.
    var esquema: ColorScheme? {
        switch self {
        case .claro: .light
        case .escuro: .dark
        case .sistema: nil
        }
    }

    /// O nome na linha do Perfil. Frase normal, na voz da casa.
    var nome: String {
        switch self {
        case .claro: "Claro"
        case .escuro: "Escuro"
        case .sistema: "Como no aparelho"
        }
    }

    /// A ordem em que as três aparecem no menu: os dois mundos primeiro, porque
    /// são a escolha; "como no aparelho" por último, porque é a renúncia a ela.
    static let naOrdem: [Aparencia] = [.claro, .escuro, .sistema]

    /// Fora de uma View (instrumento, teste, arranque).
    static var escolhida: Aparencia {
        get { (UserDefaults.standard.string(forKey: chave).flatMap(Aparencia.init(rawValue:))) ?? .claro }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: chave) }
    }
}

/// O mundo do autor, aplicado. Vive num modificador e não em cada tela porque
/// o valor tem de ser o MESMO nos cinco lugares que antes diziam `.light` — a
/// raiz, a tela de arranque, o calendário e as duas fichas dele. Uma folha
/// apresentada herda o esquema da raiz, mas as fichas do calendário já pediam
/// o seu na mão (elas nascem fora da árvore em algumas rotas); o modificador
/// mantém as duas coisas verdadeiras sem repetir a leitura do ajuste.
struct MundoDoAutor: ViewModifier {
    @AppStorage(Aparencia.chave) private var aparencia = Aparencia.claro

    func body(content: Content) -> some View {
        content.preferredColorScheme(aparencia.esquema)
    }
}

extension View {
    /// Um mundo só por vez, e é o que o autor escolheu no Perfil.
    func mundoDoAutor() -> some View { modifier(MundoDoAutor()) }
}
