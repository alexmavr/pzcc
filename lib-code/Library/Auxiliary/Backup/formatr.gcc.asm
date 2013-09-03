; function formatReal (var buffer : array of char; r : real;
;                      width, precision, flags, base : byte) : byte
; ----------------------------------------------------------------
; This procedure formats a real number for printing.


xseg           segment public 'code'
               assume  cs:xseg, ds:xseg, ss:xseg

               .286
               .8087

               public _formatReal

SPACEPAD_CHAR        equ  ' '
POINT_CHAR           equ  '.'
EXPONENT_LOWER_CHAR  equ  'e'
EXPONENT_UPPER_CHAR  equ  'E'

FLAG_LEFTALIGN equ    01h
FLAG_ZEROPAD   equ    02h
FLAG_FORCESIGN equ    04h
FLAG_NOSIGNEXP equ    08h
FLAG_FORMAT    equ    30h
FLAG_FIXED     equ    00h
FLAG_EXPON     equ    10h
FLAG_SMART     equ    20h
FLAG_UPPERCASE equ    40h

_formatReal    proc   near
               push   bp
               mov    bp, sp
               sub    sp, 70

               mov    dl, byte ptr [bp+9]
               mov    byte ptr [bp-17], dl
               mov    dx, word ptr [bp+22]
               fld    tbyte ptr [bp+12]
               mov    bl, byte ptr [bp+11]
               mov    al, byte ptr [bp+8]
               mov    byte ptr [bp-18], 0
               mov    word ptr [bp-23], dx
               sub    sp, 10
               fld    st(0)
               mov    ax, di
               mov    di, sp
               fstp   tbyte ptr [di]
               mov    di, ax
               fstp   tbyte ptr [bp-48]
               call   _isinf
               add    sp, 10
               fld    tbyte ptr [bp-48]
               test   al, al
               je     L5
               fldz
               fcompp
               fnstsw ax
               and    ah, 69
               jne    L6
               mov    byte ptr [bp-18], '-'
L6:
               mov    word ptr [bp-20], OFFSET stringInf
               jmp    L105
L5:
               sub    sp, 10
               fld    st(0)
               mov    ax, di
               mov    di, sp
               fstp   tbyte ptr [di]
               mov    di, ax
               fstp   tbyte ptr [bp-48]
               call   _isnan
               add    sp, 10
               fld    tbyte ptr [bp-48]
               test   al, al
               je     L8
               fstp   st(0)
               mov    word ptr [bp-20], OFFSET stringNaN
L105:
               mov    byte ptr [bp-25], 3
               xor    dx, dx
               mov    dl, bl
               mov    word ptr [bp-34], dx
               mov    al, byte ptr [bp-17]
               mov    byte ptr [bp-32], al
               and    byte ptr [bp-32], FLAG_LEFTALIGN
               jmp    L7
L8:
               xor    ax, ax
               mov    al, byte ptr [bp+8]
               mov    word ptr [bp-2], ax
               fild   word ptr [bp-2]
               fld1
               fld    st(0)
               fdivp  st(2), st
               mov    word ptr [bp-27], 0
               mov    word ptr [bp-36], ax
               fldz
               fcom   st(3)
               fnstsw ax
               and    ah, 69
               jne    L10
               fxch   st(3)
               fchs
               fxch   st(3)
               mov    byte ptr [bp-18], '-'
L10:
               xor    cx, cx
               mov    cl, byte ptr [bp+10]
               mov    si, OFFSET digitsL
               lea    dx, tbyte ptr [bp-16]
               mov    word ptr [bp-31], dx
               xor    ax, ax
               mov    al, bl
               mov    word ptr [bp-34], ax
               fcomp  st(3)
               fnstsw ax
               and    ah, 69
               cmp    ah, 1
               jne    L109
               xor    bx, bx
               mov    bl, byte ptr [bp+8]
               fldz
               jmp    L13
L111:
               fxch   st(3)
L13:
               fxch   st(3)
               fcom   st(1)
               fnstsw ax
               and    ah, 5
               jne    L14
               mov    word ptr [bp-4], bx
               fild   word ptr [bp-4]
               mov    dx, 1
               fcom   st(1)
               fnstsw ax
               and    ah, 69
               dec    ah
               cmp    ah, 64
               jae    L16
L17:
               fmul   st, st(0)
               add    dx, dx
               fcom   st(1)
               fnstsw ax
               and    ah, 69
               dec    ah
               cmp    ah, 64
               jb     L17
L16:
               fdivrp st(1), st
               add    word ptr [bp-27], dx
               jmp    L11
L14:
               fcom   st(2)
               fnstsw ax
               and    ah, 69
               cmp    ah, 1
               jne    L110
               mov    dx, 1
               fld    st(2)
L23:
               fmul   st, st(0)
               add    dx, dx
               fcom   st(1)
               fnstsw ax
               and    ah, 69
               je     L23
               fdivrp st(1), st
               sub    word ptr [bp-27], dx
L11:
               fcom   st(3)
               fnstsw ax
               and    ah, 69
               je     L111
               jmp    L110
L109:
               fstp   st(0)
               fstp   st(0)
               jmp    L12
L110:
               fstp   st(1)
               fstp   st(1)
               fstp   st(1)
L12:
               cmp    word ptr [bp-27], 255
               jg     L28
               mov    al, byte ptr [bp-17]
               and    al, FLAG_FORMAT
               cmp    al, FLAG_SMART
               jne    L29
               mov    ax, word ptr [bp-27]
               add    ax, 4
               cmp    ax, 10
               jbe    L27
L28:
               and    byte ptr [bp-17], NOT FLAG_FORMAT
               or     byte ptr [bp-17], FLAG_EXPON
               jmp    L29
L27:
               and    byte ptr [bp-17], NOT FLAG_FORMAT
               or     byte ptr [bp-17], FLAG_FIXED
L29:
               mov    dl, byte ptr [bp-17]
               test   dl, FLAG_FORCESIGN
               je     L31
               cmp    byte ptr [bp-18], '-'
               je     L31
               mov    byte ptr [bp-18], '+'
L31:
               mov    al, byte ptr [bp-17]
               and    al, FLAG_FORMAT
               xor    dx, dx
               mov    dl, al
               mov    byte ptr [bp-37], al
               test   dx, dx
               je     L33
               cmp    dx, FLAG_EXPON
               je     L34
               jmp    L32
L33:
               mov    di, word ptr [bp-27]
               jmp    L32
L34:
               mov    di, 1
               dec    word ptr [bp-27]
L32:
               mov    bx, cx
               mov    word ptr [bp-29], si
               mov    al, byte ptr [bp-17]
               mov    byte ptr [bp-38], al
               and    byte ptr [bp-38], FLAG_UPPERCASE
               je     L40
               mov    word ptr [bp-29], OFFSET digitsU
L40:
               fld    tbyte ptr r2pm65
               mov    si, OFFSET temp
               mov    dl, byte ptr [bp-17]
               mov    byte ptr [bp-32], dl
               and    byte ptr [bp-32], FLAG_LEFTALIGN
               test   di, di
               jg     L42
               mov    byte ptr temp, '0'
               mov    si, OFFSET temp+1
               test   bx, bx
               jle    L43
               mov    byte ptr temp+1, POINT_CHAR
               mov    si, OFFSET temp+2
L48:
               mov    ax, di
               inc    di
               test   ax, ax
               jge    L43
               mov    ax, bx
               dec    bx
               test   ax, ax
               jle    L43
               mov    byte ptr [si], '0'
               inc    si
               jmp    L48
L43:
               xor    di, di
L42:
               fild   word ptr [bp-36]
               jmp    L49
L117:
L118:
               fxch   st(2)
               fld    tbyte ptr [bp-16]
               fnstcw word ptr [bp-4]
               mov    dx, word ptr [bp-4]
               or     dx, 0C00h
               mov    word ptr [bp-6], dx
               fldcw  word ptr [bp-6]
               fistp  word ptr [bp-2]
               mov    ax, word ptr [bp-2]
               fldcw  word ptr [bp-4]
               mov    dx, word ptr [bp-29]
               and    ax, 00FFh
               push   di
               mov    di, dx
               add    di, ax
               mov    al, byte ptr [di]
               pop    di
               mov    byte ptr [si], al
               inc    si
               test   di, di
               jle    L54
               dec    di
               jne    L112
               test   bx, bx
               jle    L113
               mov    byte ptr [si], POINT_CHAR
               inc    si
               jmp    L114
L54:
               fxch   st(2)
               fxch   st(1)
               dec    bx
               jmp    L49
L112:
L114:
               fxch   st(2)
               fxch   st(1)
L49:
               fld    st(0)
               fmulp  st(3), st
               fxch   st(2)
               sub    sp, 10
               mov    ax, di
               mov    di, sp
               fstp   tbyte ptr [di]
               mov    di, ax
               mov    ax, word ptr [bp-31]
               push   ax
               fxch   st(1)
               fstp   tbyte ptr [bp-58]
               fstp   tbyte ptr [bp-68]
               call   _split
               fld    tbyte ptr [bp-58]
               fld    tbyte ptr [bp-68]
               fmul   st, st(1)
               add    sp, 12
               fcom   st(2)
               fnstsw ax
               and    ah, 69
               je     L115
               fld1
               fsub   st, st(1)
               fcomp  st(3)
               fnstsw ax
               and    ah, 69
               cmp    ah, 1
               je     L116
               test   di, di
               jng    noL117
               jmp    L117
noL117:
               test   bx, bx
               jng    L116
               jmp    L118
L113:
               fstp   st(1)
               fstp   st(1)
               jmp    L50
L115:
L116:
               fstp   st(0)
               fstp   st(0)
L50:
               fld    tbyte ptr r2pm1
               fcompp
               fnstsw ax
               and    ah, 69
               dec    ah
               cmp    ah, 64
               jae    L60
               fld    tbyte ptr [bp-16]
               fld1
               faddp  st(1), st
               fstp   tbyte ptr [bp-16]
L60:
               test   di, di
               jle    L61
               fld    tbyte ptr [bp-16]
               fnstcw word ptr [bp-4]
               mov    dx, word ptr [bp-4]
               or     dx, 0C00h
               mov    word ptr [bp-6], dx
               fldcw  word ptr [bp-6]
               fistp  word ptr [bp-2]
               mov    ax, word ptr [bp-2]
               fldcw  word ptr [bp-4]
               mov    dx, word ptr [bp-29]
               and    ax, 00FFh
               dec    di
               push   di
               mov    di, dx
               add    di, ax
               mov    al, byte ptr [di]
               pop    di
               mov    byte ptr [si], al
               inc    si
               test   di, di
               jle    L63
L64:
               mov    byte ptr [si], '0'
               inc    si
               dec    di
               test   di, di
               jg     L64
L63:
               test   bx, bx
               jnle   noL7
               jmp    L7
noL7:
               mov    byte ptr [si], POINT_CHAR
               jmp    L108
L61:
               mov    ax, bx
               dec    bx
               test   ax, ax
               jle    L107
               fld    tbyte ptr [bp-16]
               fnstcw word ptr [bp-4]
               mov    dx, word ptr [bp-4]
               or     dx, 0C00h
               mov    word ptr [bp-6], dx
               fldcw  word ptr [bp-6]
               fistp  word ptr [bp-2]
               mov    ax, word ptr [bp-2]
               fldcw  word ptr [bp-4]
               mov    dx, word ptr [bp-29]
               and    ax, 00FFh
               push   di
               mov    di, dx
               add    di, ax
               mov    al, byte ptr [di]
               pop    di
               mov    byte ptr [si], al
               jmp    L108
L72:
               mov    byte ptr [si], '0'
L108:
               inc    si
L107:
               mov    ax, bx
               dec    bx
               test   ax, ax
               jg     L72
               cmp    byte ptr [bp-37], FLAG_EXPON
               jne    L74
               mov    dx, si
               inc    si
               mov    al, EXPONENT_LOWER_CHAR
               cmp    byte ptr [bp-38], 0
               je     L75
               mov    al, EXPONENT_UPPER_CHAR
L75:
               push   di
               mov    di, dx
               mov    byte ptr [di], al
               pop    dx
               push   si
               mov    ax, word ptr [bp-27]
               push   ax
               sub    sp, 1
               mov    di, sp
               mov    byte ptr [di], 0
               xor    ax, ax
               mov    al, byte ptr [bp-38]
               mov    dl, byte ptr [bp-17]
               test   dl, FLAG_NOSIGNEXP
               jne    L77
               or     al, FLAG_FORCESIGN
L77:
               sub    sp, 1
               mov    di, sp
               mov    byte ptr [di], al
               mov    al, byte ptr [bp+8]
               sub    sp, 1
               mov    di, sp
               mov    byte ptr [di], al
               mov    di, dx
               lea    ax, byte ptr [bp-25]
               push   ax
               push   bp
               call   _formatInteger
               add    sp, 11
               xor    ax, ax
               mov    al, byte ptr [bp-25]
               add    si, ax
L74:
               mov    byte ptr [si], 0
               mov    word ptr [bp-20], OFFSET temp
               mov    al, byte ptr [bp-20]
               mov    dx, si
               sub    dl, al
               mov    byte ptr [bp-25], dl
L7:
               mov    bx, word ptr [bp-34]
               xor    ax, ax
               mov    al, byte ptr [bp-25]
               sub    bx, ax
               cmp    byte ptr [bp-18], 0
               je     L80
               dec    bx
L80:
               cmp    byte ptr [bp-32], 0
               jne    L81
               mov    al, byte ptr [bp-17]
               test   ax, FLAG_ZEROPAD
               je     L82
               mov    dl, 0
               mov    cx, bx
               test   cx, cx
               jle    L81
L86:
               push   di
               mov    di, word ptr [bp-23]
               mov    byte ptr [di], '0'
               inc    di
               mov    word ptr [bp-23], di
               pop    di
               inc    dl
               xor    ax, ax
               mov    al, dl
               cmp    ax, cx
               jl     L86
               jmp    L81
L82:
               mov    dl, 0
               mov    cx, bx
               test   cx, cx
               jle    L81
L92:
               push   di
               mov    di, word ptr [bp-23]
               mov    byte ptr [di], SPACEPAD_CHAR
               inc    di
               mov    word ptr [bp-23], di
               pop    di
               inc    dl
               xor    ax, ax
               mov    al, dl
               cmp    ax, cx
               jl     L92
L81:
               cmp    byte ptr [bp-18], 0
               je     L94
               push   di
               mov    di, word ptr [bp-23]
               mov    dl, byte ptr [bp-18]
               mov    byte ptr [di], dl
               inc    di
               mov    word ptr [bp-23], di
               mov    ax, di
               pop    di
L94:
               push   di
               mov    di, word ptr [bp-20]
               cmp    byte ptr [di], 0
               mov    dx, di
               pop    di
               je     L96
L97:
               push   di
               mov    di, word ptr [bp-20]
               mov    al, byte ptr [di]
               mov    di, word ptr [bp-23]
               mov    byte ptr [di], al
               mov    dx, di
               pop    di
               inc    word ptr [bp-20]
               push   di
               mov    di, word ptr [bp-20]
               inc    dx
               mov    word ptr [bp-23], dx
               cmp    byte ptr [di], 0
               mov    ax, di
               pop    di
               jne    L97
L96:
               cmp    byte ptr [bp-32], 0
               je     L99
               mov    dl, 0
               mov    cx, bx
               test   cx, cx
               jle    L99
L103:
               push   di
               mov    di, word ptr [bp-23]
               mov    byte ptr [di], SPACEPAD_CHAR
               inc    di
               mov    word ptr [bp-23], di
               pop    di
               inc    dl
               xor    ax, ax
               mov    al, dl
               cmp    ax, cx
               jl     L103
L99:
               mov    bx, word ptr [bp-23]
               mov    byte ptr [bx], 0
               mov    ax, bx
               sub    ax, word ptr [bp+22]
               mov    byte ptr [bp+6], al

               mov    sp, bp
               pop    bp
               ret
_formatReal    endp


; Auxiliary:
; ----------
; function split (x : real; p : ^real) : real
; -------------------------------------------
; This function splits the real number x to its integer part,
; which it stores in p^, and its fractional part, which it
; returns.
;
; CAUTION: It does not follow PCL's calling conventions.
; The activation record is simplified and the result is left
; on x87 FPU's stack.

_split         proc    near
               push    bp
               mov     bp, sp
               sub     sp, 4

               push    di
               fld     tbyte ptr [bp+6]        ; st: x
               mov     di, word ptr [bp+4]     ; di: p
               fnstcw  word ptr [bp-2]
               mov     dx, word ptr [bp-2]
               or      dh, 0Ch                 ; truncate
               mov     word ptr [bp-4], dx
               fldcw   word ptr [bp-4]
               fld     st(0)                   ; st: x, x
               frndint                         ; st: x, trunc(x)
               fldcw   word ptr [bp-2]         ; as it was
               fld     st(0)                   ; st: x, trunc(x), trunc(x)
               fstp    tbyte ptr [di]          ; *p = trunc(x), st: x, trunc(x)
               fsubrp  st(1), st               ; st: x-trunc(x)
               pop     di

               mov     sp, bp
               pop     bp
               ret
_split         endp


; Auxiliary:
; ----------
; function isinf (x : real) : boolean
; -----------------------------------
; This checks if the given real number is an infinite value.
;
; CAUTION: It does not follow PCL's calling conventions.
; The activation record is simplified and the result is left
; on al.

_isinf         proc   near
               push   bp
               mov    bp, sp

               fld    tbyte ptr [bp+6]
               fxam
               fnstsw ax
               and    ax, 4500h
               cmp    ax, 0500h
               jne    @isinf
               mov    al, 1

@isinf:        fstp   st(0)
               mov    sp, bp
               pop    bp
               ret
_isinf         endp


; Auxiliary:
; ----------
; function isnan (x : real) : boolean
; -----------------------------------
; This checks if the given real number is NaN.
;
; CAUTION: It does not follow PCL's calling conventions.
; The activation record is simplified and the result is left
; on al.

_isnan         proc   near
               push   bp
               mov    bp, sp

               fld    tbyte ptr [bp+6]
               fxam
               fnstsw ax
               and    ax, 4500h
               cmp    ax, 0100h
               jne    @isnan
               mov    al, 1

@isnan:        fstp   st(0)
               mov    sp, bp
               pop    bp
               ret
_isnan         endp


; Auxiliary stuff
; ---------------

temp           db      256 dup(?)

digitsU        db      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
               db      0
digitsL        db      '0123456789abcdefghijklmnopqrstuvwxyz'
               db      0
stringInf      db      'Inf'
               db      0
stringNan      db      'NaN'
               db      0

r2pm65         db      0, 0, 0, 0, 0, 0, 0, 128, 190, 63
r2pm1          db      0, 0, 0, 0, 0, 0, 0, 128, 254, 63

               extrn   _formatInteger : proc

xseg           ends
               end
