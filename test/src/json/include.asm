;; expect: error
;; json: yes
;; Fase 2: errore in un file incluso su due livelli. "included_from" elenca
;; la catena dal file piu' vicino al sorgente principale.
        * = $1000
        nop
        .include "inc/json_a.asm"
        rts
