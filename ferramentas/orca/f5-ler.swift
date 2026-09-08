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
for o in req.results ?? [] { if let c = o.topCandidates(1).first { print(c.string) } }
