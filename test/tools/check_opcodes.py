#!/usr/bin/env python3
"""Controlla le annotazioni ';@' di un sorgente di test contro il listing.

Ogni riga del sorgente puo' terminare con
    ;@ <byte esadecimali attesi> /<lunghezza>
I byte indicati sono il prefisso atteso della codifica (opcode e, se
indicati, operandi); /<lunghezza> e' il numero totale di byte.

Uso: check_opcodes.py <sorgente.asm> <listing.lst>
Esce con 0 se tutte le righe annotate corrispondono, 1 altrimenti.
"""
import re
import sys

ANN = re.compile(r';@\s*((?:[0-9a-fA-F]{2}\s+)*)/(\d+)')
LST = re.compile(r'^[.>](?P<addr>[0-9a-fA-F]+)\t(?P<hex>[0-9a-f ]*[0-9a-f])\t')


def annotations_in_source(path):
    count = 0
    with open(path, encoding='utf-8') as f:
        for line in f:
            if ANN.search(line):
                count += 1
    return count


def is_continuation(line):
    """Riga di soli byte (e disassemblato) senza sorgente: il listing spezza
    cosi' le istruzioni con prefisso (45GS02: 42 42 ..., EA ...)."""
    m = LST.match(line)
    if not m or ';' in line:
        return None
    rest = [x for x in line.rstrip('\n').split('\t')[2:] if x != '']
    if len(rest) > 1 or (rest and rest[0].startswith(' ')):
        return None
    return m


def check(src, lst):
    errors = []
    found = 0
    with open(lst, encoding='utf-8') as f:
        lines = f.readlines()
    pending = None

    def close(p):
        n, addr, got, want, length = p
        if len(got) != length or got[:len(want)] != want:
            errors.append('%s:%d: $%s atteso %s /%d, ottenuto %s /%d'
                          % (lst, n, addr, ' '.join(want), length,
                             ' '.join(got), len(got)))

    for n, line in enumerate(lines, 1):
        if pending is not None:
            c = is_continuation(line)
            if c is not None and int(c.group('addr'), 16) == \
                    int(pending[1], 16) + len(pending[2]):
                pending[2].extend(c.group('hex').split())
                continue
            close(pending)
            pending = None
        ann = ANN.search(line)
        if not ann:
            continue
        m = LST.match(line)
        if not m:
            errors.append('%s:%d: riga annotata senza byte: %s'
                          % (lst, n, line.rstrip()))
            continue
        found += 1
        pending = [n, m.group('addr'), m.group('hex').split(),
                   ann.group(1).lower().split(), int(ann.group(2))]
    if pending is not None:
        close(pending)
    expected = annotations_in_source(src)
    if found != expected:
        errors.append('%s: %d righe annotate nel sorgente, %d nel listing'
                      % (src, expected, found))
    return found, errors


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip())
        return 2
    found, errors = check(sys.argv[1], sys.argv[2])
    for e in errors:
        print(e)
    print('%s: %d istruzioni controllate, %d errori'
          % (sys.argv[1], found, len(errors)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
