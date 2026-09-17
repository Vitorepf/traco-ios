import SwiftUI

/// Cápsula de controle (SISTEMA-CLARO §2.3). Um desenho para o que hoje são
/// seis: o rótulo é a cápsula; o alvo de 44 vive no botão ou no menu que a
/// envolve (ADR 05f), ou nasce aqui quando há `acao`.
///
/// As formas registram as medidas que cada tela tem HOJE, sem mudar pixel:
/// a volta por tela decide qual sobrevive (o sistema pede `controle`).
struct Pilula<Conteudo: View>: View {
    enum Forma {
        /// Trabalho e caderno, ações em cápsula: meta médio, 12×8, mínimo 34 (mede 36).
        /// (D1: as Notas deixaram de usar cápsulas — filtro e ordem são palavras.)
        case filtro
        /// SISTEMA-CLARO: 36 de altura num trilho de 44.
        case controle
        /// "Pronto": chrome, 14, 36, sempre carvão.
        case acao
        /// Ação de largura inteira: chrome, alvo 44, chip.
        case larga
        /// Rótulo em cápsula (o gesto na lista das Notas): 6×2.
        case etiqueta
    }

    var forma: Forma = .controle
    var selecionada = false
    var acao: (() -> Void)?
    @ViewBuilder var conteudo: () -> Conteudo
    @Environment(\.isEnabled) private var ativa

    init(forma: Forma = .controle, selecionada: Bool = false,
         acao: (() -> Void)? = nil, @ViewBuilder conteudo: @escaping () -> Conteudo) {
        self.forma = forma
        self.selecionada = selecionada
        self.acao = acao
        self.conteudo = conteudo
    }

    var body: some View {
        if let acao {
            Button(action: acao) { capsula }
                .alvo()
                .buttonStyle(.discreto)
        } else {
            capsula
        }
    }

    private var cheia: Bool { forma == .acao || selecionada }

    /// DESABILITADA continua LEGÍVEL. `tintaMorta` (#C7C7CC) mede **1,53:1**
    /// sobre o papel — abaixo de qualquer piso — e era o que TODOS os chamadores
    /// recebiam (A3 da revisão da V19; a `TrabalhoView` chegou a contornar o
    /// componente por causa disto). `tintaFraca` (#68686C) mede **5,04:1** no
    /// papel, **4,65:1** na névoa, **4,52:1** no chip e **5,55:1** no branco:
    /// ≥ 4,5:1 em todo fundo onde uma cápsula pode pousar. Quem diz "desligado"
    /// passa a ser o FUNDO que sai, não o texto que apaga.
    /// Fora do `body` para ter teste (`PilulaContrasteTests`): a tinta é a
    /// decisão de acessibilidade do componente e não pode voltar a 1,53:1 sem
    /// alguém ver.
    static func tinta(ativa: Bool, cheia: Bool, forma: Forma) -> Color {
        if !ativa { return Tema.tintaFraca }
        if cheia { return Tema.sobreAtivo }
        return forma == .larga ? Tema.tinta : Tema.tintaSuave
    }

    private var fundo: Color {
        if !ativa { return .clear }
        return cheia ? Tema.chipAtivo : Tema.chip
    }

    /// O material das cápsulas que se tocam (15/09): o vidro do sistema, o
    /// mesmo do pé — a cápsula cinza chapada lia como controle barato ao lado
    /// dele. Cheia é vidro tingido de carvão; desligada não tem material, só a
    /// hairline (a forma continua visível, o convite não).
    @ViewBuilder private func vidro<V: View>(_ v: V) -> some View {
        if !ativa {
            v
        } else if cheia {
            v.glassEffect(.regular.tint(Tema.chipAtivo).interactive(), in: .capsule)
        } else {
            v.glassEffect(.regular.interactive(), in: .capsule)
        }
    }

    private var fonte: Font {
        switch forma {
        case .filtro: Tema.meta.weight(.medium)
        case .controle: CalendarioTema.dia
        case .acao, .larga: CalendarioTema.chrome
        case .etiqueta: Tema.label
        }
    }

    /// Sem o preenchimento, a cápsula desabilitada virava texto solto e a
    /// pessoa deixava de ver que ali havia um controle. A hairline guarda a
    /// FORMA do que está desligado — é a mesma linha de estrutura do resto do app.
    private var capsula: some View {
        corpo.overlay(Capsule().strokeBorder(ativa ? .clear : Tema.linha, lineWidth: 0.5))
    }

    @ViewBuilder private var corpo: some View {
        let base = conteudo()
            .font(fonte)
            .foregroundStyle(Self.tinta(ativa: ativa, cheia: cheia, forma: forma))
        switch forma {
        case .filtro:
            vidro(base.padding(.horizontal, 12).padding(.vertical, 8).frame(minHeight: 34))
        case .controle:
            vidro(base.padding(.horizontal, 12).frame(height: CalendarioTema.controle))
        case .acao:
            vidro(base.padding(.horizontal, 14).frame(height: CalendarioTema.controle))
        case .larga:
            vidro(base.frame(maxWidth: .infinity, minHeight: Tema.alvo))
        case .etiqueta:
            base.textCase(.uppercase).tracking(Tema.trackingLabel)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(fundo, in: Capsule())
        }
    }
}

extension Pilula where Conteudo == Text {
    init(_ texto: String, forma: Forma = .controle, selecionada: Bool = false,
         acao: (() -> Void)? = nil) {
        self.init(forma: forma, selecionada: selecionada, acao: acao) { Text(texto) }
    }
}

/// A seta de quem abre um menu, ao lado da palavra (Notas) ou no corpo da cápsula (ficha).
struct SetaDeMenu: View {
    var body: some View {
        Image(systemName: "chevron.down")
            .font(.caption2.weight(.semibold))
    }
}

#Preview("normal e selecionada") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            Pilula("Todas", forma: .filtro, selecionada: true) {}
            Pilula("WOOP", forma: .filtro) {}
            Pilula("Trabalho", forma: .filtro) {}
        }
        HStack(spacing: 8) {
            Pilula("Do seu iPhone", forma: .controle)
            Pilula("Pronto", forma: .acao)
            Pilula("Woop", forma: .etiqueta)
        }
        Pilula("Abrir no Calendário", forma: .larga) {}
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("pressionada") {
    // o que o dedo vê: a escala de `Tema.pressao` que o estilo `.discreto` aplica
    Pilula("Todas", forma: .filtro, selecionada: true)
        .scaleEffect(Tema.pressao)
        .padding()
        .background(Tema.fundo)
}

#Preview("desabilitada") {
    // ligada em cima, desligada embaixo: o que muda é o PREENCHIMENTO, não a
    // legibilidade — `tintaFraca` mede 5,04:1 sobre o papel (era 1,53:1)
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
            Pilula("Trancadas", forma: .filtro) {}
            Pilula("Pronto", forma: .acao) {}
            Pilula("Do seu iPhone", forma: .controle)
        }
        HStack(spacing: 8) {
            Pilula("Trancadas", forma: .filtro) {}
            Pilula("Pronto", forma: .acao) {}
            Pilula("Do seu iPhone", forma: .controle)
        }
        .disabled(true)
        Pilula("Abrir no Calendário", forma: .larga) {}.disabled(true)
    }
    .padding()
    .background(Tema.fundo)
}

#Preview("AX5") {
    HStack(spacing: 8) {
        Pilula("Todas", forma: .filtro, selecionada: true) {}
        Pilula("Pronto", forma: .acao) {}
    }
    .padding()
    .background(Tema.fundo)
    .environment(\.dynamicTypeSize, .accessibility5)
}
