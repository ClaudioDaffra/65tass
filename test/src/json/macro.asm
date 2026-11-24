;; expect: error
;; json: yes
;; Fase 2: errore dentro l'espansione di una macro. Le note ("original
;; location in an expanded macro was here", ...) stanno in "notes"
;; dell'errore a cui appartengono.
        * = $1000
carica  .macro
        lda #\1
        .endm
        #carica argomento_sbagliato
        rts
