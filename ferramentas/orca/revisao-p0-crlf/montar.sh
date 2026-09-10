#!/bin/bash
# Monta o harness do REVISOR. Os corpos de Antes/Depois nao sao digitados: saem
# por awk do arquivo vivo e do commit pai, para nao haver deriva de transcricao.
set -e
cd "$(dirname "$0")/../../.." || exit 1
T=$(mktemp -d)
awk '/nonisolated static func importarComEstado/,/^    \/\/ MARK: - Disco/' Traco/Notas/Corpus.swift | sed '$d' | sed '$d' > "$T/depois.swift"
git show 21939ae^:Traco/Notas/Corpus.swift > "$T/pai.swift"
awk '/nonisolated static func importarComEstado/,/^    \/\/ MARK: - Disco/' "$T/pai.swift" | sed '$d' | sed '$d' > "$T/antes.swift"
{ cat <<'HDR'
import Foundation
enum OrigemNota: String { case autor, grokbot, pesquisa, modelo }
struct GestoStub { let conhecido: Bool }
enum Gesto { static func doNome(_ n: String) -> GestoStub? { nil } }
typealias ItemImportado = (texto: String, gestoNome: String?, criadaEm: Date, origem: OrigemNota)
enum Antes {
HDR
  cat "$T/antes.swift"; printf '}\nenum Depois {\n'; cat "$T/depois.swift"; printf '}\n'
  cat ferramentas/orca/revisao-p0-crlf/casos-do-revisor.swift
} > "$T/revisao.swift"
swiftc -O "$T/revisao.swift" -o "$T/revisao" && "$T/revisao"
