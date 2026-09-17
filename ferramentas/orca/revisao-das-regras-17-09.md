# Revisão das regras — 17/09 (depois do «fiel, não literal»)

Dono, 16/09: a Sábia é parceira de pensamento; quem domina o assunto responde o essencial, não página por página. Cada regra passa por duas perguntas:
- **P1:** protege o autor de um erro real?
- **P2:** deixa o Traço mais forte para pensar junto?

«Protege, mas enfraquece» vai ao dono, não ao código.

| # | Regra | Onde | P1 | P2 | Veredito |
|---|---|---|---|---|---|
| 1 | Nota do autor que não cabe fica fora inteira | FonteNotas (E7) | Não manda linha que ele não escreveu | Não: nota de 200 mil caracteres nunca chega | **Muda** (E9): entra por partes e por síntese |
| 2 | A resposta tem de citar trechos (`trechoIDs`) e cada um tem de existir | `RespostaNotas.interpretar` | Sim: prova de onde veio, impede fonte inventada | Neutro: o texto é livre | **Fica**, como prova de origem, sem obrigar a copiar |
| 3 | Teto de 900 caracteres, corte silencioso | `RespostaNotas.tetoDoTexto` | Sim: resposta que não cabe numa tela | Sim: força o essencial | **Fica** |
| 4 | Barra das medidas = «apoio literal» | ADRs 08q/09x/10b, E8 | Contra invenção | Não: pune a síntese | **Muda**: não inventa, não contradiz, concisão, utilidade (leitor cego) |
| 5 | Fonte com «só o nome» → «não invento o que ela diz» | GuardaDeObra | Sim: sem texto não há tese | Neutro | **Fica** |
| 6 | Sem painel, menu de escolha ou pergunta de escolha (ADR 14a) | UI | Sim: é a ordem do dono sobre ele ESCOLHER | Não impede a Sábia de perguntar para fazer pensar (instigar, contrapor, seguintes) | **Fica**, esclarecida: vale para escolha de interface, não para pergunta de pensamento |
| 7 | A IA nunca escreve COMO o autor | Fronteira (ADR o) | Sim: a voz dele é dele | Não enfraquece se não virar «a Sábia não tem voz» | **Fica**: a Sábia fala na voz dela, resume e conclui; aspas atribuídas ao autor são literais |
| 8 | Seis rotas cortadas por qualidade | Politica | Contra resultado ruim calado | Não: desliga o Tutor inteiro | **Remedir** (E8), com a barra do item 4 e o contexto novo |
| 9 | Só a Decisão vai sozinha ao Grok; o Pré-mortem volta às palavras | 16j | Aprovação do dono foi só para a Decisão | Enfraquece o conselho no Pré-mortem | **Ao dono**: liberar o envio automático do Pré-mortem? |
| 10 | Sem conta Grok, ninguém responde nas rotas «só Grok» | Politica 07b | Sim: o aparelho reprovou medido | Neutro | **Fica** |
| 11 | Trancada e expressiva nunca saem do aparelho | Selo §8 | Sim | Neutro | **Fica** |
| 12 | Obra nunca é voz do autor | 16a | Sim | Sim: separa o que é dele do que é do mestre | **Fica** |
| 13 | A IA não sugere ligação | ADR 03b | Pensamento é do autor | Não: esconde relações | **Mudou** (dono, 16/09): a Sábia aponta com o trecho, o autor junta ou liga (nota viva, E6) |
| 14 | Retrato vai a toda pergunta / só pelo assunto | E7 | Menos ruído | Sim | **Fica** o «pelo assunto»; a síntese do item 1 também serve ao Retrato |
| 15 | A pergunta do Recordar não pode vazar a resposta (`Prova.vaza`) | 11a | Sim: é prova de memória | Sim | **Fica** |

**Ao dono, só um item:** o 9 (Pré-mortem vai sozinho ao Grok, como a Decisão?).
