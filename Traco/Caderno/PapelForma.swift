import Foundation

enum GestoPapel: Equatable, Hashable, Sendable {
    case titulo(Int)
    case lista(ordenada: Bool)
    case tarefa
    case citacao
    case codigo(lingua: String?)
    case tabela
    case divisoria
    case recipiente
}

enum CromoPapel: String, Sendable, Hashable {
    case padrao
    case chamada
    case voz
    case verso
    case pergunta
    case ideia
    case decisao
    case risco
    case duplo
    case cena
    case passos
    case silencio
    case epigrafe
}

struct PapelForma: Hashable, Identifiable, Sendable {
    var id: String { slug }
    let slug: String
    let nome: String
    let gesto: GestoPapel
    let cromo: CromoPapel

    static let catalogo: [PapelForma] = fazerCatalogo()

    /// A régua do teclado mostra SÓ estas (SPEC §12: menu de 136 nomes é template em menu).
    /// O catálogo completo continua existindo para o ARQUIVO: toda `:::slug` já gravada
    /// segue sendo lida e renderizada — poda-se o menu, nunca o formato.
    static let regua: [PapelForma] = {
        let slugs = ["titulo", "seccao", "lista", "numerada", "tarefa", "citacao",
                     "codigo", "tabela", "divisoria", "verso", "ideia", "silencio"]
        return slugs.compactMap { s in catalogo.first { $0.slug == s } }
    }()

    static let porSlug: [String: PapelForma] = Dictionary(
        uniqueKeysWithValues: catalogo.map { ($0.slug, $0) }
    )

    static func nome(de slug: String) -> String {
        porSlug[slug]?.nome ?? slug
    }

    static func cromo(de slug: String) -> CromoPapel {
        porSlug[slug]?.cromo ?? .padrao
    }
}

extension PapelForma {
    private static func item(
        _ slug: String,
        _ nome: String,
        _ gesto: GestoPapel,
        _ cromo: CromoPapel = .padrao
    ) -> PapelForma {
        PapelForma(slug: slug, nome: nome, gesto: gesto, cromo: cromo)
    }

    private static func recipiente(
        _ slug: String,
        _ nome: String,
        _ cromo: CromoPapel
    ) -> PapelForma {
        item(slug, nome, .recipiente, cromo)
    }

    private static func fazerCatalogo() -> [PapelForma] {
        [
            item("titulo", "Título", .titulo(1)),
            item("lista", "Lista", .lista(ordenada: false)),
            item("tarefa", "Tarefa", .tarefa),
            item("citacao", "Citação", .citacao),
            item("codigo", "Código", .codigo(lingua: nil)),
            item("tabela", "Tabela", .tabela),

            item("seccao", "Secção", .titulo(2)),
            item("subseccao", "Subsecção", .titulo(3)),
            item("numerada", "Numerada", .lista(ordenada: true)),
            recipiente("passos", "Passos", .passos),
            item("divisoria", "Divisória", .divisoria),
            recipiente("silencio", "Silêncio", .silencio),
            recipiente("pausa", "Pausa", .silencio),
            item("terminal", "Terminal", .codigo(lingua: "bash")),
            item("formula", "Fórmula", .codigo(lingua: "tex")),

            recipiente("chamada", "Chamada", .chamada),
            recipiente("traducao", "Tradução", .duplo),
            recipiente("comparar", "Comparar", .duplo),
            recipiente("causa", "Causa", .duplo),
            recipiente("epigrafe", "Epígrafe", .epigrafe),
            recipiente("verso", "Verso", .verso),
            recipiente("cena", "Cena", .cena),
            recipiente("sussurro", "Sussurro", .voz),
            recipiente("eco", "Eco", .voz),
            recipiente("voz", "Voz", .voz),
            recipiente("margem", "Margem", .voz),
            recipiente("excerto", "Excerto", .chamada),
            recipiente("nota", "Nota", .chamada),
            recipiente("lembrete", "Lembrete", .chamada),
            recipiente("respiracao", "Respiração", .voz),

            recipiente("pergunta", "Pergunta", .pergunta),
            recipiente("resposta", "Resposta", .ideia),
            recipiente("definicao", "Definição", .ideia),
            recipiente("ideia", "Ideia", .ideia),
            recipiente("duvida", "Dúvida", .pergunta),
            recipiente("decisao", "Decisão", .decisao),
            recipiente("regra", "Regra", .decisao),
            recipiente("exemplo", "Exemplo", .chamada),
            recipiente("hipotese", "Hipótese", .ideia),
            recipiente("prova", "Prova", .decisao),
            recipiente("efeito", "Efeito", .duplo),
            recipiente("risco", "Risco", .risco),
            recipiente("memoria", "Memória", .chamada),
            recipiente("foco", "Foco", .chamada),
            recipiente("contraste", "Contraste", .duplo),
            recipiente("sintese", "Síntese", .ideia),
            recipiente("achado", "Achado", .ideia),
            recipiente("tese", "Tese", .duplo),
            recipiente("antitese", "Antítese", .duplo),
            recipiente("analogia", "Analogia", .ideia),
            recipiente("metafora", "Metáfora", .verso),
            recipiente("inventario", "Inventário", .passos),
            recipiente("mapa", "Mapa", .cena),
            recipiente("eixo", "Eixo", .decisao),
            recipiente("ancora", "Âncora", .decisao),
            recipiente("gatilho", "Gatilho", .risco),
            recipiente("barreira", "Barreira", .risco),
            recipiente("recurso", "Recurso", .ideia),
            recipiente("pista", "Pista", .ideia),
            recipiente("enigma", "Enigma", .pergunta),
            recipiente("revelacao", "Revelação", .ideia),

            recipiente("pros", "Prós", .duplo),
            recipiente("contras", "Contras", .duplo),
            recipiente("data", "Data", .chamada),

            recipiente("dialogo", "Diálogo", .cena),
            recipiente("personagem", "Personagem", .cena),
            recipiente("retrato", "Retrato", .cena),
            recipiente("ambiente", "Ambiente", .cena),
            recipiente("acao", "Ação", .cena),
            recipiente("pensamento", "Pensamento", .voz),
            recipiente("flash", "Flash", .cena),
            recipiente("corte", "Corte", .cena),
            recipiente("batida", "Batida", .cena),
            recipiente("tema", "Tema", .ideia),
            recipiente("motivo", "Motivo", .ideia),
            recipiente("virada", "Virada", .cena),
            recipiente("climax", "Clímax", .cena),
            recipiente("queda", "Queda", .cena),
            recipiente("segredo", "Segredo", .voz),
            recipiente("confissao", "Confissão", .voz),
            recipiente("carta", "Carta", .voz),
            recipiente("relato", "Relato", .chamada),
            recipiente("cronica", "Crónica", .chamada),
            recipiente("ensaio", "Ensaio", .chamada),
            recipiente("manifesto", "Manifesto", .decisao),

            recipiente("sonho", "Sonho", .verso),
            recipiente("pesadelo", "Pesadelo", .risco),
            recipiente("visao", "Visão", .verso),
            recipiente("pressagio", "Presságio", .pergunta),
            recipiente("profecia", "Profecia", .decisao),
            recipiente("juramento", "Juramento", .decisao),
            recipiente("promessa", "Promessa", .decisao),
            recipiente("oracao", "Oração", .voz),
            recipiente("bencao", "Bênção", .voz),
            recipiente("maldicao", "Maldição", .risco),

            recipiente("medo", "Medo", .risco),
            recipiente("furia", "Fúria", .risco),
            recipiente("ternura", "Ternura", .voz),
            recipiente("vergonha", "Vergonha", .voz),
            recipiente("orgulho", "Orgulho", .decisao),
            recipiente("culpa", "Culpa", .risco),
            recipiente("graca", "Graça", .voz),
            recipiente("perdao", "Perdão", .voz),
            recipiente("luto", "Luto", .silencio),
            recipiente("alegria", "Alegria", .chamada),
            recipiente("espanto", "Espanto", .pergunta),
            recipiente("misterio", "Mistério", .pergunta),

            recipiente("sombra", "Sombra", .voz),
            recipiente("luz", "Luz", .chamada),
            recipiente("limiar", "Limiar", .cena),
            recipiente("umbral", "Umbral", .cena),
            recipiente("origem", "Origem", .ideia),
            recipiente("destino", "Destino", .decisao),
            recipiente("ferida", "Ferida", .risco),
            recipiente("cicatriz", "Cicatriz", .cena),
            recipiente("cheiro", "Cheiro", .voz),
            recipiente("som", "Som", .voz),
            recipiente("gosto", "Gosto", .voz),
            recipiente("temperatura", "Temperatura", .voz),
            recipiente("peso", "Peso", .ideia),
            recipiente("distancia", "Distância", .duplo),
            recipiente("tempo", "Tempo", .chamada),
            recipiente("agora", "Agora", .chamada),
            recipiente("antes", "Antes", .duplo),
            recipiente("depois", "Depois", .duplo),

            recipiente("casa", "Casa", .cena),
            recipiente("estrada", "Estrada", .cena),
            recipiente("cidade", "Cidade", .cena),
            recipiente("floresta", "Floresta", .cena),
            recipiente("mar", "Mar", .verso),
            recipiente("ceu", "Céu", .verso),
            recipiente("terra", "Terra", .cena),
            recipiente("fogo", "Fogo", .risco),
            recipiente("agua", "Água", .verso),
            recipiente("vento", "Vento", .voz),
            recipiente("pedra", "Pedra", .decisao),
        ]
    }
}
