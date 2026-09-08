#!/bin/bash
# Instala o build DESTE worktree e CONFERE que foi ele que ficou no aparelho.
#
# Lição de 08/09 (custou 25 min): outra sessão instalou o app de `main` no meu
# simulador — quase certamente por `simctl install booted` com dois aparelhos
# ligados — e a casa passou a desenhar o código velho. Parecia cache do
# `chronod`; não era. Aqui o binário é conferido por SÍMBOLO depois de instalar,
# e o script falha alto se o que ficou no aparelho não for o meu.
#
# `uninstall` antes de `install`: instalar por cima NÃO troca o `.appex` de
# forma confiável (o dylib do widget ficou com data de 40 min antes).
set -e
U="$1"; APP="${2:-/tmp/dd-f5/Build/Products/Debug-iphonesimulator/Traco.app}"
xcrun simctl uninstall "$U" app.traco 2>/dev/null || true
xcrun simctl install "$U" "$APP"
D=$(xcrun simctl get_app_container "$U" app.traco app)/PlugIns/TracoWidget.appex/TracoWidget.debug.dylib
for s in FraseDoAutor LinhasDoDestaque; do
  n=$(nm -a "$D" 2>/dev/null | grep -c "$s" || true)
  [ "$n" -gt 0 ] || { echo "f5-instalar: o aparelho NÃO ficou com o meu build (falta $s)" >&2; exit 1; }
done
echo "instalado e conferido"
