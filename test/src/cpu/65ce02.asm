;; cpu: --m65ce02
;; CSG 65CE02: come il 4510 senza MAP ($5C, AUG sul 65CE02, non
;; supportato da 65tass) e senza alias EOM. Generato da 4510.asm.
        * = $2000
far     = $3000                 ; destinazione lontana: forza i branch a 16 bit

        brk                     ;@ 00 /1
        ora ($12,x)             ;@ 01 12 /2
        cle                     ;@ 02 /1
        see                     ;@ 03 /1
        tsb $12                 ;@ 04 12 /2
        ora $12                 ;@ 05 12 /2
        asl $12                 ;@ 06 12 /2
        rmb 0,$12               ;@ 07 12 /2
        php                     ;@ 08 /1
        ora #$12                ;@ 09 12 /2
        asl a                   ;@ 0a /1
        tsy                     ;@ 0b /1
        tsb $1234               ;@ 0c 34 12 /3
        ora $1234               ;@ 0d 34 12 /3
        asl $1234               ;@ 0e 34 12 /3
        bbr 0,$12,*             ;@ 0f 12 fd /3
        bpl *                   ;@ 10 fe /2
        ora ($12),y             ;@ 11 12 /2
        ora ($12),z             ;@ 12 12 /2
        bpl far                 ;@ 13 /3
        trb $12                 ;@ 14 12 /2
        ora $12,x               ;@ 15 12 /2
        asl $12,x               ;@ 16 12 /2
        rmb 1,$12               ;@ 17 12 /2
        clc                     ;@ 18 /1
        ora $1234,y             ;@ 19 34 12 /3
        inc a                   ;@ 1a /1
        inz                     ;@ 1b /1
        trb $1234               ;@ 1c 34 12 /3
        ora $1234,x             ;@ 1d 34 12 /3
        asl $1234,x             ;@ 1e 34 12 /3
        bbr 1,$12,*             ;@ 1f 12 fd /3
        jsr $1234               ;@ 20 34 12 /3
        and ($12,x)             ;@ 21 12 /2
        jsr ($1234)             ;@ 22 34 12 /3
        jsr ($1234,x)           ;@ 23 34 12 /3
        bit $12                 ;@ 24 12 /2
        and $12                 ;@ 25 12 /2
        rol $12                 ;@ 26 12 /2
        rmb 2,$12               ;@ 27 12 /2
        plp                     ;@ 28 /1
        and #$12                ;@ 29 12 /2
        rol a                   ;@ 2a /1
        tys                     ;@ 2b /1
        bit $1234               ;@ 2c 34 12 /3
        and $1234               ;@ 2d 34 12 /3
        rol $1234               ;@ 2e 34 12 /3
        bbr 2,$12,*             ;@ 2f 12 fd /3
        bmi *                   ;@ 30 fe /2
        and ($12),y             ;@ 31 12 /2
        and ($12),z             ;@ 32 12 /2
        bmi far                 ;@ 33 /3
        bit $12,x               ;@ 34 12 /2
        and $12,x               ;@ 35 12 /2
        rol $12,x               ;@ 36 12 /2
        rmb 3,$12               ;@ 37 12 /2
        sec                     ;@ 38 /1
        and $1234,y             ;@ 39 34 12 /3
        dec a                   ;@ 3a /1
        dez                     ;@ 3b /1
        bit $1234,x             ;@ 3c 34 12 /3
        and $1234,x             ;@ 3d 34 12 /3
        rol $1234,x             ;@ 3e 34 12 /3
        bbr 3,$12,*             ;@ 3f 12 fd /3
        rti                     ;@ 40 /1
        eor ($12,x)             ;@ 41 12 /2
        neg a                   ;@ 42 /1
        asr a                   ;@ 43 /1
        asr $12                 ;@ 44 12 /2
        eor $12                 ;@ 45 12 /2
        lsr $12                 ;@ 46 12 /2
        rmb 4,$12               ;@ 47 12 /2
        pha                     ;@ 48 /1
        eor #$12                ;@ 49 12 /2
        lsr a                   ;@ 4a /1
        taz                     ;@ 4b /1
        jmp $1234               ;@ 4c 34 12 /3
        eor $1234               ;@ 4d 34 12 /3
        lsr $1234               ;@ 4e 34 12 /3
        bbr 4,$12,*             ;@ 4f 12 fd /3
        bvc *                   ;@ 50 fe /2
        eor ($12),y             ;@ 51 12 /2
        eor ($12),z             ;@ 52 12 /2
        bvc far                 ;@ 53 /3
        asr $12,x               ;@ 54 12 /2
        eor $12,x               ;@ 55 12 /2
        lsr $12,x               ;@ 56 12 /2
        rmb 5,$12               ;@ 57 12 /2
        cli                     ;@ 58 /1
        eor $1234,y             ;@ 59 34 12 /3
        phy                     ;@ 5a /1
        tad                     ;@ 5b /1   TAB nel manuale C65
        eor $1234,x             ;@ 5d 34 12 /3
        lsr $1234,x             ;@ 5e 34 12 /3
        bbr 5,$12,*             ;@ 5f 12 fd /3
        rts                     ;@ 60 /1
        adc ($12,x)             ;@ 61 12 /2
        rts #$12                ;@ 62 12 /2  RTN nella tabella
        bsr far                 ;@ 63 /3
        stz $12                 ;@ 64 12 /2  sul 4510 scrive il registro Z
        adc $12                 ;@ 65 12 /2
        ror $12                 ;@ 66 12 /2
        rmb 6,$12               ;@ 67 12 /2
        pla                     ;@ 68 /1
        adc #$12                ;@ 69 12 /2
        ror a                   ;@ 6a /1
        tza                     ;@ 6b /1
        jmp ($1234)             ;@ 6c 34 12 /3
        adc $1234               ;@ 6d 34 12 /3
        ror $1234               ;@ 6e 34 12 /3
        bbr 6,$12,*             ;@ 6f 12 fd /3
        bvs *                   ;@ 70 fe /2
        adc ($12),y             ;@ 71 12 /2
        adc ($12),z             ;@ 72 12 /2
        bvs far                 ;@ 73 /3
        stz $12,x               ;@ 74 12 /2
        adc $12,x               ;@ 75 12 /2
        ror $12,x               ;@ 76 12 /2
        rmb 7,$12               ;@ 77 12 /2
        sei                     ;@ 78 /1
        adc $1234,y             ;@ 79 34 12 /3
        ply                     ;@ 7a /1
        tda                     ;@ 7b /1   TBA nel manuale C65
        jmp ($1234,x)           ;@ 7c 34 12 /3
        adc $1234,x             ;@ 7d 34 12 /3
        ror $1234,x             ;@ 7e 34 12 /3
        bbr 7,$12,*             ;@ 7f 12 fd /3
        bra *                   ;@ 80 fe /2  BRU nella tabella
        sta ($12,x)             ;@ 81 12 /2
        sta ($12,s),y           ;@ 82 12 /2  IDSP
        bra far                 ;@ 83 /3
        sty $12                 ;@ 84 12 /2
        sta $12                 ;@ 85 12 /2
        stx $12                 ;@ 86 12 /2
        smb 0,$12               ;@ 87 12 /2
        dey                     ;@ 88 /1
        bit #$12                ;@ 89 12 /2
        txa                     ;@ 8a /1
        sty $1234,x             ;@ 8b 34 12 /3
        sty $1234               ;@ 8c 34 12 /3
        sta $1234               ;@ 8d 34 12 /3
        stx $1234               ;@ 8e 34 12 /3
        bbs 0,$12,*             ;@ 8f 12 fd /3
        bcc *                   ;@ 90 fe /2
        sta ($12),y             ;@ 91 12 /2
        sta ($12),z             ;@ 92 12 /2
        bcc far                 ;@ 93 /3
        sty $12,x               ;@ 94 12 /2
        sta $12,x               ;@ 95 12 /2
        stx $12,y               ;@ 96 12 /2
        smb 1,$12               ;@ 97 12 /2
        tya                     ;@ 98 /1
        sta $1234,y             ;@ 99 34 12 /3
        txs                     ;@ 9a /1
        stx $1234,y             ;@ 9b 34 12 /3
        stz $1234               ;@ 9c 34 12 /3
        sta $1234,x             ;@ 9d 34 12 /3
        stz $1234,x             ;@ 9e 34 12 /3
        bbs 1,$12,*             ;@ 9f 12 fd /3
        ldy #$12                ;@ a0 12 /2
        lda ($12,x)             ;@ a1 12 /2
        ldx #$12                ;@ a2 12 /2
        ldz #$12                ;@ a3 12 /2
        ldy $12                 ;@ a4 12 /2
        lda $12                 ;@ a5 12 /2
        ldx $12                 ;@ a6 12 /2
        smb 2,$12               ;@ a7 12 /2
        tay                     ;@ a8 /1
        lda #$12                ;@ a9 12 /2
        tax                     ;@ aa /1
        ldz $1234               ;@ ab 34 12 /3
        ldy $1234               ;@ ac 34 12 /3
        lda $1234               ;@ ad 34 12 /3
        ldx $1234               ;@ ae 34 12 /3
        bbs 2,$12,*             ;@ af 12 fd /3
        bcs *                   ;@ b0 fe /2
        lda ($12),y             ;@ b1 12 /2
        lda ($12),z             ;@ b2 12 /2
        bcs far                 ;@ b3 /3
        ldy $12,x               ;@ b4 12 /2
        lda $12,x               ;@ b5 12 /2
        ldx $12,y               ;@ b6 12 /2
        smb 3,$12               ;@ b7 12 /2
        clv                     ;@ b8 /1
        lda $1234,y             ;@ b9 34 12 /3
        tsx                     ;@ ba /1
        ldz $1234,x             ;@ bb 34 12 /3
        ldy $1234,x             ;@ bc 34 12 /3
        lda $1234,x             ;@ bd 34 12 /3
        ldx $1234,y             ;@ be 34 12 /3
        bbs 3,$12,*             ;@ bf 12 fd /3
        cpy #$12                ;@ c0 12 /2
        cmp ($12,x)             ;@ c1 12 /2
        cpz #$12                ;@ c2 12 /2
        dew $12                 ;@ c3 12 /2
        cpy $12                 ;@ c4 12 /2
        cmp $12                 ;@ c5 12 /2
        dec $12                 ;@ c6 12 /2
        smb 4,$12               ;@ c7 12 /2
        iny                     ;@ c8 /1
        cmp #$12                ;@ c9 12 /2
        dex                     ;@ ca /1
        asw $1234               ;@ cb 34 12 /3
        cpy $1234               ;@ cc 34 12 /3
        cmp $1234               ;@ cd 34 12 /3
        dec $1234               ;@ ce 34 12 /3
        bbs 4,$12,*             ;@ cf 12 fd /3
        bne *                   ;@ d0 fe /2
        cmp ($12),y             ;@ d1 12 /2
        cmp ($12),z             ;@ d2 12 /2
        bne far                 ;@ d3 /3
        cpz $12                 ;@ d4 12 /2
        cmp $12,x               ;@ d5 12 /2
        dec $12,x               ;@ d6 12 /2
        smb 5,$12               ;@ d7 12 /2
        cld                     ;@ d8 /1
        cmp $1234,y             ;@ d9 34 12 /3
        phx                     ;@ da /1
        phz                     ;@ db /1
        cpz $1234               ;@ dc 34 12 /3
        cmp $1234,x             ;@ dd 34 12 /3
        dec $1234,x             ;@ de 34 12 /3
        bbs 5,$12,*             ;@ df 12 fd /3
        cpx #$12                ;@ e0 12 /2
        sbc ($12,x)             ;@ e1 12 /2
        lda ($12,s),y           ;@ e2 12 /2  IDSP
        inw $12                 ;@ e3 12 /2  [doc] zp, non $nnnn
        cpx $12                 ;@ e4 12 /2
        sbc $12                 ;@ e5 12 /2
        inc $12                 ;@ e6 12 /2
        smb 6,$12               ;@ e7 12 /2
        inx                     ;@ e8 /1
        sbc #$12                ;@ e9 12 /2
        nop                     ;@ ea /1   EOM dopo un MAP
        rlw $1234               ;@ eb 34 12 /3  ROW (ruota a sinistra)
        cpx $1234               ;@ ec 34 12 /3
        sbc $1234               ;@ ed 34 12 /3
        inc $1234               ;@ ee 34 12 /3
        bbs 6,$12,*             ;@ ef 12 fd /3
        beq *                   ;@ f0 fe /2
        sbc ($12),y             ;@ f1 12 /2
        sbc ($12),z             ;@ f2 12 /2
        beq far                 ;@ f3 /3
        phw #$1234              ;@ f4 34 12 /3  [doc] "PHD IMM"
        sbc $12,x               ;@ f5 12 /2
        inc $12,x               ;@ f6 12 /2
        smb 7,$12               ;@ f7 12 /2
        sed                     ;@ f8 /1
        sbc $1234,y             ;@ f9 34 12 /3
        plx                     ;@ fa /1
        plz                     ;@ fb /1
        phw $1234               ;@ fc 34 12 /3  [doc] "PHD ABS"
        sbc $1234,x             ;@ fd 34 12 /3
        inc $1234,x             ;@ fe 34 12 /3
        bbs 7,$12,*             ;@ ff 12 fd /3

; alias del manuale C65 accettati da 65tass
        tab                     ;@ 5b /1
        tba                     ;@ 7b /1
        row $1234               ;@ eb 34 12 /3
        rtn #$12                ;@ 62 12 /2

; offset dei branch a 16 bit: relativi a opcode+2
        * = $2400
        bsr $2400               ;@ 63 fe ff /3   $2400-($2400+2)
        bra $2500               ;@ 83 fb 00 /3   $2500-($2403+2)
