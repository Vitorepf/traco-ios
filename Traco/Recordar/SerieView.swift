import SwiftData
import SwiftUI

/// R3: as quatro linhas de sentido de uma série, depois do fecho.
///
/// A ADR f promete que "no quarto fecho as quatro linhas aparecem juntas" — e
/// apareciam, naquele instante e nunca mais. O intent devolvia tudo pela Siri;
/// dentro do app não havia tela nenhuma.
///
/// O selo vale inteiro: só o SENTIDO sai, nunca o texto. É a única coisa que
/// atravessa a porta da expressiva (§8.5).
struct SerieView: View {
    let serie: UUID
    let todas: [Nota]
    @Environment(\.dismiss) private var dismiss

    private var dias: [Nota] {
        todas
            .filter { $0.serieUUID == serie && $0.gesto == .expressiva }
            .sorted { $0.diaDaSerie < $1.diaDaSerie }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("A série")
                        .font(.title2.weight(.bold))
                        .tracking(-0.4)
                    Text(dias.count == 4 ? "Quatro dias, quatro linhas."
                         : "\(dias.count) de 4 — a série continua.")
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                }
                Spacer()
                Button("Pronto") { dismiss() }
                    .font(Tema.barra)
                    .foregroundStyle(Tema.tinta)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Tema.chip, in: Capsule())
                    .accessibilityIdentifier("serie-pronto")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(dias, id: \.uuid) { nota in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text("DIA \(max(1, nota.diaDaSerie))")
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(Tema.tintaFraca)
                                Text(nota.queimada ? "queimada" : "selada")
                                    .font(Tema.label)
                                    .tracking(Tema.trackingLabel)
                                    .foregroundStyle(Tema.tintaFraca)
                                if nota.minutosEscritos >= 1 {
                                    Text("\(nota.minutosEscritos) min")
                                        .font(Tema.label)
                                        .foregroundStyle(Tema.tintaFraca)
                                }
                            }
                            // só o sentido atravessa: o texto da dor fica onde está
                            Text(nota.sentido.isEmpty ? "— sem linha —" : nota.sentido)
                                .font(Tema.corpo)
                                .foregroundStyle(nota.sentido.isEmpty ? Tema.tintaFraca : Tema.tinta)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(Tema.margem)
        .padding(.top, 8)
        .foregroundStyle(Tema.tinta)
        .background(Tema.fundo.ignoresSafeArea())
        .presentationDetents([.large]) // ADR 04u: folha de leitura nasce inteira, nunca cortada no médio
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
    }
}
