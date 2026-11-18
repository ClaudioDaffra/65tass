;; Fase 0: .assert e .check NON sono asserzioni generiche.
;; .assert <fornisce>, <richiede>, <conflitti> imposta tre maschere di bit
;; della sezione corrente; .check <richiesti>, <in conflitto> da' errore se
;; un bit richiesto non e' fornito o se un bit in conflitto e' fornito.
;; Il manuale dice: "non usarle, la sintassi cambiera'". Per i controlli
;; veri si usano .cerror e .cwarn.
        * = $1000
        .assert %0011, %0000, %0100
        .check %0001, %1000     ; bit 0 fornito, bit 3 non fornito: va bene
        .check %0011, %0100     ; va bene
        .cerror * != $1000, "indirizzo sbagliato"
        nop                     ;@ ea /1
