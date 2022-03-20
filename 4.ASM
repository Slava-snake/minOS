;VESA
org $7c00
use16
buf=$8000
NEW_SEG=$60
macro conv_eax addr
  {  mov di,addr
     call convEAX }
macro conv_al addr
  {  mov di,addr
     call convAL }
macro conv_ax addr
  {  mov di,addr
     call convAX }
macro txt source,dest,count
  {  mov si,source
     mov di,dest
     mov cx,count
     rep movsb }
macro copystr source,dest
  {  mov si,source
     mov di,dest
     xor cx,cx
   .l:lodsb
     stosb
     inc cx
     test al,al
     jnz .l
     dec cx }
macro show str,x,y,c
  {  mov ax,$1301
     mov bp,str
     mov dx,(y shl 8)+x
     mov bx,c
     int 10h }
begin:	 mov esp,$7FFC
	 xor ax,ax
	 mov ds,ax
	 mov es,ax
	 mov ss,ax
	mov ax,$60
	mov es,ax
;load 2KB (4 sectors) at  ES:BX=0060:0000
	xor bx,bx
	mov cx,2 ;
	mov ax,$0200+6
	mov dh,0
	int 13h
	cli
	 xor ax,ax
	 mov es,ax
	 mov ax,3
	 int 10h
	 mov bx,buf
	 mov si,bx
	 mov di,si
	 mov eax,'2EBV'
	 mov [si],eax
	 mov ax,$4F00
	 int 10h
	 cmp al,$4F
	 jne no_vesa
	 txt buf,show_sig,4
	 mov ax,[bx+4]
	 conv_al show_verL
	 mov al,ah
	 conv_al show_verH
	 movzx eax,word[bx+$12]
	 shl eax,6
	 conv_eax show_vmem
	 lds si,[bx+6]
	 mov di,show_oem
	 xor cx,cx
      @@:lodsb
	 stosb
	 inc cx
	 test al,al
	 jnz @b
	 mov ax,es
	 mov ds,ax
	 dec cx
	 mov di,buf+512
	 mov eax,$4F01
	 mov cx,115h or 110000000000000b ;LBR and AF
	 int 10h
	 mov cx,show_end-show_txt
	 show show_txt,0,0,7

	 mov di,buf+512
	 mov eax,$4F02
	 mov bx,115h or 110000100000000b ;LBR and AF
	 int 10h

	 mov eax,[buf+512+40]
	 mov [LFB],eax
	lgdt fword[GDTR]
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp 8:$1000


no_vesa:

convAL:  push ax
	 mov ah,al
	 and ax,$0FF0
	 cmp ah,$0A
	 jb conv_1
	 add ah,7
  conv_1:add ah,$30
	 shr al,4
	 cmp al,$0A
	 jb conv_2
	 add al,7
  conv_2:add al,$30
	 stosw
	 pop ax
	 ret

convAX:  push ax
	 xchg ah,al
	 call convAL
	 pop ax
	 call convAL
	 ret

convEAX: push eax
	 rol eax,16
	 call convAX
	 pop eax
	 call convAX
	 ret

;data
align 4
GDTR	 dw GDT_end-GDT-1
	 dd NEW_SEG*16

LFB	 dd 0
;fill last
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh

include '4_1.asm'