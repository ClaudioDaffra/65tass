;; expect: error
;; Aggiunte di 65tass: valori fuori campo per la virgola fissa.
        * = $1000
        .f88  200.0             ; 200*256 non sta in 16 bit con segno
        .f124 -2048.5           ; sotto -2048
        .u8   256               ; come .byte: fuori campo
