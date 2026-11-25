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
#include "sourcemap.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "error.h"
#include "file.h"
#include "64tass.h"
#include "arguments.h"
#include "unicode.h"

/*
   Text format (--source-map), one record per line:

   ; 65tass source map, format 1
   F <number> <file name>
   <address> <offset> <length> <file>:<line> [<m|i><file>:<line> ...]

   address  CPU address of the first byte (hex), like the labels
   offset   compile offset of the first byte (hex), like ";Offset" in
            the listing; differs from address in .logical blocks
   length   number of bytes (decimal)
   file     number from an F record, line 1 based
   then the callers from the nearest: m = macro (or function, structure)
   call, i = .include. Records follow the order of assembly.

   VICE format (--source-map-vice): "al <address> .<file>_<line>" for every
   record, "_2", "_3"... when the same line comes again (loops, macros).
*/

struct source_map_entry_s {
    address_t laddr, addr, len;
    const struct file_list_s *flist;
    linenum_t line;
    linenum_t vline;     /* one record per processed line: .rept keeps them apart */
};

bool source_map_active = false;

static struct source_map_entry_s *entries;
static size_t entries_len, entries_max;
static unsigned int *filenum;            /* by file uid, 0 = not numbered */
static const struct file_s **files;
static size_t files_len, files_max;

bool source_map_open(void) {
    if (arguments.source_map.name == NULL && arguments.source_map.vice == NULL) return false;
    entries_len = 0;
    source_map_active = true;
    return true;
}

void source_map_add(address_t laddr, address_t addr, address_t len) {
    struct source_map_entry_s *e;
    if (len == 0) return;
    if (entries_len != 0) {
        e = &entries[entries_len - 1];
        if (e->flist == current_file_list && e->line == lpoint.line && e->vline == vline &&
                e->addr + e->len == addr && e->laddr + e->len == laddr) {
            e->len += len;
            return;
        }
    }
    if (entries_len >= entries_max) extend_array(&entries, &entries_max, 1024);
    e = &entries[entries_len++];
    e->laddr = laddr;
    e->addr = addr;
    e->len = len;
    e->flist = current_file_list;
    e->line = lpoint.line;
    e->vline = vline;
}

static unsigned int file_number(const struct file_s *file) {
    if (filenum == NULL) {
        new_array(&filenum, 65536);
        memset(filenum, 0, 65536 * sizeof *filenum);
    }
    if (filenum[file->uid] == 0) {
        if (files_len >= files_max) extend_array(&files, &files_max, 16);
        files[files_len++] = file;
        filenum[file->uid] = (unsigned int)files_len;
    }
    return filenum[file->uid];
}

static FILE *open_output(const char *name, const struct argpos_s *pos) {
    FILE *f = dash_name(name) ? stdout : fopen_utf8(name, "wt");
    if (f == NULL) {
        err_msg_file2(ERROR_CANT_WRTE_SRC, name, pos);
        return NULL;
    }
    if (f == stdout && fflush(f) != 0) setvbuf(f, NULL, _IOLBF, 1024);
    clearerr(f); errno = 0;
    return f;
}

static void close_output(FILE *f, const char *name, const struct argpos_s *pos) {
    int err = ferror(f);
    err |= (f != stdout) ? fclose(f) : fflush(f);
    if (err != 0 && errno != 0) err_msg_file2(ERROR_CANT_WRTE_SRC, name, pos);
}

static void write_text(FILE *f) {
    size_t i;
    fputs("; 65tass source map, format 1\n"
          "; F <number> <file name>\n"
          "; <address> <offset> <length> <file>:<line> [<m|i><file>:<line> ...]\n", f);
    for (i = 0; i < files_len; i++) {
        fprintf(f, "F %u %s\n", (unsigned int)(i + 1), files[i]->name);
    }
    for (i = 0; i < entries_len; i++) {
        const struct source_map_entry_s *e = &entries[i];
        const struct file_list_s *fl, *caller;
        bool macro;
        fprintf(f, "%04" PRIxaddress " %04" PRIxaddress " %" PRIuaddress " %u:%" PRIuline,
                e->laddr, e->addr, e->len, file_number(e->flist->file), e->line);
        for (fl = e->flist; (caller = file_list_caller(fl, &macro)) != NULL; fl = caller) {
            fprintf(f, " %c%u:%" PRIuline, macro ? 'm' : 'i', file_number(caller->file), fl->epoint.line);
        }
        putc('\n', f);
    }
}

static void vice_name(FILE *f, const char *name) {
    const char *b = name, *s, *dot = NULL;
    for (s = name; *s != 0; s++) {
        if (*s == '/' || *s == '\\') b = s + 1;
    }
    for (s = b; *s != 0; s++) {
        if (*s == '.') dot = s;
    }
    if (dot == NULL || dot == b) dot = s;
    if (b == dot) {
        fputs("src", f);
        return;
    }
    if (*b >= '0' && *b <= '9') putc('_', f);
    for (s = b; s < dot; s++) {
        char c = *s;
        if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_') putc(c, f);
        else putc('_', f);
    }
}

static void write_vice(FILE *f) {
    size_t i;
    unsigned int **counts;
    new_array(&counts, files_len != 0 ? files_len : 1);
    for (i = 0; i < files_len; i++) counts[i] = NULL;
    for (i = 0; i < entries_len; i++) {
        const struct source_map_entry_s *e = &entries[i];
        const struct file_s *file = e->flist->file;
        unsigned int n = file_number(file) - 1, c = 1;
        if (e->line <= file->lines) {
            if (counts[n] == NULL) {
                new_array(&counts[n], (size_t)file->lines + 1);
                memset(counts[n], 0, ((size_t)file->lines + 1) * sizeof *counts[n]);
            }
            c = ++counts[n][e->line];
        }
        fprintf(f, "al %" PRIx32 " .", (uint32_t)(e->laddr & 0xffffff));
        vice_name(f, file->name);
        fprintf(f, "_%" PRIuline, e->line);
        if (c > 1) fprintf(f, "_%u", c);
        putc('\n', f);
    }
    for (i = 0; i < files_len; i++) free(counts[i]);
    free(counts);
}

void source_map_close(void) {
    size_t i;
    FILE *f;
    if (!source_map_active) return;
    source_map_active = false;

    /* files numbered in order of appearance, callers included */
    for (i = 0; i < entries_len; i++) {
        const struct file_list_s *fl, *caller;
        bool macro;
        file_number(entries[i].flist->file);
        for (fl = entries[i].flist; (caller = file_list_caller(fl, &macro)) != NULL; fl = caller) {
            file_number(caller->file);
        }
    }

    if (arguments.source_map.name != NULL) {
        f = open_output(arguments.source_map.name, &arguments.source_map.name_pos);
        if (f != NULL) {
            write_text(f);
            close_output(f, arguments.source_map.name, &arguments.source_map.name_pos);
        }
    }
    if (arguments.source_map.vice != NULL) {
        f = open_output(arguments.source_map.vice, &arguments.source_map.vice_pos);
        if (f != NULL) {
            write_vice(f);
            close_output(f, arguments.source_map.vice, &arguments.source_map.vice_pos);
        }
    }
    free(entries);
    entries = NULL;
    entries_len = entries_max = 0;
    free(filenum);
    filenum = NULL;
    free((void *)files);
    files = NULL;
    files_len = files_max = 0;
}
