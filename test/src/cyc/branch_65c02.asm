;; cpu: --mr65c02
;; flags: --list-cycles
;; Fase 1: 65C02 / R65C02. BRA sempre preso (3, +1 se cambia pagina), BBR/BBS
;; 5, +1 se salta, +1 se cambia pagina; ADC/SBC +1 in modo decimale.
        * = $1000
        bra *                   ;@ 80 fe /2 ~3
        bbr 0,$12,*             ;@ 0f 12 fd /3 ~5/6
        adc #1                  ;@ 69 01 /2 ~2-3
        sbc $1234,y             ;@ f9 34 12 /3 ~4-6
        asl $1234,x             ;@ 1e 34 12 /3 ~6-7
        inc $1234,x             ;@ fe 34 12 /3 ~7
        jmp ($1234)             ;@ 6c 34 12 /3 ~6
; la penalita' confronta la pagina dell'istruzione seguente con la
; destinazione: da $10ff a $1120 cambia pagina, da $11ff a $1220 anche
        * = $10fd
        bra $1120               ;@ 80 21 /2 ~4p
        * = $11fc
        bbs 1,$12,$1220         ;@ 9f 12 21 /3 ~5/7p
        * = $12fe
        bra $1320               ;@ 80 20 /2 ~3   da $1300: stessa pagina
