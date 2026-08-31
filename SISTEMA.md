# Traço — sistema visual (Fase 2)

Travado antes do pixel. Âncora: Apple Notes dark + protótipo-espelho + SPEC §11/§15.
Contraste medido com `tastemaker/scripts/check_contrast.py` em 29 ago 2026.

## Paleta (só estes hex)

| Token | Hex | Papel | Par legal |
|---|---|---|---|
| fundo | `#0B0B0D` | página | — |
| superficie | `#161619` | cartão / campo busca | texto 16.6:1 |
| superficieAlta | `#1E1E22` | cartão da análise | texto ok |
| tinta | `#ECECEA` | prosa do autor | 16.62:1 no fundo |
| tintaSuave | `#9A9A96` | chrome, meta | ~7:1 no fundo |
| tintaFraca | `#8E8E8A` | labels de forma, vazio | ≥4.5:1 (o `#5C5C5A` do espelho falha 2.93:1 — não usar em texto) |
| linha | `#26262A` | hairline | estrutura, não texto |
| ambar | `#D9A542` | **um** acento vivo por vista | 8.81:1 no fundo (componente). Proibido como fill sob texto. |
| ambarSuave | `rgba(217,165,66,0.14)` | realce de busca, fill do timer | não é texto |
| trava | `#C4614D` | só o chip “Aviso” | recusa, nunca fill de botão |

**Regra Von Restorff:** âmbar é isolamento. Uma coisa âmbar por ecrã.
- Página vazia: só o cursor.
- Página com texto: Concluída **ou** Análise — não os dois + Recordar + timer.
- Notas: só o `+` (volta à página). Notas e filtros em tinta.

## Tipo (SF, semântico, Dynamic Type)

| Papel | Estilo | Default | Leading |
|---|---|---|---|
| corpo da nota | `.body` | 17 | ~1.53 (26/17) |
| chrome / botão | `.body` | 17 | — |
| barra inferior | `.subheadline.weight(.semibold)` | 15 | — |
| label de forma | `.caption.weight(.semibold)` + tracking 1.0–1.3 + uppercase | 12–13 | — |
| título de confirmação | `.title.weight(.semibold)` | 28 | apertado |
| vazio / meta | `.subheadline` em tintaSuave | 15 | — |

Nada de `.system(size:)` solto. Escala com o utilizador.

## Espaço (escala de 4)

4 · 8 · 12 · 16 · 22 · 28 · 44
- Margem da página: 22 (espelho)
- Alvo: 44
- Raio cartão: 12; cartão da análise: 14
- Grupo interno 8; entre grupos ≥16

## Motion (depois do layout)

| Momento | Curva | Duração | Origem |
|---|---|---|---|
| push/pop | cubic-bezier(0.32, 0.72, 0, 1) | 400ms | página recua −28% |
| sheet (Recordar) | sistema, fundo opaco | — | sobe; nunca cross-fade de texto |
| cartãa análise | ease-out | 160/260ms | origin embaixo, +14pt, scale 0.96 |
| forma nasce | ease-out | 480ms | **só o bloco novo** blur 3→0 |
| confirmação | materializa | entra 220ms, sai mais rápido | blur+scale; RM = opacity |
| press | 120ms | scale 0.94, opacity 0.7 | todo pressable |
| busca / tecla | **proibido** | — | Emil: ação frequente não anima |

`prefers-reduced-motion` → só opacity 180ms. Nada anima enquanto se escreve.

## Hierarquia por ecrã

1. **Página:** o vazio / o texto é figura. Chrome some para tintaSuave. Barra = hairline, sem dock pesado.
2. **Notas:** as notas são figura. Sem wordmark 34pt. Busca e chips recuados.
3. **Análise:** com o cartão aberto, a barra apaga. Uma pergunta, um ato.
4. **Recordar:** memória | nota, lado a lado. Sem score.
5. **Confirmação:** uma frase. Dois caminhos. Atrito no destrutivo.

## Expressiva (contradição §8 × §15)

§15 vence a saída: qualquer rota durante o timer → “Sair agora tranca.”
§8 vence o fecho honesto: **Concluída após ≥10 min** tranca direto (a escrita já mereceu a porta).
Fim do timer **grava e tranca**. Sem isso o método não existe.

## Caderno (a nota é o artefato)

A página não é um `TextEditor` nu. **Markdown é arquivo, não língua.** O autor
nunca escreve `#`, ` ``` `, `:::`, `|---|` ou `- [ ]`. A régua do teclado(gesto de iOS, não uma sintaxe do Traço) é o vocabulário visual da nota:
DOZE formas na régua (Título, Secção, Lista, Numerada, Tarefa, Citação,
Código, Tabela, Divisória, Verso, Ideia, Silêncio) — menu grande é template
em menu (SPEC §12). O catálogo completo (~136 slugs) vive só no ARQUIVO:
toda `:::slug` já gravada segue lendo e renderizando. O toque aplica a forma
ao bloco em que o cursor está. Edita-se o conteúdo — o título, o verso, o código — nunca a marcação.
A IA não escreve o bloco; o app só materializa o gesto. Formas novas
guardam-se como `:::slug` no arquivo; a página nunca mostra essa cerca.

Âncora de portal: Craft iOS (código em cartão, gutter, língua, sintaxe) traduzida
para o escuro do Traço. O portal inteiro é a figura (common region). Tokens de
sintaxe **não** são âmbar vivo — o âmbar da página continua um.

| Token | Hex | Papel |
|---|---|---|
| codigoFundo | `#12141A` | interior do portal de código |
| codigoGutter | `#0E1016` | coluna dos números |
| synChave | `#C9A56A` | keyword / chave |
| synValor | `#7EB8A8` | string / valor |
| synNumero | `#8AA4C8` | número |
| synTipo | `#9B8FBF` | tipo / classe |
| synFuncao | `#8EB4D4` | nome de função |
| synPontuacao | `#6E6E6A` | `{}[](),.;` |
| synComentario | `#8E8E8A` | comentário (tintaFraca) |
| synTexto | `#ECECEA` | código plain |

O portal de código **anuncia-se**: cabeçalho `</>` + língua + a palavra “código”,
gutter, sintaxe. Não é um dump. Tokens de sintaxe nunca usam o âmbar vivo.

Portais de ficheiro — cada tipo tem figura própria, não um anexo genérico:
código, imagem, áudio (onda + transporte), vídeo (16:9), PDF/ficheiro (extensão).
Prosa: títulos, listas, tarefas, tabela, citação, `código` inline, divisória,
e recipientes nomeados (verso, cena, ideia, silêncio…). Hierarquia por peso,
itálico, trilho e cartão — sem arco-íris. Um cromo por família, não uma
cor por nome.
