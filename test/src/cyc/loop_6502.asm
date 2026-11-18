;; cpu: --m65xx
;; flags: --list-cycles
;; Fase 1, esempio della road map: loop ldx/inx/cpx/bne e branch su NMOS.
;; Cicli attesi (~) dalle tabelle MCS6500: branch 2, +1 se salta, +1 se la
;; destinazione e' su un'altra pagina; letture indicizzate +1 se cambia pagina.
        * = $1000
        ldx #$00                ;@ a2 00 /2 ~2
loop    inx                     ;@ e8 /1 ~2
        cpx #$10                ;@ e0 10 /2 ~2
        bne loop                ;@ d0 fb /2 ~2/3
        lda $1234,x             ;@ bd 34 12 /3 ~4-5
        sta $1234,x             ;@ 9d 34 12 /3 ~5
        lda ($12),y             ;@ b1 12 /2 ~5-6
        jmp ($1234)             ;@ 6c 34 12 /3 ~5
        jsr $1234               ;@ 20 34 12 /3 ~6
        rts                     ;@ 60 /1 ~6
; branch all'indietro nella stessa pagina: da $10ff (dopo l'istruzione) a $10f0
        * = $10f0
back    nop                     ;@ ea /1 ~2
        * = $10fd
        bne back                ;@ d0 f1 /2 ~2/3
; branch in avanti che cambia pagina: da $20ff a $2110
        * = $20fd
        bne $2110               ;@ d0 11 /2 ~2/4p
; branch all'indietro da $2102 a $20f0: cambia pagina
        * = $20f0
        nop                     ;@ ea /1 ~2
        * = $2100
        beq $20f0               ;@ f0 ee /2 ~2/4p
