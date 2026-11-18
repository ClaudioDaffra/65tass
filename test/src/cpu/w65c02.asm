;; cpu: --mw65c02
;; WDC W65C02: in piu' rispetto al R65C02 solo WAI e STP.
        * = $1000

        wai                     ;@ cb /1
        stp                     ;@ db /1
        hlt                     ;@ db /1   alias di STP
        smb 7,$12               ;@ f7 12 /2
        bbs 7,$12,*             ;@ ff 12 fd /3
        bra *                   ;@ 80 fe /2
