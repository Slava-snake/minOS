;show CPU_ID
; memory map
use16
org $7C00
;set new segments
	mov sp,$7FFC
	xor ax,ax
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov ax,3   ; cls
	int 10h
	xor dx,dx
	xor bp,bp
	xor esi,esi
;cpu id
;cpu_leaf:
;	 push dx
;	 mov eax,esi
;	 mov edi,show_leaf
;	 call conv
;	 inc esi
;	 xor ecx,ecx
;	 cpuid
;	 test bp,bp
;	 jnz cpu_1
;	 mov dword[maxval],eax
;	 inc bp
;  cpu_1:
;	 mov edi,show_char
;	 stosd
 ;	 push eax
 ;	 mov eax,ebx
 ;	 stosd
;	 mov eax,edx
;	 stosd
;	 mov [edi],ecx
;	 pop eax
;	 mov edi,show_a
;	 call conv
;	 mov eax,ebx
;	 mov edi,show_b
;	 call conv
;	 mov eax,ecx
;	 mov edi,show_c
;	 call conv
;	 mov eax,edx
;	 mov edi,show_d
;	 call conv
;
;	 mov ax,$1301
;	 mov bx,$07
;	 mov bp,show_leaf
;	 pop dx
;	 mov cx,show_end-show_leaf
;	 int 10h
;	 inc dh
;	 cmp esi,[maxval]
;	 jng cpu_leaf
;	 cmp esi,$80000000
;	 ja mem_map
;	 mov esi,$80000000
;	 xor bp,bp
;	 jmp cpu_leaf

mem_map:xor ebx,ebx
	mov ebp,ebx
	mov esi,$8000
map:
	mov edi,esi
	mov ecx,24
	mov dword[es:di+20],1
	mov edx,'SMAP'
	mov eax,$E820
	int 15h
 ;	 jc stop
;	 cmp eax,'SMAP'
;	 jnz stop
	mov edi,show_end
	mov eax,[esi+4]
	call conv
	mov eax,[esi]
	call conv
	mov al,'#'
	stosb
	mov eax,[esi+12]
	call conv
	mov eax,[esi+8]
	call conv
	mov ax,'--'
	stosw
	mov eax,[esi+16]
	call conv
	mov ax,'--'
	stosw
	mov eax,[esi+20]
	call conv
	push edx
	push ebx
	mov ax,$1301
	mov bx,$07
	mov dx,bp
	mov bp,show_end
	mov cx,53
	int 10h
	add bp,$100
	pop ebx
	pop edx
	test ebx,ebx
	jnz map

stop:
	mov edi,show_leaf
	call conv
	mov ax,$1301
	mov bx,$07
	mov bp,show_leaf
	mov cx,8
	mov dx,$1800
	int 10h
	jmp $


conv:	 push cx
	 mov cx,4
  conv_0:
	 rol eax,8
	 push eax
	 mov ah,al
	 and ax,$0FF0
	 cmp ah,$0A
	 jb   conv_1
	 add ah,7
  conv_1:
	 add ah,$30
	 shr al,4
	 cmp al,$0A
	 jb   conv_2
	 add al,7
  conv_2:
	 add al,$30
	 stosw
	 pop eax
	 dec cx
	 jnz   conv_0
	 pop cx
	 ret


;DATA zone
show_leaf   db 8 dup 0,$20
show_add    db 8 dup 0,' - '
show_a	    db 8 dup 0,$20
show_b	    db 8 dup 0,$20
show_c	    db 8 dup 0,$20
show_d	    db 8 dup 0,$20,$20
show_char   db 16 dup '.'
show_end    db 0
maxval	    dd 0
;fill last
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
