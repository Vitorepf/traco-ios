#!/bin/bash
# Varredura E2E com o aparelho GARANTIDO.
#
# Em 01/set uma noite inteira de vereditos saiu errada porque havia DOIS
# simuladores booted: o maestro escolheu um por conta própria (iPhone 17 Pro) e
# os `simctl install` iam para o outro (iPhone 17). O maestro rodava contra uma
# cópia velha do app — telas antigas nas capturas, falhas que não existiam,
# correções que "não pegavam". Este roteiro recusa rodar nessa condição.
#
#   ./maestro/varrer.sh              # tudo
#   ./maestro/varrer.sh maestro/x.yaml ...
set -u
cd "$(dirname "$0")/.."

# O aparelho pode ser DITO, e a lei de 01/set deixa de exigir exclusividade:
# `maestro --udid` e `simctl spawn <udid>` endereçam o simulador certo, e a
# varredura corre com o Air da conta e o simulador da suíte ligados ao lado
# (17/09 — sem isto a varredura era impossível nesta máquina compartilhada).
SIM=${TRACO_SIM:-}
if [ -n "$SIM" ]; then
    xcrun simctl list devices | grep -q "$SIM.*Booted" || { echo "PARADO: $SIM não está booted"; exit 2; }
    ALVO="$SIM"
    MAESTRO_ALVO="--udid $SIM"
else
    BOOTED=$(xcrun simctl list devices booted | grep -c "(Booted)")
    if [ "$BOOTED" -ne 1 ]; then
        echo "PARADO: $BOOTED simuladores booted — o maestro escolhe um e o install vai para outro."
        echo "Diga qual: TRACO_SIM=<UDID> ./maestro/varrer.sh"
        xcrun simctl list devices booted
        exit 2
    fi
    ALVO=booted
    MAESTRO_ALVO=""
fi

APP=${TRACO_APP:-build/Build/Products/Debug-iphonesimulator/Traco.app}
if [ ! -d "$APP" ]; then
    echo "PARADO: não há build em $APP"
    exit 2
fi
xcrun simctl install "$ALVO" "$APP" || exit 2

# ADR 2026-09-03p: a varredura roda com os MODELOS DESLIGADOS. Sem isto ela é
# não-determinística (o modelo responde diferente do motor local que os fluxos
# descrevem) e ainda gasta a assinatura do autor a cada pausa de análise.
#
# O canal é o AMBIENTE do simulador: `launchApp: arguments:` do maestro NÃO
# chega ao app no iOS (provado em 03/set — o fluxo com e sem a bandeira falhou
# idêntico), e UserDefaults morre no `clearState`. O ambiente não vive no
# contêiner do app, então sobrevive.
VIVOS="maestro/pergunta-sabia.yaml maestro/lente-instigar.yaml"
FLUXOS=${@:-$(ls maestro/*.yaml maestro/cenarios/*.yaml 2>/dev/null)}
FALHAS=""

xcrun simctl spawn "$ALVO" launchctl setenv TRACO_SEM_MODELO 1
for f in $FLUXOS; do
    case " $VIVOS " in *" $f "*) continue ;; esac
    # fluxo com .sh irmão precisa do que o .sh planta antes do arranque
    # (entrada-do-mac, a-volta): corre pelo .sh, que devolve o código do maestro
    sh="${f%.yaml}.sh"
    if [ -x "$sh" ]; then
        "$sh" >/dev/null 2>&1 || FALHAS="$FALHAS $(basename $f .yaml)"
    else
        ~/bin/maestro $MAESTRO_ALVO test "$f" >/dev/null 2>&1 || FALHAS="$FALHAS $(basename $f .yaml)"
    fi
done

# e os dois testes de INTEGRAÇÃO VIVA, com o modelo ligado: são o único lugar
# que prova a ADR o ponta a ponta contra um modelo de verdade
xcrun simctl spawn "$ALVO" launchctl unsetenv TRACO_SEM_MODELO
for f in $VIVOS; do
    case " $FLUXOS " in *" $f "*) ;; *) continue ;; esac
    ~/bin/maestro $MAESTRO_ALVO test "$f" >/dev/null 2>&1 || FALHAS="$FALHAS $(basename $f .yaml)"
done

echo "--- varredura ---"
echo "FALHAS:${FALHAS:- nenhuma}"
