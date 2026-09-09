# re-G3 — R1 retomada: a régua do dono foi cumprida

**Veredito: A RÉGUA DO DONO ESTÁ APROVADA (re-G3).** No commit `8a87819`,
Design, Simplicidade e Complexidade chegam a 9 por provas que conferi de novo;
nenhuma dimensão aplicável fica abaixo de 9. G5 ainda não está autorizado:
`main` avançou 25 commits e o `merge-tree` encontrou quatro caminhos alterados
nos dois lados; a integração e nova verificação do candidato mesclado são do
orquestrador.

Revisor independente: Codex GPT-5. Simulador exclusivo: iPhone 17 Pro (teste
3) `34CC3F94-FDB5-4575-A4F5-80271829A18B`; não toquei o `C2416CBC`. Todo
`xcodebuild` e helper passou por `ferramentas/orca/com-trava.sh`; não usei
Maestro, cursor, voz, Siri, ditado, VoiceOver ou iPad. Ao fim deixei meu
aparelho em `large`, com o binário de `8a87819` instalado, e o desliguei por
`xcrun simctl shutdown <UDID>`.

## Conferências da re-G3

### As seis fases não são mais formalidade

`ferramentas/orca/r1b-retomada.md:24-83` cobre as seis fases e cada uma se
sustenta no produto:

| Fase | O que fez / conferi |
|---|---|
| Ancorar | Define a tarefa verificável: voltar e saber objetivo, próximo passo e cinco fatos; a lista é a mesma do condutor `CurvaZeroRetomadaUITests.fatos`. |
| Sistema | Reusa `secao`, `Tema.meta`, `Tema.tintaSuave`, `Pilula` e a `retomada` existente; a captura normal não mostra um enxerto visual. |
| Construir | Um bloco local e `mudancasDesde`, sem tela, componente, agregado ou frase de modelo novos. |
| Mover | Aplicável e justificada: não animar a chegada privilegia leitura; também registra por que a abertura não rola sozinha. |
| Julgar | Confronta a auditoria com a tela e acrescenta visita, reabertura e AX5. |
| Portão | Domínio + quatro testes de UI; refiz os quatro estados no candidato. |

Isso fecha a causa da nota 6 anterior. A fase Mover dizer “nada se move” com
razão é cumprimento, não campo vazio.

### Curva-zero: medida de novo no mesmo aparelho e estado

Recompilei e rodei os dois candidatos no `34CC3F94`, com `large`, o mesmo
semeador e o mesmo condutor XCUITest. Para `c751c02`, usei um arquivo temporário
isolado criado por `git archive` e acrescentei somente o condutor de medição;
para `8a87819`, usei o condutor versionado. Nenhum arquivo de produto foi
alterado.

| Candidato | Toques até a folha | Arrastos na folha | Fatos sem gesto |
|---|---:|---:|---:|
| `c751c02` | 3 | **5** | 2 de 7 |
| `8a87819` | 3 | **0** | **7 de 7** |

As saídas que eu gerei repetem as tabelas versionadas
`r1b-medida-antes.txt`/`r1b-medida-depois.txt`: antes, o sétimo fato chega no
gesto 5; depois, todos estão marcados na linha 0. A corrida depois terminou em
`Test Case '-[TracoUITests.CurvaZeroRetomadaUITests
testCurvaZeroEmToquesEGestos]' passed` e `** TEST SUCCEEDED **`; a do antes
terminou no mesmo teste, também verde. A régua agora mede operação, não altura
da árvore. As alturas AX continuam apenas explicação de distância.

### Visita, teto e AX5

No candidato, executei de novo os três estados restantes, todos verdes no mesmo
UDID:

```
testTetoExcedenteEAVisitaQueRecomecaAoReabrir  — 1 teste, 0 falhas
testSemVisitaGuardadaAFolhaCala                — 1 teste, 0 falhas
testBlocoDaRetomadaEmAX5                       — 1 teste, 0 falhas
** TEST SUCCEEDED **
```

O primeiro confere quatro `trabalho-mudanca`, a linha literal `e mais 1 desde
então` e que reabrir cala a notícia já entregue; o segundo prova a primeira
visita sem bloco; o terceiro percorre até uma linha visível em AX5 e verifica
os limites horizontais. Conferi também as capturas versionadas: `r1b-normal.png`
mostra o teto e o excedente, `r1b-sem-visita.png` mostra a ausência na folha
inteira, e `r1b-ax5.png` mostra o bloco grande, legível e sem sangramento
lateral. A árvore do helper, reatada sob a trava depois que o runner acabou,
voltou para a Tela de Início; portanto não a conto como prova do app — as
assertivas XCUITest e as capturas pareadas versionadas são a evidência válida.

### O que mudou na nota

| Dimensão tocada | G3 anterior | Agora | Prova |
|---|---:|---:|---|
| Design | 6 | **9** | seis fases com ato ou inaplicabilidade justificada, e captura normal/AX5 |
| Simplicidade | 7 | **9** | comparação independente: 3+5 para 3+0, sete fatos na primeira tela |
| Complexidade | 8 | **9** | diff de produção `c751c02...8a87819`: 151 adições/14 remoções; o relatório separa 81 linhas líquidas de código, elimina `visitaLida` e centraliza `ResultadoObservado.frase`; nenhuma dependência, tela ou componente de um só uso |
| Correção | 8 | **9** | quatro testes de UI rerodados e verdes; relatório do candidato registra 963/155 verde no mesmo commit |
| Jornada real | 8 | **9** | normal, sem visita, reabertura e AX5 exercitados com fixture do app |
| Acessibilidade | 8 | **9** | AX5 exercitado e captura conferida; VoiceOver falado continua declarado como limite |
| Relato | 6 | **9** | `r1b-retomada.md` explica as fases, a comparação e os limites sem esconder o que não prova |

## Scorecard

| Dimensão | Nota | Evidência / limite |
|---|---:|---|
| Visão | 9 | Retomada serve ao ciclo multiplicar; uso real do dono segue lacuna declarada. |
| Contrato | 9 | ADR 08y, código, SPEC e EVOLUCAO coerentes. |
| Correção | 9 | Build independente verde e quatro testes de UI rerodados; suíte 963/155 é evidência registrada do candidato, não uma nova corrida minha. |
| Jornada real | 9 | Estado plantado e percurso XCUITest nos dois candidatos; visita/teto/AX5 repetidos no depois. |
| Design | 9 | Seis fases materiais, sistema existente e decisão de não rolar/não animar justificada. |
| Simplicidade | 9 | 3 toques + 5 arrastos vira 3 + 0; os sete fatos já estão na primeira tela. |
| Movimento | n/a | A R1 não altera movimento; a recusa da rolagem automática está justificada. |
| Componentes | n/a | Nenhum componente novo; extrair este único chamador aumentaria a superfície. |
| Acessibilidade | 9 | AX5 passa sem sangramento; VoiceOver falado não foi usado por ordem do dono. |
| Performance | n/a | Não há nova lista, editor ou parser; nenhum trace novo exigido por este ajuste local. |
| Privacidade e autoria | 9 | Visita local e linhas determinísticas; sem modelo, publicação ou gasto. |
| Estado honesto | 9 | Executado e observado seguem distintos; sem visita o app cala, sem inventar data. |
| Complexidade | 9 | Simplificação local verificável, sem dependência nem abstração especulativa. |
| Fora do app | n/a | Nenhuma superfície fora do app foi tocada. |
| Relato | 9 | Fecho e mudanças de nota trazem provas e limites. |

Limites honestos: a medida é gesto XCUITest, não observação de um participante;
não foi repetida em AX5 porque ali a prova é legibilidade, não esforço; e isto
não prova que o dono efetivamente volta e continua. Nenhum desses limites reduz
a prova pedida para este candidato.
