/*
    65tass: source map, address to source file and line (--source-map,
    --source-map-vice), road map phase 3

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
#ifndef SOURCEMAP_H
#define SOURCEMAP_H
#include "stdbool.h"
#include "inttypes.h"

/* true during the final pass when a source map is requested */
extern bool source_map_active;

/* before the final pass: true if a source map is requested */
extern bool source_map_open(void);
/* bytes written at CPU address laddr, image offset addr, by the current
   source line (current_file_list, lpoint.line) */
extern void source_map_add(address_t laddr, address_t addr, address_t len);
/* after the final pass: write the files */
extern void source_map_close(void);
#endif
