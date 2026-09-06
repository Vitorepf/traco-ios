# Perguntas ao dono — só as quatro que param

Regra: DIRETRIZ.md §6. O orquestrador decide sozinho tudo que é reversível e vive em git, e registra a decisão no LACO. Só quatro coisas param e esperam: risco real aos dados do dono no aparelho dele; gastar, publicar ou enviar; mudar contrato de privacidade, autoria ou selo; apagar trabalho do dono. Mesmo nesses casos a pergunta entra aqui com as opções e a RECOMENDAÇÃO do orquestrador, o laço segue com as outras voltas, e passadas duas horas sem resposta a recomendação vira decisão se for reversível na prática — dito por escrito.

## Fechadas

### 1. PRODUCT_NAME de "Traço" para "Traco" (F2, fundação fora do app) — RESPONDIDA pelo dono, 06/09
Por que parava: instalar por cima no iPhone do dono com o executável renomeado podia, na hipótese ruim, ser tratado como app diferente e levar os dados junto — risco real aos dados dele no aparelho.
Recomendação do orquestrador: (a) manter a troca, porque o chronod recusava recarregar o widget com o executável em NFD, e o bundle id e o nome exibido não mudam.
**Resposta do dono:** (a), com recuo. Mesclar só se o re-G3 provar EM SIMULADOR DE TESTE que instalar por cima preserva as notas e os compromissos; se a prova falhar ou ficar ambígua, cair para (c) e achar outra saída, como CFBundleExecutable em NFD. Nunca instalar no iPhone dele antes disso.
Estado: o re-G3 da F2 provou no simulador que instalar por cima PRESERVA notas e compromissos (f2-reg3-02..05.png), então vale (a). A F2 está mesclada. Falta só o dono conferir no aparelho dele quando quiser — isso não bloqueia nenhuma volta.

## Abertas

(nenhuma)
