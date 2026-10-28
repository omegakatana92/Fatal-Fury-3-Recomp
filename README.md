# Fatal Fury 3: Road to the Final Victory — native static recompilation

A native Windows x64 and Linux x86_64 recompilation of **Fatal Fury 3: Road to
the Final Victory** (Neo Geo MVS, 1995, NGH-069), built on
[sp00nznet/neogeorecomp](https://github.com/sp00nznet/neogeorecomp) v0.2.0.

The game's Motorola 68000 program is translated ahead of time into C. The
generated routines run against a model of the MVS board with the real
`sp-s2.sp1` system ROM; addresses without a recompiled entry run in Musashi.
It is not an emulator wrapper and it does not patch or replace the original
program.

**Status (2026-10-27):** boots through the real BIOS, runs attract mode,
accepts coin/start, shows HOW TO PLAY and ENEMY SELECT, and reaches a
playable match. Windows and Linux Release builds are produced. Native
coverage and `--verify` results for the tested sessions are recorded below.
Physical Steam Deck and physical gamepads were not available here.

## Deliverables

```
dist/
├── windows/
│   └── Fatal Fury 3-Windows-x64/
│       ├── Fatal Fury 3.exe
│       ├── README.txt
│       ├── Prepare-ROMs.ps1
│       ├── Play Fatal Fury 3.cmd
│       ├── SDL2.dll
│       ├── vcruntime140*.dll
│       └── LICENSES/
└── steamdeck/
    ├── Fatal Fury 3-SteamDeck-x86_64.AppImage
    └── README.txt
```

No ROMs or BIOS files are included in either package. The AppImage is a
native Linux x86_64 build, not a renamed Windows executable.

Published release:
<https://github.com/omegakatana92/Fatal-Fury-3-Recomp/releases/tag/v0.1.0>
(GitHub changes spaces in asset filenames to dots; the local files keep the
spaced names.)

## Verified ROM set

The supplied archive is the plain MAME `fatfury3` set. Every file's SHA-1 was
checked against MAME's `ROM_START( fatfury3 )`; all match.

| File | Size | SHA-1 | Role |
|---|---:|---|---|
| `069-p1.p1` | 1,048,576 | `519c4861151797e5f4d4f33432b83dfabed8e7c4` | fixed program bank |
| `069-sp2.sp2` | 2,097,152 | `8ece7f663cfe8e563576a397e41161d392cee67e` | banked program |
| `069-s1.s1` | 131,072 | `b7d2cc97da4f30ddebc7b801f5e1d17d2306b2db` | fixed layer |
| `069-m1.m1` | 131,072 | `a40c74f793900b8542f0b8383ce4bf46fca112d4` | Z80 sound driver |
| `069-c1.c1` | 4,194,304 | `d8610b14900b2b8fe691b67ca9b1abb335dbff74` | sprite plane 0/1 |
| `069-c2.c2` | 4,194,304 | `69501bfac68739e63d798045b812badd251d57b8` | sprite plane 2/3 |
| `069-c3.c3` | 4,194,304 | `cf6c2ef56c03a861de3b0b6dc0d7c9204d947f9d` | sprite plane 0/1 |
| `069-c4.c4` | 4,194,304 | `83cb349e2f1032652060b233e741fb893be5af16` | sprite plane 2/3 |
| `069-c5.c5` | 2,097,152 | `7e4c8ee9dd8d9a25ff183d9d8b05f38769348bc7` | sprite plane 0/1 |
| `069-c6.c6` | 2,097,152 | `6d496c549dba65caabeaffe5b762e86f9d648a26` | sprite plane 2/3 |
| `069-v1.v1` | 4,194,304 | `5f4fecf69c2329d699cbd45829c19303b1e2a80e` | ADPCM |
| `069-v2.v2` | 4,194,304 | `11b8bc53bc26a51f4a408e900e3769958625c4ed` | ADPCM |
| `069-v3.v3` | 2,097,152 | `e9550ec547b4f605afed996b22d711f49b48fa92` | ADPCM |

BIOS files: `sp-s2.sp1` (MVS Asia/Europe v2, the default), `sfix.sfix`,
`sm1.sm1` and `000-lo.lo` from the `neogeo` set.

This cart uses the standard PROGBK1 selector at `$2FFFF0` (`prom_size =
0x300000`, a 1 MB fixed bank plus a 2 MB banked image). There is no
encryption, no NEO-SMA protection and no S-ROM extraction step.

## How it works

```
069-p1.p1 + 069-sp2.sp2 ──► fatfury3_recomp (m68krecomp) ──► generated/*.c
        + M1/V ROMs                                                  │
                                                                     ▼
                     neogeorecomp runtime ◄──── Fatal Fury 3 executable
   dispatcher · Musashi fallback · LSPC video · palette · I/O · Z80/YM2610 · SDL2
```

* 469,428 instructions were emitted across 13,958 routines and 27,924
  dispatch entries by static discovery (vectors, header entries, call
  targets, jump tables, code pointers).
* Control flow is flat: return addresses live on the emulated stack and
  interrupts are real 68000 exceptions.
* `--verify` replays every native block in Musashi against the same memory
  and I/O values and compares registers, flags and writes.
* Addresses with no native entry run in Musashi. `--dump-misses` records
  them and the `profile` target feeds them back to the recompiler.

### Measured coverage

| Session | Native instructions | Interpreted | Native share | Uncovered entries |
|---|---:|---:|---:|---:|
| 3,000-frame boot/attract, no input | 56,098,553 | 189,189 | **99.66%** | 242 |
| 12,000-frame coin/start + match (`tests/play.txt`) | 218,232,083 | 948,283 | **99.57%** | 415 |
| 6,000-frame verified session (`tests/coin_start.txt`) | 109,981,868 | 473,238 | **99.57%** | 380 |

`--verify` on that 6,000-frame session checked **4,349,426 native blocks with
0 register/flag/write mismatches**. These are measurements for those scripted
sessions, not a claim about every code path.

## Requirements

* Windows 10/11 x64 with the Microsoft Visual C++ 2015-2022 runtime, or
  SteamOS/Linux x86_64 with glibc 2.35 or newer.
* Your own legally obtained `fatfury3.zip` and `neogeo.zip`.
* A gamepad is optional; SDL2 GameController mapping is used.

## Build

The local project uses CMake 3.21+ and either MSVC 2022/2026 or GCC 11+.
SDL2 is optional (without it the player is headless-only).

```powershell
cmake -S . -B build-windows -G "Visual Studio 18 2026" -A x64 `
      -DFATFURY3_ROM_DIR=C:/path/to/roms `
      -DSDL2_DIR=C:/path/to/SDL2/cmake
cmake --build build-windows --config Release --target fatfury3
```

```bash
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release \
      -DFATFURY3_ROM_DIR="$PWD/roms"
cmake --build build-linux --parallel "$(nproc)" --target fatfury3
```

The generator reads the user's ROMs and writes the recompiled C into the
build directory; none of it is committed. **The public source repository
intentionally omits CMake files at the owner's request.** The local project
directory keeps them so the binaries can be reproduced by the owner.

## Running

Unzip `fatfury3.zip` and `neogeo.zip` flat into `roms/`, then:

```
"Fatal Fury 3.exe" --rom-path roms
"Fatal Fury 3.exe" --rom-path roms --fullscreen
```

Linux:

```
./Fatal\ Fury\ 3 --rom-path roms
./Fatal\ Fury\ 3-SteamDeck-x86_64.AppImage --rom-path roms
```

Useful options: `--headless`, `--frames N`, `--interp`, `--verify`,
`--input FILE`, `--wav FILE`, `--screenshot N:FILE`, `--scale N`,
`--fullscreen`, `--mute`.

### Controls

| Keyboard | Gamepad | Neo Geo |
|---|---|---|
| Arrows | D-pad / left stick | move |
| Z X C V | A B X Y | A B C D |
| 5 | Back | coin |
| 1 | Start | player 1 start |
| 2 | — | player 2 start |
| 3 | left shoulder | select |
| 9 | — | service |
| F2 | — | test switch |
| F11 | — | fullscreen |
| Esc | — | quit |

Insert a coin before Start (MVS behaviour). Steam Input works through SDL2's
GameController mapping; a standard Xbox-layout pad needs no configuration.

## Display and audio

* 320×224 rendered image, presented at 4:3 and pillarboxed in fullscreen
  (1280×800 → 1066×800), never stretched to 16:10.
* Internal refresh 59.1856 Hz, paced to the MVS.
* YM2610 FM, SSG and ADPCM-A/B from the real Z80 driver; SDL2 output converts
  the 55,555 Hz stream to the device rate, starts with a 60 ms cushion,
  recovers from a dry queue without dropping real samples, and trims only the
  oldest excess after a >250 ms stall.

Measured 12,000-frame audio capture: 202.74 s, peak 28,075, RMS 3668/3600,
no clipped samples. The quiet windows are boot (0–7 s), a HOW TO PLAY/scene
transition (56–57 s, 61 s) and the continue/game-over screen (180 s), not a
stalled sound driver; there is no silent run of 3 s or more after boot.

### Audio pass for sibling ports

The same generic sound fixes were applied to the existing **Garou**, **KOF
'96**, **KOF '97**, **KOF 2000** and **Metal Slug 3** ports and their
runtimes were rebuilt:

* YM2610 timer status now latches on overflow even when that timer's IRQ is
  masked; the IRQ line itself is gated by the enable bits (`$27` bits 2/3).
* The SDL output path moves converted audio in whole device frames (no
  half-sample stereo slip), applies the queue trim after queueing rather than
  one frame late, and re-cushions a dry queue once instead of leaving SDL to
  underrun on every following frame.

Regression checks for those ports are in each project's `audio-check` target
and in `docs/AUDIO-V4-2026-10-27.md`.

## Testing

See `docs/TESTING.md` for exact commands and logs. Tested here:

* ROM layout, sizes and SHA-1 against MAME.
* Interpreted boot and native boot through the real BIOS.
* Title, attract, coin/start, HOW TO PLAY, ENEMY SELECT and a match.
* `--verify` with 0 register/flag/write mismatches (result in
  `docs/TESTING.md`).
* 12,000-frame WAV capture and continuity analysis.
* Windows Release executable launch (headless and windowed smoke).
* Linux Release build and AppImage launch under Xvfb at 1280×800.

Not tested: physical Steam Deck LCD/OLED, Gaming Mode, Steam Input hardware,
physical gamepads, subjective audio quality, two-player, every stage/ending.

## Known limitations

* Native coverage is high but not 100% on every session; banked entry points
  and a small number of runtime-only paths still use Musashi. They run
  correctly, just interpreted.
* Memory cards and save states are not implemented.
* The audio mix has not been auditioned; continuity/level are measured.
* No physical Steam Deck was available; the AppImage was validated on
  Ubuntu 22.04 under WSL2 with an X11 virtual display.
* The public repository omits CMake files by request, so it is a source
  archive rather than a one-command build from GitHub.

## Licensing

* **Original project code:** PolyForm Noncommercial License 1.0.0
  (confirmed by the owner on 2026-10-27). See `LICENSE` and
  `LICENSE-STATUS.md`. This is not an OSI open-source license and does not
  permit commercial redistribution.
* **neogeorecomp:** MIT, copyright sp00nznet. Preserved in
  `neogeorecomp/LICENSE`, `NOTICE` and `LICENSES/`. The generic runtime
  changes are offered under MIT.
* **Musashi:** MIT (Karl Stenerud). **superzazu/z80:** MIT (Nicolas
  Allemand). **ymfm:** BSD-3-Clause (Aaron Giles). **SDL2:** zlib.
* **ROMs, BIOS and recompiled C derived from them:** not distributed. No
  rights to SNK's game are granted. The release binaries contain translated
  game code and are provided for use with ROMs the user is legally entitled
  to use.

Fatal Fury 3 and Neo Geo are trademarks of SNK Corporation. This project is
not affiliated with or endorsed by SNK.
