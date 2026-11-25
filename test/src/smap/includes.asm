;; srcmap: yes
;; Fase 3: include su tre livelli (smap_a -> smap_b -> smap_c), lo stesso
;; file incluso due volte (record diversi, stessa riga: _2 nelle etichette
;; VICE), .binclude e un .include chiamato dentro una macro (catena i poi m).
        * = $2000
        nop
        .include "inc/smap_a.asm"
        .include "inc/sub/smap_c.asm"
dentro  .binclude "inc/sub/smap_c.asm"
carica  .macro
        .include "inc/sub/smap_c.asm"
        .endm
        #carica
        rts
