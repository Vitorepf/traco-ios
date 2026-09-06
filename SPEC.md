# Traço — spec do produto

> **Tese vigente — ADR 2026-09-05g:** leia [VISAO-PRODUTO.md](VISAO-PRODUTO.md).
> Traço realiza intenções no mundo e desenvolve capacidades pertinentes,
> combinando mente, IA e ambiente compartilhado. “Nunca escreve pelo usuário”
> e “texto pronto = dívida cognitiva” abaixo são formulações históricas
> substituídas pela fronteira contextual de autoria e delegação da ADR 05g.
> Esta decisão não declara implementadas as novas capacidades nem revoga o selo.

> iOS puro (Swift/SwiftUI). Contratos atuais seguem a visão vigente; ADRs datadas
> preservam decisões e evidências de seu período. Estado comprovado: [EVOLUCAO.md](EVOLUCAO.md).
> Uma regra histórica de superfície não limita a finalidade inteira do produto.
> ADR 2026-08-31 — Reforma da linguagem: Pilha→Notas · Porteiro→Análise (botão: Analisar) ·
> Puxar→Recordar · Códice→Padrões · Véu→Confirmação · Trava→Aviso. Critérios: usuário de
> primeira viagem entende sem manual; verbo para ação, substantivo comum para tela; zero
> metáfora interna. "Gesto" permanece: é conceito da tese, não nome de UI. Rename atômico
> em código+testes+maestro+specs; propriedades persistidas do SwiftData intocadas.
> ADR 2026-08-31e — IA real como padrão (ver §5). ADR 2026-08-31f — nota PODE ser
> apagada, com atrito (confirmação; trancada = dupla) + cancela revisão + varre anexos.
> ADR 2026-08-31g — onboarding: nenhum; a auto-análise É o onboarding (§17).
> ADR 2026-08-31h — swipe-back custom (Empilha) aceito; física nativa fica em P3.
> (01/set: a navegação do §20 rev.2 deixou o Empilha sem chamador; componente deletado.
> A física de folha do arrasto vive nas Camadas; o peek de folha na lista é P1 na FILA.)
> ADR 2026-08-31b — Régua do Caderno podada 136→12 (menu grande = template em menu, §12);
> o catálogo completo permanece no formato de arquivo: nota antiga nunca quebra.
> ADR 2026-08-31i — **Digitação viva**: em prosa+lista a página edita CRUA num único
> campo (o campo sob o cursor nunca morre no meio da digitação; Enter herda o marcador,
> double-Enter sai) e a forma VESTE ao soltar o teclado. O modo cru é proibido fora de
> prosa+lista: código/tabela/citação/anexo abrem sempre nos portais vestidos — o autor
> jamais vê markdown de mobiliário (```, traco://, :::, >). Lei do dono (31/ago):
> "eu nunca devo lembrar os códigos Markdown".
> O protótipo-espelho (HTML) demonstra os fluxos; o código real vem depois da spec aprovada.

## 1. Visão vigente

Traço transforma intenção em realização no mundo e desenvolve as capacidades
pertinentes para realizar mais depois, combinando mente humana, IA e ambiente
compartilhado. A definição completa está em [VISAO-PRODUTO.md](VISAO-PRODUTO.md).
Notas, escrita, calendário, métodos, MD/HTML e segundo cérebro são meios.

**Frase do produto:** transformar o que a pessoa pensa em algo que ela consegue
realizar, com a IA produzindo e ajudando a desenvolver o que esse objetivo pede.
Não promete realizar condições externas nem desenvolver habilidades sem evidência.

## 2. Autoria, delegação e prática

A IA pode escrever, resumir, traduzir, programar e revisar trabalho delegado.
A fronteira é a origem e a participação escolhida: texto gerado não se torna
voz pessoal, relato íntimo ou tentativa do usuário apenas por estar no documento.
Na escrita pessoal e na prática de recuperação, preservar a atividade do autor.
No Trabalho, produzir artefatos úteis com histórico e autoria; não impor uma
prova de programação a quem quer delegar a criação de um produto.

A Análise de notas continua classificando formas sem reescrever silenciosamente
a nota. Essa restrição local não é um veto à produção pela IA em outras rotas.
A lista de classificar, perguntar, recordar e calar descreve esse contrato local;
ela não é a lista completa de capacidades permitidas ao Traço.

Persistência, privacidade, permissões e transições de estado têm validação em
código. Método, representação e divisão de trabalho servem à intenção vigente.
Selo e origem continuam protegidos inclusive em busca, exportação e contexto.

## 3. Porta de entrada da escrita (fluxo existente)

O app **abre direto na página de escrita**, no sistema claro vigente, cursor pronto. Sem placeholder,
sem dica, sem chip. O vazio é intencional (o "ainda-não" do gesto).

- As **notas** anteriores ficam atrás de um gesto: botão discreto no topo-esquerdo.
- A home não é a lista. As notas não são o altar — reler cartões à noite é o anti-padrão.

## 4. Fluxo de notas (não encerra o ciclo do produto)

```
abrir app ──► página em branco ──► usuário escreve (traço livre)
                                        │
                          [botão Analisar — só quando chamado]
                                        │
              ┌──────────────┬──────────┴─────────┬──────────────┐
           gesto            aviso              pergunta        silêncio
        identificado     (recusa curta)      (uma, campo       (nada
              │                                 vazio)          aparece)
        "abrir forma"
              │
      campos VAZIOS nascem abaixo do texto do usuário
              │
      usuário preenche ──► "Concluída" ──► nota vai às notas
```

**Um gesto por sessão.** Se a Análise detecta segundo método na mesma nota → aviso.

## 5. A Análise (lógica de IA)

> ADR 2026-08-31e (decisão do dono): **IA real como padrão.** Revoga a proibição
> anterior de API. ADR 2026-08-31c (§17): gatilho automático na pausa.

- **Gatilho:** automático na pausa da escrita (debounce ~1.6s) + botão Analisar.
  Toque longo no botão liga/desliga o automático. Silêncio automático é invisível.
- **Motor padrão: xAI Grok** quando a conta do autor está ligada e há rede.
  Endpoint OpenAI-compatível, JSON estrito `{gesto, aviso|null, pergunta|null}`,
  temperatura 0, sem histórico (não é chat). **Silêncio em erro** — resposta fora
  do formato, sem rede, timeout: cai no motor local, nunca inventa.
- **Motor local é o fallback permanente:** sem conta, offline ou erro → as mesmas
  heurísticas de hoje. Sem conta ligada, o app é 100% local e gratuito.
- **Contrato de custo:** usar a assinatura autorizada, sem habilitar cobrança
  adicional por token. O cliente atual usa a conta Grok e guarda credenciais no
  Keychain. Um HTTP200 observado no passado não certifica quota, termos ou custo
  atuais do provedor; verificar a integração antes de prometer gratuidade ou
  consumo de um pool específico. Não há autorização inferida para cobrança extra.
- **Proibido:** chamada de rede SEM conta ligada pelo dono; qualquer cobrança por
  token (não existe caminho de chave de API no código); conteúdo de nota TRANCADA
  em qualquer chamada de rede (o selo vale para a rede).
- **ADR 2026-08-31j (lei do dono): SÓ A ASSINATURA.** Nunca pagar por token,
  nunca uso extra cobrado.
- **ADR 2026-08-31k: login por assinatura, chave de API REMOVIDA.** O caminho de
  `xai-…` no console foi apagado do código (Chave/ChaveView deletadas). Entra
  `ContaGrok`: device-code em `auth.x.ai/oauth2/device/code`, escopos
  `openid profile email offline_access api:access`, renovação automática, e
  `Bearer` nas chamadas. Cliente público da xAI (o do Grok CLI) — não há
  `registration_endpoint` para identidade própria; se a xAI publicar, troca-se a
  constante. Superfície sem doc pública → **fallback local obrigatório** em
  401/403/429. Sem conta, o app é 100% local.

### Avisos da Análise de notas (contrato local a migrar)
| Detecta | Aviso (essência) |
|---|---|
| Afirmação vazia ("eu sou rico/vencedor") | O que Wood, Perunovic e Lee (2009) mediram — humor depois de repetir uma frase dada, pior em quem estava com a autoestima baixa — e a pergunta pelo fato. Nunca uma sentença sobre o mundo (ADR 2026-09-06f). |
| Pedido de texto pronto | A recusa global foi revogada. Preservar a nota e encaminhar a produção ao Trabalho; não atribuir texto gerado ao autor. A migração das mensagens antigas ainda precisa de código e testes. |
| Pedido de ouvinte/consolo | Quem é a pessoa de verdade que deveria receber isto? |
| Plano sem obstáculo | Sem obstáculo interno, é fantasia — e fantasia reduz esforço (Oettingen). |
| Dois métodos na mesma nota | Um gesto por sessão. |

## 6. As formas (v1)

Templates do app. Nascem VAZIAS abaixo do texto do usuário. Uma forma por nota.

| Gesto | Roteado quando | Campos |
|---|---|---|
| **WOOP** | desejo/meta ("quero...") | Resultado · Obstáculo interno · Se [obstáculo], então eu |
| **Se–então** | hábito que trava num gatilho | Se (hora/lugar/obstáculo) · Então eu (substituto, não negação) |
| **Especificação** (interno: Spec) | algo a construir (software/projeto) | Problema · Pronto quando · O que eu NÃO vou fazer · Restrições · O que pode dar errado |
| **Nota permanente** | ideia/insight curto | Uma ideia nas suas palavras · Liga a · Fonte |
| **Destaque** | lista de tarefas / "hoje" | A única coisa de hoje, primeiro, até acabar |
| **Destilar** | texto que pede corte ("numa frase", "em 200") | Em 200 · Em 100 · Em 50 · Numa frase (tetos; aviso se estourar) |
| **Palavra** | uma palavra que o autor quer poder usar | Nas minhas palavras · Uma frase minha · Onde a encontrei |
| **Expressiva** | desabafo emocional longo | sem campos — vira o modo do §8 |
| **Decisão** (ADR p) | escolha entre caminhos ("decidir", "escolher entre") | O que estou decidindo · As opções · O que decide entre elas · Decidi · O que espero e quando confiro (vira aviso e deixa) · O que aconteceu |
| **Pré-mortem** (ADR p) | plano que quer imaginar a própria falha | O plano em uma frase · Um ano depois, falhou: o que aconteceu? · O primeiro sinal · O que eu mudo agora |

Domínio de vida (Trabalho, Casa, Saúde, Dinheiro, Pessoas, Estudo, Ideias) é
inferido no salvar, nunca arquivado à mão. Um toque no chip desfaz e trava a
inferência. Sem cor por domínio. ADR 2026-09-02c.

## 7. Recordar (retrieval)

Disponível na nota aberta e nas notas (segurar o cartão).

1. O conteúdo da nota some da tela.
2. O usuário escreve de memória o que estava lá.
3. **Revelar** → memória e nota lado a lado. Sem nota da IA, sem score — o olho compara.

Modos: Destilar esconde tudo e cobra a frase; Palavra mostra a definição e
esconde a palavra; Se–então mostra o Se e esconde o Então.

**Fila do dia** (ADR 2026-09-02d): uma notificação na hora que o autor escolhe
(padrão 8h), sem corpo da nota e sem contagem. Uma nota por tela. Silêncio
(Revelar) sobe a escada 3→7→21→60→180→365; "cobrar antes" volta ao 3.

É o único momento em que "esquecer dói" — e a dor é o treino (generation/testing effect).

## 8. Escrita expressiva (modo trancado)

Ao abrir a forma Expressiva:
1. Timer de **15 minutos** visível, discreto.
2. Instrução única: fato E sentimento, sobre o mesmo evento.
3. Ao fim do timer (ou ao sair, ou em Concluída ≥10 min) a nota **grava e sela**
   — e só então o app abre o **FECHO**, com a escolha. Selar primeiro é regra: o
   selo é garantia e não pode depender de o autor responder; matar o app no meio
   do fecho deixaria a nota aberta.
4. **O fecho oferece DOIS métodos validados, com objetivos diferentes** (ADR
   2026-08-31l — lei do dono: nada de método inventado; o app carrega os que já
   têm resultado comprovado):

   | Método | Origem | Objetivo | O que acontece |
   |---|---|---|---|
   | **Selar** | Pennebaker | O ganho vem da construção de sentido; reler à toa desfaz | O texto fica no aparelho, fora de tudo. Reabrir = dupla confirmação **+ Face ID** |
   | **Queimar** | Briñol e col., 2013 | Descartar o pensamento como objeto material reduz o poder dele | O texto é **destruído**. Sobram data, minutos e a linha de sentido |

5. **A linha de sentido** ("o que ficou claro?") vem ANTES da escolha, é escrita
   pelo AUTOR (a IA nunca a toca) e é **pulável** — obrigar depois de 15 minutos
   de peso é atrito na hora errada. Ela vive FORA do fecho: entra na busca, nos
   Padrões, no Recordar e no export. **É a única coisa que sai daqui** — a dor
   fecha, o sentido se multiplica.
6. **Queimar tem de ser verdade em todas as rotas**, senão é mentira: o texto
   sai da nota, o backup no Arquivos é regravado na hora, o índice do Spotlight
   é refeito, as versões e os apontamentos são apagados, a revisão é cancelada e
   **não há janela de desfazer** — não ter volta é o método. Teste por rota.
   Limite declarado (varredura 03/set): apagar é do MODELO, não da mídia. Zerar
   a string em Swift aloca outra, e o SwiftData grava em SQLite — o texto
   anterior pode sobreviver no WAL e em páginas livres até um vacuum. Nenhuma
   rota do app o alcança, e é isso que a promessa cobre. Garantia FÍSICA pediria
   chave por nota (queimar destrói a chave); fica na FILA, e até lá a frase é
   esta, não "sobrescrito".
7. Queimada NÃO abre: o app diz que não há o que abrir, em vez de calar.
   Na lista ela aparece como "Expressiva — queimada", com a linha de sentido e os
   minutos. Selada aparece com cadeado e título oculto.
8. A Análise nunca comenta o conteúdo de uma expressiva. Nunca.
9. **Série de quatro dias** (ADR 2026-09-02f): o fecho abre a série. No dia
   seguinte uma notificação sem conteúdo abre a página em Expressiva. No quarto
   fecho as quatro linhas de sentido aparecem juntas. Revoga a leitura de
   "sessão única" do ADR 31l — o método continua Pennebaker; o que muda é o
   número de sessões, não o método.

## 9. Padrões (padrões no tempo)

Botão nas notas ("Ler os padrões"). Só quando o usuário pede.

1. A IA lê as últimas ~12 notas não-trancadas.
2. Devolve **2–3 perguntas**, cada uma citando um fragmento literal das notas do usuário
   ("você escreveu ‘X’ três vezes este mês — o que fez diferente na vez que funcionou?").
3. Tocar numa pergunta → abre página nova com a pergunta em **cartão fixo não-editável**
   (nunca no texto da nota — ver §15). **O usuário responde na página vazia.**
4. Proibido: conclusões, diagnósticos, planos prontos, elogios, dashboards.

## 10. Modelo de dados

```swift
struct Nota {
  let id: UUID
  var texto: String
  var gesto: Gesto?        // nil = página nua
  var trancada: Bool       // expressiva pós-timer
  let criadaEm: Date
  var editadaEm: Date
  var sentido: String
  var dominio: Dominio?
  var gatilhoEm: Date?
  var serie: UUID?
  var diaDaSerie: Int
}
```
Persistência local (SwiftData/arquivo). Sem nuvem na v1. Sem conta do Traço.
O export (ADR 2026-09-02a) leva `id`, datas, `recordada`, `sentido`, `estado`,
`minutos` e o cabeçalho-contrato. Um `.md` por nota na pasta do app em Arquivos.
Import ignora `id`. Trancada e queimada saem só como metadado + sentido.

## 11. Design

- **Âncora de interação:** convenções nativas do iOS e familiaridade da escrita.
  Apple Notes é referência local, não fronteira de capacidades nem definição do Traço.
- **Cor (ADR 2026-09-02h — o mundo claro):** papel `#F4F4F2` · tinta `#1C1C1E`
  · secundário `#5F5F64` · linha `#1C1C1E` a 8% · acento âmbar `#D9A542` (como fill;
  como texto, `#7A5A16`) · aviso `#B5432F`. Um mundo só. Os hex do escuro ficam
  em `SISTEMA.md` como registro.
- **Tipo:** SF (sistema). Corpo 17/26. Labels 13 uppercase c/ tracking.
- **Espaço:** escala de 4. Raio 12.
- **Motion:** mínimo. A forma nasce com um fade curto (~250ms). Nada anima enquanto
  o usuário digita. `prefers-reduced-motion` respeitado.
- O editor mantém foco no documento, acesso a Notas e conclusão, com a régua
  de formas e ações pertinentes. A composição antiga de três botões não é uma
  proibição de controles necessários aos fluxos atuais; conferir implementação
  e estados reais contra SISTEMA-CLARO, sem reintroduzir um layout histórico.

## 12. Fronteiras atuais e decisões que não podem ser inferidas

Não construir recursos apenas porque um concorrente os oferece ou porque constam
num catálogo de pesquisa. Cada proposta precisa ligar-se à intenção, a um
obstáculo observado e a uma prova de realização ou desenvolvimento pertinente.
Não usar streaks, XP, elogio ou volume de notas como substitutos dessas provas;
não conduzir valores ou objetivos da pessoa de forma oculta.

A conversa contextual, resumo delegado e geração de artefatos não são proibidos.
Compartilhar/publicar ou executar externamente depende da delegação aplicável;
autorização de produzir um rascunho não autoriza automaticamente enviá-lo.

O cliente atual é iOS com interface pt-BR. Isso não proíbe um artefato em outro
idioma quando o objetivo o pede. HTML é formato de artefato previsto, não promessa
de cliente web pronto. Nuvem, sincronização contínua e execução geral externa
são capacidades ainda não demonstradas; decidir contratos antes de implementá-las.

## 13. Aceite da base de notas (insuficiente para concluir a visão)

- [ ] Abrir o app → página em branco com cursor em <1s
- [ ] "quero correr de manhã" + Analisar → chip WOOP + pergunta do obstáculo;
      "abrir forma" → campos vazios abaixo do meu texto
- [ ] "eu sou um vencedor" + Analisar → aviso Wood, sem forma
- [ ] Nota curta banal + Analisar → silêncio (nenhum cartão)
- [ ] Expressiva: timer 15 min → tranca → reabrir exige dupla confirmação
- [ ] Recordar: esconde, escrevo de memória, revela comparação lado a lado
- [ ] Padrões: 2–3 perguntas citando minhas frases; toque abre nota-resposta
- [ ] Escrita pessoal e prática preservadas; artefato delegado guarda origem,
      contexto e versão, sem se passar pelo autor
- [ ] "Dentista sexta às 14:30" → a ficha diz A QUE HORAS o aviso toca, e um
      toque muda a antecedência ou cala (ADR 04a)
- [ ] O próximo compromisso aparece no widget, na tela bloqueada e na Ilha —
      e sem sino quando o iPhone recusou o alarme

## 14. Casos-limite

Nota vazia + Analisar → nada (sem trabalho). Sem rede → o papel continua; a análise
local não precisa de rede. Sem chave de API → correto: **não existe chave**. Nota
gigante → classificar pela voz do autor; nunca truncar o texto persistido.

---

## 15. Decisões do loop de qualidade (protótipo, ago 2026)

Três críticos (hierarquia, motion, UX) em 3 rodadas — decisões que valem para o app Swift:

- **Classificador nunca lê o mobiliário do app**: remover marcadores de forma e labels
  (preservando as respostas do usuário) antes de classificar; com forma na nota, só o
  trecho pós-forma pode pedir outro gesto, e heurísticas de formato não contam.
- **Mesma forma → silêncio** (a análise não pune quem usou a forma que ele ofereceu).
- **A pergunta do padrões é cartão fixo não-editável** — nunca entra no texto da nota.
- **Expressiva sem escapatória digna**: sair durante o timer (qualquer rota, incluindo
  Recordar) → "Sair agora tranca." [Continuar escrevendo | Trancar e sair]; destino
  preservado após a tranca; beat de ~220ms entre confirmações.
- **Recordar**: desabilitado sem alvo (corpo vazio E campos sem o que recordar);
  voz só no Se / na frase conta; beat "Leia uma última vez — a nota vai se
  esconder." antes do blur; Revelar desabilitado até haver memória; saída "‹ voltar".
- **Copy**: sem citações acadêmicas na interface. Aviso de afirmação: "Afirmação vazia
  não muda nada — e pesa em quem se estima pouco. Escreva por que um valor seu importa."
  Reabrir trancada: "Reler o desabafo reacende o que a escrita encerrou." / "Ela foi
  escrita para ficar fechada." Silêncio da análise: toast "silêncio." ~2,5s (é resposta,
  não bug); durante o timer: "a análise cala durante a escrita."
- **Concluída** (texto, ≥44pt, oculto quando vazio) no lugar de ✓; "Notas" sem ☰;
  toda tela com rota de volta; alvos ≥44pt; página vazia SEM placeholder (decisão mantida).
- **Motion**: push/pop com parallax (curva drawer 0.32,0.72,0,1, ~400ms); sheet sobe
  opaco (nunca cross-fade de texto); cartão da análise é overlay (só transform/opacity,
  nasce da barra, transform-origin embaixo); confirmações materializam (blur+scale, exit mais
  rápido); staggers 45–70ms com teto; :active scale(0.94–0.98) em todo pressable;
  reduced-motion vira cross-fade; navegação interruptível com fila (nunca engolir toque).
- **Notas**: preview mostra só a voz do autor; trancadas com data relativa; padrões é
  botão discreto na topbar (as notas dominam a tela).
- Para o Swift: swipe-back nativo; "só o bloco novo borra" ao nascer a forma.

## 16. Busca (adição pós-protótipo)

Busca é **arquivo**, não memória: acha a nota para agir (GTD); lembrar continua sendo
trabalho do Recordar. Padrão Apple Notes (Jakob):

- Campo de busca nas notas + filtros por gesto em chips (WOOP, Se–então, Especificação,
  Nota permanente, Destaque, Trancadas). Toque alterna; um filtro por vez.
- Busca instantânea, local, sobre **a voz do autor** (labels/scaffold das formas não
  indexam — buscar "Resultado" não pode devolver toda nota WOOP).
- Resultado mostra o trecho onde bateu, com o termo em destaque âmbar; truncado em palavra.
- **Trancadas nunca expõem conteúdo**: não entram em busca por texto; só aparecem
  pelo chip "Trancadas". O selo vale também para o índice.
- Sem animação de stagger durante a filtragem (ação frequente não anima — Emil).
- Busca semântica/IA continua **não-objetivo** (v1): a busca acha, não interpreta.

Critério de aceite: buscar "celular" encontra a nota WOOP pelo trecho do obstáculo,
com realce; nota trancada não aparece; filtro WOOP mostra só WOOPs; limpar restaura tudo.

## 17. Assistência automática (a diretriz TDAH — lei de produto)

> Palavra do dono (31/ago): "Impossível eu aprender a usar todas as formas. A IA tem
> que cobrir todas as minhas incapacidades. Dificuldade no uso, ou exigir lembrar de
> alguma coisa para deixar bonito, quebra totalmente o meu uso."

**Princípio.** Reduzir esforço desnecessário de operação. O autor não precisa saber o nome de uma forma nem de
um método. O app organiza o apoio; quem escreve ou produz depende da divisão
de trabalho, e a origem permanece clara.

**A distinção de autoria no editor pessoal:**
- **Auto-FORMA: SIM.** A IA aplica forma automaticamente às palavras do autor —
  detecta lista e veste lista, detecta desabafo e veste o modo certo, detecta verso
  e veste verso. A representação precisa ser verificada na tarefa real. Nenhuma palavra é
  escrita, movida, resumida ou corrigida: a IA **veste** o texto, nunca o toca.
- **Prosa pessoal não se altera silenciosamente.** Produção delegada entra como
  artefato com origem própria; esta regra do editor não veta a IA no Trabalho.

**Consequências:**
1. O catálogo cresce quando uma representação resolve uma necessidade real;
   tamanho não é objetivo. A régua é atalho opcional, não uma lista a memorizar.
2. Métodos precisam de pertinência, origem e evidência de aplicação. O inventário
   de pesquisa não é fila automática de implementação. O roteamento pode propor
   apoio na pausa da escrita (ADR 2026-08-31c), com:
   - **um toque desfaz** qualquer aplicação automática (Soltar forma);
   - **silêncio continua válido** — na dúvida, a IA não veste nada;
   - opt-out por nota e global.
3. Automatizar organização reversível quando o contexto basta; preservar decisões
   que mudam intenção, divisão de trabalho ou consequência. Não abrir campos
   apenas porque um método existe, nem tratar a escolha da pessoa como defeito.
4. Acessibilidade cognitiva é critério de aceite: tornar o próximo passo
   reconhecível, explicar consequência e permitir recuperação. Não há teto
   universal de um passo; uma prévia útil antes de importar pode evitar erro.

**Fila que isto abre (P1):** motor de auto-forma local (heurística por bloco) →
auto-forma com IA real → roteador automático de métodos → confiança calibrada
(vestir só quando certeza; senão, silêncio).

## 18. Meu perfil
Um lugar só para conta e ajustes, alcançável do rodapé das Notas. Contém: estado
honesto da conta Grok em uma linha (conectada / expirada / sem rede / limite),
entrar e sair, e os ajustes que hoje só existiam em toque longo (análise
automática). Nada de chave, nada de preço, nada de medidor.

## 19. Divisão de responsabilidades: IA e código

A IA participa da compreensão da intenção, pesquisa, criação, planejamento,
produção e revisão delegados. O código preserva dados, referências, acesso,
permissões e transições válidas. Nenhum dos dois é infalível: os contratos exigem
verificação proporcional. Indisponibilidade do modelo deve preservar o trabalho
e informar a limitação; não simular equivalência entre heurística e produção.

### 19.1 Contratos da IA por superfície

| Superfície | Papel e fronteira | Verificação |
|---|---|---|
| Análise de notas | Classificar forma sem substituir a escrita pessoal | Enum e parser locais; preservar conteúdo e selo |
| Sábia / conversa em Notas | Informação, alternativas e perguntas no contexto permitido | Relevância, fonte e restrições; não fingir execução |
| Recordar / prática escolhida | Preparar apoio sem fabricar a tentativa da pessoa | Comparação ou demonstração pertinente ao objetivo |
| Padrões / Retrato | Observações e hipóteses corrigíveis | Atribuição, contexto, contestação; uso não prova capacidade |
| Trabalho | Produzir e revisar artefatos delegados, inclusive prosa/código/tradução | Critérios do pedido, material utilizável, origem, versões e salvamento |

A antiga proibição universal de escrever/resumir/traduzir foi revogada pela
ADR05g. Guardas de uma superfície específica não podem virar essa proibição
global, nem ser removidas em massa sem migrar seus contratos e consumidores.

### 19.2 Responsabilidade do código

Persistência e recuperação; parser/renderização; calendário e projeções;
referências entre intenção, artefato, ação e evidência; autorização e selo;
cancelamento e respostas obsoletas; importação/exportação; estados de UI.
Manter essas garantias operantes independentemente da resposta do modelo.
Algoritmos determinísticos também podem conter bugs e precisam de provas.

### 19.4 Escolha do mecanismo e evidência

Use código quando a regra é fechada; use IA onde interpretação, criação ou
adaptação forem necessárias. Não reduzir um requisito criativo a um rótulo fácil
de testar apenas para obter um passe. JSON válido, resposta não vazia e HTTP200
provam aspectos de transporte/formato, não qualidade do resultado.

Antes de aprovar uma produção, confronte as restrições explícitas e o resultado
utilizável. Uma revisão precisa mudar o que foi pedido sem copiar instruções
internas nem perpetuar erros da base. Limites do provedor entram como lacuna
real; não declare toda resposta gerada como realização ou aprendizagem.

### 19.3 Fronteira durável

O código protege o estado; a IA pode produzir e agir no escopo delegado;
a pessoa conserva direção, autoria da própria participação e correção do modelo
que a aplicação mantém sobre ela.

## 20. Navegação (sistema, ago/2026)

**Auditoria que motivou (Fase 5 do roteador):** os destinos moravam no topo
(`fitts-law` — zona morta do polegar), e perfil/exportar/importar flutuavam
soltos no rodapé das Notas com peso igual (`law-of-common-region`,
`law-of-proximity`), com navegação e ação vestidas iguais (`law-of-similarity`)
e sem affordance de toque (`critique-affordance`). iOS tem padrão universal para
destino — barra inferior (`jakobs-law`); links de texto no meio da tela o quebram.

**Decisão (rev. 2, correção do dono): escrever NÃO é uma aba — é a casa.**
Barra inferior só existe no ARQUIVO; na escrita não há chrome nenhum (§3).

```
[ Notas · Calendário · Padrões · Perfil ]  ←→  [ ESCREVER ]
        com barra                   sem nada
```

| Destino | Ícone | O que é |
|---|---|---|
| Notas | `rectangle.stack` | arquivo, busca e filtros |
| Calendário | `calendar` | uma escala (D/W/M/Y); o dia âncora não salta |
| Padrões | `circle.hexagongrid` | perguntas sobre o que se repete |
| Perfil | `person.crop.circle` | conta e ajustes |

**O trânsito é gesto, não botão:** da escrita, arrastar a partir da borda
ESQUERDA traz o arquivo; do arquivo, arrastar a partir da borda DIREITA para a
esquerda devolve a escrita. Arrasto 1:1, mola herdando a velocidade do dedo
(apple-design §2/§5/§6). O gesto nasce nos 28pt da borda — nunca rouba a seleção
de texto — e por isso vive mesmo com o teclado de pé (matá-lo criava atrito
depois de concluir uma nota). Um puxador de 3×36pt na borda esquerda dá
descobribilidade sem ocupar a tela; some com o teclado.

`hicks-law`: quatro destinos no arquivo, não cinco. A casa não se escolhe — volta-se para ela. O quarto destino é o calendário (ADR 2026-09-02g): o dono pediu o clone, não um atalho de agenda.

**A barra carrega UMA ação: "Nova".** Começar uma nota não é destino, é ato — por
isso tem forma própria (pílula âmbar cheia, sem estado de seleção) e **lidera** a
barra, separada dos destinos por um fio (`law-of-common-region`). No fim da barra
ela roubava o olho do último destino e lia como um quarto item torto. O ícone
duplicado no topo das Notas foi removido: a mesma ação em dois lugares é ruído.

**Layout (o erro que custou três tentativas):** a escrita fica PARADA no fundo e
só o arquivo desliza sobre ela. Trilho de duas páginas (HStack deslocado) e ZStack
com offset nos DOIS filhos realimentam o layout do SwiftUI e entregam o arquivo
com ~72% da largura — com a escrita vazando numa faixa preta à direita. A largura
é medida por um `GeometryReader` no `background`, fora do fluxo que dimensiona os
filhos. E a barra é chrome da CASCA, não da camada: dentro do trilho, o
`ignoresSafeArea` do material era cortado junto.

**Tokens (fixos antes de desenhar):** altura `Tema.barraNav` = 52pt + safe area · ícone 21pt ·
rótulo `.caption2` com tracking 0.4 · ativo = âmbar, inativo = tintaFraca ·
fundo `.ultraThinMaterial` sobre o fundo do tema, hairline de 0.5 no topo ·
alvo mínimo 44pt por item · troca de aba em cross-fade de 0.18s (aba não tem
direção espacial: slide seria mentira).

**Regra que salva o §3:** na escrita não há barra nenhuma; no arquivo, ela
recolhe quando o teclado sobe. O encaixe (`safeAreaInset` de `Tema.barraNav`) é
sistêmico na raiz: nenhuma tela precisa saber que a barra existe, e nada do
conteúdo morre atrás dela.

**Trocar de tela SALVA.** Todo trânsito passa por `Sessao.irPara(_:no:)`, que
grava antes de sair — navegar nunca custa uma palavra do autor. Com o timer da
expressiva rodando, a saída pede confirmação: o selo vale também aqui.

**Consequência:** ações de dados (exportar, importar) saem do rodapé das Notas e
vão para o Perfil, onde pertencem — navegação e ação deixam de se parecer.

## 21. Leis de movimento (aprendidas a duras penas, ago/2026)

Quatro rodadas de crítica em VÍDEO REAL, medindo deslocamento quadro a quadro.
As três primeiras foram reprovadas. O que ficou:

**Um objeto, um driver.** Se duas partes da mesma tela chegam em offsets
diferentes, ela chega "em dois pedaços" — e nenhum app caro faz isso. Medida de
aceite: o deslocamento por faixa horizontal tem de ser IGUAL em todos os quadros
da transição. Causas que já pegamos: o teclado descendo junto com o deslize
(mudava o encaixe no meio do movimento — agora ele sai no INÍCIO do gesto) e a
troca de aba animando durante o deslize (agora só anima com a camada parada).

**Nada de cross-fade entre irmãos que ocupam as mesmas linhas.** Duas barras
dissolvendo uma na outra deixam as DUAS legíveis por um quadro inteiro — lê como
erro de render. Um sai, o outro entra; quem anima é a ALTURA do container.
Medida de aceite: nenhum quadro com dois textos de barras diferentes legíveis na
mesma linha de base.

**Uma posição, uma fonte de verdade.** Duas variáveis para a mesma posição
(deslocamento + estado booleano) mudadas no mesmo instante cravam o valor final
em vez de persegui-lo. Pior: animar a posição e DEPOIS mudar o estado dispara um
segundo `onChange` que re-anima a MESMA posição — dois alvos no mesmo voo, e a
mola *acelera* na chegada. Mola não acelera na chegada. Nunca.

**Camada que desliza precisa de profundidade.** Sem sombra na borda nem
escurecimento do que fica atrás, "deslizar por cima" lê como conteúdo sendo
apagado, não como camada.

**Nada de estado escrito durante a animação.** `onChange` não roda por quadro de
animação — roda em mudança de estado. Derivar um valor da posição por `onChange`
e escrevê-lo num `@State` de outra view invalida a árvore no meio do voo e
atropela a própria mola: os passos saem 35 · 62 · 25 · 37 · 35 · 22 · 45 · **0** ·
69 px, que não é integração de mola nenhuma. Valor derivado se lê no `body`, do
mesmo valor animado, como MODIFICADOR animável — o SwiftUI interpola os dois
juntos. E mudar estado pesado (gravar no SwiftData, trocar de aba) no mesmo
instante em que a animação começa mata a animação: o estado vira no quadro
seguinte, com o movimento já em curso.

**Estado de seleção não se dissolve.** Uma aba acesa é ESTADO, não transição.
Com fade, sobram quadros sem nenhuma aba selecionada.

**Chrome de uma camada mora DENTRO dela.** A barra que ficava fora andava 34px
enquanto o corpo andava 233px, e não era recortada pela borda.

**Build incremental pode linkar código de arquivo deletado.** Em 31/ago o app
rodou horas com uma tela FANTASMA (um catálogo "Todas", de um arquivo que não
existe em disco nem nunca esteve no git) porque o objeto velho continuava sendo
linkado. Ao ver comportamento que o código não explica, **build limpo ANTES de
investigar** — não depois de três hipóteses erradas.

**O sistema é a régua.** No mesmo vídeo há animações do iOS (teclado, folha
modal). Elas desaceleram monotonicamente, com cauda longa. Se a do app não se
parece com aquilo, é a do app que está errada.

## 22. Corpo de texto e Dynamic Type — FECHADO (02/set)

Era defeito aberto: a entrelinha do editor crescia com o corpo do sistema e a
LETRA não, porque todo o `Tema` era `.system(size:)` — ponto fixo. Quem precisa
de letra grande recebia a mesma letra pequena com vãos enormes.

Decisão tomada: a **saída 2** — escalar o CONTEÚDO e travar o CHROME, que é o que
Notes e Bear fazem. Todo token do `Tema` passou a estilo de texto (`.title`,
`.title3`, `.body`, `.subheadline`, `.caption2`), que escala. Sobraram três
tamanhos fixos, todos em chrome de navegação (a barra inferior e uma etiqueta de
9pt nos Padrões): a régua de 12 chips e a barra não podem virar outra coisa em
corpos grandes.

Medida de aceite: o cartão da análise, os campos da forma, a lista de notas e o
texto do autor crescem de `medium` a `accessibility-extra-extra-extra-large`.

## Como ler o histórico de ADRs

As ADRs abaixo registram a decisão de sua data. Afirmações históricas de veto
universal à geração, chat, resumo ou tradução foram substituídas pela ADR05g
e pelas seções 1, 2, 12 e 19 atuais. Restrições de privacidade, escrita pessoal
e prática continuam no escopo próprio. Datas, passes e capturas antigos não
comprovam o candidato atual. Consulte EVOLUCAO para provas e pendências.

## ADR 2026-09-01a — "Spec" vira "Especificação" na UI

Era o único nome de método em inglês entre cinco em português — jargão de
programador num app de escrever; o autor de primeira viagem não o entende.
Muda só a exibição (`Gesto.nome`): o rawValue segue "Spec" e `doNome` aceita
as duas grafias, então o corpus já exportado importa sem perder o gesto.

## ADR 2026-09-02a — Segundo cérebro: export completo e "Como contexto"

§12 proibia "Compartilhamento". Continua proibido compartilhar com pessoas.
Entregar a própria nota à própria IA pela folha do sistema é export — e export
é algoritmo desde o §19.2. Toda rota nova passa no teste do selo: WOOP aberta
sai inteira; selada e queimada saem só como cabeçalho + `sentido`; expressiva
em curso não sai; `traco://` nunca sai.

O arquivo ganha um cabeçalho fixo (contrato para qualquer IA), `id`, `criada`,
`editada`, `recordada`, e um `.md` por nota em Documents/Arquivos. Import
ignora `id`. Sem servidor, sem conta do Traço.

## ADR 2026-09-02b — Destilar e Palavra entram no §6

Duas formas que treinam Linguagem. Destilar corta (200 / 100 / 50 / uma frase)
com teto visível. Palavra pede a definição nas palavras do autor, uma frase
sua e a fonte. Look Up é o do iOS no texto seleccionado — a casa não ganha
botão (§20). A IA só roteia o rótulo; nunca resume, nunca define. Recordar destas formas é invertido:
Destilar esconde tudo; Palavra mostra a definição e esconde a palavra.

## ADR 2026-09-02c — Domínio inferido, nunca arquivado

Ordem sem bibliotecário. Sete rótulos fechados, léxico local, um toque desfaz
e trava. Sem cor por domínio. Não é pasta, não é tag, não é arquivo à mão.

## ADR 2026-09-02d — Fila do dia e escada que responde

§7 ganhava uma revisão a 3 dias, por nota. Isso vira ritual: uma notificação
diária na hora do autor, fila das vencidas, uma nota por tela, sem contagem.
Escada 3→7→21→60→180→365. Revelar (silêncio) avança; "cobrar antes" volta ao 3.

## ADR 2026-09-02e — Aviso do Se, âncoras, Destaque na tela bloqueada

§12 proibia agenda. Um aviso com o título da nota, disparado pela hora ou
pelo período escrito no "Se", não é calendário: não cria evento, não sincroniza,
não tem recorrência. Três âncoras (8 / 14 / 21, ajustáveis no Perfil) no lugar
de streak. O Destaque do dia — uma linha do autor — vai à tela bloqueada
(`accessoryRectangular` / `inline`) via App Group. Nunca expressiva, nunca
trancada.

## ADR 2026-09-02f — Expressiva em série de quatro dias

ADR 31l carregou os métodos validados (Pennebaker, Briñol). A série não inventa
método: são quatro sessões do mesmo, com notificação sem conteúdo abrindo a
página. No quarto fecho as quatro linhas de sentido ficam visíveis juntas.
O selo de cada dia vale sozinho.

## ADR 2026-09-02g — Calendário local, uma escala

§12 proibia agenda-como-produto (EventKit, sync, recorrência de sistema). O
calendário que o dono pediu não é isso: é uma tela do arquivo, eventos no
aparelho (`calendario.json`), criados em prosa local — a IA nunca escreve o
evento. D / W / M / Y são zooms do mesmo dia. O aviso do Se continua a não ser
este calendário. Sem nuvem, sem EventKit, sem escrever na nota.

## ADR 2026-09-02h — O mundo claro

§11 dizia tema escuro único. O dono viu o calendário claro (clone do MovinDesign) e decidiu: o Traço inteiro vive no mundo claro, um mundo só, nunca claro numa aba e escuro noutra. Os hex e as medidas são os de `SISTEMA-CLARO.md`; `Tema.swift` os cita. O preto (carvão) é o acento de estado; o âmbar é assinatura de ação, como fill, uma vez por tela; como texto usa `ambarTinta`. Todo texto ≥4,5:1 sobre o papel, ícone ≥3:1. A pressão só escala. `SISTEMA.md` fica como registro do escuro.

## ADR 2026-09-02i — O calendário das intenções e a consulta em prosa

Emenda à ADR g. O calendário lê as notas abertas cujo "Se" tem hora e as mostra como deixas em papel com contorno, nas quatro escalas e na lista; tocar abre a nota. A deixa não vai ao disco do calendário: a nota é a dona. Expressiva e fechada nunca entram. O campo de prosa também responde a pergunta ("o que tenho sexta?", "semana que vem") indo até o dia ou o período, por algoritmo; não há chat, e o app não escreve uma palavra.

## ADR 2026-09-02j — App Intents que devolvem texto

Emenda ao §10 e ao §19.1. Além de abrir o app, os intents devolvem texto a Atalhos, Siri e ao botão de Ação: Destaque de hoje, Meu dia (compromissos), Linhas de sentido, Como contexto (o corpus, opcionalmente por forma). O selo é o do export: expressiva em curso nunca sai; selada e queimada só como metadado e linha de sentido. A rota lê o disco por conta própria e nunca escreve.

## ADR 2026-09-02k — A lente da língua

Emenda ao §6 e ao §19.2, a metade algorítmica do Apontar (Edda, iA Writer, Vocabulary). Um botão "Lente" na página abre uma folha que conta muletas, frases feitas, passivas, advérbios e adjetivos repetidos, por léxico e etiquetador locais, offline. Só aponta; nunca reescreve nem sugere substituto. O Apontar manual (marcar trecho com rótulo) fica para depois da lista fechada do §2.

## ADR 2026-09-02l — O Destaque vivo

Emenda à ADR e. A linha do Destaque também vira Live Activity na tela bloqueada e na Ilha, enquanto o dia dura; termina à meia-noite ou quando a nota deixa de ser o Destaque. Uma linha do autor, nunca expressiva, nunca trancada.

## ADR 2026-09-02m — Versões da nota

Emenda ao §10 (Drafts, Obsidian). Cada gravação que muda o texto guarda a versão anterior num arquivo por nota em Documents/Traço/versoes, até trinta. "Versões" no menu da nota lista e restaura; restaurar guarda a atual antes. A expressiva nunca tem versão, e queimar ou apagar a nota apaga as versões: o que se destrói não sobrevive em cópia. Apontar (ADR k) guarda os trechos marcados ao lado, em Documents/Traço/apontamentos, com as mesmas regras.

## ADR 2026-09-02n — A pasta no iCloud Drive do autor, e o companheiro no Mac

Resolve o "§12 sync/nuvem × iCloud Drive do autor" da colheita. Sem servidor e sem conta do Traço, sempre. O autor pode escolher, pelo seletor do sistema, uma pasta sua (iCloud Drive ou qualquer provedor do app Arquivos); o Traço grava ali a mesma pasta do segundo cérebro que grava em Documents, a cada nota concluída. Só escreve, nunca lê de volta, nunca sincroniza; o selo é o do export. Sem entitlement de iCloud, sem conta de desenvolvedor. Na pasta do autor o Traço só apaga o que este aparelho escreveu (manifesto ao lado): um .md do autor, ou de outro iPhone na mesma pasta, fica; parar de espelhar tira a cópia deste aparelho. No Mac, `ferramentas/traco-mcp/servidor.py` é um servidor MCP só de leitura sobre essa pasta, sem dependências, para Claude, ChatGPT ou Cursor lerem o corpus.

## ADR 2026-09-02o — A fronteira pelo efeito: forma, informação e pergunta, nunca a resposta do autor

**Palavra do dono (02/set):** "precisamos definir o que é dívida cognitiva e o que não for, a IA pode atuar. Se restringir o campo do calendário em que eu marco datas, é erro. Na spec, a IA tem que me ajudar como uma pessoa muito sábia: instiga, pergunta, e eu construo enquanto aprendo. Se eu deixar uma pergunta clara na nota, ela responde."

**O que muda.** O §2 proibia pelo MECANISMO ("nunca insere texto"). Passa a proibir pelo EFEITO: a IA nunca faz o trabalho que constrói a mente do autor. Dívida cognitiva é substituir o ato de formular, decidir, lembrar, escolher a palavra ou sentir. Tudo o que não for isso é serviço, e serviço multiplica.

**A fronteira, em uma frase:** a IA pode dar forma, dar informação e dar pergunta; nunca dar a resposta do autor.

**O que fica de ferro.** Redigir, completar, reescrever, resumir o que o autor devia digerir, responder o que o Recordar cobra, escrever a linha de sentido, comentar a expressiva, elogiar, medir. Nada da IA entra na nota por conta própria.

**O que passa a ser permitido, e por onde:**
1. **Transcrever e traduzir forma.** Áudio em texto, "dentista sexta 14h" em compromisso, uma frase em data. É serviço. (Ditar já existe: o microfone do teclado do iPhone, no aparelho.)
2. **Vestir tudo.** Dar forma a um texto inteiro (uma spec longa, um .md importado) sem tocar numa palavra. Motor local primeiro (`Caderno.estruturar`); a IA, quando ligada, devolve só um MAPA de rótulos por parágrafo (título, lista, tabela, citação, código, prosa) e o app aplica. Um toque desfaz.
3. **A linha "?".** Uma linha da nota que começa com "?" é uma pergunta do autor à sábia. A resposta chega num CARTÃO ao lado da página, nunca dentro da nota; o autor lê e escreve com as suas palavras. A pergunta é dele, logo a resposta não é dívida. Copiar para a nota é gesto explícito do autor.
4. **Instigar.** Numa forma que constrói pensamento (Especificação, Nota permanente, WOOP, Decisão, Pré-mortem), a IA pode devolver PERGUNTAS e buracos ("isso depende de quê?", "e quando falhar?", "este termo tem dois sentidos aqui"). Nunca preenche o buraco. Só a pedido, no botão "Instigar" da Lente; nunca sozinha na pausa.

**O selo continua inteiro.** Expressiva (em curso ou fechada) e trancada jamais vão à rede, nem por "?", nem por vestir, nem por instigar. Sem conta ligada, nada disto chama modelo: o "?" e o "Instigar" dizem que precisam da conta.

**Contrato remoto.** Além de `{gesto, aviso}` (§19.4), entram três chamadas com verificação dura: `vestir` devolve JSON `[{i, forma}]` com forma de lista fechada e índices que existem; `responder` devolve texto livre para o cartão, com teto de tamanho; `instigar` devolve `[pergunta]`, cada uma terminando em "?", no máximo cinco. Texto fora do formato = silêncio.

## ADR 2026-09-02p — Decisão e Pré-mortem entram no §6

Palavra do dono (02/set): organização e estratégia são ofícios da mente e não ficam de fora. Duas formas com método validado, ambas algoritmo (template, campos, roteamento local): **Decisão** (diário de decisão: o que decido, as opções, o critério, o decidido, o que espero e quando confiro — para comparar depois com o que aconteceu, contra a memória que reescreve) e **Pré-mortem** (Gary Klein, 2007: imaginar que o plano já falhou e explicar por quê, antes de executar). A sábia (ADR o) instiga nas duas; nunca decide nem preenche.

## ADR 2026-09-02q — A revisão da semana

Emenda ao §9 (Padrões). Organização é ofício da mente (dono, 02/set): no topo dos Padrões, um cartão "Esta semana", todo algoritmo, sem rede: quantas notas por forma nos últimos sete dias, os Destaques escolhidos, as decisões com data de conferir por vir, os desejos WOOP com obstáculo nomeado, as deixas e compromissos dos próximos sete dias, e as linhas de sentido das expressivas fechadas na semana (só o sentido, nunca o texto). Cada linha abre a nota. Nada é comentado, contado como mérito nem comparado com semanas anteriores.

## ADR 2026-09-03a — Calibração: o que eu esperava, e o que aconteceu

Emenda à ADR p. O diário de decisão só vale se a previsão sobreviver ao resultado: depois de saber o fim, a memória reescreve o que se esperava (hindsight). Por isso a Decisão ganha um campo de VOLTA, "O que aconteceu", que só aparece quando é devido — se o autor marcou quando confere, o campo espera essa hora; sem data marcada, ele fica desde o início, porque o app não adivinha. Na revisão da semana, "Decisões conferidas" mostra escolha, esperava e aconteceu, lado a lado, e cada linha abre a nota. Não há nota, placar, acerto nem comparação entre semanas: só a evidência que o papel guardou. O mesmo texto sai no intent "Esta semana" e no MCP.

## ADR 2026-09-03b — A rede das notas

O valor de um caderno não está nas notas, está nas ligações entre elas (Luhmann). Até aqui o campo "Liga a" era texto morto e uma nota que citava outra não sabia disso. Agora: `[[assim]]` no texto e cada linha do campo "Liga a" viram ligação quando casam com o título de outra nota (sem acento, sem caixa; o começo do título basta a partir de quatro letras). "Ligações", no menu da nota, mostra quem ela cita e — o que ninguém vê sem isto — quem cita ela; cada linha abre a nota. Na leitura os colchetes somem e a menção fica sublinhada: sintaxe não se lê. Algoritmo puro, offline: a IA não sugere ligação nenhuma, porque ligar é ato de pensamento. O selo vale inteiro — expressiva (em curso ou fechada) e trancada não entram na rede, nem como origem nem como destino. Nota que ninguém cita e que não cita ninguém é ilha, e ilha não é defeito.

## ADR 2026-09-03c — Ler os calendários do aparelho, e o campo que sugere

Palavra do dono (03/set): *"isso aqui tem que ser dinâmico… a gente comprou
ingressos de algum show de stand-up, marcou alguma coisa, ele tenta de alguma
forma entender: já aparecia a recomendação ali"* — e, em seguida: *"conectar os
meus calendários do Google e da Apple… podem trazer algumas informações
importantes"*.

**O que muda.** A ADR g dizia "sem nuvem, sem EventKit"; o §12 lista sync como
não-objetivo. O "sem nuvem" fica de pé inteiro. O "sem EventKit" cai: ler o
calendário do sistema é local, no aparelho, sem servidor, sem conta do Traço e
sem uma linha de rede. É a mesma natureza do Spotlight e dos Atalhos, que já
entraram sem ferir nada.

**Uma integração cobre as duas contas.** O EventKit lê TODOS os calendários
configurados no iPhone — Apple, Google, iCloud, Exchange, qualquer assinado.
Não há OAuth, não há cliente no Google Cloud, não há segunda conta. Se um dia
o Google do autor não estiver no aparelho, a resposta é configurá-lo lá, não
construir um segundo sistema de login aqui.

**Só leitura, sempre.** O Traço nunca escreve na agenda do autor, nunca
sincroniza, nunca apaga. `calendario.json` continua sendo o dono do que se
marca AQUI; o que vem do sistema é contexto, não conteúdo.

**O que eles fazem.** Alimentam a RECOMENDAÇÃO do campo (janela de sete dias)
e aparecem na GRADE (janela da escala visível). Não viram deixa, não vão ao
`calendario.json`, não saem no export nem no corpus, não se editam e não se
apagam: `EventoCalendario.doSistema` os marca, e `editavel` é o portão que
`guardar`, `apagar` e `avisar` consultam. Tocar num deles abre uma ficha só de
leitura, com uma saída para o app Calendário — que é o dono.

**A recomendação, e por que ela não mente.** A sugestão é escrita na LÍNGUA DO
CAMPO — a mesma frase que o autor teclaria ("Stand-up do Rafinha depois de
amanhã 21h"). Tocar o campo a preenche e daí em diante quem lê é
`CalendarioFrase`, como sempre: nenhum caminho novo de dados, nenhum parser
novo. E ela só aparece se sobreviver à IDA E VOLTA — montamos a frase, o parser
a lê, e o dia, a hora e o título têm de voltar iguais. Título com dia da semana
ou hora solta dentro ("Corrida 5h da manhã") faz o parser comer a palavra
errada; aí a sugestão é descartada em silêncio em vez de marcar errado. Janela
de sete dias: dica apontando para três meses adiante é ruído.

**Isto não é IA.** É §19.2 inteiro: tabela, regex e relógio. Nada vai à rede,
nada depende de conta, e o app segue igual se o autor negar o acesso — o campo
volta ao exemplo. A permissão é pedida uma vez, com o autor olhando um
calendário, nunca no arranque (§3).

## ADR 2026-09-03d — O que se marca, avisa

Varredura funcional de 03/set: o maior buraco do app era que marcar "dentista
sexta às 14h" no calendário do Traço **não fazia nada na sexta às 14h**. Só o
"Se" de uma nota disparava alarme; o calendário, que é onde se marca
compromisso, era mudo — o que derruba o propósito de marcar.

Agora todo compromisso do Traço agenda o próprio aviso, na hora dele. Série
vira uma notificação semanal por dia da semana, repetindo: o sistema cobra
sozinho, sem o app reagendar toda semana. Dia inteiro avisa na âncora da manhã
do autor, não à meia-noite. Apagar o compromisso mata o aviso — alarme de coisa
apagada é a pior mentira que um calendário conta.

Namespace próprio (`compromisso-<id>`): o id de um evento e o uuid de uma nota
são os dois UUID, e um cancelar não pode alcançar o aviso do outro.

Deixa de nota não passa por aqui: a nota é a dona dela e já tem o seu gatilho.

## ADR 2026-09-03e — Nenhuma permissão negada é um beco

Três lugares decidiam para sempre num toque, e a lei do dono é que atrito é
bug — beco sem saída é pior que atrito:

1. **Permissão.** `pedirAcesso` só agia em `notDetermined`: quem negasse o
   calendário nunca mais via a sugestão e o app não dizia por quê. O Perfil
   ganha ESTADO (calendários e avisos, em uma linha honesta cada) e a única
   volta que o iOS permite, que é abrir os Ajustes do app.
2. **Domínio.** A ADR c dizia "um toque desfaz e trava" e não previu que não
   havia segundo toque. `devolverDominio` destrava e roda o léxico na hora.
3. **Série da expressiva.** Só o fecho agendava o dia seguinte; quem ignorasse
   a notificação do dia 2 nunca mais ouvia falar dela. No arranque, toda série
   viva que perdeu o aviso reagenda. O método é de quatro sessões.

E no Recordar, duas saídas que faltavam: **"hoje não"** empurra para amanhã sem
mexer na escada (adiar não é falhar nem acertar — é a hora errada), e **"pular"**
passa à próxima da fila sem revelar, porque revelar sobe o degrau e não havia
como pular sem mentir para a própria escada.

## ADR 2026-09-03f — Um idioma só, e é o português

A varredura funcional achou o maior item da lista: o String Catalog tinha 77
chaves traduzidas para inglês, e o app tinha **177 literais de interface**. Com
o iPhone em inglês via-se "Notes" ao lado de "Buscar nas notas" — uma tela
costurada, que é pior do que uma tela só em português.

A saída não é traduzir as outras 151. É reconhecer o que o app é: **todo motor
dele fala português e só português.**

- a Análise roteia por quinze regex em pt ("escreva por mim", "eu sou rico")
- o calendário lê "dentista sexta às 14h" — e nada em inglês
- a Lente conta muletas de um léxico pt ("basicamente", "na verdade")
- o Domínio infere por palavras pt ("reunião", "boleto")
- o Ditado é `pt_BR`, no aparelho
- os Feriados são nacionais, de Goiás e de Goiânia

Interface em inglês sobre esses motores é promessa falsa: quem escrevesse
"dentist friday 2pm" não marcaria nada, "I want to run" não abriria WOOP, e a
Lente não acharia uma muleta sequer. O `en` sai do catálogo e o
`developmentLanguage` fica `pt`, sozinho.

Isto não fecha a porta: internacionalizar o Traço de verdade é traduzir os
MOTORES, não os rótulos — e aí é outro projeto, com outra spec.

## ADR 2026-09-03g — A pergunta e a forma cabem no mesmo cartão

A palavra do dono sobre a sábia (§ADR o) é incondicional: *"se eu deixar uma
pergunta clara na nota, ela responde."* Hoje isso foi quebrado duas vezes, em
direções opostas, e a varredura pegou a segunda.

**Como estava (precedência absoluta do "?").** A linha "?" vencia antes da
classificação. Uma pergunta no meio de uma especificação bloqueava a forma
**para sempre**: o autor não tinha como perguntar e ainda receber o gesto.

**Como ficou de manhã (o "?" no ramo do silêncio).** A forma passou a vir
primeiro, e o "?" só ocupava o rodapé quando não havia gesto a vestir. O
fluxo `pergunta-sabia` caiu: a nota classificou como Especificação, o cartão
da forma tomou o rodapé, e a pergunta do autor ficou **inalcançável** — sem
sequer um sinal de que estava lá.

**A decisão.** Nenhum dos dois manda. As duas coisas cabem no mesmo cartão:

- a **forma** manda na identidade do cartão (chip, trilho, texto, ação alta) —
  é o que a análise achou, e é o funil principal;
- a **pergunta** vive embaixo, discreta (`CompactoStyle`, tinta suave), e está
  sempre a um toque enquanto existir uma linha "?" na nota.

Custo: um `@ViewBuilder` de seis linhas em `CartaoAnaliseView`, reusando o
botão e o `perguntarASabia()` que já existiam. Nenhum caminho de dados novo.

E não vira beco (ADR 03e): perguntar troca o cartão pela resposta, "Fechar"
devolve o rodapé, e a próxima análise traz a forma de volta.

## ADR 2026-09-03h — A sábia estava subaproveitada

Auditoria das cinco superfícies de IA (`AnaliseRemota.classificar`,
`Sabia.vestir`, `Sabia.responder`, `Sabia.instigar`, `PadroesRemoto`). A
**arquitetura** está certa e é rara: contrato fechado em todas, verificação
dura em todas (rótulo fora da lista, chave extra ou texto livre invalidam a
resposta inteira), silêncio em falha, selo cortando expressiva e trancada
antes da rede. A IA nunca escreve na nota porque o código não tem caminho
para isso — não porque o prompt pede.

O **uso** estava tímido em três pontos. Os três fechados:

**1. A sábia lia só a página aberta.** `responder` recebia
`Caderno.prosa(de: texto)` e nada mais, enquanto o caderno tinha a Rede
inteira calculada ao lado. Agora vão junto as notas que o autor **ligou de
próprio punho** com `[[…]]` — no máximo três, 1200 caracteres cada.

O que decide o limite não é privacidade abstrata, é o ato do autor: ligar é
explícito, e perguntar também. O selo continua absoluto — o filtro é o
`Rede.podeLigar` que já existia (expressiva em curso ou fechada, trancada,
queimada), reusado, nunca reescrito. E o cartão da resposta **diz quais notas
foram junto**: quem manda texto à rede tem de ver o quê.

**2. A instigação, que é a tese, tinha um único ponto de chamada** — um botão
dentro da Lente. O orçamento automático ia todo para roteamento de gesto, que
a heurística local já faz bem o bastante para ser o fallback, e zero para
*"instiga, pergunta, e eu construo enquanto aprendo"*. Agora `instigar`
dispara ao **abrir a forma**: ato explícito, uma vez por nota (não a cada
pausa), e é onde a pergunta vale.

**3. A pergunta da forma era uma de nove strings fixas — e no caminho comum
nem aparecia.** `parseVeredito` devolvia sempre `AnaliseLocal.pergunta(gesto)`,
e `CartaoAnaliseView` fazia `case .vestida(let gesto, _)`: **descartava** o
valor. No caminho §17.3 (gatilho explícito → forma já vestida), que é o comum,
o autor abria a forma sem ouvir pergunta nenhuma. Agora o cartão mostra a da
sábia quando ela chega, e a do template segura o lugar até lá.

Custo: nenhum motor novo, nenhum prompt novo, nenhuma chamada nova — as três
reusam `Sabia.instigar`, `Sabia.responder` e `Rede.ligacoes` como estavam.

## ADR 2026-09-03i — A sábia toma a prova

O Recordar é a superfície mais repetida do Traço: toda nota volta, muitas
vezes, para sempre. Era também a **única sem IA nenhuma** — a pergunta era uma
de cinco frases fixas ("O que estava escrito?"), a mesma para toda nota do
caderno até o fim dos tempos.

E "O que estava escrito?" é o pior prompt de recuperação possível: pede
transcrição, não reconstrução. A prática de recuperação (Roediger & Karpicke)
funciona quando a pista obriga a reconstruir o miolo — e miolo é coisa que só
quem entende o conteúdo sabe apontar.

**A decisão.** A sábia toma a prova, em duas partes, cada uma com a
verificação que a torna segura:

**A pergunta.** Uma só, sobre ESTA nota, com no máximo 120 caracteres. O
contrato exige que termine em "?", e o algoritmo recusa a que VAZAR:
`Prova.vaza` reprova qualquer pergunta que repita quatro palavras seguidas do
alvo (e, para alvo curto — a Palavra, um Então de uma linha —, que contenha o
alvo). Recusada, o ritual segue com a frase fixa; o autor nunca sabe que houve
tentativa. A rede não segura o ritmo: a pergunta vem numa `task` própria, e se
chegar tarde o autor já está escrevendo.

**A conferência.** É o contrato mais fechado do app: a resposta é uma lista de
**NÚMEROS**. Os pontos são extraídos do alvo pelo algoritmo — as frases do
autor, na ordem dele — e o modelo só diz quais voltaram na memória escrita.
Índice fora do intervalo, valor não-inteiro ou chave extra derrubam a
conferência **inteira**: meia conferência mentiria sobre o que faltou. Nenhuma
palavra do modelo chega à tela: o autor lê as frases dele.

O que se mostra é só **o que não voltou**, porque é a única parte com
serventia — reler. Sem placar, sem porcentagem, sem "quase lá" (§12):
recuperação parcial é o caso NORMAL da prática, não um fracasso a medir.

**A mesma nota cobra mais fundo a cada volta.** O degrau da escada vai no
pedido, e ele diz o quanto cobrar: na primeira volta, um pedaço concreto (o
quê, onde, qual); depois a relação entre duas coisas; depois o porquê, o
mecanismo; depois a consequência; do quarto em diante, o limite — onde isto
deixa de valer, o que a contradiz.

Isto é o miolo, não enfeite. Recuperação sem dificuldade não fixa: a décima
revisão sendo idêntica à primeira é o que faz repetição espaçada virar
releitura. O app já tinha a escada e nunca a tinha contado a ninguém — custou
uma linha no pedido e um parâmetro na view.

**O que o modelo NÃO decide, de propósito.** A escada. Seria a jogada óbvia —
recuperação fraca, intervalo mais curto — e é justamente onde o modelo passaria
a decidir pelo autor. A R1 já diz que adiar não é falhar nem acertar; a escada
é do autor, e cobrar antes continua sendo um botão que ele aperta. Se um dia a
escada se adaptar, quem adapta é o algoritmo com o sinal, não o julgamento de
um modelo.

## ADR 2026-09-03j — O eco: a rede que o autor não desenhou

O estado vazio da Rede dizia a coisa exata: *"A ligação é sua; o app só a
segue."* Ele **segue** e nunca **acha**. `Rede.ligacoes` casa por TÍTULO — o
grafo do caderno é só tão bom quanto a disciplina do autor em digitar `[[…]]`.

O custo disso é invisível e enorme: duas notas sobre a mesma ideia, escritas
com palavras diferentes com meses de distância, **nunca se encontram**. E
achar isso é exatamente o que um algoritmo léxico não faz e um modelo faz.

**A decisão.** Na folha de Ligações, uma terceira seção — *TALVEZ SE LIGUEM* —
com até três notas que falam da mesma coisa que esta sem que nenhuma cite a
outra. Cada uma vem **com a prova na cara**: um trecho LITERAL da outra nota.

A verificação é a mesma do `PadroesRemoto`, que é a mais dura do app: o índice
tem de existir e o trecho tem de aparecer literalmente no texto que viajou.
Citação inventada é descartada — nunca mostrada com ressalva. Sem prova, sem
eco; e "nenhum eco" é resposta válida.

**O que NÃO acontece:** a sábia não escreve `[[…]]` em lugar nenhum. *"A
ligação é sua"* continua verdade ao pé da letra. O app passou a **mostrar um
candidato com a evidência**; quem liga é o autor, com o gesto dele.

**O que viaja:** título mais 240 caracteres de prosa por candidata, no máximo
40 — um ÍNDICE do caderno, não o caderno. É menos do que o `PadroesRemoto` já
manda hoje (9.000 caracteres de prosa por visita). O selo corta antes:
expressiva, trancada e queimada não entram na lista, e nota já ligada também
não — o valor está justamente no que a rede ainda não sabe.

## ADR 2026-09-03k — A análise no aparelho, e o cérebro deixa de ser condicional

Até hoje o cérebro do Traço era **condicional**: dependia de o autor ter ligado
a conta Grok e de haver sinal. No avião, no metrô, ou sem assinatura, a análise
caía direto nas quinze regex do motor local — que acertam o caso óbvio e calam
no resto.

O `FoundationModels` está no SDK e o app já mira iOS 26.0. Então existe um
degrau no meio que não custa nada: **o modelo do sistema, no aparelho.**

**A escada, agora com três degraus.** Grok primeiro quando há conta (é o maior);
o modelo do aparelho quando não há conta ou quando a rede falhou; as regex por
último. Nenhum caso fica pior do que estava, e o caso sem conta fica muito
melhor.

**O contrato fechado deixa de ser instrução e vira TIPO.** No `AnaliseRemota` a
lista fechada é um pedido no prompt, e `parseVeredito` existe porque um modelo
por HTTP pode devolver o que quiser — rótulo inventado, chave extra, texto livre
no lugar do JSON. Com `@Generable`, a geração é guiada pelo schema: o modelo
**não pode** emitir um caso que não existe. A classe inteira de falha some, não
por confiança, mas por construção.

**O que não muda.** A §2 continua de pé: isto classifica, e só. Nenhuma palavra
deste modelo chega à tela — o que o autor lê é sempre do app ou dele. As
definições são as MESMAS do motor remoto, palavra por palavra: ligar a conta não
pode mudar como o app roteia.

**O que isto abre.** Se o roteamento provar-se bom no aparelho, o mesmo caminho
serve para `vestir` e para a `conferir` da prova (ADR 03i) — os dois são
contrato fechado puro, que é o feitio deste modelo. As tarefas ABERTAS (responder
a pergunta do autor, instigar, os ecos) continuam melhores no Grok, e é por isso
que a escada tem degraus em vez de uma troca.

## ADR 2026-09-03l — Um cliente xAI, não três

A mesma requisição a `api.x.ai/v1/chat/completions` estava escrita TRÊS vezes —
`AnaliseRemota`, `Sabia` e `PadroesRemoto` — cada uma com o seu timeout, o seu
tratamento de erro e a sua memoização. Ou a falta dela: o `Sabia` não tinha
nenhuma, e as seis chamadas dele batiam na rede sempre. Abrir o Recordar da
mesma nota dez vezes eram **dez perguntas pagas** por uma nota que não mudou.

`Grok.responder(sistema:usuario:temperatura:timeout:memoPor:)` é o único
caminho. Um lugar significa: uma política de custo, um timeout, um ponto para
medir, e nenhuma chance de as três divergirem em silêncio.

**A regra do memo**, que agora existe porque há onde escrevê-la: contrato
determinístico (temperatura 0 — vestir, conferir) memoiza porque repetir é
desperdício puro. A pergunta da prova memoiza por `(alvo, degrau)`: dentro do
mesmo degrau ela não deve mudar, e quando o degrau sobe a chave muda sozinha.
Onde o autor pede DE NOVO esperando algo novo — instigar, Padrões — não
memoiza. E sair da conta esvazia tudo: o que ele perguntou não fica.

## ADR 2026-09-03m — O segundo cérebro entra na resposta

A ADR 03h deu à sábia as notas que o autor LIGOU com `[[…]]`. A 03j provou que
o modelo acha as que ele **não** ligou — e que a prova literal segura a
invenção. Faltava juntar as duas.

Agora a pergunta "?" viaja com o que ele ligou **mais o que ele esqueceu que
escreveu**. A ligação explícita é o que ele sabe que se conecta; o eco é o que
o segundo cérebro sabe e ele não lembra. É aí que mora a diferença entre ter um
caderno e ter uma página.

O cartão continua dizendo QUAIS notas foram junto, e o selo corta antes nos dois
caminhos: `Rede.podeLigar` nas ligadas, `fechada`/expressiva nas candidatas.

## ADR 2026-09-03n — Cada forma carrega o movimento do próprio método

A sábia instigava com `"Forma: Decisão"` e o rascunho. Ela improvisava boas
perguntas genéricas — e genérico é justamente o que não serve, porque cada
forma do §6 é um método validado e **cada método tem um movimento que a pessoa
pula quando está sozinha**:

- o obstáculo é INTERNO no WOOP, e todo mundo escreve obstáculo externo;
- o gatilho do Se–Então tem de ser observável, e a resposta um comportamento
  SUBSTITUTO, nunca "não fazer X";
- a spec sem não-escopo é desejo;
- o pré-mortem exige o enquadramento "já falhou", não "o que pode dar errado" —
  é o enquadramento que faz o método funcionar (Klein, 2007);
- a decisão pede o critério que separa as opções, a evidência que faria mudar
  de ideia, e se dá para desfazer.

`Gesto.metodo` é esse instrumento, escrito. A IA não decide nem preenche (§2):
ela **aplica o método melhor do que a memória do autor aplicaria às 23h**. É a
definição mais literal possível de multiplicar a mente — o método é dele, a
disciplina de cobrá-lo passa a ser da máquina.

## ADR 2026-09-03o — A leitura da calibragem, e o ciclo fecha

A revisão da semana (ADR q) é algoritmo puro: conta, agrupa e cobra, nunca
comenta. Ela põe lado a lado o que o autor **esperava** e o que **aconteceu** —
e depois deixa os pares ali, sem ninguém lendo.

Ler UM par é fácil, e ele já lê. O que nenhum algoritmo faz e nenhuma pessoa
faz sozinha é ver o **padrão ENTRE os pares**: o tipo de situação em que a
expectativa erra sempre para o mesmo lado, o prazo que sempre estica, a
variável que nunca entra na conta. A memória não ajuda porque ela reescreve a
expectativa depois de saber o fim — só o papel guarda a versão de antes.

`Sabia.lerCalibragem` é o único lugar do app onde a IA olha para o **autor** e
não para um texto. Por isso a prova literal pesa mais aqui do que em qualquer
outro lugar: um espelho que inventa é pior que nenhum. Citação que não aparece
nos pares é descartada, veredito não passa, e com menos de dois pares não há
leitura — um caso não é padrão.

E continua sendo PERGUNTA. Nota, placar e diagnóstico estão proibidos no prompt
e barrados no parser: quem conclui sobre o próprio juízo é ele.

**Isto fecha o ciclo.** O app já multiplicava o trabalho da mente; agora devolve
à mente a única coisa que ela não consegue ver sozinha. E a mente melhor volta a
escrever — que é onde o ciclo recomeça.

## ADR 2026-09-03p — O portão dos modelos

Duas coisas morderam de verdade no dia em que a conta foi ligada:

**A suíte.** O token do OAuth vive no chaveiro do SIMULADOR, e vale também para
o processo de teste. As 82 suítes descrevem o motor local, que é
determinístico; com a conta ligada, a análise remota passou a responder por
baixo delas e **oito testes sem nenhuma relação com IA começaram a falhar**.

**A varredura.** 86 fluxos × uma chamada por pausa de análise = a suíte de
teste gastando a assinatura do autor e levando o dobro do tempo. Suíte de teste
que custa dinheiro é defeito de projeto, não detalhe.

`Motores.desligados` é um portão só, e ele fica onde ninguém pode esquecê-lo:
dentro do `Grok.responder` (que é agora o único caminho à rede, ADR 03l) e do
`AnaliseDeBordo.classificar`. Ele liga por ambiente de teste ou pela bandeira
`motorSoLocal`, que os fluxos passam no `launchApp`.

**E dois fluxos não levantam a bandeira, de propósito:** `pergunta-sabia` e
`lente-instigar` são testes de integração VIVOS — o único lugar do projeto que
prova a ADR o ponta a ponta com modelo de verdade. Um motor que nunca roda é um
motor que ninguém sabe se funciona; por isso `classificarSemPortao` existe, e
por isso o app nunca a chama.

## ADR 2026-09-04a — O aviso que ninguém vê não existe (e essa é a lei)

**Palavra do dono (04/set):** *"Ao adicionar um compromisso o app nem opção de
me notificar ou fazer algo do tipo para o evento marcado. Está marcado não
adianta nada se eu não sei. E principalmente não tem uso no dynamic island ou
widget ou até mesmo aquelas funções vivas na tela de bloqueio."*

**O erro, com nome.** A ADR 03d fechou "o que se marca, avisa" — e fechou de
verdade no MOTOR: `Revisoes.agendarCompromisso` tem namespace próprio, série
semanal repetindo, dia inteiro na âncora da manhã, e o aviso morre com o
compromisso. Nada disso era mentira. Mentira era o que a tela contava: a ficha
do compromisso tinha QUANDO, REPETE, NOTAS e APAGAR, e **nem uma palavra sobre
aviso**. Nenhuma tela prometia, nenhuma confirmava, nenhuma deixava escolher a
antecedência, nenhuma dizia quando o iPhone tinha os avisos desligados — o
`requestAuthorization` acontecia dentro de uma `Task` e o "não" do sistema
voltava `false` para ninguém.

O app avisava e o autor não sabia. Para ele, isso é idêntico a não avisar. E
pior que idêntico: sem antecedência, o aviso "na hora" de um dentista às 14h
chega quando já era — um alarme que só serve para o arrependimento.

**A lei que fica, e que vale para TODA função daqui em diante:**

> Função que o autor não vê, não confirma e não controla **não foi entregue**.
> Motor sem superfície é dívida, não feature. A varredura mede a SUPERFÍCIE,
> nunca a chamada: `grep` que acha a função e não acha a tela é achado.

Três perguntas viram aceite obrigatório para qualquer coisa que o app passe a
fazer sozinho — nesta ordem, e as três antes de dar por pronto:

1. **Onde ele vê que vai acontecer?** (a promessa, ANTES do fato)
2. **Como ele sabe que aconteceu — ou por que não?** (estado honesto, ADR 03e)
3. **Onde ele ajusta ou desliga?** (controle, a um toque)

É a mesma raiz da ADR 03e (permissão negada é beco) e do §17 (fricção é bug),
agora escrita como critério de varredura em vez de intenção.

**O que muda no produto:**

- `EventoCalendario.avisoMinutos` — lista fechada: não avisa · na hora · 5 · 10
  · 15 · 30 min · 1 h · 2 h · 1 dia antes. Padrão "na hora" (o comportamento da
  ADR 03d fica de pé para tudo que já está no disco), e a ficha mostra a **hora
  real** do aviso ("sexta, 13h30"), nunca só o rótulo abstrato: o autor confere
  a promessa em unidades do mundo dele.
- A ficha ganha a seção AVISO com estado honesto de permissão e a única volta
  que o iOS permite quando está negado — abrir os Ajustes do app.
- Marcar pela prosa devolve a promessa em uma linha ("sexta, 14h · aviso 30 min
  antes"): o fim do percurso tem de devolver alguma coisa (peak-end-rule).
- O compromisso passa a existir **fora do app**: widget na tela de início e na
  tela bloqueada com o próximo, e Live Activity com contagem regressiva na Ilha
  no dia dele. Compromisso que só existe dentro do app é compromisso que o
  autor descobre tarde — e a tela que ele mais olha não é a do Traço.

## ADR 2026-09-04b — O orçamento de avisos

O iOS guarda **64 notificações pendentes por app** e descarta o resto **em
silêncio**. O Traço agenda: a fila diária (1), a revisão da semana (1), o
gatilho do "Se" de cada nota (1 por nota), a série da expressiva (1) e o
compromisso — que numa série semanal vira **uma por dia da semana** (até 7 por
compromisso, porque é assim que o sistema cobra sozinho sem o app reagendar).

Dez compromissos semanais em três dias já são 30; com trinta notas com hora, o
teto estoura e a ADR 03d volta a ser mentira sem um único erro na tela — que é
exatamente o defeito da ADR 04a, repetido numa camada mais fundo.

**Decisão.** O orçamento é explícito e o que não cabe é DITO, nunca engolido:
`Avisos.cabem` conta os pendentes antes de agendar; o que não cabe não é
agendado, a ficha diz na hora ("o iPhone guarda 64 avisos e já estão todos —
este ficou sem alarme"), o widget não desenha sino para ele, e o Perfil mostra
"n de 64 avisos ativos".

**O que NÃO está construído, e por isso não se promete aqui:** fila de
prioridade (derrubar o aviso distante para caber o de hoje). Recusar o novo e
contar é honesto e cabe em uma linha; escolher qual aviso morre é uma decisão
sobre a agenda do autor, e essa não se toma por conta própria. Se o teto passar
a bater de verdade, isto volta como ADR — com o autor escolhendo a regra.

## ADR 2026-09-04c — A escada não engole o aviso

A ADR 03k pôs o modelo do aparelho no meio da escada. O `Escolha` do
`FoundationModels` só tem `gesto` — ele **não pode** emitir aviso. E
`Sessao.analisar` fazia `remoto ?? AnaliseLocal.classificar(...)`: como o
degrau do aparelho devolve `.silencio` (não `nil`) quando não é forma nenhuma,
a regex **nunca rodava** num iPhone com Apple Intelligence e sem conta. Os
cinco avisos obrigatórios do §5 ficavam inalcançáveis, e o critério de aceite
do §13 ("eu sou um vencedor" → aviso Wood) falhava justamente na configuração
que a ADR 03k tornou padrão.

Ninguém viu porque a suíte e a varredura rodam com `Motores.desligados` — os
390 testes provam o degrau que, em produção, não roda.

**Decisão.** O modelo roteia FORMA; o aviso é do algoritmo, sempre. Silêncio do
modelo não é veredito: quando o degrau de cima cala, o local decide. É a §19.4
ao pé da letra — *o algoritmo garante; a IA sugere* — e custa uma linha.

## ADR 2026-09-04d — O terceiro cinza tinha de ser lido

A ADR 02h fechou: *"todo texto ≥4,5:1 sobre o papel, ícone ≥3:1"*. A varredura
de 04/set mediu: `tintaFraca` (#86868B) dá **3,29:1 no papel e 2,95:1 no chip**,
e carregava **texto** em 58 lugares — o trecho da busca, a contagem de
resultados ("1 nota com 'celular'"), o metadado da lista, e o rótulo da aba
inativa a 11pt, que o §20 manda pintar exatamente assim.

Duas regras da própria spec se contradiziam, e o código implementava a fraca.

**Decisão.** `tintaFraca` passa a #68686C — 5,04:1 no papel, 4,65:1 no campo,
4,52:1 no chip. O §20 fica como está (inativo = `tintaFraca`); o que muda é o
valor do token, não a regra de uso.

**Custo assumido, escrito para não ser esquecido:** #68686C encostou no
`tintaSuave` (#5F5F64). São dois cinzas separados por 0,7 de razão — uma
hierarquia fina demais para justificar dois tokens. Um dos dois deve morrer, e
isso é trabalho de olho, não de régua: fica na FILA. Até lá vale a ordem certa —
**um texto que se lê mal não é hierarquia, é defeito.**

## ADR 2026-09-04e — O modo férias, e a linha entre cobrar e mandar

**Palavra do dono (04/set):** *"e o modo férias? Vc tem que pensar em tudo."*

O Traço é um app que COBRA: a fila do Recordar toca todo dia na hora do autor,
a revisão da semana toca domingo à noite, e a série da expressiva cobra quatro
dias seguidos. Isso não é enfeite — é o método (§7, §8.9, ADR 02d/02f/02q).

E não havia como dizer **"estou fora"**. Quem viajasse levava o ritual junto.
O custo real não é o incômodo de uma semana: é que o autor **aprende a ignorar
a notificação** — e uma cobrança que ele aprendeu a ignorar está morta quando
ele voltar. Um ritual que não se pode pausar não é ritual, é sino.

**A linha, e ela é a mesma da ADR 04a vista do outro lado:** o Traço cala o que
**ele** inventou de cobrar — memória, revisão, série. O que o **autor** marcou
continua tocando: compromisso e aviso do "Se". **Férias não desmarca dentista.**

**Como funciona:**
- Interruptor no Perfil com data de volta. Ligar assume **uma semana** (é o que
  se pede quando se viaja) e "sem data" é escolha explícita logo abaixo.
- **Expira sozinho** no arranque e ao voltar à cena (§17: lembrar de desligar um
  recurso é fricção, e fricção é bug). Ao expirar, o que estava calado reagenda.
- Uma linha honesta diz o estado inteiro: o que cala, o que continua, até quando.
- **Feriado é opção à parte, desligada por padrão.** Um feriado é dia em casa, e
  dia em casa é bom dia para recordar. Quem discordar liga — mas a decisão é
  dele, não do app.
- A **série da expressiva não morre**: ela espera o primeiro dia que cobra. O
  método Pennebaker é de quatro SESSÕES, não de quatro datas.

**A mesma linha, aplicada ao silêncio do sistema:** o compromisso e o aviso do
"Se" saem como `timeSensitive` — atravessam o modo Foco, porque o autor os
marcou. A fila do Recordar, a revisão de domingo e a série ficam no nível
normal: o que o app inventou de cobrar espera o Foco acabar. Um alarme de
dentista que o Foco engole é a mesma frase do dono, dita de outro jeito.

**O custo técnico, escrito porque ele tem um teto:** o iOS não sabe pular um dia
num gatilho repetente. Sem silêncio no caminho, a fila continua sendo UMA
notificação repetente (um slot do orçamento da ADR 04b). Com férias ou feriado
no caminho, ela é enumerada dia a dia numa janela de **catorze dias** (≤14
slots), e o arranque do app a re-arma. Quem ficar duas semanas sem abrir o app
durante as férias volta sem fila agendada — e a fila volta no primeiro arranque.

## ADR 2026-09-04f — A tela bloqueada deixa de ser cartaz

**Palavra do dono (04/set):** *"e modo interativo na tela de bloqueio?"* — e,
sobre a primeira versão do cartão: *"muito fraco"*.

A ADR 04a pôs o compromisso na tela bloqueada. Mas **ver não é agir**: o cartão
mostrava e a única saída era abrir o app — e abrir o app é justamente o que
ninguém faz na fila do banco. Pior, havia uma incoerência de dedo: o Destaque
era BOTÃO no widget da casa e CARTAZ na tela bloqueada. A mesma coisa com duas
leis é o que faz a mão errar.

**O que ficou interativo, e por quê:**

- **Destaque** — o círculo marca a única coisa de hoje, na tela bloqueada e na
  Ilha, com o mesmo `DestaqueFeitoIntent` do widget da casa. Nenhum conceito
  novo; a mesma lei em todo lugar. (Marcar encerra a atividade: a coisa está
  feita, o cartão sai.)
- **Compromisso** — *"Lembrar em 10 min"*. Um botão, um significado, e vale
  antes ("me lembra de sair") e depois do aviso ("agora não dá"). É a frase do
  "hoje não" do Recordar (ADR 03e): adiar não é falhar nem acertar, é a hora
  errada. Namespace `soneca-<id>`: a soneca nunca alcança o aviso do
  compromisso.

**A regra que o botão herda da 04a:** o toque tem de VIRAR alguma coisa na
tela. Se agendou, o cartão passa a dizer "lembro às 11:07"; se o iPhone está
com os avisos desligados, ele diz isso, em vermelho, no lugar do botão. Botão
que não faz nada e não explica é a ADR 04a repetida do tamanho de um dedo.

**Detalhe de engenharia que quase virou defeito:** `LiveActivityIntent` roda no
processo do APP. Os dois intents moram na pasta do widget mas são compilados
TAMBÉM no alvo do app — sem isso o toque falharia calado.

**E o desenho, depois do "muito fraco".** A primeira versão pintava papel
(`Tema.fundo`) por baixo do material do sistema: saiu um cinza sujo, com o
âmbar virando ocre. A correção não é insistir na cor da casa numa tela que não
é da casa — é **entrar pela tipografia e pelo acento**: o material fica o do
iOS, a tinta é semântica (`.primary`/`.secondary`), e o Traço aparece no ponto
âmbar, no rótulo com tracking, no título de 21pt com tracking negativo, e no
contorno âmbar da ação. A hierarquia também virou: o assunto é o COMPROMISSO,
não o relógio (a versão anterior dava 20pt para a hora e 16 para o que importa
— `critique-visual-hierarchy`).

## ADR 2026-09-04g — O objetivo, escrito: o ciclo da mente

**Palavra do dono (04/set):** *"Bloco de notas eu acho que muito pequeno. Ele
tem um calendário completo para organizar e também é para montar uma espécie
de segundo cérebro, e usar o poder da mente junto com técnicas extremamente
poderosas e multiplicar o indivíduo ao máximo, além de tentar evoluir o
indivíduo. Multiplicar a mente do usuário de uma forma extraordinária. E
depois passar por outra etapa, de melhorar essa mente de forma extraordinária,
e esse ciclo. Quanto mais a mente se multiplica, mais a IA multiplica o poder
da mente."*

O §1 dizia "o bloco de notas mais simples do mercado". Era a frase de abertura,
não o objetivo. O objetivo tem **duas voltas e um eixo**:

1. **Multiplicar.** A IA amplifica o que a mente produz agora: pensamento,
   estratégia, criação, memória, linguagem. Dá forma, informação e pergunta
   (ADR o); nunca a resposta do autor.
2. **Melhorar.** O método muda a mente: recuperação com dificuldade que sobe,
   calibragem contra o que aconteceu, obstáculo interno nomeado, pré-mortem,
   quatro sessões de escrita expressiva.
3. **O eixo.** As duas voltas só se realimentam se a IA souber em que ponto a
   mente está. Sem memória do autor, cada chamada parte do zero e "quanto mais
   a mente se multiplica, mais a IA multiplica" é frase, não mecanismo.

A auditoria de 04/set mediu o app contra isso e achou: a volta de melhorar bem
servida (quase toda algoritmo, como manda o §19.4); a volta de multiplicar
tímida (sete superfícies que não sabem quem é o autor); o eixo inexistente.
As ADRs 04h a 04r fecham os catorze pontos, nesta ordem: o eixo (sinal,
retrato, degraus), a transferência entre formas, o catálogo como dado e as
faculdades que faltavam, a IA na criação, o índice de sentido, o corpus que
escala, a entrada do Mac, a trajetória, e a doutrina que decide onde a IA é
abundante e onde cala.

**O aceite que passa a valer para toda função de IA**, além das três
perguntas da ADR 04a: (a) em qual volta ela entra, e (b) o que ela SABE da
mente do autor para entrar ali. A regra de ferro fica intacta: forma,
informação e pergunta; nunca a resposta do autor; nada da IA entra na nota
por conta própria.

## ADR 2026-09-04h — O sinal: o autor diz o que serviu

Nenhum sinal voltava para a IA. Uma pergunta inútil do instigar, uma forma
vestida errada, uma resposta que não serviu: o autor não tinha como dizer, e
Soltar a forma, o único gesto, não era guardado nem lido por prompt nenhum. A
segunda volta do ciclo, a da IA aprendendo esta mente, não tinha entrada.

**Decisão.** `Sinais` é um diário no disco (`Documents/Traço/sinais.json`),
algoritmo puro, que registra o que o autor fez com o que a IA e o app lhe
deram: `solto(forma)` quando ele desfaz uma forma vestida; `ficou(forma)`
quando conclui uma nota com pelo menos um campo respondido; `pergunta(origem,
serviu)` quando toca "serviu" ou "não serviu" numa pergunta do instigar, da
forma ou da prova; `resposta(serviu)` no cartão da sábia; `naoVoltou(forma,
quantos)` na conferência do Recordar. Guarda no máximo 500 sinais, os mais
recentes.

**A superfície (ADR 04a):** todo cartão com texto de modelo ganha duas saídas
discretas, "serviu" e "não serviu", que somem depois do toque. O Perfil mostra
"O que o Traço aprendeu de você": quantos sinais, desde quando, e "esquecer
tudo". Sem conta ligada o sinal continua sendo guardado: ele serve ao
algoritmo (ADR 04j) tanto quanto à sábia.

**O que o sinal não é.** Não é nota, não é placar, não mede o autor. É a
resposta dele ao que o app fez, e é dele: sair da conta não apaga (o sinal é
do aparelho, não da rede); "esquecer tudo" apaga.

## ADR 2026-09-04i — O retrato da mente: o eixo do ciclo

A sábia lia só a página aberta, três ligadas e uma fatia do caderno. Não
sabia que o autor já respondeu vinte vezes aquele tipo de buraco, qual
obstáculo volta nos WOOPs dele, o que a memória dele solta, para que lado a
expectativa dele erra. Cada chamada esquecia o autor no fim.

**Decisão.** `Retrato.ler(notas:sinais:)` monta, por algoritmo e só com as
palavras do autor, o bloco SOBRE QUEM ESCREVE que viaja em `instigar`,
`responder`, `contrapor` e na pergunta da prova:

- as formas que ele usou nos últimos 30 dias, com contagem;
- os obstáculos internos que ele nomeou (os cinco últimos, literais);
- o que NÃO voltou nas últimas provas do Recordar (três pontos, literais);
- a calibragem: em quantas decisões conferidas o que aconteceu ficou aquém,
  igual ou além do esperado (contagem, nunca juízo);
- as palavras que ele conquistou (Palavra › nas minhas palavras, cinco últimas);
- as perguntas que ele marcou como "não serviu" (três últimas, literais), para
  a sábia não repetir a classe.

Teto de 1.500 caracteres. Sai só o que existe: retrato vazio não viaja.

**A superfície.** O Perfil mostra o retrato **exatamente como viaja**, sob "O
que a sábia sabe de você", com um interruptor "a sábia conhece você" (ligado
por padrão) que corta o bloco de todo pedido. O selo vale: nada de expressiva,
trancada ou queimada entra no retrato, nem como contagem.

**O que o retrato não faz.** Não conclui, não diagnostica, não pontua. É a
evidência que o papel guarda, posta na frente da IA para ela perguntar melhor.
Quem conclui sobre a própria mente continua sendo o autor.

## ADR 2026-09-04j — Degraus para tudo

Só a escada do Recordar era adaptativa. Limiar de confiança para vestir,
escolha da forma, dificuldade das perguntas, quantas notas viajam: constantes.
Uma mente que melhora e recebe o mesmo estímulo para de melhorar.

**Decisão.** Três degraus novos, os três por algoritmo:

1. **Instigar sobe com a prática.** O degrau da instigação é quantas notas
   daquela forma o autor já concluiu (0 · 1–2 · 3–5 · 6–10 · 11+ → 0..4), e o
   prompt diz o que cobrar em cada um: no 0, o movimento básico do método; no
   1, a relação entre dois campos; no 2, a evidência; no 3, o custo de errar;
   no 4, o limite do próprio método. Mesmo mecanismo da prova (ADR 03i).
2. **Vestir aprende com o Soltar.** Se os três últimos sinais de uma forma
   foram `solto`, ela passa a ser SUGERIDA (cartão com "Abrir a forma") em vez
   de vestida sozinha, até o autor abrir uma por vontade própria. O Perfil
   lista as formas nesse estado, e um toque as devolve ao vestir.
3. **O caderno que viaja cresce com o caderno.** Quantas notas vão junto de
   uma pergunta deixa de ser 3 + 40 arbitrárias e passa a vir do índice de
   sentido (ADR 04n): as mais próximas, e tantas quanto couberem no teto de
   caracteres.

Nenhum degrau é decidido pelo modelo (ADR 03i, "o que o modelo não decide").

## ADR 2026-09-04k — As formas se encadeiam

As formas eram ilhas. WOOP não virava Se–então, Decisão não virava Pré-mortem
sem gesto manual, Pré-mortem não gerava sinal a vigiar. A transferência entre
faculdades, que é onde o poder se multiplica, tinha um elo só (o plano sem
falha abrindo pré-mortem, ADR p × q).

**Decisão.** Cada método do catálogo declara os seus **encadeamentos**: para
qual forma ele leva, com que mapa de campos. Ao pé dos campos de uma forma
nasce a linha DEPOIS DISTO, com um botão por encadeamento, ativo quando os
campos de origem têm resposta. O toque grava a nota, abre uma página nova com
a forma de destino e os campos de origem COPIADOS nas palavras do autor, e
escreve `[[título da origem]]` no destino: a rede (ADR 03b) passa a ter o elo.

Os encadeamentos de partida:

| De | Para | O que copia |
|---|---|---|
| WOOP | Se–então | obstáculo → Se · plano → Então |
| Se–então | Compromisso "conferir o hábito" em 7 dias | o Se, com aviso |
| Decisão | Pré-mortem | decidido → plano |
| Pré-mortem | Se–então | sinal → Se · mudo → Então |
| Pré-mortem | Compromisso "vigiar o sinal" em 14 dias | o sinal, com aviso |
| Especificação | Pré-mortem | problema → plano |
| Argumento | Decisão | tese → o que estou decidindo |
| Leitura | Nota permanente | tese → ideia · fonte → fonte |
| Dia | Destaque do dia | a única → a tela bloqueada |

A IA não escreve nada aqui: é cópia das palavras dele, por algoritmo.
Encadeamento é dado do catálogo (ADR 04l): um método novo traz os seus.

## ADR 2026-09-04l — O catálogo de métodos como dado

Adicionar um método exigia ADR, enum, campos, regex, prompt e teste. A
potência do app crescia na velocidade de uma sessão de código.

**Decisão.** `Gesto` deixa de ser enum e passa a ser um id sobre um
**catálogo**: `Metodos.json` no bundle, com os dez métodos de hoje (ids
inalterados, o corpus antigo importa), mais os que esta ADR traz, mais o que o
autor puser em `Documents/Traço/metodos/*.json` (do Mac, pela pasta espelhada,
ou por qualquer editor). Cada método declara: id, nome, origem, o
reconhecimento, o movimento (ADR 03n), a pergunta do template, os campos, o
roteamento (regex sobre a voz do autor), o modo de Recordar (o que esconde e o
que mostra) e os encadeamentos (ADR 04k). O app lê o catálogo no arranque e ao
voltar à cena; entrada inválida (sem id, sem campo, id repetido) é ignorada e
dita no Perfil.

**Os métodos que entram agora**, todos com origem nomeada:

| Método | Faculdade | Campos |
|---|---|---|
| **Argumento** (Toulmin) | raciocínio | Tese · Evidência · A melhor objeção · Minha resposta · O que me faria mudar de ideia |
| **Leitura** (Adler) | aprender de fora | Fonte · A tese, nas minhas palavras · O que me surpreendeu · Onde discordo · A pergunta que ficou |
| **Feynman** | compreensão | O que estou explicando · Como para uma criança de 12 · Onde travei · O que fui ver |
| **Dia** (Ivy Lee) | foco | A única · As três seguintes · O que vai roubar o dia · Se roubar, então eu · O que roubou (à noite) |
| **Analogia** (Gentner) | criação | O problema · Onde isto já foi resolvido, em outro campo · O que trago de lá · O que não se transfere |
| **Inversão** (Munger) | criação, estratégia | O que quero · Como garantir que falhe · Logo, o que evito |
| **Steelman** | raciocínio | A posição contrária, no melhor · O que ela acerta · O que eu respondo |
| **Divergência** (Osborn) | criação | Dez opções cruas · A mais estranha · O que ela ensina |
| **Primeiros princípios** | estratégia | O que acho que sei · O que é verdade de fato · O que construo do zero |
| **Prática deliberada** (Ericsson) | habilidade | A habilidade · O pedaço que falha · O exercício · Como sei que melhorou |
| **Atualização** (Tetlock) | calibragem | O que acredito · Quanto (0–100) · O que me faria subir · O que me faria descer · Depois: quanto agora |

Vinte e um métodos. Os três degraus roteiam o catálogo inteiro: a regex do
JSON, o Grok (cujo prompt lista o catálogo) e o modelo do aparelho, cujo
esquema é gerado do mesmo arquivo (ADR 04t). Cada método traz a sua
`definicao` para o roteador; um método do autor entra nos três sem código.

**O material de fora.** Um arquivo de leitura anexado (pdf, epub) com uma
palavra do autor ao lado roteia para a Leitura antes das regex de prosa: o
arquivo continua arquivo, e o conhecimento é o que ele escreve nas próprias
palavras — com a prova no Recordar.

**O que não muda.** Campos nascem vazios; a IA só roteia o rótulo; a expressiva
continua fora do catálogo aberto (o selo não é dado configurável).

## ADR 2026-09-04m — Contrapor: a IA na criação

A criação não tinha método (agora tem quatro, ADR 04l) e a IA, autorizada a
dar informação, nunca dava o que o autor não considerou: a posição contrária,
a opção fora da lista, o exemplo de outro campo.

**Decisão.** `Sabia.contrapor` é a quarta chamada da sábia: recebe a nota e a
forma, e devolve JSON `{contra, foraDaLista, outroCampo}`, três parágrafos
de até 280 caracteres, cada um informação e nunca instrução (parser recusa
o que começa por "você deve", "faça", "escreva"). Aparece num cartão com os
três rótulos; "Copiar" leva à área de transferência; nada entra na nota.
Botão "Contrapor" na Lente, ao lado de "Instigar"; só a pedido, nunca na
pausa (ADR 04r). O retrato (ADR 04i) vai junto: contrapor quem se conhece é
mais preciso do que contrapor um texto.

É a fronteira da ADR o ao pé da letra: informação e pergunta. A resposta,
a opção escolhida e a analogia que fica são do autor.

## ADR 2026-09-04n — O índice de sentido

§12 proibia busca semântica: "a busca acha, não interpreta". Foi escrito
quando o app era bloco de notas. Com centenas de notas, achar pelo
significado é a função central de um segundo cérebro, e o aparelho tem
embeddings de palavras em português (`NLEmbedding`, 200 dimensões) sem uma
linha de rede. Medido em 04/set: o modelo de FRASES do sistema não separa
nada em português ("banco de dados" fica tão perto de "quero correr de manhã"
quanto "treinar ao acordar"); a média dos vetores das palavras de conteúdo
separa (0,3 a 0,4 para o parecido, 0,0 a 0,2 para o resto). O índice guarda
essa média por nota, e a vizinhança começa em 0,3.

**Decisão.** `Indice` guarda um vetor por nota aberta em
`Application Support/indice-sentido.json`, refeito só para a nota que mudou.
O selo corta antes: expressiva, selada e queimada nunca entram, e selar tira
do índice na hora. Três superfícies:

1. **Notas › PELO SENTIDO.** Abaixo dos resultados léxicos, até cinco notas
   próximas da busca que a busca por letras não achou. A seção diz o que é.
2. **Ecos por proximidade** (ADR 03j). As 40 candidatas deixam de ser as 40
   primeiras de um fetch sem ordem e passam a ser as 40 mais próximas.
3. **A sábia vê o caderno** (ADR 03m). A linha "?" viaja com as ligadas, os
   ecos e as seis notas mais próximas da pergunta. O cartão continua dizendo
   quais.

O Perfil mostra "índice de sentido: n notas" e "refazer". Sem o modelo no
aparelho (sistema antigo), as três superfícies simplesmente não aparecem, e o
Perfil diz.

**O que não muda.** A busca por letras continua sendo a primeira; o índice
não interpreta, aproxima. A ligação continua sendo do autor (ADR 03b).

## ADR 2026-09-04o — O corpus só regrava o que mudou

`Corpus.escrever` regravava um `.md` por nota a cada conclusão, na main
thread, em duas pastas: 190 ms a mil notas no SSD, muito pior no iCloud. O
segundo cérebro tinha teto de dezenas.

**Decisão.** Concluir uma nota escreve **só o `.md` dela** e os três arquivos
agregados, numa tarefa fora da main thread. A varredura completa (apagar o
que não existe mais, reescrever tudo) fica para as rotas do selo, que
continuam síncronas e inteiras: selar, queimar, apagar, importar, e uma vez
no arranque. É onde a promessa de "regravado na hora" mora, e ela não muda.

## ADR 2026-09-04p — A entrada do Mac

Escrevia-se só no iPhone; o Mac só lia pelo MCP. Segundo cérebro que não
aceita entrada de onde a pessoa está pensando perde o que foi pensado lá.

**Decisão.** A pasta ganha `entrada/`. O servidor MCP ganha
`traco_escrever(titulo, texto, forma?)`, que grava um `.md` ali com o
cabeçalho do corpus. O app, no arranque e ao voltar à cena, lê `entrada/` em
Documents e na pasta espelhada, cria as notas (abertas, sempre: import jamais
tranca) e apaga o arquivo lido, que agora é nota e vai aparecer em `notas/`.
Um toast diz "n notas vieram de fora"; o Perfil explica a pasta e mostra a
última entrada. O mesmo caminho lê `metodos/` (ADR 04l).

A pasta espelhada continua "só escrita" para tudo o mais: o app lê UMA
subpasta, com um contrato, e nada além.

## ADR 2026-09-04q — A trajetória

§12 proíbe medir, e está certo contra placar e streak. Mas "melhorar a mente"
é afirmação sobre uma trajetória, e nada no app deixava o autor ver a dele.

**Decisão.** Nos Padrões, abaixo da semana, o cartão TRAJETÓRIA: dois
períodos lado a lado (os últimos 30 dias e os 30 anteriores), só evidência nas
palavras do autor: as formas usadas; os obstáculos nomeados (literais); o que
não voltou no Recordar (literal); as decisões conferidas (aquém · igual ·
além, contagem); as palavras conquistadas; as linhas de sentido. Sem seta,
sem melhor/pior, sem porcentagem, sem comparação escrita: os dois lados ficam
ali e quem lê é ele, como na calibragem (ADR 03o). Cada linha abre a nota.
O mesmo texto sai no intent "Trajetória".

## ADR 2026-09-04r — Abundante no ato, calada na pausa

A spec inteira pendia para o silêncio ("na dúvida, cala"; "nunca sozinha na
pausa", ADR o) e o objetivo pende para o máximo. As duas eram defensáveis, e
nenhuma ADR escolhia; o código escolheu sozinho: a ADR 03h pôs o instigar em
`usarForma`, que o caminho automático chama a cada pausa de 1,6 s.

**A linha.** A **pausa** só roteia e veste: uma chamada de classificação,
memoizada, e nada mais. O **ato** é onde a IA é abundante: abrir os campos
de uma forma, escrever o primeiro caractere num campo, a linha "?", Instigar,
Contrapor, abrir o Recordar, visitar os Padrões. Ato é o autor dizendo "estou
aqui, pensando nisto"; pausa é ele respirando.

**O que muda no código:**
- `instigar` dispara na primeira resposta num campo ou em "Abrir os campos",
  nunca no vestir automático;
- **o aviso é do algoritmo, sempre** (ADR 04c, agora inteira): aviso local
  vence gesto remoto; o campo `aviso` sai do contrato remoto, que só roteia;
- a resposta da sábia tem UM teto, 900 caracteres, no prompt e no parser;
- o modelo nunca é chamado duas vezes pela mesma pausa.

## ADR 2026-09-04s — O selo, reafirmado sobre tudo isto

Cada ADR acima passa a mesma prova, escrita aqui uma vez: expressiva (em
curso ou fechada), selada e queimada não entram no retrato, no índice, nos
sinais que citam texto, na trajetória (só a linha de sentido, como sempre),
na entrada do Mac (import jamais tranca) nem em encadeamento nenhum. Teste
por rota, como no §8.6.

## ADR 2026-09-04t — A sábia desce ao aparelho, e o catálogo inteiro sobe ao modelo de bordo

Duas frases ficaram na FILA como "limite declarado" e não precisavam ficar:

**1. "O modelo do aparelho só roteia os dez de origem."** O esquema do
`FoundationModels` era um enum escrito à mão. Agora é gerado do catálogo em
tempo de execução (`DynamicGenerationSchema` com `anyOf` sobre os ids do
`Metodos.json`): a lista fechada continua sendo TIPO — o modelo não pode
emitir um id que não existe —, e o tipo nasce do mesmo arquivo que o prompt
remoto. Um método do autor entra nos três degraus sem uma linha de código.

**2. "Sem conta Grok, sete das nove superfícies calam."** A escada da ADR 03k
valia só para o roteamento. Passa a valer para a sábia inteira: `Sabia.chamar`
tenta o Grok e, sem conta ou sem rede, pede ao modelo do aparelho com o MESMO
prompt e o MESMO parser. A verificação dura não muda de lugar: JSON fora do
formato é silêncio, venha de onde vier. A janela do aparelho é menor (3.500
caracteres de pedido), então viajam menos candidatas — nunca menos prova. O
cartão "sem conta" passa a dizer por onde a sábia responde hoje; o Perfil
também.

**3. A calibragem deixa de adivinhar.** A Decisão ganha o campo de volta
"Ficou aquém, igual ou além do que eu esperava?", respondido pelo autor. O
retrato e a trajetória contam por ele; a leitura por palavras de sinal no
"aconteceu" fica só para as decisões antigas, sem o campo.

O que não muda: a expressiva não entra em degrau nenhum; o portão dos modelos
(ADR 03p) fecha os dois degraus na suíte e na varredura.

## ADR 2026-09-04u — Folha nasce inteira

**Palavra do dono (04/set):** *"layout totalmente quebrado, o card nasce
cortado, em vez de subir até o teto da tela."* Era a Lente: cinco perguntas
da sábia atrás da borda de um detente médio.

A ADR 04a já tinha pegado o mesmo defeito na ficha do compromisso e o
consertou só lá. A regra agora é geral: **folha que se lê ou se preenche
nasce no detente grande.** `[.medium, .large]` não escolhe pela ordem e
nasce no médio; o médio só serve a uma folha de uma linha (a ficha do
sistema, só leitura, continua nele). Mudaram: Lente, Ligações, Versões, a
série da expressiva e a folha dos campos.

E a Lente perdeu ruído: o "Pronto" em cápsula pesava mais que o título
(`von-restorff-effect` invertido) e virou texto, como nas outras folhas; o
título usa os tokens da casa; "nada a apontar" entrou na linha de metadados
em vez de ser um parágrafo solto (`critique-information-density`); as
descrições das seções cabem numa linha.

## ADR 2026-09-04v — A volta que cobra

**A distância.** A segunda volta do ciclo (ADR 04g) é o autor confrontando o
que escreveu com o que aconteceu: o "aconteceu" da Decisão, o "roubou" do
Dia, o "quanto agora" da Atualização, e qualquer campo `soDepois` de método
do autor. A hora de cada um já estava escrita na Sessão (`conferenciaDevida`)
— e só valia com a nota aberta. Sem lembrar de reabrir, a volta não vinha. A
Decisão com data avisa (ADR 03d); as outras morriam caladas. Motor sem
superfície (ADR 04a): não existia.

**A decisão.** A regra sai da Sessão para `Volta`, pura, uma só para a página
e para a lista. As Notas abrem com a seção **A VOLTA** quando há nota com
campo de volta devido e vazio: a linha diz o rótulo do campo em forma de
cobrança ("O que roubou o dia?") e o título da nota; um toque abre a página,
onde o campo já espera (ADR 03a). Sem nada devido, a seção não existe.

**Em qual volta entra:** na segunda, melhorar. **O que a IA sabe:** nada —
é algoritmo e relógio; a IA nunca lê nem escreve aqui. O que o autor
responde na volta é o que alimenta a calibragem (ADR 03o) e o retrato.

**Fora:** aviso novo (a fila de Recordar e o gatilho da Decisão já cobrem
os que avisam; a volta é o que se vê ao abrir o app), contagem na aba,
degrau. O selo: trancada, queimada e expressiva nunca têm volta.

## ADR 2026-09-04w — O caderno chega antes do compromisso

**A distância.** O app de 2036 lê o calendário e o caderno e põe na frente
do autor, antes de ele pedir, o que a própria mente já pensou sobre o que
vem. Hoje o compromisso e as notas não se conhecem: o autor entra na
reunião de orçamento sem a nota em que decidiu o orçamento — a não ser que
lembre e busque.

**A decisão.** A ficha do compromisso (a do Traço e a do iPhone) ganha a
seção **DO CADERNO**: até três notas cujo sentido é vizinho do título e das
notas do compromisso, pelo índice de sentido (ADR 04n), no aparelho, sem
rede. Um toque abre a nota. Sem vizinha, a seção não existe. A ficha do
iPhone deixa de ser folha de uma linha e passa ao detente grande (ADR 04u).

**Em qual volta entra:** na primeira, multiplicar — a memória chega antes
do ato. **O que a IA sabe:** nada além do vetor do título; não escreve, não
resume, não liga por conta própria (ADR 03b: quem liga é o autor). Selo:
trancada, queimada e expressiva nunca aparecem.

**Fora:** aviso com a nota dentro, ligação gravada, sugestão na hora de
marcar.

## ADR 2026-09-04x — O degrau ouve o sinal

**A distância.** O degrau da instigação (ADR 04j) subia só com a prática:
quantas notas da forma o autor concluiu. O sinal "não serviu" (ADR 04h) ia
ao retrato como classe a evitar, mas não mexia na dificuldade. Uma mente
que diz duas vezes "isto não serviu" e recebe o mesmo degrau não está sendo
ouvida; e quem diz "serviu" duas vezes seguidas está pronto para o degrau de
cima antes de completar a contagem.

**A decisão.** O degrau de uma forma é a prática **mais o ajuste dos dois
últimos sinais de pergunta dessa forma**: dois "não serviu" descem um; dois
"serviu" sobem um; misto ou menos de dois, nada. Fica entre 0 e 4. É
algoritmo, nunca o modelo (ADR 03i). O Perfil, em A SÁBIA E VOCÊ, mostra o
degrau por forma em que há sinal — o autor vê o que a IA vai cobrar dele.

**Em qual volta entra:** na segunda, melhorar: o estímulo muda com a
resposta. **O que a IA sabe:** o número do degrau na instrução, como já
sabia. **Fora:** degrau por pessoa (é por forma), degrau na prova do
Recordar (a escada dela já é adaptativa), qualquer palavra da IA no ajuste.

## ADR 2026-09-04y — O anexo entra no sentido

**A distância.** "Compreensão e aprendizado de fora não entram" tinha sido
respondida só na forma (Leitura, ADR 04l). O PDF anexado continuava arquivo:
o índice de sentido (04n) via a voz do autor e nada do que ele leu. Um
segundo cérebro que não acha o relatório pelo assunto do relatório não o
guardou.

**A decisão.** No índice, o vetor de uma nota com PDF anexado nasce da voz
do autor **mais o texto das três primeiras páginas do PDF**, lido pelo
PDFKit no aparelho, cortado. Só o vetor: o texto do PDF não vai à nota, ao
retrato, à rede nem ao corpus — nunca sai do aparelho. A voz vem primeiro:
o que o autor escreveu pesa mais do que o que leu. A entrada do Mac (04p)
passa a sincronizar o índice na hora (era só no arranque seguinte: achado).

**Superfície:** PELO SENTIDO nas Notas, DO CADERNO na ficha (04w) e a linha
"?" (04n) passam a achar a nota pelo assunto do anexo. **Em qual volta
entra:** na primeira, multiplicar. **O que a IA sabe:** um vetor a mais. O
selo corta antes, como sempre: trancada e queimada saem do índice, e o
anexo com elas. **Fora:** epub, imagem com OCR, resumo do PDF (a IA não
escreve), texto do PDF na busca por letras.

## ADR 2026-09-04z — As ilhas novas se encadeiam

**A distância.** A ADR 04k fez as formas se encadearem e a 04l trouxe oito
métodos novos como dado; mas os oito nasceram sem encadeamento nenhum. A
transferência entre faculdades, onde o poder se multiplica (ADR 04g), parava
exatamente nas faculdades que faltavam: criação, compreensão, estratégia,
calibragem.

**A decisão.** Oito encadeamentos, só no `Metodos.json`, com as palavras do
autor copiadas pelo mapa e o `[[origem]]` no destino (mecanismo da 04k, sem
uma linha de código): Feynman e Analogia → Nota permanente (o que expliquei
ou trouxe, nas minhas palavras); Inversão → Pré-mortem (como garantir que
falhe é a falha nomeada) e → Se–então (o que evito, vigiado); Steelman →
Argumento (a posição contrária vira a objeção, a resposta vira a resposta);
Divergência → Decisão (as dez opções cruas são as opções); Primeiros
princípios → Especificação (o que construo do zero é o problema);
Prática deliberada → Se–então (o pedaço que falha dispara o exercício) e
→ compromisso em 7 dias para medir; Atualização → Decisão (o que acredito
é o que decido). Cada um exige o campo de origem respondido.

**Superfície:** a linha DEPOIS DISTO já existente, agora também nas oito
formas. **Volta:** a primeira, multiplicar. **A IA:** nada; é cópia. **Fora:**
encadeamento automático (o gesto é do autor), cadeias de três.

## ADR 2026-09-05a — Anotar de qualquer lugar

**A distância.** A entrada (ADR 04p) aceita o que o Mac deixa em `entrada/`.
No próprio iPhone, fora do app, a mente não tinha por onde entrar: uma
frase na rua, no carro, no meio de outro app, tinha de esperar abrir o
Traço e a página. O que espera se perde.

**A decisão.** O intent **Anotar** (Siri, Atalhos, botão de Ação, sem
abrir o app) e a rota `traco://anotar?texto=…` depositam a frase em
`entrada/` com a hora, pelo mesmo caminho do Mac; o app a recolhe ao voltar
à cena (o intent) ou na hora (a rota), e diz "1 nota veio de fora." A nota
entra aberta, como toda entrada. Zero código novo de importação.

**Volta:** a primeira, multiplicar — o segundo cérebro recebe de onde a
pessoa está pensando. **A IA:** nada. **Selo:** import jamais tranca.
**Fora:** extensão de compartilhamento (pede app group e provisionamento do
dono), ditado próprio (o de Siri serve), anexos pela rota.

## ADR 2026-09-05b — O dia diz o que espera

**A distância.** A VOLTA (ADR 04v) vive nas Notas. O autor abre o app na
página em branco, onde a única companhia do cursor é a data — e a data não
sabe que há uma decisão a conferir ou um dia de ontem por fechar. Quem não
vai às Notas não vê.

**A decisão.** Sob a data da página em branco, uma linha quieta, só quando
há o que conferir: "1 volta a conferir". Um toque leva às Notas, onde A
VOLTA já espera. Some ao primeiro caractere, como a data, e não existe
quando não há volta devida: não é cartaz (ADR 04f), é a data dizendo o que
o dia espera. Não é pausa: é a porta do ato (ADR 04r).

**Volta:** a segunda, melhorar — a conferência chega antes de ser lembrada.
**A IA:** nada; relógio e algoritmo. **Fora:** o próximo compromisso na
mesma linha (a tela bloqueada já o tem), contagem na aba, aviso.

## ADR 2026-09-05c — O campo do calendário nunca se preenche sozinho

**Palavra do dono (05/set):** *"isso aqui é uma ideia boa, mas o uso está
deplorável: muitas vezes eu quero digitar e ao clicar aparece tudo do
placeholder."*

**O defeito.** A ADR 03c fez o toque no campo ACEITAR a recomendação: a
frase cinza virava texto, e a primeira tecla devia substituí-la. Na mão, a
substituição depende de o iOS entregar a tecla como o código espera;
autocorreção, ditado, colar e o cursor no meio deixam a frase no campo, e o
autor apaga tudo antes de escrever. Em todo campo do iPhone o texto cinza é
fantasma: some ao digitar e nunca vira conteúdo (`jakobs-law`,
`critique-affordance`).

**A decisão.** O campo nunca se preenche sozinho. A recomendação fica onde a
ideia era boa: no cinza, como exemplo da língua do campo ("Stand-up do
Rafinha depois de amanhã 21h"), com a ida e volta do parser garantindo que
a frase funcionaria. Tocar o campo é tocar um campo: cursor, teclado, nada
dentro. Sai o mecanismo de substituição pela primeira tecla e o estado
`sugestaoNoCampo`. Quem quiser marcar exatamente a sugestão a digita ou a
dita; ela já está no calendário do sistema de qualquer jeito, e marcar de
novo no Traço só a duplicava na grade.

**Fora:** botão para aceitar a sugestão (duplicaria um compromisso que já
existe), sugestão de compromisso novo por IA.

## ADR 2026-09-05d — O domínio pela IA, e o chip que não apaga

**Palavra do dono (05/set):** *"Não seria interessante utilizar a IA para
classificar em vez de algoritmo?"* e *"Não faz o menor sentido clicar [no
chip] ser uma forma de remover. Eu posso clicar sem querer. Se eu quiser
tirar o domínio é só ir nas configurações dessa nota."*

**O que estava errado.** (1) O léxico desempatava pela ordem da lista:
"chegar em casa … vou ler" batia Casa e Estudo com um ponto cada, e Casa
ganhava por posição, contra a própria ADR 02c ("sem confiança = silêncio").
(2) O toque no chip apagava o domínio e travava a nota: um alvo de 44 pt
que destrói sem confirmar e sem cara de botão (`critique-affordance`);
quem tocava para ver, perdia.

**A decisão.**
1. **O domínio é da IA do aparelho.** O léxico continua como primeira
   resposta, imediata e sem modelo, mas empate é silêncio. Ao salvar, se o
   autor não travou, o modelo de bordo (FoundationModels, sem rede, sem
   conta) classifica a voz numa lista fechada de sete mais "nenhum" e
   corrige o rótulo. Nunca a rede: a rede é para o que o aparelho não
   resolve (ADR 04t), e sete rótulos ele resolve. Com os motores desligados
   (ADR 03p), fica o léxico.
2. **O chip não apaga.** Tocar o chip abre o menu do domínio: os sete e "Sem
   domínio"; a escolha trava a nota. "Devolver ao app" destrava e a IA volta
   a decidir. O mesmo menu no cartão da página e na lista. Nada destrói num
   toque.

**Volta:** a primeira, multiplicar (a ordem sem bibliotecário fica certa
mais vezes). **O que a IA sabe:** a voz da nota, no aparelho; a expressiva
nunca. **Fora:** domínio pela rede, domínios novos, cor por domínio.

## ADR 2026-09-05e — A barra de baixo: buscar ou perguntar

**Palavra do dono (05/set):** *"Essa barra de pesquisa no topo deveria estar
embaixo. Um dos maiores poderes desse aplicativo é IA. Se eu quiser
perguntar alguma coisa, se eu nem sei quais fórmulas usar, a caixa desce,
tem um botão, ao escrever manda uma pergunta e sobe um card simples onde eu
converso rapidamente no contexto do Traço. O ambiente se forma a partir do
que é necessário."*

**O que estava errado.** A busca vivia no topo, zona morta do polegar
(`fitts-law`), e só buscava por letras e sentido. A sábia só respondia
dentro de uma nota, à linha "?": para perguntar "que método uso para
isto?" o autor tinha de abrir uma página e escrever a pergunta nela.

**A decisão.** Nas Notas, uma barra no pé da tela, acima da navegação e
acima do teclado: "Buscar ou perguntar". Escrever filtra a lista como
antes (letras primeiro, sentido atrás). Enviar pergunta à sábia, e um
cartão sobe sobre a barra com a resposta; a barra continua ali para a
pergunta seguinte, e a conversa curta (as últimas trocas) viaja junto. O
cartão só existe enquanto há conversa; "Fechar" a apaga. Sem conta, o
cartão diz por onde a sábia responde.

**O que a sábia vê.** As notas vizinhas da pergunta pelo índice de sentido
(ADR 04n), inteiras até um teto; o catálogo de métodos, nome e definição,
para poder dizer qual forma serve; o retrato (ADR 04i); e as trocas
anteriores desta conversa. Nunca a expressiva, a trancada, a queimada. A
resposta é informação, opções e critérios (ADR 02o): a sábia pode dizer
"isto pede um Pré-mortem" e por quê; nunca escreve a nota.

**Fora:** histórico de conversas (o cartão morre ao fechar), a barra em
outras abas, a sábia escrevendo na página a partir daqui.

## ADR 2026-09-05f — Polimento: o que o dono viu, e o que a auditoria achou

**Palavra do dono (05/set):** *"layout, experiência, design, componentes e
animações mais porcas que eu já vi… quero acabamento ultra premium, anos de
polimento."* Com três capturas: a caixa cinza atrás de "Mais recentes", a
mesma atrás do chip ESTUDO, e o cursor sobre o exemplo do campo.

**Auditoria com lei, tela a tela, sobre as capturas dos fluxos de auditoria.**
Achados corrigidos nesta rodada:
1. **A caixa atrás dos menus.** O rótulo de um `Menu` tinha um frame
   retangular de 44 pt, e o iOS realça o retângulo inteiro ao abrir. O
   rótulo passa a ser só a cápsula; o alvo de 44 pt vive no `Menu`
   (`critique-affordance`). Vale para o chip do domínio e a ordem das Notas.
2. **O topo das Notas.** "Mais recentes" e "Como contexto" eram texto solto
   no canto, sem cara de botão e vestidos como navegação
   (`law-of-similarity`, `critique-affordance`). A ordem vira cápsula com
   seta; o contexto vira o ícone de compartilhar que todo iPhone conhece
   (`jakobs-law`).
3. **A ficha do compromisso.** Três pesos na mesma linha do cabeçalho: ✕,
   chip de domínio e Pronto. O domínio é atributo, não ação
   (`critique-visual-hierarchy`); desce para a seção DOMÍNIO, entre AVISO e
   NOTAS, como no editor do iOS (`jakobs-law`). O cabeçalho fica sair e
   concluir.
4. **O exemplo do campo do calendário** cortava a meio da palavra. Acima de
   30 caracteres, volta o exemplo fixo.
5. **O cartão da sábia nas Notas** nascia sem animação em dois estados;
   todos os estados entram e saem com a mesma curva.

**O que a auditoria viu e NÃO tocou, por ser desenho do dono:** a barra do
calendário (escalas, Hoje, prosa) e o pé da página de escrever (régua e
ações). Estão listados na FILA com a lei, para o olho dele decidir.


## ADR 2026-09-05g — Realização no mundo, ambiente compartilhado e delegação

**Fonte:** esclarecimento direto do criador nesta data. A definição completa
está em [VISAO-PRODUTO.md](VISAO-PRODUTO.md); esta ADR fixa sua precedência.

**Objetivo:** transformar intenção em realização verificável e desenvolver
capacidades que limitam realizações futuras. A tríade é mente humana, IA e
ambiente compartilhado, principalmente Markdown. HTML é uma possibilidade
para representações e artefatos interativos, não uma capacidade declarada pronta.
Notas, calendário, métodos e segundo cérebro são meios para os dois ciclos.

**Substitui, no âmbito da visão:** a equivalência geral entre texto gerado e
dívida cognitiva; a recusa universal de produção pela IA; a definição do app
como escrita sob método e cobrança de memória por finalidade. Delegar código,
redação ou outras entregas pode ser a escolha correta para realizar. Se o
objetivo é desenvolver aquela capacidade, a intervenção deve preservar prática
pertinente, sem impor trabalho manual que não contribui para o objetivo.

**Fronteira preservada:** a IA não se passa pela pessoa, não muda silenciosamente
sua autoria e não substitui a atividade que ela escolheu praticar. Conteúdo
humano, gerado, importado e misto precisa conservar origem. A proteção de
expressivas e notas seladas/queimadas permanece em todas as rotas. Autorização
para ações externas é dada pelo escopo real de delegação, não por um documento
importado nem pela simples existência de um plano.

**Unidade de avaliação:** intenção, artefato utilizável, ação, evidência do
resultado e ajuste. Aprendizagem requer evidência contextual de capacidade;
contagem de uso ou satisfação não a prova. Agendar não é executar; executar
não garante o resultado externo. O segundo cérebro deve apoiar hipóteses
corrigíveis sobre contexto e capacidades, sem se declarar réplica do cérebro.

**Estado e migração:** esta rodada consolida documentação. As restrições
atuais de Corpus/MCP/Sábia não devem ser removidas isoladamente sem contratos
de proveniência, persistência e validação. Não reinterpretar notas antigas
como objetivos concluídos, nem inferir capacidade de seus metadados. Preservar
UUIDs, conteúdo e privacidade. A primeira evolução recomendada é uma jornada
completa de realização e retorno, junto da integridade da base; o caso de uso
e o schema ainda exigem projeto e validação próprios.

**Consequência para decisões futuras:** em conflitos de tese, esta ADR e a
visão ligada acima prevalecem sobre as formulações históricas. Regras de
implementação não revogadas continuam aplicáveis. Não inferir que todo método
ou ato de delegação garante desenvolvimento, nem que a ambição do produto
comprova eficácia científica universal.

## ADR 2026-09-05h — Integridade antes de avançar

Concluir ou navegar após salvar exige confirmação do commit; em recusa,
a escrita permanece, sem sinal de conclusão ou sucesso. “Guardada” refere-se
à gravação no aparelho; backup assíncrono não pode ser anunciado como confirmado.

Entrada passa a ler sem destruir. Um recibo de importação e as notas são
persistidos juntos (schema V3 aditivo, Nota preservada); somente depois se
retira a mesma versão do arquivo. Repetir coleta após commit/queda não duplica
notas, inclusive se a nota importada já foi apagada. Arquivo alterado depois
da leitura permanece para a próxima coleta. Entradas recusadas pelo selo
permanecem como fonte, sem serem convertidas nem destruídas silenciosamente.

Campos exportados usam bloco identificado `<!-- traco-campos:json-v1 -->`,
com cada valor como string JSON após seu identificador. Quebras, vazios e
espaços significativos devem sobreviver; import aceita id/rótulo legado.
Proteção selada/queimada vem do cabeçalho, não de uma frase do corpo.
Bookmark inválido limpa o estado sem tentar resolver novamente o mesmo dado.

Critérios: injeção de recusa, replay após commit, edição antes de retirada,
round-trip de campos hostis, migração V2→V3 preservando notas e recuperação
de bookmark inválido. Esta etapa não certifica corridas de outras projeções
nem encerra os demais requisitos da visão de produto.

## ADR 2026-09-05i — Trabalho persistente, produção delegada e retorno

A primeira jornada da visão05g usa um agregado Trabalho independente da nota
pessoal: intenção/revisões, resultado desejado, versões de artefatos com origem,
ações e evidências atribuídas, e hipóteses de capacidade corrigíveis. Schema V4
adiciona esse agregado; V1–V3 e notas existentes permanecem preservados.

Cada revisão guarda conteúdo e identidade. Artefato tem versão/UUID, origem,
formato e vínculo à revisão da intenção. Ação referencia material específico;
agendar não executa e executar não demonstra resultado. Relato é relato do
autor, não observação independente nem prova de aprendizagem. Hipótese registra
fontes/contexto e quem a confirmou ou contestou; contestação participa do
próximo pedido. Delegar/praticar/combinar é escolha contextual sem penalidade.

A IA pode produzir Markdown quando delegada no Trabalho, por provider real,
com origem visível; indisponibilidade mantém pedido e versões, sem geração
simulada. HTML permanece representação adicional a implementar conforme a
matriz EVOLUCAO.md. Notas expressivas/seladas não são elegíveis como origem
implícita nem fonte automática. A nota de origem não é sobrescrita.

Pedido de geração tem identidade e revisão do material. Cancelamento/edição
invalida respostas antigas; callback válido aplica ao agregado vigente e não
substitui evidências adicionadas durante a espera. Reabertura reconhece pedido
sem executor como interrompido. Commit precede anúncio/export/navegação; erro
preserva rascunho e história. O contrato detalhado deve ser implementado e
verificado em jornada real, sem equivaler aprovação desta fatia à conclusão
integral da visão.

### ADR05j — Proteção da origem acompanha o trabalho derivado

Selar, tornar expressiva, queimar ou remover a nota de origem restringe o
Trabalho derivado inteiro. A cópia não volta a ser pública por desaparecer a
fonte. Conteúdo e referência permanecem guardados; não se apagam versões ou
rascunhos como efeito do bloqueio. A lista usa identificação neutra e a busca
não examina títulos restritos. Abertura, geração, retorno assíncrono e cópia
revalidam a origem. A interface retira material visível quando o acesso muda,
incluindo rascunhos e cópias de recuperação. Metadados inválidos restringem a
abertura em vez de presumir autorização. Trabalho criado sem nota de origem
continua independente. Recuperação/desvinculação exige uma rota explícita;
não liberar silenciosamente o conteúdo nem apagar a referência para contornar
a proteção.

### ADR05k — Ação do Trabalho aparece no calendário sem cópia autônoma

O horário pertence à ação no agregado Trabalho. O calendário projeta apenas
ações pendentes elegíveis, identificadas pelo UUID da ação e do trabalho. Um
horário sem duração informada é um marco, exibido com uma única hora; não
inventa término, aviso, execução ou resultado. Encerrar o Trabalho não cancela
implicitamente suas ações. Executar/cancelar retira a projeção pendente e
conserva o horário histórico; retirar horário não apaga ação ou relato.

Commit precede confirmação e navegação. A edição recusada fica identificada
como pendente; o calendário mantém o último valor confirmado. Ver no calendário
abre o dia confirmado e só fecha o editor após navegação efetiva. Tocar a
projeção revalida a origem e abre o Trabalho na ação correspondente. Proteção,
exclusão e retorno de cena revalidam as projeções.

A projeção não pode virar compromisso autônomo por export/import, edição
genérica, widget ou aviso. Barreiras de codificação, disco e publicação
preservam essa distinção. Alertas de ação ainda não estão implementados e a
interface informa isso. As rotas reais de marcar/ver/abrir/retirar foram
exercitadas no simulador; isso não prova execução da ação no mundo.

### ADR05l — Markdown editável fora do Traço, com retorno ao histórico

A versão Markdown do Trabalho pode sair como arquivo UTF-8 `.md`, com corpo
legível e comentário de protocolo v1 contendo trabalho, artefato e intenção
de origem e SHA-256 do conteúdo original. O hash confere a base local; não
autentica autoria nem exige que o corpo editado permaneça igual. Importar
não executa HTML, anexos ou instruções contidas no texto.

O seletor de arquivos leva a uma prévia antes de qualquer aplicação. Ela
distingue base atual, base antiga, material sem vínculo e arquivo incompatível.
Base antiga exige confirmação explícita e identifica a versão vigente; mudança
de intenção é avisada antes de aplicar. A nova versão mantém ancestral e
intenção da base. Material sem envelope entra como externo, sem ancestral
presumido, no contexto escolhido pelo autor. Envelope inválido, base/hash
incompatíveis ou outro trabalho não se tornam material sem vínculo
silenciosamente. A atribuição é “Arquivo importado · autoria não verificada”.

Aplicar acrescenta uma versão, preserva história, ações e evidências e invalida
geração precedente. Versão e intenção vigentes são revalidadas após a prévia;
mudança exige nova revisão. Commit precede confirmação: recusa conserva o
candidato, e retry confirma a mesma versão sem duplicá-la. O limite de 2 MiB
recusa arquivos maiores sem truncar; UTF-8 inválido é recusado, e corpo,
quebras e BOM sem envelope são preservados. Prévia parcial é identificada e
não corta o conteúdo importado.

Acesso à origem é revalidado antes da exportação, após leitura e ao aplicar.
Uma cópia já entregue ao Files ou a outra ferramenta não pode ser recolhida
por proteção posterior do Trabalho. Revogação com seletor/exportador aberto
ainda precisa de validação visual; não se declara essa rota comprovada.

Evidência desta integração: suite integral com 536 testes e zero falhas;
exportador Files salvou `traco-versao.md`, sem acrescentar `.txt`; uma cópia
sintética editada externamente, preservando o cabeçalho, voltou pelo importador
com prévia da base v3 e autoria não verificada. Confirmar criou v4, com quatro
versões no histórico. Leitura do banco confirmou corpo importado byte a byte,
base v3 intacta e ancestral v4→v3, mantendo ação pendente ligada à v1 e relato.
A captura `markdown-historico-preservado.png` registra a lista das quatro versões.
HTML interativo, sincronização
contínua e conclusão integral da visão permanecem fora dessa evidência.

## ADR 2026-09-05m — A sábia preserva o que precisa ler

**A distância.** O corte cego do aparelho (teto de 3.500 caracteres, ADR 04t)
podia remover a pergunta em `responder` ou a memória do autor em `conferir` e
ainda produzir uma resposta; e `parseVoltaram` convertia booleanos em índices
de pontos, alimentando Sinais e Retrato com uma conferência falsa sobre a
memória do autor, que depois viajava à rede. Achados P1 da revisão de 05/set.

**A decisão.** A montagem preserva pergunta, nota/alvo e cabeçalhos; sacrifica
retrato antes de contexto, método ou pista, e candidatas nos ecos. Carga que
não cabe devolve nil. O transporte não corta mais: mensagem acima do teto é
recusada, nunca truncada. A conferência conserva pontos, todos os índices e a
memória completos ou cala, em qualquer caminho (remoto ou aparelho): memória
acima de 4.000 ou ponto acima de 400 caracteres não gera veredito. Recusa de
orçamento não é memoizada. O parser recusa booleanos, frações, strings,
índices inválidos e qualquer chave além de `voltaram`; lista vazia é válida.

**Custo assumido, nomeado:** vestir, calibragem e Padrões (até 9.000
caracteres) só seguem no aparelho se a mensagem couber inteira; acima do
teto, calam onde antes o corte cego era verificado contra vozes inteiras.
Montagem por item para essas três rotas fica na FILA.

**Volta:** melhorar na conferência do Recordar; multiplicar ao responder.
**O que a IA sabe:** só a carga preservada e o contexto que coube.
**Prova:** 17 testes focados (`SabiaOrcamentoTests`) e suíte integral 565/0
no simulador de teste; nenhum teste comprova a qualidade semântica do modelo.
**Fora:** reparo de sinais antigos, UI nova, mudança de autoria, validação
semântica do provedor.

## ADR 2026-09-05n — A ação do Trabalho avisa

**A distância.** A ação pendente entrava no calendário "sem alerta" (a ADR
05k declarava não implementado) e, pela ADR 04a, o que se marca e não avisa é
como não marcado: a ponte do calendário (visão 05g) ligava a intenção a um
horário que ninguém ouvia.

**A decisão.** O aviso mora na ação (`Acao.avisoMinutos`, lista fechada de
`Aviso.opcoes`; chave ausente = sem alerta, como foi prometido às ações
antigas; sem horário, sem aviso). A folha do horário ganha o seletor em
cápsula e mostra UMA linha de estado: antes de guardar, a promessa em hora
real ("Toca sexta-feira, 11 de set. às 13:55 · 30 min antes"), e só quando a
permissão não está negada; depois do commit, o que aconteceu de fato:
marcado, sem permissão (com "Abrir os Ajustes"), sem espaço no teto de 64,
hora passada, ou "não está marcado no iPhone — guarde de novo". Ao abrir a
Oficina, o estado é lido do centro de notificações e da permissão de hoje,
nunca presumido. O motor (`Revisoes.agendarAcao`) arma UMA notificação
`timeSensitive` no namespace `acao-<id>`, e a Oficina só sincroniza depois de
o disco aceitar: executar, cancelar, retirar e mudar o horário calam ou
reagendam num ponto só. Selar, queimar ou apagar a nota de origem cala no ato
os avisos dos Trabalhos derivados (ADR 05j). O calendário projeta o sino; a
projeção continua só leitura. O toque na notificação abre o Trabalho na ação
pela mesma rota da projeção, revalidando a origem; o toque expira em 5 min.

**Volta:** a primeira, multiplicar: o próximo ato acontece na hora porque o
autor é avisado. **O que a IA sabe:** nada; relógio, algoritmo e a escolha do
autor. **Prova:** suíte integral 576/0 no simulador de teste; fluxo
`maestro/trabalho-acao-aviso.yaml`; capturas antes/depois/reaberta. O estado
"sem permissão" na folha reaberta não é encenável no simulador (a permissão
fica indeterminada); está provado por teste com permissão injetada e pela
captura logo após guardar. **Fora:** repetição, duração, widget/Ilha da ação,
re-armar ao liberar a origem (a folha diz que não está armado), fila de
prioridade do teto (ADR 04b), rota de apagar Trabalho (não existe; quando
nascer, precisa do mesmo gancho). A notificação não cria compromisso nem vai
ao disco do calendário (ADR 05k).

## ADR 2026-09-05o — O método volta com a nota

**A distância.** `Gesto.doNome` recusava id que sumiu do catálogo: o autor
apagava o método da pasta e o corpus reimportado devolvia a nota como prosa,
sem gesto e sem campos, enquanto `init?(rawValue:)` já aceitava o mesmo id no
disco. O arquivo só levava o NOME, e por ele delimitava os campos. No
aparelho, cabeçalho de método e de pista viajavam vazios, o "não a reescreva"
sumia em `responder` local, e nota longa deixava lugar para zero candidatas de
eco. Achados P2/P3 das revisões de 05/set.

**A decisão.** `doNome` aceita o id gravado, desde que tenha cara de id (sem
espaço, até 64 caracteres): frase livre num `gesto:` de arquivo alheio não
vira id. O cabeçalho leva `metodo: <id>` quando o id não é o nome, e o import
prefere o id ao nome; o bloco de campos é delimitado pelo marcador (ADR 05h),
não pelo rótulo. No aparelho o contexto virou seção: rótulo e conteúdo
indivisíveis, a ordem é a prioridade, e a seção que não cabe sai inteira com o
rótulo — exceto o contexto da nota em `responder`, que perde a cauda até um
mínimo de 200 caracteres antes de sair. A proibição de reescrever a nota é a
mesma constante nos dois caminhos. Ecos exigem duas candidatas inteiras ou
calam.

**Custo assumido, nomeado:** como os 21 métodos têm id ≠ nome, todo `.md` com
gesto ganha a linha `metodo:` e é reescrito UMA vez, nas duas pastas
(Documents e iCloud), na primeira rota de selo depois desta versão (selar,
queimar, apagar, sentido do fecho), síncrona na thread principal como manda a
ADR 04o; a ordem por data do `traco_notas` no Mac muda nesse momento.

**Volta:** multiplicar. **O que a IA sabe:** só o que coube, com rótulo.
**Prova:** 10 testes novos (CatalogoTests, SabiaOrcamentoTests), suíte
integral 578/0 no simulador de teste. **Fora:** montagem por item de
vestir/calibragem/Padrões, caminho remoto, dizer na tela que o método sumiu.

## ADR 2026-09-05p — A conferência do artefato contra o pedido

**A distância.** O `MotorTrabalho.sistema` já mandava conferir idioma, duração
e destinatário, mas a única prova de qualidade que o Trabalho tinha era "texto
não vazio". O caso real de 05/set (EVOLUCAO, linha "IA produz trabalho
delegado com origem") saiu omitindo tempos e traduções e misturando idiomas, e
nada na tela dizia isso. Reforçar o prompt não é evidência.

**A decisão.** Cada versão produzida guarda `Artefato.conferencias`
(opcional; ausência no disco é SEM conferência, nunca "sem divergências"),
presa ao `pedidoID` que a produziu e à revisão da intenção — nunca ao último
pedido. A extração ancora cada critério num trecho LITERAL do pedido vigente,
com instrução > resultado desejado > intenção, e a gramática é pequena e
declarada: idioma explícito (inclusive papéis bilíngues, "frases em X com
tradução em Y" = dois idiomas no escopo) e distribuição temporal ("N blocos de
M minutos", "X minutos"). O léxico de tempo é UM SÓ para o pedido e para o
artefato — dígitos, número por extenso até trinta, "5'" e "meia hora": ler o
artefato com gramática mais pobre que a do pedido faz a tela afirmar "nenhuma
marca de minutos" sobre artefato que escreveu "cinco minutos" (correção da
revisão de 05/09). O que não casa fica `naoAvaliado` e aparece contado
na linha. O idioma é lido por `NLLanguageRecognizer` no aparelho, por trecho
de prosa com pelo menos 40 caracteres (cabeçalho, tabela e código ficam fora),
instância nova por trecho; confiança baixa é `inconclusivo`, e bilinguismo
declarado não vira erro. O tempo confere quantidade E soma, sem contar o total
do cabeçalho duas vezes; "não encontrei distribuição" é dito com essas
palavras e não vira "os tempos somam errado". Roda automaticamente depois de
`receber` — a versão vai ao disco PRIMEIRO e a conferência é um segundo
commit, então falhar aqui não perde o artefato — e sob demanda em "Conferir de
novo". Só a versão vigente recebe registro: retorno sobre versão antiga é
recusado. O acesso à origem é revalidado antes de ler e antes de mostrar (ADR
05j); o intercâmbio Markdown (05l) não exporta nem importa conferência. Acima
de 200.000 caracteres a conferência fica `indisponivel` em vez de ler um
pedaço (05m). A linha na versão nunca diz "verificado" ou "aprovado", e não
bloqueia ler, copiar ou usar.

**Custo assumido, nomeado:** a checagem lê REGRA, não sentido. Um artefato sem
nenhuma tradução passa no critério de idioma, porque idioma por bloco não vê
papel — foi o que aconteceu no caso real (prova/4.md). O critério
`naoAvaliado` de destinatário/conteúdo existe para essa mentira não caber na
tela: ele diz, em toda conferência, que ninguém leu o conteúdo.

**Volta:** multiplicar. **O que a IA sabe:** nada de gerativo — regras e o
reconhecedor de idioma do aparelho, sem rede. **Prova:** 24 testes
(`ConferenciaTrabalhoTests`), suíte integral 602/0 no simulador de teste, e um
caso real executado e lido em prova/4.md: a conferência apontou o tempo e
deixou passar a ausência de traduções, como a própria justificativa declara.
**Fora:** segunda passada da IA ("Conferir com IA"), adequação semântica e ao
destinatário, comparação com/sem histórico, e a jornada pela tela — o portão
`Motores.desligados` (03p) desliga o modelo dentro do XCTest, então o caso real
foi executado por sonda não commitada, fora da `TrabalhoView`.

## ADR 2026-09-05q — Conferir com a IA, e pedir o ajuste num toque

**A distância.** A conferência de 05p lê FORMA: no caso real de prova/4.md ela
apontou o tempo e DEIXOU PASSAR a ausência de traduções, porque idioma por
bloco não vê papel. E a divergência era beco — o autor tinha de reescrever o
pedido à mão. Versão que ficou sem conferência não dizia nada na tela.

**A decisão.** Dois botões de texto no disclosure, nenhum automático.
"Conferir com IA" monta SESSÃO NOVA com intenção, resultado, instrução
vigente, o artefato INTEIRO e os critérios que a checagem local extraiu, sem
dizer quem produziu; pede JSON estrito `{"criterios":[…]}` e grava OUTRA
`Conferencia` AO LADO da local, com o provedor EFETIVO devolvido por
`Sabia.chamarComProveniencia` mais "· revisão assistida", data e método —
configuração não prova executor. Uma chamada por toque; `gerar` nunca chama. O
parser derruba a revisão inteira para `indisponivel` por chave fora das seis
do contrato, `fonte`/`situacao` fora da lista, campo faltando ou JSON
inválido: recusa não vira ausência de problema. Citação não literal do pedido
ou do artefato derruba só AQUELE critério para `inconclusivo` com "citação não
encontrada", apagando a citação inventada; e citação válida não certifica
interpretação. ADR 05m: pedido, artefato e critérios cabem inteiros na janela
ou a revisão fica `indisponivel` por "limite do aparelho", sem cortar. O
acesso à origem (05j) é revalidado antes de enviar, depois do await e antes de
gravar. Favorável diz "a IA não apontou divergências nos critérios
examinados", nunca "aprovado". "Pedir ajuste" surge com divergência: preenche
o CAMPO do pedido com "Ajustar a versão anterior:" e uma linha por
divergência, nas palavras da conferência, e leva o foco ao campo — o autor
edita e toca "Preparar nova versão com IA", a rota de sempre. Versão sem
conferência mostra "Conferência: não feita · Conferir".

**A decisão da volta 5 (revisão independente de 05/09/2026).** "Conferir com
IA" só aparece com `ContaGrok.ligada` — o único provedor que hoje devolve a
revisão estruturada. Sem conta, no lugar do botão fica UMA linha: "Revisão
pela IA precisa da conta Grok; o modelo do aparelho não devolveu revisão
válida." Sem link para criar conta e sem cartaz: a linha informa, não vende. O
caminho local continua no código e provado por teste, para quando o modelo de
bordo servir — só não é oferecido como decisão na tela. A condição é o
PROVEDOR, não o tamanho: no segundo caso real a montagem COUBE (2.997 ≤ 3.500)
e mesmo assim nada utilizável voltou; portão por tamanho ofereceria o botão
justamente onde ele engana mais. Junto: nenhuma linha soa favorável sem nada
confirmado — com zero divergências E zero atendidos a linha diz "nada
confirmado · N inconclusivos", nunca "não apontou divergências"; `pedidoDe` só
casa pedido que produziu a versão (`origem == .ia`), e versão importada ou
escrita à mão mostra "não feita · sem pedido a conferir" em vez de oferecer
conferência contra pedido alheio; título de critério igual a um nome de enum
(`atendidoNoEscopo`, `instrucao`) é formato descumprido e derruba a revisão
inteira; só o ÚLTIMO registro de cada tipo (local, IA) vira linha no cartão;
"Conferir com IA" existe em UM lugar; o texto de "Pedir ajuste" leva a marca
"a partir da conferência de <data>, por <executor>" e a rolagem vai ao COMEÇO
do campo.

**Custo assumido, nomeado:** é o MESMO tipo de provedor lendo de novo —
crítica assistida, não independência, e o rodapé diz isso. No caso real
(prova/5.md) a montagem deu 3.977 caracteres contra o teto de 3.500 do
aparelho: pela rota do app o estado foi `indisponivel` por limite e nada saiu;
forçada fora do contrato, a Apple Intelligence devolveu JSON inválido nas duas
amostras e não viu as traduções ausentes. No SEGUNDO caso real, pela tela
(prova/5.md, §9), a chamada rodou — 2.997 caracteres, 13 s — e voltou JSON
válido com três critérios cujos títulos eram nomes de enum e cujas citações
não eram literais: três `inconclusivo`, nada acrescentado à leitura local.
**O custo da decisão da volta 5:** quem não tem conta Grok perde o toque, não
a informação — e perde também a chance de a revisão de bordo acertar um dia
sem que ninguém a ofereça. Assumido: duas provas de que ela não acerta hoje
valem mais que a promessa de que poderia. `ContaGrok.ligada` é lida a cada
avaliação da tela, que já revalida ao voltar à cena.

**Volta:** melhorar na conferência, multiplicar no ajuste. **O que a IA
sabe:** o pedido vigente e o artefato inteiro, sem saber quem os produziu.
**Prova:** 44 testes (`ConferenciaTrabalhoTests`), suíte integral 622/0 em
05/09/2026 e os DOIS casos reais de prova/5.md, lidos: a revisão assistida NÃO
melhorou a qualidade em nenhum deles.
**Fora:** revisão pelo Grok (sem conta neste simulador), jornada pela tela (o
portão 03p desliga o modelo no XCTest) e montagem por item para caber no
aparelho.

## ADR 2026-09-05r — Praticar de verdade: exercício, tentativa do autor e feedback sem resposta

**A distância.** `Apoio.praticar` só mudava uma frase do prompt: a IA
entregava o artefato do mesmo jeito, e quem escolheu praticar recebia a
resposta pronta. A tentativa da pessoa não tinha lugar no modelo —
`guardarVersaoHumana` criaria origem mista e trocaria a versão vigente pela
resposta de um exercício. E nada registrava demonstração de capacidade com
estado honesto: relato, uso e ação executada se pareciam com aprendizagem.

**A decisão.** Tudo aditivo, sem migração: formato 1 e SwiftData V4
preservados; chave ausente no disco é ausência, nunca "sem prática".
`Artefato.pratica?` guarda a preparação (capacidade, situação, dificuldade,
`hipoteseID`, enunciado, exemplo e critérios COM identidade).
`Evidencia.tentativa?` guarda a resposta do autor — `tipo: .tentativa`,
`origem: .pessoa`, `apoioUtilizado` obrigatório (desconhecido nunca vira "sem
ajuda"), `anteriorID` para a revisão e as suas próprias conferências. A
tentativa é EVIDÊNCIA da ação ligada ao material, nunca versão: guardar não
marca ação executada nem capacidade adquirida, e a primeira tentativa nunca é
sobrescrita. `Hipotese` ganha `propostaPor`, `avaliadaEm` e `motivoAvaliacao`;
registro antigo fica com autoria DESCONHECIDA, não reconstruída. Em
`combinar`, `trechoExercitado` delimita o que a pessoa exercita — sem ele,
combinar é entrega e nada vira exercício.

Em `praticar`, `MotorTrabalho` ramifica para preparação ESTRUTURADA: enunciado
executável, exemplo resolvido de caso diferente e 2 a 6 critérios de
desempenho. O contrato é TIPO, não instrução — no aparelho o schema é gerado
com os IDs reais dos critérios (a escada da ADR 04t) e a resposta volta como
JSON pelo MESMO parser estrito do Grok. A validação é pura e igual para os
dois: exemplo dentro do enunciado recusa; critério que repete quatro palavras
seguidas do exemplo recusa, pela mesma prova do Recordar (`Prova.vaza`).
Preparação que não sai — sem conta Grok ou sem validar — deixa o pedido guardado
como `praticaIndisponivel` e NUNCA cai na produção delegada: quem escolheu
praticar não recebe a resposta pronta (P1 da volta 6). A tela diz isso numa
linha, com o campo "Minha tentativa" disponível: a tentativa sem exercício é
evidência da ação "Praticar por conta própria", sem `artefatoID` e sem
feedback — a prática não depende da IA para existir.

"Conferir minha tentativa" é operação PRÓPRIA, uma chamada por toque: lê
enunciado, critérios, apoio e tentativa INTEIROS (05m: cabe ou fica
`indisponivel`, nada é cortado) e devolve por critério `{criterioID, situacao,
trechoDaTentativa, observacao}`. Chave fora do contrato, enum desconhecido,
campo faltando ou ID inventado derrubam a leitura inteira. Trecho não literal
da tentativa, veredito sem trecho nenhum, observação acima do teto ou que
repete o exemplo derrubam AQUELE critério para `inconclusivo`, apagando a
citação. Critério não coberto volta `naoAvaliado` — cobertura incompleta nunca
é acerto implícito. Reavaliar acrescenta à mesma tentativa e não cria outra
demonstração; feedback nunca sobrescreve a resposta. O convite "Reveja este
critério e tente novamente" é do APP. A seção "Praticar" mostra objetivo e
dificuldade corrigíveis ("O que está dificultando isso?" aceita contexto,
recursos, acesso ou divisão do trabalho); pessoa ou IA propõem com autoria
explícita, só a pessoa confirma ou contesta, com motivo — e confirmar é
concordância contextual, nunca certificação. O acesso à origem (05j) é
revalidado antes de enviar, depois do await e dentro de `alterar`; retorno
atrasado é descartado se mudou a tentativa vigente, o material, o apoio ou uma
hipótese.

**A decisão da volta 6 (revisão independente de 05/09/2026).** Como na 05q,
a condição é o PROVEDOR: exercício e "Conferir minha tentativa" pela IA só são
oferecidos com `ContaGrok.ligada`. Em 3/3 preparações e 3/3 feedbacks o modelo
de bordo saiu no formato e não serviu (prova/6.md e as capturas
`ferramentas/orca/v6-*.png`); uma preparação nem validou e o app entregou o
roteiro completo com as frases prontas — a jornada pela tela provou o P1. Sem
conta, a seção Praticar continua inteira (objetivo, "Minha tentativa", apoio,
Guardar, histórico, dificuldade) e UMA linha diz "Exercício e feedback pela IA
precisam da conta Grok; o modelo do aparelho não os produziu com qualidade";
a seção "Preparar" e "Revisar com estes relatos" não aparecem, porque não há
botão de IA a oferecer. O caminho do aparelho fica no código atrás do Grok,
para quando servir. Junto: a hipótese só nasce por `proporHipotese`, com
`propostaPor` e evidências só as selecionadas (o bloco antigo "Apoio para a
próxima tentativa" saiu); exercício, tentativa e hipóteses aparecem UMA vez na
tela (a versão com prática não repete o Markdown, "O que aconteceu" só lista
relatos); o cartão diz "Preparado por <produtor>" e omite a situação quando o
modelo a copiou da capacidade; o campo da tentativa desliga o corretor do
sistema, porque reescrever a tentativa é o que se proíbe à IA; a mensagem de
recusa da observação diz o que o código detecta ("repete o exemplo ou passa do
teto"), não "reescrita"; e a queda do Grok para o aparelho, quando ele existe,
respeita o teto do aparelho.

Re-revisão (06/09/2026): tirar o bloco antigo tinha levado junto o único
caminho de `delegar` (o padrão) para propor, confirmar ou contestar uma
dificuldade, e as hipóteses já gravadas ficavam invisíveis. Em `delegar` a
seção vira "Dificuldade": o mesmo `dificuldade(o)`, logo abaixo do objetivo e
antes do pedido, porque a contestada muda o próximo pedido (05i); e as
tentativas escritas antes de mudar o apoio continuam na tela, só leitura, com
a linha "Escritas quando o apoio era praticar" (P2-H, P3-K). Com exercício
preparado e a conta desligada depois, a linha da conta entra no lugar de
"Conferir minha tentativa" em vez de o botão sumir mudo (P3-I). A linha da
preparação que não validou só aparece com conta ligada, então culpa a
resposta ("A IA não devolveu um exercício válido"), não o aparelho (P3-J).

**Custo assumido, nomeado:** a validação lê FORMA. Ela não pega um exemplo que
satisfaz o próprio enunciado quando o enunciado é genérico, nem um critério
que cobra o que a conferência textual não pode ler ("pronunciar corretamente",
"praticar várias vezes") — os dois aconteceram no caso real. Sem conta Grok
ninguém recebe exercício nem feedback, e o pedido de prática sem conta fica
`praticaIndisponivel` sem gastar chamada; assumido, como na 05q: três provas
de que o aparelho não serve valem mais que a promessa. Tentativa sem
exercício não tem feedback — não há critérios contra os quais ler. E o
feedback continua sendo o mesmo tipo de provedor lendo: não é avaliação
independente, e o rodapé diz isso. Em `delegar` o campo "O que está
dificultando isso?" está na tela padrão de todo Trabalho, mesmo sem hipótese
nenhuma: um campo e um botão a mais, assumidos para que a hipótese continue
corrigível sem trocar o apoio.

**Volta:** melhorar — gargalo, prática, tentativa, feedback, recalibrar. **O
que a IA sabe:** para preparar, o objetivo, o resultado, a dificuldade
declarada e o pedido; nunca a tentativa. Para conferir, o exercício, o apoio e
a tentativa, sem saber quem escreveu. **Prova:** 43 testes
(`PraticaTrabalhoTests`), suíte integral em 06/09/2026 (número em EVOLUCAO), a
jornada pela tela (`ferramentas/orca/v6-*.png`, aparelho do dono; `v6-fix-*.png`,
simulador de teste, estados sem conta, prática indisponível, tentativa guardada
e Dynamic Type grande; `v6-fix2-*.png`, delegar com hipóteses e tentativas,
exercício com a conta desligada depois) e o caso real de prova/6.md em quatro amostras: a preparação e o feedback estruturados SAÍRAM
do modelo de bordo por geração guiada — o que a V5 não conseguiu com JSON
livre —, mas o exercício reduziu 15 minutos a uma frase e o feedback não
conferiu um único critério, porque nas 12 citações não copiou a tentativa
literalmente. Sem essa regra, a amostra 2 teria mostrado seis critérios
"atendidos" sobre um texto transcrito errado. **Fora:** Degraus, Sinais,
Retrato e Trajetória (nada é alimentado por isto); qualquer streak, medalha,
contagem ou promoção; prática e feedback pelo Grok (sem conta em nenhum
simulador: o único provedor oferecido está sem prova real); origem externa da
tentativa (`Tentativa.origem` só aceita `.pessoa`; texto copiado ou importado
não tem caminho para entrar como tentativa com a sua origem); escrever
tentativa nova em `delegar` (a lista é só leitura; mudar o apoio devolve o
campo); hipótese proposta pela IA em `delegar` (só a pessoa propõe ali; a IA
propõe apenas dentro da preparação, com `hipoteseID`); aprendizagem
duradoura, pronúncia e transferência.

## ADR 2026-09-05s — O commit antes do anúncio, em toda rota

**A distância.** A 05h fechou a entrada e o concluir. As outras rotas de
escrita anunciavam ou projetavam ANTES de o disco dizer sim, e o autor não
tinha como saber. A auditoria de 05/09/2026, rota por rota da `Sessao`:

| Rota | Antes do commit (main, 05/09) | Agora |
|---|---|---|
| `salvar` | widget/Destaque gravado, versão anterior registrada e, no selo, versões/apontamentos/índice apagados; aviso sumia em 2,5 s | tudo depois do `save`; recusa deixa UMA linha fixa na página |
| `trancarESair` | ignorava a recusa: `novaPagina` apagava o texto e `.trancada` anunciava um selo que não existia | recusa mantém o texto e cala |
| `trancarESair`, `abrirFecho`, `queimar` (relógio) | `pararTimer` antes do commit: na recusa a expressiva ficava sem prazo e a gravação automática seguinte apagava o `expressivaPrazo` — aberta sem tranca | o relógio só para depois do commit; a gravação seguinte leva o prazo e a varredura sela |
| `mostrarToast` | qualquer aviso transitório zerava a linha fixa antes de haver gravação | o transitório passa por cima e, ao sumir, a linha volta |
| `trancarExpressivasVencidas` | versões, apontamentos e índice apagados antes do `save` | depois |
| `apagar`, `desfazerApagar` | `try context.save()` sem `rollback` e fora da injeção de recusa; avisos cancelados antes; nota devolvida não voltava ao espelho/Spotlight/índice | `persistir`; avisos e projeções depois; varredura inteira ao devolver |
| `importarCorpus` | commit certo, mas NENHUMA projeção: espelho, Spotlight e índice só no arranque seguinte | varredura inteira depois do commit (04o) |
| `restaurar` | versão substituída registrada antes | depois |
| `abrirFecho`, `concluir`, `queimar`, `guardarSentidoDoFecho`, `recolherEntrada` | já certas (05h) | — |

**A decisão.** Nada sai da `Sessao` antes de `persistir` devolver sim: nem
versão, nem widget, nem índice, nem espelho, nem aviso. Recusa recua o
contexto, mantém o texto e diz "Não consegui guardar agora. O texto continua
aqui." — linha FIXA (`mostrarToast(fixo:)`), que só some quando um `salvar`
grava. Projeções ganham um relógio lógico (`Geracao`, na main): o `.md` de
uma conclusão fora da main, a varredura do selo e a entrada do Mac só andam
para a frente — alvo a alvo no corpus (`Corpus.avanca`), nota a nota no
índice (`Indice.avanca`), lote a lote no Spotlight (`Holofote.geracao`). A
escrita atrasada não regrava a nota selada nem apaga o `.md` recém-criado.
Pasta espelhada que resolve mas não recebe escrita não roda a cópia e o
Perfil diz "iCloud indisponível; guardando só no aparelho" (ou o nome da
pasta, quando não é iCloud); bookmark morto limpa a escolha (05h) e diz que
a pasta não existe mais. A linha some quando a cópia volta a chegar, ou ao
escolher/parar. Eixo 4: nenhuma tela, nenhuma opção; só linhas onde havia
silêncio.

**Custo assumido, nomeado:** a trava global do corpus faz a varredura do
selo na main esperar um `.md` em voo (uma nota e três agregados; fila serial
por pasta se doer). A checagem de escrita da pasta é `isWritableFile` no
raiz: um iCloud que aceita e descarta depois não é visto. Avisos (`Revisoes`)
e haptics continuam fora do contrato de commit; listados, não provados.

**Volta:** multiplicar (a nota nunca se perde; o protegido nunca vaza). **O
que a IA sabe:** nada — é disco, ordem e relógio. **Prova:** 20 testes em
`IntegridadeRotasTests` (rota × recusa, ordem forçada sem sleep, relógio de
pé na recusa, linha fixa sob aviso transitório, matriz do selo × projeção,
pasta indisponível e bookmark morto), suíte integral 642/0 em 05/09/2026,
build genérico. **Fora:** captura da linha do espelho no aparelho do dono — não encenável sem
maestro: nenhuma rota `traco://` abre o Perfil; garantia física do queimar
(§8.6) e sincronização contínua da pasta.

## ADR 2026-09-05t — Quem não vê, ouve; quem enjoa, não vê deslizar

**A distância.** Oitenta rótulos de acessibilidade espalhados, nenhum passe
ponta a ponta. Quatro gestos sem par acessível: o arrasto do calendário (a
ÚNICA forma de andar um dia, uma semana, um mês, um ano sem tocar em chip), o
toque longo em "Analisar" (liga e desliga a análise automática — invisível ao
VoiceOver), a borda da escrita e a régua. A forma vestia sozinha com anúncio
(varredura nº 4), mas a sábia respondia, pensava e calava em silêncio, no
rodapé da página e no pé das Notas. E "Reduzir movimento" valia em 10
arquivos: a barra de destinos descia 130 pt, o arquivo deslizava, a régua
subia de baixo, o cartão da Rede e os blocos do Recordar entravam com
deslocamento, o ponto de "lendo…" pulsava em laço, e o `Tema.gaveta` do
Caderno recebia `reduzido: false` cravado.

**A decisão.** (1) Uma lei de movimento num lugar só: `Tema.animacao` e
`Tema.transicao` devolvem `fadeReduzido` (0,15 s) ou `.opacity` quando o
sistema pede menos movimento; toda animação e transição custom das jornadas
principais passa por elas. Duas têm nome próprio e passam pela mesma lei: a
gaveta do Caderno (`Tema.gaveta`) e o morph/desdobramento do Calendário
(`CalendarioTema.morph`/`desdobra`) — em reduzido devolvem o MESMO
`fadeReduzido`, não um segundo valor (o G3 mediu 0,18 s em `gaveta` e num
`Tema.cartao` sem uso desde 31/ago; o segundo foi apagado). O pé das Notas
corta seco por `transaction`: o corte é o outro lado permitido da lei.
Camadas corta seco, posição e opacidade juntas, sem fade (o G4 viu o painel
sumir um quadro sob o dedo ao soltar, 05/09); a barra não desce, apaga; o
ponto de "lendo…" fica aceso, sem laço. (2) O arrasto
do calendário ganha par no rotor: "Dia/Semana/Mês/Ano seguinte" e "anterior",
uma ação por escala, no mesmo `andar` do gesto. O toque longo em "Analisar"
vira "Ligar/Desligar análise automática" no rotor. A régua diz o que faz
("Dá esta forma à linha do cursor") e "Todas" diz aonde leva. (3) Anúncios:
a página anuncia o cartão que muda sozinho no rodapé (forma sugerida, aviso,
sábia pensando, sábia respondeu, vestido, sem conta); as Notas anunciam a
sábia pensando, respondida, calada e sem modelo. O vestir automático, a
expressiva e o toast já eram anunciados pela Sessão (V7): não se duplica.
(4) O cartão da sábia nas Notas é um contêiner nomeado; o menu do domínio na
ficha do calendário diz "Domínio: X" e o que abre. Nada de "botão" em rótulo.

(5) AX5, o que a captura mostrou e fechou: a régua deixava 1,5 chip à vista e
cortava "Seção"; o menu de ordem das Notas virava "…" e, com ícone, partia
"Notas" em duas linhas; no Recordar a pergunta era comprimida a "O que
estava…" pelo editor abaixo. Régua, cabeçalho do Recordar e os dois controles
ao lado do título das Notas são chrome e param em `xxxLarge`, como as barras
do sistema; a pergunta e a pista do Recordar ganham `fixedSize` vertical; o
menu de ordem mostra o ícone de ordenar em tamanhos AX (o rótulo de VoiceOver
"Ordenar por X" já dizia tudo).

(6) O alvo é o que se mede, não o que se reserva (correções do G3, 05/09).
Um `.frame(minHeight: 44)` POR FORA do Button só reserva espaço: o dedo e o
VoiceOver medem o `contentShape` — a revisão mediu "Notas" 45×20 com o frame
de 44 e "Como contexto" 44×44 com frame e contentShape. `View.alvo()` em
`Tema` é frame E contentShape; `alvo(folgaH:folgaV:)` dá o alvo a quem vive
apertado (chips da régua, "Todas", pílulas de 38 da barra, linhas de 24 das
Notas) crescendo para os lados e devolvendo o espaço ao layout — nenhum pixel
se move. O chip do dia e da semana é UM elemento (`children: .ignore`): a
letra e o número não repetem o rótulo. O ano é um elemento por mês, "setembro
de 2026" com valor "N compromissos": os 42 números de 8 pt são desenho, não
leitura. O cartão da análise em tamanhos AX rola o TEXTO e prende as AÇÕES no
pé, uma por linha — "Abrir os campos" e "Deixar como nota" ficam à vista sem
rolar (o G3 mediu a ação três páginas abaixo em AX5); em tamanhos normais o
cartão é o que era.

**Custo assumido:** a ação de rotor é descoberta, não vista — quem não conhece
o rotor continua sem andar no calendário; o chip do dia é o caminho visível.
No AX5, o ano continua preso em `large` e a grade em `xxLarge` (decisão da
ADR 02h: 504 células não cabem em corpo maior); a régua a `xxxLarge`. A folga
dos chips da régua é fixa (9 pt): em `large` o menor chip ("Lista") mede 44;
abaixo de `large` mede 42. "pular" no Recordar e a aba do arquivo (23 pt de
largura, `Camadas`) seguem estreitos. O idioma `frame` sem `contentShape`
sobrevive fora das jornadas desta volta (Confirmação, Padrões, Trabalho).

**Prova:** build e suíte integral 623/0 em 122 suítes (05/09/2026, `TemaTests`
novo); após as correções do G3, 624/0 em 122 suítes e build limpo com um só
aviso, o pré-existente de `EditorBlocoView`. Aparência intacta em `large`:
diff de pixels antes/depois no mesmo simulador — Notas, mês, ano e Recordar
0 %; página 0,001 % (teclado); dia e semana só a linha "agora"; cartão da
forma vestida 0 %. `maestro/ax5.yaml` passa em `large` E em AX5 (16 passos, "Deixar como nota" visível; rodado pelo orquestrador no simulador da correção). Árvore esperada por
tela documentada no relatório da volta 8; a conferência com `maestro
hierarchy` é do revisor.
Capturas `simctl` em tamanho normal e AX5 das cinco telas no simulador da
volta (`ferramentas/orca/v8-*.png`), tamanho de texto restaurado a `medium`; o
iPhone do dono estava em uso por outra volta e não foi tocado além de uma
instalação e três rotas, sem mudar tamanho nem dados.
**Fora:** passe manual com VoiceOver ligado em aparelho real (requer humano);
a data da página segue oculta ao VoiceOver por decisão anterior.

## ADR 2026-09-05u — A fundação fora do app

**A distância.** A auditoria F1 achou doze intents soltos, chaves soltas no
App Group, dois botões da tela bloqueada que confirmavam sem persistir (a
soneca com `try?` e sem orçamento; o Feito alternando "o próximo atual" sem
saber de quem era), o widget do Próximo pedindo reload por minuto e servindo
compromisso apagado (D6), 39 tamanhos de fonte fixos (D3). O mesmo comando,
por entradas diferentes, não produzia o mesmo estado — e às vezes nenhum.

**A decisão, conforme o conselho (`consulta-fora-intents.md`).** Sem
framework nem package. `Traco/App/Intents/` é o catálogo: `Intencoes`,
`TracoAtalhos`, `Entidades` só no app; `Compartilhado/` (o snapshot, os
atributos das atividades e as declarações de `DestaqueFeitoIntent`,
`DestaqueDesfazerIntent`, `LembrarDepoisIntent`) compilado também no widget,
que só declara — `TRACO_APP` recusa executar fora do app. Nomes de tipos e
parâmetros preservados. Toda entrada (Siri, Atalhos, URL, widget, Ilha)
converge em `Rota.ir` ou numa função concreta (`Entrada`, `CalendarioDisco`,
`Revisoes`, `AcessoTrabalho`); a rota pendente é consumida quando a cena está
pronta, também no arranque frio.

`Superficie` é UM documento Codable versionado (`revisao`, `geradoEm`,
`validoAte`, Destaque com id+dia+feito, até três próximos com id+início), no
App Group, escrito atomicamente pelo app após cada commit relevante;
idêntico não regrava, revogação nunca espera; `reloadTimelines` só dos kinds
cuja seção mudou. O pedido de reload não devolve erro; no Air TODO pedido
era recusado (ChronoCoreErrorDomain 27) e a causa, lida no chronod, era o
nome do produto: com `PRODUCT_NAME: Traço` o executável ia ao disco em NFD
(c + cedilha combinante) e o `CFBundleExecutable` em NFC, o chronod não
reconhecia o processo como dono do widget ("Resolved bundle path
…/Traço.app does not match executable Traço") e nenhum reload entrava — o
que os widgets mostravam vinha só do toque nos botões. O produto passou a
`Traco` (ASCII; o nome exibido segue "Traço"). Como rede: o app guarda o
par revisão publicada / revisão recarregada e a volta à cena repete, dois
segundos depois, o pedido do que ainda não foi confirmado (em primeiro
plano o reload não conta no orçamento; no arranque nada está confirmado).
Falha, corrupção ou App Group ausente é "sem dados", nunca `.standard`. A linha do tempo do widget tem só transições reais (meia-noite,
fim de cada próximo, soneca, horizonte) e política `.never`: "desatualizado"
depois do horizonte, "nada marcado" dentro dele, e os dois widgets dizem a
hora do que mostram ("atualizado às 21:30", absoluta: segundos correndo eram
ruído). No pequeno, o Destaque (ou o "sem dados") toma o lugar do atalho
Recordar: a linha inteira vale mais que o segundo atalho; em tamanho de
acessibilidade o pequeno mostra só a linha, em até três linhas. Widget readicionado
nunca mostra o apagado. A suíte de testes roda dentro do app do simulador e
por isso é desviada num ponto só do arranque (`isolarParaTestes`: pasta
temporária, reload mudo, suíte própria de `UserDefaults`, sem atividades) —
nenhum teste toca a superfície real do aparelho.

Os dois botões carregam a IDENTIDADE do que mostram (nota+dia; id+início da
ocorrência) e o app relê antes de agir: feito é `true` com desfazer
explícito, nunca toggle; a soneca passa por `Revisoes.soneca` (permissão,
orçamento 04b, `add` que pode falhar) e só anuncia a hora depois do centro
aceitar — negada, lotada ou falhada vira recado no cartão. Persistido e
publicado ANTES de o cartão mudar; superfície recusada desfaz. Atividades
são reconciliadas com o estado guardado no arranque, no retorno à cena e
após cada comando; `isStale` neutraliza texto e ações em todos os estados
(cartão, Ilha compacta e expandida) e o app encerra ao executar.

Entidades mínimas: `NotaEntity` (uuid + título público, só aberta e não
expressiva), `TrabalhoEntity` (só `AcessoTrabalho.permitido`),
`CompromissoEntity` (só o que o autor marcou; deixa e projeção do Trabalho
ficam com os donos, 05k) — o selo entra na consulta E no `perform()` de
`AbrirNota/Trabalho/Compromisso`. `AnotarIntent` distingue vazio de falha de
gravação: "anotado" é depósito confirmado. Tipografia dos widgets e das Live
Activities pelos degraus de `Tema` (`miudo` e `acaoViva` novos, só fora do
app), zero tamanhos fixos.

**Custo assumido:** o `recado` da soneca vive só na atividade (some ao
republicar — F5); cache já renderizado pelo iOS não tem revogação instantânea
garantida; o widget de casa segue papel claro no escuro (D11, G0 de F4/F5).
**Volta:** multiplicar. **A IA:** nada. **Prova:** 20 testes em
`ForaDoAppTests` (recusa não confirma, repetição não inverte, cartão velho,
soneca negada/lotada/falha/corrida com editor, snapshot truncado/expirado,
D6, linha do tempo curta, reload por kind, reload repetido na volta à cena,
suíte isolada do App Group real, selo nas entidades e depois da consulta,
anotar honesto), build dos dois alvos sem aviso, capturas da bloqueada no
iPhone 17e e da casa e da Ilha no iPhone Air. **Fora:** Ilha (F5), controles e ditado (F3), Spotlight (F9).

## ADR 2026-09-05v — A fundação: componentes, tokens e um vocabulário de movimento

**A distância.** A auditoria da volta 9 contou o que cada tela desenhava por
conta própria: a cápsula de controle em nove arquivos com seis desenhos, o
rótulo de seção copiado em 32 lugares de 14 arquivos, sete `ButtonStyle`,
cinco cabeçalhos de folha, dois toasts, cinco vazios; dezesseis durações e
quatro molas para quatro verbos (entrar, sair, trocar, pressionar); Reduzir
Movimento tratado em quinze arquivos e ignorado em cinco. Nenhuma tela chegou
a 9 em Componentes (média 6,2). A fundação é a Fase Construir e Mover do
`design-router`; Ancorar e Sistema já estavam fechadas em SISTEMA-CLARO.

**A decisão, metade B (componentes).** (1) `Traco/Componentes`, um arquivo por
componente, `#Preview` por estado, nome em português, acessibilidade dentro:
`Pilula` (as seis formas que as telas têm HOJE, nomeadas — filtro, menu,
controle, ação, larga, etiqueta — para que a volta por tela escolha qual
sobrevive), `ChipDominio` único (etiqueta nas Notas; tingido com ícone e seta
na ficha; um menu só, com ícone e marca no atual, "Sem domínio" e "Devolver ao
app"), `.rotulo(_:)` (caixa alta, 11 semibold, tracking +1,2), `LinhaDeEstado`
(pensando, lendo, falhou, sem conta), `LinhaQueAbre` (menu; a variante que
abre um bloco abaixo entra na V12 com as Versões, que é quem a chama),
`.cartao(_:)` (papel, campo, flutuante, tingido; sombra só no que flutua),
três estilos de botão em Componentes (`.discreto` é a `PressaoDiscreta` de
Tema; `.primario` recua sozinho quando desabilitado; `.compacto` é o antigo
`CompactoStyle` do cartão da análise, que passou a citá-lo) — no repositório
são SETE, não três: os quatro por tela seguem abaixo no custo assumido —,
`CabecalhoDeFolha` (✕ ou "voltar", título, Pronto) e `Vazio(frase:acao:)`.
O `Toast` por `safeAreaInset` foi escrito e apagado nesta mesma volta: sem
tela que o prove não é componente; entra na V15 com o calendário, cujo
`CalendarioToast` já cita os mesmos tokens. O alvo de 44 vive no botão ou no menu que envolve a
cápsula (ADR 05f), nunca nela. (2) Três telas migradas sem mudar pixel: Notas,
ficha do calendário (a própria e a do iPhone) e Recordar. No Recordar, ler e
esconder viram UM objeto cujos modificadores animam; a fase que sai corta seco
e a que entra amanhece (§21: nenhum quadro com dois textos na mesma linha); e
toda animação passa pela lei de `Tema`.

**Tokens e movimento, metade A.** `Tema.Duracao.{curta 0,15 · media 0,25 ·
longa 0,4}` mais seis fora do vocabulário com nome e motivo (toque, passo,
pulso, fecho, relogio, queimaCena); `Tema.Mola.{toque, camada, escala,
teclado}`; `Tema.Raio.{controle 10, campo 14, cartao 18}`; `Tema.Sombra.
{flutuante, campo}` com `View.sombra(_:)`. `Tema.movimento(classe, animação,
reduzido:)` decide sozinho sob Reduzir Movimento: deslocamento vira fade
curta ou corte, escala e laço não animam, opacidade fica; `pressaoAnim` ganha
`reduzido:`. `CalendarioTema` cita `Tema` em vez de repetir hex e número.
Dezesseis literais viram três durações; Δ por chamada em
`ferramentas/orca/v10a-tokens-movimento.md`.

**Custo assumido.** `Pilula` carrega seis formas porque zero pixel era lei:
é a régua para a volta por tela reduzir a duas (SISTEMA-CLARO §2.3). O menu
do domínio ficou um só, e por isso o que abre mudou nas duas telas (ícones nas
Notas, marca no atual na ficha). Seguem onde estão até a volta de cada tela:
`PressaoClara`, `CartaoBotaoStyle`, `BarraBotaoStyle`, `AcaoTrabalhoStyle`,
os rótulos de 11 arquivos e os toasts da página, do perfil e do calendário.
Três estados de componente que só os previews exercem hoje:
`Cartao.flutuante` e `.tingido` (a barra que flutua e a ficha tingida do
calendário, V15) e `LinhaDeEstado.lendo` (a Lente e as Notas, V13); ficam
porque são o inventário da auditoria com dona no RUMO, e a volta que não os
chamar os apaga. Dois Δ de movimento que a lei por classe trouxe: (1) a
queima da expressiva (`FechoExpressivaView`) entrou na lei como
`.deslocamento`, e esta ADR assumiu, sem ninguém ter filmado, que sob Reduzir
Movimento ela viraria um fade de 0,15 s mais 3,15 s de espera parada. O G4
pediu a classe `.opacidade`, que é o que a cena é (a frente de fogo é máscara
que revela, `Queima.swift`), e assim ficou; filmada com Reduzir Movimento, a
queima nem chega à lei: `queimar()` corta antes da cena (guarda anterior à
volta, igual em main) e a página amanhece sem espera; sem Reduzir Movimento,
os mesmos 3,0 s. Δ zero nos dois modos
(`ferramentas/orca/v10-g4fix-rm-queima.mp4`, quadros em
`v10-g4fix-rm-queima-quadros.png`); (2) a célula nova da tabela
(`EditorBlocoView`) trocou a mola própria 0,35/0,80 por `Mola.escala`
0,55/0,86: assenta em ≈ 0,70 s em vez de ≈ 0,45 s (+0,25 s), perceptível só
lado a lado, numa ação rara.

**Complexidade, decisão do orquestrador.** O critério do G0 desta volta,
"linhas líquidas ≤ 0", era inadequado para uma fundação: nenhuma fundação
fecha ≤ 0 no dia em que nasce. O crescimento real é CUSTO ASSUMIDO desta ADR:
Swift do app **+679** (`Traco/*.swift`, +1149 −470), sendo `Componentes/`
+848 (278 linhas de preview a partir do primeiro `#Preview`, ~200 de
comentário de contrato, ~370 de código) e as telas **−169**. Depois da
correção do G3 (apagados `Toast`, `LinhaQueAbre.abaixo`,
`Tema.confirmacaoEntra` e o `CompactoStyle` duplicado: −109) e o rebase sobre
main 59e5833 (V6 e F2), o app fica em **+570** (+1058 −488; `Componentes/`
+758, telas −188).
A regra de compensação, que o RUMO carrega: **cada volta por tela (V12, V13,
V15, V18…) tem de ser líquido-negativa ao migrar para Componentes** — a tela
apaga mais do que o componente cresce, ou a volta não fecha.

**Prova.** Build sem aviso novo; suíte integral 650/0 em 123 suítes no iPhone 17e em
06/09/2026, refeita no iPhone 17 Pro do revisor (650/0), depois da correção
do G3 e, na árvore final (rebase sobre main 59e5833 e correção do G4),
**713/0 em 125 suítes** no iPhone 17 Pro (`✔ Test run with 713 tests in 125
suites passed after 8.392 seconds.`). Capturas antes (main) e depois em `large` e AX5, diff de pixels fora
da barra de status, em pixels reais e não "0 %": Notas vazio, calendário mês,
ficha topo em AX5 e Recordar ler/escrever/revelar 0 px nos dois tamanhos;
ficha topo e rodapé em `large` 235 px = 0,008 % (o caret do título); ficha
rodapé em AX5 1 922 px = 0,07 % (rolagem clampada a ±1 pt); Recordar
escrever 2 186 px = 0,08 % (caret) em `large` e 3,7 % em AX5 porque a
pergunta da sábia do aparelho muda a cada abertura; Notas lista 218–636 px de
anti-aliasing de texto no campo de busca e no chip "Saúde" (o `.shadow` de
raio 0 do `Cartao` e o rótulo do `Menu` por `.discreto` rasterizam o mesmo
texto com outra borda) — e, na recontagem do revisor, 1,2 % e 5,1 % que são só
a ORDEM de duas notas criadas no mesmo segundo, linha a linha idênticas. Vídeo
das fases do Recordar com corte seco na saída. Relatórios:
`ferramentas/orca/relatorio-v10-b.md`, `v10a-tokens-movimento.md` e a
revisão `revisao-v10-fundacao.md`.

## ADR 2026-09-05w — Captar pensamento em um toque

**A distância.** A entrada (05a) já recebia a frase por Siri, Atalhos e
`traco://anotar` — cada uma pedindo falar com a Siri ou digitar a URL. Na rua,
no meio de outro app, com o aparelho bloqueado, não havia UM toque que levasse
a mente ao papel: nem controle na Central ou na tela bloqueada, nem botão de
Ação. O que espera se perde.

**A decisão.** Um controle **Anotar** (`ControlWidget`, no alvo do widget)
para a Central, a tela bloqueada e o botão de Ação. Ele executa
`CapturarIntent`, o intent de ABERTURA compartilhado (declarado nos dois alvos
em `Compartilhado/`; só o app executa, `TRACO_APP`; fora dele `ForaDoAlvo`
recusa): `openAppWhenRun` e `Rota.ir(.captura(ditado: true))`. A rota é tipada
e fica pendente: `Rota.consumir()` a devolve UMA vez a quem a cena pronta chama
(`PaginaView`, no `onAppear` do arranque frio e no anúncio); a Página vai para
Escrever, salva o que estava em voo, abre em branco e pede o foco só com a
página livre (`restaurarFoco` guarda cobertura e confirmação; teclado
recolhido por arrasto deixa o `FocusState` em true, e a rota força false →
true): o app abre com o **teclado pronto e o microfone a um toque** — não
"já em ditado". O recado "Toque no microfone do teclado para ditar." diz o limite: o
iOS não expõe API para disparar o ditado do teclado — o app o deixa a um
toque; a extensão não toca em microfone. O controle não lê a superfície: só
"Anotar", desenhado pelo sistema, `tint` de `Tema.ambar`, rótulo ao VoiceOver.
Botão de Ação: iOS 18+ associa o controle direto (Ajustes › Botão de Ação ›
Controles) e o Atalhos expõe "Abrir para anotar"; sem frase de Siri — o iOS
aceita dez App Shortcuts e o Traço já tem dez. `AnotarIntent` (Siri, sem
abrir) segue em `entrada/`: "anotado" só após depósito confirmado; vazio não é
falha; na falha nada é depositado (teste).

**Custo assumido:** o ditado é o do teclado (um toque a mais que o ideal); a
tela bloqueada do simulador mostra o controle só no editor — trancada não
renderiza controle algum, nem a Lanterna (prova no aparelho). **Volta:**
multiplicar. **A IA:** nada. **Prova:** contexto de execução no log do App
Intents (`Traco[pid]` invoca `perform()` quente e no arranque frio); 3 testes
em `ForaDoAppTests` (rota guardada sem ninguém ouvir e consumida uma vez; alvo
errado recusa sem rota; falha do Anotar não deposita); suíte 715/125 sobre a V10; dois alvos
sem aviso; capturas no iPhone Air. **Fora (F3b):** ditado próprio — áudio
salvo primeiro, transcrito depois, falha preserva o áudio — por `.captura`.

---

## ADR 2026-09-06d — Os widgets da casa prestam (volta F4)

**Contexto.** Às 13:04 de 06/09 o dono mandou um print do iPhone dele com um
veredito de quatro palavras. Os dois widgets diziam "atualizado às 04:14" —
nove horas parados. E o que eles diziam, além disso, era pouco: o pequeno era
uma lista de dois links com um filete no meio, o médio inteiro servia para
"nada marcado", e nada ali dizia Traço.

**Decisão.**

1. **A linha do tempo não congela.** `TracoWidget/Relogio.swift`: as ENTRADAS
   desenham o dia (elas não custam orçamento — recarga custa) e a POLÍTICA
   garante a releitura. `policy: .never` sai das duas linhas; entra
   `.after(voltar(agora:ultima:))`, que é a última entrada limitada a três
   horas e nunca abaixo de quinze minutos: no máximo oito releituras por dia,
   e "abra o Traço" deixa de ser a única saída quando o `reloadTimelines` do
   app é recusado (ChronoCore 27, A1 da 05u). As entradas passam a incluir a
   VÉSPERA de cada compromisso (uma hora antes, quando a hora vira âmbar), o
   início, o fim, a soneca, a meia-noite e o horizonte. Relevância declarada
   (`TimelineEntryRelevance`): a Pilha Inteligente sobe o widget quando há uma
   coisa por fazer e o esquece quando ela foi feita.
2. **O widget não fala de si.** `RodapeAtualizado` ("atualizado às HH:MM", um
   terço do widget pequeno) morre. O estado honesto da 05u fica, dito só
   quando é VERDADE — e **na linha do conteúdo, não no cabeçalho**. A F4
   pôs um selo de estado ao lado da marca e em 155 pt ele saía
   `TRAÇO · desatua…`, com `PRÓXIMO` hifenizado no meio da palavra (G3, A1).
   A causa não era a fonte, era o lugar: o estado é sobre o CONTEÚDO, e o
   cabeçalho não é do conteúdo. Agora `Selo` carrega só a marca, e o corpo
   diz a frase inteira com a recuperação junto — `Desatualizado.` /
   `Não consegui ler o Traço.`, mais `Abrir o Traço`.
3. **Vazio é oferta, não vácuo** (`curva-zero`). Sem a única coisa de hoje, o
   widget do Traço traz o que vem — do MESMO instantâneo, sem dado novo. Sem
   compromisso, o widget do Próximo traz a única coisa de hoje, com o círculo
   que a marca. Sem nada, uma linha de estado e UMA ação ("Nova nota",
   "Marcar compromisso"); nunca a mesma ação duas vezes na mesma face. A
   oferta cabe INTEIRA: quebra a linha, nunca a palavra, e em tamanho de
   acessibilidade o glifo cede a coluna às palavras (G3, A3).
4. **Identidade.** O PONTO ÂMBAR que a tela bloqueada carrega desde a 05u
   entra na casa: `Selo` (ponto + rótulo). Os atalhos deixam de ser duas
   linhas de largura inteira com filete e viram glifo + palavra em `Tema.miudo`
   — cabem numa linha e sobra espaço para conteúdo. Nenhum token novo:
   `Tema.ambar`, `ambarTinta`, `label`, `miudo`, `meta`, `chrome`, `tituloTela`,
   `linha`, `aviso`.
5. **Densidade.** O médio do Próximo mostra TRÊS compromissos com hora,
   assunto e a hora do alarme (`LinhaProximo`); um só vira bloco com a hora
   como manchete (`BlocoProximo`), que é também o pequeno. O médio do Traço é
   em faixas de largura inteira, não em duas colunas — a coluna estreita
   cortava "Dentista" em "De…" (medido no simulador, 06/09).

6. **O sino é promessa, não enfeite** (G3, A2). Nenhum ponto da publicação
   consultava a autorização: `mudo:` calava UM evento e a revogação global
   não calava nada — avisos negados às 15:20 e seis sinos desenhados às
   15:21. `Avisos.estado()` passa a gravar a resposta do iOS num espelho no
   App Group (`avisosPermitidos`), lido SEM `await` por
   `ProximoCompromisso.proximasFatias`; a volta à cena relê e republica,
   porque a permissão muda nos Ajustes. E `Sessao.encadear` sem agenda em
   cena — o ramo que a F4 criou — publicava com sino e dizia "com aviso" sem
   NUNCA agendar: agora publica mudo, pede o alarme de verdade e a frase que
   fica na tela é a que o sistema respondeu.
7. **Um toque faz o que a face mostra** (G3, A6). O pequeno do Traço abria
   página em branco mesmo exibindo "16:40 Dentista"; o destino e o rodapé
   passam a sair da mesma decisão — compromisso na face leva ao Calendário.

8. **O estado honesto não depende do ramo** (Re-G3, R1). A correção do
   item 2 desceu o estado para a linha do conteúdo — e ali, na view, ele
   virou o ÚLTIMO `else if` de uma cadeia que começa no Destaque. Com
   Destaque posto e o horizonte vencido, o widget do Traço largava a agenda
   inteira e ficava **calado**: verdade truncada trocada por silêncio, no
   defeito que abriu a volta. A decisão sai do SwiftUI e vira lei com teste
   (`EstadoNaFace`, em `Relogio.swift`): **passada a validade, toda face
   diz**; só o LUGAR muda. Sem conteúdo em cima, o estado é o miolo e carrega
   a recuperação; com conteúdo, desce ao rodapé (`Velho`), onde o atalho cede
   a linha — a promessa da face vem antes de mais um caminho para dentro do
   app. Nas duas famílias da tela bloqueada, que não têm rodapé: a etiqueta
   `DESTAQUE` vira `DESATUALIZADO` e a linha do `accessoryInline` diz
   `Traço · desatualizado` em vez de exibir a frase de ontem como se fosse a
   de hoje. Um `if/else` de view não tem suíte, e foi um `if/else` de view que
   regrediu — por isso `Amostra.velhoComDestaque` entra nos previews das
   quatro famílias.
9. **O médio vazio é um quadro de ofertas** (Re-G3, M1 e A11). Quatro por dois
   para uma frase e ~70% de área morta é o defeito 5 do dono ("densidade
   errada") voltando pela porta dos fundos, e widget configurável não resolve:
   calendário vazio continua vazio com pasta escolhida ou sem. Sem Destaque e
   sem agenda não existe conteúdo a mostrar — o que existe é o que o autor
   PODE fazer daqui. A face inteira passa a ser isso: três ações reais, uma
   por linha, com o alvo na linha toda (`Nova nota`, `Marcar compromisso`,
   `Recordar`), e o cabeçalho abre mão das miniaturas, que seriam a mesma
   ação duas vezes. E elas moram no CORPO: por isso continuam existindo em
   tamanho de acessibilidade, onde o cabeçalho se cala e o vazio ficava mudo
   (M1) — a recuperação da `curva-zero` não desaparece no tamanho que mais
   precisa dela. Em AX5 são duas; "Recordar" continua no tamanho normal e no
   app.

**Custo assumido.** O pequeno tem um destino só (`widgetURL`): "Recordar"
continua no médio e no app, não no pequeno — o sistema não honra `Link` no
`systemSmall`. Em tamanho de acessibilidade o médio abre mão dos atalhos e da
agenda: a única coisa de hoje vem primeiro — mas **"+N depois" não some mais**
(G3, A8), porque esconder informação para limpar a tela é o que o AGENTS.md
proíbe. `Relogio.swift` compila também no alvo de testes (`project.yml`),
porque a lei que faltou à 05u tinha de caber numa suíte. O espelho da
permissão é o mínimo honesto dentro desta volta: a unificação com
`PromessaDoAviso` (volta 18, ainda não mesclada) é a volta seguinte.

**Volta:** multiplicar. **A IA:** nada. **Prova:** 17 testes (11 em
`LinhaDoTempoWidgetTests` — a política sempre devolve volta, com teto, piso e
orçamento; véspera/início/fim/meia-noite/soneca na linha; nada no passado,
nada repetido, linha curta — e 2 em `SinoHonestoTests`: sem permissão no
último olhar a superfície sai sem sino nenhum, e com permissão o sino volta;
e 4 em `EstadoNaFaceTests`: nas quatro combinações de velha × conteúdo, velho
é SEMPRE dito — a lei que a R1 quebrou);
suíte **732/128** na volta e **764/131** depois do `merge main`, dois alvos sem aviso (os únicos 4 `warning:` da suíte estão em `TracoTests/ConferenciaTrabalhoTests.swift:381`, que veio da main); capturas por estado nos dois temas
de verdade (`ferramentas/orca/f4b-*.png`, brilho médio 187,5 claro × 140,1
escuro), as QUATRO famílias plantadas na casa, o horizonte virando sozinho
para `Desatualizado.` inteiro, a oferta inteira em AX5, os sinos com e sem
permissão, e `sem dados` na tela. O `chronod` registrando a releitura
agendada para +3 h (`f4-rev-releitura.txt`) segue valendo. **Fora:** StandBy
e accessory na tela bloqueada trancada seguem sem render no simulador
(F1 §7) — prova no aparelho do dono.

---

## ADR 2026-09-05x — De onde vem cada método

**A distância.** O catálogo trazia só a origem nominal ("Gabriele Oettingen",
"engenharia"), e a VISAO pede que se distinga prática, lente e estudo com
evidência delimitada — beleza, tradição, nome técnico ou citação não certificam
eficácia. A eficácia era presumida pelo nome. E o método que saiu da pasta do
autor (ADR 05o) conservava a nota, mas em silêncio: a tela não dizia nada.

**A decisão.** Cada método ganha o campo aditivo `proveniencia` no
`Metodos.json`: `fonte` (obra, autor, ano ou tradição), `funcao` (`pratica` |
`lente` | `evidencia`), `adaptacao` (o que o Traço mudou), `evidencia` (o que
se sabe do uso proposto — "sem evidência específica conhecida" é resposta
válida e aparece onde não há estudo) e `aplicabilidade` (para quê serve e não
serve). Tudo opcional: JSON antigo e método do autor sem o campo decodificam;
função desconhecida vira "não informada" sem derrubar o método. A Lente abre
com a seção da forma da nota e a linha "De onde vem", recolhida; um toque
mostra as cinco linhas. A lista de métodos do Perfil traz a mesma proveniência
por método: a linha do método é o toque (alvo 44 no toque, não numa linha a
mais; seta que gira), um aberto por vez; abrir e fechar nas duas telas passam
pela lei única da ADR 05v — `Tema.animacao(.easeOut(duration: .media), reduzido:)`
e `Tema.transicao(.opacity, reduzido:)` no bloco. Na Lente a lei entra por
`withAnimation` no toque; no Perfil, por `.animation(_:value:)` na folha, porque
`withAnimation` disparado na tela que apresenta não atravessa a fronteira do
`.sheet` (medido: 1 quadro contra 8); a seta é a mesma nas duas telas
(`caption2` + `tintaSuave`); método do autor diz "a que você
escreveu" ou "não informada". As cinco linhas são um componente só,
`LinhasDeProveniencia` (Traco/Componentes), nas duas telas. Nota cujo método
saiu da pasta mostra na Lente "o método X saiu da sua pasta; os campos
continuam na nota" em `tintaSuave` — estado, não erro nem bloqueio (ADR 04a);
`aviso` fica para o que falhou. Nenhum selo, cor ou nota de eficácia:
informação onde havia silêncio. Os 21 foram preenchidos
com o que a literatura citada sustenta, delimitado ("não medido no Traço");
onde não há estudo do formato, está escrito.

**Custo assumido:** a proveniência é texto do catálogo, não verificação —
quem lê julga; a bibliografia dos 21 vive só em `Metodos.json`.
**Volta:** melhorar. **O que a IA sabe:** nada — a proveniência não viaja no
prompt. **Prova:** 4 testes novos em `CatalogoTests` (os 21 com função válida
e sem campo vazio; decode com, sem e com função inválida, e roundtrip; método
do autor com e sem o campo; estado do método ausente), suíte integral 717
testes em 125 suítes, 716 passam, 1 falha alheia (`ForaDoAppTests.sonecaRecusada`,
permissão do simulador, trilha F2) no iPhone 17 Pro Max de teste em 06/09/2026
sobre main 0d0d007; G3 em `ferramentas/orca/revisao-v16-metodos.md` (INTEGRAR,
três reparos de texto feitos: expressiva, argumento, decisão); capturas
`ferramentas/orca/v16-fix-*.png` da Lente recolhida, aberta, com método ausente
e AX5, e do Perfil compacto, aberto e AX5; movimento do Perfil em
`ferramentas/orca/g4-v16-perfil.mp4` (normal e Reduzir Movimento) e nos quadros
de `g4-v16-perfil-quadros-depois.png` — 8 quadros (267 ms) normal, 5 (167 ms)
sob Reduzir Movimento, os mesmos números da Lente. **Fora:** proveniência
no prompt da sábia, aviso ao autor quando um método some, edição da
proveniência pela tela.

## ADR 2026-09-06c — O áudio antes da letra

**A distância.** A F3 (05w) trouxe o autor de fora do app até a página em
branco com o teclado pronto e o microfone a um toque, mas quem transcrevia era
o ditado do TECLADO do iOS: sem rede, sem modelo, com o app morto no meio, não
ficava nada. A frase falada na rua dependia de a letra dar certo — e a 05a
tinha decidido o contrário: o áudio é depositado primeiro, a letra vem depois,
e falha de transcrição PRESERVA o áudio.

**A decisão.** O controle da Central de Controle (agora **"Ditar"**, com
ícone de microfone: a placa tem de dizer o que a porta abre) passa a abrir
**gravando**
(`Rota.ditar()`, não `Rota.ir(.captura(ditado:))` — teclado por trás da
gravação é ruído; o ditado corre num canal próprio que a Página, que só
entende `Destino`, ignora). `AVAudioRecorder` escreve o m4a **direto no
destino final do anexo**: o áudio nasce depositado, não é copiado no fim. Ao
tocar "Pronto" a NOTA ENTRA NO DISCO SEM UMA LETRA
(`Sessao.gravarDitado`) e só então a transcrição é pedida: se o app morrer
aqui, o autor acha a frase gravada e a linha diz a verdade. **A nota volta
para quem a pediu** — `Sessao.armarDitado` dá a cada ditado a SUA identidade.
Era uma variável só da Sessão, e dois ditados sobrepostos a dividiam: quando o
segundo depositava, a letra do primeiro não achava mais "a sua" nota e criava
uma SEGUNDA, deixando a do depósito afirmando "sem transcrição" para sempre
(G3, A2). `SFSpeechURLRecognitionRequest` com `requiresOnDeviceRecognition` —
contrato de privacidade, o mesmo do `Ditado` do calendário: sem modelo local a
letra é RECUSADA e o motivo aparece, nunca cai no reconhecimento remoto em
silêncio. Microfone e fala são permissões separadas de propósito: fala negada
ainda grava; só microfone negado impede o depósito, e aí a tela diz "Nada foi
gravado" e oferece "Escrever em vez disso" (que é a 05w intacta).

**O que o app morto deixa, dito sem exagero.** Depois do depósito, morrer não
tira nada: a nota está no disco com o áudio tocável dentro e a linha honesta
(provado no G3, com o m4a de 2,06 s dentro da nota). **Durante a gravação, não
há nota** — o `AVAudioRecorder` só fecha o átomo final do m4a no `stop()`, e um
arquivo sem ele não é áudio, é lixo; a varredura de órfãos o apaga depois da
carência. Escolhemos dizer isso em vez de persegui-lo: o caminho real de sair
do app já deposita (`willResignActive`), e cobrir uma morte violenta em
primeiro plano exigiria gravação em segmentos — muito código para um caso que
o autor não produz. Contrato antes de conforto (G3, M4).

**Sem campo novo no modelo.** O áudio entra pelo marcador de anexo que o
Caderno já lê e TOCA — `[audio:ditado 6 set. 13h37.m4a](traco://audio/<id>)`
— e o arquivo mora no cofre de anexos (`AnexoDisco`), nunca como blob no
SwiftData. O áudio é localizável a partir da nota porque está DENTRO dela, com
o mesmo portal de toda mídia do Traço: zero código de renderização novo, zero
migração. Por isso o áudio NÃO foi para o App Group: o snapshot público é da
F4, o gravador roda no processo do app, e um segundo cofre para a mesma coisa
seria duplicata com o áudio invisível na nota.

**Três estados, três nomes.** Gravado, transcrito e conferido são coisas
diferentes e a tela as diz por títulos diferentes: **"Gravando."** (nada
guardado ainda; relógio e ponto de nível — sem nível o autor não sabe se falou
para um microfone mudo), **"Áudio guardado."** (no disco, sem letra — é o
estado que uma morte do app deixa para trás, e é verdade) e **"Guardado nas
Notas."** com "Confira quando puder — máquina não é o mesmo que conferido". Na
falha, **"O áudio ficou."** com o motivo e "Tentar de novo", que re-transcreve
o MESMO arquivo. Silêncio não é sucesso: transcrição vazia vira "não ouvi
palavra nenhuma." e a nota fica com a linha do depósito. E quando quem recusa é
o DISCO, o estado tem nome próprio — **"O áudio ficou no aparelho."**, com o
que falhou, o que ficou guardado e "Tentar de novo", que redeposita o mesmo
arquivo. A tela dizia "Sem microfone. / Nada foi gravado" com o microfone
funcionando e o m4a no disco, e um teste fixava essa mentira (G3, A1).
"Guardado nas Notas." passou a oferecer **"Abrir a nota"**: pedir conferência
sem dar o caminho era mandar o autor caçar a nota na lista (G3, M3).

**Movimento.** A troca de estado é SECA. Em fade, "Gravando." e "Áudio
guardado." ficam sobrepostos por um quarto de segundo e nenhum dos dois se lê
(`f3b-02-transcrevendo-sobreposto.png`) — é a mesma decisão da troca de aba na
raiz: sem direção espacial, a troca seca não tem vão. Quem marca a mudança é o
háptico — que agora existe nas DUAS trocas de resultado, `Toque.fechou()` no
transcrito e `Toque.aviso()` em toda falha (G3, M1) — e o anúncio de
VoiceOver. A entrada da superfície segue a lei do
`Tema`: escala e desfoque sob movimento normal, só opacidade sob Reduzir
Movimento (`f3b-entrada-normal-quadros.png` × `f3b-entrada-reduzida-quadros.png`).

**Uma casca só.** A superfície do ditado copiava byte a byte a casca e quatro
auxiliares da `ConfirmacaoView` (G3, M6). O idioma de confirmação — material,
tinta rebaixada, um título, um corpo, até duas ações — passa a ser
`FolhaDeConfirmacao` + `Folha`, usado pelas duas telas. Mora em
`Traco/Ditado/` por ora: a casa certa é `Traco/Componentes/`, e a mudança fica
para a volta que estiver lá.

**Custo assumido:** o simulador não tem o modelo de fala no aparelho, então o
estado "transcrito" só existe ali pelo instrumento `traco://ditar?ensaio=`
(Debug), que troca SÓ o reconhecedor — microfone, gravação e nota continuam
reais; a falha, essa, é real e é o caminho comum do simulador. **Volta:**
multiplicar. **A IA:** nenhuma; reconhecedor do sistema, no aparelho. **Selo:**
o áudio é do autor — não sai do aparelho, não entra em prompt, não aparece em
superfície fora do app. **Prova:** 12 testes em `DitadoProprioTests` (o depósito
acontece ANTES de a letra ser pedida, contado num diário de gravações; falha
preserva o áudio; silêncio não é sucesso; tentar de novo recupera; o disco que
recusa dá `semDeposito`, NUNCA `semMicrofone`, e volta pelo mesmo depósito;
**dois ditados sobrepostos escrevem cada um na SUA nota**; a nota volta para
quem a pediu; microfone negado não grava; o marcador é uma linha só em todos os
corpos; o áudio está no cofre com a extensão que a nota procura; `traco://ditar`
não é `Destino`), suíte 727/126; dois alvos sem aviso;
`maestro/ditado-proprio.yaml` percorre os estados por id.
**Fora (F3b+):** ouvir o áudio de dentro do Recordar, ditado que continua com
o app fechado, transcrição em fila para os áudios que ficaram sem letra.

## ADR 2026-09-06f — O aviso diz o que a fonte sustenta

**A distância.** O `avisoWood` interrompia a escrita com "Afirmação sem prova
não gruda" — sentença do app sobre o mundo, sem origem na tela e **falsa em
relação à própria fonte**: Wood, Perunovic e Lee (2009) não mediram fixação nem
memória; mediram humor logo depois de repetir uma frase dada, pior em quem
estava com a autoestima baixa e um pouco melhor em quem estava com ela alta. A
ADR 05x acabara de ensinar o app a dizer de onde vem cada método; os cinco
avisos que interrompem o autor continuavam sem isso, e um deles alegava mais do
que o estudo permite.

**A decisão.** O aviso passa a ser informação e pergunta: "Um estudo de 2009
mediu isto: repetir uma frase dessas fez quem estava com a autoestima baixa se
sentir pior, e quem estava com ela alta, um pouco melhor. O que aconteceu que
fez você escrever isso?" — o resultado nos dois sentidos, inclusive o
favorável; nenhum diagnóstico de em qual grupo o autor está, porque o app não
sabe; a pergunta do texto antigo preservada palavra por palavra, porque é a
parte que pede o FATO. Nada bloqueia: o aviso continua cartão, não porta. A
proveniência entra no formato da 05x (`Metodo.Proveniencia`, reutilizada):
`AnaliseLocal.proveniencia(doAviso:)` devolve FONTE, FUNÇÃO e EVIDÊNCIA — esta
com o limite junto do achado ("não mede escrever a própria frase, não mede
efeito duradouro, e não diz nada sobre você"). O aviso do plano sem obstáculo
aponta para a proveniência do WOOP no catálogo, não para uma segunda cópia que
possa divergir dela. Aviso sem fonte devolve `nil`: os três que são regra do
Traço, e não estudo, não ganham origem inventada. A regra fica travada por
teste: nenhum aviso pode conter "não gruda", "comprovad", "cientificamente",
"estudos mostram", "eficácia", "funciona" e afins.

**Custo assumido:** o dado existe e a tela ainda não o mostra — a linha "De onde
vem" no cartão de Aviso é a próxima volta, porque `CartaoAnaliseView` está
aberta na volta 12. O aviso ficou de 79 para 214 caracteres num cartão que
interrompe. O gatilho não mudou: a regex continua estreita
(`eu sou (rico|um vencedor|incrível|o melhor|imparável)`) e a rota da IA
(`afirmacaoVazia`) continua imprevisível — mexer nela antes de ter frases reais
do autor troca um aviso que não dispara por um que dispara errado.
**Volta:** multiplicar. **O que a IA sabe:** nada — o aviso é do algoritmo (ADR
04r) e a proveniência não viaja no prompt. **Prova:** 5 testes novos em
`AvisoSemAlegacaoTests`, provados contra o texto antigo (a guarda acusa
`não gruda` e a ausência de "2009"/"autoestima" — 4 issues); build sem aviso;
suíte integral 724 testes em 126 suítes, 0 falhas, no iPhone 17 Pro (teste 4)
em 06/09/2026. **Fora:** a linha na tela do cartão (volta seguinte), a
proveniência dos avisos que são regra do app, e o gatilho.

## ADR 2026-09-06g — A lista de formas nasce do catálogo, em todas as portas

**A distância.** Duas listas fechadas escritas à mão sobreviviam num app cujo
catálogo tem 21 métodos (28 com a colagem da M3, 36 com a leva 2). A primeira,
`@Generable enum GestoDeBordo` com dez casos mais `instrucoes` com dez
definições, em `AnaliseDeBordo`: **morta desde a ADR 04l**, que passou o esquema
e o prompt para `Catalogo.todos` — e viva o bastante para fazer três leitores
(um deles o orquestrador desta rodada) concluírem que a análise no aparelho só
conhecia dez formas. A segunda, `enum GestoEscolha: AppEnum` com NOVE casos, em
`Intencoes.swift`: essa estava viva. É a lista que a Siri e os Atalhos oferecem
ao autor no filtro "Só a forma" do corpus — 9 de 21 formas alcançáveis por voz
hoje (32% das 28 depois da colagem), e nada falhava para avisar.

**A decisão.** O enum morto e as instruções mortas SAEM: código morto que
descreve um contrato falso é pior que código morto. Ficam `esquema()` e
`instrucoesDoCatalogo`, que já nasciam de `Catalogo.todos`. O `AppEnum` dos
Atalhos vira `FormaEntity: AppEntity` com `FormaQuery: EntityQuery` —
`suggestedEntities()` devolve `Catalogo.todos`, então a Siri passa a oferecer o
catálogo inteiro, inclusive o método que o autor escreveu na pasta dele, sem
código. `AppEnum` exige `caseDisplayRepresentations` estático e por isso não
podia nascer de arquivo; entidade com consulta pode, e essa é a razão da troca.
Três testes travam o invariante: o esquema tem uma opção por método do catálogo
mais `nenhum`; as instruções listam TODOS os ids, não só o primeiro que alguém
conferiu; e os Atalhos oferecem exatamente `Catalogo.todos`, na mesma ordem.

**O custo do catálogo inteiro no `@Generable`, medido, não suposto** (iPhone 17
Pro de teste, Apple Intelligence disponível, 7 frases, esquema de 10 ids contra
o de 21): **5,38 s contra 5,56 s no total — 0,77 s contra 0,79 s por chamada,
+3,3%**, dentro do ruído de uma amostra deste tamanho (a primeira chamada, fria,
levou 2,15 s sozinha). Qualidade: com dez, 5 das 7 frases foram para a forma
errada — e as cinco que convocavam método fora dos dez **não tinham como**
acertar; com o catálogo, `argumento` e `steelman` passam a ser alcançáveis e a
frase do Argumento chega no Argumento. **Não há custo proibitivo a pagar, e a
lista curta nunca foi mais barata: era só mais surda.**

**Custo assumido:** um atalho já montado com o `AppEnum` antigo perde o
parâmetro (o app não foi publicado); a Siri e os Atalhos NÃO foram exercitados
de fora — o build de simulador não tem team-identifier (D1 do EVOLUCAO), então a
prova é de compilação e de teste, e a lista na tela dos Atalhos continua
pendente de aparelho. A medição é de 7 frases num aparelho, não uma bancada.
**Volta:** multiplicar. **O que a IA sabe:** as definições do catálogo, como já
sabia. **Prova:** `Test run with 730 tests in 127 suites passed` no iPhone 17
Pro (teste 4) em 06/09/2026, build sem aviso; números da medição acima.
**Fora:** a lista de Atalhos vista na tela de um aparelho real; bancada de
roteamento com mais frases.

## ADR 2026-09-06h — A escrita pessoal fica do autor: não vira método nenhum

**A distância.** O revisor da volta M3 mediu, com 58 frases dele e prova de
tela: **22 desabafos chegavam VESTIDOS de método de exercício.** A causa era
`AnaliseLocal.detectarGesto`, que pulava a Expressiva abaixo de 120 caracteres
e promovia a primeiro-a-casar quem viesse depois dela no catálogo. Com a
colagem, quem vem depois inclui dois métodos cuja regex é feita do vocabulário
do arrependimento e do silêncio em conversa. "Perdi a paciência com ela hoje. Me
arrependi e chorei." chegava como **EXAME DA NOITE**, perguntando "que hábito
ruim você curou hoje? que defeito você conteve?" a quem tinha acabado de
escrever que chorou (`ferramentas/orca/a3-antes-exame-da-noite.png`). E não é
sugestão: a `Sessao` VESTE a nota sozinha no caminho automático, enquanto a
Expressiva, quando ganha, só sugere — os dois caminhos não são simétricos, e o
que rouba é o que veste. O defeito tem duas metades: 14 linhas curtas com
palavra de sentimento, que o teto explica, e 8 desabafos LONGOS e FACTUAIS, que
passam do teto e são roubados assim mesmo, porque o léxico de dez palavras da
Expressiva não cobre o dia ruim contado sem adjetivo.

**A decisão.** `AnaliseLocal.eEscritaPessoal` — uma guarda, não um método —
decide antes do laço, e **nenhum método leva a nota, venha ele antes ou depois
da Expressiva no catálogo**. A guarda é de CINCO famílias, não de uma lista de
frases (o revisor da volta A-B mostrou o defeito de lista: `me odiando` pegava e
`me odiei` não):

1. **o estado, por RADICAL** — `senti|sinto`, `dói|doeu`, `chor…`, `trist…`,
   `raiva`, `medo`, `pesa…`, `desmoron…`, `arrepend…`, `vergonh…`, `mago…`,
   `remoend…`, `travei|eu travo`, `angusti…`, `ansios…`, `exaust…`, `vazio|a`,
   `sozinh…`, `cansad…`, `desanimad…`, `humilhad…`, `culpad…`, `nó na garganta`.
   O radical é o que faz a família não ser lista: pega a flexão que ninguém
   escreveu ainda;
2. **o juízo sobre si** — `me odi|culp|detest|despre`, `não sirvo|presto|valho`,
   `sou o|um|uma problema|lixo|fracasso|idiota|péssimo`, `a culpa é minha`,
   `estraguei`, `me sentindo um|uma`. Em qualquer tamanho: "eu sou o problema"
   não fica menos pessoal em oitenta caracteres;
3. **o funcionamento básico negado** — `não durmo|consigo dormir|como mais|rio|
   aguento|tenho vontade|saio da cama|consigo mais`. É o desabafo que não usa
   nenhuma palavra de sentimento e mesmo assim só fala de si;
4. **o que eu fiz A ALGUÉM**, em qualquer tamanho — `fui injust|gross|duro
   demais|ríspid`, `perdi a paciência|cabeça`, `tratei mal`, `briguei`,
   `discuti com`, `gritei com`, `xinguei`, `explodi com`, `descontei com|no|na`.
   O teto de 120 era a régua errada aqui: contar que se foi grosso com o irmão é
   desabafo com noventa caracteres tanto quanto com quatrocentos;
5. **o que eu DEIXEI de fazer** (`engoli`, `fiquei calad`, `deixei passar`, `não
   devia ter`) — e este sim **só acima do teto de 120**: curta, "fiquei calada
   quando perguntaram" é a nota que nomeia uma conversa, e o método que pergunta
   serve; longa, é o dia sendo despejado.

E o **rodapé do Destaque** (três linhas curtas sem regex nenhuma) obedece o
mesmo cálculo: ele computava `pessoal` e nunca usava. "Briguei com ela. / Não
pedi desculpa. / Dormi no sofá." não é uma lista para destacar.

A guarda vive em CÓDIGO e não no `Metodos.json` por duas razões medidas: a pasta
do autor reescreve o catálogo, e uma fronteira do produto não pode morar num
arquivo editável; e alargar a Expressiva por DADO deixaria os dois métodos novos
inalcançáveis (medido pelo implementador da M3-B com 287 sondas). A guarda não
depende mais da POSIÇÃO no catálogo — a primeira versão só valia para a cauda, e
o revisor da volta A-B mediu **15 de 20 desabafos novos ainda vestidos** pelos
cinco métodos que vêm ANTES da Expressiva (`woop`, `seEntao`, `spec`,
`notaPermanente`) e pelo rodapé do Destaque. O teto de 120 continua sobre a
Expressiva: nota curta não vira desabafo, e as 14 curtas voltam ao SILÊNCIO que
tinham antes da colagem, não a uma sugestão nova. **O título honesto é este:**
8 dos 22 desabafos protegidos não vão para a Expressiva, vão para o silêncio —
o que a guarda garante é que a escrita pessoal fica do autor, não que ela vira
Expressiva.

**Custo assumido, medido com as 287 sondas do M3-B (remedido na volta A-B, com o
`Metodos.json` das 28 formas da M3, DEPOIS do conserto):** a guarda fecha **14 de
287 ramos (4,9%) para TEXTO LONGO** — 3 da Coluna da esquerda (`engoli`, `fiquei
calado`, `deixei passar`) e **11** do Exame da noite (`me arrependi`, `não devia
ter feito|reagido|agido|tratado`, `fui injusto|grosso|duro demais|ríspido`,
`perdi a paciência|cabeça`). Eram 14, não 15: `hoje eu tratei` continua chegando
ao Exame, porque a sonda é "tratei" e não "tratei mal". **Nenhum método fica sem porta:** a Coluna continua sendo
chamada por "não disse", "não consegui dizer", "devia ter dito", "queria ter
dito", "a conversa com", "na reunião com"; o Exame por "exame da noite", "passei
o dia em revista", "hoje eu fiz|reagi|tratei" — provado na tela com o Exame
chegando normalmente depois da guarda
(`ferramentas/orca/a3-o-exame-continua-alcancavel.png`). Duas frases legítimas
do revisor mudam de dono e vão para o silêncio: "Tenho medo de estar trabalhando
na coisa errada há dois anos" e "sinto que o esforço não está indo pro lugar
certo" — as duas com palavra de sentimento, as duas que iam para a pergunta de
Hamming. **É o lado certo do erro:** silêncio devolve a nota ao autor; vestir
carimba quatro campos de exercício sobre o que ele acabou de sentir. E é dito
aqui porque o `todoRamoDeRegexAlcancaOSeuMetodo` da volta M3 vai ficar VERMELHO
quando esta guarda entrar: os 14 ramos precisam entrar no `conhecidos` dele, com
esta ADR como motivo. **As catorze entradas, medidas e literais:**
`colunaEsquerda|deixei passar|silencio`, `colunaEsquerda|engoli|silencio`,
`colunaEsquerda|fiquei calado|silencio`, `exameDaNoite|fui duro demais|silencio`,
`exameDaNoite|fui grosso|silencio`, `exameDaNoite|fui injusto|silencio`,
`exameDaNoite|fui ríspido|silencio`, `exameDaNoite|me arrependi|silencio`,
`exameDaNoite|não devia ter agido|silencio`,
`exameDaNoite|não devia ter feito|silencio`,
`exameDaNoite|não devia ter reagido|silencio`,
`exameDaNoite|não devia ter tratado|silencio`,
`exameDaNoite|perdi a cabeça|silencio`, `exameDaNoite|perdi a paciência|silencio`.

**A regra escrita, agora em QUATRO linhas, nesta ordem** (`Sessao.escolher`):

1. **aviso local vence sempre** — o aviso é do algoritmo (ADR 04r);
2. **escrita pessoal reconhecida pelo algoritmo CALA o modelo** (nova);
3. **silêncio do modelo devolve a palavra ao algoritmo** (ADR 04c);
4. **forma do modelo manda.**

A linha 2 é a mais forte de todas, e ela fecha um buraco que a versão anterior
desta ADR chamou de "pode contradizer" quando o certo era "vence sempre": a
guarda devolvia `.silencio`, e `.silencio` tem precedência ZERO — com conta Grok
ou com Apple Intelligence ligada bastava o modelo devolver uma forma para a nota
protegida ser VESTIDA (e no caminho automático `aplicar` veste, não sugere). Ou
seja: a proteção era nula exatamente na configuração padrão de um iPhone
moderno, o caso que ela existe para impedir. O modelo recebe
`instrucoesDoCatalogo`, que descreve o Exame da noite inteiro; "Me arrependi e
chorei" é a frase que ele foi ensinado a classificar. `Sessao` calcula
`AnaliseLocal.escritaPessoal(texto:campos:)` do texto cru, com o mobiliário
fora, e passa o resultado para `escolher`.

**E foi provado NA TELA, com o modelo ligado.** O simulador não tem conta xAI
nem Apple Intelligence — foi por isso que o buraco nasceu invisível. Um modelo
de mentira, só em DEBUG e ligado pelo AMBIENTE do simulador
(`TRACO_MODELO_FALSO`, no mesmo canal do `TRACO_SEM_MODELO` da 03p), torna o
degrau de cima observável. `maestro/escrita-pessoal.sh` roda dois fluxos, e o
**primeiro é o controle**: com `TRACO_MODELO_FALSO=woop`, "Amanhã eu arrumo a
estante da sala" — que regex nenhuma alcança — chega VESTIDA de WOOP, com os
três campos abertos (`ferramentas/orca/ab-modelo-veste.png`). Sem esse controle
o segundo fluxo não mede nada, porque "nenhum cartão" também é o que se vê com o
modelo desligado. No segundo, com o MESMO modelo ligado, "Perdi a paciência com
ela hoje. Me arrependi e chorei." fica na página sem cartão nenhum
(`ferramentas/orca/ab-cala-o-modelo.png`).

**Volta:** multiplicar. **O que a IA sabe:** nada de novo. **Prova:**
`EscritaPessoalTests` com os SETE métodos da M3 carregados pela pasta do autor
(o `Metodos.json` é da M3 e não foi tocado) e **três réguas somadas, 57 frases**:
as 22 do revisor da M3, as 15 que o revisor da volta A-B mediu chegando vestidas
pelos métodos ANTES da Expressiva, e **20 minhas, escritas depois do conserto,
uma por PORTA do catálogo** — `cadaUmaDasMinhasBateNumaPortaDiferente` cobra que
cada uma bata mesmo na regex do método que ela declara, senão a régua não mede
nada. Sem a guarda o mesmo arquivo acusa as 22 uma a uma; a régua é a do M3-B
(escrita pessoal não vira `.gesto` NENHUM, não só os dois novos). Os 14 ramos
foram REMEDIDOS depois do conserto, com o `Metodos.json` das 28 formas da M3 e o
expansor `Sondas` da M3: `sondas totais: 287`, `ramos novos: 14`, a lista acima
palavra por palavra. Tela em `a3-antes-exame-da-noite.png`,
`a3-depois-a-nota-fica-do-autor.png` e `a3-o-exame-continua-alcancavel.png`, os
três no iPhone 17 Pro (teste 4) com os sete métodos semeados e
`TRACO_SEM_MODELO=1`. **Fora:** a assimetria vestir/sugerir, e o `conhecidos` da
M3 (a lista está aqui; quem mesclar a M3 a cola).

**Junto nesta ADR, a voz do app sobre si mesmo** (auditoria da trilha Métodos:
as doenças da voz se concentram onde o app fala de si). Três trocas de palavra:
o Perfil dizia "O que o Traço aprendeu de você" em cima de uma CONTAGEM ("12
sinais desde 3 de setembro") — passa a "O que o Traço registrou — contagem, não
conclusão"; a Lente chamava de "Muletas" uma lista que inclui "acho que", "um
pouco" e "na verdade", que são os hedges que o próprio catálogo ENSINA a usar (a
Inversão diz "costuma ser") — passa a "Palavras de apoio", com a nota
"contadas por palavra inteira", e o mesmo rótulo no apontamento de versão
(`RotuloApontar.muleta`, que a auditoria não viu e é a mesma palavra); e o aviso
do plano sem obstáculo dizia "o que, em você, COSTUMA atrapalhar isto",
atribuindo ao autor um hábito que o app não observou — passa a "pode".

