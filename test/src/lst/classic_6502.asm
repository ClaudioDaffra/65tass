;; cpu: --m65xx
;; flags: --list-classic 
;; Formato classico di 64tass (--list-classic): stesso listing di prima del
;; formato a spazi. Corpo copiato da cpu/6502.asm.
        * = $1000

        brk                     ;@ 00 /1
        ora ($12,x)             ;@ 01 12 /2
        ora $12                 ;@ 05 12 /2
        asl $12                 ;@ 06 12 /2
        php                     ;@ 08 /1
        ora #$12                ;@ 09 12 /2
        asl a                   ;@ 0a /1
        ora $1234               ;@ 0d 34 12 /3
        asl $1234               ;@ 0e 34 12 /3
        bpl *                   ;@ 10 fe /2
        ora ($12),y             ;@ 11 12 /2
        ora $12,x               ;@ 15 12 /2
        asl $12,x               ;@ 16 12 /2
        clc                     ;@ 18 /1
        ora $1234,y             ;@ 19 34 12 /3
        ora $1234,x             ;@ 1d 34 12 /3
        asl $1234,x             ;@ 1e 34 12 /3
        jsr $1234               ;@ 20 34 12 /3
        and ($12,x)             ;@ 21 12 /2
        bit $12                 ;@ 24 12 /2
        and $12                 ;@ 25 12 /2
        rol $12                 ;@ 26 12 /2
        plp                     ;@ 28 /1
        and #$12                ;@ 29 12 /2
        rol a                   ;@ 2a /1
        bit $1234               ;@ 2c 34 12 /3
        and $1234               ;@ 2d 34 12 /3
        rol $1234               ;@ 2e 34 12 /3
        bmi *                   ;@ 30 fe /2
        and ($12),y             ;@ 31 12 /2
        and $12,x               ;@ 35 12 /2
        rol $12,x               ;@ 36 12 /2
        sec                     ;@ 38 /1
        and $1234,y             ;@ 39 34 12 /3
        and $1234,x             ;@ 3d 34 12 /3
        rol $1234,x             ;@ 3e 34 12 /3
        rti                     ;@ 40 /1
        eor ($12,x)             ;@ 41 12 /2
        eor $12                 ;@ 45 12 /2
        lsr $12                 ;@ 46 12 /2
        pha                     ;@ 48 /1
        eor #$12                ;@ 49 12 /2
        lsr a                   ;@ 4a /1
        jmp $1234               ;@ 4c 34 12 /3
        eor $1234               ;@ 4d 34 12 /3
        lsr $1234               ;@ 4e 34 12 /3
        bvc *                   ;@ 50 fe /2
        eor ($12),y             ;@ 51 12 /2
        eor $12,x               ;@ 55 12 /2
        lsr $12,x               ;@ 56 12 /2
        cli                     ;@ 58 /1
        eor $1234,y             ;@ 59 34 12 /3
        eor $1234,x             ;@ 5d 34 12 /3
        lsr $1234,x             ;@ 5e 34 12 /3
        rts                     ;@ 60 /1
        adc ($12,x)             ;@ 61 12 /2
        adc $12                 ;@ 65 12 /2
        ror $12                 ;@ 66 12 /2
        pla                     ;@ 68 /1
        adc #$12                ;@ 69 12 /2
        ror a                   ;@ 6a /1
        jmp ($1234)             ;@ 6c 34 12 /3
        adc $1234               ;@ 6d 34 12 /3
        ror $1234               ;@ 6e 34 12 /3
        bvs *                   ;@ 70 fe /2
        adc ($12),y             ;@ 71 12 /2
        adc $12,x               ;@ 75 12 /2
        ror $12,x               ;@ 76 12 /2
        sei                     ;@ 78 /1
        adc $1234,y             ;@ 79 34 12 /3
        adc $1234,x             ;@ 7d 34 12 /3
        ror $1234,x             ;@ 7e 34 12 /3
        sta ($12,x)             ;@ 81 12 /2
        sty $12                 ;@ 84 12 /2
        sta $12                 ;@ 85 12 /2
        stx $12                 ;@ 86 12 /2
        dey                     ;@ 88 /1
        txa                     ;@ 8a /1
        sty $1234               ;@ 8c 34 12 /3
        sta $1234               ;@ 8d 34 12 /3
        stx $1234               ;@ 8e 34 12 /3
        bcc *                   ;@ 90 fe /2
        sta ($12),y             ;@ 91 12 /2
        sty $12,x               ;@ 94 12 /2
        sta $12,x               ;@ 95 12 /2
        stx $12,y               ;@ 96 12 /2
        tya                     ;@ 98 /1
        sta $1234,y             ;@ 99 34 12 /3
        txs                     ;@ 9a /1
        sta $1234,x             ;@ 9d 34 12 /3
        ldy #$12                ;@ a0 12 /2
        lda ($12,x)             ;@ a1 12 /2
        ldx #$12                ;@ a2 12 /2
        ldy $12                 ;@ a4 12 /2
        lda $12                 ;@ a5 12 /2
        ldx $12                 ;@ a6 12 /2
        tay                     ;@ a8 /1
        lda #$12                ;@ a9 12 /2
        tax                     ;@ aa /1
        ldy $1234               ;@ ac 34 12 /3
        lda $1234               ;@ ad 34 12 /3
        ldx $1234               ;@ ae 34 12 /3
        bcs *                   ;@ b0 fe /2
        lda ($12),y             ;@ b1 12 /2
        ldy $12,x               ;@ b4 12 /2
        lda $12,x               ;@ b5 12 /2
        ldx $12,y               ;@ b6 12 /2
        clv                     ;@ b8 /1
        lda $1234,y             ;@ b9 34 12 /3
        tsx                     ;@ ba /1
        ldy $1234,x             ;@ bc 34 12 /3
        lda $1234,x             ;@ bd 34 12 /3
        ldx $1234,y             ;@ be 34 12 /3
        cpy #$12                ;@ c0 12 /2
        cmp ($12,x)             ;@ c1 12 /2
        cpy $12                 ;@ c4 12 /2
        cmp $12                 ;@ c5 12 /2
        dec $12                 ;@ c6 12 /2
        iny                     ;@ c8 /1
        cmp #$12                ;@ c9 12 /2
        dex                     ;@ ca /1
        cpy $1234               ;@ cc 34 12 /3
        cmp $1234               ;@ cd 34 12 /3
        dec $1234               ;@ ce 34 12 /3
        bne *                   ;@ d0 fe /2
        cmp ($12),y             ;@ d1 12 /2
        cmp $12,x               ;@ d5 12 /2
        dec $12,x               ;@ d6 12 /2
        cld                     ;@ d8 /1
        cmp $1234,y             ;@ d9 34 12 /3
        cmp $1234,x             ;@ dd 34 12 /3
        dec $1234,x             ;@ de 34 12 /3
        cpx #$12                ;@ e0 12 /2
        sbc ($12,x)             ;@ e1 12 /2
        cpx $12                 ;@ e4 12 /2
        sbc $12                 ;@ e5 12 /2
        inc $12                 ;@ e6 12 /2
        inx                     ;@ e8 /1
        sbc #$12                ;@ e9 12 /2
        nop                     ;@ ea /1
        cpx $1234               ;@ ec 34 12 /3
        sbc $1234               ;@ ed 34 12 /3
        inc $1234               ;@ ee 34 12 /3
        beq *                   ;@ f0 fe /2
        sbc ($12),y             ;@ f1 12 /2
        sbc $12,x               ;@ f5 12 /2
        inc $12,x               ;@ f6 12 /2
        sed                     ;@ f8 /1
        sbc $1234,y             ;@ f9 34 12 /3
        sbc $1234,x             ;@ fd 34 12 /3
        inc $1234,x             ;@ fe 34 12 /3

; casi limite usati dalla Fase 1 (cicli): branch che attraversa la pagina
        * = $20fd
        bne $2110               ;@ d0 11 /2   da $20ff a $2110: +1 ciclo
        * = $2200
        ldx #$00                ;@ a2 00 /2
loop    inx                     ;@ e8 /1
        cpx #$10                ;@ e0 10 /2
        bne loop                ;@ d0 fb /2
        rts                     ;@ 60 /1
