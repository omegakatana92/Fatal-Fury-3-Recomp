# Fatal Fury 3 — game notes

## Header and vectors

The fixed bank is `069-p1.p1`, byte-swapped as on the cartridge. After
`ng_swap16` it has the `NEO-GEO` signature at `$100` and the BIOS entry stubs
at `$122` (USER), `$128` (PLAYER_START), `$12E` (DEMO_END) and `$134`
(COIN_SOUND). The recompiler seeds discovery from these and from vectors
1–63 of both the cartridge and the BIOS.

## Program banking

`prom_size = 0x300000`:

* `$000000-$0FFFFF` — fixed 1 MB (vectors, BIOS interface, resident code/data)
* `$100000-$1FFFFF` — bank window, 1 MB, selected through `$2FFFF0`

`069-sp2.sp2` is 2 MB and loads at `$100000` in the combined image. The
generic `bus.c` maps the banked image at `$200000`; the 68k sees
`$200000-$2FFFFF` as the selected 1 MB window. The native dispatch guard
refuses a native entry there while the selected bank is non-zero, because the
same address can mean different ROM bytes. Those entries run in Musashi
instead of executing stale native code.

## Graphics

C ROMs are loaded as odd/even byte pairs in MAME's order (C1/C2, C3/C4,
C5/C6) into a 20 MB sprite region. The fixed layer is the 128 KB `069-s1.s1`.
The S ROM is plain; `fix_bank_type` is the default (no 512 KB CMC bank bits).

## Sound

`069-m1.m1` is 128 KB. The driver selects its own M1 banks for music data
through the NEO-ZMC ports `$08-$0B`; `audio.c` derives the bank mask from the
M1 size exactly as MAME's `init_audio()` does. The V ROMs (4+4+2 MB) are
presented linearly to the YM2610's ADPCM-A and ADPCM-B address spaces.

## Input path

The BIOS reads the MVS controller ports at `$300000` (P1), `$340000` (P2) and
`$380000` (start/select), active-low. The runtime's keyboard and gamepad
layers fill `ng_input_t`, and `io_set_inputs()` applies the inversion once.
The test scripts use frame numbers from power-on; the BIOS eyecatcher ends
around frame 600 and the title appears around frame 3000 in the tested
configuration.

## Seed timings

| Frame | Event |
|---:|---|
| ~600 | BIOS eyecatcher |
| ~3000 | Fatal Fury 3 title / INSERT COIN |
| 3200 | coin in `tests/coin_start.txt` |
| 3400 | start |
| ~3800 | HOW TO PLAY |
| ~4600 | ENEMY SELECT |
| ~6000 | match starts |
