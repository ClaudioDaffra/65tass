;; Fase 0 / ticket #28: non esiste un tipo di dato big-endian. Soluzioni
;; possibili con le funzioni gia' presenti, e una trappola da evitare.
        * = $1000
lab     = $1234
        .byte >lab, <lab                ;@ 12 34 /2
        .text bytes(lab, 2)[::-1]       ;@ 12 34 /2   byte rovesciati
        .text x"1234"                   ;@ 12 34 /2   solo costanti
bw      .function v                     ; .bigword fatto in casa
        .endf bytes(v, 2)[::-1]
        .text bw(lab), bw($abcd)        ;@ 12 34 ab cd /4
; tabella: un valore alla volta (bw su una lista rovescia tutta la lista)
tab     .for v in [$1111, $2222, lab]
        .text bw(v)
        .endfor
        .text bw([$1111, lab])          ;@ 34 12 11 11 /4  ordine sbagliato!
; trappola: bits()[::-1] rovescia i bit, non i byte
        .text bits(lab, 16)[::-1]       ;@ 48 2c /2
