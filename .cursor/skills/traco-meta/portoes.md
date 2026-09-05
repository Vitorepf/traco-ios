# Provas proporcionais à tarefa vigente

Leia [VISAO-PRODUTO](../../../VISAO-PRODUTO.md), [SPEC](../../../SPEC.md) e [EVOLUCAO](../../../EVOLUCAO.md). Registre passou/falhou/não verificado/não aplicável, com motivo e evidência. Ausência de prova não é defeito demonstrado nem aprovação. Se já houver matriz do coordenador, preencha essa matriz; não crie um segundo predicado de conclusão.

## Contrato, integridade e origem

| Eixo | Condição observável | Prova pertinente |
|---|---|---|
| Autoria | Conteúdo pessoal, gerado, externo e misto conservam origem; prática escolhida não é substituída silenciosamente | Rota real + teste de origem/versionamento |
| Selo | Origem restrita não expõe conteúdo por UI, contexto, derivação ou exportação; liberar recupera trabalho conforme contrato | Revogar/liberar, reabrir e guards de serviço |
| Persistência | Gravação confirmada precede anúncio e efeitos; falha preserva entrada; replay não duplica nem destrói fonte | Fault injection, retomada e round-trip hostil |
| Produção delegada | Provider real produz no contrato autorizado; falha/cancelamento mantêm dados e descartam resposta obsoleta | Chamada real quando disponível + testes controlados de falha |
| Fronteira de ação | Artefato, agendamento, execução e resultado não se confundem | Read-back/observação da ação e evidência atribuída |
| Capacidade | Hipótese contextual corrigível; assistência e resultado não fingem aprendizagem | Tarefa pertinente e efeito real da correção no próximo apoio |

Listas fechadas e gatilhos da Análise são verificados nas rotas de notas a que pertencem, segundo ADR vigente. Não exigir ausência de API de modelo ou de todo texto gerado como portão global.

## Documento e experiência

| Eixo | Condição observável | Prova pertinente |
|---|---|---|
| Leitura/edição | Conteúdo compreensível, representação apropriada, sem marca acidental nem controles falsos | Render e interação de cada tipo afetado |
| Intercâmbio | MD preserva conteúdo/origem/identidade; importação antiga é revisável; formato não suportado não executa nem some | Exportar, editar, importar e reabrir |
| Visual | Tokens vigentes, hierarquia e contraste nos fundos reais | Captura identificada + medição quando aplicável |
| Acesso | Ações encontráveis e rótulos legíveis, inclusive com teclado, AX e leitor de tela | Jornada e tecnologia assistiva disponível; declarar o não exercitado |
| Movimento | Transições preservam orientação e respeitam preferência relevante | Vídeo/interrupção, não screenshot isolado |
| Recuperação | Voltar, cancelar, erro e retomar preservam o que prometem | Percurso adversarial com dados fictícios |

Registrar candidato com WIP, rota/folha, conteúdo, configuração e procedimento. Nome da captura não confirma estado. Restaurar configuração temporária anterior não fecha defeito descoberto no teste.

## Execução técnica

Confirme os comandos e alvo no [README](../../../README.md) e projeto reais. Use o simulador coordenado disponível; UDID, conta, assinatura e número histórico de testes não são constantes. Não instalar ferramentas, acionar serviço pago ou disputar aparelho por consequência deste documento.

Build e suíte validam seus predicados. Execute caso de reprodução, testes afetados e integração pertinente; prove o provider/caminho real quando a capacidade o exige. Fixtures não demonstram geração disponível. Correção documental não exige iniciar build ou simulador se nenhum comportamento executável mudou.

Uma entrega passa quando a pessoa consegue o resultado contratado com os estados críticos verificados. Não exigir um número fixo de juízes, rodadas vazias ou um commit para substituir evidência. Preserve as capacidades restantes na matriz integral.
