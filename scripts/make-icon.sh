#!/bin/bash
# Regenera Resources/AppIcon.icns a partir de scripts/make-icon.swift.
set -euo pipefail
cd "$(dirname "$0")/.."

TMP="$(mktemp -d)"
ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"

swift scripts/make-icon.swift "$TMP/icon-1024.png"

for size in 16 32 128 256 512; do
    sips -z $size $size "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    sips -z $((size * 2)) $((size * 2)) "$TMP/icon-1024.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns

# Catálogo de iconos (lo compila actool en build-app.sh para generar Assets.car).
SET="Resources/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$SET"
rm -f "$SET"/*.png
cp "$ICONSET"/*.png "$SET"/
cat > Resources/Assets.xcassets/Contents.json <<'JSON'
{ "info" : { "version" : 1, "author" : "xcode" } }
JSON
python3 - "$SET" <<'PY'
import json, sys
images = []
for size in (16, 32, 128, 256, 512):
    for scale in (1, 2):
        name = f"icon_{size}x{size}" + ("@2x" if scale == 2 else "") + ".png"
        images.append({"size": f"{size}x{size}", "idiom": "mac", "filename": name, "scale": f"{scale}x"})
json.dump({"images": images, "info": {"version": 1, "author": "xcode"}}, open(sys.argv[1] + "/Contents.json", "w"), indent=2)
PY
cp "$TMP/icon-1024.png" Resources/AppIcon-1024.png
rm -rf "$TMP"
echo "Listo: Resources/AppIcon.icns"
