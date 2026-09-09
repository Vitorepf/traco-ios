# G3 — revisão independente da R1: retomada do Trabalho

**Veredito: CORRIGIR ANTES.** O contrato determinístico da retomada é bom e a recusa de rolar automaticamente está correta, mas a volta fica abaixo da régua: o relato não cumpre as seis fases obrigatórias do `design-router`, a `curva-zero` não foi medida em toques/gestos e o próprio autor marcou Complexidade 8.

Revisor independente: Codex GPT-5. Simulador reservado: iPhone 17 Pro (teste 3) `34CC3F94-FDB5-4575-A4F5-80271829A18B`. Usei somente esse UDID; não toquei o `C2416CBC`. Toda chamada ao helper passou por `com-trava.sh`; nenhuma voz, Siri, ditado, VoiceOver, iPad, Maestro ou cursor do Mac foi usado. Repeti os mesmos três toques (Notas → Trabalhos → documento) e conferi captura + árvore simultâneas em `ferramentas/orca/g3-r1-folha-estavel.png`: bloco datado, quatro linhas, excedente, data e resultado estão presentes. Isso confirma o estado normal, não os estados sem visita e AX5.

## Achados

### ALTO — G4 Design: as seis fases obrigatórias não foram relatadas

`ferramentas/orca/r1-retomada.md:19-23` cita a rota e somente “fase 5 (auditar antes de tocar)”. Não há **Ancorar, Sistema, Construir, Mover, Julgar e Portão** citados e confrontados com a tela, como exige `ferramentas/orca/ESTEIRA.md:25-28`. O score 9 de Design é incompatível com esse portão documental; é **6/10** até o dono registrar as seis fases e a prova visual correspondente. Não é uma exigência de redesenho: basta fechar o relato do ajuste local que foi realmente feito.

### ALTO — Simplicidade: “telas” não é a medida de toques requerida

O relatório mistura três medidas: os três toques até a folha são iguais (`r1-retomada.md:63-65`), as posições AX caem de 1,57–4,22 para 0,48–0,67 (`:52-61`), e daí infere “no mínimo quatro arrastos” (`:67-71`). A primeira só prova que a entrada não ganhou custo; a segunda prova geometria/presença, não quantos gestos uma pessoa executa. A própria ADR em `SPEC.md:6798-6802` diz que o arrasto do helper amplifica 6–24x e por isso não é régua. Logo a comparação não sustenta a nota 9 de curva-zero em toques: é **7/10** até haver roteiro antes/depois com toques e gestos realmente executados (ou uma métrica de tarefa diferente, declarada sem chamá-la de toques).

### MÉDIO — Cobertura de interface e AX5 é incompleta para o novo bloco

Os cinco testes em `TracoTests/RetomadaTrabalhoTests.swift` exercitam `mudancasDesde`, a janela temporal e as âncoras, mas não a persistência da visita, o teto de quatro linhas nem o excedente no `TrabalhoView`. A captura normal `r1-depois-decisoes-e-teto.png` mostra quatro linhas e “e mais 1”, o que é evidência positiva desse estado; já `r1-depois-ax5.png` mostra o topo da folha, sem o bloco “Desde”. Ausência na árvore não serviria para concluir que o bloco não está lá, mas tampouco essa captura prova sua legibilidade em AX5. Jornada real, Correção e Acessibilidade ficam **8/10** até cobrir os estados sem visita, mais de quatro eventos e AX5 com captura + árvore do mesmo instante.

### MÉDIO — UserDefaults é correto para a semântica escolhida, com limite explícito

`TrabalhoView.swift:1555-1562` lê/grava `trabalho.visita.<uuid>` uma vez por folha; isso preserva a janela durante uma reabertura na mesma visita e evita escrever no documento compartilhado. Para **dois aparelhos**, cada um terá sua própria primeira/última visita; para **reinstalação** (ou limpeza de dados) a chave some e a primeira abertura cala; depois de **um mês**, a mesma chave continua e mostra os eventos desde a última visita, sujeita ao teto + excedente. Isso é coerente com a ADR, não um defeito, mas falta teste que fixe esses três limites e a tela não informa que a janela é local ao aparelho.

## Conferências favoráveis

- A recusa de rolagem automática é correta. Antes e depois colocam intenção em 0,15 e “Continuar” em 0,36 tela; rolar esconderia o objetivo que o critério manda retomar. O diff confirma que não foi deixada uma âncora quebrada: a folha não programa rolagem na abertura, salvo foco/ação explícitos.
- “Escrito pelo app, nunca por modelo” se sustenta no diff. `DocumentoTrabalho.mudancasDesde(_:)` (`Traco/Trabalho/Trabalho.swift:356-387`) só interpola `Artefato`, `Acao`, `Evidencia`, `apoioMarcadoEm`, `trechoDelimitadoEm` e `Hipotese`; não chama `Grok`, `Sabia`, `OficinaTrabalho.gerar` nem recebe texto gerado. A view apenas apresenta essa lista em `TrabalhoView.swift:250-275`.
- O teto existe no código: `prefix(Self.tetoDaRetomada)` e a linha explícita `e mais N desde então` em `TrabalhoView.swift:259-271`. A captura normal confirma o caso de seis mudanças: quatro exibidas e “e mais 1”, porque o relato já mostrado abaixo é removido da lista para não duplicar a notícia.
- A separação entre executado e observado permanece honesta: `Trabalho.swift:363-375` cria linhas distintas, e `retomada` mantém data e resultado do último retorno (`TrabalhoView.swift:218-240`).

## Scorecard

| Dimensão | Nota | Evidência / limite |
|---|---:|---|
| Visão | 9 | Item 4 do ciclo multiplicar; EVOLUCAO declara honestamente que uso real ainda falta. |
| Contrato | 9 | ADR 08y, SPEC, EVOLUCAO e diff coerentes. |
| Correção | 8 | Testes de domínio/âncora e verde histórico 963/155; sem teste de visita/teto na view e sem corrida independente concluída. |
| Jornada real | 8 | Estado populado repetido localmente com três toques, captura e AX pareados; ainda sem os estados sem visita e AX5. |
| Design | **6** | Seis fases obrigatórias ausentes do relato. |
| Simplicidade | **7** | Distância AX melhorou; contagem de toques/gestos não foi medida. |
| Movimento | n/a | Nenhum movimento novo da R1. |
| Componentes | n/a | Nenhum componente novo. |
| Acessibilidade | 8 | AX5 lateral positivo, mas o bloco novo não foi visível na captura AX5. VoiceOver falado, corretamente, não foi usado. |
| Performance | n/a | Sem evidência de regressão de lista/editor/parser nesta mudança local. |
| Privacidade e autoria | 9 | Janela local, vínculos preservados, nenhuma chamada de modelo na retomada. |
| Estado honesto | 9 | Datas ausentes não são inventadas; executado e observado seguem distintos. |
| Complexidade | **8** | O próprio relatório registra +146 linhas de produção e nota 8; a ESTEIRA não permite arredondar. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 6 | Sem as seis fases e sem medida de toques que afirma. |

## Próximo portão mínimo

1. Completar o relato do design-router com Ancorar, Sistema, Construir, Mover, Julgar e Portão, cada um ancorado à tela.
2. Repetir a curva-zero por uma tarefa definida, contando toques e gestos reais nos dois candidatos; manter as alturas AX como medida complementar, não como substituta.
3. Acrescentar prova de UserDefaults (primeira visita/reabertura), teto e excedente, e captura + AX simultâneos do bloco em AX5.

Não alterei código de produto, SPEC ou EVOLUCAO.
