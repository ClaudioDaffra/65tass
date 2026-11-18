#!/usr/bin/env python3
"""Confronta la tabella dei cicli di 65tass con fonti indipendenti.

Uso: check_cycles.py <cycles_dump> <cartella test>

  1. NMOS 6502 (anche illegali): test/ref/nmos_cycles_cd65.txt, estratta
     dalla tabella di cd65 (illegali verificati da cd65 con SingleStepTests).
  2. 65CE02 / 4510 / 45GS02: regole per gruppi di istruzioni scritte dalla
     Commodore 65 System Specification 2.3.7.5 (non per opcode), applicate a
     test/src/cpu/4510.asm (mnemonico + modo di indirizzamento).
  3. Altre CPU: righe "opcode cicli" in test/ref/cycles_<cpu>.txt
     (valori presi a mano dai data sheet WDC/Rockwell).
"""
import os
import re
import subprocess
import sys


def dump(tool, cpu, *opts):
    out = subprocess.run([tool, cpu] + list(opts), capture_output=True,
                         text=True, check=True).stdout
    return dict((int(l.split()[0], 16), l.split()[1]) for l in out.splitlines())


def text_range(t):
    """'4' -> (4,4); '4-5' -> (4,5); '2/3' -> (2,4) (branch generico)."""
    if '/' in t:
        nt = int(t.split('/')[0])
        return (nt, nt + 2)
    if '-' in t:
        a, b = t.split('-')
        return (int(a), int(b))
    return (int(t), int(t))


def check_nmos(tool, ref, errors):
    tab = dump(tool, '6502i')
    n = 0
    for line in open(ref, encoding='utf-8'):
        if line.startswith('#') or not line.strip():
            continue
        op, name, lo, hi, kind, halt = line.split()
        op, lo, hi = int(op, 16), int(lo), int(hi)
        got = tab[op]
        n += 1
        if halt == '1':
            if got != '-':
                errors.append('6502i $%02x %s: atteso - (halt), ottenuto %s' % (op, name, got))
            continue
        if got in ('?', '-', '+') or text_range(got) != (lo, hi):
            errors.append('6502i $%02x %s: atteso %d-%d, ottenuto %s' % (op, name, lo, hi, got))
    return n


# Regole del capitolo 2.3.7.5 della C65 System Specification (per gruppi).
ALU = {'adc', 'and', 'cmp', 'eor', 'lda', 'ora', 'sbc', 'cpx', 'cpy', 'cpz',
       'ldx', 'ldy', 'ldz'}
STORE = {'sta', 'stx', 'sty', 'stz'}
SHIFT = {'asl', 'lsr', 'rol', 'ror', 'asr', 'tsb', 'trb'}
IMPL1 = {'clc', 'cld', 'clv', 'sec', 'sed', 'tax', 'tay', 'taz', 'tad', 'tab',
         'txa', 'tya', 'tza', 'tda', 'tba', 'tsx', 'txs', 'tsy', 'tys',
         'inx', 'iny', 'inz', 'dex', 'dey', 'dez', 'nop', 'eom'}
IMPL2 = {'cli', 'cle', 'sei', 'see', 'neg'}


def ce02_rule(mn, op):
    """Cicli attesi da mnemonico e operando (sintassi di 65tass)."""
    op = op.replace(' ', '')
    imm = op.startswith('#')
    ind = op.startswith('(')
    bp = re.match(r'^\$[0-9a-f]{2}(,[xy])?$', op) is not None
    ab = re.match(r'^\$[0-9a-f]{4}(,[xy])?$', op) is not None
    if mn in ALU:
        if imm: return 2
        if op.endswith(',s),y'): return 6
        if ind: return 5
        if bp: return 3
        if ab: return 4
    if mn in STORE:
        if op.endswith(',s),y'): return 6
        if ind: return 5
        if bp: return 3
        if ab: return 4
    if mn in SHIFT:
        if op in ('', 'a'): return 2 if mn == 'asr' else 1
        if bp: return 4
        if ab: return 5
    if mn in ('inc', 'dec'):
        if op in ('', 'a'): return 1
        if bp: return 4
        if ab: return 5
    if mn in ('inw', 'dew'): return 6
    if mn == 'asw': return 7
    if mn in ('row', 'rlw'): return 6
    if mn == 'bit':
        if imm: return 2
        if bp: return 4
        if ab: return 5
    if mn in ('bpl', 'bmi', 'bvc', 'bvs', 'bcc', 'bcs', 'bne', 'beq', 'bra', 'bru'):
        return None  # dipende dalla lunghezza: controllato a parte
    if mn == 'bsr': return 5
    if mn in ('bbr', 'bbs', 'rmb', 'smb'): return 4
    if mn == 'jmp': return 3 if not ind else 5
    if mn == 'jsr': return 5 if not ind else 7
    if mn == 'rts': return 7 if imm else 4
    if mn == 'rtn': return 7
    if mn == 'rti': return 5
    if mn == 'brk': return 7
    if mn in ('pha', 'php', 'phx', 'phy', 'phz', 'pla', 'plp', 'plx', 'ply', 'plz'):
        return 3
    if mn == 'phw': return 5 if imm else 7
    if mn in IMPL1: return 1
    if mn in IMPL2: return 2
    if mn == 'map': return 4
    return None


def check_ce02(tool, asm, errors):
    tab = {c: dump(tool, c) for c in ('65ce02', '4510', '45gs02')}
    n = 0
    seen = set()
    for line in open(asm, encoding='utf-8'):
        m = re.match(r'^\s+(\w+)\s*([^;]*?)\s*;@\s*([0-9a-f]{2})[^/]*/(\d)', line)
        if not m:
            continue
        mn, operand, op, length = m.group(1), m.group(2).lower(), int(m.group(3), 16), int(m.group(4))
        if mn in ('bpl', 'bmi', 'bvc', 'bvs', 'bcc', 'bcs', 'bne', 'beq', 'bra'):
            want = 2 if length == 2 else 3   # byte / word relative
        else:
            want = ce02_rule(mn, operand)
        if want is None:
            errors.append('4510 $%02x %s %s: nessuna regola' % (op, mn, operand))
            continue
        for cpu in ('65ce02', '4510', '45gs02'):
            if cpu == '65ce02' and mn == 'map':
                continue
            got = tab[cpu][op]
            if got != str(want):
                errors.append('%s $%02x %s %s: atteso %d, ottenuto %s' % (cpu, op, mn, operand, want, got))
        seen.add(op)
        n += 1
    if len(seen) != 256:
        errors.append('4510: controllati %d opcode su 256' % len(seen))
    return n


def check_ref(tool, path, errors):
    name = os.path.basename(path)[len('cycles_'):-4]
    parts = name.split('_')
    tab = dump(tool, parts[0], *parts[1:])
    n = 0
    for line in open(path, encoding='utf-8'):
        line = line.split('#')[0].strip()
        if not line:
            continue
        op, want = line.split()[:2]
        got = tab[int(op, 16)]
        n += 1
        if got != want:
            errors.append('%s $%s: atteso %s, ottenuto %s' % (name, op, want, got))
    return n


def main():
    tool, root = sys.argv[1], sys.argv[2]
    errors = []
    n = check_nmos(tool, os.path.join(root, 'ref', 'nmos_cycles_cd65.txt'), errors)
    print('NMOS 6502 contro cd65: %d opcode' % n)
    n = check_ce02(tool, os.path.join(root, 'src', 'cpu', '4510.asm'), errors)
    print('65CE02/4510/45GS02 contro le regole della C65 System Specification: %d righe' % n)
    for f in sorted(os.listdir(os.path.join(root, 'ref'))):
        if f.startswith('cycles_') and f.endswith('.txt'):
            n = check_ref(tool, os.path.join(root, 'ref', f), errors)
            print('%s: %d opcode' % (f, n))
    for e in errors:
        print('  ' + e)
    print('errori: %d' % len(errors))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
