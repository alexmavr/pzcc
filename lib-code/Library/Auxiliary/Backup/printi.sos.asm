; procedure writeInteger (i : integer)
; ------------------------------------
; This procedure prints an integer to the standard output.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public _writeInteger

_writeInteger proc  near
              push  bp
              mov   bp, sp
              mov   ax, word ptr [bp+8]      ; 1st parameter
              or    ax, ax                   ; If it is negative
              jge   non_neg
              push  ax                       ; Print a minus sign
              mov   dl, '-'
              mov   ah, 02h
              int   21h
              pop   ax
              neg   ax                       ; i = -i
              jmp   short positive
non_neg:
              jnz   positive                 ; If it is zero
              mov   dl, '0'                  ; Print 0
              mov   ah, 02h
              int   21h
              jmp   short ok
positive:
              mov   si, 5                    ; si holds index in buffer
              mov   bx, 10                   ; bx holds system base
next:
              or    ax, ax                   ; If 0 then finished
              jz    print
              xor   dx, dx                   ; Divide with system base
              div   bx
              add   dl, '0'                  ; Calculate next digit
              dec   si                       ; Store digits in buffer
              mov   byte ptr digit[si], dl   ; in reverse order
              jmp   short next
print:
              mov   dl, byte ptr digit[si]   ; Print digit
              push  si
              mov   ah, 02h
              int   21h
              pop   si
              inc   si
              cmp   si, 5
              jb    print
ok:
              pop   bp
              ret
_writeInteger endp

digit         db    5 dup(?)

xseg          ends
              end
