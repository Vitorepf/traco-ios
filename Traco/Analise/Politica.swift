import Foundation

/// ADR 2026-09-07b — QUEM responde cada operação de IA, e por quê. Uma tabela
/// só, lida pelas rotas e mostrada no Perfil. Antes dela eram cinco políticas
/// soltas (a escada da sábia, a do Trabalho, três `contaLigada`, a de três
/// degraus da classificação e o domínio só de bordo), e o modelo do aparelho
/// seguia em oito rotas onde a medição de 07/09 diz que ele não serve.
///
/// ADR 2026-09-08q acrescentou a quarta regra: `indisponivelPorQualidade`.
/// Até ela, a tabela só sabia dizer "falta conta"; a medida de 08/09 no
/// aparelho do dono, com a conta LIGADA, reprovou seis operações — e mandar
/// conectar uma conta que já existe é mentira na tela.
///
/// A regra nasce da MEDIÇÃO (DIRETRIZ §5: medir, não torcer), e cada linha
/// carrega a prova. Mudar de provedor é mudar esta tabela, e a prova junto.
/// O modelo do aparelho tem 3 bilhões de parâmetros e 4.096 tokens de janela
/// compartilhada entre pedido e resposta; serve para rotular, extrair e
/// escolher entre rótulos fechados com esquema tipado. Não serve para gerar
/// texto longo fiel a restrições, nem para julgar com citação literal.
enum Politica {
    enum Operacao: String, CaseIterable, Sendable {
        case produzir, prepararPratica, conferirTentativa, revisar
        case responderNasNotas, responder, instigar, contrapor, vestir
        case recordar, conferir, ecos, calibragem, padroes
        case classificar, dominio
        case escolherRegra
    }

    enum Regra: Equatable, Sendable {
        /// Grok quando há conta; senão o modelo do aparelho. Para o que o
        /// aparelho já provou ou ainda não reprovou.
        case grokDepoisBordo
        /// Só o Grok. O aparelho foi medido nesta operação e não serviu;
        /// sem conta a tela DIZ, em vez de descer calada a um resultado pior.
        case soGrok
        /// Só o aparelho: rótulo curto, esquema tipado, sem rede.
        case soBordo
        /// NINGUÉM responde: a operação foi medida COM a conta ligada e o que
        /// respondia não atendeu. A linha fica na tabela, com o motivo datado
        /// e a prova — o que sai é o EXECUTOR, não o registro. É distinta de
        /// `soGrok` sem conta: aqui a conta existe, e mandar conectá-la seria
        /// mentira. Volta a ter executor quando algum passar a MESMA matriz.
        case indisponivelPorQualidade
    }

    enum Provedor: String, Sendable {
        case grok = "Grok"
        case bordo = "Apple Intelligence no aparelho"
    }

    struct Linha: Sendable {
        let regra: Regra
        /// A evidência, datada. É o que sustenta a regra e vai para a ADR:
        /// contagem ("3 de 6"), caso concreto e caminho da prova.
        let porque: String
        /// O que a TELA mostra: uma oração curta, em linguagem de pessoa, sem
        /// data e sem caminho de prova — a falha MEDIDA naquela operação, não
        /// um diagnóstico geral. Vazio nas linhas que ainda têm executor: quem
        /// responde não precisa de motivo, e o Perfil só lê este campo na
        /// lista das indisponíveis por qualidade (onde o teste exige que
        /// exista). Não é opcional de propósito — a tela escreve `l.motivo`
        /// sem desembrulhar nem inventar substituto.
        let motivo: String
        /// A data da medida que sustenta a regra, como o autor a lê. A tabela
        /// é UMA só (07b): o Perfil lê daqui em vez de guardar uma cópia que
        /// envelhece sozinha.
        let medidaEm: String?
        /// Só para `indisponivelPorQualidade`: o conserto já nomeado, quando
        /// existe. `nil` = reprovada sem substituto nem conserto conhecido —
        /// e a tela não promete volta que ninguém pode datar.
        let conserto: String?

        init(regra: Regra, porque: String, motivo: String = "",
             medidaEm: String? = nil, conserto: String? = nil) {
            self.regra = regra
            self.porque = porque
            self.motivo = motivo
            self.medidaEm = medidaEm
            self.conserto = conserto
        }
    }

    static func linha(_ op: Operacao) -> Linha {
        switch op {
        case .produzir:
            .init(regra: .soGrok, porque: "o aparelho reprovou 3 de 3 no roteiro de espanhol (minutos que não fecham, palavra inglesa no material) — prova/4.md e prova/qualidade-ia-avaliacao-base.md, 07/09")
        case .prepararPratica, .conferirTentativa:
            .init(regra: .soGrok, porque: "3 de 3 exercícios e 3 de 3 feedbacks do aparelho saíram no formato e não serviram; 0 critérios avaliados por citação não literal — prova/6.md")
        case .revisar:
            .init(regra: .soGrok, porque: "dois casos reais do aparelho sem revisão utilizável: JSON inválido e citações não literais — prova/5.md")
        case .conferir:
            .init(regra: .soGrok, porque: "o aparelho confirmou 3 de 3 um ponto explicitamente contradito e perdeu 3 de 3 uma paráfrase correta; o Grok acertou 6 de 6 casos com a conta ligada em 08/09 — prova/qualidade-ia-q5-avaliacao-base.md e prova/q-qualidade-avaliacoes.jsonl")
        case .ecos:
            .init(regra: .indisponivelPorQualidade,
                  porque: "sem retorno 6 de 6 no aparelho; e com a conta ligada em 08/09 o Grok devolveu lista vazia justamente onde o vínculo era o mais útil (18 inscritos contra a sala que comporta 15) — 3 de 6 casos reprovados — ferramentas/orca/q-qualidade.md, corridas em prova/q-qualidade-avaliacoes.jsonl. CONFERIDA em 10/09 sobre a MESMA corrida, e a contagem fecha: o caso do vínculo mais útil volta [] nas 3 repetições, `qn-ecos-nota-curta` também, e `q5-ecos-sentido-e-contradicao` perde o índice 2 em 1 das 3. O que NÃO se pode afirmar é a CAUSA: aquele JSONL é anterior ao `Grok.Diagnostico.bruto` (ADR 10b) e não guarda o retorno do modelo — zero ocorrências no arquivo inteiro —, então lista vazia VINDA do modelo e lista DERRUBADA pela nossa tesoura (`parseEcos` só aceita o trecho como substring literal da candidata, e descarta em silêncio) são indistinguíveis no registro. É NÃO VERIFICÁVEL, não 'nenhuma derrubada'. O indício disponível vai contra a tesoura: nas repetições com vínculo, os 6 trechos passaram literais. A tesoura LOCAL (`GuardaDeEcos`) agora aceita a citação dela com acento ou espaço diferente; não inventa vínculo. A rota PERMANECE cortada até remedição com bruto. ferramentas/orca/cauda-ecos-calibragem-recordar.md e GuardaDeEcosTests",
                  motivo: "deixa de fora justamente as notas que mais tinham a ver",
                  medidaEm: "08/09/2026")
        case .calibragem:
            .init(regra: .indisponivelPorQualidade, porque: "A PORTA LOCAL já aceita um par (`Sabia.paresDaCalibragem`, ADR 2026-09-11a) — `qn-calibragem-par-unico` deixaria de morrer antes do provedor. A rota PERMANECE cortada: a qualidade de 08/09 ainda não foi remedida depois dessa porta. Das 5 que chegaram, `qn-calibragem-previsao-acertada` volta [] 3 de 3 onde o requisito exige pergunta — calou sobre o que sustentou os acertos. Sem corrida nova, com bruto, um par já é matéria e a tela não promete volta. prova/q-qualidade-avaliacoes.jsonl e ferramentas/orca/cauda-ecos-calibragem-recordar.md",
                  motivo: "não diz nada quando você não errou",
                  medidaEm: "08/09/2026")
        case .padroes:
            .init(regra: .soGrok, porque: "falhou 3 de 3 e 2 de 3 no aparelho; as perguntas locais cobrem — prova/qualidade-ia-q5-avaliacao-base.md")
        case .recordar:
            .init(regra: .indisponivelPorQualidade, porque: "A RÉGUA LOCAL já olha o predicado e os números, não o enunciado (ADR 2026-09-11a, `Prova.vaza`): «Qual é a capital de Portugal?» não vaza Lisboa; «…exatamente 15?» vaza o 15. A rota PERMANECE cortada: o vazamento DO MODELO (`qn-recordar-degrau-avancado` entrega o 15 em 2 de 3 na corrida de 08/09) não foi remedido depois da régua nova. Sem essa corrida a tela não promete volta. A frase fixa do ritual continua cobrindo — prova/q-qualidade-avaliacoes.jsonl, ProvaTests (Lisboa/15) e ferramentas/orca/cauda-ecos-calibragem-recordar.md",
                  motivo: "muitas vezes não devolve pergunta nenhuma, e a que vem já entrega a resposta",
                  medidaEm: "10/09/2026")
        case .responderNasNotas:
            .init(regra: .soGrok,
                  porque: "VOLTOU em 10/09, com a comparação pareada que a DIRETRIZ §10 pede. O LOTE-09d correu a MESMA fixture nos dois modelos, na mesma janela (02:27:24Z–02:33:03Z), com uma instalação só e a conta conferida ligada nas três fumaças: `grok-4.5` passa os 7 casos × 3 (21 de 21) e `grok-4.3` passa 12 de 21 — calcula os R$ 3.354 e NÃO diz os R$ 2.646 em 3 de 3, e expõe os 18 inscritos contra a sala de 15 sem o próximo ato em 3 de 3. A linha de base ficou intacta nos DOIS (cotação na conversa, prazo, sem lastro e instrução hostil, 6 de 6 cada) e `escreveuRotuloInterno` é false nas 42 saídas, lidas inteiras. Por isso o executor é o Grok com o modelo MEDIDO desta rota (`Sabia.modeloMedido`), e não o padrão global — que fica no 4.3 porque o 4.5 é pior no `contrapor`. O aparelho continua fora: ele acertou os fatos 3 de 3 e não citou a nota 3 de 3 (ADR 09h) — prova/lote09d-q3-grok-4.3.jsonl, prova/lote09d-q3-grok-4.5.jsonl e ferramentas/orca/q3-responder-nas-notas.md")
        case .responder:
            .init(regra: .indisponivelPorQualidade,
                  porque: "cortada em 08/09 (a 08q mediu 3 de 6: horário de biblioteca e um total de R$ 1.008 que o contexto não sustentava). O contrato de sustentação em `sistemaResponder` matou a fabricação de NÚMERO (0 em 108 execuções na 08z) e FICA. A Q2-F (ADR 09q) refez a escolha do modelo com UMA alavanca e não achou substituto: `grok-4.3` 15 de 18, `grok-4.5` 17, `grok-4.6` 16, nenhum chega a 18. A ADR 2026-09-10b atacou a alavanca seguinte — o PROMPT — com o conserto que a Q2-F nomeara, e ele NÃO FECHA: duas reescritas medidas contra a base no MESMO binário, 20 casos × 3 cada, deram base **14 e 15 de 20** nas duas janelas, e candidato **12 de 20** nas duas. O defeito é simétrico e nenhuma das duas o separou: mandar ajudar traz de volta a estrutura inventada do documento ('abra o PDF', 'vá ao sumário'), e mandar não inventar faz o modelo parar em 'não consta X' sem o próximo ato (`revisor-orcamento-cotacao-datada` 3 de 3 → 0 de 3 no candidato 1). `revisor-responsavel-nao-definido` reprova 1 de 3 nas duas tentativas. Por isso o conserto do prompt saiu daqui: ele foi tentado e medido. A alavanca seguinte da ordem da Astra é o CONTEXTO. 240 saídas lidas uma a uma, mais 6 de uma pergunta REAL do aparelho da conta; prova/10b/, prova/10b2/ e ferramentas/orca/responder.md. E8 (16/09, PRINCÍPIO DA SÁBIA, árvore pós-E7, leitores cegos): volta 1 — grok-4.5 8 de 20 da matriz 10b e 2 de 4 casos novos, grok-4.3 8 de 20 e 0 de 4: o modelo não é a alavanca, e a causa principal era NOSSA — `SustentacaoPagina.filtrar` trocava a resposta inteira por «Não descrevo um documento» por uma frase (12 de 144). Volta 2 (guarda que tira só a frase + pedido que não supõe o que quem escreve anota ou usa e fecha a conta de data): recusas 8 → 0, respostas que cumprem 42 → 50 de 72, matriz ainda 8 de 20 e novos 2 de 4 — o que reprova é conhecimento geral de documento posto como fato do material («leia o resumo executivo»), telefone 156, hábito suposto, «você mesmo» e falta dita pela metade. Volta 3 (17/09: conhecimento geral dito como geral, guarda local de gênero, faltas com quantidade e unidade; leitores com a regra de que geral MARCADO não é invenção): matriz 12 de 20, novos 2 de 4, respostas que cumprem 59 de 72, «você mesmo» 0 — 7 dos 10 casos reprovados caem por UMA repetição, e a causa principal é de novo NOSSA: a guarda que tira a frase do PDF deixa item de lista vazio e frase órfã. Volta 4 (item inteiro renumerado, profissional em dor, uma nova tentativa no 200 vazio): matriz 13 de 20, novos 4 de 4, 60 de 72, nenhuma resposta quebrada nem vazia — falta UM caso para a barra (≥ 14/20); o que reprova já não é guarda nossa: conflito de datas respondido só com o que falta (0 de 3), suposição do que a pessoa já sabe, conhecimento geral de relatório posto como fato. A decisão de ligar assim é do dono. prova/e8-responder/",
                  motivo: "inventa uma situação que você não escreveu, e às vezes só diz o que falta",
                  medidaEm: "17/09/2026",
                  conserto: "falta a Sábia não supor o que você já sabe ou tem, e dizer o que desempata quando duas informações se contradizem")
        case .instigar:
            .init(regra: .indisponivelPorQualidade,
                  porque: "com a conta ligada em 08/09 o Grok devolveu ao autor o vocabulário interno que o app passa no pedido ('o movimento básico que se pula', 'neste degrau 0', 'a forma nota') — 1 de 6 casos — ferramentas/orca/q-qualidade.md; o conserto tirou o andaime e o G3 do LOTE-1 achou três defeitos novos. O LOTE-3 mediu a Q4-B (6 casos × 3 em grok-4.3 e em grok-4.5) e DERRUBOU dois: o degrau 4 deixou de repetir as perguntas do degrau 0 (3 de 3 nos dois modelos) e a proibição por procedência devolveu o método e o degrau que o AUTOR escreveu (3 de 3 nos dois, inclusive com 'metodo' sem acento). Sobrou o texto magro: as perguntas saem vagas e não pedem QUANDO aconteceu — 3 de 3 no grok-4.3 e 2 de 3 no grok-4.5 — prova/lote09c-q4-grok-4.3.jsonl, prova/lote09c-q4-grok-4.5.jsonl e ferramentas/orca/revisao-q4-instigar.md. A volta INSTIGAR (ADR 10c, 10/09) condicionou a cobrança à MATÉRIA e mediu os DOIS braços no MESMO binário, com o SHA do pedido em cada linha do JSONL: o texto magro passa a pedir o quando em 6 de 6 (2 modelos × 3) contra 4 de 12 da base nas duas janelas juntas, Fisher p = 0,011. E desta vez SEM repetir o colapso do LOTE-5: as perguntas ancoradas na nota ficam na faixa da PRÓPRIA base, 88 a 93%, onde a promoção incondicional as tinha derrubado a 76% e 89%. Contra a base o ganho de 1 ponto é RUÍDO (p = 0,54, e a base contra ela mesma dá 0,37) e a contagem absoluta de ancoradas cai, 55 para 52 no grok-4.3 — o que se afirma é que o preço do LOTE-5 não voltou, não que o candidato ancore mais. O caso CEGO, escrito nesta volta, é o que a segura: numa nota que NEGA por escrito o quando e o \"dar certo\", o grok-4.3 pergunta os dois assim mesmo em 3 de 3 execuções, e o grok-4.5 não pergunta em 3 de 3. A 2ª redação, que mandava a perna só entrar se a nota a tivesse deixado em aberto, consertou o 4.3 e QUEBROU o controle (texto magro de 3/3 a 1/3, ancoradas de 93% a 74%) — foi medida e descartada. A tesoura LOCAL (`GuardaDeInstigar`) derruba a pergunta cuja perna a nota já fechou (negação ou resposta explícita) e não encosta na nota magra; o pedido vigente não muda. A rota PERMANECE cortada até remedição pareada — prova/instigar-lote/t1/*.jsonl, prova/instigar-lote/t2/*.jsonl, GuardaDeInstigarTests e ferramentas/orca/instigar.md",
                  motivo: "quando você diz que não sabe quando foi, ela pergunta assim mesmo",
                  medidaEm: "10/09/2026",
                  conserto: "falta ela parar de perguntar o que você já disse que não sabe")
        case .contrapor:
            // ADR 2026-09-09x — esta linha esteve UM COMMIT fora da lista, e a
            // medida a trouxe de volta. O G3 do LOTE-5 leu 36 execuções e deu 9
            // nas cinco dimensões; a Q4-E remediu os MESMOS seis casos mais dois
            // CEGOS e nenhum modelo passou nos dois lados. Não é opinião nova
            // sobre a mesma prova: é prova nova sobre a mesma opinião.
            .init(regra: .indisponivelPorQualidade,
                  porque: "cortada em 08/09 (08q): o Grok sustentou o contraponto em fato inventado, sempre no outroCampo — 1 de 6 casos, ferramentas/orca/q-qualidade.md. O conserto matou a evidência fabricada e ela não voltou; o LOTE-5 derrubou os dois defeitos do LOTE-3 e o G3 deu 9 nas cinco dimensões nas 36 execuções. O LOTE-6 (Q4-E) reprovou os DOIS modelos em lados opostos: o grok-4.3 fechou q4-contrapor-tudo-ou-nada rep. 2 com os TRÊS campos vazios sobre HTTP 200, e o grok-4.5 propôs 3 de 3, no caso cego, o ensaio que a nota fecha por escrito. A Q4-F (ADR 09/10c) gastou as DUAS tentativas do regime numa alavanca só — o PEDIDO — e mediu as duas na MESMA fixture do LOTE-6, byte a byte (SHA da012e21…), no aparelho da conta 34CC3F94, uma instalação por janela, `cmp` do dylib antes e no fim, conta ligada nas quatro fumaças. LOTE-7 (15:54Z-16:05Z), tentativa 1 — o que ela já descartou é DADO: os três campos vazios do 4.3 foram a ZERO (1 → 0) e as propostas da saída fechada no foraDaLista do 4.3 também (3 → 0); o 4.5 caiu de 3/3 para 1/3 de reprovação no caso cego. LOTE-8 (16:14Z-16:26Z), tentativa 2 — a mesma regra estendida ao substituto e ao argumento a favor: o 4.5 passa o cego `razoes-fechadas` 3 de 3 e o `alternativas-negadas` 2 de 3, com campos vazios 0 de 72 nos dois lotes; o 4.3 piora no cego (1 de 3 em cada) e melhora nos vazios (14 → 10 de 72). NENHUM dos dois passa os DOIS casos cegos em 3 de 3, e por isso a rota não volta. O que sobra é UM defeito, medido nas duas tentativas: para o recurso que a nota diz não ter, o modelo oferece um SUBSTITUTO (ensaio com dado sintético, cópia mascarada, recorte representativo) — a falta declarada é lida como lacuna a preencher. Também ficou medido que o retorno vazio do modelo não se distinguia do apagado pela guarda sem o retorno BRUTO, que esta volta passou a preservar. prova/lote09g/, prova/lote09h/ e ferramentas/orca/q4f-contrapor.md. A TERCEIRA alavanca — o ESQUEMA DA SAÍDA (ADR 2026-09-10d) — foi medida no LOTE-9 (10/09, 19:45Z-20:11Z, aparelho da conta B91C8DEF, uma instalação, os DOIS braços no MESMO dylib com o antigo escolhido por ambiente, conta ligada nas quatro fumaças) e TAMBÉM NÃO PASSA. O esquema obriga o modelo a enumerar em `fechadas` o que a nota fecha ANTES de existir proposta, e a guarda `dependeDoQueElaFechou` decide no nosso lado. No grok-4.3 o substituto sumiu do `foraDaLista` em 3 de 3 no cego das alternativas negadas, e a guarda não disparou nenhuma vez lá — o ganho é da FORMA, não da guarda. No grok-4.5 o substituto passou inteiro em 1 de 3 ('espelho com dados reais ou mascarados fiéis') porque o próprio modelo deixou o ambiente de teste FORA da lista que ele mesmo escreveu: separar fato de decisão não impede o modelo de encolher o fato. E a guarda disparou 5 vezes nos dois braços com 1 acerto e 4 erros, sempre sobre proposta que usava de outro jeito um recurso que ela JÁ TEM. O polo de controle pagou: no grok-4.5 o `foraDaLista` caiu de 18 para 17 de 18 (o perdido foi erro da guarda) e o comprimento médio caiu de 139 para 73 caracteres. A recontagem SEM o join, feita da MESMA prova (o `bruto` guarda o que o modelo escreveu antes da guarda), diz o resultado: no grok-4.3 o polo de controle NÃO CAI (11 para 13 de 18) e o substituto não aparece nos DOIS cegos em 3 de 3 — o primeiro braço a chegar lá. O G3 mediu o piso de ruído e ele proíbe a seta: o MESMO braço antigo, com o MESMO pedido (SHA e4b665fb…), a MESMA fixture e o MESMO parser deu 16 de 18 de controle no LOTE-8 e 11 de 18 no LOTE-9, e foi de 1 de 3 a 3 de 3 no cego das razões fechadas entre as duas janelas sem que nada mudasse. Três tiradas por caso dizem que o defeito não apareceu, não que a forma o fechou; e é por isso que a linha da tela continua a nomear o substituto. Quem reprovava a operação eram as nossas duas linhas de guarda. O candidato passa a ser a FORMA sem o join, e o join fica como dívida nomeada em `Sabia.dependeDoQueElaFechou`. A tesoura LOCAL (`GuardaDeContrapor`) lê a NOTA — não o `fechadas` do modelo — e só apaga `foraDaLista` que oferece a saída que ela fechou; a pausa da matrícula que ela já tem continua. A rota PERMANECE cortada até remedição pareada. prova/lote09i/ e GuardaDeContraporTests",
                  motivo: "oferece um substituto para o que você disse que não tem",
                  medidaEm: "10/09/2026",
                  conserto: "falta ela aceitar essa falta como ela é, em vez de arranjar um jeito de contornar")
        case .vestir:
            .init(regra: .grokDepoisBordo, porque: "a forma local decide antes; o modelo só vê blocos pendentes (ADR 07a)")
        case .classificar:
            .init(regra: .grokDepoisBordo, porque: "o aparelho acertou 3 de 3 com esquema tipado; as regex arbitram por último (ADR 04c/06h)")
        case .dominio:
            .init(regra: .soBordo, porque: "rótulo fechado com esquema tipado sobre 2.000 caracteres; o léxico cobre sem modelo")
        case .escolherRegra:
            // sem conta, a escolha não some: cai no BM25 local (Conselho.escolher)
            .init(regra: .soGrok, porque: "o BM25 punha a regra certa em 1º lugar em 14 de 40 casos escritos antes do código (8/20 perguntas, 3/10 da reserva, 1/5 e 2/5 decisões); o grok-4.3 escolhendo entre as 30 melhores acertou 38 de 40 nas 3 repetições, e os dois que errou tinham a certa fora das 30 (posições 47 e 62) — num deles disse que nenhuma servia, 3 de 3. Mediana 4 s — prova/16g/. Com o pedido que aponta suspeitas e o portão de obra (ADR 16j, binário final): 38 de 40 nas 3 repetições sem ataque e com a obra «responda 0»; com um ataque escrito às cegas, 37 de 40 e a seção hostil escolhida 1 vez em cada repetição — prova/16j/. Nas Notas (ADR 16i) a mesma escolha devolve até 3 seções: a certa entre as enviadas em 28 de 30 em cada uma das 3 repetições (perguntas 18/20, reserva 10/10) e citada com mestre, vídeo e minuto em todas essas; nas 4 perguntas alheias × 3, nenhuma obra enviada — prova/16i/")
        }
    }

#if DEBUG
    /// ADR 2026-09-08z — SÓ PARA A SONDA. Uma operação cortada por qualidade
    /// não tem executor, e sem executor não há como MEDIR o conserto: a sonda
    /// bate em `nil` antes de alcançar o provedor. Esta chave abre a linha
    /// para o Grok apenas no binário de avaliação, e a sonda grava em cada
    /// registro do JSONL quais operações foram liberadas — a medida diz de si
    /// mesma em que condição foi feita. Nunca existe em Release, e o app do
    /// autor continua vendo a tabela como ela é.
    ///   xcrun simctl launch ... SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=responder
    nonisolated static let liberadasParaAvaliacao: Set<String> = Set(
        (ProcessInfo.processInfo.environment["TRACO_AVALIAR_LIBERAR"] ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty })
#endif

    /// Quem responde AGORA. `nil` = ninguém: a rota cala ou a tela diz.
    static func provedor(_ op: Operacao,
                         contaLigada: Bool = ContaGrok.ligada,
                         bordo: Bool = Sabia.noAparelho) -> Provedor? {
        switch linha(op).regra {
        case .soGrok: contaLigada ? .grok : nil
        case .soBordo: bordo ? .bordo : nil
        case .grokDepoisBordo: contaLigada ? .grok : (bordo ? .bordo : nil)
        case .indisponivelPorQualidade:
#if DEBUG
            liberadasParaAvaliacao.contains(op.rawValue) && contaLigada ? .grok : nil
#else
            nil
#endif
        }
    }

    /// A regra deixa o aparelho responder quando o Grok não respondeu?
    static func desceAoAparelho(_ op: Operacao) -> Bool {
        linha(op).regra == .grokDepoisBordo
    }

    /// A frase para a tela quando ninguém responde. Uma por operação, sem
    /// culpar o aparelho pelo que ele não promete.
    static func semProvedor(_ op: Operacao) -> String {
        switch op {
        case .produzir: "Preparar uma versão pela IA precisa da conta Grok (em Perfil); o modelo do aparelho não produziu com qualidade."
        case .prepararPratica, .conferirTentativa: PraticaTrabalho.semProvedor
        case .revisar: RevisaoTrabalho.semProvedor
        case .conferir: "Conferir o que voltou pela IA precisa da conta Grok; o modelo do aparelho errou a comparação."
        case .padroes: "Precisa da conta Grok; o modelo do aparelho não serviu aqui."
        // ADR 09v: a `responderNasNotas` SAIU desta lista em 10/09 e virou
        // `.soGrok` — a frase dela agora é a de quem só precisa de conta.
        // As SEIS abaixo continuam INDISPONÍVEIS POR QUALIDADE (ADR 08q; a
        // `responder` saiu da lista na 09n e VOLTOU no mesmo dia, quando o G3
        // reprovou a escolha do modelo): a conta pode estar ligada e mesmo
        // assim ninguém responde, porque o que respondia não atendeu.
        //
        // ADR 09z — a LÍNGUA destas seis é a do autor, e este é o pior lugar
        // possível para o nosso jargão: ele lê isto NO MOMENTO em que toca a
        // operação e ela não acontece. Sem data, sem "medida", sem causa
        // nossa: o que ela ainda não faz por ele, no presente, e o que ele
        // pode fazer agora. A frase não manda conectar conta, não pede para
        // tentar de novo e não promete guardar nada — quem guardou o pedido é
        // que diz isso, depois de confirmar.
        case .responder: "Responder à sua pergunta pela IA está indisponível: ela ainda inventa uma situação que você não escreveu e, às vezes, só diz o que falta em vez de ajudar. O que você escreveu continua aqui, e a sua pergunta fica na nota."
        case .ecos: "Sugerir notas parecidas está indisponível: a IA deixava de fora justamente as que mais tinham a ver."
        case .calibragem: "Ler o seu juízo pela IA está indisponível: ela ainda não diz nada quando você não errou. Os seus pares de previsão e resultado continuam aqui para você comparar."
        case .recordar: "A pergunta do Recordar pela IA está indisponível: muitas vezes ela ainda não devolve pergunta nenhuma, e a que vem já entrega a resposta. O ritual segue com a pergunta fixa."
        case .instigar: "Instigar pela IA está indisponível: quando você diz que não sabe quando foi, ela pergunta assim mesmo. As perguntas do método continuam na página."
        case .contrapor: "Contrapor pela IA está indisponível: ela ainda oferece um substituto para o que você disse que não tem. O Steelman e a Inversão continuam no catálogo, escritos por você."
        case .responderNasNotas: "Responder as perguntas que você deixa nas notas precisa da sua conta Grok (em Perfil)."
        case .vestir, .classificar:
            "A Sábia precisa da sua conta Grok (em Perfil) ou da Apple Intelligence ligada."
        case .dominio: "O domínio pela IA precisa da Apple Intelligence ligada; sem ela, o léxico decide."
        case .escolherRegra: "Escolher pelo sentido a regra dos mestres para a sua Decisão e para as Notas precisa da sua conta Grok (em Perfil); sem ela, e sempre no Pré-mortem, a escolha é pelas palavras."
        }
    }

    /// O que a TELA DIZ, no ponto em que o autor tocou. `nil` = há quem
    /// responda e a rota segue. ADR 2026-09-09q: `semProvedor` já existia com
    /// uma frase por operação, mas cada rota decidia sozinha se perguntava —
    /// e a Lente perguntava a `Sabia.disponivel`, que responde "sim" com a
    /// conta ligada mesmo quando a tabela diz que ninguém responde. Resultado:
    /// o autor tocava "Instigar", via o laço girar e recebia uma VIBRAÇÃO.
    /// Uma linha aqui, e a resposta é a mesma em toda rota.
    static func aviso(_ op: Operacao, contaLigada: Bool = ContaGrok.ligada,
                      bordo: Bool = Sabia.noAparelho) -> String? {
        provedor(op, contaLigada: contaLigada, bordo: bordo) == nil ? semProvedor(op) : nil
    }

    /// Para o Perfil: o que o aparelho faz sozinho, o que exige a conta, e o
    /// que NÃO TEM MAIS EXECUTOR. As três listas juntas são as dezesseis; uma
    /// operação indisponível por qualidade não pode aparecer nas outras duas,
    /// porque isso prometeria ao autor uma ajuda que ele não vai receber.
    static var pelaConta: [Operacao] { Operacao.allCases.filter { linha($0).regra == .soGrok } }
    static var peloAparelho: [Operacao] {
        Operacao.allCases.filter { linha($0).regra == .soBordo || linha($0).regra == .grokDepoisBordo }
    }
    static var indisponiveis: [Operacao] {
        Operacao.allCases.filter { linha($0).regra == .indisponivelPorQualidade }
    }

    static func nome(_ op: Operacao) -> String {
        switch op {
        case .produzir: "preparar versões no Trabalho"
        case .prepararPratica: "preparar exercícios"
        case .conferirTentativa: "conferir a sua tentativa"
        case .revisar: "revisar uma versão"
        case .responderNasNotas: "responder nas Notas"
        case .responder: "responder à sua pergunta"
        case .instigar: "instigar"
        case .contrapor: "contrapor"
        case .vestir: "dar a forma certa à nota"
        case .recordar: "a pergunta do Recordar"
        case .conferir: "conferir o que voltou"
        case .ecos: "sugerir notas parecidas"
        case .calibragem: "comparar o que você previu com o que aconteceu"
        case .padroes: "perguntas dos Padrões"
        case .classificar: "reconhecer o tipo de nota"
        case .dominio: "o domínio da nota"
        case .escolherRegra: "escolher a regra dos mestres"
        }
    }
}
