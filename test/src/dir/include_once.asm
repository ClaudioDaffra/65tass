;; Fase 0 / ticket #24: "include once" con la guardia :?= e .if.
;; Il file e' incluso due volte ma il codice (helper) compare una volta sola.
        * = $1000
        .include "inc/common.inc"
        .include "inc/common.inc"
        lda #K_ONE              ;@ a9 01 /2
        jsr helper              ;@ 20 00 10 /3
        rts                     ;@ 60 /1
