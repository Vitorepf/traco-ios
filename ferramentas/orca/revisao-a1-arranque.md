# G3 — revisão independente: A1, o arranque honesto

**Veredito: NÃO PASSA — CORRIGIR ANTES.** O comportamento novo de recusa foi
reproduzido no banco real e preservou o espelho, mas a volta declara como
`grep` uma medição que esse comando não produz, e deixou sem prova dois estados
de G2/Acessibilidade: espelho vazio e VoiceOver falado.

**Revisor:** Codex GPT-5.6; **candidato:** `8f2c671`;
**aparelho:** iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, iOS
26.5. Não toquei `C2416CBC`, `34CC3F94` nem `64F7B8B4`. Todo `xcodebuild` e
todo uso de `orca emulator` passou por `ferramentas/orca/com-trava.sh`; ao fim,
o store real, os WAL/SHM e `content_size=large` foram restaurados.

## Achados que atacam a causa

### A/B — confirmados

`main:Traco/Modelo/Migracao.swift` confirma que, se o disco recusava,
`DiscoTraco.abrir` devolvia `try memoria()` e `main:Traco/TracoApp.swift`
sempre montava `RaizView`. A árvore atual troca isso por
`DiscoTraco.Resultado`, põe `compartilhado = nil` na recusa e só monta
`RaizView().modelContainer(container)` no caso `.aberto`.

`Traco/Notas/Corpus.swift:440-464` confirma a segunda metade: `escrever`
forma `ids` a partir das fatias recebidas e remove cada `notas/*.md` ausente
da lista; `soOsMeus` só limita a remoção na pasta externa do autor, não no
espelho local `Corpus.diretorio`. `Sessao.projetarTudo`, selo, queima, apagar e
importar chamam `Corpus.backupAutomatico`, portanto a combinação antiga era um
risco real de apagar o espelho quando uma rota de projeção recebesse o mundo
vazio.

### C — a formulação mais forte não se sustenta literalmente

Não achei chamada de `Corpus.escrever` no arranque antigo que, com o
`ModelContainer` de emergência recém-vazio, pudesse apagar arquivos sozinho.
As rotas que o chamam precisam de uma projeção posterior; em particular, o
selo automático encontra zero notas naquele container. Logo, o risco é grave
**depois de uma interação/fluxo posterior no caderno falso**, mas não há prova
de destruição simplesmente ao iniciar, sem gesto do autor. A1 corta a classe
inteira ao não montar `RaizView`, o que é a correção segura mesmo para esse
risco condicional.

## Execução independente no aparelho

Gravei e concluí a nota real `Prova G3: o espelho preserva este conteudo.`.
Antes da sabotagem ela estava em
`Documents/notas/5a855496-56f4-43fb-bc67-cb04aba676ba.md` e no
`traco-corpus.md`. Parei o app, movi `default.store`, `-wal` e `-shm` para
backup temporário e criei um diretório no lugar exato de `default.store`.
O app retornou `SwiftDataError...loadIssueModelContainer`; não foi mock.

Evidência antes, durante e depois de tocar **Tentar abrir de novo**:

```
692379eb1f1a8c3e2eef6359a2eb98650c26b7dbdce04053679a1dc2570868db  nota .md
d8bab8f4b1cc25205aa58bd8a0e6525ed8ca7b12b453564e6b9002f6bbd36ee6  traco-corpus.md
MIRROR_UNCHANGED=YES
MIRROR_AFTER_RETRY_UNCHANGED=YES
STORE_AND_SIZE_RESTORED=YES
```

Na falha, `find Documents/notas -name '*.md'` contou três arquivos e a árvore
mostrou exatamente **“3 notas estão em Markdown...”**. A árvore em `large`
deu ao botão `{x: 0.0455, y: 0.3877, width: 0.9091, height: 0.046}`;
`0.046 × 956 = 43,98 pt`. A captura do mesmo UDID confirma a mesma copy e
estado. Em AX5, o botão mede `0.1311 × 956 = 125,35 pt`; a parte inferior da
tela rolada deixa a cópia, ação e detalhe técnico legíveis. Após o deep link
`traco://notas` durante a recusa, a árvore ainda só continha a tela de falha e
`arranque-tentar`; não apareceu rota de nota, selo, queima ou apagar.

Capturas desta revisão: `revisao-a1-falha-large.png`,
`revisao-a1-recusou-de-novo.png`, `revisao-a1-falha-ax5.png`,
`revisao-a1-falha-ax5-rolado.png` e `revisao-a1-nota-recuperada.png` em
`ferramentas/orca/`. A última mostra a nota novamente na lista depois da
restauração do store.

## Portão do `try!`

O portão é funcional. Plantei temporariamente uma propriedade de produção
compilável em `Traco/App/TituloTela.swift`, rodei apenas
`PortaoDoTryBangTests` e obtive:

```
✘ Test nenhumTryBangNovoNaProducao() ...
Traco/App/TituloTela.swift: 1 hoje, 0 congelado  ← SUBIU
✘ Suite PortaoDoTryBangTests failed after 0.229 seconds with 1 issue.
** TEST FAILED **
```

Removi a sonda; `git diff -- Traco/App/TituloTela.swift` voltou a zero. A
suíte integral posterior passou. A tabela congelada do teste enumera oito
ocorrências reais e classifica as quatro dívidas (`FonteNotas`,
`PraticaTrabalho`, `Corpus:144`, `Sessao:599`) como dívida e as demais como
infallíveis/condicionais, incluindo a ressalva de `ConferenciaTrabalho`.

**Achado R1 — evidência de medição falsa (médio).** `a1-arranque.md`, ADR 08n,
RUMO e o comentário do portão afirmam que `grep -rn 'try!' Traco/ TracoWidget/`
deu 9 antes e 8 depois. No candidato, esse comando literal devolve **10**
linhas; em `main`, devolve **9**. As duas linhas adicionais são comentários
novos da A1. O portão não está cego: ele usa `codigoVisivel`, que remove
comentários/strings, e chega aos oito casos corretos. Ainda assim, a prova
documentada não é reprodutível como escrita e precisa dizer `codigoVisivel`
ou corrigir o comando/números.

## Build e suíte

No UDID designado, candidato atual, DerivedData isolado e
`-parallel-testing-enabled NO`:

```
** BUILD SUCCEEDED **
build warning lines = 0
✔ Test run with 934 tests in 152 suites passed after 75.121 seconds.
** TEST SUCCEEDED **
test warning lines = 0
```

## Estados declarados mas ainda não provados

- **Espelho vazio — falta.** A ramificação é simples e honesta no código, mas
  é a mensagem que pode dizer à pessoa que nenhuma cópia foi encontrada. Sem
  captura (ou teste de UI que a exija), G2 não demonstrou todos os estados
  relevantes da própria tela.
- **VoiceOver falado — falta.** AX confirma cabeçalho, copy, local do conteúdo,
  botão e detalhe técnico nessa ordem, mas não substitui ouvir a leitura no
  aparelho. A ordem estrutural é boa; a prova auditiva ainda não existe.

## Scorecard

| dimensão | nota | evidência e limite |
|---|---:|---|
| Visão | 9 | Item 8 e EVOLUCAO; preservar vem antes de recuperar. |
| Contrato | 8 | Código/ADR coerentes, mas R1 torna a prova de “medida” falsa como escrita. |
| Correção | 9 | Falha real, vermelho plantado, build e 934/152 verdes. |
| Jornada real | 8 | Falha, repetição, AX5 e recuperação reais; espelho vazio não visto. |
| Design | 9 | Seis fases relatadas e conferíveis; um ato, tokens existentes, sem ornamento. |
| Simplicidade | 9 | Caminho normal inalterado; falha oferece uma ação recuperável. |
| Movimento | n/a | Tela estática; nenhuma animação introduzida. |
| Componentes | n/a | Tela única usa componente primário existente; nada reutilizável nasceu. |
| Acessibilidade | 8 | AX5, alvo e ordem AX passam; VoiceOver falado não foi exercitado. |
| Performance | n/a | Tela estática, sem lista/editor/parser novo. |
| Privacidade e autoria | 9 | Não monta rotas do caderno falso; hashes do espelho preservados. |
| Estado honesto | 9 | Explica recusa, conta medida, não promete reparo e mostra segunda recusa. |
| Complexidade | 9 | Estado explícito substitui fallback perigoso; sem dependência nova. |
| Fora do app | n/a | Nenhuma superfície externa foi alterada. |
| Relato | 8 | Boa evidência visual, mas R1 e os dois limites impedem nota 9. |

## Correções antes de G5

1. Corrigir R1 em todos os textos: não atribuir 9→8 a `grep` literal; registrar
   a varredura que remove comentários/strings e seu resultado reproduzível.
2. Exercitar e guardar a tela com espelho vazio.
3. Ouvir VoiceOver no mesmo UDID e registrar ordem/fala, ou declarar a
   incapacidade como lacuna que mantém Acessibilidade abaixo de 9.
