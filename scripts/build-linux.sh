#!/usr/bin/env bash
# Build the Linux x86_64 player (Release). No packaging, no downloads.
#
# Usage: ./scripts/build-linux.sh [ROM_DIR]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROMS="${1:-$ROOT/roms}"
BUILD="$ROOT/build-linux"
JOBS="${JOBS:-4}"

echo "== Fatal Fury 3: Linux x86_64 build =="
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DFATFURY3_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$JOBS" --target fatfury3
echo "built $BUILD/Fatal Fury 3"
