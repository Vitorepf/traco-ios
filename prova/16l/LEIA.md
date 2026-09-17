# prova/16l — contexto da Sábia (E7). Régua registrada em 16/09/2026, antes da corrida no Air

**Alavanca (E7, análise em `ferramentas/orca/analise-atlas-contexto.md`):** (1) um serializador só (`VozDoAutor.rotulada`) leva a nota com os rótulos do método a todas as rotas que mandam campos ao modelo — Notas, Conselho (`situacao`), Padrões, Recordar (nota livre), a pergunta da Página (citadas, vizinhas, ecos); a busca por palavras segue sem rótulo; o Trabalho fica fora (a intenção é texto de tela). (2) Retrato com tipo e data em cada linha, pessoa neutra, corte por bloco inteiro com recibo. (3) Nas Notas, o catálogo das formas só quando a pergunta fala de forma ou método; o Retrato só com os blocos cujas citações dividem assunto com a pergunta (nenhum: os blocos que cabem, na ordem, até 500). O teto por nota saiu na volta 3 (revisão: o recorte por linha deixava só o título de nota de parágrafo longo). (4) O pacote registra o que ficou fora; a tela nomeia só a nota do autor que não coube (texto do líder).

**Fixture:** `prova/16k/lote-remedida.json` (sha256 `eb6519cb752b0c8dae9ba00ee7d82d332ad0bf210be295c4782cf74316484761`), o mesmo da remedida da V: 7 casos da V (6 cegos de precedência + `real-01`) + 30 da 16i + 4 alheias, × 3 = 123 casos.

**Base:** remedida da V, corrida `88B31333-6889-4547-9452-E8853DA357A9` (`prova/16k/LEIA.md`).

**Régua:**
1. `real-01` × 3: a nota entra e a resposta diz que a decisão foi não dar desconto e oferecer o bônus, sem dar o desconto como decisão nem como conflito — leitor cego, 3/3.
2. 16i: a seção certa entre as enviadas ≥ 28/30 em cada repetição, citada com mestre, vídeo e minuto (`prova/16i/contar.py`). Base 29/29/29.
3. Precedência: a nota esperada no pacote ≥ 5/6 nos 6 cegos em cada repetição (`prova/16k/contar_v2.py`). Base 6/6/6.
4. Voz 0 e gênero 0 nas 123 respostas — leitor cego.
5. Respostas vazias: 0 de 123 (base 0).
6. Alheias sem obra enviada: registrado (base 11/12).
7. Tamanho do pedido: média de `pacoteChars` (o que foi ao modelo) e, sobre as MESMAS fontes, `pacoteCharsInteiros` (catálogo e Retrato inteiros) × `pacoteCharsPelaPergunta` (catálogo e Retrato pela pergunta). Registrado; depois ≤ antes.

**Fora desta medida (declarado antes):** a rota do Conselho com rótulo tem teste de ponta no 17e, não corrida no Air (a sonda `escolherRegra` passa a montar a `situacao` quando a fixture traz `campos`). Padrões e Recordar: teste no 17e, sem corrida (Recordar segue cortada por qualidade).

## Remedida — corrida `95B2EC14-FA52-4A61-A7E9-9875C2D51219` (Air, 00:18Z–01:16Z de 17/09)

Binário `Traco.debug.dylib` sha256 `fa36839575758f7b…` (volta 3), HEAD `2650511f` + diff da E7. `remedida-e7-grok.jsonl` (248 linhas). Contagem: `contar_e7.py`, `prova/16i/contar.py`, precedência pelo mesmo critério de `prova/16k/contar_v2.py`.

| régua | medido |
|---|---|
| 1. `real-01` diz a decisão certa (leitor cego) | **3/3** |
| 2. 16i: certa entre as enviadas ≥ 28/30 e citada com minuto | **29 / 29 / 29** (só `p-19`, como na base) |
| 3. precedência: nota esperada no pacote ≥ 5/6 | **6/6, 5/6, 6/6** (`prec-04` rep 2 levou só a nota que corrige) |
| 4. voz e gênero (leitor cego) | **0/123 e 0/123** |
| 5. respostas vazias | **0 de 123** |
| 6. alheias sem obra enviada | 11/12 (`alheia-3` rep 2, como a base) |
| 7. tamanho do pedido | catálogo e Retrato inteiros **5.601** → pela pergunta **3.302** caracteres de média (−41%); o pedido real (com a escolha de seções do Grok) **1.491** de média |

**Regressão vista fora da régua pré-registrada:** `prec-02` cumpriu o que devia 0 de 3 (na remedida da V, 3 de 3) — o modelo leu «O que estou decidindo» como o que estava em jogo. Diagnóstico no mesmo binário (`leitura-remedida-e7.md`): 2 de 3 com o Retrato e 3 de 3 sem ele, variância num caso cujo «Decidi» guarda só a data. Fica como dívida da E9 (síntese fiel que conclui).
