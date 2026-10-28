# Runtime changes in the vendored toolkit

The project vendors neogeorecomp v0.2.0 at commit
`af96b2b4b39b42b392b17bcaa6a74a5f27088202` (MIT). On top of that baseline it
carries the generic fixes below. There are **no title-specific addresses,
ROM patches or game checks** in the runtime; the only Fatal Fury 3-specific
file is `src/game.c`, which describes the ROM layout.

The fixes are offered under the toolkit's MIT license.

## 1. Native bank-window guard (`src/exec.c`)

A native entry in `$200000-$2FFFFF` is refused while the cart bank is not 0.
The recompiled bank table describes only the image at the selected bank, so
the same 68k address can mean different bytes after a bank switch. Such code
runs in Musashi instead of executing stale native code. Fatal Fury 3's
standard PROGBK1 window is therefore safe.

## 2. Instruction accounting (`src/exec.c`)

`exec_native_instrs` counts instructions inside native blocks. The `[exec]`
report prints native and interpreted instruction counts plus a measured
native share and the number of uncovered entry points. All coverage numbers
in this project come from that line.

## 3. Watchdog reset in the board (`src/neogeo.c`)

The `$300001` kick and the ~1.62 M 68000-clock deadline are board-level. On
expiry the bus, LSPC, palette, video latch, audio ROM select, Z80 and CPU are
reset while work and backup RAM keep their contents; IRQ3 is asserted like the
BIOS expects. This is generic MVS behaviour.

## 4. M1 bank mask from the M1 file size (`src/audio.c`)

MAME's `init_audio()` builds each Z80 bank entry as

```
bank_address = 0x10000 + ((bank << (11 + window)) & address_mask);
```

with the M1 file visible from region offset `0x10000` through `ROM_RELOAD`.
The **file** offset is therefore the masked value alone:

```
file_offset = (bank & ((M1 size - 1) & 0x3FFFF)) + (addr & window_mask)
```

The old code added a second `0x10000` or used a mask derived the wrong way,
which truncated the banked music/sample data. This was the "music stops while
effects keep playing" family of failures in several ports. The fix is
size-derived and generic. Fatal Fury 3's 128 KB M1 uses mask `0x1FFFF`.

## 5. Frame-boundary Z80 sync (`src/audio.c`)

`audio_take_samples()` calls `audio_sync()` before generating samples, so the
Z80 sequencer and YM2610 timers keep running even when the 68000 stops
polling the sound latches.

## 6. YM2610 timer status vs IRQ enable (`src/audio.c`, 2026-10-27)

The two are separate on hardware. A timer's status bit latches when the timer
overflows, regardless of whether its IRQ is enabled; `$27` bits 2/3 only gate
the IRQ line to the Z80. The runtime previously set the status bit only when
the IRQ was enabled, which loses an event for any driver that polls status
with IRQs masked. `ym_update_timers()` now always latches status and
`audio_sync()` asserts `int_pending` only for an enabled, latched timer.

## 7. SDL output path (`src/window_sdl.c`, 2026-10-27)

* Device opened with `SDL_AUDIO_ALLOW_FREQUENCY_CHANGE`,
  `ALLOW_FORMAT_CHANGE` and `ALLOW_CHANNELS_CHANGE`; the 55,555 Hz YM2610
  stream is converted with `SDL_AudioStream`. Devices that reject 55,555 Hz
  no longer leave the game silent.
* Converted data is moved in **whole destination frames**, so a partial frame
  cannot slip into the device queue and swap left/right.
* The queue is trimmed **after** the newly converted data is queued, not one
  frame earlier. Only the oldest excess above 250 ms is dropped, down to the
  60 ms cushion; good audio is never discarded on ordinary jitter.
* If the device queue runs dry (<8 ms) between frames, it is re-cushioned to
  60 ms once. Previously SDL was left to underrun on every following frame,
  which is audible as clicks on a busy compositor.
* `NG_AUDIO_TRACE=1` reports the negotiated format, queue depth, peak queue,
  trim count and underrun count.

## 8. Fullscreen and 4:3 presentation (`src/window_sdl.c`)

`--fullscreen` creates a desktop-fullscreen window; F11 toggles it. The
320x224 image is drawn into a centred 4:3 rectangle (1280x800 -> 1066x800)
and is never stretched to 16:10.

## 9. Optional cart features (zero for Fatal Fury 3)

These are generic `ng_game_t` fields used by other carts, not hacks:

* `bank_map` / `bank_write_addr`: cart-supplied bank table and select port
  (NEO-SMA and similar).
* `prot_read_addr` / `prot_value`: constant protection read.
* `fix_bank_type`: 512 KB fixed-layer S ROMs that take tile-code bits from
  VRAM.

## 10. Fixed calendar for reproducible tests (`src/io.c`)

`NG_RTC=YYYY-MM-DD` seeds the uPD4990A calendar, so scripted sessions are
deterministic across runs and hosts.

## Scope

The vendored toolkit remains MIT. The project's own `src/`, tests, scripts,
packaging and docs are PolyForm Noncommercial 1.0.0. Third-party notices are
in `THIRD_PARTY_NOTICES.md` and `neogeorecomp/NOTICE`.
