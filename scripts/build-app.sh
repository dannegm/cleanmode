#!/bin/bash
# Compila el paquete y genera build/CleanMode.app listo para abrir.
# Por defecto genera un binario universal (arm64 + x86_64); NATIVE_ONLY=1 compila solo la arquitectura de este Mac.
# CODESIGN_IDENTITY="Nombre del certificado" para firmar con un certificado propio
# (así el permiso de Accesibilidad sobrevive entre recompilaciones). Por defecto: firma ad hoc.
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/CleanMode.app"
BINARY="$(mktemp)"

# Primero se compila y solo si sale bien se arma el .app (así un fallo no deja un .app vacío).
if [ "${NATIVE_ONLY:-0}" = "1" ]; then
    # Build rápido solo para la arquitectura de este Mac (desarrollo).
    swift build -c release
    cp "$(swift build -c release --show-bin-path)/CleanMode" "$BINARY"
else
    # Binario universal: Apple Silicon (arm64) + Intel (x86_64). Cada arquitectura usa su propia
    # carpeta de compilación: SwiftPM comparte una base de datos por carpeta y alternar
    # arquitecturas en la misma la corrompe ("command ... not registered").
    for arch in arm64 x86_64; do
        swift build -c release --arch "$arch" --scratch-path ".build-universal/$arch"
    done
    lipo -create \
        "$(swift build -c release --arch arm64 --scratch-path .build-universal/arm64 --show-bin-path)/CleanMode" \
        "$(swift build -c release --arch x86_64 --scratch-path .build-universal/x86_64 --show-bin-path)/CleanMode" \
        -output "$BINARY"
fi
echo "Arquitecturas: $(lipo -archs "$BINARY")"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BINARY" "$APP/Contents/MacOS/CleanMode"
chmod +x "$APP/Contents/MacOS/CleanMode"
rm -f "$BINARY"
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
