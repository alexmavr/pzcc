real modfl (real x , real *p);
------------------------------
	push	bp
	mov	 	bp, sp
	sub	 	sp, 4
	fld	 	tbyte ptr [bp+8]		; st: x
	mov	 	ax, word ptr [bp+20]	; ax: p
	fnstcw	word ptr [bp-2]
	mov	 	dx, word ptr [bp-2]
	or	 	dh, 0Ch					; truncate
	mov	 	word ptr [bp-4], dx
	fldcw	word ptr [bp-4]
	fld	 	st(0)					; st: x, x
	frndint							; st: x, trunc(x)
	fldcw	word ptr [bp-2]			; as it was
	fld	 	st(0)					; st: x, trunc(x), trunc(x)
	fstp	tbyte ptr [ax]			; *p = trunc(x), st: x, trunc(x)
	fsubrp	st(1), st				; st: x-trunc(x)
	leave	
	ret	


int isinf (double);
-------------------
	push	bp
	mov	 	bp, sp
	mov	 	ax, [bp+8]
	mov	 	dx, [bp+12]
	mov	 	cx, dx
	and	 	cx, 07fffffffh
	mov	 	dx, ax
	neg	 	dx
	or	 	ax, dx
	shr	 	ax, 01fh
	or	 	cx, ax
	mov	 	ax, 07ff00000h
	su	 	ax, cx
	mov	 	cx, ax
	neg	 	ax
	mov	 	sp, bp
	or	 	cx, ax
	mov	 	ax, 01h
	shr	 	cx, 01fh
	pop	 	bp
	su	 	ax, cx
	ret	
	

int isnan (double);
-------------------
	push	bp
	mov	 	bp, sp
	mov	 	ax, [08h+bp]
	mov	 	dx, [0ch+bp]
	mov	 	cx, dx
	and	 	cx, 07fffffffh
	mov	 	dx, ax
	neg	 	dx
	or	 	ax, dx
	shr	 	ax, 01fh
	or	 	cx, ax
	mov	 	ax, 07ff00000h
	su	 	ax, cx
	mov	 	cx, ax
	mov	 	sp, bp
	pop	 	bp
	shr	 	ax, 01fh
	ret	
