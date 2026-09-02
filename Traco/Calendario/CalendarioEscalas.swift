import SwiftUI

struct CalendarioDiaView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let inicioHora = 6
    private let fimHora = 22

    var body: some View {
        VStack(spacing: 12) {
            faixaSemana
            timeline
        }
    }

    private var faixaSemana: some View {
        HStack(spacing: 6) {
            ForEach(agenda.semana, id: \.self) { dia in
                let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
                Button {
                    Toque.selecao()
                    withAnimation(CalendarioTema.morph(reduceMotion)) {
                        agenda.ir(dia: dia)
                    }
                } label: {
                    CalendarioChipDia(dia: dia, activo: activo, cal: agenda.cal)
                        .matchedGeometryEffect(id: idDia(dia), in: morph)
                }
                .buttonStyle(PressaoDiscreta())
            }
        }
        .padding(.horizontal, 16)
        .accessibilityIdentifier("calendario-faixa-semana")
    }

    private var timeline: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    horas
                    linhaAgora
                    eventosSobrepostos
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 180)
            }
            .onAppear {
                let hora = agenda.cal.component(.hour, from: .now)
                proxy.scrollTo(max(inicioHora, hora - 1), anchor: .top)
            }
        }
        .accessibilityIdentifier("calendario-dia")
    }

    private var horas: some View {
        VStack(spacing: 0) {
            ForEach(inicioHora...fimHora, id: \.self) { hora in
                HStack(alignment: .top, spacing: 10) {
                    Text(String(format: "%02d:00", hora))
                        .font(CalendarioTema.hora)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(width: 44, alignment: .trailing)
                    Rectangle()
                        .fill(CalendarioTema.linha)
                        .frame(height: 1)
                }
                .frame(height: CalendarioTema.horaAltura, alignment: .top)
                .id(hora)
            }
        }
    }

    private var eventosSobrepostos: some View {
        ForEach(agenda.eventos(no: agenda.ancora)) { evento in
            let topo = offset(de: evento.inicio)
            let altura = max(56, offset(de: evento.fim) - topo)
            Button {
                agenda.ficha = evento
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: CalendarioTema.icone(de: evento.categoria))
                            .font(.system(size: 12, weight: .semibold))
                        Text(evento.titulo)
                            .font(CalendarioTema.evento)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 11, weight: .medium))
                        Text(intervalo(evento))
                            .font(CalendarioTema.meta)
                    }
                }
                .foregroundStyle(CalendarioTema.tinta(de: evento.categoria))
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: altura, alignment: .topLeading)
                .background(
                    CalendarioTema.fundo(de: evento.categoria),
                    in: RoundedRectangle(cornerRadius: CalendarioTema.raio, style: .continuous)
                )
            }
            .buttonStyle(PressaoDiscreta())
            .padding(.leading, 58)
            .offset(y: topo)
            .accessibilityIdentifier("evento-\(evento.id.uuidString)")
        }
    }

    private var linhaAgora: some View {
        let hoje = Calendario.eHoje(agenda.ancora, agora: .now, agenda.cal)
        return Group {
            if hoje {
                let y = offset(de: .now)
                HStack(spacing: 8) {
                    Text("now")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(CalendarioTema.agora, in: Capsule())
                    Rectangle()
                        .fill(CalendarioTema.agora)
                        .frame(height: 1)
                }
                .offset(y: y - 8)
                .accessibilityLabel("now")
            }
        }
    }

    private func offset(de data: Date) -> CGFloat {
        let h = agenda.cal.component(.hour, from: data)
        let m = agenda.cal.component(.minute, from: data)
        let minutos = (h * 60 + m) - inicioHora * 60
        return CGFloat(minutos) / 60 * CalendarioTema.horaAltura
    }

    private func intervalo(_ evento: EventoCalendario) -> String {
        "\(Calendario.formatar(evento.inicio, "HH:mm", agenda.cal)) – \(Calendario.formatar(evento.fim, "HH:mm", agenda.cal))"
    }

    private func idDia(_ dia: Date) -> String {
        "dia-\(Int(Calendario.inicioDoDia(dia, agenda.cal).timeIntervalSince1970))"
    }
}

struct CalendarioSemanaView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let horas = Calendario.horasDaSemana

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Color.clear.frame(width: 36)
                ForEach(horas, id: \.self) { hora in
                    Text(String(format: "%02d", hora))
                        .font(CalendarioTema.hora)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)

            VStack(spacing: 10) {
                ForEach(Array(agenda.semana.enumerated()), id: \.element) { indice, dia in
                    linha(dia: dia, indice: indice)
                }
            }
            .padding(.horizontal, 12)
            Spacer(minLength: 0)
        }
        .padding(.bottom, 160)
        .accessibilityIdentifier("calendario-semana")
    }

    private func linha(dia: Date, indice: Int) -> some View {
        let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        return HStack(spacing: 8) {
            Button {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) {
                    agenda.ir(dia: dia)
                    agenda.ir(para: .dia)
                }
            } label: {
                CalendarioChipDia(dia: dia, activo: activo, cal: agenda.cal, compacto: true)
                    .matchedGeometryEffect(id: idDia(dia), in: morph)
            }
            .buttonStyle(PressaoDiscreta())

            GeometryReader { geo in
                let evs = agenda.eventos(no: dia)
                ZStack(alignment: .leading) {
                    Capsule().fill(CalendarioTema.chip)
                    HStack(spacing: 0) {
                        ForEach(horas, id: \.self) { _ in
                            Rectangle()
                                .fill(CalendarioTema.linha)
                                .frame(width: 1)
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 8)
                    if let x = agoraX(largura: geo.size.width) {
                        Capsule()
                            .fill(CalendarioTema.agoraLinha)
                            .frame(width: 2, height: geo.size.height - 8)
                            .offset(x: x)
                            .accessibilityLabel("now")
                    }
                    ForEach(Array(evs.enumerated()), id: \.element.id) { i, evento in
                        let (x, w) = faixa(evento, largura: geo.size.width)
                        Button {
                            agenda.ficha = evento
                        } label: {
                            Text(rotulo(evento.titulo, largura: w))
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(CalendarioTema.tinta(de: evento.categoria))
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .frame(width: w, height: 22, alignment: .leading)
                                .background(
                                    CalendarioTema.fundo(de: evento.categoria),
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(PressaoDiscreta())
                        .offset(x: x, y: evs.count > 2 ? CGFloat(i % 2) * 8 - 4 : 0)
                    }
                }
            }
            .frame(height: CalendarioTema.semanaBarra)
        }
        .offset(x: reduceMotion ? 0 : CGFloat(indice) * 2)
    }

    private func faixa(_ evento: EventoCalendario, largura: CGFloat) -> (CGFloat, CGFloat) {
        let inicio = minutos(evento.inicio)
        let fim = minutos(evento.fim)
        let origem = 3 * 60
        let span = 18 * 60
        let bruto = CGFloat(max(20, fim - inicio)) / CGFloat(span) * largura
        let w = min(largura, max(36, bruto))
        let x = min(max(0, CGFloat(inicio - origem) / CGFloat(span) * largura), max(0, largura - w))
        return (x, w)
    }

    /// O vídeo corta o título da pílula ("Brun", "Muse") — não o "T…".
    private func rotulo(_ titulo: String, largura: CGFloat) -> String {
        let teto = largura < 40 ? 4 : (largura < 64 ? 6 : 12)
        if titulo.count <= teto { return titulo }
        return String(titulo.prefix(teto))
    }

    private func agoraX(largura: CGFloat) -> CGFloat? {
        let hoje = agenda.semana.contains { Calendario.eHoje($0, agora: .now, agenda.cal) }
        guard hoje else { return nil }
        let m = minutos(.now)
        let origem = 3 * 60
        let span = 18 * 60
        guard m >= origem, m <= origem + span else { return nil }
        return CGFloat(m - origem) / CGFloat(span) * largura
    }

    private func minutos(_ data: Date) -> Int {
        agenda.cal.component(.hour, from: data) * 60 + agenda.cal.component(.minute, from: data)
    }

    private func idDia(_ dia: Date) -> String {
        "dia-\(Int(Calendario.inicioDoDia(dia, agenda.cal).timeIntervalSince1970))"
    }
}

struct CalendarioMesView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, letra in
                    Text(letra)
                        .font(CalendarioTema.letra)
                        .foregroundStyle(CalendarioTema.tintaFraca)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)

            let celulas = agenda.grelha
            let semanas = stride(from: 0, to: celulas.count, by: 7).map { Array(celulas[$0..<min($0 + 7, celulas.count)]) }
            VStack(spacing: 6) {
                ForEach(Array(semanas.enumerated()), id: \.offset) { _, semana in
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(semana, id: \.self) { dia in
                            celula(dia, mes: agenda.ancora)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { valor in
                        guard abs(valor.translation.height) > abs(valor.translation.width) else { return }
                        let delta = valor.translation.height < 0 ? 1 : -1
                        if let novo = agenda.cal.date(byAdding: .month, value: delta, to: agenda.ancora) {
                            withAnimation(CalendarioTema.morph(reduceMotion)) {
                                agenda.ir(dia: novo)
                            }
                        }
                    }
            )
            Spacer(minLength: 0)
        }
        .padding(.bottom, 160)
        .accessibilityIdentifier("calendario-mes")
    }

    private func celula(_ dia: Date, mes: Date) -> some View {
        let noMes = Calendario.mesmoMes(dia, mes, agenda.cal)
        let activo = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let naSemana = agenda.semana.contains { Calendario.mesmoDia($0, dia, agenda.cal) }
        let doDia = agenda.eventos(no: dia)
        let visiveis = Array(doDia.prefix(2))
        let extra = doDia.count - visiveis.count

        return Button {
            Toque.selecao()
            withAnimation(CalendarioTema.morph(reduceMotion)) {
                agenda.ir(dia: dia)
            }
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(Calendario.formatar(dia, "d", agenda.cal))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(
                        activo ? .white
                            : (noMes ? CalendarioTema.tinta : CalendarioTema.tintaFraca)
                    )
                    .frame(width: 28, height: 28)
                    .background {
                        if activo {
                            Circle().fill(CalendarioTema.chipActivo)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(visiveis) { evento in
                    Text(evento.titulo)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(CalendarioTema.tinta(de: evento.categoria))
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            CalendarioTema.fundo(de: evento.categoria),
                            in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                }
                if extra > 0 {
                    Text("+\(extra)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(CalendarioTema.trabalhoTinta)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        }
        .buttonStyle(PressaoDiscreta())
        .matchedGeometryEffect(
            id: naSemana
                ? idDia(dia)
                : "mes-\(Calendario.formatar(mes, "yyyy-MM", agenda.cal))-\(idDia(dia))",
            in: morph,
            isSource: agenda.escala == .mes
        )
        .opacity(noMes ? 1 : 0.45)
    }

    private func idDia(_ dia: Date) -> String {
        "dia-\(Int(Calendario.inicioDoDia(dia, agenda.cal).timeIntervalSince1970))"
    }
}

struct CalendarioAnoView: View {
    @Bindable var agenda: CalendarioAgenda
    var morph: Namespace.ID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 20) {
                ForEach(agenda.meses, id: \.self) { mes in
                    mesMini(mes)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 180)
        }
        .accessibilityIdentifier("calendario-ano")
    }

    private func mesMini(_ mes: Date) -> some View {
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
                Text(Calendario.formatar(mes, "MMM", agenda.cal).uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(actual ? CalendarioTema.tinta : CalendarioTema.tintaSuave)
                VStack(spacing: 1) {
                    ForEach(0..<6, id: \.self) { linha in
                        HStack(spacing: 1) {
                            ForEach(0..<7, id: \.self) { col in
                                let i = linha * 7 + col
                                let dia = celulas.indices.contains(i) ? celulas[i] : mes
                                celulaAno(dia, mes: mes)
                            }
                        }
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if actual {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CalendarioTema.chipActivo, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(PressaoDiscreta())
        .matchedGeometryEffect(id: actual ? "mes-actual" : "mes-\(Calendario.formatar(mes, "yyyy-MM", agenda.cal))", in: morph)
        .accessibilityLabel(Calendario.formatar(mes, "MMMM yyyy", agenda.cal))
        .accessibilityIdentifier(actual ? "calendario-ano-actual" : "calendario-ano-\(Calendario.formatar(mes, "yyyy-MM", agenda.cal))")
    }

    private func celulaAno(_ dia: Date, mes: Date) -> some View {
        let noMes = Calendario.mesmoMes(dia, mes, agenda.cal)
        let ancora = Calendario.mesmoDia(dia, agenda.ancora, agenda.cal)
        let tem = noMes && !agenda.eventos(no: dia).isEmpty
        let numero = agenda.cal.component(.day, from: dia)
        return Text("\(numero)")
            .font(.system(size: 8, weight: ancora ? .bold : .medium))
            .foregroundStyle(
                ancora && noMes ? .white
                    : (noMes ? CalendarioTema.tinta : CalendarioTema.tintaFraca)
            )
            .frame(maxWidth: .infinity, minHeight: 12)
            .background {
                if ancora && noMes {
                    Circle().fill(CalendarioTema.chipActivo)
                } else if tem {
                    Circle().fill(CalendarioTema.trabalho)
                }
            }
            .opacity(noMes ? 1 : 0.35)
    }
}
