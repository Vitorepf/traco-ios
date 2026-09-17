import SwiftData
import SwiftUI
import UIKit

struct CalendarioFichaView: View {
    @State var evento: EventoCalendario
    @Bindable var agenda: CalendarioAgenda
    @Environment(\.dismiss) private var dismiss
    @FocusState private var tituloEmFoco: Bool
    @State private var seletorAberto: String?
    @State private var confirmarApagar = false
    // ADR 04w: o que a mente já pensou sobre isto, antes do ato
    @Query private var notas: [Nota]
    @State private var doCaderno: [Nota] = []
    private var consulta: String { DoCadernoView.consulta(titulo: evento.titulo, notas: evento.notas) }

    private var jaExiste: Bool { agenda.eventos.contains { $0.id == evento.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // título à esquerda, como todo título do app (era centrado —
                // a única folha centrada da casa)
                TextField("Título", text: $evento.titulo, axis: .vertical)
                    .font(Tema.tituloTela)
                    .tracking(Tema.trackingTitulo)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .foregroundStyle(CalendarioTema.tinta)
                    .focused($tituloEmFoco)
                    .padding(.top, 4)
                    .accessibilityIdentifier("ficha-titulo")

                secao("Quando") {
                    VStack(spacing: 0) {
                        Toggle("Dia inteiro", isOn: Binding(
                            get: { evento.diaInteiro },
                            set: { todo in
                                evento.diaInteiro = todo
                                // a lista do dia inteiro é outra: 30 min antes
                                // de "o dia todo" não quer dizer nada (ADR 04a)
                                if todo, let m = evento.avisoMinutos, m != 0, m < 1440 {
                                    evento.avisoMinutos = 0
                                }
                                if todo {
                                    evento.inicio = Calendario.inicioDoDia(evento.inicio, agenda.cal)
                                    evento.fim = Calendario.hora(24, 0, no: evento.inicio, agenda.cal)
                                } else {
                                    evento = evento.comInicio(Calendario.hora(9, 0, no: evento.inicio, agenda.cal))
                                    evento.fim = evento.inicio.addingTimeInterval(3600)
                                }
                            }
                        ))
                        .tint(CalendarioTema.chipActivo)
                        .padding(.vertical, 12)
                        divisoria
                        // série: a data é o COMEÇO dela, não "o dia" — dizer
                        // "Data" numa coisa que acontece toda sexta é mentira
                        linhaDeData(evento.repete ? "A partir de" : "Data", selection: Binding(
                            get: { evento.inicio },
                            set: { evento = evento.movido(paraODiaDe: $0, agenda.cal) }
                        ), componentes: .date)
                        divisoria
                        repeticao
                        if !evento.diaInteiro {
                            divisoria
                            linhaDeData("Começa", selection: Binding(
                                get: { evento.inicio },
                                set: { evento = evento.comInicio($0) }
                            ), componentes: .hourAndMinute)
                            divisoria
                            linhaDeData("Termina", selection: Binding(
                                get: { evento.fim },
                                set: { evento = evento.comFim($0) }
                            ), componentes: .hourAndMinute)
                            // "Duração" saiu: Começa e Termina já a dizem
                        }
                    }
                    .font(.callout)
                    .tint(CalendarioTema.tinta)
                    .cartao(.campo, recuo: .horizontal)
                }

                // ADR 2026-09-04a: a seção que faltava. O motor avisava desde
                // a ADR 03d e a tela nunca disse uma palavra — para o autor,
                // isso é idêntico a não avisar.
                secao("Aviso") {
                    VStack(spacing: 0) {
                        Menu {
                            ForEach(opcoesDeAviso, id: \.self) { minutos in
                                Button {
                                    evento.avisoMinutos = minutos
                                    Toque.selecao()
                                } label: {
                                    if evento.avisoMinutos == minutos {
                                        Label(Aviso.nome(minutos, diaInteiro: evento.diaInteiro),
                                              systemImage: "checkmark")
                                    } else {
                                        Text(Aviso.nome(minutos, diaInteiro: evento.diaInteiro))
                                    }
                                }
                            }
                        } label: {
                            LinhaQueAbre("Avisar", valor: Aviso.nome(evento.avisoMinutos, diaInteiro: evento.diaInteiro)) {
                                Image(systemName: evento.avisoMinutos == nil ? "bell.slash" : "bell.fill")
                                    .font(.footnote)
                                    .foregroundStyle(evento.avisoMinutos == nil
                                                     ? CalendarioTema.tintaSuave : CalendarioTema.tinta)
                            }
                        }
                        .accessibilityIdentifier("ficha-aviso")
                        .accessibilityLabel("Avisar: \(Aviso.nome(evento.avisoMinutos, diaInteiro: evento.diaInteiro))")

                        // A promessa passa pelo mesmo tipo da folha do Trabalho
                        // (`PromessaDoAviso`): hora passada e avisos desligados
                        // calam a frase, em vez de prometer o que não vai tocar.
                        let promessa = PromessaDoAviso.para(
                            minutos: evento.avisoMinutos, estado: agenda.estadoDosAvisos,
                            hora: Aviso.promessa(de: evento, agenda.cal, manha: Ancora.hora(.manha)) ?? "",
                            instante: Aviso.instante(de: evento, agenda.cal, manha: Ancora.hora(.manha)),
                            repete: evento.repete)
                        switch promessa {
                        case .semAviso:
                            EmptyView()
                        case .toca, .seDeixarem, .jaPassou:
                            divisoria
                            Text(promessa.texto)
                                .font(.footnote)
                                .foregroundStyle(promessa == .jaPassou ? CalendarioTema.aviso : CalendarioTema.tintaSuave)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .accessibilityIdentifier("ficha-aviso-promessa")
                        case .desligados:
                            // ADR 03e: permissão negada não é beco — a tela diz, e
                            // dá a única volta que o iOS permite
                            divisoria
                            VStack(alignment: .leading, spacing: 8) {
                                Text(promessa.texto)
                                    .font(.footnote)
                                    .foregroundStyle(CalendarioTema.aviso)
                                Button("Abrir os Ajustes") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(CalendarioTema.tinta)
                                .underline()
                                .frame(minHeight: Tema.alvo, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4)
                            .accessibilityIdentifier("ficha-aviso-negado")
                        }

                        if agenda.ultimoAviso == .semEspaco, evento.avisoMinutos != nil {
                            divisoria
                            Text("O iPhone guarda \(Avisos.teto) avisos e já estão todos ocupados. Este ficou sem alarme.")
                                .font(.footnote)
                                .foregroundStyle(CalendarioTema.aviso)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                        }
                    }
                    .font(.callout)
                    .cartao(.campo, recuo: .horizontal)
                }

                // ADR 04a/05f: o domínio é ATRIBUTO do compromisso, não ação do
                // cabeçalho (critique-visual-hierarchy); no editor do iOS o
                // cabeçalho tem só sair e concluir (jakobs-law)
                secao("Domínio") {
                    ChipDominio(atual: evento.dominio, tingido: true) { evento.dominio = $0 }
                        .accessibilityIdentifier("ficha-dominio")
                }

                secao("Notas") {
                    TextField("Algo a lembrar", text: $evento.notas, axis: .vertical)
                        .font(.callout)
                        .lineLimit(2...6)
                        .cartao(.campo)
                        .accessibilityIdentifier("ficha-notas")
                }

                if !doCaderno.isEmpty {
                    DoCadernoView(vizinhas: doCaderno) { uuid in
                        agenda.guardar(evento)
                        dismiss()
                        agenda.aoAbrirNota?(uuid)
                    }
                }

                if jaExiste {
                    // apagar pede confirmação (auditoria 16/09 noite: sumia na hora, sem volta)
                    Button {
                        confirmarApagar = true
                    } label: {
                        Text("Apagar compromisso")
                            .font(CalendarioTema.chrome)
                            .foregroundStyle(CalendarioTema.aviso)
                            .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                    }
                    .buttonStyle(.discreto)
                    .accessibilityIdentifier("ficha-apagar")
                    .confirmationDialog("Apagar este compromisso?", isPresented: $confirmarApagar, titleVisibility: .visible) {
                        Button("Apagar", role: .destructive) {
                            agenda.apagar(evento.id)
                            dismiss()
                        }
                        Button("Manter", role: .cancel) {}
                    }
                }
            }
            .padding(CalendarioTema.margem)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        // ✕ e Pronto ficam fora da rolagem: rolando a ficha, sumiam (auditoria 16/09 noite)
        .safeAreaInset(edge: .top, spacing: 0) {
            CabecalhoDeFolha(aoSair: { dismiss() }, concluir: {
                agenda.guardar(evento)
                dismiss()
            }, prefixo: "ficha")
            .padding(.horizontal, CalendarioTema.margem)
            .padding(.top, 8)
            .background(CalendarioTema.fundo)
        }
        .background(CalendarioTema.fundo.ignoresSafeArea())
        .foregroundStyle(CalendarioTema.tinta)
        .environment(\.locale, Locale(identifier: "pt_BR"))
        .preferredColorScheme(.light)
        .onAppear {
            if evento.titulo.isEmpty { tituloEmFoco = true }
            agenda.lerEstadoDosAvisos()
        }
        .task(id: consulta) { doCaderno = await DoCadernoView.procurar(consulta, entre: notas) }
    }

    /// Dia inteiro não tem "minutos antes" que signifiquem coisa: ou cobra na
    /// âncora da manhã, ou na véspera, ou cala (ADR 04a).
    private var opcoesDeAviso: [Int?] {
        evento.diaInteiro ? Aviso.opcoesDiaInteiro : Aviso.opcoes
    }

    /// A2: dá para LIGAR a repetição, não só tirar. Antes, série só nascia da
    /// frase — quem marcasse pela ficha não tinha caminho nenhum para repetir.
    private var repeticao: some View {
        VStack(alignment: .leading, spacing: 8) {
            // os sete dias só aparecem quando há repetição ou quando a pessoa
            // toca a linha para marcar uma: "não repete" com sete chips em
            // baixo era decisão oferecida sem ser pedida (laço de 14/09)
            Button {
                Toque.selecao()
                withAnimation(Tema.gaveta(reduzido: reduceMotion)) { editandoRepeticao.toggle() }
            } label: {
                HStack {
                    Text("Repete")
                    Spacer()
                    Text(evento.repete
                         ? Calendario.diasEmLetras(evento.repeteEm, agenda.cal)
                         : "Não repete")
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .accessibilityIdentifier("ficha-repete-dias")
                    // o mesmo sinal das outras linhas que abrem escolha (auditoria 16/09 noite)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.semibold))
                        .padding(.leading, -4)
                        .foregroundStyle(CalendarioTema.tintaSuave)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.discreto)
            .accessibilityHint("Abre os dias da semana")
            if editandoRepeticao || evento.repete {
            HStack(spacing: 6) {
                ForEach(diasDaSemana, id: \.numero) { dia in
                    let ligado = evento.repeteEm.contains(dia.numero)
                    Button {
                        Toque.selecao()
                        if ligado {
                            evento.repeteEm.removeAll { $0 == dia.numero }
                        } else {
                            evento.repeteEm = (evento.repeteEm + [dia.numero]).sorted()
                        }
                    } label: {
                        Text(dia.letra)
                            .font(CalendarioTema.dia)
                            .foregroundStyle(ligado ? .white : CalendarioTema.tintaSuave)
                            .frame(width: 32, height: 32)
                            .background(ligado ? CalendarioTema.chipActivo : CalendarioTema.chip, in: Circle())
                            .frame(height: Tema.alvo)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.discreto)
                    .accessibilityLabel(dia.nome)
                    .accessibilityAddTraits(ligado ? [.isButton, .isSelected] : .isButton)
                    .accessibilityIdentifier("ficha-repete-\(dia.numero)")
                }
            }
            .transition(.identity)
            }
        }
        .padding(.vertical, 12)
        .accessibilityIdentifier("ficha-repete")
    }

    /// Os sete dias na ordem da semana do autor (domingo ou segunda primeiro).
    @State private var editandoRepeticao = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var diasDaSemana: [(numero: Int, letra: String, nome: String)] {
        Calendario.semana(da: Date(timeIntervalSince1970: 0), agenda.cal).map { dia in
            (agenda.cal.component(.weekday, from: dia),
             Calendario.letraDoDia(dia, agenda.cal),
             Calendario.formatar(dia, "EEEE", agenda.cal))
        }
    }

    private var divisoria: some View {
        Rectangle().fill(CalendarioTema.linha).frame(height: 1)
    }

    /// A data e a hora na MESMA linha das outras (título, valor em tinta
    /// suave, seta) — o seletor do sistema, com a sua pílula cinza, era a
    /// única caixa da ficha. Tocar a linha abre o seletor LOGO ABAIXO, como no
    /// Calendário do iPhone; tocar de novo fecha. (Um seletor invisível por
    /// cima do valor não recebia o toque no iOS 26.)
    private func linhaDeData(_ titulo: String, selection: Binding<Date>,
                             componentes: DatePickerComponents) -> some View {
        let aberto = seletorAberto == titulo
        return VStack(spacing: 0) {
            Button {
                Toque.selecao()
                withAnimation(CalendarioTema.morph(reduceMotion)) {
                    seletorAberto = aberto ? nil : titulo
                }
            } label: {
                HStack {
                    Text(titulo)
                    Spacer()
                    HStack(spacing: 4) {
                        Text(componentes == .date
                             ? selection.wrappedValue.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
                             : selection.wrappedValue.formatted(date: .omitted, time: .shortened))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(aberto ? CalendarioTema.tinta : CalendarioTema.tintaSuave)
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.linha)
            .accessibilityLabel(titulo)
            .accessibilityValue(selection.wrappedValue.formatted(date: componentes == .date ? .abbreviated : .omitted,
                                                               time: componentes == .date ? .omitted : .shortened))
            if aberto {
                Group {
                    if componentes == .date {
                        DatePicker("", selection: selection, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    } else {
                        DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                    }
                }
                .labelsHidden()
                .tint(CalendarioTema.tinta)
                .frame(maxWidth: .infinity)
                .transition(Tema.transicao(.opacity, reduzido: reduceMotion))
            }
        }
    }

    private func secao<Conteudo: View>(_ titulo: String, @ViewBuilder _ conteudo: () -> Conteudo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .rotulo(Tema.tintaSuave)
            conteudo()
        }
    }

}
