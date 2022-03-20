;partition boot sector
use16
org $7C00
		jmp boot_loader

   partition_name db 'minOS',0,0,0,0,0,0,0
   cluster_size   db 1 ; size in sectors
   root_sector	  dd 60
   freeBlocksSect dd 0
   PartSize	  dd 0 ;size in sectors

   boot_loader: mov sp,$7FF0
	     ;clear screen
		mov ax,3
		int 10h
	     ; unlock A20
		in al,$92
		or al,2
		out $92,al
	     ;prepare loading
		mov eax,[si+12]
		mov [minOSpart],eax ; size in sectors
		mov eax,[si+8]
		mov [LogSector0],eax
		inc eax
		push eax
		mov [init_start],eax
	     ;load init module
		mov ah,$42
		mov si,init_Load
		int 13h
		mov [BootDriveNumber],dl
		mov si,LogDiskDAP
		mov word[DAP],sizeof.tDAP
		mov [DAP.buffer],$80000000
		mov [DAP.count],191
		pop eax
		add eax,59
		mov dword[DAP.startblock],eax
		mov ah,$42
		int 13h

   get_memory_ranges:
		mov edi,initialMEMORYranges
		mov dword[di+20],1
		xor ebx,ebx
	     @@:mov eax,$E820
		mov ecx,$20
		mov edx,$534D4150; 'SMAP'
		int 15h
		add di,$20
		inc byte[RangeCount]
		test ebx,ebx
		jnz @b
		mov ax,$E801
		int 15h
		mov [MaxRAM],bx
		mov [RAMbetween1M_16M],ax

		cli
	     ;init GDT
		mov ax,GDTseg16
		mov es,ax
		xor eax,eax
		mov ecx,GDTsize/4
		rep stosd
		mov si,initialGDT
		mov di,0+1*8
		mov cx,initialGDTsize/4 ;size in DW   ;3 descr
		rep movsd

		jnc INITmodule

		jmp $

align $10
initialGDT:
    DEFINE_CODE_SEG  $1000,$6BFF,0;KernelModuleBase+KernelModuleSize-1,0
    DEFINE_STACK_SEG 0,STACKbase,0
    DEFINE_DATA_SEG  0,$FFFFFFFF,0
 ;   db $FF,$FF,0,0,0,$92,$CF,0 ; 4 GB
initialGDT_end:

  init_Load  dw 24
  init_size  dw 59
  init_buff  dd $600
  init_start dd 0,0

LogSector0   dd 0
minOSpart    dd 0
;free Zone
	 db ($$+510-$) dup 0
	 dw $AA55
