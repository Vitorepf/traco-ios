import Foundation
import Testing
@testable import Traco

/// ADR 2026-09-12a — acento e espaço não inventam vínculo; citação
/// que a candidata não tem continua caindo.
struct GuardaDeEcosTests {
    private let candidatas = [
        "Atenção é um músculo :: treina com repetição espaçada e cansa como músculo",
        "Sala de 15 :: 18 inscritos contra a sala que comporta 15",
        "Lista do mercado :: arroz, feijão, café",
    ]

    @Test func acentoEEspacoNaoDerrubamACitacaoDela() {
        #expect(GuardaDeEcos.cita("atencao e um musculo", na: candidatas[0]))
        #expect(GuardaDeEcos.cita("mesmo   desligado\nele custa",
                                  na: "Celular na mesa :: mesmo desligado ele custa um pedaço"))
        let r = Sabia.parseEcos(
            #"{"ecos":[{"i":0,"trecho":"atencao e um musculo :: treina"}]}"#,
            candidatas: candidatas)
        #expect(r?.count == 1)
        #expect(r?.first?.i == 0)
    }

    @Test func vinculoUtilComNumeroDelaPassaEInventadoCai() {
        let r = Sabia.parseEcos(
            #"{"ecos":[{"i":1,"trecho":"18 inscritos contra a sala que comporta 15"}]}"#,
            candidatas: candidatas)
        #expect(r?.count == 1)
        #expect(r?.first?.i == 1)
        #expect(Sabia.parseEcos(
            #"{"ecos":[{"i":1,"trecho":"a sala comporta o dobro sem aperto"}]}"#,
            candidatas: candidatas)?.isEmpty == true)
    }
}
