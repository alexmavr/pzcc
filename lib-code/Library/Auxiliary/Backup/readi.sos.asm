; function readInteger () : integer
; ---------------------------------
; This function reads an integer from the standard input
; and returns it.  A whole line (of up to MAXSTRING characters)
; is actually read by a call to readString.  Leading spaces are
; ommited.  If the line does not contain a valid number, 0 is
; returned (same behaviour as 'atoi' in C).


MAXSTRING    equ 256

xseg         segment public 'code'
             assume  cs:xseg, ds:xseg, ss:xseg

             public _readInteger

_readInteger proc  near
             push  bp
             mov   bp, sp
             mov   ax, MAXSTRING
             push  ax                       ; Pass MAXSTRING as 1st parameter
             lea   si, byte ptr inpstr
             push  si                       ; Pass inpstr as 2nd parameter
             sub   sp, 4                    ; 2 words for result & link
             call  near ptr _readString     ; Read a string
             add   sp, 8
             lea   si, byte ptr inpstr
             xor   ax, ax                   ; value = 0
             mov   bx, 10                   ; bx holds system base
             xor   cl, cl                   ; sign = POSITIVE
             mov   byte ptr sign, cl
loop1:
             mov   cl, byte ptr [si]        ; Skip leading blanks
             inc   si
             cmp   cl, 20h
             jz    loop1
             cmp   cl, 09h
             jz    loop1
             cmp   cl, '+'                  ; Check for sign +
             jnz   no_plus
             mov   cl, byte ptr [si]
             inc   si
             jmp   short no_minus
no_plus:
             cmp   cl, '-'                  ; Check for sign -
             jnz   no_minus
             mov   cl, 1                    ; sign = NEGATIVE
             mov   byte ptr sign, cl
             mov   cl, byte ptr [si]        ; Get the first character
             inc   si
no_minus:
             or    cl, cl                   ; Is it the end of the string ?
             jz    ok
             cmp   cl, '9'                  ; Is it a digit ?
             jg    ok
             sub   cl, '0'
             jl    ok
             xor   ch, ch                   ; If it is, update value
             imul  bx
             jc    overflow                 ; and check for overflow
             add   ax, cx
             jc    overflow
             mov   cl, byte ptr [si]        ; Get the next character
             inc   si
             jmp   no_minus
overflow:
             mov   ax, 7fffh                ; value = 32767
ok:
             mov   cl, byte ptr sign        ; If it is negative
             or    cl, cl
             jz    store
             neg   ax                       ; value = - value
store:
             mov   si, word ptr [bp+6]      ; Address of result
             mov   word ptr [si], ax        ; Store result
             pop   bp
             ret
_readInteger endp

sign         db    ?
inpstr       db    MAXSTRING dup(?)

             extrn _readString : proc

xseg         ends
             end
