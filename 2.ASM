;show MSR
use16
CURR_SEG=$07C0 ;current segment

;set new segments
	mov sp,$3FC
	mov ax,CURR_SEG
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov ax,3   ; cls
	int 10h
	mov ecx,$000000 ;input
	mov edx,$FF00 ;dx-screen pos
  next: mov eax,ecx
	mov edi,show
	call conv
	rdmsr
	test eax,eax
	jnz show_row
	test edx,edx
	jnz show_row
	jmp next_reg
  show_row:
	mov edi,show_bin
	call conv01
	inc edi
	mov eax,edx
	call conv
	inc [row]
	cmp [row],25
	jne in_page
	xor ah,ah
  wait_key:
	int 16h
	test ah,ah
	jz wait_key
	mov byte[row],$0 ;top row
in_page:push ecx
	mov ax,$1301
	mov bx,$07
	mov bp,show
	mov cx,show_end-show
	mov dx,word[col]
	int 10h
	pop ecx
  next_reg:
	inc ecx
	cmp ecx,$C0020000
	jb next
	jmp $

col	 db 0
row	 db 0
show	 db 8 dup 0,$20,$20
show_bin db (32+7) dup $20
show_edx db 10 dup $020
show_end:

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

conv01:  mov bx,$420
  conv01__:
	 sal eax,1
	 jc conv1
	 mov byte[di],'0'
	 jmp conv_
  conv1: mov byte[di],'1'
  conv_: inc di
	 dec bh
	 jnz conv2
	 mov bh,4
	 inc di
   conv2:dec bl
	 jnz conv01__
	 ret
;free zone
	 db (446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
