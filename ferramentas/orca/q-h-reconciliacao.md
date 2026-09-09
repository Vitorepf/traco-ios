# Q-H — a volta Q e a V17 na mesma função, sem que nenhuma das duas ceda

**O que é.** Reconciliação, não volta nova. Enquanto a Q escrevia, a V17 (ADR
08j) mesclou em `main` e mexeu nas MESMAS duas funções: `parsePreparacao` e
`validar` de `PraticaTrabalho`, e `prepararPratica` de `MotorTrabalho`. Os
conflitos não eram de vizinhança — eram dois contratos escritos por cima um do
outro. Este documento diz, decisão por decisão, qual semântica ficou e por quê.

Simulador: `34CC3F94-FDB5-4575-A4F5-80271829A18B` (teste 3), ligado no início e
desligado ao fim. Nenhum outro aparelho tocado; nada de `erase`, `uninstall`
nem teste no `C2416CBC`.

---

## As decisões de semântica, uma por linha

1. **`lerPreparacao` passa a conhecer `comMudanca`.** O conjunto de chaves
   esperadas vira `chavesDaPreparacao ∪ {"mudanca"}` quando o pedido é um
   ajuste. A regra da V17 fica inteira: num ajuste, a chave `mudanca` é do
   contrato, e sem ela a preparação INTEIRA cai. O que muda é só que a queda
   passa a ter nome.

2. **Chave `mudanca` ausente num ajuste → `chavesForaDoContrato(faltando:
   ["mudanca"], sobrando: [])`.** Caso REAPROVEITADO, não novo: num ajuste a
   `mudanca` é chave do contrato como as outras cinco, e "faltando" é
   literalmente o que houve. Inventar um caso próprio diria que a ausência
   dela é uma categoria diferente de defeito — não é.

3. **Chave `mudanca` presente e fora do tipo → `campoNaoTexto("mudanca")`.**
   Reaproveitado, pelo mesmo motivo dos outros cinco campos: é a mesma guarda,
   sobre o mesmo tipo, com a mesma consequência.

4. **Chave `mudanca` presente, texto, mas vazia depois do `trim` →
   `campoVazio("mudanca")`.** Reaproveitado. Na V17 as duas condições
   (`texto(...)` e `!m.isEmpty`) eram um `nil` só; aqui elas se separam porque
   são defeitos distintos do provedor — tipo errado é forma, vazio é limite —
   e a recusa da Q existe justamente para não confundir os dois. Efeito
   idêntico ao da V17: a preparação cai.
   *Nota:* é a primeira vez que `campoVazio` é emitido por `lerPreparacao` e
   não por `provar`. A redação ("limite · mudanca veio vazio") lê certo nos
   dois lugares, e o par forma/limite continua honesto.

5. **`provar`: `mudanca` vazia depois de `limpo` → `campoVazio("mudanca")`.**
   A V17 conferia o vazio DE NOVO em `validar`, mesmo já tendo conferido no
   parse. Mantive a repetição de propósito: `Preparada` também se constrói à
   mão (nos testes, e em qualquer chamador futuro que não passe pelo parse), e
   a guarda de `provar` é a que vale para essa origem.

6. **`provar`: `mudanca` acima do teto → `campoAcimaDoTeto("mudanca", tamanho:,
   teto: Limite.mudanca)`.** Reaproveitado: mesma forma exata das quatro
   medidas de campo que já existem, com o teto de 400 que a V17 declarou.

7. **`provar`: `mudanca` vazando o exemplo → `mudancaVazaOExemplo(palavra:, de:,
   trechoPalavras:, noPedidoDoAutor:)` — CASO NOVO.** É a única decisão em que
   NÃO reaproveitei. `criterioVazaOExemplo` carrega um `indice` e sua redação
   diz "o critério N". Usá-lo para a `mudanca` obrigaria a inventar um índice
   de critério para um campo que não é critério: a recusa mentiria sobre qual
   guarda reprovou, que é exatamente o que a ADR 08p existe para impedir. O
   caso novo usa a MESMA régua (`Prova.vazamento`), a MESMA disciplina de
   medida sem conteúdo (posição, contagem, origem — nunca o trecho) e o MESMO
   `Recusa.origem`. Só o campo é declarado por nome.

8. **A ORDEM das guardas: a `mudanca` é provada DEPOIS dos critérios.** É onde
   a V17 a pôs, e a razão continua boa: o exercício se prova antes do que se
   diz sobre o exercício. Uma preparação que vaza num critério é recusada pelo
   critério, não pelo anúncio.

9. **`Preparada.mudanca` → `Pratica.mudanca` segue adiante intacto.** A V17
   leva a descrição da mudança até a `Pratica` para o anúncio "## Nesta versão"
   que o APP escreve. Nada da Q toca esse caminho.

10. **`prepararPratica`: um único `ajustando = p.ajuste != nil` governa TRÊS
    coisas.** O esquema de saída (`esquemaRemotoPreparacao(comMudanca:)`), a
    leitura (`lerPreparacao(cru, comMudanca:)`) e o rótulo do produtor
    (`"Grok · exercício adaptado"` quando ajusta, `"Grok · exercício preparado"`
    quando não). As três eram da V17 e as três ficam.

11. **O `timeout` é `Grok.tetoTrabalho`, não `90`.** Decisão da ADR 08r: o `90`
    da V17 é o valor suposto que a Q mediu e substituiu — as 20 falhas de
    transporte da 08q caíram para 0 em 30 chamadas com o teto medido. Manter
    o `90` aqui devolveria à rota de ajuste a falha que a Q acabou de fechar.

12. **A sonda de recusa da Q grava as recusas do AJUSTE também, sem ramo.** Não
    há `if ajustando` em volta do `recusasDaPreparacao.append`. A recusa de um
    ajuste é a que MAIS precisa de nome: é a que decide se o exercício de
    alguém não mudou por defeito do provedor ou por estreiteza da nossa régua.

13. **Uma extração, sem mudança de comportamento:** a contagem
    "quantas palavras do trecho o autor já tinha escrito" virou a função local
    `medida(_:)` dentro de `provar`, porque agora dois campos a fazem. A
    redação das recusas e os números que ela produz são idênticos aos da Q.

**Nenhuma regra das duas voltas desapareceu.** Da V17: chave obrigatória no
ajuste, queda da preparação inteira quando ela falta ou vem vazia, teto e prova
de vazamento sobre a `mudanca`, `mudanca` levada à `Pratica`, rótulo do
produtor, esquema de saída condicional. Da Q: `Result<Preparada, Recusa>` nas
duas funções, guarda nomeada em cada queda, `Prova.vazamento` com posição e
contagem, `pedidoDoAutor` para a origem, `Grok.tetoTrabalho`, sonda de DEBUG.

---

## Os outros três conflitos

**`Traco.xcodeproj/project.pbxproj`** (2) — arquivos novos dos dois lados
(`PerfilQualidadeTests` da Q, `PilulaContrasteTests` da main). Ficaram os dois,
e `xcodegen generate` refez o projeto por cima: os arquivos das duas voltas
estão nos alvos certos (conferido por `grep` no `.pbxproj` gerado —
`PerfilQualidadeTests`, `PilulaContrasteTests`, `EscritaVisivel`,
`ArranqueFalhouView`, todos com `PBXBuildFile` e `PBXFileReference`).

**`EVOLUCAO.md`** (1) — três linhas da tabela em conflito, e cada lado mexeu em
linhas DIFERENTES: a Q só na linha "Qualidade efetiva transversal da IA", a
main nas outras duas (A1 e 08m–o). Ficou a linha da Q e as duas da main. Zero
texto perdido dos dois lados (conferível: `git diff main -- EVOLUCAO.md` é uma
linha trocada mais o marcador do Perfil da Q).

**`SPEC.md`** (1) — vizinhança pura: os dois lados anexaram blocos de ADR no
mesmo ponto. Ficaram os dois blocos, o da main primeiro (`j, k, m, n, o, s`
continua a corrida alfabética depois do `i` que já estava lá) e o da Q depois
(`q, p, r, l`, na ordem cronológica das passadas, que é como o bloco foi
escrito). `git diff main -- SPEC.md` = 171 linhas adicionadas, 0 removidas:
adição pura. As letras não se mexeram: `08l`, `08p`, `08q`, `08r` continuam da
Q; `08j`/`08k` da V17, `08m`/`08n`/`08o` da E1, `08s` da A1.

---

## Prova de fecho

**Build limpo na árvore MESCLADA.** `xcodebuild ... build` →
`** BUILD SUCCEEDED **`, e a compilação completa de app + testes no log do
`test` traz **0 ocorrências de `warning:`**.

**Suíte integral na árvore mesclada**, por `ferramentas/orca/com-trava.sh` com
`-parallel-testing-enabled NO`, no `34CC3F94`:

```
** TEST SUCCEEDED **
```
```
"result" : "Passed", "totalTestCount" : 957, "passedTests" : 956,
"failedTests" : 0, "skippedTests" : 1, "expectedFailures" : 0
```

Executada DUAS vezes até o fim, com o mesmo resultado nas duas — 957 / 956 / 0 / 1,
`** TEST SUCCEEDED **`, 0 `warning:` na compilação completa das duas.

O único pulado é `CadernoHitchesTests/digitacaoERolagemNoCaderno()`, que já se
pulava antes desta fusão (teste de hitches, condicional) — não é achado desta
volta.

**Nenhum teste de nenhuma das duas voltas ficou vermelho pela fusão.** Os
testes da V17 sobre `mudanca` e os da Q sobre `Recusa` passam JUNTOS, que é o
que ninguém tinha medido antes.

### O que é limite do instrumento, e não resultado

**As duas primeiras execuções da suíte não rodaram teste nenhum:**
`The test runner hung before establishing connection.`, 0 de 957 executados,
345 s parados nas duas. Não é falha de teste — o app não chegou a conectar-se
ao runner. Provei que a árvore mesclada SOBE: instalei o `.app` construído dela
no `34CC3F94`, lancei (`app.traco: 24024`) e fotografei o Caderno de pé
(`ferramentas/orca/q-h-app-mesclado.png`). Na terceira e na quarta execução a suíte
correu inteira e passou, com números idênticos. Registro os dois travamentos como fato do instrumento, não os
escondo, e não os atribuo à fusão: o mesmo binário, no mesmo aparelho, abre e
passa.
