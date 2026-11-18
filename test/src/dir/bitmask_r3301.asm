;; cpu: --mr65c02
;; Novita' del trunk 64tass r3301 (fuso in 65tass il 2026-11-18): il bit di
;; RMB/SMB/BBR/BBS si puo' scrivere anche come maschera immediata.
;; Con 64tass 1.60.3243 questo test fallisce.
        * = $1000
        smb #$80,$12            ;@ f7 12 /2      = smb 7,$12
        rmb #$01,$12            ;@ 07 12 /2      = rmb 0,$12
        bbr #$40,$12,*          ;@ 6f 12 fd /3   = bbr 6,$12,*
        bbs #$08,$12,*          ;@ bf 12 fd /3   = bbs 3,$12,*
        smb 7,$12               ;@ f7 12 /2      forma classica
