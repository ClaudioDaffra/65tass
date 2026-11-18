;; Operatori < > ` <> >` >< su valori bytes (x"..", pf32): devono dare gli
;; stessi byte del valore intero equivalente. Correzione 65tass in
;; bytesobj.c (calc1): il terzo byte era spostato di 8 bit invece di 16, cosi'
;; > dava byte1|byte2 e ` dava 0. Il bug c'e' anche in 64tass 1.60.3243 e nel
;; trunk r3301.
        * = $1000
b3      = x"563412"                     ; bytes little-endian = $123456
        .byte <b3, >b3, `b3             ;@ 56 34 12 /3
        .byte <$123456, >$123456, `$123456      ;@ 56 34 12 /3
        .word <>b3                      ;@ 56 34 /2
        .word >`b3                      ;@ 34 12 /2
        .word ><b3                      ;@ 34 56 /2
; bytes invertiti (~): come ~$123456 = ...edcba9
        .byte <~b3, >~b3, `~b3          ;@ a9 cb ed /3
; pf32 (65tass): primi 4 byte MBF di 1.24 = 81 1e b8 51
v       = 1.24pf32
        .byte <v, >v, `v, v >> 24       ;@ 81 1e b8 51 /4
        .dword v                        ;@ 81 1e b8 51 /4
; come la macro load_op1_imm32 di cd65_ASMLib/lib/libCD.asm
        lda #>(v >> 16)                 ;@ a9 51 /2
        lda #<v                         ;@ a9 81 /2
        ldy #>v                         ;@ a0 1e /2
        ldx #<(v >> 16)                 ;@ a2 b8 /2
