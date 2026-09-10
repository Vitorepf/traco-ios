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
| Acessibilidade | rótulos e ordem certa na árvore, contraste, alvo ≥ 44 pt; Dynamic Type só até **large** — tamanhos de acessibilidade (AX1–AX5, XXXL) estão FORA DO ESCOPO por ordem do dono (DIRETRIZ §12, 10/09): não se testa, não se captura, não vira dívida | árvore AX + captura em large |
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

> **⚠️ ESTA SEÇÃO ESTAVA ERRADA E FICA COMO REGISTRO.** A causa não era o install
> por cima: era **a suíte integral**, que apagava o cofre pelo `ContaGrok.sair()`
> de dois testes (ver *"A SUÍTE INTEGRAL APAGA A CONTA DO DONO"*, e a K1 que a
> consertou). O install por cima **não derruba a conta** — medido três vezes em
> 09/09, e de novo pelo LOTE, com `contaGrokLigada=true` **antes, depois e ao fim**
> de uma janela com instalação no meio.

A lei antiga proibia `erase`, `clearState`, `uninstall` e `xcodebuild test` no
`C2416CBC` e **permitia instalar por cima**. A fumaça antes do install registrou
`contaGrokLigada=true` com **12 modelos** às 03:20:38Z e, depois, `false` com
**0 modelos** às 03:22:07Z — **e a conclusão que tirei disso, de que o install era
o culpado, era grande demais**: no mesmo minuto havia uma suíte correndo. O
revisor parou na hora e **não contornou**, e foi isso que permitiu achar a causa
verdadeira horas depois.

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

### `git push origin main` empurra o que está no seu checkout, não o commit que você acabou de escrever (09/09)

Eu escrevi no LACO, às claras, que **não empurraria** a fusão vermelha. Uma hora
depois dei `git push origin main` para publicar **um registro do LACO** — e levei
junto **três mesclas** que estavam no meu `main` local, com **dois testes
vermelhos**. A intenção era um commit; o efeito foi o ramo inteiro.

**Regra para quem mescla:** o `main` do orquestrador é **área de trabalho**, e
empurrá-lo publica **tudo o que estiver nele**. Antes de qualquer
`git push origin main`, **`git log --oneline origin/main..main`** e leia a lista —
se aparecer algo que você não pretendia publicar, **não empurre**.

**E a regra que evita o problema na raiz, que eu já deveria estar seguindo:**
trabalho de volta **não mora no checkout do orquestrador**. Mescla que não fecha na
hora vira **branch com worktree e dono** — foi o que fiz com a `fusao-c1r1s1`,
tarde demais. Registro que ficou fora do livro vira dívida invisível, e dívida
invisível é a que vaza para o `main`.

### DIRETRIZ §6 — DECIDA SOZINHO, e eu descumpri duas vezes hoje (09/09)

O dono cobrou, e a conta é objetiva: **duas `AskUserQuestion` hoje pararam o laço
por vinte minutos cada**, esperando ele ver. As duas eram **decisões
reversíveis**, e nenhuma estava na lista fechada.

**Perguntar é só nos quatro casos:** dados do dono; dinheiro, publicar ou enviar;
contrato de privacidade, autoria ou selo; apagar trabalho. **Todo o resto: decida,
registre no LACO com a razão, e siga** — se estiver errado, o registro é o que
permite desfazer.

**Para me lembrar de como isso se parece na prática, as duas de hoje:** *"onde
roda a suíte, já que um simulador só e nunca `xcodebuild test` nele não cabem
juntas?"* — eu tinha a resposta (segundo aparelho efêmero) e a recomendei na
própria pergunta. E *"main ficou vermelho, reverto ou conserto para a frente?"* —
eu já sabia que reverter três mesclas cria a armadilha do re-merge, e disse isso
na própria pergunta. **Quem escreve a recomendação junto com a pergunta já
decidiu; o que falta é assumir.**

### ⛔ A SUÍTE INTEGRAL APAGA A CONTA DO DONO (09/09) — e isso atinge todo mundo

**Achado do worker da M1-B, medido em três leituras independentes.** O fecho
obrigatório de qualquer volta — *"suíte integral por `com-trava.sh`"* — **apaga a
conta Grok** quando roda no aparelho dela.

**A causa, no código:** `TracoTests/NotasESessaoTests.swift:572` e `:578` chamam
`ContaGrok.sair()`, que faz `guardar(nil)` em `oauth-acesso` e `oauth-renova` do
keychain `app.traco.xai` — e **o keychain é do SIMULADOR, não do processo de
teste**. A suíte apaga a conta de verdade.

**A prova:** sonda dentro do app-host **ligada=true às 08:57**; **false às
09:12:48**; `genp` do keychain do simulador **de 56 para 54 linhas**, `-wal`
carimbado **08:58**, dentro da janela da suíte.

**Enquanto a K1 não fecha:** **NINGUÉM roda `xcodebuild test` no aparelho da
conta.** Suíte só no aparelho de trabalho efêmero.

**E isto fecha o mistério de ontem, corrigindo duas conclusões minhas.** Eu escrevi
que **o install por cima derrubava a conta**; depois medi que **não derrubava** e
disse que a causa provável era o `xcodebuild test`. **Era.** A cadeia inteira de
ontem — a conta caindo duas vezes, a Q2 travada uma noite, o revisor bloqueado
duas vezes — foi **a nossa própria suíte**, e o que a expôs foi a regra barata de
sempre: **fumaça antes e depois, e parar em vez de contornar**.

**A lição de teste, que é maior que este caso:** **teste que escreve em recurso do
APARELHO — keychain, `UserDefaults` do app, App Group, arquivos do contêiner — não
está isolado**, por mais que o alvo se chame "testes de unidade". O que ele apaga,
apaga de verdade. Injete o cofre, ou pule com a razão dita.

### `try?` pode ser um verde que nunca visita o defeito (09/09, achado da B1)

Trocar `try!` por `try?` parece o conserto óbvio, e **em dois dos quatro casos da
B1 seria um verde falso**: `JSONSerialization.data(withJSONObject:)` com objeto
inválido **NÃO lança** — ela **levanta `NSInvalidArgumentException` e mata o
processo**, por baixo de `try!`, `try?` e `do/catch` **igualmente**. Medido: com o
`try!` de volta, o teste **derruba o runner e nem aparece como falha** — que é
exatamente a morte que o autor veria.

**O guarda certo é `isValidJSONObject` ANTES da chamada**, e a degradação vai para
a recusa que o app já sabe dizer.

**A regra maior:** antes de trocar um operador de erro por outro, **descubra se a
API falha por `throw` ou por exceção Objective-C**. Se for exceção, **nenhum
`try` a pega**, e o conserto é a **pré-condição**, não o tratamento.

**E a segunda metade do achado, que é rara:** os outros dois casos
(`Corpus:171`, `Sessao:615`) **não têm dado que os derrube** — testados com NUL,
controle, `U+FFFF`, emoji, `U+2028/2029`, aspas e barra. Eles passam de "dívida
real" a **"infalível por construção COM A PROVA"**. Sair da lista **por medida** é
tão válido quanto sair por conserto — e é mais barato.

### ⛔ Com o dono ativo na máquina, não se levanta janela nem se escreve em campo (09/09)

**O que aconteceu, e é o pior tipo de acidente: o silencioso.** A janela do Grok
Bot sumiu; o worker fez `open -a "Grok Bot"` para ler a resposta, e isso
**levantou a janela por cima do que o dono estava fazendo** — um `appl` dele
apareceu no campo do bot. O worker esperou **45 s de inatividade**, clicou no
campo, mandou `cmd+a` (o helper respondeu **"provider unavailable": não selecionou
nada**), colou a pergunta e deu Return. **O campo tinha um rascunho do dono, e ele
foi enviado ao bot junto com a pergunta do worker.**

Nada saiu da conta dele e o destinatário foi o próprio bot; o worker **escalou na
hora, não apagou nem editou a conversa, e não tocou mais no app**. Isso é o
comportamento certo depois do erro — e o erro continua sendo evitável.

**Três regras, e as três nasceram deste minuto:**

1. **Com o dono ativo no Mac (ocioso < 60 s), não se levanta janela nem se escreve
   em campo de texto.** Esperar 45 s não bastou; espere o Mac ficar realmente
   parado, ou **peça e aguarde**.
2. **`open -a` não é neutro:** ele **rouba o foco** do que a pessoa está fazendo.
   Para *ler* uma janela, leia pela árvore de acessibilidade sem trazê-la à frente.
3. **O `hotkey` do helper não é confiável.** Ele respondeu "provider unavailable" e
   **não selecionou nada**, e o worker seguiu como se tivesse selecionado.
   **Confira o VALOR do campo por AX antes de qualquer Return** — enviar é
   irreversível, e o que estava lá não era seu.

**A regra geral por trás das três:** **antes de um ato irreversível num app do
dono — enviar, salvar, apagar — leia o estado real e confirme que é o seu.** Não
basta ter mandado o comando que deveria limpar.

### O binário entrou cinco vezes, e o worker DISSE (09/09)

A lei diz **uma vez por volta**. A Q2-E declarou, sem ser perguntada: *"o binário
entrou cinco vezes no aparelho da conta, não uma, cada vez forçada por um achado
da corrida anterior"* — com a conta conferida ligada **às 13:30:03 e às 14:05:35**,
e nenhum `erase`, `clearState`, `uninstall` ou `xcodebuild test`.

**O propósito da lei foi cumprido** (a conta sobreviveu, e cada install teve
motivo medido); **a letra foi excedida, e o excesso está escrito**. É assim que
uma regra sobrevive ao contato com o trabalho: **quem excede, declara**, e quem lê
decide se a regra muda ou se o caso era exceção.

**A regra muda:** *"uma vez por volta"* passa a ser **"cada install é declarado,
com o achado que o forçou e a conta conferida antes e depois"**. Contar instalações
nunca foi o objetivo — **não perder a conta era**, e a K1 já tirou dela o perigo
real.

### O teste que guarda o estado tem de guardar o MOTIVO (09/09)

Ao reverter a adoção do modelo, o teste `responderVoltouComOMelhorModeloEOEsforcoMedido`
ficou vermelho — **corretamente**: ele guardava o estado que deixou de valer. A
tentação é apagá-lo ou afrouxá-lo; o certo é **reescrevê-lo para guardar o estado
novo E a razão dele**.

Ele virou `responderEsperaAComparacaoPareadaAntesDeVoltar`, e o comentário diz o
que a próxima pessoa precisa saber: **`responder` só sai da lista de novo quando
uma comparação de UMA alavanca escolher o modelo**. E a lista das cortadas voltou
a sete com a frase *"quem tirar uma sem medida nova, PAREADA, quebra aqui"*.

**A regra:** teste de estado é documentação executável. Quando o estado muda, o
teste muda **junto com o porquê** — senão a volta seguinte desfaz a reversão por
descuido, e ninguém saberá que houve um motivo.

### Aparelho ligado que você não ligou, e trava ocupada (09/09)

Duas perguntas de worker no mesmo dia sobre a mesma coisa. As respostas:

- **Aparelho que você encontrou ligado e não ligou:** use-o se for o seu por spec,
  e **deixe como achou**. A lei "quem liga, desliga" tem o par que faltava:
  **quem NÃO ligou, não desliga**.
- **Trava ocupada não é suíte bloqueada.** A `com-trava.sh` **serializa de
  propósito** — esperar é o comportamento correto, e "registrei a suíte como
  bloqueada" é declarar limite onde só havia fila.

### O `worker_done` pode morrer no runtime, e o worker não pode ficar preso nisso

O revisor da Q2-E teve o `worker_done` **rejeitado três vezes** por um erro do
runtime (`unknown dispatch`, com o id truncado num caractere), depois de
`request-show` e `dispatch-show` confirmarem o despacho. Ele fez o certo:
**comitou o veredito no branch** e **mandou um `status`** dizendo que o resultado
estava pronto e onde. **O trabalho chegou; só o carimbo não.**

**Regra:** se o `worker_done` falhar por erro do runtime, **comite o resultado e
mande um `status` com o SHA e o caminho do relatório**. E do meu lado: **despacho
preso se resolve com `worker-abandon`**, que não finge que o processo parou —
só o desprende.

### Portão que não enxerga tem de falhar FECHADO (09/09, B1-B)

O portão da regex tinha `regex\(([^()]*)\)`. Com **um parêntese dentro do
argumento** ele **não casa em lugar nenhum** — e a chamada ficava **invisível**,
com a contagem parada em 4. Não era um portão frouxo: era um portão **cego**, que
dá verde por não ver.

O conserto exige **identificador nu seguido de `)`** e **devolve o resto da linha
cru** para qualquer outra forma — que então **cai em `deFora`** e reprova.

**A direção da falha é a lição.** O portão novo **não reconhece** concatenação,
interpolação, string inline nem chamada em duas linhas — e todas elas saem
**VERMELHAS mesmo sendo literais**. **Nenhuma dá falso verde.** Um portão que
reprova o que não entende custa uma conversa; um que aprova o que não entende
custa o defeito.

**E o limite está escrito onde se lê** — no próprio portão, na ADR e no RUMO, com
a saída honesta nomeada. Portão que promete mais do que vê era o defeito que esta
volta veio consertar; declarar o que ele não vê é o que impede a repetição.

### Uma corrida não é uma medida (09/09, Q2-F)

O **`12 de 12`** que fez a 09n adotar o `grok-4.6` **veio de UMA corrida**. A Q2-F
repetiu **três corridas idênticas** e **numa delas o 4.6 perdeu dois casos**.
Nenhum número mudou de dono por opinião: mudou porque **a segunda e a terceira
corrida existiram**.

**Regra:** medida de IA com **uma corrida** é indício. **Três corridas idênticas**
são a menor coisa que se pode chamar de medida — e a variação entre elas **entra
no relato**, porque é ela que diz se o número é do modelo ou do dia.

### Recusa da API é FATO; ausência na lista é hipótese (09/09, Q2-F)

O G3 reprovou a triagem anterior por excluir candidatos **por nome e posição**. A
Q2-F trocou isso por uma coisa que se lê: **mandou os doze à API com a mesma
requisição de produção** e usou **a frase da resposta** como critério — as cinco
`imagine` dizem `Model not found`; o `grok-build-0.1` e as três `grok-4.20` dizem
`does not support parameter reasoningEffort`.

**E essa recusa prova o que faltava provar:** *o provedor só recusa o parâmetro
pelo nome se ele foi enviado*. A triagem honesta deixou **três** candidatos, não
dois — e o `grok-4.5`, **cortado por posição na passada anterior**, era um deles,
e acabou sendo o melhor dos três.

### A trava serializa COMANDO, não SEQUÊNCIA (09/09) — e o aparelho é de UMA volta por vez

**O que aconteceu:** eu dei o mesmo aparelho de trabalho a duas voltas. Uma
instalou e lançou **sob a trava** às 17h27; a outra plantou a tela bloqueada às
17h28. Os **dois toques de navegação** da primeira foram dados **fora da trava** e
caíram **na tela da segunda** — e um deles **respondeu "Permitir"** a um diálogo do
sistema que era da corrida alheia. O install por cima ainda pode ter **trocado o
binário debaixo da medida dela**.

**Duas leis, e a segunda o próprio worker escreveu antes de mim:**

1. **Toda a SEQUÊNCIA de captura vai dentro de UMA chamada de `com-trava.sh`** —
   plantar, instalar, lançar, navegar, fotografar. **Segurar a trava para instalar
   e soltá-la para dirigir é o mesmo que não segurar.**
2. **Diálogo de sistema que aparece numa corrida alheia não se responde** — nem
   para seguir em frente. *"O 'Permitir' que eu dei não era meu para dar."*

**E a lei de despacho, que é minha:** **um aparelho é de UMA volta por vez.** Duas
voltas no mesmo UDID é contenção que a trava não resolve, porque a trava não sabe
o que é uma sessão. Quem despacha **escreve o UDID de cada volta e confere que
nenhum se repete**.

**E o que se faz com a evidência contaminada:** **declara-se e descarta-se.**
Captura tirada durante a colisão não sabe qual binário estava instalado nem quem
respondeu ao diálogo. **Evidência contaminada declarada vale; usada, é pior que
nenhuma.**

### A sonda não passava a conversa que a produção passa (09/09, achado da Q3)

Mais um da família *"o instrumento não mede a rota real"*, e este durou desde que a
sonda existe: **`AvaliacaoIA.Entrada` nunca teve `conversa`**, enquanto a rota de
produção **sempre passou** as trocas anteriores. Ou seja, **medimos a operação sem
o contexto que ela tem no app** — e as conclusões sobre "o modelo não usa o que já
foi dito" nunca puderam ser separadas de "nós nunca dissemos".

**Regra:** antes de confiar numa medida, **compare o que a sonda monta com o que o
chamador de produção monta, campo a campo**. Já nos custou duas vezes: a
sobrecarga fantasma da `responderNasNotas` (a sonda chamava outra função) e agora
a conversa que faltava.

### Rótulo interno: some do autor, fica na medida (09/09, Q3)

O `N1T1` **tem de ir no pedido** — sem ele o modelo não tem como citar a nota
certa. O erro não era mandá-lo; era **deixá-lo voltar ao texto do autor**.

O conserto tem as duas metades: **`semRotulos` troca o rótulo pelo título** na
volta, e **`escreveuRotuloInterno` grava que o modelo escreveu um** — *"o autor não
vê o endereço, a medida vê"*. **Limpar sem registrar teria escondido do portão
justamente o que ele precisa contar** (é a lei da 09o: portão não pode ser cego).

### A guarda de 30 min da trava briga com a lei da janela inteira (09/09, achado do LOTE)

`com-trava.sh` **retoma a trava de um dono vivo depois de 30 min**, e a lei de hoje
manda **a sequência inteira numa chamada só** — janelas de medição de IA passam
disso com facilidade (a do LOTE levou 10 min, mas três operações e mais corridas
chegam lá).

**As duas regras juntas produzem o pior caso: outro worker entra no meio de uma
janela que o dono da trava ainda está usando.** É a colisão de hoje com outro
nome.

**Dívida nomeada** (RUMO, dona: a próxima volta que tocar `com-trava.sh`): a
retomada deve exigir **prova de que o dono morreu** (o processo não existe mais),
não só tempo — tempo mede paciência, não abandono.

### Guarda mecânica não vê defeito semântico — e trocar de modelo não conserta o que ela não vê (09/09, LOTE-2)

**A medida:** as mesmas fixtures nos três modelos, uma alavanca só, 114 execuções.
Passando os três pelo mesmo conferidor de guardas literais: **57/57 no `grok-4.3`,
56/57 no `4.5`, 57/57 no `4.6`**. **Nenhum dos três viola as guardas estruturais** —
e, no entanto, os revisores reprovaram os três consertos.

**Conclusão que vale para todo o laço:** *"a cotação dita na conversa não vira o
cálculo exigido"*, *"o conflito não traz próximo ato"*, *"instigar não cobra o
limite"* — **nada disso é regex**. São defeitos **do que a resposta faz**, não da
forma dela.

**Duas regras:**

1. **A pergunta "passa com um modelo melhor?" não se responde por contagem** quando
   o defeito é semântico. **Modelo maior não conserta o que a guarda não vê** — e
   gastar janela do instrumento trocando de modelo, nesse caso, é gastar por nada.
2. **Guarda mecânica serve para o que é mecânico** (rótulo interno vazando, campo
   fora do contrato, teto estourado). Para o resto, **a leitura inteira é o
   instrumento**, e ela é de gente — foi por isso que o conselho exigiu revisor que
   não escreveu os casos.

### `semRetorno` não é erro de transporte (09/09, LOTE-2)

Uma execução voltou **HTTP 200**, desfecho *"conteúdo completo"*, e mesmo assim
`Falha.semRetorno` com `saida null`. **O LOTE anterior contava as duas coisas na
mesma coluna** — e "zero erro de transporte" passou a significar duas coisas
diferentes no mesmo relatório.

**Regra:** **transporte** (a chamada chegou e voltou) e **retorno** (veio conteúdo
utilizável) são **colunas separadas**. Somá-las esconde exatamente o caso que mais
interessa: **o provedor que responde 200 e não diz nada.**

### Não peça a um medidor uma coluna que exige juízo (09/09)

Eu escrevi no spec do LOTE-2: *"a tabela **operação × modelo × casos passados**"* —
e proibi, no mesmo spec, que ele julgasse. **"Passou" só se decide lendo os
requisitos em prosa contra a saída**, que é exatamente o juízo que eu tinha
proibido. O worker viu a contradição, **perguntou**, o `ask` estourou em 900 s, e
ele **decidiu dentro do papel e documentou o critério**: construiu um conferidor de
**guardas literais** e disse que a leitura de mérito continua sendo do revisor.

**Regra:** quem mede entrega **contagem do que é mecânico** e **saídas inteiras**.
Se a coluna precisa de leitura, ela **não é do medidor** — e pedi-la é empurrar o
juízo para quem foi proibido de julgar.

### A meia-recusa: reconhecer o dado e parar ali (09/09, achado do G3 da Q3)

Depois de matar a **recusa total**, apareceu a irmã dela: a resposta **reconhece o
dado e não faz o que ele permite fazer**. Três casos, o mesmo padrão — *"3/3
reconhecem os R$ 6,45 ditos pela pessoa; 0/3 calculam"*, *"3/3 repetem 12/18
cadeiras e o limite 15; 0/3 dizem qual lista vale"*.

**A frase do revisor é a régua:** ***"expor números sem caminho é a recusa
disfarçada"***. Ela **parece resposta** e deixa o autor no mesmo lugar — e por isso
passa por guarda nenhuma: **está tudo lá, menos o uso**.

### Contrato que cobra "hoje" sem dizer que dia é hoje é inexequível (09/09, Q3-B)

O pedido mandava tratar **"um fato de HOJE"** à parte — e **nunca dizia que dia é
hoje**. A nota *"Câmbio de hoje — 09/09"* chegava ao modelo **indistinguível de uma
de um ano atrás**. Não é o modelo falhando: **é o contrato pedindo o impossível.**

**Regra:** toda cláusula que depende do **agora** — hoje, ontem, esta semana,
vencido, atual — só é exequível se **o agora vai junto**. Antes de acusar o modelo
de ignorar a regra, **procure o dado que a regra precisa e que ninguém mandou**.

**E a sonda pegou o bug do próprio conserto:** `ISO8601Format()` devolvia
`2026-09-10T00:24Z` às **21h24 de 09/09** em Brasília — **invertendo o sentido de
"hoje"**. Data em UTC num contrato que fala do dia do autor **é o dia errado por
três horas todo fim de tarde.**

### O prompt que PRESCREVE a saída errada (09/09, Q3-B)

Três dos quatro defeitos da meia-recusa estavam **escritos por nós, como
instrução**:

- a regra do fato atual era chaveada **pelo TIPO do fato** (*"cotação"*), então
  **com o valor na mão** o modelo **obedecia** e mandava confirmar no banco;
- *"a fórmula com os nomes no lugar do que falta"* era **a única instrução** para o
  cálculo — e saiu exatamente *"multiplique 520 pela taxa"*;
- *"explique o limite"* era **licença para parar no conflito**.

**Antes de chamar de defeito do modelo, leia o pedido como se fosse uma ordem
literal** — porque é o que ele é. **O modelo estava obedecendo.**

### A guarda inocente: acuse o instrumento só depois de medi-lo (09/09, Q4-B)

O G3 escreveu que **a guarda `vazaAlheio` comprou mudez sobre palavras do autor**.
A Q4-B foi medir e **a guarda estava INOCENTE** — o texto do autor tinha *"método"*
e *"degrau"*, e **nada foi derrubado**. Quem calava era **`sistemaInstigar`, que
proibia POR NOME**.

O conserto mudou de lugar por causa disso: a proibição passou a ser **por
PROCEDÊNCIA** — e a guarda passou a **dobrar acento e caixa**, para que *"quem
digita 'metodo' sem agudo continue dono da palavra"*.

**Regra:** **acusação de revisor é hipótese até ser medida**, inclusive quando ele
está certo sobre o sintoma. Consertar o componente acusado sem medir teria
**mexido no inocente e deixado o culpado**.

### Parâmetro que chega mas não manda (09/09, Q4-B)

O **degrau chegava** ao modelo — a sonda passa, entra na mensagem de sistema — **e
não mandava**, porque vinha **solto no fim de uma lista fixa de buracos** que
incluía *"o que pode dar errado"*, **que é literalmente o que o degrau 4
devolvia**.

**"Chegou" e "mandou" são coisas diferentes.** Antes de concluir que o modelo
ignora um parâmetro, **veja onde ele cai na instrução**: um dado que entra no fim
de uma lista compete com a lista, e a lista costuma ganhar.

### O conferidor mais duro que a fixture (09/09, LOTE-3)

O placar mecânico caiu de **57/57 para 54/57** — e o próprio medidor mostrou que
**duas das três quedas eram a RÉGUA, não o retorno**: a fixture nunca escreve
*"contra vazio reprova"*, só *"os três campos vazios reprovam"*, e ali **os três
não estavam vazios**. **Pela letra da fixture é 56/57.**

**Regra:** o conferidor **lê a fixture, não a intenção de quem a escreveu**. Um
conferidor mais duro que a fixture **reprova conserto bom** — e é tão perigoso
quanto um mais frouxo, com o agravante de parecer rigor.

**E quem mede tem de saber notar isso.** Este apontou a diferença **contra o
próprio número que produziu** — que é o comportamento que faz uma medida valer.

## Build incremental não conta warning (09/09, achado no G3 da F6)

O relato da F6 declarou **"0 warning"** e o revisor, recompilando, achou **um**, herdado
de `main` em `NotasView.swift:806`. Não houve má-fé: `grep -c warning:` sobre a saída de
um **build incremental** conta os warnings **dos arquivos que recompilaram**, e os
outros simplesmente não aparecem — o número é verdadeiro sobre a corrida e falso sobre
a árvore.

**A lei:** *contagem de warning só vale sobre build que compilou tudo.* Quem declara
"0 warning" declara junto **qual build produziu o número** — limpo ou incremental — e,
se foi incremental, o número é da corrida, não da árvore. Vale para a régua de tempo
pela mesma razão que o quadro longo da V12-C era a captura do teste: **o instrumento
entra na medida, e medida sem o instrumento declarado não é medida.**

## A legenda que promete menos do que a prova entrega (09/09, mesmo G3)

O par `f6-bloqueada-dia-ax5-claro/escuro.png` foi anexado como prova de claro/escuro. As
duas capturas **não diferem em aparência** — diferem em **tamanho de letra**. O revisor
não descartou o par: mediu por pixel e descobriu que ele prova **coisa melhor** do que
prometia — que as faces de acessório não escalam com Dynamic Type (0,73 de variação na
fileira contra 11,87 no cartão vivo, mesmo build, mesmo minuto) — e **subiu** a nota de
Acessibilidade que o autor tinha se dado.

**A lei:** *abrir o artefato é obrigação em qualquer direção.* A captura que não
sustenta a frase que a cita é achado; a que sustenta **outra** frase, melhor, também é —
e quem só confere se a prova bate com a legenda perde metade dos dois casos. **O nome do
arquivo não é evidência; o pixel é.**

## A caça-fala estava CEGA — o vigia que diz zero tem de provar que enxerga (09/09, 23h25)

Por horas o laço reportou **`FALA: 0`** com **quatro processos de síntese vivos** dentro
dos dois simuladores ligados (`SiriAUSP` e `MacinTalkAUSP`, desde 20h27 e 21h18). A
causa é de uma linha: o script lia `ps -Ao pid=,comm=` e pegava **`$2`** como caminho —
e o caminho do runtime do simulador **tem espaço** (`iOS 26.5.simruntime`), então `$2`
era só o primeiro pedaço e o `basename` nunca casava com o nome procurado.

E às **23h20 o `sirittsd` do Mac subiu**, com `ppid 1`. Matei em ~2 minutos. **Nenhum
comando de worker explica**: os quatro em curso não pediram `siri`, nem botão, nem
`say`, nem VoiceOver; o dono estava ativo na máquina ~5 minutos antes. **Não sei quem
foi, e digo isso em vez de inventar culpado.**

**A lei:** *vigia que reporta zero tem de provar que enxerga.* Quem escreve uma caça —
de fala, de warning, de vazamento — **planta o alvo uma vez e confere que a caça o
acha**; caça que nunca acusou nada não está provada, está muda. É a mesma família de
"portão que não enxerga tem de falhar fechado" e de "medir o que a regex conta antes de
congelar".

**E o corolário que essa caça ensinou:** *separe o que FALA do que FALARIA.* O daemon do
Mac (`sirittsd`, `speechsynthesisd`) é o que sai pelo alto-falante do dono — alarme, e
se mata. O plugin de síntese carregado dentro de um simulador ligado é o **estopim**:
reporta-se com o aparelho e **não se mata às cegas**, porque derrubar o áudio de um
simulador tira o chão de uma suíte em curso. Contar os dois no mesmo número é o que
transforma um alarme real em ruído que ninguém lê.

## O estado do instrumento se lê na TRAVA, não no efeito colateral (09/09, 23h30)

Perguntaram-me se a janela do aparelho da conta estava livre. Olhei o **binário
instalado** — ainda o do LOTE-3 — e respondi "ninguém entrou, pode abrir". Estava
errado: a Q3-C **já tinha a trava desde 23h27:13** e simplesmente ainda não chegara ao
`install`. O worker da Q4-C me corrigiu com a prova certa: `/tmp/traco-instrumento.lock`
com PID, script e hora, mais casos concluindo no `avaliacoes-ia.jsonl` com
`contaGrokLigada=true`. Ele **não colidiu**: entrou na fila do `com-trava.sh`, que é o
desenho.

**A lei:** *o dono do instrumento se lê na trava — PID, script e hora —, nunca por
efeito colateral.* Binário instalado, última captura, fase do batimento e arquivo de
prova **todos atrasam** em relação à posse: dizem o que já aconteceu, não o que está
acontecendo. Quem responde "o aparelho está livre" sem ter lido a trava está adivinhando.

**E o padrão maior, que é meu e apareceu duas vezes na mesma hora:** mandei a MERGE-Q34
parar lendo a saída **antiga** dela, quando ela já se recuperara; e disse que a janela
estava livre lendo o **binário** em vez da trava. Duas vezes **li um efeito e chamei de
estado**. *Antes de decidir sobre um worker ou sobre o instrumento, leia o sinal
autoritativo e o mais NOVO que existir* — a trava para posse, a última saída para
progresso. Sinal velho custa mais caro que sinal nenhum, porque parece informação.

## Prova de vigia tem dois graus, e o menor se DECLARA (10/09, caça-fala)

Ontem escrevi a lei "vigia que reporta zero tem de provar que enxerga". Hoje ela foi
cobrada de mim e o resultado é mais interessante que um simples "provado":

- A perna do **estopim** foi provada com **alvo plantado**: um `/bin/sleep` renomeado
  para `MacinTalkAUSP-ISCA`, zero áudio. Isca viva, acusa 1; isca morta, acusa 0.
- A perna do **falante** **não pôde** ser provada assim: copiar um binário assinado para
  um arquivo chamado `sirittsd` faz o macOS matar o processo no ato (rc=137). O que se
  pode afirmar é **menos**: o mecanismo foi conferido contra daemon real e contra nome
  inexistente, e a perna **pegou o alvo verdadeiro duas vezes** em campo.

**A lei ganha um segundo andar:** *prova de vigia tem graus, e o grau menor se declara no
próprio vigia.* Alvo plantado > captura em campo > mecanismo conferido > nada. Escrever
"provado" quando só se tem o terceiro grau é o mesmo defeito que a caça cega, com uma
camada a mais de confiança falsa. **O grau está escrito dentro do `cacar-fala.sh`**, para
quem o herdar não precisar acreditar em ninguém.

**E eu já tinha cometido o erro:** o commit que trouxe essa caça para o repositório disse
"provada com alvo plantado", sem qualificar — verdade para uma perna, não para a outra.
Corrigido aqui, no arquivo, que é onde a próxima pessoa vai procurar.

## A guarda vai onde todos passam, não em cada um que passa (10/09, G3 da MAC-2-A)

O G3 reprovou a MAC-2-A com **Privacidade e autoria em 4**, e o defeito é uma forma que
vai voltar: `Sessao.calarAcoesDerivadas` tem **três chamadores**, e
`trancarExpressivasVencidas` **sela de verdade sem ser um deles**. Como
`espelharTrabalhos` só escreve e nunca retira, o `.md` do trabalho de uma nota **selada**
ficaria legível pelo bot no Mac **para sempre**. A sonda do revisor diz em uma linha:
`SONDA-3 expressiva vencida: trancada=true permitido=false existe=true`.

**A lei:** *guarda espalhada por chamador é uma lista de gente que precisa lembrar;
guarda no laço que escreve é uma invariante.* Quatro rotas selam hoje; a quinta que
alguém escrever amanhã não vai chamar nada, e tem de ficar correta mesmo assim. **O
conserto certo é quase sempre MENOR que o errado** — aqui, a invariante no laço de
espelhar dispensa o `remover` de todos os chamadores.

**E o controle que prova a régua:** das quatro sondas do revisor, **uma passa de
propósito**. Sem ela, três vermelhos não distinguem "achei o defeito" de "a sonda está
quebrada". *Toda sonda que acusa precisa de uma irmã que não acusa.*

## Fotografar janela sem levantá-la (10/09, mesmo G3)

Alegou-se que a conversa do Grok Bot não podia ser capturada porque a janela está fora da
área capturável — e a ausência da captura foi aceita como **limite de instrumento**, sem
descontar nota, porque a chamada tinha prova de máquina e o retorno era verificável.
**Mas o motivo não vira precedente:** `screencapture -l<windowid>` fotografa uma janela
**sem trazê-la à frente**, o que respeita a lei do dono ativo (ocioso < 60 s, não levantar
janela). Antes de declarar "não dá para fotografar", tente por id de janela.

## O requisito promovido para morder no caso pobre vira TETO no caso rico (10/09, Q4-C)

A Q4-C consertou três defeitos medidos de uma vez — `semRetorno` com HTTP 200 **1→0**,
renda inventada **1→0**, e o texto magro passou a pedir *quando* **0/3 → 3/3**. E, na
mesma medida, **nasceu o defeito oposto**: num caso em que a nota dá material farto, as
perguntas viraram literalmente *"O que aconteceu? / Quando aconteceu? / O que seria dar
certo?"* — a lista, sem nada da nota —, onde a base do LOTE-3 cobria critério, evidência
e custo de errar.

**A lei:** *requisito promovido para MORDER no caso pobre deixa de governar só onde
falta matéria.* A medida da Q4-C nomeou a forma melhor do que eu: o requisito vira
**acréscimo** na nota farta — o modelo cumpre a lista promovida **e a soma** às perguntas
que já faria —, e às vezes vira **substituição**, com as três perguntas da lista e nada
da nota (`q4-instigar-com-metodo-decisao` r2).
Promover uma lista fixa ao alto do pedido, com "pelo menos duas cumprem ao pé da letra",
faz o modelo cumprir a lista **e parar**. No texto magro isso é o conserto; no texto
farto é o dano. Quando a promoção regride a linha de base, a alavanca seguinte não é
*mais* promoção nem *mais* proibição: é o requisito ficar **condicionado à matéria** —
quando a nota dá pouco, pergunte o que/quando/o que seria dar certo; quando dá mais, as
perguntas saem do que ela escreveu.

**E o modo como isto apareceu é o que se quer de um medidor:** a própria volta mediu,
viu, e **nomeou o defeito como causado pela mudança dela**, sem arredondar, antes de
saber se o outro modelo repetia. *Quem mede o próprio conserto tem de poder reprovar-se —
e a medida que só confirma quem a encomendou não é medida.*

## A trava serializa COMANDO; não serializa o ESTADO do aparelho (10/09, Q4-C)

Despachei a Q3-C e a Q4-C com o **mesmo** `B91C8DEF`, cada uma com "uma instalação por
cima", e invoquei a trava como salvaguarda. **A trava não cobre isto.** Ela serializa
comandos; o `install` é uma **mutação que sobrevive à soltura da trava** e troca o binário
debaixo de quem vier depois. A Q4-C mediu sozinha das 10:55:25Z às 11:10:47Z, com o
binário carimbado nos dois extremos do log e a conta ligada nas três leituras — e então
percebeu que **qualquer captura sua feita depois do install da Q3-C seria do binário
alheio**. Parou antes de tirá-la.

**A lei, afiada:** *duas voltas não dividem um aparelho onde qualquer uma INSTALA, nem
serializadas.* A trava basta para quem só lê a tela; não basta para quem escreve o
aparelho. Quem despacha escreve o UDID de cada volta e confere que **nenhum se repete** —
e se duas precisam do mesmo aparelho da conta, ou elas entram na MESMA janela com UM
binário (que é o que os LOTES fazem), ou a segunda espera a primeira **fechar a volta**,
não fechar a trava.

**E o corolário que a Q4-C escreveu melhor do que o meu despacho:** *evidência
contaminada, declarada e usada, é pior que evidência nenhuma.* Uma captura do binário do
vizinho, com uma nota de rodapé honesta, ainda seria lida como prova da volta que a
anexou.

## Não se fotografa o que o app não pode mostrar (10/09, mesma volta)

A Q4-C pediu uma segunda instalação para fotografar a frase nova (`nadaPassouNaGuarda`).
A resposta estava na própria pergunta: a frase é **inalcançável em produção hoje**, porque
`Politica.aviso` responde antes — `instigar` e `contrapor` seguem `indisponivelPorQualidade`.

**A lei:** *motor sem superfície não conta como entregue — mas superfície que o app não
pode alcançar não se fotografa.* Gastar o aparelho da conta atrás dessa captura produziria
nada. O limite se declara, com o motivo, e **vira dívida nomeada com dono**: quem devolver
a operação à lista fotografa a frase **no mesmo ato**. Não é acabamento esquecido, é
consequência declarada — no dia do retorno, essa frase chega ao autor sem nunca ter sido
vista na tela.


## O conserto escrito depois da medida NÃO entra no binário medido (10/09, Q4-C)

A Q4-C escreveu o conserto do defeito oposto e **não o aplicou, de propósito**. A razão é
exata: *"aplicá-la agora faria o binário comitado divergir do binário medido, e uma
corrida nova também não seria medida"* — porque não haveria tempo nem janela para medi-la
com a mesma alavanca única.

**A lei:** *a volta que mede fecha com o binário que mediu.* O conserto que nasce da
leitura da medida é **dívida nomeada da volta seguinte**, não um remendo de última hora —
senão o relatório descreve um binário e o commit entrega outro, e ninguém percebe porque
os dois têm o mesmo SHA de árvore. Escrever o conserto e não aplicá-lo é disciplina, não
preguiça: a alavanca fica pronta e a medida fica honesta.

## A trava virou ARQUIVO e travou a casa por meia hora (10/09, achado da Q4-C)

Às **08h25** o `/tmp/traco-instrumento.lock` deixou de ser diretório e virou **arquivo
comum de 0 byte**. **A causa foi achada pela Q4-C e é de uma linha:** o *keep-alive* das
janelas de medida fazia `touch "$L"` a cada 60 s para a trava não parecer velha — e um
`touch` **depois** de a trava ser solta **CRIA um arquivo** no lugar dela. Aconteceu duas
vezes hoje. Consertado nos quatro `lote-ia-09*-janela.sh`: `[ -d "$L" ] && touch "$L"`. A primitiva do `com-trava.sh` é `mkdir` — atômica **porque** cria
diretório —, então ela passou a falhar **para sempre**, e dois workers (Q4-C e MAC-2-A-B)
ficaram girando sem poder entrar. Pior: sem `$L/dono` legível, a **guarda de PID também
cega**, e só a de 30 minutos salvava. Meia hora de instrumento parado com três voltas
vivas.

**O conserto custou duas linhas** e está provado com **defeito plantado**: planto um
arquivo no lugar da trava, o `com-trava.sh` acusa *"a trava virou ARQUIVO; removendo para
destravar"* e entra; sem o defeito, entra igual (o controle).

**A lei:** *toda guarda que depende da FORMA de uma coisa confere a forma antes de confiar
nela.* `mkdir` só é atômico sobre diretório; `flock` só serializa sobre descritor; a
guarda de PID só lê PID se o arquivo existir. Quando a forma quebra, a guarda não avisa —
ela **falha aberta ou trava fechada**, e as duas são piores que o defeito. Aqui a
degradação era silenciosa em ambos os sentidos, e quem a viu foi um worker esperando a
vez, não o vigia.


**E as duas camadas se justificam:** o `[ -d "$L" ]` do keep-alive ainda tem uma janela de
corrida de microssegundos entre o teste e o `touch`; a guarda de forma no `com-trava.sh`
cobre o resto. *Conserto de causa e conserto de sintoma não competem quando o sintoma é
uma casa parada por meia hora* — mas o de causa vem primeiro, e sem ele o outro só encurta
o estrago.

## O binário que a medida rodou é EVIDÊNCIA, e um rebuild a destrói (10/09, G3 da Q3-C)

O autor da Q3-C achou que a árvore carregava um prompt **editado depois de a janela
fechar** e resolveu certo: extraiu o texto **do binário medido** (`Traco.debug.dylib`
`57d02df3`) e comitou esse, conferido byte a byte. Mandei o G3 refazer a conferência pelo
binário — e o revisor respondeu: **`57d02df3` não existe mais em disco.** Um build
posterior o substituiu.

**A lei:** *o binário que a medida rodou é evidência da medida, e evidência que um rebuild
apaga não é evidência.* Quem abre janela de medida guarda, junto do `.jsonl`, **o hash e o
que for preciso para reproduzir a alegação** — o texto do prompt extraído, no mínimo. Sem
isso, a frase "conferi byte a byte contra o binário medido" vira **palavra**, e a régua
desta casa é que ninguém acredita em palavra.

**E é uma dívida de forma, não de pessoa:** o carimbo do binário nos dois extremos do log
(que os LOTES já fazem) prova **qual** binário rodou; não preserva **o conteúdo** que
alguém vai querer conferir depois. Os dois são precisos.

## A porcentagem que faz média esconde o caso que foi a ZERO (10/09, G3 da Q4-C)

A Q4-C mediu a regressão que o próprio conserto comprou e a reportou honestamente:
perguntas ancoradas na nota caíram de **96% (49/51) para 76% (48/63)** no `grok-4.3`. O
G3 reproduziu os números — e então **leu caso a caso**, e achou o que a média tinha
diluído: em `q4-instigar-com-metodo-decisao`, **as TRÊS pernas da fixture** — critério,
evidência e custo de errar — caíram de **3/3 para 0/3**. Não é uma piora de vinte pontos:
naquele caso a operação **parou de fazer o que a fixture pede**, inteiramente.

**A lei:** *coluna que faz média entre casos esconde o caso que foi a zero.* Uma
porcentagem agregada é boa para dizer que **algo** mudou e péssima para dizer **o quê**.
Toda régua nova nasce com a leitura **por caso** ao lado; e quando a agregada piorar, a
primeira pergunta é **qual caso morreu**, não **quantos pontos caíram**.

**E o modo como apareceu vale tanto quanto o achado:** o autor reportou a média com
honestidade e sem arredondar; o revisor, que não escreveu os casos, foi ao caso. *Nenhum
dos dois viu sozinho o que os dois viram juntos* — é para isso que o G3 é de quem não fez
a volta.

## O keep-alive morre com a janela que ele mantém viva (10/09, 08h42, achado do re-G3)

Consertei de manhã o `touch "$L"` dos quatro `lote-ia-09*-janela.sh` e a guarda de forma
no `com-trava.sh`, achando que era aquilo. **Não era.** Às 08h42 a casa travou de novo, e
o culpado era **outro** keep-alive com o mesmo defeito — `segurar-trava.sh`, num
scratchpad de sessão do `q3-c` — e desta vez **não destravava nunca**:

- `mkdir` **nunca** passa sobre um arquivo;
- a retomada de dono morto lê `$L/dono`, que num arquivo **não existe**;
- a retomada de 30 min olha o **mtime**, que o `touch` renova a cada 30 s.

**As duas saídas do `com-trava.sh` mortas ao mesmo tempo.** Três workers parados.

E o processo era **órfão**: `ppid = 1`, o worker que ele servia já estava
`completed/succeeded/settled`, e as capturas dele já estavam comitadas. Ele segurava uma
janela que tinha acabado, **anunciando no `dono` um trabalho que ninguém mais fazia**.

**A lei, em duas metades:**
1. *Todo `touch` numa trava confere que ela ainda é o diretório* — senão ele a **recria
   como arquivo** assim que o dono a solta. O padrão é sistêmico: vale para qualquer
   keep-alive, em qualquer script, inclusive os de scratchpad que ninguém revisa.
2. *O keep-alive morre com a janela que ele mantém viva.* Um que sobrevive ao dono não
   está protegendo nada — está **mentindo no `dono`** e travando a casa. Se ele pode ficar
   órfão (`ppid 1`), ele vai ficar.

**E a nota amarga:** `kill` não o matou; precisou de `kill -9`. **Segunda vez no dia** que
um matador educado falha nesta máquina — a primeira foi o vigia de fala mandando SIGTERM a
um `sirittsd` que o ignora, e o deixou vivo 19 minutos. *Matador que não confere o corpo
não matou.*

**O método do worker que achou merece cópia:** leu a trava por `stat` e o dono por `ps`,
**não por efeito colateral**; e viu que *"só `rm` do arquivo não resolve, o `touch` o
recria em até 30 s"* — que é a diferença entre destravar e **parecer** que destravou. E
não matou processo alheio sozinho: escalou com o PID na mão e seguiu na leitura estática
enquanto esperava.

## A trava deixou de serializar EM SILÊNCIO, e três xcodebuild correram no mesmo aparelho

O pior efeito do dia não foi a casa parada — foi a casa **andando errado**. Enquanto a
trava oscilava entre diretório e arquivo, ela **parou de serializar sem avisar ninguém**, e
**três `xcodebuild test` correram no mesmo simulador**. Com o mesmo bundle id, duas
corridas se instalam por cima uma da outra e **as duas medem errado**.

A prova é de um revisor e é irrefutável: a primeira suíte dele **executou
`RespostaNotasTests.oModeloDaRotaPassaPelaSonda()`** — um teste que **não existe na árvore
dele**, e que `git log -S` localiza no commit `319e9a5` de outra volta, confirmado
**não-ancestral** do HEAD dele. O pacote que rodou no UDID dele **não era o dele**. Ele
descartou a corrida e refez.

**A lei:** *suíte verde medida com a trava quebrada não é suíte verde.* E porque a quebra
é silenciosa, o portão não pode depender de a trava estar sã:

> **Quem declara "suíte verde" cola a contagem E prova que rodou a PRÓPRIA árvore** —
> mostrando no log um teste **exclusivo do seu candidato**. Sem isso, o número pode ser do
> vizinho.

É a mesma família do controle que prova a régua: um teste que só existe aqui é o **alvo
plantado** da suíte. E o dano não é só falso verde: **vermelho falso reprova volta boa**,
e uma volta reprovada por engano custa mais que uma aprovada por engano, porque ninguém
vai reconferir uma reprovação.

**E o `xcodebuild test` chamado FORA do `com-trava.sh` é a causa que sobra.** A lei do
`revisor.md` já mandava passar pela trava; um worker foi visto às 08h49 rodando direto,
com a trava inexistente e outro esperando na fila. **Nenhuma corrida no aparelho de
trabalho fora da trava, nem "rapidinho".**

## A guarda mais forte é a que o COMPILADOR aplica (10/09, MAC-2-A-C)

Duas voltas seguidas ensinaram a mesma coisa em degraus. Primeiro: *a guarda vai onde
todos passam, não em cada um que passa* — e a invariante saiu dos chamadores para o laço
que escreve. O revisor então achou o mesmo defeito **uma função adiante**: a `cercar` era
aplicada **à mão** em três dos quatro campos crus, e o quarto forjava a seção.

A MAC-2-A-C subiu o último degrau: **`markdown` passou a montar o arquivo a partir de
`[Linha]`, não de `[String]`.** Literal de Swift é estrutura; valor interpolado que começa
linha passa por `cercar` **para existir**. Um `String` cru **não compila** — e ela provou
isso de propósito, colhendo o erro (*"cannot convert value of type String to expected
argument type EspelhoTrabalhos.Linha"*) e desfazendo a mutação.

**A lei, no seu degrau mais alto:** *guarda em tempo de execução é uma promessa; guarda no
tipo é um fato.* Quando a forma do dado pode carregar a regra, **carregue** — o quinto
campo que alguém acrescentar amanhã não vai lembrar de cercar, mas também **não vai
compilar**. Suba: à mão em cada chamador → invariante no laço → impossível pelo tipo.

**E a sonda subiu junto:** passou a contar título **por ESTRUTURA** (ATX com espaço, ATX
com TAB, setext, nada dentro de cerca de código) em vez de `hasPrefix` — porque *a sonda
que erra do mesmo jeito que o código não guarda nada*. A prova de que ela enxerga: a
reescrita ficou **vermelha na primeira corrida**, antes de a asserção apertar.

## A garantia do tipo vale até a genérica que aceita tudo (10/09, 3º G3 da MAC-2-A)

Celebrei ontem à tarde que o defeito virara **impossível**: `markdown` monta de `[Linha]`,
`String` cru **não compila**. O revisor refez a prova — **ela se sustenta** — e então a
contornou por três portas, e as três valem a lição:

1. **`appendInterpolation<T>` aceitava `Substring` e `Any`**, que passam **sem cerca**. A
   promessa "não compila" valia para `String` e **não para os primos**. *Guarda no tipo é
   um fato — mas a genérica que aceita tudo é a porta dos fundos do tipo.* Estreite o
   `where`, ou a garantia é decorativa.
2. **`"\r\n"` é UM `Character` em Swift.** `split(separator: "\n")` sobre um texto com fim
   de linha do Windows devolve **UMA linha**, e a cerca **não rebaixa nada**: as rotas
   reabrem juntas e o ``` pendurado **engole as seções do próprio arquivo**.
3. **`Corpus.umaLinha` trocava o `\n` e deixava o `\r`** — que é quebra pela mesma
   CommonMark que a ADR cita. Todo campo de "uma linha" **plantava linha**: **2 e 4** seções
   `## Relatos` medidas onde só cabe 1.

**E o conserto já existia na casa:** `Traco/Caderno/BlocoCaderno.swift:78-84` normaliza CRLF
com o comentário certo — *"CRLF entra por import de .md feito fora do iPhone. Sem
normalizar, o `\r` sobrevive até a TELA"*. **Escrever a segunda normalização em vez de
reusar a primeira seria o slop que a lei nomeia.**

**A lei:** *toda guarda que parte texto declara o que considera fim de linha.* E o corolário
que fecha o arco de dois dias — à mão em cada chamador → invariante no laço → impossível
pelo tipo — **é que nenhum degrau dispensa a pergunta seguinte: por onde mais entra?**

## Fato observado, ou defeito com outra roupa? (mesma volta)

O autor declarou o cabeçalho YAML como **"fato observado"**. O revisor **discordou com
prova**: enquanto o `umaLinha` deixar o `\r`, é **o mesmo defeito com outra roupa** — e a
frase do `SPEC` que sustentava a declaração (*"o autor não consegue plantar linha ali"*) é
**falsa hoje**, porque foi por ali que saíram as quatro seções.

**A lei:** *"fato observado" é uma alegação, e alegação se confere.* Declarar limite é
honesto; declarar limite sobre uma premissa que ninguém testou é a meia-recusa da
engenharia. Feche a premissa primeiro — o que sobrar depois, aí sim, é fato.

## O atalho rápido que é CEGO ao caso que ele guarda (10/09, MAC-2-A-D)

Mandei reusar o normalizador de CRLF que **já existia** no repositório
(`BlocoCaderno.fatiasSemMemo`) — e a volta descobriu, consertando, que **ele nunca
correu**. A forma era:

```swift
let normal = fonte.contains("\r") ? fonte.replacing... : fonte
```

**`String.contains("\r")` resolve para `contains(_ element: Character)`** — e num texto
CRLF o `Character` é **`"\r\n"`**, não `"\r"`. Logo **`false`**, e o normalizador **não
roda**. Medido: `false` por `contains`, `true` por `unicodeScalars`. Ou seja: **o import
de `.md` do Windows nunca foi normalizado no Caderno**, e o `\r` sobrevivia até a tela —
exatamente o que o comentário daquele código dizia estar impedindo.

**E a sonda que guardava o caso estava verde pelo mesmo furo:**
`!visivel.contains("\r")` — **a sonda copiou a expressão do código**. *A sonda que erra
igual ao código não guarda nada*, e é a segunda vez em dois dias que isso aparece (a
primeira foi a `SONDA-4` sem ver o TAB).

**A lei:** *o atalho de desempenho tem de enxergar o mesmo que o caminho lento.* Um
`guard` que evita trabalho e é cego ao caso que o trabalho trata é **pior que não ter
guarda** — ele desliga o conserto **e** dá a impressão de que ele roda. Ao escrever
"só normaliza se precisar", prove que o "se precisar" enxerga.

**Em Swift, concretamente:** para procurar `\r` num texto que pode ser CRLF, use
`s.unicodeScalars.contains("\r")`. Para "tem alguma quebra?", `contains(where: \.isNewline)`,
**nunca** `contains("\n")`.

**E a correção é minha:** eu mandei reusar aquele código dizendo que o repositório já
resolvia isso. **Reusar é o degrau certo da escada — mas reusar sem conferir propaga o
defeito com a autoridade de quem já estava lá.** O irmão que se reusa também se lê.

## O arquivo só se apaga quando o app consumiu TUDO o que havia nele (10/09, P0-CRLF)

A volta do `\r` mediu de novo, com harness próprio — cópia verbatim das linhas do `Corpus`,
em vez de acreditar no revisor — e achou um **caso E** que muda o nome do defeito:

> **prosa do autor antes do primeiro cabeçalho, LF puro, sem um único `\r`:**
> `itens=1`, **leu 12 de 104 chars**, `apagaria=SIM`.

O laço começa em `hits[0].range.location`: **tudo o que vem antes do primeiro
`---\ncriada:` nunca é examinado**. Um `.md` que o autor escreva **à mão** na pasta
`entrada/` do Mac, começando com um título, **perde essas linhas calado — e o arquivo é
apagado**. Não é o bug do Windows. **O `\r` era só um dos jeitos de chegar nele.**

**A lei, corrigida pelo G3 que a mediu — e a correção é minha:** *o arquivo só se apaga
quando o app **delimitou** tudo o que havia nele.* Eu tinha escrito **cobertura de
LEITURA**, e o revisor derrubou a alegação forte com dois contraexemplos: um descarte no
estilo da própria casa (**teto de 140 grafemas da ADR 08h, sem `continue`**) importou **140
de 659 caracteres** com `consumido = 1,00` **e apagou o arquivo**; e sem código futuro
nenhum, os campos `dominio` e `recordada` — que **o próprio app escreve e o importador nunca
lê** — somem na volta pela `entrada/` com a conta dizendo 100%. **A cobertura tem de contar
o que foi DELIMITADO como pertencente a alguma nota, não o que foi consumido pelo caminho
que existe hoje.** Menos de 100% é **incerteza**, e incerteza não apaga —
bloco que caiu no `continue`, prosa antes do primeiro cabeçalho, bloco sem fecho, cabeçalho
que não casou. **A pergunta certa não é "o regex casou?" e sim "quanto do arquivo eu
consumi?"**, e isso é um número que o código calcula e o teste lê, não uma impressão.

**A coluna que a volta inventou no próprio harness — `leu X de Y chars` — É a invariante.**
Vale a atenção: a régua certa apareceu como coluna de diagnóstico antes de alguém perceber
que era a regra. *Quando um medidor precisa de uma coluna nova para explicar o defeito,
essa coluna costuma ser o contrato que faltava.*

**E o corolário do portão:** hoje um cabeçalho que **não casa** vira "sem cabeçalho" e
**abre tudo** — origem vira autor, selo não detectado. *Portão que não enxerga tem de
falhar fechado*: formato não reconhecido **não entra como do autor** e **não apaga**.

## O oráculo não pode ser cópia da regra que ele julga (10/09, re-G3 da MAC-2-A)

O terceiro re-G3 achou o caminho que ainda entrava: **`cercar` decide se a linha abre ou
fecha cerca de código DEPOIS de aparar o espaço; a CommonMark §4.5 decide ANTES, contando o
recuo** (até três espaços). Com **quatro** espaços as duas discordam **nos dois sentidos**.

Na tela do bot: com uma cerca recuada quatro espaços dentro da resposta do modelo, **o
`## Relatos` DELE vira seção de verdade do arquivo e o relato do AUTOR fica dentro de um
bloco de código** — some o que ele escreveu e entra o que ele não escreveu.

**E o método é a lição:** ele usou **o parser CommonMark da Apple como oráculo**, e disse
por quê — *"escolhido por NÃO ser cópia da regra do código"*. A sonda da própria casa
(`TitulosDoMarkdown`) **também apara antes de decidir**, e por isso era **cega a isto**.

**A lei:** *o oráculo não pode ser cópia da regra que ele julga.* Uma sonda escrita a partir
do código confirma o código, não o contrato — é a terceira vez em dois dias que isto
aparece (a `SONDA-4` sem ver o TAB, a sonda do CRLF copiando o `contains` do código, e agora
a régua de títulos aparando junto). **Quando existir um implementador independente do
contrato — um parser de referência, uma biblioteca do sistema, o próprio consumidor —,
julgue por ele.**

**E a lista do que NÃO passou é prova tanto quanto o que passou:** `U+2028`, `U+0085`, `\r`
isolado, CRLF nos quatro campos e no cabeçalho, cerca aberta e nunca fechada, e
`Substring`, `NSString`, `String?`, `Any`, `Double`, `Bool`, `Character`, `UUID` e
`[String]` na interpolação — **todos recusados pelo compilador, um a um por
`swiftc -typecheck`**. Quem só publica o que quebrou não mostra o tamanho da garantia.

## Uma trava de shell não serializa uma chamada MCP (10/09) — e o P0 aconteceu ao vivo

**A causa raiz das três contaminações de hoje.** Havia um **`npx xcodebuildmcp@latest mcp`**
vivo desde as 10h40, filho do `codex app-server` do ambiente de um worker Codex. **Um MCP de
`xcodebuild` não passa pelo `com-trava.sh` POR CONSTRUÇÃO** — nenhuma trava de shell
serializa uma chamada de ferramenta MCP. Enquanto ele existir, **a trava é decorativa** para
quem o usa, e a suíte do vizinho roda no seu UDID.

**E o P0 do dia aconteceu ao vivo, com hora e testemunha.** Às 10h56, dentro da própria
trava, uma volta instalou o candidato dela e semeou sete `.md`; às **10h57**, entre duas
chamadas dela, **outro build instalou no mesmo aparelho** (o contêiner trocou, o `cmp` do
binário deu diferente) — e **apagou quatro dos sete arquivos em um minuto, sem pedir nada**,
deixando exatamente os dois que o parser de `main` também recusa. **Um build sem o conserto
apagou arquivos de um autor simulado**, e nenhuma fixture teria produzido essa prova.

**Duas leis:**

1. *Toda medida de comportamento no aparelho confere que o binário instalado é o SEU* — com
   `cmp` contra o próprio produto de build, **antes e depois** da corrida. A frase é de quem
   achou: **"a trava está livre não é o mesmo que o binário é o meu."**
2. *Nada de `xcodebuild` por MCP.* Build e install passam por **chamada de shell sob
   `com-trava.sh`**, sempre. Um servidor MCP de build vivo na máquina é hazard, não
   conveniência — e se aparecer um, **encerre-o e diga**.

**E o padrão de auditoria de suíte sobe:** contar testes pega contaminação que muda o total;
**conferir os NOMES executados contra os declarados na própria árvore pega a que não muda**.
A volta que achou isto auditou **901 nomes distintos** e declarou **zero de fora**. É o que
passo a pedir.

## ⛔ TAMANHO DE LETRA DE ACESSIBILIDADE É PROIBIDO (DIRETRIZ §12, dono, 10/09)

Ao lado da proibição de VOZ, e pela mesma razão: **o dono disse que não usa, e ver o app em
letra máxima o irrita.** Ele viu o aparelho de trabalho em tamanho AX às **11h04** e
escreveu: *"está testando letra grande por quê? já falei que está proibido."* Foi **trinta
minutos** depois de a §12 ser escrita.

**Proibido, sem exceção:**
- `xcrun simctl ui <UDID> content_size` com **qualquer valor acima de `large`**;
- **flow** `ax5.yaml` ou equivalente;
- `f5-fotografar.sh` com tamanho de acessibilidade — **o 4º parâmetro dele foi removido** e
  o tamanho é sempre `large`;
- **launch arg** de `ContentSizeCategory` acima de `large`;
- spec, portão, captura, teste, vídeo ou dívida em AX1–AX5 / XXXL.

**Dynamic Type vale até `large`**, que é o padrão do iPhone, e é em `large` que se
fotografa. Código que já existe fica como está: **se quebrar em AX5, não é defeito**.

**Continua valendo, e não é negociável:** alvos de **44 pt**, **contraste**, **rótulos** e
**ordem na árvore**.

## Quem mata um worker herda a restauração dele (10/09, a mesma violação)

**Quem pôs a letra em AX foi a volta `AX5-1`**, às ~10h39 — quatro minutos depois de a §12
ser escrita e antes de a ordem chegar até mim. Mas **a letra ficou grande porque EU a matei
com `worker-stop` antes de o passo de restauração dela rodar**. O spec que eu mesmo escrevi
para ela dizia *"restaure `medium` ao fim, conferido por captura"* — e matar o worker pulou
exatamente essa linha.

**A lei:** *quem encerra um worker à força herda o `defer` dele.* Aparelho, tamanho de
letra, tema, orientação, trava, processo de apoio: o worker morto **não desfaz nada**, e o
estado que ele deixou é responsabilidade de quem apertou o botão. **Antes de `worker-stop`,
leia o que o spec mandava restaurar; depois de matar, restaure e confira por captura.**

Os outros três foram conferidos e estão limpos: a Q4-E só **leu** `content_size` (consulta,
sem valor), a P0-CRLF só **escreveu `medium`** (restauração, com captura de prova), e a
MAC-2-A G3, a Astra, a MERGE-Q3D e a TEMPO **não o chamaram nenhuma vez**.

## Os aparelhos, refeitos por ordem do dono (10/09, 11h10)

Palavras dele: *"eu preciso que vocês resolvam, pode fazer o que for preciso, eu JÁ REALIZEI
LOGIN. Não é para vocês ficarem toda hora criando novo simulador para ter que de novo fazer
login no Grok."*

| aparelho | UDID | papel | lei |
|---|---|---|---|
| teste 2 | `B91C8DEF-…` | **CONTA** | sonda de IA e capturas. **Nunca** `erase`, `clearState`, `uninstall` nem `xcodebuild test`. Install **por cima**. |
| teste 3 | `34CC3F94-…` | **CONTA** (novo) | **a mesma lei, inteira.** Deixa de receber suíte hoje. |
| teste 4 | `A1DF082C-…` | **SUÍTE** | build e teste. Nenhum aparelho de conta recebe suíte. |

**Duas leis novas, e a segunda é a que o dono cobrou:**

1. **Com DOIS aparelhos de conta, as janelas de IA correm em PARALELO** — uma operação em
   cada, **cada um com a própria trava por UDID**. O gargalo de uma janela de ~25 min por
   operação **cai pela metade**.
2. **CRIAR SIMULADOR É ATO DO ORQUESTRADOR, uma vez, registrado no LACO.** Nenhum worker
   cria; **ninguém apaga simulador**. Cada simulador novo custa um login do Grok feito **à
   mão pelo dono** — é o recurso mais caro da casa e não se gasta por conveniência. O teste
   4 **já existia**: foi religado, não criado.

**E a razão de a suíte sair dos aparelhos de conta é medida, não zelo:** `xcodebuild test`
roda hospedado no app e o chaveiro é do SIMULADOR — foi assim que a suíte **apagou a conta
do dono** em 09/09 (ADR 09l, volta K1). Enquanto a suíte correr onde há conta, a conta está
a uma corrida de sumir.
