;; cpu: --m65el02
;; 65EL02 (-e, RedPower): una parte degli opcode in piu' rispetto al 65C02.
;; Fonte: solo il manuale di 65tass ("Additional 65EL02 opcodes"); nessuna
;; documentazione esterna in questa cartella: da confrontare se serve.
        * = $1000

        nxt                     ;@ 02 /1
        ora $12,s               ;@ 03 12 /2
        ora $12,r               ;@ 07 12 /2
        rhi                     ;@ 0b /1
        ora ($12,s),y           ;@ 13 12 /2
        ora ($12,r),y           ;@ 17 12 /2
        rhx                     ;@ 1b /1
        rli                     ;@ 2b /1
        rlx                     ;@ 3b /1
        nxa                     ;@ 42 /1
        rha                     ;@ 4b /1
        rhy                     ;@ 5b /1
        txi                     ;@ 5c /1
        rla                     ;@ 6b /1
        rly                     ;@ 7b /1
        txr                     ;@ 8b /1
        zea                     ;@ 8f /1
        txy                     ;@ 9b /1
        sea                     ;@ 9f /1
        lda $12,s               ;@ a3 12 /2
        lda $12,r               ;@ a7 12 /2
        trx                     ;@ ab /1
        tda                     ;@ af /1
        lda ($12,s),y           ;@ b3 12 /2
        lda ($12,r),y           ;@ b7 12 /2
        tyx                     ;@ bb /1
        tad                     ;@ bf /1
        rep #$30                ;@ c2 30 /2
        wai                     ;@ cb /1
        pld                     ;@ cf /1
        stp                     ;@ db /1
        tix                     ;@ dc /1
        phd                     ;@ df /1
        sep #$30                ;@ e2 30 /2
        xba                     ;@ eb /1
        xce                     ;@ fb /1
