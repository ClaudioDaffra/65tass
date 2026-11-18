;; cpu: --m65816
;; flags: --list-cycles
;; Fase 1: 65816. I cicli dipendono da .as/.al (m), .xs/.xl (x) e dal byte
;; basso del direct page (.dpage); l'assemblatore li conosce e li usa. Il
;; modo nativo/emulazione non e' noto: BRK/COP/RTI e i branch che cambiano
;; pagina mostrano un intervallo.
        * = $8000
        lda #$12                ;@ a9 12 /2 ~2
        lda $12                 ;@ a5 12 /2 ~3
        lda $1234,x             ;@ bd 34 12 /3 ~4-5
        asl $12                 ;@ 06 12 /2 ~5
        .al
        .xl
        lda #$1234              ;@ a9 34 12 /3 ~3
        lda $12                 ;@ a5 12 /2 ~4
        lda $1234,x             ;@ bd 34 12 /3 ~6
        asl $12                 ;@ 06 12 /2 ~7
        ldy #$1234              ;@ a0 34 12 /3 ~3
        .as
        .xs
        .dpage $1201
        lda $1210               ;@ a5 0f /2 ~4
        .dpage 0
        mvn #$01,#$02           ;@ 54 /3 ~7*n
        brk                     ;@ 00 /1 ~7-8
        rti                     ;@ 40 /1 ~6-7
        bne *                   ;@ d0 fe /2 ~2/3
        brl *                   ;@ 82 fd ff /3 ~4
        * = $80fd
        bne $8110               ;@ d0 11 /2 ~2/3-4
