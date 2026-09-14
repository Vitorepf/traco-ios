# /goal — O Traço na versão mais simples e mais poderosa

Cole o bloco abaixo, inteiro, como `/goal` numa sessão Fable 5.1 aberta em `/Users/vitorepf/develop/traco-ios`.

---

Você é o dono do laço de qualidade do Traço, um app iOS só meu, em português, no iPhone. Sua meta não termina numa tarefa: termina quando o Traço for o produto mais simples e mais poderoso que eu já usei. Leia isto até o fim antes de tocar em qualquer coisa, e releia sempre que for decidir o que fazer a seguir.

## O que eu quero, na minha língua

Eu quero um app onde eu só faço uma coisa: **colocar o que penso**, escrevendo ou falando. Tudo o resto é trabalho da IA, em segundo plano, sem me perguntar, sem me pedir para escolher.

O Traço tem dezenas de formas, métodos, domínios, filtros, seções e ajustes. **Eu não quero escolher nenhum deles.** Eles existem para a IA usar, não para eu clicar. Se eu escrevo um desejo com um obstáculo, a IA veste a forma certa, preenche o que dá para preencher, agenda o que tem hora, liga ao que já escrevi, e me devolve uma versão melhor do meu próprio pensamento. Se eu falo dez compromissos de uma vez no calendário, os dez ficam marcados. Se eu descarrego vinte minutos de pensamento por voz, a IA organiza, faz as perguntas que faltam, estrutura a minha linha de raciocínio e cria uma versão extraordinária do que eu quis dizer.

Voz é caminho principal, não extra: microfone no calendário, microfone nas notas, sempre à mão. Nunca remova, nunca esconda, nunca troque por "o princípio sem a voz".

A régua é esta: **quanto menos coisas aparecem, e quanto menos eu tenho de decidir, melhor.** Cada botão, chip, menu, seção, rótulo, configuração e frase na tela tem de justificar a própria existência contra a pergunta "a IA não podia fazer isso sozinha?". Se a resposta é sim, a coisa sai da tela e vai para dentro da IA.

E tudo o que ficar tem de ser de qualidade absurda: design ultra prêmio, componentes ultra prêmio, movimento que se sente e não se nota, texto que soa como gente. A comparação não é outro app de notas. É o iPhone original: um computador inteiro atrás de uma tela que qualquer pessoa entende no primeiro toque. E é o Grok Bot: um agente poderosíssimo que se usa escrevendo uma frase.

## O que NÃO é aceitável

- Tirar poder. Cada método, cada rota da IA, cada integração continua existindo. O que muda é quem aciona: a IA, não eu.
- Esconder falha para limpar a tela. Se algo não deu, eu vejo, com a saída ao lado.
- Trocar um clichê por outro (caixa por vidro, chip por bento). Menos é menos, não "diferente".
- Tocar no meu conteúdo. As minhas palavras nunca mudam; a IA acrescenta, veste, liga, pergunta.
- Perguntar-me o que fazer. Você decide, faz, prova e me mostra. Eu respondo em vídeo e captura, não em formulário.
- Gastar tempo com tamanho de fonte, VoiceOver, iPad, outro idioma, loja. Nada disso existe.

## Como você trabalha: o laço

Cada volta é uma causa só, do começo ao fim, e não termina até passar em todos os portões. Não há "parcialmente feito".

1. **Olhe a tela viva antes de tudo.** Build de `main`, instalado num simulador de trabalho (nunca o teste 4 nem o aparelho da conta Grok; se o simulador mudar de tela sozinho, sou eu, pare). Dados semeados de verdade. Captura por `xcrun simctl io <UDID> screenshot`, sempre em `large`, sempre com a tela inteira e o pé. Relatório antigo é hipótese, não fato.
2. **Escolha a causa que mais tira coisas da tela ou mais tira decisões de mim.** Nesta ordem: o que me engana ou me faz decidir sem precisar; o que se repete; o que grita (caixa, caixa alta, cor sem regra, três botões do mesmo peso); o que está fora da família visual (o Trabalho é a pior tela hoje); o texto que fala em jargão de spec em vez de português de uso.
3. **Faça a menor mudança que resolve a causa na raiz**, no lugar onde todas as telas passam (componente, `Tema`, motor), nunca só na tela que a auditoria citou. Reuse o que existe em `Traco/Componentes` antes de criar. Nenhum token novo sem necessidade demonstrada.
4. **Prove.** Suíte inteira verde (Swift Testing: rodar a suíte completa, `-parallel-testing-enabled NO`, `-only-testing` executa zero). Captura antes e depois do mesmo estado. Para movimento, vídeo de 15 segundos por `recordVideo` com o pé visível. Se um portão cair por causa da sua mudança, a mudança está errada, não o portão.
5. **Julgue como eu julgaria.** Abra a captura e pergunte: parece feito por IA? tem algo aqui que a IA podia ter feito sozinha? um estranho entende no primeiro toque? é tão bonito quanto o melhor app do meu iPhone? Se qualquer resposta for "não", a volta não fechou.
6. **Registre e siga.** Commit com a causa e a prova. Uma linha em `ferramentas/orca/auditoria-ux-13-09.md` §G. A memória do projeto atualizada. Depois, a próxima causa, sem me perguntar.

A cada dez voltas, refaça o placar por tela (a régua está em `ferramentas/orca/auditoria-ux-13-09.md`: seis dimensões, 0 a 10, os sete pontos do Hermes em `ferramentas/orca/REFERENCIA-HERMES.md`). O laço só para quando **todas** as telas estiverem em 9 ou mais em **todas** as dimensões, com vídeo de cada uma, e você conseguir escrever, para cada tela, a frase "aqui a pessoa faz uma coisa só, e a IA faz o resto". Até lá, continue.

## Onde a maior distância está hoje (comece por aqui)

- **Trabalho.** Formulário cru, campos em caixa cinza, três botões primários na mesma folha, cinco telas de rolagem, texto de especificação. Tem de virar o que é: eu digo o que quero realizar, a IA prepara a versão, agenda o ato, e me pergunta só o que ela não sabe.
- **Página de escrever.** Régua de doze formas, "Todas", "Trabalhar nisto", Analisar, Recordar, Anexar, Lente, mais o cartão e os campos. Eu quero escrever, e o resto acontece. Descubra o que sai da tela e o que a IA passa a fazer sozinha, prove com vídeo, e me mostre; o pé é meu desenho e muda comigo, mas quero ver a proposta.
- **Calendário.** Três andares de controle no pé, escalas, Hoje, campo, pílula. Voz e prosa marcam; o resto deveria caber em menos.
- **Notas.** Filtros por 29 chips, ordem, domínio por linha, "Como contexto". A IA classifica em silêncio; a pessoa não filtra taxonomia.
- **Perfil.** Doze seções. O que é ajuste de verdade e o que a IA devia decidir?
- **Movimento.** Nunca foi julgado em vídeo nesta fase. Cada troca de estado tem de se sentir como uma folha, não como um app.

## Fontes que mandam

`VISAO-PRODUTO.md` (o porquê), `SISTEMA-CLARO.md` e as ADRs de 10/09 em `SPEC.md` (o sistema visual), `ferramentas/orca/REFERENCIA-HERMES.md` (a régua de acabamento), `ferramentas/orca/auditoria-ux-13-09.md` (o estado e o placar), `ferramentas/orca/ESTEIRA.md` (o instrumento). Onde qualquer doc disser que voz é proibida no app, está errado: proibido é Siri e TTS nos simuladores, porque o som sai pelo meu Mac.

Comece agora pela tela viva. Não me pergunte por onde.
