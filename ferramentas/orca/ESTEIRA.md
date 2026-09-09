# Esteira de qualidade do Traço

Vale para toda volta do laço. Nota por dimensão de 0 a 10, dada pelo revisor independente com evidência anexada. Nenhuma volta mescla em main com dimensão abaixo de 9. Dimensão que não se aplica à volta recebe "n/a" com o motivo, nunca nota de cortesia.

## Portões, na ordem

| portão | quando | quem | o que prova |
|---|---|---|---|
| G0 contrato | antes de editar | orquestrador | linha da volta (ciclo, intenção, obstáculo, evidência), escopo de arquivos, critérios verificáveis, prova esperada; volta visual passa por design-router: Ancorar e Sistema fechados aqui |
| G1 instrumento | ao terminar de editar | implementador, via com-trava.sh | build sem aviso, suíte integral verde no simulador de teste, testes novos para cada comportamento novo |
| G2 jornada | após G1 | implementador | capturas simctl de cada tela alterada nos estados: normal, vazio, carregando, falha, sem permissão, Dynamic Type grande; vídeo simctl quando há movimento |
| G3 revisão | após G2 | Fable revisor em sessão própria | scorecard abaixo preenchido com evidência; achado alto volta ao dono da área; revisão nunca corrige |
| G4 design | só volta visual, após G3 | segundo Fable, papel de julgar do design-router | fases Mover, Julgar e Portão; compara captura antes e depois; recusa acabamento que compensa fluxo confuso |
| G5 merge | tudo ≥ 9 | orquestrador | merge sem conflito, ADR, EVOLUCAO, LACO, RUMO atualizados, worktree removido |

Duas recusas seguidas na mesma volta abrem consulta ao conselho (Astra) antes da terceira tentativa. O conselho é para você decidir, não para o dono decidir: o parecer é insumo, a decisão é do orquestrador (DIRETRIZ §6).

## Skills obrigatórias por portão

Ordem do dono (06/09): usar cada vez mais `design-router`, `curva-zero` e `gate-loop`. Não é sugestão; é parte do portão. O worker carrega a skill ANTES de escrever qualquer código e cita no relato a fase em que estava.

| skill | quem carrega | quando | o que o relato tem de citar |
|---|---|---|---|
| `gate-loop` | orquestrador, em toda volta | no G0, para fixar resultado, escopo, critérios e provas; e a cada recusa, para decidir a próxima ação | contrato da volta e o critério que falhou |
| `design-router` | todo worker que toca view, Tema, componente, movimento ou copy | antes da primeira linha de SwiftUI; redesenho começa na fase de auditar antes de tocar | as seis fases: Ancorar, Sistema, Construir, Mover, Julgar, Portão |
| `curva-zero` | worker de jornada, formulário, onboarding, folha, primeiro uso, ou tela com nota de Simplicidade abaixo de 9 | ao desenhar o roteiro, antes do layout | jornada, resultado verificável, atrito observado, recuperação |

Volta visual sem as fases do `design-router` citadas no relato é recusada no G4, mesmo que o código esteja certo. Volta de jornada sem `curva-zero` é recusada na dimensão Simplicidade. O revisor confere a citação contra o que está na tela, não aceita a menção sozinha.

## Lei do instrumento — o maestro não isola (achado de 06/09, com prova)

`maestro --device` / `--udid` **NÃO isola**: o driver residente de outro simulador segura a porta 7001 e o maestro passa a ler a **hierarquia do vizinho**. Provado às 16h54 de 06/09 pelo revisor da F3b, que teve o maestro jurando que "Gravando." não estava na tela enquanto o `simctl` do próprio UDID mostrava "Gravando." no mesmo instante.

Consequência, e é dura: **com mais de um simulador ligado na máquina, nenhuma nota, achado ou veredito pode se apoiar em evidência do maestro** — nem `assertVisible`, nem `assertNotVisible`, nem `hierarchy`. Prova de tela é `xcrun simctl io booted screenshot` e o conteúdo do contêiner do próprio UDID. Quem precisar mesmo de maestro garante ser o único simulador ligado naquele instante, e escreve no relato que garantiu. Fluxo que falha de um jeito que não faz sentido é **instrumento**, e não desconta nota.

A mesma máquina, com seis ou sete simuladores, derruba simulador sozinha por pressão de memória — o iPhone 17 do dono caiu assim, sem ninguém o tocar. Ligue só o seu, desligue ao terminar.

**`booted` é ambíguo e outra sessão instala por cima de você** (achado de 08/09, 11h04, com prova). O worker da F4-F viu o contêiner do app trocar de bundle sozinho no simulador dele (`17814799` → `A6548AD8`) e o dylib instalado voltar a ser o código de `main` — sem que ele instalasse nada. Perdeu ~25 min perseguindo um "cache do `chronod`" que não existia: a casa mostrava o código velho porque **outra sessão reinstalou por cima**, usando `booted` com vários simuladores ligados.

Lei: **nunca `booted` e nunca `-destination generic` para instalar**. Sempre `xcodebuild -destination id=<UDID>` e `xcrun simctl install <UDID>`; captura sempre `xcrun simctl io <UDID> screenshot`. E a defesa que o próprio worker inventou, que vale para todos: **quando a tela mostrar comportamento antigo que você jura ter consertado, confira os símbolos do dylib instalado (`nm` no binário do contêiner) antes de caçar cache** — pode ser outra sessão em cima do seu aparelho, não um bug seu. Simulador que outra sessão declarou como dela é dela: leia o que as sessões vizinhas escreveram antes de escolher o seu.

**VOZ, VOICEOVER E iPAD SÃO PROIBIDOS (lei de 08/09, ordem do dono, repetida por ele inúmeras vezes).** Nenhum worker aciona Siri, o botão siri do `orca emulator`, ditado por voz, Speak Screen, VoiceOver ou `say`, em simulador nenhum, nunca: a fala dos simuladores sai pelas caixas do Mac do dono, e em 08/09 ele ouviu a Siri do teste 2 e do teste 4 enquanto trabalhava. Prova de Siri, de ditado e de qualquer entrada por voz é no iPhone do dono, com ele presente, ou não existe. Acessibilidade se prova pela árvore (`orca emulator ax`, hierarquia) e por captura, nunca com VoiceOver ligado. iPad não existe no Traço e não se cita. Worker que violar é parado e a volta recomeça. Vai no preâmbulo de todo spec, antes de qualquer outra lei.

**UM SIMULADOR SÓ (ordem do dono, 09/09 08h50).** Só o iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9` fica ligado, e é o aparelho da conta Grok (o dono autorizou lá em 09/09 10:55 e mandou "usar o que já está funcionando"; o C2416CBC deixou de ser o aparelho da conta). Ninguém liga outro. Build, suíte, sonda, capturas e jornada correm nele, serializados por `com-trava.sh`. Nada de erase, clearState ou uninstall; instalar por cima só quando a volta precisa do binário novo, uma vez, com `ContaGrok.ligada` conferido antes e depois; se a conta cair, o worker para e diz o comando que a derrubou. Com um aparelho, o maestro volta a valer como evidência.

**O controle do computador está LIBERADO para todo worker (ordem do dono, 08/09 22h, DIRETRIZ §7).** O worker pode usar o computer-use do Orca, o simulador, apps do Mac e o Espelhamento do iPhone quando a prova exigir o aparelho, com duas condições: avisar no comentário do worktree ao começar e ao terminar, e nunca dois workers no mesmo app ao mesmo tempo. Para o simulador, `orca emulator` continua sendo o caminho preferido (toca pelo UDID, sem disputar o cursor); `cliclick` em coordenada de tela cai na janela do vizinho. Quem muda orientação, tamanho de letra ou aparência restaura ao fim. **VOZ, VOICEOVER E iPAD CONTINUAM PROIBIDOS.**

**A galeria de widgets trava.** A folha "Adicionar Widget" para de paginar e depois trava de vez — três sessões seguidas de revisão da F4 esbarraram nisso, e já custou replantio de widget em três revisões. Some com o Simulator reiniciado, às vezes. Quando travar: é instrumento, não desconta nota, e a saída é usar as capturas de quem conseguiu plantar, conferindo o conteúdo e o relógio delas. A Live Activity do Destaque também engole o toque no botão "Editar" da galeria.

## Medir a rota certa — lei de 08/09, achada pela volta Q

**Hash de fixture e JSONL completo NÃO impedem medir a rota errada.** Na volta Q, três dos seis casos de `responderNasNotas` exercitaram `Sabia.responderNasNotas(pergunta:contexto:)`, que **não tem nenhum chamador de produção**: existe só para a sonda, e embrulha a string de contexto numa fonte sintética com o título literal "Contexto fornecido". A atribuição genérica que ia ser registrada como **defeito do provedor** era um título **fabricado pelo próprio app** — o modelo citou corretamente a única fonte que recebeu.

Lei, para toda volta que medir comportamento de IA ou de qualquer motor: **antes de dar nota, leia os chamadores e diga, operação por operação, com arquivo e linha, qual rota a produção usa e se o caso mediu ESSA rota.** Rota exercitada só pela medição é armadilha, não conveniência: apague-a ou exija o caminho real. Medição feita por rota fantasma é **inválida por defeito do instrumento** — registre assim, com essas palavras, mesmo quando a conclusão anterior era favorável a nós. E medição inválida **não vira boa por ser antiga**: as bases anteriores que usaram a rota morta ficam marcadas como tal, sem reescrever prova alheia.

Isto é irmão do achado da V12-D (o quadro longo era o `fotografar()` do próprio teste) e do `ax --device` que lê o vizinho: **em três medições do mesmo dia, o instrumento foi o réu.**

## Verde que não visitou o lugar do defeito — o padrão de 08/09

**Quatro vezes num dia** um instrumento nosso provou menos do que parecia, e sempre pelo mesmo mecanismo: **passou verde sem visitar o lugar onde o defeito mora.**

1. **V12-D:** o quadro longo na rolagem não era do app — era o `fotografar()` do próprio teste (`drawHierarchy` + PNG de 1,3 MB, 127–162 ms na main thread).
2. **`ax --device`:** lê a árvore do aparelho VIZINHO sem avisar, então a medida de geometria pode ser do aparelho errado e parecer certa.
3. **Volta Q:** três casos mediram uma sobrecarga **sem chamador de produção**, que fabricava o título "Contexto fornecido" — a "atribuição genérica do provedor" era um título do próprio app.
4. **V12-E:** o teste que devia provar que o fantasma acabou **aceitava o estado sem cartão e passava verde** — não percorria "Abrir os campos", que é onde o fantasma vivia.

Regra, para todo portão novo: **o teste declara o estado que exige como PRÉ-CONDIÇÃO QUE FALHA**, nunca como estado aceitável — se o cenário não foi montado, ele fica vermelho dizendo isso. E **todo portão nasce com a prova do vermelho**: plante a violação, mostre a falha, remova. Verde sozinho não é portão; é confiança falsa, que é pior que nenhuma.

**Dois becos de plantio de estado, achados pela V12-F em 08/09**, que fazem um teste passar verde sem o estado que ele exige: **`'1'` e `'YES'` chegam como String ao domínio de argumentos**, e o `object(forKey:) as? Bool` os ignora — plante `<true/>`/`<false/>` de verdade e confira lendo o valor de dentro do app; e **`xcodebuild test-without-building` troca o contêiner**, então plantar por plist antes dele não chega ao app que roda.

**`orca emulator gesture` exige `type` begin/move/end em CADA ponto** (achado da E1-C, 08/09): sem isso ele devolve `ok:false` e **não faz nada** — e um gesto que não acontece parece um app que não responde.

### ⛔ VOZ, VOICEOVER E iPAD SÃO PROIBIDOS NO TRAÇO — SEM EXCEÇÃO

Ordem do dono, repetida inúmeras vezes e reforçada em **08/09 19h35, com o Mac dele falando alto**. Proibido: comando por voz, acionar a Siri (inclusive `orca emulator button siri`), ditado por voz, Speak Screen, **VoiceOver ligado em simulador**, `say`, síntese de fala por qualquer caminho, e **iPad em qualquer forma**. Vale para todo worker, todo juiz e todo revisor, e vai **no preâmbulo de todo spec**.

**O que vale no lugar:** prova de Siri é **no iPhone do dono, com ele** — no simulador ela não é evidência; teste de acessibilidade é **por árvore de acessibilidade e captura conferida no mesmo instante**, com o VoiceOver falado **declarado como limite**, o que **não desconta nota**; e **um simulador por worker**, dito no relato.

**Nada de Siri, ditado por voz ou síntese de fala em simulador enquanto o dono está na máquina** (ordem do dono, 08/09 19h25, depois de OUVIR a voz). A síntese roda dentro do simulador (`sirittsd`, `SiriAUSP`, `MacinTalk`) e sai pelas caixas do Mac; inclui `orca emulator button siri`, Speak Screen e ditado do teclado. E a razão que torna a lei fácil de aceitar: **prova de Siri é no iPhone do dono, com ele** — no simulador ela não conta como evidência, então acioná-la não produz prova, só ruído na sala de quem trabalha. O mesmo vale para VoiceOver falado: prove pela árvore de AX conferida contra captura, e declare o falado como limite.

## Scorecard

| dimensão | mínimo 9 significa | evidência |
|---|---|---|
| Visão | a volta entra num dos dois ciclos e fecha uma lacuna nomeada do EVOLUCAO | linha G0 + diff do EVOLUCAO |
| Contrato | ADR curta, SPEC e EVOLUCAO coerentes com o código | diff dos três |
| Correção | comportamento novo coberto por teste; suíte verde; sem regressão nos fluxos maestro tocados | linhas de resultado coladas |
| Jornada real | todos os estados do G2 vistos na tela, conteúdo conferido, não só o arquivo | capturas nomeadas |
| Design | Ancorar, Sistema, Construir, Mover, Julgar, Portão cumpridos; tokens de Tema.swift, nada solto | relato do G4 |
| Simplicidade | curva-zero: caminho comum evidente, passos, decisões e telas não crescem; poder avançado continua encontrável | contagem antes/depois |
| Movimento | toda animação tem propósito, é interrompível, respeita movimento reduzido, duração e curva coerentes com o sistema | vídeo simctl + reduce motion |
| Componentes | reutilizável, um lugar só em Traco/Componentes, estados completos, preview, nome em pt, sem duplicata | diff + preview |
| Acessibilidade | VoiceOver com rótulos e ordem certa, Dynamic Type até XXL sem clipe, contraste, alvo ≥ 44 pt | captura AX + Dynamic Type |
| Performance | sem hitch em rolagem e digitação nas telas tocadas; Instruments quando toca lista, editor ou parser | trace ou medida |
| Privacidade e autoria | selo, origem e rotas protegidas intactos; nada publica, gasta ou envia sem gesto | teste + leitura do diff |
| Estado honesto | produzido, agendado, executado e observado distintos na tela; falha visível, nunca escondida | captura da falha |
| Complexidade | linhas líquidas, arquivos e dependências não crescem sem lacuna que justifique; simplificação conta como entrega | shortstat |
| Fora do app | superfície entregue com captura real em todos os estados (início, bloqueada, Ilha compacta/expandida/mínima, StandBy), um toque faz uma coisa, nada protegido exposto, orçamento de atualização respeitado | capturas por estado + vídeo |
| Relato | fecho em seis linhas com evidência, legível por quem não abre terminal | LACO |

## Conselho de arquitetura (Astra)

O Astra é o interlocutor de altíssimo nível do orquestrador, não implementador. Usar para: estrutura e arquitetura, contratos difíceis, direção do sistema de design e de componentes, empacotamento, trade-offs de concorrência e dados, e revisão de rumo. Até duas consultas por volta e uma revisão de rumo por dia sobre o LACO e o RUMO. Parar em 90% da cota semanal do Codex. Cada consulta fica gravada em ferramentas/orca/consulta-*.md com a pergunta e a recomendação.

## Rumo

O orquestrador mantém ferramentas/orca/RUMO.md: lista ordenada das próximas voltas com valor, esforço, ciclo e lacuna, atualizada a cada fecho. As três primeiras já trazem a linha G0 pronta. Volta que não está no RUMO não abre. O dono lê o RUMO para saber o que vem, e o LACO para saber o que veio.

## Frente de front-end

Antes de multiplicar voltas visuais, uma volta de auditoria (design-router, fase de auditar antes de tocar) percorre as telas principais e dá nota base no scorecard para cada uma. Em seguida uma volta de fundação: tokens em Tema.swift, pasta Traco/Componentes com previews, biblioteca de movimento com curvas e durações nomeadas. Só depois as voltas por tela, cada uma subindo a nota da tela até 9 ou mais. Tela abaixo de 9 no RUMO tem prioridade sobre função nova de mesma lacuna.

### Worker morto não é volta perdida (08/09)

Dois despachos da A1 terminaram `failed`, terminal `exited`, **sem `worker_done`
e sem saída capturada** — falharam calando. O que eles tinham feito continuava
no worktree: quatro arquivos modificados, uma captura nova, as três correções do
revisor escritas. Refazer a volta do zero teria jogado tudo fora.

**Terceira vez em 24 h** (A1-B, A1-C, M1-B, 08/09–09/09): o terminal sai, o
despacho fica `dispatched` ou `failed`, e **o trabalho está inteiro no worktree**.
Na M1-B estavam lá as fixtures `v0` a `v5`, o schema `V0` e o teste ampliado — e o
portão já tinha passado no aparelho.

**Regra:** ao ver um despacho morto, **`orca orchestration worker-read --dispatch <id>`** e, em seguida, `git status` e
`git diff` no worktree dele — antes de decidir se a volta recomeça, continua ou
fecha. O spec do sucessor diz onde o trabalho parado está e manda **ler o diff
antes de qualquer coisa**, sem `stash` e sem refazer. E o sucessor **confere os
números em vez de acreditar neles**: quem os mediu não está mais aqui para
responder por eles.

### O registro das letras de ADR é do orquestrador, e mora aqui (08/09)

Três voltas colidiram na mesma letra em um só dia — a A1 e a E1-B em `08n`, a
V13 e a Q em `08p` — e a causa é minha: eu reservava **uma letra por volta**,
quando uma volta escreve **quantas ADRs precisar**. Quem mescla primeiro fica
com a letra; quem chega depois renumera, e renumerar depois de um revisor já ter
conferido a letra **invalida uma prova conferida**.

**Regra:** o registro mora em `ferramentas/orca/LETRAS-ADR.md`, num lugar só, e
o spec de cada volta aponta para lá em vez de carregar a sua cópia — reservar
dentro de cada spec foi o que produziu a TERCEIRA colisão do dia (dei a mesma
`08w` à Q-H e à C1, porque a lista vivia espalhada). Antes de qualquer volta
escrever uma ADR, o orquestrador lê o registro completo com um comando, não de
memória:

```
for ref in main origin/main <cada branch vivo>; do
  echo "$ref: $(git grep -ho '2026-09-0[0-9][a-z]' $ref -- SPEC.md | sort -u | tr '\n' ' ')"
done
```

O registro vale para **todas as refs vivas**, não só `main`: o branch que ainda
não mesclou já é dono da letra dele. **Buraco antigo não se reaproveita** (a
`08c` e a `08d` estão vagas e ficam vagas — reusar uma letra morta faz duas
coisas diferentes terem o mesmo nome na história).

**Quando duas voltas vivas colidem, muda quem é mais barato de mover**, não quem
chegou depois: uma volta com três ADRs encadeadas e revisor que já conferiu
letra a letra fica; uma ADR sozinha muda.

**A renumeração se prova assim** (e a prova é do tamanho da alegação, não maior):
normalize a letra nos dois lados do diff e mostre que os multiconjuntos de
linhas removidas e adicionadas são **idênticos**. Se sobrar qualquer linha, a
alegação "só a letra mudou" é falsa — e foi exatamente essa a falha que o re-G3
da Q pegou.

### Duas leituras da mesma caixa se derrubam (08/09)

`orca orchestration check --wait` **é um consumidor da caixa**. Rodar um `check`
simples enquanto um `--wait` está no ar **substitui** o consumidor: o que estava
esperando morre com `consumer_fenced` ("this mailbox consumer was replaced while
waiting"), e o `worker-start` seguinte ainda pode falhar por o terminal
coordenador ter perdido o vínculo com o Run — conserta-se com `run-use` de novo.

Perdi dois observadores assim antes de entender: eles saíam com código 1 e sem
saída, e eu li o silêncio como "nada chegou".

**A mesma queda tem uma segunda causa, e ela vem de fora (08/09 20h36):** outro
terminal rodando `run-use` no mesmo Run **assume o coordenador** e sobe a
geração — quem estava esperando cai igual, com `consumer_fenced` e saída vazia, e
o `worker-start` seguinte é recusado por "requires the coordinator terminal
currently bound". Não é sinal de que a sua sessão errou. **Conserto nos dois
casos: `run-use` de novo, e conferir os despachos vivos** (`worker-show`) antes
de concluir qualquer coisa — os workers seguem trabalhando enquanto o
coordenador troca de mão.

**Regra:** um leitor de cada vez. **O observador de fundo é dispensável** — o
próprio ambiente avisa quando há mensagem ("You have N orchestration messages"),
e aí um `check` simples basta. Se ainda assim quiser esperar em bloco, então
**nenhum `check` avulso** até ele voltar.

E a lição de leitura, que é a de sempre: **um comando que sai em silêncio não
disse "nada aconteceu"** — pode ter sido derrubado. Olhe o código de saída e o
erro antes de concluir.

### O portão passa, e a mescla ainda pode não caber (08/09)

A volta Q **passou** no quarto re-G3, todas as dimensões em 9 — e a mescla
abortou com cinco conflitos, dois deles em Swift de mérito: enquanto ela
trabalhava, outra volta mesclou e **mexeu nas mesmas funções**. Nenhum dos dois
lados está errado; os dois contratos precisam caber na mesma função, e a decisão
de como é **semântica**, não mecânica.

**Regra:** o G5 tem dois passos, não um. Aprovado ≠ mesclável. Quando os
conflitos passarem de vizinhança, **o orquestrador não resolve adivinhando** —
devolve ao implementador uma volta de **reconciliação**, que traz o `main` para
dentro do branch, funde as regras sem que nenhuma desapareça, **declara cada
escolha de semântica por escrito**, e prova na **árvore mesclada** (a que nenhum
dos dois lados testou). Teste de um dos lados que fica vermelho na fusão **é o
achado**, não um estorvo.

Resolver conflito de mérito no lugar de quem escreveu o código é a versão de
mescla do "conserto confiante e errado": o diff é pequeno, parece limpo, e põe no
`main` uma semântica que ninguém escolheu.

### A árvore de AX do serve-sim pode devolver menos do que a tela tem (08/09)

**O que está PROVADO, e é só isto:** num cartão de quatro elementos, o leitor
devolveu a árvore **sem "Fechar"** enquanto a captura do mesmo instante mostrava
"Fechar" na tela. Os frames dos elementos que vieram batem **pixel a pixel** com
a captura — foi assim que a V13-B separou limite do leitor de defeito do app, e
o revisor confirmou a atribuição **nesta evidência**.

**O que NÃO está provado, e não se cita como se estivesse:** que o teto seja
"no máximo três", e que a variação dependa do tamanho de letra. A V13-B observou
que em AX5 com pergunta longa sumia "Repetir pergunta" e em `medium` some
"Fechar", mas **a árvore bruta em `medium` não foi guardada**, e sem ela a regra
geral não se sustenta. Quem precisar dessa generalização, meça e guarde as duas
árvores brutas.

**O que isto muda em toda prova de acessibilidade:**
- **Presença na árvore continua valendo** — rótulo, ordem de leitura, frame.
- **Ausência na árvore NÃO é prova de ausência na tela.** Nenhuma conclusão do
  tipo "nada se sobrepõe", "não há linha que diga X" ou "o elemento não existe"
  se sustenta na árvore sozinha: precisa da **captura do mesmo instante**
  mostrando o mesmo.
- Se a contagem da árvore não bater com a captura, **diga isso** em vez de
  escolher a fonte que fecha a conta.

É o oitavo instrumento do dia a dizer mais (ou menos) do que mostra — e o
primeiro em que a diferença entre "o app não expõe" e "o leitor não devolveu"
era invisível sem alguém ir medir a mesma tela de dois jeitos.

### O runner que trava antes de conectar não é resultado (08/09)

A Q-H registrou dois travamentos do runner de teste — *"hung before establishing
connection"*, **0 de 957**, 345 s cada — e fez o certo: **não os contou como
falha nem como verde**. Provou que a árvore mesclada sobe, instalando e lançando
o app no aparelho, e reexecutou; as execuções seguintes passaram inteiras, duas
vezes idênticas.

**Regra:** `0 de N` com o runner travado antes de conectar é **limite do
instrumento**, e a resposta é repetir a corrida e mostrar as duas saídas — nunca
declarar vermelho (não houve teste) nem verde (não houve teste). Quem relata,
relata as duas: a que travou e a que rodou.

### `orca emulator kill` derruba o vizinho (09/09)

A R1 fechou com `orca emulator kill --device 34CC3F94` seguido de `simctl
shutdown` do próprio aparelho — e **o `6033B043` de outra volta desligou no mesmo
segundo** (`device.plist` modificado às 22:08:33; o comando às 22:08:34). O
worker nem tinha tocado nele. É o mesmo helper único da máquina, já conhecido por
perder a árvore de AX e por apontar para o aparelho errado depois de um `attach`:
o `kill` derruba **o que o helper gerencia**, não só o `--device` pedido.

**Regra:** para encerrar o SEU aparelho, use `xcrun simctl shutdown <UDID>` — que
é escopado — e **evite `orca emulator kill` enquanto houver outra volta com
simulador ligado**. Se precisar dele, **avise antes** e **confira depois** quais
aparelhos ficaram de pé, restaurando o que você derrubou sem querer. Nenhum dado
se perde num `shutdown` (o contêiner fica), mas a volta do vizinho perde a
passada.

**E o que o worker fez de certo:** perguntou por `ask` antes de mexer no aparelho
alheio. A pergunta **expirou em 10 minutos sem resposta** e ele então religou o
`6033B043` para **restaurar o estado em que encontrou a máquina** — que é a
decisão certa quando o coordenador não responde: voltar ao que estava, não
escolher por conta própria um estado novo.

### O `ask` expira, e o laço tem de contar com isso (09/09)

Duas perguntas de worker morreram por timeout na mesma noite (10 min e 900 s),
porque o orquestrador só olha a caixa quando o ambiente o avisa. **Quem pergunta
não pode ficar parado:** o spec passa a dizer que, se o `ask` expirar, o worker
**faz o que restaura o estado anterior** (ou segue pelo caminho menos
destrutivo), **registra a pergunta e a expiração no relato**, e continua — nunca
escolhe sozinho um caminho irreversível.

### LEI DO SIMULADOR DO GROK, corrigida: o INSTALL POR CIMA também derruba a conta (09/09)

A lei antiga proibia `erase`, `clearState`, `uninstall` e `xcodebuild test` no
`C2416CBC` e **permitia instalar por cima**. Estava errada, e a medida é limpa:
a fumaça antes do install registrou `contaGrokLigada=true` com **12 modelos**
às 03:20:38Z; depois do **install por cima**, `contaGrokLigada=false` com
**0 modelos** às 03:22:07Z. O revisor parou na hora e **não contornou**.

**A lei, na forma que o dono deu em 09/09 08h40:** no `C2416CBC` **a sonda roda no
build JÁ INSTALADO** — `simctl launch` com `TRACO_AVALIAR_IA` no ambiente, ou
`terminate`+`launch`. **Binário novo entra nesse aparelho UMA vez por volta**, com
**`ContaGrok.ligada` conferido antes e depois**. Nada de `erase`, `clearState`,
`uninstall` nem `xcodebuild test` — nunca. **Se a conta cair, a volta para e diz;
mas o objetivo é ela não cair.** Só o dono reautoriza, e cada reautorização custa
a ele — foi o install por cima repetido que a derrubou duas vezes e travou uma
noite inteira.

**E como se roda uma corrida de IA sem instalar**, que é o que destrava o
trabalho: a sonda `AvaliacaoIA` lê a fixture pelo nome em
`TRACO_AVALIAR_IA=<fixture.json>` **no Documents do app**
(`AvaliacaoIA.swift:58`). Então:

1. escreva a fixture nova no contêiner de dados do app
   (`xcrun simctl get_app_container <UDID> <bundle> data`);
2. relance com a variável (`SIMCTL_CHILD_TRACO_AVALIAR_IA=<fixture.json>`,
   `simctl launch --terminate-running-process`);
3. **use o binário que já está no aparelho** e diga no relato **qual candidato é**
   (o SHA que o instalou por último), porque medir com binário alheio é o erro
   irmão.

**Fumaça obrigatória antes e depois de cada corrida:** `contaGrokLigada` e a
contagem de modelos, com carimbo de hora, coladas no relato. Se cair, **diga em
vez de contornar** — foi assim que o gatilho apareceu.

### Prova que ninguém olhou não é prova (09/09)

A C1-B versionou um MP4 e o anunciou como "a gaveta consertada". O revisor abriu:
**44,04 s da Tela Inicial, sem o Traço dentro**. A sequência textual carimbada da
mesma passada era boa; **o vídeo era prova falsa** — e ninguém tinha aberto o
arquivo antes de anexá-lo.

**Regra:** todo artefato de prova — vídeo, captura, árvore, log — é **aberto e
conferido por quem o anexa**, e o relato diz **o que se vê nele**, não o que
deveria ver. Um caminho de arquivo no relatório não é evidência; é uma promessa.

Duas irmãs do mesmo dia, para a lista não parecer exagero: o helper do
`orca emulator` devolveu **`ok:true` sem mover a tela** (a R1-B trocou de
instrumento e mediu por XCUITest), e a sonda nova da C1-B media **`E ⊆ P` mas não
`P ∩ O = ∅`** — metade da invariante 08f, com a outra metade sem portão.

### A sonda que mede metade da regra é pior que nenhuma (09/09)

Porque ela dá um verde. Quando escrever instrumento para uma invariante de duas
partes, **mostre o vermelho de cada parte separadamente** — se uma das metades
nunca ficou vermelha, ela não está sendo medida.

### O checkout descartável do pai é o caminho certo, não uma exceção (09/09)

Um revisor perguntou se podia montar um checkout descartável do pai em `/tmp`
para reproduzir o vermelho no próprio aparelho, porque a regra *"só no seu
worktree"* deixava isso ambíguo. **Pode, e deve.** A regra existe para ninguém
escrever no worktree alheio nem no checkout principal — nunca quis dizer que não
se monta uma árvore descartável para ver um vermelho.

Foi assim que o revisor da C1 produziu a melhor prova da noite: montou o pai
descartável, **trouxe só a sonda do candidato**, viu o vermelho com as próprias
mãos e depois o verde. Sem isso, estaria acreditando no log de outra pessoa.

**Condições:** em `/tmp`, **removido ao fim** e dito no relato; **só o seu UDID**;
nada escrito no checkout principal nem em worktree alheio; e **diga o que trouxe
do candidato para o pai** — medir o pai com o instrumento do candidato é o que
torna a comparação válida, e trazer mais do que o instrumento é o que a invalida.

### Verde que só é verde na sua máquina (09/09)

A S1 relatou **973 testes verdes**; o revisor rodou **o mesmo candidato** e os
dois testes novos dela deram **3 falhas**. Nenhum dos dois mentiu: o teste
dependia de estado que um tinha e o outro não — com o campo de busca em foco a
**barra de navegação some inteira**, e o toque cai numa tecla.

**Regra:** teste de jornada nova roda **dez vezes seguidas, do zero**, com o
aparelho recém-ligado e o app recém-instalado, e as **dez saídas** vão no relato.
**Um teste que passa 9 de 10 não passa** — é um teste que mente uma vez em dez.
E toda **pré-condição de estado** (teclado fechado, aba inicial, nota semeada)
mora **dentro do teste**, falhando com mensagem clara quando não vale, em vez de
tocar às cegas.

**E nunca afrouxe a asserção para ficar verde.** Se o caminho não é testável do
jeito escrito, **troque o instrumento** — foi o que a R1-B fez ao ver o helper
devolver `ok:true` sem mover a tela.

### O que conta é a nota do produto, não a volta mesclada (09/09, ordem do dono)

*"Esse tempo todo e ainda é 7."* O dono mede pelo produto. Uma volta mesclada que
não move a nota de nenhuma dimensão **não é progresso, é manutenção** — e
manutenção necessária continua não sendo o que ele pediu.

**Toda volta de IA fecha com três coisas, não duas:**
1. a medida (a sonda, o JSONL, a leitura independente das saídas inteiras);
2. **a linha do Perfil atualizada** — a operação **sai da lista de indisponíveis**,
   e a tabela `Politica` recebe a medida nova;
3. **a captura do cartão com a resposta real na tela.** *"O dono quer VER a IA
   funcionando"* — JSONL não é tela, e motor sem superfície não conta como
   entregue.

E o LACO registra **com a hora** o momento em que cada operação volta a estar
disponível.

### UM SIMULADOR SÓ (ordem do dono, 09/09 08h50)

O dono desligou todos os simuladores menos o **iPhone 17 Pro
`C2416CBC-C5D9-41F9-ACD8-45EED8FC355E`** e **liberou o Grok nele**. A partir daqui:

- **Nenhum worker liga outro simulador.** Build, suíte, sonda, capturas e jornada,
  **tudo nesse aparelho**, serializado por `com-trava.sh`. Três frentes editam,
  **uma de cada vez no instrumento**.
- **Nada de `erase`, `clearState` ou `uninstall`.** Instalar por cima **só quando a
  volta precisar do binário novo, uma vez**, com `ContaGrok.ligada` conferido
  **antes e depois**, com a hora.
- **Se a conta cair, o worker PARA e diz na hora, com o comando que a derrubou** —
  para o dono reautorizar e para acharmos a causa.
- **O maestro volta a valer como evidência.** A proibição de 06/09 existia porque
  com vários simuladores ele lia a hierarquia do vizinho; com um só, o motivo
  caiu. **As leis morrem quando a razão delas morre** — e essa é a única forma
  honesta de encolher uma lista de regras.
- **O caçador de fala segue** rodando em toda espera.

**O que isto custa, dito na frente:** o paralelismo cai. Três voltas podem editar,
mas a fila do instrumento é única — e uma suíte integral segura as outras duas.
Vale a pena porque **a conta do dono vive nesse aparelho**, e foi a disputa entre
aparelhos que a derrubou duas vezes.

### Fixture do passado se GRAVA com o código do passado (09/09)

A M1 declarou que não fabricava fixtures das versões antigas *"com o código de
hoje, por ser circular"*. A objeção está certa: **gerar um store antigo com o
código de hoje não prova nada**, porque o que se quer provar é que o código de
hoje **lê o que o código de ontem gravou**.

**A saída não é gerar: é gravar com o código de ontem.** O git tem os commits, e o
revisor da mesma volta já fez isso — montou os cadernos V2, V3 e V4 e o conserto
abriu os três. Então: **checkout descartável em `/tmp` no commit da época**,
compilar ali, gravar o caderno, **copiar o `default.store` para as fixtures**, e
**dizer de qual commit veio cada uma** — a proveniência é parte da prova.

Se alguma versão **não compilar mais** com o Xcode de hoje, **isso é o relato**:
diga qual, com o erro, e aquela fixture fica **declarada impossível**. Declarar
limite é aceitável; **prometer "cada versão" e entregar duas não é**.

### Duas ordens que não cabiam juntas, e o erro que as expôs (09/09)

**Eu mandei a suíte da árvore mesclada rodar com `xcodebuild test` no
`C2416CBC`** — o aparelho da conta do dono —, que é **exatamente o comando que a
minha própria lei proíbe nele**. Matei antes da fase de teste; o contêiner e os
JSONL das corridas sobreviveram. Mas o erro não foi só distração: **"um simulador
só" e "nunca `xcodebuild test` nesse simulador" não cabem juntas** — a suíte fica
sem onde rodar, e quem executa acaba escolhendo em silêncio qual das duas quebrar.

**A regra, na forma que o dono deu (09/09 09h30), decidida pela reversibilidade:**

- **`C2416CBC` é o aparelho da CONTA e o único ligado fora de uma corrida de
  suíte.** Recebe o binário **uma vez por volta**, com `ContaGrok.ligada`
  conferido; **nunca `xcodebuild test`**, nunca `erase`/`clearState`/`uninstall`,
  **nunca voz nem mouse nele**.
- **O segundo simulador existe SÓ para build e suíte.** É **ligado pela trava no
  início da corrida e DESLIGADO ao fim da MESMA corrida** — quem liga, desliga, e
  não deixa ligado "para a próxima". Fora da suíte, **há um aparelho ligado na
  máquina**.
- Nenhum worker liga um terceiro.

**A lição de orquestração:** quando duas ordens se contradizem, **quem executa não
resolve em silêncio** — mostra a contradição para quem mandou. Eu só a vi porque
tropecei nela; o certo era tê-la visto ao escrever a segunda.

### DIRETRIZ §8 (09/09, `418a1b5`) — o mais rápido possível, zero bugs, ponytail

Palavras do dono: *"o mais rápido possível; eliminar todos os bugs e erros;
otimizar ao máximo; ponytail"*. Cinco pontos, e eles mudam como a esteira corre:

1. **Fechar antes de abrir.** Escopo mínimo, **uma passada de revisão**, e
   **acabamento vira dívida nomeada** em vez de segurar a volta. O laço de hoje
   teve voltas com três e quatro re-G3 — isso acaba: se o mérito passou e falta
   acabamento, **o acabamento vai para o RUMO com dono**.
2. **Trilha B, caça a defeitos, permanente:** **B1** os `try!` de produção
   (`TracoApp.swift:13` primeiro), **B2** estados inalcançáveis e rotas que calam,
   **B3** texto que promete o que o motor não sustenta. **Cada uma com teste que
   reproduz antes.**
3. **Otimização com medida antes/depois** em **lista, editor e parser** — número,
   não impressão.
4. **`ponytail` é lei de código**, para implementador **e** revisor: a escada
   (existe? já existe aqui? stdlib? nativo? dependência que já entrou? uma linha?)
   antes de escrever, e o diff mais curto que funciona **depois de entender o
   problema**.
5. **A fila da §7 segue:** Q2, Q3 e Q4 na frente de IA, a **trilha B ao lado**, e
   C1/R1/S1 **fecham antes de abrir mais**.

### A mutação que prova o vermelho é uma DÍVIDA VIVA até ser desfeita (09/09)

A M1-B comentou `TracoSchemaV0` do plano de migração e apagou o estágio V0→V1
para ver o portão reprovar — **e morreu antes de desfazer**. O commit póstumo
levou a mutação para `main`, com a consequência exata que o portão denunciava: **o
caderno mais antigo não abria**, que era o defeito que a volta existia para
fechar. A suíte ficou vermelha **dizendo a verdade**, e foi só por isso que a
mutação apareceu.

**Regras, e as três são baratas:**

1. **Marque a mutação para ela gritar.** `/*SONDA ...*/` foi o que salvou aqui —
   um comentário com uma palavra única que se acha com um `grep`. Use sempre a
   mesma palavra, e **procure por ela antes de comitar**.
2. **Desfaça antes de rodar a corrida de fecho**, e **diga no relato que desfez**,
   com a saída verde depois da reversão. Foi o que a Q-F e a C1-C fizeram.
3. **Quem comita o trabalho de um worker morto herda a dívida dele:** procure a
   palavra da sonda **antes** de comitar por ele. O trabalho estava pronto; a
   mutação também estava lá.

**E o portão fez o que devia:** ele não deixou passar. Um portão que só fica verde
não é portão — este ficou vermelho no dia em que a mutação chegou ao `main`, e é
por isso que o defeito durou minutos em vez de semanas.

### CORREÇÃO DE APARELHO (09/09 10h58): a conta que funciona é a do `B91C8DEF`

O dono autorizou no **`C2416CBC`** e o Traço lá continuou dizendo **"sem conta"**;
no **`B91C8DEF` (teste 2)** ele autorizou e o Perfil mostra **"Grok — conectada —
o Grok é o motor, pago pela sua assinatura"**, lido por mim na árvore de AX às
10h58. Ordem dele: ***"usa o que já está funcionando"***.

**A partir daqui:**

- **`B91C8DEF` é o APARELHO DA CONTA** — sonda de IA e capturas da tela real.
  **Nunca** `erase`, `clearState`, `uninstall` nem `xcodebuild test` nele. Binário
  de `main` instalado **uma vez por volta**, por cima, com `ContaGrok` conferido
  **antes e depois**.
- **A suíte roda num segundo simulador EFÊMERO e sem conta** (`34CC3F94`, teste
  3), **ligado e desligado pela trava na mesma corrida**.
- O **`C2416CBC` foi desligado pelo dono** (tinha um consentimento pendente que
  não vamos usar).

**A lição que eu levo daqui, e ela é minha:** eu vinha rodando `xcodebuild test`
no `B91C8DEF` a noite toda como "aparelho de trabalho" — **era o aparelho onde a
conta funcionava**. Aparelho não se identifica por apelido nem por memória: **o
papel de cada UDID se lê na tela antes de cada corrida**, e o Perfil é a fonte.

### O install por cima NÃO derruba a conta — a medida de hoje corrige a de ontem (09/09)

Ontem eu escrevi, a partir da fumaça do revisor da Q2, que **o install por cima
derrubava a conta**: `contaGrokLigada` verdadeiro com 12 modelos, e falso com 0
**89 segundos depois de um `simctl install`**. Hoje medi o contrário, no aparelho
onde a conta funciona:

```
10:57:16  antes do install   "conectada — o Grok é o motor, pago pela sua assinatura"
10:57:16  xcrun simctl install B91C8DEF... Traco.app   (por cima, sem uninstall)
10:58:16  depois do install   "conectada — o Grok é o motor, pago pela sua assinatura"
```

**As duas medidas são boas e a conclusão de ontem era grande demais:** o install
por cima **não é suficiente** para derrubar a conta. O que caiu ontem caiu por
outra coisa no mesmo minuto — o candidato mais provável é o `xcodebuild test`, que
instala o runner e pode trocar o contêiner, e que estava proibido justamente por
isso.

**A regra prática não muda, e é a barata:** `ContaGrok` conferido **antes e
depois** de cada corrida, com a hora; **se cair, parar e dizer com o comando
exato**. Foi o que produziu as duas medidas e o que vai produzir a terceira.
