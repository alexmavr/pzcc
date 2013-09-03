; procedure writeInteger (i : integer)
; ------------------------------------
; This procedure prints an integer to the standard output.


xseg          segment public 'code'
              assume  cs:xseg, ds:xseg, ss:xseg

              public writeInteger

writeInteger  proc  near
              push  bp
              mov   bp, sp
              sub   sp, 1                ; dummy space for the result
              
              mov   ax, OFFSET buffer    ; where to store it
              push  ax
              push  word ptr [bp+8]      ; 1st parameter (the number)
              mov   ax, 0000h            ; width = 0, flags = 0
              push  ax
              sub   sp, 1
              mov   si, sp
              mov   byte ptr [si], 10    ; base = 10
              lea   ax, byte ptr [bp-1]
              push  ax                   ; dummy: result
              push  bp                   ; dummy: access link
              call  near ptr formatInteger
              add   sp, 11
              
              mov   ax, OFFSET buffer    ; what to print
              push  ax
              sub   sp, 2                ; dummy: result
              push  bp                   ; dummy: access link
              call  near ptr writeString
              add   sp, 6

              mov   sp, bp
              pop   bp
              ret
writeInteger  endp

buffer        db    6 dup(?)

              extrn formatInteger : proc
              extrn writeString : proc

xseg          ends
              end
