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
#ifndef CYCLES_H
#define CYCLES_H
#include "stdbool.h"
#include "inttypes.h"

struct cpu_s;

#define CYCLES_TEXT_LEN 16

/* Set by instruction.c around the 45GS02 prefix bytes (42 42, EA). */
extern bool cycles_prefix;

/* Write the cycle text of one instruction into buf (CYCLES_TEXT_LEN).
   cod: opcode, adr: operand bytes (little endian), ln: operand length,
   next: address after the instruction (for branch targets). */
extern void cycles_text(char *buf, const struct cpu_s *cpu, unsigned int cod,
                        uint32_t adr, int ln, uint32_t next);

/* Totals of .cycles/.endcycles blocks. cycles_account adds one instruction
   to the open blocks; it is called for every instruction in every pass. */
#define CYCLES_TOTAL_LEN 96
extern void cycles_reset(void);
extern bool cycles_block_open(void);
extern void cycles_account(const struct cpu_s *cpu, unsigned int cod,
                           uint32_t adr, int ln, uint32_t next);
extern bool cycles_block_begin(uint32_t iterations, uint32_t start);
/* Returns false without an open block. min/max: total; unknown: an
   instruction of the block has no documented timing. */
extern bool cycles_block_end(uint32_t end, char *buf, uint64_t *min,
                             uint64_t *max, bool *unknown);
#endif
