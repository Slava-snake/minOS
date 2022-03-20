;show int 16h $E820
use16
org $7C00
		mov ax,cs
		mov es,ax
		mov ds,ax
		mov sp,$7c00
		mov ax,3
		int 10h
		mov ebx,0
start:		call read_range
		jc error
		call show_range
	push bx
	mov bp,starth
	mov ax,$1301
	mov bx,$07
	mov cx,types-starth
	mov dx,word[pos]
	int 10h
	inc dh
	cmp dh,25
	jz $
	mov [pos+1],dh
	pop bx
	test ebx,ebx
	jz $
	jmp start

read_range:	mov eax,$E820
		mov ecx,24
		mov edi,$1000
		mov esi,edi
		mov edx,$534D4150
		mov dword[es:edi+20],1
		int 15h
		ret
error:		cmp eax,$534D4150
		jnz no_support

no_support: mov bp,err_mes
	    mov cx,err_mes1-err_mes
	    mov ax,$1301
	    mov bx,$07
	    mov dx,0
	    int 10h
	    jmp $

pos	 db 0,1
err_mes  db '$E820 int 15h is not supported !'
err_mes1 db 0
convD:	 mov cl,4
  conv_0:rol eax,8
	 push eax
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
	 pop eax
	 dec cl
	 jnz   conv_0
	 ret
show_range:		   lodsd
		mov edi,startl
		call convD
		lodsd
		mov edi,starth
		call convD
		mov edi,lenl
		lodsd
		call convD
		mov edi,lenh
		lodsd
		call convD
		lodsb
		mov edi,typetxt
enum_str: ;copy string from enumirate list
	 mov esi,types
	 mov ah,al
      @@:lodsb
	 cmp ah,al
	 jz enum_str_find
  skip_str:
	 lodsb
	 test al,al
	 jnz skip_str
	 cmp byte[esi],0
	 jnz @b
	 mov esi,undefined
  enum_str_find:
  copy_zstr:
	 lodsb
	 test al,al
	 jz copy_zstr_end
	 stosb
	 jmp copy_zstr
  copy_zstr_end:
	 ret

starth	  db 8 dup $20
startl	  db 8 dup $20,' - '
lenh	  db 8 dup $20
lenl	  db 8 dup $20,' => '
typetxt   db 15 dup $20,13,0

types  db 1,'RAM       ',0
       db 2,'reserved  ',0
       db 3,'ACPI      ',0
       db 4,'NVS       ',0
       db 5,'unusuable ',0
       db 6,'disabled  ',0
       db 0
undefined db 'undefined ',0
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
	 db 512*7 dup 0
