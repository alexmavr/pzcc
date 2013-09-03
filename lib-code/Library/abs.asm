; function abs (i : integer) : integer
; ------------------------------------
; This function returns the absolute value of an integer.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public _abs

_abs          proc   near
              push   bp
              mov    bp, sp
              mov    ax, word ptr [bp+8]      ; 1st parameter
              or     ax, ax                   ; If it is negative
              jge    ok
              neg    ax                       ; i = -i
ok:
              mov    si, word ptr [bp+6]      ; store result
              mov    word ptr [si], ax
              pop    bp
              ret
_abs          endp

xseg          ends
              end
