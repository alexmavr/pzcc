; function ord (c : char) : integer
; ---------------------------------
; This function returns the ASCII code of a character.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public _ord

_ord          proc   near
              push   bp
              mov    bp, sp
              mov    al, byte ptr [bp+8]      ; 1st parameter
              xor    ah, ah
              mov    si, word ptr [bp+6]      ; store result
              mov    word ptr [si], ax
              pop    bp
              ret
_ord          endp

xseg          ends
              end
