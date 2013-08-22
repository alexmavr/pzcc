; function readInteger () : integer
; ---------------------------------
; This function reads an integer from the standard input
; and returns it.  A whole line (of up to MAXSTRING characters)
; is actually read by a call to readString.  Leading spaces are
; ommited.  If the line does not contain a valid number, 0 is
; returned (same behaviour as 'atoi' in C).


MAXSTRING     equ 256

xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public readInteger

readInteger   proc  near
              push  bp
              mov   bp, sp
              sub   sp, 1                    ; dummy space for the result

              mov   ax, MAXSTRING
              push  ax                       ; Pass MAXSTRING as 1st parameter
              lea   si, byte ptr buffer
              push  si                       ; Pass buffer as 2nd parameter
              sub   sp, 4                    ; 2 words for result & link
              call  near ptr readString     ; Read a string
              add   sp, 8
              
              mov   ax, OFFSET buffer        ; where to read it from
              push  ax
              push  word ptr [bp+6]          ; where to store it
              sub   sp, 1
              mov   si, sp
              mov   byte ptr [si], 10        ; base = 10
              lea   ax, byte ptr [bp-1]
              push  ax                       ; dummy: result
              push  bp                       ; dummy: access link
              call  near ptr parseInteger
              add   sp, 9
              
              mov   sp, bp
              pop   bp
              ret
readInteger   endp

buffer        db    MAXSTRING dup(?)

              extrn readString : proc
              extrn parseInteger : proc

xseg          ends
              end
