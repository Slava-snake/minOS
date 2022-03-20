;PCI devices
ADR=$0CF8
DAT=$0CFC
use16
org $7C00
	   mov ax,cs
	   mov ds,ax
	   mov es,ax
	   mov sp,$7c00
	   mov edi,$8000
	   mov ax,3
	   int 10h
	   xor ecx,ecx ; CH-function, CL-reg
	   mov edx,ecx
	   mov ebx,ecx ; BH-bus, BL-device
next_dev:  call readPCI
	   jnc save_adr
next_adr:  xor cx,cx
	   inc bl
	   cmp bl,32
	   jnz next_dev
	   xor bl,bl
	   inc bh
	   jnz next_dev
	   jmp stop_scan
save_adr:  mov [di],ebp
	   add di,4
next_func: inc ch
	   cmp ch,8
	   jz next_adr
	   call readPCI
	   jc next_func
	   mov [di],ebp
	   add di,4
	   jmp next_func
stop_scan: sub di,4
	   mov [last],di
	   mov esi,$8000
	   mov ax,$B800
	   mov bp,160
	   mov es,ax
start:	   xor di,di
	   mov eax,[esi]
	   mov ebx,eax
	   call show_addr
	   xor cl,cl
   showreg:test cl,$0C
	   jnz inline ;in current line
	   call next_line
	   mov al,cl
	   call showbyte
	   mov ax,$073A
	   stosw
	   add di,2
    inline:mov eax,ebx
	   or al,cl
	   call read_conf
	   call showdword
	   cmp cl,08	     ;reg device type
	   jnz @f
	   and eax,$FF000000
	   cmp eax,$03000000  ;vga
	   jnz @f
	   call show_size_vga	 ;show size of vga mem
       @@: add di,2
	   add cl,4
	   jnc showreg
       @@: mov ah,$10
	   int 16h
	   cmp ah,$4B ;left
	   jz left
	   cmp ah,$4D
	   jz right
	   jmp @b
   left:   cmp si,$8000
	   jz @b
	   sub si,4
	   jmp start
    right: cmp si,[last]
	   jz @b
	   add si,4
	   jmp start

show_addr: shr eax,16
	   call showbyte
	   mov ax,$073A
	   stosw
	   mov ax,bx
	   shr ax,11
	   call showbyte
	   mov ax,$073A
	   stosw
	   mov al,bh
	   and al,$07
	   call showbyte
next_line: mov ax,di
	   xor dx,dx
	   div bp
	   inc ax
	   mul bp
	   mov di,ax
	   ret

writePCI:  push eax
	   call conv_adr
	   mov ebp,eax
	   pop eax
write_conf:push eax
	   mov eax,ebp
	   mov dx,ADR  ;EAX-addr
	   out dx,eax
	   mov dx,DAT
	   pop eax
	   out dx,eax
	   ret

conv_adr:  mov ah,$80 ;convert BH,BL => EAX-data
	   mov al,bh
	   shl eax,16
	   xor ax,ax
	   mov al,bl
	   shl ax,11
	   or ax,cx
	   ret

readPCI:   call conv_adr
	   mov ebp,eax
read_conf: mov dx,ADR  ;EAX-addr
	   out dx,eax
	   mov dx,DAT
	   in eax,dx
	   cmp eax,$FFFFFFFF
	   jz invalid_
	   clc
	   ret
  invalid_:stc
	   ret

showdword:   mov dl,4
  conv_0:rol eax,8
	 push eax
	 call showbyte
	 pop eax
	 dec dl
	 jnz   conv_0
	 ret


showword:push ax
	 mov al,ah
	 call showbyte
	 pop ax
	 call showbyte
	 ret

show_size_vga: nop
	       push eax
	       push ebp
	       mov eax,ebx
	       or al,$10
	       mov ebp,eax
	       push di
	       call read_conf
	       push eax
	       mov eax,$FFFFFFFF
	       call write_conf
	       mov eax,ebp
	       call read_conf
	       not eax
	       inc eax
	       mov di,40
	       call showdword
	       pop eax
	       call write_conf
	       pop di
	       pop ebp
	       pop eax
	       ret


last	 dw 0
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h

showbyte:push ax
	 mov ah,al
	 and al,$F0
	 shr al,4
	 cmp al,$0A
	 jb convb_1
	 add al,7
  convb_1:add al,$30
	 stosb
	 inc di
	 and ah,$0F
	 cmp ah,$0A
	 jb   convb_2
	 add ah,7
  convb_2:add ah,$30
	 mov al,ah
	 stosb
	 inc di
	 pop ax
	 ret
	 db ($$+510-$) dup 0,55h,0AAh