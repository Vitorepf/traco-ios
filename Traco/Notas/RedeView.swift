import SwiftData
import SwiftUI

/// As ligações de uma nota (ADR 2026-09-03b): quem ela cita e quem cita ela.
/// O que ela cita, o autor escreveu. Quem a cita, ele não tem como ver sem isto.
struct RedeView: View {
    let nota: Nota
    let todas: [Nota]
    let sessao: Sessao
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Cruzar todas as notas contra todas as menções é trabalho de abrir a
    /// folha, não de cada avaliação de `body`.
    @State private var ligacoes: [Rede.Ligacao] = []
    /// ADR 03j: as notas que a sábia diz falarem da mesma coisa que esta, sem
    /// que nenhuma cite a outra. Vazio = nada verificado, e aí não se mostra.
    @State private var ecos: [Sabia.Eco] = []
    @State private var candidatas: [Nota] = []

    /// Quem pode ser eco: nota de verdade, não esta, não selada, e AINDA NÃO
    /// ligada — o valor está justamente no que a rede não sabe.
    private func montarCandidatas(_ jaLigadas: Set<UUID>) -> [Nota] {
        todas.filter {
            $0.uuid != nota.uuid && !$0.fechada && $0.gesto != .expressiva
                && !jaLigadas.contains($0.uuid)
                && !Caderno.prosa(de: $0.texto).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        .prefix(40)
        .map { $0 }
    }

    /// O texto EXATO que viaja por candidata — e contra o qual a citação
    /// literal é conferida. Título mais um pedaço da prosa: um índice do
    /// caderno, não o caderno.
    private func linha(_ n: Nota) -> String {
        let corpo = Caderno.prosa(de: n.texto).trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(n.tituloNaLista) :: \(corpo.prefix(240))"
    }

    private func procurarEcos() async {
        guard Politica.provedor(.ecos) != nil, ecos.isEmpty else { return }
        let jaLigadas = Set(ligacoes.filter { $0.de == nota.uuid || $0.para == nota.uuid }
            .flatMap { [$0.de, $0.para] })
        let cs = montarCandidatas(jaLigadas)
        guard !cs.isEmpty else { return }
        candidatas = cs
        let achados = await Sabia.ecos(nota: Caderno.prosa(de: nota.texto),
                                       candidatas: cs.map(linha), gesto: nota.gesto)
        withAnimation(Tema.movimento(.deslocamento, .easeOut(duration: Tema.Duracao.media), reduzido: reduceMotion)) { ecos = achados ?? [] }
    }

    private func lerLigacoes() {
        ligacoes = Rede.ligacoes(todas.map(\.paraRede))
    }

    var body: some View {
        let daqui = Rede.daqui(nota.uuid, ligacoes)
        let paraCa = Rede.paraCa(nota.uuid, ligacoes)
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ligações")
                        .font(.title2.weight(.bold))
                        .tracking(-0.4)
                    Text(nota.tituloNaLista)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .lineLimit(1)
                }
                Spacer()
                Pilula("Pronto", forma: .acao) { dismiss() }
                    .accessibilityIdentifier("rede-pronto")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if daqui.isEmpty, paraCa.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Esta nota ainda não se liga a nenhuma.")
                                .font(Tema.corpo)
                                .foregroundStyle(Tema.tintaSuave)
                            Text("Escreva [[o título de outra nota]] no texto, ou preencha “Liga a”. A ligação é sua; o app só a segue.")
                                .font(Tema.meta)
                                .foregroundStyle(Tema.tintaFraca)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("rede-vazia")
                    }
                    if !daqui.isEmpty { secao("Esta nota cita", daqui.map(\.para)) }
                    if !paraCa.isEmpty { secao("Citam esta nota", paraCa.map(\.de)) }
                    ecoSecao
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
        .task {
            lerLigacoes()
            await procurarEcos()
        }
    }

    /// O eco não é uma ligação: é um candidato COM A PROVA na cara. O trecho
    /// mostrado é literal e foi conferido contra o texto que viajou — se a
    /// sábia inventasse, o eco teria sido descartado antes de chegar aqui.
    ///
    /// E ela não escreve `[[…]]` em lugar nenhum: "a ligação é sua" continua
    /// verdade. O app passou a MOSTRAR um candidato; quem liga é o autor.
    @ViewBuilder private var ecoSecao: some View {
        if !ecos.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("TALVEZ SE LIGUEM")
                    .font(Tema.label)
                    .tracking(Tema.trackingLabel)
                    .foregroundStyle(Tema.tintaSuave)
                    .padding(.leading, 4)
                VStack(spacing: 0) {
                    ForEach(ecos, id: \.i) { eco in
                        if eco.i < candidatas.count {
                            let alvo = candidatas[eco.i]
                            Button {
                                sessao.abrir(alvo)
                                sessao.irPara(.escrever, no: context)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(alvo.tituloNaLista)
                                        .font(.callout)
                                        .foregroundStyle(Tema.tinta)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    // nota curta: o título É a primeira linha, e a
                                    // citação cobria ela inteira — saía a mesma
                                    // frase duas vezes (visto na 1ª chamada real).
                                    // A prova só aparece quando ACRESCENTA.
                                    if !Prova.normal(alvo.tituloNaLista)
                                        .contains(Prova.normal(eco.trecho)) {
                                        Text("“\(eco.trecho)”")
                                            .font(Tema.meta)
                                            .foregroundStyle(Tema.tintaSuave)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .alvo()
                            }
                            .buttonStyle(PressaoDiscreta())
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
                            }
                        }
                    }
                }
                .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
            }
            .accessibilityIdentifier("rede-ecos")
            .transition(Tema.transicao(.opacity.combined(with: .offset(y: 8)), reduzido: reduceMotion))
        } else if Politica.provedor(.ecos) == nil {
            // ADR 07b: a seção que não veio diz por quê, em vez de calar
            LinhaDeEstado(Politica.semProvedor(.ecos), .semConta)
                .padding(.leading, 4)
                .accessibilityIdentifier("rede-sem-provedor")
        }
    }

    private func secao(_ titulo: String, _ uuids: [UUID]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo.uppercased())
                .font(Tema.label)
                .tracking(Tema.trackingLabel)
                .foregroundStyle(Tema.tintaSuave)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                ForEach(uuids, id: \.self) { uuid in
                    if let alvo = todas.first(where: { $0.uuid == uuid }) {
                        Button {
                            sessao.abrir(alvo)
                            sessao.irPara(.escrever, no: context)
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                Text(alvo.tituloNaLista)
                                    .font(.callout)
                                    .foregroundStyle(Tema.tinta)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 8)
                                if let g = alvo.gesto {
                                    Text(g.nome.uppercased())
                                        .font(Tema.label)
                                        .tracking(Tema.trackingLabel)
                                        .foregroundStyle(Tema.tintaSuave)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .alvo()
                        }
                        .buttonStyle(PressaoDiscreta())
                        .overlay(alignment: .bottom) {
                            Rectangle().fill(Tema.linha).frame(height: 1).padding(.leading, 14)
                        }
                    }
                }
            }
            .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))
        }
    }
}
