;PCI congiguration
ADR=$0CF8
DAT=$0CFC
BASE=$80000000
use16
org $7C00
	   mov ax,cs
	   mov ds,ax
	   mov sp,$7c00
	   mov ax,$B800
	   mov es,ax
	   mov ax,3
	   int 10h
	   xor ecx,ecx
	   mov di,cx
	   mov ch,160
	   mov ebx,BASE
	   mov eax,ebx
	   shr eax,16
	   call showbyte
	   add di,4
	   mov ax,bx
	   shr ax,11
	   call showbyte
	   add di,4
	   mov al,bh
	   and al,$07
	   call showbyte
	 ;show reg
     showreg:
	   test cl,$0C
	   jnz inline ;in current line
	   mov ax,di  ;next line
	   div ch
	   inc al
	   mul ch
	   mov di,ax
	   mov al,cl
	   call showbyte
	   add edi,4
     inline:
	   mov dx,ADR
	   mov eax,ebx
	   or al,cl
	   out dx,eax
	   mov dx,DAT
	   in eax,dx
	   call showdword
	   add di,2
	   add cl,4
	   jnc showreg
	   jmp $
showdword:   mov dl,4
  conv_0:rol eax,8
	 push eax
	 call showbyte
	 pop eax
	 dec dl
	 jnz   conv_0
	 ret

showbyte:mov ah,al
	 and al,$F0
	 shr al,4
	 cmp al,$0A
	 jb conv_1
	 add al,7
  conv_1:add al,$30
	 stosb
	 inc di
	 and ah,$0F
	 cmp ah,$0A
	 jb   conv_2
	 add ah,7
  conv_2:add ah,$30
	 mov al,ah
	 stosb
	 inc di
	 ret
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
