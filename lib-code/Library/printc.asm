; procedure writeChar (c : char)
; ------------------------------
; This procedure prints a character to the standard output.


xseg        segment public 'code'
            assume  cs:xseg, ds:xseg, ss:xseg

            public _writeChar

_writeChar  proc  near
            push  bp
            mov   bp, sp
            mov   dl, byte ptr [bp+8]      ; 1st parameter
            or    dl, dl                   ; ignore high order byte
            jz    ok                       ; if 0, then ok
            cmp   dl, 0Ah
            jnz   normal                   ; if not '\n', no problem
            push  dx
            mov   dl, 0Dh
            mov   ah, 02h
            int   21h                      ; else, print also '\r'
            pop   dx
normal:
            mov   ah, 02h
            int   21h
ok:
            pop   bp
            ret
_writeChar  endp

xseg        ends
            end
