;; cpu: --m65816
;; flags: -B
;; Fase 0 / ticket #30: -B (long branch) si attiva solo da riga di comando;
;; nel sorgente esiste solo l'opzione non documentata auto_longbranch_as_jmp
;; che sul 65816 sceglie JMP invece di BRL. Uno stesso trampolino puo'
;; essere riusato dai branch successivi.
        * = $1000
        bne far                 ;@ f0 03 82 fb 0f /5   beq *+5 / brl far
        .option auto_longbranch_as_jmp = 1
        bra far                 ;@ 4c 00 20 /3   jmp
        .option auto_longbranch_as_jmp = 0
        bra far                 ;@ 82 /3         brl
        .option allow_branch_across_page = 1
        * = $2000
far     nop                     ;@ ea /1
