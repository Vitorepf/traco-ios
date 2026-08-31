import AVFoundation
import AVKit
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

struct SinalTipo: View {
    let nome: String

    var body: some View {
        Text(nome.uppercased())
            .font(Tema.label)
            .tracking(1.2)
            .foregroundStyle(Tema.tintaFraca)
    }
}

struct PortalArquivoView: View {
    let bloco: BlocoCaderno
    var aoEditar: () -> Void = {}

    var body: some View {
        switch bloco {
        case .imagem(let id, let alt):
            portalImagem(id, alt)
        case .audio(let id, let nome):
            portalAudio(id, nome)
        case .video(let id, let nome):
            portalVideo(id, nome)
        case .arquivo(let id, let nome):
            if (nome as NSString).pathExtension.lowercased() == "pdf" {
                portalPDF(id, nome)
            } else {
                portalFicheiro(id, nome)
            }
        default:
            EmptyView()
        }
    }

    private func portalImagem(_ id: String, _ alt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "imagem")
                .onTapGesture(perform: aoEditar)
            if let data = AnexoDisco.dados(id, nome: alt), let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }
                    .onTapGesture(perform: aoEditar)
            } else {
                falta(alt.isEmpty ? "imagem em falta" : alt)
                    .onTapGesture(perform: aoEditar)
            }
            if !alt.isEmpty {
                Text(alt)
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaFraca)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Portal de imagem, \(alt)")
        .accessibilityHint("Imagem desta nota")
        .accessibilityIdentifier("portal-imagem")
    }

    private func portalAudio(_ id: String, _ nome: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SinalTipo(nome: "áudio")
            HStack(alignment: .center, spacing: 12) {
                onda
                VStack(alignment: .leading, spacing: 2) {
                    Text(nome)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .lineLimit(2)
                    Text(AnexoDisco.tamanho(id, nome: nome))
                        .font(Tema.label)
                        .foregroundStyle(Tema.tintaFraca)
                }
                Spacer(minLength: 8)
                PlayerAnexo(url: AnexoDisco.url(id, nome: nome))
            }
        }
        .padding(14)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                .strokeBorder(Tema.linha, lineWidth: 1)
        }
        .overlay(alignment: .leading) { trilho }
        .contentShape(Rectangle())
        .onTapGesture(perform: aoEditar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Portal de áudio, \(nome)")
        .accessibilityIdentifier("portal-audio")
    }

    private func portalVideo(_ id: String, _ nome: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "vídeo")
                .onTapGesture(perform: aoEditar)
            PlayerVideo(url: AnexoDisco.url(id, nome: nome))
            HStack {
                Text(nome)
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaSuave)
                    .lineLimit(1)
                Spacer()
                Text(AnexoDisco.tamanho(id, nome: nome))
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaFraca)
            }
            .onTapGesture(perform: aoEditar)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Portal de vídeo, \(nome)")
        .accessibilityIdentifier("portal-video")
    }

    private func portalPDF(_ id: String, _ nome: String) -> some View {
        let url = AnexoDisco.url(id, nome: nome)
        return VStack(alignment: .leading, spacing: 8) {
            SinalTipo(nome: "pdf")
            if let pagina = PDFDocument(url: url)?.page(at: 0) {
                let caixa = pagina.bounds(for: .mediaBox)
                let largura: CGFloat = 640
                let altura = caixa.height == 0 ? largura : largura * (caixa.height / max(caixa.width, 1))
                Image(uiImage: pagina.thumbnail(of: CGSize(width: largura, height: altura), for: .mediaBox))
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }
            } else {
                Text(nome)
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tintaSuave)
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            }
            HStack {
                Text(nome)
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaSuave)
                    .lineLimit(1)
                Spacer()
                Text(AnexoDisco.tamanho(id, nome: nome))
                    .font(Tema.label)
                    .foregroundStyle(Tema.tintaFraca)
                ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Tema.tintaSuave)
                        .frame(width: Tema.alvo, height: Tema.alvo)
                }
                .accessibilityLabel("Partilhar PDF")
            }
        }
        .padding(14)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                .strokeBorder(Tema.linha, lineWidth: 1)
        }
        .overlay(alignment: .leading) { trilho }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Portal de PDF, \(nome)")
        .accessibilityIdentifier("portal-pdf")
    }

    private func portalFicheiro(_ id: String, _ nome: String) -> some View {
        let ext = (nome as NSString).pathExtension.uppercased()
        return VStack(alignment: .leading, spacing: 10) {
            SinalTipo(nome: ext.isEmpty ? "arquivo" : ext)
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Tema.superficieAlta)
                        .frame(width: 40, height: 52)
                    Text(ext.isEmpty ? "DOC" : String(ext.prefix(4)))
                        .font(Tema.label.monospaced())
                        .foregroundStyle(Tema.tintaSuave)
                        .minimumScaleFactor(0.7)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(nome)
                        .font(Tema.corpo)
                        .foregroundStyle(Tema.tinta)
                        .lineLimit(2)
                    Text(AnexoDisco.tamanho(id, nome: nome))
                        .font(Tema.label)
                        .foregroundStyle(Tema.tintaFraca)
                }
                Spacer(minLength: 8)
                ShareLink(item: AnexoDisco.url(id, nome: nome)) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Tema.tintaSuave)
                        .frame(width: Tema.alvo, height: Tema.alvo)
                }
                .accessibilityLabel("Partilhar arquivo")
            }
        }
        .padding(14)
        .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                .strokeBorder(Tema.linha, lineWidth: 1)
        }
        .overlay(alignment: .leading) { trilho }
        .contentShape(Rectangle())
        .onTapGesture(perform: aoEditar)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Portal de arquivo, \(nome)")
        .accessibilityIdentifier("portal-arquivo")
    }

    private var trilho: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: Tema.raio,
            bottomLeadingRadius: Tema.raio,
            bottomTrailingRadius: 1,
            topTrailingRadius: 1,
            style: .continuous
        )
        .fill(Tema.linha)
        .frame(width: 3)
        .padding(.vertical, 10)
    }

    private var onda: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(Array([8, 14, 10, 18, 12, 22, 16, 9, 20, 14, 8, 16, 24, 12, 18, 10, 15, 21, 11, 8].enumerated()), id: \.offset) { _, h in
                Capsule()
                    .fill(Tema.tintaFraca.opacity(0.55))
                    .frame(width: 2, height: CGFloat(h))
            }
        }
        .frame(width: 72, height: 28)
        .accessibilityHidden(true)
    }

    private func falta(_ nome: String) -> some View {
        Text(nome)
            .font(Tema.corpo)
            .foregroundStyle(Tema.tintaSuave)
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
            .padding(14)
            .background(Tema.superficie, in: RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
    }
}

private struct PlayerAnexo: View {
    let url: URL
    @State private var player: AVAudioPlayer?
    @State private var toca = false

    var body: some View {
        Button {
            if toca {
                player?.stop()
                toca = false
            } else {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
                player = try? AVAudioPlayer(contentsOf: url)
                player?.play()
                toca = true
            }
        } label: {
            Image(systemName: toca ? "pause.fill" : "play.fill")
                .foregroundStyle(Tema.tinta)
                .frame(width: Tema.alvo, height: Tema.alvo)
        }
        .buttonStyle(PressaoDiscreta())
        .accessibilityLabel(toca ? "Pausar" : "Tocar")
    }
}

private struct PlayerVideo: View {
    let url: URL
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Tema.raio, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Tema.raio, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            }
            .onAppear {
                if player == nil { player = AVPlayer(url: url) }
            }
            .onDisappear {
                player?.pause()
            }
    }
}
