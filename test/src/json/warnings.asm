;; json: yes
;; flags: -Wall -Wshadow
;; Fase 2: avvisi in JSON con il nome della diagnostica ("-Wleading-zeros",
;; "-Wshadow"...) separato dal messaggio; .warn dell'utente ha nome null.
;; Nessun errore: il binario si crea e rc = 0.
        * = $1000
uno     = 1
blocco  .block
uno     = 2
        lda #uno
        .endblock
        lda 0001
        .warn "avviso dell'utente"
        lda #uno
        rts
