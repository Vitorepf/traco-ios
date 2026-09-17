import AVFoundation
import UIKit
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct CadernoView: View {
    /// A barra de ações da página viaja DENTRO deste mesmo inset: uma barra
    /// deslizando e outra aparecendo por opacidade se atravessavam no ar.
    var rodape: AnyView?
    /// Campos da forma — abaixo do texto, não numa folha que some ao reabrir.
    var abaixo: AnyView? = nil
    /// Acima da régua: o aviso, o cartão da análise, a linha "lendo…". Entra e
    /// sai sem mover a régua nem as ações — o pé é desenho do dono (ADR 05f) e
    /// não some sob o dedo (V9: o toque em "Todas" caía no cartão).
    var acima: AnyView? = nil
    /// Só em tamanhos AX: o cartão e a régua não cabem juntos na mesma tela
    /// (AX5 + régua + cartão com três saídas deixava uma letra do autor à
    /// vista); a régua, que já segue o foco, cede ao cartão.
    var esconderRegua: Bool = false
    /// A folha dos campos está a subir ou em cena: o encaixe inteiro sai por
    /// corte — a régua também, porque o foco NÃO cai quando a folha sobe (o
    /// teclado desce sem o SwiftUI soltar o `FocusState`), e a régua descendo
    /// com o teclado deixava o "Todas" legível sobre os campos do papel por
    /// ~100 ms (V12-E, quadros nativos).
    var folhaEmCena: Bool = false
    @Binding var texto: String
    var foco: FocusState<Bool>.Binding
    var folga: CGFloat
    @Binding var abrirArquivo: Bool
    /// O "+" da página pediu a folha de desenho.
    @Binding var abrirDesenho: Bool
    /// §17 × dedo em voo: o toque na régua avisa a sessão para SEGURAR o vestir
    /// automático — a forma não veste no meio do alcance e o chip não salta.
    var aoTocarRegua: ((Bool) -> Void)? = nil
    /// Q2: os títulos das outras notas, para completar `[[assim]]` ao digitar.
    /// Sem isto, ligar duas notas exigia decorar o título — e a lei do dono é
    /// que ele nunca deve ter de lembrar de nada.
    var titulosParaLigar: [String] = []
    var aoMudar: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var editando: String?
    // Enter no título/parágrafo troca o campo focado: se o FocusState cair na
    // troca, esta flag devolve o foco ao editor que nasce (medido em 01/set:
    // sem ela o teclado descia no meio da descida para o corpo)
    @State private var descendoDoTitulo = false
    @State private var unaCrua = false
    @State private var foto: PhotosPickerItem?
    @State private var video: PhotosPickerItem?
    @State private var menuFoto = false
    @State private var menuDesenho = false
    @State private var menuVideo = false
    @State private var importaAudio = false
    @State private var importaFicheiro = false
    @State private var menuArquivo = false
    @State private var menuLingua = false
    @State private var gravando = false
    @State private var gravador: AVAudioRecorder?
    /// Altura desta view — com o teclado de pé, a tela menos o teclado.
    @State private var alturaDisponivel: CGFloat = 0
    @State private var alturaDoPe: CGFloat = 0
    /// A régua entra e sai POR CORTE, fora da transação em que o foco muda:
    /// dentro de uma transação animada o SwiftUI segura a régua removida até o
    /// fim da animação, e o "Todas" ficava no lugar enquanto o pé descia
    /// (resíduo medido na V12-D). Com o papel agora dono da faixa, ficaria
    /// sobre texto.
    @State private var reguaEmCena = false
    /// Três linhas de corpo: o piso declarado do papel (ADR 05y).
    @ScaledMetric(relativeTo: .body) private var pisoDoPapel: CGFloat = 92

    private var fatias: [FatiaCaderno] { Caderno.fatias(texto) }

    private var soProsa: Bool {
        fatias.allSatisfy {
            if case .paragrafo = $0.bloco { return true }
            return false
        }
    }

    @ViewBuilder
    private var paginaCaderno: some View {
        if let una = Caderno.paginaUna(texto)
            ?? (unaCrua && foco.wrappedValue && Caderno.soProsaELista(texto)
                ? FatiaCaderno(id: "una-crua", bloco: .paragrafo(texto), fonte: texto, aberto: true)
                : nil) {
            paginaUna(una)
        } else {
            paginaFatias
        }
    }

    /// UM ramo só, e é isso que importa aqui. Antes havia dois — com e sem
    /// `abaixo` —, e vestir a forma cria os campos: o ramo trocava, o SwiftUI
    /// recriava o EDITOR, o foco caía, o teclado descia e o encaixe inteiro era
    /// redesenhado noutra geometria. O que se via era o pé do cartão e o pé da
    /// página dissolvidos sobre o texto do cartão, ~165 ms (Re-G3 da V12,
    /// `v12reg3-cruzamento-cartao-rm.png`). Com um ramo só o editor mantém
    /// identidade e FOCO: o teclado não desce, e o encaixe só cresce.
    /// A diferença entre os dois casos virou VALOR, não estrutura: sem campos o
    /// editor ocupa a altura toda (o papel inteiro é alvo do cursor, como era);
    /// com campos ele cede o que não usa e os campos entram por baixo.
    private func paginaUna(_ una: FatiaCaderno) -> some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    editorUna(una)
                        .padding(.horizontal, Tema.margem)
                        // com campos, o editor cede: 160 pt sob um título de uma
                        // linha era um buraco entre o título e a forma
                        // (auditoria 15/09, capturas 05 e 47); 96 = duas linhas
                        // de corpo mais o respiro, e o papel inteiro continua
                        // tocável para escrever
                        .frame(maxWidth: .infinity, minHeight: abaixo == nil ? geo.size.height : 96,
                               alignment: .topLeading)
                    // os campos nascem CORTANDO, como a régua e o cartão: sob
                    // Reduzir Movimento nada dissolve, e o fade padrão do
                    // Optional aparecia como um véu sobre o papel (Re-G3)
                    abaixo?.transition(.identity)
                }
                .padding(.bottom, abaixo == nil ? 0 : 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .onScrollGeometryChange(for: CGFloat.self, of: { $0.containerSize.height }, action: seguirAoMudarAJanela)
        }
    }

    /// A janela do papel mudou (teclado, cartão, aviso, pé): a linha ativa tem
    /// de continuar dentro dela, NO MESMO QUADRO — esperar a volta do runloop
    /// deixa o quadro apresentado com o papel já encolhido e a linha no lugar
    /// velho (ADR 08x). A altura vai junto: o container chega um quadro ANTES
    /// dos `bounds`, e quem lê o `bounds` aqui corrige para o papel de ontem.
    private func seguirAoMudarAJanela(_: CGFloat, _ agora: CGFloat) {
        EscritaVisivel.seguirCaretAgora(folga: folga, altura: agora)
    }

    private var paginaFatias: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(fatias) { fatia in
                    fatiaNaPagina(fatia)
                        .padding(.horizontal, Tema.margem)
                }
                abaixo?.transition(.identity) // mesma lei da página una
            }
            .padding(.bottom, 28)
        }
        .scrollDismissesKeyboard(editando == nil ? .interactively : .never)
        .onScrollGeometryChange(for: CGFloat.self, of: { $0.containerSize.height }, action: seguirAoMudarAJanela)
    }

    @ViewBuilder
    private func fatiaNaPagina(_ fatia: FatiaCaderno) -> some View {
        if deveEditar(fatia) {
            editor(fatia)
        } else {
            portal(fatia)
        }
    }

    /// O pé do encaixe: régua (ou barra de ligação), linha de gravação e a
    /// barra de ações. Não depende do cartão — por isso a sua altura pode ser
    /// medida sem laço de layout e descontada do que sobra para o papel.
    private var peDoEncaixe: some View {
        // VStack EXPLÍCITO: um `@ViewBuilder` com vários filhos devolve um
        // TupleView, e um TupleView com modificador (aqui o `onGeometryChange`)
        // deixa de ser achatado pelo VStack de fora — a régua ia parar EM CIMA
        // da barra de ações, que é exatamente a sobreposição que a 05y proíbe.
        VStack(spacing: 0) { conteudoDoPe }
            // RÍGIDO. Como irmão numa pilha (V12-E) o pé recebia uma PROPOSTA, e
            // o `.frame(minHeight:)` do rodapé aceita qualquer proposta acima do
            // mínimo: a pilha do corpo dividia a tela a meio entre papel e
            // encaixe, e em AX5 com o cartão o pé (213 pt) cabia em 91 e
            // transbordava 61 pt para cada lado — sobre a linha do cartão e sob
            // o teclado (re-G4 da V12-E, B1; medido por sonda na V12-G).
            // Dentro do `.safeAreaInset` a proposta era nula e o pé valia o
            // ideal; aqui isso se declara.
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var conteudoDoPe: some View {
        if gravando {
            Button("A gravar") { pararGravacao() }
                .font(Tema.label)
                .foregroundStyle(Tema.tintaSuave)
                .frame(maxWidth: .infinity, minHeight: Tema.alvo)
                .accessibilityIdentifier("a-gravar")
                .accessibilityLabel("Parar gravação")
        }
        if reguaEmCena, let trecho = Rede.ligacaoEmVoo(texto),
           !sugestoesDeLigacao(trecho).isEmpty {
            barraDeLigacao(trecho)
                .padding(.horizontal, Tema.margem)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tema.fundo)
                .overlay(alignment: .top) {
                    Rectangle().fill(Tema.linha).frame(height: 0.5)
                }
                .transition(.identity)
        } else if reguaEmCena, !esconderRegua, !folhaEmCena {
            // A régua de formatos saiu da página (ordem do dono, 14/09: "uma
            // das piores formas para opções visuais de texto"). Título, seção
            // e lista nascem do texto pelo `Caderno.estruturar` ao concluir; o
            // catálogo continua no arquivo. O código fica até a próxima volta
            // decidir o que sobra dele.
            // sem o fio de cima: a régua ficou vazia e o fio sobrava sozinho,
            // uma linha solta sobre o pé (auditoria 16/09 noite, 01)
            regua
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.identity)
        }
        // a barra de ações da página mora AQUI: um container, uma lei.
        // A altura mínima impede o quadro VAZIO entre um ocupante sair
        // e o outro entrar (k175) — sem voltar à sobreposição.
        rodape
            .frame(minHeight: rodape == nil ? 0 : 54)
    }

    /// Quanto o encaixe pode tomar: tudo menos o pé e o piso do papel. `nil`
    /// enquanto ainda não há medida (primeiro quadro), para não achatar nada.
    /// O piso é `pisoDoPapel` — três linhas de corpo —, mas nunca mais de
    /// metade do que sobra depois do pé: em tamanhos AX três linhas de corpo
    /// não cabem com o cartão, e um piso maior que o teto deixaria o autor sem
    /// as duas saídas em vez de sem texto.
    /// E NUNCA menos de UMA linha (`piso / 3`) — ADR 09d. Metade do que sobra
    /// era pouco onde a tela é pequena e a letra grande: no iPhone 17e em
    /// AX XXXL o pé toma 275 dos 414 pt disponíveis, a metade dava 69,5 pt de
    /// papel e a linha de corpo mede 67 — não cabia em quadro nenhum, com ou
    /// sem rolagem, e o autor escrevia às cegas (18 amostras vermelhas da
    /// invariante 08f). Com o aviso o pé sobe a 327 e sobravam 43,5 pt: aí o
    /// papel toma o que sobra inteiro e o encaixe cede, porque a lei 08f é a
    /// letra do autor à vista, não a saída do cartão.
    /// Fora do `body` para ter teste (`CadernoTetoTests`).
    static func tetoDoEncaixe(altura: CGFloat, pe: CGFloat, piso: CGFloat) -> CGFloat? {
        guard altura > 0 else { return nil }
        let sobra = altura - pe
        guard sobra > 0 else { return nil }
        let doPapel = min(max(min(piso, sobra / 2), piso / 3), sobra)
        return max(0, sobra - doPapel)
    }

    private var tetoDoEncaixe: CGFloat? {
        Self.tetoDoEncaixe(altura: alturaDisponivel, pe: alturaDoPe, piso: pisoDoPapel)
    }

    /// O encaixe: o que fica acima do pé (aviso, cartão, "lendo…") e o pé.
    /// Irmão do papel na pilha do `body`, nunca por cima dele.
    private var encaixe: some View {
        VStack(spacing: 0) {
            acima
                // o cartão nunca come a página: se o que sobra não chega,
                // é o TEXTO DO CARTÃO que rola dentro do teto, nunca a
                // linha que o autor está a escrever que sai da tela. O teto
                // viaja pelo ambiente para o cartão o usar POR DENTRO (é lá
                // que a rolagem dele mora); o `.frame` aqui é a rede.
                .environment(\.tetoDoEncaixe, tetoDoEncaixe)
                // A rede NÃO PODE EXPANDIR (ADR 08f): `.frame(maxHeight:)` é flexível
                // e enchia o teto inteiro (554 pt com o teclado de pé) mesmo vazio —
                // e esta pilha é opaca, logo cobria o papel a partir da terceira
                // linha. `fixedSize` devolve à caixa a altura do ocupante; o teto
                // segue como limite e `.bottom` como lei do pé.
                .frame(maxHeight: tetoDoEncaixe, alignment: .bottom)
                .fixedSize(horizontal: false, vertical: true)
            peDoEncaixe
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { alturaDoPe = $0 }
        }
        // uma animação para a superfície inteira: os filhos trocam DENTRO
        // dela — quem anima é a ALTURA do container, não a opacidade de
        // dois irmãos que ocupam as mesmas linhas. Por isso os ocupantes
        // entram e saem por `.identity`: com `.move(edge: .bottom)` a régua
        // DESLIZAVA por cima do rodapé e ficava legível em duas posições, uma
        // delas na linha de base de "Trabalhar nisto" (G3 da V12, A1 —
        // `v12-rev-cruzamento-regua-pe.png`); o `.clipped()` é do VStack
        // inteiro e não separa irmão de irmão. Cortar aqui não perde
        // movimento: o encaixe cresce e revela, que é a lei da gaveta.
        // A régua entra e sai com o TECLADO, e o teclado já tem a sua curva:
        // uma gaveta de 0,4 s por cima de uma descida de 0,25 s são dois
        // relógios no mesmo evento, e o que se vê é o pé numa geometria e o
        // cartão noutra, os dois legíveis (A3 do G4 da V12, ~215 ms sem RM
        // no toque em "Abrir os campos"). Aqui a régua CORTA e quem carrega
        // o movimento é o teclado. A gaveta fica onde a altura muda sozinha:
        // `esconderRegua` (o cartão a chegar em AX) — e com o FOCO no papel
        // quem a desliga é a Página, porque nenhuma gaveta corre sobre a linha
        // do autor (ADR 08x).
        .animation(Tema.gaveta(reduzido: reduceMotion), value: esconderRegua)
        .clipped()
        // o papel desce até a borda: sem isto o texto rolado aparecia por
        // baixo do pé, na faixa do indicador de casa (AX5, 06/09)
        .background(Tema.fundo.ignoresSafeArea(edges: .bottom))
    }

    var body: some View {
        // A LEI DA ESCRITA VISÍVEL mora AQUI (ADR 08f, V12-E): o contêiner
        // concede ao papel e ao encaixe áreas EXCLUSIVAS — irmãos de uma pilha,
        // nenhum pixel em comum. Antes o encaixe era um `.safeAreaInset`, e o
        // ScrollView do papel corria POR BAIXO dele: o `TextEditor` julgava o
        // caret visível dentro de um frame que o pé e o cartão cobriam (G4 final
        // da V12, A2 — 0 pixels de caret em 11 amostras), e ao abrir a folha o
        // papel refluía ATRAVESSANDO o cartão (A1). Com áreas disjuntas nada do
        // papel pode desenhar sob o encaixe em quadro nenhum, por construção;
        // rolar até o caret é de `EscritaVisivel`, e `EscritaVisivelTests` mede
        // as duas coisas na Página real.
        VStack(spacing: 0) {
            // O ZStack existe para dar ao papel uma identidade que não troca.
            // `paginaCaderno` escolhe entre página una e fatias, e `paginaUna`
            // entre ter ou não ter `abaixo` — vestir a forma cria os campos e vira
            // esse ramo; com o encaixe pendurado direto no ramo, o SwiftUI trocava
            // a ÁRVORE INTEIRA e dissolvia o pé velho sobre o novo (G3 da V12, A1).
            ZStack(alignment: .top) { paginaCaderno }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            encaixe
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: foco.wrappedValue) { _, agora in
            var t = Transaction(); t.disablesAnimations = true
            withTransaction(t) { reguaEmCena = agora }
            EscritaVisivel.seguirCaret(folga: folga)
            if !agora, descendoDoTitulo {
                descendoDoTitulo = false
                foco.wrappedValue = true
            }
        }
        // a linha nova: o papel rola até o caret (só enquanto há foco). O teclado
        // a subir e o cartão a chegar disparam pela geometria do próprio
        // ScrollView, em `paginaUna`/`paginaFatias`.
        .onChange(of: texto) { _, _ in EscritaVisivel.seguirCaret(folga: folga) }
        // O PISO DO PAPEL (ADR 05y, correção do G4): o que sobra da tela depois
        // do encaixe é o trabalho do autor. A medida é a altura INTEIRA desta
        // view, que com o teclado de pé já é a tela menos o teclado — medida por
        // dentro do encaixe ela vinha descontada dele e o teto realimentava a si
        // mesmo. O pé mede-se sozinho e não depende do cartão.
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { alturaDisponivel = $0 }
        .onAppear {
            unaCrua = Caderno.paginaUna(texto) != nil
            reguaEmCena = foco.wrappedValue
        }
        // A régua segue o FOCO e mais nada. Duas tentativas de amarrá-la ao
        // teclado falharam: seguir a PRESENÇA do teclado apagava a régua inteira
        // com teclado físico (iPad, Magic Keyboard); soltar o foco no
        // keyboardWillHide matava o editor recém-aberto, porque trocar de campo
        // posta willHide antes de o novo campo assumir. O vão que o dono viu era
        // do ScrollView sem altura — já corrigido lá embaixo, na própria régua.
        .onChange(of: foco.wrappedValue) { _, f in
            // o vínculo cru se decide quando o teclado SOBE (a nota era una?);
            // ao descer, a condição do branch já solta a forma sozinha
            if f { unaCrua = Caderno.paginaUna(texto) != nil }
        }
        .onDisappear {
            if gravando { pararGravacao() }
        }
        .onChange(of: abrirArquivo) { _, pedido in
            if pedido {
                menuArquivo = true
                abrirArquivo = false
            }
        }
        .onChange(of: abrirDesenho) { _, pedido in
            if pedido {
                menuDesenho = true
                abrirDesenho = false
            }
        }
        // desenhar também é colocar o que se pensa (dono, 14/09): a folha de
        // desenho pendura a imagem na nota pelo mesmo caminho da foto
        .sheet(isPresented: $menuDesenho) {
            DesenhoView { png in gravar(dados: png, nome: "desenho.png", tipo: .png) }
        }
        .photosPicker(isPresented: $menuFoto, selection: $foto, matching: .images)
        .photosPicker(isPresented: $menuVideo, selection: $video, matching: .videos)
        .onChange(of: foto) { _, item in
            Task { await importarFoto(item) }
        }
        .onChange(of: video) { _, item in
            Task { await importarVideo(item) }
        }
        .fileImporter(isPresented: $importaAudio, allowedContentTypes: [.audio], allowsMultipleSelection: false) { resultado in
            importarResultado(resultado)
        }
        .fileImporter(isPresented: $importaFicheiro, allowedContentTypes: [.item], allowsMultipleSelection: false) { resultado in
            importarResultado(resultado)
        }
        .confirmationDialog("Anexar", isPresented: $menuArquivo, titleVisibility: .visible) {
            Button("Desenhar") { menuDesenho = true }
            Button("Foto") { menuFoto = true }
            Button("Vídeo") { menuVideo = true }
            Button("Áudio") { importaAudio = true }
            Button(gravando ? "Parar" : "Gravar") { tocarGravacao() }
            Button("Arquivo") { importaFicheiro = true }
        }
        .confirmationDialog("Língua do código", isPresented: $menuLingua, titleVisibility: .visible) {
            Button("Swift") { transformarCodigo("swift") }
            Button("JSON") { transformarCodigo("json") }
            Button("JavaScript") { transformarCodigo("javascript") }
            Button("TypeScript") { transformarCodigo("typescript") }
            Button("Python") { transformarCodigo("python") }
            Button("Rust") { transformarCodigo("rust") }
            Button("Go") { transformarCodigo("go") }
            Button("HTML") { transformarCodigo("html") }
            Button("CSS") { transformarCodigo("css") }
            Button("SQL") { transformarCodigo("sql") }
            Button("Shell") { transformarCodigo("bash") }
            Button("Texto") { transformarCodigo("texto") }
        }
    }

    private func sugestoesDeLigacao(_ trecho: String) -> [String] {
        Rede.sugestoes(para: trecho, entre: titulosParaLigar)
    }

    /// A régua cede o lugar: enquanto se escreve uma ligação, o rodapé mostra
    /// os títulos que casam. Um toque fecha o `]]` — o autor nunca digita o
    /// título inteiro nem precisa lembrar dele.
    private func barraDeLigacao(_ trecho: String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sugestoesDeLigacao(trecho), id: \.self) { titulo in
                    Pilula(forma: .filtro, acao: {
                        Toque.selecao()
                        texto = Rede.completar(texto, com: titulo)
                        aoMudar()
                    }) { Text(titulo).lineLimit(1) }
                    .accessibilityIdentifier("ligar-\(titulo)")
                }
                Color.clear.frame(width: 4)
            }
        }
        .frame(height: Tema.alvo)
        .accessibilityLabel("Notas para ligar")
        .accessibilityIdentifier("barra-ligacao")
    }

    private var regua: some View {
        // Nada aqui (dono, 14/09: "qual aplicativo tem um botão só para
        // fechar o teclado?"). O teclado recolhe pelo arrasto da página. O
        // encaixe fica com 1 pt para o papel continuar a medir a janela do
        // teclado como antes (portão da escrita visível).
        Color.clear.frame(height: 1)
            .accessibilityHidden(true)
    }

    private func editorUna(_ fatia: FatiaCaderno) -> some View {
        let eLista = if case .itens = fatia.bloco { true } else { false }
        let eTarefa = if case .tarefas = fatia.bloco { true } else { false }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        let eTabela = if case .tabela = fatia.bloco { true } else { false }
        let nivel = if case .titulo(let n, _) = fatia.bloco { n } else { 0 }
        let eSeccao = nivel == 2
        let eSub = nivel == 3
        let eTituloCapa = nivel == 1
        let mostraSinal = eTabela || eSeccao || eSub
        let nomeSinal = eSeccao ? "seção" : eSub ? "subseção" : "tabela"
        return VStack(alignment: .leading, spacing: 0) {
            SinalTipo(nome: nomeSinal)
                .opacity(mostraSinal ? 1 : 0)
                .frame(height: mostraSinal ? 18 : 0)
                .padding(.bottom, mostraSinal ? 8 : 0)
                .accessibilityHidden(!mostraSinal)
            // lista digita CRUA no mesmo campo (o cursor nunca troca de árvore);
            // ao soltar o teclado, veste a forma
            if eLista, !foco.wrappedValue,
               !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ProsaView(bloco: fatia.bloco)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { foco.wrappedValue = true }
            } else {
                linhaEditor(fatia)
            }
        }
        .padding(eCitacao ? 12 : 0)
        .background(eCitacao ? Tema.superficie : .clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityIdentifier(
            eLista ? "portal-lista"
                : eTarefa ? "portal-tarefa"
                : eTabela ? "portal-tabela"
                : eCitacao ? "portal-citacao"
                : eSeccao ? "portal-seccao"
                : eSub ? "portal-subseccao"
                : eTituloCapa ? "portal-titulo"
                : "pagina"
        )
    }

    private func linhaEditor(_ fatia: FatiaCaderno) -> some View {
        let eTarefa = if case .tarefas = fatia.bloco { true } else { false }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        let feito = if case .tarefas(let xs) = fatia.bloco { xs.first?.feito == true } else { false }
        return HStack(alignment: .top, spacing: eTarefa || eCitacao ? 12 : 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(Tema.tintaFraca)
                        .frame(width: 2, height: 28)
                        .opacity(eCitacao ? 1 : 0)
                    VistoDaTarefa(feito: feito, alternar: {
                        guard case .tarefas(let xs) = fatia.bloco else { return }
                        var next = xs.isEmpty ? [TarefaCaderno(feito: false, texto: "")] : xs
                        next[0].feito.toggle()
                        texto = Caderno.aplicar(fatias, id: fatia.id, bloco: .tarefas(next))
                        aoMudar()
                    })
                    .opacity(eTarefa ? 1 : 0)
                    .allowsHitTesting(eTarefa)
                    .accessibilityHidden(!eTarefa)
                }
                .frame(width: eTarefa || eCitacao ? (eTarefa ? Tema.alvo : 20) : 0)
                campoUna(fatia)
        }
    }

    private func campoUna(_ fatia: FatiaCaderno) -> some View {
        let nivel = if case .titulo(let n, _) = fatia.bloco { n } else { 0 }
        let feito = if case .tarefas(let xs) = fatia.bloco { xs.first?.feito == true } else { false }
        let eCitacao = if case .citacao = fatia.bloco { true } else { false }
        // lista não projeta: edita o documento cru e o Enter herda o marcador
        let projeta = switch fatia.bloco {
        case .paragrafo, .itens: false
        default: true
        }
        return TextEditor(text: Binding(
            get: {
                if projeta {
                    return Caderno.textoVisivel(fatia.bloco)
                }
                return texto
            },
            set: { novo in
                // clobber de teardown: quando a régua transforma o documento, o
                // campo velho morre na troca de branch e tenta reescrever o texto
                // antigo por cima — um escrito de um campo que já não representa
                // o documento é descartado
                let vivo = Caderno.paginaUna(texto)
                if projeta {
                    guard vivo?.id == fatia.id else { return }
                    // Enter no título una desce para o corpo: a cabeça fica
                    // título, o cursor nasce no parágrafo da cauda (mesma
                    // receita do multi: editando + flag de rearme do foco)
                    if case .titulo(let n, _) = fatia.bloco, let corte = novo.firstIndex(of: "\n") {
                        let cabeca = String(novo[..<corte])
                        let resto = String(novo[novo.index(after: corte)...])
                        texto = Caderno.aplicar(
                            fatias, id: fatia.id,
                            novo: Caderno.serializar(.titulo(n, cabeca)) + "\n\n" + resto
                        )
                        editando = Caderno.fatias(texto).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id
                        descendoDoTitulo = true
                        aoMudar()
                        return
                    }
                    texto = Caderno.aplicar(fatias, id: fatia.id, bloco: Caderno.comTexto(fatia.bloco, novo))
                } else {
                    guard vivo != nil || (foco.wrappedValue && Caderno.soProsaELista(texto)) else { return }
                    texto = Caderno.continuar(velho: texto, novo: novo)
                }
                aoMudar()
            }
        ))
        .font(nivel == 1 ? Tema.tituloNota : nivel >= 2 ? Tema.secaoNota : eCitacao ? Tema.corpo.italic() : Tema.corpo)
        .lineSpacing(nivel > 0 ? 4 : folga)
        .tracking(nivel == 1 ? -0.4 : nivel >= 2 ? -0.2 : -0.05)
        .foregroundStyle(feito ? Tema.tintaFraca : Tema.tinta)
        .strikethrough(feito, color: Tema.tintaFraca)
        .scrollContentBackground(.hidden)
        .focused(foco)
        .tint(Tema.ambar)
        // o recuo interno do TextEditor punha a prosa num degrau à direita do
        // rótulo da data (26pt vs 24pt medidos) — mesmo conserto do Recordar
        .padding(.horizontal, -Tema.sangriaEditor)
        .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
        .id("pagina-una")
        .accessibilityLabel(
            nivel == 1 ? "Título"
                : nivel == 2 ? "Seção"
                : nivel == 3 ? "Subseção"
                : eCitacao ? "Citação"
                : "Página"
        )
        .accessibilityIdentifier("pagina")
    }

    @ViewBuilder
    private func portal(_ fatia: FatiaCaderno) -> some View {
        switch fatia.bloco {
        case .codigo(let lingua, let fonte) where lingua == "tex" || lingua == "latex":
            PortalFormulaView(fonte: fonte)
                .onTapGesture { editar(fatia) }
        case .codigo(let lingua, let fonte):
            PortalCodigoView(lingua: lingua, fonte: fonte)
                .onTapGesture { editar(fatia) }
        case .imagem, .audio, .video, .arquivo:
            PortalArquivoView(bloco: fatia.bloco, aoApagar: { apagarAnexo(fatia) })
        case .tarefas:
            ProsaView(bloco: fatia.bloco, aoAlternarTarefa: { i in alternarTarefa(fatia, i) })
                .onTapGesture { editar(fatia) }
        case .divisoria:
            ProsaView(bloco: fatia.bloco)
        case .paragrafo(let t) where t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            Color.clear
                .frame(maxWidth: .infinity, minHeight: Tema.alvo, alignment: .topLeading)
                .contentShape(Rectangle())
                .onTapGesture { editar(fatia) }
                .accessibilityIdentifier("pagina")
        default:
            ProsaView(bloco: fatia.bloco)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture { editar(fatia) }
        }
    }

    private func deveEditar(_ fatia: FatiaCaderno) -> Bool {
        if let editando {
            return fatia.id == editando
        }
        if fatia.aberto, case .paragrafo(let t) = fatia.bloco {
            return !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }

    private func editor(_ fatia: FatiaCaderno) -> some View {
        EditorBlocoView(
            bloco: fatia.bloco,
            folga: folga,
            foco: foco,
            aoMudar: { bloco in
                // Enter no título ou no parágrafo desce para um bloco NOVO
                // (Notes): o \n parte o texto no corte, o resto nasce parágrafo
                // e o cursor vai atrás por adoção — o editor seguinte nasce no
                // MESMO ciclo, vinculado ao mesmo foco, e o teclado nunca desce
                // decide pela FATIA editada, não pelo bloco que chega: o editor
                // de lista envia .paragrafo(cru multilinha) pelo caminho do
                // continuar, e parti-lo no primeiro \n mutilava a lista
                let eTituloOuParagrafo = switch fatia.bloco {
                case .titulo, .paragrafo: true
                default: false
                }
                let quebra: (novo: String, corte: String.Index)? = if eTituloOuParagrafo {
                    switch bloco {
                    case .titulo(_, let t): t.firstIndex(of: "\n").map { (t, $0) }
                    case .paragrafo(let t): t.firstIndex(of: "\n").map { (t, $0) }
                    default: nil
                    }
                } else {
                    nil
                }
                if let (t, corte) = quebra {
                    let cabeca = String(t[..<corte])
                    let resto = String(t[t.index(after: corte)...])
                    let cabecote: BlocoCaderno = if case .titulo(let n, _) = bloco {
                        .titulo(n, cabeca)
                    } else {
                        .paragrafo(cabeca)
                    }
                    let posicao = fatias.firstIndex { $0.id == fatia.id }
                    texto = Caderno.aplicar(
                        fatias, id: fatia.id,
                        novo: Caderno.serializar(cabecote) + "\n\n" + resto
                    )
                    if let p = posicao {
                        editando = Caderno.fatias(texto).dropFirst(p + 1).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id ?? editando
                    }
                    descendoDoTitulo = true
                    aoMudar()
                    return
                }
                // saída da lista (double-Enter): o continuar removeu o
                // marcador e deixou "\n" à cauda — o cursor desce para o
                // parágrafo seguinte, como no título
                if case .itens = fatia.bloco, case .paragrafo(let t) = bloco, t.hasSuffix("\n") {
                    let posicao = fatias.firstIndex { $0.id == fatia.id }
                    texto = Caderno.aplicar(fatias, id: fatia.id, novo: t)
                    if let p = posicao {
                        editando = Caderno.fatias(texto).dropFirst(p + 1).first {
                            if case .paragrafo = $0.bloco { true } else { false }
                        }?.id ?? editando
                    }
                    descendoDoTitulo = true
                    aoMudar()
                    return
                }
                // a primeira tecla no corpo confirma a adoção do foco: a
                // flag da descida já cumpriu o papel e não pode sobrar armada
                // (sobrando, o rearme brigaria com a próxima dispensa do teclado)
                descendoDoTitulo = false
                texto = Caderno.aplicar(fatias, id: fatia.id, bloco: bloco)
                aoMudar()
            },
            aoLingua: { menuLingua = true }
        )
    }

    private func editar(_ fatia: FatiaCaderno) {
        editando = fatia.id
        Task { @MainActor in
            foco.wrappedValue = true
        }
    }

    private func transformarCodigo(_ lingua: String) {
        transformar(PapelForma(slug: "codigo", nome: "Código", gesto: .codigo(lingua: lingua), cromo: .padrao))
    }

    private func transformar(_ papel: PapelForma) {
        if case .codigo(let lingua) = papel.gesto, lingua == nil {
            menuLingua = true
            Toque.leve()
            return
        }
        if soProsa {
            transformarProsa(papel)
        } else {
            transformarFatia(papel)
        }
        Toque.leve()
        Task { @MainActor in
            foco.wrappedValue = true
        }
        aoMudar()
    }

    private func transformarProsa(_ papel: PapelForma) {
        let (antes, ultimo) = Caderno.partirUltimo(texto)
        if insereNovo(papel) {
            let bloco = bloco(de: papel, texto: "")
            let prosa = ultimo.trimmingCharacters(in: .whitespacesAndNewlines)
            if prosa.isEmpty {
                texto = Caderno.juntar(antes, bloco)
            } else {
                texto = Caderno.juntar(Caderno.juntar(antes, .paragrafo(ultimo)), bloco)
            }
            abrirUltimo(de: papel)
        } else {
            texto = Caderno.juntar(antes, bloco(de: papel, texto: ultimo))
            // vestir a forma NÃO expulsa quem escreve. Com texto na linha, o
            // editor fechava (editando = nil), o teclado descia junto e a régua
            // ia com ele: o autor tocava VERSO e perdia a escrita. A prosa veste
            // ao SOLTAR o teclado, não ao formatar.
            abrirUltimo(de: papel)
        }
    }

    private func transformarFatia(_ papel: PapelForma) {
        guard let alvo = fatiaAlvo else {
            texto = Caderno.juntar(texto, bloco(de: papel, texto: ""))
            abrirUltimo(de: papel)
            return
        }
        let visivel = Caderno.textoVisivel(alvo.bloco)
        let vazio = visivel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if insereNovo(papel) {
            if vazio, case .paragrafo = alvo.bloco {
                texto = Caderno.aplicar(fatias, id: alvo.id, bloco: bloco(de: papel, texto: ""))
                editando = alvo.id
            } else {
                texto = Caderno.juntar(texto, bloco(de: papel, texto: ""))
                abrirUltimo(de: papel)
            }
        } else {
            // o id carrega o papel ("paragrafo:0" -> "recipiente:0"), então o
            // bloco vestido é reencontrado pela POSIÇÃO, não pelo id antigo
            let posicao = fatias.firstIndex { $0.id == alvo.id }
            texto = Caderno.aplicar(fatias, id: alvo.id, bloco: bloco(de: papel, texto: visivel))
            let novas = Caderno.fatias(texto)
            editando = vazio
                ? alvo.id
                : posicao.flatMap { novas.indices.contains($0) ? novas[$0].id : nil } ?? novas.last?.id
        }
    }

    private func insereNovo(_ papel: PapelForma) -> Bool {
        switch papel.gesto {
        case .codigo, .tabela, .divisoria: true
        default: false
        }
    }

    private func bloco(de papel: PapelForma, texto: String) -> BlocoCaderno {
        Caderno.bloco(de: papel, texto: texto)
    }

    private var fatiaAlvo: FatiaCaderno? {
        if let editando, let hit = fatias.first(where: { $0.id == editando }) {
            return hit
        }
        return fatias.last { $0.aberto } ?? fatias.last
    }

    private func abrirUltimo(de papel: PapelForma) {
        let f = Caderno.fatias(texto)
        switch papel.gesto {
        case .codigo:
            editando = f.last { if case .codigo = $0.bloco { true } else { false } }?.id
        case .tabela:
            editando = f.last { if case .tabela = $0.bloco { true } else { false } }?.id
        case .divisoria:
            editando = nil
        case .recipiente:
            editando = f.last {
                if case .recipiente(let slug, _) = $0.bloco { slug == papel.slug } else { false }
            }?.id
        default:
            editando = f.last { !$0.aberto }?.id
        }
    }

    /// Tira o bloco do anexo do documento. O arquivo em disco morre sozinho na
    /// próxima varredura de órfãos — ela já apaga o que nenhuma nota referencia.
    private func apagarAnexo(_ fatia: FatiaCaderno) {
        texto = Caderno.aplicar(fatias, id: fatia.id, novo: "")
        editando = nil
        Toque.fechou()
        aoMudar()
    }

    private func alternarTarefa(_ fatia: FatiaCaderno, _ indice: Int) {
        // a fatia vem do desenho: se o texto mudou antes do toque, o índice pode não existir mais
        guard case .tarefas(let xs) = fatia.bloco, xs.indices.contains(indice) else { return }
        var next = xs
        next[indice].feito.toggle()
        texto = Caderno.aplicar(fatias, id: fatia.id, bloco: .tarefas(next))
        aoMudar()
    }

    private func importarFoto(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        gravar(dados: data, nome: "foto.jpg", tipo: .jpeg)
    }

    private func importarVideo(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        gravar(dados: data, nome: "video.mov", tipo: .mpeg4Movie)
    }

    private func importarResultado(_ resultado: Result<[URL], Error>) {
        if case .success(let urls) = resultado, let url = urls.first {
            importarURL(url)
        }
    }

    private func importarURL(_ url: URL) {
        let ok = url.startAccessingSecurityScopedResource()
        defer { if ok { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else { return }
        let tipo = UTType(filenameExtension: url.pathExtension) ?? .data
        gravar(dados: data, nome: url.lastPathComponent, tipo: tipo)
    }

    private func gravar(dados: Data, nome: String, tipo: UTType) {
        let id = UUID()
        guard (try? AnexoDisco.gravar(id: id, dados: dados, nome: nome)) != nil else { return }
        texto += AnexoDisco.marcaMarkdown(id: id, nome: nome, tipo: tipo)
        editando = nil
        Toque.leve()
        aoMudar()
    }

    private func tocarGravacao() {
        if gravando { pararGravacao() } else { iniciarGravacao() }
    }

    private func iniciarGravacao() {
        Task {
            let ok = await AVAudioApplication.requestRecordPermission()
            guard ok else { return }
            do {
                let sessao = AVAudioSession.sharedInstance()
                try sessao.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
                try sessao.setActive(true)
                let dest = FileManager.default.temporaryDirectory
                    .appendingPathComponent("voz-\(UUID().uuidString).m4a")
                let gravadorNovo = try AVAudioRecorder(
                    url: dest,
                    settings: [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44_100,
                        AVNumberOfChannelsKey: 1,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                )
                gravadorNovo.record()
                gravador = gravadorNovo
                gravando = true
            } catch {
                gravando = false
                gravador = nil
            }
        }
    }

    private func pararGravacao() {
        let url = gravador?.url
        gravador?.stop()
        gravador = nil
        gravando = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        guard let url,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              data.count > 200
        else { return }
        gravar(dados: data, nome: "voz.m4a", tipo: .mpeg4Audio)
    }
}

/// Quanto o encaixe (aviso, cartão, "lendo…") pode tomar da tela — o que sobra
/// depois do pé e do piso do papel (ADR 05y). Viaja pelo ambiente porque quem
/// mede é o Caderno e quem precisa rolar por dentro é o cartão da Página.
private struct TetoDoEncaixeChave: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var tetoDoEncaixe: CGFloat? {
        get { self[TetoDoEncaixeChave.self] }
        set { self[TetoDoEncaixeChave.self] = newValue }
    }
}
