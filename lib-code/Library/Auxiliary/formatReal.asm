










               .386p	
               Code32	 segment para public use32
assume cs:Code32, ds:Code32
 
gcc2_compiled_:	
___gnu_compiled_c:	
 
               _temp_9	  db 256 dup(?)
LC0:	
               db	 "Inf", 0, ""
LC1:	
               db	 "NaN", 0, ""
 
LC2:	
               db	 "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, ""
 
LC3:	
               db	 "0123456789abcdefghijklmnopqrstuvwxyz", 0, ""
 
LC4:	
               dd	  00h, 080000000h, 03fbeh
 
LC5:	
               dd	  00h, 080000000h, 03ffeh
 
               public	 _formatReal
_formatReal:	
               push	 	bp
               mov	 	bp, sp
               sub	 	sp, 140
               push	 	di
               push	 	si
               push	 	bx
               mov	 	dl, byte ptr [bp+9]
               mov	 	byte ptr [bp-17], dl
               mov	 	dx, word ptr [bp+22]
               fld	 	tbyte ptr [bp+12]
               mov	 	bl, byte ptr [bp+11]
               mov	 	al, byte ptr [bp+10]
               mov	 	byte ptr [bp+10], al
               mov	 	al, byte ptr [bp+8]
               mov	 	byte ptr [bp+8], al
               mov	 	byte ptr [bp-18], 0
               mov	 	word ptr [bp-23], dx
               add	 	sp, -4
               sub	 	sp, 12
               fld	 	 st(0)
               fstp	 	tbyte ptr [sp]
               fstp	 	tbyte ptr [bp-48]
               call	 	_isinfl
               add	 	sp, 16
               fld	 	tbyte ptr [bp-48]
               test	 	al, al
               je	 	L5
               fldz	
               fcompp	
               fnstsw	 	ax
               and	 	ah, 69
               jne	 	L6
               mov	 	byte ptr [bp-18], 45
L6:	
               mov	 	word ptr [bp-20], OFFSET LC0
               jmp	 	L105
 
L5:	
               add	 	sp, -4
               sub	 	sp, 12
               fld	 	 st(0)
               fstp	 	tbyte ptr [sp]
               fstp	 	tbyte ptr [bp-48]
               call	 	_isnanl
               add	 	sp, 16
               fld	 	tbyte ptr [bp-48]
               test	 	al, al
               je	 	L8
               fstp	 	 st(0)
               mov	 	word ptr [bp-20], OFFSET LC1
L105:	
               mov	 	byte ptr [bp-25], 3
               xor	 	dx, dx
               mov	 	dl, bl
               mov	 	word ptr [bp-34], dx
               mov	 	al, byte ptr [bp-17]
               mov	 	byte ptr [bp-32], al
               and	 	byte ptr [bp-32], 1
               jmp	 	L7
 
L8:	
               xor	 	ax, ax
               mov	 	al, byte ptr [bp+8]
               mov	 	word ptr [bp-2], ax
               fild	 	word ptr [bp-2]
               fld1	
               fld	 	 st(0)
               fdivp	 	 st(2), st
               mov	 	word ptr [bp-27], 0
               mov	 	word ptr [bp-36], ax
               fldz	
               fcom	 	 st(3)
               fnstsw	 	ax
               and	 	ah, 69
               jne	 	L10
               fxch	 	 st(3)
               fchs	
               fxch	 	 st(3)
               mov	 	byte ptr [bp-18], 45
L10:	
               xor	 	cx, cx
               mov	 	cl, byte ptr [bp+10]
               mov	 	si, OFFSET LC3
               lea	 	dx, tbyte ptr [bp-16]
               mov	 	word ptr [bp-31], dx
               xor	 	ax, ax
               mov	 	al, bl
               mov	 	word ptr [bp-34], ax
               fcomp	 	 st(3)
               fnstsw	 	ax
               and	 	ah, 69
               cmp	 	ah, 1
               jne	 	L109
               xor	 	bx, bx
               mov	 	bl, byte ptr [bp+8]
               fldz	
               jmp	 	L13
L111:	
               fxch	 	 st(3)
 
L13:	
               fxch	 	 st(3)
               fcom	 	 st(1)
               fnstsw	 	ax
               and	 	ah, 5
               jne	 	L14
               mov	 	word ptr [bp-4], bx
               fild	 	word ptr [bp-4]
               mov	 	dx, 1
               fcom	 	 st(1)
               fnstsw	 	ax
               and	 	ah, 69
               dec	 	ah
               cmp	 	ah, 64
               jae	 	L16
 
L17:	
               fmul	 	st,  st(0)
               add	 	dx, dx
               fcom	 	 st(1)
               fnstsw	 	ax
               and	 	ah, 69
               dec	 	ah
               cmp	 	ah, 64
               jb	 	L17
L16:	
               fdivrp	 	 st(1), st
               add	 	word ptr [bp-27], dx
               jmp	 	L11
 
L14:	
               fcom	 	 st(2)
               fnstsw	 	ax
               and	 	ah, 69
               cmp	 	ah, 1
               jne	 	L110
               mov	 	dx, 1
               fld	 	 st(2)
 
L23:	
               fmul	 	st,  st(0)
               add	 	dx, dx
               fcom	 	 st(1)
               fnstsw	 	ax
               and	 	ah, 69
               je	 	L23
               fdivrp	 	 st(1), st
               sub	 	word ptr [bp-27], dx
L11:	
               fcom	 	 st(3)
               fnstsw	 	ax
               and	 	ah, 69
               je	 	L111
               jmp	 	L110
L109:	
               fstp	 	 st(0)
               fstp	 	 st(0)
               jmp	 	L12
L110:	
               fstp	 	 st(1)
               fstp	 	 st(1)
               fstp	 	 st(1)
L12:	
               cmp	 	word ptr [bp-27], 255
               jg	 	L28
               mov	 	al, byte ptr [bp-17]
               and	 	al, 48
               cmp	 	al, 32
               jne	 	L29
               mov	 	ax, word ptr [bp-27]
               add	 	ax, 4
               cmp	 	ax, 10
               jbe	 	L27
L28:	
               and	 	byte ptr [bp-17], 207
               or	 	byte ptr [bp-17], 16
               jmp	 	L29
 
L27:	
               and	 	byte ptr [bp-17], 207
L29:	
               mov	 	dl, byte ptr [bp-17]
               test	 	dl, 4
               je	 	L31
               cmp	 	byte ptr [bp-18], 45
               je	 	L31
               mov	 	byte ptr [bp-18], 43
L31:	
               mov	 	al, byte ptr [bp-17]
               and	 	al, 48
               xor	 	dx, dx
               mov	 	dl, al
               mov	 	byte ptr [bp-37], al
               test	 	dx, dx
               je	 	L33
               cmp	 	dx, 16
               je	 	L34
               jmp	 	L32
 
L33:	
               mov	 	di, word ptr [bp-27]
               jmp	 	L32
 
L34:	
               mov	 	di, 1
               dec	 	word ptr [bp-27]
L32:	
               mov	 	bx, cx
               mov	 	word ptr [bp-29], si
               mov	 	al, byte ptr [bp-17]
               mov	 	byte ptr [bp-38], al
               and	 	byte ptr [bp-38], 64
               je	 	L40
               mov	 	word ptr [bp-29], OFFSET LC2
 
L40:	
               fld	 	tbyte ptr LC4
               mov	 	si, OFFSET _temp_9
               mov	 	dl, byte ptr [bp-17]
               mov	 	byte ptr [bp-32], dl
               and	 	byte ptr [bp-32], 1
               test	 	di, di
               jg	 	L42
               mov	 	byte ptr _temp_9, 48
               mov	 	si, OFFSET _temp_9+1
               test	 	bx, bx
               jle	 	L43
               mov	 	byte ptr _temp_9+1, 46
               mov	 	si, OFFSET _temp_9+2
 
L48:	
               mov	 	ax, di
               inc	 	di
               test	 	ax, ax
               jge	 	L43
               mov	 	ax, bx
               dec	 	bx
               test	 	ax, ax
               jle	 	L43
               mov	 	byte ptr [si], 48
               inc	 	si
               jmp	 	L48
 
L43:	
               xor	 	di, di
L42:	
               fild	 	word ptr [bp-36]
               jmp	 	L49
L117:	
L118:	
               fxch	 	 st(2)
               fld	 	tbyte ptr [bp-16]
               fnstcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-4]
               or	 	dx, 3072
               mov	 	word ptr [bp-6], dx
               fldcw	 	word ptr [bp-6]
               fistp	 	word ptr [bp-2]
               mov	 	ax, word ptr [bp-2]
               fldcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-29]
               and	 	ax, 255
               mov	 	al, byte ptr [ax+dx]
               mov	 	byte ptr [si], al
               inc	 	si
               test	 	di, di
               jle	 	L54
               dec	 	di
               jne	 	L112
               test	 	bx, bx
               jle	 	L113
               mov	 	byte ptr [si], 46
               inc	 	si
               jmp	 	L114
 
L54:	
               fxch	 	 st(2)
               fxch	 	 st(1)
               dec	 	bx
               jmp	 	L49
L112:	
L114:	
               fxch	 	 st(2)
               fxch	 	 st(1)
L49:	
               fld	 	 st(0)
               fmulp	 	 st(3), st
               fxch	 	 st(2)
               mov	 	ax, word ptr [bp-31]
               push	 	ax
               sub	 	sp, 12
               fstp	 	tbyte ptr [sp]
               fxch	 	 st(1)
               fstp	 	tbyte ptr [bp-58]
               fstp	 	tbyte ptr [bp-68]
               call	 	_modfl
               fld	 	tbyte ptr [bp-58]
               fld	 	tbyte ptr [bp-68]
               fmul	 	st,  st(1)
               add	 	sp, 16
               fcom	 	 st(2)
               fnstsw	 	ax
               and	 	ah, 69
               je	 	L115
               fld1	
               fsub	 	st,  st(1)
               fcomp	 	 st(3)
               fnstsw	 	ax
               and	 	ah, 69
               cmp	 	ah, 1
               je	 	L116
               test	 	di, di
               jg	 	L117
               test	 	bx, bx
               jg	 	L118
               jmp	 	L116
L113:	
               fstp	 	 st(1)
               fstp	 	 st(1)
               jmp	 	L50
L115:	
L116:	
               fstp	 	 st(0)
               fstp	 	 st(0)
L50:	
               fld	 	tbyte ptr LC5
               fcompp	
               fnstsw	 	ax
               and	 	ah, 69
               dec	 	ah
               cmp	 	ah, 64
               jae	 	L60
               fld	 	tbyte ptr [bp-16]
               fld1	
               faddp	 	 st(1), st
               fstp	 	tbyte ptr [bp-16]
L60:	
               test	 	di, di
               jle	 	L61
               fld	 	tbyte ptr [bp-16]
               fnstcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-4]
               or	 	dx, 3072
               mov	 	word ptr [bp-6], dx
               fldcw	 	word ptr [bp-6]
               fistp	 	word ptr [bp-2]
               mov	 	ax, word ptr [bp-2]
               fldcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-29]
               and	 	ax, 255
               dec	 	di
               mov	 	al, byte ptr [ax+dx]
               mov	 	byte ptr [si], al
               inc	 	si
               test	 	di, di
               jle	 	L63
 
L64:	
               mov	 	byte ptr [si], 48
               inc	 	si
               dec	 	di
               test	 	di, di
               jg	 	L64
L63:	
               test	 	bx, bx
               jle	 	L7
               mov	 	byte ptr [si], 46
               jmp	 	L108
 
L61:	
               mov	 	ax, bx
               dec	 	bx
               test	 	ax, ax
               jle	 	L107
               fld	 	tbyte ptr [bp-16]
               fnstcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-4]
               or	 	dx, 3072
               mov	 	word ptr [bp-6], dx
               fldcw	 	word ptr [bp-6]
               fistp	 	word ptr [bp-2]
               mov	 	ax, word ptr [bp-2]
               fldcw	 	word ptr [bp-4]
               mov	 	dx, word ptr [bp-29]
               and	 	ax, 255
               mov	 	al, byte ptr [ax+dx]
               mov	 	byte ptr [si], al
               jmp	 	L108
 
L72:	
               mov	 	byte ptr [si], 48
L108:	
               inc	 	si
L107:	
               mov	 	ax, bx
               dec	 	bx
               test	 	ax, ax
               jg	 	L72
               cmp	 	byte ptr [bp-37], 16
               jne	 	L74
               mov	 	dx, si
               inc	 	si
               mov	 	al, 101
               cmp	 	byte ptr [bp-38], 0
               je	 	L75
               mov	 	al, 69
L75:	
               mov	 	byte ptr [dx], al
               mov	 	ax, word ptr [bp-36]
               add	 	sp, -12
               push	 	ax
               xor	 	ax, ax
               mov	 	al, byte ptr [bp-38]
               mov	 	dl, byte ptr [bp-17]
               test	 	dl, 8
               jne	 	L77
               or	 	al, 4
L77:	
               and	 	ax, 255
               push	 	ax
               push	 	word ptr 0
               movsx	 	ax, word ptr [bp-27]
               push	 	ax
               push	 	si
               call	 	_formatInteger
               and	 	ax, 255
               add	 	si, ax
L74:	
               mov	 	byte ptr [si], 0
               mov	 	word ptr [bp-20], OFFSET _temp_9
               mov	 	al, byte ptr [bp-20]
               mov	 	dx, si
               sub	 	dl, al
               mov	 	byte ptr [bp-25], dl
L7:	
               mov	 	bx, word ptr [bp-34]
               xor	 	ax, ax
               mov	 	al, byte ptr [bp-25]
               sub	 	bx, ax
               cmp	 	byte ptr [bp-18], 0
               je	 	L80
               dec	 	bx
L80:	
               cmp	 	byte ptr [bp-32], 0
               jne	 	L81
               mov	 	al, byte ptr [bp-17]
               test	 	ax, 2
               je	 	L82
               mov	 	dl, 0
               movsx	 	cx, bx
               test	 	cx, cx
               jle	 	L81
 
L86:	
               mov	 	ax, word ptr [bp-23]
               mov	 	byte ptr [ax], 48
               inc	 	ax
               mov	 	word ptr [bp-23], ax
               inc	 	dl
               xor	 	ax, ax
               mov	 	al, dl
               cmp	 	ax, cx
               jl	 	L86
               jmp	 	L81
 
L82:	
               mov	 	dl, 0
               movsx	 	cx, bx
               test	 	cx, cx
               jle	 	L81
 
L92:	
               mov	 	ax, word ptr [bp-23]
               mov	 	byte ptr [ax], 95
               inc	 	ax
               mov	 	word ptr [bp-23], ax
               inc	 	dl
               xor	 	ax, ax
               mov	 	al, dl
               cmp	 	ax, cx
               jl	 	L92
L81:	
               cmp	 	byte ptr [bp-18], 0
               je	 	L94
               mov	 	ax, word ptr [bp-23]
               mov	 	dl, byte ptr [bp-18]
               mov	 	byte ptr [ax], dl
               inc	 	ax
               mov	 	word ptr [bp-23], ax
L94:	
               mov	 	dx, word ptr [bp-20]
               cmp	 	byte ptr [dx], 0
               je	 	L96
 
L97:	
               mov	 	dx, word ptr [bp-20]
               mov	 	al, byte ptr [dx]
               mov	 	dx, word ptr [bp-23]
               mov	 	byte ptr [dx], al
               inc	 	word ptr [bp-20]
               mov	 	ax, word ptr [bp-20]
               inc	 	dx
               mov	 	word ptr [bp-23], dx
               cmp	 	byte ptr [ax], 0
               jne	 	L97
L96:	
               cmp	 	byte ptr [bp-32], 0
               je	 	L99
               mov	 	dl, 0
               movsx	 	cx, bx
               test	 	cx, cx
               jle	 	L99
 
L103:	
               mov	 	ax, word ptr [bp-23]
               mov	 	byte ptr [ax], 95
               inc	 	ax
               mov	 	word ptr [bp-23], ax
               inc	 	dl
               xor	 	ax, ax
               mov	 	al, dl
               cmp	 	ax, cx
               jl	 	L103
L99:	
               mov	 	dx, word ptr [bp-23]
               mov	 	byte ptr [dx], 0
               mov	 	al, byte ptr [bp-23]
               sub	 	al, byte ptr [bp+22]
               lea	 	sp, word ptr [bp-70]
               and	 	ax, 255
               pop	 	bx
               pop	 	si
               pop	 	di
               mov	 	sp, bp
               pop	 	bp
               ret	
	 
               Code32	 ends
               end	
