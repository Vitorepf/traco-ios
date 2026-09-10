# ENTRADA — como se pergunta à sábia (ADR 2026-09-10i)

**Linha do ciclo.** Volta de frontend da IA, ordem do dono das 16h50 (LACO 10/09); intenção "resolver a experiência, o design e o uso da IA"; obstáculo "o campo 'buscar ou perguntar' no pé das Notas é um campo de sistema pousado sobre as abas — reprova no teste do genérico e o dono chamou-lhe lixo"; prova: a marca "?" (`MarcaDePergunta`) em toda tela com `TituloTela`, a busca de volta à lista, o pé livre, suíte no teste 4, jornada real no aparelho de conta em `large` com o pé no quadro, vídeo de 15 s.

**Régua do dono:** *"não parece feito por IA"*; busca é busca; perguntar é um gesto com identidade do Traço, o mesmo em toda tela; sem campo permanente no pé; tastemaker + curva-zero; vídeo de 15 s, tela inteira.

## 1. Diagnóstico (design-router, fase 5 — auditar antes de tocar)

**O "antes" é o branch que está a ser mesclado agora** (`Vitorepf/sistema-ia`, ADR 10f), fotografado pela própria cadeira no aparelho de conta `34CC3F94` às 15h40, em `large`, **tela inteira com o pé** — e o que o dono viu às 16h50 é o irmão mais velho dele (o campo "buscar ou perguntar" da 05e/09k). Copiei as três capturas para `ferramentas/orca/entrada-da-ia/antes-*.png` para que o antes e o depois estejam na mesma pasta. Conferi na tela e no código, não na auditoria das 14h40 (`auditoria-ia-na-tela.md`, que ainda descreve o campo duplo — ela é datada: o modo "perguntar" da 10f já tinha substituído o campo duplo, e é o que o dono reprovou).

| captura | o que se vê, com o pé | defeito nomeado | onde |
|---|---|---|---|
| `antes-01-notas-pe-large` | a lista; no pé, uma linha "buscar" com a palavra "perguntar" à direita, e logo abaixo a barra de abas — **dois andares de chrome no pé** | campo de texto de sistema, permanente, pousado sobre as abas; o gesto de perguntar é uma palavra num campo de busca | `NotasView.campoBusca` no `safeAreaInset(.bottom)` |
| `antes-02-modo-perguntar-large` | a mesma linha virou "pergunte sobre as suas notas" com um ✕ — o mesmo campo, outro placeholder | o modo é um placeholder: nada do Traço; trocando o nome, serve a qualquer app | idem |
| `antes-03-resposta-pe-large` | a folha da resposta (boa, G4 passou) e, no pé, o campo de novo: "pergunte de novo" | o campo continua no pé mesmo com a resposta aberta; a folha está pousada em cima dele | idem |

**Separação das falhas (REDESENHO.md §2):**
- **uso:** perguntar mora num campo que também é busca (ou que já foi); nenhuma outra tela do arquivo tem o gesto; a página pergunta de outro jeito (a linha "?"). Quatro telas, dois gestos, um só lugar que responde.
- **estrutura:** o pé tem dois andares (campo + abas). O que o polegar alcança primeiro é um campo genérico.
- **visual/identidade:** o campo é o `TextField` do sistema com prompt; a única coisa do Traço é a tinta. Teste do genérico: reprova.
- **implementação:** `entrada` servia à busca e à pergunta; o modo era um `Bool` a trocar o placeholder.

**O que funciona e não se mexe:** a folha da resposta (10f): pergunta como título, espera com tempo e parar, resposta inteira, fontes tocáveis, um Fechar. A linha "?" da página (ADR o). A lista da 09k.

**Curva-zero, antes:** perguntar a primeira vez = 3 toques (perguntar, escrever, enviar) num campo cujo nome não diz o que o Enter faz; buscar = 1 toque + escrever num campo no pé, onde nenhum app de notas a põe.

## 2. O desenho (design-router: tarefa → estrutura → direção → implementação → jornada)

**Tarefa.** Alguém, no arquivo, quer perguntar às suas notas; ou quer achar uma nota. Duas intenções, cada uma com o seu lugar.

**As quatro perguntas do despacho, respondidas pela estrutura:**

1. **Onde mora o gesto, se não é um campo no pé?** No sinal que o Traço já tem para pergunta: **a linha "?"**. Na página é a linha escrita ("? qual plano compensa", ADR o). Onde não há página para escrever, é **a marca "?" em âmbar-tinta na linha do título** — `MarcaDePergunta`, em `TituloTela`, por isso a mesma em Notas, Padrões e Perfil sem uma linha de código por tela. O toque abre a folha da conversa (10f) **vazia, com a linha "? |" e o teclado de pé**. A linha não é campo permanente: existe dentro da folha, e a folha existe enquanto se pergunta. Com resposta aberta, a linha "?" vive **no pé da folha**, depois do retorno, como continuação — nunca no pé da tela.
2. **Como se sabe que existe?** A marca é visível, um glifo, sempre no mesmo canto; o rótulo diz "Perguntar às suas notas"; a primeira linha da folha diz o que é ("pergunte sobre as suas notas"). E há **uma segunda porta, para quem já aprendeu o "?" na página**: escrever "?" na linha da busca abre a mesma folha com a pergunta começada. Curva-zero: reconhecimento (a marca) para a primeira vez, recordação (o "?" escrito) para o uso repetido — e as duas portas dão no mesmo lugar.
3. **O que acontece à busca?** Volta ao lugar de busca: **uma linha da lista**, sob o título, antes das notas — "buscar", hairline, caret âmbar, sem cartão nem lupa (a linha da 09k, no lugar onde todo app de notas a põe). Só filtra. A busca em escrita passa a viver na `ConversaNotas` (como a conversa), porque a view é recriada a cada troca de aba (09c) — antes vivia no mesmo `entrada` da pergunta.
4. **A pergunta que já se escreve na nota é a mesma coisa?** É o **mesmo sinal, com dois alcances**: na página, a pergunta é sobre esta nota (rota `responder`, indisponível por qualidade hoje); no arquivo, é sobre as notas todas (`responderNasNotas`). Um sinal, uma folha de resposta (10f), dois contextos — e é isto que a ADR 10i diz.

**Direção.** Nada de novo no sistema: `Tema.ambarTinta` (a assinatura de ação como texto), `Tema.corpo` (a letra da página), `Tema.linha` (hairline), `Tema.alvo`. O "?" é o glifo do próprio texto, não um ícone. Teste do genérico: um "?" âmbar no título e uma linha "? |" na folha não servem a outro app — são o hábito de escrever "?" na página, levado ao arquivo.

**O pé da tela fica com a barra de abas e mais nada.** É a mudança que o dono vê primeiro.

## 3. Curva-zero, em toques

| tarefa | antes (10f) | depois (10i) |
|---|---|---|
| perguntar a primeira vez (das Notas) | 3: "perguntar" no campo do pé, escrever, enviar | 3: marca "?", escrever, enviar — e a folha nasce com o teclado de pé |
| perguntar de Padrões ou do Perfil | não existia (ir às Notas + 3) | 3: a mesma marca, escrever, enviar |
| perguntar de novo | 2, no campo do pé | 2, na linha "?" no pé da folha (depois de ler) |
| perguntar por escrito, como na página | não existia | "?" + a pergunta na busca + enviar |
| buscar | 1 toque + escrever, no pé | 1 toque + escrever, na primeira linha da lista |
| voltar à lista | 1 (Fechar) | 1 (Fechar, o único) |
| chrome no pé da tela | 2 andares (campo + abas) | 1 (abas) |

**Custo assumido:** quem entrava na busca com o polegar sem esticar (a barra do pé era zona do polegar, 05e) agora sobe até a primeira linha — o preço de a busca ser busca. E a marca é um glifo: quem não a reconhecer descobre pelo toque, sem perder nada (Fechar devolve tudo).

## 4. Estados exercitados

| estado | como se chega | captura (teste 4, `large`, tela inteira) |
|---|---|---|
| lista com busca e marca | Notas | `t4/01-lista-large.png` |
| folha vazia, linha "?", caret | marca "?" | `t4/02-folha-vazia-large.png` |
| pergunta escrita, enviar | escrever | `t4/03-escrita-large.png` |
| falha junto da pergunta, "Perguntar de novo", sem linha "?" | teste 4 sem provedor que responda | `t4/05-resposta-large.png` |
| lista de volta, com a marca | Fechar | `t4/07-lista-de-volta-large.png` |
| a porta pela busca ("?") | escrever "?" na busca | `t4/08-porta-busca-large.png` |
| a mesma marca em Padrões, e a folha nas Notas | Padrões → "?" | `t4/10-padroes-large.png`, `t4/11-padroes-leva-as-notas-large.png` |
| pensando, tempo, parar (10f) | ensaio `-ensaio-espera-nas-notas` | `t4/ensaio-espera-large.png` |
| resposta com a linha "?" no pé da folha | ensaio `-ensaio-resposta-longa-nas-notas` | `t4/ensaio-resposta-cauda-large.png` |
| resposta REAL | aparelho de conta | ver §6 |
