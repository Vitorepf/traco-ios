# Traço

Bloco de notas para iPhone com uma IA que **nunca escreve pelo autor**.

A tese: a IA multiplica o que a mente faz — então o app garante que o que ela
multiplica é o gesto certo (escrever sob regra), nunca o atalho (texto pronto,
dívida cognitiva). A Análise classifica e pergunta; as palavras da tela são
todas do app; a nota é sempre do autor.

## As cinco regras de ferro

1. **A IA nunca escreve na nota.** Ela devolve um rótulo de lista fechada — o
   Veredito. Campos de forma nascem vazios.
2. **Nota trancada é selada em toda rota:** busca, índice, Recordar, Padrões,
   export, import, rede, notificação, apagar, processo morto.
3. **Um gesto por sessão.** O segundo método vai para outra página.
4. **Silêncio é resposta válida.** Na dúvida, a Análise cala.
5. **Zero chat, streaks, XP, elogio ou resumo.**

## Como rodar

Projeto gerado por [XcodeGen](https://github.com/yonaskolb/XcodeGen) — o
`.xcodeproj` é derivado, não fonte de verdade.

```bash
xcodegen generate
xcodebuild build -project Traco.xcodeproj -scheme Traco \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Testes (Swift Testing, inclui fuzz de propriedade do parser):

```bash
xcodebuild test -project Traco.xcodeproj -scheme Traco \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Varredura E2E ([Maestro](https://maestro.mobile.dev)) — recusa rodar com mais
de um simulador ligado, porque com dois o instalador e o driver escolhem
aparelhos diferentes e o veredito sai falso:

```bash
./maestro/varrer.sh                    # todos os fluxos
./maestro/varrer.sh maestro/busca.yaml # um fluxo
```

## Os documentos

| Arquivo | Papel |
|---|---|
| [SPEC.md](SPEC.md) | Fonte da verdade do produto. Conflito código×spec emenda a SPEC com ADR **antes** de codar. |
| [SISTEMA.md](SISTEMA.md) | Sistema visual: paleta, tipo, espaço, motion, hierarquia por tela. |
| [META.md](META.md) · [META-FINAL.md](META-FINAL.md) | Como conduzir uma sessão longa sem improvisar outra tese. |
| [FILA.md](FILA.md) | O que está aberto, o que fechou, e a medida que provou cada defeito. |

## Sem servidor

Notas em SwiftData no aparelho, com backup automático em `.md` no app Arquivos.
As revisões espaçadas são notificações locais. O único tráfego externo é a
Análise, que fala direto com a API da xAI usando o token da conta Grok do
próprio autor (Keychain) — não há backend a hospedar, e qualquer falha de rede
cai no motor local em silêncio.

## Estrutura

```
Traco/
  Analise/     motor local, motor remoto, conta Grok
  App/         raiz, camadas de navegação, sessão
  Caderno/     parser de blocos, editores, portais, régua de formas
  Notas/       arquivo, busca, corpus, export/import
  Pagina/      a página em branco, cartão da Análise, campos de forma
  Padroes/ Perfil/ Recordar/ Confirmacao/
TracoTests/    suíte + fuzz do parser
maestro/       fluxos E2E; cenarios/ = famílias hostis
```
