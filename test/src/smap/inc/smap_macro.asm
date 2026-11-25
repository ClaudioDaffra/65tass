; incluso da smap/macros.asm: una macro definita qui e chiamata dal
; sorgente principale. La catena dei suoi byte e' m (la chiamata), non i.
colore  .macro
        lda #\1
        sta $d021
        .endm
