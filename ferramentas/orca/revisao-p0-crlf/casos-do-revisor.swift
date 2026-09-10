// Casos ADVERSARIAIS do revisor. Cada um pergunta a MESMA coisa:
// o app apagou um arquivo do autor afirmando ter lido tudo o que havia nele?
func crlf(_ s: String) -> String { s.replacingOccurrences(of: "\n", with: "\r\n") }

let selada = "---\ncriada: 2026-09-09T10:00:00Z\norigem: modelo\nestado: selada\n---\n\na dor que ninguem le\n"
let aberta = "---\ncriada: 2026-09-09T10:00:00Z\n---\n\ncorpo aberto\n"

// --- refeitos do relato do autor ---
let D = selada.replacingOccurrences(of: "origem: modelo\n", with: "origem: modelo\r\n")
let E = "# minhas notas de hoje\n\numa linha que so existe aqui\n\n" + aberta

// --- ataques novos do revisor ---
// N1: selo cujo cabecalho e INVISIVEL AOS DOIS contadores (criada sem espaco).
let N1 = "---\ncriada:2026-09-09T10:00:00Z\nestado: selada\n---\n\na dor que ninguem le\n"
// N2: selo escrito a mao, sem linha criada nenhuma.
let N2 = "---\nestado: selada\n---\n\na dor que ninguem le\n"
// N3: gesto com nome que o catalogo NAO conhece e sem metodo: o nome e descartado.
let N3 = "---\ncriada: 2026-09-09T10:00:00Z\ngesto: Meu Metodo Pessoal\n---\n\ncorpo aberto\n"
// N4: nota EXPORTADA PELO APP com dominio/recordada/editada - campos que o
//     importador nunca le. Ida e volta pela entrada/.
let N4 = "---\nid: 11111111-1111-1111-1111-111111111111\ncriada: 2026-09-09T10:00:00Z\neditada: 2026-09-09T12:00:00Z\ndominio: Espanhol\nrecordada: 4\n---\n\ncorpo aberto\n"
// N6: selo com a chave grudada (estado:selada) num cabecalho por tudo o mais valido.
let N6 = "---\ncriada: 2026-09-09T10:00:00Z\nestado:selada\n---\n\na dor que ninguem le\n"
// N7: selo so-metadado, como o app escreve expressiva selada (sem corpo).
let N7 = "---\nid: 22222222-2222-2222-2222-222222222222\ncriada: 2026-09-09T10:00:00Z\nestado: selada\nminutos: 12\n---\n"
// N8: so-metadado NAO selado (expressiva viva): corpo vazio -> continue.
let N8 = aberta + "\n---\nid: 33333333-3333-3333-3333-333333333333\ncriada: 2026-09-09T11:00:00Z\nrecordada: 2\n---\n"
// N9: separador de linha Unicode U+2028 no cabecalho.
let N9 = "---\u{2028}criada: 2026-09-09T10:00:00Z\u{2028}estado: selada\u{2028}---\u{2028}\u{2028}a dor que ninguem le\n"
// N10: cabecalho que nunca fecha.
let N10 = "---\ncriada: 2026-09-09T10:00:00Z\nestado: selada\n\na dor que ninguem le\n"
// N11: arquivo que TERMINA no cabecalho, sem quebra final.
let N11 = "---\ncriada: 2026-09-09T10:00:00Z\n---\ncorpo aberto"
// N12: tudo CRLF (o caso do Windows puro).
let N12 = crlf(selada)
// N13: prosa do autor DEPOIS do ultimo bloco, colada no fim.
let N13 = aberta + "\nps: lembrar de ligar para a minha mae\n"

let casos: [(String, String, String)] = [
  ("D  \\r so na origem       ", D,   "dor"),
  ("E  prosa antes do 1o     ", E,   "so existe aqui"),
  ("N1 criada: sem espaco    ", N1,  "dor"),
  ("N2 selo a mao, sem criada", N2,  "dor"),
  ("N3 gesto desconhecido    ", N3,  "Meu Metodo Pessoal"),
  ("N4 export com dominio    ", N4,  "Espanhol"),
  ("N6 estado:selada grudado ", N6,  "dor"),
  ("N7 selo so-metadado      ", N7,  "dor"),
  ("N8 so-metadado nao selado", N8,  "@@nunca@@"),
  ("N9 U+2028 no cabecalho   ", N9,  "dor"),
  ("N10 cabecalho nao fecha  ", N10, "dor"),
  ("N11 termina no corpo     ", N11, "@@nunca@@"),
  ("N12 tudo CRLF, selada    ", N12, "dor"),
  ("N13 prosa depois do fim  ", N13, "ligar para a minha mae"),
]

print("caso                      | ANTES apaga | DEPOIS apaga | consumido | itens | perdeu o que vazaria/sumiria?")
print("--------------------------|-------------|--------------|-----------|-------|------------------------------")
for (nome, md, agulha) in casos {
    let a = Antes.importarComEstado(md)
    let p = Depois.importarComEstado(md)
    let apagaAntes = a.itens.isEmpty ? "nao(vazio)" : (a.contemProtegida ? "nao" : "SIM")
    let apagaDepois = p.itens.isEmpty ? "nao(vazio)" : (p.podeRetirar ? "SIM" : "nao")
    // o texto sensivel sobreviveu em alguma nota importada?
    let vazou = p.itens.contains { $0.texto.contains(agulha) }
    // o campo sumiu do resultado embora o arquivo va ser apagado?
    let sumiu = !vazou && agulha != "@@nunca@@" && p.podeRetirar
    let veredito = vazou ? "VAZOU no import" : (sumiu ? "SUMIU e o arquivo APAGA" : "-")
    print("\(nome) | \(apagaAntes.padding(toLength: 11, withPad: " ", startingAt: 0)) | \(apagaDepois.padding(toLength: 12, withPad: " ", startingAt: 0)) | \(String(format: "%9.2f", p.consumido)) | \(String(format: "%5d", p.itens.count)) | \(veredito)")
}
