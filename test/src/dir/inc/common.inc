; File incluso con guardia "include once" (soluzione indicata dall'autore
; di 64tass nel ticket #24: non esiste una direttiva .include once).
common_inc :?= false            ; crea la variabile solo se non esiste
        .if !common_inc
common_inc := true
K_ONE   = 1
helper  rts
        .endif
