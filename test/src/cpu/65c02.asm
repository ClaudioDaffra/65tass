;; cpu: --m65c02
;; CMOS 65C02 (-c): gli opcode in piu' rispetto al 6502.
;; Fonte: "Additional 65C02 opcodes" del manuale.
        * = $1000

        tsb $12                 ;@ 04 12 /2
        tsb $1234               ;@ 0c 34 12 /3
        ora ($12)               ;@ 12 12 /2
        trb $12                 ;@ 14 12 /2
        inc a                   ;@ 1a /1
        trb $1234               ;@ 1c 34 12 /3
        and ($12)               ;@ 32 12 /2
        bit $12,x               ;@ 34 12 /2
        dec a                   ;@ 3a /1
        bit $1234,x             ;@ 3c 34 12 /3
        eor ($12)               ;@ 52 12 /2
        phy                     ;@ 5a /1
        stz $12                 ;@ 64 12 /2   scrive zero
        adc ($12)               ;@ 72 12 /2
        stz $12,x               ;@ 74 12 /2
        ply                     ;@ 7a /1
        jmp ($1234,x)           ;@ 7c 34 12 /3
        bra *                   ;@ 80 fe /2
        bit #$12                ;@ 89 12 /2
        sta ($12)               ;@ 92 12 /2
        stz $1234               ;@ 9c 34 12 /3
        stz $1234,x             ;@ 9e 34 12 /3
        lda ($12)               ;@ b2 12 /2
        cmp ($12)               ;@ d2 12 /2
        phx                     ;@ da /1
        sbc ($12)               ;@ f2 12 /2
        plx                     ;@ fa /1
; alias
        ina                     ;@ 1a /1
        dea                     ;@ 3a /1
        clr $12                 ;@ 64 12 /2
