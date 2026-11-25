;; srcmap: yes
;; Fase 3: indirizzo CPU e offset. .logical (indirizzo diverso
;; dall'offset), sezioni messe con .dsection dopo la loro definizione,
;; .fill, .align, dati lunghi (piu' righe nel listing, un record), e le
;; parti che non vanno nell'output: .virtual e definizioni di .struct.
        * = $0801
        .section dati
tabella .byte 1,2,3,4,5,6,7,8,9,10      ; 10 byte: due righe nel listing
        .send dati
        lda tabella
        .dsection codice
        .virtual $c000                  ;nomap
        lda #1                          ;nomap
        .endvirtual                     ;nomap
        .logical $0400
copia   lda #2                          ; indirizzo $0400, offset $0805
        jmp copia
        .endlogical
        .fill 3, $ea
        .align 4, $00
        .text "ciao dal 6502"
        .dsection dati
        .section codice
        rts
        .send codice
        brk
