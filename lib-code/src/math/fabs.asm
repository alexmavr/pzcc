; function fabs (r : real) : real
; -------------------------------
; This function returns the absolute value of a real number.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              .8087

              public _fabs

_fabs         proc   near
              push   bp
              mov    bp, sp
              fld    tbyte ptr [bp+8]
              fabs
              mov    si, word ptr [bp+6]      ; store result
              fstp   tbyte ptr [si]
              pop    bp
              ret
_fabs         endp

xseg          ends
              end
