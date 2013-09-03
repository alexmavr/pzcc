










	.386p
	Code32 segment para public use32
assume cs:Code32, ds:Code32
 
gcc2_compiled_:	
___gnu_compiled_c:	
 
 
LC0:	
	db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, ""
 
LC1:	
	db "0123456789abcdefghijklmnopqrstuvwxyz", 0, ""
	_temp_3  db 8 dup(?)
 
	public _formatInteger
_formatInteger:	
	push 	bp
	mov 	bp, sp
	sub 	sp, 28
	push 	di
	push 	si
	push 	bx
	mov 	ax, word ptr [bp+11]
	mov 	dx, ax
	mov 	cl, byte ptr [bp+10]
	mov 	word ptr [bp-2], OFFSET LC1
	mov 	bl, byte ptr [bp+9]
	test 	bl, 64
	je 	L3
	mov 	word ptr [bp-2], OFFSET LC0
L3:	
	mov 	bx, word ptr [bp+13]
	mov 	byte ptr [bp-3], 0
	mov 	di, OFFSET _temp_3
	test 	ax, ax
	jge 	L5
	neg 	dx
	mov 	byte ptr [bp-3], 45
	jmp 	L6
 
L5:	
	mov 	al, byte ptr [bp+9]
	test 	ax, 4
	je 	L6
	mov 	byte ptr [bp-3], 43
L6:	
	test 	dx, dx
	jne 	L8
	mov 	byte ptr [di], 48
	inc 	di
	xor 	dx, dx
	mov 	dl, cl
	mov 	word ptr [bp-6], dx
	mov 	al, byte ptr [bp+9]
	mov 	byte ptr [bp-4], al
	and 	byte ptr [bp-4], 1
	jmp 	L9
 
L8:	
	xor 	ax, ax
	mov 	al, cl
	mov 	word ptr [bp-6], ax
	mov 	al, byte ptr [bp+9]
	mov 	byte ptr [bp-4], al
	and 	byte ptr [bp-4], 1
	test 	dx, dx
	jle 	L9
	xor 	ax, ax
	mov 	al, byte ptr [bp+8]
	mov 	word ptr [bp-8], ax
 
L12:	
	movsx 	ax, dx
	cdq
	idiv 	word ptr [bp-8]
	mov 	si, word ptr [bp-2]
	mov 	cx, ax
	mov 	al, dl
	and 	ax, 255
	mov 	dx, cx
	mov 	al, byte ptr [ax+si]
	mov 	byte ptr [di], al
	inc 	di
	test 	cx, cx
	jg 	L12
L9:	
	mov 	cx, word ptr [bp-6]
	mov 	ax, di
	mov 	dx, OFFSET _temp_3
	sub 	ax, dx
	sub 	cx, ax
	cmp 	byte ptr [bp-3], 0
	je 	L14
	dec 	cx
L14:	
	lea 	ax, word ptr [di-1]
	cmp 	byte ptr [bp-4], 0
	jne 	L15
	mov 	dl, byte ptr [bp+9]
	test 	dl, 2
	je 	L16
	test 	cx, cx
	jle 	L15
	mov 	dx, cx
 
L20:	
	mov 	byte ptr [bx], 48
	inc 	bx
	dec 	dx
	jne 	L20
	jmp 	L15
 
L16:	
	test 	cx, cx
	jle 	L15
	mov 	dx, cx
 
L26:	
	mov 	byte ptr [bx], 95
	inc 	bx
	dec 	dx
	jne 	L26
L15:	
	cmp 	byte ptr [bp-3], 0
	je 	L28
	mov 	dl, byte ptr [bp-3]
	mov 	byte ptr [bx], dl
	inc 	bx
L28:	
	mov 	di, ax
	cmp 	di, OFFSET _temp_3
	jb 	L30
 
L31:	
	mov 	al, byte ptr [di]
	mov 	byte ptr [bx], al
	inc 	bx
	dec 	di
	cmp 	di, OFFSET _temp_3
	jae 	L31
L30:	
	cmp 	byte ptr [bp-4], 0
	je 	L33
	test 	cx, cx
	jle 	L33
	mov 	dx, cx
 
L37:	
	mov 	byte ptr [bx], 95
	inc 	bx
	dec 	dx
	jne 	L37
L33:	
	mov 	byte ptr [bx], 0
	mov 	al, bl
	sub 	al, byte ptr [bp+13]
	and 	ax, 255
	pop 	bx
	pop 	si
	pop 	di
	mov 	sp, bp
	pop 	bp
	ret
	 
	Code32 ends
	end
