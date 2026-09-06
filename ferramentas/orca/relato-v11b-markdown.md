# V11-B — correção do G3 (Ambiente Markdown: conflito, retry e revogação)

Implementador: Claude Opus 5. Worktree `volta-11-markdown`, sobre `797adc2`.
Instrumento: iPhone 17e **C7341E64-3A33-4ADD-AF6C-9296215FAD09**, ligado por mim
(estava desligado), tudo por `ferramentas/orca/com-trava.sh`. O iPhone 17 do dono
(1A46B6D3) não foi tocado; nenhum simulador alheio foi desligado. Tamanho de
texto: `large` antes, AX5 durante a conferência, **`large` restaurado e conferido**.

ADR renumerada de `2026-09-06x` para **`2026-09-06a`** por atribuição do dono
(colidia com a V18), em SPEC, EVOLUCAO, comentários e fluxo maestro.

## Item a item

### A3 — conflito inventado — CORRIGIDO NA CAUSA
O predicado "este conteúdo já está guardado" estava embutido dentro de
`aplicarVersaoExterna`; a tela não tinha como perguntá-lo e por isso oferecia uma
decisão que a mutação recusaria. Agora é uma função só,
`IntercambioTrabalho.jaGuardado`, e os DOIS lados a usam: a mutação para não
fabricar versão, a tela para não oferecer escolha. `conflito(_:em:)` exige, além
de `.baseAntiga`, que a versão local tenha ANDADO (`baseID != versaoVigenteID`) e
que o conteúdo não esteja guardado. `descricaoDaBase` deixou de ser um switch
cego no estado do protocolo.

Efeito colateral bom: a mesma correção conserta o retorno feliz e o arquivo sem
vínculo, que também ofereciam "Guardar como nova versão externa" caindo em
`.semNovidade`. Um guard no funil, não um por chamador.

Prova: teste `arquivoSemNovidadeNaoInventaConflitoNemPedeDecisao` (as três
formas: intenção revista; export intocado depois que a versão andou; e o
conflito de verdade, que continua de pé) e a captura
`v11b-sem-decisao.png` — "Este arquivo traz o mesmo conteúdo que já está guardado
aqui. Não há nada para decidir: nenhuma versão será criada.", sem botão.

### A4 — botão que nunca podia dar certo — CORRIGIDO
`RecusaDoCommit` (`.nenhuma`, `.disco`, `.baseDivergente`) sai de `guardar()` e
entra em `Desfecho.de(mudou:guardou:acesso:recusa:)` — parâmetro obrigatório, sem
padrão, para nenhum chamador esquecer qual recusa foi. `.aguardandoCommit` (disco)
continua sendo o único que oferece "Tentar guardar de novo". `.precisaReabrir`
não oferece botão e diz o que fazer: voltar, reabrir o trabalho, com o arquivo
preservado no aparelho.

Prova: `recusaPorBaseDivergenteNaoOfereceNovaTentativaQueNaoPodeDarCerto`. O teste
não simula a guarda: abre uma SEGUNDA `Oficina` do mesmo `Trabalho` e escreve por
ela — o que responde a dúvida que o revisor deixou em aberto ("não provei que duas
`Oficina`s coexistem hoje"). Coexistem, a guarda dispara, e o teste ainda afirma
que repetir `guardar()` recusa de novo.

O irmão que o revisor apontou (`.recusada` cobrindo "conteúdo repetido + disco
recusou") deixou de ser alcançável pela tela: sem novidade, o botão não existe
mais. `.recusada` fica sendo o que o nome diz — a mutação não pôde ser aplicada.

### A5 — o fluxo roda sozinho — CORRIGIDO, 2 de 2 verdes
Descobri, tentando eliminar o passo manual, que ele NÃO era supérfluo: um `.md`
intocado nunca é conflito, porque o corpo é idêntico à versão de onde saiu. O
conflito exige as duas pontas, e uma delas só existe fora do app. Então o passo
externo virou script: `maestro/intercambio-conflito.sh` roda a parte 1, reescreve
o corpo do `.md` no disco do simulador preservando o envelope da linha 1, e roda a
parte 2 (`maestro/partes/`, fora do alcance do `varrer.sh`, que corre
`maestro/*.yaml`). O `varrer.sh` já prefere o `.sh` irmão quando existe.

Quatro coisas quebravam a reexecução, todas consertadas e comentadas no fluxo:
- a pasta "No Meu iPhone" sobrevive ao `clearState` e o exportador abria
  "Substituir Itens Existentes?", alerta fora do processo que o maestro não vê
  (o `.sh` apaga a cópia velha antes);
- `hideKeyboard` não fecha este teclado — o arrasto fecha; com ele aberto a
  rolagem chega ao fim ANTES de o botão sair de baixo da barra de navegação, que
  é exatamente a falha que o revisor viu;
- parar a rolagem no próprio botão o deixa encostado no topo: rolo até a âncora
  seguinte, e o alvo fica acima do meio da tela;
- "Recentes" veio vazia depois do relançamento e "Explorar" abre na última pasta
  visitada (um iCloud Drive vazio, numa das voltas): o arquivo passa a ser achado
  pela BUSCA do seletor.

Também acrescentei asserções que fazem a falha aparecer onde ela acontece
("Versão 1" guardada, "Arquivo exportado…"), em vez de três telas adiante.

### A6 — "build sem aviso" — AGORA CONFERIDO
`comBaseAtual` era `var` sem mutação (linha 217) — o `_ = comBaseAtual` que
tentava calar o aviso saiu junto. Aproveitei o `var (d, p)` de
`ConferenciaTrabalhoTests:381`, que era anterior mas mantinha a afirmação falsa.
Recompilação INTEGRAL dos dois alvos (derivedData limpo):

```
✔ Test run with 720 tests in 125 suites passed after 7.376 seconds.
** TEST SUCCEEDED **
grep -c "warning:" → 0
```

### A7 — estados que faltavam — CAPTURADOS, e o que não dá, declarado
- `v11b-importar-bloqueado.png`: "Importar versão de arquivo" desabilitado com
  "Guarde a intenção ou a versão em edição antes de importar." (reproduzido por
  mim, com edição de versão pendente).
- `v11b-sem-decisao.png`: o estado novo do A3.
- `ProgressView("Lendo arquivo…")`: **não capturado, e agora declarado na ADR**.
  Com um `.md` de 400 bytes a leitura em `Task.detached` não dura um quadro; não
  há gesto de tela que a segure. Fica no "custo assumido", que era a queixa.
- `.precisaReabrir`: também sem captura, e pelo mesmo tipo de motivo — exige duas
  `Oficina`s do mesmo Trabalho vivas, e a tela não abre duas folhas. Provado por
  teste, declarado na ADR.

### A8 — AX5 — CORRIGIDO por corpo de acessibilidade
`linhasDoConflito` deixou de ser constante e passa a ler
`@Environment(\.dynamicTypeSize)`: doze linhas no tamanho normal, quatro quando
`isAccessibilitySize`. Em `v11b-conflito-ax5.png` o primeiro cartão cabe inteiro e
o segundo começa na mesma tela — antes um cartão sozinho ocupava tudo. Honesto:
os dois ainda NÃO cabem inteiros no mesmo olhar em AX5; encurtar mais deixaria
texto de menos para comparar. Está dito na ADR e no EVOLUCAO.

### Baixos que entraram junto (dois toques, mesma dimensão)
- `.textSelection(.enabled)` nos dois lados do conflito: o caminho comum já
  permitia copiar, o conflito não.
- `material` passa a contar a janela do `lendo`: o selo caindo entre o seletor
  fechar e a prévia nascer não registrava recolhimento nenhum.
- `.confirmada` não afirma mais "na nova tentativa": ela também aparece quando o
  commit vem por outra ação do autor, que não tentou nada.

Não mexi em `.cartao(.campo)`. Julguei e mantive: é o ÚNICO degrau que separa do
`Tema.superficie` do bloco de revisão; `.papel` desapareceria no fundo. A ADR
registra a escolha em vez de a deixar como acidente.

## As seis fases do `design-router` (com o que eu vi em cada uma)

Redesenho de bloco existente, então comecei pela auditoria (REDESENHO.md).

1. **Ancorar.** Autor no meio de um trabalho, decidindo sob pressão o que fazer
   com um arquivo que voltou. Resultado observável: uma versão a mais no
   histórico, ou nenhuma — nunca uma a menos. Restrição: nada some, autoria
   externa preservada.
2. **Sistema.** Nada novo. `cartao(.campo)`, `rotulo()`, `Tema.meta/corpo`, e
   `.compacto` de `Botao.swift`, que já existia e não estava sendo usado aqui.
3. **Construir.** Regra fora da View — `conflito`, `jaGuardado`, `Desfecho`,
   `RecusaDoCommit` são testáveis sem renderizar SwiftUI. A View pergunta e
   desenha.
4. **Mover.** Nenhuma animação nova, nenhuma removida. Não há movimento nesta
   volta e não faltou.
5. **Julgar** — a fase que o dono mandou olhar, lendo `v11-conflito-escolha.png`
   contra o sistema. Achei duas coisas: (a) as duas saídas estavam ambas em
   âmbar, empatadas em peso, quando o comentário do próprio `Botao.swift` diz
   "duas saídas em âmbar empatam em peso e o olho não sabe qual é o caminho"; a
   tela desobedecia a uma regra escrita na casa. (b) As doze linhas fixas eram um
   número mágico que a tela grande desmontava. Os dois viraram correção.
6. **Portão.** Estados exercitados no aparelho e capturados; sem defeito material
   conhecido em aberto; limites declarados em vez de escondidos.

## Os quatro itens da `curva-zero`

- **Jornada:** "editei fora e voltei" — exportar, editar noutra ferramenta,
  importar, decidir. Uma tarefa, não um wizard.
- **Resultado verificável:** o histórico cresce em um e nenhuma versão anterior
  some. O contador "Histórico de versões (N)" é o que o autor lê para confirmar.
- **Atrito observado:** a tela chamava para uma decisão inventada em três toques,
  sem editor externo nenhum, e a decisão não tinha efeito; e oferecia uma nova
  tentativa que, num dos dois caminhos, não podia funcionar. Foram medidos lendo
  o código contra a tela — não é pesquisa com pessoas, e não estou chamando de
  pesquisa.
- **Recuperação:** disco recusou → o mesmo botão confirma a MESMA versão; base
  divergente → reabrir, arquivo preservado; conteúdo repetido → fechar a revisão,
  nada criado; origem selada → material recolhido e dito por nome. Nenhum caminho
  termina sem próxima ação possível.

## O que não mexi de propósito

O revisor confirmou três contratos duros — o conflito nunca sobrescreve, o retry
prova identidade do artefato relido do banco, o recolhimento é fiação reativa — e
os dois toques em `OficinaTrabalho`/`TrabalhoView` como o lugar certo. Não toquei
em nenhum deles. `TrabalhoView` mudou UMA linha, de comentário (o número da ADR).
