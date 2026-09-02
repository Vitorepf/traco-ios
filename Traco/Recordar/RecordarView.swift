import SwiftUI

/// O que cada forma esconde no Recordar. Destilar some tudo; o resto mostra
/// o alvo na leitura — Palavra e Se deixam a pista visível.
enum RitualRecordar: Equatable, Sendable {
    case livre, destilada, palavra, seEntao

    nonisolated static func de(_ gesto: Gesto?) -> Self {
        switch gesto {
        case .destilar: .destilada
        case .palavra: .palavra
        case .seEntao: .seEntao
        default: .livre
        }
    }

    /// Destilar some tudo. Palavra deixa a definição e some a palavra.
    /// Mostrar o alvo antes é ditado, não memória.
    nonisolated var mostraAlvoAntesDeEscrever: Bool {
        switch self {
        case .destilada, .palavra: false
        default: true
        }
    }

    /// O que o autor tenta lembrar. Destilar cobra a frase — ou o corte
    /// mais curto que ele chegou a fazer. O rascunho de origem nunca é o alvo:
    /// era o que se cortava, não o que se lembra.
    nonisolated func alvo(texto: String, campos: [String: String]) -> String {
        switch self {
        case .livre:
            return VozDoAutor.juntar(texto: texto, campos: campos)
        case .destilada:
            for id in ["frase", "em50", "em100", "em200"] {
                let corte = campos[id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !corte.isEmpty { return corte }
            }
            return ""
        case .palavra:
            return Caderno.prosa(de: texto).trimmingCharacters(in: .whitespacesAndNewlines)
        case .seEntao:
            return campos["entao"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
    }

    nonisolated func temAlvo(texto: String, campos: [String: String]) -> Bool {
        !alvo(texto: texto, campos: campos).isEmpty
    }
}

struct RecordarView: View {
    let texto: String
    let campos: [String: String]
    var gesto: Gesto?
    var aoRevelar: () -> Void = {}
    var aoCobrarAntes: (() -> Void)?
    var aoProxima: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var fase: Fase
    @State private var memoria = ""
    @FocusState private var foco: Bool

    private enum Fase {
        case ler, esconder, escrever, revelar
    }

    init(texto: String, campos: [String: String], gesto: Gesto? = nil,
         aoRevelar: @escaping () -> Void = {},
         aoCobrarAntes: (() -> Void)? = nil,
         aoProxima: (() -> Void)? = nil) {
        self.texto = texto
        self.campos = campos
        self.gesto = gesto
        self.aoRevelar = aoRevelar
        self.aoCobrarAntes = aoCobrarAntes
        self.aoProxima = aoProxima
        _fase = State(initialValue: RitualRecordar.de(gesto).mostraAlvoAntesDeEscrever ? .ler : .escrever)
    }

    private var modo: RitualRecordar { RitualRecordar.de(gesto) }

    private var notaInteira: String {
        VozDoAutor.juntar(texto: texto, campos: campos)
    }

    private var pista: String {
        switch modo {
        case .livre: notaInteira
        case .destilada: ""
        case .palavra: campos["minhas"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        case .seEntao: campos["se"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
    }

    private var alvo: String {
        modo.alvo(texto: texto, campos: campos)
    }

    private var pergunta: String {
        switch modo {
        case .livre: "O que estava escrito?"
        case .destilada: "A frase?"
        case .palavra: "Qual era a palavra?"
        case .seEntao: "Então você faz o quê?"
        }
    }

    private var instrucao: String {
        switch modo {
        case .livre: "Leia uma última vez — a nota vai se esconder."
        case .destilada: "A frase some. Escreva-a de memória."
        case .palavra: "A definição fica. A palavra some."
        case .seEntao: "O Se fica. O Então some."
        }
    }

    private var rotuloAlvo: String {
        switch modo {
        case .livre: "A NOTA"
        case .destilada: "A FRASE"
        case .palavra: "A PALAVRA"
        case .seEntao: "ENTÃO"
        }
    }

    private var memoriaVazia: Bool {
        memoria.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.backward")
                            .font(.subheadline.weight(.semibold))
                        Text("voltar")
                            .font(Tema.chrome)
                    }
                }
                    .foregroundStyle(Tema.tinta)
                    .frame(minHeight: Tema.alvo)
                    .buttonStyle(PressaoDiscreta())
                    .accessibilityLabel("Voltar")
                Spacer()
                Text("RECORDAR")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaFraca)
                Spacer()
                Color.clear.frame(width: 64, height: Tema.alvo)
            }
            .padding(.horizontal, Tema.margem)

            if fase == .ler || fase == .esconder {
                Text(instrucao)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 16)
            }

            switch fase {
            case .ler:
                ScrollView {
                    if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                        Text(pista)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .padding(.bottom, 16)
                    }
                    if modo.mostraAlvoAntesDeEscrever {
                        Text(alvo)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                    }
                }
            case .esconder:
                ScrollView {
                    if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                        Text(pista)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Tema.margem)
                            .padding(.bottom, 16)
                    }
                    if modo.mostraAlvoAntesDeEscrever {
                        Text(alvo)
                            .font(Tema.corpo)
                            .foregroundStyle(Tema.tinta)
                            .blur(radius: reduceMotion ? 0 : 14)
                            .scaleEffect(reduceMotion ? 1 : 0.985)
                            .opacity(0.25)
                            .padding(.horizontal, Tema.margem)
                            .accessibilityHidden(true)
                    }
                }
            case .escrever:
                if modo == .palavra || modo == .seEntao, !pista.isEmpty {
                    Text(pista)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tintaSuave)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Tema.margem)
                        .padding(.bottom, 12)
                }
                Text(pergunta)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tema.margem)
                    .padding(.bottom, 8)
                TextEditor(text: $memoria)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .scrollContentBackground(.hidden)
                    .focused($foco)
                    .tint(Tema.ambar)
                    .padding(.horizontal, Tema.margem - 5)
                    .accessibilityLabel("Memória")
                Button("Revelar") {
                    Toque.suave()
                    foco = false
                    aoRevelar()
                    withAnimation(.easeOut(duration: 0.35)) { fase = .revelar }
                }
                .disabled(memoriaVazia)
                .buttonStyle(PrimarioStyle(recede: memoriaVazia))
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
                .accessibilityHint(memoriaVazia ? "Escreva de memória primeiro" : "Mostra memória e nota lado a lado")
            case .revelar:
                GeometryReader { geo in
                    let ladoALado = geo.size.width >= 360
                    let colunas = ladoALado
                        ? [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                        : [GridItem(.flexible())]
                    ScrollView {
                        LazyVGrid(columns: colunas, alignment: .leading, spacing: 22) {
                            bloco("DE MEMÓRIA", memoria)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                            bloco(rotuloAlvo, alvo)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                                .animation(.easeOut(duration: 0.35).delay(0.08), value: fase)
                        }
                        .padding(Tema.margem)
                        .overlay {
                            if ladoALado {
                                Rectangle()
                                    .fill(Tema.linha)
                                    .frame(width: 0.5)
                                    .padding(.vertical, Tema.margem)
                            }
                        }
                    }
                }
                VStack(spacing: 4) {
                    if let aoProxima {
                        Button("próxima") { aoProxima() }
                            .buttonStyle(PrimarioStyle())
                            .accessibilityLabel("Próxima")
                            .accessibilityHint("Abre a seguinte. Sem contagem.")
                    } else {
                        Button("Voltar à página") { dismiss() }
                            .buttonStyle(PrimarioStyle())
                    }
                    if let aoCobrarAntes {
                        Button("cobrar antes") { aoCobrarAntes() }
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                            .buttonStyle(PressaoDiscreta())
                            .accessibilityHint("A escada volta a 3 dias")
                    }
                }
                .padding(.horizontal, Tema.margem)
                .padding(.bottom, 24)
            }
        }
        .background(Tema.fundo.ignoresSafeArea())
        .task {
            if !modo.mostraAlvoAntesDeEscrever {
                foco = true
                return
            }
            let esperaLeitura: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(1500)
            let esperaBlur: Duration = reduceMotion ? .milliseconds(250) : .milliseconds(900)
            try? await Task.sleep(for: esperaLeitura)
            withAnimation(.easeOut(duration: reduceMotion ? 0.18 : 0.4)) { fase = .esconder }
            try? await Task.sleep(for: esperaBlur)
            withAnimation(.easeOut(duration: 0.3)) { fase = .escrever }
            foco = true
        }
    }

    private func bloco(_ titulo: String, _ corpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaSuave)
            Text(corpo)
                .font(Tema.corpo)
                .foregroundStyle(Tema.tinta)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PrimarioStyle: ButtonStyle {
    var recede: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(Tema.pressaoAnim(configuration.isPressed), value: configuration.isPressed)
            .font(Tema.barra)
            .foregroundStyle(recede ? Tema.tintaFraca : Tema.ambarTinta)
            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
            .scaleEffect(configuration.isPressed ? Tema.pressao : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
