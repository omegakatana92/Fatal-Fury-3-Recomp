#!/usr/bin/env bash
# Build the Linux x86_64 player and package it as a Steam Deck AppImage.
#
# Prerequisites: gcc, g++, cmake 3.21+, make, libsdl2-dev, wget, strip.
# The user's ROMs are never bundled. The AppImage contains the recompiled
# player and its licenses only.
#
# Usage: ./packaging/appimage/build-appimage.sh [ROM_DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms}"
BUILD="${FATFURY3_BUILD_DIR:-$ROOT/build-linux}"
JOBS="${JOBS:-4}"
APPDIR="$BUILD/AppDir"
OUT="$ROOT/dist/steamdeck/Fatal Fury 3-SteamDeck-x86_64.AppImage"

echo "== Fatal Fury 3: Steam Deck AppImage =="
echo "repo: $ROOT"
echo "roms: $ROMS"

cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DFATFURY3_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$JOBS" --target fatfury3

echo "== assemble AppDir =="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$APPDIR/usr/share/doc/fatfury3/LICENSES"
cp "$BUILD/Fatal Fury 3" "$APPDIR/usr/bin/fatfury3"
strip --strip-unneeded "$APPDIR/usr/bin/fatfury3" 2>/dev/null || true

SDL=$(ldd "$BUILD/Fatal Fury 3" | awk '/libSDL2-2\.0\.so\.0/{print $3; exit}')
if [ -n "${SDL:-}" ]; then cp "$SDL" "$APPDIR/usr/lib/"; fi

if [ ! -f "$ROOT/packaging/appimage/fatfury3.png" ]; then
    python3 "$ROOT/packaging/appimage/make_icon.py"
fi
cp "$ROOT/packaging/appimage/fatfury3.png" "$APPDIR/fatfury3.png"
cp "$ROOT/packaging/appimage/fatfury3.png" \
   "$APPDIR/usr/share/icons/hicolor/256x256/apps/fatfury3.png"
cp "$ROOT/packaging/appimage/fatfury3.desktop" "$APPDIR/fatfury3.desktop"
cp "$ROOT/packaging/appimage/fatfury3.desktop" \
   "$APPDIR/usr/share/applications/fatfury3.desktop"
cp "$ROOT/packaging/appimage/README.txt" "$APPDIR/usr/share/doc/fatfury3/README.txt"
cp "$ROOT/LICENSE" "$APPDIR/usr/share/doc/fatfury3/LICENSE.txt"
cp "$ROOT/LICENSE-STATUS.md" "$APPDIR/usr/share/doc/fatfury3/LICENSE-STATUS.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$APPDIR/usr/share/doc/fatfury3/THIRD_PARTY_NOTICES.txt"
cp "$ROOT/neogeorecomp/LICENSE" "$APPDIR/usr/share/doc/fatfury3/LICENSES/neogeorecomp.txt"
cp "$ROOT/neogeorecomp/NOTICE" "$APPDIR/usr/share/doc/fatfury3/LICENSES/neogeorecomp-NOTICE.txt"
cp "$ROOT/neogeorecomp/LICENSES/"*.txt "$APPDIR/usr/share/doc/fatfury3/LICENSES/"
cp "$ROOT/packaging/windows/SDL2.txt" "$APPDIR/usr/share/doc/fatfury3/LICENSES/SDL2.txt"
cp "$ROOT/packaging/appimage/AppRun" "$APPDIR/AppRun"
chmod +x "$APPDIR/AppRun"

echo "== appimagetool =="
mkdir -p "$ROOT/dist/steamdeck"
TOOL="${APPIMAGETOOL:-$BUILD/appimagetool.AppImage}"
if [ ! -x "$TOOL" ]; then
    wget -q -O "$TOOL" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$TOOL"
fi
ARCH=x86_64 "$TOOL" --appimage-extract-and-run --no-appstream "$APPDIR" "$OUT"
chmod +x "$OUT"
echo "wrote $OUT"
