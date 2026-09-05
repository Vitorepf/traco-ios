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
    }

    /// Arrastar para o lado anda no tempo: um dia aqui, sete na semana.
    private func andar(_ unidade: Calendar.Component, _ passo: Int) {
        if let novo = agenda.cal.date(byAdding: unidade, value: passo, to: agenda.ancora) {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
        }
    }

    private var faixaSemana: some View {
        HStack(spacing: 4) {
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
                .accessibilityIdentifier("dia-chip-\(Calendario.formatar(dia, "yyyy-MM-dd", agenda.cal))")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
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
                        .frame(minHeight: Tema.alvo)
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
        let y = max(0, offset(de: alvo) - altura * 1.25)
        if animado, !reduceMotion {
            withAnimation(CalendarioTema.morph(false)) { posicao.scrollTo(y: y) }
        } else {
            posicao.scrollTo(y: y)
        }
    }

    private var horas: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hora in
                HStack(alignment: .top, spacing: 10) {
                    Text(String(format: "%02d:00", hora))
                        .font(CalendarioTema.hora)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(width: gutter - 14, alignment: .trailing)
                        .offset(y: -7)
                    Rectangle()
                        .fill(CalendarioTema.linha)
                        .frame(height: 1)
                }
                .frame(height: altura, alignment: .top)
                .id(hora)
            }
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

    private let horas = Calendario.horasDaSemana
    private let origem = 3 * 60
    private let span = 18 * 60

    /// O chrome flutuante cobre este tanto do fundo: a última linha fica acima dele.
    static let reservaChrome: CGFloat = 150

    var body: some View {
        let mapa = agenda.porDia
        GeometryReader { geo in
            let alturaLinha = min(CalendarioTema.semanaBarra,
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
            .gesture(Arrasto { passo in
                if let novo = agenda.cal.date(byAdding: .day, value: passo * 7, to: agenda.ancora) {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
                }
            })
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
                CalendarioChipDia(dia: dia, activo: activo, hoje: hoje, cal: agenda.cal, compacto: true)
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

    private func barra(dia: Date, eventos: [EventoCalendario], hoje: Bool, largura: CGFloat, altura: CGFloat) -> some View {
        let colunas = Calendario.colunas(eventos)
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
            let maisPistas = min(3, colunas.map(\.total).max() ?? 1)
            let pistas = maisPistas + (inteiros.isEmpty ? 0 : 1)
            let alturaPilula: CGFloat = pistas <= 1 ? 22 : (pistas == 2 ? 20 : 14)
            let passo = alturaPilula + 2
            let topo = -CGFloat(pistas - 1) / 2 * passo
            ForEach(Array(inteiros.prefix(1))) { evento in
                pilula(evento, x: 4, w: largura - 8, y: topo, h: alturaPilula)
            }
            ForEach(colunas, id: \.evento.id) { coluna in
                if coluna.indice < 3 {
                    let (x, w) = faixa(coluna.evento, largura: largura)
                    let pista = coluna.indice + (inteiros.isEmpty ? 0 : 1)
                    pilula(coluna.evento, x: x, w: w, y: topo + CGFloat(pista) * passo, h: alturaPilula)
                }
            }
            if let extra = colunas.first(where: { $0.indice >= 3 }) {
                let (x, _) = faixa(extra.evento, largura: largura)
                Text("+\(colunas.filter { $0.indice >= 3 }.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(CalendarioTema.tintaSuave)
                    .offset(x: x + 2, y: altura / 2 - 9)
            }
        }
    }

    /// O rótulo é CORTADO pela cápsula, não abreviado com reticências: "Corri", não "Co…".
    private func pilula(_ evento: EventoCalendario, x: CGFloat, w: CGFloat, y: CGFloat, h: CGFloat) -> some View {
        Button {
            agenda.abrir(evento)
        } label: {
            Text(evento.titulo)
                .font(.system(size: h < 18 ? 9 : 11, weight: .semibold))
                .foregroundStyle(CalendarioTema.tinta(de: evento))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.leading, 7)
                .frame(width: w, height: h, alignment: .leading)
                .desvanece(12)
                .background(CalendarioTema.fundo(de: evento))
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
        let w = min(largura - 8, max(48, bruto))
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
    @ScaledMetric(relativeTo: .caption2) private var tamChip: CGFloat = 10

    var body: some View {
        let mapa = agenda.porDia
        let celulas = agenda.grelha
        let semanas = stride(from: 0, to: celulas.count, by: 7).map { Array(celulas[$0..<min($0 + 7, celulas.count)]) }
        GeometryReader { geo in
            let alturaCelula = max(64, (geo.size.height - CalendarioSemanaView.reservaChrome - 14 - 8 - 5 * 4) / 6)
            grade(semanas: semanas, mapa: mapa, alturaCelula: alturaCelula)
        }
    }

    private func grade(semanas: [[Date]], mapa: [Date: [EventoCalendario]], alturaCelula: CGFloat) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(Array(Calendario.letrasDaSemana(agenda.cal).enumerated()), id: \.offset) { _, letra in
                    Text(letra)
                        .font(CalendarioTema.letra)
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
            .gesture(Arrasto(eixo: .ambos) { passo in
                if let novo = agenda.cal.date(byAdding: .month, value: passo, to: agenda.ancora) {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
                }
            })
            Spacer(minLength: 0)
        }
    }

    private func celula(_ dia: Date, eventos: [EventoCalendario], altura: CGFloat) -> some View {
        let noMes = Calendario.mesmoMes(dia, agenda.ancora, agenda.cal)
        let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let hoje = Calendario.eHoje(dia, agora: agora, agenda.cal)
        let visiveis = Array(eventos.prefix(2))
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
                    .foregroundStyle(activo ? .white : (noMes ? CalendarioTema.tinta : CalendarioTema.tintaMorta))
                    .riscoDeFeriado(
                        Feriados.eFeriado(dia, agenda.cal),
                        largura: 15,
                        cor: activo ? .white : (noMes ? CalendarioTema.tinta : CalendarioTema.tintaMorta))
                    .frame(width: 28, height: 28)
                    .background {
                        if activo {
                            Circle().fill(CalendarioTema.chipActivo)
                        } else if hoje {
                            Circle().strokeBorder(CalendarioTema.tinta, lineWidth: 1.5)
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
                            Text(evento.titulo)
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
    @ScaledMetric(relativeTo: .caption2) private var tamDia: CGFloat = 8

    var body: some View {
        let mapa = agenda.porDia
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                ForEach(agenda.meses, id: \.self) { mes in
                    mesMini(mes, mapa: mapa)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 180)
        }
        .gesture(Arrasto { passo in
            if let novo = agenda.cal.date(byAdding: .year, value: passo, to: agenda.ancora) {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) { agenda.ir(dia: novo) }
            }
        })
    }

    private func mesMini(_ mes: Date, mapa: [Date: [EventoCalendario]]) -> some View {
        let actual = Calendario.mesmoMes(mes, agenda.ancora, agenda.cal)
        let celulas = Calendario.grelhaDoMes(da: mes, agenda.cal)
        return Button {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) {
                agenda.ir(mes: mes)
                agenda.ir(para: .mes)
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(Calendario.mesCurto(mes, agenda.cal).uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(0.6)
                    .foregroundStyle(actual ? CalendarioTema.tinta : CalendarioTema.tintaSuave)
                VStack(spacing: 1) {
                    ForEach(0..<6, id: \.self) { linha in
                        HStack(spacing: 1) {
                            ForEach(0..<7, id: \.self) { col in
                                let i = linha * 7 + col
                                let dia = celulas.indices.contains(i) ? celulas[i] : mes
                                celulaAno(dia, mes: mes, eventos: mapa[Calendario.inicioDoDia(dia, agenda.cal)] ?? [])
                            }
                        }
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(actual ? CalendarioTema.chipActivo : .clear, lineWidth: 1.5)
            }
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(PressaoClara())
        .matchedGeometryEffect(id: idMes(mes, agenda.cal), in: morph, isSource: agenda.escala == .ano)
        .accessibilityLabel(Calendario.formatar(mes, "MMMM 'de' yyyy", agenda.cal))
        .accessibilityIdentifier(actual ? "calendario-ano-actual" : "calendario-ano-\(Calendario.formatar(mes, "yyyy-MM", agenda.cal))")
    }

    private func celulaAno(_ dia: Date, mes: Date, eventos: [EventoCalendario]) -> some View {
        let noMes = Calendario.mesmoMes(dia, mes, agenda.cal)
        let ancora = noMes && Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let hoje = noMes && Calendario.eHoje(dia, agora: agora, agenda.cal)
        // a semana da âncora em azul de papel: o "onde estou" do clone, mesmo
        // quando a semana atravessa dois meses (30, 31 | 1…5)
        let naSemana = noMes && agenda.semana.contains { Calendario.mesmoDia($0, dia, agenda.cal) }
        let tinta = noMes ? eventos.first?.dominio : nil
        let numero = agenda.cal.component(.day, from: dia)
        return Text("\(numero)")
            .font(.system(size: tamDia, weight: ancora || hoje ? .bold : .medium))
            .monospacedDigit()
            .foregroundStyle(ancora ? .white : (noMes ? CalendarioTema.tinta : CalendarioTema.tintaMorta))
            // o ano também recebe o risco (dono, 03/set: "em qualquer tipo de
            // visualização"). Menor e mais fino, na proporção do número de 8pt.
            .riscoDeFeriado(
                noMes && Feriados.eFeriado(dia, agenda.cal),
                largura: tamDia, espessura: 0.7,
                cor: ancora ? .white : CalendarioTema.tinta)
            .frame(maxWidth: .infinity, minHeight: 13)
            .background {
                if ancora {
                    Circle().fill(CalendarioTema.chipActivo)
                } else if naSemana {
                    Circle().fill(CalendarioTema.semanaAncora)
                } else if let tinta, !eventos.isEmpty {
                    Circle().fill(CalendarioTema.fundo(de: tinta))
                } else if hoje {
                    Circle().strokeBorder(CalendarioTema.tinta, lineWidth: 1)
                }
            }
            .opacity(noMes ? 1 : 0.4)
    }
}
