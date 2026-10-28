# Building Fatal Fury 3

The project is a normal CMake 3.21+ project. The public source repository
intentionally omits CMake files at the owner's request; this page documents
the local build that produced the release binaries.

## Dependencies

* CMake 3.21–4.x
* A C11 and C++14 compiler: MSVC 2022/2026 x64, or GCC 11+/Clang 14+
* SDL2 development package (optional; without it the player is headless)
* Python 3 only for the optional `audio-check` target
* On Linux, `libm` (linked automatically by the toolkit for Musashi)

## Windows

```powershell
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 `
      -DFATFURY3_ROM_DIR=C:/path/to/roms `
      -DSDL2_DIR=C:/path/to/SDL2/cmake
cmake --build build-windows --config Release --target fatfury3 --parallel
```

Output: `build-windows/Release/Fatal Fury 3.exe` plus `SDL2.dll`.

`FATFURY3_ROM_DIR` must contain the 13 `069-*` game files and the four
`neogeo` BIOS files, unzipped flat. The generator runs during the build and
writes `generated/recomp_*.c` into the build tree. The generated C is large
(about 76 MB); MSVC needs `/bigobj` and the project builds it at `/O1`.

## Linux

```bash
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
      -DFATFURY3_ROM_DIR="$PWD/roms"
cmake --build build-linux --parallel "$(nproc)" --target fatfury3
```

Output: `build-linux/Fatal Fury 3`.

## AppImage

```bash
JOBS=4 ./packaging/appimage/build-appimage.sh "$PWD/roms"
```

This builds the Linux player, assembles `build-linux/AppDir`, bundles the
SDL2 the binary linked against, and runs `appimagetool`. It downloads
`appimagetool` only if it is not already present. Output:
`dist/steamdeck/Fatal Fury 3-SteamDeck-x86_64.AppImage`.

## Windows package

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\package-windows.ps1
```

It copies the executable, SDL2, the VC++ runtime DLLs, the ROM helper and the
license set into `dist/windows/Fatal Fury 3-Windows-x64` and creates the zip.

## Tests

```bash
# interpreted board-model check
./Fatal\ Fury\ 3 --headless --interp --rom-path roms --frames 3000

# native correctness
./Fatal\ Fury\ 3 --headless --verify --rom-path roms --frames 6000 \
  --input tests/coin_start.txt

# audio continuity
./Fatal\ Fury\ 3 --headless --rom-path roms --frames 12000 \
  --input tests/play.txt --wav /tmp/ff3.wav
python3 tests/check_audio.py /tmp/ff3.wav
```

The CMake `profile` target runs a 6,000-frame attract session and a
20,000-frame scripted match, dumps runtime-only entry points, and the next
build regenerates with them:

```bash
cmake --build build-windows --config Release --target profile
```
