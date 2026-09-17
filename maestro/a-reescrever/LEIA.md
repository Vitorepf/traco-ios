# Fluxos a reescrever

Corridos em 17/09 num iPhone 17e próprio (`Traço Maestro 17-09`, iOS 27, pt-BR,
modelos desligados), depois de consertar o que era comum a todos (o id
`abrir-campos`, o gesto da borda que não abre mais o arquivo, o alerta de avisos
que o `clearState` traz de volta, os campos da forma sob o teclado). Estes nove
ainda descrevem uma interface que mudou; fora de `maestro/*.yaml`, o
`varrer.sh` não os roda até alguém reescrevê-los contra a tela atual.

| fluxo | primeiro passo que falha | o que mudou |
|---|---|---|
| auditoria-completa | `tapOn: Recordar` na nota aberta | a nota aberta não mostra «Recordar»; ele está no menu de toque longo da lista |
| busca-filtro | `tapOn: filtro-notas` | o id existe em `NotasView`, mas não está na tela nesse ponto do fluxo (não investigado) |
| cadeia-completa | `"Virar Se–então"` visível | o rótulo existe no catálogo, mas não está na tela nesse ponto (não investigado) |
| encadear | `"Virar Se–então"` visível | idem |
| ilhas-encadeadas | `"Virar Pré-mortem"` visível | idem |
| degrau-no-perfil | `".*WOOP no degrau 1.*"` | o Perfil diz «Como a Sábia pergunta em cada forma — …» |
| forma-folha | `soltar-na-folha` | a folha dos campos saiu (14/09); os campos estão no papel |
| metodos-novos | `"LEITURA"` | os rótulos de seção deixaram a caixa alta |
| pelo-sentido | `"pelo sentido"` | o simulador não tem o índice de sentido em português; só no aparelho que o tem |

## Varredura completa (17/09, tarde)

Os 88 fluxos restantes rodaram duas vezes no mesmo 17e próprio, a segunda depois de confirmar o diálogo «Abrir com Traço?» que o iOS mostra antes de seguir um `traco://`. Passaram 41 no total (os 12 da manhã e mais 29); estes 59 ainda falham e saíram da varredura. A coluna é o primeiro passo que falhou na segunda corrida. Fluxos com `.sh` irmão (a-volta, anexo-no-sentido, entrada-do-mac, intercambio-conflito) não rodaram: o `.sh` usa o simulador `booted` e havia vários ligados.

| fluxo | primeiro passo que falha |
|---|---|
| anotar-de-fora.yaml | Assert that "1 nota veio de fora." is visible |
| barra-de-baixo.yaml | Assert that id: cartao-sabia-notas is visible |
| caderno-citacao.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| caderno-codigo.yaml | Swiping in LEFT direction on id: regua |
| caderno-divisoria.yaml | Swiping in LEFT direction on id: regua |
| caderno-gravar.yaml | Tap on id: abrir-arquivo |
| caderno-lista.yaml | Tap on "Esconder teclado" |
| caderno-numerada.yaml | Assert that id: regua-numerada is visible |
| caderno-seccao.yaml | Tap on id: regua-seccao |
| caderno-silencio.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| caderno-tabela.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| caderno-titulo.yaml | Tap on id: regua-titulo |
| caderno-toque-lista.yaml | Tap on id: regua-lista |
| caderno-verso.yaml | Swiping in LEFT direction on id: regua |
| caderno-vocabulario.yaml | Swiping in LEFT direction on id: regua |
| calendario.yaml | Tap on id: escala-semana |
| calibragem.yaml | Assert that "Decisões conferidas" is visible |
| compromisso-avisa.yaml | Tap on "30 min antes" |
| do-caderno.yaml | Scrolling DOWN until id: ficha-do-caderno is visible. |
| dominio-no-menu.yaml | Assert that "TRABALHO" is visible |
| expressiva-depois.yaml | Assert that "Expressiva — trancada" is visible |
| expressiva.yaml | Assert that id: confirmacao-abrir is visible |
| feriado-e-repeticao.yaml | Assert that ".*seg.*sex.*" is visible |
| formas-novas.yaml | Assert that "ARGUMENTO" is visible |
| latencia-ida-e-volta.yaml | Assert that id: trabalho-pedido is visible |
| latencia.yaml | Scrolling DOWN until id: latencia-resumo is visible. |
| lente-apontar.yaml | Tap on id: abrir-lente |
| lente.yaml | Tap on id: abrir-lente |
| lista-viva.yaml | Tap on "Esconder teclado" |
| menu-136.yaml | Tap on id: regua-todas |
| metodos-m3-tom.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| metodos-m3.yaml | Scrolling DOWN until id: metodos is visible. |
| notas-ordem-e-lote.yaml | Assert that id: ordem-notas is visible |
| perfil-sabia.yaml | Assert that "A sábia conhece você" is visible |
| perfil.yaml | Scrolling DOWN until id: ajuste-auto-analise is visible. |
| pilha-codigo.yaml | Swiping in LEFT direction on id: regua |
| premortem-do-plano.yaml | Assert that "Planos sem a falha nomeada" is visible |
| recordar-completo.yaml | Tap on "Recordar" |
| recordar-revelar.yaml | Tap on "Recordar" |
| recordar.yaml | Tap on "Recordar" |
| rede.yaml | Tap on "Ligações" |
| sinal-solto.yaml | Scrolling DOWN until ".*soltou três vezes seguidas.*" is visible. |
| tour-completo.yaml | Assert that "Deixar como nota" is visible |
| trabalho-acao-aviso.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| trabalho-bloqueio.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| trabalho-curva-zero.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| versoes.yaml | Tap on id: pagina |
| vestir-tudo.yaml | Assert that id: regua-todas is visible |
| cenarios/anexar-cancelado.yaml | Tap on id: abrir-arquivo |
| cenarios/emoji-e-rtl.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| cenarios/formas-empilhadas.yaml | Tap on id: regua-titulo |
| cenarios/paragrafos-preservados.yaml | Tap on id: regua-titulo |
| cenarios/regua-construtor.yaml | sem passo registrado (o maestro não chegou a rodar o fluxo) |
| cenarios/regua-dedo-em-voo.yaml | Swiping in UP direction on id: regua |
| cenarios/titulo-corpo-lista.yaml | Tap on id: regua-titulo |
| cenarios/titulo-enter-desce.yaml | Tap on id: regua-titulo |
| cenarios/titulo-nota-reaberta.yaml | Tap on id: regua-titulo |
| cenarios/toque-duplo-chip.yaml | Tap on id: regua-titulo |
| cenarios/widget-rotas.yaml | Assert that "Leia uma última vez — a nota vai se esconder." is visible |
