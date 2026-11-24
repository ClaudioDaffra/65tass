;; json: yes
;; Fase 2: nessun messaggio, "diagnostics" vuoto, errors e warnings a 0.
        * = $1000
        ldx #$00
loop    inx
        bne loop
        rts
