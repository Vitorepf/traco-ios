import SwiftData
import SwiftUI

/// A nota viva (proposta de 16/09, telas 1 e 3; dono: "no final de um ano vou
/// ter inúmeras notas de compras… se ela se atualizar ou criar versões, mantém
/// os dados"). Notas parecidas andam juntas e aparecem como UMA, com versões.
///
/// Juntar não toca no store: cada nota continua inteira, com texto, data e
/// origem dela. Aqui fica só quem anda com quem, num arquivo ao lado das
/// versões de edição — separar devolve tudo exatamente como era. A IA não
/// escreve nada: quem junta é o autor, pelo toque longo.
nonisolated enum Juntas {
    nonisolated(unsafe) static var url: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Traço/juntas.json")

    /// nota → grupo. Em memória depois da primeira leitura.
    nonisolated(unsafe) private static var cache: [UUID: UUID]?

    nonisolated static func mapa() -> [UUID: UUID] {
        if let cache { return cache }
        let lido = (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode([UUID: UUID].self, from: $0) } ?? [:]
        cache = lido
        return lido
    }

    nonisolated static func grupo(de uuid: UUID) -> UUID? { mapa()[uuid] }

    nonisolated static func membros(de uuid: UUID) -> [UUID] {
        guard let g = grupo(de: uuid) else { return [uuid] }
        return mapa().filter { $0.value == g }.map(\.key)
    }

    /// Selada, expressiva e obra nunca entram: o selo e a origem valem inteiros.
    nonisolated static func podeJuntar(fechada: Bool, gesto: Gesto?, obra: Bool) -> Bool {
        !fechada && gesto != .expressiva && !obra
    }

    /// `outra` passa a andar com `nota` (e com quem já andava com qualquer das duas).
    @discardableResult
    nonisolated static func juntar(_ nota: UUID, com outra: UUID) -> Bool {
        guard nota != outra else { return false }
        var m = mapa()
        let g = m[nota] ?? m[outra] ?? UUID()
        let antigo = m[outra]
        m[nota] = g
        m[outra] = g
        if let antigo, antigo != g { for (k, v) in m where v == antigo { m[k] = g } }
        return gravar(m)
    }

    /// A nota volta a ser sozinha; um grupo de um só deixa de existir.
    @discardableResult
    nonisolated static func separar(_ uuid: UUID) -> Bool {
        var m = mapa()
        guard let g = m.removeValue(forKey: uuid) else { return false }
        let restantes = m.filter { $0.value == g }.map(\.key)
        if restantes.count == 1 { m.removeValue(forKey: restantes[0]) }
        return gravar(m)
    }

    /// Devolve o mapa de antes (o «Desfazer»).
    @discardableResult
    nonisolated static func restaurar(_ antes: [UUID: UUID]) -> Bool { gravar(antes) }

    nonisolated private static func gravar(_ m: [UUID: UUID]) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(m).write(to: url, options: .atomic)
            cache = m
            return true
        } catch {
            return false
        }
    }

    /// Para os testes: esquece o que leu.
    nonisolated static func esquecerCache() { cache = nil }

    // MARK: - O que mudou de uma versão para outra

    /// Linha a linha, sem marcador de lista: «+ detergente», «− leite». É
    /// comparação de palavras do autor, não texto gerado.
    nonisolated static func diferenca(de antes: String, para depois: String) -> (entrou: [String], saiu: [String]) {
        func itens(_ t: String) -> [String] {
            t.split(whereSeparator: \.isNewline)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .map { l in
                    var s = Substring(l)
                    while let c = s.first, "-*•·–—[]x ".contains(c) { s = s.dropFirst() }
                    return String(s).trimmingCharacters(in: .whitespaces)
                }
                .filter { !$0.isEmpty }
        }
        let chave = { (s: String) in s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
        let a = itens(antes), b = itens(depois)
        let ca = Set(a.map(chave)), cb = Set(b.map(chave))
        return (b.filter { !ca.contains(chave($0)) }, a.filter { !cb.contains(chave($0)) })
    }

    // MARK: - Quem se parece com quem

    /// As candidatas a juntar, da mais parecida para a menos: palavras do título
    /// em comum pesam mais que as do começo do texto; a mesma forma soma. Sem
    /// modelo — é a lista que o autor percorre, não uma decisão.
    nonisolated static func parecidas(com titulo: String, texto: String, gesto: Gesto?,
                                      candidatas: [(uuid: UUID, titulo: String, texto: String, gesto: Gesto?, data: Date)]) -> [UUID] {
        func palavras(_ s: String) -> Set<String> {
            Set(s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
                .split { !$0.isLetter && !$0.isNumber }
                .map(String.init)
                .filter { $0.count >= 3 })
        }
        let t = palavras(titulo)
        let c = palavras(String(texto.prefix(400)))
        var pontuadas: [(uuid: UUID, pontos: Int, data: Date)] = []
        for k in candidatas {
            let doTitulo: Int = palavras(k.titulo).intersection(t).count * 3
            let doTexto: Int = palavras(String(k.texto.prefix(400))).intersection(c).count
            let daForma: Int = (gesto != nil && k.gesto == gesto) ? 2 : 0
            pontuadas.append((k.uuid, doTitulo + doTexto + daForma, k.data))
        }
        pontuadas.sort { $0.pontos != $1.pontos ? $0.pontos > $1.pontos : $0.data > $1.data }
        return pontuadas.map(\.uuid)
    }
}

/// A folha «Juntar com»: as notas mais parecidas primeiro, um toque junta.
struct JuntarView: View {
    let nota: Nota
    let todas: [Nota]
    let juntou: (Nota) -> Void
    @Environment(\.dismiss) private var dismiss

    private var candidatas: [Nota] {
        let jaJuntas = Set(Juntas.membros(de: nota.uuid))
        let pool = todas.filter {
            !jaJuntas.contains($0.uuid)
                && Juntas.podeJuntar(fechada: $0.fechada, gesto: $0.gesto, obra: $0.origem.eObra)
        }
        let ordem = Juntas.parecidas(
            com: nota.tituloNaLista, texto: nota.textoDeQualquerOrigem, gesto: nota.gesto,
            candidatas: pool.map { ($0.uuid, $0.tituloNaLista, $0.textoDeQualquerOrigem, $0.gesto, $0.criadaEm) })
        let porId = Dictionary(uniqueKeysWithValues: pool.map { ($0.uuid, $0) })
        return ordem.prefix(30).compactMap { porId[$0] }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Juntar com")
                        .font(.title2.weight(.bold))
                        .tracking(-0.4)
                    Text(nota.tituloNaLista)
                        .font(Tema.meta)
                        .foregroundStyle(Tema.tintaSuave)
                        .lineLimit(1)
                }
                Spacer()
                Pilula("Pronto", forma: .acao) { dismiss() }
                    .accessibilityIdentifier("juntar-pronto")
            }

            Text("A nota escolhida vira uma versão desta. Nada se apaga, e dá para separar de novo.")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaFraca)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                LazyVStack(spacing: Tema.entreCartoes) {
                    ForEach(candidatas, id: \.uuid) { outra in
                        Button {
                            Toque.selecao()
                            juntou(outra)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(outra.tituloNaLista)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Tema.tinta)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Text(outra.criadaEm.formatted(.dateTime.day().month(.wide)))
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(Tema.tintaFraca)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .cartao()
                        }
                        .buttonStyle(PressaoDeCartao())
                        .accessibilityHint("Junta como versão desta nota")
                    }
                }
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(Tema.margem)
        .padding(.top, 8)
        .foregroundStyle(Tema.tinta)
        .background(Tema.fundo.ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Tema.fundo)
    }
}

/// Tela 3: a fileira de datas das versões, abaixo do topo da página, e o que
/// mudou desde a versão anterior. Tocar numa data abre aquela versão.
struct VersoesDaNotaViva: View {
    let atual: Nota
    let membros: [Nota]
    let abrir: (Nota) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ordenados: [Nota] { membros.sorted { $0.criadaEm > $1.criadaEm } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(ordenados, id: \.uuid) { v in
                        let esta = v.uuid == atual.uuid
                        Button {
                            guard !esta else { return }
                            Toque.selecao()
                            abrir(v)
                        } label: {
                            Text(rotulo(v.criadaEm))
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                                .foregroundStyle(esta ? .white : Tema.tinta)
                                .padding(.horizontal, 12)
                                .frame(height: 32)
                                .background(esta ? Tema.chipAtivo : Tema.chip,
                                            in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                                .frame(minHeight: Tema.alvo)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.discreto)
                        .accessibilityLabel("Versão de " + v.criadaEm.formatted(.dateTime.day().month(.wide)))
                        .accessibilityAddTraits(esta ? .isSelected : [])
                    }
                }
                .padding(.horizontal, Tema.margem)
            }
            .scrollIndicators(.hidden)

            if let linha = oQueMudou {
                linha
                    .font(Tema.meta)
                    .padding(.horizontal, Tema.margem)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("nota-viva-mudou")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("nota-viva-versoes")
    }

    private func rotulo(_ d: Date) -> String {
        if Calendar.current.isDateInToday(d) { return "Hoje" }
        // «10 set», sem o «de» e sem o ponto da abreviatura
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate(Calendar.current.isDate(d, equalTo: .now, toGranularity: .year) ? "dMMM" : "dMMMyy")
        return f.string(from: d).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " de ", with: " ")
    }

    /// «Desde 10 de setembro: + detergente · − leite». Só entre esta versão e a
    /// anterior a ela; nada quando as duas dizem o mesmo.
    private var oQueMudou: Text? {
        guard let i = ordenados.firstIndex(where: { $0.uuid == atual.uuid }), i + 1 < ordenados.count else { return nil }
        let anterior = ordenados[i + 1]
        let d = Juntas.diferenca(de: anterior.textoDeQualquerOrigem, para: atual.textoDeQualquerOrigem)
        guard !d.entrou.isEmpty || !d.saiu.isEmpty else { return nil }
        let partes = d.entrou.prefix(4).map { "+ " + $0 } + d.saiu.prefix(4).map { "− " + $0 }
        return Text("Desde " + anterior.criadaEm.formatted(.dateTime.day().month(.wide)) + ": ").foregroundStyle(Tema.tintaSuave)
            + Text(partes.joined(separator: " · ")).foregroundStyle(Tema.tinta)
    }
}
