;; cpu: --m65xx
;; flags: --list-cycles
;; Fase 1, totali: .cycles <iterazioni> ... .endcycles. Il branch che chiude
;; il blocco e torna dentro (loop branch) si conta preso <iterazioni>-1
;; volte e non preso una volta; gli altri branch danno minimo (non preso) e
;; massimo (preso). I totali attesi (;=cycles) sono calcolati a mano.
        * = $1000
        ldx #$00                ;@ a2 00 /2 ~2
        .cycles 16
loop    inx                     ;@ e8 /1 ~2
        cpx #$10                ;@ e0 10 /2 ~2
        bne loop                ;@ d0 fb /2 ~2/3
        .endcycles              ;=cycles 111 (16 iterations, loop branch taken 15 times)
;                                  16*(2+2) + 15*3 + 2 = 111

; loop annidati: il blocco interno conta come un'istruzione dell'esterno
        .cycles 8
outer   ldy #4                  ;@ a0 04 /2 ~2
        .cycles 4
inner   dey                     ;@ 88 /1 ~2
        bne inner               ;@ d0 fd /2 ~2/3
        .endcycles              ;=cycles 19 (4 iterations, loop branch taken 3 times)
;                                  4*2 + 3*3 + 2 = 19
        dex                     ;@ ca /1 ~2
        bne outer               ;@ d0 f8 /2 ~2/3
        .endcycles              ;=cycles 207 (8 iterations, loop branch taken 7 times)
;                                  8*(2+19+2) + 7*3 + 2 = 207

; blocco senza loop branch: minimo e massimo (pagina, branch preso)
        .cycles
        lda $1234,x             ;@ bd 34 12 /3 ~4-5
        beq +                   ;@ f0 01 /2 ~2/3
        nop                     ;@ ea /1 ~2
+       rts                     ;@ 60 /1 ~6
        .endcycles              ;=cycles 14-16 (1 iteration)
;                                  (4+2+2+6) - (5+3+2+6)

; loop il cui branch cambia pagina: preso costa 4
        * = $10f8
        .cycles 3
wait    dex                     ;@ ca /1 ~2
        * = $1100
        bne wait                ;@ d0 f6 /2 ~2/4p
        .endcycles              ;=cycles 16 (3 iterations, loop branch taken 2 times)
;                                  3*2 + 2*4 + 2 = 16 (da $1102 a $10f8: cambia pagina)
