;Data for 5.asm
use32
org 600h
GDT:	dq 0
	dw $1FFF,0,$9A00,$40 ;08H CODE
	dw $FFFF,0000,$9200,$00CF     ;10h  4GB
GDT_end:

curr_tab   db 0
tab_count  db 0
tab_pos    dd show_all_types

show_start db 4 dup $20,'  at '
show_addr_ep db 8 dup $20,13,'length: '
show_len   db 2 dup $20,'  ver: '
show_verh  db 2 dup $20,'.'
show_verl  db 2 dup $20,'  structure''s max size : '
show_size  db 4 dup $20,' rev: '
show_rev   db 2 dup $20,13
show_intermed_str db 5 dup $20,13,'tab_length: '
show_tab_len db 4 dup $20,'  tab_address: '
show_addr  db 8 dup $20,13,'number of structures: '
show_nstruc db 4 dup $20,'  rev: '
show_bcd_rev db 2 dup $20,13,0

show_BIOS_info	   db 3,15,'*BIOS information*  ',3,7,' BIOS vendor: '
show_BIOS_ven	   db 20 dup 1,'  BIOS version: '
show_BIOS_ver	   db 20 dup 1,13,' BIOS address: '
show_BIOS_addr	   db 4 dup $20,'0   BIOS date: '
show_BIOS_date	   db 16 dup 1,'   BIOS size: '
show_BIOS_size	   db '  0000 bytes ',13,' BIOS support: '
show_BIOS_support  db 256 dup 1,13,' BIOS vendor: '
show_BIOS_vendor   db 4 dup $20,'   System vendor: '
show_sys_vendor    db 4 dup $20,'  System BIOS release: '
show_sys_relh	   db 1,1,1,'.'
show_sys_rell	   db 1,1,1,13,0

show_BIOS_no_characteristics db '<characteristics are not supported>'

unknown  db '<unknown>',0

show_system_info   db 3,15,'*System information*  ',3,7,'Manufacturer: '
show_sys_manufact  db 30 dup 1,'  Product name: '
show_prod_name	   db 30 dup 1,13,' version: '
show_sys_version   db 30 dup 1,'  Serial number: '
show_sys_serial    db 32 dup 1,13,' UUID: {'
show_sys_UUID	   db '        -    -    -    -            }  SKU: '
show_sys_SKU	   db 32 dup 1,'  Family: '
show_sys_family    db 30 dup 1,13,' Wake-up: '
show_sys_wakeup    db 40 dup 1,13,0

show_proc_info	   db 3,15,'*Processor information* ',3,7,'length: '
show_proc_len	   db 3 dup 1,'  Socket: '
show_proc_socket   db 20 dup 1,'  ','Type: '
show_proc_type	   db 20 dup 1,13,' Family:'
show_proc_family   db 32 dup 1,'  Manufacturer: '
show_proc_manufact db 32 dup 1,13,' version: '
show_proc_version  db 16 dup 1,' voltage: '
show_proc_voltage  db 16 dup 1,13,' ExtClock: '
show_proc_extclock db 9 dup 1,' MHz  MaxSpeed: '
show_proc_maxclock db 9 dup 1,' MHz  CurrentSpeed: '
show_proc_curclock db 9 dup 1,' MHz',13,' Status: '
show_proc_status   db 50 dup 1,13,' Serial: '
show_proc_serial   db 32 dup 1,'  Asset: '
show_proc_asset    db 32 dup 1,' Part: '
show_proc_part	   db 32 dup 1,13
show_proc_cores    db 9 dup 1,' Cores  '
show_proc_core_en  db 9 dup 1,' cores enabled  '
show_proc_threads  db 9 dup 1,' thread count ',13,0

show_physmem_info  db 3,15,'*Physical Memory Array*  ',3,7,'length: '
show_physmem_len   db 1,1,'  Location: '
show_physmem_loc   db 22 dup 1,'  Use: '
show_physmem_use   db 20 dup 1,13,' Max Capacity: '
show_physmem_max   db 10 dup 1,' kB',13,0

show_memmap_info   db 3,15,'*Memory Array Mapped Address*   ',3,7,'Area: '
show_memmap_start  db 8 dup 1,'-'
show_memmap_end    db 8 dup 1,'   Partition width: '
show_memmap_width  db 3 dup 1,13,0

show_memdev_info   db 3,15,'*Memory Device Information*   ',3,7,'length: '
show_memdev_len    db 1,1,'  Size: '
show_memdev_size   db 9 dup 1,' Form factor: '
show_memdev_form   db 18 dup 1,13,' Device: '
show_memdev_dev    db 20 dup 1,'  Bank: '
show_memdev_bank   db 20 dup 1,'  Type: '
show_memdev_type   db 20 dup 1,13,' Detail: '
show_memdev_detail db 70 dup 1,13,0

show_onboard_info  db 3,15,'*On-board Devices*   ',3,7,13,' '
show_onboard_dev   db 256 dup 1,0
show_no_sm db '_SM_ not found'

show_all_tab   db  'Table types: '
show_all_types db  67 dup ' ',0
	 db ($A00-$+$$) dup 0

;code section
org 1000h
	 mov ax,10h
	 mov es,ax
	 mov ds,ax
	 mov ss,ax
	 mov esp,$7FF0
      ;search SM entry point
	mov esi,$F0000-16
	mov eax,'_SM_'
	mov ecx,16
	mov edx,$100000
     @@:add esi,ecx
	cmp esi,edx
	jz no_sm_
	cmp eax,[esi]
	jnz @b
      ;bingo
	mov ebx,esi
	mov eax,esi
	mov edi,show_addr_ep
	call convD
	mov edi,show_start
	movsd
	mov al,[SMep.length]
	mov edi,show_len
	call convB
	mov al,[SMep.major_ver]
	mov edi,show_verh
	call convB
	mov al,[SMep.minor_ver]
	mov edi,show_verl
	call convB
	mov al,[SMep.major_ver]
	mov edi,show_verh
	call convB
	mov ax,[SMep.max_size]
	mov edi,show_size
	call convW
	mov al,[SMep.revision]
	mov edi,show_rev
	call convB
	mov ecx,5
	mov edi,show_intermed_str
	mov esi,SMep.intermed_str-SMep.signature
	add esi,ebx
	rep movsb
	mov ax,[SMep.tab_length]
	mov [tab_count],al
	mov edi,show_tab_len
	call convW
	mov eax,[SMep.tab_addr]
	mov edi,show_addr
	call convD
	mov ax,[SMep.num_struc]
	mov edi,show_nstruc
	call convW
	mov al,[SMep.bcd_rev]
	mov edi,show_bcd_rev
	call convB
	mov esi,show_start
	call show_
      ;parse tables
	mov edx,[SMep.tab_addr]
	movzx ebx,word[SMep.tab_length]
	add ebx,edx ;EBX- out the structures
align $20
  parse_tab:
	mov edi,[tab_pos]
	mov al,byte[edx]
	call convB
	inc edi
	mov [tab_pos],edi
	  cmp al,tBIOSinfo
	    jz parseBIOSinfo
	  cmp al,tSystemInfo
	    jz parseSystemInfo
	  cmp al,tProcessorInfo
	    jz parseProcessorInfo
	  cmp al,tPhysMemArray
	    jz parsePhysMemArray
	  cmp al,tMemoryDevice
	    jz parseMemoryDevice
	  cmp al,tMemMapAddress
	    jz parseMemMapAddress
	  cmp al,tOnboardInfo
	    jz parseOnboardInfo
  next_struc:
	inc [curr_tab]
	mov al,[tab_count]
	cmp al,[curr_tab]
	jz show_all_tab_types
	add dl,byte[edx+1]
	jnc next_struc1
	add edx,$100
  next_struc1:
	mov ax,[edx]
	inc edx
	test ax,ax
	jnz next_struc1
	inc edx
	cmp edx,ebx
	jb parse_tab
	jmp show_all_tab_types

parseBIOSinfo:
	xor ecx,ecx
	mov al,[BIOS.vendor]
	call find_str
	mov edi,show_BIOS_ven
	call copy_zstr
    bios_ver:
	mov al,[BIOS.version]
	test al,al
	jz bios_date
	call find_str
	mov edi,show_BIOS_ver
	call copy_zstr
    bios_date:
	mov al,[BIOS.date]
	test al,al
	jz bios_no_str
	call find_str
	mov edi,show_BIOS_date
	call copy_zstr
    bios_no_str:
	mov ax,[BIOS.start_seg]
	mov edi,show_BIOS_addr
	call convW
	mov al,[BIOS.ROMsize]
	inc al
	mov edi,show_BIOS_size
	call convB
	mov eax,dword[BIOS.characteristics]
	mov edi,show_BIOS_support
	test al,$8
	jz parseBIOSinfo0
	mov esi,show_BIOS_no_characteristics
	mov ecx,unknown-show_BIOS_no_characteristics
	rep movsb
	jmp parseBIOSinfo1
   parseBIOSinfo0:
	  test al,$10
	  jnz BIOSchar1
	  mov dword[edi],'ISA '
	  add edi,4
      BIOSchar1:
	  test al,$20
	  jnz BIOSchar2
	  mov dword[edi],'MCA '
	  add edi,4
      BIOSchar2:
	  test al,$40
	  jnz BIOSchar3
	  mov dword[edi],'EISA'
	  mov byte[edi+4],' '
	  add edi,5
      BIOSchar3:
	  test al,$80
	  jnz BIOSchar4
	  mov dword[edi],'PCI '
	  add edi,4
      BIOSchar4:
	  test ax,$100
	  jnz BIOSchar5
	  mov dword[edi],'PCMC'
	  mov word[edi+4],'IA'
	  mov byte[edi+6],' '
	  add edi,7
      BIOSchar5:
	  test ax,$200
	  jnz BIOSchar6
	  mov dword[edi],'Plug'
	  mov dword[edi+4],'''n''P'
	  mov dword[edi+8],'lay '
	  add edi,12
      BIOSchar6:
	  test ax,$400
	  jnz BIOSchar7
	  mov dword[edi],'APM '
	  add edi,4
      BIOSchar7:
	  test ax,$800
	  jnz BIOSchar8
	  mov dword[edi],'Flas'
	  mov dword[edi+4],'hBIO'
	  mov word[edi+8],'S '
	  add edi,10
      BIOSchar8:
	  test ax,$1000
	  jnz BIOSchar9
	  mov dword[edi],'Shad'
	  mov dword[edi+4],'owin'
	  mov word[edi+8],'g '
	  add edi,10
      BIOSchar9:
	  test ax,$2000
	  jnz BIOSchar10
	  mov dword[edi],'VL-V'
	  mov dword[edi+4],'ESA '
	  add edi,8
      BIOSchar10:
	  test ax,$4000
	  jnz BIOSchar11
	  mov dword[edi],'ESCD'
	  mov byte[edi+4],' '
	  add edi,5
      BIOSchar11:
	  test ax,$8000
	  jnz BIOSchar12
	  mov dword[edi],'boot'
	  mov dword[edi+4],'_CD '
	  add edi,8
      BIOSchar12:
	  test eax,$10000
	  jnz BIOSchar13
	  mov dword[edi],'Sele'
	  mov dword[edi+4],'ct_b'
	  mov dword[edi+8],'oot '
	  add edi,12
      BIOSchar13:
	  test eax,$20000
	  jnz BIOSchar14
	  mov dword[edi],'ROM_'
	  mov dword[edi+4],'is_s'
	  mov dword[edi+8],'ocke'
	  mov dword[edi+12],'ted '
	  add edi,16
      BIOSchar14:
	  test eax,$40000
	  jnz BIOSchar15
	  mov dword[edi],'PCMC'
	  mov dword[edi+4],'IA_b'
	  mov dword[edi+8],'oot '
	  add edi,12
      BIOSchar15:
	  test eax,$80000
	  jnz BIOSchar16
	  mov dword[edi],'EDD '
	  add edi,4
      BIOSchar16:
	  test eax,$100000
	  jnz BIOSchar17
	  mov dword[edi],'NEC9'
	  mov dword[edi+4],'800_'
	  mov dword[edi+8],'1.2M'
	  mov byte[edi+12],' '
	  add edi,13
      BIOSchar17:
	  test eax,$200000
	  jnz BIOSchar18
	  mov dword[edi],'Tosh'
	  mov dword[edi+4],'iba_'
	  mov dword[edi+8],'1.2M'
	  mov byte[edi+12],' '
	  add edi,13
      BIOSchar18:
	  test eax,$400000
	  jnz BIOSchar19
	  mov dword[edi],'5.25'
	  mov dword[edi+4],'"/36'
	  mov word[edi+8],'0K'
	  mov byte[edi+10],' '
	  add edi,11
      BIOSchar19:
	  test eax,$800000
	  jnz BIOSchar20
	  mov dword[edi],'5.25'
	  mov dword[edi+4],'"/1.'
	  mov word[edi+8],'2M'
	  mov byte[edi+10],' '
	  add edi,11
      BIOSchar20:
	  test eax,$1000000
	  jnz BIOSchar21
	  mov dword[edi],'3.5"'
	  mov dword[edi+4],'/720'
	  mov word[edi+8],'K '
	  add edi,10
      BIOSchar21:
	  test eax,$2000000
	  jnz BIOSchar22
	  mov dword[edi],'3.5"'
	  mov dword[edi+4],'/2.8'
	  mov word[edi+8],'8M'
	  mov byte[edi+10],' '
	  add edi,11
      BIOSchar22:
	  test eax,$4000000
	  jnz BIOSchar23
	  mov dword[edi],'Prin'
	  mov dword[edi+4],'tScr'
	  mov byte[edi+8],' '
	  add edi,9
      BIOSchar23:
	  test eax,$8000000
	  jnz BIOSchar24
	  mov dword[edi],'8042'
	  mov dword[edi+4],'keyb'
	  mov byte[edi+8],' '
	  add edi,9
      BIOSchar24:
	  test eax,$10000000
	  jnz BIOSchar25
	  mov dword[edi],'COM '
	  add edi,4
      BIOSchar25:
	  test eax,$20000000
	  jnz BIOSchar26
	  mov dword[edi],'LPT '
	  add edi,4
      BIOSchar26:
	  test eax,$40000000
	  jnz BIOSchar27
	  mov dword[edi],'CGA/'
	  mov dword[edi+4],'Mono'
	  mov byte[edi+8],' '
	  add edi,9
      BIOSchar27:
	  test eax,$80000000
	  jnz BIOSchar28
	  mov dword[edi],'NEC_'
	  mov dword[edi+4],'PC-9'
	  mov word[edi+8],'8 '
	  add edi,10
      BIOSchar28:
	  mov ebp,edi
	  mov eax,dword[BIOS.characteristics+4]
	  mov edi,show_BIOS_vendor
	  call convW
	  shr eax,16
	  mov edi,show_sys_vendor
	  call convW
	xor ecx,ecx
	mov cl,[BIOS.header.length]
	sub cl,$12
	test cl,cl
	jz parseBIOSinfo1
	sub cl,4  ;;CL-extension bytes
	mov al,[BIOS.major_ver+ecx]
	mov edi,show_sys_relh
	call convBdec
	mov edi,show_sys_rell
	mov al,[BIOS.minor_ver+ecx]
	call convBdec
	test cl,cl
	jz parseBIOSinfo1
	mov al,[edx+$12]
	mov edi,ebp
	test al,al
	jz BIOSextchar_2
	  test al,1
	  jz BIOSextchar1
	  mov dword[edi],'ACPI'
	  mov byte[edi+4],' '
	  add edi,5
      BIOSextchar1:
	  test al,2
	  jz BIOSextchar2
	  mov dword[edi],'USB_'
	  mov dword[edi+4],'lega'
	  mov word[edi+8],'cy'
	  mov byte[edi+10],' '
	  add edi,11
      BIOSextchar2:
	  test al,4
	  jz BIOSextchar3
	  mov dword[edi],'AGP '
	  add edi,4
      BIOSextchar3:
	  test al,8
	  jz BIOSextchar4
	  mov dword[edi],'I2O_'
	  mov dword[edi+4],'boot'
	  mov byte[edi+8],' '
	  add edi,9
      BIOSextchar4:
	  test al,$10
	  jz BIOSextchar5
	  mov dword[edi],'LS-1'
	  mov dword[edi+4],'20_b'
	  mov dword[edi+8],'oot '
	  add edi,12
      BIOSextchar5:
	  test al,$20
	  jz BIOSextchar6
	  mov dword[edi],'ATAP'
	  mov dword[edi+4],'I_ZI'
	  mov dword[edi+8],'P_bo'
	  mov word[edi+12],'ot'
	  mov byte[edi+14],' '
	  add edi,15
      BIOSextchar6:
	  test al,$40
	  jz BIOSextchar7
	  mov dword[edi],'1394'
	  mov dword[edi+4],'_boo'
	  mov word[edi+8],'t '
	  add edi,10
      BIOSextchar7:
	  test al,$10
	  jz BIOSextchar_2
	  mov dword[edi],'Smar'
	  mov dword[edi+4],'t_ba'
	  mov dword[edi+8],'tter'
	  mov word[edi+12],'y '
	  add edi,14
  BIOSextchar_2:
	  cmp cl,2
	  jb parseBIOSinfo1
	  mov al,[edx+$13]
	  test al,al
	  jz parseBIOSinfo1
	  test al,$1
	  jz BIOSextchar8
	  mov dword[edi],'Boot'
	  mov dword[edi+4],'_spe'
	  mov dword[edi+8],'cif '
	  add edi,12
      BIOSextchar8:
	  test al,$2
	  jz BIOSextchar9
	  mov dword[edi],'Key-'
	  mov dword[edi+4],'init'
	  mov dword[edi+8],'_net'
	  mov dword[edi+12],'work'
	  mov dword[edi+16],'_boo'
	  mov word[edi+20],'t '
	  add edi,22
      BIOSextchar9:
	  test al,$4
	  jz BIOSextchar10
	  mov dword[edi],'Targ'
	  mov dword[edi+4],'eted'
	  mov dword[edi+8],'_con'
	  mov dword[edi+12],'tent'
	  mov dword[edi+16],'_dis'
	  mov dword[edi+20],'trib'
	  mov dword[edi+24],'utio'
	  mov word[edi+28],'n '
	  add edi,30
      BIOSextchar10:
	  test al,$8
	  jz BIOSextchar11
	  mov dword[edi],'UEFI'
	  mov byte[edi+4],' '
	  add edi,5
      BIOSextchar11:
	  test al,$10
	  jz parseBIOSinfo1
	  mov dword[edi],'It''s'
	  mov dword[edi+4],'_VM '
  parseBIOSinfo1:
	mov esi,show_BIOS_info
	call show_
	jmp next_struc

parseSystemInfo:
	xor ecx,ecx
	mov cl,[SysInf.header.length]
	mov esi,edx
	add esi,ecx
	mov ebp,esi ;addr of the 1st string
	mov al,[SysInf.manufacturer]
	test al,al
	jz  sysinfo0
	call find_str
	mov edi,show_sys_manufact
	call copy_zstr
   sysinfo0:
	mov al,[SysInf.prod_name]
	test al,al
	jz  sysinfo1
	call find_str
	mov edi,show_prod_name
	call copy_zstr
   sysinfo1:
	mov al,[SysInf.version]
	test al,al
	jz  sysinfo2
	call find_str
	mov edi,show_sys_version
	call copy_zstr
   sysinfo2:
	mov al,[SysInf.serial]
	test al,al
	jz  sysinfo3
	call find_str
	mov edi,show_sys_serial
	call copy_zstr
   sysinfo3:
	mov eax,dword[SysInf.UUID]
	mov edi,show_sys_UUID
	call convD
	inc edi
	mov ebp,4
	mov cl,3
     @@:mov ax,word[SysInf.UUID+ebp]
	call convW
	inc edi
	add ebp,2
	dec cl
	jnz @b
	mov cl,6
	mov ebp,10
     @@:mov al,[SysInf.UUID+ebp]
	call convB
	inc ebp
	dec cl
	jnz @b
	mov al,[SysInf.wakeup]
	mov edi,show_sys_wakeup
	test al,$80
	jz sysinfo4
	mov dword[edi],'AC_P'
	mov dword[edi+4],'ower'
	mov dword[edi+8],'_res'
	mov dword[edi+12],'tore'
	mov word[edi+16],'d '
	add edi,18
    sysinfo4:
	test al,$40
	jz sysinfo5
	mov dword[edi],'PCI_'
	mov dword[edi+4],'PME#'
	mov byte[edi+8],' '
	add edi,9
    sysinfo5:
	test al,$20
	jz sysinfo6
	mov dword[edi],'Powe'
	mov dword[edi+4],'r_sw'
	mov dword[edi+8],'itch'
	mov byte[edi+12],' '
	add edi,13
    sysinfo6:
	test al,$10
	jz sysinfo7
	mov dword[edi],'LAN_'
	mov dword[edi+4],'remo'
	mov word[edi+8],'te'
	mov byte[edi+10],' '
	add edi,11
    sysinfo7:
	test al,$8
	jz sysinfo8
	mov dword[edi],'Mode'
	mov dword[edi+4],'m_ri'
	mov word[edi+8],'ng'
	mov byte[edi+10],' '
	add edi,11
    sysinfo8:
	test al,$4
	jz sysinfo9
	mov dword[edi],'APM_'
	mov dword[edi+4],'time'
	mov word[edi+8],'r '
	add edi,10
    sysinfo9:
	test al,$2
	jz sysinfo10
	mov dword[edi],'Unkn'
	mov dword[edi+4],'own '
	add edi,8
    sysinfo10:
	test al,1
	jz sysinfo11
	mov dword[edi],'Othe'
	mov word[edi+4],'r '
	add edi,6
    sysinfo11:
	mov cl,[SysInf.header.length]
	cmp cl,$1A
	jb sysinfo13
	mov al,[SysInf.SKU]
	test al,al
	jz  sysinfo12
	call find_str
	mov edi,show_sys_SKU
	call copy_zstr
    sysinfo12:
	mov al,[SysInf.family]
	test al,al
	jz sysinfo13
	call find_str
	mov edi,show_sys_family
	call copy_zstr
     sysinfo13:
	mov esi,show_system_info
	call show_
	jmp next_struc

parseProcessorInfo:
	mov al,[edx+1]
	mov edi,show_proc_len
	call convB
	mov al,[edx+4]
	mov edi,show_proc_socket
	call copy_X_str
	mov al,[edx+5]
	mov edi,show_proc_type
	mov esi,type_proc
	call copy_E_str
	mov al,[edx+6]
	mov esi,processors
	mov edi,show_proc_family
	call copy_E_str
	mov al,[edx+7]
	mov edi,show_proc_manufact
	call copy_X_str
	mov al,[edx+$10]
	mov edi,show_proc_version
	call copy_X_str
	mov ax,[edx+$12]
	mov edi,show_proc_extclock
	call convWdec_non0
	mov ax,[edx+$14]
	mov edi,show_proc_maxclock
	call convWdec_non0
	mov ax,[edx+$16]
	mov edi,show_proc_curclock
	call convWdec_non0
	mov al,[edx+$18]
	and al,$07
	mov edi,show_proc_status
	mov esi,proc_status
	call copy_E_str
	cmp byte[edx+1],$1A
	jbe parseProcessorInfo9
	mov al,[edx+$20]
	mov edi,show_proc_serial
	call copy_X_str
	mov al,[edx+$21]
	mov edi,show_proc_asset
	call copy_X_str
	cmp byte[edx+1],$23
	jbe parseProcessorInfo9
	mov al,[edx+$22]
	mov edi,show_proc_part
	call copy_X_str
	mov al,[edx+$23]
	mov edi,show_proc_cores
	call convBdec_non0
	mov al,[edx+$24]
	mov edi,show_proc_core_en
	call convBdec_non0
	mov al,[edx+$25]
	mov edi,show_proc_threads
	call convBdec_non0
  parseProcessorInfo9:
	mov esi,show_proc_info
	call show_
	jmp next_struc

parsePhysMemArray:
	mov al,[edx+1]
	mov edi,show_physmem_len
	call convB
	mov al,[edx+4]
	mov esi,mem_array_loc
	mov edi,show_physmem_loc
	call copy_E_str
	mov al,[edx+5]
	mov esi,mem_array_use
	mov edi,show_physmem_use
	call copy_E_str
	mov eax,[edx+7]
	mov edi,show_physmem_max
	call convDdec_non0
parsePhysMemArray_end:
	mov esi,show_physmem_info
	call show_
	jmp next_struc

parseMemoryDevice:
	mov al,[edx+1]
	mov edi,show_memdev_len
	call convB
	mov ax,[edx+12]
	mov edi,show_memdev_size
	mov ebp,' MB '
	test ax,$8000
	jz @f
	sub ax,$8000
	mov ebp,' kB '
     @@:call convWdec_non0
	mov [edi],ebp
	mov al,[edx+14]
	mov esi,mem_device_form
	mov edi,show_memdev_form
	call copy_E_str
	mov al,[edx+16]
	mov edi,show_memdev_dev
	call copy_X_str
	mov al,[edx+17]
	mov edi,show_memdev_bank
	call copy_X_str
	mov al,[edx+18]
	mov edi,show_memdev_type
	mov esi,mem_device_type
	call copy_E_str
	mov bp,[edx+19]
	mov al,15
	mov edi,show_memdev_detail
   parseMemDeviceDetail0:
	shl bp,1
	jnc parseMemDeviceDetail1
	mov esi,mem_device_detail
	call copy_E_str
    parseMemDeviceDetail1:
	dec al
	jnz parseMemDeviceDetail0
	mov esi,show_memdev_info
	nop
	call show_
	jmp next_struc

parseMemMapAddress:
	mov eax,[edx+4]
	mov edi,show_memmap_start
	call convD
	mov eax,[edx+8]
	mov edi,show_memmap_end
	call convD
	mov al,[edx+14]
	mov edi,show_memmap_width
	call convBdec_non0
	mov esi,show_memmap_info
	call show_
	jmp next_struc

parseOnboardInfo:
	mov al,[edx+1]
	mov esi,edx
	add esi,4
	mov edi,show_onboard_dev
	sub al,4
	shr al,1
	mov cl,al ; number of devices = (length-4)/2
  parseOnboardInfo0:
	xor ch,ch
	lodsb
	test al,$80
	jnz parseOnboardInfo1  ;device enabled
	mov word[edi],$0803; change color for gray
	add edi,2
	mov ch,1
  parseOnboardInfo1:
	push esi
	mov esi,onboard_device
	call copy_E_str
	mov byte[edi],'-'
	inc edi
	pop esi
	lodsb
	call copy_X_str
	test ch,ch
	jz   parseOnboardInfo2
	mov ax,$0703
	stosw
  parseOnboardInfo2:
	mov word[edi],$2013
	add edi,2
	dec cl
	jnz parseOnboardInfo0
	mov byte[edi-1],0
	mov esi,show_onboard_info
	call show_
	jmp next_struc

no_sm_: mov esi,show_no_sm
	call show_
	jmp $

show_all_tab_types:
	 mov esi,show_all_tab
	 call show_
	 jmp $

copy_E_str: ;copy string from enumirate list
	 mov ah,al
      @@:lodsb
	 cmp ah,al
	 jz copy_E_str_find
	 call skip_str
	 cmp byte[esi],0
	 jnz @b
	 mov esi,unknown
  copy_E_str_find:
	 call copy_zstr
	 retd

skip_str:lodsb
	 test al,al
	 jnz skip_str
	 retd

copy_X_str: ;copy string from addition field
	 test al,al
	 jz copy_X_str_end
	 call find_str
	 call copy_zstr
  copy_X_str_end:
	 retd

find_str:
	 movzx esi,byte[edx+1]
	 add esi,edx
	 mov ah,al
	 xor al,al
     find_next_str:
	 dec ah
	 test ah,ah
	 jz find_str_end
      @@:lodsb
	 test al,al
	 jnz @b
	 jmp find_next_str
  find_str_end:
	 retd

include 'show.asm';conversion and showing
include 'processors.asm'


	 db 15*512+$$-$ dup 0
