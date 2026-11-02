#!/bin/bash
# Compila el paquete y genera build/CleanMode.app listo para abrir.
# CODESIGN_IDENTITY="Nombre del certificado" para firmar con un certificado propio
# (así el permiso de Accesibilidad sobrevive entre recompilaciones). Por defecto: firma ad hoc.
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release
BIN="$(swift build -c release --show-bin-path)/CleanMode"

APP="build/CleanMode.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/CleanMode"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# Compila el catálogo de iconos con actool (Xcode) para generar Assets.car y declara
# CFBundleIconName solo si se generó. Sin Xcode se queda con AppIcon.icns.
XCODE_DEV="/Applications/Xcode.app/Contents/Developer"
if [ -d "$XCODE_DEV" ] && [ -d Resources/Assets.xcassets ]; then
    ACT="$(mktemp -d)"
    if DEVELOPER_DIR="$XCODE_DEV" xcrun actool Resources/Assets.xcassets --compile "$ACT" \
        --platform macosx --minimum-deployment-target 13.0 --app-icon AppIcon \
        --output-partial-info-plist "$ACT/partial.plist" >/dev/null 2>&1 && [ -f "$ACT/Assets.car" ]; then
        cp "$ACT/Assets.car" "$APP/Contents/Resources/Assets.car"
        [ -f "$ACT/AppIcon.icns" ] && cp "$ACT/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
        /usr/libexec/PlistBuddy -c "Add :CFBundleIconName string AppIcon" "$APP/Contents/Info.plist" 2>/dev/null \
            || /usr/libexec/PlistBuddy -c "Set :CFBundleIconName AppIcon" "$APP/Contents/Info.plist"
        echo "Icono: Assets.car generado con actool"
    else
        echo "Aviso: actool falló; se usa AppIcon.icns" >&2
    fi
    rm -rf "$ACT"
fi

SIGN_ID="${CODESIGN_IDENTITY:--}"
SIGN_ARGS=(--force --sign "$SIGN_ID")
# Notarizar exige hardened runtime y sello de tiempo (solo con certificados Developer ID).
case "$SIGN_ID" in "Developer ID"*) SIGN_ARGS+=(--options runtime --timestamp) ;; esac
codesign "${SIGN_ARGS[@]}" "$APP"

# Refresca el icono en LaunchServices (lista de Accesibilidad, Finder, Dock).
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" >/dev/null 2>&1 || true
touch "$APP"

echo "Listo: $PWD/$APP"
