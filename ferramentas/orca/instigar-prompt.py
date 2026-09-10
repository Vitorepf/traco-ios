#!/usr/bin/env python3
"""Extrai do BINÁRIO o texto do prompt que a corrida mediu, e o SHA-256 dele,
para o conferidor de amanhã não depender de um `.dylib` que um build posterior
já apagou (dívida nomeada no RUMO em 10/09: a janela carimbava o HASH do binário
e não guardava o CONTEÚDO do pedido).

Por BYTES, e não por `strings`: o literal Swift traz acento em UTF-8 e `strings`
corta na primeira sequência que não é ASCII, entregando meio prompt.

Acha a âncora FINAL primeiro e a inicial mais próxima ANTES dela: desde a ADR
10c o mesmo binário carrega os DOIS pedidos, base e candidato, e os dois começam
pela mesma frase — procurar do começo entregaria um Frankenstein dos dois.

O SHA-256 que ele imprime é o que o app grava em `pedidoInstigarSHA256`: quem
conferir amanhã liga o texto ao JSONL sem acreditar em ninguém.

Uso: instigar-prompt.py <binario> <âncora-inicial> <âncora-final> [saida]"""
import hashlib, sys

binario, inicio, fim = sys.argv[1], sys.argv[2].encode(), sys.argv[3].encode()
dados = open(binario, 'rb').read()
b = dados.find(fim)
if b < 0:
    sys.exit('⛔ âncora final %r ausente de %s' % (sys.argv[3], binario))
a = dados.rfind(inicio, 0, b)
if a < 0:
    sys.exit('⛔ âncora inicial %r ausente antes da final' % sys.argv[2])
cru = dados[a:b + len(fim)]
texto = cru.decode('utf-8', 'replace')
sha = hashlib.sha256(texto.encode()).hexdigest()
print('%d bytes  sha256=%s' % (len(cru), sha))
if len(sys.argv) > 4:
    open(sys.argv[4], 'w').write(texto + '\n')
    print('  -> %s' % sys.argv[4])
else:
    print(texto)
