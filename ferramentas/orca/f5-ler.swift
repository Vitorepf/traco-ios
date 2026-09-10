// Lê o texto de uma captura (OCR do Vision). Uma linha por trecho reconhecido.
// Uso: f5-ler <captura.png>   — compilado por f5-fotografar.sh quando precisa.
import Vision
import AppKit
let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let img = NSImage(contentsOf: url),
      let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(2) }
let req = VNRecognizeTextRequest()
req.recognitionLevel = .accurate
req.recognitionLanguages = ["pt-BR", "en-US"]
try VNImageRequestHandler(cgImage: cg).perform([req])
// `--xy` acrescenta o CENTRO do trecho em 0..1 com origem no ALTO — que é o
// que `orca emulator tap` espera. Sem o flag a saída é a de sempre: quem já
// chama este arquivo não muda de linha. (Q4-E: o helper de AX devolve árvore
// vazia neste simulador, e ausência na árvore não é ausência na tela.)
let comXY = CommandLine.arguments.count > 2 && CommandLine.arguments[2] == "--xy"
for o in req.results ?? [] {
    guard let c = o.topCandidates(1).first else { continue }
    if comXY {
        let b = o.boundingBox
        print(String(format: "%.4f %.4f\t%@", b.midX, 1 - b.midY, c.string))
    } else {
        print(c.string)
    }
}
