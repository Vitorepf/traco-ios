# Consulta V12 — a invariante da escrita visível

> **Que invariante, verificável por teste e não por olho, tornaria IMPOSSÍVEL qualquer coisa cobrir o texto que o autor está escrevendo — inclusive durante uma transição?**

**Recomendo fechar a classe por contrato de ocupação e visibilidade, com dono único no contêiner. Não recomendo aceitar correções por gatilho como arquitetura. Mas uma varredura de fonte não prova pixels, e não existe hoje nesta suíte uma prova de todos os quadros da transição nativa.**

## 1. A invariante

**Em cada quadro apresentado enquanto a Página recebe escrita, a linha visual ativa inteira e o retângulo do caret pertencem à área livre do papel; nenhuma outra superfície pode desenhar nessa área.** Isso protege a última linha digitada, inclusive vazia; na edição intermediária, acompanha a inserção real. O piscar do caret não suspende sua proteção.

Em coordenadas da janela, para todo quadro `t`:

```
E(t) ⊆ P(t) ⊆ W(t)       e       P(t) ∩ O(t) = ∅
```

`E` é a linha ativa mais o caret; `P`, o viewport efetivo e recortado do papel; `W`, a janela útil sem teclado; `O`, a ocupação das demais superfícies, incluindo efeitos e deslocamentos. São regiões apresentadas, não frames finais ou AX. `E` e `P` devem existir: área vazia nunca aprova.

**A lei mora no contêiner `CadernoView`.** Ele concede áreas exclusivas ao papel e ao encaixe; cartão, régua e ações obedecem à mesma separação. O papel mantém a linha ativa dentro da concessão, mediante rolagem real. Se falta espaço, o aparato cede antes da escrita; apenas recortar o papel continua sendo reprovação.

Nenhuma camada futura pode desenhar fora dessa concessão, inclusive a folha apresentada por `PaginaView`, acima do `CadernoView`. Abrir a folha transfere deliberadamente a edição: até essa transferência, a Página permanece protegida; durante ela, nenhum texto vaza entre superfícies. Desligar uma flag não prova transferência. **Um tipo novo com `CGRect` não resolve:** um ancestral ainda pode ignorá-lo.

## 2. Como se prova sem olho

**Existe prova geométrica automatizável, sem condução manual do simulador; ela exige UIKit/SwiftUI executando em um app de teste no simulador ou aparelho. Não é um teste puro de números sem runtime iOS.**

O teste hospedado monta a Página real com estado isolado, editor focado, teclado de software confirmado e texto maior que o viewport. Insere no fim e no meio, e mede linha e caret contra o recorte dos ancestrais e a ocupação das superfícies, na mesma coordenada. UIKit fornece [o retângulo do caret](https://developer.apple.com/documentation/uikit/uitextinput/caretRect(for:)) e [retângulos de seleção](https://developer.apple.com/documentation/uikit/uitextinput/selectionRects(for:)); a linha visual inteira requer a geometria de layout do texto, não só o caret. Encaixe vazio, cartão, aviso e mudança de tamanho entram pela mesma asserção, incluindo `large` e AX5. O teste não pode rolar artificialmente até o fim para produzir o resultado que deveria verificar.

**Hoje isso falta.** `TemaTests.oPapelTemPiso` testa o cálculo do teto. `CadernoHitchesTests` encontra o `UITextView` real, mas é opt-in, altera a sessão compartilhada e mede tempo/inset/offset; não afirma a visibilidade da linha. O observador deve reprovar camada intrusa semeada e caret sob o encaixe; camada não contabilizada é falha.

O equivalente da ADR 08e é **um portão da fronteira de composição**, impedindo sobreposições fora do contêiner. Regex de modificadores não prova geometria arbitrária nem composição do sistema. A própria 08e delimita sua garantia a curvas literais; ela não garante ausência universal de fantasmas. O custo geométrico é moderado; enumerar qualquer camada desconhecida não vem pronto da hierarquia SwiftUI.

## 3. O fantasma da transição

**O contrato temporal é: cada pixel reservado a uma superfície textual tem um único dono em todo quadro; enquanto seu texto aparece, a cobertura que exclui o texto de trás permanece íntegra na mesma geometria.** Isso inclui os vazios onde apareceu “OBSTÁCULO INTERNO”. `opacity == 1` no cartão não prova isso: ancestrais, máscaras e a composição da apresentação também contam. Apenas engrossar o fundo esconderia o A1 e ainda poderia cobrir o autor no A2; as duas condições anteriores continuam obrigatórias.

**É possível automatizar a reprovação nos quadros nativos capturados**: um oráculo de pixels detecta texto/padrão semeado do papel na região exclusiva do cartão, perda da cobertura ou duas geometrias concorrentes. Deve acusar perda de fundo e duplicação plantadas, na composição real, com e sem RM. A análise acontece após a captura, sem juiz assistindo ao vídeo.

**Isso custa instrumentação de renderização e não prova, por si, “nenhum quadro possível”.** São necessários captura externa ao caminho medido, localização das superfícies, tolerâncias calibradas e controle de quadros ausentes. Lacuna de captura torna aquele intervalo inconclusivo. `CADisplayLink` é [um temporizador sincronizado à tela](https://developer.apple.com/documentation/quartzcore/cadisplaylink), não uma captura de pixels; a Apple descreve [`presentation()` como aproximação](https://developer.apple.com/documentation/quartzcore/calayer/presentation()) da camada exibida. Não há nessas APIs um certificado de cada quadro composto pelo `.sheet`. A V12-D mediu 127–162 ms no próprio snapshot: fotografar no callback alteraria o fenômeno.

Portanto: **contrato estrutural para impedir a classe no domínio controlado pelo app; teste geométrico na suíte; prova temporal automatizada e explicitamente amostrada para a composição nativa.** Sem esse último instrumento, o A1 permanece dependente de julgamento visual, e a afirmação de fechamento da 08f permanece refutada pelo G4 final. Estado final correto não prova transição.

---

Base: visão, brief Astra, DIRETRIZ §6, G4 original e ADR 08e neste checkout; G4 final, V12-B/C/D, G3 e dois re-G3, ADR 08f e fontes no worktree `../volta-v12b-pagina`, candidato `b49ee0f`, onde estão os documentos finais ausentes aqui. Consulta em 08/09/2026, sem build, testes ou implementação; números atribuídos aos relatórios, não remedidos.
