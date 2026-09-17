# Traço — instruções de projeto

Escopo: este repositório, cliente iOS e companheiro MCP. Preserve mudanças em
andamento e dados existentes; não restaure arquivos inteiros para desfazer um
trecho. Este documento orienta trabalho, não concede permissões externas.

## Entenda o produto antes de alterar comportamento

Leia [VISAO-PRODUTO.md](VISAO-PRODUTO.md). Traço combina mente humana, IA e
ambiente compartilhado para transformar intenção em realização e desenvolver
as capacidades relevantes para realizar mais depois. Notas, calendário,
métodos, segundo cérebro e MD/HTML são meios para esses dois ciclos.

Fontes, em ordem de função:

- Pedido vigente do usuário e visão: direção e finalidade.
- [SPEC.md](SPEC.md), seções atuais e ADRs aplicáveis: contratos. ADR antiga
  não prevalece sobre uma decisão que a substituiu.
- [EVOLUCAO.md](EVOLUCAO.md), código e execução: capacidade existente, provas
  e lacunas. Uma descrição de visão não prova implementação.
- [README.md](README.md): mapa dos documentos. Pesquisa, metas encerradas e
  provas históricas não são ordens de implementar tudo que mencionam.
- O que está em curso e o que vem a seguir: [ferramentas/orca/RUMO.md](ferramentas/orca/RUMO.md).
  Quem responde cada operação de IA hoje (e o que está cortado por qualidade):
  a tabela de [Traco/Analise/Politica.swift](Traco/Analise/Politica.swift) —
  o código vence o parágrafo de estado de qualquer documento.

Antes de implementar uma capacidade, identifique no plano já usado: intenção
servida, obstáculo reduzido, quem faz o quê e evidência esperada. Se só houver
uma referência de concorrente ou uma ideia de catálogo, falta justificativa.
Não crie formulário ou aprovação ritual para registrar essa decisão.

## Fronteiras que mudam decisões

- A IA pode redigir, programar, resumir, traduzir e revisar trabalho delegado.
  Não tratar a antiga frase “a IA nunca escreve” como regra global. Guardas
  locais de escrita pessoal, expressiva e Recordar preservam autoria/prática;
  migrar contratos e consumidores antes de mudar essas rotas.
- Delegar programação para criar um produto não exige aprender programação.
  Se aprender é o objetivo, preservar a prática pertinente. Não inferir falta
  de capacidade porque a pessoa delegou ou não respondeu.
- Preservar origem, versões, vínculos e conteúdo. Texto importado/gerado não
  vira voz pessoal ou tentativa do autor por estar no mesmo arquivo.
- Produzido, agendado, realizado e resultado observado são estados distintos.
  Relato é atribuído; hipótese é corrigível. Uso não demonstra aprendizagem.
- Expressivas, notas protegidas e suas derivações exigem o mesmo contrato de
  acesso em busca, contexto, exportação e retorno assíncrono. Delegação não
  autoriza remover proteção nem inventar permissão para publicar ou gastar.
- Simplicidade reduz esforço de operar e compreender, preservando informação
  necessária, controle e recuperação. Não esconder falha para limpar a tela.
- Traço é só do dono: português, iPhone, sem público. Nunca propor nem citar
  leitor de tela, outro aparelho, outro idioma, loja ou “até você decidir”.
  Lei fechada; histórico que mencione isso não reabre.
- Um caderno (ADR 2026-09-12a): classificar em silêncio; pesquisa ≠ voz;
  obra ausente das Fontes cai na guarda local («não está no caderno»).
  Não inventar Território nem wizard de taxonomia.

## Entradas técnicas

Swift/SwiftUI, SwiftData e Swift Testing; versões e targets em
[project.yml](project.yml). O projeto Xcode é gerado por XcodeGen.

| Área | Entrada |
|---|---|
| Intenção, versões, geração, importação | [Traco/Trabalho](Traco/Trabalho) |
| Escrita e representação | [Traco/Caderno](Traco/Caderno), [Traco/Pagina](Traco/Pagina) |
| Notas, Corpus, entrada e projeções | [Traco/Notas](Traco/Notas) |
| Calendário e ações | [Traco/Calendario](Traco/Calendario) |
| Modelos, autoria e migração | [Traco/Modelo](Traco/Modelo) |
| Provedores e contratos da IA | [Traco/Analise](Traco/Analise) |
| MCP no Mac | [ferramentas/traco-mcp/README.md](ferramentas/traco-mcp/README.md) |

## Verificação e fechamento

Comandos e pré-requisitos em [README.md](README.md#como-rodar), a partir da raiz.
Antes de commitar Swift, `ferramentas/portao.sh` compila app e testes e roda a
suíte unitária no simulador indicado (pela trava `com-trava.sh`); o hook de
pre-commit instalado por `ferramentas/portao.sh --instalar` compila o que vai
ser commitado e recusa o commit que não compila.
Escolha explicitamente o simulador antes de instalar/testar; não apague nem
reconfigure um aparelho com dados do usuário por conveniência. Registre e
restaure configurações temporárias, inclusive tamanho de texto. Se o projeto
gerado contiver WIP, gere um candidato isolado com todas as fontes atuais.

Execute os testes relevantes, depois a jornada integrada quando a mudança
alterar navegação, estado ou IO. Confira conteúdo e estado reais da captura.
Para geração, leia a resposta completa contra as restrições do pedido: saída
não vazia, JSON válido e testes de transporte não aprovam utilidade semântica.
Use revisão independente para contratos substanciais e confronte seus achados.

Atualize contrato e matriz de evolução quando mudar comportamento. Declare
limites de execução, provedor e evidência. Um incremento aprovado não conclui
toda a visão; passes históricos não certificam o candidato atual.
