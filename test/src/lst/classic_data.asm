;; flags: --list-classic 
;; Formato classico di 64tass (--list-classic): stesso listing di prima del
;; formato a spazi. Corpo copiato da dir/float65tass.asm.
        * = $1000
        .f88  1.24, -1.24               ;@ 3d 01 c3 fe /4
        .f124 1.24, -1.24               ;@ 13 00 ed ff /4
        .f168 1.24, -1.24               ;@ 3d 01 00 c3 fe ff /6
        .f248 1.24, -1.24               ;@ 3d 01 00 00 c3 fe ff ff /8
        .f32  1.24, -1.24               ;@ 52 b8 9e 3f 52 b8 9e bf /8
        .word  1.24pf88, -1.24pf88      ;@ 3d 01 c3 fe /4
        .word  1.24pf124, -1.24pf124    ;@ 13 00 ed ff /4
        .long  1.24pf168, -1.24pf168    ;@ 3d 01 00 c3 fe ff /6
        .dword 1.24pf248, -1.24pf248    ;@ 3d 01 00 00 c3 fe ff ff /8
        .dword 1.24pf32, -1.24pf32      ;@ 81 1e b8 51 81 9e b8 51 /8
        .dword 0.5p32                   ;@ 00 00 00 80 /4   suffisso storico
        .u8  123                        ;@ 7b /1
        .s8  -123                       ;@ 85 /1
        .u16 123                        ;@ 7b 00 /2
        .s16 -123                       ;@ 85 ff /2
        .u24 123                        ;@ 7b 00 00 /3
        .s24 -123                       ;@ 85 ff ff /3
        .u32 123                        ;@ 7b 00 00 00 /4
        .s32 -123                       ;@ 85 ff ff ff /4
