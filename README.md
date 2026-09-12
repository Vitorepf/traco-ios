# Traço

Traço transforma intenção em realização no mundo, combinando **mente humana,
IA e um ambiente compartilhado de trabalho**. Ao realizar, desenvolve as
capacidades que limitam o que a pessoa poderá realizar depois.

A [visão vigente](VISAO-PRODUTO.md), consolidada com o criador em 05/09/2026,
define os dois ciclos: **multiplicar a capacidade de realizar agora** e
**melhorar capacidades relevantes para multiplicar mais no futuro**. Notas,
calendário, métodos, segundo cérebro e Markdown são partes desse sistema.
HTML pode ampliar suas representações e artefatos interativos.

**Direção não é implementação concluída.** A base atual oferece escrita,
formas, recordação, calendário e contexto. Trabalho acrescenta intenção,
artefatos versionados, produção delegada, ações, relatos, hipóteses corrigíveis
e ida/volta em Markdown. A qualidade da geração, desenvolvimento de capacidades,
HTML e continuidade entre ferramentas ainda têm lacunas em [EVOLUCAO.md](EVOLUCAO.md).

## Princípios de produto

1. **Delegação com origem clara.** A IA pode produzir trabalho delegado.
   Não deve se passar pelo autor nem substituir silenciosamente a atividade
   que ele escolheu praticar. Delegar programação para criar um produto não
   equivale a dívida cognitiva por definição. As rotas atuais de nota ainda
   têm restrições históricas; a migração precisa preservar dados e autoria.
2. **Privacidade em todas as rotas.** O contrato de proteção de expressivas,
   notas seladas e queimadas continua obrigatório, inclusive em projeções,
   busca, exportação e contexto da IA. É requisito a verificar, não certificado.
3. **Método a serviço da intenção.** Um método por nota continua sendo uma
   regra do fluxo atual; um objetivo pode atravessar métodos e artefatos.
4. **Estado honesto.** Silêncio pode ser válido na classificação incerta.
   Falha de gravação, execução ou recuperação precisa ser comunicada.
   Produzido, executado e resultado observado são estados distintos.
5. **Realização e autonomia como critérios.** Uso, streaks, XP ou elogios
   não demonstram desenvolvimento. A conversa curta em Notas é permitida
   pela ADR 05e; a antiga proibição global de chat não rege esse fluxo.

## Como rodar

Projeto gerado por [XcodeGen](https://github.com/yonaskolb/XcodeGen) — o
`.xcodeproj` é derivado, não fonte de verdade.

```bash
xcodegen generate
xcodebuild build -project Traco.xcodeproj -scheme Traco \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build
```

Testes (Swift Testing, inclui fuzz de propriedade do parser):

```bash
xcodebuild test -project Traco.xcodeproj -scheme Traco \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath build
```

Os exemplos exigem Xcode, XcodeGen e um simulador iPhone 17 disponível. Confira
`xcrun simctl list devices available`; com nomes repetidos, use
`-destination 'platform=iOS Simulator,id=<UDID escolhido>'`. Na auditoria desta
evolução, build e testes rodaram em candidato isolado, com UDID explícito; não
se presume que o projeto gerado ou um simulador arbitrário já estejam atualizados.

Varredura E2E ([Maestro](https://maestro.mobile.dev)) — recusa rodar com mais
de um simulador ligado, porque com dois o instalador e o driver escolhem
aparelhos diferentes e o veredito sai falso:

```bash
./maestro/varrer.sh                    # todos os fluxos
./maestro/varrer.sh maestro/busca.yaml # um fluxo
```

O script exige build no caminho acima e `~/bin/maestro`. Leia o fluxo antes:
alguns cenários limpam o estado e os testes vivos usam o modelo disponível.
Use um simulador de teste; não desligue ou apague aparelhos alheios para
satisfazer a pré-condição. O status do script não substitui examinar seu resumo
de falhas e a evidência do fluxo.

## Os documentos

| Arquivo | Papel |
|---|---|
| [VISAO-PRODUTO.md](VISAO-PRODUTO.md) | Tese vigente, objetivo, delegação, caderno único e critérios de realização/desenvolvimento. |
| [AGENTS.md](AGENTS.md) | Entrada operacional para agentes: finalidade, fontes, invariantes, código e verificação. |
| [SPEC.md](SPEC.md) | Contratos atuais e ADRs datadas. Seções 1, 2, 12 e 19 seguem a visão; veto universal antigo à geração foi substituído. |
| [EVOLUCAO.md](EVOLUCAO.md) | Matriz integral: estado comprovado e trabalho ainda necessário. |
| [SISTEMA-CLARO.md](SISTEMA-CLARO.md) | Sistema visual vigente; SISTEMA.md conserva o sistema escuro histórico. |
| [META.md](META.md) · [META-FINAL.md](META-FINAL.md) · [PROMPT.md](PROMPT.md) · [PLAN.md](PLAN.md) | Roteiros/metas de trabalho com estado e escopo explícitos; não substituem a visão. |
| [FILA.md](FILA.md) | Pendências e registros datados; revalidar contra objetivo e candidato atuais. |
| [CATALOGO.md](CATALOGO.md), [COLHEITA.md](COLHEITA.md), [DOSSIE.md](DOSSIE.md), [VIZINHANCA.md](VIZINHANCA.md), [REFERENCIAS.md](REFERENCIAS.md) | Pesquisa e propostas; não constituem ordens de implementação nem validação universal de eficácia. |
| [.cursor/rules/traco-meta.mdc](.cursor/rules/traco-meta.mdc) · [.cursor/skills/traco-meta/SKILL.md](.cursor/skills/traco-meta/SKILL.md) | Entradas existentes do Cursor, subordinadas à mesma visão. |
| [prova/1.md](prova/1.md) · [prova/2.md](prova/2.md) · [prova/3.md](prova/3.md) · [_historico/menu-136/PROMPT-menu-136.md](_historico/menu-136/PROMPT-menu-136.md) | Evidência/prompt históricos, preservados com data e escopo; não certificam o produto atual. |

## Sem servidor

Notas em SwiftData no aparelho, com backup automático em `.md` no app Arquivos.
As revisões espaçadas são notificações locais. Rotas de IA podem falar direto
com a xAI usando a conta Grok do autor (Keychain) ou usar Apple Intelligence
quando disponível. Não há backend próprio a hospedar. O fallback depende da
superfície: classificar pode resultar em silêncio; falha de produção ou
gravação de Trabalho precisa ser informada. Não confundir disponibilidade
local com equivalência de qualidade ou prova de custo da assinatura.

## Estrutura

```
Traco/
  Analise/     motor local, motor remoto, conta Grok, a sábia
  Modelo/      Metodos.json (o catálogo), Sinais, Retrato, Degraus
  App/         raiz, camadas de navegação, sessão
  Caderno/     parser de blocos, editores, portais, régua de formas
  Notas/       arquivo, busca, corpus, export/import
  Pagina/      a página em branco, cartão da Análise, campos de forma
  Trabalho/    intenção, artefatos, execução delegada, ações, evidência e Markdown
  Calendario/  compromissos e projeção das ações dos Trabalhos
  Padroes/ Perfil/ Recordar/ Confirmacao/
TracoTests/    suíte + fuzz do parser
maestro/       fluxos E2E; cenarios/ = famílias hostis
```

## Documentos de setembro

- `SISTEMA-CLARO.md` — o mundo claro: tokens medidos, componentes por estado, movimento, ordem de aplicação (ADR 2026-09-02h).
- `DOSSIE.md`, `VIZINHANCA.md`, `REFERENCIAS.md`, `CATALOGO.md`, `COLHEITA.md` — o mercado e o que se colheu dele.
- `ferramentas/traco-mcp/` — o companheiro no Mac: servidor MCP de consulta e entrada de notas na pasta do Traço; não é ainda um executor geral de realizações.
- SPEC ADRs 2026-09-02o a q — contratos locais da sábia/prática, formas Decisão e Pré-mortem e revisão da semana; não são veto global à produção delegada.
- SPEC ADR 2026-09-12a e a seção **Um caderno, parâmetros escondidos** da visão — um bloco só; classificar cala; pesquisa não vira voz; sem modo território.
- SPEC ADRs 2026-09-04g a s — o ciclo da mente: o sinal (serviu / não serviu), o retrato que viaja com cada pergunta, degraus para instigar e vestir, as formas que se encadeiam (DEPOIS DISTO), o catálogo de 21 métodos como dado (`Traco/Modelo/Metodos.json` + `Documents/Traço/metodos/*.json`), Contrapor, o índice de sentido no aparelho, o corpus incremental, a entrada do Mac (`entrada/`, pelo MCP `traco_escrever`), a trajetória nos Padrões, e a doutrina "abundante no ato, calada na pausa".
