;; cpu: --mr65c02
;; expect: error
;; Trunk r3301: la maschera deve avere un solo bit acceso.
        * = $1000
        smb #$81,$12
        rmb #$00,$12
