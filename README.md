
# 65tass

65tass is a multi pass optimizing macro assembler for the 65xx series of
processors.

## Installation

Executables for released versions are not difficult to come by.

On Linux there's a good chance it is already included in the package manager of
the distribution. It's also in ports for the BSDs. For Mac it's in the ports or
brew. If the packaged version is not up to date compilation from source is
always an option.

For Windows 65tass is packaged in MSYS2 for a variety of target architectures
including Aarch64. For old versions of Windows (down to XP running on a 686)
Sourceforge hosts binaries. Manual compilation for even older Windows versions
or 32 bit DOS should be possible for those who dare.

## Compilation

The only dependencies are a working C compiler and Make.

The Makefile was written to support both GNU Make and BSD Make.

GCC or Clang can compile it without a problem. Other C compilers may work but
compile flags might need adjustments.

The project provides platform-specific makefiles:

- `makefileLinuxGCC` builds a native `65tass` binary with GCC or Clang. For
  example: `make -f makefileLinuxGCC`. On macOS, `CPPFLAGS="-D_XOPEN_SOURCE"`
  may be needed.
- `makefileWindowsMingw` cross-compiles `65tass.exe` with MinGW; adjust `CC`
  if the compiler has a different name.
- `makefileWindowsCL` builds `65tass.exe` natively with Microsoft C (`nmake
  -f makefileWindowsCL`).

The MinGW and MSVC makefiles produce Windows binaries; the MSVC makefile is
included for native Windows builds.

### Makefile targets

If no target is given it just compiles the binary. Other useful targets:

- clean: deletes all objects
- distclean: delete the binary as well

These targets assume that "prefix" is set otherwise the destination will be
/usr/local. It's recommended to check what these targets actually do to avoid
surprises.

- install-man: installs the man file man1
- install-doc: installs the reference manual to doc dir
- install: install everything, with symbols
- install-strip: install everything, without symbols
- uninstall: remove what was installed

## Usage

This document would become way too long if I'd go into details so please check
the reference manual!

As it's a command line assembler the source files are edited in a text editor.
Sample syntax highlight configuration files are included for these editors:

- Crimson editor
- Gedit
- Jedit
- Kate
- Mcedit
- Notepad++
- PSPad
- Sublime
- VIM

I saw that there exists a VSCode extension as well. Last time I've checked it
didn't display warning messages and so may need manual tweaking at source
level.

Relaunch64 directly supports 65tass and can even do code completion for simple
projects.

65tass is normally used as a part of a build system. For example it's invoked
from a Makefile, script or batch file. Some text editors may be configured to
invoke binary for compilation which might be handy.

Diagnostic messages are printed to console by default but may be saved to a
file. There are various output formats for the results.

## 65tass additions

65tass adds signed and unsigned aliases for the standard integer data
directives: `.u8`/`.s8`, `.u16`/`.s16`, `.u24`/`.s24`, and `.u32`/`.s32`.
They are aliases for `.byte`/`.char`, `.word`/`.sint`, `.long`/`.lint`, and
`.dword`/`.dint`, respectively.

For floating-point output, `.f88`, `.f124`, `.f168`, and `.f248` write signed
8.8, 12.4, 16.8, and 24.8 fixed-point values, while `.f32` writes a 32-bit
IEEE-754 single-precision value. A decimal literal can instead carry a
`pf88`, `pf124`, `pf168`, `pf248`, or `pf32` suffix; it evaluates to the
corresponding bytes and can be stored with the matching integer directive.
`pf32` uses the first four bytes of the five-byte Microsoft MBF/F40 encoding.

The command-line conversion helpers `-f32tof40`/`-f64tof40` and
`-f32tof8.8`, `-f32tof12.4`, `-f32tof16.8`, `-f32tof24.8` (with analogous
`-f64...` forms) print fixed-point or MBF/F40 representations for a supplied
number.

## Listing layout

The 65tass listing uses only spaces and fixed columns, so it looks the same in
every editor: offset, cycles (with `--list-cycles`), hex bytes (8 data bytes
fit), monitor, source. `--list-classic` gives back the 64tass layout with tabs.

    ;Offset  ;Cycles    ;Hex                     ;Monitor          ;Source
    .1000    [ 2     ]  a2 00                    ldx #$00                  ldx #$00
    .1002    [ 2     ]  e8                       inx               loop    inx
    .1005    [ 2/3   ]  d0 fb                    bne $1002                 bne loop
    >0836               43 49 41 4f 20 44 41 4c                            .text "CIAO DAL 6502",13

## CPU cycles in the listing

`--list-cycles` adds a `;Cycles` column to the listing (off by default). It
covers all supported CPUs: NMOS 6502 with illegal opcodes (C64, VIC-20, C128,
Plus/4, C16), 65DTV02, 65C02/R65C02/W65C02, 65816 (following `.as/.al`,
`.xs/.xl` and `.dpage`), 65CE02 and 4510 (Commodore 65, from the C65 System
Specification). Branches show `not taken/taken`, with `p` when the taken
branch crosses a page; `?` marks opcodes without documented timing (45GS02
prefixed instructions, 65EL02 extensions).

    65tass --m4510 --list-cycles -L list.txt a.asm

`.cycles [<iterations>]` ... `.endcycles` writes the total of a block into the
listing. The iteration count is the explicit hypothesis: the loop branch at
the end of the block counts taken `iterations-1` times and not taken once.

            .cycles 16
    loop    inx
            cpx #$10
            bne loop
            .endcycles      ; listing: ;******  Cycles: 111 (16 iterations, ...)

With a label (`name .endcycles`) the total is a constant tuple
`(minimum, maximum)` that the source can check, for example
`.cerror name[1] > 63, "too slow"`.

## Diagnostics in JSON

`--error-json=<file>` writes the error and warning messages in JSON as well
(`-` for the standard output), for editors, language servers and CI. The text
messages do not change. One object, one diagnostic per line:

    65tass -Wall --error-json=errors.json a.asm

    {"program":"65tass","version":"1.60.3243+","format":1,"diagnostics":[
    {"severity":"warning","name":"-Wleading-zeros","message":"leading zeros ignored","file":"a.asm","line":12,"column":13,"source":"        lda 0001","included_from":[],"notes":[]}
    ],"errors":0,"warnings":1}

`name` is the diagnostic option (`-Wshadow`...) or null, `column` counts
characters from 1, `included_from` is the include chain and `notes` the notes
of the message. `--error-json-append` appends, `--no-error-json` turns it off.
See README.txt for the details.

## Tests

`test/` holds a regression suite: one source per CPU (all 256 opcodes for the
CSG 4510, checked against the Commodore 65 System Specification opcode table),
directive tests and expected-error cases, with the expected binaries, listings
and messages. Build first, then run it from the project root:

    make -f makefileLinuxGCC
    bash test/run_tests.sh

See `test/LEGGIMI.txt` for the options and the file format, and
`roadMap/fase0_rapporto.txt` for the analysis behind the suite.

## Support

Bug reports and feature requests:

https://sourceforge.net/p/tass64/bugs/
https://sourceforge.net/p/tass64/feature-requests/

The current reference manual is available in README.txt and README.html. For the
last release it can be read online at:

https://tass64.sourceforge.net/

## Contributing

Development is done at:

https://sourceforge.net/p/tass64

SVN repository:

https://svn.code.sf.net/p/tass64/code/trunk

## License

GNU GENERAL PUBLIC LICENSE Version 2, June 1991

## Project status

It is actively maintained. Release frequency might vary and might be too long
for some. If so please try to compile the current repository version. It might
have bug fixes already but on the other hand it might have new problems.

