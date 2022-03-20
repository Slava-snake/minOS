;show
align 10h

posX	  dw 0
posY	  dw 0
color	  db 7
show_buff db 5 dup 0
unknown   db 'unknown',0
undefined db 'undefined',0
;#00-stop
;#01-skip char
;#02-skip last part of string
;#03-change attr

show_:	;ESI-text
	pushad
	push es
	mov ax,$B800
	mov es,ax
	mov bp,160
	mov ax,[posY]
	mul bp
	mov di,ax
	mov ax,[posX]
	shl ax,1
	add di,ax
	mov ah,[color] ;color
	mov ch,ah
  show_txt:
	lodsb
	test al,al
	jz end_show	 ;0-stop
	cmp al,1	 ;1-skip char
	jz show_txt
	cmp al,3	 ;3-change attr
	jz show_change_attr
	cmp al,2	 ;2-skip line
	jnz show_txt_1
  show_txt_0:
	lodsb
	test al,al
	jz end_show
	cmp al,13
	jnz show_txt_0
	jmp show_txt
  show_txt_1:
	cmp al,13
	jnz show_char
	mov ax,di
	div bp
	inc ax
	cmp ax,25
	jnz show_txt_next_row
	;shift up screen
	push si
	push cx
	push ds
	mov ax,es
	mov ds,ax
	mov si,$A0
	mov di,$00
	mov ecx,960
	rep movsd
	mov ax,$0720
	mov ecx,80
	rep stosw
	pop ds
	mov edi,160*24
	pop cx
	pop si
	jmp show_txt_bottom_row
  show_txt_next_row:
	mul bp
	xor dx,dx
	mov di,ax
  show_txt_bottom_row:
	mov ah,ch
	jmp show_txt
  show_change_attr:
	lodsb
	mov ah,al
	mov [color],al
	jmp show_txt
  show_char:
	stosw
	jmp show_txt
  end_show:
	mov ax,di
	div bp
	mov [posY],ax
	shr dx,1
	mov [posX],dx
	pop es
	popad
	ret

convD:	 push cx
	 mov cl,4
  convD_0:
	 rol eax,8
	 push eax
	 call convB
	 pop eax
	 dec cl
	 jnz  convD_0
	 pop cx
	 ret

convW:	 push ax
	 xchg ah,al
	 push ax
	 call convB
	 pop ax
	 mov al,ah
	 call convB
	 pop ax
	 ret

convB:	 push ax
	 mov ah,al
	 and ax,$0FF0
	 cmp ah,$0A
	 jb   conv_1
	 add ah,7
  conv_1:add ah,$30
	 shr al,4
	 cmp al,$0A
	 jb   conv_2
	 add al,7
  conv_2:add al,$30
	 stosw
	 pop ax
	 ret

convHB:  ;convert low half-byte to char
	 push ax
	 and al,$0F
	 cmp al,$0A
	 jb @f
	 add al,7
      @@:add al,$30
	 stosb
	 pop ax
	 ret

convH:	 ;convert HEX last CL-symbols
	 push eax
	 push cx
	 dec cl
	 shl cl,2
	 ror eax,cl
	 shr cl,2
	 inc cl
      @@:call convHB
	 rol eax,4
	 dec cl
	 jnz @b
	 pop cx
	 pop eax
	 ret

conv_bin_B:;convert CL-bits from AL
	 push ax
	 push cx
	 mov ch,cl
	 mov cl,8
	 sub cl,ch
	 rol al,cl
   conv_bin_bit:
	 shl al,1
	 jc conv_bin_1
	 mov byte[es:di],'0'
	 jmp conv_bin_next
   conv_bin_1:
	 mov byte[es:di],'1'
   conv_bin_next:
	 inc di
	 dec ch
	 jnz conv_bin_bit
	 pop cx
	 pop ax
	 ret

convBdec:cmp al,99
	 jbe convB_2
	 cmp al,200
	 jb @f
	 sub al,200
	 mov ah,$32
	 jmp convB3
      @@:mov ah,$31
	 sub al,100
  convB3:mov [edi],ah
	 inc edi
    convB_2:
	 mov ah,al
	 xor al,al
      @@:cmp ah,10
	 jb @f
	 sub ah,10
	 inc al
	 jmp @b
      @@:add ax,$3030
	 stosw
	 ret

   table1000000000 dd 1000000000,100000000,10000000,1000000,100000
   table10000 dd 10000,1000
   table100   dd 100,10

convDdec_non0:
	 push eax
	 test eax,eax
	 jz copy_zero
	 push ecx
	 push ebx
	 mov cx,9
	 mov ebx,table1000000000
	 jmp decimal_char

convWdec_non0:
	 push eax
	 test ax,ax
	 jz copy_zero
	 and eax,$FFFF
	 push ecx
	 push ebx
	 mov cx,4
	 mov ebx,table10000
	 jmp decimal_char

convBdec_non0:
	 push eax
	 test al,al
	 jz copy_zero
	 and eax,$FF
	 push ecx
	 push ebx
	 mov cx,2
	 mov ebx,table100
decimal_char:
	 push edx
      @@:xor edx,edx
	 div dword[ebx]
	 test eax,eax
	 jnz conv_dig
	 test ch,ch
	 jz conv_next_dig
  conv_dig:
	 mov ch,1
	 add al,$30
	 stosb
  conv_next_dig:
	 mov eax,edx
	 add ebx,4
	 dec cl
	 jnz @b
	 mov al,dl
	 add al,$30
	 stosb
	 pop edx
	 pop ebx
	 pop ecx
	 pop eax
	 ret

copy_zero:mov al,$30
	 stosb
	 pop eax
	 ret

copy_unknown:
	 mov esi,unknown
	 call copy_zstr
	 ret

copy_enum_str:
	 push ax
	 mov ah,al
      @@:lodsb
	 cmp ah,al
	 je copy_zstr_next
	 call skip_str
	 cmp byte[esi],0
	 jnz @b
	 mov esi,undefined
	 jmp copy_zstr_next
  enum_str_find:
copy_zstr:push ax
copy_zstr_next:
	 lodsb
	 test al,al
	 jz copy_zstr_end
	 stosb
	 jmp copy_zstr_next
  copy_zstr_end:
	 pop ax
	 ret

skip_str:lodsb
	 test al,al
	 jnz skip_str
	 ret

copy_enum2_str:
	 push bp
	 mov bp,ax
      @@:lodsw
	 cmp bp,ax
	 je enum2_str_find
	 call skip_str
	 cmp word[esi],0
	 jnz @b
	 mov esi,undefined
  enum2_str_find:
	 call copy_zstr
	 pop bp
	 ret
