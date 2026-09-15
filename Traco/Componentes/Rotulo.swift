import SwiftUI

/// Rótulo de seção (SISTEMA-CLARO §3): 11 semibold, caixa alta, tracking +1,2.
/// Era o mesmo trio de modificadores copiado em 32 lugares de 14 arquivos
/// (auditoria V9). A cor muda de tela para tela: as Notas usam `tintaFraca`,
/// a ficha do calendário e o Recordar usam `tintaSuave`.
///
/// Desde a ADR 10k (Hermes §5) a caixa alta só AGRUPA: quem a usa para dar
/// nome a um parágrafo, a uma coluna ou a uma etiqueta está nomeando
/// conteúdo, e isso vai em frase normal. O lugar dela é o `CabecalhoDeSecao`.
struct Rotulo: ViewModifier {
    var cor: Color = Tema.tintaFraca

    func body(content: Content) -> some View {
        content
            .textCase(.uppercase)
            .font(Tema.label)
            .tracking(Tema.trackingLabel)
            .foregroundStyle(cor)
    }
}

extension View {
    func rotulo(_ cor: Color = Tema.tintaFraca) -> some View { modifier(Rotulo(cor: cor)) }
}

/// O cabeçalho de seção (Hermes §5): sussurrado — versalete espaçado, cinza
/// fraco, pequeno — e dono da DENSIDADE. À direita vêm a contagem, quando a
/// seção é uma lista que se conta, e o chevron que a recolhe. No Hermes é o
/// "45 ⌄": controla-se ali, não num menu escondido.
struct CabecalhoDeSecao: View {
    let titulo: String
    var contagem: Int?
    var recolhida: Binding<Bool>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(_ titulo: String, contagem: Int? = nil, recolhida: Binding<Bool>? = nil) {
        self.titulo = titulo
        self.contagem = contagem
        self.recolhida = recolhida
    }

    var body: some View {
        if let recolhida {
            Button {
                withAnimation(Tema.animacao(.easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) {
                    recolhida.wrappedValue.toggle()
                }
            } label: {
                faixa(fechada: recolhida.wrappedValue)
            }
            .buttonStyle(.discreto)
            .accessibilityValue(recolhida.wrappedValue ? "recolhida" : "aberta")
            .accessibilityHint(recolhida.wrappedValue ? "Mostra a seção" : "Recolhe a seção")
        } else {
            faixa(fechada: nil)
        }
    }

    private func faixa(fechada: Bool?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(titulo).rotulo()
            Spacer(minLength: 8)
            if let contagem {
                Text("\(contagem)")
                    .font(Tema.meta.monospacedDigit())
                    .foregroundStyle(Tema.tintaFraca)
            }
            if let fechada {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Tema.tintaFraca)
                    .rotationEffect(.degrees(fechada ? -90 : 0))
            }
        }
        .frame(minHeight: Tema.alvo)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// A linha de lista (Hermes §4), a mesma em toda tela: três níveis — a
/// IDENTIDADE à esquerda, que distingue pela forma antes da cor; o TÍTULO; o
/// SUBTÍTULO numa linha só, cortado — e o fio de cabelo RECUADO, que começa
/// depois do glifo e acaba antes do acessório (chevron, interruptor,
/// contagem). Nunca de ponta a ponta: o fio separa textos, não a tela.
///
/// Sem caixa: a linha pousa no papel. O glifo é tinta suave, a menos que a
/// coisa tenha cor de IDENTIDADE (o domínio de um compromisso) — ver a regra
/// da cor no `Tema`.
struct LinhaDeLista<Glifo: View, Acessorio: View>: View {
    let titulo: String
    var subtitulo: String?
    /// nil deixa o título quebrar: quando o título É o conteúdo (a pergunta
    /// dos Padrões), cortá-lo seria esconder a coisa que se veio ler
    var linhasDoTitulo: Int? = 1
    /// o subtítulo tem duas linhas: numa só, o Perfil cortava a única cópia da
    /// explicação ("O Traço para de cobrar memória: a fil…", auditoria 15/09)
    var linhasDoSubtitulo = 2
    var fio = true
    /// O que destrói tem o título em `aviso` — é ESTADO, pela regra da cor
    var destrutiva = false
    @ViewBuilder var glifo: () -> Glifo
    @ViewBuilder var acessorio: () -> Acessorio
    @ScaledMetric(relativeTo: .body) private var coluna: CGFloat = 28

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // tinta suave por padrão; o glifo com cor de identidade traz a
            // própria e ganha (o estilo de dentro vence o de fora)
            glifo()
                .font(.body)
                .foregroundStyle(Tema.tintaSuave)
                .frame(width: coluna)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(Tema.chrome)
                    .foregroundStyle(destrutiva ? Tema.aviso : Tema.tinta)
                    .lineLimit(linhasDoTitulo)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: linhasDoTitulo == nil)
                if let subtitulo, !subtitulo.isEmpty {
                    Text(subtitulo)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .lineLimit(linhasDoSubtitulo)
                        .truncationMode(.tail)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .leading)
            // o fio mora na coluna do TEXTO: começa onde o título começa e
            // acaba onde ele acaba, antes do acessório
            .overlay(alignment: .bottom) {
                if fio { Rectangle().fill(Tema.linha).frame(height: 0.5) }
            }
            acessorio()
        }
        .contentShape(Rectangle())
        // uma linha, um elemento: "Grok, sem conta…" — como se lê de olho
        .accessibilityElement(children: .combine)
    }
}

extension LinhaDeLista where Glifo == Image, Acessorio == EmptyView {
    /// A forma mais comum: glifo do SF Symbols em tinta suave, sem acessório.
    init(_ simbolo: String, _ titulo: String, _ subtitulo: String? = nil,
         linhasDoTitulo: Int? = 1, fio: Bool = true, destrutiva: Bool = false) {
        self.init(titulo: titulo, subtitulo: subtitulo, linhasDoTitulo: linhasDoTitulo, fio: fio,
                  destrutiva: destrutiva,
                  glifo: { Image(systemName: simbolo) }, acessorio: { EmptyView() })
    }
}

extension LinhaDeLista where Glifo == Image, Acessorio == Chevron {
    /// A linha que se toca: o chevron é a forma da ação — não a cor.
    init(tocavel simbolo: String, _ titulo: String, _ subtitulo: String? = nil,
         linhasDoTitulo: Int? = 1, fio: Bool = true, destrutiva: Bool = false) {
        self.init(titulo: titulo, subtitulo: subtitulo, linhasDoTitulo: linhasDoTitulo, fio: fio,
                  destrutiva: destrutiva,
                  glifo: { Image(systemName: simbolo) }, acessorio: { Chevron() })
    }
}

/// As seções que o autor recolheu, lembradas entre aberturas — uma chave por
/// tela. Recolher é escolha de densidade de quem lê, não estado da sessão:
/// a seção fechada ontem continua fechada hoje.
struct Recolhidas: DynamicProperty {
    /// O estado vivo é `@State` (anima dentro do `withAnimation` do cabeçalho);
    /// o disco recebe a cópia. Com `@AppStorage` direto, a mudança chegava à
    /// árvore fora da transação e a seção abria e fechava em corte (vídeo de
    /// 14/09, volta 57).
    @State private var conjunto: Set<String>
    private let chave: String

    /// `deInicio`: as seções que nascem recolhidas até o autor abrir uma vez —
    /// letra miúda de consulta, cujo cabeçalho basta para ser achada.
    init(_ tela: String, deInicio: [String] = []) {
        chave = "secoes-recolhidas.\(tela)"
        let guardadas = UserDefaults.standard.string(forKey: chave) ?? deInicio.sorted().joined(separator: ",")
        _conjunto = State(initialValue: Set(guardadas.split(separator: ",").map(String.init)))
    }

    subscript(_ secao: String) -> Binding<Bool> {
        Binding(
            get: { conjunto.contains(secao) },
            set: { fechar in
                var s = conjunto
                if fechar { s.insert(secao) } else { s.remove(secao) }
                conjunto = s
                UserDefaults.standard.set(s.sorted().joined(separator: ","), forKey: chave)
            })
    }

    func aberta(_ secao: String) -> Bool { !conjunto.contains(secao) }

    /// Uma seção no papel (ADR 10k): o cabeçalho sussurrado, com o recolher
    /// lembrado, e o conteúdo embaixo. Sem cartão — o grupo é feito pelo
    /// espaço e pelo cabeçalho, não por uma caixa.
    func secao<Conteudo: View>(_ titulo: String, id: String, contagem: Int? = nil,
                               @ViewBuilder _ conteudo: () -> Conteudo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CabecalhoDeSecao(titulo, contagem: contagem, recolhida: self[id])
                .accessibilityIdentifier("secao-\(id)")
            if aberta(id) {
                conteudo()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

/// O acessório da linha que se toca. Cinza-escuro, como no Hermes.
struct Chevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Tema.tintaFraca)
            .accessibilityHidden(true)
    }
}

#Preview("normal") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Pelo sentido").rotulo()
        Text("Quando").rotulo(Tema.tintaSuave)
        Text("Aviso").rotulo(Tema.aviso)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("seção") {
    @Previewable @State var fechada = false
    VStack(alignment: .leading, spacing: 0) {
        CabecalhoDeSecao("Dados", contagem: 3, recolhida: $fechada)
        if !fechada {
            LinhaDeLista(tocavel: "square.and.arrow.up", "Exportar todas as notas", "um .md com as notas abertas")
            LinhaDeLista(tocavel: "square.and.arrow.down", "Importar notas", "de arquivos Markdown")
            LinhaDeLista("folder", "Espelhar numa pasta", "iCloud Drive ou outra nuvem sua", fio: false)
        }
    }
    .padding(.horizontal, Tema.margem)
    .background(Tema.fundo)
}

#Preview("AX5") {
    Text("O que não voltou").rotulo()
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
