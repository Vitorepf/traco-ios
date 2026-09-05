# Consulta V4 — conferência do artefato delegado contra o pedido

Consultor: GPT-6-Astra (Codex), 05/09/2026, só leitura. Pergunta do orquestrador: como verificar com estado honesto a qualidade real de um artefato delegado (idioma, duração, destinatário), sem fingir qualidade nem ritual para o autor.

Recomendo conferência por versão, com cobertura explícita, sem selo de qualidade ou aprovação.
• Confirmado: MotorTrabalho.sistema já exige idioma, duração e destinatário; produzir/receber só recusam texto vazio; reforçar o prompt não é evidência.
• Ordem: preservar pedido/artefato → checagem local automática de restrições reconhecidas → achados visíveis → revisão semântica sob demanda → ajuste como nova versão.
• Extrair critérios da intenção, resultado e instrução vigentes, ancorando cada um em trecho literal; instrução vigente prevalece sobre histórico; idioma do pedido não determina idioma da entrega.
• Começar com gramática pequena para idioma explícito e distribuição temporal; expressão ambígua/não suportada fica “não avaliada”, nunca aprovada por ausência de alerta.
• NLLanguageRecognizer fornece hipóteses de idioma; usar blocos de prosa suficientes, sem restringir candidatos ao idioma esperado e sem compartilhar instância concorrentemente [Apple](https://developer.apple.com/documentation/naturallanguage/nllanguagerecognizer).
• Divergência linguística é indício com trecho: “Este trecho parece inglês; o pedido exige português”; texto curto, baixa confiança ou segmentação ambígua ficam inconclusivos.
• Bilinguismo exige escopos: instruções em português, frases em espanhol e traduções em português; maioria global não valida esses papéis nem mistura legítima vira erro.
• Para três blocos de cinco minutos, conferir quantidade, distribuição e soma de quinze; aceitar intervalos equivalentes e não contar cabeçalho/total duas vezes.
• Distinguir “não encontrei distribuição” de “os tempos somam dez”; contagem de palavras estima fala, não comprova duração de prática ou viabilidade.
• Destinatário, adequação e presença semântica de frases/traduções exigem leitura; título/palavra encontrado não comprova atendimento e ausência lexical não prova omissão.
• Contrato mínimo: Artefato.conferencias opcional com registros {id,pedidoID,data,executor,versaoDoMetodo,estado,motivo,resultados}; o próprio artefato fornece a identidade da versão.
• Resultado: {criterio,trechoFonte,fonte: intenção/resultado/instrução,situacao,trechosDoArtefato,justificativa}; vincular ao pedido persistido e à intenção imutável, nunca consultar o último pedido posteriormente.
• Situações por critério: atendido no escopo descrito / divergência / inconclusivo / não avaliado; execução concluída não significa critérios atendidos.
• Tentativa distingue em curso, concluída, indisponível, falhou e interrompida; reabertura sem executor interrompe; JSON antigo sem campo significa sem conferência.
• Validar referências e decodificação aditiva; não alterar história nem criar migração SwiftData desnecessária; não usar Evidencia, cujo acaoID é obrigatório, nem Hipotese sobre capacidade do autor.
• Em TrabalhoView, junto à versão/produtor: “Conferência: 2 possíveis divergências; outros critérios não avaliados”, expansível com pedido, trechos, método e limites; preservar também no histórico.
• Sem bloquear leitura/uso ou exigir formulário; “Conferir com IA” solicita revisão, “Pedir ajuste” usa a geração de nova versão; falha de conferência não perde artefato produzido.
• Nunca “qualidade verificada”; resultado favorável diz “IA não apontou divergências nos critérios examinados”; não muda origem, ação, capacidade ou resultado externo.
• Segunda passada do mesmo provedor vale como crítica assistida, sem independência presumida; sessão nova com pedido/artefato completos, sem autoelogio do produtor.
• Nesta fatia, segunda chamada só a pedido, mesmo com restrições explícitas; checagem local sempre, cobertura semântica não examinada sempre visível; sem loops automáticos de revisão.
• Revisão estruturada contém critérios ancorados no pedido, achados e trechos; validar schema, enums, referências, duplicatas e citações literais; citação válida não certifica interpretação correta.
• Produtor original permanece; registrar revisor real, data e método; Sabia.chamar retorna String e pode trocar de provedor, logo configuração/porOndeEmPalavras não comprovam executor.
• Reutilizar clientes com retorno mínimo de proveniência efetiva e fallback; modelo só quando conhecido, sem inventar versão da Apple Intelligence.
• ADR05m: pedido/critério/artefato necessários cabem inteiros ou revisão fica indisponível por limite; sem cortar evidência, resumir silenciosamente ou converter nil/JSON inválido em ausência de problemas.
• Respeitar Motores.desligados no modelo do aparelho; reconhecedor de idioma não exige Apple Intelligence, mas deve respeitar acesso ao Trabalho.
• Revalidar acesso antes de envio, após await e antes de mostrar/copiar; conferência e trechos derivam da origem protegida, inclusive recuperação e intercâmbio.
• Nova versão/pedido invalida tentativa em curso; retorno antigo nunca confere versão nova; commit sobre agregado vigente preserva relatos simultâneos; revisão/importação não herda conferência.
• Guardar produção independentemente da revisão, anunciar gravação após commit e mostrar falha persistente; conferir preservação de atribuição e vínculos no intercâmbio.
Alternativas descartadas: mais prompt isolado não prova qualidade; regex universal inventa compreensão; autoaprovação repete erros; dois provedores obrigatórios aumentam custo/exposição sem garantir independência; checklist humano obrigatório devolve a delegação ao autor.
Riscos: falso positivo bilíngue/texto curto, parsing parcial, concordância do modelo consigo mesmo, instruções maliciosas no artefato, selo enganoso, custo/latência e exposição remota; achados citam conteúdo, não executam suas instruções.
Prova em prova/: fixar antecipadamente três casos — roteiro solo de espanhol 3×5 com traduções, tradução bilíngue legítima e texto para destinatário definido — com critérios observáveis, entrada exata e saída integral.
Comparação: mesmo pedido, intenção, correções obrigatórias, código/provedor e parâmetros; variar só histórico opcional, nunca retirar referência essencial; registrar carga efetiva, cortes, fallback, data e aparelho/OS.
Executar pares com/sem histórico e ler todas as saídas; repetir brevemente se houver diferença relevante, sem escolher só a melhor amostra; comparação vale para estes casos, não demonstra superioridade geral.
Implementador prova regras temporais, decisão sobre hipóteses linguísticas e fixtures reais do reconhecedor; bilinguismo legítimo sem falso alerta, incerteza sem aprovação e mera menção sem atendimento semântico.
Provar também JSON legado, referências inválidas, persistência, revisão tardia, edição, falha de save, revogação durante espera, indisponibilidade e nenhuma chamada adicional automática; jornada real mostra versão, achado, ajuste e saída integral.
Para retirar “qualidade insuficiente”, executar e ler novamente o caso antes falho: distribuição correta, material para começar, traduções presentes, idiomas nos papéis certos e prática solo; detector verde sozinho não permite mudar a linha.
Redação após prova: “Caso X utilizável em execução real datada; conferência estrutural e revisão assistida com limites”; não comprova duração real sem ensaio, fidelidade de toda tradução, eficácia pedagógica, aprendizagem, generalização ou garantia de qualidade.
Consulta só de leitura atual; nenhuma geração/teste executado nem arquivo editado; documento Atlas de governança indicado ausente neste checkout e não usado como autoridade.
