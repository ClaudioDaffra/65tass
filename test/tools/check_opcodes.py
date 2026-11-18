#!/usr/bin/env python3
"""Controlla le annotazioni ';@' di un sorgente di test contro il listing.

Ogni riga del sorgente puo' terminare con
    ;@ <byte esadecimali attesi> /<lunghezza> [~<cicli>]
I byte indicati sono il prefisso atteso della codifica (opcode e, se
indicati, operandi); /<lunghezza> e' il numero totale di byte; ~<cicli> e'
il testo atteso nella colonna ;Cycles (listing fatto con --list-cycles).
Per le istruzioni con prefisso del 45GS02 si controlla la colonna della
loro ultima riga.

Una riga .endcycles puo' avere ";=cycles <testo>": il testo atteso della
riga ";******  Cycles: <testo>" che il listing scrive per quel blocco (si
confrontano in ordine).

Uso: check_opcodes.py <sorgente.asm> <listing.lst>
Esce con 0 se tutte le righe annotate corrispondono, 1 altrimenti.
"""
import os
import re
import sys

ANN = re.compile(r';@\s*((?:[0-9a-fA-F]{2}\s+)*)/(\d+)(?:\s+~(\S+))?')
LST = re.compile(r'^[.>](?P<addr>[0-9a-fA-F]+)\t(?P<hex>[0-9a-f ]*[0-9a-f])\t')
INC = re.compile(r'^\s*\.include\s+"([^"]+)"', re.I)
TOT = re.compile(r';=cycles\s+(.*\S)')
LTOT = re.compile(r'^;\*{6}  Cycles: (.*\S)')
TAB = 8


def totals_in_source(path):
    """Totali attesi (;=cycles) nel sorgente e nei file inclusi, in ordine."""
    out = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            m = TOT.search(line)
            if m:
                out.append(m.group(1))
            m = INC.match(line)
            if m:
                out.extend(totals_in_source(
                    os.path.join(os.path.dirname(path), m.group(1))))
    return out


def annotations_in_source(path):
    """Righe annotate nel sorgente e nei file che include."""
    count = 0
    with open(path, encoding='utf-8') as f:
        for line in f:
            if ANN.search(line):
                count += 1
            m = INC.match(line)
            if m:
                count += annotations_in_source(
                    os.path.join(os.path.dirname(path), m.group(1)))
    return count


ADDR = re.compile(r'^[.>](?P<addr>[0-9a-fA-F]+)')
HEXB = re.compile(r'^[0-9a-f]{2}$')


def header_columns(lines):
    """Posizioni delle colonne dall'intestazione ';Offset ...' (le tabulazioni
    del formato classico di 64tass vengono espanse a 8)."""
    for line in lines:
        if line.startswith(';Offset'):
            head = line.rstrip('\n').expandtabs(TAB)
            cols = {}
            for name in (';Cycles', ';Hex', ';Monitor', ';Source'):
                if name in head:
                    cols[name] = head.index(name)
            return cols
    return {}


def field(text, cols, name):
    if name not in cols:
        return None
    start = cols[name]
    after = [v for v in cols.values() if v > start]
    end = min(after) if after else len(text) + 1
    return text[start:end]


def parse(line, cols):
    """(indirizzo, byte, sorgente, cicli) di una riga con byte, oppure None."""
    text = line.rstrip('\n').expandtabs(TAB)
    m = ADDR.match(text)
    if not m or ';Hex' not in cols:
        return None
    # dalla colonna Hex fino al sorgente: i byte sono i primi token di due
    # cifre (nel formato classico i dati lunghi sconfinano nel Monitor)
    end = cols.get(';Source', len(text) + 1)
    hexf = []
    for tok in text[cols[';Hex']:end].split():
        if not HEXB.match(tok):
            break
        hexf.append(tok)
    if not hexf:
        return None
    src = text[cols[';Source']:].strip() if ';Source' in cols else ''
    cyc = field(text, cols, ';Cycles')
    if cyc is not None:
        cyc = cyc.strip().strip('[]').strip()
    return m.group('addr'), hexf, src, cyc


def check(src, lst):
    errors = []
    found = 0
    with open(lst, encoding='utf-8') as f:
        lines = f.readlines()
    cols = header_columns(lines)
    pending = None

    def close(p):
        n, addr, got, want, length, cyc_want, cyc_got = p
        if len(got) != length or got[:len(want)] != want:
            errors.append('%s:%d: $%s atteso %s /%d, ottenuto %s /%d'
                          % (lst, n, addr, ' '.join(want), length,
                             ' '.join(got), len(got)))
        if cyc_want is not None and cyc_got != cyc_want:
            errors.append('%s:%d: $%s cicli attesi %s, ottenuti %s'
                          % (lst, n, addr, cyc_want, cyc_got))

    for n, line in enumerate(lines, 1):
        if pending is not None:
            c = parse(line, cols)
            # riga di continuazione (prefissi 45GS02): byte senza sorgente
            if c is not None and c[2] == '' and ';' not in line and \
                    int(c[0], 16) == int(pending[1], 16) + len(pending[2]):
                pending[2].extend(c[1])
                pending[6] = c[3]
                continue
            close(pending)
            pending = None
        ann = ANN.search(line)
        if not ann:
            continue
        c = parse(line, cols)
        if c is None:
            errors.append('%s:%d: riga annotata senza byte: %s'
                          % (lst, n, line.rstrip()))
            continue
        found += 1
        if ann.group(3) is not None and ';Cycles' not in cols:
            errors.append('%s:%d: ~cicli senza colonna ;Cycles (manca --list-cycles)'
                          % (lst, n))
        pending = [n, c[0], list(c[1]),
                   ann.group(1).lower().split(), int(ann.group(2)),
                   ann.group(3), c[3]]
    if pending is not None:
        close(pending)
    expected = annotations_in_source(src)
    if found != expected:
        errors.append('%s: %d righe annotate nel sorgente, %d nel listing'
                      % (src, expected, found))
    want = totals_in_source(src)
    if want:
        got = [m.group(1) for m in (LTOT.match(l) for l in lines) if m]
        if got != want:
            errors.append('%s: totali attesi %s, nel listing %s' % (src, want, got))
        found += len(want)
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
