;; cpu: --mr65c02
;; Rockwell R65C02: in piu' rispetto al 65C02 i bit (RMB/SMB/BBR/BBS) e
;; quattro NOP con operando. Fonte: "Additional R65C02 opcodes over 65C02".
        * = $1000

        rmb 0,$12               ;@ 07 12 /2
        bbr 0,$12,*             ;@ 0f 12 fd /3
        rmb 1,$12               ;@ 17 12 /2
        bbr 1,$12,*             ;@ 1f 12 fd /3
        rmb 2,$12               ;@ 27 12 /2
        bbr 2,$12,*             ;@ 2f 12 fd /3
        rmb 3,$12               ;@ 37 12 /2
        bbr 3,$12,*             ;@ 3f 12 fd /3
        nop $12                 ;@ 44 12 /2
        rmb 4,$12               ;@ 47 12 /2
        bbr 4,$12,*             ;@ 4f 12 fd /3
        nop $12,x               ;@ 54 12 /2
        rmb 5,$12               ;@ 57 12 /2
        bbr 5,$12,*             ;@ 5f 12 fd /3
        rmb 6,$12               ;@ 67 12 /2
        bbr 6,$12,*             ;@ 6f 12 fd /3
        rmb 7,$12               ;@ 77 12 /2
        bbr 7,$12,*             ;@ 7f 12 fd /3
        nop #$12                ;@ 82 12 /2
        smb 0,$12               ;@ 87 12 /2
        bbs 0,$12,*             ;@ 8f 12 fd /3
        smb 1,$12               ;@ 97 12 /2
        bbs 1,$12,*             ;@ 9f 12 fd /3
        smb 2,$12               ;@ a7 12 /2
        bbs 2,$12,*             ;@ af 12 fd /3
        smb 3,$12               ;@ b7 12 /2
        bbs 3,$12,*             ;@ bf 12 fd /3
        smb 4,$12               ;@ c7 12 /2
        bbs 4,$12,*             ;@ cf 12 fd /3
        nop $1234               ;@ dc 34 12 /3
        smb 5,$12               ;@ d7 12 /2
        bbs 5,$12,*             ;@ df 12 fd /3
        smb 6,$12               ;@ e7 12 /2
        bbs 6,$12,*             ;@ ef 12 fd /3
        smb 7,$12               ;@ f7 12 /2
        bbs 7,$12,*             ;@ ff 12 fd /3
; un opcode del 65C02 per controllo
        stz $1234               ;@ 9c 34 12 /3
