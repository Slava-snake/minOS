;resource list
org $7C00
use16

SC_up=$48E0
SCAN_UP=$48
SC_left=$4BE0
SCAN_LEFT=$4B
SC_right=$4DE0
SCAN_RIGHT=$4D
SC_down=$50E0
SCAN_DOWN=$50
SC_esc=$011B
SCAN_ESC=$01
SC_space=$3920
SCAN_SPACE=$39
SC_enter=$1C0D
SCAN_ENTER=$1C
SC_tab=$0F09
SCAN_TAB=$0F
SC_f1=$3B00
SC_f2=$3C00
SC_f3=$3D00
SC_f4=$3E00
SC_f5=$3F00
SC_f6=$4000
SC_f7=$4100
SC_f8=$4200
SC_f9=$4300
SC_f10=$4400
SC_f11=$8500
SC_f12=$8600
ADR=$0CF8
DAT=$0CFC
MTRR_INFO=$9000
MTRR_LIST=$8FE0
PCI_LIST=$8400
PCI_INFO=$8800
MEM_LIST=$8000
NEW_SEG=$80
NEW_OFS=NEW_SEG shl 4
SECS   = 9

;set new segments
	mov sp,$7FFC
	mov ax,0
	mov ds,ax
	mov ss,ax
	mov ax,NEW_SEG
	mov es,ax
	mov ax,3
	int 10h
	xor bx,bx
	mov cx,2 ;
	mov ax,$0200+SECS
	mov dh,0
	int 13h
	jc error_load
	mov ax,3   ; cls
	int 10h
	jmp 0:NEW_OFS

conv_adr:  mov ah,$80 ;convert BH,BL,CH,CL => EAX-data
	   mov al,bh
	   shl eax,16
	   xor ax,ax
	   mov al,bl
	   shl ax,11
	   or ax,cx
	   ret

readPCI:   call conv_adr
	   mov ebp,eax
read_conf:;EBP-addr,  EAX-data
	   mov dx,ADR  ;EAX-addr
	   mov eax,ebp
	   out dx,eax
	   mov dx,DAT
	   in eax,dx
	   ret

writePCI:  push eax
	   call conv_adr
	   mov ebp,eax
	   pop eax
write_conf:push eax
	   mov eax,ebp
	   mov dx,ADR
	   out dx,eax
	   mov dx,DAT
	   pop eax
	   out dx,eax
	   ret

error_load:
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
	mov bp,err_txt
	xor dx,dx
	mov cx,err_code-err_txt+4
	int 10h
	cli
	hlt

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
	 jb convb_2
	 add ah,7
  convb_2:add ah,$30
	 mov al,ah
	 stosb
	 inc di
	 pop ax
	 ret

err_txt      db 'Disk read error #'
err_code     dw ?
	     db 13,10,0
last_dev_PCI dw 0
last_MTRR    dw 0
count_mem_ranges dw 0
mode	     db 0
temp0	     dd 0
temp1	     dd 0
temp2	     dd 0
phy_addr     db 0
lin_addr     db 0
MTRRvar      db 0
PATsupp      db 0
;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
;------------------------------------------------------------------------------
mMEM=0
mPCI=1
mMTRR=2
modes=3
org NEW_OFS

	 mov ax,ds
	 mov es,ax
	 call listPCI
	 call list_mem_ranges
	 call listMTTR
	 mov esi,mem_ranges
   info: mov ax,3
	 int 10h
	 xor ax,ax
	 mov [posX],0
	 mov [posY],0
	 call show_
 get_key:mov ah,10h
	 int 16h ; get_key_presssed
	 call show_scan_code
	 cmp ah,SCAN_ESC  ;<ESC>
	 je change_info
	 cmp byte[mode],mMEM
	 jne @f
	   ;control mem ranges
     @@: cmp byte[mode],mPCI
	 jne @f
	   ;control pci data
;	    mov si,[bx]
	   cmp ah,SCAN_LEFT ;left
	   jz PCIleft
	   cmp ah,SCAN_RIGHT
	   jz PCIright
	   jmp get_key
   PCIleft:cmp bx,PCI_LIST
	   jz get_key
	   sub bx,4
	   jmp PCIget_new_pos
   PCIright:cmp bx,[last_dev_PCI]
	   jz get_key
	   add bx,4
	   jmp PCIget_new_pos
   PCIget_new_pos:
	   mov si,[bx]
	   jmp info
     @@: cmp byte[mode],mMTRR
	 jnz @f
	   ;control MTRRs
;	    mov si,[bx]
	   cmp ah,SCAN_LEFT ;left
	   jz MTRRleft
	   cmp ah,SCAN_RIGHT
	   jz MTRRright
	   jmp get_key
   MTRRleft:cmp bx,MTRR_LIST
	   jz get_key
	   sub bx,2
	   jmp MTRRget_new_pos
   MTRRright: cmp bx,[last_MTRR]
	   jz get_key
	   add bx,2
	   jmp MTRRget_new_pos
   MTRRget_new_pos:
	   mov si,[bx]
	   jmp info

     @@: jmp get_key

change_info:
	 mov al,[mode]
	 inc al
	 cmp al,modes
	 jne @f
	 xor al,al
     @@: mov [mode],al
	 cmp al,mMEM
	 jne @f
	 mov si,mem_ranges
	 jmp info
     @@: cmp al,mPCI
	 jne @f
	 mov bx,PCI_LIST
	 mov si,[bx]
	 jmp info
     @@: cmp al,mMTRR
	 jne @f
	 mov si,MTRR_INFO
	 mov bx,MTRR_LIST
     @@: jmp info

listPCI:   xor ecx,ecx ; CH-function, CL-reg
	   mov edx,ecx
	   mov ebx,ecx ; BH-bus, BL-device
	   mov edi,PCI_LIST
	   mov esi,edi
next_dev:  call readPCI  ;read dev #, func 0
	   cmp ax,$FFFF
	   je next_adr
	   mov [di],ebp
	   add di,4
	   mov cl,$0C
	   call readPCI
	   bt eax,23
	   jnc next_adr
	   xor cl,cl
next_func: inc ch
	   cmp ch,8
	   jz next_adr
	   call readPCI  ;read func 1-7
	   cmp ax,$FFFF
	   je next_func
	   mov [di],ebp
	   add di,4
	   jmp next_func
next_adr:  xor cx,cx
	   inc bl
	   cmp bl,32
	   jnz next_dev
	   xor bl,bl
	   inc bh
	   jnz next_dev
	   sub di,4
	   mov [last_dev_PCI],di
	   ;fill the form of PCI data
	   mov edi,PCI_INFO
next_PCI_: mov eax,[si]
	   mov [si],di
	   mov ebp,eax
	   push si
	   ror eax,16
	   call convB
	   mov al,':'
	   stosb
	   mov ax,bp
	   shr ax,11
	   call convB
	   mov al,':'
	   stosb
	   mov ax,bp
	   mov al,ah
	   and al,$07
	   call convHB
	   mov al,13
	   stosb
	   call read_conf
	   mov si,venID
	   call copy_zstr
	   call convW
	   mov ax,'  '
	   stosw
	   shr eax,16
	   mov si,devID
	   call copy_zstr
	   call convW
	   mov ax,'  '
	   stosw
	   mov si,dev_type
	   call copy_zstr
	   or bp,8
	   call read_conf
	   call convD
	   mov al,'>'
	   stosb
	   shr eax,16
	   mov si,dev_types
	   call copy_enum2_str
	   mov al,13
	   stosb
	   mov ax,bp
	   mov al,12
	   mov bp,ax
	   call read_conf
	   shr eax,16
	   and al,3
	   cmp al,0
	   jnz @f
	   ;header type 00h; endpoint-------------------------
	   mov ax,bp
	   mov al,$2C
	   mov bp,ax
	   call read_conf
	   test eax,eax
	   jz check_bars
	   mov si,subsys
	   call copy_zstr
	   call convW
	   mov ax,'  '
	   stosw
	   shr eax,16
	   mov si,subsID
	   call copy_zstr
	   call convW
	   mov al,13
	   stosb
   check_bars:
	   mov cl,6;max BAR
	   call get_bars
	   mov ax,bp
	   mov al,$30
	   mov bp,ax
	   call read_conf
	   test eax,eax
	   jz noROM
	   call showROMaddr
   noROM:
	   jmp PCI_feat
	@@:cmp al,1
	   jnz @f
	   ;header type 01h ;bridge------------------------
	   mov cl,2;max BAR
	   call get_bars
	   mov ax,bp
	   mov al,$1C
	   mov bp,ax
	   call read_conf
	   test al,$0F
	   jz io16
	   ;32bits I/O space
      io16:cmp al,ah
	   ja check_mem
	   mov si,subspace
	   call copy_zstr
	   mov si,iospace
	   call copy_zstr
	   shl eax,8
	   call convW
	   mov al,'-'
	   stosb
	   shr eax,8
	   or ax,$0FFF
	   call convW
	   mov al,13
	   stosb
  check_mem:
	   mov ax,bp
	   mov al,$20
	   mov bp,ax
	   call read_conf
	   test eax,eax
	   jz checkROM
	   mov si,subspace
	   call copy_zstr
	   mov si,memspace
	   call copy_zstr
	   test al,$0f
	   jz mem32
	   ;64bits mem space
     mem32:mov edx,eax
	   shl eax,16
	   and eax,$FFF00000
	   call convD
	   mov al,'-'
	   stosb
	   mov eax,edx
	   or eax,$FFFFF
	   call convD
	   mov al,13
	   stosb
  checkROM:mov ax,bp
	   mov al,$38
	   mov bp,ax
	   call read_conf
	   test eax,eax
	   jz noROM1
	   call showROMaddr
	   mov al,13
	   stosb
   noROM1: mov ax,bp
	   mov al,$18
	   mov bp,ax
	   call read_conf
	   mov si,primbus
	   call copy_zstr
	   call convB
	   mov al,' '
	   stosb
	   stosb
	   mov si,secbus
	   call copy_zstr
	   shr ax,8
	   call convB
	   mov ax,'  '
	   stosw
	   mov si,subbus
	   call copy_zstr
	   shr eax,16
	   call convB
	   mov al,13
	   stosb
	@@:cmp al,2
	   jnz @f

	@@:;error header type
   PCI_feat:
	   mov ax,bp
	   mov al,$3C
	   mov bp,ax
	   call read_conf
	   cmp al,$FF
	   je no_intr
	   mov ch,ah
	   mov si,intline
	   call copy_zstr
	   call convBdec_non0
	   mov al,13
	   stosb
	   mov al,ch
	   test al,al
	   jz no_intr
	   mov si,intpin
	   call copy_zstr
	   mov ah,'#'
	   add al,$40
	   stosw
	   mov al,13
	   stosb
   no_intr:mov ax,bp
	   mov al,$34
	   mov bp,ax
	   call read_conf
	   test al,al
	   jz no_capability_ptr
	   mov si,capability
	   call copy_zstr
	   mov ah,al
   next_cap_ptr:
	   shr ax,8
	   and bp,$FF00
	   or bp,ax
	   call read_conf
	   call copy_enum_str
	   test ah,ah
	   jz last_cap_ptr
	   mov al,','
	   stosb
	   jmp next_cap_ptr
   last_cap_ptr:
	   mov al,13
	   stosb
   no_capability_ptr:
	   pop si
	   xor al,al
	   stosb
	   add si,4
	   cmp si,[last_dev_PCI]
	   jbe next_PCI_
	   ret

showROMaddr:
	   mov si,ROM
	   call copy_zstr
	   call convD
	   mov [temp0],eax
	   mov al,'-'
	   stosb
	   mov eax,$FFFFFFFF
	   call write_conf
	   call read_conf
	   not eax
	   and ax,$F000
	   add eax,[temp0]
	   or ax,$0FFF
	   call convD
	   mov eax,[temp0]
	   call write_conf
	   mov al,13
	   stosb
	   ret

get_bars:  mov ax,bp
	   mov al,$10
	   mov bp,ax
	   mov ch,0
       @@: call read_conf
	   test eax,eax
	   jz get_next_bar
	   mov [temp1],eax
	   test al,1
	   jnz get_bar_io
	   ;memory space
	   mov si,memspace
	   call copy_zstr
	   test al,8
	   jnz get_bar_no_pref
	   mov si,prefetchable
	   call copy_zstr
   get_bar_no_pref:
	   and al,7
	   cmp al,0  ;32bit addr
	   jne no32addr
	   mov al,byte[temp1]
	   and al,$F0
	   call convD
	   mov [temp0],eax
	   mov al,'-'
	   stosb
	   mov eax,$FFFFFFFF
	   call write_conf
	   call read_conf
	   not eax
	   and al,$F0
	   add eax,[temp0]
	   or al,$0F
	   call convD
	   mov ax,'  '
	   stosw
	   jmp get_next_bar_
   no32addr:
   get_bar_io: ;I/O
	   mov si,iospace
	   and eax,$0000FFFC;I/O
	   call copy_zstr
	   call convW
	   mov word[temp0],ax
	   mov al,'-'
	   stosb
	   mov eax,$FFFFFFFF
	   call write_conf
	   call read_conf
	   not ax
	   and al,$FC
	   add ax,word[temp0]
	   or al,3
	   call convW
	   mov ax,'  '
	   stosw
  get_next_bar_:
	   mov eax,[temp1]
	   call write_conf
	   mov al,13
	   stosb
  get_next_bar:
	   inc ch
	   add bp,4
	   cmp ch,cl
	   jne @b
	   ret

list_mem_ranges:xor ebx,ebx
		mov bp,bx
		mov edi,MEM_LIST
		mov esi,edi
  get_mem_range:mov eax,$E820
		mov ecx,24
		mov edx,$534D4150
		mov dword[es:edi+20],1
		int 15h
		jc copy_zstr_end
		cmp eax,$534D4150
		jne copy_zstr_end
		jcxz next_mem_range
		cmp cl,20
		jbe not_ext_range
		test byte[di+20],1
		jz next_mem_range
  not_ext_range:inc bp
		add di,24
  next_mem_range:
		test ebx,ebx
		jnz get_mem_range
		;conversion into text
		mov edi,mem_ranges
		mov ecx,24 ;step
  convert_range:mov al,[esi+4]
		call convB
		mov eax,[esi]
		call convD
		mov al,'-'
		stosb
		mov al,[esi+12]
		add al,[esi+4]
		call convB
		mov eax,[esi+8]
		add eax,[esi]
		dec eax
		call convD
		mov al,'='
		stosb
		mov eax,[esi+16]
		push esi
		mov esi,mem_types
		call copy_enum_str
		mov al,13 ;enter
		stosb
		pop esi
		add esi,ecx
		dec bp
		jnz convert_range
		mov byte[es:di],0
  noE820:	ret

listMTTR:  mov eax,$80000008
	   cpuid
	   mov word[phy_addr],ax
	   mov eax,1
	   cpuid
	   mov bx,MTRR_LIST
	   mov di,MTRR_INFO
	   bt edx,12
	   jc MTRRsup
	   mov si,noMTRR
	   call copy_zstr
	   mov [bx],si
	   mov [last_MTRR],bx
	   ret
   MTRRsup:mov ecx,$FE ;IA32_MTRRCAP
	   bt edx,16
	   jnc MTRRCAP
	   mov byte[PATsupp],1
   MTRRCAP:rdmsr
	   mov [MTRRvar],al
	   mov si,MTRR_headline
	   mov [bx],di
	   call copy_zstr
	   call convBdec_non0
	   mov si,num_MTRR_ranges
	   call copy_zstr
	   mov si,MTRR_FIX
	   call copy_zstr
	   bt ax,8
	   jc FIXsup
	   mov si,unsupported
	   jmp FIX_sup_result
    FIXsup: mov si,supported
    FIX_sup_result:
	   call copy_zstr
	   mov al,13
	   stosb
	   mov si,WCmode
	   call copy_zstr
	   bt ax,10
	   jnc noWC
	   mov si,supported
	   jmp WCresult
     noWC: mov si,unsupported
     WCresult:
	   call copy_zstr
	   mov al,13
	   stosb
	   mov si,SMRR_
	   call copy_zstr
	   bt ax,11
	   jnc noSMRR
	   mov si,supported
	   jmp SMRRresult
    noSMRR: mov si,unsupported
    SMRRresult:
	   call copy_zstr
	   mov al,13
	   stosb
	   mov si,PATtxt
	   call copy_zstr
	   test [PATsupp],1
	   jz noPAT
	   mov si,supported
	   call copy_zstr
	   mov ax,$200D
	   stosw
	   mov ecx,$277
	   rdmsr
	   mov ch,0
	   mov cl,3
	@@:xchg ch,al
	   call conv_bin_B
	   xchg ch,al
	   mov byte[es:di],'-'
	   inc di
	   mov si,range_types
	   call copy_enum_str
	   inc ch
	   shrd eax,edx,8
	   cmp ch,8
	   jne @b
	   jmp PATres
     noPAT:mov si,unsupported
	   call copy_zstr
    PATres:mov ax,$0D0D
	   stosw
	   mov ecx,$2FF  ;MTRR_DEFTYPE
	   rdmsr
	   mov si,MTRR_deftype
	   call copy_zstr
	   mov si,range_types
	   call copy_enum_str
	   mov al,13
	   stosb
	   mov si,nowMTRR
	   call copy_zstr
	   bt ax,11
	   jc MTRRen
	   mov si,disabled
	   jmp MTRRres
    MTRRen:mov si,enabled
    MTRRres:call copy_zstr
	   mov al,13
	   stosb
	   mov si,MTRR_FIX
	   call copy_zstr
	   bt ax,10
	   jc FIXen
	   mov si,disabled
	   jmp FIXres
     FIXen:mov si,enabled
     FIXres:call copy_zstr
	   mov al,13
	   stosb
	   xor al,al
	   stosb
	   ;page Fixed ranges
	   add bx,2
	   mov si,fix_ranges
	   mov [bx],di
	   call copy_zstr
	   push bx
	   mov ecx,$250 ;MTRRfix_64K
	   xor ebp,ebp	 ;start addr
	   mov ebx,$FFFF ;range limit
	   call MTRRfix_conv
	   mov ecx,$258
	   shr ebx,2
	   call MTRRfix_conv
	   inc ecx
	   call MTRRfix_conv
	   mov ecx,$268
	   shr ebx,2
       @@: call MTRRfix_conv
	   inc ecx
	   cmp ecx,$270
	   jne @b
	   xor al,al
	   stosb
	   pop bx
     variable_ranges:
	   nop
	   nop
	   cmp [MTRRvar],0
	   je  SMRR_range
	   add bx,2
	   mov [bx],di
	   mov si,var_ranges
	   call copy_zstr
	   mov ecx,$201
      var_range:
	   rdmsr
	   bt ax,11
	   jnc var_range_not_valid
	   not eax
	   not edx
	   or ax,$FFF
	   mov [temp0],eax
	   mov [temp1],edx
	   dec ecx
	   rdmsr
	   push ecx
	   mov ch,al
	   mov cl,[phy_addr]
	   sub cl,32
	   shr cl,2
	   and ax,$F000
	   mov ebp,eax
	   mov eax,edx
	   call convH
	   mov eax,ebp
	   call convD
	   mov byte[es:di],'-'
	   inc di
	   add eax,[temp0]
	   adc edx,[temp1]
	   mov ebp,eax
	   mov eax,edx
	   call convH
	   mov eax,ebp
	   call convD
	   mov al,'='
	   stosb
	   mov al,ch
	   mov si,range_types
	   call copy_enum_str
	   mov al,13
	   stosb
	   pop ecx
      var_range_not_valid:
	   add cx,3
	   cmp ecx,$210
	   jb var_range
      SMRR_range:
	   xor al,al
	   stosb
	   mov [last_MTRR],bx
	   ret

MTRRfix_conv:
	   rdmsr
	   mov [temp0],edx
	   mov edx,eax
	   push ecx
	   mov ecx,$020405
  MTRRfix_newline:
	   mov ch,4
       @@: mov eax,ebp
	   call convH
	   mov al,'-'
	   stosb
	   mov ax,bp
	   add eax,ebx
	   call convH
	   inc eax
	   mov ebp,eax ;new range
	   mov ax,' ='
	   stosw
	   stosb
	   mov al,dl
	   shr edx,8
	   and al,$0F
	   mov si,range_types
	   call copy_enum_str
	   mov ax,'  '
	   stosw
	   dec ch
	   jnz @b
	   mov edx,[temp0]
	   mov al,13
	   stosb
	   sub ecx,$10000
	   cmp ecx,$10000
	   jnb MTRRfix_newline
	   pop ecx
	   ret

show_scan_code:
	   push dword[posX]
	   mov [posX],74
	   mov [posY],24
	   push si
	   push di
	   mov si,show_buff
	   mov di,si
	   call convW
	   call show_
	   pop di
	   pop si
	   pop dword[posX]
	   ret

include 'show.asm'

var_ranges  db 'Variable ranges :',13,0
fix_ranges  db 'Fixed ranges :',13,0
range_types db 0,'UC ',0
	    db 1,'WC ',0
	    db 4,'WT ',0
	    db 5,'WP ',0
	    db 6,'WB ',0
	    db 7,'UC-',0,0

PATtxt		db 'PAT feature - ',0
MTRR_deftype	db 'Default memory type - ',0
MTRR_headline	db 3,15,'  Memory Type Range Registers  ',3,7,13,0
noMTRR		db 'no MTRR',13,0
nowMTRR 	db 'now MTRR is ',0
num_MTRR_ranges db ' - variable ranges',13,0
WCmode		db 'Write combinig (WC) mode - ',0
MTRR_FIX	db 'Fixed range registers - ',0
enabled 	db 'enabled', 0
disabled	db 'disabled',0
supported	db 'supported',0
unsupported	db 'unsupported',0
SMRR_		db 'System-Management Range Registers - ',0

mem_types  db 1,'RAM       ',0
	   db 2,'reserved  ',0
	   db 3,'ACPI      ',0
	   db 4,'NVS       ',0
	   db 5,'unusuable ',0
	   db 6,'disabled  ',0
	   db 0
undefined  db 'undefined ',0

venID	   db 'ven ID = ',0
subsys	   db 'subsystem: ven= ',0
subsID	   db 'dev= ',0
devID	   db 'dev ID = ',0
dev_type   db 'type = ',0
multfunc   db 'func = ',0
prefetchable db 'prefetchable ',0
memspace   db 'mem_range = ',0
subspace   db 'secondary bus ',0
iospace    db 'I/O_range = ',0
intpin	   db 'intr_pin = ',0
intline    db 'intr_line = ',0
ROM	   db 'ROM_image = ',0
primbus    db 'prim_bus = ',0
secbus	   db 'sec_bus = ',0
subbus	   db 'sub_bus = ',0
capability db 'supported capabilities: ',0
dev_types  db 1,0,'VGA-compatible',0
	   db 0,1,'SCSI bus controller',0
	   db 1,1,'IDE ctrl',0
	   db 2,1,'Floppy ctrl',0
	   db 5,1,'ATA ctrl',0
	   db 6,1,'SATA ctrl',0
	   db 7,1,'SAS ctrl',0
	   db $80,1,'Mass storage ctrl',0
	   db 0,2,'Ethernet ctrl',0
	   db $80,2,'Network ctrl',0
	   db 0,3,'VGA-compatible ctrl',0
	   db $80,3,'Display ctrl',0
	   db 1,4,'Audio device',0
	   db 0,4,'Video device',0
	   db $80,4,'Multimedia device',0
	   db 0,5,'RAM ctrl',0
	   db 1,5,'Flash ctrl',0
	   db $80,5,'Memory ctrl',0
	   db 0,6,'Host bridge',0
	   db 1,6,'ISA bridge',0
	   db 4,6,'PCI bridge',0
	   db $80,6,'Bridge device',0
	   db 0,7,'Serial ctrl',0
	   db 1,7,'Parallel port',0
	   db 3,7,'Modem',0
	   db 0,8,'Interrupt ctrl',0
	   db 1,8,'DMA ctrl',0
	   db 2,8,'Timer',0
	   db 3,8,'RTC',0
	   db $80,8,'System peripheral',0
	   db 0,9,'Keyboard',0
	   db 1,9,'Digitizer',0
	   db 2,9,'Mouse',0
	   db 3,9,'Scanner',0
	   db 4,9,'Gameport',0
	   db $80,9,'Input ctrl',0
	   db 0,12,'IEEE 1394',0
	   db 3,12,'USB ctrl',0
	   db 5,12,'SMbus',0
	   dw 0

capabilities db 1,'power management',0
	     db 2,'AGP port',0
	     db 3,'Vital product data',0
	     db 4,'numbering of slots and chassie',0
	     db 5,'MSI',0
	     db 6,'Hot swap',0
	     db 7,'protocol extention',0
	     db 8,'reserved for AMD',0
	     db 9,'Vendor specific',0
	     db 10,'Debug port',0
	     db 11,'PCI hot plug',0
	     db 0

mem_ranges  db 'E820 int 15h - ERROR !',512-23 dup 1,0
;free zone
	 db ($$+SECS*512-$) dup 0
