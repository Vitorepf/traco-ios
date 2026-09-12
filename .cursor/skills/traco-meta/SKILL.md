---
name: traco-meta
description: Conduzir trabalho prolongado no traco-ios com fidelidade à visão de intenção, realização e desenvolvimento, preservando contratos, WIP e provas. Use em evolução, auditoria ou reparos do Traço; não executar uma fila histórica por invocação.
---

# Traço — execução orientada ao resultado

Leia [VISAO-PRODUTO.md](../../../VISAO-PRODUTO.md), as ADRs vigentes da [SPEC.md](../../../SPEC.md) e a matriz [EVOLUCAO.md](../../../EVOLUCAO.md). O [SISTEMA-CLARO.md](../../../SISTEMA-CLARO.md) orienta decisões visuais. Este arquivo organiza a execução; não substitui o propósito nem amplia a autorização da tarefa. Se já houver coordenador ou gate-loop, participe do ciclo existente.

## Propósito e fronteiras

Traço transforma intenções em realizações usando mente, IA e ambiente compartilhado; durante o trabalho, desenvolve capacidades relevantes para realizações futuras. Notas, formas, escrita e calendário são componentes. A IA pode produzir o que foi delegado, preservando origem e sem se passar pela pessoa. Delegar programação ou redação não é dívida cognitiva por definição; se a intenção é aprender essa atividade, preserve a prática escolhida. Não transformar toda tarefa em exercício.

A Análise das notas pessoais conserva seus contratos específicos; produção em Trabalho não autoriza preencher relatos íntimos, respostas de prática ou notas como se fossem voz humana. Expressivas, notas seladas e conteúdo privado permanecem protegidos em todas as rotas, inclusive derivadas. O produto é só do dono: português, iPhone, sem público. A lei fechada em [anti.md](anti.md) manda calar — não “adiar” — o que ele vetou. Consultar [anti.md](anti.md) para erros concretos de fronteira.

## Contratar antes de implementar

Registre no plano já existente:

- Objetivo integral e resultado que a pessoa conseguirá usar.
- Próximo incremento verificável, requisitos que atende e o que permanece pendente.
- Arquivos/responsáveis, WIP, contratos afetados, limitações e autorização real.
- Prova que distingue artefato produzido, ação executada, evidência atribuída e resultado observado; quando houver aprendizagem, contexto e apoio utilizado.

Código atual e registros históricos são o ponto de partida. Não vetam evolução explicitamente pedida, nem autorizam expandir uma correção delimitada. Alterações de contrato do produto entram na SPEC antes do código dependente. Uma fatia aprovada não encerra o objetivo integral por conveniência.

## Ciclo de trabalho

1. Investigue o impedimento real à tarefa. Priorize integridade, privacidade e recuperação, depois capacidade requerida, compreensão e acabamento conforme o pedido. Não invente features para manter o ciclo ocupado.
2. Descreva ação da pessoa/IA, retorno visível, dado preservado e recuperação. Formato visual deve servir ao trabalho, sem obrigar sintaxe Markdown nem esconder fonte quando ela é solicitada ou necessária à inspeção segura.
3. Implemente nos contratos existentes com um dono por arquivo compartilhado. Não relaxe globalmente guardas da Análise para habilitar produção em outra superfície. Reuse providers autorizados; falha ou indisponibilidade não vira resposta simulada.
4. Execute [portoes.md](portoes.md) nos eixos afetados. Vincule evidência ao candidato com WIP e ao estado real da interface; screenshot não prova persistência ou execução externa.
5. Peça revisão independente quando pertinente ao contrato. Relendo o próprio diff, faça uma segunda passada autoral, sem chamá-la de crítico cego. Revisor recebe pedido, candidato e fontes, sem a autoavaliação do implementador.
6. Corrija causas demonstradas, revalide dependências e registre o incremento e lacunas restantes. Mesma falha sem informação nova pede outra hipótese; não encerra automaticamente após três tentativas.

## Entrega e retomada

Concluir exige requisitos da tarefa demonstrados na versão atual, não número de rodadas, garantias de perfeição ou mera suíte verde. Sem recurso para uma prova, registre não verificado e continue trabalho independente útil. Não declare bloqueio por cansaço, nem aprovação de uma capacidade indisponível.

Em interrupção, deixe contrato, candidato, evidências válidas, pendências e próxima ação. Preserve WIP; não faça commits, push, publicação ou mudanças no ambiente por consequência. Use o simulador coordenado, sem abrir outro para disputar uma corrida. Respeite configurações pessoais e restaure configurações temporárias de teste ao terminar.

[fila.md](fila.md) e [FILA.md](../../../FILA.md) são registros datados a revalidar. Não são backlog obrigatório nem prova atual de conclusão. Limites do host e dependências reais devem ficar explícitos, sem pedir continuidade por conveniência.
