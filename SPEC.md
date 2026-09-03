# Traço — spec do produto

> iOS puro (Swift/SwiftUI). Este documento é a fonte da verdade.
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

## 1. Visão

O bloco de notas mais simples do mercado, com uma IA multiplicadora que **nunca escreve
pelo usuário**. A tese: a IA multiplica o que a mente faz — então o app garante que o que
ela multiplica é o gesto certo (escrever sob regra), nunca o atalho (texto pronto, dívida
cognitiva — Kosmyna/MIT 2025).

**Frase do produto:** a IA do ChatGPT escreve; esta recusa — para você ter de escrever,
e depois cobra que você lembre.

## 2. Regra de ferro

A IA **nunca insere texto na nota**. Nunca completa, resume, melhora, consola ou elogia.
Toda estrutura que aparece na página é template determinístico do app (labels de campos),
disparado por classificação — nunca prosa do modelo.

### Lista fechada do que a IA pode fazer
1. **Rotear** — nomear o gesto que o texto do usuário já começou
2. **Avisar** — recusar o atalho, numa frase curta
3. **Perguntar** — no máximo UMA pergunta: o próximo campo vazio
4. **Recordar** — cobrar memória (ver §7)
5. **Padrões** — devolver perguntas sobre padrões das próprias notas (ver §9)
6. **Calar** — silêncio é resposta válida e frequente

Fora da lista = bug de produto, não feature.

## 3. Porta de entrada

O app **abre direto na página em branco**, escura, cursor pronto. Sem placeholder,
sem dica, sem chip. O vazio é intencional (o "ainda-não" do gesto).

- As **notas** anteriores ficam atrás de um gesto: botão discreto no topo-esquerdo.
- A home não é a lista. As notas não são o altar — reler cartões à noite é o anti-padrão.

## 4. Fluxo central

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
- **Conta e custo: ZERO.** Não existe chave de API neste app. O autor entra com
  a PRÓPRIA conta Grok (OAuth 2.0 device-code em `auth.x.ai`; access+refresh no
  Keychain, nunca em texto plano) e as chamadas a `api.x.ai` debitam o **pool
  semanal da assinatura**. Provado na conta do dono em 31/ago: HTTP 200 com
  crédito de console em US$ 0,00 — logo, não é medidor de token.
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

### Avisos obrigatórios (no system prompt)
| Detecta | Aviso (essência) |
|---|---|
| Afirmação vazia ("eu sou rico/vencedor") | Piora quem se estima pouco (Wood 2009). Escreva POR QUE um valor seu importa. |
| Pedido de texto pronto | A frase aqui é sua. O Traço não escreve. |
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
6. **Queimar tem de ser verdade em todas as rotas**, senão é mentira: o texto é
   sobrescrito antes de esvaziar, o backup no Arquivos é regravado na hora, o
   índice do Spotlight é refeito, a revisão é cancelada e **não há janela de
   desfazer** — não ter volta é o método. Teste por rota.
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

- **Âncora:** Apple Notes dark + iOS HIG. Deve parecer o bloco que a pessoa já conhece.
- **Cor:** fundo `#0B0B0D` · texto `#ECECEA` · secundário `#9A9A96` · linha `#26262A`
  · acento âmbar `#D9A542` · aviso `#C4614D`. Tema escuro único (a página preta é o produto).
- **Tipo:** SF (sistema). Corpo 17/26. Labels 13 uppercase c/ tracking.
- **Espaço:** escala de 4. Raio 12.
- **Motion:** mínimo. A forma nasce com um fade curto (~250ms). Nada anima enquanto
  o usuário digita. `prefers-reduced-motion` respeitado.
- A UI inteira do editor: topo com [Notas] e [Concluída], página, e UMA barra inferior
  discreta [Analisar · Recordar · Anexar]. Nada mais. (ADR 31/ago: Anexar entrou com o Caderno.)

## 12. Não-objetivos (v1)

Chat/conversa. Streaks, XP, gamificação. Ouvinte emocional. Resumos. Busca semântica.
Sync/nuvem/conta do Traço. Templates em menu (a forma nasce da palavra).
Android/web.

**Exceções (ADR 2026-09-02a, 2026-09-02e):** "Compartilhar como contexto" é
export pela folha do sistema — entrega a nota do autor à IA do autor; não é
compartilhar com pessoas. O aviso do "Se" com hora é uma notificação com o
título da nota, não um evento de calendário. Três âncoras (manhã, tarde, noite)
substituem streak.

## 13. Pronto quando (critérios de aceite)

- [ ] Abrir o app → página em branco com cursor em <1s
- [ ] "quero correr de manhã" + Analisar → chip WOOP + pergunta do obstáculo;
      "abrir forma" → campos vazios abaixo do meu texto
- [ ] "eu sou um vencedor" + Analisar → aviso Wood, sem forma
- [ ] Nota curta banal + Analisar → silêncio (nenhum cartão)
- [ ] Expressiva: timer 15 min → tranca → reabrir exige dupla confirmação
- [ ] Recordar: esconde, escrevo de memória, revela comparação lado a lado
- [ ] Padrões: 2–3 perguntas citando minhas frases; toque abre nota-resposta
- [ ] Em nenhum fluxo a IA insere prosa na minha nota

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

**Princípio.** Fricção é bug. O autor nunca precisa saber o nome de uma forma nem de
um método. Quem conhece o catálogo é a IA; quem escreve é o autor. Ponto.

**A distinção que preserva a regra de ferro:**
- **Auto-FORMA: SIM.** A IA aplica forma automaticamente às palavras do autor —
  detecta lista e veste lista, detecta desabafo e veste o modo certo, detecta verso
  e veste verso. A página fica visualmente impecável sozinha. Nenhuma palavra é
  escrita, movida, resumida ou corrigida: a IA **veste** o texto, nunca o toca.
- **Auto-PROSA: NUNCA.** A regra de ferro (§2) permanece intacta.

**Consequências:**
1. O catálogo de formas cresce sem teto (136 → 300+): ele serve à IA, não à memória
   do humano. A régua de 12 vira atalho manual opcional — não o caminho principal.
2. O catálogo de MÉTODOS também é vasto (WOOP, se–então, spec, expressiva, e todos
   os que o inventário conhece): a IA roteia automaticamente o melhor para o momento,
   sem o autor pedir. Revoga-se o "só quando chamado" do §5 (ADR 2026-08-31c):
   o gatilho passa a ser automático na pausa da escrita, com:
   - **um toque desfaz** qualquer aplicação automática (Soltar forma);
   - **silêncio continua válido** — na dúvida, a IA não veste nada;
   - opt-out por nota e global.
3. Toda sugestão de método aparece pronta (campos vazios já abertos quando a
   confiança é alta), não como pergunta que exige decisão. Decidir também é fricção.
4. Acessibilidade cognitiva é critério de aceite: nenhum fluxo pode exigir memória
   de recurso, nome de feature ou mais de um passo para o caminho principal.

**Fila que isto abre (P1):** motor de auto-forma local (heurística por bloco) →
auto-forma com IA real → roteador automático de métodos → confiança calibrada
(vestir só quando certeza; senão, silêncio).

## 18. Meu perfil
Um lugar só para conta e ajustes, alcançável do rodapé das Notas. Contém: estado
honesto da conta Grok em uma linha (conectada / expirada / sem rede / limite),
entrar e sair, e os ajustes que hoje só existiam em toque longo (análise
automática). Nada de chave, nada de preço, nada de medidor.

## 19. Divisão de responsabilidades: IA × algoritmo

A lei que decide quem faz o quê. **Se um item da coluna do algoritmo passar a
depender de IA, é bug de arquitetura** — o app tem de continuar inteiro sem rede,
sem conta e sem modelo. A IA é multiplicador; nunca alicerce.

### 19.1 Responsabilidade da IA (só isto, nada além)
A IA só existe em cima do texto do autor, e o resultado dela é sempre uma
ESCOLHA dentro de uma lista fechada — nunca prosa que entra na nota (§2).

| # | Papel | O que ela devolve | Se falhar |
|---|---|---|---|
| 1 | **Rotear o gesto** | um nome de forma da lista fixa (WOOP, Se–então, Especificação, Nota permanente, Destaque, Expressiva) ou nada | heurística local roteia |
| 2 | **Avisar** | uma frase curta de recusa, dentro dos casos da tabela do §5 | heurística local avisa |
| 3 | **Perguntar** | UMA pergunta sobre o próximo campo vazio | pergunta fixa do template |
| 4 | **Perguntas de Padrões** | perguntas sobre padrões entre notas, citando fragmento literal do autor | perguntas locais |
| 5 | **Calar** | silêncio (resposta válida e frequente) | silêncio |

**Regras que valem para todos os cinco:** temperatura 0 · JSON estrito
`{gesto, aviso|null, pergunta|null}` · sem histórico (não é chat) · resposta fora
do formato = silêncio, nunca improviso · nota **trancada** e **expressiva** jamais
saem do aparelho · só a VOZ do autor viaja (`Caderno.prosa` tira mobiliário e
anexos) · sem conta ligada, nenhuma chamada acontece.

**Proibido à IA, para sempre:** escrever, completar, reescrever, resumir,
traduzir ou "melhorar" o texto · elogiar, consolar, bajular, fazer companhia ·
gerar título, tag ou resumo da nota · pontuar, dar nota, medir progresso ·
decidir o que é apagado ou trancado · qualquer texto que entre na nota.

### 19.2 Responsabilidade do algoritmo (fechado, determinístico, offline)
Tudo abaixo é código nosso, testado, sem rede. É o corpo do produto — a IA some e
o Traço continua um bloco de notas inteiro.

| Domínio | O que o algoritmo faz sozinho |
|---|---|
| **Escrita** | parser Markdown ao vivo, digitação viva da lista (Enter herda marcador, double-Enter sai), vestir a forma ao soltar o teclado, régua de 12 formas, tabela que cresce por toque, código com sintaxe local, anexos |
| **Formas** | os templates e seus campos (labels são NOSSOS, não do modelo), abrir/soltar preservando resposta, um gesto por sessão |
| **Roteamento de reserva** | heurísticas locais: verbo de intenção, afirmação vazia (Wood), plano sem obstáculo (Oettingen), pedido de texto pronto, pedido de ouvinte, desabafo longo |
| **Memória** | Recordar (esconder → escrever de memória → revelar → comparar), escada de revisão 3→7→21, notificação sem conteúdo da nota |
| **Selo** | expressiva com timer, trancar ao fim, e o bloqueio em TODAS as rotas de saída (busca, Padrões, export, Spotlight, rede, notificação) |
| **Arquivo** | SwiftData, export/import Markdown, backup automático, busca sem acento, filtros, seções por mês |
| **Sistema** | Atalhos/Siri, `traco://`, Spotlight, hápticos, movimento, acessibilidade, Dynamic Type |
| **Conta** | OAuth device-code, Keychain, renovação de sessão, queda para local em 401/403/429 |

### 19.4 Doutrina: algoritmo primeiro (lei do dono, 31/ago)

**Tudo que fecha em algoritmo TEM de ser algoritmo.** Algoritmo não erra: ou faz o
planejado, ou é bug — e bug se conserta. Uma IA dá N respostas para a mesma
entrada; isso é inaceitável no núcleo de um produto que existe para multiplicar
pensamento sem introduzir erro. A IA fica só com o que não fecha, e ali ela vale
como **algoritmo dinâmico** — poderosa justamente por não ser fixa.

Três regras que decorrem disso, e que valem como aceite:

1. **Antes de perguntar à IA, tente a regra.** Se fecha, escreve-se a regra.
   A IA nunca é o caminho mais curto; é o último.
2. **A IA só devolve o que o algoritmo sabe VERIFICAR.** Nada de texto livre para
   a tela ou para a nota: ela devolve RÓTULO de lista fechada, e o app supõe as
   palavras. Rótulo desconhecido = silêncio.
3. **Onde texto livre é inevitável, a verificação é dura.** Em Padrões, a IA
   escreve perguntas — então o algoritmo exige: tem "?" (pergunta, não conclusão)
   e cada trecho entre aspas existe LITERALMENTE nas notas. Falhou a prova,
   a pergunta é descartada sem aparecer.

**Consequência já aplicada:** o contrato remoto virou
`{gesto: <enum|null>, aviso: <enum|null>}`. A pergunta saiu do contrato — é sempre
a do template, porque o algoritmo já sabe qual é o próximo campo vazio.
**Nenhuma palavra do modelo chega à tela do autor.**

### 19.3 A fronteira, em uma frase
**O algoritmo garante; a IA sugere.** Nada que o autor perca se a IA sumir pode
morar do lado da IA — e nada que a IA escreva pode entrar na nota.

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

## 22. Corpo de texto e Dynamic Type — DEFEITO ABERTO (set/2026)

Medido no simulador, mesma tela, corpo do sistema em `medium` e em
`accessibility-extra-extra-extra-large`:

- a ENTRELINHA do editor cresce (`@ScaledMetric(relativeTo: .body) corpoFolga`,
  em `PaginaView`, vai de 9 para ~28)
- o TAMANHO DA LETRA não cresce: todo o `Tema` é `.system(size:)`, que é ponto
  fixo e ignora o corpo do sistema
- o cartão de análise — WOOP, o reconhecimento, as duas saídas — fica idêntico,
  pixel a pixel, nos dois tamanhos

Quem precisa de letra grande recebe a MESMA letra pequena com vãos enormes: o
layout estica e o texto continua ilegível. É Dynamic Type pela metade, e o meio
que funciona é justamente o que não ajuda a ler.

O conserto é de sistema: cada token do `Tema` passa de `.system(size:)` para
fonte que escala (`.custom(_, size:, relativeTo:)` ou `Font.system(.body)` com
ajuste). Isso REFLUI TODA TELA — a régua de 12 chips, os cartões, a barra
inferior, a folha de 124 formas. Não é mudança para entrar sem o dono ver: a
régua já perde chips a 15pt, e a XXXL ela não cabe de jeito nenhum.

Decisão do dono, com duas saídas plausíveis:
1. escalar tudo e aceitar que a régua vire outra coisa em corpos grandes
2. escalar o CONTEÚDO (texto do autor, cartões, notas) e travar o CHROME
   (régua, barra), que é o que Notes e Bear fazem

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
