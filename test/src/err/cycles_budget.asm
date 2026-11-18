;; expect: error
;; Fase 1: un .cerror sul totale di un blocco scatta quando si supera il
;; tempo disponibile (qui 100 cicli per un loop da 111).
        * = $1000
        ldx #$00
        .cycles 16
loop    inx
        cpx #$10
        bne loop
loop_t  .endcycles
        .cerror loop_t[1] > 100, "loop troppo lento: ", loop_t[1], " cicli"
