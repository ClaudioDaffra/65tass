;; cpu: --m45gs02
;; flags: --list-classic 
;; Formato classico di 64tass (--list-classic): stesso listing di prima del
;; formato a spazi. Corpo copiato da cpu/45gs02.asm.
        * = $2000

        map                     ;@ 5c /1
        eom                     ;@ ea /1
        lda [$12],z             ;@ ea b2 12 /3
        sta [$12],z             ;@ ea 92 12 /3
        adc [$12],z             ;@ ea 72 12 /3
        ldq $12                 ;@ 42 42 a5 12 /4
        ldq $1234               ;@ 42 42 ad 34 12 /5
        ldq ($12),z             ;@ 42 42 b2 12 /4
        ldq [$12],z             ;@ 42 42 ea b2 12 /5
        stq $12                 ;@ 42 42 85 12 /4
        stq $1234               ;@ 42 42 8d 34 12 /5
        stq ($12)               ;@ 42 42 92 12 /4   senza ,z (Z non usato)
        adq $12                 ;@ 42 42 65 12 /4
        anq $12                 ;@ 42 42 25 12 /4
        orq $12                 ;@ 42 42 05 12 /4
        eoq $12                 ;@ 42 42 45 12 /4
        cpq $12                 ;@ 42 42 c5 12 /4
        sbq $12                 ;@ 42 42 e5 12 /4
        btq $12                 ;@ 42 42 24 12 /4
        inq                     ;@ 42 42 1a /3
        deq                     ;@ 42 42 3a /3
        asl q                   ;@ 42 42 0a /3
        lsr q                   ;@ 42 42 4a /3
        rol q                   ;@ 42 42 2a /3
        ror q                   ;@ 42 42 6a /3
        asr q                   ;@ 42 42 43 /3
        ind $12                 ;@ 42 42 e6 12 /4
        ded $12                 ;@ 42 42 c6 12 /4
        asd $12                 ;@ 42 42 06 12 /4
        lsd $12                 ;@ 42 42 46 12 /4
        rld $12                 ;@ 42 42 26 12 /4
        rrd $12                 ;@ 42 42 66 12 /4
        ard $12                 ;@ 42 42 44 12 /4
; sintassi generica con registro Q
        ldr q,$12               ;@ 42 42 a5 12 /4
        str q,$12               ;@ 42 42 85 12 /4
; opcode del 4510 per controllo
        neg a                   ;@ 42 /1
        ldz #$12                ;@ a3 12 /2
