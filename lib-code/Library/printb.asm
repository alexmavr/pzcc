; procedure writeBoolean (b : boolean)
; ------------------------------------
; This function prints a boolean to the standard output.
; One of the strings 'true' and 'false' is printed.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public _writeBoolean

_writeBoolean proc  near
              push  bp
              mov   bp, sp
              mov   al, byte ptr [bp+8]      ; 1st parameter
              or    al, al                   ; True if non zero
              jnz   par_true
              lea   dx, byte ptr str_false   ; Print 'false'
              mov   ah, 09h
              int   21h
              jmp   short ok
par_true:
              lea   dx, byte ptr str_true    ; Print 'true'
              mov   ah, 09h
              int   21h
ok:
              pop   bp
              ret
_writeBoolean endp

; These are the strings that will be printed
; DOS int 21h, function 09h requires a '$' at the end.

str_false     db    'false'
              db    '$'
str_true      db    'true'
              db    '$'

xseg          ends
              end
