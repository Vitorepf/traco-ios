# Traço — spec do produto

> iOS puro (Swift/SwiftUI). Este documento é a fonte da verdade.
> ADR 2026-08-31 — Reforma da linguagem: Pilha→Notas · Porteiro→Análise (botão: Analisar) ·
> Puxar→Recordar · Códice→Padrões · Véu→Confirmação · Trava→Aviso. Critérios: usuário de
> primeira viagem entende sem manual; verbo para ação, substantivo comum para tela; zero
> metáfora interna. "Gesto" permanece: é conceito da tese, não nome de UI. Rename atômico
> em código+testes+maestro+specs; propriedades persistidas do SwiftData intocadas.
> ADR 2026-08-31b — Régua do Caderno podada 136→12 (menu grande = template em menu, §12);
> o catálogo completo permanece no formato de arquivo: nota antiga nunca quebra.
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

- **Gatilho:** botão explícito. NUNCA roda a cada tecla, NUNCA na pausa (decisão de produto:
  controle total, zero vigilância).
- **Motor v1 (obrigatório):** análise **local**, no aparelho — as mesmas heurísticas do
  protótipo-espelho. **Zero rede. Zero token. Zero fatura.**
- **SuperGrok ≠ API.** A conta Super (grok.com / app Grok) é chat de consumidor com
  cota semanal. A [API da xAI](https://docs.x.ai/developers/pricing) é outro produto,
  cobrado por token, créditos não-reembolsáveis. Os dois medidores **não se misturam**.
  Extra Usage Credits da Super também são gasto extra — **proibidos**.
- **Proibido no código:** `api.x.ai`, chave de Console, Keychain de API, `URLSession`
  para modelo, qualquer fallback que “só um pouquinho” cobre. Se a análise não
  classificar, o veredito é silêncio — nunca uma chamada paga.
- Grok de verdade no app só entra se a xAI um dia oferecer cota Super *dentro* do
  app, sem ledger de API. Até lá, Super fica no app oficial; Traço não gasta.

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
| **Spec** | algo a construir (software/projeto) | Problema · Pronto quando · Não-objetivos · Restrições · Casos-limite |
| **Nota permanente** | ideia/insight curto | Uma ideia nas suas palavras · Liga a · Fonte |
| **Destaque** | lista de tarefas / "hoje" | A única coisa de hoje, primeiro, até acabar |
| **Expressiva** | desabafo emocional longo | sem campos — vira o modo do §8 |

## 7. Recordar (retrieval)

Disponível na nota aberta e nas notas (segurar o cartão).

1. O conteúdo da nota some da tela.
2. O usuário escreve de memória o que estava lá.
3. **Revelar** → memória e nota lado a lado. Sem nota da IA, sem score — o olho compara.

É o único momento em que "esquecer dói" — e a dor é o treino (generation/testing effect).

## 8. Escrita expressiva (modo trancado)

Ao abrir a forma Expressiva:
1. Timer de **15 minutos** visível, discreto.
2. Instrução única: fato E sentimento, sobre o mesmo evento.
3. Ao fim do timer: a nota **grava e tranca**. Qualquer outra rota durante o timer
   pede “Sair agora tranca.” **Concluída após ≥10 min** tranca direto — a escrita
   já mereceu a porta. Antes dos 10 min, Concluída também passa pelo confirmação.
4. Nota trancada aparece nas notas com cadeado, título oculto. Reabrir exige confirmação
   dupla com atrito ("Pennebaker pede para não reler. Abrir mesmo assim?").
5. A Análise nunca comenta o conteúdo de uma expressiva. Nunca.

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
}
```
Persistência local (SwiftData/arquivo). Sem nuvem na v1. Sem conta.

## 11. Design

- **Âncora:** Apple Notes dark + iOS HIG. Deve parecer o bloco que a pessoa já conhece.
- **Cor:** fundo `#0B0B0D` · texto `#ECECEA` · secundário `#9A9A96` · linha `#26262A`
  · acento âmbar `#D9A542` · aviso `#C4614D`. Tema escuro único (a página preta é o produto).
- **Tipo:** SF (sistema). Corpo 17/26. Labels 13 uppercase c/ tracking.
- **Espaço:** escala de 4. Raio 12.
- **Motion:** mínimo. A forma nasce com um fade curto (~250ms). Nada anima enquanto
  o usuário digita. `prefers-reduced-motion` respeitado.
- A UI inteira do editor: topo com [Notas] e [Concluída], página, e UMA barra inferior
  discreta [Analisar · Recordar]. Nada mais.

## 12. Não-objetivos (v1)

Chat/conversa. Streaks, XP, gamificação. Ouvinte emocional. Resumos. Busca semântica.
Sync/nuvem/conta. Compartilhamento. Templates em menu (a forma nasce da palavra).
Agenda/calendário. Android/web.

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
- **Recordar**: desabilitado com página vazia; beat "Leia uma última vez — a nota vai se
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

- Campo de busca nas notas + filtros por gesto em chips (WOOP, Se–então, Spec,
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
