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
