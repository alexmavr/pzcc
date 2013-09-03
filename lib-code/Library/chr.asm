; function chr (i : integer) : char
; ---------------------------------
; This function returns the character corresponding to an ASCII code.
; Only the lower 8 bits of the parameter are considered, thus the
; parameter should be a number between 0 and 255.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public _chr

_chr          proc   near
              push   bp
              mov    bp, sp
              mov    ax, word ptr [bp+8]      ; 1st parameter
              mov    si, word ptr [bp+6]      ; store result
              mov    byte ptr [si], al
              pop    bp
              ret
_chr          endp

xseg          ends
              end
