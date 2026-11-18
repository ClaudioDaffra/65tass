;; cpu: --m45gs02
;; flags: --list-cycles
;; Fase 1, totali: un'istruzione con prefisso del 45GS02 non ha tempo
;; documentato, quindi il totale del blocco e' sconosciuto.
        * = $2000
        .cycles 10
        ldq $12                 ;@ 42 42 a5 12 /4 ~?
        inz                     ;@ 1b /1 ~1
        .endcycles              ;=cycles unknown (1 instruction without timing)
