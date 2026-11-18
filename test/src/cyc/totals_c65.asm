;; cpu: --m4510
;; flags: --list-cycles
;; Fase 1, totali sul Commodore 65: i branch del 4510 impiegano lo stesso
;; tempo presi o no (C65 System Specification), quindi il totale e' esatto.
        * = $2000
        ldx #$00                ;@ a2 00 /2 ~2
        .cycles 100
loop    lda $1000,x             ;@ bd 00 10 /3 ~4
        sta ($fb),z             ;@ 92 fb /2 ~5
        inx                     ;@ e8 /1 ~1
        bne loop                ;@ d0 f8 /2 ~2
        .endcycles              ;=cycles 1200 (100 iterations)
;                                  100*(4+5+1+2) = 1200: sul 4510 il branch
;                                  costa 2 preso o no, non serve l'ipotesi
; blocco senza branch, ripetuto 2 volte
        .cycles 2
        neg a                   ;@ 42 /1 ~2
        .endcycles              ;=cycles 4 (2 iterations)
