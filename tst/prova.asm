

*       = $0801
        .word (+), 2005  ;pointer, line number
        .null $9e, format("%4d", start);will be sys 4096
+       .word 0          ;basic line end


	xx .f88 1.24
	
	a	.f88  1.24, -1.24 ;	-> 3D 01  C3 FE
	b	.f124 1.24, -1.24 ;	-> 13 00  ED FF
	c	.f168 1.24, -1.24 ;	-> 3D 01 00  C3 FE FF
	d	.f248 1.24, -1.24 ;	-> 3D 01 00 00  C3 FE FF FF
	e	.f32  1.24, -1.24 ;	-> 52 B8 9E 3F  52 B8 9E BF

	f	.dword	1.24p8 ;

	a1	.word  	1.24pf88		, -1.24pf88 ;	-> 3D 01  C3 FE
	b2	.word 	1.24pf124	, -1.24pf124 ;	-> 13 00  ED FF
	c3	.long 	1.24pf168	, -1.24pf168 ;	-> 3D 01 00  C3 FE FF
	d4	.dword 	1.24pf248	, -1.24pf248 ;	-> 3D 01 00 00  C3 FE FF FF
	e5	.dword  1.24pf32	, -1.24pf32 ;	-> 81 1E B8 51  81 9E B8 51
	p32_compat .dword 0.5p32              ;	-> 00 00 00 80
	
	i8	.byte	123
	i16	.word	123
	i24	.long	123
	i32	.dword	123

	ii8		.char	-123
	ii16	.sint	-123
	ii24	.lint	-123
	ii32	.dint	-123

	si8		.s8	-123
	si16	.s16	-123
	si24	.s24	-123
	si32	.s32	-123
	
start   
	nop
	rts
