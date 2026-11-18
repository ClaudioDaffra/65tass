;; cpu: --m6502
;; NMOS 6502 con opcode illegali (-i, --m6502): gli opcode in piu' rispetto
;; al 6502 standard. Fonte: "Additional NMOS 6502 opcodes" del manuale.
        * = $1000

        jam                     ;@ 02 /1
        slo ($12,x)             ;@ 03 12 /2
        nop $12                 ;@ 04 12 /2
        slo $12                 ;@ 07 12 /2
        anc #$12                ;@ 0b 12 /2
        nop $1234               ;@ 0c 34 12 /3
        slo $1234               ;@ 0f 34 12 /3
        slo ($12),y             ;@ 13 12 /2
        nop $12,x               ;@ 14 12 /2
        slo $12,x               ;@ 17 12 /2
        slo $1234,y             ;@ 1b 34 12 /3
        nop $1234,x             ;@ 1c 34 12 /3
        slo $1234,x             ;@ 1f 34 12 /3
        rla ($12,x)             ;@ 23 12 /2
        rla $12                 ;@ 27 12 /2
        rla $1234               ;@ 2f 34 12 /3
        rla ($12),y             ;@ 33 12 /2
        rla $12,x               ;@ 37 12 /2
        rla $1234,y             ;@ 3b 34 12 /3
        rla $1234,x             ;@ 3f 34 12 /3
        sre ($12,x)             ;@ 43 12 /2
        sre $12                 ;@ 47 12 /2
        asr #$12                ;@ 4b 12 /2   ALR
        sre $1234               ;@ 4f 34 12 /3
        sre ($12),y             ;@ 53 12 /2
        sre $12,x               ;@ 57 12 /2
        sre $1234,y             ;@ 5b 34 12 /3
        sre $1234,x             ;@ 5f 34 12 /3
        rra ($12,x)             ;@ 63 12 /2
        rra $12                 ;@ 67 12 /2
        arr #$12                ;@ 6b 12 /2
        rra $1234               ;@ 6f 34 12 /3
        rra ($12),y             ;@ 73 12 /2
        rra $12,x               ;@ 77 12 /2
        rra $1234,y             ;@ 7b 34 12 /3
        rra $1234,x             ;@ 7f 34 12 /3
        nop #$12                ;@ 80 12 /2
        sax ($12,x)             ;@ 83 12 /2
        sax $12                 ;@ 87 12 /2
        ane #$12                ;@ 8b 12 /2   XAA
        sax $1234               ;@ 8f 34 12 /3
        sha ($12),y             ;@ 93 12 /2
        sax $12,y               ;@ 97 12 /2
        shs $1234,y             ;@ 9b 34 12 /3  TAS
        shy $1234,x             ;@ 9c 34 12 /3
        shx $1234,y             ;@ 9e 34 12 /3
        sha $1234,y             ;@ 9f 34 12 /3
        lax ($12,x)             ;@ a3 12 /2
        lax $12                 ;@ a7 12 /2
        lax #$12                ;@ ab 12 /2   LXA
        lax $1234               ;@ af 34 12 /3
        lax ($12),y             ;@ b3 12 /2
        lax $12,y               ;@ b7 12 /2
        lds $1234,y             ;@ bb 34 12 /3  LAS
        lax $1234,y             ;@ bf 34 12 /3
        dcp ($12,x)             ;@ c3 12 /2
        dcp $12                 ;@ c7 12 /2
        sbx #$12                ;@ cb 12 /2   AXS
        dcp $1234               ;@ cf 34 12 /3
        dcp ($12),y             ;@ d3 12 /2
        dcp $12,x               ;@ d7 12 /2
        dcp $1234,y             ;@ db 34 12 /3
        dcp $1234,x             ;@ df 34 12 /3
        isb ($12,x)             ;@ e3 12 /2
        isb $12                 ;@ e7 12 /2
        isb $1234               ;@ ef 34 12 /3
        isb ($12),y             ;@ f3 12 /2
        isb $12,x               ;@ f7 12 /2
        isb $1234,y             ;@ fb 34 12 /3
        isb $1234,x             ;@ ff 34 12 /3
; un opcode standard per controllo
        lda #$12                ;@ a9 12 /2
