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
`reduzido:`. (**O "ou" desta frase foi a ambiguidade que trouxe a classe A1 de
volta cinco vezes: a 05y, V12-D, escolhe o CORTE, e sob reduzido só a opacidade
anima.**) `CalendarioTema` cita `Tema` em vez de repetir hex e número.
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

10. **A palavra do estado não se parte ao meio** (Re-G3, N1/N2/N3). A F4-C
   declarou o custo de AX5 pela metade — escreveu que a frase do Destaque
   "cede uma linha", quando na tela ela terminava em RETICÊNCIAS
   (`Terminar / o / capítul…`); não declarou que `Desatualizado.` quebrava com
   HÍFEN NO MEIO (`Desatualiza-/do.`) no pequeno do Próximo, que é a mesma
   família do `PRÓXI-/MO` do item 2; e atribuiu ao rodapé um corte que já
   existia sem ele, no ramo "o vazio traz o Destaque". Nenhuma das três é
   troca: são propriedades que ficaram para trás. A frase do Destaque passa a
   `minimumScaleFactor(0.6)` com `allowsTightening`, nos dois lugares onde
   ela é desenhada — a receita que `Velho()` já usava três linhas ao lado, e
   que faz a frase ENCOLHER inteira em vez de cortar. E o teto de linhas da
   frase de estado sai da view e vira `LinhasDoEstado`, em `Relogio.swift`,
   com suíte: **palavra sem espaço não tem quebra honesta**, então recebe uma
   linha só e encolhe; com espaço, quebra a linha e sai no corpo cheio. Com
   teto maior que 1 o SwiftUI prefere hifenizar a encolher, e era isso que
   partia a palavra que diz a verdade. A troca do item 8 continua de pé — o
   estado ganha do comprimento da frase —, mas o custo dela deixa de ser
   pago: cabem os dois.

**Custo assumido.** O pequeno tem um destino só (`widgetURL`): "Recordar"
continua no médio e no app, não no pequeno — o sistema não honra `Link` no
`systemSmall`. Em tamanho de acessibilidade o médio abre mão dos atalhos e da
agenda: a única coisa de hoje vem primeiro — mas **"+N depois" não some mais**
(G3, A8), porque esconder informação para limpar a tela é o que o AGENTS.md
proíbe. **Em AX5, no pequeno, com Destaque longo e horizonte vencido, a frase
do Destaque tem três linhas em vez de quatro e ENCOLHE até 60% para caber
nelas** — este é o custo inteiro, medido na tela: não há reticências em lugar
nenhum, nem hífen no meio de palavra, em nenhuma das quatro famílias, em
nenhum dos dois temas. `Relogio.swift` compila também no alvo de testes (`project.yml`),
porque a lei que faltou à 05u tinha de caber numa suíte. O espelho da
permissão é o mínimo honesto dentro desta volta: a unificação com
`PromessaDoAviso` (volta 18, ainda não mesclada) é a volta seguinte.

### F4-E — a face não fecha um número que ela não sabe (correção do G4)

O G4 recusou por um degrau em cinco eixos e o achado mais pesado era da
dimensão *Fora do app*: com **cinco** compromissos no calendário a superfície
carrega três e o pequeno imprimia **"+2 depois"** — uma contagem exata,
derivada de uma lista que a própria face sabia cortada. O dono lia "+2" e
acreditava que o dia dele tinha três. Número errado é pior que nenhum, porque
encerra a dúvida.

1. **O instantâneo passa a carregar quantos há** (mudança de contrato da 05u,
   declarada): `Superficie.alemDaLista: Int?` guarda quantos compromissos do
   horizonte NÃO couberam. É opcional de propósito — documento gravado antes
   desta conta decodifica com `nil`, que quer dizer *não sei*, e a face que não
   sabe diz "mais depois", sem número (`Restantes` em `Relogio.swift`, com
   suíte). O CORTE mudou de lugar: `proximasFatias` devolve o horizonte
   inteiro e quem corta é `publicar`, junto de `candidatas` e de `validoAte` —
   quem corta conta. `Superficie.candidatas` desceu para o documento porque o
   alvo do widget não compila `ProximoCompromisso` e precisa do número para
   saber se a lista que tem na mão está cortada.
2. **A guarda do idêntico e o mapa de reload passaram a ver o documento
   inteiro.** O sexto compromisso do dia não muda os três publicados, muda
   quantos faltam: sem `alemDaLista` na comparação a escrita era descartada
   como "idêntica" e a face seguia contando errado. E o mapa "kind afetado" era
   da F2, quando cada face lia METADE do documento — desde a F4 o widget do
   Traço mostra a agenda e o do Próximo mostra o Destaque, então **os dois
   kinds recarregam sempre**; recarregar só "quem mudou" deixava a agenda de
   ontem embaixo do Destaque de hoje. Quem economiza orçamento é a guarda do
   idêntico, e ela ficou onde estava.
3. **Quem decide quantas linhas cabem é o layout, não um `if`.**
   `AgendaQueCabe` (`ViewThatFits`) prova três, duas, uma — e cada candidata
   leva junto a conta do que ela mesma deixou de fora, então o número nunca
   descreve outra lista. A guarda `!tipo.isAccessibilitySize` que escondia a
   agenda inteira caiu: em AX5 a face mostra o que cabe e, quando não cabe nem
   uma linha, diz quantos vêm. Espaçador flexível DISPUTA altura com o
   `ViewThatFits` e com o texto — por isso os espaçadores dessas faces viraram
   padding, o conteúdo ganhou `frame(maxHeight: .infinity)` e a linha do
   Destaque ganhou `layoutPriority(1)`: sem ela o VStack repartia a altura em
   fatias iguais, a frase recebia menos do que o teto de linhas pedia e saía
   com reticências — a família da C causada pela REPARTIÇÃO, não pela
   propriedade.
4. **`BlocoProximo` no mesmo degrau dos irmãos** (achado C): `0,85` não chega
   em 155 pt e o pequeno saía "Café com o Pe…" — o nome do compromisso, que é
   a informação. Fechada a classe com uma varredura: **os 24 `lineLimit` e os 8
   `minimumScaleFactor` do alvo, conferidos um a um** face por face (o arquivo
   terminou com 31 e 24), com seis divergências corrigidas: o rótulo do `Selo`;
   a hora e o assunto da
   `LinhaProximo`, que passou a sair em AX5; a hora e o título do
   `BlocoProximo`; `DESATUALIZADO` e a linha do Destaque na tela bloqueada; e
   o `PRÓXIMO` da bloqueada, que não tinha teto de linha NENHUM — é o
   `PRÓXI-/MO` original, vivo na superfície que o dono mais olha.
5. **O quadro de ofertas é um só** (`QuadroVazio`), e agora o do Próximo vazio
   também — calendário vazio é o estado mais comum num app de escrita. Com o
   alvo de 44 pt do achado G, **três ofertas não cabem num médio** (medido na
   tela): são duas, uma em AX5, e elas PREENCHEM a altura que sobra, então não
   há mais cartão morto embaixo. A terceira continua no cabeçalho e no app.
6. **O risco do feito aparece** (achado F) e **o toque tem eco** (achado H).
   `.strikethrough` como modificador não chegava à tela ao conviver com
   `minimumScaleFactor`; como atributo de run, chega. Só que
   `Text(AttributedString)` ignora `minimumScaleFactor` e `allowsTightening` —
   então cada estado leva o caminho que serve a ele: a linha POR FAZER é texto
   simples e encolhe inteira; a linha FEITA, que já é recibo e não leitura,
   vira atributo e ganha o traço. `.invalidatableContent()` nos dois botões do
   feito, e `.contentTransition(.numericText())` na hora do bloco.
7. **A promessa e o destino, a mesma frase** (achado J): com o instantâneo
   velho a face dizia "Abrir o Traço para atualizar" e o toque abria uma
   PÁGINA EM BRANCO; passa a abrir o app (`traco://notas`), que é o que
   republica.

**Custo assumido:** o alvo de 44 pt do cabeçalho custa uma linha de agenda no
médio do Traço — as duas coisas que o juiz pediu não cabem juntas, e entre um
alvo de 16 pt e uma linha a mais fica o alvo; a face diz o que não mostrou, e
por isso nada fica escondido. O achado I (o quadro lê como lista de Ajustes)
não foi tratado: as ofertas agora preenchem a altura e têm primária em âmbar,
mas a forma continua glifo + palavra.

**Prova:** 6 testes novos (`RestantesTests`: dia inteiro na face, cinco no dia
com um na face = "+4 depois" e não "+2", instantâneo que não sabe não publica
número, a voz acompanha a tela, lista curta sabe sozinha; `ForaDoAppTests`:
cinco publicados de ponta a ponta com `alemDaLista == 2` e o sexto compromisso
acordando a escrita que a guarda do idêntico descartaria, e as duas faces
recarregando juntas), suíte **773/133**, dois alvos sem aviso. Capturas do
build desta volta, plantadas na casa pelo `IconState.plist` (a galeria não é
preciso): `ferramentas/orca/f4e-casa-claro.png`, `-escuro`, `-ax5-claro`,
`-ax5-escuro`, `f4e-ax5-nome-inteiro.png` (o recorte onde o juiz leu "Café com
o Pe…" e agora se lê o nome inteiro com "+4 depois"), `f4e-vazio.png`,
`f4e-feito.png`, `f4e-feito-risco.png` e `f4e-desatualizado.png` (o horizonte
vencendo sozinho pela linha do tempo, não por remendo no arquivo).
**Fora:** tela bloqueada e StandBy seguem sem render no simulador; o toque
(e portanto o vídeo do eco do feito) exige janela, que este instrumento não
tem.

**Volta:** multiplicar. **A IA:** nada. **Prova:** 17 testes (11 em
`LinhaDoTempoWidgetTests` — a política sempre devolve volta, com teto, piso e
orçamento; véspera/início/fim/meia-noite/soneca na linha; nada no passado,
nada repetido, linha curta — e 2 em `SinoHonestoTests`: sem permissão no
último olhar a superfície sai sem sino nenhum, e com permissão o sino volta;
e 4 em `EstadoNaFaceTests`: nas quatro combinações de velha × conteúdo, velho
é SEMPRE dito — a lei que a R1 quebrou; e 3 em `LinhasDoEstadoTests`: palavra
sem espaço ganha uma linha e encolhe, frase com espaço usa o teto — o corte
que se via na tela e em suíte nenhuma);
suíte **732/128** na volta, **764/131** depois do `merge main` e **767/132**
com a correção do corte em AX5, dois alvos sem aviso (os únicos 4 `warning:` da suíte estão em `TracoTests/ConferenciaTrabalhoTests.swift:381`, que veio da main); capturas por estado nos dois temas
de verdade (`ferramentas/orca/f4b-*.png`, brilho médio 187,5 claro × 140,1
escuro), as QUATRO famílias plantadas na casa, o horizonte virando sozinho
para `Desatualizado.` inteiro, a oferta inteira em AX5, os sinos com e sem
permissão, e `sem dados` na tela. As QUATRO famílias em AX5, nos dois temas,
com Destaque longo e horizonte vencido, sem reticências e sem hífen no meio
da palavra do estado: `ferramentas/orca/f4d-ax5-claro.png`,
`f4d-ax5-escuro.png`, e o ramo "o vazio traz o Destaque" com a superfície
fresca em `f4d-ax5-vazio-destaque-claro.png` e `-escuro.png`. O `chronod` registrando a releitura
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

## ADR 2026-09-05y — A página não perde o pé

**A distância.** A auditoria da volta 9 deu 6,7 à Página+Caderno, a porta de
entrada da escrita. O cartão da forma vestida tomava o rodapé: régua e ações
SUMIAM sob o dedo — o toque mirado em "Todas" caiu no texto do cartão
(`v9-caderno-menu-todas.png`, reproduzido no 17e); em AX as ações da página
ficavam fora da vista e o texto rolável cortava a meio glifo (G4 da volta 8);
`.primario` e `.compacto` pressionavam por opacidade contra a ADR 02h e a
célula nova usava `Mola.escala` sob a classe `.deslocamento` (G4 da volta 10);
`Camadas` não devolvia a posição quando o binding recusava (re-G3 da volta 7); e as telas desenhavam rótulo, cápsula, cartão e botão à mão.

**A decisão.** (1) O pé é desenho do dono (05f) e não sai do lugar: cartão,
aviso e "lendo…" passam a viver ACIMA da régua e das ações, no mesmo encaixe
(`CadernoView.acima`), e quem anima é a ALTURA do container (§21); o rodapé
deixa de ter "um ocupante por vez" e a linha de gravação recusada (05s) não
cobre mais a barra. (2) As saídas do cartão moram no pé DELE em todo tamanho,
e o texto que passa da dobra ganha degradê enquanto há mais para ler. (3) Em
AX o pé tem "Trabalhar nisto" como BOTÃO e o resto num menu, "Mais ações da
nota" (lado a lado as quatro ações espremiam o rótulo a "Mais ações d…"; com as
cinco dentro do menu, o menu ficava mais alto que a tela e a quinta só existia
depois de rolar — G3 da V12, M3), e a régua cede ao cartão. (4)
`BotaoPrimario`/`BotaoCompacto` pressionam só por escala; `CartaoBotaoStyle`
morre e o cartão cita `.primario`. (5) A célula nova entra com `Duracao.media`
easeOut, a classe que declara. (6) `Camadas.onEnded` devolve a posição quando
o binding recusa — a aritmética mora em `Trilho.posicaoAposRecusa`, fora do
gesto, para ter teste. (7) Página e Caderno migram para `.rotulo`, `.cartao`,
`Pilula`, `CabecalhoDeFolha` e `.discreto`; a folha dos campos troca o "Voltar
à página" em âmbar sobre branco (2,0:1) pelo cabeçalho da casa.

**A lei do movimento, escrita como a tela a cumpre (correção do G3, V12-B).**
Quem anima é a ALTURA do encaixe; o CONTEÚDO corta. Três coisas fazem isso ser
verdade e não intenção: (a) o `.safeAreaInset` pendura numa identidade ESTÁVEL —
`paginaCaderno` troca de ramo quando os campos nascem, e com o encaixe pendurado
no ramo o SwiftUI trocava a árvore inteira e dissolvia o pé velho sobre o novo
(régua legível em duas posições, uma na linha de base de "Trabalhar nisto");
(b) régua, aviso, cartão e "lendo…" entram e saem por `.identity` — `.move(edge:
.bottom)` desliza a régua POR CIMA do rodapé, e o `.clipped()` é do VStack
inteiro, não separa irmão de irmão; (c) o cartão tem identidade por CASO, senão
o texto de `.forma` dissolve sobre o de `.vestida` nas mesmas linhas. Vale com e
sem Reduzir Movimento (`v12b-pe-quadros.png`, quatro linhas).

**O resíduo da mesma classe, e a última peça (correção do Re-G3, V12-C).** A
(a) acima consertou o encaixe, não a CAUSA de ele ser redesenhado. `paginaUna`
tinha DOIS ramos — com e sem `abaixo` —, e vestir a forma cria os campos: o ramo
trocava, o SwiftUI recriava o EDITOR, o foco caía, o teclado descia e o encaixe
inteiro era desenhado em duas geometrias ao mesmo tempo. O que se via era o pé do
cartão ("Abrir os campos" / "Deixar como nota") e o pé da página ("Trabalhar
nisto" e as ações) dissolvidos SOBRE o texto do cartão, por ≈15 quadros, com E
sem Reduzir Movimento — o Re-G3 filmou (`v12reg3-cruzamento-cartao-rm.png`).
Bissectado por experimento, como o A1: matar as duas `Tema.gaveta` apagava o
fantasma (prova de que a animação era o veículo), mas matar cada uma sozinha
não; `.transaction { $0.animation = nil }` no corpo também não. O que apaga é
tirar o RAMO: `paginaUna` passa a ter um só, e a diferença entre os dois casos
vira VALOR — sem campos o editor ocupa a altura do container (o papel inteiro
segue alvo do cursor), com campos ele cede o que não usa e os campos entram por
baixo. O editor mantém identidade e FOCO: o teclado não desce mais quando a
forma veste, que é a lei do dono (§3 — o cursor não se perde) e de quebra apaga
o cruzamento. No mesmo lugar, os campos passam a NASCER cortando
(`abaixo?.transition(.identity)`): o fade padrão do Optional era um véu sobre o
papel, e sob Reduzir Movimento nada dissolve. A página vazia é **0 px** de
diferença contra `69bec69` fora da faixa de sugestão do teclado do iOS. Prova: `v12c-pe-quadros-sem-rm.png` e `v12c-pe-quadros-com-rm.png`,
sete quadros a 30 fps por linha, antes (`69bec69`) e depois em cada modo.

**O papel tem piso, e o cartão vale uma linha enquanto se escreve (correção do
G4, V12-D).** O G4 mediu o preço que ninguém tinha medido: com o TECLADO DE PÉ —
o único estado em que se escreve — o cartão da forma vestida ocupava 413 pt, 47%
da tela, e deixava **33 pt de papel**; o juiz digitou 37 caracteres depois de o
cartão chegar e NENHUM apareceu. O defeito da V9 não tinha acabado: o cartão
saiu de cima da régua e das ações e foi para cima **do papel**, que é pior,
porque o que ele cobre é o trabalho do autor. Duas decisões, e a régua é uma só:
*o texto que o autor está digitando fica na tela*. (1) **Piso do papel.** O teto
do cartão deixa de ser absoluto (440/380): o encaixe leva o que SOBRA —
`CadernoView.tetoDoEncaixe(altura:pe:piso:)`, altura desta view (com teclado, a
tela menos o teclado) menos o pé medido menos o piso, e o piso é três linhas de
corpo (`@ScaledMetric` 92) mas nunca mais de METADE do que sobra, porque em
tamanho AX três linhas de corpo não cabem com o cartão e um piso maior deixaria
o autor sem as saídas em vez de sem texto. É a mesma medida que conserta o
transbordo em AX5 (A4): a pilha passa a caber, "Mais ações da nota" — a ÚNICA
porta das quatro ações em AX — fica acima do teclado, "Deixar como nota" deixa
de ser cortado em "Deixar" e a topbar sai de cima da barra de estado. (2) **Com
o teclado de pé o cartão é UMA LINHA**: o trilho âmbar e a frase que importa,
cortada numa linha; fora de AX as duas saídas ficam logo abaixo dela, à vista;
em AX elas não cabem ao lado e a linha vira MENU — o mesmo desenho que o pé da
página já usa em AX. Um toque na linha abre a prosa NO LUGAR, sem mexer no
teclado: derrubar o teclado aqui foi tentado e filmado, e a barra do pé viaja
334 pt enquanto o cartão cresce, com os dois legíveis na mesma faixa por ~165 ms
— a classe A1 outra vez. Quatro cartões NÃO recolhem: o aviso e o "sem conta"
(esconder falha para limpar a tela é o que o contrato proíbe), o "pensando…" e a
RESPOSTA DA SÁBIA — essa o autor pediu, e entregá-la recolhida seria esconder o
resultado de quem o mandou vir (`curva-zero` §2). No mesmo lugar, a régua deixa
de ter gaveta ao seguir o FOCO: ela entra e sai com o teclado, e o teclado já
tem a sua curva — uma gaveta de 0,4 s por cima de uma descida de 0,25 s são dois
relógios no mesmo evento, e o que se via era o pé numa geometria e o cartão
noutra. **Custo assumido:** com o teclado de pé, a prosa do cartão fica atrás de
um toque; em AX, as saídas também — declarado, como a régua que já cede ao
cartão em AX. **Limite conhecido, não corrigido aqui:** nota MAIS ALTA que o
papel visível continua a mostrar as PRIMEIRAS linhas enquanto se escreve no fim
— o `TextEditor` desta página não rola sozinho e quem rola é o `ScrollView` de
fora, que não segue caret. É anterior a esta volta (só aparecia agora que há
papel para ver), foi medido, e a correção mexe na estrutura de `paginaUna` que a
V12-C acabou de estabilizar: vai para o RUMO com a prova.

**A lei do movimento reduzido escolhe o corte, e é do app inteiro (correção do
G4, V12-D).** A 05v dizia "deslocamento → fade curta OU corte", e a
implementação escolhia a fade: `Tema.movimento(.deslocamento, …, reduzido:)`
devolvia `fadeReduzido`, que é `.easeOut(0,15)` — uma DURAÇÃO menor, não um
corte. A geometria continuava a ser interpolada, só que depressa; e quando os
filhos do container são texto legível, essa interpolação é um cross-dissolve de
duas geometrias. Foi o que produziu a QUINTA ocorrência da classe A1, no toque
em "Abrir os campos": ~215 ms sem Reduzir Movimento e **~370 ms COM** — mais
lento com RM do que sem, o contrário do que RM promete. O "ou" era a
ambiguidade. **Esta ADR escolhe o corte**, e a lei fica de uma linha só: sob
Reduzir Movimento **só a opacidade anima**; deslocamento, escala e laço cortam.
`fadeReduzido` deixa de existir — não sobrou caso para ele: quem quer uma fade
declara a classe `.opacidade`, que mantém a animação que a view pediu.
`Tema.animacao` (o nome curto do deslocamento) e `Tema.gaveta` passam a devolver
`Animation?`; `Tema.corte` fica como o mesmo corte com o nome à vista de quem
move com o dedo ou com o relógio. **Vale para as 12 chamadas de `.deslocamento`,
as 8 de `animacao`/`morph` e as 4 de `gaveta` do app**, não só para a Página:
`CalendarioTema.morph` também devolve `nil` sob RM. Prova nos dois lugares, em
quadros nativos: na Página, a linha que abre a prosa e o toque em "Abrir os campos", sete quadros
nativos por linha, SEM Reduzir Movimento (`v12d-sem-rm-quadros.png`) e COM
(`v12d-com-rm-quadros.png`): o cartão está num quadro e não está no seguinte, e
em nenhum há par legível na mesma faixa — **afirmação corrigida pela V12-E
(08f): o G4 final mediu ~100 ms sem RM e ~125 ms com, e a prova passa a ser
amostrada, nunca universal**; no **Calendário**, tela de outra volta,
Dia→Semana e Semana→Mês sob RM em UM quadro cada
(`v12d-calendario-rm-corta.png`), onde a fade de 0,15 s dava uma interpolação de
quatro a cinco. A chegada do cartão sob RM também virou um quadro
(`v12d-com-rm.mp4`). **Custo assumido:** sob Reduzir Movimento a
chegada do cartão deixa de crescer de baixo para cima — ela aparece. O G4 tinha
gostado desse crescimento (M2), mas é a mesma regra que trazia o fantasma de
volta em cada gatilho novo; a lei não pode dizer duas coisas. **Resíduo medido,
não corrigido:** ao apresentar a folha dos campos, o rótulo "Todas" (a porta da
régua) fica no lugar por alguns quadros enquanto o pé desce — sobre o fundo da
barra, nunca sobre texto. É a fotografia que o `.sheet` tira da tela que
apresenta, não uma animação nossa.

**Prova da V12-D.** Suíte **760/0 em 128 suítes** no iPhone 17 Pro C2416CBC
(`✔ Test run with 760 tests in 128 suites passed after 7.982 seconds.`),
06/09/2026, com dois testes novos: `oPapelTemPiso` (a aritmética do teto, com os
números do G4 — 446 pt disponíveis, pé de 90, piso de 92 → 264 de encaixe e 92
de papel; e o caso apertado onde o piso cede a metade) e `oAvisoEARespostaNaoRecolhem`.
Medido na tela, no mesmo estado do G4 (`large`, teclado de pé, forma vestida,
captura `simctl` 1206×2622): base da topbar **94 pt** (o mesmo ponto que o G4
mediu), topo do cartão **235**, teclado em **540** — **papel 141 pt** contra os
33 do G4, encaixe **305 pt = 35% da tela** contra 413 = 47%, e a frase inteira
"quero correr de manhã e nadar à noite quando der, sem falta" na tela com o
caret (`v12d-large-vestida-teclado.png`). AX5 no mesmo estado
(`v12d-ax5-vestida-teclado.png`): topbar fora da barra de estado, uma linha de
papel, cartão numa linha e "Mais ações da nota" INTEIRO acima do teclado; as
duas saídas no menu da linha, sem corte (`v12d-ax5-menu-do-cartao.png`). O par
antes/depois do estado que decide (M1 do G4) é este contra as capturas do
próprio G4, que são o "antes" com o teclado de pé:
`g4-v12-cartao-come-o-papel.png` e `g4-v12-ax5-cartao.png`. Swift do app
**+261 líquidas** (+337 −76; 123 das linhas somadas são comentário), portanto a
V12-D também NÃO cumpre a regra de shortstat líquido-negativo da 05v — pelo
mesmo motivo declarado na V12-B: tirar duas decisões de dentro de `body` para
elas terem teste, e escrever no código a bissecção que custou três voltas.

**A aresta é do material, não do chamador (correção do G3, V12-B).** `Cartao`
devolve o fio de `Tema.linha` 0,5 a todo branco sobre o papel (`.papel` e
`.flutuante`) e a segunda sombra, a de CONTATO (r2 y1, SISTEMA-CLARO §1.5), ao
`.flutuante`. A migração da volta havia apagado as duas sem declarar: o aviso
— a superfície onde mora a linha de gravação recusada da 05s — virou branco sem
aresta sobre #F4F4F2, e os três portais do caderno perderam o `strokeBorder` que
tinham em main. `luzBorda` FICA fora: é branco sobre branco no mundo claro.

**Custo assumido.** Em AX, com o cartão em cena, a régua não está à vista: as
formas voltam a um toque quando ele sai; uma terceira barra não cabe. Em AX o pé
passa a ter DUAS linhas (botão + menu), e é o texto do cartão que rola por elas
— o pé não cede (V12-B). O fio de `.papel` alcança quem mais usa o estilo: o
cartão da sábia e o campo de busca das Notas e os três portais do caderno ganham
a mesma aresta de 0,5 — restauração no caderno, refinamento nas Notas. O alvo
da aba do arquivo foi de 23 a 44 pt sem mover um pixel (a cápsula segue 4×64).
A aba na página vazia oscila com a corrida do teclado (1 de 3 em main, 2 de 3 no branch, mesma faixa y): anterior à volta, fica na FILA.

**Prova.** Build sem aviso novo; suíte **718/0 em 125 suítes** no iPhone 17
Pro C2416CBC (`✔ Test run with 718 tests in 125 suites passed after 7.695
seconds.`), 06/09/2026 — as 716 do G3 mais as duas que faltavam: `Camadas`
devolvendo a posição quando o binding recusa e `esconderRegua` só em tamanho AX.
Movimento filmado nos dois modos nos DOIS builds (`v12b-pe-quadros.png`,
`v12b-vestir.mp4`, `v12b-rm-vestir.mp4`). Aresta MEDIDA na coluna x=600 do mesmo
estado: no topo do cartão o papel (242) ia direto ao branco (252) e agora passa
por 238; na base, 252 → 230 virou 252 → 238 → 205 → 217 → … → 229 — o fio mais a
sombra de contato (`v12b-aresta-cartao.png`, `v12b-aviso-aresta.png`). AX5 com o
cartão: `v12b-ax5-pe.png` e `v12b-ax5-menu.png`, quatro ações desenhadas, sem
rolagem.

**A voz do cartão (06/09, auditoria da trilha Métodos).** A dica das duas saídas
prometia "ele aprende com você" — alegação de eficácia sem dono. `Degraus.ajuste`
é um contador com memória de dois: as duas últimas respostas DESTA forma, e só se
concordarem, movem o degrau ±1 entre 0 e 4. A dica passa a dizer o mecanismo —
"duas respostas iguais seguidas mudam o que ele cobra nesta forma" —, que também
é a razão de apertar o botão. É `accessibilityHint`: o iOS não o desenha, então
não há o que cortar em tamanho nenhum.
Capturas antes (main 0d0d007) e depois em `large` e AX5 nos seis estados do G2
(`ferramentas/orca/v12-*.png`), diff fora da barra de status: arquivo pela
borda **0 px** nos dois tamanhos, página vazia **0 px** com a aba presente nos
dois, escrevendo 484 px = 0,016 % (caret). Intencionais: forma vestida 15,8 %
(`large`) e 27,8 % (AX5) — o cartão sai do pé e as ações reaparecem; campos
3,6 % e 9,8 % (cabeçalho da folha); escrevendo AX5 7,6 % (o pé em AX). O
cartão da sábia não compara por pixel: a resposta muda a cada abertura. Vídeos de vestir/soltar e da borda com e sem Reduzir Movimento. O commit da V12
era líquido-negativo (−55 linhas de Swift do app); com a correção do G3 (+124
−16, das quais 63 somadas são comentário) a volta INTEIRA vira **+53 líquidas** —
a regra da 05v não se cumpre aqui, e o custo está declarado, não escondido: os
dois testes que faltavam exigiram tirar uma decisão de dentro de um gesto e outra
de dentro de um `body`.
Estes números de pixel são do build da V12 (`5937943`): o V12-B mexe neles de
propósito — o pé em AX ganhou a linha de "Trabalhar nisto" e todo branco sobre o
papel ganhou 0,5 de aresta. O que o V12-B mede está no parágrafo acima.
## ADR 2026-09-06a — O conflito na tela: as duas versões, o retry e o selo que recolhe

**O que estava provado.** A ADR 05l provou o retorno FELIZ: o `.md` sai com
envelope, volta, e o corpo editado fora vira versão nova com autoria externa.
Nada além disso tinha tela. Quando as duas pontas mudam, quando o commit é
recusado, e quando a origem é selada com o seletor aberto, o autor via — ou uma
prévia de um lado só, ou uma frase que mandava importar de novo, ou nada.

**A decisão.** Quatro coisas, nenhuma delas nova no modelo: a lei do arquivo já
acrescentava e nunca sobrescrevia. O que faltava era a tela dizer a verdade.

1. **Conflito com as duas versões — e só quando existem duas.** Conflito é
   `.baseAntiga` **mais** duas condições que a primeira volta não pedia: a
   versão local ANDOU desde a base do arquivo (`baseID != versaoVigenteID`) e o
   que voltou ainda não está guardado. Sem elas a tela mentia numa rota de três
   toques — exportar, "Guardar intenção", importar o mesmo arquivo —, porque
   rever a intenção já muda o estado para `.baseAntiga` sem mover versão
   nenhuma: os dois cartões traziam o MESMO número e o MESMO texto, e qualquer
   escolha caía em `.semNovidade`. Havendo conflito, os dois lados vêm com
   título e a consequência escrita antes da escolha ("Nenhuma escolha apaga
   nada: a versão N continua no histórico e o arquivo, se você o guardar, entra
   como versão nova"), em `cartao(.campo)`, e as duas saídas são nomeadas —
   **Guardar o arquivo como nova versão** (âmbar) e **Manter só a versão
   atual** (`.compacto`, sem cor própria: duas saídas âmbar empatariam em peso).
2. **A pergunta que a mutação faria, a tela faz antes.**
   `IntercambioTrabalho.jaGuardado` é a regra única de "este conteúdo já está
   aqui": `aplicarVersaoExterna` a usa para não fabricar versão, e a tela a usa
   para não OFERECER decisão. Quando ela responde sim — o mesmo arquivo de
   volta, ou um export intocado depois que a versão andou — a linha é "Este
   arquivo traz o mesmo conteúdo que já está guardado aqui. Não há nada para
   decidir: nenhuma versão será criada.", sem botão de guardar. Uma decisão sem
   efeito é estado desonesto, mesmo quando o texto do botão não mente.
3. **As duas recusas de `guardar()` são duas.** `RecusaDoCommit` (`.disco`,
   `.baseDivergente`) sai da Oficina e entra em
   `Desfecho.de(mudou:guardou:acesso:recusa:)`. `.aguardandoCommit` (o disco
   recusou; a versão está na memória) é o único caso que oferece **Tentar
   guardar de novo**, e esse botão chama `guardar()`, não outra importação:
   confirma a MESMA versão. `.precisaReabrir` (o trabalho mudou em outra
   abertura) NÃO oferece botão nenhum, porque repetir bate na mesma guarda:
   `basePersistida` só muda num commit bem-sucedido. A tela diz o que houve e o
   que fazer — voltar, reabrir o trabalho, e o arquivo continua no aparelho.
4. **O selo recolhe.** A tela declara em `oficina.intercambioAberto` o que tem
   em mãos (`.seletor`, `.exportacao`, `.revisao` — inclusive durante a
   leitura); `verificarAcesso()` — o ponto por onde toda rota do Trabalho
   revalida — move isso para `intercambioRecolhido` no instante da restrição, e
   a tela protegida diz o que recolheu ("A origem foi protegida: recolhi o
   arquivo que estava em revisão. Nada foi importado."). Liberada a origem, a
   linha cala.

**A passada de design (`design-router`, seis fases).** *Ancorar*: autor no meio
de um trabalho, decidindo sob pressão o que fazer com um arquivo que voltou;
resultado observável é uma versão a mais no histórico ou nenhuma, nunca uma a
menos. *Sistema*: nada novo — `cartao(.campo)` (o único degrau que separa do
`Tema.superficie` do bloco), `rotulo()`, `Tema.meta/corpo`, `.compacto` de
`Botao.swift`. *Construir*: a regra fora da View (`conflito`, `jaGuardado`,
`Desfecho`), a View só desenha. *Mover*: nenhuma animação nova; nada a
interromper. *Julgar*, lendo a própria tela: as duas saídas estavam ambas em
âmbar, empatadas — `Botao.swift` já dizia que a secundária não é âmbar, e a
tela desobedecia; e as doze linhas fixas do começo de cada lado eram magia que
não sobrevivia ao corpo de acessibilidade. *Portão*: os dois consertados aqui.

**A passada de jornada (`curva-zero`).** *Jornada*: "editei fora e voltei" —
exportar, editar noutra ferramenta, importar, decidir. *Resultado verificável*:
o histórico cresce em um e nenhuma versão anterior some (a captura mostra o
contador). *Atrito observado*: a tela chamava para uma decisão inventada em três
toques sem editor nenhum, e oferecia uma nova tentativa que não podia dar certo
— os dois foram medidos lendo o código contra a tela, não supostos.
*Recuperação*: recusa de disco → o mesmo botão confirma a mesma versão; base
divergente → reabrir, com o arquivo preservado; conteúdo repetido → fechar a
revisão, nada criado; origem selada → o material recolhido, dito por nome.

**Custo assumido.** A linha do recolhimento só aparece se o selo cair enquanto a
MESMA `Oficina` está viva, e nenhuma rota do app sela a origem com a folha do
Trabalho aberta: fica provada por teste, não por captura. `.precisaReabrir`
também: exige duas `Oficina`s do mesmo `Trabalho` vivas ao mesmo tempo — o teste
as cria e prova que a guarda dispara e que repetir não resolve; a tela não tem
rota para duas folhas. O `ProgressView("Lendo arquivo…")` existe e está no
caminho, mas com um `.md` de 400 bytes a leitura não dura um quadro: não há
captura dele. Em corpo de acessibilidade (AX5) o começo de cada lado cai de doze
para quatro linhas; ainda assim os dois cartões não cabem inteiros no mesmo
olhar — cabe o primeiro completo e o começo do segundo.

### Volta 11-C — a comparação mostra ONDE as duas versões diferem

O G4 derrubou a premissa das duas voltas anteriores, e tinha razão. Em AX5 os
dois cartões exibiam a MESMA cadeia de caracteres, e não por falta de espaço:
**a truncagem mostra o COMEÇO e a edição de ida-e-volta acontece no FIM**. Não é
defeito de AX5 — reaparece nas doze linhas do corpo normal assim que o documento
passa de doze linhas, e o protocolo aceita 2 MiB. A tela que existe para comparar
devolvia dois blocos idênticos no caso comum. Quatro correções:

1. **O recorte ancora na primeira divergência.**
   `IntercambioTrabalho.recorteDaDiferenca(atual:arquivo:contexto:)` mede o
   prefixo comum; quando ele passa do contexto que cabe na janela, os dois
   cartões deixam de mostrar o começo e passam a mostrar o mesmo ponto — um fio
   de contexto antes da divergência, recuado até a fronteira legível (linha
   inteira quando há uma perto, senão palavra, com `…`). A tela diz onde
   começou: "As duas começam iguais até a linha N. Mostro daí em diante, onde
   elas mudam." (ou, em parágrafo único, "nos primeiros N caracteres"). O
   contexto é parâmetro porque a janela muda: 48 no corpo normal, 12 em corpo de
   acessibilidade — com 48 as quatro linhas do AX5 são preenchidas pelo contexto
   sozinho, que é exatamente o defeito. Cálculo de string ao lado de
   `conflito(_:em:)`, testável sem renderizar SwiftUI.
   A ressalva de truncagem saiu de dentro da garantia de não-perda: eram duas
   informações de naturezas diferentes numa frase cinza só, e agora são duas
   linhas, a consequência em tinta cheia.
2. **Sair da revisão é desfecho.** `Desfecho.mantida` — "Nada foi importado. O
   arquivo continua no seu aparelho e pode ser importado depois." — atende as
   DUAS saídas que fechavam a revisão em silêncio ("Manter só a versão atual" e
   "Fechar revisão"). Escolha sem retorno visível deixa o autor sem saber se o
   app entendeu.
3. **A chegada e o desfecho são vistos e falados.** O cartão de revisão nascia
   abaixo da dobra: um `ScrollViewReader` dentro do painel (o proxy é da rolagem
   da folha, que já envolve esta tela) traz a âncora `trabalho-intercambio-revisao`
   ao topo quando a prévia chega, e o VoiceOver ouve "Arquivo recebido. A revisão
   está abaixo.". A entrada e o recolhimento do cartão passam por
   `Tema.movimento(.deslocamento, Tema.Mola.camada, reduzido:)` com transição de
   deslocamento + opacidade, e a linha de desfecho por
   `Tema.movimento(.opacidade, …)`. A linha de desfecho deixou de ser a terceira
   frase cinza igual às instruções fixas: ganhou `cartao(.campo)` e `Tema.tinta`,
   e TODO desfecho é anunciado por `AccessibilityNotification.Announcement`.
4. **Nenhuma ação desta tela some (o movimento da volta 18).** `AcaoTrabalhoStyle`
   nunca leu `@Environment(\.isEnabled)`, e por isso o "Importar" desabilitado
   era pixel-idêntico ao habilitado. O estilo deixa de existir na volta 18, que
   resolveu a doença na raiz: no lugar do `.disabled()`, a ação continua cápsula
   (`Pilula`, `.filtro` nas secundárias e `.larga` cheia na principal), o motivo
   fica escrito ao lado E no `accessibilityHint`, e tocar diz o que falta em vez
   de não fazer nada. As três ações do intercâmbio seguem o mesmo padrão, para as
   duas voltas chegarem em main falando a mesma língua. Efeito colateral bem-vindo:
   a principal em cápsula cheia (carvão sobre papel) desfaz a inversão de peso
   que o G4 mediu entre ela e o `.compacto`, sem tocar no `.compacto`.

**A passada de design da 11-C (`design-router`, seis fases).** *Ancorar*: o autor
volta do editor externo e precisa DECIDIR; se a tela não mostra a diferença, o
intercâmbio vira gerador de versões que ninguém escolheu. *Sistema*: nada novo —
`Pilula`, `cartao(.campo)`, `rotulo()`, `Tema.movimento`/`Mola.camada`,
`Tema.tinta`. *Construir*: o recorte é string pura no modelo, com teste; a View
só desenha e pergunta. *Mover*: as duas coisas que a tela tinha a dizer e não
dizia — a decisão chegando e o efeito acontecendo — entram pela lei de
`Tema.swift`, medidas no vídeo cru (recolhimento em nove quadros consecutivos com
subida e cauda, contra o quadro único que o G4 mediu; sob Reduzir Movimento, a
fade curta). *Julgar*, lendo a própria tela no aparelho: em AX5 o contexto de 48
preenchia sozinho as quatro linhas e os dois cartões voltavam a ser idênticos —
achado da captura, não do código, e é por isso que o contexto virou parâmetro.
*Portão*: os quatro itens do mínimo provados por captura no iPhone 17e.

**Custo assumido da 11-C.** O obstáculo das ações bloqueadas mora na folha do
Trabalho, acima desta tela (território da volta 18): aqui tocar NOMEIA o que
falta e anuncia, não rola até ele. O `recado` continua não sendo zerado por atos
não relacionados (dívida do RUMO). A inversão de contraste do `.compacto` como
regra da casa segue para o RUMO: esta volta não mexeu nele.

**Prova da 11-C:** suíte **722/0 em 125 suítes** em 06/09/2026; 2 testes novos
(`aComparacaoMostraOndeAsDuasVersoesDiferem` com documento de 41 linhas e a
diferença na última, mais o recorte de janela pequena e o de parágrafo único;
`manterAVersaoAtualDizOQueAconteceuComOArquivo`). Jornada real de ponta a ponta
no iPhone 17e `C7341E64…`, dirigida à mão e conferida por
`xcrun simctl io <UDID> screenshot` (maestro NÃO isola com vários simuladores
ligados — `--device` diz um aparelho e o driver XCTest atende outro, provado por
dimensão de pixel): versão 1 escrita, exportada, o `.md` reescrito FORA do app
com dez linhas, importado, editado no fim dos dois lados, conflito.
Capturas `ferramentas/orca/g4c-v11-*.png` — a chegada já na tela, os dois cartões
começando no ponto de divergência, as duas saídas com pesos distintos, o "Manter"
falando, o AX5 com os dois cartões DIFERENTES, o importar bloqueado ainda cápsula
com o motivo ao lado — e vídeos `g4c-v11-normal.mp4` / `g4c-v11-reduzido.mp4`.

### Volta 11-D — tocar uma ação bloqueada responde na tela

O Re-G4 fechou três dos quatro itens e deixou meia regra da volta 18 de fora. A
lei dela tem duas metades — o motivo escrito ao lado E **tocar leva ao que
falta** — e a própria V18 declara o limite: `Announcement` é canal do VoiceOver,
e "para quem usa Controle Assistivo **sem** VoiceOver o que resta é o desvio
visível". A 11-C adotou a cápsula e o anúncio e parou aí: o juiz mediu **0,032 %**
de pixels alterados ao tocar "Importar versão de arquivo" bloqueado — o dígito do
relógio virando. E era regressão, não lacuna herdada: antes desta trilha o
controle tinha `.disabled()` e o varredor o PULAVA; sem o `.disabled()` ele agora
pousa num controle que aceita ativação e não fazia nada observável.

**A correção, uma linha.** Em `IntercambioTrabalhoView.acao(...)` o impedimento
deixa de sair só por `AccessibilityNotification.Announcement` e passa por
`anunciar(_:)` — que já existia nesta tela, já põe a linha em `cartao(.campo)`
com `Tema.tinta` sob `Tema.movimento(.opacidade, …, reduzido:)` e já fala. As
duas pessoas recebem a mesma resposta: quem ouve, pelo anúncio; quem varre a
tela sem VoiceOver, pelo cartão que aparece. As três ações do painel passam pelo
mesmo `acao(...)`, então a regra vale para todas de uma vez.

O cartão repete a frase que já está cinza ao lado da cápsula, e isso é
deliberado: a linha cinza é a **condição** (vale enquanto o impedimento existir),
o cartão é o **evento** (você acabou de tentar), e ele diz QUAL das ações
bloqueadas foi tocada — tocar "Exportar" troca a linha pela do export
(`g4-v11d-bloqueado-outra-acao.png`). Duas naturezas, dois pesos, e a segunda
chega por movimento.

**Nada em `TrabalhoView`.** O desvio ao obstáculo (foco e rolagem) mora na folha
do Trabalho, que é território da volta 18. Quando as duas mesclarem, estas ações
passam a rotear pelo desvio dela e esta linha compõe com ele; a ausência dela é
que atrapalharia.

**Prova da 11-D:** suíte **722/0 em 125 suítes** em 06/09/2026 (`TEST SUCCEEDED`,
iPhone 17e `C7341E64…`); nenhum teste novo — a mudança é o corpo de um closure de
`Pilula`, que Swift Testing não alcança sem renderizar SwiftUI, e a prova é a
tela. Jornada à mão no iPhone 17e, conferida por `xcrun simctl io <UDID>
screenshot`: intenção guardada → versão em edição (rascunho pendente) →
"Importar versão de arquivo" bloqueado → toque. **27,52 % dos pixels da tela
mudam** (28,89 % ignorando a barra de status), contra os 0,032 % medidos pelo
juiz no build anterior. No vídeo cru a 30 fps a resposta é uma corrida de **8
quadros com subida e cauda** — `6,54 8,78 9,05 8,52 8,35 7,16 5,64 3,07` — e zero
nos vizinhos. Capturas `ferramentas/orca/g4-v11d-bloqueado-antes.png`,
`-resposta.png`, `-outra-acao.png`; vídeo `g4-v11d-toque-bloqueado.mp4`.

**Custo assumido da 11-D.** O caminho de movimento é o de `anunciar`, que o
Re-G4 já mediu nos dois modos (a lei de `Tema` mantém opacidade sob Reduzir
Movimento); não o remedi. Quando a linha nasce de uma ação bloqueada DENTRO do
cartão de revisão, o cartão de desfecho aparece no alto do painel, acima da
revisão — é o lugar único do `recado`, e esse estado só existe se o trabalho
deixar de estar salvo depois que a prévia chegou. E as dívidas do RUMO seguem
abertas de propósito: `recorteDaDiferenca` é O(n) e roda duas vezes por `body`
(28,9 ms a 100 KB, 608 ms no teto de 2 MiB), o `min(16, contexto)` é a segunda
constante fora da conta do 48/12, e o `recado` não é zerado por atos não
relacionados.

**Volta:** multiplicar — a continuidade entre ferramentas é a tese.
**A IA:** nada. **Prova:** 5 testes em `IntercambioTrabalhoTests` (as duas
versões e a escolha que não sobrescreve; recusa de disco → retry que confirma a
mesma versão e uma segunda passada que não duplica; selo com `.seletor`,
`.exportacao` e `.revisao`; o arquivo sem novidade que não vira conflito nem
decisão, nas três formas — intenção revista, export intocado, e o conflito de
verdade que continua de pé; a recusa por base divergente que não oferece nova
tentativa), suíte **720/0 em 125 suítes** em 06/09/2026, build limpo sem UM
aviso (conferido em recompilação integral dos dois alvos).
`maestro/intercambio-conflito.sh` roda a jornada inteira SOZINHO — parte 1 no
app, a edição do `.md` no disco do simulador feita pelo próprio roteiro, parte 2
em `maestro/partes/` — e passou 2 de 2 seguidas no iPhone 17e; capturas
`ferramentas/orca/v11b-*.png` (conflito com as duas versões, as duas escolhas
com pesos distintos, o mesmo em AX5, o arquivo sem novidade sem botão de
decisão, o importar bloqueado por edição pendente).

## ADR 2026-09-06b — O Trabalho entra na família (voltas 18 e 18-B)

**A distância.** O Trabalho tirou 6,0 na auditoria V9 (`auditoria-frontend.md`
§6), a pior nota do app: Design 5, Simplicidade 5, Componentes 4. Ao lado da
ficha do calendário ele parecia outro aplicativo — formulário cru do sistema,
chips e chevrons do UIKit, sem papel, sem cartão, sem rótulo de seção; e a
MESMA ação, "Preparar com IA", vestia duas roupas: cápsula cinza antes da
primeira versão, cápsula marrom escura depois (`v9-trabalho-versao-1.png`),
nenhuma das duas do sistema (`law-of-similarity`). Cinco telas de rolagem,
oito `DisclosureGroup`, e o botão principal desabilitado sem parecer
(`critique-affordance`). Pela curva-zero, intenção → versão preparada custava
6 toques e 2 digitações, e a decisão que muda tudo — delegar, praticar ou
combinar — morava dentro de um disclosure e nunca era oferecida no caminho.

**A decisão.** Três mudanças, nesta ordem.

*Ordem de leitura.* O documento passou a ler o ciclo (VISAO-PRODUTO): intenção
→ apoio → preparar → versão → intercâmbio → próximo ato → o que aconteceu →
dificuldade → histórico → estado. "Dificuldade" estava ANTES do caminho
principal e empurrava a ação primária para fora da primeira tela; é o trabalho
que revela o obstáculo, não o contrário. "Praticar" desceu para depois de
"Preparar": era o exercício aparecendo acima do campo que o pediu.

*A decisão no caminho.* O `Picker` "Neste trabalho, prefiro" saiu do disclosure
e virou um trilho de três pílulas, com `delegar` já marcado — a decisão fica
visível e reversível sem custar um toque a quem só quer começar. Em tamanho de
acessibilidade o trilho empilha: três cápsulas lado a lado estouravam a largura
da folha e sangravam o documento pelos dois lados (defeito que a V9 já tinha e
a captura AX5 desta volta reproduz).

*A família.* `CabecalhoDeFolha` no lugar do `NavigationStack` com barra do
sistema (nas duas telas); rótulo de seção em caixa alta como na ficha;
`campo` em `Cartao.campo` (névoa); versão, ato, tentativa e relato em
`Cartao.papel`; "Quando" do agendamento em cartão de névoa com hairlines e
`LinhaQueAbre`, igual ao calendário; `AcaoTrabalhoStyle` apagado. A lei de cor:
**carvão avança, âmbar salva** — a cápsula carvão (`Pilula.larga` selecionada)
é a ação que produz algo na seção; o âmbar aparece só como saída de um problema
(Ajustes, recuperar, retomar); todo o resto é `Pilula.filtro`, porque texto
solto sobre papel não se lê como controle e não tem estado desabilitado.

*Desabilitado honesto (refeito na 18-B).* A volta 18 aplicou a regra a DOIS
botões de sete e manteve `.disabled()` no resto — e a revisão mostrou o preço:
`Pilula` desabilitada devolve fundo `.clear` com `tintaMorta`, **1,53:1 sobre o
papel**, sem cápsula e sem forma de botão; a ação PRIMÁRIA da tela virava
legenda cinza num estado alcançável em quatro toques
(`v18-rev-gerar-travado-sem-capsula.png`). Meia regra é pior que nenhuma.

A 18-B fecha a regra numa lei só, e ela vale para os sete: **nenhuma ação desta
folha some**. Não há mais um `.disabled()` em `TrabalhoView` nem em
`AgendamentoAcaoView`. A ação bloqueada continua a mesma cápsula, com o mesmo
alvo de 44 e o mesmo contraste; o motivo continua escrito na linha de baixo (e
agora também no `accessibilityHint`, para quem ouve a tela); e **tocar leva ao
que falta**: campo vazio recebe o foco (`faltaCampo`), edição não guardada
recebe o foco (`campoEmEdicao`), salvamento falho leva à saída no alto da folha
(`levouAoObstaculo`, dentro de `aplicar`, por onde todas as escritas passam),
preparação em curso leva ao próprio progresso (`preparacaoEmCurso`). Prova:
`v18b-gerar-vazio-continua-capsula.png` e `v18b-gerar-edicao-pendente.png` — o
mesmo estado que a revisão fotografou, agora cápsula carvão inteira com o motivo
ao lado — e `maestro/trabalho-bloqueio.yaml`.

**O que se perde, dito:** o VoiceOver não anuncia mais "indisponível" nessas
ações; anuncia o motivo pelo `accessibilityHint`, e o toque leva ao obstáculo em
vez de não fazer nada. `Traco/Componentes` não foi tocado — a cápsula do
desabilitado continua dívida da volta dos Componentes, e ainda vale para
`IntercambioTrabalhoView`, que ficou fora do escopo e desabilita três ações.

*O trilho fala com quem ouve (18-B).* As três pílulas do apoio saíam iguais no
`maestro hierarchy` (`selected: false` nas três): a decisão que muda o que
"Preparar" faz era comunicada só por cor, e isso era regressão contra o `Picker`
da V9, que anunciava o valor de graça. `.accessibilityAddTraits(.isSelected)` na
pílula marcada, guardado por `maestro/trabalho-bloqueio.yaml`, que assere
`selected: true` na escolhida e `false` nas outras duas.

*A promessa do aviso (defeito 6, o mesmo 2 da ficha).* `AgendamentoAcaoView`
prometia "Toca hoje às 20:22 · na hora" com os avisos do Traço desligados
porque o `Bool permissaoNegada` juntava dois estados diferentes — *negado* e
*ainda não perguntado* — e só o primeiro calava a promessa. A frase agora sai
de `PromessaDoAviso.para(minutos:estado:hora:)`, pura e testada, sobre os três
estados de `Avisos.Estado` mais o "ainda lendo": concedido diz "Toca …";
não perguntado e leitura pendente dizem "Toca …, se você permitir os avisos
quando o iPhone perguntar"; negado não promete, avisa e leva aos Ajustes. A
view lê a permissão sozinha (`.task` e volta à cena), o que fecha também a
janela em que a frase prometia antes de a leitura voltar. Depois do commit, a
linha continua vindo do motor (`ResultadoDoAviso`), nunca do que se pediu.

*A outra metade, e ela é do relógio (18-B).* A revisão pegou a folha prometendo
"Toca hoje às **14:37** · 30 min antes" às **15:08** — hora já passada — na
captura dela e na do próprio implementador (`v18-agendar.png`). Quem sabia a
verdade era só o motor, e só DEPOIS do commit (`ResultadoDoAviso.passou`).
`PromessaDoAviso` ganhou o quinto caso, `jaPassou`, e `para(...)` ganhou
`instante:` (quando o alarme tocaria, de `Aviso.instante`) e `agora:`. O caso não
carrega valor associado porque a frase não usa a hora; quem decide é o `agora:`.
A ordem é a do motor (`Avisos.agendar`): sem permissão primeiro — beco com saída
nos Ajustes —, depois o relógio, que cala qualquer promessa, só então a promessa.
E a folha parou de propor um horário que já nasce atrás do relógio: um ato sem
horário abre em meia hora à frente, arredondada nos 5 minutos, em vez de `.now`
cru, cujo alarme "na hora" o motor recusaria. Prova:
`v18b-promessa-hora-passada.png` (relógio 17:13, ato 17:45, "2 h antes", a linha
em âmbar), `v18b-promessa-toca.png` e os testes em `PromessaDoAvisoTests`. O tipo
serve à volta que liga a ficha do Calendário, onde este é o defeito 2 da revisão
da V9 — **mas não estava completo para ela até a 18-C**, que fecha o compromisso
que se repete; a primeira redação dizia "completo" e a re-G3 mostrou que não era.

**Custo assumido.** A volta NÃO é líquido-negativa: +742/−396 nos três arquivos
de view (código sem comentário, 1119 → 1296 linhas), somando 18 e 18-B. Só a
volta 18 foi +599/−371 e 1119 → 1247 — o "+592/−364" da primeira redação era
contagem errada, apontada pela revisão. Foram apagados
`AcaoTrabalhoStyle`, dois `NavigationStack` com toolbar, três
`DisclosureGroup` (oito → cinco, e nenhum aninhado), o `Picker` de apoio e um
`@State`; foram acrescentados o trilho de apoio, o tri-estado da promessa, as
linhas de motivo do desabilitado, o ramo de acessibilidade do trilho e o
cabeçalho fixo — cada um fechando um defeito nomeado da §6. Encolher além disso
seria apagar correção. **Dívida para a volta dos Componentes:** `Pilula`
desabilitada perde a cápsula (fundo `.clear`), e em AX5 o texto de
`Pilula.larga` encosta na borda (sem recuo horizontal); faltam em
`Traco/Componentes` uma `Secao` (rótulo + conteúdo, hoje copiada da ficha) e a
linha que abre um BLOCO — os cinco `DisclosureGroup` restantes ainda são do
sistema, com `tint` do tema por fora. `OficinaTrabalho.permissaoNegada` ficou
sem leitor externo. **Volta:** multiplicar. **A IA:** nada mudou no que ela
produz, lê ou pode enviar.

**Prova.** Suíte 728/126 verde e build sem aviso no iPhone 17 Pro (teste 2);
13 testes em `PromessaDoAvisoTests`. Três fluxos maestro no aparelho:
`trabalho-curva-zero.yaml` (a medição da jornada), `trabalho-bloqueio.yaml` (a
lei do bloqueio e o `selected` do trilho) e `trabalho-acao-aviso.yaml` — este
falhava 2/2 no branch porque os quatro `swipe` de posição fixa passavam do alvo
com a ordem nova das seções; viraram `scrollUntilVisible`. Capturas `simctl` antes e depois em
large e AX5 (`ferramentas/orca/v18-*.png`), vídeo do movimento com e sem
Reduzir Movimento (`v18-movimento-normal.mp4`, `v18-movimento-reduzido.mp4`).
Curva-zero, medida comando a comando no aparelho (`maestro/trabalho-curva-zero.yaml`,
que é a medição e falha se alguém acrescentar um toque): intenção → versão
preparada **cai de 6 toques e 2 digitações para 5 e 2**. O toque que saiu é o
do campo do pedido, que só existia para revelar o passo seguinte — a folha
recém-criada abre com o cursor lá. A volta 18 sozinha NÃO tinha derrubado o
número: a revisão remediu e achou 6, porque o toque que a volta dizia ter
economizado ("abrir o disclosure para chegar ao apoio") nunca esteve na conta
da auditoria, que já media o caminho de quem não decide o apoio. O que a volta
18 melhorou sem mexer na contagem, e é real: a decisão de apoio passou de
escondida a visível a 0 toques, o caminho principal cabe numa tela só (com o
teclado aberto, `v18b-curva-zero-abre-no-pedido.png`) e a ação primária saiu de
trás de "Dificuldade".
**Não provado:** o estado *negado* da promessa (a permissão do simulador de
teste estava `naoPerguntado` e, depois de concedida, o iOS não deixa voltar
atrás sem Ajustes — o caso vive no teste, não na captura); a chegada da versão
da IA em vídeo (o modelo do aparelho leva ~90 s, acima do teto de 20 s, então o
vídeo usa a versão escrita pela pessoa, que dispara a MESMA animação); e o
alerta de permissão do iOS, que ao aparecer uma única vez recolhe a gaveta do
horário e rola a folha ao topo — reproduzido, e não acontece em nenhum
salvamento seguinte (`v18-reguardado.png`).

### Volta 18-C — uma linha, e duas guardas

**A recusa.** O re-G3 fechou cinco dos seis achados na tela e subiu Design,
Simplicidade e Componentes para 9 (a jornada caiu mesmo: 5 toques e 2
digitações, remedidos à mão pelo revisor). Segurou por **uma linha**: a folha
enunciava uma regra que não cumpria.

*A regra que não se cumpria (achado A).* A lei do bloqueio acima descreve
"edição não guardada recebe o foco (`campoEmEdicao`)". Em `trabalho-gerar` isso
**não acontecia**: ao remover o `.disabled(travado)`, a 18-B portou só a metade
`!o.salvo` do guarda, e `edicaoPendente` continuou entrando apenas no cálculo da
**mensagem**. Com a intenção editada e não guardada, a folha escrevia "Guarde a
intenção ou a versão que está editando antes de pedir uma nova preparação" e
**disparava a IA assim mesmo** — ~90 s de preparação gastos no caso exato que a
regra existia para evitar, e uma versão que a própria folha depois marcava em
vermelho como preparada para uma intenção anterior. É a doença da volta pelo
lado avesso: antes o botão bloqueava sem dizer; agora dizia e não bloqueava.

A causa não é a linha que faltava, é que **havia duas listas de guardas
copiadas** — `trabalho-gerar` e `trabalho-revisar` — e elas divergiram. A 18-C
não copia a linha de volta: funde as duas em `levouAoQueFalta(_:campoObrigatorio:)`,
o guarda único das duas rotas que chamam a IA. Não há mais onde divergir. E a
ordem do guarda passou a ser a ordem em que `motivoDoTravamento` fala —
salvamento, preparação em curso, edição pendente, campo vazio —, porque com
`!salvo` **e** edição pendente juntos a folha nomeava um obstáculo e levava a
outro. Prova na tela (`v18c-regra-cumprida.png`, cinco estados): a regra
escrita; o toque que não prepara nada; o texto seguinte entrando no campo em
edição **sem nenhum toque nele**, que é a prova do foco; o guardar; e o MESMO
toque preparando de verdade em seguida. Guarda contra a volta do defeito:
`maestro/trabalho-bloqueio.yaml` ganhou o caso, com `assertNotVisible` em
`trabalho-preparando`.

*A perda estreita do VoiceOver, fechada.* Trocar `.disabled()` por "tocar leva
ao que falta" é ganho líquido — 1,53:1 virou 13,94:1, o motivo continua a um
deslize e o toque virou rota em vez de nada. A perda nomeada pelo revisor:
`.disabled(true)` marca `isEnabled = false`, e **Controle Assistivo e Acesso
Total por Teclado pulam controles desabilitados**; sem ele, quem varre pousa num
controle que aceita ativação e não conclui. A 18-C posta
`AccessibilityNotification.Announcement` com o motivo nos ramos que antes só
rolavam a tela — salvamento falho (`o.erro`) e preparação em curso — e no ramo
da edição pendente, onde o campo que recebe o cursor fica em OUTRA seção da
folha e ouvir só "O que quero realizar" não explica por que a preparação não
começou. **Não** foi posto em `faltaCampo`: ali o campo focado É o obstáculo
nomeado, o foco já é falado (provado em `v18-reg3-toque-leva-ao-campo.png`), e
uma segunda fala correria com a do foco. **Limite honesto:** `Announcement` é
canal do VoiceOver; quem usa Controle Assistivo **sem** VoiceOver continua sem a
fala, e para essa pessoa o que resta é o desvio visível — o foco e a rolagem até
o obstáculo. A perda não foi eliminada, foi reduzida ao caso sem VoiceOver.

*`PromessaDoAviso` pronto para a ficha do Calendário.* O revisor achou o que
faltava, e é pré-requisito da volta seguinte, não defeito desta: `Aviso.instante`
calcula a partir do **início da série**. Para "Correr toda terça 6:30" esse
início está no passado, então `instante <= agora` e o tipo devolveria `jaPassou`
("esta ação ficou sem alarme") enquanto `Revisoes.agendarCompromisso` arma um id
por dia da semana e o alarme toca toda semana — a mesma mentira ao contrário,
justamente sobre o compromisso que mais toca. Duas guardas:

1. `jaPassou` só quando **não** repete: `para(...)` recebe `repete:` e o caso
   passa a ser `if let instante, !repete, instante <= agora`.
2. `instante:` e `repete:` **sem valor padrão**. Era `instante: Date? = nil`, e
   um chamador que esquecesse o parâmetro perdia a correção do relógio inteira,
   em silêncio; `false` é o lado que mente em `repete`. Agora não se ligam as
   duas pontas sem passar os dois.

No Trabalho nada muda na tela — o ato monta `EventoCalendario` sem `repeteEm`,
então `repete` é sempre `false` —, e é isso que a prova mostra:
`v18c-promessa-repete.png`, os dois lados do corte com a assinatura nova
("Toca hoje às 18:45 · na hora" e, com "2 h antes" de 18:45 às 18:11, a linha
em âmbar "A hora do aviso já passou"). Os 10 testes viraram 13: série que
repete não fica sem alarme (e o mesmo instante, sem série, continua `jaPassou`),
série não atropela o beco de quem desligou os avisos, série sem aviso pedido
continua sem aviso. **Fica para a volta da ficha:** mover o tipo de
`AgendamentoAcaoView.swift` para junto de `Avisos`/`Aviso` — ele não tem nada de
view, e a ficha não deveria importar a folha do Trabalho.

**Custo.** +73/−11 nos dois arquivos de view (1296 → 1313 linhas sem
comentário), +58/−13 em `PromessaDoAvisoTests` e 48 linhas de fluxo. Cada
entrada fecha um achado nomeado; a única linha nova sem defeito de origem é a
fusão dos dois guardas, e ela apaga a classe do achado A.

**Prova.** `xcodebuild` sem aviso (`grep -c warning:` = 0) e **728 testes em 126
suítes verdes** no iPhone 17 Pro (teste 2) `B91C8DEF`, sob `com-trava.sh`.
Estados na tela por `xcrun simctl io <UDID> screenshot`, toque a toque com a
janela do meu simulador trazida à frente — não por maestro, cuja leitura hoje
volta do vizinho: `v18c-regra-cumprida.png` e `v18c-promessa-repete.png`.
**Não provado:** o fluxo `maestro/trabalho-bloqueio.yaml` com o caso novo, que
ficou **pendente de instrumento** (a estrutura confere com a medição à mão, mas
rodá-lo hoje fotografaria outro aparelho); e o anúncio de acessibilidade sendo
de fato FALADO — `Announcement` não aparece em captura, e o simulador com
VoiceOver não estava disponível neste turno: o que está provado é o desvio
(nenhuma preparação, foco no campo em edição), não a fala.
**Fora do escopo, para o RUMO:** em AX5 um documento **com** versão da IA volta
a sangrar pelos dois lados (achado B do re-G3) — não é regressão desta volta, o
diff não toca `ConteudoTrabalhoView`, e o dono está por definir.


### Volta 18-D — o rascunho que ninguém escreveu

**A recusa.** O G4 passou **Movimento 9** e provou a família (`Pilula`,
`CabecalhoDeFolha`, `.cartao`, `.rotulo` compartilhados com a ficha do
Calendário; `AcaoTrabalhoStyle` apagado; oito `DisclosureGroup` em cinco; folha
vazia em duas telas; e sob Reduzir Movimento as mesmas três trocas do trilho em
16 quadros contra 253, **todos em estado resolvido**). Segurou por um estado
preso: **depois de o autor guardar a PRÓPRIA versão, a folha afirmava para
sempre uma edição pendente que não existia** — imprimia a versão duas vezes,
travava "Preparar nova versão com IA" e a importação, e sobrevivia a fechar,
reabrir, descartar rascunhos e reiniciar o aparelho. É o avesso exato da 18-C:
ela consertou "diz que bloqueia e não bloqueia", e sobrou "bloqueia para sempre
sem motivo".

*A causa, e ela tem duas metades.* A primeira o juiz nomeou: `campoEmEdicao`
julgava a intenção e o resultado por **diferença** e a versão por
**não-vazio**. A segunda eu medi no aparelho, e sem ela a primeira não bastava:
**o rascunho de "versao" não é escrito só por quem digita.** Um `TextField` que
sai da tela devolve o texto ao binding, e o `limpar` do salvamento já apagou o
rascunho — então o que voltava era o `padrao`. Depois de "Guardar minha
versão", o `plist` do app tinha literalmente `"versao" => ""` (lido em
`Library/Preferences/app.traco.plist` no simulador de teste), e `"pedido" =>
""` numa folha em que ninguém escreveu pedido. Julgado por não-vazio, o
rascunho igual à versão travava; julgado só por diferença, o rascunho vazio
travava. Nas duas leituras a folha nomeava um obstáculo que a pessoa não tinha
como resolver guardando.

*O conserto, na causa.* **Edição pendente é rascunho DIFERENTE do guardado, e
rascunho em branco não é edição em campo nenhum.** A regra vira três funções
`static` em `TrabalhoView` — `guardado(_:em:)` (o que o documento tem para um
campo que nasce preenchido; `nil` é campo livre), `alterado(_:_:em:)` e
`campoEmEdicao(_:em:)` — e passa a ser lida nos **três** lugares que antes
divergiam: o guarda do bloqueio, a condição que reabre o campo "Editar a
versão" dentro do cartão (era `!vazio("versao")`, e era a origem do parágrafo
impresso duas vezes) e o rodapé que oferece "Descartar rascunhos dos campos".
Nenhum campo destes pode ser guardado vazio (`reverIntencao` e
`guardarVersaoHumana` recusam), então em branco nunca é trabalho à espera de
commit. E o `set` de `campo(_:chave:padrao:)` deixa de gravar o que não mudou:
escrever nada não vira rascunho. As duas metades juntas fazem o aparelho **já
preso sair do estado sozinho, na primeira leitura** — provado abrindo o
trabalho que estava travado antes da correção.

Prova: `RascunhoTrabalhoTests` (7 casos), com
`guardarAPropriaVersaoNaoDeixaEdicaoPendenteAoReabrir` fechando o caminho
inteiro — guardar a própria versão, o rascunho fantasma indo e voltando pelo
`UserDefaults` com a chave do app (`TrabalhoView.chaveRascunho`, extraída para
isso), e a folha continuando destravada — e
`rascunhoVazioNaoEEdicaoPendente`, `versaoDiferenteDaGuardadaContinuaPendente`
e `aOrdemDoDesvioEADaLeitura` guardando os dois lados da regra.

**A linha do trilho passa a falar da opção selecionada.** Era
`Text("Delegar não exige aprender a executar tudo…")` fixo, e continuava
dizendo isso com Praticar e com Combinar marcados: a única frase que explica a
decisão que muda o resto da tela descrevia a escolha que o autor **não** fez,
encostada nela. Agora `explicacaoDoApoio(_:)` diz o que a marcada muda —
"Delegar: a IA prepara a versão inteira…", "Praticar: você escreve a
tentativa; a IA prepara o exercício e o retorno, nunca a resposta.",
"Combinar: você exercita o trecho que delimitar abaixo; o resto continua com a
IA." — e mantém "Você pode mudar quando quiser", a única parte da frase antiga
que valia para as três. Em Combinar a frase aponta para o campo que aparece
logo abaixo dela.

**O achado 3 não é desta volta.** O bloco "Editar com outras ferramentas"
continua `Button` cru com `.disabled()` neste branch, e o juiz mediu certo
(habilitado e desabilitado em `#1C1C1E`). O conserto já existe na volta 11, que
aplicou nesse arquivo exatamente o padrão desta folha; consertar aqui daria
dois consertos do mesmo bloco para reconciliar. Confirmação no G5, depois das
duas mescladas.

**Custo.** +95/−9 em `TrabalhoView.swift` (nenhuma linha de movimento: as cinco
chamadas pela lei continuam cinco, `grep "withAnimation\|.animation(\|.transition("`
em `Traco/Trabalho/` devolve 5), +113 em `RascunhoTrabalhoTests`.

**Prova.** `xcodebuild` sem aviso (`grep -c warning:` = 0) e **735 testes em
127 suítes verdes** no iPhone 17 Pro (teste 2) `B91C8DEF`, sob `com-trava.sh`.
Estados na tela por `xcrun simctl io <UDID> screenshot`, toque a toque com a
janela do meu simulador à frente — não por maestro, que hoje não isola (havia
driver de outro worker em `[::1]:7001`) e cuja captura fotografa build velho:

- `v18d-estado-preso-desfeito.png`, quatro estados do mesmo trabalho: (1)
  editando de verdade, a folha TRAVA e diz por quê — o positivo verdadeiro da
  18-C, intacto; (2) logo depois de "Guardar minha versão", DESTRAVADA, versão
  impressa **uma** vez e o campo fechado em "Editar esta versão"; (3) depois de
  fechar a folha, reabrir, **desligar e religar o aparelho** e reabrir, segue
  destravada; (4) editando a versão de novo, TRAVA de novo, e a importação
  volta a dizer "Guarde a intenção ou a versão em edição antes de importar".
- `v18d-trilho-fala-do-selecionado.png`: as três frases nas três seleções.
- `v18d-rodape-sem-rascunho-fantasma.png`: o rodapé de uma folha sem rascunho
  nenhum — só "Versões e atos guardados neste aparelho", sem oferecer descartar
  o que não existe. O `plist` do trabalho novo confirma: dicionário vazio,
  contra `"pedido" => ""` e `"versao" => ""` nos criados antes da correção.

**Não provado nesta volta:** nada que envolva conta Grok (não há conta neste
aparelho) — versão preparada pela IA, exercício, feedback e conferência
assistida seguem sem prova minha, como no G4; e o anúncio de acessibilidade
sendo FALADO, pelo mesmo motivo da 18-C.

**Fora do escopo, para o RUMO** (nomeado pelo juiz, e concordo): o `.disabled()`
de `Pilula` continua quebrado **no componente**; tocar uma pílula do trilho
cancela em silêncio uma preparação em curso (`trilhoDoApoio` chama
`cancelarPedido()` sem passar pelo guarda `preparacaoEmCurso`); o instante de
~0,2 s em que nenhuma pílula lê como selecionada na troca; duas ou três
cápsulas carvão de largura inteira por rolagem; o `confirmationDialog` que
chega sem o título; e `Pilula` morando em `Componentes/` mas dependendo de
`CalendarioTema`.

#### O que falta para o ciclo aparecer como ciclo

O juiz respondeu a pergunta central da volta: em **identidade** sim — a folha
abre com a frase do próprio autor como título em 28 pt e a ordem de leitura é a
do ciclo; em **estrutura** ainda não — "o ciclo nunca se mostra como ciclo, e a
forma repetida rótulo/pergunta/campo/botão ainda é a de um formulário bem
vestido". Não é conserto de portão, é redesenho, e fica para a próxima volta.
Minha leitura, para quem a pegar:

O problema não é decoração, é que **as quatro seções são independentes na
tela e dependentes na vida.** Intenção, preparar, ato e dificuldade têm todas o
mesmo peso, o mesmo papel e a mesma forma, e nada diz que a versão nasce do
pedido, que o ato nasce da versão e que a dificuldade volta para o pedido. O
autor lê quatro perguntas; ele vive uma volta.

Três mudanças que eu tentaria, em ordem de retorno:

1. **A folha muda de forma conforme o ciclo anda, em vez de mostrar tudo
   sempre.** Hoje uma folha em branco já exibe quatro perguntas com campo e
   botão, e quatro linhas de apoio. O estado do documento já sabe onde a pessoa
   está — sem versão, com versão sem ato, com ato sem relato, com relato — e
   esse é o dado que falta na tela. A seção da vez ganha o campo aberto e a
   cápsula carvão; as já passadas viram **uma linha de resultado** ("Versão 1,
   sua, sem conferência") que se abre ao toque; as ainda não alcançadas ficam
   como rótulo sem campo. Isso resolve de uma vez as duas ou três cápsulas
   carvão por rolagem (sobra uma) e a voz de manual numa tela vazia, e é o que
   `curva-zero` chama de divulgação progressiva sem esconder poder: nada some,
   tudo continua a um toque.
2. **O elo, não a etapa.** Um indicador de progresso seria um wizard, e o
   trabalho não é sequencial — o autor volta ao pedido depois do relato, e é
   justamente aí que a volta se fecha. O que falta é dizer **de onde veio** cada
   coisa: a versão já sabe o pedido que a produziu (`pedidoDe`), o ato sabe a
   versão (`Acao.artefatoID`), a evidência sabe o ato. Uma linha de proveniência
   no alto de cada bloco — "desta versão", "do pedido de 19:48" — e a
   dificuldade oferecendo em uma ação **voltar ao pedido com o obstáculo
   dentro** (a rota de "Pedir ajuste" já existe na conferência; falta a mesma
   saída na Dificuldade) fecham o desenho da volta sem desenhar um círculo.
3. **Contenção, para o olho ver quatro coisas e não dezesseis.** Os rótulos de
   seção são 11 pt de peso igual sobre o mesmo papel; `law-of-common-region`
   pede que cada etapa seja uma região. O cartão de papel já existe e já é da
   casa (é o da versão) — estendê-lo às demais etapas, com o rótulo dentro da
   borda, dá a região sem inventar componente novo. Falta em `Componentes` uma
   `Secao`/`Bloco` que faça isso, e é a mesma peça que substituiria os cinco
   `DisclosureGroup` do sistema que sobraram.

O que eu **não** faria: linha do tempo, círculo desenhado, numeração de passos
ou barra de progresso. Nenhum descreve um trabalho que volta, e todos
transformam uma oficina em formulário — a mesma doença, com outra roupa.

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

## ADR 2026-09-06e — Sete métodos novos, e o que protege a escrita pessoal

**A distância.** O catálogo tinha 21 métodos e três faculdades vazias
(simplificação, direção, consequência). A trilha Métodos levantou doze
candidatos com fonte primária, rejeitou seis por duplicação, e mediu uma coisa
que não é intuitiva: **onde um método é colado muda o que o autor recebe.**
`AnaliseLocal.detectarGesto` percorre o catálogo **na ordem do arquivo** e vence
o primeiro cuja regex casa. Ordem é comportamento, não arrumação.

**A decisão.** Os sete aprovados entram **no FIM** do `Metodos.json`, nesta
ordem: Subtração, Coluna da esquerda, Classe de referência, Cinco porquês (M1),
A pergunta de Hamming, O que se vê e o que não se vê, Exame da noite (M2).

Colados **antes da Especificação**, a Coluna da esquerda passa a roubar o
desabafo da Expressiva — medido nesta volta com o catálogo inteiro montado:

```
os 7 no FIM                 -> 0 desvio nas 74 frases desta AMOSTRA
os 7 antes da Especificação -> colunaEsquerda «na reunião com o chefe eu senti
                               uma raiva enorme, doeu ficar ali, fiquei calado
                               o tempo todo e chorei depois no corredor…»
```

**74 frases é uma amostra, não uma propriedade do catálogo**: 74 frases escritas
pelo autor desta volta, roteadas contra o catálogo montado. O G3 escreveu 58
próprias e achou **22 desvios** — todos de escrita pessoal.

**O que protege a escrita pessoal, medido pelo G3:** é a ordem do arquivo
**mais** o teto de 120 caracteres em `AnaliseLocal.detectarGesto`
(`if g == .expressiva, x.count <= 120 { continue }`). O teto pula a Expressiva
em texto curto e promove `colunaEsquerda` e `exameDaNoite` a primeiro-a-casar:
14 de 14 linhas curtas com palavra de sentimento chegam vestidas de método
(`m3-rev-03`). E acima do teto a ordem também não basta, porque o léxico de dez
palavras da Expressiva não cobre o desabafo **factual**: 8 de 8 chegam vestidos
(`m3-rev-02`).

Daí a regra permanente, **corrigida**: nenhum método cuja regex mencione
conversa, silêncio, arrependimento ou sentimento entra antes da Expressiva —
**e essa regra sozinha não protege ninguém enquanto o teto de 120 existir**. Os
sete a obedecem e o roubo acontece assim mesmo. `oDesabafoLongoContinuaExpressivo`
prova só o caso fácil (desabafo longo e carregado de vocabulário da Expressiva);
`aEscritaPessoalNaoChegaVestidaDeMetodo` cobra as 22 frases do G3 e **falhava
nesta volta, de propósito** — o conserto morava em `Traco/Analise`, fora daqui.

**A colagem (volta M3-C, 06/09).** O conserto chegou pelas voltas A1–A5 (ADRs
2026-09-06h e 06i, com as passadas 06i-B/C/D) e entrou em main antes desta.
Depois do `git merge main`, **as 22 passaram sem uma linha de `Traco/Analise`
tocada aqui**: `aEscritaPessoalNaoChegaVestidaDeMetodo` está verde, e nenhuma
das 22 sobrou. A guarda cobriu tudo o que esta volta criava.

Alargar a Expressiva por dado não é saída: as palavras que cobririam o desabafo
factual (`engoli`, `fiquei calado`, `me arrependi`, `perdi a paciência`) são as
regex dos dois métodos novos, e o alargamento os deixaria inalcançáveis.
Medido com `todoRamoDeRegexAlcancaOSeuMetodo`, não suposto.

**No mesmo passo, o conserto do Se–então.** `sempre que|toda vez|não consigo
parar` sem `\b` casava DENTRO de "sempre quebra", "sempre queria", "sempre
quero" — e o Se–então levava a frase de quem ela era. Com `\b`:

```
seEntao -> cincoPorques    «sempre quebra no mesmo ponto, qual é a causa»
seEntao -> colunaEsquerda  «sempre queria ter dito o que pensei»
seEntao -> seEntao         «sempre que abro o telefone na cama eu perco uma hora»
```

**Guarda de dado contra botão morto.** `Sessao.encadear` sai em silêncio quando
o destino não está no catálogo, mas `CamposFormaView` desenha o botão do mesmo
jeito: destino inexistente = botão que acende e não faz nada. Nenhum
encadeamento colado aponta para id inexistente, e
`nenhumEncadeamentoApontaParaMetodoInexistente` trava sobre `Catalogo.todos`.
A correção da tela (não acender) é outra volta.

**O tom do cartão vestido.** Três frases de `reconhecimento` julgavam o autor em
vez de nomear o material — a voz das outras 25 (`isto é…`, `isto pede…`).
`m3-rev-03` mostra a pior servida a quem escreveu que chorou. Corrigidas para a
voz da casa, e a da Coluna da esquerda passa a repetir a própria `definicao`:
"você calou o principal" → "o principal ficou por dizer"; "trabalho sem direção
— falta perguntar se importa" → "trabalho que ainda não nomeou o problema
importante"; "o seu dia pedindo julgamento — dos seus atos" → "o seu dia em
revista — e uma regra para amanhã" (o próprio `movimento` diz que julgamento sem
prescrição é remorso, e remorso não é método). É mitigação, não cura: a cura é a
nota pessoal não chegar vestida.

**Três frases de honestidade nos 21 antigos.** A régua da proveniência
(trilha Métodos) achou três fichas com grau de origem declarado acima do real —
obra real citada ao lado de procedimento que não está nela. Nenhuma sai; as três
passam a dizer o que a fonte não contém: a **Decisão** ("prática atribuída a
Daniel Kahneman, sem texto dele que a descreva"; o artigo de 2009 é evidência
vizinha, não a origem), os **Primeiros princípios** ("Aristóteles não propõe
este exercício; o Traço toma dele a noção de princípio e monta o resto") e a
**Inversão** ("sem transcrição de referência localizada", e a frase de Jacobi
marcada como atribuição). Fragilidade dita é honestidade.

**O que fica de fora, e é dito.** Cinco desvios de roteamento que já existiam
antes desta volta continuam de pé, e são de uma volta de roteamento própria:
`(?m)^quero` do WOOP engole Pré-mortem, Feynman, Primeiros princípios e Prática
deliberada; `ideia` da Nota permanente engole Destilar. Um sexto, achado aqui:
`\bo dia de hoje\b` do Dia engole `\bolhando o dia de hoje\b` do Exame da noite
— a mesma família (regex larga e cedo comendo regex específica e tarde), sem
efeito novo, porque a frase já ia para o Dia antes.

**Alcance de ramo, guarda nova.** Nenhum teste garantia que uma frase de gatilho
**chega** ao método que a declara — todo método futuro podia nascer com ramos
mortos sem ninguém saber. `todoRamoDeRegexAlcancaOSeuMetodo` gera uma frase por
ramo de regex de `Catalogo.todos` (287 sondas nos 28) e cobra a chegada.

Os desvios conhecidos são **dezoito**, remedidos na colagem com `conhecidos`
vazio — não herdados da lista de catorze da ADR 06h, e o estreitamento da A5 e
das 06i-B/C/D **não mudou a conta**. Quatro são regex larga e cedo comendo regex
específica e tarde: `melhor argumento contra` (steelman → argumento), `dez
ideias` e `todas as ideias` (divergência → nota permanente) e `olhando o dia de
hoje` (exame da noite → dia); os quatro seguem vivos, nenhuma entrada morta. Os
outros **catorze** são a guarda da escrita pessoal chegando antes do roteamento
e calando a sonda: **3 ramos da Coluna da esquerda** (`engoli`, `fiquei calado`,
`deixei passar`) e **11 do Exame da noite**. Não é regex morta — é regex que o
app se recusa a usar, de propósito. Desvio novo, fora dos dezoito, derruba o
teste.

**O preço, dito por inteiro.** O **segundo ramo do Exame da noite** (`não devia
ter …`, `me arrependi`, `fui injusto|grosso|duro demais|ríspido`) está
**inteiro fechado**: 9 de 9 sondas caladas. O método continua alcançável pelo
primeiro ramo (`exame da noite`, `passei o dia em revista`) e por `hoje eu
(fiz|reagi|tratei)`, mas a sua porta mais natural sumiu. É a proteção
funcionando, e é o que ela custa — está no teste para ninguém redescobrir
sozinho.

**Duas frases desta volta morreram, e estavam erradas.** `osSeteNovosRoteiamParaSiMesmos` afirmava que "perdi a paciência na reunião e me arrependi" e "fui
injusto com o time hoje de manhã" chegavam ao Exame da noite. As duas são
confissão de conduta, indistinguíveis das 22 do revisor: **o teste pedia
exatamente o roubo que a 06h proíbe**. Foram trocadas por três frases que
convocam o método sem confessar nada. O teste estava errado, não a guarda.

**As sete portas ganharam régua.** `todaPortaDeMainTemPeloMenosDuasFrases` cobra
duas notas de trabalho por porta de `Catalogo.doApp`, e o catálogo passou de 21
para 28: as sete novas — justamente as que roubavam — entraram com **catorze
frases de trabalho** em `EscritaPessoalTests.trabalho` (58 → 72). As três réguas
de main (57 protegidas, 13 com gancho, 6 legítimas, agora 72 de trabalho) valem
com os sete colados, sem um caractere de guarda enfraquecido.

**A prova.** Suíte integral verde no iPhone 17 Pro (teste 2) na colagem — **785
testes em 130 suítes, 0 falhas** — e 723 testes em 125 suítes no fecho da
primeira volta; no app o Perfil diz "28 do app" com a proveniência
dos novos abrindo (`maestro/metodos-m3.yaml`). O target do app compila limpo; o
de teste traz **4 avisos (2 únicos) em `ConferenciaTrabalhoTests.swift:381`,
pré-existentes de `73b1ebc`** — não são desta volta, e "build sem aviso" era
falso. **Fora:** os três da M4, a correção da UI
do botão sem destino, os cinco desvios do WOOP e da Nota permanente, e os
pedidos de app que a forma livre levantou (campo repetível, compromisso
recorrente, campo emparelhado, Classe de referência lendo o corpus).

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

**O PREÇO DESTA GUARDA, declarado (acrescentado na volta A-5).** Esta ADR mediu
um lado só. O revisor do re-G3 mediu o outro e achou o custo: com a guarda
alcançando todo o catálogo, **a família 1 passou a comer nota comum de
trabalho.** `vazio`, `sozinho`, `cansado`, `pesa`, `ansioso` e `medo` são
palavras de trabalho tanto quanto de desabafo — de dez notas comuns que ele
escreveu, NOVE mudaram de destino e OITO eram regressão limpa. O caso mais caro,
dito por extenso: **"Quero correr de manhã, mas o medo de me machucar me trava"
deixou de receber WOOP**, num app cujo campo do WOOP se chama "OBSTÁCULO INTERNO
(O SEU HÁBITO/MEDO)" e cuja `perguntaWOOP` pergunta "qual é o hábito ou o MEDO
seu que vai impedir"; o app pedia o medo pelo nome e calava quando o autor o
escrevia. E "estado vazio, carregando e falha" — o vocabulário do próprio G2 da
ESTEIRA — calava também. **Nenhum teste cobria essa direção**, e foi por isso
que passou: `oQueOsDoisMetodosLevamComRazaoContinuaDeles` protegia 6 frases dos
DOIS métodos da M3, e as outras 19 portas não tinham régua de alcance. A volta
A-5 estreita a família 1 e escreve a régua que faltava — **ADR 2026-09-06i**.

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


## ADR 2026-09-06i — A família 1 reconhece o SENTIMENTO COMO ASSUNTO, não a palavra solta

**A distância.** A 06h fechou a guarda pelo catálogo inteiro e, na mesma linha,
alargou o dano: a família 1 é uma lista de RADICAIS soltos, e seis deles têm
dupla vida. O revisor do re-G3 mediu dez notas comuns de trabalho — **nove mudam
de destino, oito são regressão limpa** contra o código anterior:

| antes → agora | a nota | o radical que dispara |
|---|---|---|
| woop → silêncio | "Quero correr de manhã, mas o MEDO de me machucar me trava" | `medo` |
| spec → silêncio | "Preciso construir a tela de estado VAZIO do app…" | `vazi[oa]` |
| spec → silêncio | "Estado VAZIO, carregando e falha: as três telas…" | `vazi[oa]` |
| spec → silêncio | "Estou CANSADO desse módulo cheio de casos especiais…" | `cansad` |
| spec → silêncio | "A carga PESA demais nesse endpoint…" | `\bpesa` |
| spec → silêncio | "O módulo roda SOZINHO depois do deploy…" | `sozinh` |
| seEntão → silêncio | "Sempre que fico SOZINHO em casa eu abro a geladeira…" | `sozinh` |
| notaPermanente → silêncio | "Percebi que sistemas ANSIOSOS por resposta imediata…" | `ansios` |

O caso que dói é o primeiro, e é constrangedor: o campo do WOOP chama-se
"OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" e `perguntaWOOP` pergunta pelo "hábito
ou o medo seu que vai impedir". **O app pede o medo pelo nome e cala quando o
autor o escreve.** Um sétimo radical entra pela mesma porta sem ninguém ter
medido: `senti` sem borda de palavra casa dentro de "o SENTIdo dele" e "o
SENTImento do cliente" — duas expressões que não têm nada de desabafo.

**A decisão.** A família 1 se parte em duas, e o critério é o SENTIMENTO COMO
ASSUNTO.

- **1a, `lexicoDoSentimento`** — o sentimento que só tem uma vida: `senti`,
  `sinto`, `sentia`, `me sentindo` (agora com **borda de palavra**, que é o
  conserto do `sentido`/`sentimento`), `dói|doeu`, `chor…`, `trist…`, `raiva`,
  `desmoron…`, `arrepend…`, `vergonh…`, `mago…`, `remoend…`, `travei|eu travo`,
  `angusti…`, `desanimad…`, `humilhad…`, `culpad…`, `nó na garganta`. Dispara
  sozinho, como antes.
- **1b, `lexicoDeDuplaVida`** — `medo`, `pesa`, `ansios`, `exaust`, `vazi[oa]`,
  `sozinh`, `cansad`. **Sozinha não decide nada.** Ela só vale com uma destas
  três companhias:
  1. **o autor no meio** (`lexicoDoSentimentoNoAutor`): primeira pessoa + verbo
     de estado, e o complemento é PRONOME ou nada — "estou sozinho nisso",
     "estou cansado de mim", "fico vazio." —, nunca objeto de trabalho ("estou
     cansado **desse módulo**", "fico sozinho **em casa**"). Para `medo` a linha
     é entre **predicar** ("estou com medo", "tenho medo", "senti medo") e
     **nomear** ("o medo de errar"), que é o obstáculo DENTRO de uma intenção —
     exatamente o que o WOOP existe para receber. `vazio` conta como
     SUBSTANTIVO ("esse vazio", "um vazio"), não como adjetivo de tela ("estado
     vazio"). `pesa` conta quando o que pesa não tem nome ("isso pesa", "cada
     dia pesa"), porque a nota de trabalho nomeia a carga ("a carga pesa");
  2. **densidade** — duas palavras DIFERENTES de dupla vida na mesma nota
     ("Estou exausto e vazio."). Uma é vocabulário; duas são o assunto;
  3. **a omissão ao lado** (família 5) em QUALQUER tamanho — "Foi pesado e eu
     fiquei calada." tem 29 caracteres e é a nota mais frágil das 57. A omissão
     continua sem disparar sozinha abaixo do teto de 120: aqui ela é companhia,
     não gatilho.

`descontei` também ganhou os pronomes que faltavam (`descontei nela|nele|em`):
a família 4 casava "descontei com" e "descontei no", e deixava "descontei nela"
passar — a nota ficava presa só à família 1 e caía junto com ela.

**A régua NOVA, que é o coração desta volta: a direção inversa.** Havia 57
frases provando que desabafo não vira método e **nenhuma** provando que nota
comum continua achando a forma — por isso a regressão passou.
`EscritaPessoalTests.trabalho` tem **47 frases, no mínimo duas por PORTA das 21
formas de main**, as dez do revisor incluídas e marcadas `[R]`, com as que
citam sentimento de propósito: WOOP com `medo`, Se–então com `cansado`,
Especificação com "estado vazio", Pré-mortem com `medo`, Leitura com "times
cansados", Decisão com "o medo de errar", e duas sondas do conserto do `senti`
("o sentimento do time", "busca exaustiva").
`todaPortaDeMainTemPeloMenosDuasFrases` cobra a cobertura contra
`Catalogo.doApp`, para a régua não encolher sem ninguém ver. **E ela mede:**
portada a mesma régua para a família 1 de `2d33d63`, **15 das 47 são caladas**
(as 8 do revisor, mais Decisão, Pré-mortem, Leitura, Palavra e as duas sondas
do `senti`, mais a segunda do Se–então); com a família partida em duas, **0**.

**As duas réguas correm JUNTAS** em `asDuasReguasValemAoMesmoTempo`, no mesmo
catálogo e na mesma corrida: as 57 continuam protegidas E as 47 continuam
roteando. **Nenhum caso precisou de arbitragem** — o critério satisfaz as duas
ao mesmo tempo, e nenhuma frase foi retirada de nenhuma das réguas para isso.
Se um dia as duas se contradisserem num caso, o lado é o da guarda, e a razão é
a assimetria que o revisor usou nos dois sentidos: **silêncio numa nota de
trabalho custa um toque para escolher a forma à mão; vestir um desabafo carimba
quatro campos de exercício sobre o que o autor acabou de sentir.** O caso vai
para esta ADR com o lado escolhido e o motivo, não para dentro do teste.

**O que esta guarda continua sem fazer.** Ela é regex, não compreensão: "estou
cansado de escrever documentação" não é reconhecido como desabafo (não chega a
método nenhum, então cai no silêncio de sempre), e um desabafo escrito só com
palavra de dupla vida sem primeira pessoa — "que vazio hoje" — também não. O
critério é sintático de propósito: ele mede quem é o sujeito da frase, não o que
o autor sente.

**Volta:** multiplicar. **O que a IA sabe:** nada de novo — a guarda continua
sem modelo, no aparelho. **Prova:** `EscritaPessoalTests` com as TRÊS réguas na
mesma suíte — **57 protegidas + 10 com gancho + 6 legítimas da M3 + 48 de
trabalho** — e `aPalavraDeDuplaVidaSozinhaNaoDecide` fixando o critério nos dois
sentidos com 23 asserções. **Fora:** o `\bpesa` continua casando "pesado" pela
esquerda (é o que protege "Foi pesado"); `exaust` entrou na 1b sem que ninguém
tenha medido "busca exaustiva" em nota real, só por leitura; e as 48 frases da
régua inversa são minhas, não de uso real — elas provam alcance, não
representatividade.

**Junto nesta volta, os acabamentos que o re-G3 nomeou**
(`ferramentas/orca/revisao-a-voz.md`, §R-5). **M-2:** o diálogo destrutivo do
Perfil dizia "Esquecer tudo o que o Traço **aprendeu de você**?" — a frase que a
A4 condenou e trocou no rótulo logo acima ("O que o Traço registrou — contagem,
não conclusão"), mas não no diálogo; passa a "Esquecer tudo o que o Traço
**registrou**?", a mesma palavra do rótulo e do corpo da mensagem ("Os sinais
somem do aparelho. As notas ficam."). **M-3:** a dica de VoiceOver do botão da
Lente dizia "**Muletas**, frases feitas…" para abrir uma tela cujas seções se
chamam "Palavras de apoio" e "Frases de outro"; passa a "Palavras de apoio,
frases de outro, passivas e adjetivos repetidos. Só aponta." — a dica volta a
nomear o que a tela mostra, que é o que uma dica de VoiceOver existe para fazer.
O quarto acabamento, o preço da guarda, está escrito no "Fora" da 06h.

**As seis fases do `design-router` nas duas strings** (M-5 do re-G3, que valia
para a copy da A4 e vale para esta). **Ancorar:** rota "ajuste local de
componente/copy" — nenhum moodboard, nenhum token novo, nenhum crítico; a
pessoa é o autor lendo um diálogo destrutivo e o autor ouvindo o VoiceOver.
**Sistema:** as duas frases já tinham dona na tela — `PerfilView:161` diz
"registrou" e `LenteView:133/138` dizem "Palavras de apoio"/"Frases de outro";
o conserto é reusar o vocabulário que existe, não inventar um terceiro.
**Construir:** duas strings, zero mudança de layout, de Tema ou de estado.
**Mover:** nada — copy não anima. **Julgar:** o teste contra design genérico não
se aplica a duas frases, mas o teste da 06f se aplica e é o que pega o defeito:
o app não diz o que não mediu, e "aprendeu de você" alegava aprendizado sobre uma
contagem de sinais. **Portão:** a mudança do Perfil é visível na tela (diálogo de
confirmação) e a da Página só pelo VoiceOver. **A captura do M-2 está feita**
(`ferramentas/orca/a5b-m2-esquecer-dialogo.png`): o diálogo diz "Esquecer tudo o
que o Traço registrou?" sobre "Os sinais somem do aparelho. As notas ficam.", e
o rótulo logo acima na mesma tela diz "O que o Traço registrou — contagem, não
conclusão" — a mesma palavra, que era o ponto. A leitura anterior desta ADR
estava errada e o revisor a derrubou com razão: a lei do instrumento da ESTEIRA
tira o **maestro** quando há vários simuladores ligados, e no mesmo parágrafo
nomeia o substituto — `xcrun simctl io <UDID> screenshot`, que é por-UDID e não
sofre do problema. A lei tira o maestro, não a captura. A da Página continua sem
foto porque VoiceOver não fotografa; é verdadeira por leitura do código.

### 06i-B — A CAUDA, e o preço que o estreitamento cobrou (volta A-5-B)

**O que o revisor do G3 achou, e ele estava certo.** O critério "sentimento como
assunto" é o critério certo, mas ele foi aplicado com uma lista de caudas tirada
da amostra e não do idioma. O revisor replicou a guarda em Swift lendo os
literais direto do `AnaliseLocal.swift`, escreveu **20 desabafos novos que usam
só vocabulário 1b MAIS um gancho de roteamento**, e mediu as duas versões:
**em `main` 19 dos 20 caíam no silêncio; na A-5, 18 dos 20 passaram a ser
VESTIDOS** em quatro campos de exercício. "Quero sumir uns dias, ando muito
cansado ultimamente" virava WOOP; "Percebi que estou sozinha faz meses" virava
Nota permanente; "Não entendi por que ando tão vazio ultimamente" virava
Feynman. Na moeda que esta ADR escolheu — vestir custa mais que calar — o saldo
da A-5 era **negativo**, e as 57 não pegaram porque **só 7 delas exercitam a
família 1b e nenhuma tem gancho**.

**A causa é a CAUDA, não o radical.** Alargar o radical foi o que causou a
regressão da 06h; reabri-lo desfaria esta volta. O que faltava era a lista do
que vem DEPOIS do adjetivo num desabafo real:

- **intensificador posposto** — "cansado **demais**", "sozinha **demais**"
- **advérbio de tempo** — "cansado **ultimamente**", "sozinha **faz meses**",
  "exausto **por dois dias**", "ansioso **desde** que ela foi embora"
- **verbo de estado que ficou de fora** — `acordo cansado` (só `acordei`
  entrara), `fico com um medo`, `bate um medo`, `morrendo de medo`
- **os substantivos** `ansiedade` e `cansaço`, que `ansios`/`cansad` não
  alcançam

A cauda virou constante própria (`caudaDoSentimento`), reusada pelo ramo do
adjetivo. Os **dez casos que o revisor citou por extenso passam a ser calados,
10 de 10** — medido no simulador, na suíte, antes e depois.

**`dá medo` foi recusado na 06i-B, e a recusa era metade certa.** O revisor
pediu `fico|dá|bate` no ramo do `medo`. `fico` e `bate` entraram; **`dá` não**,
porque a régua inversa dele mesmo contém "Pré-mortem: imagino o lançamento no
chão e o que me **dá medo** é ninguém avisar a tempo" esperando `premortem` — o
`dá medo` largo custa uma forma real, e isso foi medido antes de recusar. O que
estava errado era o enquadramento: a 06i-B declarou o caso "primeiro caso de
arbitragem desta ADR" e, na mesma frase, **nomeou o discriminador sem
implementá-lo**. A 06i-C o implementa e a arbitragem some (ver abaixo).

**Um caractere, e ele contradizia esta ADR.** `vazi[oa]` era o único radical de
`lexicoDeDuplaVida` que capturava a própria flexão, então "A lista **vazia** e o
estado **vazio** da tela" contava como duas palavras diferentes e disparava a
densidade sozinha — contra o comentário do próprio código ("duas palavras
DIFERENTES") e contra o exemplo canônico desta ADR. Agora é `vazi`, e
"Preciso construir a lista vazia e o estado vazio da tela" está na régua inversa
como `spec`.

**A RÉGUA GANHA UM BLOCO, e é a lição da rodada.** Duas réguas não bastavam
porque nenhuma das duas exercitava **o cruzamento**: desabafo que TAMBÉM tem
palavra que roteia — o caso mais comum na vida real e o ponto cego das duas.
`EscritaPessoalTests.comGancho` tem **dez desabafos, um por gancho de
roteamento** (`^quero`, `sempre que`, `toda vez`, `percebi`, `hoje eu preciso`,
`não entendi`, `^preciso começar`, `^preciso parar`, `meu objetivo`, `\bapp\b`),
oito deles medidos VESTIDOS pelo revisor. O teste cobra as duas metades: a nota
é calada **e** o gancho da porta declarada casa mesmo — sem isso a régua não
mede nada. As **três** réguas correm juntas em `asDuasReguasValemAoMesmoTempo`.

**Fora (a dívida que sobra, nomeada e não consertada).** A densidade ainda cala
nota de sistema que usa duas palavras de dupla vida ("estado vazio" + "fila
vazia" já não, mas "o medo é o servidor cair" + "equipe cansada" sim): o revisor
mediu 15 de 20 notas de trabalho novas caladas na A-5 — **e as mesmas 20 eram
caladas em `main` também**. É dívida residual, não regressão, e vai para o RUMO,
não para esta volta. Os dois substantivos novos (`ansiedade`, `cansaço`) entram
em `lexicoDeDuplaVida` e portanto alargam essa mesma densidade em dois termos.
E o critério continua sintático: ele mede quem é o sujeito da frase, não o que o
autor sente.

### 06i-C — A FORMA DA CAUDA, e a borda de palavra varrida até o fim (volta A-5-C)

**Três dimensões em 8 no re-G3, e uma raiz só.** Correção, Contrato e
Privacidade desceram pelo mesmo defeito: a cauda da 06i-B foi escrita como
**terminador** e o intensificador posposto entrou nela. Como terminador, ele
curto-circuita o teste que o critério inteiro usa para separar trabalho de
desabafo — o do OBJETO —, porque a regex para de olhar assim que casa `demais`:

```
não casa  «estou cansado desse módulo cheio de casos especiais.»          ← TRABALHO ✔
CASAVA    «estou cansado demais desse módulo para reescrever a função.»   ← virava PESSOAL ✘
```

A segunda é a primeira com uma palavra a mais, e é o exemplo canônico do lado
trabalho **desta própria ADR**. O conserto não é tirar o intensificador: é
torná-lo **transparente** — `intensificadorPosposto` entra ENTRE o adjetivo e a
cauda, opcional, e a cauda continua sendo cobrada depois dele. `pra isso` entra
na cauda porque é complemento pronominal, não objeto. Com isso "cansado demais
**pra isso**" é desabafo e "cansado demais **desse módulo**" é trabalho, que é a
linha que a ADR sempre disse traçar.

**A BORDA DE PALAVRA, varrida até o fim.** O padrão da volta inteira era um só e
apareceu três vezes (`senti` na 06i, `vazi[oa]` na 06i-B, `ando ` agora):
radical sem `\b` casando dentro de outra palavra. Desta vez a guarda foi varrida
por completo — **os 8 léxicos, 82 alternativas, uma por uma** — e **11 pontos
precisaram de `\b`** (as três listas de verbos contam três), a maioria medida com
frase real antes e depois:

| lugar | a palavra que entrava pela porta errada | a nota que era calada |
|---|---|---|
| `\b` nas 3 listas de verbos de `lexicoDoSentimentoNoAutor` | `ando ` dentro do gerúndio; `bate ` dentro de "combate" | "trabalhando cansado demais, vou revisar o módulo" |
| `\bcansad` | "des**cansad**o" | "O time está descansado e a fila vazia depois do deploy" |
| `\bmedo`, `\bcansaço` | "**medo**nho", "des**cansaço**" | — sem caso medido; entram pela mesma classe, junto com `\bcansad`, que tem |
| `\bsou (o\|um\|uma)` | "pen**sou o** problema" | "Ele pensou o problema todo e devolveu a spec revisada" |
| `\bme (odi\|culp\|…)` | "fil**me odi**ado" | "O filme odiado pela crítica virou tema da spec" |
| `\bculpad` | "des**culpad**o" | "O erro foi desculpado pelo time e a fila voltou a rodar" |
| `\bbriguei` | "a**briguei**" | "Me abriguei da chuva e cheguei atrasado na reunião" |

**As outras alternativas foram conferidas e não têm o defeito**, e três que
pareciam ter foram medidas e estão limpas: `exaust` em "busca exaustiva" (não
dispara sozinho, precisa de companhia), `vazi` em "es**vazi**a" (colapsa com
"vazio" na mesma chave da densidade, que é o conserto da 06i-B funcionando) e
`\bpesa` em "pesa demais" (o objeto ainda é testado). **A classe foi VARRIDA —
não está fechada** (frase corrigida na 06i-D, que achou mais dois pontos da
mesma classe): as alternativas foram lidas uma a uma e as que não têm borda à
esquerda foram medidas contra os candidatos que soubemos nomear.

**PREDICAR vs NOMEAR, escrito.** A linha que a 06i-B nomeou na frase da recusa
agora existe em código, e é a que o revisor propôs, com uma correção medida:

```
\bd[áa] (um |uma )medo  |  \bd[áa] medo de \w+r\b  |  (^|[.!?]\s*)d[áa] medo
```

- **PREDICAR** — leva artigo ("me **dá um** medo"), pede **infinitivo** ("dá
  medo **de encarar**") ou abre a frase ("**Dá medo.**"). É desabafo.
- **NOMEAR** — "o que me dá medo é ninguém avisar" não faz nenhum dos três: é
  obstáculo dentro de uma intenção, e continua indo ao Pré-mortem.

A correção sobre a proposta do revisor: `d[áa] medo de` largo comia "o que **dá
medo de** verdade nesse plano", que é trabalho. Com `de` + **infinitivo**
(`\w+r\b`) os dois lados ficam de pé — que é a própria definição que ele
escreveu ("nunca vem com `de` + infinitivo" é a marca do NOMEAR). **Esta frase
está errada e a 06i-D a corrige:** o braço `de` + infinitivo NÃO é
discriminador, é ARBITRAGEM — ele come Pré-mortem que usa a mesma forma. A ADR
TEM um caso de arbitragem, e é este.

**Mais dois buracos do mesmo ramo.** `bate|bateu|dá|deu` entram no ramo de
`ansiedade|cansaço` (a 06i-B pôs `bate` só no ramo do `medo` — assimetria da
própria correção), e `por dentro` entra na lista de sujeitos do `pesa`. Fecham
"toda vez que eu abro o computador **bate um cansaço**" e "hoje eu preciso
fingir que está tudo bem, mas **por dentro pesa**".

**Volta:** melhorar. **O que a IA sabe:** nada de novo — a guarda continua sem
modelo, no aparelho. **Prova:** as TRÊS réguas na mesma suíte, agora
**57 protegidas + 13 com gancho + 6 legítimas da M3 + 52 de trabalho**, mais
`aPalavraDeDuplaVidaSozinhaNaoDecide` com 40 asserções. As 121 frases das réguas
existentes foram medidas antes e depois num binário que copia as linhas 111–238
do `AnaliseLocal.swift` **verbatim** (o método do revisor): **0 mudanças** — os
12 casos que mudaram de lado são exatamente os 12 alvo. `xcodebuild test` no
iPhone 17 Pro (teste 4) `A1DF082C`: `✔ Test run with 752 tests in 128 suites
passed after 7.379 seconds.` / `** TEST SUCCEEDED **`. **Fora:** o `\bpesa`
continua casando "pesado" pela esquerda (é o que protege "Foi pesado"); `exaust`
continua sem medida em nota real; a dívida da densidade em nota de sistema segue
no RUMO; e a régua inversa continua sendo escrita por mim e pelo revisor, não
por uso real.



### 06i-D — As duas bordas que faltavam, e duas frases de honestidade (volta A-5-D)

**O revisor reconstruiu o binário verbatim sobre a A-5-C e mediu: 122 frases das
réguas, 0 problemas.** Sobraram duas linhas de código — a mesma classe de borda
da 06i-C, em dois pontos que a varredura não alcançou — e duas frases desta ADR
que estavam otimistas demais. Ele baixou **Estado honesto de 9 para 8** por
causa das duas frases, e tem razão nas duas.

**As duas linhas.** Nenhuma decisão nova de critério; as duas são a borda
esquerda que a 06i-C já tinha varrido em outros onze pontos:

| linha | a palavra que entrava pela porta errada | a nota que era calada |
|---|---|---|
| `\btratei mal` | "**contratei mal**", "**retratei mal**" | "Contratei mal o fornecedor e vou construir um processo de seleção" |
| `me d[áa]\|me deu` (era `d[áa]\|deu`) | a ansiedade **do usuário**, não a do autor | "A fila dá ansiedade no usuário e vou construir um indicador" |

O segundo é correção sobre a MINHA implementação, não sobre a proposta: a
sugestão do `dá|deu` no ramo de `ansiedade|cansaço` foi do revisor e eu a
implementei mais larga do que ele mediu. Com `me`, o sujeito volta a ser o autor
— que é o critério inteiro desta ADR.

**Fora — a ARBITRAGEM declarada.** O braço `\bd[áa] medo de \w+r\b` da 06i-C
não é discriminador: ele come Pré-mortem que usa a mesma forma ("dá medo de
perder o cliente se o deploy falhar" perde a forma). Mantê-lo é ESCOLHA, não
acerto, e as três saídas foram medidas:

| saída | custo |
|---|---|
| **manter o braço** (a escolhida) | **0 carimbos** em desabafo, **2 silêncios** em Pré-mortem |
| tirar o braço | o desabafo predicado com infinitivo ("dá medo de encarar segunda") volta a virar exercício — carimbar nota pessoal é o erro caro desta guarda |
| afinar por outro sinal | as duas formas admitem o mesmo sujeito e o mesmo verbo; não achamos sinal que separe |

A escolha é pela ASSIMETRIA: calar é reversível pelo autor, carimbar não. Fica
declarado como o **único caso de arbitragem da 06i** — a frase da 06i-C que diz
o contrário está corrigida acima.

**A classe NÃO está fechada.** A frase "a classe está fechada" da 06i-C ia para
o LAÇO como se varrer fosse provar. Não é: a varredura leu os 8 léxicos e as 82
alternativas uma a uma, e as que não tinham borda à esquerda foram medidas
**contra os candidatos que soubemos nomear** — e esta volta achou mais dois
exatamente aí. O resíduo conhecido e sem conserto grátis é a **família do
adjetivo sem cópula** ("dia vazio", "gente cansada" dentro de nota de sistema),
que a densidade ainda pode calar: consertá-la exige análise sintática, não
borda.

**Volta:** melhorar. **O que a IA sabe:** nada de novo — a guarda continua sem
modelo, no aparelho. **Prova:** as três réguas com **6 frases novas** na régua
inversa (58 de trabalho; 57 protegidas + 13 com gancho + 6 legítimas), e as seis
medidas VERMELHAS antes do conserto — `silencio ← «Contratei mal o fornecedor e
vou construir um processo de seleção com três etapas.» (esperado spec)` e as
outras cinco. Depois, no iPhone 17 Pro (teste 4) `A1DF082C`: `✔ Test run with
14 tests in 1 suite passed after 0.297 seconds.` na `EscritaPessoalTests` e
`✔ Test run with 752 tests in 128 suites passed after 8.910 seconds.` /
`** TEST SUCCEEDED **` na suíte inteira. **Fora:** a arbitragem do `dá medo de` acima; a família do adjetivo
sem cópula; a dívida da densidade em nota de sistema segue no RUMO; e a régua
inversa continua sendo escrita por mim e pelo revisor, não por uso real.

## ADR 2026-09-06j — A latência da descoberta: quanto tempo entre afirmar e saber

**A distância.** O Traço já media e não sabia que media. `Hipotese` guarda
`data` (quando foi proposta) e `avaliadaEm` (quando foi avaliada, ADR 05r); a
Decisão guarda "o que espero que aconteça, e quando eu confiro" e "o que
aconteceu" (03a/04t); `Versoes` carimba cada gravação desde a 04. Nada disso
virava grandeza: o único leitor de `avaliadaEm` em todo o app era
`TrabalhoView.avaliacao`, que imprime a data absoluta ao lado de UMA hipótese
("· por você em 3 de jul de 2026, 10:00"). Distância entre os dois carimbos,
nenhuma; série ao longo dos meses, nenhuma. Motor sem superfície: função que o
autor não vê não foi entregue.

**Primeiro medir, depois inventar campo.** A ordem foi essa, e o resultado é
que **nenhum campo novo foi criado**. Do que já estava gravado saiu tudo:

- Hipótese: `data` → `avaliadaEm` dá a latência inteira, sem nada a mais.
- Hipótese avaliada ANTES da 05r: `estado` diz que foi avaliada e `avaliadaEm`
  é `nil`. Isso não é buraco a preencher, é a informação real — a tela diz
  "tempo desconhecido" e ninguém reconstrói a data por dedução.
- Decisão: `criadaEm` é a afirmação; a data do "espero", lida por `Gatilho`, é
  a hora de conferir; "o que aconteceu" preenchido é a descoberta.
- **A descoberta da decisão tem data porque `Versoes` já a tinha.** `editadaEm`
  seria a mentira fácil: é a última edição de qualquer coisa e desliza a cada
  retoque. O histórico guarda o estado ANTERIOR carimbado com a hora da
  gravação, então a versão mais recente que ainda tinha "o que aconteceu" vazio
  é a hora em que ele deixou de estar vazio. Sem histórico (nota importada, ou
  as 30 versões passaram por cima), fica `nil` — tempo desconhecido, de novo
  sem inventar. Foi esse achado que dispensou o campo novo.

**A decisão.** `Traco/Modelo/Latencia.swift`, motor puro (`nonisolated enum`, no
molde de `Retrato`): lê hipóteses e decisões, devolve `Registro` com quatro
estados **distintos na tela** — AFIRMADO (dito, ainda não é hora), DEVIDO (a
hora chegou e continua sem resposta), DESCOBERTO (soube, com ou sem a data) e
ABANDONADO (fechou sem conferir). Nenhum deles é falha. Abandonar é resultado
legítimo e aparece com essa palavra. Hipótese não tem data de conferir e por
isso **nunca fica DEVIDA**: cobrar prazo que o autor não marcou seria inventar.

**A série é o produto, não o número.** Uma latência sozinha não diz nada. A
tela mostra o mês, o tempo do MEIO daquele mês (mediana, não média — uma
hipótese esquecida por um ano deslocaria a média do mês inteiro) e quantas
descobertas houve. E **os abertos viajam junto dos fechados**: série só do que
fechou é o viés de sobrevivência, que é justamente o que a conversa de origem
desta volta (`ferramentas/orca/IDEIAS.md` §A) veio combater. A palavra
"mediana" fica no código; na tela é "a do meio", que se lê sem glossário.

**Não é placar, e o desenho é que garante isso.** Sem meta, sem sequência, sem
XP, sem seta, sem verde e vermelho — e, desde a L1-C, **sem barra nenhuma**: o
mês é uma linha de palavras. Nenhuma ação na seção — o autor lê e sai.
A cobrança de conferir já existe na lista de Notas (`Volta.campoDevido`) e não
foi duplicada aqui; se esta tela tivesse um botão "conferir agora", a medida
viraria lista de tarefas e destruiria o que mede. A pergunta da `curva-zero`
tem resposta literal na tela: "não há nada a preencher aqui".

**Onde mora.** `Traco/Perfil/PerfilView.swift`, logo depois de "A SÁBIA E VOCÊ".
É a mesma família da linha que a 06h acabou de corrigir — "O que o Traço
registrou, contagem, não conclusão" —, e herda essa vizinhança e essa voz. Não
foi para a Análise nem para o Trabalho: a série é do AUTOR e atravessa todos os
trabalhos, então não pertence a um deles.

**Custo assumido.** `Versoes.listar` roda uma vez por decisão ao abrir o Perfil,
síncrono na main — são JSONs pequenos e dezenas de notas; se um dia doer, o
caminho é gravar a data no instante em que "o que aconteceu" enche (aí sim um
campo). `Gatilho` prefere uma hora escrita ("às 9h") à data do mesmo texto e
devolve a próxima manhã: limite herdado, que atinge igualmente a cobrança da
lista, não corrigido aqui. E o estado DEVIDO desta leitura ancora a data do
"espero" em `criadaEm`, enquanto `Volta.devida` a relê a partir de HOJE — em
texto relativo ("em duas semanas") a lista adia a cobrança para sempre e esta
tela não; a divergência é deliberada e está declarada, não resolvida.

**Selo:** nota trancada ou queimada **não entra na latência, nem como
contagem** — a mesma regra do retrato, que é o cartão imediatamente acima nesta
tela ("nada de expressiva, trancada ou queimada entra no retrato, nem como
contagem"). A primeira escrita desta ADR dizia "entra pela contagem" e citava a
05s por uma regra que a 05s não tem; a citação estava errada e a política era
mais frouxa que a do vizinho de cima. Uma DURAÇÃO medida a partir do que o selo
fechou é mais do que contar. A guarda mora em `Latencia.registro(decisao:)`,
que devolve `nil` — no funil por onde toda leitura de decisão passa, não em
cada chamador. Consequência aceita: a decisão selada deixa de ser o único
caminho de uma decisão para ABANDONADO, que agora é só do Trabalho encerrado —
e isso é mais honesto, porque trancar uma nota nunca foi abandonar a decisão.
**Volta:** melhorar — é a lacuna "modelo revisável do autor" do EVOLUCAO.
**O que a IA sabe:** nada. A leitura é do algoritmo, não viaja no prompt e não
entra no retrato.
**Prova:** 11 testes em `LatenciaTests`; suíte integral **758 testes em 129
suítes, 0 falhas**, no iPhone 17 Pro Max de teste em 06/09/2026. A série na
tela, com os quatro estados na mesma captura, uma hipótese fechada, uma aberta
e o registro antigo em "tempo desconhecido": `ferramentas/orca/l1-serie-large.png`,
`l1-tempo-desconhecido-large.png`, `l1-serie-ax5.png` e
`l1-tempo-desconhecido-ax5.png` (`xcrun simctl io screenshot`, não a captura do
maestro). Fluxo `maestro/latencia.yaml`, que rola até cada um dos quatro
estados — em AX5 a seção não cabe numa tela e "está visível agora" seria
asserção sobre o tamanho do texto. As barras foram MEDIDAS na captura: julho
42,6 % da largura (21/49 = 42,9 %) e agosto 7,8 % (4/49 = 8,2 %) — e foi essa
medida, repetida pela revisão, que tirou a barra da tela na L1-C.
**Semeadura declarada:** o simulador não viaja no tempo, então os registros com
datas de junho a setembro foram escritos no formato que o próprio app grava —
mesma tabela SwiftData, mesmo JSON do `DocumentoTrabalho`, mesmo histórico
`Versoes` (`ferramentas/orca/semear-latencia.py`). **Não é a série do aparelho
do dono**, que continua sem captura.
**Fora:** a decisão respondida antes de existir histórico continua sem data; o
`Gatilho`; e não há rota `traco://` para o Perfil (a captura pede maestro).

### A volta L1-B — o portão que a seção não tinha atravessado

A revisão G3 derrubou três dimensões e todas as três pela mesma raiz: uma
superfície nova de LEITURA foi aberta sem passar pelos funis que o resto do app
já tinha. Nenhuma delas era erro de conta.

**1. O selo do Trabalho vale aqui.** `PerfilView.lerLatencia` lia `t.ler()` de
todo `Trabalho` sem `AcessoTrabalho.permitido` — sozinha entre onze superfícies
que gateiam. Um Trabalho nascido de nota trancada, queimada ou expressiva some
da lista, do calendário, da página e dos Atalhos, e continuava imprimindo o
texto literal da hipótese no Perfil. Agora passa pelo mesmo funil. A causa é de
FORMA, e fica escrita: o gate é chamado por cada leitor, então esquecer é
sempre possível; fechar a classe é barato: `trabalho.ler()`
tem TRÊS chamadores no app inteiro, e uma versão única que recebe o
`ModelContext` e devolve `nil` no restrito tira o gate da lembrança de quem
escreve a próxima superfície. Não foi feito aqui para a volta não inchar — está
nomeado, com o tamanho medido.

**2. O corte da lista é POR ESTADO.** `prefix(12)` sobre a lista com os abertos
na frente apagava todos os fechados assim que os abertos passavam de doze: com
dezessete, a tela virava doze contadores de dívida, sem uma descoberta e sem um
abandono. É o modo de falha que o dono nomeou com as próprias palavras ("se a
tela fizer o autor se sentir devendo, a volta não passa"), chegando por um
limite de lista. `Latencia.paraTela` dá cota a cada estado: **2 devidos, o resto
de 4 em afirmados** (na ordem do tempo, o mais velho primeiro), **2 sem data,
4 descobertos** (os mais recentes) **e 2 abandonados** — teto de doze linhas, e
cada estado que existe sobrevive ao corte. A linha de resumo continua contando
TUDO: a lista é amostra, o número é inteiro.

**3. A autoria viaja junto (05r).** `Latencia.registros` descartava
`propostaPor`, então o registro anterior à 05r e a hipótese proposta pela IA
apareciam como do autor — sob uma frase que dizia "entre **você** afirmar". A
latência de uma hipótese que a IA propôs não é a latência do autor. `Registro`
leva `propostaPor` e a linha ganha a marca quando ela NÃO é do autor: "proposta
por Grok", "autoria desconhecida" para o registro antigo — as mesmas palavras
que a `TrabalhoView` já imprime. Sem marca significa do autor, e a decisão nunca
tem marca porque decisão é escrita do autor e não tem proponente. A frase de
abertura perdeu o "você": "quanto tempo passa entre afirmar uma coisa e saber
se estava certa".

**Prova da L1-B.** Suíte integral no iPhone 17 Pro Max de teste, 06/09/2026:
`✔ Test run with 792 tests in 131 suites passed after 6.525 seconds.` /
`** TEST SUCCEEDED **`. `LatenciaTests`: 13 testes. Na tela, com o estado que a
revisão usou para derrubar (origem selada + dezessete abertos + autoria perdida,
`MODO=b python3 ferramentas/orca/semear-latencia.py`):
`ferramentas/orca/l1b-selo-nao-vaza.png` — a hipótese do trabalho de origem
trancada é a MAIS VELHA de todas e não aparece em lugar nenhum; e
`l1b-quatro-estados-e-autoria.png` — com dezoito em aberto, as doze linhas
trazem afirmado, devido, descoberto (com data e sem data) e abandonado, e as
duas primeiras dizem "autoria desconhecida" e "proposta por Grok". A decisão
trancada e respondida não entra na contagem: o resumo diz 4 descobertas, não 5.
`maestro/latencia.yaml` ganhou `assertNotVisible: "SEGREDO SELADO.*"`.

**O ida-e-volta pelo app**, que a revisão pediu e tinha razão:
`maestro/latencia-ida-e-volta.yaml` cria a hipótese PELA TELA do Trabalho,
avalia PELA TELA e a encontra no Perfil como "descoberto · levou menos de um
dia", sem nenhuma marca de autoria alheia
(`ferramentas/orca/l1b-ida-e-volta-pelo-app.png`). Isso fecha a circularidade de
o semeador e o leitor terem sido escritos pela mesma mão: o ciclo está provado
pelo app. A SÉRIE de meses continua dependendo da semeadura, e a série real do
dono só existe no aparelho dele.

**Ainda fora na L1-B:** a barra do mês continua normalizada pelo pior mês da
série, sem escala fixa — duas capturas de meses diferentes não são comparáveis
entre si. É decisão do dono (pista fixa ou nenhuma barra) e não foi tomada aqui.

### A volta L1-C — a barra sai, ficam as palavras

**Por que não há barra.** Ela não mentia: o número em dias estava escrito ao
lado, e não havia meta, cor nem seta. Mas a escala era a série, não a duração —
**o pior mês da série é sempre 100 %**. Um mês com mediana de 300 dias enchia
97,6 % da pista e um mês com mediana de 1 dia encheria igual, porque a barra
codificava POSIÇÃO NA SÉRIE ao lado de um número ABSOLUTO. O relance e a leitura
discordavam, e num painel cujo contrato inteiro é "nunca vira placar" a barra era
o elemento mais parecido com um placar da tela. **A única escala honesta seria
absoluta, e uma escala absoluta de dias não cabe na largura nem informa**: a
latência real vai de horas a anos, então ou a pista tem um teto arbitrário (que
é meta disfarçada) ou os meses curtos viram fios de 1 px. As palavras já eram
honestas e já estavam lá — "julho de 2026 · 21 dias · 3 descobertas" —, então
tirar foi entrega, não recusa. Decisão do dono (DIRETRIZ §6), não do
implementador.

**O que ficou no lugar: o espaço.** Sem barra, o que separa um mês do outro é o
vão, e vão fixo quebra em AX5 — a linha do mês passa a ocupar três linhas e um
espaço de 8 pt some dentro da própria entrelinha, colando os três meses num
bloco só. O vão entre meses vira `@ScaledMetric(relativeTo: .footnote)`, e o vão
do grupo até os registros carrega o mesmo valor **somado** ao ritmo da seção,
para que a fronteira do grupo seja sempre maior que a distância interna (a
inversão de proximidade que a barra escondia).

**Prova da L1-C.** Suíte integral no iPhone 17 Pro Max de teste (6033B043),
06/09/2026: `✔ Test run with 792 tests in 131 suites passed after 9.267
seconds.` / `** TEST SUCCEEDED **`. Na tela, com a semeadura de três meses
(`MODO=a`): `ferramentas/orca/l1c-sem-barra-large.png` — julho 21 dias, agosto
4 dias e setembro 49 dias em três linhas de palavras, sem barra, e a série ainda
lida como série; `l1c-sem-barra-ax5.png` — em AX5 cada mês quebra em três linhas
e continua separado do vizinho e do primeiro registro. `xcrun simctl io
screenshot`, não a captura do maestro.

**Fora — e é volta própria, não conserto desta.** A L1-B fechou a rota da nota
selada para ABANDONADO ("trancar uma nota nunca foi abandonar a decisão") e com
isso deixou a Decisão **sem nenhuma porta para `abandonado`**: hipótese chega lá
pelo Trabalho encerrado, decisão não chega de jeito nenhum. A consequência é a
conflação INVERTIDA — a decisão que o autor nunca vai conferir fica DEVIDA para
sempre, e o único jeito de tirá-la da tela é trancar a nota, que é exatamente o
gesto que a L1-B declarou não ser abandono. Falta o gesto de "não vou conferir
esta": um ato explícito do autor sobre a decisão (não sobre a nota), que a
levasse a ABANDONADO e a tirasse da dívida sem selar nada. Não foi implementado
aqui de propósito — inventar o gesto pede campo novo ou releitura do "espero", e
esta volta é de subtração. Fica nomeado, com o modo de falha medido: uma tela
que existe para não fazer o autor se sentir devendo tem hoje um estado que só
sai pela porta errada.
## ADR 2026-09-06k — O Recordar tem um pé, um eixo e uma coluna quando a letra cresce (volta 19)

**A distância.** A auditoria V9 deu **6,2** ao Recordar (Design 5 · Movimento 5 ·
Acessibilidade 5 · Componentes 6 · Estado honesto 8 · Simplicidade 8) e disse
que a curva-zero era o que estava certo: "1 toque + escrever + 1 toque; adiar é
1 toque; curta e certa". Essa curva **não muda nesta volta**.

Metade dos defeitos que a V9 listou já tinha caído entre 05 e 06/09 e foi
**conferida na tela viva antes de tocar em qualquer linha**, não relida do
relatório:

| defeito V9 | onde caiu | como se conferiu hoje |
|---|---|---|
| `PrimarioStyle` próprio, "voltar" e RECORDAR à mão | V10-B (`1f0c8f3`) | a tela consome `CabecalhoDeFolha`, `.rotulo()`, `.buttonStyle(.primario/.discreto)`; nenhum estilo local |
| cross-fade entre irmãos (§21), durações 0,3/0,35/0,4 sem token | V8 + V10-B | tira de quadros a 30 fps de `v19-antes-movimento.mp4`: nenhum quadro com dois textos legíveis; todas as durações vêm de `Tema.Duracao` |
| "vol-tar"/"RECOR-DAR" hifenizados e pergunta cortada em AX5 | V8 (`dynamicTypeSize(...xxxLarge)`, `fixedSize`) | `v19-antes-06-ax5-escrever.png` |

**Correção da volta 19-B: esta tabela tinha uma quarta linha, e ela era falsa.**
A volta 19 escreveu que o defeito 15 da V9 — "o toast do 'hoje não' nasce em cima
de 'Trabalhar nisto' e das quatro ações" — já tinha caído em `PaginaView`
(`padding(.bottom, 88)`), e deu por prova `v19-antes-05-hoje-nao.png`. **A prova
não provava nada:** aquela captura é de uma página VAZIA, onde "Trabalhar nisto"
e a régua Analisar · Recordar · Anexar · Lente nem existem na tela. O estado que a
auditoria acusou não estava na foto. O revisor do G3 reproduziu o defeito duas
vezes com a nota escrita (`v19-rev-01-toast-tapa-a-barra.png`), e o
`padding(.bottom, 88)` está em `PaginaView.swift:303` desde `eae9a8f` (31/08),
**antes** da auditoria: nada mudou ali, nada podia ter caído.

**O defeito 15 da V9 continua ABERTO.** Dono: quem toca `Traco/Pagina/PaginaView.swift`
— o toast tem de medir a altura real da barra de ações em vez de chutar 88. A
volta 19-B parou na fronteira em vez de invadir o arquivo de outra volta.

Regra que fica para as próximas voltas por tela: **quando o defeito é "A tapa B",
a prova tem de mostrar B na tela.** Conferir a auditoria na tela viva antes de
tocar continua certo e poupou esta volta de reconsertar três coisas — mas só vale
quando a tela viva reproduz o estado que a auditoria acusou.

O que a V9 apontou e **continuava de pé**, mais três defeitos que só a tela viva
mostrou:

1. **Nenhuma ação tinha cara de ação.** "Revelar" era texto âmbar centrado no
   meio de ~1 100 px de papel vazio, com "hoje não" logo abaixo, do mesmo
   naipe; no revelar, "Voltar à página" e "cobrar antes" repetiam o par
   (`critique-affordance`; a principal não se destacava, `von-restorff-effect`).
2. **Três eixos numa tela só.** O `VStack` raiz era `.center`: conteúdo na
   margem esquerda, "serviu / não serviu" e as ações flutuando no centro
   (`law-of-continuity`).
3. **O julgamento da pergunta ocupava o segundo lugar mais visível da tela**,
   entre a pergunta e o lugar de escrever — é o ato menos importante do ritual.
4. **"DE MEMÓRIA" e "A NOTA" não partilhavam linha de base** (57 pt em `large`,
   ~280 pt em AX5): a `LazyVGrid` centra verticalmente a célula mais curta.
5. **Em AX5 o revelar insistia em duas colunas**, porque o teste era só
   `largura >= 360` — medida em pontos, cega ao corpo do texto. Com ~150 pt por
   coluna o SwiftUI **hifeniza em vez de encolher**: "obstá-culo", "MEMÓ-RIA",
   "per-gunta", a nota cortada no meio de uma letra e a ação por cima do corte
   (`v19-antes-07-ax5-revelar.png`).
6. **Em AX5 o campo do autor ficava com linha e meia**: a pergunta, com
   `fixedSize`, tomava sete linhas e a prática não cabia na tela onde ela
   acontece (`v19-antes-06-ax5-escrever.png`).
7. **§21, um objeto um driver:** a frase "Leia uma última vez — a nota vai se
   esconder." ficava ~1,2 s em opacidade cheia DEPOIS de a nota ter sumido,
   prometendo o que já tinha acontecido, e a tela ficava um quadro em branco
   antes da pergunta.
8. **A pergunta da sábia trocava embaixo do autor.** O comentário no código já
   dizia "chegou tarde… nada muda embaixo dele"; o código não fazia isso — o
   vídeo pegou o enunciado sendo substituído ~4 s depois, com o autor escrevendo.

### Decisão

- **Um pé, um só, para escrever e para revelar** (`rodape`): fio no topo — daí
  para baixo é controle, não texto (`law-of-common-region`) —, a ação principal
  como `Pilula(forma: .larga, selecionada:)`, o único objeto escuro da folha, e
  as saídas honestas ("hoje não" / "pular"; "cobrar antes") em meta abaixo dela.
  Centrar DENTRO do pé é decisão; centrar no meio do papel era eixo quebrado.
  **Nada de componente novo:** a cápsula larga já existia em `Traco/Componentes`.
- Desabilitada, a `Pilula` fica sem fundo; o pé desenha um contorno de 0,5 para
  a ação bloqueada não voltar a ser texto solto. É a única dívida local, e é uma
  linha.
- **`VStack(alignment: .leading)` na raiz.** Um eixo.
- **"serviu / não serviu" desce para depois do campo**, e continua em TODO corpo
  de texto: esconder o julgamento de quem usa letra grande seria tirar poder de
  quem já tem menos.
- **A pergunta cede altura, nunca legibilidade.** `ViewThatFits`: cabe inteira,
  encosta e o campo começa logo abaixo; não cabe, a MESMA pergunta rola dentro de
  metade do vão. O campo tem piso de três alvos. `fixedSize` fica nos dois ramos
  — é o que impede o SwiftUI de hifenizar em vez de encolher.
  **Corrigido na volta 19-B (M1 do G3):** a metade era TETO e virou COTA. O
  `.frame(maxHeight: geo.size.height / 2)` estava do lado de FORA do
  `ViewThatFits` e cobrava a metade inteira mesmo com a pergunta em duas linhas —
  em `large`, o caso comum, abriam ~198 pt de papel morto e o autor passava a
  escrever no meio da folha (caret a 46,2 % da altura, contra 23,6 % antes da
  volta: a volta comprou AX5 e vendeu `large`). O teto desceu para dentro do ramo
  que rola, que é o único que precisa dele. Medido de novo na tela viva em
  `large`: **caret a 22,0 %** — o vão morto sumiu e ficou abaixo do original
  (`ferramentas/orca/v19b-01-escrever-sem-vao-morto.png`).
  A máscara de gradiente do ramo que rola **saiu** (B1): ela apagava a última
  linha também depois de já se ter rolado até o fim, então quem chegava ao fim da
  pergunta via a última linha desmaiada para sempre. Nenhuma outra `ScrollView`
  desta base mascara a borda; a do `ler`, na mesma tela, não mascara.
- **`RecordarView.comparaLadoALado(largura:tamanho:)`**: lado a lado exige folha
  larga E corpo de texto normal. Regra nomeada e testada fora da tela (lição da
  F4), não um `if` no meio do `body`. `GridItem(alignment: .topLeading)` põe os
  dois rótulos na mesma linha de base.
- **A instrução sai no MESMO driver da nota** (`opacity(escondendo ? 0 : 1)`).
- **A pergunta da sábia que chega depois da primeira letra não entra.** Trocar o
  enunciado no meio da prova é mudar a prova. Na volta 19-B a regra vira
  `RecordarView.aceitaPergunta(jaTem:memoria:)`, nomeada e testada fora da tela
  como o `comparaLadoALado` (M4 do G3: era o comportamento novo mais importante
  da volta e o único sem teste). Espaço em branco não conta como escrita — um
  toque no campo não pode fechar a porta da pergunta. E a guarda passou a valer
  também ANTES de pedir: com `.task(id: memoriaVazia)` a primeira letra cancela a
  chamada em voo em vez de só descartar a resposta quando ela chega, senão, com
  conta da sábia, a pergunta tardia era paga e jogada fora (B3 do G3).

### O que isto NÃO muda

A curva-zero: 1 toque para abrir + escrever + 1 toque em Revelar; "hoje não" e
"pular" seguem em 1 toque; "serviu/não serviu" segue opcional e em 1 toque. A
escada, o silêncio do §12 (sem placar) e o "O QUE NÃO VOLTOU" ficam como estão.

### Evidência

`ferramentas/orca/v19-antes-*.png` e `v19-depois-*.png` (sete estados cada, em
`large` e AX5, percorridos pelo MESMO roteiro); `v19-antes-movimento.mp4`,
`v19-depois-movimento.mp4` e `v19-depois-movimento-reduzido.mp4`. A prova do §21
é a tira de quadros a 30 fps: a instrução e a nota apagam juntas, o papel fica
limpo e só então a pergunta amanhece — **nenhum quadro com dois textos
legíveis**, com e sem Reduzir Movimento. Build sem aviso e suíte verde
(782 testes, 131 suítes) em 06/09/2026, no iPhone 17 Pro (teste 4)
A1DF082C; `content_size`, `appearance` e `ReduceMotionEnabled` conferidos de
volta em `large` / `light` / `0`. **Volta 19-B:** build sem aviso e
`✔ Test run with 786 tests in 132 suites passed after 7.506 seconds` /
`** TEST SUCCEEDED **` no mesmo A1DF082C (os +4 testes e a +1 suíte são a regra
da pergunta tardia, M4).

**As seis fases do `design-router` e os quatro itens da `curva-zero`** estão em
`ferramentas/orca/relatorio-v19b-recordar.md`, escritas contra a tela — A2 e M5
do G3. A volta 19 as cumpriu e não as escreveu; a ESTEIRA recusa no G4 a volta
visual sem as fases citadas no relato, mesmo com o código certo.

**Limites.** Sem VoiceOver ligado (exige humano) e sem aparelho real. A pergunta
da sábia muda a cada abertura, então as capturas de `escrever` não são
comparáveis palavra a palavra; o que se compara nelas é o layout.

**Limite retirado (M2 do G3).** Esta ADR dizia que "O QUE NÃO VOLTOU" não podia
ser capturado porque "exige conta da sábia, que este simulador não tem". **Era
desculpa, não limite, e o motivo dado era falso:** `Sabia.disponivel` é
`ContaGrok.ligada || noAparelho`, e a sábia de bordo está de pé no simulador — é
ela que gerou as perguntas visíveis em `v19-antes-02` e `v19-depois-02`, na mesma
página desta ADR. A própria evidência da volta contradizia o limite declarado ao
lado dela. O revisor capturou o estado em quatro minutos, sem conta nenhuma:
`ferramentas/orca/v19-rev-03-revelar-large-nao-voltou.png`.

**Afirmação retirada (A3 do G3).** Esta ADR dizia que a `Pilula` desabilitada
"continua em `tintaMorta`: legível como bloqueada". **1,53:1 não sustenta a
palavra "legível".** Medido: `Tema.tintaMorta` #C7C7CC sobre `Tema.fundo` #F4F4F2
dá **1,53:1** — a ação principal caiu de 6,32:1 para pior que 1:6 do mínimo, e a
saída "hoje não" (6,73:1) ficou quatro vezes mais legível que o caminho. É o
`von-restorff-effect` invertido, e no estado em que o Recordar SEMPRE abre: a
memória vazia é o primeiro que o autor vê, todo dia, no ritual mais repetido do
app. **Continua ABERTO**, e a causa não é do Recordar: `Pilula.swift:52`
(`if !ativa { return Tema.tintaMorta }`) mais o fundo `.clear` da linha 57 valem
para TODOS os chamadores — a `Pilula` não tem estado desabilitado para ninguém.
O contorno de 0,5 que esta volta acrescentou é remendo num chamador só. Dono:
quem toca `Traco/Componentes`. A volta 19-B parou na fronteira em vez de forkar
o desenho do componente dentro de uma tela.

**A exceção de líquido-positivo (M3 do G3).** A ADR 05v pede que cada volta por
tela seja líquido-negativa, e esta fechou em +218/−88. O motivo, escrito porque a
regra não pode ficar calada: o que entrou de caro foi **regra nomeada e testada
fora da tela** — `comparaLadoALado(largura:tamanho:)` e, na 19-B,
`aceitaPergunta(jaTem:memoria:)` — que é a lição da F4 cumprida, e o `rodape(...)`
é troca, não adição: substitui dois pés duplicados por um, e a duplicação era
metade do defeito de affordance. A parte que o revisor recusou como ainda não
paga era o `GeometryReader`/`ViewThatFits`, porque cobrava 198 pt de papel morto
em `large`; com o M1 fechado e medido na tela, ela entrega os dois corpos em vez
de trocar um pelo outro. A 19-B ainda devolveu linhas: a máscara de gradiente
saiu inteira (B1).
### 06i-E — A CONFISSÃO CURTA, e o buraco que era de AMOSTRA (volta A-6)

**Uma linha de código, e ela veio de fora.** Quem achou foi o revisor da volta
M3, medindo a guarda contra o catálogo de 28 métodos, e a prova é a tela dele
(`m3-reg3-01-confissao-curta-vestida.png`, no branch
`Vitorepf/volta-m3-colagem`): **"Não devia ter reagido assim com ele." — 36
caracteres — chegava VESTIDA de Exame da noite.**

**A causa, e por que ela é arbitrária.** `não devia ter` morava na **família 5**
(a omissão, que só dispara ACIMA do teto de 120) e não na **família 4** (o ato,
que vale em qualquer tamanho). No mesmo tamanho e com o mesmo ato de fala:

| a frase | a família | abaixo do teto |
|---|---|---|
| "Fui grosso com ele hoje." | 4 | calada ✓ |
| "Perdi a paciência com ele hoje." | 4 | calada ✓ |
| "Não devia ter reagido assim com ele." | **5** | **vestida de Exame da noite** ✗ |

As três são confissão de conduta, que é o que a 06h existe para proteger.
`engoli`, `fiquei calad` e `deixei passar` continuam na 5 porque são omissão de
verdade — curtas, elas nomeiam uma conversa e a Coluna da esquerda serve
("Fiquei calada quando perguntaram quem tinha feito", uma das seis legítimas).
`não devia ter` não nomeia conversa nenhuma: nomeia o que o autor fez. **A
decisão:** ele muda para a família 4, e a família 4 passa a se chamar pelo que
sempre foi — **confissão de conduta**, não só "o que eu fiz A ALGUÉM".

**O buraco maior era de AMOSTRA, não de léxico** — e é o item que impede a
próxima cegueira desta classe. *(Corrigido pela volta P1 em 08/09: a causa
escrita aqui era falsa. Dizia-se que "as 57 protegidas carregavam um rabo de
~140 caracteres e quase toda sonda ficava ACIMA do teto". Medido contra a
implementação real: **46 das 57 já estavam ABAIXO do teto**. O rabo de 140 é da
régua de ALCANCE — `todoRamoDeRegexAlcancaOSeuMetodo` —, não das protegidas.)*
A causa verdadeira é **CONTAMINAÇÃO**: das 57, 17 tocam a família 4 e 11 dessas
são curtas, mas a única curta que carregava o token do defeito —
"Não devia ter feito isso, senti muito." (38 caracteres) — é presa pela família
**1a** por causa de `senti`, antes de a 4 ou a 5 opinarem. Toda sonda curta com
o token trazia junto uma palavra de outra família, e foi por isso que quatro
voltas de régua (06i, 06i-B, 06i-C, 06i-D) passaram por cima da assimetria sem
vê-la. O conserto que isso pede não é sonda curta: é sonda curta **exclusiva**.
`EscritaPessoalTests.curtasPorFamilia` fecha isso com **uma sonda por família
ABAIXO do teto**, cada uma com a porta que a levaria vestida — sem a porta a
sonda não mede nada:

| família | a sonda (chars) | a porta que a levaria |
|---|---|---|
| 1a sentimento | "Hoje eu fiz besteira e chorei escondido no carro." (49) | Exame da noite |
| 1b dupla vida | "Toda vez que abro o chat eu fico ansioso pra caramba." (53) | Se–então |
| 2 juízo sobre si | "Percebi que eu não presto pra ninguém." (38) | Nota permanente |
| 3 não aguento | "Hoje eu preciso trabalhar e não durmo desde terça." (50) | Meu dia |
| 4 confissão | "Não devia ter reagido assim com ele." (36) | Exame da noite |
| 4 confissão | "Fui grosso com o meu irmão hoje." (32) | Exame da noite |
| 5 omissão + companhia | "Foi pesado e eu fiquei calada." (30) | Coluna da esquerda |

`cadaFamiliaTemUmaSondaAbaixoDoTeto` cobra as cinco famílias contra o mapa de
léxicos: **família sem sonda curta é teste vermelho**. Desde a volta P1 ela
cobra também a **EXCLUSIVIDADE** — nenhuma outra família pode reconhecer a
sonda —, que é a propriedade que teria pego este defeito e que até então existia
por sorte do texto (seis das sete sondas saíram exclusivas sem que nada o
exigisse). A da família 5 é a companhia por definição (a omissão sozinha
continua sem disparar abaixo do teto, ADR 06i): a 1b entra DECLARADA na própria
linha da sonda, à vista da régua, não escondida nela.

**A frase da 06h que era falsa abaixo do teto, corrigida.** A 06h escreveu o
custo como "a guarda fecha 14 de 287 ramos (4,9%) **para TEXTO LONGO**" e a
06i repetiu o enquadramento. **Não era verdade nos dois lados do teto:** dos 11
ramos do Exame, 7 já fechavam em QUALQUER tamanho (`me arrependi` pela família
1, `fui injusto|grosso|duro demais|ríspido` e `perdi a paciência|cabeça` pela
4); só os quatro de `não devia ter (feito|reagido|agido|tratado)` ficavam
abertos abaixo de 120 — que é exatamente o defeito. **Como fica, medido:**

| ramos | fechados |
|---|---|
| 3 da Coluna da esquerda (`engoli`, `fiquei calado`, `deixei passar`) | só ACIMA do teto |
| 11 dos 17 ramos do Exame da noite — os de confissão | em QUALQUER tamanho (era 7 desses 11) |

E o Exame **continua alcançável abaixo do teto** pelo primeiro ramo ("exame da
noite", "passei o dia em revista") e por "hoje eu fiz|reagi|tratei" — que é a
frase verdadeira, agora dos dois lados do teto.

*(Corrigido pela volta P1: esta lista trazia também "olhando o dia de hoje", e a
porta era MORTA em qualquer tamanho. `Meu dia` tem `\bo dia de hoje\b` no
roteamento e vem antes no catálogo, então toda nota com essa frase cai no Meu
dia e nunca no Exame — o desvio estava registrado desde a ADR 06e em
`todoRamoDeRegexAlcancaOSeuMetodo`, e a versão anterior desta ADR listava só os
dois primeiros, certos. A P1 apagou o ramo do `Metodos.json` em vez de o
descrever: ramo que nunca roteia é promessa que a ficha do método não cumpre, e
apagá-lo tirou um desvio congelado da régua de alcance, que passou de 18 para
17. O Exame fica com 16 ramos: 11 calados pela guarda, 5 vivos. Também se
corrigiu o rótulo "os 11 ramos do Exame": pela mesma expansão, o método tinha
17 ramos e 11 é o subconjunto de confissão.)*

**Volta:** melhorar. **O que a IA sabe:** nada de novo — a guarda continua sem
modelo, no aparelho. **Prova:** a régua nova medida VERMELHA antes do conserto,
com `não devia ter` de volta à família 5 — `✘ confissão curta vestida de
exameDaNoite: «Não devia ter reagido assim com ele.»` em
`cadaFamiliaTemUmaSondaAbaixoDoTeto` e em `asDuasReguasValemAoMesmoTempo`
(`✘ Test run with 15 tests in 1 suite failed after 0.210 seconds with 4
issues.`). Depois, no iPhone 17 Pro (teste 2) `B91C8DEF`: `✔ Test run with 15
tests in 1 suite passed after 0.209 seconds.` nas quatro réguas
(**64 protegidas + 13 com gancho + 6 legítimas + 58 de trabalho**) e
`✔ Test run with 780 tests in 130 suites passed after 7.102 seconds.` /
`** TEST SUCCEEDED **` na suíte inteira. **Fora:** `não devia ter` agora cala
também a confissão de conduta sobre coisa ("não devia ter aceitado esse prazo").
**O preço, medido pela volta P1 no catálogo de 28 e com controle negativo** (o
token de volta na família 5, nada mais trocado): das seis notas de trabalho que
o revisor escreveu com o token, **6 de 6 perdem a forma** — `classeDeReferencia`,
`primeirosPrincipios`, `cincoPorques`, `argumento`, `vistoNaoVisto` e `destilar`
viram silêncio. Na mesma medida, os ramos do Exame que chegam ao método abaixo
do teto caem de **9 de 17 para 5 de 17**, e nenhum muda de lado com o teto (eram
4 que mudavam). Foi testada a saída estreita — cobrar só os quatro verbos do
próprio Exame — e ela é PIOR: devolve as notas de trabalho e abre três buracos
novos pela Coluna da esquerda (`não devia ter dito|falado|respondido`). O token
largo é escolha, não descuido. Isso é assumido pela assimetria de sempre — calar custa um toque, vestir
carimba quatro campos; o literal continua sendo `não devia ter` com acento, e
quem escreve "nao devia ter" não é alcançado (o mesmo resíduo de `fiquei calad`
e companhia); e as sondas curtas são minhas e do revisor, não de uso real —
elas provam alcance, não representatividade.

## ADR 2026-09-07a — Qualidade efetiva da IA: contratos e prova em curso

O pedido vigente exige ajuda utilizável, fiel às restrições e fundamentada,
com avaliação >=9 por caso e dimensão. O contrato e a matriz integral estão
em [QUALIDADE-IA.md](QUALIDADE-IA.md). Testes de tipos, transporte, guardas e
persistência não certificam a utilidade semântica. O objetivo permanece aberto.

**Produção e prática.** Combinar com trecho delimitado prepara o exercício e
produz o restante delegado; o enunciado e a divisão entram inteiros no pedido
da entrega, que deve reservar a contribuição da pessoa. Só o sucesso das duas
partes retorna uma versão. `Artefato.parteDelegada?` preserva a parte mostrada
separadamente quando o exercício está em Praticar; `conteudo` contém ambas
para leitura integral e Markdown. Campos ausentes em documentos antigos
continuam `nil`. Mudar apoio, hipótese ou trecho cancela a preparação em voo,
inclusive antes de uma segunda chamada. Trocar o apoio para Delegar não
esconde o exercício já guardado. A qualidade dessa divisão ainda precisa ser
medida em saídas reais, inclusive para impedir resposta-alvo na parte delegada.

**Provedor e feedback.** Preparação, conferência de tentativa e revisão usam
JSON Schema no protocolo Grok, além da validação de domínio. Essas operações
não descem silenciosamente ao modelo do aparelho: as provas históricas 5–6
não demonstraram capacidade suficiente dele. Feedback v2 seleciona IDs de
linhas em um array JSON compacto; o app resolve o texto original, preservando
CRLF e recusando referências inventadas, repetidas, fora de ordem ou com lacunas.
O formato persistido das citações continua o mesmo. Revisão assistida v2 não
confirma atendimento sem citar conteúdo do artefato. Resposta incompleta não
vira entrega, e a falha não afirma que o provedor deixou de ler algo enviado.
Estas regras não provam que um critério é observável nem que o julgamento é
correto; esses casos continuam obrigatórios na avaliação semântica.

**Regras locais.** Conferência v2 exige cada duração pedida, além da soma e
quantidade; números fora de capacidade não derrubam o app nem desaparecem da
soma. A gramática continua limitada e não é aprovação de qualidade. Vestir
preserva cercas e separadores originais e reaproveita estrutura local útil
antes de pedir rótulos para prosa pendente. Citações de calibragem e Padrões
não são cortadas após validação. Recordar preserva decimais e abreviaturas ao
segmentar as frases. O aviso de texto pronto distingue pedido direto nesta
página de relato/citação, sem reinstalar a proibição global de delegar.

**Evidência.** A base viva de 07/09 teve três falhas de conteúdo/duração no
roteiro espanhol e três respostas sobre notas sem fonte. Reforçar o prompt
da consulta não corrigiu a atribuição em outras três execuções: o contrato de
fontes está em revisão. Relatórios e JSONL completos ficam em `prova/qualidade-ia-*`.
A bateria selecionada de 14:16 UTC passou 137 testes no iPhone 17 Pro (teste 2),
com modelos desligados pela suíte. Esse resultado cobre aquele candidato e
não os incrementos posteriores nem a semântica dos provedores. Validação
remota aguarda conta Grok nesse simulador; não se presume acesso nem se copiam
credenciais. O Perfil deixa explícita a dependência.

## ADR 2026-09-08a — Retomada com ação e retorno compreensíveis

Ajustar uma entrega ou um exercício deve levar ao executor o contexto da
ação, seu estado atribuído, o material utilizado e os relatos pertinentes.
Preparar prática também pode ler tentativas anteriores e feedback atribuído
para adaptar o próximo exercício; isso não autoriza resolver a nova tentativa.
Pedidos anteriores concluídos contextualizam restrições; o pedido vigente
prevalece. Nenhum relato marca execução ou aprendizagem automaticamente.
Histórico excedente tem omissão explícita; o núcleo do pedido não é truncado.
Na interface, relatos identificam a ação e a versão; a retomada oferece acesso
ao próximo ato e ao retorno sem exigir reconstruir o documento.

Bootstrap e placement emulados: visão, SPEC, EVOLUCAO e código local; não há
artisan nem o documento Atlas nesta árvore. Donos: Trabalho (domínio, contexto
e interface), Analise/AvaliacaoIA (provas vivas), TracoTests (regressões).
Esta decisão não certifica qualidade de provedor nem realização humana.

## ADR 2026-09-07b — Quem responde cada operação: a tabela, medida

**A distância.** Não existia um lugar que decidisse provedor por operação. Eram cinco políticas soltas: a escada Grok → aparelho da sábia (`Sabia.chamarComProveniencia`), a escada própria do Trabalho com duas montagens (`MotorTrabalho.produzirEntrega`), três `contaLigada` (preparar exercício, conferir tentativa, revisar), os três degraus da classificação escritos na `Sessao`, e o domínio só de bordo. E o modelo do aparelho seguia em OITO rotas onde a medição de 07/09 (`prova/qualidade-ia-avaliacao-base.md`, `prova/qualidade-ia-q5-avaliacao-base.md`, provas 4 a 6) diz que ele não serve: produzir reprovado 3 de 3; conferir do Recordar confirmando 3 de 3 um ponto explicitamente contradito, e o veredito vira sinal gravado; ecos sem retorno 6 de 6; calibragem vazia 6 de 6 com o positivo perdido; Padrões 3 de 3 e 2 de 3; a pergunta do Recordar revelando a resposta. Em todas, a falha era SILÊNCIO na tela: o autor não distinguia "não há ecos" de "ninguém respondeu".

O dono pediu, em 07/09: implementar e sobretudo ENTENDER quando usar Apple Intelligence e quando usar o Grok, porque "tem muita coisa que o Apple Intelligence não é bom e não tem capacidade". O modelo do aparelho tem 3 bilhões de parâmetros e uma janela de 4.096 tokens compartilhada entre instruções, pedido e resposta; a Apple o descreve para resumir, extrair e classificar, e diz que não serve a conhecimento de mundo nem a raciocínio avançado. O modelo de nuvem privada (32K, raciocínio, sem conta) é do iOS 27 e não existe no SDK 26.5 deste projeto.

**A decisão.** `Traco/Analise/Politica.swift` é a tabela única: para cada uma das 16 operações da sonda `AvaliacaoIA`, uma regra (`soGrok`, `grokDepoisBordo`, `soBordo`) e o PORQUÊ, datado, com o arquivo da prova. A regra nasce da medição (DIRETRIZ §5: medir, não torcer), e mudar de provedor é mudar a tabela e a prova junto.

- **Só Grok** (o aparelho foi medido e não serviu): produzir, preparar exercício, conferir tentativa, revisar, conferir o que voltou, ecos, calibragem, Padrões, a pergunta do Recordar. Sem conta, NINGUÉM responde e a tela diz — `Politica.semProvedor` — em vez de descer calada a um resultado pior. A falha de rede do Grok também não desce.
- **Grok, depois o aparelho** (provou ou ainda não reprovou; pergunta e resposta curtas cabem na janela): responder, instigar, contrapor, responder nas Notas (fatos certos 3 de 3, fonte em revisão pela 07a), vestir (a forma local decide antes) e classificar (3 de 3 com esquema tipado; as regex arbitram por último, 04c/06h).
- **Só o aparelho**: o domínio da nota, rótulo fechado com esquema tipado.

A classe que o aparelho serve é uma: escolher entre rótulos fechados com esquema tipado sobre entrada curta. A classe que ele não serve são duas: gerar texto longo fiel a restrições, e julgar com citação literal. É esse o entendimento, e é ele que a tabela codifica.

A escada da sábia, o `conferir`, o `responderNasNotas`, o `produzirEntrega` e o `PadroesRemoto` passam a consultar a tabela: `Politica.provedor(op)` diz quem pode responder agora e `Politica.desceAoAparelho(op)` diz se a falha do Grok desce. O caminho do aparelho nessas rotas continua no código, GUARDADO pela tabela, para o dia em que uma medição o reabrir — não é código morto descrevendo contrato falso (a lição da A2), é ramo fechado por dado.

**A superfície** (a lei do motor sem superfície): o Perfil ganha, no cartão da conta, duas linhas — o que o aparelho faz sem conta e o que só faz com a conta Grok, com "medido em 07/09: nessas, o modelo do aparelho não serviu". As três seções que calavam ganham a linha do estado (`LinhaDeEstado`, `.semConta`) no lugar da seção ausente: "O QUE NÃO VOLTOU" no Recordar, "TALVEZ SE LIGUEM" na Rede, "Sobre o seu juízo" nos Padrões. A mensagem do Trabalho sem provedor vem da tabela.

**O teto passa a ser medido.** Desde o iOS 26.4 o modelo conta tokens (`SystemLanguageModel.tokenCount(for:)`, `contextSize`). `Sabia.noAparelho` mantém os 3.500 caracteres como pré-corte da montagem, mas o portão real é pedido + instruções + 1.024 tokens de resposta reservados ≤ `contextSize`; sem espaço para a resposta, cala. `maximumResponseTokens` fixa a reserva.

**O que esta ADR não prova.** Nenhuma operação tem medição com Grok: a conta não existe em nenhum simulador (login iniciado no iPhone 17 Pro de teste em 07/09, à espera do dono). A tabela decide onde o aparelho NÃO entra; se o Grok serve, é a próxima medição pela mesma sonda. `responder`, `instigar` e `contrapor` seguem sem medição em nenhum provedor. 5 testes em `PoliticaTests`; suíte 826/134 em 07/09/2026.

## ADR 2026-09-08b — Raciocínio explícito e medição do provedor

A base viva de 08/09 (`prova/cinco-itens.md`) encontrou falhas semânticas no
Grok em prática e revisão apesar do schema válido. Produção, preparação de
prática, feedback e revisão passam a solicitar raciocínio `medium`; demais
chamadas preservam `none`. O modelo explícito é `grok-4.3`, em lugar do alias
aposentado `grok-4-fast-non-reasoning`. A [migração oficial da xAI](https://docs.x.ai/developers/migration/may-15-retirement)
descreve o redirecionamento do alias para 4.3 sem raciocínio. A aceitação pela
conta e a qualidade são medidas no app, não inferidas dessa documentação.

A sonda Debug registra modelo solicitado/respondido, esforço, status HTTP e
desfecho de transporte/conteúdo, sem credenciais ou corpos de erro. As saídas
semânticas continuam completas no JSONL. Não existe aprovação automática por
raciocínio ativado; a revisão independente e a jornada continuam obrigatórias.
Mudança de ações ou evidências cancela preparação em voo, pois ela ainda não
leu o novo retorno. O pedido cancelado permanece disponível para retomada.

### ADR08c — conferência conserva restrições ao adaptar (08/09/2026)

A jornada com conta conectada expôs dois falsos alarmes locais: a apresentação
“três blocos de cinco minutos” contava como um quarto bloco, e o pedido genérico
“adapte aos relatos” perdia tempo/idiomas anteriormente pedidos. Regras v3 excluem
resumos compatíveis anteriores à distribuição, sem excluir blocos adicionais
posteriores. É uma gramática limitada, não medição da duração praticada.

Produção, prática, conferência local e revisão assistida compartilham a seleção
de instruções anteriores concluídas da mesma intenção, somente antes do pedido
lido, recentes primeiro. A restrição explícita vigente prevalece. As conferências
preservam o trecho literal como instrução, incluindo histórico; revisão que não
cabe inteira na janela fica indisponível. Registros v2 anteriores permanecem
históricos, sem reescrita. A sonda usa o mesmo contexto da interface.

Na preparação de prática, o candidato passa a raciocínio `high`, limite de 90 s,
pois `medium` ainda omitiu fala pedida e gerou tradução incorreta nas variantes.
Sem gravação limita avaliação, não elimina uma prática oral solicitada. Adaptação
precisa mudar apoio ou atividade diante da dificuldade; repetir o enunciado não
prova ajuste útil. Este registro descreve o candidato, não aprovação semântica.

### ADR08d — modelo por rota de Trabalho e limites da prova (08/09/2026)

As medições de `grok-4.3` com raciocínio, prompt curto e segunda leitura continuaram
falhando em preparação e adaptação. A segunda leitura foi só experimento da sonda;
não foi acrescentada ao produto. A listagem autenticada `/v1/models` confirmou
`grok-4.6` disponível na conta. O candidato o usa explicitamente em produzir,
preparar exercício, conferir tentativa e revisão assistida. As demais rotas
mantêm o modelo configurado anterior. O cache distingue modelo, esforço e pedido.

A observação de feedback e revisão é em português. Reconhecer um critério textual
atendido não é aprovação global nem certificação da pessoa. `inconclusivo` exige
lacuna de evidência real; incompletude não torna errada uma tradução presente que
está correta. A preparação usa um contrato mais curto de tarefa, apoio, exemplo e
critérios; o pedido explícito governa assunto do exemplo e atividades obrigatórias.

A sonda Debug também pode listar apenas IDs de modelos e registrar a contagem de
tokens de raciocínio devolvida pela API. Não guarda credenciais nem raciocínio.
Troca de modelo não é prova de qualidade: matrizes, denominadores e retornos
anteriores permanecem em `prova/cinco-itens*`, e o novo candidato exige leitura
integral das respostas e jornada com persistência antes de ser considerado pronto.

## ADR 2026-09-08e — O portão do movimento, e três dívidas de documento pagas (volta P1)

**A dívida 7 da limpeza de 07/09, e por que ela é a mais estrutural.** Na volta
12 a classe do cross-fade voltou SEIS vezes, com TRÊS causas distintas. O juiz
do re-G4 nomeou a causa comum: **não existe portão** que impeça escrever uma
curva do SwiftUI em literal sem passar por `Tema`.
Quem escreve a curva no ponto de uso escolhe sozinho a CLASSE de movimento, e é
a classe que decide o comportamento sob "Reduzir movimento" (ADR 05y), lei que
mora em `Tema` num lugar só. Sem portão, cada tela recomeça a decisão.

**A decisão: um teste de varredura com a dívida CONGELADA, não um lint.**
`TracoTests/PortaoDoMovimentoTests` lê o TEXTO dos fontes de `Traco/` e
`TracoWidget/`, tira comentário e miolo de string, e conta por arquivo quantas
vezes ele escreve **curva ou duração LITERAL fora de `Tema`** (curva nomeada do
SwiftUI, `Animation.`, `repeatForever`, duração/atraso/mola em número cru).
`Traco/Tema.swift` é o único isento.

**O que o portão NÃO conta, e por quê (correção do G3, 08/09).** A primeira
versão contava também `withAnimation(` e a curva passada DENTRO de uma chamada a
`Tema.…(…)` / `CalendarioTema.…(…)`. Isso congelou 76 ocorrências em 19
arquivos — e o revisor do G3 mediu o que elas eram: **69 das 76 estavam em linha
que já cita `Tema.`**, e as outras 7 idem por variável. Era a **forma que esta
ADR manda escrever**: `Tema.movimento(_ classe:, _ normal: Animation, reduzido:)`
exige uma `Animation` no ponto de chamada. O portão ficava vermelho para quem
fizesse a coisa certa, e a lista congelada era inalcançável por construção.
A varredura passa a apagar o miolo das chamadas a `Tema.`/`CalendarioTema.`
antes de contar a curva — mas NÃO apaga número cru lá dentro, porque
`Tema.movimento(.opacidade, .easeOut(duration: 0.25), reduzido:)` continua sendo
a duração decidida na view, e `Tema.Duracao.*` existe para isso.

**Medido depois do conserto: a dívida é ZERO.** Nenhum fonte de `Traco/` ou
`TracoWidget/` escreve curva ou duração literal fora de `Tema` hoje; as 38
chamadas de `withAnimation(` do repositório passam todas por `Tema.*` ou
`CalendarioTema.morph`. A lista congelada `faltosos` nasce **vazia**, e é uma
notícia boa: o produto já roteia o movimento por `Tema`, e o portão existe para
que a PRÓXIMA curva literal não entre. Não há nada a migrar.

**Descer nunca é vermelho.** A guarda é `hoje > congelado`, não `hoje !=
congelado`: quem migrar uma tela um dia não pode precisar editar este teste para
não ficar vermelho. Se um arquivo entrar na lista por uma volta, o número desce
no commit da migração e a linha sai quando zera.

**Prova de que ele falha de verdade.** Verde no repositório de hoje; vermelho
com três plantas ao mesmo tempo — um arquivo NOVO fora do `project.pbxproj`
(`Traco/Componentes/ProvaPortaoG3.swift: 2 hoje, 0 congelado ← SUBIU`) e uma
curva literal num arquivo existente
(`Traco/Padroes/PadroesView.swift: 2 hoje, 0 congelado ← SUBIU`) — enquanto a
forma PRESCRITA (`Tema.movimento(.opacidade, .easeOut(duration: Tema.Duracao.media),
reduzido:)`, em uma e em várias linhas), um comentário e uma string com curva
dentro ficaram de fora da conta. E com a dívida congelada em 2 num arquivo já
migrado, `hoje 0 / congelado 2` fica **verde**. As plantas foram removidas.
Como a lista nasce vazia, o teste ficaria verde se a varredura parasse de
enxergar: `aVarreduraAindaEnxerga` é o contra-veneno — quatro sondas sintéticas,
duas que TÊM de acusar e duas que NÃO podem.

**Fora, dito:** a varredura é sobre texto, não sobre a árvore do compilador.
Vale para o que se lê num fonte; não persegue a curva que atravessa uma
`Animation` guardada numa variável, nem string de várias linhas, nem parêntese
desbalanceado dentro de string dentro de chamada a `Tema.` — os três erram para
o lado de NÃO acusar. Congelar número por arquivo é grosso de propósito: obriga
a olhar a linha nova, e não julga se a linha existente está certa.

**As três dívidas de documento (itens 5 e 6 do RUMO)** foram pagas nas ADRs
onde elas moram — 06i-E corrigida em quatro pontos (a causa, que era
contaminação e não rabo; a régua que passa a cobrar exclusividade; a porta morta
`olhando o dia de hoje`; e os dois números medidos), e a `aplicabilidade` do
`exameDaNoite` no `Metodos.json` reescrita. A ficha dizia ao autor "serve para o
fim de um dia em que você fez algo que não quer repetir" — exatamente a matéria
que a guarda da 06h se recusa a levar ao método. Passa a dizer a verdade: o
método se abre pelo nome, e quando o texto é confissão a nota fica do autor.
*(Copy revista no G3, 08/09, depois de fotografada: saiu o `(ADR 2026-09-06h)`,
que era a única citação de ADR nas 28 fichas; a frase volta a uma pessoa só — o
autor, como as outras 27 —, e as aspas passam a ser as tipográficas do app.
De 385 para 282 caracteres.)*

**A porta morta: apagada, não descrita.** `olhando o dia de hoje` sai do
roteamento do `exameDaNoite`. `Meu dia` tem `\bo dia de hoje\b` e vem antes no
catálogo: a frase nunca chegava ao Exame, em nenhum tamanho — o desvio estava
congelado em `todoRamoDeRegexAlcancaOSeuMetodo` desde a ADR 06e. Descrever a
porta morta a manteria como promessa que a ficha não cumpre; apagá-la tirou um
desvio da lista de conhecidos (18 → 17) e não muda roteamento nenhum. O Exame
fica com 16 ramos: 11 calados pela guarda, 5 vivos.

**Uma armadilha fechada de lambuja.** `EscritaPessoalTests.novos` é uma cópia
congelada das sete regex da M3, e desde a colagem de 07/09 é o bundle que manda
(o `comOsNovos` virou no-op: `Catalogo.recarregar` recusa id repetido). Cópia
que envelhece em silêncio faz a régua medir a M3 e não o app —
`osSeteCongeladosBatemComOBundle` compara ramo a ramo. Ela acusou esta própria
volta na primeira corrida, que é a prova de que precisava existir.

**Volta:** melhorar para multiplicar mais depois (eixo 4, diminuir
complexidade). **O que a IA sabe:** nada de novo. **Prova:**
`✔ Test run with 889 tests in 144 suites passed after 11.769 seconds.` +
`** TEST SUCCEEDED **` e `** BUILD SUCCEEDED **` com 0 aviso, no iPhone 17 Pro
(teste 4) `A1DF082C`, sob `com-trava.sh`. As quatro réguas protegidas (64
protegidas, 13 com gancho, 6 legítimas, 72 de trabalho) verdes, nenhuma mudou de
lado. Sem maestro: com três simuladores ligados ele lê a hierarquia do vizinho.

## ADR 2026-09-08f — O encaixe cola no pé: o fantasma do `.sheet`, o aviso e a cápsula desligada (volta V12-B)

**A distância.** Três dívidas da limpeza de 07/09, todas na Página, todas com a
mesma raiz de layout ou o mesmo esquecimento de contraste.

1. **O fantasma do `.sheet`** (A5 do re-G4 da V12): ao tocar "Abrir os campos",
   o cartão da forma vestida aparecia em DUAS geometrias no mesmo gesto — a
   assinatura da classe A1 —, e o defeito era idêntico com e sem Reduzir
   Movimento, logo não era a lei do movimento.
2. **O aviso** (`toast`) nascia longe da barra, no meio do papel — sobre o texto
   do autor. A revisão da V19 tinha achado o `padding(.bottom, 88)` chutado; a
   V12 já o tinha apagado ao mudar o aviso para dentro do encaixe, e o número
   não foi substituído por outro número: foi substituído por um vão.
3. **A `Pilula` desabilitada** devolvia `tintaMorta` (#C7C7CC) — **1,53:1**
   sobre o papel — para TODOS os chamadores (A3 da revisão da V19).

**Correção da V12-E (08/09, à noite):** o que esta ADR chama de "fantasma do
`.sheet`" fechou só em parte — o vão e o salto de 176 pt caíram, mas o par
legível ficou (~100 ms sem Reduzir Movimento, ~125 ms com, medidos pelo G4
final em quadros nativos, `g4f-fantasma-*`); a frase "nenhum par legível" abaixo
e na 05y era falsa. O que a V12-E mudou e o que ela mediu está na seção
**"A invariante da escrita visível (V12-E)"**, no fim desta ADR.

**A causa dos dois primeiros é uma só, e não é o `.sheet`.** `CadernoView` dá
ao encaixe `.frame(maxHeight: tetoDoEncaixe)` — sem alinhamento. Sem alinhamento
o conteúdo fica **centrado** numa caixa cuja altura é o teto, e o teto cresce
334 pt quando o teclado desce. Consequência medida em `large`, com o cartão da
forma vestida: **86,7 pt de vão** entre o pé do cartão e o fio da régua
(cartão 284,3 → 393,3 pt; régua 480,0 pt), e um **salto de ~176 pt** do cartão
no mesmo quadro em que a folha subia — o teclado a descer dobrava o teto e o
centro da caixa mudava de lugar. O `.sheet` não pintava fantasma nenhum: ele
só revelava um encaixe que flutuava.

**A decisão.**

- O encaixe **cola no pé**: `.frame(maxHeight: tetoDoEncaixe, alignment: .bottom)`.
  O aviso e o cartão viajam COM o teclado, um relógio só, e a distância até a
  barra passa a ser a soma dos paddings do próprio ocupante — **12,7 pt**
  medidos (cartão 358,3 → 467,3 pt; régua 480,0 pt), não um número escolhido.
  Nenhuma constante entrou no lugar do 88: quem mede é o layout.
- `PaginaView.acimaDoPe` passa a ser um `VStack(spacing: 0)` explícito. Ele
  chega ao `CadernoView` dentro de um `AnyView`; apagado o tipo, o `TupleView`
  deixa de ser achatado pela pilha de baixo e os ocupantes espalhavam-se pela
  caixa. A pilha explícita fecha isso.
- **`Pilula` desabilitada continua legível**: a tinta é `tintaFraca` (#68686C) —
  **5,04:1** no papel, **4,65:1** na névoa, **4,52:1** no chip, **5,55:1** no
  branco, ≥ 4,5:1 em todo fundo onde uma cápsula pousa. O que diz "desligado"
  passa a ser o preenchimento que sai, e a **cápsula sobrevive** por uma hairline
  `Tema.linha`. A tinta sai do `body` (`Pilula.tinta(ativa:cheia:forma:)`) e tem
  portão em `PilulaContrasteTests`. O contorno à mão que a `RecordarView` tinha
  no chamador foi apagado (medido: a hairline era desenhada duas vezes, RGB 211
  contra os 227 de uma linha só).

**O que esta ADR não muda.** Nenhuma curva, duração ou `withAnimation` novo: a
lista congelada do portão do movimento só desce. O `.sheet` continua a ser
`.sheet`; a folha dos campos continua a nascer inteira (04u).

**Prova** (iPhone 17 Pro Max `6033B043`, `TRACO_SEM_MODELO=1`, tudo por
`xcrun simctl io` preso ao UDID, quadros nativos por `ffmpeg`; sem maestro,
porque havia quatro simuladores ligados): `ferramentas/orca/v12b-pagina.md`.
Suíte: 890 testes em 144 suítes, verde.

**As quatro medidas que faltavam (V12-C, 08/09).** O G3 independente (GPT 5.6
Terra) confirmou a causa, o contraste e o crédito, e reprovou a PROVA em quatro
dimensões — não o código. As medidas, coladas em
`ferramentas/orca/v12c-medidas.md`:

- **Curva-zero, em toques.** Roteiro Página → cartão vestido → "Abrir os
  campos", contado nos dois builds (`499623c` e este), no mesmo aparelho:
  `large` **1 toque antes, 1 toque depois**; AX5 **2 toques antes, 2 toques
  depois** (o cartão vira menu "•••" e "Abrir os campos" mora dentro). Empate,
  e é o que se esperava: a volta moveu geometria, não controles.
- **VoiceOver.** O simulador não roda o VoiceOver; a prova é a árvore de
  acessibilidade viva (`orca emulator ax`, que lê os mesmos elementos, rótulos
  e traços que o leitor lê). `Pilula` desabilitada ("Recordar" na Página,
  "Conferir o hábito em 7 dias" na forma) expõe `enabled = false` — o leitor
  anuncia "esmaecido", não botão comum — com o rótulo inteiro. Em AX5
  vestido, todo elemento tem rótulo e a ordem posicional é topbar → papel e
  campos → cartão → ações; o VoiceOver em si não roda no simulador, e isso
  fica dito como limite do instrumento.
- **Performance.** O Instruments não mede hitch no simulador ("Hitches is not
  supported on this platform"; "The SwiftUI instrument is not supported on the
  Simulator") e o Time Profiler pendura sem fim neste aparelho. O trace
  equivalente é `CadernoHitchesTests`: um `CADisplayLink` dentro do processo
  conta quadros atrasados enquanto o teste digita 1232 caracteres no
  `TextEditor` real e rola o `ScrollView` real três vezes. Antes e depois:
  **0 quadros perdidos atribuíveis** (1750 quadros de digitação, 252 de
  rolagem; o ruído de 0–5 quadros oscila igual nos dois builds).
- **O que a medida achou, e o conserto.** O mesmo teste imprime o inset
  inferior do papel: com o teclado de pé e o encaixe VAZIO, a base media
  192 pt e a V12-B **746 pt**. Era o papel coberto: `.frame(maxHeight:
  tetoDoEncaixe)` é flexível e enche o teto que o `.safeAreaInset` propõe, e
  o `VStack` explícito desta ADR fez a caixa existir mesmo sem ocupante —
  opaca, cobria o texto do autor a partir da terceira linha
  (`v12c-digitado-v12b-coberto.png`). O `alignment: .bottom` tratava o
  sintoma. **A rede não pode expandir:** `.fixedSize(horizontal: false,
  vertical: true)` depois do frame devolve à caixa a altura do ocupante; o
  teto segue como limite, o cartão fica colado ao pé por construção, e o
  inset volta a 192 pt (`v12c-digitado-depois.png`).
- **Complexidade — exceção concedida.** O código de app fecha em **+36 linhas
  líquidas** (`git diff 499623c --numstat -- Traco/`: +99/−63; com `-w`,
  +51/−15 = +36): +45 menos a passada de corte (dois wrappers de uma linha na
  `Pilula` inlinados, dois comentários que repetiam esta ADR encurtados, −11)
  mais o conserto acima (+2). A regra líquido-negativa da migração para `Componentes` **não é
  atendida, e fica excepcionada nesta volta pelo orquestrador (Claude Opus 5,
  08/09)**, pela régua da ESTEIRA e não por simpatia: o saldo compra **um
  estado que não existia** — a `Pilula` desabilitada legível, que estava a
  1,53:1 para TODOS os chamadores — e **um portão que impede a regressão**
  (`PilulaContrasteTests`). Isto é lacuna nomeada, que é o que a regra pede
  para admitir crescimento. Não se inventou refatoração para caçar o zero:
  trocar dívida de tamanho por dívida de clareza seria pior.

**A letra e o quadro longo (V12-D, 08/09).** Esta ADR nasceu como `08c`, letra
que já era de `main` (a conferência que conserva restrições ao adaptar); passa
a **`08f`** em SPEC, EVOLUCAO, relatórios e nos dois comentários de código que
a citam. E o quadro longo que a V12-C viu em 3 de 6 rodadas de rolagem
(92–176 ms) tinha uma hipótese — o aviso da análise a cair no deslize — e
hipótese não fecha dimensão. `CadernoHitchesTests` passou a ler, **a cada
quadro**, o inset inferior do papel (a altura do encaixe) e o offset da
rolagem, a imprimir cada quadro longo com o que mudou nele e a cronometrar a
chamada de rolar. Em **3 de 3** rodadas do protocolo antigo o quadro longo
(131–176 ms) caiu a +0,13–0,18 s da primeira descida com o encaixe parado em
**192 → 192 pt** e a chamada em **< 1 ms**: **não era o aviso** — sob teste
ele nem entra (o Grok cala quando `emTeste`, e nem cartão nem "lendo…" mudaram
o encaixe em 3 s medidos). Medida também a espera, o mesmo quadro apareceu a
+0,15 s **dela** — e as duas fases tinham a mesma coisa logo antes: a captura
do próprio teste (`drawHierarchy` da janela + PNG de 1,3 MB), que cronometrada
custa **127–162 ms na main thread**. Era o instrumento a medir-se a si mesmo.
Com a captura fora de toda janela medida, **6 de 6** rodadas fecham com **0
quadros perdidos** na espera (1080 quadros), na primeira descida (247) e na
rolagem em regime (1516); a digitação segue com o ruído de 0–1 quadro de
45–54 ms. Nenhuma linha de app mudou por isto, e nada vai ao RUMO: não há
custo a declarar. Linhas de 21 rodadas em `ferramentas/orca/v12d-hitch-linhas.txt`;
relato `v12d-letra-e-quadro.md`.

### A invariante da escrita visível (V12-E, 08/09)

**A distância.** O G4 final recusou a volta pela segunda vez com dois achados:
**A2**, o autor escreve às cegas assim que o texto passa da altura do papel —
em AX5 com o encaixe vazio e em `large` com o cartão, **0 pixels de caret em 11
amostras**, porque o frame do papel corria POR BAIXO do encaixe (`Página` até
0,667 em AX5, 77 pt dentro do cartão em `large`) e o `TextEditor` julgava o caret
visível dentro de um frame que o pé e o cartão cobriam; e **A1**, o fantasma de
"Abrir os campos" continuava vivo (~100 ms sem RM, ~125 ms com), com o papel a
refluir ATRAVESSANDO o cartão enquanto o teclado descia. A segunda recusa abriu
consulta ao conselho (`ferramentas/orca/consulta-v12-invariante.md`), e a decisão
do orquestrador é o contrato desta seção.

**A invariante, com estas palavras:** *em cada quadro apresentado enquanto a
Página recebe escrita, a linha visual ativa inteira e o retângulo do caret
pertencem à área livre do papel; nenhuma outra superfície pode desenhar nessa
área.* Protege a última linha digitada, inclusive vazia; o piscar do caret não
suspende a proteção.

**A decisão.**

- **A lei mora no contêiner.** `CadernoView.body` deixa de pendurar o encaixe
  num `.safeAreaInset` — que deixava o `ScrollView` do papel correr por baixo
  dele — e passa a ser uma pilha de dois irmãos, **papel e encaixe, sem pixel em
  comum**: o papel recebe o que sobra, o encaixe (aviso, cartão, "lendo…", régua,
  ações) fica abaixo, com o mesmo teto e o mesmo piso de antes. Nada do papel
  pode desenhar sob o encaixe em quadro nenhum, por construção; um tipo novo com
  `CGRect` não resolveria, porque um ancestral ainda poderia ignorá-lo.
- **O papel rola de verdade até o caret.** `EscritaVisivel.seguirCaret` (em
  `Traco/Caderno`) corre quando o texto muda, quando o foco muda e quando a
  janela do `ScrollView` muda (teclado, cartão, aviso, pé — lido por
  `onScrollGeometryChange`, depois do layout); acha o editor focado, mede o
  caret, e põe o offset MÍNIMO que traz a linha inteira (caret mais a folga entre
  linhas) para dentro da área visível. Só enquanto há foco: com o teclado
  recolhido o autor pode estar a reler qualquer parte. Detalhes que custaram
  medida: o `ScrollView` do SwiftUI ignora `scrollRectToVisible` (o offset é
  posto à mão), e a rolagem corre por `RunLoop.main.perform`, não pela fila
  principal do GCD — um runloop aninhado (o de um teste hospedado) não esvazia a
  fila, e o seguidor só correria depois de o teste acabar. O SwiftUI segue o
  caret sozinho em parte dos casos (73 de 75 amostras sem o seguidor, medido),
  mas deixa a linha ~10 pt sob o pé e não reage ao cartão a chegar; o seguidor
  garante a linha inteira em todos.
- **Se falta espaço, o aparato cede antes da escrita:** o teto do encaixe e o
  piso do papel (05y) continuam a lei; só recortar o papel segue reprovado.
- **O teste geométrico entra na suíte, hospedado:** `EscritaVisivelTests` monta
  a Página REAL do app hospedeiro (a `Sessao` viva é publicada por um gancho só
  de DEBUG em `PaginaView`), espera o editor focado e o teclado de software,
  digita mais do que cabe no papel — no fim e no meio — e, a cada inserção, mede
  na mesma coordenada da janela: **E** (a linha do caret pelo layout do TextKit
  2, mais o caret), **P** (o recorte do `ScrollView` do papel e de todo ancestral
  que recorta, sem o teclado) e **O** (toda camada À FRENTE do editor que toque a
  linha — pela árvore de `CALayer`, porque o SwiftUI desenha texto e cor sem
  `UIView`). Em `large` e AX5 (por `traitOverrides` na janela), com o encaixe
  vazio, o cartão e o aviso. O teste NÃO rola o papel: quem rola é o app. Verde
  no candidato: **AX5 31 de 31 amostras, `large` 44 de 44**, teclado de software
  real nos dois. Vermelho com as duas plantas: uma camada intrusa sobre as
  últimas linhas do papel (**59 amostras reprovadas**, "CALayer 0,360 440×120 |
  CGDrawingLayer") e uma superfície do encaixe desenhada 120 pt para cima sobre
  o papel (**59 reprovadas**, "CALayer 0,280 440×120"); plantas removidas.
- **Limite do instrumento, escrito:** sob `xcodebuild test` o teclado de
  software nasce fora da tela e o hospedeiro do SwiftUI não desvia dele; o teste
  o levanta pelo UIKit (soltar e pedir o foco de novo) e repõe o desvio por
  `additionalSafeAreaInsets` — a mesma coisa, pela porta do UIKit — conferindo
  que o papel ficou acima do teclado antes de medir. Rodado sozinho, o teclado
  real subiu nos dois tamanhos; dentro da suíte integral (892 testes, 146
  suítes, verde) ele ficou fora da tela e a altura foi reservada com a etiqueta
  "EMULADO" na linha do relato. A suíte inteira corre no mesmo processo, e
  outra suíte pode deixar o app noutra camada (`CalendarioTrabalhoTests` posta
  `abrirCompromisso`): o teste volta à Página e exige papel limpo antes de medir.
- **A1, a parte decidida por corte.** A pilha sozinha NÃO bastou, e os quadros
  nativos disseram por quê (`v12e-antes-abrir-*`): no toque em "Abrir os
  campos" o teclado desce, o `UIScrollView` do papel recebe o frame FINAL de
  imediato e o desenho do SwiftUI (cartão, pé, régua) desce animado — por ~100
  ms, sem e com RM, os rótulos dos campos (conteúdo do papel) ficavam legíveis
  entre a linha do cartão e "Trabalhar nisto". A causa concreta é o encaixe
  continuar em cena enquanto a folha sobe. Agora `PaginaView.abrirCampos` tira
  o encaixe INTEIRO — cartão, pé e régua — numa transação sem animação e só
  depois põe a folha a subir; ao descer a folha, o encaixe volta por corte
  (`folhaEmCena`). A régua também passa a entrar e sair por corte fora da
  transação em que o foco muda (`reguaEmCena`). O contrato temporal do
  conselho — cada pixel reservado a uma superfície textual tem um único dono em
  todo quadro — fica atendido porque, do toque até a folha cobrir a tela, a
  única superfície na faixa é o papel. A prova é **amostrada por quadros
  nativos** (`v12e-abrir-sem-rm.mp4`, `v12e-abrir-com-rm.mp4`, uma tomada por
  modo), e o número está no relato; **não é universal**. O oráculo de pixels
  sobre a composição nativa é volta própria e vai para o RUMO: custa
  instrumentação de renderização e não certifica "nenhum quadro possível".

**O que esta seção não muda.** Nenhuma curva, duração ou `withAnimation` novo.
`Tema.swift` intacto. O `.sheet` continua `.sheet`. **Custo assumido:** ao
abrir, o encaixe some por corte e o papel fica só, nu, por ~6 quadros (45–90
ms, medido) até a folha subir; ao voltar, reaparece por corte atrás da folha
ainda de pé.

**O condutor da prova de tela.** O helper compartilhado do `orca emulator`
relança (ou derruba) o app da frente ao anexar — provado por bissecção, e com
três voltas a disputá-lo ele apagou o texto digitado e derrubou o app duas
vezes. A prova de tela passou a ser conduzida por um alvo XCUITest
(`TracoUITests`, esquema próprio, fora da suíte integral): toques e teclado
reais pelo XCTest, `-UIPreferredContentSizeCategoryName` para AX5, e
`xcrun simctl io <UDID>` de fora, sincronizado por arquivos-sinal.

**Prova** (iPhone 17 Pro Max `6033B043`, `TRACO_SEM_MODELO=1`, teclado de
software — "Connect Hardware Keyboard" desligado para o UDID e restaurado —,
tudo por `xcrun simctl io` preso ao UDID; direção por `orca emulator` sob
`com-trava.sh`, sem maestro e sem mouse): `ferramentas/orca/v12e-escrita-visivel.md`.

### O teste do A1 passa pelo caminho do A1 (V12-F, 08/09)

O re-G3 da V12-E apanhou o `testLargeComCartao` a passar VERDE sem cartão:
o alvo que devia provar o fim do fantasma de "Abrir os campos" aceitava o
estado sem cartão como saída normal e nunca tocava no botão — verde que não
visitou o lugar do defeito, quarta vez no dia. **Regra que fica:** num teste
de prova de tela, o estado de partida é PRÉ-CONDIÇÃO que falha com o motivo,
nunca um ramo aceitável. No condutor: cartão, botão "Abrir os campos" e folha
aberta são três `XCTFail` nomeados; a falha escreve `falhou.pronto` com o
motivo, e o shell de fora encerra na hora em vez de esperar 180 s por um
`gravar` que não vem (35,8 s contra 151,8 s do falso-verde). Os casos "encaixe
vazio" afirmam o contrário — o texto sem forma NÃO veste. Em AX5 o botão vive
no menu da linha do cartão e o teste o abre por lá.

**O estado do aparelho não decide a prova.** A causa do sem-cartão era
`autoAnalise = false` esquecido no contêiner do app (lido no plist do
`B91C8DEF` antes de tocar em nada). O teste passa `-autoAnalise <true/>` em
`launchArguments` — tem de ser a forma `<true/>`: no domínio de argumentos
`1`, `YES` e `true` são STRING, e o `object(forKey:) as? Bool` da `Sessao`
os ignora (provado com `UserDefaults` num binário de linha de comando; a
primeira planta com `"0"` passou verde por isso). Achado colateral: o
`xcodebuild test-without-building` trocou o contêiner de dados do app
(UUID novo, sem plist), então plantar pelo plist não chega ao app — a planta
válida é `<false/>` pelo mesmo canal.

**Prova** (iPhone 17 Pro (teste 2) `B91C8DEF`, iOS 26.5, teclado de software,
`-parallel-testing-enabled NO`, tudo sob `com-trava.sh`, capturas e filmes
por `xcrun simctl io B91C8DEF`, sem maestro, sem mouse, `C2416CBC` e
`6033B043` intocados): planta `<false/>` VERMELHA com a pré-condição nomeada e
o condutor parado (`v12f-teste-linhas.txt`, `v12f-planta-falhou.png`);
refilmagem pelo caminho certo, sem RM `v12f-abrir-sem-rm.mp4`: q26 (2,212 s)
é o último quadro com o encaixe, q27 (2,230 s) já não tem cartão, régua nem
pé, folha a partir de q35 — **0 quadros com par legível em 69**; com RM
`v12f-abrir-com-rm.mp4`: q26 (2,327 s) último com encaixe, q27 (2,350 s) sem
ele, folha a partir de q34 — **0 em 69**. Uma tomada por modo, amostrada; o
oráculo de pixels segue no RUMO. Relato: `ferramentas/orca/v12f-teste-do-a1.md`.

### O pé é rígido na pilha (V12-G, 08/09)

O re-G4 da V12-E apanhou a regressão B1: em AX5 com o cartão e o teclado de
pé, "Mais ações da nota" tinha a segunda linha sob o teclado, e o relato
anterior escrevia "inteiros" sobre uma foto que mostrava o corte. **Causa,
medida por sonda de geometria:** ao virar irmão do papel na pilha do corpo
(V12-E), o pé passou a receber uma PROPOSTA de altura, e o
`.frame(minHeight:)` do rodapé aceita qualquer proposta acima do mínimo — o
encaixe inteiro ficou flexível, e a pilha dividia o corpo A MEIO entre papel e
encaixe (200,8 pt cada, num corpo de 401,7). Dentro do encaixe o cartão
recolhido tomava 109,7 e o pé, que mede 212,7, cabia em 91,2: transbordava
60,7 pt para cima (a barra por cima da linha do cartão) e 60,7 pt para baixo
(sob o teclado). Dentro do `.safeAreaInset` a proposta era nula e o pé valia o
ideal, por acidente. **Regra que fica:** o pé do encaixe declara-se rígido
(`fixedSize` vertical); a pilha do corpo tem UM filho flexível, o papel. O
teto do cartão (05y: nunca mais que metade da sobra) segue como está.

**Custo, com número:** no iPhone 17 Pro (874 pt) em AX5 com cartão e
teclado, a sobra depois do pé é 189 pt, o teto 94,5, e a linha recolhida do
cartão pede 109,7 — perde 15 pt do topo (o recuo de 16 do cartão; a linha
fica inteira) e o papel fica com 94,5 pt, uma linha e meia de AX5. É a regra
da metade da 05y a decidir contra o cartão, não contra o texto; no Pro Max
(956 pt) cabe tudo. **Régua nova no condutor:** o topo real do teclado é o
`inputView` (barra preditiva incluída, 44 pt acima de `app.keyboards`); o
`testAX5ComCartao`/`testLargeComCartao` medem "Trabalhar nisto", "Mais ações
da nota", a barra e a régua contra ele e FALHAM se o pé entrar sob o teclado
(vermelho provado no topo `e4ea756`: "o pé entra 8 pt sob o teclado" ainda
com a régua velha; com a verdadeira eram 52,7).

**Prova** (`B91C8DEF`, teclado de software, sob `com-trava.sh`, `simctl io`):
`v12g-ax5-cartao-pe-inteiro.png` e `-rm.png` — "Mais ações da nota"
405,7–531,0, `inputView` a 539, **8 pt de ar**, sem e com RM, iguais;
`v12g-antes-ax5-cartao-pe-cortado.png` é o topo anterior. Os quatro casos do
condutor verdes (`v12g-teste-linhas.txt`), inclusive os dois "encaixe vazio",
que nunca tinham sido rodados. AX5 com RM refilmado (`v12g-ax5-abrir-com-rm.mp4`):
o encaixe corta em q38 (2,355 s) atrás do menu; de q40 a q44 (2,377–2,433 s,
~60 ms) o MENU DO SISTEMA dissolve sobre os rótulos do papel — superfície do
UIKit, não do encaixe, igual sem RM (q37–q44, ~65 ms, `v12g-ax5-abrir-sem-rm.mp4`);
a folha cobre a partir de q46. `large` continua 0 pares: sem RM q26 último com
encaixe, q27 sem, folha q35; com RM q26/q27/q34 — os mesmos números da V12-F.
Suíte integral 891/892 (1 pulado, 0 falhas) em `B91C8DEF`. Relato:
`ferramentas/orca/v12g-pe-ax5.md`.

### A última frase falsa, e a árvore mesclada (V12-H, 08/09)

"O que esta seção não muda" dizia que a folha cobre a tela nos dois instantes
do corte. Na abertura é falso — o próprio parágrafo acima diz que "do toque
até a folha cobrir a tela" só há papel — e o juiz mediu o buraco duas vezes:
**6 quadros de papel nu, 45–90 ms conforme o aparelho**. A frase agora diz o
medido. A ADR é contrato, não narrativa: quem lê "cobre" constrói por cima.
`main` (08b, 08e, 08g–08k) entrou no branch com a 08f no seu lugar
cronológico; a árvore mesclada dá build sem aviso e suíte integral
**933/933 em 152 suítes (1 pulada, 0 falhas)** em `B91C8DEF`, com
`PortaoDoMovimentoTests` verde — os 41 testes a mais são de `main`. A
evidência do G4 e dos dois re-G4 está comitada reduzida (nenhum arquivo acima
de 400 KB; vídeos com a contagem de quadros conferida igual). Relato:
`ferramentas/orca/v12h-g5.md`.

## ADR 2026-09-08g — A frase do autor não termina em reticências (volta F4-F)

**A distância.** A F4 foi mesclada em `main` sem o último portão, com quatro dívidas escritas no RUMO. A primeira, e a que abriu a volta original, é a mais dura: **em AX5, no widget pequeno e no médio, a linha do Destaque terminava em reticências** quando o rodapé "Desatualizado." entrava — `terminar o capítulo do meio antes…` no pequeno, `terminar o capítulo do meio antes de do…` no médio, com metade do cartão vazia embaixo. Fotografado de novo em 08/09 na tela viva, antes de tocar em Swift: `ferramentas/orca/f5-antes-ax5-desatualizado.png`.

**Por que três voltas não fecharam isto.** Porque a causa nunca foi a propriedade. A F4-D já tinha `minimumScaleFactor(0.6)` e `allowsTightening` nos dois lugares, e mesmo assim cortava. A causa é o **teto de linhas**: com `lineLimit(n)` a altura de que a `Text` precisa fica presa em n linhas, ela nunca excede a proposta, o SwiftUI conclui que já cabe e **corta em vez de encolher**. É literalmente a lei que a F4-D descobriu na palavra do estado ("com teto o SwiftUI prefere hifenizar a encolher") — só que ninguém a levou da palavra para a frase. Em tamanho normal o defeito não aparece porque n linhas no corpo cheio cabem na altura dada; em AX5 não cabem, e aí ele aparece. Foi por isso que a F4 fechou o caso olhando o tamanho normal.

**A decisão, em três leis.**

1. **A frase do autor não tem teto de linhas.** `FraseDoAutor` recebe a ALTURA que a face de fato lhe deu — no pequeno, tudo que sobra; no médio, um teto em pontos — e o encolhimento decide quantas linhas cabem. Quem mede é o layout. As quatro `Text` que desenhavam a linha do Destaque (casa pequena, casa média, o ramo "o vazio traz o Destaque" do Próximo e a tela bloqueada) passam a ser a mesma view: a correção mora num lugar só.
2. **O piso do encolhimento é do PAPEL, não da face** (`Encolhe`). A frase do autor desce até 35%; o rótulo — marca, estado, oferta, texto NOSSO e reescrevível — para em 60%. A 60% de um corpo de acessibilidade a frase ainda não cabe em 123 pt, e o que não cabe o SwiftUI corta. **Letra pequena é letra pequena; frase cortada é mentira.** Custo declarado: num pequeno em AX5 com frase longa, a linha do autor sai em corpo bem menor que o do sistema. É o preço de dizê-la inteira, e é o lado certo da troca.
3. **Em tamanho de acessibilidade o pequeno larga a MARCA.** O selo "TRAÇO" custa quase um quarto de um cartão de 123 pt, e a casa já escreve "Traço" na etiqueta embaixo do widget. Gastar a altura do autor para repetir o nome do app é a falta que a F4 tirou do cabeçalho ("o widget não gasta linha falando de si mesmo"), um degrau acima. Onde a frase aperta, quem sai é a marca.

**O médio, decidido e defendido (dívida 4 do RUMO).** O juiz da F4 pediu duas coisas que não cabem juntas num 4×2: três linhas de agenda e a frase do autor inteira. A conta, medida na tela e não estimada: cabeçalho com dois atalhos de 44 pt + frase de duas linhas + filete + linha de conta = a `AgendaQueCabe` não achava altura nem para UMA linha e caía em "3 compromissos por vir" — o dia do autor reduzido a um número (`f5-antes-inicio-claro.png`). A escolha não é quantas linhas, é **quem paga**: a agenda, que na tela de início só existe ali, ou dois caminhos para dentro do app, que existem no ícone, no controle Ditar, na Siri, no toque do widget pequeno e no quadro do estado vazio. **Pagam os atalhos.** O cabeçalho do médio passa a ser a marca e só ela; a agenda passa de ZERO para DUAS linhas com "+1 depois" (`f5-depois-inicio-claro.png`). Três só sem Destaque posto — e isso é aritmética de 158 pt, não escolha. A face nunca esconde o resto: o que não coube é contado (`Restantes`).

Junto, a lei do teto sai da view e ganha suíte (`LinhasDoDestaque`), como `EstadoNaFace` e `LinhasDoEstado` antes dela: a F4 escrevia `max(1, teto - 1)` dentro da view, e no médio isso dava **uma linha** para a frase do autor — era esse `if` que imprimia `…antes de do…`.

**O quadro de ofertas deixa de ler como lista de Ajustes (achado I da revisão da F4).** E lia mesmo: duas linhas de largura inteira, mesmo peso, glifo à esquerda, mesmo passo, esticadas para dividir o cartão em fatias iguais — isso é uma lista de sistema, seja qual for a tinta; e uma lista não tem ação principal. O quadro vira **frase de estado + uma ação, com uma alternativa ao lado**: a primeira em cápsula âmbar (a mesma que o autor já toca na tela bloqueada, `CapsulaLembrar` — a assinatura da casa fora do app), a segunda em texto discreto, sem glifo, no fim da mesma linha. Linha de ações, não pilha de linhas iguais; hierarquia por forma, não por ordem. Quando a linha não cabe (acessibilidade), `ViewThatFits` fica com a cápsula — sem `if` de tamanho de tipo escrito à mão. Antes e depois: `f5-antes-vazio-claro.png` e `f5-depois-vazio-claro.png`.

**O que esta ADR NÃO prova.** O modo escuro do widget não existe: `Tema.fundo` é uma cor de papel única e `Tema.swift` é da volta L2 — as capturas escuras mostram parede e dock escuros com o cartão em papel, que é o desenho vigente, não um defeito desta volta. A **Ilha mínima** não foi produzida: ela só aparece quando duas atividades disputam a Ilha, e neste simulador não há um segundo app com Live Activity (o Relógio não está instalado); o código desenha em `minimal` exatamente a mesma view de `compactLeading`, que está fotografada. **StandBy não renderiza no simulador** — trancado e girado, o aparelho segue na tela bloqueada comum, como a F4 já registrara.

Suíte 893 testes em 145 suítes, verde; build dos dois alvos sem aviso.

## ADR 2026-09-08h — A latência lê-se em dois degraus, e a lista de meses para de crescer (volta L2)

**A distância.** A volta L1 foi mesclada em main por ordem do dono com o G4
REPROVADO (`ferramentas/orca/g4-l1-design.md`: Design 8, Simplicidade 7). O juiz
confirmou o conceito — paleta silenciosa, nenhum placar, quatro estados no mesmo
cinza, nada tocável — e fechou com quatro correções pequenas, nenhuma delas
mexendo no modelo, em teste, ou no que a seção mede. Esta volta faz as quatro.

**1. Teto de doze meses, com o horizonte dito.** A lista de registros já tinha
corte por estado; a de meses era `ForEach(lista)` sem corte nenhum. Com três
meses semeados não se via; no aparelho de quem escreve há dois anos são 24
linhas, e era justamente o pedaço de onde a barra saiu na L1-C. Agora
`lista.suffix(12)`, e a copy diz o horizonte ("nos 12 últimos"), senão o corte
mentiria por omissão. Medido: com vinte meses semeados o cartão passa de
6.148 pt para 5.340 pt em AX5 (−13%).

**2. `Tema.miudo` sai de dentro do app.** O degrau de 12 pt está documentado em
`Tema.swift:75` como reservado a FORA do app (ADR 05u — a faixa compacta da Ilha
e o rodapé do widget não têm 15 pt), e a L1 foi o primeiro uso dele dentro do
app em todo o produto — logo na linha que carrega a medida. A varredura
`grep -rn "Tema.miudo" Traco` agora não devolve nada: o token voltou a existir
só para `TracoWidget`.

**3. Dois degraus, sempre no mesmo sentido.** O par da L1 era 12 pt/`tintaFraca`
em cima e 13 pt/`tintaSuave` embaixo: a linha da MEDIDA era ao mesmo tempo a
menor e a mais clara, e o registro lia-se como uma massa só em tamanho padrão.
A regra do cartão passa a ser uma só: **linha que carrega medida é
`Tema.meta` + `tintaSuave`; prosa de apoio é `.footnote` + `tintaFraca`**. Vale
para o registro, para a linha do mês e para a segunda linha do resumo; a
manchete continua `Tema.chrome` + `tinta` e o rótulo continua `Tema.label`.
Nenhuma cor nova, nenhum token novo, e os quatro estados seguem no mesmo cinza.

**4. A frase-resumo em duas linhas.** Cinco fatos colados por "·" faziam o olho
parar no que destoa — no MODO B, o "18 em aberto" — e não na duração que a seção
existe para mostrar. A medida vira manchete sozinha; a composição (sem data · em
aberto · abandonadas) desce uma linha e fica mais quieta. **Nenhum número sai**,
e a copy da série não nasce de novo na view: são duas leituras da MESMA
`Latencia.emPalavras`, uma com só os descobertos e outra com só o resto. O
identificador `latencia-resumo` fica no grupo, então os fluxos que o usam de
âncora continuam achando a seção mesmo quando um dos dois lados está vazio.

**5. `quantas == 1` não tem "tempo do meio".** Um mês com uma descoberta só
imprimia "agosto de 2026 · 5 dias · 1 descoberta" sob a legenda "o tempo do meio
entre as descobertas". Agora diz "agosto de 2026 · 1 descoberta · levou 5 dias":
mesmo número, sem estatística falsa.

**6. Copy encurtada (declarado, não pedido pelo juiz).** O parágrafo de abertura
perdeu 12 das 49 palavras e a legenda dos meses 10 das 16, sem perder nenhuma
das três promessas que o juiz creditou ("nada a preencher aqui", "hipótese sem
resposta é informação", "abandonar é resultado") nem a proveniência (hipóteses do
Trabalho, decisões com data de conferir). É o que paga parte da altura que o
degrau maior custa.

**O que a decisão custa, medido e não escondido.** Pôr a medida num degrau
legível engorda o cartão onde a série é curta: em AX5, com o estado semeado de
três meses, o cartão vai de 5.200 pt para 5.541 pt (+6,6%); no MODO B, de
5.758 pt para 6.115 pt (+6,2%). São +345 pt só da linha da medida em nove
registros. Onde a série é de verdade — vinte meses — o teto inverte o sinal:
6.148 pt → 5.340 pt (−13%). A troca é essa, e é deliberada: a linha que carrega
o número deixa de ser o menor texto do produto, e o pedaço que crescia sem fim
para de crescer.

**O que esta volta NÃO faz.** Não muda o modelo, `Decisao`, `abandonado`, nem o
que a seção mede; não extrai os nove cartões inline do `PerfilView` (dívida do
RUMO); não devolve a barra; não cria alvo, cor de juízo, meta, sequência ou
ordem que pareça ranking. Movimento: nenhum — a seção segue sendo superfície de
leitura, e a ausência é deliberada (o juiz já a aceitou no G4 da L1).

**Prova.** Suíte integral 887 testes em 143 suítes, verde no iPhone 17 Pro
`C2416CBC` em 08/09/2026; build sem aviso. Altura medida pela árvore de
acessibilidade (`orca emulator ax`), que devolve o frame de todo elemento dentro
e fora da tela — do rótulo "LATÊNCIA DA DESCOBERTA" ao rótulo "MÉTODOS" —, com o
número conferido de forma independente por varredura de capturas com OCR
(5.198 pt contra 5.200 pt no mesmo estado). Capturas antes/depois em
`ferramentas/orca/l2-*.png`; relatório em `ferramentas/orca/l2-latencia-g4.md`.

**Volta L2-B (a correção do G3, 08/09/2026).** Três coisas. (1) Esta ADR nasceu
com a letra `08b`, que é de `main`; a letra reservada à volta é `08h`, e SPEC e
EVOLUCAO passam a usá-la. (2) As capturas "depois" da primeira passada tinham a
copy de um binário intermediário ("Sai do que já está escrito…", "nos últimos 12
meses com descobertas.") — as três medidas de altura eram do binário certo (a
árvore de AX conferiu: 5.541, 6.115), mas a foto não era. Todas as capturas
`l2-depois-*.png`, as árvores `l2-ax-*-ax5.json` e as medidas foram refeitas
com o binário deste commit, nos quatro estados (A, B, vazio, vinte meses),
inclusive o vazio DEPOIS que faltava: 241 pt em `large`, 1.485 pt em AX5.
O estado de vinte meses foi semeado de novo com script próprio (duas
descobertas por mês, jan/2025→ago/2026) e por isso o número mudou: 4.992 pt em
AX5, não 5.340 — é outra semente, não outra altura; o teto de doze e a copy do
horizonte estão na captura. (3) O G3 pediu que os +341 pt da série curta em AX5
caíssem por "uma apresentação de fato compacta dos detalhes dos registros". Foi
tentado, medido e RECUSADO, e a razão está na tabela: a única apresentação mais
compacta que não esconde texto nem devolve `Tema.miudo` é o registro num fluxo
só — a medida abre a linha em `Tema.meta`/`tintaSuave` e a hipótese segue em
`.footnote`/`tintaFraca` na mesma linha. Ela recupera 180 pt dos 341 em AX5
(5.541→5.361, −3,2%) e 36 pt em `large` (886→850), porque em AX5 quase todo
registro já embrulha em quatro a seis linhas e a hipótese começa numa linha nova
de qualquer jeito (`l2-alternativa-inline-ax5-registros.png`); e em `large` ela
troca a linha "título · legenda" — a medida sozinha, a hipótese embaixo — por
uma linha de dois corpos que quebra no meio da hipótese
(`l2-alternativa-inline-large-fim.png`). Onde a altura mora em AX5, pela árvore:
o parágrafo de abertura tem 833 pt, os nove registros 3.000 pt em linhas
embrulhadas, e nenhum arranjo dos detalhes muda a conta sem cortar palavras.
Decisão: o registro fica em duas linhas; o custo de +341 pt em AX5 na série
curta é o preço de a medida ser legível, e fica declarado, não escondido. A
nota de Simplicidade que isso vale é do revisor.

**Achado que fica aberto (não é desta volta).** Em AX5, a camada do arquivo do
Perfil transborda na horizontal em algumas sessões — o cartão e a barra de abas
saem cortados dos dois lados. Reproduz igual no build de HEAD, sem esta mudança
(`l2-achado-ax5-transbordo-head.png`), e o app Ajustes no mesmo aparelho e no
mesmo tamanho de letra não transborda. É acessibilidade real e é do `Camadas` /
`RaizView`, não do cartão: fica para a volta do Perfil.

## ADR 2026-09-08i — O corte honesto: o publicador limita a projeção, a face limita a apresentação (volta F4-H)

**A distância.** A 08g prometeu "a frase do autor inteira, sempre" e comprou a promessa com encolhimento até 35%. O G4 da F4-F mediu o preço em dois fatos: com 103 caracteres em AX5 a frase saía no mesmo corpo de ~11 pt de quem não ligou acessibilidade, enquanto tudo à volta crescia 1,4× — o encolhimento comia o aumento que a pessoa pediu; e com a primeira linha de uma nota real (247 caracteres; `VozDoAutor.titulo` não tem teto) o pequeno desenhava onze linhas a ~7 pt no normal e **voltava a terminar em reticências** em AX5. O "pior caso real" de 43 caracteres da 08g não era o que o app publica. Segunda recusa da volta; o conselho (`ferramentas/orca/consulta-f4f-corte-honesto.md`) foi ouvido e esta é a decisão.

**A regra, que vale para TODA face:** *reticência é honestidade quando indica continuação realmente omitida por um limite público declarado ou pelo espaço restante depois de retirar o dispensável, preservando leitura no tamanho escolhido e acesso ao original; é falha quando encobre corte evitável, texto ilegível ou uma promessa de integralidade.* A promessa da 08g muda de "inteira, sempre" para **"trecho fiel e legível, com omissão reconhecível"** — e isso não absolve a regressão original: cortar 43 caracteres com metade do cartão vazia continua sendo corte evitável.

**As decisões.**

1. **O teto do que se publica é do PUBLICADOR, e mora na projeção.** `Superficie.Destaque.teto` (140 grafemas, marcador incluído) é aplicado em `DestaqueDoDia.projecao`, uma vez, antes da distribuição — porque `publicar` (o `superficie.json` do widget e da tela bloqueada) e `reconciliar` (o `ContentState` da Live Activity) leem a MESMA projeção. Limitar só a escrita do arquivo deixaria a Ilha com outro contrato; achado do conselho. O estado (`chaveLinha`) guarda o texto do autor inteiro; só a projeção corta. Nenhum número garante que o texto caiba — a face ainda corta o que sobrar; o teto reduz o que viaja e declara a omissão.
2. **A projeção distingue três estados** (`Destaque.inteira: Bool?` → `integridade`): trecho integral, trecho abreviado, integralidade desconhecida (instantâneo anterior a esta conta decodifica `nil`, e a face não afirma nada). A pontuação literal do autor não é metadado: uma frase que já termina em "…" dentro do teto é inteira.
3. **O teto é em grafemas** (`Character`), prefere fronteira de palavra dentro do orçamento e corta por grafema quando a palavra não cabe — sempre sinalizado. "Primeira frase" não é limite; contagem de palavras também não. Testado com bandeiras (um grafema, dois escalares), palavra de 300 letras e reticência do autor.
4. **O piso é o corpo do papel, não uma fração.** A frase mantém `Tema.chrome` (casa) e `Tema.meta` (bloqueada) na categoria corrente e reduz a QUANTIDADE de texto: `FraseDoAutor` prova `n` linhas, `n − 1`… até uma (`ViewThatFits`) no corpo cheio, sem `minimumScaleFactor`, e o que não coube termina em "…" — o corte da face, somado ao do publicador, que já vem na linha. `Encolhe.frase` (0,35) deixa de existir; `Encolhe.rotulo` (0,6) continua sendo só de rótulo. Custo declarado: em AX5 o pequeno mostra menos palavras e, com a coluna de 90 pt ao lado do círculo, o SwiftUI pode partir uma palavra em sílaba (`pen-/sando…`) — quebra tipográfica, não corte; o corte é o "…".
5. **A ordem de sacrifício, declarada como dado com suíte** (`Sacrificio.candidatos`): acima da disputa ficam legibilidade, o rodapé "Desatualizado.", a identificação do objeto, o entendimento do toque, o alvo e a recuperação. Depois cede o rótulo de caminho "Nova nota" do pequeno — que é desenho, não alvo (o G4 provou) — e só então a quantidade de frase. Para cada `n`, o candidato com rótulo vem antes do sem: o rótulo só entra quando não custa uma linha. No vazio "Nova nota" é a oferta principal e não cede (`Oferta`/`QuadroVazio`, intocados). O médio sem agenda deixa de ter teto de duas linhas (`LinhasDoDestaque.noMedio(comAgenda:)`): com o rodapé ele deixava três linhas de cartão vazias entre a frase cortada e o rodapé — corte evitável.
6. **A promessa de continuação passou a ser verdadeira.** O pequeno com Destaque abria "Nova nota" (G4). Agora o `widgetURL` dele é `traco://nota/<id>` — a rota de entidade da 05u (`Destino.nota`), que a tela já revalida por selo e acesso; o que esta ADR acrescenta é só a grafia da URL. O rótulo decorativo diz "Abrir a nota". Nota apagada ou selada cai no recado existente ("Essa nota não está disponível."), nunca numa página em branco.
7. **VoiceOver distingue trecho de integral** (`Destaque.emVoz`, também na Live Activity): um trecho é anunciado como "Trecho: … Continua no Traço."; a projeção inteira, como está; a desconhecida não afirma nada.

**As duas dívidas menores do G4.** "Recordar" saiu da casa na F4-F sem ser dito: a terceira oferta dos dois quadros nunca era desenhada e o comentário do pequeno afirmava o contrário — saiu do código e fica dito aqui: continua no app, na Siri e em `traco://recordar`. A cápsula "a mesma da tela bloqueada" não era a mesma (16/9 contra 18/38): agora as duas vestem `CapsulaViva` (18 pt de lado, 38 de altura mínima; 14/32 na Ilha); a tinta é de quem veste, por contraste (`Tema.ambar` sobre o material, `Tema.ambarTinta` sobre o papel).

**Emenda da F4-I (08/09, depois do re-G4) — as duas coisas de Componentes que o juiz nomeou.**

*As duas gramáticas do marcador: são duas, e ficam duas.* O publicador corta em fronteira de palavra (`trecho`: o último espaço que ainda guarde metade do orçamento; senão, por grafema) porque corta ANTES de qualquer layout, uma vez, para três destinos de larguras diferentes — não há linha a respeitar, só um orçamento de grafemas, e sem linha a palavra inteira é a única fronteira honesta que existe. A face corta onde o SwiftUI cortar (`para man…`, `promes…`) porque ela conhece a linha real, no corpo real, na largura real: o `lineLimit(n)` termina a n-ésima linha no último grafema que cabe e põe o marcador ali. Unificar exigiria medir o texto por fora do layout para achar a última palavra inteira da n-ésima linha e devolver ao SwiftUI um texto já cortado — reproduzir o motor de texto na face e errar onde ele acerta (hífen, `allowsTightening`, categoria de tamanho). Não se unifica. O que as duas têm em comum é o que a regra pede: o "…" é sempre o último grafema do que se vê, a omissão é reconhecível, e o omitido está a um toque (ponto 6). O que muda é só ONDE a frase para: numa palavra inteira quando quem corta não vê a linha, numa fração de palavra quando quem corta vê. A regra do corte honesto não pede fronteira de palavra; pede omissão reconhecível.

*O critério medível de "corte evitável".* "Dispensável" é classificação por face; a lista do que está acima da disputa (ponto 5) vale para o Destaque, e para a PRÓXIMA face "evitável" precisa de medida ou vira opinião. Fica esta, com as palavras do juiz do re-G4: **corte é evitável quando cabe uma linha inteira do corpo do papel no espaço livre ao lado do marcador.** Com ela o critério é teste de captura — mede-se o espaço livre abaixo da última linha e compara-se com o passo de linha do corpo — e não um adjetivo. A suíte não renderiza layout; o que ela garante é a premissa que faz o `ViewThatFits` cumprir o critério: os candidatos de `Sacrificio` descem de um em um, sem lacuna, e o primeiro que cabe é o maior que cabe — se n + 1 não coube, sobra menos de uma linha (`SacrificioTests.semLacunaEntreCandidatos`). O resto de ~26 pt do pequeno velho (re-G4, 2.2) é o exemplo: menos de um passo de 27 pt, não evitável.

*Previews por estado.* `FraseDoAutor` e `CapsulaViva` ganham preview por estado (inteira, trecho e desconhecida; a face cortando em corpo cheio; com "Desatualizado."; AX5; tela bloqueada; casa e Ilha), e o trecho do preview sai do mesmo `trecho()` do publicador. Ficam no arquivo do widget, não em `Traco/Componentes`: o alvo `TracoWidget` compila só `TracoWidget/`, `Tema.swift` e `Intents/Compartilhado` (ADR 05u), e nada no app usa as duas — mudá-las de pasta as poria a compilar no app para ninguém e abriria à extensão uma pasta que é do app. A casa de um componente é onde ele é usado.

**O que esta ADR NÃO prova.** StandBy e Ilha mínima seguem limites do instrumento (08g). O toque no widget que abre a nota foi provado na rota e no aparelho com uma nota real; o alvo do círculo do feito no pequeno continua dividido com o `widgetURL`, como antes. Modo escuro do widget continua sendo o papel único de `Tema.fundo` (volta L2).

## ADR 2026-09-08j — A causa do ajuste é dado, não inferência (volta V17)

O laço que faltava ao artefato era de **observação e versão**, não de
renderização: o Trabalho já tinha versão com origem (05i, 05s), tentativa do
autor como evidência separada (05r), ida e volta pelo arquivo com conflito e
retry (05l, 06a) e preparação que lê tentativas anteriores (08a). O que não
existia era a **causa do ajuste como dado vinculante**: `pedidoDe` a inferia por
base e intenção, e inferência não pode ser a autoridade que explica ao autor por
que o exercício dele mudou.

**Dono único: o Trabalho.** O exercício continua sendo
`DocumentoTrabalho.Artefato.pratica` e a versão seguinte nasce pela rota que já
existe — `OficinaTrabalho.gerar` → `MotorTrabalho.produzir` →
`DocumentoTrabalho.receber`. Nenhuma versão, corpus ou índice paralelo; nenhuma
tela nova; a representação segue na seção Praticar da folha do Trabalho.

**Contrato mínimo.** `Pedido.ajuste?` guarda gatilho **fechado**
(`pedidoDoAutor` ou `necessidadePercebida`), motivo escrito pelo app e
referência à evidência — mais a conferência e os critérios quando foram eles que
o sustentaram. `Artefato.pedidoID?` liga a versão à causa. `validarAjuste`
recusa vínculo quebrado, `necessidadePercebida` sem tentativa E sem leitura,
motivo vazio e critério que não pertence ao exercício daquela tentativa.
Ausência nos registros antigos significa **vínculo não registrado**: `ajuste(de:)`
devolve `nil` e ninguém reconstrói causalidade histórica. A inferência antiga
sobrevive só dentro de `pedidoDe`, e só para achar a rota de conferência da 05q.

**Nenhum estado de exercício persistido.** Produzido vem da versão guardada;
tentativa registrada vem da evidência do autor; desempenho demonstrado continua
exigindo leitura sustentada com avaliador visível. Sem `aprendido`, sem
pontuação global, sem contador de domínio, sem promoção automática de hipótese.
Reescrever o exercício não é dizer que a pessoa aprendeu, e a seção que anuncia
a mudança escreve isso na tela.

**A causa não cabe no trecho descartável.** Num ajuste, a tentativa que o
sustenta, a leitura atribuída dela, os critérios vigentes e as restrições ainda
aplicáveis sobem para a cabeça do contexto, fora do bloco que o orçamento corta.
Não cabendo na janela do provedor, o pedido fica `ajusteIndisponivel` e a folha
diz isso — nunca sai um pedaço da evidência que explica a mudança.

**A fronteira da IA está no tipo.** A saída da adaptação aceita a preparação e
`mudanca` — o que mudou — e nada mais: `additionalProperties: false`, chave a
mais derruba a resposta inteira, e não existe campo de resposta nem comando que
toque em `Evidencia`. `guardarTentativa` continua operação do autor e o campo de
tentativa da versão nova nasce vazio. `mudanca` passa pelo mesmo teto e pela
mesma prova de vazamento dos critérios. **Limite reconhecido:** validação
estrutural impede escrita na evidência, mas **não prova ausência de solução
disfarçada no enunciado** — isso é leitura semântica, como a 05r já admite.

**O ato visível é "Conferir e adaptar o exercício"**, novo e explícito, porque
"Conferir minha tentativa" já promete uma operação e uma chamada por toque
(05r). Ele lê a tentativa, guarda a leitura **antes** de pedir a versão (05s), e
só reescreve quando a leitura sustenta: conferência indisponível ou sem
divergência não gera versão e a folha diz por quê. A mesma leitura não gera duas
versões; reabrir o documento não dispara nada; não há laço em segundo plano.

**O anúncio é UMA seção no próprio documento**, escrita pelo app: a descrição da
mudança é do modelo, a origem, o motivo e os vínculos são do código — o modelo
não inventa ID nem decide qual pedido o produziu. Não repete o histórico e não
declara aprendizagem.

**A correção do dono sobre a leitura.** `ConferenciaTentativa.contestadaEm` e
`motivoDaContestacao`, pela ação "Não foi isso que eu errei". A leitura **fica**
no registro, com todos os seus resultados, e sai do `contextoDeRetorno` e do
núcleo do ajuste: a interpretação que o autor contestou não orienta mais os
ajustes seguintes.

**Defeito de superfície achado na tela viva e corrigido nesta volta:** a lista de
tentativas é filtrada pela versão vigente, então a tentativa que causou a versão
sumia da folha no instante em que passava a importar, levando junto a leitura e a
rota de contestá-la. A seção "A tentativa que gerou esta versão" a devolve, em
leitura, com o feedback e a contestação.

**Limite de instrumento, declarado.** O simulador de teste não tem conta Grok — o
aparelho que tem é de outra volta e não podia ser tocado. Os dois atos gatilhados
pela conta foram fotografados com `-ensaio-oferta-da-pratica`, um argumento de
lançamento **só em Debug** que abre a OFERTA e nada mais: não fabrica token, não
chama rede, e o que a tela mostra depois do toque continua sendo a
indisponibilidade real. É o mesmo instrumento que a 06c criou para o ditado. A
jornada foi observada num documento plantado no aparelho, não gerado pelo
provedor: esta ADR descreve o contrato e a superfície, e **não** certifica a
qualidade semântica do exercício adaptado, que continua sendo prova da frente Q.

## ADR 2026-09-08k — A garantia sai da tela e vira invariante do documento (volta V17-B)

A revisão independente da V17 passou nos sete pontos do contrato e **reprovou por
dois P1 com a mesma doença**: a garantia existia **na tela** e não no agregado. A
lição do dia é essa: **a lei tem de morar onde ninguém pode contorná-la** — outra
rota, uma importação ou uma regressão de chamador passam por cima de um `guard`
de View.

**A unicidade e a semântica da leitura passam a ser do documento.**
`OficinaTrabalho.conferirEAdaptar` impedia a repetição; `validarAjuste` só conferia
que o `conferenciaID` existia. Agora, no agregado: `necessidadePercebida` exige
critério apontado; a leitura citada tem de estar **concluída** e cada critério
citado tem de ser **divergência nela** — critério que a leitura deu por atendido
não sustenta reescrita; e o mesmo `conferenciaID` **não aparece em dois**
`Pedido.ajuste`, de modo que a N+2 da mesma leitura é recusada em `iniciarPedido`
e um documento que a trouxesse é recusado em `validar()`.

**A leitura contestada é checada no nascimento do pedido, não em `validar`.** Uma
contestação vem DEPOIS da versão que ela explica; recusar o documento inteiro por
isso apagaria a história. `iniciarPedido` recusa o ajuste novo apoiado numa
leitura contestada; a versão que já nasceu dela continua guardada e explicada.

**A troca de documento durante a edição.** Enquanto a IA prepara ou adapta, a
folha **não deixa entrar em edição** — tocar leva ao progresso em curso, como toda
ação que compete com ele (e `adaptando` entra nessa conta: entre a leitura e a
versão seguinte não existe `pedidoAtivo`, e era por essa fresta que a edição
começava). E porque guarda de tela não é invariante, `guardarVersaoHumana` passa a
aceitar a **base** que estava na tela e a recusar guardar por cima de outra: um
texto escrito sobre a versão N não é guardado como resposta à N+1. `nil` = base
não declarada (importação e registro antigo), e ninguém reconstrói o que a pessoa
estava lendo.

**A causa do pedido escrito pelo autor.** "Adaptar o próximo exercício" era o
único chamador de UI que criava `Pedido.ajuste(gatilho: .pedidoDoAutor)` — cortar
a cápsula sem mais apagaria a via do pedido explícito. Então, na ordem: primeiro
**o que o autor escreve no campo vira a causa registrada** (`pedidoDoAutor`, com o
texto dele como motivo, dentro da prática e com exercício vigente — preparar não é
ajustar), e só então a cápsula enlatada saiu. A seção Praticar volta de quatro
para três cápsulas e o anúncio da versão diz "A pedido seu." seguido do que ele
escreveu. **Nenhuma evidência é apontada**: ele escreveu um pedido, não disse a
qual tentativa responde, e deduzir isso seria inventar causalidade.

**Limite de instrumento, declarado.** O bloqueio da entrada em edição **não se
fotografa** neste aparelho: sem conta Grok, `adaptando` dura milissegundos e um
pedido ativo é interrompido na abertura do documento. Ele está provado por teste
(`editarDuranteAAdaptacaoNaoTrocaODocumentoDebaixoDaPessoa`) e por código, não por
captura. A lacuna da jornada com provedor real continua exatamente como a 08j a
declarou — é prova da frente Q.

## ADR 2026-09-08m — O resultado da ação volta ao trabalho: agendado, feito e funcionou (volta E1)

`EstadoAcao` tinha três casos e a auditoria de 07/09 achou os três **mortos**: não
havia como dizer que uma ação foi **observada**, `cancelada` era **inalcançável**
na tela, e o relato do que aconteceu **não mudava a orientação seguinte**. O
contrato desta volta é o item 5 da fila do dono: *"o resultado informado muda a
próxima orientação; agendado, feito e funcionou continuam distintos"*.

**Observar é outro eixo, não um quarto estado.** `ResultadoObservado` —
`funcionou`, `parcial`, `naoFuncionou` — mora no **relato**
(`Evidencia.resultado`), não na ação. É de propósito: executar é ato, observar é
resultado, e um existe sem o outro. A tela prova os dois: uma ação **pendente**
com "Resultado que você informou: Não funcionou", e uma **executada** sem
resultado nenhum. `observacao(de:)` devolve o último resultado informado para uma
ação; `nil` é **não observado**, nunca "deu certo por omissão".

**Fracasso e parcial são de primeira classe.** As três formas estão no mesmo
trilho de cápsulas, com o mesmo peso — a ferramenta que só aceita sucesso mente
por omissão, e o dono pediu explicitamente as tentativas parciais e os fracassos.
Informar continua **opcional**: contar o que houve sem classificar é honesto, e a
linha ao lado diz para onde isso vai ("sem ele, o relato fica como não observado —
nunca como sucesso"). Nada aqui é nota, pontuação ou "aprendeu": "funcionou" é
observação do autor, não certificação do app.

**Migração: nenhum estado velho vira resultado por releitura.** Documento gravado
antes deste contrato não tem a chave, decodifica `nil` e fica **não observado** —
inclusive o relato de uma ação marcada como `executada`. É a mesma regra que a 05r
fixou para a tentativa. E `resultado` só existe em relato: numa tentativa,
"funcionou" seria a resposta de um exercício se declarando certa, e quem lê
tentativa é a conferência (`validar()` recusa).

**`cancelada` ganha gesto.** "Cancelar esta ação" no cartão, e só sobre o que está
**pendente**: o que a pessoa marcou como realizado aconteceu, e desfazer isso
apagaria um ato. A agenda e o aviso já liam `pendente`, então cancelar sai do
calendário e cala o alarme pelas rotas que já existiam.

**A orientação seguinte muda pelo resultado, e o documento diz por quê.** Reuso do
mecanismo da 08j, e não um segundo: a causa é `Pedido.ajuste`, o vínculo é
`Artefato.pedidoID`. `GatilhoDoAjuste` ganha `resultadoInformado` — e o acréscimo
não fura a lista fechada, porque o motivo **não é inventado pelo app**: é o
resultado que a pessoa informou, citado com o relato dela. `validarAjuste` exige
que a evidência apontada exista e **traga um resultado**; `conferenciaID` e
`criterioIDs` têm de estar vazios, porque aqui não há leitura de tentativa a
citar. "Revisar com estes relatos" passa a escrever **três instruções diferentes**
— preservar o que funcionou, trabalhar só o que faltou, propor um caminho
diferente — e a tela diz de qual resultado a revisão vai partir, antes do toque.
O contexto da IA passa a distinguir os três eixos na mesma linha: *estado
registrado* · *resultado informado pela pessoa* (ou "não observado") · material.

**O que ficou de fora, e por quê.** A entrega **delegada** não recebe o
`nucleoDoAjuste` como núcleo obrigatório: ela tem duas janelas (remoto e aparelho)
e nenhuma rota de `ajusteIndisponivel`, então exigir a causa inteira ali só
produziria meia causa mandada calada. A causa chega ao pedido pela instrução (que
não se corta) e pelo `contextoDeRetorno`; a explicação ao autor vem do documento,
não do prompt. E "o que mudou" descrito pelo modelo continua exclusivo da prática,
onde o contrato de saída tem a chave `mudanca`: resumir a diferença de uma entrega
livre seria o app afirmando o que não observou. Fora da prática, a versão diz a
**origem e o motivo** guardados — `causaDaVersao` no cartão da versão.

**Limite de instrumento, declarado.** A versão nascida do relato **não se
fotografa** neste aparelho: sem conta Grok o pedido nasce com a causa, é guardado
e falha. A causa registrada foi conferida no `default.store` do App Group
(`gatilho: resultadoInformado`, `evidenciaID` do relato de fracasso, motivo com a
frase da pessoa) e a tela mostra a falha, não uma versão inventada. A jornada com
provedor real continua sendo prova da frente Q.

## ADR 2026-09-08n — Cancelar não apaga o que já foi observado (volta E1-B)

A 08m separou dois eixos — **executar** é ato, **observar** é resultado — e deixou
a invariante do cancelamento olhando **só um deles**. `cancelarAcao` exigia
`estado == .pendente`, e uma observação **não muda o estado** de propósito. Logo o
mesmo cartão que dizia *"Resultado que você informou: Funcionou"* ainda oferecia
*"Cancelar esta ação"*: dava para apagar o que a pessoa já tinha dito que
aconteceu. O G3 reproduziu na própria captura `02` da volta anterior.

É a doença que a V12 nomeou e que derrubou a V17: **a regra olha uma dimensão e o
mundo tem duas**. Separar os eixos foi decisão do dono, e ela obriga a invariante a
olhar os dois.

**A garantia é do agregado, nas duas ordens.** `podeCancelar(_:)` exige `pendente`
**e** `observacao(de:) == nil`; `cancelarAcao` passa a lê-lo. A ordem inversa é
outro caminho e por isso tem outra guarda: `registrarRelato` recusa `resultado`
numa ação **cancelada** — contar o que houve continua valendo, classificar o
resultado do que se desistiu de fazer, não. E `validar()` recusa o par
`cancelada` + evidência com resultado, para que nenhuma importação, migração ou
chamador novo grave pelas costas o estado que os dois gestos recusam. Garantia que
vive só na tela é contornável por outra rota — foi por isso que o G3 da V17
reprovou.

**Na tela, o gesto some e diz por quê.** Onde havia "Cancelar esta ação" com
resultado informado, o cartão passa a dizer: *"Esta ação não se cancela mais: você
já informou um resultado, e cancelar apagaria o que aconteceu."* Gesto que
desaparece calado parece defeito; a linha é do mesmo `Tema.meta`/`tintaSuave` das
outras linhas do cartão, sem componente novo. A ação **pendente e não observada**
continua com o gesto — provado na mesma tela, não só no teste.

**O que continua valendo.** Ação `executada` segue sem cancelamento (08m), relato
sem classificação continua entrando em qualquer estado, e o resultado observado
continua sendo do relato, nunca um quarto estado da ação.

## ADR 2026-09-08t — A lista das Notas não afirma o que não há (volta V13)

**A auditoria V9 foi conferida na tela viva antes da primeira linha**, defeito a
defeito, porque no Recordar ela já tinha envelhecido (RUMO, "parcialmente
desatualizada"). Nas Notas os quatro defeitos nomeados estavam **vivos**, e dois
dos secundários tinham caído pela metade (o menu de ordem em AX5 virou ícone na
V8; as cápsulas locais das Notas migraram para `Pilula` na V10-B, as de Versões e
Rede não). A tabela com captura por defeito está em `ferramentas/orca/v13-notas.md`.

**Quatro decisões, cada uma amarrada a um defeito confirmado:**

1. **Trabalhos é destino, e destino não se veste de link.** O texto âmbar com
   ícone sob o título era a mesma doença que o §20 tirou do rodapé e a 05f do
   topo. Vira uma **linha da lista** — ícone em `tintaSuave`, "Trabalhos" em
   `chrome`, a contagem e a seta `chevron.forward` em `tintaFraca` —, a primeira do
   arquivo, que rola com ele e some quando o autor está buscando ou filtrando
   (não é resultado). Com o arquivo vazio a linha continua, acima do vazio: é a
   porta da função, e os fluxos `maestro/*` que chegam por `abrir-trabalhos` com
   `clearState` dependem dela.
2. **A régua de chips diz que há mais — e só enquanto há.** A máscara de 28 pt
   de 31/08 (`2a3dc68`) esfumava o último chip e apagava o seguinte inteiro: a
   régua *parecia terminar* em "Especificação", que é mentira pequena (lei da
   08g: reticência que encobre corte evitável). Tirar a máscara e confiar no
   chip cortado não bastou: **no iPhone 17e a borda cai exatamente no vão entre
   dois chips** (`v13-depois-folha-1958.png`, primeira captura, antes da seta) e
   não há corte a ver. O sinal passa a ser determinístico: uma seta
   `chevron.forward` no fim da régua, sobre o fundo, que **existe enquanto a
   geometria do scroll diz que há chip omitido à direita** e some no fim
   (`onScrollGeometryChange`). É reticência honesta na definição da 08g: indica
   continuação realmente omitida. E quando o chip aceso rolou para fora da régua,
   a contagem diz por quê: **"3 notas · WOOP"**, "4 notas · Saúde".
3. **Teto é teto, não altura.** No cartão da sábia, `ScrollView { … }.frame(maxHeight:)`
   ocupa o teto inteiro mesmo com uma linha de texto — daí o vão de ~100 pt entre
   a pergunta e "a sábia não respondeu." `fixedSize(horizontal: false, vertical: true)`
   depois do `frame` devolve ao cartão a altura do conteúdo, até o teto. Vale para
   a resposta (220) e para a pergunta pendente (120). Em AX5 "Repetir pergunta"
   cortava em "Repetir pergu…": a ação quebra linha, não some.
4. **Página sem nome não vira linha em branco.** Uma nota que nasce só com o
   marcador de seção (`## `) grava (`Sessao.paginaVazia` lê o texto cru),
   `Nota.temVoz` diz sim e `tituloNaLista` devolve "": a lista afirmava uma nota
   onde não havia nada — estado desonesto. Escolhi **"não é nota"** em vez de
   **"tem nome"**: o arquivo já esconde a página sem voz da série em voo pela
   mesma razão (§8), e batizar de "Sem título" uma página em que o autor não
   escreveu nada seria o app pondo palavras na boca dele. `NotasFiltro` esconde
   a nota aberta cujo `tituloNaLista` é vazio; código sozinho continua entrando
   (tem nome, porque `Caderno.visivel` o lê). **A raiz fica nomeada e fora desta
   volta:** `Sessao.paginaVazia` e `Nota.temVoz` deviam olhar o texto visível,
   não o cru — `Traco/App` e `Traco/Modelo`, área do arquiteto.

**E dois acertos menores:** em tamanhos de acessibilidade o título da nota não
tem teto de duas linhas (cortava "Quero dormir mais cedo est…"); "Pronto" e
"Restaurar" de Versões e Ligações usam `Pilula(.acao)` em vez de três `Capsule()`
à mão — o "Pronto" passa de chip/tinta para carvão/branco, que é o "Pronto" do
sistema (`CabecalhoDeFolha`).

**O que não mudou, de propósito:** a barra de baixo (busca + cartão no
`safeAreaInset`) — a V9 não achou defeito nela e esta volta não inventa item; a
régua continua a decisão mais longa da tela (29 chips), e o conserto de verdade é
chip por capacidade, que mora no catálogo (RUMO).

**Achado novo, sem conserto aqui:** a pergunta interrompida some. `ConversaNotas`
promete "sair da tela não perde o pedido", mas `RaizView` recria `NotasView` ao
trocar de aba e o `@State` morre — perguntei, fui ao Calendário, voltei: nenhum
cartão. É estado desonesto e a saída é a conversa viver na `Sessao` (A1).

**Prova:** suíte integral no iPhone 17e `C7341E64` sob `com-trava.sh`, `-parallel-testing-enabled NO`: **948 testes em 153 suítes, 947 verdes**; o único vermelho é `EscritaVisivelTests.aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel` em AX XXXL, **pré-existente no 17e** (18 issues idênticas na árvore de `HEAD` sem este diff — geometria do caderno num aparelho de 390 pt, fora desta volta); build sem aviso. Capturas antes e depois por estado em `ferramentas/orca/v13/`.
Curva-zero do roteiro "achar uma nota da semana passada": no 17e, com as mesmas 16 notas, a nota de 02/09 exige **2 arrastos antes e 2 depois**; em repouso ela está 0,057 de tela (≈48 pt) mais perto do topo, porque a linha em branco de HOJE sumiu e a linha Trabalhos rola com o arquivo em vez de ocupar 44 pt fixos do chrome. Por palavra continua 1 toque + digitar; por filtro, 1 toque em 29 chips (o chip aceso agora se lê na contagem).
`git diff --shortstat`: código `5 files changed, 119 insertions(+), 50 deletions(-)` — **não ficou líquido-negativo**: a linha Trabalhos (+32), a seta determinística da régua (+22) e o teste da prova do vermelho (+15) pesam mais que a máscara (−7) e as três cápsulas (−12); as duas primeiras são o preço de dois defeitos vivos, e o que se pôde tirar foi tirado.

## ADR 2026-09-08o — A orientação diz de QUAL ação está falando (volta E1-C)

A 08m prometeu que **o resultado informado muda a próxima orientação**. Ela
cumpria a promessa lendo `ultimaObservacao` — o último relato com resultado do
**Trabalho inteiro** — e nunca dizia **de que ação** esse resultado veio. Com uma
ação só, funciona por coincidência. Com três ações e três resultados, o juiz do G4
fotografou o defeito (`g4-e1-09`, `g4-e1-11`): proposta *Funcionou*, orçamento *em
parte*, ensaio *Não funcionou* — e a instrução gerada mandava *"proponha um caminho
diferente"* num Trabalho cuja ação principal a pessoa disse que **funcionou**. O
botão falava em "estes relatos" (plural) e a linha num resultado (singular) sem
nome.

**A ação passa a ser nomeada nos dois textos.** `TrabalhoView.acaoObservada(_:)`
resolve o texto da ação do último resultado num lugar só; a linha da tela diz *"A
revisão vai partir do último resultado que você informou, na ação “X”: Não
funcionou."* e `orientacaoDoRelato(_:acao:)` diz à IA *"A pessoa informou que a
ação “X” NÃO FUNCIONOU…"*. Os três textos por resultado não mudaram de conteúdo —
só ganharam sujeito. O contexto já levava o resultado por ação
(`OficinaTrabalho`); o que faltava era o **pedido vigente** concordar com ele, e é
o pedido que prevalece.

**E a premissa vem antes do gesto.** A linha "A revisão vai partir…" ficava
**abaixo** do botão "Revisar com estes relatos": o VoiceOver lia relato → botão →
e só então de que resultado a revisão parte. Passa a vir antes do botão, sem
componente novo e sem mudar tinta ou fonte.

**O que fica em aberto, e é honesto dizer.** O cartão da ação continua mostrando
só o **último** resultado dela (o histórico inteiro fica em "O que aconteceu"), e
o motivo gravado em `causaDoRelato` continua dizendo "desta ação" sem nomeá-la —
ali o motivo já carrega o relato inteiro contra o teto `Limite.motivoDoAjuste`, e
nomear a ação empurraria o relato para fora. Os dois são P3 do G4, registrados,
não consertados nesta volta.

## ADR 2026-09-08s — O arranque que não abre tem de dizer, não morrer (volta A1)

`TracoApp.swift:13` era `try! DiscoTraco.abrir(emTeste:)`. O RUMO registrava a
morte no arranque desde a limpeza de 07/09, e o item 8 da fila do dono pedia
que "falhas previsíveis permitam recuperação e preservem o conteúdo".

**A recusa do disco vira estado, e a tela responde três perguntas.** O arranque
deixou o `try!`: `DiscoTraco.abrir` devolve `.aberto(container)` ou
`.recusou(erro)`, e `ArranqueFalhouView` diz **o que houve** ("o arquivo onde as
suas notas ficam neste aparelho não respondeu"), **onde está o conteúdo** (a
contagem MEDIDA dos `.md` no espelho: "1 nota está em Markdown no app Arquivos,
na pasta Traço") e **o próximo ato** ("Tentar abrir de novo", alvo de 44,0 pt
medido na árvore de AX). Se a segunda tentativa também recusa, a tela diz isso —
não promete conserto que não existe, porque o Traço não tem como reparar um
arquivo que não conseguiu ler.

**O que a leitura da radiografia de 02/09 (tag `arquivo/fix-furos-radiografia`)
mudou nesta volta, e é o achado maior que o `try!`.** A versão que estava em
`main` não morria: ela caía num contentor **em memória** e deixava o app inteiro
de pé sobre um caderno vazio, com uma frase de aviso por cima. Só que
`Corpus.escrever` **apaga do espelho em Arquivos todo `.md` que não estiver na
lista que recebe** (`Corpus.swift:440-464`, a varredura do selo), e a lista vem
do contexto.

**A forma exata do perigo, porque a forma exagerada seria falsa.** O arranque
antigo **não apagava nada sozinho**: nenhuma chamada de `Corpus.escrever` corre
só por subir, e o selo automático, encontrando zero notas naquele contentor de
emergência, não chega à varredura destrutiva. O estrago precisava de **um gesto
seguinte da pessoa dentro do caderno falso** — selar, queimar, apagar ou
importar, qualquer rota que projete o mundo. Aí sim a lista chegava vazia e o
espelho em Arquivos, que é o backup sem nuvem, era varrido. Dizer "apaga
sozinho" seria mentira, e mentira sobre um risco grave é o que autoriza
desprezá-lo: o defeito era **um gesto de distância** da destruição, com a pessoa
convencida de que estava mexendo no caderno dela. É por isso que ele se corta
pela raiz, e não por aviso. Agora **nada se abre no lugar**: sem container não há `RaizView`, sem `RaizView` nenhuma rota do selo
existe, e o espelho não é tocado. `Ferias`, `Revisoes` e as reconciliações da
Ilha também não correm — reagendar a partir de um mundo vazio calaria o que está
de pé lá fora. **Preservar vem antes de voltar a funcionar**, e nenhum caminho
de recuperação limpa, recria ou migra o que não conseguiu ler.

**O portão do `try!`**, irmão do portão do movimento da 08e e com a mesma
varredura (`codigoVisivel`, que apaga comentário e string antes de contar).
A lista congelada **nasce medida, e a medida se refaz** — o `grep` cru não serve
de prova, porque esta volta escreveu duas linhas de comentário que dizem `try!`
e o comando literal passou a contar 10. A conta que vale é a de `try!` em
código, e este comando a reproduz em qualquer checkout:

```
grep -rn 'try!' Traco/ TracoWidget/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//'
```

**9 em `main`, 8 aqui**, e as 8 linhas que ele imprime são exatamente as da
tabela congelada. O portão não usa esse filtro de uma linha: usa `codigoVisivel`,
que apaga comentário **e** string antes de contar, e chega ao mesmo 8. Julgamento
caso a caso — **infalível por construção** (`AnexoDisco`, `Indice` e
`Corpus:277`, regex de padrão literal; `ConferenciaTrabalho`, literal só
enquanto todo chamador passar literal) e **dívida real** (`FonteNotas`,
`PraticaTrabalho`, `Corpus:144` e `Sessao:599` — serialização de valor vindo de
fora). As quatro dívidas foram ao RUMO e **não se consertam aqui**: `Analise` é
da volta Q e `Trabalho` é da volta E1, as duas vivas.

**A prova do vermelho.** Um `try!` plantado em `Traco/App/TituloTela.swift`
deixou o portão vermelho — `Traco/App/TituloTela.swift: 1 hoje, 0 congelado ←
SUBIU` — e foi removido. Verde sozinho não é portão.

**A prova da tela é com o banco de verdade impedido de abrir**, não com um mock:
o `default.store` do App Group foi guardado e trocado por um diretório de mesmo
nome; o arranque recebeu `SwiftDataError(_error: …loadIssueModelContainer)` de
verdade. Depois de três arranques falhos e de um "tentar de novo" recusado, o
espelho continuava com o `.md` da nota e o `traco-corpus.md` com 2.303 bytes;
restaurado o `default.store`, a nota reapareceu na lista. Capturas em
`ferramentas/orca/a1-arranque.md`.

**O pior caso da frase do meio, fotografado.** Com o mesmo banco impedido de
abrir e o espelho **esvaziado** (`Documents/notas/` sem nenhum `.md`), a tela diz
"Não encontrei cópia em Markdown no app Arquivos. O arquivo original continua
neste aparelho, intacto — o Traço não o toca enquanto não conseguir lê-lo."
(`ferramentas/orca/a1-08-espelho-vazio.png`). É o momento em que a tela mais
poderia assustar ou mentir, e ela faz as duas coisas certas: não inventa um
backup que não existe e não deixa a pessoa achar que o original foi perdido.
Os `.md` guardados voltaram byte a byte (SHA-256 idêntico antes e depois).

**Lacuna que fica, por ordem do dono, não por limite de instrumento.** A leitura
falada do VoiceOver **não foi e não será exercitada**: comando por voz e
VoiceOver estão proibidos no Traço — o áudio de qualquer simulador sai pelas
caixas do Mac do autor. A acessibilidade desta tela se prova por árvore de AX
(cabeçalho → o que houve → onde está o conteúdo → ação → detalhe técnico) e por
captura, que é o que a lei manda. A ordem de leitura está provada; a fala, não.

## ADR 2026-09-08q — Quem responde, medido COM a conta: a quarta regra da tabela (volta Q)

*(Letra corrigida na Q-E, 08/09: esta ADR nasceu `2026-09-08k` e a letra já estava tomada em `main` pela V17-B, "A garantia sai da tela e vira invariante do documento". As mensagens de commit anteriores a esta correção ainda dizem `08k`.)*

**A distância.** A 07b decidiu onde o modelo do aparelho NÃO entra, e disse com todas as letras o que faltava: "nenhuma operação tem medição com Grok; a conta não existe em nenhum simulador". A conta passou a existir em 08/09, num aparelho só — o iPhone 17 Pro `C2416CBC`, autorizado pelo dono. Nove operações estavam em "só Grok" por PRESUNÇÃO: o aparelho tinha reprovado, e ninguém tinha medido se o Grok servia.

**A medida.** Sonda `AvaliacaoIA` pelo caminho de produção (`TRACO_AVALIAR_IA`, ADR 07a), 16 operações × 6 casos × 3 execuções em três lançamentos distintos, sem memo; fixture `prova/q-qualidade-casos.json` sha256 `29654d46…`; saídas inteiras em `prova/q-qualidade-avaliacoes.jsonl`; leitura em `ferramentas/orca/q-qualidade.md`. `contaGrokLigada: true` em todos os registros, e a corrida de fumaça devolveu a listagem autenticada de modelos. Um caso só passa se as TRÊS execuções cumprirem todos os requisitos obrigatórios; média não aprova nada.

**Qual binário, e a correção de 08/09 (achado do G3, corrigido na volta Q-B).** Esta ADR dizia "candidato `325c819`", e `325c819` **não implementa nada disto**: ele só acrescenta `ferramentas/orca/LACO.md`. O commit que carrega a decisão — a quarta regra, a sobrecarga morta apagada, a sonda exigindo `fontes`, e as quinze provas — é **`acdfcb4`**, e é ele o candidato desta ADR. Conferível hoje no aparelho do dono: o `Traco.debug.dylib` instalado do build de `acdfcb4` traz `indisponivelPorQualidade`, `medidaEm` e `conserto`, e `nm` só encontra a assinatura `responderNasNotas(pergunta:fontes:…)` — a de `contexto:` não existe mais.

E há um fato que a redação antiga escondia atrás de um hash só: **a corrida não foi de um binário, foi de dois**, e o JSONL prova qual é qual pela própria entrada dos casos.

| corridas | árvore construída | bundle conferido por sha256 | como se sabe |
|---|---|---|---|
| `05D574C2`, `D91E98DE`, `F4D24F76` — a matriz de 16 × 6 × 3 | a de `325c819` (é `main` antes da volta Q) | `Traco` `504d29d7…`, `Traco.debug.dylib` `2152892a…` | os três casos de `responderNasNotas` com `contexto` **concluíram com saída**, e só a sonda anterior aceitava `contexto` |
| `1FB24380`, `60B40CFE`, `B7A619E5` — a remedição com fontes tipadas | a que virou `acdfcb4` | o mesmo aparelho, instalado por cima | os casos `…-tipada-q` exigem `fontes`, o que só a sonda de `acdfcb4` faz |

A troca de binário no meio da volta **não contamina a matriz**: o que `acdfcb4` mudou em execução foi a sonda (passou a exigir `fontes`) e a tabela `Politica` — e a tabela é CONSEQUÊNCIA da medida, não entrada dela; nas quatro rotas de Trabalho `desceAoAparelho` já era falso na 07b, antes e depois. O que a troca custa é dito, e é isto: os hashes `504d29d7…`/`2152892a…` atestam o binário da **matriz**, não o da remedição, e nenhum dos dois é o binário que hoje serve a decisão.

**O que o SPEC tem direito de escrever, e é só isto:** neste candidato identificado, nesta data e nestas condições, cada rota atendeu N de 6 casos obrigatórios e K de 18 execuções, com leitura por dimensão; a política habilita os executores aprovados NESSE escopo e torna os demais indisponíveis com explicação e continuação. Seria mentira escrever "IA ≥ 9 sempre", "Grok aprovado nas dezesseis", "fallback equivalente" sem prova dele, ou que o autor aprendeu qualquer coisa.

**A decisão: a quarta regra.** `Politica.Regra` ganha `indisponivelPorQualidade`. A linha da tabela FICA, com operação, motivo datado e a prova; o que sai é o EXECUTOR. Ela existe porque as três regras anteriores não sabiam distinguir "falta conta" de "foi medido e não serviu" — e mandar conectar uma conta que já existe é mentira na tela. `provedor()` devolve `nil`, `desceAoAparelho()` é falso, e `semProvedor()` diz o que está indisponível, por quê em uma frase, e qual é a continuação que funciona; não pede para conectar conta e não promete guardar nada (quem guardou é que diz, depois de confirmar).

**A tabela, antes e depois.**

| operação | 07b | 08q | por quê |
|---|---|---|---|
| produzir, prepararPratica, conferirTentativa, revisar | só Grok | **só Grok** | o conteúdo serve quando responde; o que falha é tempo, não qualidade (ver abaixo) |
| conferir | só Grok | **só Grok** | 6 de 6 casos, 18 de 18 execuções |
| padroes | só Grok | **só Grok** | 6 de 6 casos, 18 de 18 execuções |
| **ecos** | só Grok | **indisponível por qualidade** | 3 de 6. Devolve `[]` onde o vínculo mais serve: 18 inscritos contra "a sala 7 comporta no máximo 15 pessoas" |
| **calibragem** | só Grok | **indisponível por qualidade** | 2 de 6. Cala quando não há erro a apontar, e com um par só a rota nem chega ao provedor |
| **recordar** | só Grok | **indisponível por qualidade** | 1 de 6. Vazou o alvo ("Por que a sala 7 não pode receber mais que 15 pessoas?"); quando a guarda `Prova.vaza` suprimiu a pergunta, o autor ficou sem nada |
| **responder** | Grok, depois o aparelho | **indisponível por qualidade** | 3 de 6, por FABRICAÇÃO: "A biblioteca municipal do seu bairro abre às 13h"; "1.650 km… R$ 1.072,50" num pedido em que o autor disse não ter distância, consumo nem preço |
| **instigar**, **contrapor** | Grok, depois o aparelho | **indisponível por qualidade** | 1 de 6 cada. Instigar devolve o vocabulário do próprio prompt ("o movimento básico que se pula", "a nota DEGRAU 0"); contrapor sustenta o contraponto em fato inventado ("metanálises de 2022", "na construção naval do século XV o preço era 12 % menor") |
| **responderNasNotas** | Grok, depois o aparelho | **indisponível por qualidade**, no grupo com conserto nomeado | remedida com fontes tipadas (ressalva 1): 4 de 6. Cita a nota certa e resiste a instrução hostil, mas recusa por inteiro quando falta o fato atual, sem usar o que as notas trazem, e deixa escapar os rótulos `N1T1`/`N2T1` no texto do autor |
| vestir, classificar | Grok, depois o aparelho | **inalteradas** | ver a ressalva 2 abaixo |
| dominio | só o aparelho | **só o aparelho** | 4 de 6; o mesmo texto voltou `trabalho`, `estudo` e `casa` em três execuções. Instabilidade registrada, sem trocar de executor: não há outro medido |

O corte tem DOIS grupos, e a tela precisa distingui-los: **cinco sem substituto medido** (`ecos`, `calibragem`, `recordar`, `instigar`, `contrapor`) e **duas com conserto nomeado, em correção** (`responder`, `responderNasNotas`). `Politica.Linha` ganhou `medidaEm` e `conserto` para que o Perfil leia a distinção da tabela em vez de guardar uma cópia que envelhece sozinha. Nenhuma das sete cortadas tem substituto: quatro já constavam como reprovadas no aparelho na 07b, e para as outras três o aparelho **não foi medido** — e só substitui quem passar a MESMA matriz e o mesmo limiar. Aviso de qualidade foi descartado: aviso não transforma resultado insuficiente em ajuda aprovada. Descer ao aparelho por ser "menos ruim" também.

**Ressalva 1, e ela vai contra nós: a medida anterior de `responderNasNotas` foi INVÁLIDA POR DEFEITO DO INSTRUMENTO, não do provedor.** `Sabia.responderNasNotas(pergunta:contexto:)` não tinha nenhum chamador de produção — só a sonda — e embrulhava a prosa inteira numa `FonteNotas` sintética de título "Contexto fornecido". A "atribuição genérica do Grok" que quase virou linha de SPEC era um título que o PRÓPRIO APP fabricou. A sobrecarga foi apagada e a sonda passa a exigir `fontes`; os casos foram reescritos com fontes tipadas (`prova/q-qualidade-notas-tipadas.json`, `ea68b976…`) e remedidos em três execuções. O resultado NOVO — 4 de 6, com o caso do conflito entre notas passando a acertar — é o que decide, e ele reprova assim mesmo. As bases de 07/09 e as de `prova/cinco-itens-*` usam a mesma conveniência nesses casos: aquelas linhas medem a rota morta, e ficam registradas assim, sem reescrita de prova alheia.

**Ressalva 2: `vestir` não teve o Grok exercitado em nenhum dos seis casos** — a forma local resolveu antes, como a 07a previu. A rota do Grok em `vestir` continua NÃO MEDIDA, e nada se habilita nem se corta com base nesta volta. A única falha de `vestir` (vestir de título e lista um texto que pedia "não quero organizar isso em tópico nenhum") e a única de `classificar` (Destaque numa lista de compras) são da REGRA LOCAL, com o modelo calado — não são matéria de tabela de provedor.

**Defeito de disponibilidade, medido aqui e consertado na 08r.** São **20** falhas de transporte, não 12: o número 12 estava errado nesta ADR e no EVOLUCAO, e a soma da própria tabela já o desmentia — 11 + 6 + 3 = 20. Recontadas linha a linha no JSONL em 08/09 pela Q-B, são **20 de 72** chamadas a `grok-4.6`, todas nas quatro rotas de Trabalho, que pedem raciocínio e tinham teto de 90 s: prepararPratica 11 de 18 (61 %), revisar 6 de 18, produzir 3 de 18, conferirTentativa 0 de 18 — sempre aos 91 s, e sempre concentradas nos mesmos nove casos. As rotas em `grok-4.3` tiveram 0 falhas em **177** chamadas na matriz, e 0 em **186** contando as 9 da remedição com fontes tipadas — os dois números são o mesmo fato com denominador diferente, e ficam escritos os dois para não virarem uma terceira contradição. `prepararPratica` fica em **1 de 6 casos** por causa disso, não por conteúdo. Para o autor, uma operação que falha metade das vezes por tempo é uma operação que não está lá — e por isso o conserto virou ADR própria: **2026-09-08r**.

**O limite desta prova, escrito porque ela é sobre medir.** O JSONL da sonda **não é transcrição integral do provedor**: guarda o retorno das APIs de domínio, não o bruto que os parsers descartam. O hash atesta identidade dos bytes comparados, não correção nem execução do binário alegado. `modeloRespondido` ausente significa identidade não confirmada. Duração e esforço solicitado não provam raciocínio efetivo. Os 59 casos novos foram escritos pelo implementador e lidos por ele: **não são teste cego nem held-out**, e a aprovação final exige casos novos de um revisor que não os tenha visto. Uma amostra finita não prova "sempre". E a lição que custou esta volta: hash de fixture e JSONL completo **não impedem medir a rota errada** — "qual executor e qual caminho foram realmente observados" se responde lendo o chamador, caso a caso.

**A superfície.** As telas que já liam a tabela (`RecordarView`, `RedeView`, `PadroesView`, `OficinaTrabalho`) passam a mostrar a frase nova sem mudança de view. O **Perfil** precisa de uma TERCEIRA linha — hoje ele imprime só `pelaConta` e `peloAparelho`, e uma operação cortada sumiria das duas; `Politica.indisponiveis` existe para ela. Frente de front-end aberta pelo orquestrador; enquanto ela não fecha, o corte está no motor e **não** está dito no Perfil. Suíte: 911 testes em 148 suítes, zero falhas.

## ADR 2026-09-08p — Por que o NOSSO parser recusou, dito por ele mesmo (volta Q-C)

**A distância.** A 08r mediu que **3 de 15** execuções de `prepararPratica` não entregavam nada ao autor **depois** de o provedor ter entregue inteiro — HTTP 200, `finish_reason: stop`, `grok-4.6` confirmado, 3.777 a 6.865 tokens de raciocínio — e escreveu, honestamente, que quem recusou foi o nosso contrato de domínio. Mas parou aí. O re-G3 reprovou por isso e tem razão: `parsePreparacao` e `validar` são **onze guardas** e o JSONL guardava um `nil`. "O provedor devolveu conteúdo inválido" e "uma regra nossa é estreita" continuavam sendo inferências concorrentes, e ninguém pode decidir sobre uma régua que não consegue ler. **É a mesma lei que esta volta inteira aplicou ao provedor: falha sem motivo legível não é medida.** Nós a aplicávamos a ele e não a nós.

**A decisão: a recusa tem nome, e o nome não custa o bruto.** `PraticaTrabalho.Recusa` é um enum com doze casos; `lerPreparacao` e `provar` devolvem `Result<_, Recusa>` e são a ÚNICA cópia das regras — `parsePreparacao` e `validar` viram `try? …get()`, para que a régua e o motivo nunca divirjam em silêncio. Cada caso redige **uma linha**: a categoria (`forma`, `limite`, `repetição`, `exemplo`, `vazamento`), o campo e uma **medida** — contagem, tamanho, índice do critério, nome de chave truncado em 32. Não vai o texto do exercício, que é a prática da pessoa, nem credencial, nem o bruto: exatamente a categoria que o revisor recomendou, mais o campo que ela sozinha não dá. No caso do vazamento o motivo precisa dizer mais que "vazou" — e é aí que a primeira redação desta ADR errou. Ela gravava o **quadrigrama normalizado** que casou, e o re-G3 reprovou com razão: tirar acento e pontuação não tira o conteúdo. O trecho é, por definição, texto do EXEMPLO; um exemplo com dado pessoal, texto selado ou credencial em quatro palavras seria publicado pela sonda. E o pedido que gerou o furo foi meu: pedi o trecho para provar o diagnóstico.

**A correção: posição e contagem, nunca o trecho.** A recusa por vazamento registra (a) qual critério, (b) a partir de qual palavra do exemplo, de quantas, e (c) **quantas das palavras do trecho o AUTOR já tinha escrito neste pedido** — objetivo, resultado e instrução vigente, os três campos que a sonda já grava em `entrada` e que o leitor pode conferir sozinho. O trecho existe dentro de `provar` e morre lá. `Prova.vazamento` devolve `(trecho, palavra, de)` e `Prova.vaza` continua sendo `vazamento(…) != nil` — uma implementação, dois usos, para não haver duas contas de quatro palavras. O pedido do autor **não entra na régua**: nada passa nem cai por causa dele, e sem ele a recusa diz "origem não conferida" em vez de supor zero. **A garantia é ESTRUTURAL, e o teste prova pela forma** (correção da Q-F, 08/09): `Recusa` não tem campo nenhum que carregue o trecho, e `nenhumCampoDaRecusaCarregaPalavraDoExercicio` varre a serialização inteira — a linha redigida mais o dump do valor com todos os campos associados — de um caso de cada uma das doze guardas, contra um exercício em que cada palavra é um marcador inventado, oito deles de 1 a 4 letras, conferidos por igualdade de token normalizado. Campo novo com o texto derruba o teste; caso novo sem varredura derruba a conta de doze. A fronteira que fica aberta está dita no próprio teste: `chavesForaDoContrato` ecoa o NOME da chave a mais que veio na resposta, cortado em 32 caracteres.

**Por que contagem por palavra, e o que ela não garante.** Exigir as quatro palavras SEGUIDAS no pedido seria quase sempre falso — o autor escreve "separando o que foi concluído, a dependência e o próximo passo", não a frase do exemplo — e não distinguiria nada. Contar palavra a palavra distingue, mas palavra funcional ("a", "de") infla a conta: por isso **só o valor cheio** (todas as palavras do trecho já escritas pelo autor) sustenta sozinho "isto é vocabulário do pedido"; qualquer valor menor é indício e está escrito como indício. O hash do quadrigrama foi considerado e recusado: continua sendo oráculo de confirmação para quem tenha um palpite do texto, e não responde a pergunta que a ADR faz. O teste de privacidade agora procura a forma NORMALIZADA — o furo que o re-G3 achou era procurar só "¿dónde está la estación?" quando a saída seria "donde esta la estacion" — e varre palavra a palavra do exemplo em cada uma das doze linhas redigidas.

Em DEBUG, `MotorTrabalho.prepararPratica` guarda a linha e a sonda a retira com `retirarRecusasDaPreparacao()`, do mesmo jeito que retira os diagnósticos do Grok; a chave `recusasDaPreparacao` só aparece no JSONL quando houve recusa.

**A remedição, no aparelho do dono, com a conta ligada.** `C2416CBC`, install **por cima** (sem `uninstall`, `erase`, `clearState` nem `xcodebuild test`), conta conferida por listagem **autenticada** de 12 modelos na abertura (corrida `2DFC05C3`, 20h55Z), em cada um dos registros e no fecho (`qc-fumaca-fecho`, 21h58Z, os mesmos 12). Dois lançamentos: `2DFC05C3` com 5 repetições dos dois casos e `0065BE4A` com 4, já com o quadrigrama exposto. **18 execuções de `prepararPratica`, 18 respostas HTTP 200 completas de `grok-4.6`, 5 recusas nossas.** Fixtures `prova/qc-recusa-casos.json` (`df2fc8bb…`) e `prova/qc-recusa2-casos.json` (`5a65ccdf…`); saídas inteiras em `prova/qc-recusa-avaliacoes.jsonl`.

| corrida | caso | execução | motivo redigido |
|---|---|---:|---|
| 2DFC05C3 | revisor-sintetico-resumo-projeto-2x5 | 2 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 1 | vazamento · o critério 5 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 2 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 2DFC05C3 | q2-conhecido-preparar-apresentacao-proposta | 3 | vazamento · o critério 4 repete quatro palavras seguidas do exemplo |
| 0065BE4A | revisor-sintetico-resumo-projeto-2x5 | 4 | vazamento · o critério 3 repete do exemplo as quatro palavras seguidas **“a dependencia ainda aberta”** |

(Esta última linha é a redação ANTIGA, que carregava o trecho. Fica registrada porque o caso é **sintético e autorizado** — a régua da volta permite JSONL completo dessas entradas — e porque apagar a história para parecer limpo seria pior que declará-la. O mecanismo mudou: nenhuma recusa produz mais trecho.)

**Cinco de cinco na MESMA guarda.** Nenhuma recusa foi de forma, de chave, de limite, de critério repetido ou de exemplo contido no enunciado: as onze outras guardas não dispararam uma vez. A recusa é **uma** — `Prova.vaza(criterio, alvo: exemplo)`, a última linha de `provar`.

**A segunda remedição (volta Q-D): a causalidade medida caso a caso, sem o trecho.**
O re-G3 disse, com razão, que a conclusão "o defeito é nosso" estava provada em UMA das
cinco recusas — só a quinta tinha quadrigrama. As outras quatro não têm como ser
recuperadas: o bruto foi corretamente descartado e as corridas passaram. Então em vez de
inferir, **remedi com o instrumento novo**. `C2416CBC`, install por cima, sem `uninstall`,
`erase`, `clearState` nem `xcodebuild test`; conta conferida por listagem **autenticada** de
12 modelos na abertura e no fecho (`qd-fumaca-abertura`/`qd-fumaca-fecho`) e
`contaGrokLigada: true` em cada registro. Corrida `1B7E0E63`, os mesmos dois casos,
6 repetições: **12 execuções de `prepararPratica`, 12 HTTP 200 completos de `grok-4.6`,
4 recusas nossas.** Fixture `prova/qd-origem-casos.json` (`6e38dfbe…`), saídas inteiras em
`prova/qd-origem-avaliacoes.jsonl` (`fd60c7c8…`).

| caso | exec. | guarda | posição | origem |
|---|---:|---|---|---|
| revisor-sintetico-resumo-projeto-2x5 | 3 | **limite** | enunciado com 1582 caracteres, teto 1500 | — |
| revisor-sintetico-resumo-projeto-2x5 | 4 | vazamento | critério 3, palavra 19 de 95 | **4 das 4** já escritas pelo autor |
| q2-conhecido-preparar-apresentacao-proposta | 4 | vazamento | critério 5, palavra 80 de 85 | **4 das 4** já escritas pelo autor |
| q2-conhecido-preparar-apresentacao-proposta | 5 | vazamento | critério 4, palavra 73 de 78 | **4 das 4** já escritas pelo autor |

**O veredito, caso a caso, e ele não é arredondado para o nosso lado.** Nas **três** recusas
por vazamento desta corrida, **as quatro palavras do trecho já estavam no pedido do autor —
3 de 3 no valor cheio**. Com a quinta recusa da 08p (`“a dependencia ainda aberta”`, cujo
vocabulário está na instrução), são **4 ocorrências com evidência exposta, 4 apontando para
NÓS**. As **quatro recusas da corrida `2DFC05C3` continuam sem evidência individual** e
assim ficam escritas: não foram contadas a favor.

**O que isso NÃO prova.** A conta é por palavra, não por sequência; o pedido do autor tem
93 palavras distintas num caso e 70 no outro, e palavra funcional ("a", "de", "o") entra na
conta. Um trecho de quatro palavras funcionais daria 4 de 4 sem dizer nada. O que sustenta a
leitura aqui é o valor CHEIO em três de três, num alvo de 70–93 palavras distintas — indício
forte, não teorema. E a leitura de fundo continua a mesma: em `provar` o `alvo` de
`Prova.vaza` é o EXEMPLO, que o nosso próprio prompt manda ser de outro caso e nunca a
resposta-alvo; em Recordar o `alvo` É a resposta. Herdamos a régua sem herdar a premissa.

**Uma correção de fato contra a 08p original: as outras guardas DISPARAM.** A redação
anterior dizia "as onze outras guardas não dispararam uma vez", e isso valia para 18
execuções. Em 12 novas, `limite · enunciado tem 1582 caracteres e o teto é 1500` disparou uma
vez — guarda de tamanho, não de vazamento, e nada a ver com a régua importada. Somando as
duas remedições: **30 execuções, 9 recusas (30 %), 8 por vazamento e 1 por limite.** A
recusa por vazamento é DOMINANTE, não exclusiva, e a ADR passa a dizer isso.

**E mesmo assim o parser NÃO muda nesta volta.** Alargar contrato de validação é volta própria, com régua antes do conserto, e por três razões que valem mais que a pressa: (1) a guarda protege de verdade contra o caso em que o exemplo É o caso-alvo disfarçado, e desligá-la sem uma régua nova reabre isso; (2) trocar o `alvo` de `exemplo` para "o que a pessoa deve produzir" exige nomear esse alvo, que hoje o contrato não tem campo para dizer; (3) o revisor tem de ver a régua antes, e não depois. **Vai para o RUMO, nomeado: `Prova.vaza` em `PraticaTrabalho.provar` usa o EXEMPLO como alvo e reprova vocabulário estrutural da tarefa — 8 recusas por essa guarda em 30 preparações completas em 08/09/2026, e nas quatro com origem exposta o quadrigrama era, palavra por palavra, vocabulário que o autor já tinha escrito no pedido. Decidir o alvo certo, escrever a régua nos dois sentidos (o que deve passar e o que deve continuar sendo recusado) e só então mexer.** A linha está escrita: `ferramentas/orca/RUMO.md`, seção **“A RÉGUA DO VAZAMENTO, nos dois sentidos — volta própria, e ela vem antes de mexer no parser”**, com a evidência desta ADR e as quatro recusas sem evidência declaradas INDETERMINADAS. Esta volta **não** escreveu a régua e **não** mexeu no parser: o que ela entrega é a medida e a pergunta, não o conserto. Até lá `EstadoPedido.praticaIndisponivel` continua contando a falha pedido a pedido na `TrabalhoView`, como a 08r decidiu, e a tabela `Politica` continua sem mudança.

**O teto: o teste passa a guardar o valor decidido, e são duas guardas, não uma.** `oTetoDeTrabalhoCobreAPiorLatenciaMedida` só exigia `>= 180` e `> 90` — passava com `181` e deixava cair os 240 s que a 08r decidiu, que é a folga, não o piso. Agora são três expectativas com papéis separados: o **piso observado** (`>= 179`, porque a pior execução inteira medida é 178,144 s), a lápide dos 90 s, e a **decisão** (`== 240`), com a mensagem dizendo que mudar o número é mudar a ADR e trazer medida nova ao lado. O comentário que chamava 141 s de "pior latência" foi corrigido: 141,058 s é a chamada isolada mais lenta; 178,144 s é a pior execução de ponta a ponta, com duas chamadas.

**O que esta ADR não prova.** 30 execuções não são a distribuição: 5 de 18 (28 %) e 4 de 12 (33 %) são consistentes com os 3 de 15 (20 %) da 08r, e nada mais. Das doze guardas, DUAS foram vistas recusar (vazamento e limite); das outras dez continua sendo ausência de evidência, não evidência de ausência. A causalidade tem evidência exposta em **quatro** ocorrências (três da `1B7E0E63` mais a quinta da `2DFC05C3`), não em todas as nove: as quatro recusas iniciais rodaram no binário anterior, sem posição nem origem, e não foram contadas. A origem é contagem por palavra num alvo de 70–93 palavras distintas, não prova de sequência. E esta volta **não julgou a qualidade** dos treze exercícios que passaram — mediu quem recusou e por quê, não se o que entrou serve.

## ADR 2026-09-08r — O teto das rotas de Trabalho é medido, não suposto (volta Q-B)

*(Letra corrigida na Q-E, 08/09: esta ADR nasceu `2026-09-08m` e a letra já estava tomada em `main` pela E1, "O resultado da ação volta ao trabalho". As mensagens de commit anteriores a esta correção ainda dizem `08m`.)*

**A distância.** O G3 da volta Q recusou a 08q por três coisas, e a segunda é esta: manter `produzir`, `prepararPratica` e `revisar` como oferta **contradiz a régua que nós mesmos escrevemos** — timeout material significa operação ausente para o autor. A 08q tinha o dado e mesmo assim deixou a oferta de pé: **20 de 72** chamadas a `grok-4.6` morriam aos 91 s (`prepararPratica` 11 de 18, 61 %), contra **0 de 177** em `grok-4.3`. Anunciar no Perfil "só com a conta Grok: preparar exercícios" quando a operação chega em 1 de 6 casos é prometer o que não se entrega.

**Por que o teto, e não as outras duas saídas.** As três estavam na mesa; duas caem pela própria medida.

- **Retentativa: reprovada pelo dado, não por gosto.** A falha não é intermitente. Cinco dos nove casos que carregavam as 20 falhas estouraram os 91 s nas **três** execuções — `q2-conhecido-preparar-espanhol-solo`, `qn-preparar-criterio-so-do-que-esta-escrito`, `qn-preparar-outro-dominio-planilha`, `qn-produzir-combinar-sem-resolver-a-pratica` e `ler-rascunho-q2-conhecido-preparar-espanhol-solo`. Repetir um pedido determinístico é fazer o autor esperar 180 s pelo mesmo nada.
- **Indisponível por qualidade: desproporcional ao defeito medido.** Cortaria junto `conferirTentativa`, que é `grok-4.6` com esforço `high` e teve **0 falhas em 18** e 6 de 6 casos, e `produzir`, cuja única reprovação foi exatamente este teto. Aplicar a regra de indisponibilidade a um defeito de espera é usar a régua errada.
- **Teto: o único que não invalida a medida de qualidade.** Mesmo modelo, mesmo `reasoning_effort`, mesmo prompt, mesma janela — muda só a paciência. Baixar o raciocínio, que a 08q também listava, mudaria o que foi medido e obrigaria a remedir as dezesseis.

**A decisão.** O `90` literal, repetido em quatro chamadas de `Traco/Trabalho`, vira **um** valor em `Grok.tetoTrabalho`, e o valor é **240 s** — que é o teto sob o qual a remedição foi feita e nada o encostou. Um lugar só, pela mesma razão da 03l: quatro cópias divergem em silêncio, e foi assim que um teto virou a ausência de uma operação sem ninguém decidir isso.

**A medida nova, no aparelho do dono, com a conta ligada.** Sonda `AvaliacaoIA` pelo caminho de produção, no `C2416CBC`, install **por cima** (sem `uninstall`, `erase`, `clearState` nem `xcodebuild test`). Conta conferida **antes de instalar** (corrida de fumaça `2934F6EC`, 20h08Z: `contaGrokLigada: true` e a listagem **autenticada** de 12 modelos devolvida pela API), **em cada um dos 27 registros** da corrida, e **depois de tudo** (corrida `007BB0B8`, 20h59Z, os mesmos 12 modelos). A conta sobreviveu ao `boot`, ao install por cima e às 30 chamadas. Fixture `prova/qb-teto-casos.json` sha256 `1055b023…`; saídas inteiras em `prova/qb-teto-avaliacoes.jsonl` sha256 `fa51544a…` (as três corridas, fumaça de abertura, remedição e fumaça de fecho, no mesmo arquivo); corrida da remedição `B54FF0BE`.

Os nove casos remedidos são exatamente os que carregavam as 20 falhas — 9 casos × 3 execuções = 27, e 30 chamadas a `grok-4.6` (os três `Combinar` chamam duas vezes).

| rota | antes, teto 90 s | depois, teto 240 s | pior latência medida |
|---|---|---|---|
| prepararPratica | 11 de 18 falhas de transporte | **0 de 15** | 141,1 s |
| revisar | 6 de 18 | **0 de 9** | 133,7 s |
| produzir | 3 de 18 | **0 de 3** (duas chamadas por execução) | 178,1 s no caso inteiro |
| conferirTentativa | 0 de 18 | não remedido (não tinha falha) | 45,7 s em 08/09 |
| **total `grok-4.6`** | **20 de 72 (28 %)** | **0 de 30** | — |

Os casos que estouravam nas três execuções voltaram inteiros: `ler-rascunho-q2-conhecido-preparar-espanhol-solo` em 133/91/100 s, `qn-preparar-outro-dominio-planilha` em 113/107/102 s, `qn-produzir-combinar-sem-resolver-a-pratica` em 160/178/130 s. **O teto era o defeito.**

**O achado que vai contra nós, e ele não é de teto.** Com o transporte inteiro, **3 das 15 execuções de `prepararPratica` continuam sem entregar nada ao autor** — `revisor-sintetico-resumo-projeto-2x5` (2 de 3) e `q2-conhecido-preparar-apresentacao-proposta` (1 de 3). Nessas três a chamada voltou **HTTP 200, `finish_reason: stop`, conteúdo completo, `grok-4.6` confirmado, 3.777 a 6.865 tokens de raciocínio**: quem recusou foi o **nosso contrato de domínio** (`PraticaTrabalho.parsePreparacao`/`validar`), não a rede. É defeito de conteúdo, medido, e o teto não o conserta. Pela contagem de entrega por caso, `prepararPratica` sai de **1 de 6** para **4 de 6**; as outras três rotas entregaram em todas as execuções medidas.

**O que isso muda na tabela `Politica`: nada, e o motivo é o lugar do estado honesto.** Ausência sistemática — metade das vezes, determinística por caso — é indisponibilidade e mora na tabela. Recusa ocasional do próprio contrato já tem superfície própria e por pedido: `Trabalho.EstadoPedido.praticaIndisponivel`, que a `TrabalhoView` mostra em `pratica-preparacao-indisponivel` com a saída "Retomar esse pedido". Mover isso para a tabela apagaria a operação inteira por um defeito que a tela já conta, pedido a pedido — e a tabela não sabe dizer "às vezes". O que fica aberto no RUMO, nomeado: por que `validar` recusa 1 em 5 preparações completas, e se o defeito é do provedor ou do nosso esquema.

**`responderNasNotas` continua cortada.** O revisor escreveu um caso tipado **novo, que o implementador não viu** — teto de R$ 5.000, US$ 300 + US$ 120 previstos, cotação de R$ 5,20 datada — e as três execuções recusaram por inteiro: *"Não tenho informação disponível nesta consulta para confirmar isso."* Zero de três (`prova/q-revisao-avaliacoes.jsonl`). A linha da tabela não muda e o motivo continua sendo o da recusa por inteiro: **conserto nomeado não é conserto feito**.

**O que esta ADR não prova.** 240 s é o teto sob o qual **nada** encostou em 30 chamadas; não é prova de que nada encostará — a cauda é longa e a maior amostra que temos por ponto é uma. As 27 execuções saíram de **um** lançamento com três repetições e `esquecerMemo()` entre elas, não de três lançamentos como a matriz da 08q: menos independência entre execuções do que a corrida original, e isso está dito. Só os nove casos que falhavam foram remedidos — os 52 que já chegavam abaixo de 90 s não foram repetidos, porque subir um teto não transforma sucesso em falha. E esta volta mediu **entrega**, não releu a qualidade caso a caso: dizer "4 de 6" para `prepararPratica` é dizer que quatro casos entregaram nas três execuções, não que o conteúdo dos quatro atende a rubrica.

## ADR 2026-09-08l — A terceira linha do Perfil: o que a medida reprovou, dito ao autor

**A distância.** A ADR 08q tirou da execução as operações que a medida de 08/09 reprovou com a conta ligada (`indisponivelPorQualidade`). Mas o Perfil imprimia só duas listas — `pelaConta` e `peloAparelho` —, e uma operação reprovada sumia das duas: o autor via menos coisa e nenhuma explicação, o contrário da ordem do dono ("o que reprovar vira linha honesta na tela, nunca resultado pior calado"). Pior: com o filtro por negação de `peloAparelho`, a reprovada passaria a ser anunciada como "pelo aparelho, sem conta" — mentira produzida por código que ninguém tocou (achado desta volta, corrigido na 08q pelo filtro por inclusão).

**A decisão.** O cartão CONTA do Perfil ganha uma terceira lista, lida da MESMA tabela (`Politica.indisponiveis`, com `motivo`, `medidaEm` e `conserto` na `Linha`): uma linha por operação, no nome que o autor entende (`Politica.nome`) e não no símbolo, com o porquê em uma oração de pessoa e a data da medida. Dois estados, dois grupos, para o dono ver qual é qual: *reprovada sem substituto medido* ("Indisponível mesmo com a conta Grok — a medida de 08/09 reprovou, e não há outro caminho:") e *reprovada com conserto nomeado* ("Em correção, com conserto nomeado e sem data — a medida de 08/09 reprovou:", e a linha termina em "· conserto: …"). A data sobe para a abertura do grupo quando todas as linhas a compartilham; se um dia divergirem, desce a cada linha. A lista muda de tamanho com a medida — e vazia é o estado que se quer: a tela então diz "Nenhuma operação indisponível por qualidade." em vez de sumir com a linha.

O que a linha NÃO faz, por regra: não manda conectar conta (a conta existe; a frase de recusa no momento do pedido é a de `semProvedor`, que a 08q já corrigiu); não promete prazo (conserto tem nome, não tem data); não vira boletim — a evidência (contagens, caminhos de prova) fica em `porque`, para a ADR e o `prova/`, e não na tela. A frase longa do momento da recusa e a linha curta do Perfil são duas coisas: não se repete a longa nos dois lugares.

**Dynamic Type.** A letra miúda do cartão tinha `maxWidth: 280` fixo em pontos; em AX5 isso dava doze caracteres por linha e um terço da tela em branco, e as três listas dobravam de altura à toa. Passa a `medidaMiuda`, `@ScaledMetric` relativo a `.subheadline` (280 em `large`, ~45 caracteres): escala com a letra e, quando cresce além da tela, a largura do cartão manda. Medido no iPhone Air em AX5: a linha de uma operação cai de 0,32–0,38 tela para 0,26.

**O que esta ADR não prova.** A qualidade das frases de `motivo` é de quem mediu; a tela só as formata. VoiceOver não foi ouvido (o simulador pede reiniciar o aparelho); a árvore de acessibilidade mostra cada linha como um elemento, na ordem visual, nada focável como ação. 3 testes em `PerfilQualidadeTests` (a lista vem da tabela; a data no lugar certo; o conserto na linha).

## ADR 2026-09-08w — Duas voltas na mesma função: a `mudanca` do ajuste passa a recusar com nome (volta Q-H)

**O conflito.** Enquanto a volta Q instrumentava as guardas da preparação, a
V17 (ADR 08j) mesclou em `main` e acrescentou às MESMAS duas funções um campo
novo de contrato: `mudanca`, a frase em que o modelo diz o que mudou de um
exercício para o anterior. `parsePreparacao` virou `lerPreparacao ->
Result<Preparada, Recusa>` de um lado e ganhou `comMudanca:` do outro;
`validar` virou `provar` de um lado e ganhou teto e prova de vazamento sobre a
`mudanca` do outro. As duas mudanças são de mérito e nenhuma cede.

**Decisão.** A `lerPreparacao` conhece `comMudanca`, e cada queda que a V17
escrevia como `nil` passa a ter guarda nomeada. Chave ausente num ajuste é
`chavesForaDoContrato(faltando: ["mudanca"])` — num ajuste ela É do contrato.
Tipo errado é `campoNaoTexto("mudanca")`; vazia é `campoVazio("mudanca")`; acima
de `Limite.mudanca` é `campoAcimaDoTeto`. Os quatro são casos REAPROVEITADOS:
a `mudanca` falha do mesmo jeito que os outros cinco campos, e inventar
categoria para ela diria que é outro tipo de defeito. A regra da V17 fica
inteira: qualquer uma dessas quedas derruba a preparação INTEIRA, porque versão
que muda calada é o que aquela volta existe para impedir.

**O único caso NOVO: `mudancaVazaOExemplo`.** `criterioVazaOExemplo` carrega um
`indice` e diz "o critério N". Usá-lo para a `mudanca` obrigaria a inventar um
índice de critério para um campo que não é critério — a recusa mentiria sobre
qual guarda reprovou, que é o oposto do que a ADR 08p faz. Mesma régua
(`Prova.vazamento`), mesma disciplina de medida sem conteúdo (posição, contagem
de palavras e origem no pedido do autor; nunca o trecho), mesmo `Recusa.origem`.
Só o campo é declarado por nome. A `mudanca` é provada DEPOIS dos critérios: o
exercício se prova antes do que se diz sobre ele.

**Na rota remota**, um único `ajustando = p.ajuste != nil` governa o esquema de
saída, a leitura e o rótulo do produtor (`"Grok · exercício adaptado"`), e o
`timeout` é o `Grok.tetoTrabalho` MEDIDO na 08r, não o `90` suposto que a V17
carregava — mantê-lo devolveria à rota de ajuste a falha de transporte que a
volta Q acabou de fechar. A sonda de DEBUG grava as recusas do ajuste também,
sem ramo: a recusa de um ajuste é a que mais precisa de nome, porque é ela que
decide se o exercício de alguém não mudou por defeito do provedor ou por
estreiteza da nossa régua.

**Prova.** Build sem aviso e suíte integral na árvore MESCLADA — a que ninguém
tinha testado — no `34CC3F94`: 957 testes, 956 passados, 0 falhos, 1 pulado em duas execuções limpas; e 958 / 957 / 0 / 1 depois de trazer também o `main` que a V13 avançou durante o trabalho (auto-merge limpo, zero conflitos)
(`CadernoHitchesTests`, já pulado antes). Os testes da V17 sobre `mudanca` e os
da Q sobre `Recusa` passam juntos. Decisão por decisão em
`ferramentas/orca/q-h-reconciliacao.md`.

**O que esta ADR NÃO prova.** Nada de novo sobre a qualidade do ajuste: nenhuma
chamada real ao provedor foi feita nesta passada, e a régua do vazamento
continua como estava — alargá-la é volta própria, já no RUMO. Duas execuções da
suíte travaram antes de conectar o runner (0 de 957, 345 s cada) e a terceira
passou inteira; provei que a árvore mesclada sobe instalando e lançando o app
no aparelho (`ferramentas/orca/q-h-app-mesclado.png`). É limite do instrumento
registrado, não resultado.

## ADR 2026-09-08u — Quem escreve na pasta tem nome (volta MAC-1)

O companheiro do Mac (`ferramentas/traco-mcp/servidor.py`) lia notas e corpus e
escrevia em `entrada/`, mas **`traco_escrever` não sabia dizer quem escreveu**:
uma nota do bot entrava idêntica a uma nota da pessoa, e o app a tratava como
voz do autor — inclusive no Retrato, que é a evidência SOBRE QUEM ESCREVE posta
na frente da IA. Faltavam também a agenda e as decisões, sem as quais o "bom
dia" e a revisão da semana não existem (casos 11 e 2 de `ferramentas/grokbot/CASOS.md`).

**`origem` é obrigatória em toda escrita que não seja texto da pessoa, e a
recusa diz o que falta.** `traco_escrever` ganhou `origem` (`autor` | `grokbot`
| `pesquisa`), `motivo` e `fontes`. O padrão continua `autor`. Origem diferente
de `autor` **sem motivo é recusada** — "escrita com origem “grokbot” exige
`motivo` — uma linha dizendo por que o bot está escrevendo isto" —, e nada é
gravado. `pesquisa` sem `fontes` também é recusada: pesquisa sem fonte é opinião
do bot, e o próprio texto da recusa manda escrevê-la como `grokbot`. O motivo e
as fontes viajam no CORPO da nota, como rodapé ("— feito pelo bot: …"), para que
o autor leia quem escreveu e por quê **dentro da nota**, sem abrir outra tela; o
cabeçalho carrega só `origem:`, que é o que o app consome.

**A etiqueta.** `Nota.origemRaw` (vazio = o autor, que é o que toda nota anterior
a esta ADR é) atravessa o import (`Corpus.importarComEstado` lê `origem:` do
cabeçalho já extraído para checar o selo — a ordem das linhas não importa), o
export (`arquivoMd` só escreve a linha quando não é do autor) e a tela. Na tela
é `Pilula(forma: .etiqueta)`, a MESMA cápsula em que o gesto já vive na lista —
sem cor nova, sem componente novo: **"feito pelo bot"** (a formulação do
contrato) e **"pesquisa do bot"**. Aparece em dois lugares, e os dois importam:
na linha da lista, para que o autor saiba antes de abrir; e na página aberta,
**acima do texto**, porque a página é o lugar em que se confunde o texto do bot
com a própria voz — o rótulo tem de chegar antes da leitura, não depois.

**Fora do Retrato, e não só do Retrato.** `Retrato.NotaLida.doAutor` corta a
nota do bot no mesmo filtro em que o selo já cortava expressiva, selada e
queimada — **nem como contagem**: duas notas WOOP, uma do bot, dizem "1 WOOP".
`Trajetoria.NotaLida.doAutor` faz o mesmo, porque a trajetória calcula a
calibragem das decisões e as palavras conquistadas; deixar o bot ali seria
medir a mente da pessoa com texto que não é dela. No servidor, `traco_semana` e
`traco_decisoes` também pulam origem diferente de `autor`.

**`agenda.md`, o quarto arquivo solto.** `Corpus.agenda` escreve, ao lado de
`LEIA-ME.md`, `INDICE.md` e `traco-corpus.md`: **Compromissos** (do mesmo
`calendario.json` que a pasta já copiava), **Decisões a conferir** (as que
`Volta.campoDevido` diz que venceram) e **Recordar devido** (`FatiaCorpus.recordarEm`,
lido de `Revisoes.proximaData` no ponto em que a fatia nasce, que é @MainActor).
É `.md` com a data no começo de cada linha e " · " como separador: o autor abre
a pasta e lê, e `traco_agenda(dias)` parte a linha. O selo continua valendo —
`vivas` já exclui a expressiva em curso, e selada/queimada entram como
`soMetadado`, que a agenda pula. Ações de Trabalho **não** estão aqui: são da
MAC-2, e o arquivo diz isso em vez de fingir completude.

**`traco_decisoes` e o bug que ele desenterrou.** A ferramenta devolve, por
decisão, `esperava` × `aconteceu` × `saldo`, separando `respondidas` de
`sem_resposta`. Ao escrevê-la apareceu que **`traco_semana` lia os campos da
forma do CABEÇALHO** (`c.get("escolha")`), e eles vivem no CORPO, depois do
marcador `<!-- traco-campos:json-v1 -->` (ADR 05h): a revisão da semana devolvia
decisões e destaques vazios desde sempre, e a fixture do autoteste sustentava o
engano pondo `unica:` no cabeçalho, onde nenhuma nota real o tem.
`Pasta.campos()` passa a ler o bloco JSON, e a fixture foi corrigida para o
formato que o app de fato exporta.

**Sem V5 no schema.** `origemRaw` entrou como atributo com valor padrão, dentro
da V4. A primeira tentativa criou `TracoSchemaV5` com a mesma lista de classes
da V4 e o CoreData derrubou o arranque com "Duplicate version checksums
detected" — os `VersionedSchema` daqui apontam para a classe VIVA, não para uma
cópia congelada, então versão nova só faz sentido para MODELO novo (a V3 trouxe
o recibo, a V4 o Trabalho). *(A afirmação "dois testes de migração pegaram isto"
era falsa quando escrita: o diff não os tinha. A 09b os escreveu, e ao escrevê-los
o defeito ficou mais preciso do que este parágrafo dizia — veja lá.)*

**Prova.** Autoteste do servidor verde com os casos novos e as três recusas
(sem motivo, pesquisa sem fontes, origem desconhecida), incluindo a asserção de
que a recusa **não escreve arquivo nenhum**. Cinco testes novos em
`IntegridadeCorpusTests`: a origem atravessa o import (as quatro grafias,
inclusive a inválida, que vira `autor`), sobrevive ao roundtrip pela pasta, fica
fora do Retrato nem como contagem, a agenda traz o que vence e não traz o que o
selo fecha, e expressiva/selada continuam fora dos quatro arquivos soltos depois
deste diff. Suíte integral 953/0 em 153 suítes, `grep -c warning:` = 0.
Capturas em `ferramentas/orca/mac1-*.png`.

**Limite declarado.** A leitura falada do VoiceOver não foi exercitada: voz e
VoiceOver estão proibidos no Traço (ordem do dono). A etiqueta tem
`accessibilityIdentifier` e `accessibilityLabel` ("Esta nota não é sua voz: …"),
provados por árvore de AX e por captura.

## ADR 2026-09-09b — A origem acompanha todo consumidor (volta MAC-1-B)

A 08u pôs a origem na nota e cortou o bot do Retrato e da Trajetória. O G3
recusou a volta e mostrou por quê: o corte estava no LEITOR, e um CHAMADOR
esquecia de passá-lo. `Sessao.responderNasNotas` — **a rota de produção**, a que
monta o retrato para a IA quando o autor pergunta nas Notas — construía
`Retrato.NotaLida` sem o argumento, e o padrão `= true` mandava a nota `grokbot`
embora. O teste da 08u exercitava `Retrato.ler` isolado: **não visitava o lugar
do defeito**, e por isso o verde não valia nada.

**A regra, palavra do dono (09/09).** Não é conserto pontual: **nenhum consumidor
que declare voz, retrato, trajetória ou mapa do autor lê texto que não seja
dele — nem para inferir domínio, nem para contar.** A interface promete um
retrato feito "só com as suas palavras e contagens"; chamar de TRABALHO o texto
que o bot escreveu faz uma afirmação DERIVADA dele moldar o mapa do autor.

**O nome carrega a regra.** O campo passou de `doAutor` a **`vozDoAutor`** e
**perdeu o padrão**: em `Retrato.NotaLida`, `Trajetoria.NotaLida`,
`RevisaoSemanal.NotaLida` (nova) e `Rede.NotaLida` (nova) ele é obrigatório, e
quem escrever o sétimo chamador **não compila** sem declarar de quem é a voz. A
disciplina saiu da cabeça de quem escreve e entrou no tipo. E as seis conversões
`Nota → NotaLida` espalhadas por views e intents viraram **uma só**, em
`Nota.paraRetrato/paraTrajetoria/paraSemana/paraRede`: um lugar para acertar.

**Quatro consumidores, não um.** Cada um diz na própria documentação que fala da
mente do autor, e cada um lia texto que não era dela:
- **Retrato** — a evidência SOBRE QUEM ESCREVE posta na frente da IA;
- **Trajetória** — inclusive a linha de sentido, que não era filtrada;
- **Revisão da semana** — "o que a MENTE deixou no papel": contava a nota do bot
  por forma e mostrava o destaque dele como destaque da pessoa;
- **Rede** — "a ligação nasce do que o AUTOR escreveu": uma menção `[[assim]]`
  escrita pelo bot virava ligação dele. A nota do bot continua sendo **destino**
  — ligar a ela é ato do autor —, mas nunca **origem**.

**O texto também tem nome.** `Nota.vozDoAutor` prometia "só a voz do autor" e
devolvia o texto do bot. Agora devolve **vazio** quando a nota não é dele, e a
busca — que TEM de achar a nota do bot, porque ela está na pasta — passou a
pedir `Nota.textoDeQualquerOrigem`, cujo nome diz o que está pedindo. Com isso o
léxico e o classificador de bordo pararam de rotular o que o bot escreveu, e as
perguntas dos Padrões pararam de perguntar ao autor sobre o texto do bot: nada
disso precisou de um `if` novo em cada lugar.

**O rótulo que já estava gravado cala, sem migração.** `Nota.dominio` devolve
`nil` quando a origem não é o autor — a não ser que o AUTOR tenha escolhido no
menu (`dominioTravado`), porque aí a afirmação é dele. Foi o chip `TRABALHO` na
nota `grokbot` que o G3 viu na tela; ele some sem tocar no disco.

**Citar a nota do bot continua possível — com o nome de quem escreveu.**
`Sessao.fonteParaPergunta` põe a etiqueta no TÍTULO da fonte ("… · feito pelo
bot"). A citação na tela e a fonte no prompt dizem quem escreveu, em vez de
devolverem texto do bot como voz de quem perguntou.

**O caso 8 passou a funcionar no cliente real.** `traco_contrato` devolvia o
contrato sem os métodos: o catálogo vive no bundle do app, que o Mac não abre, e
`metodos/` na pasta só tem os do autor. O contrato passou a ser **gerado** de
`Catalogo.todos` — bloco "Métodos, campos e a PERGUNTA de cada um", com
`- <Nome> (\`id\`)`, `campos:` e `pergunta:` —, o que de quebra apagou a lista
fixa de dez formas que já não era o catálogo de vinte e oito. Exercitado num
cliente MCP de verdade: o bot confirma o que entendeu, acha o WOOP e faz a
pergunta dele, uma só (`ferramentas/orca/mac1b-caso8-cliente-mcp.txt`).

**Os dois vermelhos que faltavam, agora reexecutáveis.**
- `traco_semana`: o autoteste passou a rodar a fixture nova **contra o leitor
  antigo** (os campos lidos do cabeçalho) e a exigir que ele venha VAZIO, ao lado
  do verde do leitor de hoje na mesma fixture.
- A V5: `TracoSchemaV5Duplicado` e `TracoMigracaoComV5` existem no teste, e o
  replay roda com `touch /tmp/traco-replay-v5`. **A sonda corrigiu a 08u:** com
  um caderno NOVO o plano com a V5 duplicada abre sem reclamar — o checksum só é
  conferido quando um estágio de fato RODA. Por isso o replay sobe um caderno da
  V3, e aí sim: `*** Terminating app due to uncaught exception
  'NSInvalidArgumentException', reason: 'Duplicate version checksums detected.'`
  É `NSException`, não `Error` de Swift: **nenhum `do/catch` a pega**, e é por
  isso que ela derrubava o arranque em vez de virar recusa tratada. O guarda
  permanente é o verde ao lado — um caderno da V3 sobe pelo plano de hoje; quem
  acrescentar a V5 mata a suíte inteira.

**Prova.** Oito testes novos, **um por consumidor e todos do CHAMADOR**, cada um
visto vermelho contra o código de `2f0749b` antes de ficar verde. Suíte integral
963/0 em 155 suítes, `grep -c warning:` = 0. Na tela do A1DF, com a mesma pasta:
os chips `TRABALHO` e `ESTUDO` somem das notas do bot (`mac1b-dominio-antes.png`
× `mac1b-dominio-depois.png`) e os Padrões contam "1 destaque · 1 woop" com duas
notas Destaque no caderno (`mac1b-padroes-sem-o-bot.png`).

**Limite declarado.** O cartão do Retrato no Perfil continua fora de alcance: o
gesto do helper não rola aquela tela (o mesmo limite que o G3 registrou, com a
árvore parada em y=2,07). A rota do Perfil já passava a origem em `2f0749b` e
está coberta por teste; a prova viva desta volta veio dos Padrões, que é a tela
cujo comportamento MUDOU. A etiqueta no título da fonte citada é provada por
teste na função de produção: vê-la na tela exige uma resposta de provedor, e o
único simulador com a conta do dono está fora de alcance nesta rodada.

## ADR 2026-09-08v — A Ilha é do compromisso, e os estados que ninguém tinha visto (volta F5b)

A F1 fotografou a Ilha compacta e a expandida; a F4 deixou a **mínima** por
fotografar ("exige outra atividade viva ao mesmo tempo") e ninguém tinha visto
o **fim** de um compromisso nem a compacta com duas atividades em AX5. Esta
volta plantou os quatro estados no iPhone 17 Pro Max do simulador e corrigiu o
que apareceu.

**Duas atividades do mesmo app: o iOS mostra UMA na Ilha e empilha a outra na
tela bloqueada, e sem dizer qual.** Com o Destaque e o compromisso vivos ao
mesmo tempo, a Ilha era do Destaque e o compromisso a 40 minutos ficava atrás
(`f5b-antes-ilha-compacta-destaque-esconde.png`; o `liveactivitiesd` registra
as duas a subir no mesmo segundo, e a tela mostra uma). É o D9 da F1, ainda
vivo. **O compromisso vence**: `ProximoCompromisso.relevanciaNaIlha = 1` e
`DestaqueDoDia.relevanciaNaIlha = 0` (o padrão do `ActivityContent`), porque a
Ilha é o único lugar em que a contagem se vê sem abrir o app, e o Destaque tem
o widget e o cartão. Vale para a Ilha e para a ordem da pilha na tela bloqueada
(`f5b-depois-ilha-compacta-compromisso-vence.png`,
`f5b-depois-bloqueada-dois-vivos.png`, `f5b-depois-bloqueada-pilha-aberta.png`).
Teste: `ForaDoAppTests.aIlhaEDoCompromisso` fixa a ordem.

**A mínima só existe com atividade de OUTRO app.** Duas do Traço não bastam
(acima). O simulador não tem Relógio nem navegação, então a F5b subiu um app
descartável com uma Live Activity vazia (`ferramentas/orca/f5b-outra/`,
instrumento, não produto) e a Ilha encolheu as duas para o círculo: a do Traço
é só o ícone — estrela âmbar para o Destaque, calendário para o compromisso —
sem texto, que é o que cabe (`f5b-ilha-minima-destaque.png`,
`f5b-ilha-minima-compromisso.png`, `f5b-ilha-minima-compromisso-ax5.png`).
Nada a mudar na mínima: o `minimal` já desenhava o mesmo ícone do
`compactLeading`.

**A expandida cortava o último dígito da contagem** ("36:1|5",
`f5b-antes-ilha-expandida-corte.png`). O `Text(_, style: .timer)` reserva a
largura do maior valor que pode mostrar (h:mm:ss, porque a atividade sobe até
seis horas antes), e o teto de 76 pt centrava essa caixa e a cortava dos dois
lados. Sai o teto: a região mede o que a contagem precisa e os dígitos ficam à
esquerda da caixa, com a folga à direita (`f5b-depois-ilha-expandida.png`).
Duas formas que NÃO servem, vistas na tela e registradas para ninguém repetir:
`fixedSize(horizontal:)` na contagem deixa a expandida **vazia** — só o ícone
da região `leading` desenha (`f5b-instrumento-fixedsize-expandida-vazia.png`);
e `multilineTextAlignment(.trailing)` empurra os dígitos para a borda da caixa
reservada e corta de novo (`f5b-instrumento-alinhada-corta.png`).

**O fim: "acabou", e por quanto tempo.** Semeado um compromisso de um minuto, o
`staleDate` (= fim) passa e o `liveactivitiesd` marca a atividade *stale*: a
compacta vira calendário + "acabou", a expandida vira "Dentista / acabou" sem
contagem e sem cápsula, e o cartão da tela bloqueada perde o relógio relativo
e diz "acabou" (`f5b-fim-1-*.png` antes, `f5b-fim-2-*.png` no fim). **A Ilha
larga o "acabou" sozinha em menos de doze minutos** — às 21:42 estava vazia
sem o app ter aberto (`f5b-fim-3-ilha-vazia-12min.png`); **a tela bloqueada
mantém o cartão** (aos catorze minutos, `f5b-fim-3-bloqueada-acabou-14min.png`)
até o app voltar à cena e `reconciliar` encerrar. É o desenho que o ActivityKit
permite: não há fim agendado, só `staleDate`; o que a tela diz nesse intervalo é
verdade, e o cartão sai com um deslize. Quanto tempo o iOS deixa o cartão de pé
sem o app é medida para o aparelho do dono. Na expandida do fim a curva do
canto da Ilha comia o "a" de "acabou", a linha mais baixa da região (`…-antes.png`):
o recuo horizontal da região inferior passa de 4 para 10 pt (`…-depois.png`).

**AX5 na Ilha não existe.** A compacta é idêntica em `large` e em AX5
(`f5b-ax5-ilha-compacta-destaque.png`, `f5b-ax5-ilha-compacta-compromisso.png`
contra as capturas normais): a Ilha não escala com o Dynamic Type; o cartão da
tela bloqueada escala (`f5b-ax5-bloqueada-destaque.png`). O "t" cortado que o
juiz da F4 viu na compacta com duas atividades em AX5 **não se reproduz**: com
as duas vivas e AX5 a compacta diz "terminar o ca…", com reticências limpas. A
auditoria é datada; este defeito caiu sozinho, e sai do RUMO.

**Movimento.** A Ilha anima pelo sistema; o Traço não escreve curva nem duração
nela (o portão do movimento segue com a lista vazia). Entrada (o app publica e a
atividade sobe), troca de estado (a cápsula "Lembrar em 10 min" vira o recado
"avisos desligados no iPhone", que é o estado honesto de um contêiner sem
permissão) e saída (o app reconcilia um compromisso passado e encerra) estão
em `f5b-ilha-movimento.mp4` e, com Reduzir Movimento, em
`f5b-ilha-movimento-reduzido.mp4` — a expansão vira fusão, o resto é igual.

**Revisão G3 (F5b-B, 09/09): a prova reprodutível.** O revisor independente
confirmou o mecanismo e recusou a prova (`ferramentas/orca/revisao-f5b-ilha.md`).
O que mudou para fechá-la, sem redesenho:

- **O teste segura o wiring, não a constante.** O `ActivityContent` que sobe
  para o ActivityKit — em `request`, em `update` e no recado do intent — nasce
  de UM construtor por atividade (`ProximoCompromisso.conteudo(de:recado:)`,
  `DestaqueDoDia.conteudo(_:agora:)`), e `aIlhaEDoCompromisso` lê o
  `relevanceScore` e o `staleDate` do conteúdo construído: apagar o argumento
  do construtor põe o teste vermelho. Limite declarado: a suíte não exercita o
  ActivityKit (ADR 05u isola `atividades()` em teste), então um `ActivityContent`
  montado à mão fora do construtor não é visto pelo teste — é o que a revisão
  de código guarda, e os dois arquivos não têm outro.
- **A atividade já viva ganha a relevância.** `update` só saía quando o
  `ContentState` mudava; uma atividade que subiu numa versão sem prioridade
  ficava atrás do Destaque até o app a encerrar. `ActivityContent.difere(de:relevancia:)`
  compara estado E relevância, nas duas atividades; o teste cobre os dois lados.
- **A semeadura publica pela rota real.** O arranque só reconcilia a projeção
  que já está no disco; `f5b-semear.sh` escrevia `calendario.json` e o
  compromisso nunca ia ao ar — a reprodução do revisor viu só o Destaque. Em
  DEBUG, `TRACO_REPUBLICAR_CALENDARIO` no ambiente faz o arranque chamar
  `ProximoCompromisso.publicar(eventos, cal:)`, a mesma função da agenda, do
  editor e do intent (precedente: `TRACO_AVALIAR_IA`). O script agora exige o
  título semeado dentro de `superficie.json` e, com `LOG=<arquivo>`, grava o
  `liveactivitiesd` do instante: `Starting activity` com o id e
  `Marking activities stale` com o `staleDate` — o compromisso stale no fim,
  o Destaque à meia-noite. O daemon **não** registra o `relevanceScore`; a
  prova dele na tela é qual das duas a Ilha mostra.
- **Pares `large`/AX5 refeitos, Ilha inteira no quadro, mesmo estado, log ao
  lado.** Casa: `f5bb-large-ilha-compacta.png` (04:16:27) / `f5bb-ax5-ilha-compacta.png`
  (04:18:18) — a Ilha é do compromisso nas duas e é idêntica; o que escala são
  os rótulos da casa, prova de que AX5 aplicou. Bloqueada: `f5bb-large-bloqueada.png`
  (04:16:31) / `f5bb-ax5-bloqueada.png` (04:16:42) e `f5bb-ax5-bloqueada-ao-acordar.png`
  (04:16:38) — o cartão do compromisso por cima nas duas. `f5bb-log-large.log`
  é o `liveactivitiesd` da semeadura (04:16:19, dois `Starting activity`);
  `f5bb-log-ax5.log` é a janela inteira das seis capturas, sem atividade a
  subir ou cair entre elas. Tamanho lido de volta antes e depois; restaurado
  a `medium`.
- **Controle natural, não planejado:** entre duas capturas o `xcodebuild test`
  de outra volta instalou no mesmo aparelho um binário SEM a 08v (`cmp`
  diferente, `nm` sem `relevanciaNaIlha`); o iOS relançou o app por "Activity
  ended" e o arranque reergueu as duas atividades a partir da mesma projeção
  (`f5bb-log-controle.log`): **a Ilha voltou ao Destaque**
  (`f5bb-controle-sem-relevancia-ilha-compacta.png`, 04:13:05). Mesmo estado,
  mesma projeção, só o `relevanceScore` diferente — é a prova mais limpa desta
  volta de que ele é o mecanismo, e ela veio de um acidente de posse do aparelho.
- **Achado novo em AX5:** no cartão da tela bloqueada o relógio relativo do
  canto ("39 minutos" em `large`) cortava para **"39 minut…"** em AX5
  (`f5bb-ax5-bloqueada.png`); ao acordar a tela o mesmo canto mostrava a
  contagem "39:39" inteira (`…-ao-acordar.png`). Corrigido na F5b-C, abaixo.
- **O corte por alinhamento à direita vira hipótese.** A captura
  `f5b-instrumento-alinhada-corta.png` mostra "29:48" inteiro; o corte que o
  relato alegou não está nela. Fica registrado que `multilineTextAlignment(.trailing)`
  sem teto **não foi provado** cortar; a escolha de deixar os dígitos à esquerda
  da caixa do `.timer` se sustenta sozinha pela captura `f5b-depois-ilha-expandida.png`.
  (A F5b-C, abaixo, mostra por que a caixa é larga: o `Text` de data é guloso.)

**Revisão G3 (F5b-C, 09/09): o corte em AX5, e o controle com nome.** O
revisor aceitou as três provas e recusou de novo por duas coisas: a tela
bloqueada cortava em AX5 e o relato não trazia as seis fases do
`design-router`. O que mudou:

- **O relógio do cartão não corta mais, em nenhum tamanho.** A causa não era
  o tamanho da letra: o `Text` de data (`.timer` e `.relative`) é **guloso** —
  toma toda a largura que a linha oferece e encosta o conteúdo à esquerda
  dela. O teto de 92 pt existia para domar isso, e em AX5 "39 minutos" precisa
  de mais que 92. Sem teto o texto nunca corta, mas gruda em "PRÓXIMO"
  (`f5bc-instrumento-sem-teto-relogio-a-esquerda.png`, visto na tela);
  alinhado à direita (`multilineTextAlignment(.trailing)`) ele volta ao canto
  e, de quebra, a contagem passa a encostar na mesma borda da hora — antes
  ficava 40 pt para dentro (`f5bb-ax5-bloqueada-ao-acordar.png`, "39:39"
  solto). Pares refeitos, mesmo estado (Dentista em +40 min por 60 min,
  Destaque vivo), mesmo binário (`cmp` igual nos dois dylibs), semeadura pela
  rota real: bloqueada `f5bc-large-bloqueada.png` (05:21:42) /
  `f5bc-ax5-bloqueada.png` (05:21:59), ambas "39 minutos" inteiro no canto;
  ao acordar `f5bc-large-bloqueada-ao-acordar.png` (05:21:45, "39:43") /
  `f5bc-ax5-bloqueada-ao-acordar.png` (05:22:01, "39:26"); casa
  `f5bc-large-ilha-compacta.png` / `f5bc-ax5-ilha-compacta.png`, a Ilha do
  compromisso nas duas. `f5bc-log-large.log` é o `liveactivitiesd` da
  semeadura (05:21:31, dois `Starting activity`); `f5bc-log-ax5.log` é a
  janela das capturas AX5, sem atividade a subir ou cair. O que a hipótese
  acima dizia da expandida vale aqui às avessas: alinhar à direita **não
  cortou** no cartão, porque a caixa gulosa tem folga; na expandida a região
  é estreita e a folga não existe — a escolha de lá fica como está.
- **O controle ganha o nome certo.** O que a F5b-B chamou de "controle que eu
  não planejei" é um **grupo de controle**: o `xcodebuild test` de outra volta
  instalou no mesmo aparelho um binário sem a 08v, o iOS reergueu as duas
  atividades **a partir da mesma projeção**, e a Ilha voltou ao Destaque
  (`f5bb-controle-sem-relevancia-ilha-compacta.png`, 04:13:05;
  `f5bb-log-controle.log`, ids `2F19AAAE…`/`C496A60E…` às 04:07:00). Mesmo
  estado, mesma projeção, mesmo aparelho, só o `relevanceScore` ausente: é a
  prova **por ausência** de que a relevância é o mecanismo — e vale mais que
  uma captura a mais, porque nenhuma captura com a 08v distingue "a relevância
  decidiu" de "o iOS escolheu por outro critério que coincide". O daemon não
  registra `relevanceScore` (declarado e aceito): a prova é a tela **com** e
  **sem**.
- **Limite do instrumento, visto de novo:** entre uma captura e outra o iOS
  perguntou "Deseja continuar permitindo as Atividades ao Vivo do app Traço?"
  por cima do cartão (`f5bc-instrumento-dialogo-atividades.png`); o toque do
  `orca emulator` na pilha fechada abre a pilha em vez de acertar o botão, e só
  na pilha aberta o botão recebe o toque. Respondido "Permitir Sempre".

## ADR 2026-09-09d — Uma linha é o piso do papel, e a folga cede antes da letra (volta C1)

**Ciclo:** multiplicar a mente — o autor escreve sem lutar com a ferramenta.
**Intenção:** a pessoa vê o que está escrevendo, em qualquer tamanho de letra e
em qualquer aparelho. **Obstáculo:** a invariante da escrita visível (ADR 08f)
estava provada no iPhone 17 Pro e no Pro Max e **falhava no iPhone 17e em
AX XXXL** — 18 amostras vermelhas, o único vermelho da suíte integral naquele
aparelho, pré-existente (a V13 mediu as mesmas 18 em `HEAD` sem o diff dela).

### O que estava errado, medido antes de ser corrigido

Sonda em `CadernoView.tetoDoEncaixe` no 17e com o teclado de pé, em AX XXXL:

```
SONDA teto: altura 413,67  pe 274,67  piso 259,33 -> teto 69,50  papel 69,50
SONDA teto: altura 413,67  pe 326,67  piso 259,33 -> teto 43,50  papel 43,50
```

A tela do 17e dá 413,67 pt de trabalho com o teclado de pé. **O pé toma 274,67
— e 326,67 com o aviso.** A regra de então era `papel = min(piso, sobra / 2)`:
com 139 pt de sobra o papel ficava com **69,5 pt**, e com 87 de sobra ficava com
**43,5**. Uma linha de corpo em AX XXXL mede **67 pt**. O papel era menor que a
linha que ele existe para mostrar — não havia rolagem que resolvesse, e o autor
escrevia às cegas. Duas causas independentes, as duas em função compartilhada:

1. **O contêiner concedia menos de uma linha.** `tetoDoEncaixe` repartia o que
   sobra do pé pela metade. Onde a tela é pequena e a letra grande, metade não
   dá uma linha. O comentário da 05y admitia a troca de propósito — "um piso
   maior deixaria o autor sem as duas saídas em vez de sem texto" — e essa troca
   **contradiz a 08f**: a letra do autor à vista vale mais que a saída do cartão.
2. **O seguidor perseguia o CARET, não a LINHA.** `EscritaVisivel.seguirCaret`
   media `caretRect`, que em AX XXXL tem 45 pt para uma linha de 67: a
   entrelinha fica POR CIMA do caret. E pedia `folga` inteira dos dois lados;
   com o papel curto, a folga empurrava a linha para fora — o alinhamento pelo
   fundo deixava 22 pt de letra acima da borda no meio da nota, onde havia
   rolagem de sobra.

### A decisão

**O piso do papel é UMA LINHA, e a folga cede antes da letra.**

- `tetoDoEncaixe` passa a ser `sobra − min(max(min(piso, sobra/2), piso/3), sobra)`:
  o piso continua sendo três linhas limitado a meia sobra, mas **nunca desce
  abaixo de `piso/3`, que é uma linha**. Quando nem uma linha cabe, o papel toma
  a sobra inteira e o encaixe cede — é a 08f aplicada à letra, não ao cartão.
- `EscritaVisivel.linhaDoCaret` mede a **linha visual** pelo TextKit 2 (o
  fragmento de linha unido ao retângulo do caret), e `seguirCaret` segue essa
  linha. A medida é feita de novo aqui, e não lida do teste: o instrumento mede
  sozinho, senão a prova passa a citar o código que devia julgar.
- A folga vira `min(folga, (vista − linha) / 2)`: onde o papel não tem espaço
  para ela, ela encolhe simetricamente. **Quem tem de caber é a linha.**

Em `large` nada muda (a sonda mede papel 92 pt antes e depois); a regra só morde
onde a metade já era menor que uma linha.

### A pré-mortem

O que pode dar errado: em AX XXXL com aviso E toast, o encaixe fica com ~0 pt e
a mensagem do cartão some da tela. Isso é **decisão, não descuido** — mas é o
sinal de que o verdadeiro exagero está no pé, que toma 275 dos 414 pt naquele
aparelho. **Fica no RUMO:** a barra de baixo em tamanhos de acessibilidade
precisa de uma volta própria; enquanto ela não vier, o papel ganha da barra.

### Resíduo observado, não corrigido

Durante a **gaveta do cartão a chegar** (`Tema.gaveta` anima a altura do
encaixe), há um quadro em que a altura do encaixe já cresceu e o seguidor ainda
não correu: a linha ativa aparece **cortada ao meio** pela borda do cartão
(`ferramentas/orca/c1/c1-04-residuo-gaveta-cartao.png`, ~0,11 s numa varredura
de 220 quadros). O mecanismo — um quadro de atraso entre a altura animada e a
volta do runloop — não foi alterado por esta volta, e a suíte não o apanha
porque mede em pontos discretos. **Fica escrito, não escondido.**

## ADR 2026-09-08x — Nenhuma gaveta corre sobre a linha do autor (volta C1-B)

**Ciclo:** multiplicar a mente. **Intenção:** a pessoa vê o que está escrevendo,
em qualquer tamanho de letra e em qualquer aparelho — **em cada quadro**, que é
como a 08f está escrita. **Obstáculo:** a 09d fechou a invariante nos pontos
DISCRETOS onde a suíte mede (31/31 em AX5, 44/44 em `large`) e deixou declarado
um resíduo: durante a gaveta do cartão a chegar, a linha ativa aparecia cortada
(`c1-04-residuo-gaveta-cartao.png`, "~0,11 s numa varredura de 220"). Declarar
não torna mesclável uma violação conhecida de uma regra escrita sem exceção, e
"~0,11 s" não era verificável.

### O instrumento primeiro: a invariante passa a ser medida POR QUADRO

`EscritaVisivelTests.aLinhaFicaNoPapelEmCadaQuadroDaGaveta(tamanho:)` põe um
`CADisplayLink` a medir a 08f **em cada quadro entregue**, com o instante de
cada um, enquanto a Página REAL recebe as três gavetas que encolhem o papel: o
cartão a chegar, o aviso a tomar o lugar dele e o toast. Duas coisas o separam
do teste discreto que já existia:

- **mede as camadas de APRESENTAÇÃO, não o modelo.** Durante uma animação o
  modelo já tem o valor final e só a apresentação diz o que o olho vê — que é o
  que a 08f escreve. O quadro apresentado é, medido, sempre o **modelo do
  quadro anterior**.
- **cada quadro traz o seu instante**, e a conta sai em quadros e em segundos,
  com a cadência ao lado (16,7 ms: 60 Hz sem quadro perdido) e o custo da
  própria sonda (0,2–0,5 ms/quadro). É a "sequência carimbada" que o re-G3
  pediu no lugar da varredura sem tempo.

**O que ele mediu no pai (build `4898703`, iPhone 17e `C7341E64`):**

```
GAVETA AX5,   cartão a chegar: 85 quadros em 1,42 s, 6 fora; +0,268 a +0,350 s = 0,098 s, pior corte 32 pt
GAVETA large, cartão a chegar: 86 quadros em 1,42 s, 6 fora; +0,267 a +0,350 s = 0,100 s, pior corte 13 pt
GAVETA (aviso e toast, nos dois tamanhos): 0 fora
```

**Duas correções ao que a 09d escreveu**, as duas contra nós: o resíduo é de
**0,098–0,100 s**, não 0,11; e **não é só de AX XXXL** — o `large`, que a 09d
dava por são, tem o mesmo resíduo de 6 quadros. A "varredura de 220" não
sustentava nenhum dos dois números.

### A causa, medida antes de tocar no código

Sonda por quadro no `tetoDoEncaixe` e na geometria do papel, no 17e:

- **`large`:** a altura do papel é ANIMADA pela gaveta e desce 378 → 366 → 352
  → 334 → 314 → 295 → 283 → … pt, **até 21 pt por quadro**. O seguidor é
  chamado a cada quadro (`onScrollGeometryChange` avisa 275,0 → 262,8 → 248,6 →
  231,3 → 210,7 → …, em dia), corrige, e **a linha fica sempre um passo atrás**:
  o corte de cada quadro é exatamente o passo daquele quadro.
- **AX5:** o mesmo, mais um **estouro de 52 pt**. O cartão entra por CORTE
  (`.identity`) e a régua saía por GAVETA, então por ~0,3 s o encaixe tinha os
  dois — 52 pt a mais do que antes E do que depois — e o papel caía a **35 pt
  para uma linha de 67**. Aí nenhuma rolagem cabe: a 08f é impossível por
  construção enquanto durar.

**E o limite, medido e não suposto:** **de fora do layout não há corrida a
ganhar.** Foram experimentados três seguidores — adiado pelo runloop (como
era), síncrono no aviso da geometria, e síncrono com a altura anunciada mais um
passo de adiantamento e mira no piso da 09d — e os **três produziram os mesmos
offsets, ao ponto** (`ferramentas/orca/c1b-gaveta.md`, tabela da ablação). A
correção da rolagem e a mudança da altura não cabem no mesmo quadro quando a
altura é animada, porque o quadro apresentado é o modelo do anterior.

### A decisão

**Nenhuma gaveta corre sobre a linha do autor.** Com o foco na Página, a altura
do encaixe muda por **CORTE**; a gaveta fica para quando o autor não está a
escrever.

- `PaginaView`: `.animation(focoPagina ? nil : Tema.gaveta(reduzido:), value:
  sessao.cartao)`, e o mesmo para `sessao.analisando`. É a mesma lei que a 08f
  já tinha aplicado duas vezes no mesmo encaixe — a régua CORTA, e o encaixe
  inteiro sai por corte ao abrir os campos —, agora estendida ao ocupante que
  faltava. **Não é uma exceção nova: é a regra do encaixe, completa.**
- `EscritaVisivel.seguirCaretAgora(folga:altura:)`: quando quem chama é
  `onScrollGeometryChange`, o seguidor corre **agora**, e não na volta seguinte
  do runloop, **com a altura que lhe ANUNCIARAM** — nessa passada o `bounds` do
  ScrollView ainda é o da anterior, e o seguidor que lê em vez de ouvir corrige
  para o papel de ontem. Isto ganha a corrida contra uma mudança de **um passo**
  — que é o que o corte produz — e só. `seguirCaret(folga:)`, o de texto e foco,
  continua adiado: ali o layout ainda não assentou.

**As duas metades são necessárias e nenhuma basta**, medido por ablação no
mesmo aparelho: só o corte (com o seguidor adiado) deixa **1 quadro com 115 pt**
de linha cortada em `large`; só o seguidor síncrono, com a gaveta de pé, deixa
os **6 quadros** de sempre. Juntas: **0**.

**O que fica igual.** Nenhuma curva, duração ou `withAnimation` novo — o portão
do movimento continua vazio. `Tema.swift` intacto. A gaveta do cartão continua a
existir e a correr sempre que a Página **não** tem o foco. A gaveta de
`esconderRegua` no `CadernoView` **ficou**: a ablação mostrou que, com o corte de
cima, ela já não estoura nada, e tirá-la seria movimento perdido sem razão
medida.

### A prova

iPhone 17e `C7341E64` e iPhone 17 Pro Max `6033B043`, `com-trava.sh` em toda
passada, teclado de software REAL nos dois aparelhos e nos dois tamanhos
(308 pt no 17e, 318 no Pro Max):

```
17e     GAVETA AX5 e large, três cenas cada: 0 fora em todas (84–88 quadros, cadência 16,7 ms)
17e     ESCRITA AX5 31/31, large 44/44, teclado real nos dois
Pro Max GAVETA AX5 e large: 0 fora; ESCRITA AX5 31/31, large 44/44, teclado real 318 pt
17e     ✔ Test run with 956 tests in 154 suites passed after 81.350 seconds — grep -c warning: 0
```

Quadros carimbados, versionados: `ferramentas/orca/c1/c1b-quadros-vermelho.txt`
e `c1b-quadros-verde.txt`. Relato: `ferramentas/orca/c1b-gaveta.md`. **O vídeo
que esta seção anunciava foi removido na C1-C: continha 44 s da Tela Inicial,
sem o Traço** — ver a correção do re-G3 no fim desta ADR.

### O que mais o re-G3 nomeou, e ficou fechado aqui

- **As bordas do TextKit 2** em `linhaDoCaret` têm suíte própria
  (`LinhaDoCaretTests`): documento vazio, linha vazia depois de `\n`, quebra
  suave por palavra, fim do documento, e a borda do `NSMaxRange` varrida em
  todos os offsets. **E a medida achou o contrário do que se esperava:** num
  `UITextView` nu — com a entrelinha do papel e a fonte de corpo em AX XXXL — o
  `caretRect` do UIKit **já é** a caixa da linha visual, ao ponto, em **0 de 61
  offsets** ele difere. A distância de 45 para 67 pt que a 09d mediu é do editor
  da **Página**, não do TextKit 2 em geral; quem a prova é o teste hospedado. As
  bordas cobram então o que protege o seguidor em qualquer editor: nunca nula,
  sempre contendo o caret, UMA linha visual só, e na altura certa do documento.
- **O que muda onde havia folga sobrando** (a pergunta do Pro Max) é
  **nada, e provado por varredura, não por aparelho**:
  `TemaTests.ondeHaviaFolgaSobrandoA09dNaoMudaNada` percorre 3.025 combinações
  de tela, pé e piso — **2.687 com folga sobrando e 338 apertadas** — e mostra
  que, onde meia sobra já dava uma linha, a regra da 09d devolve **o mesmo
  número** da 05y, e onde não dava, devolve estritamente mais papel. O Pro Max é um caso dessa varredura, e a corrida nele confirma a
  aritmética na tela.
- **As duas dívidas prometidas foram escritas no RUMO** (barra de baixo em AX;
  oráculo de pixels), mais a terceira que esta volta mediu: **o seguidor não
  ganha de uma altura animada**, com os três seguidores e os offsets iguais.

### A pré-mortem

**O que pode dar errado:** o cartão passa a APARECER, sem gaveta, enquanto o
autor escreve — e um salto de 52 pt (AX5) ou 121 (`large`) sem movimento pode
ler-se como um susto, que é justamente o que a lei do movimento evita. É a
troca que esta ADR aceita, e ela tem lado: **um salto que o autor vê é melhor
que uma linha que ele não vê**, e o quadro em que a linha estava cortada era
exatamente o quadro em que ele estava a escrever. Se a leitura na mão do dono
disser o contrário, o caminho não é voltar à gaveta: é a gaveta **empurrar o
papel antes de crescer** — reservar primeiro, animar depois —, e isso precisa
do gancho dentro do layout que o RUMO já nomeia.

**A segunda:** `focoPagina` é a condição, e ela não é o mesmo que "o teclado
está de pé". Com o teclado recolhido por arrasto o foco continua (a régua segue
o foco), e o corte vale ali também, onde a gaveta não fazia mal nenhum. É
movimento perdido num estado; preferi a condição que o `EscritaVisivel` já usa
para correr, porque duas condições diferentes para o mesmo evento é como nascem
os dois relógios que esta ADR acabou de fechar.

### A correção do re-G3 (C1-C, 09/09/2026): a sonda mede a regra inteira

O re-G3 reproduziu o vermelho do pai e o verde do candidato com as próprias
mãos, e mesmo assim reprovou — por duas coisas que não são o conserto, e sim a
**prova** dele.

**1. A sonda media metade da 08f.** `Quadro.cabe` era só `area.contains(linha)`:
`E ⊆ P`. A 08f também diz que **nenhuma outra superfície desenha nessa área** —
`P ∩ O = ∅` —, e essa metade não tinha portão nenhum por quadro. Agora cada
quadro carrega as duas, medidas e **relatadas separadas**: `noPapel` e
`semIntruso`, com o vermelho de cada uma contado, datado e nomeado no seu
próprio termo. O `intrusos(sobre:editor:)` que a medida discreta já usava passa
a ser chamado **em cada quadro**, e a ler a árvore de camadas pela
**apresentação**, como `E` e `P`.

**Uma camada sem `presentation()` não conta.** A primeira versão desta medida
acusou um intruso em `large` no primeiro quadro depois de o cartão nascer: era
falso. Uma camada recém-criada ainda não foi entregue ao render — `presentation()`
devolve nil — e lê-la pelo modelo é lê-la **na geometria de destino**, enquanto
a linha e o papel estão na do quadro anterior. Dois relógios outra vez, agora
dentro do instrumento. Camada sem apresentação não pinta naquele quadro: fica
de fora, e isso está escrito no código.

**E o portão prova que sabe reprovar.** Na mesma corrida, depois das três cenas
verdes, o teste **planta uma camada adversarial** à frente do editor, sobre a
linha ativa, e exige que os quadros a acusem — 35 de ~51 em cada tamanho, com o
intervalo do que a apresentação leva para a mostrar. Sai depois, e os quadros
seguintes voltam a zero. Zero intruso só vale como prova quando a sonda mostra,
ali, que veria um.

**2. `E` era a caixa do caret, não a linha.** Medindo, a faixa adversarial saiu
com **2 pt de largura**: no FIM do documento — que é onde o autor escreve —
nenhum fragmento do TextKit 2 começa na posição do caret, `textLayoutFragment(for:)`
devolve nil, e `linhaAtiva` ficava só com o `caretRect`. Com o recuo de um
caractere, `E` volta a ser a linha de letras: **322 pt em AX5, 55 em `large`**.
A metade `P ∩ O = ∅` cobrava, antes disto, apenas quem cobrisse a coluna do
caret.

**O vermelho do pai, agora nas duas metades** (pai `4898703` num checkout
descartável, **só** a sonda trazida deste ramo, mesmo 17e `C7341E64`):

```
PAI 4898703 + sonda C1-C, teclado real 308 pt
AX5,   cartão a chegar: 85 quadros, 7 fora do papel (E ⊄ P) e 2 cobertos (P ∩ O ≠ ∅)
       fora +0,270 a +0,367 s = 0,113 s, pior corte 32 pt
       coberta +0,317 a +0,350 s = 0,050 s — ColorShapeLayer e CGDrawingLayer do CARTÃO sobre a linha
large, cartão a chegar: 85 quadros, 5 fora (0,083 s, pior corte 14 pt) e 5 cobertos (0,083 s)
✘ Test run with 2 tests in 1 suite failed after 54,574 s with 4 issues

CANDIDATO, mesmo aparelho: 0 fora e 0 cobertos nas seis cenas, nos dois tamanhos
✔ Test run with 956 tests in 154 suites passed after 85,241 s — grep -c warning: 0
```

O cartão do pai não só **cortava** a linha: ele **desenhava por cima dela**, e
o instrumento anterior não tinha como dizê-lo. O conserto da C1-B fecha as duas.

**3. O vídeo era prova falsa.** `c1b-gaveta-consertada.mp4` tinha 44 s da Tela
Inicial, sem o Traço. Foi **removido**. No lugar entra
`c1/c1c-pagina-na-sonda.mp4` — 36 s, 390×844, gravado por
`xcrun simctl io <UDID> recordVideo` durante a corrida verde e **assistido
quadro a quadro antes de versionar**: mostra a Página real com o teclado, o
texto a ser escrito, o cartão a chegar, o aviso, o toast e a faixa adversarial
vermelha sobre a linha ativa. O que ele prova é que a corrida aconteceu **na
Página**; a prova por quadro continua sendo a sequência carimbada,
`c1/c1c-quadros-{vermelho,verde}.txt`. Relato: `ferramentas/orca/c1c-sonda-inteira.md`.

**O que fica herdado, e dito.** A parte do Pro Max `6033B043` **não foi
reexecutada** nesta volta: o aparelho estava reservado a outra frente e a
pergunta ao orquestrador expirou sem resposta. A prova da C1-B no Pro Max
permanece **herdada**, não observada aqui. E a corrida da suíte INTEGRAL desta
volta teve teclado real em `large` (308 pt) mas **emulado em AX5** (318 pt, 8
tentativas) — a corrida isolada teve real nos dois. Limite do instrumento, não
asserção afrouxada.
