# Consulta da trilha Fora do app — intents compartilhados entre app, widgets, controles, Siri e URL

Conselho: GPT-6-Astra (Codex), 05/09/2026, só leitura sobre main d4d98da. Pergunta do orquestrador: catálogo único de App Intents e entidades sem duplicar lógica nem furar o selo; dados do widget; interação de um toque fora do app; captação em um toque; ordem de F2.

Recomendação: F2 deve consolidar as entradas existentes, com app como único escritor de domínio, snapshot público no App Group e uma única implementação por operação.
Intenção servida: captar e agir sem perder contexto; prova: o mesmo comando produz o mesmo estado confirmado em qualquer entrada, sem expor conteúdo protegido.

1. Catálogo e fronteiras
- Criar Traco/App/Intents/ para declarações, entidades e TracoAtalhos; preservar nomes dos tipos/parâmetros existentes para não quebrar atalhos salvos.
- Continuar compilando os mesmos arquivos nos dois targets somente quando necessários a widgets/controles/Live Activities; não levar todo Intencoes.swift, SwiftData, Corpus ou Rota para a extensão.
- Extrair execução para funções concretas no app, reutilizando Entrada, CalendarioDisco, Revisoes, AcessoTrabalho e as regras do agregado Trabalho; sem framework, protocolo de repositório ou registro paralelo de capacidades.
- Compartilhar DTOs e leitura de snapshot em arquivos pequenos; separar implementação dependente do app por compilação condicional quando um intent exigir declaração nos dois targets, recusando execução no alvo errado.
- SwiftUI, intent.perform(), URL, Spotlight e didReceive convergem na mesma operação/rota tipada; NotificationCenter apenas anuncia uma rota pendente, consumida depois que a cena estiver pronta, inclusive no arranque frio.
- LiveActivityIntent já executa no processo do app sem trazer a interface; openAppWhenRun=false sozinho não escolhe processo; novos comandos devem ter seu contexto de execução demonstrado, não presumido [Apple: interatividade](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities).
- NotaEntity: UUID e título público mínimo; EntityQuery por IDs, sugestões limitadas e EntityStringQuery aplicam !fechada && gesto != .expressiva antes de produzir qualquer representação.
- TrabalhoEntity: UUID/título somente após AcessoTrabalho.permitido, inclusive quando a origem sumiu; CompromissoEntity distingue compromisso local, evento externo e ocorrência recorrente por identidade estável.
- Ação do Trabalho conserva trabalhoID+acaoID e sua origem: nunca vira compromisso autônomo (05k); eventual AcaoEntity é referência ao agregado, sem cópia editável nem execução inferida de horário passado.
- Queries de notas/trabalhos ficam no app inicialmente; não espelhar o corpus para configurar widgets; revalidar IDs e proteção em perform(), mesmo com entidade antiga recebida do sistema.
- AppEntity não publica automaticamente no Spotlight: manter Holofote e unificar elegibilidade/IDs; serializar indexação para uma tarefa antiga não republicar conteúdo depois da revogação.

2. Snapshot e atualização
- Substituir as várias chaves de DestaqueDoDia/ProximoCompromisso por um documento Codable versionado, escrito atomicamente no group.app.traco: revision, generatedAt, validUntil, IDs, estado confirmado e somente texto permitido.
- O snapshot é projeção descartável; feito/soneca precisam de estado persistido próprio e identidade, para reconstruir a projeção sem perder confirmação; não usar o snapshot como autorização.
- Publicar após commits relevantes: criação/edição/exclusão, proteção e derivações, feito/soneca, agenda atualizada e retorno de cena; agrupar autosaves idênticos, mas nunca atrasar revogação deliberadamente.
- Após escrita bem-sucedida, o publicador pede reloadTimelines apenas dos kinds afetados; controles terão sua invalidação própria; falha/corrupção/App Group indisponível produz estado indisponível, sem fallback para .standard.
- Timeline contém poucas transições conhecidas e entrada vazia/expirada no fim; se só houver um próximo compromisso, não inventar o seguinte; horizonte curto com candidatos reais permite continuar sem abrir o app.
- Hoje ProvedorProximo passa a pedir reload a cada minuto depois de inicio+60s: corrigir essa recorrência; relógios relativos usam renderização do sistema, não polling.
- Exibir “Atualizado há…” com generatedAt e “Desatualizado” após validUntil; relevância só na janela pertinente; reload é pedido, não garantia de horário [Apple: atualização](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date/).

3. Escrita, confirmação e ciclo de vida
- Manter DestaqueFeitoIntent e LembrarDepoisIntent como LiveActivityIntent nos dois alvos, com mutação no app; a extensão visual não abre a store nem escreve calendários/Trabalho.
- Passar identidade do item mostrado: destaque UUID+dia e compromisso UUID+ocorrência; reler/revalidar antes de agir; abandonar “operar o próximo atual” e substituir toggle por definir feito=true, com desfazer explícito.
- Para Swift 6.2, domínio/ModelContext no MainActor e valores nonisolated Codable/Sendable entre fronteiras; nenhum @Model atravessa atores; lock/actor local não protege processos diferentes.
- MainActor também não impede reentrância em await nem sobrescrita por editor antigo: transação curta sem suspensão, revisão/base esperada e revalidação após IO assíncrono, incluindo app aberto.
- Soneca reutiliza orçamento Avisos/Revisoes; contar substituição do mesmo ID, tratar erro de add e só anunciar horário após sucesso; hoje há try? que fabrica confirmação e não consulta o orçamento.
- Persistir resultado e publicar superfície antes de retornar; aguardar update/end da atividade correspondente, em vez de deixar apenas uma Task enfileirada; identidade de atividade não pode ser somente horário.
- Reconciliar atividades ativas com estado persistido no arranque, retorno e comandos; encerrada/excluída/protegida não recria; falha entre commit e ActivityKit é recuperável.
- staleDate NÃO encerra: neutralizar texto/ações em todos os estados stale, inclusive Ilha compacta/expandida; chamar end quando executando; “sumir exatamente no prazo com app suspenso” não pode ser prometido com timer local [Apple: staleDate](https://developer.apple.com/documentation/activitykit/activitycontent/staledate).

4. Captação
- Siri/Atalhos continuam usando AnotarIntent → Entrada.depositar → coleta com ReciboEntrada; 05a já resolve a fila e 05h a retirada somente após commit, sem novo importador.
- Distinguir texto vazio de falha de gravação: hoje ambos respondem “nada a anotar”; “anotado” significa depósito confirmado, não nota já importada.
- Controle/botão de Ação usa intent de abertura compartilhado e rota tipada de captura com ditado solicitado; guardar rota até editor pronto e permissões resolvidas; não iniciar microfone na extensão.
- Ditado próprio preserva áudio antes de transcrever, inclusive falha/cancelamento; isso é a próxima superfície, pois 05a explicitamente não o implementa.
- Se futura extensão precisar depositar sem app, acrescentar entrada/ no App Group como segunda raiz da coleta, com UUID e escrita atômica; preservar a raiz atual e os recibos, sem migração em massa.

5. Alternativas, riscos e prova de F2
- Descarto framework/package agora: dois targets já compartilham fontes; só extrair módulo quando dependências/terceiro consumidor justificarem custo e descoberta de metadados AppIntents.
- Descarto SwiftData lido/escrito pela extensão: exige schema/migração compatíveis, tratamento de conflitos e proteção ampliada; snapshots resolvem leitura; fila eventual de comandos também não serve para confirmar “feito” imediatamente.
- Não presumir que a store atual é privada: ModelConfiguration usa configuração automática e pode escolher App Group; registrar URL efetiva sem alterá-la [Apple: group container automático](https://developer.apple.com/documentation/swiftdata/modelconfiguration/groupcontainer-swift.struct/automatic).
- Selo: expurgo de snapshot, índice, atividades e entidades deve acompanhar proteção/exclusão; caches já renderizados pelo iOS não têm revogação instantânea garantida, nem cópias já entregues a Atalhos são recuperáveis; não certificar essa garantia absoluta.
- Provisionamento: grupo nos dois entitlements não prova acesso real; validar containerURL, proteção de arquivos com aparelho bloqueado e assinatura de ambos em dispositivo; store indisponível nunca confirma escrita no fallback em memória de DiscoTraco.
- Ordem em um dia: (a) extrair catálogo/rotas preservando tipos; (b) snapshot e migração apenas das projeções públicas; (c) corrigir os dois intents e integrar publicação; (d) entidades mínimas no app com queries protegidas e testes; ajustar SPEC/EVOLUCAO.
- Fronteiras: project.yml, Traco/App/Intents/, Intencoes.swift/Rota, TracoWidget/, DestaqueDoDia/ProximoCompromisso, pontos de commit em Sessao/Calendario, Holofote/didReceive e testes existentes; Tema.swift já é compartilhado.
- Provar sem UI: persistência recusada não confirma; repetição não duplica/inverte; item velho não altera novo; soneca negada/lotada/falha; snapshot truncado/expirado; corrida entre commit e editor; proteção/remoção depois da query e durante await; recibo de entrada sem duplicação.
- Implementador ainda precisa de build dos dois alvos e extração de intents sem avisos, jornada com app frio/aberto/bloqueado, confirmação na superfície e expiração em todas as regiões; esta consulta não rodou build nem alterou arquivos.
- Ficam depois: novos controles, ditado próprio, widget configurável, expansão Spotlight para Trabalho e mutação externa de ações do Trabalho; se todo esse escopo for exigido em F2, dividir a volta em vez de declarar fundação concluída sem prova.
