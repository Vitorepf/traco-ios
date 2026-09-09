# Outra — o segundo app que faz a Ilha do Traço encolher para a MÍNIMA

A Ilha só mostra a apresentação mínima quando **duas atividades de apps
diferentes** disputam o espaço; duas do mesmo app não bastam (o iOS mostra uma
e empilha a outra na tela bloqueada — F1 D9, provado de novo na F5b). O
simulador não tem Relógio nem Mapas com navegação, então este app descartável
sobe uma Live Activity vazia ao abrir. Não é produto: é instrumento.

    cd ferramentas/orca/f5b-outra && xcodegen generate
    ferramentas/orca/com-trava.sh xcodebuild build -project Outra.xcodeproj -scheme Outra \
      -destination id=<UDID> -derivedDataPath /tmp/outra-dd CODE_SIGNING_ALLOWED=NO
    xcrun simctl install <UDID> /tmp/outra-dd/Build/Products/Debug-iphonesimulator/Outra.app
    xcrun simctl launch <UDID> app.traco.f5b.outra   # a mínima aparece ao voltar à casa
    xcrun simctl uninstall <UDID> app.traco.f5b.outra   # encerra a atividade dela

O `appex` precisa de `CFBundleShortVersionString`/`CFBundleVersion` no Info —
sem eles o `simctl install` recusa com "Invalid placeholder attributes".
