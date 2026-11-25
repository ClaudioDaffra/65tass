#!/bin/bash
# Suite di test di 65tass (Fase 0 della road map).
#
# Uso:  test/run_tests.sh [--update] [--keep] [--asm <assemblatore>] [filtro]
#   --update   riscrive i file attesi in test/expected (solo dopo un controllo!)
#   --keep     non cancella la cartella temporanea con gli output
#   --asm      assemblatore da provare (predefinito: ../65tass, o $ASM)
#   filtro     esegue solo i test il cui nome contiene il testo (es. cpu/4510)
#
# Ogni sorgente test/src/<gruppo>/<nome>.asm puo' avere in testa:
#   ;; cpu: <opzione>       per esempio --m4510 (predefinito --m65xx)
#   ;; flags: <opzioni>     altre opzioni da riga di comando
#   ;; expect: error        il test deve fallire con gli errori attesi
#   ;; json: yes            anche --error-json (Fase 2): il file deve essere
#                           JSON valido e uguale all'atteso (.json)
#   ;; srcmap: yes          anche --source-map e --source-map-vice (Fase 3):
#                           uguali agli attesi (.map, .vice) e controllati
#                           contro il listing (tools/check_srcmap.py)
# Si confrontano: binario (.bin), listing senza intestazione (.lst),
# messaggi (.err), messaggi JSON (.json) e le annotazioni ';@'
# (tools/check_opcodes.py).
# Con l'assemblatore del progetto c'e' anche il test "cicli/riferimenti":
# la tabella dei cicli (cycles.c) contro le fonti indipendenti di test/ref
# (tools/cycles_dump.c, tools/check_cycles.py).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
ASM=${ASM:-$ROOT/65tass}
UPDATE=0
KEEP=0
FILTER=
while [ $# -gt 0 ]; do
    case "$1" in
    --update) UPDATE=1 ;;
    --keep) KEEP=1 ;;
    --asm) shift; ASM=$1 ;;
    -h|--help) sed -n '2,23p' "$0"; exit 0 ;;
    *) FILTER=$1 ;;
    esac
    shift
done
case "$ASM" in /*) ;; *) ASM=$(cd "$(dirname "$ASM")" && pwd)/$(basename "$ASM") ;; esac
if [ ! -x "$ASM" ]; then
    echo "assemblatore non trovato: $ASM (compilare con make -f makefileLinuxGCC)" >&2
    exit 2
fi
OUT=$(mktemp -d "${TMPDIR:-/tmp}/65tass-test.XXXXXX") || exit 2
[ $KEEP -eq 1 ] || trap 'rm -rf "$OUT"' EXIT

pass=0
fail=0
failed=
cd "$HERE" || exit 2
echo "assemblatore: $ASM ($("$ASM" --version | head -1))"
for src in src/*/*.asm; do
    name=${src#src/}
    name=${name%.asm}
    case "$name" in *"$FILTER"*) ;; *) continue ;; esac
    cpu=$(sed -n 's/^;; cpu: *//p' "$src" | head -1)
    flags=$(sed -n 's/^;; flags: *//p' "$src" | head -1)
    expect=$(sed -n 's/^;; expect: *//p' "$src" | head -1)
    json=$(sed -n 's/^;; json: *//p' "$src" | head -1)
    mkdir -p "$OUT/$(dirname "$name")" "expected/$(dirname "$name")"
    o=$OUT/$name
    srcmap=$(sed -n 's/^;; srcmap: *//p' "$src" | head -1)
    jflags=
    [ "$json" = yes ] && jflags="--error-json=$o.json"
    [ "$srcmap" = yes ] && jflags="$jflags --source-map=$o.map --source-map-vice=$o.vice"
    # shellcheck disable=SC2086
    "$ASM" ${cpu:---m65xx} $flags -q -b -o "$o.bin" -L "$o.lst" -E "$o.err" $jflags "$src"
    rc=$?
    [ -f "$o.lst" ] && sed -n '/^;Offset/,$p' "$o.lst" > "$o.lstn"
    problems=
    if [ "$expect" = error ]; then
        [ $rc -ne 0 ] || problems="$problems [doveva fallire]"
        files="err"
    else
        [ $rc -eq 0 ] || problems="$problems [errore rc=$rc: $(head -3 "$o.err" | tr '\n' ' ')]"
        files="bin lst err"
        # un altro assemblatore (64tass) ha solo il formato classico del
        # listing: si confrontano binario e messaggi
        [ "$ASM" = "$ROOT/65tass" ] || files="bin err"
    fi
    if [ "$json" = yes ]; then
        files="$files json"
        # la versione cambia: nel confronto diventa "*"
        [ -f "$o.json" ] && sed 's/^\({"program":"65tass","version":\)"[^"]*"/\1"*"/' "$o.json" > "$o.jsonn"
        if ! python3 -I -c 'import json,sys; json.load(open(sys.argv[1], encoding="utf-8"))' "$o.json" 2> "$o.jsonchk"; then
            problems="$problems [JSON non valido]"
            tail -1 "$o.jsonchk" | sed 's/^/      /'
        fi
    fi
    if [ "$srcmap" = yes ]; then
        files="$files map vice"
        if [ -f "$o.map" ] && [ -f "$o.lst" ] &&
           ! python3 -I tools/check_srcmap.py "$o.map" "$o.lst" > "$o.smchk"; then
            problems="$problems [source map diversa dal listing]"
            sed 's/^/      /' "$o.smchk" | head -20
        fi
    fi
    for ext in $files; do
        got=$o.$ext
        [ "$ext" = lst ] && got=$o.lstn
        [ "$ext" = json ] && got=$o.jsonn
        want=expected/$name.$ext
        if [ $UPDATE -eq 1 ]; then
            [ -f "$got" ] && cp "$got" "$want"
        elif [ ! -f "$want" ]; then
            problems="$problems [manca $want]"
        elif ! cmp -s "$got" "$want"; then
            problems="$problems [$ext diverso]"
            [ "$ext" = bin ] || diff -u "$want" "$got" | head -20 | sed 's/^/      /'
        fi
    done
    if [ -z "$expect" ] && [ -f "$o.lst" ] && grep -q ';@' "$src"; then
        if ! python3 -I tools/check_opcodes.py "$src" "$o.lst" > "$o.chk"; then
            problems="$problems [opcode diversi dalle annotazioni]"
            sed 's/^/      /' "$o.chk" | head -20
        fi
    fi
    if [ -z "$problems" ]; then
        pass=$((pass + 1))
        printf '  ok    %s\n' "$name"
    else
        fail=$((fail + 1))
        failed="$failed $name"
        printf '  FALLITO %s%s\n' "$name" "$problems"
    fi
done
name=cicli/riferimenti
case "$name" in *"$FILTER"*) dorefs=1 ;; *) dorefs=0 ;; esac
if [ $dorefs -eq 1 ] && [ "$ASM" = "$ROOT/65tass" ]; then
    if [ -f "$ROOT/cycles.o" ] && [ -f "$ROOT/opcodes.o" ] &&
       cc -I"$ROOT" -o "$OUT/cycles_dump" tools/cycles_dump.c "$ROOT/cycles.o" "$ROOT/opcodes.o" &&
       python3 -I tools/check_cycles.py "$OUT/cycles_dump" "$HERE" > "$OUT/cycles.chk"; then
        pass=$((pass + 1))
        printf '  ok    %s (%s)\n' "$name" "$(grep -c ': [0-9]* \(opcode\|righe\)' "$OUT/cycles.chk") fonti"
    else
        fail=$((fail + 1))
        failed="$failed $name"
        printf '  FALLITO %s\n' "$name"
        [ -f "$OUT/cycles.chk" ] && sed 's/^/      /' "$OUT/cycles.chk" | head -30
    fi
fi
[ $UPDATE -eq 1 ] && echo "attesi aggiornati in $HERE/expected"
[ $KEEP -eq 1 ] && echo "output in $OUT"
echo "risultato: $pass passati, $fail falliti${failed:+ (}${failed# }${failed:+)}"
[ $fail -eq 0 ]
