;; expect: error
;; json: yes
;; flags: -Wleading-zeros -Werror=leading-zeros
;; Fase 2: un avviso trasformato in errore (-Werror=) ha gravita' "error" e
;; conserva il nome "-Wleading-zeros".
        * = $1000
        lda 0001
        rts
