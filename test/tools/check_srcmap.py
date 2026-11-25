#!/usr/bin/env python3
"""Controlla una source map di 65tass (--source-map) contro il listing.

Il listing e la source map vengono dalla stessa passata, ma da codice
diverso: il listing scrive offset, byte e testo della riga elaborata;
la source map scrive offset, lunghezza e file:riga. Qui si verifica che:
  - ogni record corrisponda, nell'ordine, a una riga del listing con lo
    stesso offset (;Offset), lo stesso indirizzo (;PC se c'e', altrimenti
    uguale all'offset) e lo stesso numero di byte;
  - la riga file:riga letta dal file sorgente sia il testo della colonna
    ;Source (spazi normalizzati; i parametri delle macro \\1 \\nome @1
    valgono qualsiasi testo);
  - i chiamanti "m" siano righe che chiamano una macro (# o . davanti a un
    nome, o una .dstruct/.dunion) e i chiamanti "i" righe .include o
    .binclude;
  - ogni riga del listing con byte abbia il suo record, tranne quelle con
    ";nomap" nel sorgente (.virtual, definizioni di .struct, che non vanno
    nell'output).

Uso: check_srcmap.py <mappa> <listing.lst>
Esce con 0 se tutto corrisponde, 1 altrimenti.
"""
import re
import sys

ADDR = re.compile(r'^[.>](?P<addr>[0-9a-fA-F]+)')
HEXB = re.compile(r'^[0-9a-f]{2}$')
REC = re.compile(r'^(?P<addr>[0-9a-f]+) (?P<off>[0-9a-f]+) (?P<len>\d+) '
                 r'(?P<file>\d+):(?P<line>\d+)(?P<callers>(?: [mi]\d+:\d+)*)$')
CALLER = re.compile(r' (?P<kind>[mi])(?P<file>\d+):(?P<line>\d+)')
PARAM = re.compile(r'\\\\(?:\d|[A-Za-z_]\w*|\{[^}]*\})|@\d')
INCLUDE = re.compile(r'^\s*(?:[A-Za-z_]\w*\s+)?\.b?include\b', re.I)
MCALL = re.compile(r'(?:^|\s)(?:#\w|\.\w+\s*$|\.\w+\s+[^;]|\.dstruct\b|\.dunion\b)', re.I)


def norm(text):
    return ' '.join(text.split())


def source_regex(line):
    """Regex del testo atteso: la riga sorgente con i parametri liberi."""
    line = norm(line)
    out = []
    pos = 0
    esc = re.escape(line)
    for m in PARAM.finditer(esc):
        out.append(esc[pos:m.start()])
        out.append('.+?')
        pos = m.end()
    out.append(esc[pos:])
    return re.compile('^' + ''.join(out) + '$')


def read_map(path):
    files = {}
    records = []
    errors = []
    with open(path, encoding='utf-8') as f:
        for n, line in enumerate(f, 1):
            line = line.rstrip('\n')
            if line.startswith(';') or not line:
                continue
            if line.startswith('F '):
                num, name = line[2:].split(' ', 1)
                files[int(num)] = name
                continue
            m = REC.match(line)
            if not m:
                errors.append('%s:%d: record non valido: %s' % (path, n, line))
                continue
            callers = [(c.group('kind'), int(c.group('file')), int(c.group('line')))
                       for c in CALLER.finditer(m.group('callers'))]
            records.append((n, int(m.group('addr'), 16), int(m.group('off'), 16),
                            int(m.group('len')), int(m.group('file')),
                            int(m.group('line')), callers))
    return files, records, errors


def columns(lines):
    for line in lines:
        if line.startswith(';Offset'):
            head = line.rstrip('\n')
            return {name: head.index(name) for name in
                    (';PC', ';Cycles', ';Hex', ';Monitor', ';Source') if name in head}
    return {}


def field(text, cols, name):
    start = cols[name]
    after = [v for v in cols.values() if v > start]
    return text[start:min(after) if after else len(text)]


def statements(path):
    """Righe del listing con byte: (riga, offset, pc, byte, sorgente).
    Le righe di continuazione (dati lunghi) si uniscono alla precedente."""
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()
    cols = columns(lines)
    out = []
    for n, line in enumerate(lines, 1):
        text = line.rstrip('\n')
        m = ADDR.match(text)
        if not m or ';Hex' not in cols:
            continue
        nbytes = 0
        for tok in field(text, cols, ';Hex').split():
            if not HEXB.match(tok):
                break
            nbytes += 1
        if nbytes == 0:
            continue
        off = int(m.group('addr'), 16)
        src = text[cols[';Source']:] if ';Source' in cols and len(text) > cols[';Source'] else ''
        pc = field(text, cols, ';PC').strip() if ';PC' in cols else ''
        pc = int(pc, 16) if pc else None
        if out and not src.strip() and off == out[-1][1] + out[-1][3]:
            last = out[-1]
            out[-1] = (last[0], last[1], last[2], last[3] + nbytes, last[4])
            continue
        out.append((n, off, pc, nbytes, src))
    return out


def check(mpath, lpath):
    files, records, errors = read_map(mpath)
    sources = {}

    def src_line(num, line):
        name = files.get(num)
        if name is None:
            return None
        if name not in sources:
            try:
                with open(name, encoding='utf-8') as f:
                    sources[name] = f.read().split('\n')
            except OSError as e:
                errors.append('%s: %s' % (name, e))
                sources[name] = []
        lines = sources[name]
        return lines[line - 1] if 0 < line <= len(lines) else None

    stmts = statements(lpath)
    ri = 0
    for (n, off, pc, nbytes, src) in stmts:
        if ri < len(records) and records[ri][2] == off:
            rn, addr, roff, length, fnum, line, callers = records[ri]
            ri += 1
            want_addr = pc if pc is not None else off
            if addr != want_addr:
                errors.append('%s:%d: indirizzo $%04x, nel listing $%04x (riga %d)'
                              % (mpath, rn, addr, want_addr, n))
            if length != nbytes:
                errors.append('%s:%d: %d byte, nel listing %d (riga %d)'
                              % (mpath, rn, length, nbytes, n))
            text = src_line(fnum, line)
            if text is None:
                errors.append('%s:%d: riga %d:%d inesistente' % (mpath, rn, fnum, line))
            elif not source_regex(text).match(norm(src)):
                errors.append('%s:%d: %s:%d e\' "%s", nel listing (riga %d) "%s"'
                              % (mpath, rn, files[fnum], line, norm(text), n, norm(src)))
            for kind, cf, cl in callers:
                ctext = src_line(cf, cl)
                if ctext is None:
                    errors.append('%s:%d: chiamante %d:%d inesistente' % (mpath, rn, cf, cl))
                    continue
                code = ctext.split(';', 1)[0]
                if kind == 'i' and not INCLUDE.match(code):
                    errors.append('%s:%d: i%d:%d non e\' un .include: "%s"'
                                  % (mpath, rn, cf, cl, norm(ctext)))
                if kind == 'm' and (INCLUDE.match(code) or not MCALL.search(code)):
                    errors.append('%s:%d: m%d:%d non e\' una chiamata di macro: "%s"'
                                  % (mpath, rn, cf, cl, norm(ctext)))
        elif ';nomap' not in src:
            errors.append('%s:%d: nessun record per $%04x "%s"'
                          % (lpath, n, off, norm(src)))
    for r in records[ri:]:
        errors.append('%s:%d: record senza riga nel listing ($%04x)' % (mpath, r[0], r[2]))
    return len(records), errors


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip())
        return 2
    found, errors = check(sys.argv[1], sys.argv[2])
    for e in errors:
        print(e)
    print('%s: %d record controllati, %d errori' % (sys.argv[1], found, len(errors)))
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
