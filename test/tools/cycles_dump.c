/* Stampa la tabella dei cicli di 65tass (cycles.c) per una CPU, un opcode
   per riga: "opcode testo". Serve ai controlli della suite di test.
   Compilazione (dalla radice, dopo make):
     cc -I. -o <out> test/tools/cycles_dump.c cycles.o opcodes.o
   Uso: cycles_dump <cpu> [m16] [x16] [dl]
   cpu: 6502 6502i 65dtv02 65c02 r65c02 w65c02 65el02 65816 65ce02 4510 45gs02
   Il branch viene calcolato verso l'istruzione seguente (nessun cambio di
   pagina): un branch condizionato appare come "2/3". */
#include <stdio.h>
#include <string.h>
#include "opcodes.h"
#include "cycles.h"

bool longaccu, longindex;
uint32_t dpage;

int main(int argc, char *argv[]) {
    static const struct { const char *name; const struct cpu_s *cpu; } cpus[] = {
        {"6502", &c6502}, {"6502i", &c6502i}, {"65dtv02", &c65dtv02},
        {"65c02", &c65c02}, {"r65c02", &r65c02}, {"w65c02", &w65c02},
        {"65el02", &c65el02}, {"65816", &w65816}, {"65ce02", &c65ce02},
        {"4510", &c4510}, {"45gs02", &c45gs02}
    };
    const struct cpu_s *cpu = NULL;
    unsigned int i;
    int a;
    char buf[CYCLES_TEXT_LEN];
    if (argc < 2) return 2;
    for (i = 0; i < sizeof cpus / sizeof cpus[0]; i++) {
        if (strcmp(argv[1], cpus[i].name) == 0) cpu = cpus[i].cpu;
    }
    if (cpu == NULL) { fprintf(stderr, "cpu sconosciuta: %s\n", argv[1]); return 2; }
    for (a = 2; a < argc; a++) {
        if (strcmp(argv[a], "m16") == 0) longaccu = true;
        else if (strcmp(argv[a], "x16") == 0) longindex = true;
        else if (strcmp(argv[a], "dl") == 0) dpage = 0x1201;
    }
    for (i = 0; i < 256; i++) {
        int ln = ((i & 0x1f) == 0x10) ? 1 : (((i & 0x0f) == 0x0f) ? 2 : 1);
        cycles_text(buf, cpu, i, 0, ln, 0x1000);
        printf("%02x %s\n", i, buf);
    }
    return 0;
}
