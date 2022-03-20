use16
org $7C00
SHOW_TXT=$8000 ;text
CURR_SEG=$0000 ;current segment
NEW_=$600
sektors=7
;set new segments
	mov sp,$7FFC
	mov ax,CURR_SEG
	mov ds,ax
	mov ss,ax
	mov es,ax
	mov ax,3   ; cls
	int 10h
	mov ah,$41
	mov bx,$55AA
	int 13h
	jnc ext_13h
	mov ax,NEW_ shr 4
	mov es,ax ;segment
	xor bx,bx ;offet
	mov cx,2 ;start sector
	mov ax,$0200+sektors
	mov dh,0 ;head
	int 13h
	jnc setPM
err_load:
	push ds
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
ext_13h:mov ah,$42
	mov si,DAP
	int 13h
	jc err_load
setPM:	cli
	lgdt fword[GDTR]
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp 8:NEW_
err_text      db 'Disk read error #'
err_code     dw $2020
	     db 13,10,0


;data
align 4
GDTR	 dw GDT_end-GDT-1
	 dd GDT
entry32  dd 0
cseg	 dw 8
align 16
GDT:	dq 0
	dw $FFFF,0,$9A00,$00CF ;08H CODE
	dw $FFFF,0000,$9200,$00CF     ;10h  4GB
GDT_end:
DAP	  dw 16,sektors,NEW_,0,1,0,0,0
txtbuff   db 9 dup 32,0
err_txt   db 13,'Error #'
err_num   db 32,0
foundRSDP db 'RSDP founded at '
RSDPaddr  db 8 dup 1,13,0
tabl	  db '     at '
tabaddr   db 8 dup 1,'.   ',0
tab_count    db 0
attr	     db 7
posX	     dw 0
posY	     dw 0
align 4
firmware_ctrl	 dd 0
firmware_wak_vec dd 0
Global_lock	 dd 0
localAPIC	 dd 0
IOAPICid	 dw 0
IOAPIC		 dd 0
RSDP		 dd 0
RSDT		 dd 0
tables=$7000
mcfg=$7A00

;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
;_______________________________________________________________________________

struc DescriptionHeader
  {  .signature  dd ? ; 4 ASCII character
     .length	 dd ?
     .revision	 db ?
     .checksum	 db ?
     .OEM_ID	 db 6 dup ?
     .OEMtable	 db 10 dup ?
     .OEMrev	 dd ?
     .CreatorID  dd ?
     .CreatorRev dd ?
     .FirstEntry dd ?  }

virtual at EBX
  TAB DescriptionHeader
end virtual

macro Space
  {  mov al,' '
     stosb	}

macro Enter
  {  mov al,13
     stosb	}

struc table_address
  {  .sign	 dd ?
     .addr	 dd ? }

virtual at EDX
  TAB_ADDR table_address
end virtual
;________________________________________________________________________________________
;code section
use32
org NEW_
	 mov ax,10h
	 mov es,ax
	 mov ds,ax
	 mov ss,ax
	 mov esp,$8000
      ;search 32bit services catalog
	mov esi,$E0000-16
	mov [err_num],'0'
	mov eax,'RSD '
	mov edx,'PTR '
	mov ecx,16
	mov edi,$100000
     @@:add esi,ecx
	cmp esi,edi
	jz error
	cmp [esi],eax
	jnz @b
	cmp [esi+4],edx
	jnz @b
       ;RSDP
	mov eax,esi
	mov edi,RSDPaddr
	call convD
	mov esi,foundRSDP
	call show_
	mov esi,eax
	test byte[esi+15],$F
	jnz ver20  ;ver. 2 or higher
	mov ebx,8
	mov ecx,20
	jmp @f
  ver20:mov ecx,36
	mov ebx,32
     @@:mov [err_num],'1'
	call checksum
	jnz error
	mov [err_num],'2'
	xor edx,edx
	mov ebx,[esi+16] ;addr32 of RSDT
  push esi
  mov esi,ebx
  mov cl,36
  mov edi,$E000
@@:lodsb
  call convB
  mov byte[edi],$20
  inc edi
  dec cl
  jnz @b
  mov word[edi],13
  mov esi,$E000
  call show_
  pop esi
	mov eax,'RSDT'
	cmp eax,dword[ebx]
	je tab
	mov edx,4 ;XSDT
	mov ebx,[esi+24] ;addr32 of XDST
  push esi
  mov esi,ebx
  mov cl,36
  mov edi,$E000
@@:lodsb
  call convB
  mov byte[edi],$20
  inc edi
  dec cl
  jnz @b
  mov word[edi],13
  mov esi,$E000
  call show_
  pop esi
	mov eax,'XSDT'
	cmp eax,dword[ebx]
	jne error
align 16
 tab:	mov dword[tabl],eax
	mov ecx,[ebx+4]
	sub ecx,36
	shr ecx,2
	test dl,dl

	je @f
	shr ecx,1
     @@:mov esi,ebx
	add esi,36
	mov ecx,[TAB.length]
	mov [err_num],'3'
  ;	 call checksum
  ;	 jnz error
	mov eax,ebx
	mov edi,tabaddr
	call convD
	mov esi,ebx
	mov eax,'RSDT'
	call add_table
	add esi,36
	mov eax,[TAB.length]
	sub eax,esi
	shr eax,2
	mov cl,al
	mov ebx,esi
     @@:mov esi,[ebx]
	mov eax,[esi]
	call add_table
	mov dword[tabl],eax
	mov eax,esi
	add ebx,4
	dec cl
	jnz @b
	mov [err_num],'4'

	mov esi,tables
	mov cl,[tab_count]
	mov edi,SHOW_TXT
     @@:movsd
	Space
	add esi,4
	dec cl
	jnz @b

	mov esi,SHOW_TXT
	call show_
	call CR

  align 16
	mov edi,SHOW_TXT
     ;FACP
	mov eax,'FACP'
	call find_addr
	jc @f
	stosd
	call conv_par
	Space
	mov ecx,[esi+4]
	call checksum
	jnz error
	mov eax,[esi+36]
	mov [firmware_ctrl],eax ;addr FACS
	call convD
	push ax
	Space
	pop ax
	test eax,eax
	jz facp1
	push esi
	mov esi,eax
	mov eax,[esi]
	call add_table
	pop esi
   facp1:mov eax,[esi+40];addr DSDT
	call convD
	test eax,eax
	jz error
	push esi
	mov esi,eax
	mov eax,'DSDT'
	call add_table
	pop esi
	Space
	mov al,[esi+45]
	call convB
	Space
	mov ax,[esi+46]
	call convW
	Space
	mov eax,[esi+48]
	call convD
	Space
	mov al,[esi+52]
	call convB
	Space
	mov al,[esi+53]
	call convB
	Space
	mov al,[esi+54]
	call convB
	Space
	mov al,[esi+55]
	call convB
	Space
	mov eax,[esi+56]
	call convD
	Space
	mov eax,[esi+60]
	call convD
	Space
	mov eax,[esi+64]
	call convD
	Space
	mov eax,[esi+68]
	call convD
	Space
	mov eax,[esi+72]
	call convD
	Space
	mov eax,[esi+76]
	call convD
	Space
	mov eax,[esi+80]
	call convD
	Space
	mov eax,[esi+84]
	call convD
	Space
	mov al,[esi+88]
	call convB
	Space
	mov al,[esi+89]
	call convB
	Space
	mov al,[esi+90]
	call convB
	Space
	mov al,[esi+91]
	call convB
	Space
	mov al,[esi+92]
	call convB
	Space
	mov al,[esi+93]
	call convB
	Space
	mov al,[esi+94]
	call convB
	Space
	mov al,[esi+95]
	call convB
	Space
	mov ax,[esi+96]
	call convW
	Space
	mov ax,[esi+98]
	call convW
	Space
	mov ax,[esi+100]
	call convW
	Space
	mov ax,[esi+102]
	call convW
	Space
	mov eax,[esi+112]
	call convD
	Enter


     ;FACS
     @@:mov eax,'FACS'
	call find_addr
	jc @f
	stosd
	call conv_par
	Space
       ; mov ecx,[esi+4]
       ; call checksum
       ; jnz error
	mov eax,[esi+12]
	call convD
	mov [firmware_wak_vec],eax
	Space
	mov eax,esi
	add eax,16
	mov [Global_lock],eax
	call convD
	Space
	mov eax,[esi+20]
	call convD
	Enter

     ;DSDT
     @@:mov eax,'DSDT'
	call find_addr
	jc @f
	stosd
	call conv_par
	mov ecx,[esi+4]
	call checksum
	jnz error
	Enter
     ;SSDT
     @@:mov eax,'SSDT'
	call find_addr
	jc error
	stosd
	call conv_par
	mov ecx,[esi+4]
	call checksum
	jnz error
	Enter

     ;APIC
     @@:mov eax,'APIC'
	call find_addr
	jc @f
	stosd
	call conv_par
	Space
	mov ecx,[esi+4]
	call checksum
	jnz error
	mov eax,[esi+36]
	mov [localAPIC],eax
	call convD
	Space
	mov eax,[esi+40]
	call convD
	Space
	add ecx,esi ;out of table
	mov edx,esi
	add edx,44
  apic_parse:
	mov al,[edx]
	cmp al,0
	je apic0
	cmp al,1
	je apic1
	cmp al,2
	je apic2
	cmp al,3
	je apic3
	cmp al,4
	je apic4
	cmp al,5
	je apic5
	cmp al,6
	je apic6
	cmp al,7
	je apic7
	cmp al,8
	je apic8
	cmp al,9
	je apic9
	cmp al,10
	je apic10
	cmp al,11
	je apic11
       ;skip record
	jmp apic_skip

  apic0:mov esi,procID
	call copy_zstr
	mov ax,[edx+2]
	call convD
	Space
	mov esi,locAPIC
	call copy_zstr
	mov ax,[edx+3]
	call convB
	Space
	test ah,1
	jz apic01
	mov esi,enable
	jmp apic02
  apic01:mov esi,disable
  apic02:call copy_zstr
	jmp apic_skip
  apic1:mov esi,IOAPICID
	call copy_zstr
	mov al,[edx+2]
	call convB
	Space
	mov esi,IOAPICadr
	call copy_zstr
	mov eax,[edx+4]
	call convD
	Space
	mov esi,IOAPICint
	call copy_zstr
	mov ax,[edx+8]
	call convW
	jmp apic_skip
  apic2:mov esi,IntOverRide
	call copy_zstr
	mov esi,intBUS
	call copy_zstr
	mov al,[edx+2]
	call convB
	Space
	mov al,[edx+3]
	call convB
	mov al,'-'
	stosb
	mov al,[edx+4]
	call convB
	Space
	mov ax,[edx+8]
	call convW
	jmp apic_skip
  apic3:mov esi,NMI
	call copy_zstr
	mov al,[edx+4]
	call convB
	Space
	mov al,[edx+2]
	call convB
	jmp apic_skip
  apic4:mov esi,locNMI
	call copy_zstr
	mov ax,[edx+2]
	call convW
	Space
	mov al,[edx+5]
	call convB
	Space
	mov al,[edx+3]
	call convB
	jmp apic_skip
  apic5:
  apic6:
  apic7:
  apic8:
  apic9:
  apic10:
  apic11:
	call convB
	mov al,'#'
	stosb
  apic_skip:
	mov ax,'; '
	stosw
	movzx eax,byte[edx+1]
	add edx,eax
	cmp edx,ecx
	jb apic_parse
	Enter
     ;MCFG
     @@:mov eax,'MCFG'
	call find_addr
	jc @f
	stosd
	call conv_par
	mov ecx,[esi+4]
	sub ecx,36
  mcfg1:lodsd
	call convB
	Space
	dec ecx
	jnz mcfg1
	Enter
     ;ECDT
     @@:mov eax,'ECDT'
	call find_addr
	jc @f
	stosd
	call conv_par
	Space
	mov edx,36
	add edx,esi
	mov eax,'EC_C'
	stosd
	mov eax,'trl:'
	stosd
	call convGAS
	Space
	add edx,12
	mov eax,'EC_D'
	stosd
	mov eax,'ata:'
	stosd
	call convGAS
	Space
	mov esi,gpe_bit
	call copy_zstr
	mov al,[esi+64]
	call convB
	Space
	add esi,65
	call copy_zstr
	Enter

      ;HPET
     @@:mov eax,'HPET'
	call find_addr
	jc @f
	stosd
	call conv_par
	mov ax,[esi+38]
	call convW
	Space
	mov al,[esi+52]
	call convB
	Space
	mov edx,40
	add edx,esi
	call convGAS
	mov esi,num
	call copy_zstr
	mov al,[esi+37]
	and al,15
	call convB
	Space
	mov esi,min
	call copy_zstr
	mov ax,[esi+53]
	call convW
	Space
	mov al,[esi+55]
	call convB
	Enter

  align 16
     ;;show results
     @@:mov esi,SHOW_TXT
	call show_
	nop
	mov dx,$B2
	mov al,$f1
	out dx,al
	jmp $


  align 32
;error--------------------------
  error:nop
	push edi
	push esi
	push eax
	mov esi,err_txt
	call show_
	mov edi,regEAX
	pop eax
	call convD
	mov edi,ptrEAX
	mov eax,[eax]
	call convD

	mov edi,regEBX
	mov eax,ebx
	call convD
	mov edi,ptrEBX
	mov eax,[ebx]
	call convD

	mov edi,regECX
	mov eax,ecx
	call convD
	mov edi,ptrECX
	mov eax,[ecx]
	call convD

	mov edi,regEDX
	mov eax,edx
	call convD
	mov edi,ptrEDX
	mov eax,[edx]
	call convD

	mov edi,regESI
	pop eax
	call convD
	mov edi,ptrESI
	mov eax,[eax]
	call convD

	mov edi,regEDI
	pop eax
	call convD
	mov edi,ptrEDI
	mov eax,[eax]
	call convD

	mov esi,show_regs
	call show_
	hlt

CR:	mov [posX],0
	inc [posY]
	ret
show_:	;ESI-start
	push eax
	push edx
	push bp
	push cx
	push edi
	mov bp,160
	mov ax,[posY]
	mul bp
	movzx edi,ax
	mov ax,[posX]
	mov cl,al
	shl ax,1
	add di,ax
	add edi,$B8000
	mov ah,[attr]
	mov ch,ah
  show_txt:
	lodsb
	test al,al
	jz end_show	 ;0-stop
	cmp al,1	 ;1-skip char
	jz show_txt
  show_txt_1:
	cmp al,13
	jnz show_char
	mov ax,di
	and ax,$0FFF
	div bp
	inc ax
	mul bp
	add ax,$8000
	mov di,ax
	mov ah,ch
	xor cl,cl
	inc [posY]
	jmp show_txt
  show_char:
	stosw
	inc cl
	cmp cl,80
	jne show_txt
	inc byte[posY]
	xor cl,cl
	jmp show_txt
  end_show:
	mov byte[posX],cl
	pop edi
	pop cx
	pop bp
	pop edx
	pop eax
	ret

find_addr: ;EAX-signature
	   ;=> ESI-addr
	push cx
	xor cl,cl
	mov esi,tables
    @@: cmp eax,[esi]
	je find_a
	add esi,8
	inc cl
	cmp cl,[tab_count]
	jne @b
	pop cx
	stc
	ret
 find_a:mov esi,[esi+4]
	pop cx
	clc
	ret

add_table:; EAX-signature, ESI-addr
	push edx
	movsx edx,[tab_count]
	shl edx,3
	add edx,tables
	mov [edx],eax
	mov [edx+4],esi
	inc byte[tab_count]
	pop edx
	ret

checksum: ;ESI-start; ECX-count
	  ;=> ZF=1 checksum is Ok
	push cx
	xor al,al
     @@:add al,byte[esi+ecx-1]
	dec cx
	jnz @b
	test al,al
	pop cx
	ret

dumpbytes:
	push edx
	push edi
	push ecx
	push eax
	xor edx,edx
     @@:mov edi,txtbuff
	mov al,[esi+edx]
	call convB
	mov word[edi],$20
	push esi
	mov esi,txtbuff
	call show_
	pop esi
	inc edx
	dec ecx
	jnz @b
	pop eax
	pop ecx
	pop edi
	pop edx
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

showD:	 push eax
	 push esi
	 push edi
	 mov edi,txtbuff
	 mov esi,edi
	 call convD
	 call show_
	 pop edi
	 pop esi
	 pop eax
	 ret

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

convGAS: ;EDX-pointer
	 push eax
	 mov al,[edx]
	 cmp al,0
	 je convGAS0
	 cmp al,1
	 je convGAS1
	 cmp al,2
	 je convGAS2
	 cmp al,3
	 je convGAS3
	 cmp al,4
	 je convGAS4
	 cmp al,10
	 je convGASA
	 cmp al,$7F
	 je convGAS7f
	 cmp al,$C0
	 jae convGASC0
  convGAS0:
	 mov eax,'mem_'
	 jmp convGASu
  convGAS1:
	 mov eax,'I/O_'
	 stosd
	 mov ax,[edx+4]
	 call convW
	 jmp convGASw
  convGAS2:
	 mov eax,'PCI_'
	 stosd
	 mov ax,':0'
	 stosw
	 mov al,[edx+8]
	 call convB
	 mov al,':'
	 stosb
	 mov al,[edx+6]
	 call convB
	 mov al,':'
	 stosb
	 mov ax,[edx+4]
	 call convW
	 jmp convGASw
  convGAS3:
	 mov eax,'ECn_'
	 jmp convGASu
  convGAS4:
	 mov eax,'SMB_'
	 jmp convGASu
  convGASA:
	 mov eax,'PCC_'
	 jmp convGASu
  convGAS7f:
	 mov eax,'FFH_'
	 jmp convGASu
  convGASC0:
	 mov eax,'OEM_'
  convGASu:
	 stosd
	 mov eax,[edx+8]
	 call convD
	 mov eax,[edx+4]
	 call convD
  convGASw:
	 mov al,'['
	 stosb
	 mov al,[edx+1]
	 call convB
	 mov al,':'
	 stosb
	 mov al,[edx+2]
	 call convB
	 mov al,']'
	 stosb
	 movzx eax,byte[edx+3]
	 add eax,acc_size
	 mov al,[eax]
	 stosb
	 pop eax
	 ret

conv_par:mov al,'['
	 stosb
	 mov eax,esi
	 call convD
	 mov ax,']('
	 stosw
	 mov ax,[esi+4]
	 call convW
	 mov ax,') '
	 stosw
	 ret
;__________________________________________________
;data area
show_regs db 13,'EAX='
regEAX	  db 8 dup 1,' ['
ptrEAX	  db 8 dup 1,']',13,'EBX='
regEBX	  db 8 dup 1,' ['
ptrEBX	  db 8 dup 1,']',13,'ECX='
regECX	  db 8 dup 1,' ['
ptrECX	  db 8 dup 1,']',13,'EDX='
regEDX	  db 8 dup 1,' ['
ptrEDX	  db 8 dup 1,']',13,'ESI='
regESI	  db 8 dup 1,' ['
ptrESI	  db 8 dup 1,']',13,'EDI='
regEDI	  db 8 dup 1,' ['
ptrEDI	  db 8 dup 1,']',13,0

procID	  db 'ProcID:',0
locAPIC   db 'APICid:',0
enable	  db 'EN ',0
disable   db 'DIS ',0
IOAPICID  db 'IO_APICid:',0
IOAPICadr db 'IO_APIC:',0
IOAPICint db 'IO_APIC_int:',0
IntOverRide db 'Interrupt Override: ',0
intBUS	  db 'bus:',0
NMI	  db 'NMI: ',0
locNMI	  db 'LocalNMI: ',0
acc_size  db 'UBWDQ ',0
gpe_bit   db 'GPEbit:',0
min	  db 'min:',0
num	  db 'num:',0
;-------------------------------------
	 db (sektors*512-$+$$) dup $FF