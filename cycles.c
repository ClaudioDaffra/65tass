/*
    65tass: CPU cycle counts for the listing (--list-cycles)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

*/
/*
   Cycle text written into the listing column:
     4        fixed number of cycles
     4-5      minimum-maximum (index crossing a page, decimal mode on the
              65C02, 65816 native/emulation mode or 16 bit index)
     2/3      branch: not taken / taken
     2/4p     branch whose taken target is on another page (p), known at
              assembly time
     7*n      65816 MVN/MVP: 7 cycles per byte moved
     -        the instruction halts the CPU (NMOS JAM)
     +        45GS02 prefix byte, counted with the next instruction
     ?        no documented timing for this CPU and opcode

   Sources:
     NMOS 6502 (also illegal opcodes, 6510, 8500, 8502, 7501, 8501) and
     65DTV02: MCS6500 programming manual timing; illegal opcodes from the
     usual NMOS 6510 tables.
     65C02, R65C02, W65C02: WDC W65C02S / Rockwell R65C02 data sheets.
     65816: WDC W65C816S data sheet (notes on m, x, e and DL).
     65CE02, 4510, 45GS02: Commodore 65 System Specification 2.3.7.5 and the
     CBM 4510 data sheet (drawing 390490). TRB/TSB are missing there and
     follow the other read-modify-write instructions (4 base page, 5
     absolute). The 45GS02 prefixed instructions (Q register, [zp],z) have
     no documented timing here.
*/
#include "cycles.h"
#include <stdio.h>
#include "opcodes.h"
#include "instruction.h"

bool cycles_prefix;

#define F_PAGE 0x0001u  /* +1 if the index crosses a page (reads) */
#define F_DEC  0x0002u  /* +1 in decimal mode (65C02 ADC/SBC) */
#define F_BR   0x0004u  /* branch: +1 if taken, +1 more if the target page differs */
#define F_BRA  0x0008u  /* always taken branch: +1 if the target page differs */
#define F_M    0x0010u  /* 65816: +1 if m=0 (16 bit accumulator/memory) */
#define F_M2   0x0020u  /* 65816: +2 if m=0 (read-modify-write) */
#define F_X    0x0040u  /* 65816: +1 if x=0 (16 bit index) */
#define F_DL   0x0080u  /* 65816: +1 if the low byte of D is not zero */
#define F_PX   0x0100u  /* 65816: +1 if x=0 or the index crosses a page */
#define F_E    0x0200u  /* 65816: +1 in native mode */
#define F_BRE  0x0400u  /* 65816 branch: +1 taken, +1 page crossed in emulation */
#define F_BRAE 0x0800u  /* 65816 BRA: +1 page crossed in emulation */
#define F_MOVE 0x1000u  /* 65816 MVN/MVP: cycles per byte */
#define F_UNK  0x2000u  /* no documented timing */
#define F_JAM  0x4000u  /* halts the CPU */

struct cycles_s {
    uint8_t base;
    uint16_t flags;
};

#define N(n) {n, 0}
#define C(n, f) {n, f}
#define Pg(n) {n, F_PAGE}
#define Br {2, F_BR}
#define Jm {0, F_JAM}
#define Un {0, F_UNK}

/* NMOS 6502 with the illegal opcodes */
static const struct cycles_s nmos[256] = {
    /* 0 */ N(7),N(6),Jm,N(8),N(3),N(3),N(5),N(5),N(3),N(2),N(2),N(2),N(4),N(4),N(6),N(6),
    /* 1 */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7),
    /* 2 */ N(6),N(6),Jm,N(8),N(3),N(3),N(5),N(5),N(4),N(2),N(2),N(2),N(4),N(4),N(6),N(6),
    /* 3 */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7),
    /* 4 */ N(6),N(6),Jm,N(8),N(3),N(3),N(5),N(5),N(3),N(2),N(2),N(2),N(3),N(4),N(6),N(6),
    /* 5 */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7),
    /* 6 */ N(6),N(6),Jm,N(8),N(3),N(3),N(5),N(5),N(4),N(2),N(2),N(2),N(5),N(4),N(6),N(6),
    /* 7 */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7),
    /* 8 */ N(2),N(6),N(2),N(6),N(3),N(3),N(3),N(3),N(2),N(2),N(2),N(2),N(4),N(4),N(4),N(4),
    /* 9 */ Br,N(6),Jm,N(6),N(4),N(4),N(4),N(4),N(2),N(5),N(2),N(5),N(5),N(5),N(5),N(5),
    /* A */ N(2),N(6),N(2),N(6),N(3),N(3),N(3),N(3),N(2),N(2),N(2),N(2),N(4),N(4),N(4),N(4),
    /* B */ Br,Pg(5),Jm,Pg(5),N(4),N(4),N(4),N(4),N(2),Pg(4),N(2),Pg(4),Pg(4),Pg(4),Pg(4),Pg(4),
    /* C */ N(2),N(6),N(2),N(8),N(3),N(3),N(5),N(5),N(2),N(2),N(2),N(2),N(4),N(4),N(6),N(6),
    /* D */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7),
    /* E */ N(2),N(6),N(2),N(8),N(3),N(3),N(5),N(5),N(2),N(2),N(2),N(2),N(4),N(4),N(6),N(6),
    /* F */ Br,Pg(5),Jm,N(8),N(4),N(4),N(6),N(6),N(2),Pg(4),N(2),N(7),Pg(4),Pg(4),N(7),N(7)
};

#define Dc(n) {n, F_DEC}
#define PD(n) {n, F_PAGE | F_DEC}
#define Bb {5, F_BR}

/* CMOS 65C02, R65C02 (bit instructions) and W65C02 (WAI, STP) */
static const struct cycles_s cmos[256] = {
    /* 0 */ N(7),N(6),N(2),N(1),N(5),N(3),N(5),N(5),N(3),N(2),N(2),N(1),N(6),N(4),N(6),Bb,
    /* 1 */ Br,Pg(5),N(5),N(1),N(5),N(4),N(6),N(5),N(2),Pg(4),N(2),N(1),N(6),Pg(4),Pg(6),Bb,
    /* 2 */ N(6),N(6),N(2),N(1),N(3),N(3),N(5),N(5),N(4),N(2),N(2),N(1),N(4),N(4),N(6),Bb,
    /* 3 */ Br,Pg(5),N(5),N(1),N(4),N(4),N(6),N(5),N(2),Pg(4),N(2),N(1),Pg(4),Pg(4),Pg(6),Bb,
    /* 4 */ N(6),N(6),N(2),N(1),N(3),N(3),N(5),N(5),N(3),N(2),N(2),N(1),N(3),N(4),N(6),Bb,
    /* 5 */ Br,Pg(5),N(5),N(1),N(4),N(4),N(6),N(5),N(2),Pg(4),N(3),N(1),N(8),Pg(4),Pg(6),Bb,
    /* 6 */ N(6),Dc(6),N(2),N(1),N(3),Dc(3),N(5),N(5),N(4),Dc(2),N(2),N(1),N(6),Dc(4),N(6),Bb,
    /* 7 */ Br,PD(5),Dc(5),N(1),N(4),Dc(4),N(6),N(5),N(2),PD(4),N(4),N(1),N(6),PD(4),Pg(6),Bb,
    /* 8 */ C(3, F_BRA),N(6),N(2),N(1),N(3),N(3),N(3),N(5),N(2),N(2),N(2),N(1),N(4),N(4),N(4),Bb,
    /* 9 */ Br,N(6),N(5),N(1),N(4),N(4),N(4),N(5),N(2),N(5),N(2),N(1),N(4),N(5),N(5),Bb,
    /* A */ N(2),N(6),N(2),N(1),N(3),N(3),N(3),N(5),N(2),N(2),N(2),N(1),N(4),N(4),N(4),Bb,
    /* B */ Br,Pg(5),N(5),N(1),N(4),N(4),N(4),N(5),N(2),Pg(4),N(2),N(1),Pg(4),Pg(4),Pg(4),Bb,
    /* C */ N(2),N(6),N(2),N(1),N(3),N(3),N(5),N(5),N(2),N(2),N(2),N(3),N(4),N(4),N(6),Bb,
    /* D */ Br,Pg(5),N(5),N(1),N(4),N(4),N(6),N(5),N(2),Pg(4),N(3),N(3),N(4),Pg(4),N(7),Bb,
    /* E */ N(2),Dc(6),N(2),N(1),N(3),Dc(3),N(5),N(5),N(2),Dc(2),N(2),N(1),N(4),Dc(4),N(6),Bb,
    /* F */ Br,PD(5),Dc(5),N(1),N(4),Dc(4),N(6),N(5),N(2),PD(4),N(4),N(1),N(4),PD(4),N(7),Bb
};

#define M_(n) {n, F_M}
#define MD(n) {n, F_M | F_DL}
#define MDP(n) {n, F_M | F_DL | F_PX}
#define MP(n) {n, F_M | F_PX}
#define R2(n) {n, F_M2}
#define R2D(n) {n, F_M2 | F_DL}
#define X_(n) {n, F_X}
#define XD(n) {n, F_X | F_DL}
#define XP(n) {n, F_X | F_PX}
#define DL(n) {n, F_DL}
#define E_(n) {n, F_E}
#define BrE {2, F_BRE}
#define Mv {7, F_MOVE}

/* WDC 65816 (base: m=1, x=1, D low byte zero, emulation mode) */
static const struct cycles_s w816[256] = {
    /* 0 */ E_(7),MD(6),E_(7),M_(4),R2D(5),MD(3),R2D(5),MD(6),N(3),M_(2),N(2),N(4),R2(6),M_(4),R2(6),M_(5),
    /* 1 */ BrE,MDP(5),MD(5),M_(7),R2D(5),MD(4),R2D(6),MD(6),N(2),MP(4),N(2),N(2),R2(6),MP(4),R2(7),M_(5),
    /* 2 */ N(6),MD(6),N(8),M_(4),MD(3),MD(3),R2D(5),MD(6),N(4),M_(2),N(2),N(5),M_(4),M_(4),R2(6),M_(5),
    /* 3 */ BrE,MDP(5),MD(5),M_(7),MD(4),MD(4),R2D(6),MD(6),N(2),MP(4),N(2),N(2),MP(4),MP(4),R2(7),M_(5),
    /* 4 */ E_(6),MD(6),N(2),M_(4),Mv,MD(3),R2D(5),MD(6),M_(3),M_(2),N(2),N(3),N(3),M_(4),R2(6),M_(5),
    /* 5 */ BrE,MDP(5),MD(5),M_(7),Mv,MD(4),R2D(6),MD(6),N(2),MP(4),X_(3),N(2),N(4),MP(4),R2(7),M_(5),
    /* 6 */ N(6),MD(6),N(6),M_(4),MD(3),MD(3),R2D(5),MD(6),M_(4),M_(2),N(2),N(6),N(5),M_(4),R2(6),M_(5),
    /* 7 */ BrE,MDP(5),MD(5),M_(7),MD(4),MD(4),R2D(6),MD(6),N(2),MP(4),X_(4),N(2),N(6),MP(4),R2(7),M_(5),
    /* 8 */ C(3, F_BRAE),MD(6),N(4),M_(4),XD(3),MD(3),XD(3),MD(6),N(2),M_(2),N(2),N(3),X_(4),M_(4),X_(4),M_(5),
    /* 9 */ BrE,MD(6),MD(5),M_(7),XD(4),MD(4),XD(4),MD(6),N(2),M_(5),N(2),N(2),M_(4),M_(5),M_(5),M_(5),
    /* A */ X_(2),MD(6),X_(2),M_(4),XD(3),MD(3),XD(3),MD(6),N(2),M_(2),N(2),N(4),X_(4),M_(4),X_(4),M_(5),
    /* B */ BrE,MDP(5),MD(5),M_(7),XD(4),MD(4),XD(4),MD(6),N(2),MP(4),N(2),N(2),XP(4),MP(4),XP(4),M_(5),
    /* C */ X_(2),MD(6),N(3),M_(4),XD(3),MD(3),R2D(5),MD(6),N(2),M_(2),N(2),N(3),X_(4),M_(4),R2(6),M_(5),
    /* D */ BrE,MDP(5),MD(5),M_(7),DL(6),MD(4),R2D(6),MD(6),N(2),MP(4),X_(3),N(3),N(6),MP(4),R2(7),M_(5),
    /* E */ X_(2),MD(6),N(3),M_(4),XD(3),MD(3),R2D(5),MD(6),N(2),M_(2),N(2),N(3),X_(4),M_(4),R2(6),M_(5),
    /* F */ BrE,MDP(5),MD(5),M_(7),N(5),MD(4),R2D(6),MD(6),N(2),MP(4),X_(4),N(2),N(8),MP(4),R2(7),M_(5)
};

/* CSG 65CE02 / 4510 (Commodore 65): no page crossing penalties, branches
   take the same time taken or not. */
static const struct cycles_s ce02[256] = {
    /* 0 */ N(7),N(5),N(2),N(2),N(4),N(3),N(4),N(4),N(3),N(2),N(1),N(1),N(5),N(4),N(5),N(4),
    /* 1 */ N(2),N(5),N(5),N(3),N(4),N(3),N(4),N(4),N(1),N(4),N(1),N(1),N(5),N(4),N(5),N(4),
    /* 2 */ N(5),N(5),N(7),N(7),N(4),N(3),N(4),N(4),N(3),N(2),N(1),N(1),N(5),N(4),N(5),N(4),
    /* 3 */ N(2),N(5),N(5),N(3),N(4),N(3),N(4),N(4),N(1),N(4),N(1),N(1),N(5),N(4),N(5),N(4),
    /* 4 */ N(5),N(5),N(2),N(2),N(4),N(3),N(4),N(4),N(3),N(2),N(1),N(1),N(3),N(4),N(5),N(4),
    /* 5 */ N(2),N(5),N(5),N(3),N(4),N(3),N(4),N(4),N(2),N(4),N(3),N(1),N(4),N(4),N(5),N(4),
    /* 6 */ N(4),N(5),N(7),N(5),N(3),N(3),N(4),N(4),N(3),N(2),N(1),N(1),N(5),N(4),N(5),N(4),
    /* 7 */ N(2),N(5),N(5),N(3),N(3),N(3),N(4),N(4),N(2),N(4),N(3),N(1),N(5),N(4),N(5),N(4),
    /* 8 */ N(2),N(5),N(6),N(3),N(3),N(3),N(3),N(4),N(1),N(2),N(1),N(4),N(4),N(4),N(4),N(4),
    /* 9 */ N(2),N(5),N(5),N(3),N(3),N(3),N(3),N(4),N(1),N(4),N(1),N(4),N(4),N(4),N(4),N(4),
    /* A */ N(2),N(5),N(2),N(2),N(3),N(3),N(3),N(4),N(1),N(2),N(1),N(4),N(4),N(4),N(4),N(4),
    /* B */ N(2),N(5),N(5),N(3),N(3),N(3),N(3),N(4),N(1),N(4),N(1),N(4),N(4),N(4),N(4),N(4),
    /* C */ N(2),N(5),N(2),N(6),N(3),N(3),N(4),N(4),N(1),N(2),N(1),N(7),N(4),N(4),N(5),N(4),
    /* D */ N(2),N(5),N(5),N(3),N(3),N(3),N(4),N(4),N(1),N(4),N(3),N(3),N(4),N(4),N(5),N(4),
    /* E */ N(2),N(5),N(6),N(6),N(3),N(3),N(4),N(4),N(1),N(2),N(1),N(6),N(4),N(4),N(5),N(4),
    /* F */ N(2),N(5),N(5),N(3),N(5),N(3),N(4),N(4),N(1),N(4),N(3),N(3),N(7),N(4),N(5),N(4)
};

/* 65EL02 opcodes not shared with the 65C02: no timing source */
static const uint8_t el02_unknown[] = {
    0x02, 0x03, 0x07, 0x0b, 0x0f, 0x13, 0x17, 0x1b, 0x1f, 0x22, 0x23, 0x27,
    0x2b, 0x2f, 0x33, 0x37, 0x3b, 0x3f, 0x42, 0x43, 0x44, 0x47, 0x4b, 0x4f,
    0x53, 0x54, 0x57, 0x5b, 0x5c, 0x5f, 0x62, 0x63, 0x67, 0x6b, 0x6f, 0x73,
    0x77, 0x7b, 0x7f, 0x82, 0x83, 0x87, 0x8b, 0x8f, 0x93, 0x97, 0x9b, 0x9f,
    0xa3, 0xa7, 0xab, 0xaf, 0xb3, 0xb7, 0xbb, 0xbf, 0xc2, 0xc3, 0xc7, 0xcb,
    0xcf, 0xd3, 0xd4, 0xd7, 0xdb, 0xdc, 0xdf, 0xe2, 0xe3, 0xe7, 0xeb, 0xef,
    0xf3, 0xf4, 0xf7, 0xfb, 0xfc
};

static bool in_list(const uint8_t *list, size_t len, unsigned int cod) {
    size_t i;
    for (i = 0; i < len; i++) if (list[i] == cod) return true;
    return false;
}

static bool page_crossed(uint32_t next, int offset) {
    uint32_t target = (next + (uint32_t)offset) & 0xffff;
    return ((target ^ next) & 0xff00) != 0;
}

/* Cycles of one instruction, for the column and for the totals. */
typedef enum Cval_kinds { CV_PLAIN, CV_BRANCH, CV_UNKNOWN, CV_PREFIX } Cval_kinds;

typedef struct Cval {
    Cval_kinds kind;
    unsigned int min, max;    /* CV_PLAIN; CV_BRANCH: not taken .. taken max */
    unsigned int nt;          /* CV_BRANCH: not taken */
    unsigned int tmin, tmax;  /* CV_BRANCH: taken */
    bool has_target;
    uint32_t target;
} Cval;

static void compute(Cval *v, char *buf, bool *pending_prefix, const struct cpu_s *cpu,
                    unsigned int cod, uint32_t adr, int ln, uint32_t next) {
    struct cycles_s c;
    unsigned int min, max;
    bool cross = false, known = false;
    int offset = 0;
    cod &= 0xff;
    v->has_target = false;
    if (cycles_prefix) {
        *pending_prefix = true;
        v->kind = CV_PREFIX;
        snprintf(buf, CYCLES_TEXT_LEN, "+");
        return;
    }
    if (*pending_prefix) {
        *pending_prefix = false;
        v->kind = CV_UNKNOWN;
        snprintf(buf, CYCLES_TEXT_LEN, "?");
        return;
    }
    if (cpu == &c6502 || cpu == &c6502i) c = nmos[cod];
    else if (cpu == &c65dtv02) {
        switch (cod) {
        case 0x12: c.base = 3; c.flags = F_BRA; break; /* BRA */
        case 0x32:                                      /* SAC # */
        case 0x42: c.base = 2; c.flags = 0; break;      /* SIR # */
        default: c = nmos[cod];
        }
    } else if (cpu == &c65c02 || cpu == &r65c02 || cpu == &w65c02) c = cmos[cod];
    else if (cpu == &c65el02) {
        if (in_list(el02_unknown, sizeof el02_unknown, cod)) { c.base = 0; c.flags = F_UNK; }
        else c = cmos[cod];
    } else if (cpu == &w65816) c = w816[cod];
    else if (cpu == &c65ce02 || cpu == &c4510 || cpu == &c45gs02) {
        c = ce02[cod];
        if (cpu == &c65ce02 && cod == 0x5c) { c.base = 0; c.flags = F_UNK; } /* AUG */
    } else { c.base = 0; c.flags = F_UNK; }

    if ((c.flags & (F_UNK | F_JAM | F_MOVE)) != 0) {
        v->kind = CV_UNKNOWN;
        if ((c.flags & F_UNK) != 0) snprintf(buf, CYCLES_TEXT_LEN, "?");
        else if ((c.flags & F_JAM) != 0) snprintf(buf, CYCLES_TEXT_LEN, "-");
        else snprintf(buf, CYCLES_TEXT_LEN, "%u*n", c.base);
        return;
    }

    min = max = c.base;
    if ((c.flags & F_M) != 0 && longaccu) { min++; max++; }
    if ((c.flags & F_M2) != 0 && longaccu) { min += 2; max += 2; }
    if ((c.flags & F_X) != 0 && longindex) { min++; max++; }
    if ((c.flags & F_DL) != 0 && (dpage & 0xff) != 0) { min++; max++; }
    if ((c.flags & F_PX) != 0) { if (longindex) { min++; max++; } else max++; }
    if ((c.flags & F_PAGE) != 0) max++;
    if ((c.flags & F_DEC) != 0) max++;
    if ((c.flags & F_E) != 0) max++;
    v->kind = CV_PLAIN;
    v->min = min; v->max = max;

    if ((c.flags & (F_BR | F_BRA | F_BRE | F_BRAE)) != 0) {
        /* byte relative offset: last operand byte (BBR/BBS: second one) */
        if (ln == 1) offset = (int8_t)adr;
        else if (ln == 2) offset = (int8_t)(adr >> 8);
        if (ln == 1 || ln == 2) {
            cross = page_crossed(next, offset);
            known = true;
            v->has_target = true;
            v->target = (next & ~(uint32_t)0xffff) | ((next + (uint32_t)offset) & 0xffff);
        }
        if ((c.flags & (F_BR | F_BRE)) != 0) {
            v->kind = CV_BRANCH;
            v->nt = min;
            v->tmin = min + 1;
            if ((c.flags & F_BR) != 0) v->tmax = v->tmin + ((!known || cross) ? 1 : 0);
            else v->tmax = v->tmin + ((!known || cross) ? 1 : 0);
            if ((c.flags & F_BR) != 0 && known) v->tmin = v->tmax;
            v->min = v->nt;
            v->max = v->tmax;
            if ((c.flags & F_BR) != 0 && known && cross) snprintf(buf, CYCLES_TEXT_LEN, "%u/%up", v->nt, v->tmax);
            else if (v->tmin == v->tmax) snprintf(buf, CYCLES_TEXT_LEN, "%u/%u", v->nt, v->tmax);
            else snprintf(buf, CYCLES_TEXT_LEN, "%u/%u-%u", v->nt, v->tmin, v->tmax);
            return;
        }
        /* always taken (BRA) */
        if ((c.flags & F_BRA) != 0) {
            if (known && cross) { v->min = v->max = min + 1; snprintf(buf, CYCLES_TEXT_LEN, "%up", min + 1); }
            else if (known) snprintf(buf, CYCLES_TEXT_LEN, "%u", min);
            else { v->max = min + 1; snprintf(buf, CYCLES_TEXT_LEN, "%u-%u", min, min + 1); }
        } else {
            if (known && !cross) snprintf(buf, CYCLES_TEXT_LEN, "%u", min);
            else { v->max = min + 1; snprintf(buf, CYCLES_TEXT_LEN, "%u-%u", min, min + 1); }
        }
        return;
    }
    if (min == max) snprintf(buf, CYCLES_TEXT_LEN, "%u", min);
    else snprintf(buf, CYCLES_TEXT_LEN, "%u-%u", min, max);
}

/* --------------------------------------------------------------------------
   .cycles <iterations> ... .endcycles

   Hypothesis written in the listing: every instruction of the block runs
   <iterations> times; branches count not taken (minimum) or taken (maximum),
   except the last instruction of the block when it is a branch back into
   the block (the loop branch): taken <iterations>-1 times and not taken
   once. An inner block counts as one instruction of the outer one. */

#define CYCLES_DEPTH 16

typedef struct Cblock {
    uint32_t start;
    uint32_t iterations;
    uint64_t min, max;
    unsigned int unknown;
    bool has_last;
    Cval last;
} Cblock;

static Cblock blocks[CYCLES_DEPTH];
static unsigned int depth;

void cycles_reset(void) {
    depth = 0;
}

bool cycles_block_open(void) {
    return depth != 0;
}

static void add_plain(Cblock *b, const Cval *v) {
    switch (v->kind) {
    case CV_PLAIN:
    case CV_BRANCH:
        b->min += v->min;
        b->max += v->max;
        break;
    case CV_UNKNOWN:
        b->unknown++;
        break;
    case CV_PREFIX:
        break;
    }
}

static void account(const Cval *v) {
    Cblock *b;
    if (depth == 0 || depth > CYCLES_DEPTH) return;
    b = &blocks[depth - 1];
    if (v->kind == CV_PREFIX) return;
    if (b->has_last) add_plain(b, &b->last);
    b->last = *v;
    b->has_last = true;
}

bool cycles_block_begin(uint32_t iterations, uint32_t start) {
    Cblock *b;
    depth++;
    if (depth > CYCLES_DEPTH) return false;
    b = &blocks[depth - 1];
    b->start = start;
    b->iterations = iterations;
    b->min = b->max = 0;
    b->unknown = 0;
    b->has_last = false;
    return true;
}

bool cycles_block_end(uint32_t end, char *buf, uint64_t *rmin, uint64_t *rmax, bool *runknown) {
    Cblock *b;
    uint64_t n, min, max;
    bool loop = false;
    Cval total;
    buf[0] = 0;
    *rmin = *rmax = 0;
    *runknown = true;
    if (depth == 0) return false;
    depth--;
    if (depth >= CYCLES_DEPTH) return true;
    b = &blocks[depth];
    n = b->iterations;
    if (b->has_last && b->last.kind == CV_BRANCH && b->last.has_target &&
        b->last.target >= b->start && b->last.target < end && n > 0) {
        loop = true;
        min = b->min * n + b->last.tmin * (n - 1) + b->last.nt;
        max = b->max * n + b->last.tmax * (n - 1) + b->last.nt;
    } else {
        if (b->has_last) add_plain(b, &b->last);
        min = b->min * n;
        max = b->max * n;
    }
    if (b->unknown != 0) {
        snprintf(buf, CYCLES_TOTAL_LEN, "unknown (%u instruction%s without timing)",
                 b->unknown, b->unknown == 1 ? "" : "s");
    } else {
        int l;
        if (min == max) l = snprintf(buf, CYCLES_TOTAL_LEN, "%llu", (unsigned long long)min);
        else l = snprintf(buf, CYCLES_TOTAL_LEN, "%llu-%llu", (unsigned long long)min, (unsigned long long)max);
        if (l > 0 && l < CYCLES_TOTAL_LEN) {
            if (loop) snprintf(buf + l, (size_t)(CYCLES_TOTAL_LEN - l), " (%llu iteration%s, loop branch taken %llu time%s)",
                               (unsigned long long)n, n == 1 ? "" : "s",
                               (unsigned long long)(n - 1), n == 2 ? "" : "s");
            else snprintf(buf + l, (size_t)(CYCLES_TOTAL_LEN - l), " (%llu iteration%s)",
                          (unsigned long long)n, n == 1 ? "" : "s");
        }
    }
    *rmin = min;
    *rmax = max;
    *runknown = b->unknown != 0;
    /* the block is one instruction of the outer block */
    if (depth > 0 && depth <= CYCLES_DEPTH) {
        if (b->unknown != 0) total.kind = CV_UNKNOWN;
        else {
            total.kind = CV_PLAIN;
            total.min = (unsigned int)(min > 0xffffffffu ? 0xffffffffu : min);
            total.max = (unsigned int)(max > 0xffffffffu ? 0xffffffffu : max);
        }
        total.has_target = false;
        account(&total);
    }
    return true;
}

void cycles_text(char *buf, const struct cpu_s *cpu, unsigned int cod,
                 uint32_t adr, int ln, uint32_t next) {
    static bool pending_prefix;
    Cval v;
    compute(&v, buf, &pending_prefix, cpu, cod, adr, ln, next);
}

/* Called for every instruction in every pass (instruction.c, dump_instr):
   the totals are known in each pass, so they can be used in the source. */
void cycles_account(const struct cpu_s *cpu, unsigned int cod,
                    uint32_t adr, int ln, uint32_t next) {
    static bool pending_prefix;
    char buf[CYCLES_TEXT_LEN];
    Cval v;
    compute(&v, buf, &pending_prefix, cpu, cod, adr, ln, next);
    account(&v);
}
