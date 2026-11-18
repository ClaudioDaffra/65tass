"
" $Id$
" 
" Place it into this folder ~/.vim/syntax/
" Enable with: set syntax=64tass
"
" Options:
" let tass64_case_sensitive = 1 " Case sensitive or not
" let tass64_6502i = 1          " Use illegal opcodes
" let tass64_65dtv02 = 1        " Use dtv opcodes
" let tass64_65c02 = 1          " Use 65C02 opcodes
" let tass64_r65c02 = 1         " Use Rockwell 65C02 opcodes
" let tass64_w65c02 = 1         " Use WDC 65C02 opcodes
" let tass64_w65816 = 1         " Use WDC 65816 opcodes
" let tass64_65el02 = 1         " Use 65EL02 opcodes
" let tass64_65ce02 = 1         " Use 65CE02 opcodes
" let tass64_4510 = 1           " Use 4510 opcodes
" let tass64_45gs02 = 1         " Use 45GS02 opcodes

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

if !exists("tass64_case_sensitive")
    syn case ignore
endif

syn sync minlines=0

syn cluster tass64Statements contains=tass64Mne,tass64Macro,tass64Comment
syn cluster tass64Expression contains=tass64Float,tass64Dec,tass64Hex,tass64Bin,tass64Gap,tass64String,tass64String2,tass64Oper1,tass64Anon,tass64Ident,tass64MacroRef,tass64Comment
syn cluster tass64Expression2 contains=tass64Oper2,tass64Comment

" Line start
syn match tass64start /^/ skipwhite nextgroup=@tass64Statements,tass64Label

" Labels
syn match tass64Label /\v[[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>/ contained nextgroup=tass64Oper3
syn match tass64Label /\v[+-]%([ \t;]@=|$)|\*%([ \t;=]@=|$)/ skipwhite contained nextgroup=tass64Assign,@tass64Statements
syn match tass64Oper3 /:\?/ skipwhite contained nextgroup=tass64Assign,@tass64Statements
syn match tass64Oper3 /\./ contained nextgroup=tass64Label

" Assignments
syn match tass64Assign /\v%([<>*.:&|]{2}|[<>:]\?|[-+%*/^&|.x:])?\=/ skipwhite contained nextgroup=@tass64Expression

" Macro invocation
syn match tass64Macro /\v[#.][[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>/ skipwhite contained contains=tass64PreProc,tass64PreCondit,tass64Include,tass64Define,tass64Structure,tass64Type,tass64Debug nextgroup=@tass64Expression
syn match tass64Macro /\v[#.][[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>\.@=/ contained nextgroup=tass64Oper4
syn match tass64Macro2 /\v[[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>/ skipwhite contained nextgroup=@tass64Expression
syn match tass64Macro2 /\v[[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>\.@=/ contained nextgroup=tass64Oper4
syn match tass64Oper4 /\./ contained nextgroup=tass64Macro2

" Comment
syn keyword tass64Todo TODO FIXME XXX NOTE contained
syn region tass64Comment start=/;/ end=/$/ contained contains=@Spell,tass64Todo

" 6502 Mnemonics
syn match tass64Mne /\v%(a%(dc|nd|sl)|b%([cv][cs]|eq|mi|ne|pl|it|rk)|c%(l[cdiv]|mp|p[axy])|%(de|in)[cxy]|eor|j%(mp|sr)|l%(d[arxy]|sr)|nop|or[ar]|p%([lh][ap]|sh|ul)|r%(o[lr]|t[is])|s%(bc|e[cdi]|t[arxy])|t%(a[xy]|sx|x[as]|ya))>/ skipwhite contained nextgroup=@tass64Expression
" 6502 Mnemonic aliases
syn match tass64Mne /\v%(b%(ge|lt)|g%([cv][cs]|eq|ge|lt|mi|ne|pl)|sh[lr])>/ skipwhite contained nextgroup=@tass64Expression
" 6502 registers
syn keyword tass64Reg a x y s p contained
" 6502i opcodes
if exists("tass64_6502i")
    syn match tass64Mne /\v%(a%(n[ce]|[rs]r)|dcp|isb|jam|l%(ax|ds)|r[lr]a|s%([ab]x|h[asxy]|lo|re))>/ skipwhite contained nextgroup=@tass64Expression
    " 6502i opcode aliases
    syn match tass64Mne /\v%(a%(hx|lr|xs)|dcm|i%(ns|sc)|l%(a[es]|xa)|tas|xaa)>/ skipwhite contained nextgroup=@tass64Expression
endif
" 65dtv02 opcodes
if exists("tass64_65dtv02")
    syn match tass64Mne /\v%(a%(ne|rr|sr)|bra|dcp|isb|lax|r[lr]a|s%(a[cx]|ir|lo|re))>/ skipwhite contained nextgroup=@tass64Expression
    " 65dtv02 opcode aliases
    syn match tass64Mne /\v%(gra|alr|dcm|i%(ns|sc)|lxa|xaa)>/ skipwhite contained nextgroup=@tass64Expression
endif
" 65c02 opcodes
if exists("tass64_65c02") || exists("tass64_r65c02") || exists("tass64_w65c02") || exists("tass64_w65816") || exists("tass64_65el02")
    syn match tass64Mne /\v%(bra|p%([hl][xy])|stz|t[rs]b)>/ skipwhite contained nextgroup=@tass64Expression
    " 65dtv02 opcode aliases
    syn match tass64Mne /\v%(clr|dea|gra|ina)>/ skipwhite contained nextgroup=@tass64Expression
    " 65c02 registers
    syn keyword tass64Reg z contained
endif
" r65c02 opcodes
if exists("tass64_r65c02") || exists("tass64_w65c02") 
    syn match tass64Mne /\v%(bb[rs]|[rs]mb)>/ skipwhite contained nextgroup=@tass64Expression
endif
" w65c02 opcodes
if exists("tass64_w65c02") || exists("tass64_w65816")
    syn match tass64Mne /\v%(stp|wai)>/ skipwhite contained nextgroup=@tass64Expression
    " w65c02 opcode aliases
    syn match tass64Mne /\vhlt>/ skipwhite contained nextgroup=@tass64Expression
endif
" w65816 opcodes
if exists("tass64_w65816")
    syn match tass64Mne /\v%(brl|cop|jsl|mv[np]|p%(e[air]|h[bdk]|l[bd])|r%(ep|tl)|sep|t%(c[ds]|[ds]c|xy|yx)|x%(ba|ce))>/ skipwhite contained nextgroup=@tass64Expression
    " w65816 opcode aliases
    syn match tass64Mne /\v%(c%(sp|lp)|jml|swa|t%(a[ds]|[ds]a))>/ skipwhite contained nextgroup=@tass64Expression
    " 65816 registers
    syn keyword tass64Reg b d k contained
endif
" 65el02 opcodes
if exists("tass64_65el02")
    syn match tass64Mne /\v%(div|ent|m%(mu|ul)|nx[at]|pe[air]|p[hl]d|r%(e[aipr]|[hl][aixy]|sh|ul)|s%(e[ap]|tp)|t%(ad|da|[ir]x|x[ir]|xy|yx)|wai|x%(ba|ce)|zea)>/ skipwhite contained nextgroup=@tass64Expression
    " 65el02 opcode aliases
    syn match tass64Mne /\v%(clp|hlt|swa)>/ skipwhite contained nextgroup=@tass64Expression
    " 65el02 registers
    syn keyword tass64Reg d r i contained
endif
" 65ce02 opcodes
if exists("tass64_65ce02") || exists("tass64_4510") || exists("tass64_45gs02")
    syn match tass64Mne /\v%(as[rw]|b%(b[rs]|ra|sr)|c%(le|pz)|de[wz]|in[wz]|ldz|neg|p%([hl][xyz]|hw)|r%(mb|ow)|s%(mb|ee|tz)|t%(a[dz]|[dz]a|[rs]b|sy|ys))>/ skipwhite contained nextgroup=@tass64Expression
    " 65ce02 opcode aliases
    syn match tass64Mne /\v%(dea|gra|ina|r%(tn|lw)|t%(ab|ba))>/ skipwhite contained nextgroup=@tass64Expression
    " 65ce02 registers
    syn keyword tass64Reg b d z contained
endif
" 4510 opcodes
if exists("tass64_4510") || exists("tass64_45gs02")
    syn match tass64Mne /\v%(map|eom)>/ skipwhite contained nextgroup=@tass64Expression
endif
" 45gs02 opcodes
if exists("tass64_45gs02")
    syn match tass64Mne /\v%(a%([dn]q|[rs]d)|btq|cpq|de[qd]|eoq|in[qd]|l%(dq|sd)|orq|r[lr]d|s[bt]q)>/ skipwhite contained nextgroup=@tass64Expression
    " 45gs02 registers
    syn keyword tass64Reg q contained
endif

syn match tass64Label /\v[a-z]{3}\ze[:.]/ contained nextgroup=tass64Oper3

" Assembler directives
syn match tass64PreProc /\v\.%(al|align|as|autsiz|bend|block|endblock|alignblk|endalignblk|alignpageind|alignind|cdef|cpu)>/ contained
syn match tass64PreProc /\v\.%(databank|dpage|dsection|edef|encode|enc|end|endpage|endp)>/ contained
syn match tass64PreProc /\v\.%(endweak|eor|for|bfor|goto|from|here|endlogical|hidemac)>/ contained
syn match tass64PreProc /\v\.%(lbl|logical|mansiz|next|endfor|endrept|endwhile|virtual|endv|endvirtual)>/ contained
syn match tass64PreProc /\v\.%(offs|option|page|pend|proc|endproc|proff|pron|rept|brept|while|bwhile|section|endsection)>/ contained
syn match tass64PreProc /\v\.%(seed|send|showmac|tdef|var|weak|xl|xs|namespace|endnamespace|endn|with|endwith|endencode)>/ contained
syn match tass64Define  /\v\.%(segment|endsegment|macro|endmacro|endm|function|endfunction|endf|sfunction)>/ contained
syn match tass64Include /\v\.%(include|binclude)>/ contained
syn match tass64PreCondit /\v\.%(elif|elsif|ifmi|ifne|ifpl|else|fi|if|ifeq|endif|switch|endswitch|case|default|comment|endcomment|endc|breakif|continueif|break|continue)>/ contained
syn match tass64Structure /\v\.%(union|endunion|endu|struct|endstruct|ends|dstruct|dunion)>/ contained
syn match tass64Debug /\v\.%(error|cwarn|warn|cerror|check|assert)>/ contained

" Data statements
syn match tass64Type    /\v\.%(addr|binary|byte|char|dint|lint|dword|fill|long|null)>/ contained
syn match tass64Type    /\v\.%(ptext|rta|shift|shiftl|sint|text|word)>/ contained

" String escapes
syn match tass64Escapes /\C{space}/ contained conceal cchar= 
syn match tass64Escapes /\C{cbm-9}/ contained conceal cchar=)
syn match tass64Escapes /\C{cbm-0}/ contained conceal cchar=0
syn match tass64Escapes /\C{shift-0}/ contained conceal cchar=0
syn match tass64Escapes /\C{shift-1}/ contained conceal cchar=!
syn match tass64Escapes /\C{shift-2}/ contained conceal cchar="
syn match tass64Escapes /\C{shift-3}/ contained conceal cchar=#
syn match tass64Escapes /\C{shift-4}/ contained conceal cchar=$
syn match tass64Escapes /\C{shift-5}/ contained conceal cchar=%
syn match tass64Escapes /\C{shift-6}/ contained conceal cchar=&
syn match tass64Escapes /\C{shift-7}/ contained conceal cchar='
syn match tass64Escapes /\C{shift-8}/ contained conceal cchar=(
syn match tass64Escapes /\C{shift-9}/ contained conceal cchar=)
syn match tass64Escapes /\C{shift-,}/ contained conceal cchar=<
syn match tass64Escapes /\C{shift-\.}/ contained conceal cchar=>
syn match tass64Escapes /\C{shift-\/}/ contained conceal cchar=?
syn match tass64Escapes /\C{shift-:}/ contained conceal cchar=[
syn match tass64Escapes /\C{shift-;}/ contained conceal cchar=]
if &enc == 'utf-8'
    syn match tass64Escapes /\C{pound}/ contained conceal cchar=£
    syn match tass64Escapes /\C{up arrow}/ contained conceal cchar=↑
    syn match tass64Escapes /\C{left arrow}/ contained conceal cchar=←
    syn match tass64Escapes /\C{cbm-a}/ contained conceal cchar=┌
    syn match tass64Escapes /\C{shift--}/ contained conceal cchar=│
    syn match tass64Escapes /\C{shift-+}/ contained conceal cchar=┼
    syn match tass64Escapes /\C{shift-\*}/ contained conceal cchar=─
    syn match tass64Escapes /\C{shift-a}/ contained conceal cchar=♠
    syn match tass64Escapes /\C{shift-i}/ contained conceal cchar=╮
    syn match tass64Escapes /\C{shift-j}/ contained conceal cchar=╰
    syn match tass64Escapes /\C{shift-k}/ contained conceal cchar=╯
    syn match tass64Escapes /\C{shift-m}/ contained conceal cchar=╲
    syn match tass64Escapes /\C{shift-n}/ contained conceal cchar=╱
    syn match tass64Escapes /\C{shift-q}/ contained conceal cchar=●
    syn match tass64Escapes /\C{shift-s}/ contained conceal cchar=♥
    syn match tass64Escapes /\C{shift-u}/ contained conceal cchar=╭
    syn match tass64Escapes /\C{shift-v}/ contained conceal cchar=╳
    syn match tass64Escapes /\C{shift-w}/ contained conceal cchar=○
    syn match tass64Escapes /\C{shift-x}/ contained conceal cchar=♣
    syn match tass64Escapes /\C{shift-z}/ contained conceal cchar=♦
    syn match tass64Escapes /\C{cbm-q}/ contained conceal cchar=├
    syn match tass64Escapes /\C{cbm-w}/ contained conceal cchar=┤
    syn match tass64Escapes /\C{cbm-z}/ contained conceal cchar=└
    syn match tass64Escapes /\C{cbm-s}/ contained conceal cchar=┐
    syn match tass64Escapes /\C{cbm-x}/ contained conceal cchar=┘
    syn match tass64Escapes /\C{cbm-e}/ contained conceal cchar=┴
    syn match tass64Escapes /\C{cbm-r}/ contained conceal cchar=┬
    syn match tass64Escapes /\C{cbm-d}/ contained conceal cchar=▗
    syn match tass64Escapes /\C{cbm-f}/ contained conceal cchar=▖
    syn match tass64Escapes /\C{cbm-c}/ contained conceal cchar=▝
    syn match tass64Escapes /\C{cbm-v}/ contained conceal cchar=▘
    syn match tass64Escapes /\C{cbm-b}/ contained conceal cchar=▚
    syn match tass64Escapes /\C{cbm-k}/ contained conceal cchar=▌
    syn match tass64Escapes /\C{cbm-j}/ contained conceal cchar=▍
    syn match tass64Escapes /\C{cbm-h}/ contained conceal cchar=▎
    syn match tass64Escapes /\C{cbm-g}/ contained conceal cchar=▏
    syn match tass64Escapes /\C{cbm-m}/ contained conceal cchar=▕
    syn match tass64Escapes /\C{cbm-t}/ contained conceal cchar=▔
    syn match tass64Escapes /\C{cbm-i}/ contained conceal cchar=▄
    syn match tass64Escapes /\C{cbm-o}/ contained conceal cchar=▃
    syn match tass64Escapes /\C{cbm-p}/ contained conceal cchar=▂
    syn match tass64Escapes /\C{cbm-@}/ contained conceal cchar=▁
    syn match tass64Escapes /\C{cbm-+}/ contained conceal cchar=▒
    syn match tass64Escapes /\C{pi}/ contained conceal cchar=π
endif
" String formatting
syn match tass64Escapes5 "%%" contained conceal cchar=%
syn match tass64Escapes5 "\C%[-+' #0*]*\(\d*\|\*\)\(\.\(\d*\|\*\)\)\=[AabdxXFfeEgGcCsS]" contained

syn match tass64Escapes1 /''/ contained conceal cchar='
syn match tass64Escapes2 /""/ contained conceal cchar="
syn match tass64Escapes3 /''/ contained conceal cchar='
syn match tass64Escapes3 /{[^}']*}/ contains=tass64Escapes contained
syn match tass64Escapes4 /""/ contained conceal cchar="
syn match tass64Escapes4 /{[^}"]*}/ contains=tass64Escapes contained

syn match tass64Delimiter /_/ contained
syn match tass64Expo    /\v[ep]/ contained
syn match tass64Bin     /\v\%%(%([01]_+)+[01]|[01])+>\.@!/ skipwhite contained contains=tass64Delimiter nextgroup=@tass64Expression2
syn match tass64Dec     /\v%(%(\d_+)+\d|\d)+>\.@!/ skipwhite contained contains=tass64Delimiter nextgroup=@tass64Expression2
syn match tass64Hex     /\v\$%(%(\x_+)+\x|\x)+>\.@!/ skipwhite contained contains=tass64Delimiter nextgroup=@tass64Expression2
syn match tass64Ident   /\v\.@<=[[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>/ skipwhite contained nextgroup=@tass64Expression2
syn match tass64Ident   /\v\.@<![[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>/ skipwhite contained contains=tass64Reg,tass64Function,tass64Const nextgroup=@tass64Expression2
syn match tass64Gap     /\v\?/ skipwhite contained nextgroup=@tass64Expression2
syn match tass64Float   /\v\%%(%(\.%(%([01]_+)+[01]|[01])+|%(%([01]_+)+[01]|[01])+\.\.@!%(%([01]_+)+[01]|[01])*)%([ep][+-]?%(%(\d_+)+\d|\d)+)?|%(%([01]_+)+[01]|[01])+[ep][+-]?%(%(\d_+)+\d|\d)+)/ skipwhite contained contains=tass64Expo,tass64Delimiter nextgroup=@tass64Expression2
syn match tass64Float   /\v\$%(%(\.%(%(\x_+)+\x|\x)+|%(%(\x_+)+\x|\x)+\.\.@!%(%(\x_+)+\x|\x)*)%(p[+-]?%(%(\d_+)+\d|\d)+)?|%(%(\x_+)+\x|\x)+p[+-]?%(%(\d_+)+\d|\d)+)/ skipwhite contained contains=tass64Expo,tass64Delimiter nextgroup=@tass64Expression2
syn match tass64Float   /\v%(\.%(%(\d_+)+\d|\d)+|%(%(\d_+)+\d|\d)+\.\.@!%(%(\d_+)+\d|\d)*)%([ep][+-]?%(%(\d_+)+\d|\d)+)?|%(%(\d_+)+\d|\d)+[ep][+-]?%(%(\d_+)+\d|\d)+/ skipwhite contained contains=tass64Expo,tass64Delimiter nextgroup=@tass64Expression2
syn match tass64String2  /[bnlspxz]\ze['"]/ contained nextgroup=tass64String
syn region tass64String  start=/'/ skip=/''/ end=/'/ oneline skipwhite contained contains=tass64Escapes5,tass64Escapes3 nextgroup=@tass64Expression2
syn region tass64String  start=/"/ skip=/""/ end=/"/ oneline skipwhite contained contains=tass64Escapes5,tass64Escapes4 nextgroup=@tass64Expression2
syn region tass64String  start=/[xz]'/ skip=/''/ end=/'/ oneline skipwhite contained contains=tass64Escapes1 nextgroup=@tass64Expression2
syn region tass64String  start=/[xz]"/ skip=/""/ end=/"/ oneline skipwhite contained contains=tass64Escapes2 nextgroup=@tass64Expression2

" Macro parameter reference
syn match tass64MacroRef /\v\\%([@1-9]>|[[:lower:][:upper:]_][[:lower:][:upper:]0-9_]*>|\{[^}]*\})/ skipwhite contained nextgroup=@tass64Expression2

" Operators
syn match tass64Oper1   /\v[#!~<>`^([{:]|([-+*])%(\1|\s*[)\]};,:]|\s*$)@!/ skipwhite contained nextgroup=@tass64Expression
syn match tass64Oper1   /\v[)\]}]/ skipwhite contained nextgroup=@tass64Expression2
syn match tass64Oper1   /\v\.[-+(\*[:lower:][:upper:]_]@=/ contained nextgroup=@tass64Expression

syn match tass64Oper2   /\v[<>&^|*.]{2}|[>=<!]\=|[><?]\?|[-+/*%^|&,.?:<>=[(]|%(!?in|x)>/ skipwhite contained nextgroup=@tass64Expression
syn match tass64Oper2   /\v([<>&|*.:]{2})\=|[=!]\=\=|[><:]\?\=|[-+/*%^|&:x.]\=/ skipwhite contained nextgroup=@tass64Expression
syn match tass64Oper2   /\v,[xyzrsdbk]>|[\])}]/ skipwhite contained nextgroup=@tass64Expression2

syn match tass64Anon    /\v%(\++|-+|\*|\.\.\.)%(\s*[),;.\]}!=<>:+/*%|&^-]|\s*$)@=/ skipwhite contained nextgroup=@tass64Expression2

" Functions
syn keyword tass64Function abs acos all any asin atan atan2 binary cbrt ceil cos cosh deg exp floor format frac hypot len log log10 pow rad random range repr round sign sin sinh size sort sqrt tan tanh trunc byte char rta addr word sint long lint dword dint contained
syn keyword tass64Function address bits bool bytes code dict float gap int list str tuple type contained

" Predefined constants
syn keyword tass64Const    true false pi contained

" Colors
hi link tass64Mne       Statement
hi link tass64Reg       Statement
hi link tass64PreProc   PreProc
hi link tass64PreCondit PreCondit
hi link tass64Define    Define
hi link tass64Include   Include
hi link tass64Structure Structure
hi link tass64Type      Type
hi link tass64Todo      Todo
hi link tass64Comment   Comment
hi link tass64Bin       Number
hi link tass64Float     Float
hi link tass64Dec       Number
hi link tass64Hex       Number
hi link tass64Gap       Number
hi link tass64Const     Number
hi link tass64String    String
hi link tass64String2   String
hi link tass64Macro     Macro
hi link tass64Macro2    Macro
hi link tass64Ident     Identifier
hi link tass64Anon      Identifier
hi link tass64MacroRef  PreProc
hi link tass64Escapes   SpecialChar
hi link tass64Escapes1  SpecialChar
hi link tass64Escapes2  SpecialChar
hi link tass64Escapes3  SpecialChar
hi link tass64Function  Function
hi link tass64Expo      Float
hi link tass64Delimiter Delimiter
hi link tass64Debug     Debug

let b:current_syntax = "64tass"

