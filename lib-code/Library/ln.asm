; function ln (r : real) : real
; -----------------------------
; This function returns the natural logarithm of a real number.

; KNOWN BUGS !!!
; 1. Does not check anything.
; 2. Does not handle exceptions.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              .8087

              public _ln

_ln           proc   near
              push   bp
              mov    bp, sp
              fld1                            ; 1
              fldl2e                          ; 1, log2(e)
              fdivp  st(1), st(0)             ; 1/log2(e)
              fld    tbyte ptr [bp+8]         ; 1/log2(e), x
              fyl2x                           ; (1/log2(e)) * log2(x) == ln(x)
              mov    si, word ptr [bp+6]      ; store result
              fstp   tbyte ptr [si]
              pop    bp
              ret
_ln           endp

xseg          ends
              end
