import SwiftUI

// Um objeto em quatro zooms. O chip do dia âncora tem a MESMA identidade em
// todas as escalas (`dia-<ts>`), e o bloco do mês também (`mes-yyyy-MM`);
// só a escala visível é fonte. É isso que faz a troca ler como desdobramento.

private func idDia(_ dia: Date, _ cal: Calendar) -> String {
    "dia-\(Int(Calendario.inicioDoDia(dia, cal).timeIntervalSince1970))"
}

private func idMes(_ mes: Date, _ cal: Calendar) -> String {
    "mes-\(Calendario.formatar(mes, "yyyy-MM", cal))"
}

// MARK: - Dia

struct CalendarioDiaView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    var agora: Date
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var posicao = ScrollPosition()
    @ScaledMetric(relativeTo: .caption) private var gutter: CGFloat = 58
    private var altura: CGFloat { CalendarioTema.horaAltura }

    var body: some View {
        let doDia = agenda.eventos(no: agenda.ancora)
        let inteiros = doDia.filter(\.diaInteiro)
        VStack(spacing: 12) {
            faixaSemana
            if !inteiros.isEmpty {
                diaInteiro(inteiros)
            }
            timeline(doDia)
        }
        .gesture(Arrasto { passo in andar(.day, passo) })
        // o arrasto tem par no rotor do VoiceOver (ADR 05t)
        .accessibilityAction(named: Text("Dia seguinte")) { andar(.day, 1) }
        .accessibilityAction(named: Text("Dia anterior")) { andar(.day, -1) }
    }

    /// Arrastar para o lado anda no tempo: um dia aqui, sete na semana.
    private func andar(_ unidade: Calendar.Component, _ passo: Int) {
        if let novo = agenda.cal.date(byAdding: unidade, value: passo, to: agenda.ancora) {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
        }
    }

    // os sete dias repartem a largura toda, como as colunas do mês: juntos ao
    // centro sobrava um vão nas pontas (dono, 16/09)
    private var faixaSemana: some View {
        HStack(spacing: 0) {
            ForEach(agenda.semana, id: \.self) { dia in
                let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
                Button {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) {
                        agenda.ir(dia: dia)
                    }
                } label: {
                    CalendarioChipDia(
                        dia: dia, activo: activo,
                        hoje: Calendario.eHoje(dia, agora: agora, agenda.cal),
                        cal: agenda.cal
                    )
                    .matchedGeometryEffect(id: idDia(dia, agenda.cal), in: morph, isSource: agenda.escala == .dia)
                }
                .buttonStyle(PressaoClara())
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("dia-chip-\(Calendario.formatar(dia, "yyyy-MM-dd", agenda.cal))")
            }
        }
        .padding(.horizontal, 10)
    }

    private func diaInteiro(_ eventos: [EventoCalendario]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(eventos) { evento in
                    Button {
                        agenda.abrir(evento)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: CalendarioTema.icone(de: evento))
                                .font(.caption2.weight(.semibold))
                            Text(evento.titulo)
                                .font(CalendarioTema.meta)
                                .lineLimit(1)
                        }
                        .foregroundStyle(CalendarioTema.tinta(de: evento))
                        .padding(.horizontal, 12)
                        .frame(height: 32)
                        .background(CalendarioTema.fundo(de: evento), in: Capsule())
                        .overlay { if CalendarioTema.temContorno(evento) { Capsule().strokeBorder(CalendarioTema.contorno(de: evento), lineWidth: 1) } }
                        .alvo()
                        .contentShape(Capsule())
                    }
                    .buttonStyle(PressaoClara())
                }
            }
            .padding(.horizontal, CalendarioTema.margem)
        }
        .frame(height: Tema.alvo)
    }

    private func timeline(_ doDia: [EventoCalendario]) -> some View {
        let colunas = Calendario.colunas(doDia)
        let hoje = Calendario.eHoje(agenda.ancora, agora: agora, agenda.cal)
        return ScrollView {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    horas
                    if hoje { fioAgora }
                    eventos(colunas, largura: geo.size.width)
                    if hoje { marcaAgora }
                }
            }
            .frame(height: altura * 24 + 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 172)
        }
        .scrollPosition($posicao)
        .onAppear { rolar(doDia: doDia, hoje: hoje, animado: false) }
        .onChange(of: agenda.ancora) { _, _ in
            rolar(doDia: agenda.eventos(no: agenda.ancora),
                  hoje: Calendario.eHoje(agenda.ancora, agora: agora, agenda.cal), animado: true)
        }
    }

    /// Hoje: o agora a um quarto da tela. Outro dia: o primeiro compromisso. Vazio: a manhã.
    private func rolar(doDia: [EventoCalendario], hoje: Bool, animado: Bool) {
        let alvo: Date
        if hoje {
            alvo = agora
        } else if let primeiro = doDia.first(where: { !$0.diaInteiro }) {
            alvo = primeiro.inicio
        } else {
            alvo = Calendario.hora(8, 0, no: agenda.ancora, agenda.cal)
        }
        // a grade abre na HORA CHEIA do alvo, com o rótulo dela logo abaixo dos
        // dias: abrir 1h15 antes deixava um vão de linha vazia (dono, 16/09)
        let horaCheia = Calendario.hora(agenda.cal.component(.hour, from: alvo), 0, no: agenda.ancora, agenda.cal)
        let y = max(0, offset(de: horaCheia) - 10)
        // rolar até a hora é deslocamento que o relógio pede: sob reduzido, corta
        withAnimation(animado ? Tema.corte(Tema.Mola.escala, reduzido: reduceMotion) : nil) {
            posicao.scrollTo(y: y)
        }
    }

    private var horas: some View {
        // o rótulo da hora cheia some quando a etiqueta do agora cai sobre ele:
        // às 14:11 o "14:00" aparecia por baixo do "14:11" (16/09)
        let agoraNaGrade = Calendario.eHoje(agenda.ancora, agora: agora, agenda.cal)
            ? Calendario.minutosDoDia(agora, agenda.cal) : nil
        return VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hora in
                HStack(alignment: .top, spacing: 10) {
                    Text(String(format: "%02d:00", hora))
                        .font(CalendarioTema.hora)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(width: gutter - 14, alignment: .trailing)
                        .offset(y: -7)
                        .opacity(agoraNaGrade.map { abs($0 - hora * 60) < 20 } == true ? 0 : 1)
                    Rectangle()
                        .fill(CalendarioTema.linha)
                        .frame(height: 1)
                }
                .frame(height: altura, alignment: .top)
                .id(hora)
            }
            // a grade fecha à meia-noite: parava no fio das 23h e sobrava um vão
            // sem nome embaixo (auditoria 16/09 noite)
            HStack(alignment: .top, spacing: 10) {
                Text("00:00")
                    .font(CalendarioTema.hora)
                    .foregroundStyle(CalendarioTema.tintaFraca)
                    .frame(width: gutter - 14, alignment: .trailing)
                    .offset(y: -7)
                Rectangle()
                    .fill(CalendarioTema.linha)
                    .frame(height: 1)
            }
            .frame(height: 24, alignment: .top)
        }
        .padding(.top, 8)
    }

    private func eventos(_ colunas: [Calendario.Coluna], largura: CGFloat) -> some View {
        let util = max(0, largura - gutter)
        return ForEach(colunas, id: \.evento.id) { coluna in
            let evento = coluna.evento
            let topo = offset(de: evento.inicio)
            let fundo = offset(de: evento.fim)
            let alturaBloco = max(Tema.alvo, fundo - topo)
            let larguraColuna = util / CGFloat(coluna.total)
            let x = gutter + larguraColuna * CGFloat(coluna.indice)
            let compacto = alturaBloco < 60
            Button {
                agenda.abrir(evento)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: CalendarioTema.icone(de: evento))
                            .font(.caption.weight(.semibold))
                        Text(evento.titulo)
                            .font(CalendarioTema.evento)
                            .lineLimit(compacto ? 1 : 2)
                        if compacto {
                            Text(Calendario.horaCurta(evento.inicio, agenda.cal))
                                .font(CalendarioTema.hora)
                                .opacity(0.8)
                        }
                    }
                    if !compacto {
                        HStack(spacing: 5) {
                            Text(Calendario.intervalo(evento, agenda.cal))
                                .font(CalendarioTema.meta.monospacedDigit())
                            // ADR 04a: o autor vê na GRADE que aquilo vai
                            // cobrá-lo. Sino é ícone (≥3:1), não texto.
                            if evento.editavel, evento.avisoMinutos != nil {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 9, weight: .semibold))
                                    .accessibilityLabel("com aviso")
                            }
                        }
                        .opacity(0.85)
                    }
                }
                .foregroundStyle(CalendarioTema.tinta(de: evento))
                .padding(.horizontal, 12)
                .padding(.vertical, compacto ? 8 : 12)
                .frame(width: max(44, larguraColuna - 4), height: alturaBloco, alignment: .topLeading)
                .background(
                    CalendarioTema.fundo(de: evento),
                    in: RoundedRectangle(cornerRadius: min(CalendarioTema.raio, alturaBloco / 2.6), style: .continuous)
                )
                .overlay {
                    if evento.eDeixa {
                        RoundedRectangle(cornerRadius: min(CalendarioTema.raio, alturaBloco / 2.6), style: .continuous)
                            .strokeBorder(CalendarioTema.contornoDeixa, lineWidth: 1)
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: CalendarioTema.raio, style: .continuous))
            }
            .buttonStyle(PressaoClara())
            .offset(x: x, y: topo)
            .accessibilityLabel("\(evento.titulo), \(Calendario.intervalo(evento, agenda.cal))")
            .accessibilityIdentifier("evento-\(evento.id.uuidString)")
        }
    }

    /// O agora: a única vez que o âmbar aparece no calendário. O fio passa
    /// POR BAIXO dos compromissos, para não riscar o título; a marca, por cima.
    private var fioAgora: some View {
        Rectangle()
            .fill(CalendarioTema.agora)
            .frame(height: 1.5)
            .padding(.leading, gutter + 4)
            .offset(y: offset(de: agora) - 0.75)
            .allowsHitTesting(false)
    }

    private var marcaAgora: some View {
        HStack(spacing: 6) {
            Text(Calendario.horaCurta(agora, agenda.cal))
                .font(CalendarioTema.hora.weight(.semibold))
                .foregroundStyle(CalendarioTema.tinta)
                .padding(.horizontal, 5)
                .frame(height: 18)
                .background(CalendarioTema.agora, in: Capsule())
                .fixedSize()
                .frame(width: gutter - 4, alignment: .trailing)
            Circle()
                .fill(CalendarioTema.agora)
                .frame(width: 7, height: 7)
        }
        .offset(y: offset(de: agora) - 9)
        .allowsHitTesting(false)
        .accessibilityLabel("agora, \(Calendario.horaCurta(agora, agenda.cal))")
        .accessibilityIdentifier("calendario-agora")
    }

    private func offset(de data: Date) -> CGFloat {
        CGFloat(Calendario.minutosDoDia(data, agenda.cal)) / 60 * altura + 8
    }
}

// MARK: - Semana

struct CalendarioSemanaView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    var agora: Date
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Arrastar ou, no VoiceOver, a ação do rotor: sete dias por passo.
    private func andar(_ passo: Int) {
        if let novo = agenda.cal.date(byAdding: .day, value: passo * 7, to: agenda.ancora) {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
        }
    }

    private let horas = Calendario.horasDaSemana
    // O dia inteiro, 0–24 h. A escala 03–21 prendia à borda o que caía fora
    // (`faixa`), e o jantar das 20h sumia debaixo do dentista das 22h30
    // (auditoria 13/09, defeito 2). As horas escritas seguem de 3 em 3.
    private let origem = 0
    private let span = 24 * 60

    /// O pé cobre este tanto do fundo das grades: o campo de 40 pt desce 6
    /// para dentro da reserva do Dock (34 à vista) e a grade para 12 acima dele,
    /// a mesma folga entre o campo e o Dock. Era 150 do pé de duas linhas, e
    /// semana, mês e ano deixavam um vão enorme com o conteúdo espremido
    /// (dono, 16/09).
    static let reservaChrome: CGFloat = 46

    var body: some View {
        let mapa = agenda.porDia
        GeometryReader { geo in
            // as linhas crescem até 76 pt para ocupar a tela: com o teto de 52
            // a metade de baixo ficava vazia (auditoria 15/09, 14)
            let alturaLinha = min(92,
                                  max(40, (geo.size.height - Self.reservaChrome - 14 - 8 - 6 * 8) / 7))
            VStack(alignment: .leading, spacing: 8) {
                cabecalhoHoras
                VStack(spacing: 8) {
                    ForEach(agenda.semana, id: \.self) { dia in
                        linha(dia: dia, eventos: mapa[Calendario.inicioDoDia(dia, agenda.cal)] ?? [], alturaLinha: alturaLinha)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .gesture(Arrasto { passo in andar(passo) })
            .accessibilityAction(named: Text("Semana seguinte")) { andar(1) }
            .accessibilityAction(named: Text("Semana anterior")) { andar(-1) }
        }
    }

    private var cabecalhoHoras: some View {
        HStack(spacing: 8) {
            Color.clear.frame(width: Tema.alvo, height: 14)
            GeometryReader { geo in
                ForEach(horas, id: \.self) { hora in
                    Text(String(format: "%02d", hora))
                        .font(CalendarioTema.hora)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .position(x: fracao(hora * 60) * geo.size.width, y: 7)
                }
            }
            .frame(height: 14)
        }
    }

    private func linha(dia: Date, eventos: [EventoCalendario], alturaLinha: CGFloat) -> some View {
        let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let hoje = Calendario.eHoje(dia, agora: agora, agenda.cal)
        return HStack(spacing: 8) {
            Button {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) {
                    agenda.ir(dia: dia)
                    agenda.ir(para: .dia)
                }
            } label: {
                // com a linha alta o chip volta ao tamanho do dia (44), com a letra
                CalendarioChipDia(dia: dia, activo: activo, hoje: hoje, cal: agenda.cal, compacto: alturaLinha < 60)
                    .matchedGeometryEffect(id: idDia(dia, agenda.cal), in: morph, isSource: agenda.escala == .semana)
            }
            .buttonStyle(PressaoClara())
            .accessibilityIdentifier("semana-chip-\(Calendario.formatar(dia, "yyyy-MM-dd", agenda.cal))")

            // a barra NÃO é Button: um Button com rótulo engolia as pílulas de
            // dentro, e o VoiceOver não chegava a nenhum compromisso da semana
            GeometryReader { geo in
                barra(dia: dia, eventos: eventos, hoje: hoje, largura: geo.size.width, altura: geo.size.height)
            }
            .frame(height: alturaLinha)
            .contentShape(Capsule())
            .onTapGesture {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) {
                    agenda.ir(dia: dia)
                    agenda.ir(para: .dia)
                }
            }
            .accessibilityElement(children: .contain)
            // F4: o risco é invisível a quem não vê — o nome do feriado tem de sair no rótulo
        .accessibilityLabel(
            Feriados.de(dia, agenda.cal).map {
                "\(Calendario.diaPorExtenso(dia, agenda.cal)), feriado, \($0.nome)"
            } ?? Calendario.diaPorExtenso(dia, agenda.cal)
        )
            .accessibilityHint("Toque para abrir o dia")
        }
    }

    private struct Pista { let evento: EventoCalendario; let x: CGFloat; let w: CGFloat; let indice: Int }

    /// Pistas por sobreposição VISUAL, não de horário: a pílula tem largura
    /// mínima (48 pt ≈ 4 h em 24) e a última do dia é presa à borda, então
    /// dois compromissos afastados no relógio colidem na tela — o jantar das
    /// 20h sumia debaixo do dentista das 23h30 (auditoria 13/09, defeito 2).
    private func pistas(_ eventos: [EventoCalendario], largura: CGFloat) -> [Pista] {
        var fins: [CGFloat] = []
        var saida: [Pista] = []
        for e in eventos.filter({ !$0.diaInteiro }).sorted(by: { $0.inicio < $1.inicio }) {
            let (x, w) = faixa(e, largura: largura)
            let indice = fins.firstIndex { $0 <= x } ?? fins.count
            if indice == fins.count { fins.append(x + w) } else { fins[indice] = x + w }
            saida.append(Pista(evento: e, x: x, w: w, indice: indice))
        }
        return saida
    }

    /// Quantos compromissos do dia NÃO couberam na barra. Os de dia inteiro
    /// dividem UMA pista (a de cima), e do segundo em diante sumiam sem entrar
    /// em conta nenhuma: o dia com «Aniversário da Ana» (do iPhone) e «Viagem
    /// a Lisboa» (do autor) mostrava uma pílula e nenhum «+n» — e com o
    /// calendário do iPhone lido, dois de dia inteiro no mesmo dia é o caso
    /// comum (auditoria 17/09). A célula do Mês já contava o excedente; a
    /// Semana é a escala em que se confere "o que tenho nesta semana".
    static func escondidos(pistas: [Int], inteiros: Int) -> Int {
        pistas.filter { $0 >= 3 }.count + max(0, inteiros - 1)
    }

    private func barra(dia: Date, eventos: [EventoCalendario], hoje: Bool, largura: CGFloat, altura: CGFloat) -> some View {
        let marcados = pistas(eventos, largura: largura)
        let inteiros = eventos.filter(\.diaInteiro)
        return ZStack(alignment: .leading) {
            Capsule().fill(CalendarioTema.chip)
            ForEach(horas, id: \.self) { hora in
                Rectangle()
                    .fill(CalendarioTema.linha)
                    .frame(width: 1, height: altura - 12)
                    .offset(x: fracao(hora * 60) * largura)
            }
            if hoje, let x = agoraX(largura: largura) {
                Capsule()
                    .fill(CalendarioTema.agora)
                    .frame(width: 2, height: altura - 8)
                    .offset(x: x - 1)
                    .accessibilityLabel("agora")
            }
            // pistas: o dia inteiro ocupa a de cima; os marcados dividem as outras.
            // Três ao mesmo tempo é o teto visível; o quarto conta no "+n".
            let maisPistas = min(3, max(1, (marcados.map(\.indice).max() ?? 0) + 1))
            let pistas = maisPistas + (inteiros.isEmpty ? 0 : 1)
            // a pílula cresce com a faixa: na linha alta o nome se lê inteiro
            let alturaPilula: CGFloat = pistas <= 1 ? min(30, max(22, altura * 0.38))
                : pistas == 2 ? min(26, max(20, (altura - 14) / 2 - 2))
                : max(14, min(20, (altura - 12) / 3 - 2))
            let passo = alturaPilula + 2
            let topo = -CGFloat(pistas - 1) / 2 * passo
            ForEach(Array(inteiros.prefix(1))) { evento in
                pilula(evento, x: 4, w: largura - 8, y: topo, h: alturaPilula)
            }
            ForEach(marcados.filter { $0.indice < 3 }, id: \.evento.id) { p in
                let pista = p.indice + (inteiros.isEmpty ? 0 : 1)
                pilula(p.evento, x: p.x, w: p.w, y: topo + CGFloat(pista) * passo, h: alturaPilula)
            }
            let escondidos = Self.escondidos(pistas: marcados.map(\.indice), inteiros: inteiros.count)
            if escondidos > 0 {
                // sem marcado escondido o número é de dia inteiro, e a pílula
                // deles ocupa a largura toda: o «+n» encosta à esquerda
                Text("+\(escondidos)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(CalendarioTema.tintaSuave)
                    .offset(x: (marcados.first(where: { $0.indice >= 3 })?.x ?? 4) + 2, y: altura / 2 - 9)
            }
        }
    }

    /// O rótulo é CORTADO pela cápsula, não abreviado com reticências: "Corri", não "Co…".
    private func pilula(_ evento: EventoCalendario, x: CGFloat, w: CGFloat, y: CGFloat, h: CGFloat) -> some View {
        Button {
            agenda.abrir(evento)
        } label: {
            Text(evento.titulo)
                .font(.system(size: h < 18 ? 9 : (h < 24 ? 11 : 12), weight: .semibold))
                .foregroundStyle(CalendarioTema.tinta(de: evento))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.leading, 7)
                .frame(width: w, height: h, alignment: .leading)
                .desvanece(12)
                .background(CalendarioTema.fundoSobreChip(de: evento))
                .clipShape(Capsule())
                .overlay { if CalendarioTema.temContorno(evento) { Capsule().strokeBorder(CalendarioTema.contorno(de: evento), lineWidth: 1) } }
                .frame(height: Tema.alvo)
                .contentShape(Capsule())
        }
        .buttonStyle(PressaoClara())
        .offset(x: x, y: y)
        .accessibilityLabel("\(evento.titulo), \(Calendario.intervalo(evento, agenda.cal))")
    }

    private func fracao(_ minutos: Int) -> CGFloat {
        CGFloat(minutos - origem) / CGFloat(span)
    }

    private func faixa(_ evento: EventoCalendario, largura: CGFloat) -> (CGFloat, CGFloat) {
        let inicio = Calendario.minutosDoDia(evento.inicio, agenda.cal)
        let fim = Calendario.minutosDoDia(evento.fim, agenda.cal)
        let bruto = CGFloat(max(20, fim - inicio)) / CGFloat(span) * largura
        // 60 pt de mínimo: numa linha alta o nome de uma palavra cabe inteiro
        let w = min(largura - 8, max(60, bruto))
        let x = min(max(4, fracao(inicio) * largura), max(4, largura - w - 4))
        return (x, w)
    }

    private func agoraX(largura: CGFloat) -> CGFloat? {
        let m = Calendario.minutosDoDia(agora, agenda.cal)
        guard m >= origem, m <= origem + span else { return nil }
        return fracao(m) * largura
    }
}

// MARK: - Mês

struct CalendarioMesView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    var agora: Date
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Arrastar ou, no VoiceOver, a ação do rotor: um mês por passo.
    private func andar(_ passo: Int) {
        if let novo = agenda.cal.date(byAdding: .month, value: passo, to: agenda.ancora) {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
        }
    }
    @ScaledMetric(relativeTo: .caption2) private var tamChip: CGFloat = 11

    var body: some View {
        let mapa = agenda.porDia
        let celulas = agenda.grelha
        // só as semanas que têm dia do mês (auditoria 17/09: a sexta linha era
        // inteira de outubro, esmaecida)
        let semanas = stride(from: 0, to: celulas.count, by: 7)
            .map { Array(celulas[$0..<min($0 + 7, celulas.count)]) }
            .filter { semana in semana.contains { Calendario.mesmoMes($0, agenda.ancora, agenda.cal) } }
        GeometryReader { geo in
            let linhas = CGFloat(max(4, semanas.count))
            let alturaCelula = max(64, (geo.size.height - CalendarioSemanaView.reservaChrome - 14 - 8 - (linhas - 1) * 4) / linhas)
            grade(semanas: semanas, mapa: mapa, alturaCelula: alturaCelula)
        }
    }

    private func grade(semanas: [[Date]], mapa: [Date: [EventoCalendario]], alturaCelula: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(Array(Calendario.letrasDaSemana(agenda.cal).enumerated()), id: \.offset) { _, letra in
                    Text(letra)
                        .font(CalendarioTema.meta)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)

            VStack(spacing: 4) {
                ForEach(Array(semanas.enumerated()), id: \.offset) { _, semana in
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(semana, id: \.self) { dia in
                            celula(dia, eventos: mapa[Calendario.inicioDoDia(dia, agenda.cal)] ?? [], altura: alturaCelula)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .matchedGeometryEffect(id: idMes(agenda.ancora, agenda.cal), in: morph, isSource: agenda.escala == .mes)
            .contentShape(Rectangle())
            .gesture(Arrasto(eixo: .ambos) { passo in andar(passo) })
            .accessibilityAction(named: Text("Mês seguinte")) { andar(1) }
            .accessibilityAction(named: Text("Mês anterior")) { andar(-1) }
            Spacer(minLength: 0)
        }
    }

    private func celula(_ dia: Date, eventos: [EventoCalendario], altura: CGFloat) -> some View {
        let noMes = Calendario.mesmoMes(dia, agenda.ancora, agenda.cal)
        let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let hoje = Calendario.eHoje(dia, agora: agora, agenda.cal)
        // cabem tantas etiquetas quanto a célula alta comporta: número (28 + 3),
        // uma linha guardada para o "+n", e o resto em etiquetas de tamChip + 9
        // quando todos cabem, o "+n" não guarda linha
        let semMais = max(1, Int((altura - 31) / (tamChip + 9)))
        let cabem = eventos.count <= semMais ? semMais : max(1, Int((altura - 31 - (tamChip + 2)) / (tamChip + 9)))
        let visiveis = Array(eventos.prefix(cabem))
        let extra = eventos.count - visiveis.count

        return Button {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) {
                // segundo toque no dia já escolhido: aproxima
                if activo { agenda.ir(para: .dia) } else { agenda.ir(dia: dia) }
            }
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(Calendario.formatar(dia, "d", agenda.cal))
                    .font(CalendarioTema.dia)
                    // feriado em vermelho de folhinha, não riscado
                    .foregroundStyle(activo ? Tema.sobreAtivo : !noMes ? CalendarioTema.tintaMorta
                                     : Feriados.eFeriado(dia, agenda.cal) ? CalendarioTema.feriado : CalendarioTema.tinta)
                    .frame(width: 28, height: 28)
                    .background {
                        if activo {
                            RoundedRectangle(cornerRadius: Tema.raioDeCasa(28), style: .continuous).fill(CalendarioTema.chipActivo)
                        } else if hoje {
                            RoundedRectangle(cornerRadius: Tema.raioDeCasa(28), style: .continuous).strokeBorder(CalendarioTema.tinta, lineWidth: 1.5)
                        }
                    }
                    .matchedGeometryEffect(id: idDia(dia, agenda.cal), in: morph, isSource: agenda.escala == .mes)
                    .frame(maxWidth: .infinity, alignment: .center)
                ForEach(visiveis) { evento in
                    // o texto vai em overlay: não propõe largura, e a coluna
                    // continua igual às outras
                    Color.clear
                        .frame(height: tamChip + 6)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .leading) {
                            // a coluna do mês cabe uma palavra: "Jantar" lê,
                            // "Jantar co" não (auditoria 13/09, defeito 26)
                            Text(evento.titulo.split(separator: " ").first.map(String.init) ?? evento.titulo)
                                .font(.system(size: tamChip, weight: .semibold))
                                .foregroundStyle(CalendarioTema.tinta(de: evento))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.leading, 4)
                        }
                        .desvanece(10)
                        .clipped()
                        .background(
                            CalendarioTema.fundo(de: evento),
                            in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .overlay {
                            if evento.eDeixa {
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(CalendarioTema.contornoDeixa, lineWidth: 1)
                            }
                        }
                }
                if extra > 0 {
                    Text("+\(extra)")
                        .font(.system(size: tamChip, weight: .semibold))
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .padding(.leading, 4)
                }
                Spacer(minLength: 0)
            }
            .opacity(noMes ? 1 : 0.5)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(height: altura)
            .clipped()
            .contentShape(Rectangle())
        }
        .buttonStyle(PressaoClara())
        // F4: o risco é invisível a quem não vê — o nome do feriado tem de sair no rótulo
        .accessibilityLabel(
            Feriados.de(dia, agenda.cal).map {
                "\(Calendario.diaPorExtenso(dia, agenda.cal)), feriado, \($0.nome)"
            } ?? Calendario.diaPorExtenso(dia, agenda.cal)
        )
        .accessibilityValue(eventos.isEmpty ? "" : (eventos.count == 1 ? "1 compromisso" : "\(eventos.count) compromissos"))
        .accessibilityAddTraits(activo ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("mes-dia-\(Calendario.formatar(dia, "yyyy-MM-dd", agenda.cal))")
    }
}

// MARK: - Ano

struct CalendarioAnoView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    var agora: Date
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Arrastar ou, no VoiceOver, a ação do rotor: um ano por passo.
    private func andar(_ passo: Int) {
        if let novo = agenda.cal.date(byAdding: .year, value: passo, to: agenda.ancora) {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
        }
    }
    /// O ano ocupa a tela inteira: as quatro linhas de meses dividem a altura
    /// acima do pé, e o número cresce com a célula (dono, 16/09: "tem um
    /// espaço enorme, enquanto todo o espaço dele é comprimido").
    private struct Medida {
        // margem + respiro = 18: o "Jan" alinha com o título do ano
        static let margem: CGFloat = 14, colunas: CGFloat = 6, linhas: CGFloat = 10, respiro: CGFloat = 4, titulo: CGFloat = 20
        let celulaL: CGFloat, celulaA: CGFloat, fonte: CGFloat
        init(largura: CGFloat, altura: CGFloat) {
            let cartaoL = (largura - 2 * Self.margem - 2 * Self.colunas) / 3
            let cartaoA = (altura - CalendarioSemanaView.reservaChrome - 3 * Self.linhas) / 4
            celulaL = max(10, (cartaoL - 2 * Self.respiro) / 7)
            // a célula não passa de 1,3 da largura: número espichado não é leitura
            celulaA = min(celulaL * 1.3, max(13, (cartaoA - 2 * Self.respiro - Self.titulo - 4 - 5) / 6))
            // a largura manda: "28" precisa de ar dos dois lados na coluna de 17 pt
            fonte = min(13, max(8, min(celulaA * 0.62, celulaL * 0.62)))
        }
    }

    var body: some View {
        let mapa = agenda.porDia
        GeometryReader { geo in
            let m = Medida(largura: geo.size.width, altura: geo.size.height)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Medida.colunas), count: 3), spacing: Medida.linhas) {
                    ForEach(agenda.meses, id: \.self) { mes in
                        mesMini(mes, mapa: mapa, m: m)
                    }
                }
                .padding(.horizontal, Medida.margem)
                .padding(.bottom, CalendarioSemanaView.reservaChrome)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .gesture(Arrasto { passo in andar(passo) })
        .accessibilityAction(named: Text("Ano seguinte")) { andar(1) }
        .accessibilityAction(named: Text("Ano anterior")) { andar(-1) }
    }

    private func mesMini(_ mes: Date, mapa: [Date: [EventoCalendario]], m: Medida) -> some View {
        let actual = Calendario.mesmoMes(mes, agenda.ancora, agenda.cal)
        let celulas = Calendario.grelhaDoMes(da: mes, agenda.cal)
        let compromissos = celulas
            .filter { Calendario.mesmoMes($0, mes, agenda.cal) }
            .reduce(0) { $0 + (mapa[Calendario.inicioDoDia($1, agenda.cal)]?.count ?? 0) }
        return Button {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) {
                agenda.ir(mes: mes)
                agenda.ir(para: .mes)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                // ADR 10k: o nome do mês nomeia a grade que está embaixo —
                // é conteúdo, então vai em frase normal, sem caixa alta
                Text(Calendario.mesCurto(mes, agenda.cal).capitalizadoNoInicio)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(actual ? CalendarioTema.tinta : CalendarioTema.tintaSuave)
                    .frame(height: Medida.titulo)
                VStack(spacing: 1) {
                    ForEach(0..<6, id: \.self) { linha in
                        HStack(spacing: 1) {
                            ForEach(0..<7, id: \.self) { col in
                                let i = linha * 7 + col
                                let dia = celulas.indices.contains(i) ? celulas[i] : mes
                                celulaAno(dia, mes: mes, eventos: mapa[Calendario.inicioDoDia(dia, agenda.cal)] ?? [], m: m)
                            }
                        }
                    }
                }
            }
            .padding(Medida.respiro)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(actual ? CalendarioTema.chipActivo : .clear, lineWidth: 1.5)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(PressaoClara())
        .matchedGeometryEffect(id: idMes(mes, agenda.cal), in: morph, isSource: agenda.escala == .ano)
        // um elemento por mês: os 42 números de 8 pt não são leitura, são desenho
        // (G3 v8: ~500 elementos soltos no rotor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Calendario.formatar(mes, "MMMM 'de' yyyy", agenda.cal))
        .accessibilityValue(compromissos == 0 ? "" : (compromissos == 1 ? "1 compromisso" : "\(compromissos) compromissos"))
        .accessibilityAddTraits(actual ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(actual ? "calendario-ano-actual" : "calendario-ano-\(Calendario.formatar(mes, "yyyy-MM", agenda.cal))")
    }

    private func celulaAno(_ dia: Date, mes: Date, eventos: [EventoCalendario], m: Medida) -> some View {
        let noMes = Calendario.mesmoMes(dia, mes, agenda.cal)
        let ancora = noMes && Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let hoje = noMes && Calendario.eHoje(dia, agora: agora, agenda.cal)
        // a semana da âncora em azul de papel: o "onde estou" do clone, mesmo
        // quando a semana atravessa dois meses (30, 31 | 1…5)
        let naSemana = noMes && agenda.semana.contains { Calendario.mesmoDia($0, dia, agenda.cal) }
        let tinta = noMes ? eventos.first?.dominio : nil
        let numero = agenda.cal.component(.day, from: dia)
        // a casa do ano é um quadrado contínuo; a semana da âncora vira UMA
        // faixa, arredondada só nas pontas (dono, 16/09: "como uma régua")
        let lado = min(m.celulaL, m.celulaA) - 1
        let raio = Tema.raioDeCasa(lado)
        func tambemNaSemana(_ passo: Int) -> Bool {
            guard let vizinho = agenda.cal.date(byAdding: .day, value: passo, to: dia) else { return false }
            return Calendario.mesmoMes(vizinho, mes, agenda.cal)
                && agenda.semana.contains { Calendario.mesmoDia($0, vizinho, agenda.cal) }
        }
        let antes = naSemana && tambemNaSemana(-1), depois = naSemana && tambemNaSemana(1)
        return Text("\(numero)")
            .font(.system(size: m.fonte, weight: ancora || hoje ? .bold : .medium))
            .monospacedDigit()
            .tracking(-0.3)
            // o ano também marca o feriado (dono, 03/set: "em qualquer tipo de
            // visualização"): o número em vermelho de folhinha
            .foregroundStyle(ancora ? Tema.sobreAtivo : !noMes ? CalendarioTema.tintaMorta
                             : Feriados.eFeriado(dia, agenda.cal) ? CalendarioTema.feriado : CalendarioTema.tinta)
            // no ano, o dia do mês vizinho não se desenha (auditoria 17/09: doze
            // meses com os vizinhos esmaecidos eram ruído); a casa fica
            .opacity(noMes ? 1 : 0)
            .frame(maxWidth: .infinity)
            .frame(height: m.celulaA)
            .background {
                ZStack {
                    if naSemana {
                        UnevenRoundedRectangle(topLeadingRadius: antes ? 0 : raio, bottomLeadingRadius: antes ? 0 : raio,
                                               bottomTrailingRadius: depois ? 0 : raio, topTrailingRadius: depois ? 0 : raio,
                                               style: .continuous)
                            .fill(CalendarioTema.semanaAncora)
                            .frame(height: lado)
                            // cobre o 1 pt entre as casas: a faixa é contínua
                            .padding(.leading, antes ? -0.5 : 0)
                            .padding(.trailing, depois ? -0.5 : 0)
                    } else if let tinta, !eventos.isEmpty {
                        RoundedRectangle(cornerRadius: raio, style: .continuous)
                            .fill(CalendarioTema.fundo(de: tinta)).frame(width: lado, height: lado)
                    } else if hoje, !ancora {
                        RoundedRectangle(cornerRadius: raio, style: .continuous)
                            .strokeBorder(CalendarioTema.tinta, lineWidth: 1).frame(width: lado, height: lado)
                    }
                    if ancora {
                        RoundedRectangle(cornerRadius: raio, style: .continuous)
                            .fill(CalendarioTema.chipActivo).frame(width: lado, height: lado)
                    }
                }
            }
            .opacity(noMes ? 1 : 0.4)
    }
}
