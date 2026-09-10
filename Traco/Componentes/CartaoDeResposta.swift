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
/// controle, não dois links). O fechar, quando a rota o tem, fica no canto,
/// fora do caminho da leitura.
///
/// Os TRÊS estados da IA cabem aqui, sob a mesma pergunta (§15): enquanto
/// pensa, o corpo é a `Espera` (pensando, tempo, parar de esperar); quando não
/// respondeu, o corpo é a falha **com a recuperação ao lado** — um toque
/// pergunta de novo; quando respondeu, o corpo é do chamador (`Conteudo`):
/// nas Notas e na Página é a prosa; no Contrapor, três parágrafos; no
/// Instigar, perguntas. O componente não sabe o que há dentro — só onde cada
/// coisa fica.
///
/// Sem teto de altura: a resposta é uma folha do Traço e se lê inteira (§15,
/// "resposta inteira, sem a palavra CONTINUA na dobra"). O teto de 220/360 pt
/// existia porque o cartão flutuava sobre a lista; a folha não flutua sobre
/// nada, e a dobra saiu com ele.
struct CartaoDeResposta<Conteudo: View>: View {
    /// Uma nota que foi junto. `id` nil onde a rota só tem o título (a Página).
    struct Fonte: Identifiable {
        var id: UUID?
        var titulo: String
    }

    /// A pergunta da pessoa, ou o que ela pediu. Em letra normal, sempre.
    /// Nil na conversa das Notas: lá a pergunta é a mensagem de VOCÊ, acima,
    /// e este cartão é só o que a SÁBIA diz (REFERENCIA-HERMES §6).
    let titulo: String?
    /// Enquanto houver hora, o corpo dá lugar à espera.
    var pensandoDesde: Date? = nil
    var cancelar: (() -> Void)? = nil
    /// A frase da falha, na língua de quem lê; com ela, o corpo é a falha e a
    /// recuperação (`repetir`), nunca a resposta.
    var falhou: String? = nil
    var repetir: (() -> Void)? = nil
    var rotuloDoRepetir = "Perguntar de novo"
    var fontes: [Fonte] = []
    /// A linha fechada das fontes; nil monta "leu N notas suas".
    var resumoDasFontes: String? = nil
    var abrirFonte: ((UUID) -> Void)? = nil
    /// Nil: sem controle de retorno (já avaliada, ou a rota não avalia).
    var retorno: ((Bool) -> Void)? = nil
    var avaliada = false
    /// Nil: o cartão não se fecha por aqui (a Lente, onde a seção fica; as
    /// Notas, onde o fechar é da folha inteira).
    var fechar: (() -> Void)? = nil
    /// Prefixo dos identificadores de AX: `pergunta-<rota>`, `resposta-<rota>`,
    /// `<rota>-pensando`, `<rota>-falhou`, `repetir-<rota>`, `fontes-<rota>`.
    let rota: String
    @ViewBuilder let conteudo: () -> Conteudo
    @State private var mostrarFontes = false

    /// "leu 1 nota sua" / "leu 3 notas suas" — fora do `body` para ter teste.
    static func resumo(_ quantas: Int) -> String {
        quantas == 1 ? "leu 1 nota sua" : "leu \(quantas) notas suas"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let titulo { cabecalho(titulo) }
            if let pensandoDesde {
                Espera(frase: Espera.aSabiaPensa, desde: pensandoDesde,
                       identificador: "\(rota)-pensando", cancelar: cancelar)
            } else if let falhou {
                LinhaDeEstado(falhou, .falhou)
                    .accessibilityIdentifier("\(rota)-falhou")
                if let repetir {
                    Button(rotuloDoRepetir, action: repetir)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.ambarTinta)
                        .alvo()
                        .buttonStyle(.discreto)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("repetir-\(rota)")
                }
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
    private func cabecalho(_ titulo: String) -> some View {
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

    private var corpo: some View {
        conteudo()
            .font(Tema.corpo)
            .foregroundStyle(Tema.tinta)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("resposta-\(rota)")
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
/// borda e sem relação visível entre si (§14). A cor E O PESO são os do texto
/// de apoio (`meta`): o retorno é opcional, e a resposta acima é o que importa.
/// O G4 apanhou `.compacto` pondo `Tema.barra` no rótulo — "serviu | não
/// serviu" saía maior e mais pesado que "leu 4 notas suas", e o peso desmentia
/// a frase acima. Por isso `.discreto` com `alvo()` em cada saída, como o
/// "repetir" e a linha das fontes deste mesmo arquivo.
struct ControleDeRetorno: View {
    let responder: (Bool) -> Void

    init(_ responder: @escaping (Bool) -> Void) { self.responder = responder }

    var body: some View {
        // o fio precisa de ar dos dois lados: colado, "serviu|não serviu" lia
        // como uma palavra só (visto na captura do aparelho da conta, 15h40)
        HStack(spacing: 10) {
            Button("serviu") { responder(true) }
                .alvo()
                .accessibilityIdentifier("serviu")
            Rectangle().fill(Tema.tintaMorta).frame(width: 1, height: 18)
            Button("não serviu") { responder(false) }
                .alvo()
                .accessibilityIdentifier("nao-serviu")
        }
        .font(Tema.meta)
        .foregroundStyle(Tema.tintaSuave)
        .buttonStyle(.discreto)
        .padding(.horizontal, 10)
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
        abrirFonte: { _ in }, retorno: { _ in }, rota: "preview"
    ) {
        Text("Com a cotação que o banco te cobrou hoje (R$ 6,45 por euro), hospedagem 400 € + transporte 120 € = 520 €. Em reais: 520 × 6,45 = R$ 3.354. Você reservou R$ 6.000; sobram R$ 2.646 para o restante.")
            .textSelection(.enabled)
    }
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

#Preview("não respondeu, e a saída ao lado") {
    CartaoDeResposta(titulo: "O que falta no plano?", falhou: "a sábia não respondeu.", repetir: {}, rota: "preview") { Text("") }
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
