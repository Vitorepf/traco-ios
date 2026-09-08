# Revisão independente G3 — V12-B Página

**Veredito: CORRIGIR ANTES.** O conserto de layout é real, localizado e não
introduz movimento novo; porém a volta não mediu a curva-zero, não mediu
performance apesar de tocar o editor, e não verificou VoiceOver. Pela ESTEIRA,
essas três dimensões não podem receber 9.

## Instrumento e leitura do candidato

- Candidato: `62fc69f`, diff `main...HEAD`, sem erro de whitespace.
- iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, iOS Simulator 26.5.
  Liguei o aparelho, compilei/testei sob `ferramentas/orca/com-trava.sh` com
  destino por UDID e instalei o produto resultante para inspeção. O
  `xcresult` informa **890 testes, 0 falhas, Passed**.
- Inspeção do candidato: a Página com o cartão WOOP realmente fica colada à
  régua; a árvore AX mostra o cartão e ações como elementos próprios. Não usei
  maestro nem outro simulador.

## Achados e confronto das alegações

### 1. Causa do fantasma — confirmada

O diagnóstico é causal, não coincidência: `CadernoView` monta `acima` antes de
`peDoEncaixe`, mede um teto que depende da altura disponível e, antes deste
commit, aplicava `.frame(maxHeight: tetoDoEncaixe)` sem alinhamento. Assim, o
conteúdo ocupante é centrado na caixa que cresce quando o teclado desce;
`alignment: .bottom` o prende ao irmão `peDoEncaixe`.

As tiras nativas confirmam a previsão: `v12b-fantasma-antes.png` mostra o
cartão em três alturas enquanto a folha aparece; as seis amostras de
`v12b-fantasma-depois-sem-rm.png` e de
`v12b-fantasma-depois-com-rm.png` mantêm uma única altura e não deixam dois
textos legíveis na mesma faixa. A minha inspeção do build atual reproduziu o
cartão WOOP ancorado sobre a régua. Portanto, a causa não é o `.sheet` nem a
lei de movimento; a folha só tornava visível o erro de centralização.

### 2. Toast e re-G4 item 2 — crédito anterior confirmado

`git show 5937943 -- Traco/Pagina/PaginaView.swift` prova que a V12 removeu
`padding(.bottom, 88)` e levou o aviso para `CadernoView.acima`; o número não
é mudança desta volta. A V12-B fecha o vão residual pelo mesmo alinhamento:
o par `v12b-antes-large-vestida.png`/`v12b-depois-large-vestida.png` mostra
86,7 pt até a régua virarem 12,7 pt, sem nova constante.

Também confirmo a honestidade sobre o item 2: a captura **antes**
`v12b-antes-ax5-vestida.png` já traz teclado de pé, cartão vestido e ações
acima dele; `v12b-ax5-saidas-no-menu.png` traz inteiros “Abrir os campos” e
“Deixar como nota”. A mudança preserva esse resultado; não o criou.

### 3. Pilula desabilitada — confirmada

Refiz WCAG sRGB: `#C7C7CC` sobre papel/chip/branco/névoa dá
**1,529 / 1,373 / 1,684 / 1,412:1**; `#68686C` dá
**5,038 / 4,522 / 5,548 / 4,651:1**. Os números arredondados do relato e da
ADR estão corretos e o novo `PilulaContrasteTests` cobre os quatro fundos e as
seis formas.

O componente agora desenha a hairline somente quando desabilitado, logo a
remoção do overlay do `RecordarView` não perde a razão do comentário antigo.
O par `v12b-recordar-antes.png`/`v12b-recordar-depois.png` mantém a cápsula
“Revelar” reconhecível como controle desligado; a borda dupla desaparece
(RGB relatado 211 para 227). Não encontrei outro overlay manual equivalente.

### 4. Item 4, movimento e portão futuro

Os quatro arquivos `*-large-vestida` e `*-ax5-vestida` mostram forma vestida
e teclado presente; no AX5, a topbar, o cartão e o menu cabem sem corte.
As seis fases do `design-router` estão explicitamente relatadas — Ancorar,
Auditar, Sistema, Construir, Mover e Julgar/Portão — e a tela confirma as
decisões visuais principais (um encaixe, uma âncora, cápsula legível).

O portão P1 ainda não está nesta branch, mas sua versão em `14535b5` congela
`CadernoView`=4, `PaginaView`=7 e `RecordarView`=9. O diff desta volta não
adiciona `withAnimation`, curva literal, duração crua, `.animation` ou
`.transition`: as três transições de `PaginaView` apenas foram reindentadas;
as contagens permanecem 4/7/9 e `Pilula` continua 0. Logo P1 não acusará
movimento novo deste diff.

## Scorecard da ESTEIRA

| dimensão | nota | evidência independente |
|---|---:|---|
| Visão | 9 | Fecha três dívidas nomeadas na limpeza de 07/09 e atualiza a lacuna “Direção visual e uso simples” em `EVOLUCAO.md`. |
| Contrato | 9 | ADR 08c é curta e verdadeira: distingue o `88` já removido do vão e registra o alinhamento, contraste e limites. Nenhuma rota de origem, autoria ou privacidade foi alterada no diff. |
| Correção | 9 | `xcresult` próprio: 890 passed, 0 failed; `PilulaContrasteTests` trava a regressão de contraste. |
| Jornada real | 9 | Conferi as capturas large/AX5, teclado de pé, toast em quatro condições e as tiras RM/não-RM; o conteúdo pedido está de fato na tela. |
| Design | 9 | Diagnóstico, sistema e construção reduzem-se à âncora correta; antes/depois elimina o espaço acidental sem elemento novo. |
| Simplicidade | 8 | O fluxo aparenta conservar os toques, mas o relato não registra **contagem antes/depois**, exigida pela curva-zero; “nenhum passo a mais” não é medida. |
| Movimento | 9 | Antes há três geometrias; depois há uma, tanto com RM quanto sem. O diff não aumenta a dívida congelada do P1. |
| Componentes | 9 | Estado desabilitado sobe para `Pilula`, com preview e portão; o chamador duplicado perde a borda. |
| Acessibilidade | 8 | Contraste e AX5 passam visualmente, mas o próprio relato declara que **VoiceOver não foi medido**; falta verificar rótulo, ordem e estado desabilitado por leitor de tela. |
| Performance | 8 | `CadernoView` é o encaixe do editor e foi alterado; a ESTEIRA exige medida/trace quando editor é tocado. Não há Instruments nem medição de hitch em digitação/rolagem. |
| Privacidade e autoria | n/a | Nenhuma rota de dados, selo, origem, exportação ou IA foi tocada; leitura do diff não revela regressão. |
| Estado honesto | 9 | O aviso de silêncio permanece explícito e agora fica fora das ações que ele não pode ocultar. |
| Complexidade | 8 | Código de app é **+107/−62 = +45**; com `-w`, **+59/−14 = +45**. O teste e estado central justificam parte do crescimento, mas a regra de migração líquido-negativa não foi atendida nem há exceção nova aprovada. |
| Fora do app | n/a | Não há superfície fora do app neste escopo. |
| Relato | 9 | Seis fases, limites, capturas e crédito pré-existente estão claros; a omissão de curva-zero/VO/performance permanece anotada acima. |

## CORRIGIR ANTES

1. **Simplicidade:** medir e registrar a curva-zero, em toques antes/depois, para o roteiro Página → cartão vestido → Abrir os campos; acrescentar a prova ao relato.
2. **Acessibilidade:** rodar VoiceOver no estado `Pilula` desabilitado e no AX5 vestido, registrando ordem, rótulos e estado de controle.
3. **Performance:** medir no Instruments (ou trace equivalente aceito) digitação e rolagem do `CadernoView` após o novo encaixe; anexar o resultado.
4. **Complexidade:** reduzir o saldo de +45 para atender a regra líquido-negativa, ou obter e registrar uma exceção explícita para este portão de contraste/preview.

Nenhum código foi alterado nesta revisão.
