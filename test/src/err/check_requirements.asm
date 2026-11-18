;; expect: error
;; .check con un bit richiesto non fornito, poi con un bit in conflitto,
;; poi un .cerror vero.
        * = $1000
        .assert %0011, %0000, %0000
        .check %0100, %0000     ; requirements not met
        .check %0000, %0001     ; conflict
        .cerror * == $1000, "programma troppo lungo di ", * - $0fff, " byte"
        nop
