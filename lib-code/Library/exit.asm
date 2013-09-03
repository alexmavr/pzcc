; procedure exit (code : integer)
; -------------------------------
; This procedure aborts execution of the program by returning
; the given exit code to the operating system.  It never returns.
; Only the 8 lower bits of the exit code are considered, thus
; the exit code should be a number between 0 and 255.


xseg         segment   public 'code'
             assume    cs:xseg, ds:xseg, ss:xseg

             public    _exit

_exit        proc      near
             push      bp
             mov       bp, sp
             mov       ah, 4Ch
             mov       al, byte ptr [bp+8]
             int       21h
_exit        endp

xseg         ends
             end
