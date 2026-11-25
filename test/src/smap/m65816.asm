;; srcmap: yes
;; cpu: --m65816
;; flags: -X
;; Fase 3: indirizzi a 24 bit del 65816 (banco nell'indirizzo, anche nelle
;; etichette VICE).
        * = $018000
        .al
        .xl
        rep #$30
        lda #$1234
        ldx #$5678
        jml $028000
        * = $028000
        rtl
