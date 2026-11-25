;; srcmap: yes
;; Fase 3: macro annidate su tre livelli, con parametri, una macro definita
;; in un file incluso, .rept dentro una macro e .dstruct. I byte di una riga
;; di macro puntano alla riga del corpo, poi ai chiamanti (m) fino al
;; sorgente principale.
        * = $1000
        .include "inc/smap_macro.asm"   ; definisce colore (nessun byte)

livello3 .macro
        inx                             ; $1004: 1:10 m1:14 m1:18 m1:23
        .endm
livello2 .macro
        lda #\1
        #livello3
        .endm
livello1 .macro valore
        ldx #0
        #livello2 \valore
        #livello2 \valore+1
        sta $d020
        .endm

        #livello1 5
ripeti  .macro
        .rept \1
        dey
        .endrept
        .endm
        #ripeti 3
        #colore 2
punto   .struct                         ;nomap
x       .byte 9                         ;nomap
y       .word $1234                     ;nomap
        .ends                           ;nomap
        .dstruct punto
        rts
