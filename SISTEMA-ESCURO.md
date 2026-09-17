# Traço — o mundo escuro (sistema visual, rev. 1)

**Escopo operativo — linguagem visual, subordinada ao propósito vigente.** Irmão do [SISTEMA-CLARO.md](SISTEMA-CLARO.md), que continua sendo a régua: o mundo escuro não é um tema alternativo nem uma inversão automática, é a MESMA lei escrita com a luz do outro lado. Onde este arquivo cala, vale o claro.

> Nasce do pedido do dono em 17/set/2026: "preciso também que em meu perfil
> tenha um modo para alternar em modo claro e modo escuro. lembrando os dois
> modos tem que manter a forma mais ultra premium, e mais refinada possível".
> A régua é o que já existe — em 17/set o dono disse que o design do app está
> no melhor ponto que já esteve. Por isso o claro não se mexeu: os hex do
> `SISTEMA-CLARO.md` estão congelados por teste (`MundoEscuroTests`), e o
> escuro é que teve de subir até eles. Medições: WCAG 2.2, 1.4.3, calculadas
> sobre os hex em 17/set/2026. São registros de medição e escolhas de projeto;
> números de contraste não demonstram sozinhos qualidade da experiência, e
> nada aqui foi visto ainda em aparelho.

## 1. O que muda, e é só isto

A 02h escreveu oito leis. Sete atravessam inteiras:

1. **Papel, não tela** → **grafite, não vazio.** O fundo é `#0F0F12`, um
   quase-preto frio, e não `#000000`. Preto puro tira o chão do que flutua e
   faz o OLED borrar no rolar; o grafite mantém as duas alturas.
2. **Um acento** → o mesmo, do outro lado. O estado selecionado é uma cápsula
   `#E6E6EA` (osso) com tinta `#121216`. É o mesmo objeto de contraste máximo
   do claro (lá, carvão sobre branco), com a tinta invertida. O âmbar continua
   IDENTIDADE, fill, uma vez por tela.
3. **Tudo é cápsula** — igual.
4. **Hairline em vez de linha** — igual, em branco a 10 % no lugar de tinta a
   8 %: 8 % de branco sobre grafite não chega a existir.
5. **Duas sombras, nenhuma dura** — igual, mas em PRETO e mais fundas (0,45 e
   0,40 no lugar de 0,08 e 0,06). Cinza-quente a 8 % sobre grafite é nada.
6. **Título com presença** — igual.
7. **Tipo secundário cinza, não pequeno** — igual, com os dois cinzas
   finalmente separados (ver §3).
8. **Movimento com massa** — igual, sem uma linha de diferença.

**A única lei que inverte** é a direção da altura. No claro, o que flutua é
MAIS CLARO que o papel (branco sobre `#F4F4F2`) e o que afunda é mais escuro
(névoa `#EBEBEA`). No escuro, os dois vão para o mesmo lado: em direção à luz.
O que flutua é `#1C1C22`, o campo afundado é `#17171C`, e quem separa um do
outro é o fio de luz no topo mais a sombra de contato — não a direção.

A razão é física, não gosto: no papel a luz é o branco e só há um caminho
para longe dele; no grafite a luz é o que sobra, e afundar mais é sumir.

## 2. Tokens, nos dois mundos

Regra do roteador, sem emenda: **componente nunca cita hex, cita o token
semântico**. O que mudou é que um token agora tem DOIS valores, escritos no
mesmo lugar e na mesma linha (`Color(claro:escuro:)`, em `Tema.swift`), e
quem resolve é a aparência da janela. Nenhuma das ~220 telas do app precisou
de um `if escuro`.

### 2.1 Semânticos

| Semântico | Claro | Escuro | O que é |
|---|---|---|---|
| `fundo` | `#F4F4F2` | `#0F0F12` | papel · grafite |
| `superficie` / `superficieAlta` | `#FFFFFF` | `#1C1C22` | o que flutua |
| `superficieBaixa` | `#EBEBEA` | `#17171C` | névoa · bruma: campo, trilho |
| `chip` | `#E8E8E6` | `#212127` | controle em repouso |
| `chipAtivo` | `#2C2C2E` | `#E6E6EA` | carvão · osso: o ESTADO |
| `sobreAtivo` | `#FFFFFF` | `#121216` | a tinta que pousa no acento |
| `tinta` | `#1C1C1E` | `#E9E9EC` | texto |
| `tintaSuave` | `#5F5F64` | `#9E9EA6` | secundário |
| `tintaFraca` | `#68686C` | `#8E8E98` | terceiro nível |
| `tintaMorta` | `#C7C7CC` | `#3A3A42` | SÓ desabilitado real |
| `linha` | tinta × 0,08 | branco × 0,10 | hairline |
| `luzBorda` | branco × 0,6 | branco × 0,12 | o fio de luz no topo |
| `ambar` | `#D9A542` | `#D9A542` | a assinatura, igual nos dois |
| `ambarTinta` | `#7A5A16` | `#D9A542` | o âmbar que se lê |
| `sabia` | `#1F6B5A` | `#46AE93` | a marca dela |
| `aviso` | `#B5432F` | `#E06A54` | recusa |
| `veu` | preto × 0,28 | preto × 0,55 | a folha que afunda na pilha |
| `sombraContato` | tinta × 0,10 | preto × 0,50 | |
| `sombraFlutuante` | tinta × 0,08 | preto × 0,45 | |
| `Sombra.campo` | tinta × 0,06 | preto × 0,40 | |
| `sombraCamada` | tinta × 0,22 | preto × 0,55 | a folha do arquivo em movimento |

**O âmbar não muda de tom, e muda de emprego pela segunda vez.** No papel ele
mede 2,0:1 como texto e por isso existe `ambarTinta`, um âmbar escurecido. No
grafite ele mede **8,6:1** sozinho: `ambarTinta` no escuro É o âmbar, sem a
muleta. É a única cor da casa que atravessa os dois mundos idêntica, e o
portão a mede para que continue assim.

### 2.2 Domínio (fundo tingido · letra da mesma matiz)

No claro, fundo pastel e letra escura. No escuro, fundo fundo e letra clara —
a mesma matiz, a mesma leitura antes de ler.

| Domínio | Fundo claro | Letra clara | Fundo escuro | Letra escura | Medido (claro · escuro) |
|---|---|---|---|---|---|
| Trabalho | `#C9D8F5` | `#2F4F8A` | `#1C2A46` | `#8FAEE0` | 5,6 · 6,3 |
| Saúde | `#C8E6D4` | `#2D6A4F` | `#14332A` | `#7FC3A2` | 4,8 · 6,7 |
| Pessoas | `#F3D4C4` | `#8A4B2F` | `#3A2318` | `#D9A177` | 4,8 · 6,5 |
| Casa | `#D9C8F0` | `#5A3D7A` | `#2A1E42` | `#AC91D6` | 5,7 · 5,7 |
| Dinheiro | `#F2E2B8` | `#6B4E0F` | `#33280F` | `#C9AF6A` | 6,0 · 6,8 |
| Estudo | `#C9E3E8` | `#245A66` | `#142E35` | `#82B9C6` | 5,7 · 6,6 |
| Ideias | `#E4E4E2` | `#3A3A3C` | `#26262A` | `#ADADB4` | 8,9 · 6,8 |

O fundo tingido guarda a mesma distância do papel nos dois mundos (1,16 a
1,42 no claro; 1,24 a 1,40 no escuro): o cartão continua a ser tinta chapada
sobre o plano, não um objeto que flutua.

### 2.3 Sintaxe do portal de código

| Papel | Claro | Escuro | Medido sobre o fundo do portal |
|---|---|---|---|
| texto | `#1C1C1E` | `#E9E9EC` | 14,3 · 14,7 |
| chave | `#7A4E10` | `#C0954E` | 6,0 · 6,5 |
| valor | `#1F6B5A` | `#4FAE90` | 5,3 · 6,6 |
| número | `#2F4F8A` | `#7E9CCE` | 6,8 · 6,4 |
| tipo | `#5A3D7A` | `#A88CD0` | 7,4 · 6,2 |
| função | `#245A66` | `#6EA8B6` | 6,5 · 6,8 |
| pontuação | `#6E6E73` | `#8A8A92` | **4,25** · 5,2 |
| comentário | `tintaFraca` | `tintaFraca` | 4,7 · 5,5 |

## 3. O que o escuro ganhou que o claro ainda deve

O `Tema` registra, desde a ADR 04d, que `tintaSuave` (5,77:1) e `tintaFraca`
(5,04:1) "ficaram perto — dois cinzas que quase se encostam. Um deles deve
morrer (FILA); ler vem antes de escalonar". No escuro os dois nasceram com um
degrau de verdade: **7,19:1** e **5,90:1**, ambos acima do piso, com o
`tintaFraca` calibrado pelo pior fundo onde ele pousa (o chip, 4,94:1) —
exatamente como o `#68686C` do claro foi calibrado pelo chip a 4,52:1.

Duas dívidas do claro ficaram registradas e NÃO foram corrigidas aqui, porque
corrigi-las é mexer no visual sem pedido:

- `aviso`/`feriado` `#B5432F` mede **4,49:1** sobre o chip — um centésimo
  abaixo do piso da 02h. No escuro, 4,85:1.
- `synPontuacao` `#6E6E73` mede **4,25:1** sobre o fundo do portal. É o mesmo
  cinza que a ADR 04d aposentou do TEXTO e que sobreviveu no realce de código.
  No escuro, 5,21:1.

As duas estão congeladas em teste: quem for corrigi-las encontra a conta.

## 4. O que o pedido NÃO autorizou, e não se fez

- **Nenhum componente novo.** A aparência se escolhe no menu da linha que a
  hora do Recordar já usa, no Perfil: glifo, título, o valor de agora à
  direita e o chevron duplo. O Perfil ganhou uma linha, não um vocabulário.
- **Nenhum pixel do claro.** Os dezesseis hex do mundo claro estão congelados
  por teste; mover um é vermelho.
- **Nenhuma cor nova de identidade nem de estado.** A regra da cor do `Tema`
  (§10 do Hermes, ADR 10k) não abriu exceção: o escuro reusa os mesmos papéis.
- **A cerimônia da queima** (`Queima.swift`) continua com o preto cravado que
  ela sempre teve. A 02h já registrava que o fogo foi rejulgado em vídeo sobre
  papel claro; rejulgá-lo sobre grafite é trabalho de outra volta, com o dono
  a ver o vídeo.

## 5. A escolha

`Aparencia` (`Traco/Modelo/Aparencia.swift`), três estados, em
`UserDefaults` sob a chave `aparencia`:

| Valor | O que faz |
|---|---|
| `claro` | **o padrão** |
| `escuro` | grafite |
| `sistema` | segue o aparelho |

O padrão é `claro` de propósito, e não `sistema`: hoje o app força claro seja
qual for a aparência do aparelho, e quem nunca abrir este ajuste tem de ver
exatamente o app de ontem. Um padrão `sistema` viraria o Traço no escuro, sem
pedido, para todo mundo que anda com o iPhone no escuro.

Os cinco `.preferredColorScheme(.light)` que existiam (a raiz, a tela de
arranque, o calendário e as duas fichas dele) passaram a ser o mesmo
`.mundoDoAutor()`, que lê a chave. **Um mundo só POR VEZ** continua a ser a
lei: o que a 02h proibia era o app virar claro numa aba e escuro noutra, e
isso segue proibido.

## 6. O que só se confere em aparelho

Nada abaixo foi visto: esta volta nasceu numa máquina sem Xcode.

1. O fio de luz (`luzBorda` a 12 %) em volta da `SuperficieElevada`: no claro
   o gradiente vai de branco 60 % a tinta 5,6 %; no escuro vai de branco 12 %
   a branco 7 %, ou seja um aro de luz mais forte em cima. É o que separa
   "vidro sobre alumínio" de "cartão", e é a coisa mais fácil de errar.
2. O `glassEffect` do sistema (barra do pé, cápsulas, campo): ele tem a
   própria resposta à aparência, e o tint dele é `chipAtivo` — que no escuro
   ficou CLARO. A cápsula cheia da barra é o lugar para olhar primeiro.
3. O trilho afundado do calendário: a luz interna caiu de 0,9 para 0,06 e a
   sombra interna subiu de 0,10 para 0,45.
4. O véu da folha que afunda (`Camadas`), a 55 %.
5. A tela de arranque: ela segue o APARELHO, não o ajuste — o iOS não deixa
   um launch screen ler `UserDefaults`. Com aparelho e ajuste em mundos
   diferentes há um quadro de troca. Ver a nota do PR.
