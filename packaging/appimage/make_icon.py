#!/usr/bin/env python3
"""Draw an original 256x256 icon for the Fatal Fury 3 recompilation.

No SNK artwork is used: the mark is a sunset-coloured field, a dark panel,
and block letters drawn from a tiny bitmap font.
"""
import os, struct, zlib

W = H = 256
px = bytearray(W * H * 3)

def put(x, y, r, g, b):
    if 0 <= x < W and 0 <= y < H:
        i = (y * W + x) * 3
        px[i] = r; px[i+1] = g; px[i+2] = b

# warm vertical gradient
for y in range(H):
    for x in range(W):
        put(x, y, 40 + y // 5, 12 + y // 12, 8 + y // 24)

# diagonal amber band
for y in range(H):
    for x in range(W):
        if 30 <= (x + y) % 256 <= 66:
            put(x, y, 226, 116, 26)

# dark panel behind the letters
for y in range(84, 178):
    for x in range(20, 236):
        put(x, y, 16, 12, 14)

FONT = {
    'F': ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
    '3': ["11110", "00001", "00001", "01110", "00001", "00001", "11110"],
}
text = "FF3"
scale = 12
tw = (len(text) * 5 + (len(text) - 1)) * scale
tx = (W - tw) // 2
ty = (H - 7 * scale) // 2
for ci, ch in enumerate(text):
    for gy, row in enumerate(FONT[ch]):
        for gx, bit in enumerate(row):
            if bit == '1':
                for yy in range(scale):
                    for xx in range(scale):
                        put(tx + (ci * 6 + gx) * scale + xx,
                            ty + gy * scale + yy, 246, 238, 220)

# small blue accent bar under the letters
for y in range(196, 204):
    for x in range(78, 178):
        put(x, y, 54, 108, 196)

raw = bytearray()
for y in range(H):
    raw.append(0)
    raw += px[y * W * 3:(y + 1) * W * 3]

def chunk(t, d):
    return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)

out = b'\x89PNG\r\n\x1a\n'
out += chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0))
out += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
out += chunk(b'IEND', b'')
path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fatfury3.png")
open(path, 'wb').write(out)
print(path)
