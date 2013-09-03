; function arctan (r : real) : real
; ---------------------------------
; This function returns the arc tangent of a real number.

; KNOWN BUGS !!!
; 1. Does not handle exceptions.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              .8087

              public _arctan

_arctan       proc   near
              push   bp
              mov    bp, sp
              fld    tbyte ptr [bp+8]
              fld1
              fpatan
              mov    si, word ptr [bp+6]      ; store result
              fstp   tbyte ptr [si]
              pop    bp
              ret
_arctan       endp

xseg          ends
              end
