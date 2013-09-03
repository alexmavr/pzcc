; function trunc (r : real) : integer
; -----------------------------------
; This function converts a real number to an integer by truncating.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              .8087

FXTRUNC       MACRO
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

              public _trunc

_trunc        proc   near
              push   bp
              mov    bp, sp
              FXTRUNC                         ; truncate to zero
              fld    tbyte ptr [bp+8]         ; 1st parameter
              mov    si, word ptr [bp+6]      ; store result
              fistp  word ptr [si]
              pop    bp
              ret
_trunc        endp

tempw         dw     ?

xseg          ends
              end
