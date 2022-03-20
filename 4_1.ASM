;
use32
org 600h
GDT:	dq 0
	dw $1FFF,0,$9A00,$40 ;08H CODE
	dw $FFFF,0000,$9200,$00CF     ;10h  4GB
GDT_end:
color	dd $10000
col	dd 0
row_ofs dd 0
step	dd 3
log_line dd 0
width	dd 0
out_scr     dd 0
Bpp	db 0,0,0,0
x      dd 255
y      dd 3
w      dd 2
h      dd 500
c      dd $A0DE80

show_txt db 'signature: '
show_sig db 4 dup 0,'   ver: '
show_verH db 0,0,'.'
show_verL db 0,0,'  Video memory: '
show_vmem db 8 dup $20,' kB',13,10,'OEM: '
show_oem db 75 dup $20,13,10
show_others db 200 dup $20
show_end:

	 db ($A00-$+$$) dup 0

;code section
org 1000h
	 mov ax,10h
	 mov es,ax
	 mov ds,ax
	 mov ss,ax
	 mov esp,$7FF0
	 mov edi,[LFB]
	 xor eax,eax
	 mov ebx,eax
	 mov edx,eax
	 mov ecx,eax
	 mov ebp,eax
	 mov ax,[$8210] ;logic_line_size = width * bytes_per_pixel
	 mov [log_line],eax
	 mov ax,[$8212]
	 mov [width],eax
	 mov ax,[$8214] ;height
	 mul word[log_line];height * logic_line_size = out_of_screen
	 mov word[out_scr],ax
	 mov word[out_scr+2],dx
	 mov edx,[out_scr]
	 mov al,[$8219] ;bits per pixel
	 shr al,3
	 mov [Bpp],al
   next_col:
	 xor ebx,ebx ;offset in col
   next_row:
	 mov eax,ecx ;offset in row
	 add eax,ebx
	 mov [edi+eax],ebp
	 add ebx,[log_line]
	 cmp ebx,edx
	 jnz next_row
	 add ebp,[color]
	 add ecx,dword[Bpp]
	 inc [col]
	 mov al,byte[col]
	 test al,al
	 jnz next_col
	 shr dword[color],8
	 xor ebp,ebp
	 dec [step]
	 jnz next_col
align 32
    ;bar in center  3bytes per pixel
	 mov eax,[w]
	 dec eax
	 mov bx,3
	 mul bx
	 shl edx,16
	 add eax,edx; width in bytes without last
	 mov [width],eax
	 dec dword[w]
	 mov ecx,[w]
	 mov ebp,[log_line]
	 sub ebp,eax
	 mov eax,[x]
	 mul bx
	 shl edx,16
	 add eax,edx
	 mov [x],eax; offset in row
	 mov eax,[y]
	 mov bx,word[log_line]
	 mul bx
	 shl edx,16
	 add eax,edx
	 add eax,[LFB]
	 add eax,[x]
	 mov [y],eax
	 mov edi,eax; addr of the 1st pixel
	 mov eax,[c]
	 mov ebx,$FF000000
	 mov esi,[h]
      @@:mov [edi],eax; draw
	 add edi,3    ; the
	 dec ecx      ; line
	 jnz @b       ; of bar
	 mov edx,[edi]
	 and edx,ebx
	 or edx,eax
	 mov [edi],edx
	 add edi,ebp
	 mov ecx,[w]
	 dec esi
	 jnz @b
	 jmp $

	 db 512+$$-$ dup 0
