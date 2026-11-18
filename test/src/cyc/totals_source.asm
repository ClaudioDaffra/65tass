;; cpu: --m65xx
;; Fase 1, totali nel sorgente: "nome .endcycles" assegna a nome la coppia
;; (minimo, massimo). Si puo' usare prima del blocco (le passate risolvono
;; il riferimento in avanti) e senza --list-cycles.
        * = $1000
        .cerror irq_t[1] > 63, "irq troppo lento: ", irq_t[1], " cicli"
        ldx #$00                ;@ a2 00 /2
        .cycles 16
loop    inx                     ;@ e8 /1
        cpx #$10                ;@ e0 10 /2
        bne loop                ;@ d0 fb /2
loop_t  .endcycles
        .cycles
irq     lda $d019               ;@ ad 19 d0 /3
        sta $d019               ;@ 8d 19 d0 /3
        beq +                   ;@ f0 03 /2
        inc $d020               ;@ ee 20 d0 /3
+       jmp $ea31               ;@ 4c 31 ea /3
irq_t   .endcycles
; i valori nel binario: 111-111 e 19-20 (4+4+2+6+3 / 4+4+3+6+3)
        .word loop_t            ;@ 6f 00 6f 00 /4
        .byte irq_t             ;@ 13 14 /2
        .byte irq_t[1] - irq_t[0]       ;@ 01 /1
