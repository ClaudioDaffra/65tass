;; expect: error
;; Fase 0 / ticket #24: senza guardia la doppia inclusione da' errore.
        * = $1000
        .include "../dir/inc/noguard.inc"
        .include "../dir/inc/noguard.inc"
        rts
