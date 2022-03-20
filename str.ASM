;sructures
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

struc SMBIOS_entry_point
  {  .signature  dd ?
     .checksum	 db ?
     .length	 db ?
     .major_ver  db ?
     .minor_ver  db ?
     .max_size	 dw ?
     .revision	 db ?
     .formatted  db 5 dup ?
     .intermed_str db 5 dup ?
     .intermed_chk db ?
     .tab_length dw ?
     .tab_addr	 dd ?
     .num_struc  dw ?
     .bcd_rev	 db ? }

virtual at EBX
  SMep SMBIOS_entry_point
end virtual

tBIOSinfo	=0
tSystemInfo	=1
tBaseboardInfo	=2
tSystemEnclosure=3
tProcessorInfo	=4
tCacheInfo	=7
tSystemSlots	=9
tOnboardInfo	=11 ;(0Bh)
tPhysMemArray	=16 ;(10h)
tMemoryDevice	=17 ;(11h)
tMemMapAddress	=19 ;(13h)
tSytemBootInfo	=32 ;(20h)

struc SMBIOS_struc_header
  {  .type	 db ?
     .length	 db ?
     .handle	 dw ? }

struc BIOSinfo
  { .header SMBIOS_struc_header
    .vendor    db ?
    .version   db ?
    .start_seg dw ?
    .date      db ?
    .ROMsize   db ?
    .characteristics dq ?
    .major_ver db ?
    .minor_ver db ?
    .ECfirm_major db ?
    .ECfirm_minor db ? }

virtual at EDX
  BIOS BIOSinfo
end virtual

struc SystemInfo
  { .header SMBIOS_struc_header
    .manufacturer db ?
    .prod_name	  db ?
    .version	  db ?
    .serial	  db ?
    .UUID	  db 16 dup ?
    .wakeup	  db ?
    .SKU	  db ?
    .family	  db ? }

virtual at EDX
  SysInf SystemInfo
end virtual

macro CP n
  {  mov word[$B8000+160*n-2],n+$30+(n shl 8) }

macro SHOW src,num
  {  push esi
     mov ecx,num
     mov edi,$B8000
     mov esi,src
   .next:
     lodsb
	push ax
	mov ah,al
	and ax,$0FF0
	cmp ah,$0A
	jb @f
	add ah,7
   @@: add ah,$30
	shr al,4
	cmp al,$0A
	jb @f
	add al,7
   @@: add al,$30
	mov bh,ah
	mov ah,7
	stosw
	mov al,bh
	stosw
	pop ax
	mov bl,$20
	cmp al,$20
	jb @f
	cmp al,$7F
	ja @f
	mov bl,al
   @@:
      mov eax,$00200F20
      mov al,bl
      stosd
      dec ecx
      jnz .next
      jmp $ }