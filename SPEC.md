# Traço — spec do produto

> iOS puro (Swift/SwiftUI). Este documento é a fonte da verdade.
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
2. **Travar** — recusar o atalho, numa frase curta
3. **Perguntar** — no máximo UMA pergunta: o próximo campo vazio
4. **Puxar** — cobrar memória (ver §7)
5. **Códice** — devolver perguntas sobre padrões das próprias notas (ver §9)
6. **Calar** — silêncio é resposta válida e frequente

Fora da lista = bug de produto, não feature.

## 3. Porta de entrada

O app **abre direto na página em branco**, escura, cursor pronto. Sem placeholder,
sem dica, sem chip. O vazio é intencional (o "ainda-não" do gesto).

- A **pilha** (notas anteriores) fica atrás de um gesto: botão discreto no topo-esquerdo.
- A home não é a pilha. A pilha não é o altar — reler cartões à noite é o anti-padrão.

## 4. Fluxo central

```
abrir app ──► página em branco ──► usuário escreve (traço livre)
                                        │
                          [botão Porteiro — só quando chamado]
                                        │
              ┌──────────────┬──────────┴─────────┬──────────────┐
           gesto            trava              pergunta        silêncio
        identificado     (recusa curta)      (uma, campo       (nada
              │                                 vazio)          aparece)
        "abrir forma"
              │
      campos VAZIOS nascem abaixo do texto do usuário
              │
      usuário preenche ──► "Concluída" ──► nota vai à pilha
```

**Um gesto por sessão.** Se o Porteiro detecta segundo método na mesma nota → trava.

## 5. O Porteiro (lógica de IA)

- **Gatilho:** botão explícito. NUNCA roda a cada tecla, NUNCA na pausa (decisão de produto:
  controle total, zero vigilância).
- **Motor v1 (obrigatório):** porteiro **local**, no aparelho — as mesmas heurísticas do
  protótipo-espelho. **Zero rede. Zero token. Zero fatura.**
- **SuperGrok ≠ API.** A conta Super (grok.com / app Grok) é chat de consumidor com
  cota semanal. A [API da xAI](https://docs.x.ai/developers/pricing) é outro produto,
  cobrado por token, créditos não-reembolsáveis. Os dois medidores **não se misturam**.
  Extra Usage Credits da Super também são gasto extra — **proibidos**.
- **Proibido no código:** `api.x.ai`, chave de Console, Keychain de API, `URLSession`
  para modelo, qualquer fallback que “só um pouquinho” cobre. Se o porteiro não
  classificar, o veredito é silêncio — nunca uma chamada paga.
- Grok de verdade no app só entra se a xAI um dia oferecer cota Super *dentro* do
  app, sem ledger de API. Até lá, Super fica no app oficial; Traço não gasta.

### Travas obrigatórias (no system prompt)
| Detecta | Trava (essência) |
|---|---|
| Afirmação vazia ("eu sou rico/vencedor") | Piora quem se estima pouco (Wood 2009). Escreva POR QUE um valor seu importa. |
| Pedido de texto pronto | A frase aqui é sua. O porteiro não escreve. |
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

## 7. Puxar (retrieval)

Disponível na nota aberta e na pilha (segurar o cartão).

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
   já mereceu a porta. Antes dos 10 min, Concluída também passa pelo véu.
4. Nota trancada aparece na pilha com cadeado, título oculto. Reabrir exige confirmação
   dupla com atrito ("Pennebaker pede para não reler. Abrir mesmo assim?").
5. O Porteiro nunca comenta o conteúdo de uma expressiva. Nunca.

## 9. Códice (padrões no tempo)

Botão na pilha ("Ler o códice"). Só quando o usuário pede.

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
  · acento âmbar `#D9A542` · trava `#C4614D`. Tema escuro único (a página preta é o produto).
- **Tipo:** SF (sistema). Corpo 17/26. Labels 13 uppercase c/ tracking.
- **Espaço:** escala de 4. Raio 12.
- **Motion:** mínimo. A forma nasce com um fade curto (~250ms). Nada anima enquanto
  o usuário digita. `prefers-reduced-motion` respeitado.
- A UI inteira do editor: topo com [Pilha] e [Concluída], página, e UMA barra inferior
  discreta [Porteiro · Puxar]. Nada mais.

## 12. Não-objetivos (v1)

Chat/conversa. Streaks, XP, gamificação. Ouvinte emocional. Resumos. Busca semântica.
Sync/nuvem/conta. Compartilhamento. Templates em menu (a forma nasce da palavra).
Agenda/calendário. Android/web.

## 13. Pronto quando (critérios de aceite)

- [ ] Abrir o app → página em branco com cursor em <1s
- [ ] "quero correr de manhã" + Porteiro → chip WOOP + pergunta do obstáculo;
      "abrir forma" → campos vazios abaixo do meu texto
- [ ] "eu sou um vencedor" + Porteiro → trava Wood, sem forma
- [ ] Nota curta banal + Porteiro → silêncio (nenhum cartão)
- [ ] Expressiva: timer 15 min → tranca → reabrir exige dupla confirmação
- [ ] Puxar: esconde, escrevo de memória, revela comparação lado a lado
- [ ] Códice: 2–3 perguntas citando minhas frases; toque abre nota-resposta
- [ ] Em nenhum fluxo a IA insere prosa na minha nota

## 14. Casos-limite

Nota vazia + Porteiro → nada (sem trabalho). Sem rede → o papel continua; o porteiro
local não precisa de rede. Sem chave de API → correto: **não existe chave**. Nota
gigante → classificar pela voz do autor; nunca truncar o texto persistido.

---

## 15. Decisões do loop de qualidade (protótipo, ago 2026)

Três críticos (hierarquia, motion, UX) em 3 rodadas — decisões que valem para o app Swift:

- **Classificador nunca lê o mobiliário do app**: remover marcadores de forma e labels
  (preservando as respostas do usuário) antes de classificar; com forma na nota, só o
  trecho pós-forma pode pedir outro gesto, e heurísticas de formato não contam.
- **Mesma forma → silêncio** (o porteiro não pune quem usou a forma que ele ofereceu).
- **A pergunta do códice é cartão fixo não-editável** — nunca entra no texto da nota.
- **Expressiva sem escapatória digna**: sair durante o timer (qualquer rota, incluindo
  Puxar) → "Sair agora tranca." [Continuar escrevendo | Trancar e sair]; destino
  preservado após a tranca; beat de ~220ms entre véus.
- **Puxar**: desabilitado com página vazia; beat "Leia uma última vez — a nota vai se
  esconder." antes do blur; Revelar desabilitado até haver memória; saída "‹ voltar".
- **Copy**: sem citações acadêmicas na interface. Trava de afirmação: "Afirmação vazia
  não muda nada — e pesa em quem se estima pouco. Escreva por que um valor seu importa."
  Reabrir trancada: "Reler o desabafo reacende o que a escrita encerrou." / "Ela foi
  escrita para ficar fechada." Silêncio do porteiro: toast "silêncio." ~2,5s (é resposta,
  não bug); durante o timer: "o porteiro cala durante a escrita."
- **Concluída** (texto, ≥44pt, oculto quando vazio) no lugar de ✓; "Pilha" sem ☰;
  toda tela com rota de volta; alvos ≥44pt; página vazia SEM placeholder (decisão mantida).
- **Motion**: push/pop com parallax (curva drawer 0.32,0.72,0,1, ~400ms); sheet sobe
  opaco (nunca cross-fade de texto); cartão do porteiro é overlay (só transform/opacity,
  nasce da barra, transform-origin embaixo); véus materializam (blur+scale, exit mais
  rápido); staggers 45–70ms com teto; :active scale(0.94–0.98) em todo pressable;
  reduced-motion vira cross-fade; navegação interruptível com fila (nunca engolir toque).
- **Pilha**: preview mostra só a voz do autor; trancadas com data relativa; códice é
  botão discreto na topbar (as notas dominam a tela).
- Para o Swift: swipe-back nativo; "só o bloco novo borra" ao nascer a forma.

## 16. Busca (adição pós-protótipo)

Busca é **arquivo**, não memória: acha a nota para agir (GTD); lembrar continua sendo
trabalho do Puxar. Padrão Apple Notes (Jakob):

- Campo de busca na pilha + filtros por gesto em chips (WOOP, Se–então, Spec,
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
