Fatal Fury 3: Road to the Final Victory - native static recompilation
====================================================================

Windows x64 build. The game's Motorola 68000 program was translated ahead of
time into C and runs on the neogeorecomp MVS board model with the real MVS
BIOS. It is not an emulator frontend.

ROMs are NOT included
---------------------
You must supply your own legally obtained MAME dumps:

  From fatfury3.zip:
    069-p1.p1   069-sp2.sp2   069-s1.s1   069-m1.m1
    069-c1.c1   069-c2.c2     069-c3.c3   069-c4.c4
    069-c5.c5   069-c6.c6     069-v1.v1   069-v2.v2
    069-v3.v3
  From neogeo.zip:
    sp-s2.sp1   sfix.sfix   sm1.sm1   000-lo.lo

The easiest way is to run:

    powershell -ExecutionPolicy Bypass -File .\Prepare-ROMs.ps1

It asks for the two zip files, extracts them into roms\, and writes nothing
outside this folder. You can also unzip both sets flat into roms\ yourself.

Run
---
    "Fatal Fury 3.exe" --rom-path roms
or
    "Fatal Fury 3.exe" --rom-path roms --fullscreen
or double-click "Play Fatal Fury 3.cmd".

F11 toggles fullscreen, Esc quits. Fullscreen keeps the Neo Geo's 4:3
aspect and pillarboxes it on a 16:9/16:10 display.

Controls
--------
  Arrows / left stick        move
  Z X C V / A B X Y          Neo Geo A B C D
  5 / pad Back               insert coin
  1 / pad Start              player 1 start
  2                          player 2 start
  3 / left shoulder          select
  9                          service credit
  F2                         test switch
  F11                        fullscreen
  Esc                        quit

Insert a coin before Start does anything (MVS behaviour).

Command-line options
--------------------
  --rom-path DIR        game ROM files (default: roms)
  --bios-path DIR       system ROM files (default: the ROM path)
  --bios FILE           system ROM (default: sp-s2.sp1)
  --headless            no window; run as fast as possible
  --frames N            stop after N frames
  --screenshot N:FILE   save frame N as PNG
  --input FILE          scripted input
  --wav FILE            write the YM2610 audio to a WAV file
  --interp              run everything in the interpreter
  --verify              replay every native block in Musashi and compare
  --dump-misses FILE    write interpreted entry points
  --scale N             window scale (default 3)
  --fullscreen          fullscreen, 4:3 pillarboxed
  --mute                no sound from the window

Status
------
  * Windows x64 Release build, MSVC 19.5x (VS 18 2026), SDL2 2.32.x.
  * The ROM set is the plain MAME "fatfury3" set (NGH-069); every file's
    SHA-1 was checked against MAME. No decryption or protection patch is
    needed.
  * Native recompilation coverage and the --verify result for the tested
    session are printed by the executable and recorded in the project
    README. Coverage is a measurement, not a claim about every code path.
  * Audio: real Z80 driver + YM2610 (FM, SSG, ADPCM-A/B), SDL2 output with
    rate conversion and underrun recovery. Subjective mix quality was not
    auditioned in this environment.
  * Physical Steam Deck and physical gamepads were not available for
    testing.

Licensing
---------
The project's original code is PolyForm Noncommercial 1.0.0 (see
LICENSES\LICENSE.txt and LICENSES\LICENSE-STATUS.txt). The bundled
neogeorecomp toolkit is MIT; Musashi and z80 are MIT; ymfm is BSD-3-Clause;
SDL2 is zlib. See LICENSES\THIRD_PARTY_NOTICES.txt.

Fatal Fury 3 and Neo Geo are trademarks of SNK Corporation. This project is
not affiliated with or endorsed by SNK. No ROM or BIOS data is included.
This package contains code generated from SNK's ROM data; use it only with
ROMs you are legally entitled to use. No rights to SNK's game are granted.
