;; expect: error
;; json: yes
;; flags: -a -Wall
;; Fase 2: errori in JSON. Simbolo non definito, sintassi, .cerror con
;; virgolette, barra rovesciata, tabulazione e caratteri UTF-8 (colonna in
;; caratteri, non in byte). L'avviso -Wleading-zeros non compare (come nel
;; testo: con errori gli avvisi non si mostrano).
        * = $1000
        lda #non_definito
        lda #($12
	.cerror 1, "tab	""q"" \ è €"
        lda 0001
        rts
