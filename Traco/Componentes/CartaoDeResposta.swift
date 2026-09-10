import SwiftUI

/// A SUPERFÍCIE DA RESPOSTA — uma só para toda operação que responde em texto
/// (`responder`, `responderNasNotas`, `contrapor`, `instigar`; DIRETRIZ §14).
///
/// O dono viu a primeira resposta real nas Notas (10/09, 13h58) e chamou a
/// tela de deplorável. O que ele viu, e que este componente existe para não
/// deixar voltar: um cabeçalho em caixa alta com jargão ("A SÁBIA, SOBRE:
/// …"), a espera sem tempo nem saída, a resposta cortada com "CONTINUA" em
/// letra grande, a mesma nota três vezes em "Foram junto:", "serviu / não
/// serviu" soltos e dois "Fechar".
///
/// A ordem de leitura é a da conversa: **a pergunta da pessoa** (o título, em
/// letra de gente — ela não pergunta a uma "sábia"), depois **o que a IA
/// diz** (o corpo, na tinta do texto), depois **de onde veio** (as notas, só
/// se ela quiser ver, tocáveis, uma vez cada), depois **serviu ou não** (um
/// controle, não dois links) — e **um** fechar, no canto, fora do caminho da
/// leitura. Enquanto a IA pensa, no lugar do corpo fica a `Espera`:
/// pensando, tempo e parar de esperar (§13 item 3).
///
/// O corpo é do chamador (`Conteudo`): nas Notas e na Página é a prosa da
/// resposta; no Contrapor são três parágrafos; no Instigar, perguntas. O
/// componente não sabe o que há dentro — só onde cada coisa fica.
///
/// **O teto, por medida.** Nas Notas o cartão sobe sobre a lista e não pode
/// cobri-la inteira (ADR 02o: a resposta chega AO LADO, nunca dentro). As 18
/// corridas de 09–10/09 mediram respostas de 203 a 568 grafemas, mediana 384;
/// em `large`, com `Tema.corpo`, cabem ~35 grafemas por linha de ~25 pt, então
/// **o teto de 360 pt guarda ~500 grafemas inteiros** — a mediana cabe com
/// folga, e só a cauda longa (568) rola. O teto antigo, de 220 pt, cortava
/// ~330 grafemas: a mediana já transbordava, e a palavra "continua" virava a
/// primeira coisa que o olho lia. A palavra saiu; a dobra (`SinalDeSobra`)
/// fica, sem letra, e a árvore de AX continua a enxergá-la.
struct CartaoDeResposta<Conteudo: View>: View {
    /// Uma nota que foi junto. `id` nil onde a rota só tem o título (a Página).
    struct Fonte: Identifiable {
        var id: UUID?
        var titulo: String
    }

    /// A pergunta da pessoa, ou o que ela pediu. Em letra normal, sempre.
    let titulo: String
    /// Enquanto houver hora, o corpo dá lugar à espera.
    var pensandoDesde: Date? = nil
    var cancelar: (() -> Void)? = nil
    var fontes: [Fonte] = []
    /// A linha fechada das fontes; nil monta "leu N notas suas".
    var resumoDasFontes: String? = nil
    var abrirFonte: ((UUID) -> Void)? = nil
    /// Nil: sem controle de retorno (já avaliada, ou a rota não avalia).
    var retorno: ((Bool) -> Void)? = nil
    var avaliada = false
    /// Nil: o cartão não se fecha por aqui (a Lente, onde a seção fica).
    var fechar: (() -> Void)? = nil
    /// Com teto, o corpo rola dentro dele e a dobra avisa o que sobra.
    var teto: CGFloat? = nil
    /// Prefixo dos identificadores de AX: `resposta-<rota>`, `sobra-<rota>`,
    /// `<rota>-pensando`.
    let rota: String
    @ViewBuilder let conteudo: () -> Conteudo
    @State private var mostrarFontes = false

    /// "leu 1 nota sua" / "leu 3 notas suas" — fora do `body` para ter teste.
    static func resumo(_ quantas: Int) -> String {
        quantas == 1 ? "leu 1 nota sua" : "leu \(quantas) notas suas"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cabecalho
            if let pensandoDesde {
                Espera(frase: Espera.aSabiaPensa, desde: pensandoDesde,
                       identificador: "\(rota)-pensando", cancelar: cancelar)
            } else {
                corpo
                if !fontes.isEmpty { fontesQueForamJunto }
                if let retorno { ControleDeRetorno(retorno) }
                else if avaliada {
                    Text("anotado.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaFraca)
                        .accessibilityIdentifier("retorno-anotado")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// A pergunta em `chrome` e tinta suave: é o contexto, e o que a IA diz é
    /// o assunto (o corpo, maior e em tinta). O fechar divide a linha com ela
    /// — um só, no canto, alvo de 44.
    private var cabecalho: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(titulo)
                .font(Tema.chrome)
                .foregroundStyle(Tema.tintaSuave)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("pergunta-\(rota)")
            if let fechar {
                Button("Fechar", action: fechar)
                    .font(Tema.meta)
                    .foregroundStyle(Tema.tintaSuave)
                    .alvo(folgaH: 8)
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier("fechar-resposta")
            }
        }
    }

    @ViewBuilder private var corpo: some View {
        let texto = conteudo()
            .font(Tema.corpo)
            .foregroundStyle(Tema.tinta)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("resposta-\(rota)")
        if let teto {
            ScrollView { texto }
                .frame(maxHeight: teto)
                .sinalDeSobra("sobra-\(rota)")
                .fixedSize(horizontal: false, vertical: true)
        } else {
            texto
        }
    }

    /// Fechada: uma linha que diz quantas. Aberta: os títulos, um por linha,
    /// tocáveis quando a rota sabe abrir a nota. A pessoa vê se quiser.
    private var fontesQueForamJunto: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                mostrarFontes.toggle()
            } label: {
                HStack(spacing: 6) {
                    Text(resumoDasFontes ?? Self.resumo(fontes.count))
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .rotationEffect(.degrees(mostrarFontes ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaSuave)
                .alvo()
            }
            .buttonStyle(.discreto)
            .accessibilityIdentifier("fontes-\(rota)")
            .accessibilityHint(mostrarFontes ? "Recolhe as notas" : "Mostra quais notas foram junto")
            if mostrarFontes {
                ForEach(Array(fontes.enumerated()), id: \.offset) { _, fonte in
                    if let id = fonte.id, let abrirFonte {
                        Button(fonte.titulo) { abrirFonte(id) }
                            .font(Tema.meta)
                            .foregroundStyle(Tema.ambarTinta)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .alvo()
                            .buttonStyle(.discreto)
                    } else {
                        Text(fonte.titulo)
                            .font(Tema.meta)
                            .foregroundStyle(Tema.tintaSuave)
                            .lineLimit(2)
                            .alvo()
                    }
                }
                .accessibilityIdentifier("fonte-\(rota)")
            }
        }
    }
}

/// "serviu / não serviu" como CONTROLE: as duas saídas num campo só, separadas
/// por um fio, cada uma com alvo de 44. Eram dois links soltos em cinza, sem
/// borda e sem relação visível entre si (§14). A cor é a do texto de apoio: o
/// retorno é opcional, e a resposta acima é o que importa.
struct ControleDeRetorno: View {
    let responder: (Bool) -> Void

    init(_ responder: @escaping (Bool) -> Void) { self.responder = responder }

    var body: some View {
        HStack(spacing: 0) {
            Button("serviu") { responder(true) }
                .accessibilityIdentifier("serviu")
            Rectangle().fill(Tema.linha).frame(width: 1, height: 20)
            Button("não serviu") { responder(false) }
                .accessibilityIdentifier("nao-serviu")
        }
        .font(Tema.meta)
        .foregroundStyle(Tema.tintaSuave)
        .buttonStyle(.compacto)
        .padding(.horizontal, 4)
        .cartao(.campo, recuo: [])
        .fixedSize()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Esta resposta serviu?")
    }
}

#Preview("resposta inteira, fontes e retorno") {
    CartaoDeResposta(
        titulo: "Quanto vou gastar em reais com hospedagem e transporte na viagem?",
        fontes: [.init(id: UUID(), titulo: "Reservei R$ 6000 para a viagem"),
                 .init(id: UUID(), titulo: "Câmbio de hoje")],
        abrirFonte: { _ in }, retorno: { _ in }, fechar: {}, teto: 360, rota: "preview"
    ) {
        Text("Com a cotação que o banco te cobrou hoje (R$ 6,45 por euro), hospedagem 400 € + transporte 120 € = 520 €. Em reais: 520 × 6,45 = R$ 3.354. Você reservou R$ 6.000; sobram R$ 2.646 para o restante.")
            .textSelection(.enabled)
    }
    .cartao(.papel)
    .padding()
    .background(Tema.fundo)
}

#Preview("pensando, com tempo e saída") {
    CartaoDeResposta(titulo: "Como uso o Traço?", pensandoDesde: .now.addingTimeInterval(-12),
                     cancelar: {}, fechar: {}, rota: "preview") { Text("") }
        .cartao(.papel)
        .padding()
        .background(Tema.fundo)
}

#Preview("já avaliada, sem fontes") {
    CartaoDeResposta(titulo: "O que falta no plano?", avaliada: true, fechar: {}, rota: "preview") {
        Text("Falta dizer QUANDO: o plano tem o quê e o como, e nenhuma data.")
    }
    .cartao(.papel)
    .padding()
    .background(Tema.fundo)
}
