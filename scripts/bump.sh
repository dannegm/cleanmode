#!/bin/bash
# Sube la versión, hace commit, crea el tag anotado y lo publica (push).
#
#   scripts/bump.sh -M | --major     X.Y.Z → (X+1).0.0
#   scripts/bump.sh -m | --minor     X.Y.Z → X.(Y+1).0
#   scripts/bump.sh -p | --patch     X.Y.Z → X.Y.(Z+1)
#
# Opciones:
#   -n | --dry-run   solo muestra qué haría, sin tocar nada
#   --no-push        hace el commit y el tag, pero no los sube
#   -h | --help      esta ayuda
#
# Qué hace, en orden:
#   1. Actualiza CFBundleShortVersionString en Resources/Info.plist y suma 1 a CFBundleVersion.
#   2. Hace commit "chore: bump version to X.Y.Z" (el tag debe apuntar a un commit que YA lleve la versión).
#   3. Crea el tag anotado vX.Y.Z.
#   4. Hace push de la rama y del tag (atómico). El push del tag dispara el workflow de release.
#
# Requisitos: árbol de trabajo limpio (commitea antes tus cambios, incluido el CHANGELOG) y estar al día con origin.
set -euo pipefail
cd "$(dirname "$0")/.."

PLIST="Resources/Info.plist"
KIND=""
DRY=0
PUSH=1

die() { echo "Error: $*" >&2; exit 1; }

usage() {
    cat <<'USAGE'
Uso: scripts/bump.sh (-M|--major | -m|--minor | -p|--patch) [-n|--dry-run] [--no-push]

  -M, --major     X.Y.Z → (X+1).0.0
  -m, --minor     X.Y.Z → X.(Y+1).0
  -p, --patch     X.Y.Z → X.Y.(Z+1)
  -n, --dry-run   solo muestra qué haría
      --no-push   commit y tag locales, sin subirlos
  -h, --help      esta ayuda
USAGE
}

set_kind() {
    [ -z "$KIND" ] || die "elige solo uno: --major, --minor o --patch."
    KIND="$1"
}

while [ $# -gt 0 ]; do
    case "$1" in
        -M|--major) set_kind major ;;
        -m|--minor) set_kind minor ;;
        -p|--patch) set_kind patch ;;
        -n|--dry-run) DRY=1 ;;
        --no-push) PUSH=0 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; die "opción desconocida: $1" ;;
    esac
    shift
done
[ -n "$KIND" ] || { usage >&2; die "indica el tipo de bump: -M, -m o -p."; }

# ---------- comprobaciones ----------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "esto no es un repositorio git."
BRANCH="$(git branch --show-current)"
[ -n "$BRANCH" ] || die "no estás en una rama (HEAD suelto)."

DIRTY=0
[ -z "$(git status --porcelain)" ] || DIRTY=1
if [ "$DIRTY" -eq 1 ] && [ "$DRY" -eq 0 ]; then
    die "hay cambios sin commitear. Haz commit primero: el commit del bump solo debe llevar el cambio de versión."
fi

# ---------- versión nueva ----------
CURRENT="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST")"

VERSION_RE='^([0-9]+)\.([0-9]+)\.([0-9]+)$'
[[ "$CURRENT" =~ $VERSION_RE ]] || die "la versión actual '$CURRENT' no tiene el formato X.Y.Z."
MAJOR=$((10#${BASH_REMATCH[1]}))
MINOR=$((10#${BASH_REMATCH[2]}))
PATCH=$((10#${BASH_REMATCH[3]}))
[[ "$BUILD" =~ ^[0-9]+$ ]] || die "CFBundleVersion '$BUILD' no es un número."

case "$KIND" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac
NEW="$MAJOR.$MINOR.$PATCH"
NEW_BUILD=$((10#$BUILD + 1))
TAG="v$NEW"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    die "el tag $TAG ya existe."
fi

# La versión nueva debe ser mayor que la del último tag (si el plist se quedó atrás, el bump saldría mal).
sort_versions() { sort -t. -k1,1n -k2,2n -k3,3n; }
LATEST="$(git tag -l 'v[0-9]*' | sed 's/^v//' | sort_versions | tail -1 || true)"
if [ -n "$LATEST" ] && [ "$LATEST" != "$NEW" ]; then
    GREATEST="$(printf '%s\n%s\n' "$LATEST" "$NEW" | sort_versions | tail -1)"
    if [ "$GREATEST" = "$LATEST" ]; then
        die "el último tag (v$LATEST) es mayor que la versión nueva ($NEW). El plist está en $CURRENT: corrígelo a la versión del último tag y vuelve a intentar."
    fi
fi

# ---------- remoto (solo si se va a subir) ----------
if [ "$PUSH" -eq 1 ]; then
    git remote get-url origin >/dev/null 2>&1 || die "no hay un remoto 'origin'. Usa --no-push para trabajar solo en local."
    if [ "$DRY" -eq 0 ]; then
        git fetch --quiet origin "$BRANCH" 2>/dev/null \
            || die "no pude consultar origin/$BRANCH (¿sin conexión o rama nueva?). Usa --no-push para trabajar sin red."
        BEHIND="$(git rev-list --count "HEAD..origin/$BRANCH")"
        [ "$BEHIND" -eq 0 ] || die "tu rama está $BEHIND commit(s) detrás de origin/$BRANCH. Haz pull primero."
    fi
fi

# ---------- resumen / dry-run ----------
echo "Rama:           $BRANCH"
echo "Versión actual: $CURRENT (build $BUILD)"
echo "Versión nueva:  $NEW (build $NEW_BUILD)  [$KIND]"
echo "Tag:            $TAG"

if [ "$DRY" -eq 1 ]; then
    echo
    echo "Dry-run: no se cambia nada. Se haría:"
    echo "  1. editar $PLIST"
    echo "  2. git commit -m \"chore: bump version to $NEW\""
    echo "  3. git tag -a $TAG"
    if [ "$PUSH" -eq 1 ]; then echo "  4. git push --atomic origin $BRANCH $TAG"; else echo "  4. (sin push: --no-push)"; fi
    [ "$DIRTY" -eq 0 ] || echo "  Aviso: hay cambios sin commitear; para el bump real tendrás que commitearlos antes."
    exit 0
fi

# ---------- 1. plist ----------
# Se edita solo el texto de los dos valores (PlistBuddy reescribiría todo el archivo y ensuciaría el diff).
perl -0pi -e "s|(<key>CFBundleShortVersionString</key>\\s*<string>)[^<]*(</string>)|\${1}${NEW}\${2}|; s|(<key>CFBundleVersion</key>\\s*<string>)[^<]*(</string>)|\${1}${NEW_BUILD}\${2}|" "$PLIST"

plutil -lint "$PLIST" >/dev/null || die "el Info.plist quedó inválido tras editarlo (revísalo con git diff)."
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$PLIST")" = "$NEW" ] || die "no se pudo actualizar CFBundleShortVersionString."
[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$PLIST")" = "$NEW_BUILD" ] || die "no se pudo actualizar CFBundleVersion."

# ---------- 2 y 3. commit y tag ----------
git add "$PLIST"
git commit --quiet -m "chore: bump version to $NEW"
git tag -a "$TAG" -m "Clean Mode $NEW"
echo
echo "Commit y tag $TAG creados."

# ---------- 4. push ----------
if [ "$PUSH" -eq 1 ]; then
    if git push --atomic origin "$BRANCH" "refs/tags/$TAG"; then
        echo
        echo "Publicado: $BRANCH y $TAG en origin. El workflow de release ya debería estar corriendo."
    else
        echo >&2
        echo "El push falló. El commit y el tag siguen en local. Reintenta con:" >&2
        echo "  git push --atomic origin $BRANCH $TAG" >&2
        echo "o deshaz el bump con:" >&2
        echo "  git tag -d $TAG && git reset --hard HEAD~1" >&2
        exit 1
    fi
else
    echo
    echo "Sin push (--no-push). Para publicar:"
    echo "  git push --atomic origin $BRANCH $TAG"
fi
