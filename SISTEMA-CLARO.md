# Traço — o mundo claro (sistema visual, rev. 1)

> Nasce do calendário que o Cursor clonou do vídeo de @rsuyoy (MovinDesign,
> 01/set/2026) e da palavra do dono em 02/set: "essa mistura de preto e branco
> ficou incrível, muito melhor que a versão normal do Traço". Este arquivo é a
> Fase 2 do roteador: tokens travados ANTES de tocar em qualquer tela. Ele
> substitui a paleta do `SISTEMA.md` e pede a ADR do fim. Medições: capturas do
> app real (`simctl`), `tastemaker/scripts/extract_palette.py` e
> `check_contrast.py` em 02/set/2026. Nada aqui é gosto: cada valor tem número.

## 1. O DNA do clone (o que faz ele parecer caro)

Lido nos quadros do vídeo e nas capturas do app, não em adjetivos:

1. **Papel, não tela.** Fundo `#F4F4F2` (medido `#F2F2F0` a `#F9F9F8`), cinza
   quente e fosco, sem branco puro atrás do conteúdo. O branco puro só aparece
   no chrome que FLUTUA (a barra de controles), o que cria duas alturas com uma
   cor só.
2. **Um acento: o preto.** O estado selecionado é uma pílula `#2C2C2E` com
   texto branco. Nenhuma cor de marca disputa. As cores existem só como
   TINTA de categoria, pastel no fundo e escura na letra, sempre da mesma matiz
   (azul `#C9D8F5` / `#2F4F8A`, 5,6:1). É a lei do §11 do Traço, "um acento
   por tela", cumprida com o preto no lugar do âmbar.
3. **Tudo é cápsula.** Controles em raio total; chips do dia são círculos de
   44pt; cartões em raio 18 contínuo. Um vocabulário de forma só, e por isso
   nada precisa de borda: a forma separa.
4. **Hairline em vez de linha.** Divisórias a 8% de preto (`#1C1C1E` × 0,08).
   Ninguém vê a linha; vê a ordem.
5. **Duas sombras, nenhuma dura.** Barra flutuante: preto 8%, raio 16,
   deslocamento 6. Campo de prosa: preto 6%, raio 12, deslocamento 4. Cartões
   sobre o papel NÃO têm sombra: são tinta chapada. Sombra só no que flutua.
6. **Título com presença.** 32pt bold, tracking −0,6, alinhado à esquerda, com
   dois botões circulares de 36pt à direita. O título é o único elemento
   grande; tudo o resto é 11 a 16pt.
7. **Tipo secundário cinza, não pequeno.** Horas, letras de dia e escalas
   inativas ficam em cinza médio no MESMO tamanho, não menores. Hierarquia por
   cor, não por corpo.
8. **Movimento com massa e sem pressa.** Mola `response 0,55 / damping 0,86`
   para a troca de escala; pressão `scale 0,94` em todo toque; `reduceMotion`
   vira fade curto.

**O que NÃO se carrega** (tells do clone que o Traço não herda): strings em
inglês e calendário `en_GB`; eventos-semente falsos; cinco itens iguais na
barra; alvos de 36pt; fontes `.system(size:)` sem Dynamic Type; a transição
por wipe diagonal com blur entre quatro views (é troca, não desdobramento);
título a 56pt do topo por chute em vez de safe area; texto secundário
`#8E8E93` que mede 2,96:1 sobre o papel e reprova até como ícone.

## 2. Tokens, em três camadas

Regra do roteador: componente nunca cita hex; cita o token semântico. A troca
de mundo (escuro → claro) acontece SÓ na camada semântica.

### 2.1 Primitivos (valores crus)

| Token | Hex | Origem |
|---|---|---|
| `papel` | `#F4F4F2` | fundo do clone (medido) |
| `branco` | `#FFFFFF` | barra flutuante |
| `nevoa` | `#EBEBEA` | campo de prosa |
| `cinza-200` | `#E8E8E6` | chip inativo |
| `cinza-300` | `#C7C7CC` | dias fora do mês, desabilitado |
| `cinza-400` | `#86868B` | **corrigido**: ícones e letras grandes (3,3:1) |
| `cinza-600` | `#5F5F64` | **corrigido**: texto secundário; 5,7:1 no papel, 5,2:1 no chip (o `#6E6E73` media 4,1 sobre o chip) |
| `carvao` | `#2C2C2E` | pílula selecionada |
| `tinta` | `#1C1C1E` | texto |
| `ambar` | `#D9A542` | a assinatura do Traço, só como FILL |
| `ambar-tinta` | `#7A5A16` | âmbar que se lê sobre o papel (5,9:1) |
| `aviso` | `#B5432F` | recusa; medir antes de usar como texto |

Tintas de domínio (fundo pastel · letra escura, mesma matiz). As quatro do
clone medem 4,8 a 5,7:1; as três novas precisam de medição antes de entrar.

| Domínio | Fundo | Letra | Estado |
|---|---|---|---|
| Trabalho | `#C9D8F5` | `#2F4F8A` | medido 5,6:1 |
| Saúde | `#C8E6D4` | `#2D6A4F` | medido 4,8:1 |
| Pessoas | `#F3D4C4` | `#8A4B2F` | medido 4,8:1 |
| Casa | `#D9C8F0` | `#5A3D7A` | medido 5,7:1 |
| Dinheiro | `#F2E2B8` | `#6B4E0F` | medido 6,0:1 |
| Estudo | `#C9E3E8` | `#245A66` | medido 5,7:1 |
| Ideias | `#E4E4E2` | `#3A3A3C` | medido (é o "outro" do clone) |

Isto substitui as DUAS taxonomias de hoje (`CategoriaEvento` com 5 e
`Dominio` com 7) por uma: o domínio da nota é o domínio do evento.

### 2.2 Semânticos (o que muda de mundo)

| Semântico | Claro | O que era no escuro |
|---|---|---|
| `fundo` | `papel` | `#0B0B0D` |
| `superficie` | `branco` | `#161619` |
| `superficieBaixa` | `nevoa` | `#1E1E22` |
| `chip` | `cinza-200` | ambarSuave |
| `chipAtivo` | `carvao` | âmbar |
| `tinta` | `tinta` | `#ECECEA` |
| `tintaSuave` | `cinza-600` | `#9A9A96` |
| `tintaFraca` | `cinza-400` | `#8A8A8F` |
| `tintaMorta` | `cinza-300` | `#6B6B70` |
| `linha` | tinta × 0,08 | `#26262A` |
| `acento` | `ambar` (fill) · `ambar-tinta` (texto) | âmbar |
| `sombraFlutuante` | preto 0,08 · raio 16 · y 6 | (não havia) |
| `sombraCampo` | preto 0,06 · raio 12 · y 4 | (não havia) |

**O âmbar sobrevive, mas muda de emprego.** Sobre o papel ele mede 2,0:1 como
texto: reprova. Fica como assinatura em três lugares só: a pílula "Nova"
(texto escuro sobre âmbar, 7,6:1), o cursor da página, e o fill do filtro
ativo. Estado selecionado vira `carvao`, como no clone. Texto âmbar, quando
inevitável (o realce da busca), usa `ambar-tinta`.

### 2.3 Componentes (spec por estado, escrita antes de construir)

**Pílula de controle** (D W M Y; Todas · WOOP · …; Notas · Padrões · Perfil):
| Estado | Fundo | Texto | Escala |
|---|---|---|---|
| padrão | transparente sobre `nevoa` | `tintaSuave` | 1 |
| selecionado | `chipAtivo` | branco | 1 |
| pressionado | idem | idem | 0,94 |
| desabilitado | transparente | `tintaMorta` | 1 |
Altura 36 dentro de um trilho de 44; o alvo é o trilho, nunca a pílula.

**Chip do dia / do domínio:** círculo ou cápsula em `chip`, texto
`tintaSuave`; ativo em `chipAtivo` com branco; 44pt de alvo sempre.

**Cartão tingido** (evento, nota com domínio): fundo pastel do domínio, letra
escura do domínio, raio 18, sem sombra, ícone 12pt + título 16 semibold +
meta 13 medium. Nota sem domínio: `superficieBaixa` com `tinta`.

**Barra flutuante:** `superficie` em cápsula, `sombraFlutuante`, 14pt das
bordas, 8pt do fundo. Carrega no máximo: um par de modos + um trilho de
escalas + uma ação. Se precisar de mais, é outra tela.

**Campo de prosa:** cápsula `superficieBaixa`, `sombraCampo`, ícone à
esquerda em `tinta`, placeholder em `tintaSuave`, ação à direita num quadrado
36 de raio 10 em `chip`.

**Ficha (sheet):** `fundo` papel, botão fechar circular 36 em `chip`, chip de
categoria central, título 34 bold centrado, seções com rótulo 13 medium em
`tintaSuave`, campos em `superficieBaixa` raio 14.

**Barra de destinos (§20):** vira clara. `superficie` com hairline no topo,
ícone 21 + `.caption2` tracking 0,4; ativo em `tinta` (não em âmbar: âmbar
como texto reprova), inativo em `tintaFraca`; a pílula "Nova" âmbar com
glifo escuro lidera a barra, separada por fio. Três destinos mais o
calendário: quatro, nunca cinco iguais.

## 3. Tipo

SF, sempre. Todos os tokens passam a escalar com Dynamic Type
(`relativeTo:`), o que fecha o defeito do §22 de uma vez.

| Papel | Tamanho | Peso | Tracking | relativeTo |
|---|---|---|---|---|
| título de tela | 32 | bold | −0,6 | `.largeTitle` |
| título de ficha | 34 | bold, centrado | −0,6 | `.largeTitle` |
| corpo (voz do autor) | 20 | regular | 0 | `.body` |
| chrome / botão | 17 | regular / semibold | 0 | `.body` |
| cartão | 16 | semibold | 0 | `.callout` |
| meta / hora | 13 | medium, numerais tabulares | 0 | `.footnote` |
| letra de dia / rótulo | 11 | medium | 0 | `.caption2` |
| rótulo de seção (formas) | 11 | semibold, caixa alta | +1,2 | `.caption2` |

Números de hora e data em `monospacedDigit()`: a coluna 17:00 / 18:00 não
pode dançar.

## 4. Forma, espaço, altura

- Raio: cápsula para controle; 18 para cartão grande; 14 para campo; 10 para
  o quadrado de ação; 8 para o dia selecionado na grade. Dentro menor, fora
  maior (raios concêntricos: externo 18, interno 18 − padding).
- Espaço: escala de 4. Margem de tela 20. Entre itens 12. Entre grupos 32.
  Chips com 6 de vão. Barra flutuante a 14 das bordas.
- Alvo mínimo 44 em tudo que se toca. O clone tem 36 em vários lugares; aqui
  36 é o desenho, 44 é o alvo (`contentShape` no trilho).
- Só duas alturas: o papel (0) e o que flutua (a barra e o campo). Cartões
  não flutuam.

## 5. Movimento

- Troca de escala e de estado: mola `response 0,55 / damping 0,86`.
- Pressão: `scale 0,94`, 120ms, em todo pressable (já existe: `PressaoDiscreta`).
- Troca de aba: cross-fade 0,18s (§20) continua; aba não tem direção.
- **O desdobramento.** O vídeo tem UM objeto em quatro zooms: a faixa da
  semana do dia É a primeira linha da semana, que É uma linha do mês, que É
  um quadrado do ano; o chip do dia âncora fica no lugar e o resto cresce em
  volta. O clone hoje troca quatro views com wipe diagonal e blur. A Fase 4
  refaz isto com uma grade só, cada célula de dia com geometria casada entre
  escalas e a ALTURA animando (§21: um objeto, um driver; nada de cross-fade
  entre irmãos). Blur em tela inteira sai: custa GPU e esconde o objeto.
- `reduceMotion`: fade 0,15s em tudo.
- Nada anima enquanto o autor digita (§11). O mundo claro não muda isso.

## 6. Onde entra, tela a tela

| Tela | O que muda | Ordem |
|---|---|---|
| `Tema.swift` | as três camadas acima; `.system(size:)` → `relativeTo` | 1 |
| Barra de destinos | clara, "Nova" volta a ser pílula, quatro destinos | 2 |
| Calendário | **feito em 02/set**: safe area; pt-BR; semente fora; domínio único; alvos 44; desdobramento por geometria casada; `CalendarioTema` é a primeira instância destes tokens | 3 |
| Notas | cartões tingidos por domínio; filtros em trilho de pílulas; busca em campo de prosa | 4 |
| Página em branco | papel `#F4F4F2`, cursor âmbar, tinta `#1C1C1E`; régua em chips; cartão da Análise como ficha | 5 |
| Recordar, Padrões, Perfil | pílulas, chips, ficha | 6 |
| Cerimônias (véu, queima, Revelar) | rejulgar em VÍDEO sobre papel claro: o fogo lê melhor no claro; o véu precisa de material claro | 7 |

Ordem do `REDESENHO.md`: tokens → paleta → estados → layout → componentes →
vazios/erros → escala tipográfica. Uma mudança por commit, capturas antes e
depois, e o veredito do dono em vídeo antes de dar por bom.

## 7. Para elevar além do clone

1. **Raios concêntricos** na barra flutuante e nas fichas: casca externa 18,
   núcleo 18 − padding; hoje o clone usa raio igual dentro e fora.
2. **Sombra com tinta**: sombra cinza-quente (`tinta` a 8%), não preto puro.
3. **Hairline interna** de 1pt a 60% de branco no topo da barra flutuante:
   é o que separa "vidro sobre alumínio" de "cartão".
4. **Numerais tabulares** em hora, data e contador dos campos Destilar.
5. **Alinhamento óptico**: ícone junto de texto desce 1pt; play em círculo
   avança 1pt.
6. **Vazios desenhados**: dia sem nada mostra a linha do "agora" e mais nada;
   mês sem nada mostra a grade e o dia; nunca uma frase de desculpa.
7. **Um acento por tela**, agora o preto; o âmbar aparece uma vez, na "Nova".
8. **Materiais de verdade** só onde há profundidade real (véu, folha de
   confirmação): `.regularMaterial` claro com hairline, nunca blur de tela
   inteira em transição.

## ADR 2026-09-02h — O mundo claro (proposta, para o dono assinar)

§11 dizia "tema escuro único, a página preta é o produto". Em 02/set o dono
viu o calendário claro e decidiu: o Traço inteiro passa a viver no mundo
claro do clone, com a mesma paleta e elementos ainda mais limpos. Regras que
decorrem: um mundo só, nunca dois (hoje o app vira claro/escuro por aba,
contra §20 e §21); o preto é o acento de estado e o âmbar é assinatura de
ação, uma vez por tela; todo texto mede ≥4,5:1 sobre o papel e todo ícone
≥3,0:1; o §22 fecha junto, porque os tokens novos já nascem escalando.
Os hex deste arquivo são a fonte da verdade; `Tema.swift` os cita, nunca os
inventa.
