# Revisão independente — volta L2 da latência (G3)

**Veredito: CORRIGIR ANTES — Design chega a 9; Simplicidade fica em 8, e há dois bloqueios de contrato/evidência.** Revisei `8e3a1a5...9bea1b8`; não editei Swift, não desliguei o `C2416CBC`, não limpei Safari e não toquei nos UDIDs proibidos.

## Achados que impedem o G5

### [P1] A ADR registrada não usa a letra reservada para esta volta

O contrato desta tarefa reserva `08h`; o candidato cria `## ADR 2026-09-08b` em `SPEC.md:5391`, e `EVOLUCAO.md:14` também a chama de `ADR 08b`. SPEC e EVOLUCAO concordam entre si, mas ambos divergem do identificador explicitamente reservado; é fronteira documental, não uma variação editorial.

**Correção:** renomear esta ADR e todas as suas referências de L2 para `08h`, depois conferir SPEC e EVOLUCAO juntos.

### [P1] As capturas “depois” não são prova do `HEAD` que está sendo julgado

No `HEAD`, `PerfilView.swift:227` contém `Sai das hipóteses ...` e `:280` contém `nos 12 últimos.`. Já `ferramentas/orca/l2-depois-modo-b.png` mostra a copy anterior, `Sai do que já está escrito ...`, e `l2-depois-teto-12-meses.png` mostra `nos últimos 12 meses com descobertas.`; ambas são diferentes do binário-fonte deste commit e coincidem com a copy anterior/intermediária. Logo, elas confirmam a direção visual, mas não G2 do candidato final nem as alturas atribuídas a ele.

**Correção:** compilar o `9bea1b8`, semear novamente os estados A, B, vazio e vinte meses, e substituir as capturas/árvores AX e as três medidas pelo mesmo binário.

### [P2] A troca de densidade é progresso, mas a auto-nota 8 de Simplicidade é calibrada

As contas declaradas fecham: `(5.541 - 5.200) / 5.200 = 6,56%` e `(6.148 - 5.340) / 6.148 = 13,14%`, isto é, `+6,6%` na série curta e `-13%` na longa. Não consegui reproduzir a geometria: após anexar explicitamente o `C2416CBC`, o helper global voltou a apontar ao `A1DF...` e as chamadas seguintes perderam o aparelho; isso confirma A3, mas não é uma segunda medição. A troca elimina o crescimento sem limite, portanto é progresso real no caso longo; contudo, no Perfil cuja nota-base de Simplicidade já era 6, o cartão ainda cresce 341 pt no caso curto, então não chega a 9.

**Correção:** reduzir pelo menos esses 341 pt no estado curto sem devolver `Tema.miudo` nem ocultar um estado (por exemplo, uma apresentação realmente compacta dos detalhes dos registros), e medir de novo A e vinte meses no binário final.

## O que foi confirmado

- `ForEach(lista.suffix(12))` em `PerfilView.swift:285` é o teto correto dos doze meses; a legenda em `:280` declara o horizonte. A linha singular em `:288-290` passa a dizer `1 descoberta · levou ...`.
- `rg -n 'Tema\\.miudo' Traco` não devolve resultado. O token permanece vivo no widget (`TracoWidget/TracoWidget.swift`, por exemplo linhas 151 e 156), como determina a ADR 05u.
- O resumo usa duas chamadas de `Latencia.emPalavras` (`PerfilView.swift:251-253`) e não há arquivo alterado em `Traco/Modelo` nem `Traco/Analise`. Não encontrei regressão de placar: a ordem segue cronológica, não há meta/sequência/%/streak, não há cor por estado, nem alvo novo.
- A captura preservada `l2-incidente-grok-perfil-sem-conta.png` contém literalmente `sem conta — recursos locais disponíveis`; ela prova o estado às 11h23 e não mostra token no Traço. Não pude renovar essa confirmação ao vivo por A3; não alterei o login nem as abas do Safari.
- A captura `l2-achado-ax5-transbordo-head.png` mostra o transbordo; o diff não toca `Traco/App/Camadas.swift` nem `RaizView.swift`. Isso sustenta a atribuição ao RUMO, não à L2, mas a reprodução independente em HEAD ficou impedida pelo mesmo helper global e não deve ser vendida como nova prova.

## Scorecard

| dimensão | nota | evidência e julgamento |
|---|---:|---|
| Visão | 9 | Fecha a lacuna explícita da L1 no `EVOLUCAO.md:14`: a leitura continua descrevendo capacidade, não pendência. |
| Contrato | 8 | SPEC e EVOLUCAO concordam com o código, mas registram `08b`, não o `08h` reservado. |
| Correção | 8 | O diff é mínimo e não toca modelo/analise; há relato de 887 testes, mas não há teste novo nem prova visual do binário final. |
| Jornada real | 7 | MODO B, meses e conta foram inspecionados nas capturas, mas as capturas pós-mudança têm copy divergente do HEAD; vazio pós-mudança continua sem foto. |
| Design | **9** | O teto, o degrau `meta`/`tintaSuave`, a manchete em duas linhas e os quatro estados cinza atendem ao G4; as fases do `design-router` e a `curva-zero` constam do relato e a tela confirma a direção. |
| Simplicidade | **8** | Progresso no caso longo, mas +341 pt no caso curto; a auto-crítica 8 é correta, não subestimação. |
| Movimento | 9 | Nenhuma animação nova; ausência deliberada e adequada a uma superfície de leitura. |
| Componentes | 9 | `resumo` é helper privado pequeno no padrão herdado; não há componente duplicado, dependência ou abstração nova. |
| Acessibilidade | 8 | A ordem/combinação descritas são coerentes e a L2 não toca Camadas/Raiz; porém a prova AX5 final não é do HEAD e há dívida horizontal pré-existente no Perfil. Não desconto essa dívida desta volta. |
| Performance | 9 | `suffix(12)` limita a lista que renderiza; não houve caminho de IO/rolagem novo. |
| Privacidade e autoria | 9 | Nenhuma rota protegida mudou; a captura preservada informa `sem conta`, e Modelo/Analise não entram no diff. |
| Estado honesto | 9 | Teto declarado, quatro estados preservados e singular sem estatística falsa; nenhum placar entrou. |
| Complexidade | 8 | `PerfilView` soma 52 e remove 16 linhas, incluindo comentário excessivo; a extração do resumo é pequena, mas não há redução líquida. |
| Fora do app | n/a | Nenhuma superfície externa foi alterada; só foi verificado que `Tema.miudo` continua no widget. |
| Relato | 7 | É detalhado e declara custos/instrumento, mas afirma ADR 08b e apresenta capturas que não correspondem à copy do HEAD. |

## Instrumento e limites

Usei apenas `orca emulator` com o UDID concedido e `simctl io <UDID> screenshot`; o simulador permaneceu ligado. A anexação começou no `C2416CBC`, mas o servidor da máquina alternou para `A1DF082C` e devolveu `No active emulator`/`ERR_CONNECTION_REFUSED`, reproduzindo a limitação A3 sem permitir uma medição independente limpa. A substituição por árvore AX serve para **altura** quando pertence ao mesmo binário; não substitui uma foto de clipping, nem serve aqui porque as fotos arquivadas divergem da copy do candidato. A árvore do vazio serve apenas para geometria/elemento, não para validar leitura visual do vazio.

## Fecho

As quatro correções de interface estão presentes no código e Design chega a 9. A L2 resolve o crescimento sem fim, mas troca parte dele por crescimento mensurável no caso curto; Simplicidade 8 é a nota honesta. Antes de novo portão: corrigir `08h`, regenerar as provas do `9bea1b8` e reduzir a altura curta; o transbordo AX5 continua dívida do RUMO, não desconto desta volta.
