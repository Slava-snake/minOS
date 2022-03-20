;Data for 3.asm
use32
org 600h
GDT:	dq 0
	dw $1FFF,0,$9A00,$40 ;08H CODE
	dw $FFFF,0000,$9200,$00CF     ;10h  4GB
GDT_end:

RSDT	  dd 0
XSDT	  dd 0
posX	  dw 0
posY	  dw 0
color	  db 7

align 16
show_apic db 'MSR(APIC_base): '
show_msr  db 10 dup $20,'  Base: '
show_base db 8 dup 0,13,'ID: '
show_id   db 8 dup 0,'   Version: '
show_ver  db 8 dup 0,'   Logical Destination: '
show_ldr  db 8 dup 0,13,'Destination Format: '
show_dfr  db 8 dup 0,'   Spuroius Vector: '
show_spur db 8 dup 0,13,'Error Status: '
show_esr  db 8 dup 0,13,0
show_rsdp db 'OEM ID: '
show_oemid db 6 dup $20,'   revision: '
show_rev  db 4 dup $20,0
show_rsdt_loc db '   RSDT XSDT address:'
show_rsdt db 8 dup $20,$20
show_xsdt db 16 dup $20,13,'#'
show_rsdt_sig db 4 dup $20,'#   length: '
show_rsdt_len db 8 dup $20,'   rev: '
show_rsdt_rev  db 2 dup $20,'   OEM ID: '
show_rsdt_oem  db 6 dup $20,13,'OEMtableID: '
show_rsdt_tab  db 8 dup $20,13
show_tabs db 80 dup $20    ;whole row
show_table db 0

show_end db 0

	 db ($A00-$+$$) dup 0
;code section
org 1000h
	 mov ax,10h
	 mov es,ax
	 mov ds,ax
	 mov ss,ax
	 mov esp,$7FF0
	 call apic
	 mov esi,show_apic
	 call show_
      ;search RDSP
	mov esi,$E0000-16
	mov eax,'RSD '
	mov ebx,'PTR '
	mov ecx,16
     @@:add esi,ecx
	cmp eax,[esi]
	jnz @b
	cmp ebx,[esi+4]
	jnz @b
       ;bingo
	mov ebx,esi ;EBX-addr of RDSP
	mov ah,[ebx+20]
	mov edx,[ebx+24]; XSDT
	xor al,al
	test ah,ah
	jnz @f
	mov eax,[ebx+16]
	mov [RSDT],eax
	mov edx,eax
	mov ah,20   ;size of RSDP(1.0)
     @@:add al,[esi]
	inc esi
	dec ah
	jnz @b
	test al,al
	jnz show_err_rsdp
	mov esi,ebx
	add esi,9
	mov edi,show_oemid
	movsd ;4 bytes copy
	movsw ;+2 bytes copy
	mov eax,[ebx+16]
	mov edi,show_rsdt
	call conv
	mov eax,'0.0 '
	mov al,[ebx+15]
	add al,$31
	mov dword[show_rev],eax
	mov ebp,4
	cmp dword[RSDT],0
	jnz s2
CP 1
	;revision 2.0 or higher
   s1:	mov eax,[ebx+28]
	mov edi,show_xsdt
	call conv
	mov eax,[ebx+24]
	call conv
	mov ebp,8
	;RSDT
     s2:mov esi,show_rsdp
	call show_
	mov ebx,edx
	add edx,36 ; EDX-addr of the 1st table
	mov edi,show_rsdt_sig
	mov esi,ebx
	movsd
	mov eax,[ebx+4]
	mov edi,show_rsdt_len
	call conv
	mov al,[ebx+8]
	mov edi,show_rsdt_rev
	call convbyte
	mov esi,ebx
	add esi,10
	mov ecx,3
	mov edi,show_rsdt_oem
	rep movsw
	mov ecx,2
	mov edi,show_rsdt_tab
	rep movsd
	add ebx,[ebx+4] ; out of RSDT
	mov edi,show_tabs
	mov al,$20
    s3: mov esi,[edx]
	movsd
	stosb
	add edx,ebp
	cmp edx,ebx
	jb s3
align 16
CP 2
       ;all tables
	mov ebx,[RSDT]
	mov edx,ebx
	add edx,36; EDX-pointer to the 1st entry
	mov ebp,[ebx+4]
	add ebp,ebx
	mov edi,show_table
     s4:mov ebx,[edx]; EBX-addr of table
	mov esi,ebx
	movsd
	mov byte[edi],$20
	inc edi
	mov ecx,[TAB.length]
	sub ecx,36
	mov esi,ebx
	add esi,36
    s5: lodsb
	call convbyte
	mov byte[edi],$20
	inc edi
	dec ecx
	jnz s5
	mov byte[edi],13
	inc edi
	add edx,4
	cmp edx,ebp
	jb s4
	mov [color],$70
	mov esi,show_rsdt_loc
	call show_

	jmp $

;show
show_:	;ESI-text
	pushad
	mov edi,$B8000
	mov bp,160
	mov ax,[posY]
	mul bp
	add di,ax
	mov ax,[posX]
	shl ax,1
	add di,ax
	mov ah,[color] ;color
	mov ch,ah
  show_txt:
	lodsb
	test al,al
	jz end_show		 ;stop
	cmp al,13
	jnz show_char
	mov ax,di
	sub ax,$8000
	div bp
	inc ax
	cmp ax,25
	jnz show_txt_next_row
	;shift up screen
	push esi
	push ecx
	mov esi,$B80A0
	mov edi,$B8000
	mov ecx,960
	rep movsd
	mov ax,$0720
	mov ecx,80
	rep stosw
	mov edi,$B8000+160*24
	pop ecx
	pop esi
	jmp show_txt_bottom_row
  show_txt_next_row:
	mul bp
	xor dx,dx
	add ax,$8000
	mov di,ax
  show_txt_bottom_row:
	mov ah,ch
	jmp show_txt
  show_char:
	stosw
	jmp show_txt
  end_show:
	mov ax,di
	sub ax,$8000
	div bp
	mov [posY],ax
	shr dx,1
	mov [posX],dx
	popad
	retd

err_rsdp db 'Error RSDP '
show_err_rsdp:
	mov edi,show_oemid
	mov esi,err_rsdp
	mov ecx,show_err_rsdp-err_rsdp
  err_msg:
;	 rep movsb
	mov ecx,$100
	xor eax,eax
;	 rep stosd
	jmp show_

err_xrsdp db 'Error XSDP '
show_err_xrsdp:
	mov edi,show_oemid
	mov esi,err_xrsdp
	mov ecx,show_err_xrsdp-err_xrsdp
	jmp err_msg

err_rsdt db 'Error RSDT '
show_err_rsdt:
	mov edi,show_rsdt
	mov esi,err_rsdt
	mov ecx,show_err_rsdt-err_rsdt
	jmp err_msg

check_sum:
	mov ecx,[TAB.length]
	mov esi,ebx
	xor ah,ah
  check_sum_1:
	lodsb
	add ah,al
	dec ecx
	jnz check_sum_1
	test ah,ah
	retd

conv:
	 mov cl,4
  conv_0:
	 rol eax,8
	 push eax
	 call convbyte
	 pop eax
	 dec cl
	 jnz   conv_0
	 retd

convbyte:mov ah,al
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
	 retd

;APIC
apic:	mov ecx,$1B
	rdmsr
	mov edi,show_msr
	call conv
	and ax,$F000
	mov edi,show_base
	call conv
	mov edx,eax; EDX-base
	mov eax,[edx+$20]
	mov edi,show_id
	call conv
	mov eax,[edx+$30]
	mov edi,show_ver
	call conv
	mov eax,[edx+$D0]
	mov edi,show_ldr
	call conv
	mov eax,[edx+$E0]
	mov edi,show_dfr
	call conv
	mov eax,[edx+$F0]
	mov edi,show_spur
	call conv
	mov eax,[edx+$280]
	mov edi,show_esr
	call conv
      ;end APIC
	retd
	 db 1024+$$-$ dup 0
