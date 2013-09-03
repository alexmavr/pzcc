; function readReal () : real
; ---------------------------
; This function reads a real number from the standard input
; and returns it.  A whole line (of up to MAXSTRING characters)
; is actually read by a call to readString.  Leading spaces are
; ommited.  If the line does not contain a valid number, 0.0 is
; returned (same behaviour as 'atof' in C).

; NOT READY YET: RETURNS 0.0 ANYWAY !!!


xseg         segment public 'code'
             assume  cs:xseg, ds:xseg, ss:xseg

              .8087

MAXSTRING    equ 256

             public _readReal

_readReal    proc  near
             push  bp
             mov   bp, sp
             mov   ax, MAXSTRING
             push  ax                       ; Pass MAXSTRING as 1st parameter
             lea   si, byte ptr inpstr
             push  si                       ; Pass inpstr as 2nd parameter
             sub   sp, 4                    ; 2 words for result & link
             call  near ptr _readString     ; Read a string
             add   sp, 8
store:
             mov   si, word ptr [bp+6]      ; Address of result
	     fldz                           ; Always return 0.0 !!!
	     fstp  tbyte ptr [si]           ; Store result
             pop   bp
             ret
_readReal    endp

sign         db    ?
inpstr       db    MAXSTRING dup(?)

             extrn _readString : proc

xseg         ends
             end
