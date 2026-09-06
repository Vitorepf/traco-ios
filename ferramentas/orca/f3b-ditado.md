# F3b — o áudio antes da letra (relatório da volta)

**Ciclo.** MULTIPLICAR: intenção → artefato. A frase falada na rua vira nota
mesmo quando a letra não vem.

## As seis fases do design-router

**Ancorar.** Li a 05a (o áudio depositado primeiro, falha preserva o áudio), a
05w (o que a F3 entregou e por que parou no ditado do teclado), `Ditado.swift`
do calendário (que já fixou a linguagem de recusa e o contrato de
`requiresOnDeviceRecognition`), `AnexoDisco`/`BlocoCaderno`/`PortalArquivoView`
(que já leem, desenham e TOCAM `[audio:nome](traco://audio/<id>)` dentro da
nota) e `ConfirmacaoView` (o idioma visual de toda tela que cobre). Pessoa e
situação: o autor andando, com pressa, tocando o controle na tela bloqueada.
Resultado verificável: uma nota com o áudio dentro e uma linha verdadeira.
Restrição: o áudio não sai do aparelho; nada de blob no SwiftData; `Traco/Pagina`,
`Traco/Caderno`, `Traco/Componentes`, `Camadas.swift` e `TracoWidget/` fechados
(voltas 12, 16 e F4 em curso).

**Sistema.** Zero tokens novos e zero componentes novos. `Tema.fundo/tinta/
tintaSuave/tintaFraca/ambarTinta/aviso`, `confirmacaoTitulo/confirmacaoCorpo/
chrome/barra/meta/mono`, `Raio.campo`, `alvo`, `Duracao.media/toque`,
`Tema.movimento(...)`, `PressaoDiscreta`. O único número novo é o lado do ponto
de nível, e ele é `@ScaledMetric` — cresce com o texto.

**Construir.** Roteiro em texto antes do layout (curva-zero §2), com falha e
recuperação desde o começo: gravando → (Pronto) depósito → transcrevendo →
transcrito | falha (com "Tentar de novo" sobre o MESMO arquivo) | sem microfone
(com "Escrever em vez disso", que é a 05w intacta). Uma tarefa por tela, no
máximo duas ações, ação principal primeiro.

**Mover.** A troca de estado é SECA. A primeira versão animava por opacidade e a
captura mostrou "Gravando." e "Áudio guardado." SOBREPOSTOS e ilegíveis
(`f3b-02-transcrevendo-sobreposto.png`) — mesma decisão que a raiz já tinha
tomado na troca de aba. A entrada da superfície segue a lei do `Tema`: escala e
desfoque no normal, só opacidade sob Reduzir Movimento
(`f3b-entrada-normal-quadros.png` × `f3b-entrada-reduzida-quadros.png`,
`f3b-movimento.mp4` lado a lado). O ponto de nível fica quieto sob movimento
reduzido; o relógio, que é informação, continua andando.

**Julgar.** Dois defeitos achados na tela e corrigidos na volta: (1) o teclado
da Página subia POR CIMA da gravação — o foco continua armado por baixo, então a
superfície o derruba ao aparecer e a raiz o segura enquanto o ditado está na
tela; (2) um segundo toque no controle não fazia nada quando um ditado JÁ
TERMINADO estava na tela — agora só gravação em curso resiste à substituição.

**Portão.** G1 build dos dois alvos sem aviso e suíte 724/126 verde. G2 capturas
simctl dos cinco estados em large, dois em AX5, a nota nos dois desfechos, a
lista, a saída sem microfone, e vídeo com e sem Reduzir Movimento. G3/G4 são de
outra sessão.

## Curva-zero

**Jornada:** um toque fora do app → fala → a frase entra. **Resultado
verificável:** nota nas Notas com o áudio tocável dentro e a linha de origem.
**Atrito observado (F3):** o autor chegava à página com o teclado pronto e
ainda tinha de achar o microfone; e o que ele dizia dependia inteiramente de a
transcrição do teclado dar certo. **Recuperação:** a falha não é beco — o áudio
já está guardado, "Tentar de novo" re-transcreve o mesmo arquivo, e sem
microfone a tela oferece escrever. **Poder preservado:** `traco://anotar`, o
`AnotarIntent` da Siri e a página em branco com o teclado continuam existindo.

## Estados capturados (iPhone Air 64F7B8B4, build da árvore final)

| arquivo | estado |
|---|---|
| `f3b-01-gravando.png` | gravando: relógio, ponto de nível, Pronto, Descartar |
| `f3b-02-transcrevendo.png` | áudio guardado, transcrevendo — "a nota já existe" |
| `f3b-04-transcrito.png` | transcrito + "Confira quando puder" |
| `f3b-03-falha.png` | falha real da transcrição (o simulador não tem modelo de fala no aparelho) |
| `f3b-08-sem-microfone.png` | microfone negado: "Nada foi gravado" |
| `f3b-09-escrever-em-vez-disso.png` | a saída: página em branco com o teclado (05w) |
| `f3b-05-notas-lista.png` | as notas do ditado na lista |
| `f3b-06-nota-transcrita.png` | a nota com a transcrição, o portal de ÁUDIO (95 KB) e a origem |
| `f3b-07-nota-falha.png` | a nota da FALHA: o áudio de 99 KB e a linha honesta |
| `f3b-10-ax5-gravando.png`, `f3b-11-ax5-falha.png` | AX5 sem clipe |
| `f3b-movimento.mp4` | normal × Reduzir Movimento, lado a lado |
| `f3b-02-transcrevendo-sobreposto.png` | o defeito que motivou a troca seca |

## O que NÃO foi possível provar aqui

- **Transcrição real em português.** O simulador não tem o modelo de fala no
  aparelho, e o contrato de privacidade proíbe o reconhecimento remoto: no
  simulador a letra sempre falha. O estado "transcrito" foi encenado pelo
  instrumento `traco://ditar?ensaio=transcrito` (só em Debug), que troca SÓ o
  reconhecedor — microfone, gravação, depósito e nota continuam reais. A
  qualidade da transcrição pede o aparelho do dono.
- **Ditado com o app fechado.** Fora do escopo: o controle abre o app.
- **VoiceOver com pessoa.** Rótulos, `isModal`, ação de escape e anúncios por
  estado estão no código e no fluxo maestro; leitor de tela real, não.
