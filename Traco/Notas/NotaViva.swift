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

    /// O que a lista e a página precisam saber de cada nota — sem SwiftData,
    /// para as regras terem teste.
    nonisolated struct Ficha: Sendable, Equatable {
        var uuid: UUID
        var criadaEm: Date
        var podeJuntar: Bool
    }

    /// Quantas versões cada nota tem, contando só as que EXISTEM e PODEM andar
    /// juntas. Uma nota que ficou selada, expressiva ou obra depois de juntada
    /// sai da conta (revisão de 16/09: o «Desde…» mostrava texto trancado) e
    /// volta a aparecer sozinha. Nota fora de grupo não entra no dicionário.
    nonisolated static func contagens(_ mapa: [UUID: UUID], _ fichas: [Ficha]) -> [UUID: Int] {
        var porGrupo: [UUID: Int] = [:]
        for f in fichas where f.podeJuntar {
            if let g = mapa[f.uuid] { porGrupo[g, default: 0] += 1 }
        }
        var saida: [UUID: Int] = [:]
        for f in fichas where f.podeJuntar {
            if let g = mapa[f.uuid], let n = porGrupo[g], n > 1 { saida[f.uuid] = n }
        }
        return saida
    }

    /// A lista com cada grupo uma vez só, pela versão mais nova que está à
    /// vista; a ordem de chegada é mantida. Nota selada nunca esconde outra.
    nonisolated static func recolher(_ lista: [Ficha], mapa: [UUID: UUID], contagens: [UUID: Int]) -> [UUID] {
        var maisNova: [UUID: Ficha] = [:]
        for f in lista where contagens[f.uuid] != nil {
            guard let g = mapa[f.uuid] else { continue }
            if let atual = maisNova[g], atual.criadaEm >= f.criadaEm { continue }
            maisNova[g] = f
        }
        var vistos: Set<UUID> = []
        return lista.compactMap { f in
            guard contagens[f.uuid] != nil, let g = mapa[f.uuid] else { return f.uuid }
            guard maisNova[g]?.uuid == f.uuid, vistos.insert(g).inserted else { return nil }
            return f.uuid
        }
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
                // só UM marcador inteiro sai: «xícara» não perde o x
                .map { $0.replacing(/^(?:[-*•·–—]|\[[ xX]?\])\s*/, with: "").trimmingCharacters(in: .whitespaces) }
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
        pontuadas(com: titulo, texto: texto, gesto: gesto, candidatas: candidatas).map(\.uuid)
    }

    /// As mesmas candidatas com os pontos: 0 = nada em comum.
    nonisolated static func pontuadas(com titulo: String, texto: String, gesto: Gesto?,
                                      candidatas: [(uuid: UUID, titulo: String, texto: String, gesto: Gesto?, data: Date)]) -> [(uuid: UUID, pontos: Int)] {
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
        return pontuadas.map { ($0.uuid, $0.pontos) }
    }
}

/// A folha «Juntar com»: as notas mais parecidas primeiro, um toque junta.
struct JuntarView: View {
    let nota: Nota
    let todas: [Nota]
    let juntou: (Nota) -> Void
    /// A mesma folha escolhe a nota para LIGAR (Notas ligadas): muda o título,
    /// a frase e quem fica de fora (só ela mesma, não as versões).
    var paraLigar = false
    @Environment(\.dismiss) private var dismiss
    /// Achar a nota certa num caderno grande (auditoria 17/09: sem busca).
    @State private var filtro = ""

    /// As parecidas primeiro, separadas das outras: misturadas, a lista não
    /// dizia quais tinham algo em comum com esta.
    private var candidatas: (parecidas: [Nota], outras: [Nota]) {
        let jaJuntas: Set<UUID> = paraLigar ? [nota.uuid] : Set(Juntas.membros(de: nota.uuid))
        let termo = filtro.trimmingCharacters(in: .whitespaces)
        let pool = todas.filter {
            !jaJuntas.contains($0.uuid)
                && Juntas.podeJuntar(fechada: $0.fechada, gesto: $0.gesto, obra: $0.origem.eObra)
                && (termo.isEmpty || $0.textoDeQualquerOrigem.localizedStandardContains(termo))
        }
        let ordem = Juntas.pontuadas(
            com: nota.tituloNaLista, texto: nota.textoDeQualquerOrigem, gesto: nota.gesto,
            candidatas: pool.map { ($0.uuid, $0.tituloNaLista, $0.textoDeQualquerOrigem, $0.gesto, $0.criadaEm) })
        let porId = Dictionary(pool.map { ($0.uuid, $0) }, uniquingKeysWith: { a, _ in a })
        let limite = ordem.prefix(40)
        return (limite.filter { $0.pontos > 0 }.compactMap { porId[$0.uuid] },
                limite.filter { $0.pontos == 0 }.compactMap { porId[$0.uuid] })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(paraLigar ? "Ligar a" : "Juntar com")
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

            Text(paraLigar
                 ? "O título da nota escolhida entra no fim desta, entre [[ ]], e as duas passam a se ligar."
                 : "A nota escolhida vira uma versão desta. Nada se apaga, e dá para separar de novo.")
                .font(Tema.meta)
                .foregroundStyle(Tema.tintaFraca)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Tema.tintaFraca)
                    .accessibilityHidden(true)
                TextField("", text: $filtro, prompt: Text("Buscar nas notas").foregroundStyle(Tema.tintaFraca))
                    .font(Tema.corpo)
                    .foregroundStyle(Tema.tinta)
                    .tint(Tema.ambar)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .accessibilityIdentifier("juntar-buscar")
                if !filtro.isEmpty {
                    Button { filtro = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Tema.tintaFraca)
                    }
                    .buttonStyle(.discreto)
                    .accessibilityLabel("Limpar")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Tema.superficieBaixa, in: RoundedRectangle(cornerRadius: Tema.Raio.campo, style: .continuous))

            ScrollView {
                let c = candidatas
                LazyVStack(alignment: .leading, spacing: Tema.entreCartoes) {
                    if !c.parecidas.isEmpty { cabecalho("Parecidas") }
                    ForEach(c.parecidas, id: \.uuid) { linha($0) }
                    if !c.outras.isEmpty { cabecalho("Outras notas").padding(.top, c.parecidas.isEmpty ? 0 : 12) }
                    ForEach(c.outras, id: \.uuid) { linha($0) }
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

    private func cabecalho(_ titulo: String) -> some View {
        Text(titulo)
            .font(Tema.meta.weight(.semibold))
            .foregroundStyle(Tema.tintaSuave)
            .accessibilityAddTraits(.isHeader)
    }

    private func linha(_ outra: Nota) -> some View {
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
                // uma linha do texto: duas «Compras» só com título e data eram iguais
                let previa = outra.textoDeQualquerOrigem
                    .split(whereSeparator: \.isNewline)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty && $0 != outra.tituloNaLista }
                    .prefix(4).joined(separator: ", ")
                if !previa.isEmpty {
                    Text(previa)
                        .font(.subheadline)
                        .foregroundStyle(Tema.tintaSuave)
                        .lineLimit(1)
                }
                // a mesma data do cartão das Notas: hora hoje, dia nos outros
                Text(Calendar.current.isDateInToday(outra.criadaEm)
                     ? outra.criadaEm.formatted(date: .omitted, time: .shortened)
                     : outra.criadaEm.formatted(.dateTime.day().month(.wide)))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Tema.tintaFraca)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .cartao()
        }
        .buttonStyle(PressaoDeCartao())
        .accessibilityHint(paraLigar ? "Liga esta nota à escolhida" : "Junta como versão desta nota")
    }
}

/// Tela 3: a fileira de datas das versões, abaixo do topo da página, e o que
/// mudou desde a versão anterior. Tocar numa data abre aquela versão; o toque
/// longo separa aquela versão das outras.
struct VersoesDaNotaViva: View {
    let atual: Nota
    /// Só as que podem andar juntas — quem chama já filtrou.
    let membros: [Nota]
    let abrir: (Nota) -> Void
    let separar: (Nota) -> Void

    private var ordenados: [Nota] { membros.sorted { $0.criadaEm > $1.criadaEm } }

    private static let diaMes: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("dMMM")
        return f
    }()
    private static let diaMesAno: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("dMMMyy")
        return f
    }()

    var body: some View {
        let lista = ordenados
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(lista, id: \.uuid) { v in
                        chip(v, lista: lista)
                    }
                }
                .padding(.horizontal, Tema.margem)
            }
            .scrollIndicators(.hidden)

            // altura fixa (auditoria 17/09: o texto pulava até 48 pt ao trocar
            // de data): a linha existe sempre — o que mudou, ou de quando é
            (oQueMudou(lista) ?? Text(primeiraOuIgual(lista)).foregroundStyle(Tema.tintaFraca))
                .font(Tema.meta)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .topLeading)
                .padding(.horizontal, Tema.margem)
                .accessibilityIdentifier("nota-viva-mudou")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("nota-viva-versoes")
    }

    private func chip(_ v: Nota, lista: [Nota]) -> some View {
        let esta = v.uuid == atual.uuid
        return Button {
            guard !esta else { return }
            Toque.selecao()
            abrir(v)
        } label: {
            Text(rotulo(v, lista: lista))
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
        .contextMenu {
            Button("Separar esta versão", systemImage: "square.split.2x1") { separar(v) }
        }
        .accessibilityLabel("Versão de " + v.criadaEm.formatted(.dateTime.day().month(.wide).hour().minute()))
        .accessibilityAddTraits(esta ? .isSelected : [])
        .accessibilityHint(esta ? "Versão aberta. Segure para separar" : "Abre esta versão. Segure para separar")
    }

    /// «Hoje», «10 set», «3 mai 25»; com a hora quando duas versões caem no mesmo dia.
    private func rotulo(_ v: Nota, lista: [Nota]) -> String {
        let cal = Calendar.current
        let d = v.criadaEm
        let mesmoDia = lista.contains { $0.uuid != v.uuid && cal.isDate($0.criadaEm, inSameDayAs: d) }
        var base = cal.isDateInToday(d) ? "Hoje"
            : (cal.isDate(d, equalTo: .now, toGranularity: .year) ? Self.diaMes : Self.diaMesAno).string(from: d)
                .replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " de ", with: " ")
        if mesmoDia { base += ", " + d.formatted(date: .omitted, time: .shortened) }
        return base
    }

    private func primeiraOuIgual(_ lista: [Nota]) -> String {
        lista.last?.uuid == atual.uuid ? "A primeira versão" : "Igual à versão anterior"
    }

    /// «Desde 10 de setembro: + detergente · − leite». Só entre esta versão e a
    /// anterior; cada parte curta — em prosa, um parágrafo inteiro não cabe.
    private func oQueMudou(_ lista: [Nota]) -> Text? {
        guard let i = lista.firstIndex(where: { $0.uuid == atual.uuid }), i + 1 < lista.count else { return nil }
        let anterior = lista[i + 1]
        let d = Juntas.diferenca(de: anterior.textoDeQualquerOrigem, para: atual.textoDeQualquerOrigem)
        guard !d.entrou.isEmpty || !d.saiu.isEmpty else { return nil }
        let curto = { (x: String) in x.count > 32 ? String(x.prefix(31)).trimmingCharacters(in: .whitespaces) + "…" : x }
        let partes = d.entrou.prefix(4).map { "+ " + curto($0) } + d.saiu.prefix(4).map { "− " + curto($0) }
        return Text("Desde " + anterior.criadaEm.formatted(.dateTime.day().month(.wide)) + ": ").foregroundStyle(Tema.tintaSuave)
            + Text(partes.joined(separator: " · ")).foregroundStyle(Tema.tinta)
    }
}
