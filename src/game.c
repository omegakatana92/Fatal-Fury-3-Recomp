/*
 * game.c - Fatal Fury 3: Road to the Final Victory (MAME set "fatfury3"),
 * the verified ROM layout shared by the player and the recompiler.
 *
 * The supplied archive is SNK's original, unencrypted MVS release.  Every
 * file's size and SHA-1 was checked against MAME's neogeo.cpp
 * ROM_START( fatfury3 ) (NGH-069):
 *
 *   069-p1.p1    1 MB   fixed program bank, stored byte-swapped
 *   069-sp2.sp2  2 MB   banked program image, stored byte-swapped
 *   069-c1..c6          sprite bitplanes, C1/C2 and C3/C4 4 MB, C5/C6 2 MB
 *   069-s1.s1  128 KB   fixed layer
 *   069-m1.m1  128 KB   Z80 sound program
 *   069-v1..v3  10 MB   ADPCM samples (4 MB + 4 MB + 2 MB)
 *
 * The cart uses Neo Geo's standard PROGBK1 bank selector at $2FFFF0: the
 * low bits choose a 1 MB window inside the 2 MB banked image.  There is no
 * protection device, no encryption and no S-ROM extraction step, so the
 * generic toolkit path is used.
 */
#include "game.h"

const ng_game_t k_fatfury3 = {
    .name = "fatfury3",
    .title = "Fatal Fury 3 - Road to the Final Victory",
    .prom_size = 0x300000,          /* 1 MB fixed + 2 MB banked */
    .prom = {
        {"069-p1.p1",   0x000000, 0x000000, 0x100000, 1},
        {"069-sp2.sp2", 0x000000, 0x100000, 0x200000, 1},
    },
    .crom_size = 0x1400000,         /* 20 MB after pairing */
    .crom_pairs = {
        {"069-c1.c1", "069-c2.c2"},
        {"069-c3.c3", "069-c4.c4"},
        {"069-c5.c5", "069-c6.c6"},
    },
    .srom = "069-s1.s1",
    .m1 = "069-m1.m1",
    .vrom = {"069-v1.v1", "069-v2.v2", "069-v3.v3"},
};
