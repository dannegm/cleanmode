#!/bin/bash
# Compila, firma y empaqueta build/CleanMode-<versión>.zip (+ .sha256) listo para publicar.
# Usa CODESIGN_IDENTITY igual que build-app.sh (por defecto firma ad hoc).
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/build-app.sh

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)"
ZIP="build/CleanMode-$VERSION.zip"

rm -f "$ZIP" "$ZIP.sha256"
ditto -c -k --keepParent --norsrc --noextattr --noqtn build/CleanMode.app "$ZIP"
(cd build && shasum -a 256 "CleanMode-$VERSION.zip" > "CleanMode-$VERSION.zip.sha256")

echo "Listo: $PWD/$ZIP"
cat "$ZIP.sha256"
