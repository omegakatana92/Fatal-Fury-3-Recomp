# Compatibility — Fatal Fury 3

## Game

* Title: **Fatal Fury 3: Road to the Final Victory**
* MAME set: `fatfury3` (NGH-069), MVS/AES
* Year: 1995, SNK
* Board: NEO-MVS PROGBK1 / CHA-? (standard Neo Geo, no custom protection)
* BIOS used: `sp-s2.sp1` (MVS Asia/Europe v2)

## ROM layout

| File | Size | SHA-1 | Load |
|---|---:|---|---|
| `069-p1.p1` | 1,048,576 | `519c4861…e7c4` | fixed bank, byte-swapped |
| `069-sp2.sp2` | 2,097,152 | `8ece7f66…e67e` | banked image at `$100000`, byte-swapped |
| `069-s1.s1` | 131,072 | `b7d2cc97…b2db` | fixed layer |
| `069-m1.m1` | 131,072 | `a40c74f7…12d4` | Z80 program |
| `069-c1.c1` … `069-c6.c6` | 4/4/4/4/2/2 MB | see README | paired sprite bitplanes |
| `069-v1.v1` … `069-v3.v3` | 4/4/2 MB | see README | ADPCM-A/B samples |

Program image: `0x300000` bytes = 1 MB fixed + 2 MB banked. The cart uses the
standard PROGBK1 selector at `$2FFFF0`; writes select a 1 MB window. No
NEO-SMA, no CMC encryption, no S-ROM extraction.

## Hardware model exercised

| Area | State |
|---|---|
| 68000 | 469,428 instructions recompiled into 13,958 routines; Musashi fallback |
| BIOS | real `sp-s2.sp1`, no HLE; power-on RAM test and eyecatcher run |
| Cartridge banking | standard `$2FFFF0` selector, bank guard in `exec.c` |
| Video | per-scanline sprites, shrink, sticky chains, 96/line limit, fix layer, both palette banks |
| Palette / raster | palette RAM, raster timer IRQ, auto-animation |
| Input | keyboard and SDL2 GameController, two players, coin/service/test |
| Audio | real Z80 M1 driver, NMI/reply latches, M1 banking, YM2610 FM/SSG/ADPCM-A/B through ymfm |
| Watchdog | reset on expiry, used by the BIOS/protection checks |
| Backup RAM | banked and locked/unlocked through the system latch |

## Working

* BIOS boot, NEO-GEO MAX screen, title/attract.
* Coin/start, HOW TO PLAY, ENEMY SELECT.
* Match start and fighting on the tested stage.
* Audio from boot through the match; no driver stall in the 12,000-frame
  capture.
* Windows x64 Release and Linux x86_64 AppImage.

## Not verified / limitations

* Only one match/stage and one continue were exercised.
* Not every character, stage, ending or the service menu.
* No physical Steam Deck, Gaming Mode, Steam Input hardware or physical pad.
* No subjective audio audition; measurements only.
* Memory cards and save states are not implemented.
* Remaining runtime-only 68k entry points run in Musashi (99.57% native on
  the tested session).

## Tested environment

* Windows 11 x64, MSVC 19.51 (VS 18 2026), SDL2 2.32.10.
* WSL2 Ubuntu 22.04, gcc 11.4, glibc 2.35, SDL2 2.0.20, Xvfb.
* No physical Steam Deck.
