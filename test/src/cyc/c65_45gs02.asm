;; cpu: --m45gs02
;; flags: --list-cycles
;; Fase 1: Commodore 65 / MEGA65. Le istruzioni del 4510 hanno i cicli della
;; C65 System Specification (niente penalita' di pagina, branch con tempo
;; fisso). I prefissi del 45GS02 (42 42 per Q, EA per [zp],z) mostrano "+" e
;; l'istruzione che segue "?": nessuna fonte per i tempi del MEGA65.
        * = $2000
        lda #1                  ;@ a9 01 /2 ~2
        lda $1234,x             ;@ bd 34 12 /3 ~4
        lda ($12),z             ;@ b2 12 /2 ~5
        bne *                   ;@ d0 fe /2 ~2
        bne $3000               ;@ d3 /3 ~3
        map                     ;@ 5c /1 ~4
        eom                     ;@ ea /1 ~1
        neg a                   ;@ 42 /1 ~2
        ldq $12                 ;@ 42 42 a5 12 /4 ~?
        lda [$12],z             ;@ ea b2 12 /3 ~?
        inq                     ;@ 42 42 1a /3 ~?
        lda #2                  ;@ a9 02 /2 ~2
