# Testing Fatal Fury 3

All commands were run from the project root on 2026-10-27. The Windows build
used MSVC 19.51 (Visual Studio 18 2026) x64 and SDL2 2.32.10.

## 1. ROM validation

The supplied `fatfury3.zip` was opened without modification and every file's
size and SHA-1 compared with MAME's `ROM_START( fatfury3 )`. All 13 game
files matched (table in `README.md` and `docs/COMPATIBILITY.md`). The archive
also contained the `neogeo` BIOS files, which were extracted to `roms/`.

## 2. Interpreted boot

```bash
./Fatal\ Fury\ 3 --headless --interp --rom-path roms --frames 3000 \
  --screenshot 600:shots/i600.png --screenshot 2999:shots/i2999.png
```

Frame 600: NEO-GEO MAX BIOS eyecatcher. Frame 2999: Fatal Fury 3 title with
Terry and INSERT COIN. This checks the board model independently of the
recompiler.

## 3. Native boot and gameplay

```bash
"Fatal Fury 3.exe" --headless --rom-path roms --frames 6000 \
  --input tests/coin_start.txt \
  --screenshot 3400:shots/title.png --screenshot 3800:shots/howto.png \
  --screenshot 4600:shots/select.png --screenshot 5999:shots/match.png
```

Observed: title screen, HOW TO PLAY, ENEMY SELECT (Bob Wilson / Franco Bash /
Blue Mary / Joe Higashi), then the Terry vs Franco Bash match at the harbor
stage. The longer `tests/play.txt` run reaches 12,000 frames, loses the first
match, shows CONTINUE and returns to attract; no crash.

## 4. CPU verification

```bash
"Fatal Fury 3.exe" --headless --verify --rom-path roms --frames 6000 \
  --input tests/coin_start.txt
```

Result:

```
[verify] 4349426 blocks checked, 0 mismatches
[exec] native blocks 4349426, native instructions 109981868,
       interpreted instructions 473238 (99.57% native),
       380 uncovered entry points
```

No register, flag or bus-write mismatch. The interpreted instructions are
entry points not covered by static discovery; they execute correctly in
Musashi.

## 5. Coverage measurements

| Run | Frames | Native instructions | Interpreted | Native share | Uncovered |
|---|---:|---:|---:|---:|---:|
| Boot/attract, no input | 3,000 | 56,098,553 | 189,189 | 99.66% | 242 |
| Coin/start + match | 12,000 | 218,232,083 | 948,283 | 99.57% | 415 |
| Coin/start + match, verified | 6,000 | 109,981,868 | 473,238 | 99.57% | 380 |

A profile pass can add the remaining runtime-only addresses; the current
deliverable uses Musashi for them so correctness is unchanged.

## 6. Audio

```bash
"Fatal Fury 3.exe" --headless --rom-path roms --frames 12000 \
  --input tests/play.txt --wav shots/ff3-play.wav
```

Analysis (55,555 Hz stereo, 202.74 s):

* Peak 28,075; RMS 3668 (L) / 3600 (R); zero clipped samples.
* Quiet seconds (peak < 50): 0–7 (boot), 56–57 (HOW TO PLAY/scene change),
  61 (transition), 180 (CONTINUE/game over).
* No silent run of 3 s or more after 10 s.
* The Z80 command/reply latches, M1 bank changes and YM2610 register writes
  are visible with `NG_AUDIO_TRACE=1`.

The audio path was also rebuilt with the generic fixes described in
`docs/AUDIO-V4-2026-10-27.md`: timer status latches with IRQ masked, the SDL
queue is drained in whole device frames, and a dry queue is re-cushioned
once.

## 7. Windows package

`scripts/package-windows.ps1` produced
`dist/windows/Fatal Fury 3-Windows-x64` and its zip. The executable was
launched headless (above) and in a window with the real SDL2 DLL; F11 and Esc
were exercised. The package contains no ROMs or BIOS.

## 8. Linux and AppImage

Built under WSL2 Ubuntu 22.04 (gcc 11.4, glibc 2.35), SDL2 2.0.20:

```bash
./packaging/appimage/build-appimage.sh "$PWD/roms"
```

The AppImage was launched with `--headless`, with `--verify`, and with a
1280x800 Xvfb display in fullscreen (`NG_WINDOW_TRACE=1` reports the output
size and 4:3 destination rectangle). `ldd` was used to confirm the bundled
SDL2 resolves before the host copy. Exit code 0 in each case.

## Not tested

* Physical Steam Deck LCD/OLED, SteamOS Gaming Mode, Steam Input hardware.
* Physical gamepads and subjective audio quality.
* Two-player, every stage, every ending, service menu.
* Memory cards and save states (not implemented).
