#!/usr/bin/env python3
"""Audio continuity check for a Fatal Fury 3 capture.

Usage: tests/check_audio.py <capture.wav>

Boot (0-10 s) is ignored. After that, a music-sized dropout is a run of
whole seconds whose peak is below 50. Short two-second scene transitions
(HOW TO PLAY, select, continue) are allowed; three or more consecutive
seconds is a failure. The check also requires a non-silent capture and a
sensible median RMS.

Requires numpy (the WSL/Ubuntu test environment has it).
"""
import sys
import wave

import numpy as np


def main(path):
    w = wave.open(path, "rb")
    rate, channels = w.getframerate(), w.getnchannels()
    if rate < 8000 or channels not in (1, 2):
        print(f"FAIL: unexpected WAV format: {rate} Hz, {channels} ch")
        return 1
    n = w.getnframes()
    data = np.frombuffer(w.readframes(n), dtype="<i2").astype(np.float32)
    if channels == 2:
        data = data.reshape(-1, 2).mean(axis=1)
    peak = float(np.max(np.abs(data))) if len(data) else 0.0
    if peak < 1000:
        print(f"FAIL: capture is silent (peak {peak:.0f})")
        return 1

    win = rate
    secs = []
    for i in range(len(data) // win):
        block = data[i * win:(i + 1) * win]
        secs.append((i, float(np.sqrt(np.mean(block * block))),
                     int(np.max(np.abs(block)))))

    runs = []
    start = None
    for t, rms, pk in secs:
        if t < 10:
            continue
        if pk < 50:
            if start is None:
                start = t
        elif start is not None:
            if t - start >= 3:
                runs.append((start, t - 1))
            start = None
    if start is not None and len(secs) - start >= 3:
        runs.append((start, len(secs) - 1))

    after = [rms for t, rms, pk in secs if t >= 10]
    median = float(np.median(after)) if after else 0.0
    print(f"duration {n / rate:.2f} s, peak {peak:.0f}, "
          f"median RMS after 10 s {median:.1f}")
    if runs:
        print("FAIL: silent runs >= 3 s: " +
              ", ".join(f"{a}-{b} s" for a, b in runs))
        return 1
    if median < 500:
        print(f"FAIL: median RMS {median:.1f} is too low")
        return 1
    print("PASS: no music-sized dropout after boot")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: tests/check_audio.py <capture.wav>")
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
