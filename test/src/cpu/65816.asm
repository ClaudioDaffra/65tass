;; cpu: --m65816
;; WDC 65816 (-x): opcode in piu' rispetto al 65C02 e immediati a 16 bit.
;; Fonte: "Additional W65816 opcodes over 65C02" del manuale.
        * = $1000

        cop #$12                ;@ 02 12 /2
        ora $12,s               ;@ 03 12 /2
        ora [$12]               ;@ 07 12 /2
        phd                     ;@ 0b /1
        ora $123456             ;@ 0f 56 34 12 /4
        ora ($12,s),y           ;@ 13 12 /2
        ora [$12],y             ;@ 17 12 /2
        tcs                     ;@ 1b /1
        ora $123456,x           ;@ 1f 56 34 12 /4
        jsl $123456             ;@ 22 56 34 12 /4
        and $12,s               ;@ 23 12 /2
        and [$12]               ;@ 27 12 /2
        pld                     ;@ 2b /1
        and $123456             ;@ 2f 56 34 12 /4
        and ($12,s),y           ;@ 33 12 /2
        and [$12],y             ;@ 37 12 /2
        tsc                     ;@ 3b /1
        and $123456,x           ;@ 3f 56 34 12 /4
        wdm #$12                ;@ 42 12 /2
        eor $12,s               ;@ 43 12 /2
        mvp #$12,#$34           ;@ 44 /3
        eor [$12]               ;@ 47 12 /2
        phk                     ;@ 4b /1
        eor $123456             ;@ 4f 56 34 12 /4
        eor ($12,s),y           ;@ 53 12 /2
        mvn #$12,#$34           ;@ 54 /3
        eor [$12],y             ;@ 57 12 /2
        tcd                     ;@ 5b /1
        jml $123456             ;@ 5c 56 34 12 /4
        eor $123456,x           ;@ 5f 56 34 12 /4
        per *                   ;@ 62 fd ff /3
        adc $12,s               ;@ 63 12 /2
        adc [$12]               ;@ 67 12 /2
        rtl                     ;@ 6b /1
        adc $123456             ;@ 6f 56 34 12 /4
        adc ($12,s),y           ;@ 73 12 /2
        adc [$12],y             ;@ 77 12 /2
        tdc                     ;@ 7b /1
        adc $123456,x           ;@ 7f 56 34 12 /4
        brl *                   ;@ 82 fd ff /3
        sta $12,s               ;@ 83 12 /2
        sta [$12]               ;@ 87 12 /2
        phb                     ;@ 8b /1
        sta $123456             ;@ 8f 56 34 12 /4
        sta ($12,s),y           ;@ 93 12 /2
        sta [$12],y             ;@ 97 12 /2
        txy                     ;@ 9b /1
        sta $123456,x           ;@ 9f 56 34 12 /4
        lda $12,s               ;@ a3 12 /2
        lda [$12]               ;@ a7 12 /2
        plb                     ;@ ab /1
        lda $123456             ;@ af 56 34 12 /4
        lda ($12,s),y           ;@ b3 12 /2
        lda [$12],y             ;@ b7 12 /2
        tyx                     ;@ bb /1
        lda $123456,x           ;@ bf 56 34 12 /4
        rep #$30                ;@ c2 30 /2
        cmp $12,s               ;@ c3 12 /2
        cmp [$12]               ;@ c7 12 /2
        wai                     ;@ cb /1
        cmp $123456             ;@ cf 56 34 12 /4
        cmp ($12,s),y           ;@ d3 12 /2
        pei ($12)               ;@ d4 12 /2
        cmp [$12],y             ;@ d7 12 /2
        stp                     ;@ db /1
        jmp [$1234]             ;@ dc 34 12 /3
        cmp $123456,x           ;@ df 56 34 12 /4
        sep #$30                ;@ e2 30 /2
        sbc $12,s               ;@ e3 12 /2
        sbc [$12]               ;@ e7 12 /2
        xba                     ;@ eb /1
        sbc $123456             ;@ ef 56 34 12 /4
        sbc ($12,s),y           ;@ f3 12 /2
        pea #$1234              ;@ f4 34 12 /3
        sbc [$12],y             ;@ f7 12 /2
        xce                     ;@ fb /1
        jsr ($1234,x)           ;@ fc 34 12 /3
        sbc $123456,x           ;@ ff 56 34 12 /4

; immediati: 8 bit di default, 16 bit dopo .al/.xl
        lda #$12                ;@ a9 12 /2
        .al
        .xl
        lda #$1234              ;@ a9 34 12 /3
        ldx #$1234              ;@ a2 34 12 /3
        .as
        .xs
        ldy #$12                ;@ a0 12 /2
