; procedure writeReal (r : real)
; ------------------------------
; This procedure prints a real number to the standard output.
;
; NOT READY YET: JUST PRINTS SMALL RANGE !!!


xseg         segment public 'code'
             assume  cs:xseg, ds:xseg, ss:xseg

             .8087

FXFLG        MACRO
IF ((@CPU AND 00FFh) LT 7)
             fstsw word ptr tempw
             mov   ax, word ptr tempw
ELSE
             fstsw ax
ENDIF
             sahf
             ENDM

FXTRUNC      MACRO
IF ((@CPU AND 00FFh) LT 7)
             fstcw word ptr tempw
             mov   ax, word ptr tempw
ELSE
             fstcw ax
ENDIF
             and   ax, 0F3FFh
             or    ax, 0C00h
             mov   word ptr tempw, ax
             fldcw word ptr tempw
             ENDM

MAX          equ   20

             public _writeReal

_writeReal   proc  near
             push  bp
             mov   bp, sp

             mov   si, 0
             fld   tbyte ptr [bp+8]         ; 1st parameter
             ftst                           ; check if zero
             FXFLG
             jnz   nonzero
             mov   byte ptr place[si], '0'  ; print '0'
             inc   si
             jmp   short print
nonzero:
             jg    positive                 ; check if negative
             mov   byte ptr place[si], '-'  ; print '-'
             inc   si
             fchs                           ; change to positive
positive:
             FXTRUNC                        ; truncate to zero
             fld   tbyte ptr ten5           ; st = x, 1e5
             fdivp ST(1), ST(0)             ; st = 1e-5 * x
             mov   cx, 10
again:
             fld   tbyte ptr ten1           ; st = 1e-{5-n} * x, 1e1
             fmulp ST(1), ST(0)             ; st = 1e-{4-n} * x
             fld   ST(0)                    ; st = 1e-{4-n} * x, 1e-{4-n} * x
             frndint                        ; st = 1e-{4-n} * x, [1e-{4-n} * x]
             fist  word ptr tempw
             fsubp ST(1), ST(0)             ; st = 1e-{4-n} * x - [1e-{4-n} * x]
             mov   al, byte ptr tempw
             add   al, '0'
             mov   byte ptr place[si], al
             inc   si
             dec   cx
             jnz   again
print:
             mov   byte ptr place[si], 0
             mov   si, 0
printmore:
             mov   dl, byte ptr place[si]   ; Print character
             or    dl, dl
             jz    ok
             push  si
             mov   ah, 02h
             int   21h
             pop   si
             inc   si
             jmp   short printmore
ok:
             pop   bp
             ret
_writeReal   endp

ten5         dt    1e5
ten1         dt    1e1
place        db    MAX dup(?)
tempw        dw    ?

xseg         ends
             end
