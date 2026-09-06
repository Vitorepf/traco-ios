import SwiftUI

/// ADR 05x: de onde um método vem, na Lente e no Perfil com o mesmo texto.
/// Informação, nunca selo. Do autor: "a que você escreveu"; sem o campo:
/// "não informada — o arquivo do método não tem o campo" (o arquivo é dele,
/// a lacuna também).
struct LinhasDeProveniencia: View {
    let metodo: Metodo
    let identificador: String

    init(_ metodo: Metodo, identificador: String = "proveniencia") {
        self.metodo = metodo
        self.identificador = identificador
    }

    var body: some View {
        Group {
            if let p = metodo.proveniencia, !p.linhas.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    if metodo.doAutor {
                        Text("proveniência: a que você escreveu")
                            .foregroundStyle(Tema.tintaSuave)
                    }
                    ForEach(p.linhas, id: \.rotulo) { linha in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(linha.rotulo).rotulo()
                            Text(linha.texto).foregroundStyle(Tema.tinta)
                        }
                    }
                }
            } else {
                Text(metodo.doAutor ? "proveniência: não informada — o arquivo do método não tem o campo." : "proveniência não informada.")
                    .foregroundStyle(Tema.tintaSuave)
            }
        }
        .font(Tema.meta)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(identificador)
    }
}

#Preview("catálogo") {
    LinhasDeProveniencia(Catalogo.metodo("woop")!)
        .padding()
        .background(Tema.fundo)
}

#Preview("do autor, sem o campo") {
    var m = Metodo(id: "cornell", nome: "Cornell")
    m.doAutor = true
    return LinhasDeProveniencia(m)
        .padding()
        .background(Tema.fundo)
}

#Preview("AX5") {
    LinhasDeProveniencia(Catalogo.metodo("expressiva")!)
        .padding()
        .background(Tema.fundo)
        .environment(\.dynamicTypeSize, .accessibility5)
}
