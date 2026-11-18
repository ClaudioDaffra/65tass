;; cpu: --m65dtv02
;; C64 DTV (65DTV02, -t): BRA, SAC e SIR, piu' una parte degli illegali NMOS.
;; Fonte: "65DTV02 opcodes" del manuale.
        * = $1000

        bra *                   ;@ 12 fe /2
        sac #$12                ;@ 32 12 /2
        sir #$12                ;@ 42 12 /2
; illegali NMOS ancora validi sul DTV
        slo $12                 ;@ 07 12 /2
        lax $1234               ;@ af 34 12 /3
        dcp ($12),y             ;@ d3 12 /2
        isb $1234,x             ;@ ff 34 12 /3
; opcode standard per controllo
        lda #$12                ;@ a9 12 /2
        rts                     ;@ 60 /1
