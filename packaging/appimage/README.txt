Fatal Fury 3: Road to the Final Victory - Steam Deck / Linux x86_64 AppImage
===========================================================================

This is a native Linux x86_64 build. The game's Motorola 68000 program was
statically recompiled to C and runs on the neogeorecomp MVS board model with
the real MVS BIOS. It is not an emulator wrapper.

ROMs are NOT included
---------------------
Supply your own legally obtained MAME dumps, unzipped flat into a folder
named "roms":

  From fatfury3.zip:
    069-p1.p1   069-sp2.sp2   069-s1.s1   069-m1.m1
    069-c1.c1   069-c2.c2     069-c3.c3   069-c4.c4
    069-c5.c5   069-c6.c6     069-v1.v1   069-v2.v2
    069-v3.v3
  From neogeo.zip:
    sp-s2.sp1   sfix.sfix   sm1.sm1   000-lo.lo

The AppRun script looks for the folder in this order:
  - an explicit --rom-path;
  - FATFURY3_ROM_DIR;
  - a "roms" folder next to the AppImage;
  - ~/.local/share/fatfury3/roms;
  - ~/Emulation/roms/fatfury3, ~/roms/fatfury3, ~/roms.

Quick start
-----------
1. chmod +x "Fatal Fury 3-SteamDeck-x86_64.AppImage"
2. Desktop Mode: double-click it.
   Gaming Mode: add it as a non-Steam game and launch it.
3. F11 toggles fullscreen, Esc quits.

Steam Deck controls
-------------------
  D-pad / left stick         move
  A B X Y (Xbox layout)      Neo Geo A B C D
  Back                       insert coin
  Start                      player 1 start
  Left shoulder              select
  Keyboard: arrows, Z X C V = A B C D, 5 = coin, 1 = start, 3 = select,
  9 = service, F2 = test, F11 = fullscreen, Esc = quit.

Steam Input: the runtime uses SDL2's GameController mapping. A pad SDL does
not recognise can be described with SDL_GAMECONTROLLERCONFIG. A standard
Xbox-layout pad works without extra configuration.

Display
-------
The game runs at its native 320x224 and is presented at 4:3 in fullscreen
(1280x800 -> 1066x800 pillarboxed), so it is not stretched to the 16:10
panel. Internal refresh is the MVS 59.1856 Hz and frames are paced to it.

Audio
-----
The real Z80 sound driver runs the YM2610 (FM, SSG, ADPCM-A/B). Output is
converted to the device rate with SDL_AudioStream, starts with a 60 ms
cushion, recovers from a dry queue without dropping real samples, and trims
only the oldest excess after a >250 ms stall. Subjective mix quality was
not auditioned in this environment.

Verification
------------
Built and run under Ubuntu 22.04 (glibc 2.35) under WSL2: headless boot,
attract mode, coin/start, character select and gameplay, --verify with 0
mismatches, and the AppImage launched at 1280x800 under Xvfb (SDL2 X11),
exiting 0. Physical Steam Deck LCD/OLED hardware, Steam Input and Gaming
Mode were not available, so they are not claimed as tested. SteamOS 3 is
glibc 2.35-compatible with the build host.

Licensing
---------
The project's own source is PolyForm Noncommercial 1.0.0. The bundled
neogeorecomp toolkit and Musashi/z80/ymfm keep their MIT/BSD licenses; see
the LICENSES folder. No ROM or BIOS data is included. Fatal Fury 3 and Neo
Geo are trademarks of SNK Corporation; this project is not affiliated with
or endorsed by SNK. The binary contains code generated from SNK's ROM data;
use it only with ROMs you are legally entitled to use.
