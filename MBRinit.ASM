;MBR
use16
org $7C00
		xor ax,ax
		mov es,ax
		mov ds,ax
		mov sp,$7FF0
		mov ax,3
		int 10h

		cmp word[$7DFE],$AA55
		jne err_load

		in al,$92  ; unlock A20
		or al,2
		out $92,al
		cld
    ;
		mov ah,$41
		mov bx,$55AA
		int 13h
		jnc ext_13h

		mov bx,$600
		mov cx,2 ;start sector
		mov ax,$0200+59;sectors till $7BFF
		mov dh,0 ;head
		int 13h
		jc err_load

		jmp INITmodule

     ext_13h:	mov byte[DAPenable],1
		mov ah,$42
		mov si,DAP
		int 13h

		jnc INITmodule

      err_load: push ds
		pop es
		mov al,ah   ; AH-code of error
		and ax,$0FF0
		cmp ah,$0A
		jb numl
		add ah,7
	numl:	add ah,$30
		shr al,4
		cmp al,$0A
		jb numh
		add al,7
	numh:	add al,$30
		mov [err_code],ax
		mov ax,$1301
		mov bl,$1F
		mov bp,err_text
		xor dx,dx
		mov cx,err_code-err_text+4
		int 10h
		cli
		hlt
		jmp $$

