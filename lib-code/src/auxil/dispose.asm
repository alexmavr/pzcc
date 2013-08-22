; [polymorphic in T]
; procedure _dispose (pointer : ^T)
; ---------------------------------
; This procedure deallocates the memory that is pointed to by the
; given pointer.  Undefined behaviour if this memory has not been
; allocated by a call to _new.

; KNOWN BUGS !!!
; 1. Does not deallocate :-)


xseg         segment   public 'code'
             assume    cs:xseg, ds:xseg, ss:xseg

             public    __dispose

__dispose    proc      near
             ret                ; do nothing !!!
__dispose    endp

xseg         ends
             end
