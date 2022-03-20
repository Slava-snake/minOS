include 'Macroses.asm'
include 'structures.asm'
;
include 'MBRboot.asm'
;____________________________________________________________________________
include 'constants.asm'
;________________________________________________________
;partition boot-sector
include 'bootsect.asm'
;____________________________________________________________________________
org $600

GDTR	 dw GDTsize-1
	 dd GDTbase
IDTR	 dw IDTsize-1
	 dd IDTbase

GDT_1st_free	dd GDT_1st_free_init

MMUfreeRanges	tRECLIST  ;610h
ProcessList	tRECLIST  ;628h
TaskList	tRECLIST  ;640h
HandleList	tRECLIST  ;658h
FreeRAM 	dd 0	  ;670h
ProcessListAddr dd 0
TaskListAddr	dd 0
ERRORresults	dd 0
TAB_PORT_BM	dd 0
ACPIbase	dd 0
ACPIsize	dd 0
MaxRAM		dw 0
RAMbetween1M_16M dw 0
SystemHeader	dd 0
PDaddr		dd 0

ProcessCount	dw 0
TaskCount	dw 0
TaskManagerSel	dw 0

RangeCount	db 0
BootDriveNumber db 0
FSBenable	db 0

APICbase	dd 0
IOAPICbase	dd 0

LogDiskDAP	tDAP

;Process Header Type - sizes: CommandLine,WorkDir,VarEnv,Usage(12),Unused(12),VirtUsage(12),LDT(8),Handles(4),MsgBox(32)

PrHeaderTypes	tPrHeaderType  1,256,256,256,1536,252,1092, 128,128;,15
PrHeaderTypeEnd:

RUNsystem    db 0
process0name db 'system',0
process1name db 'DriverMgr',0
drvmgr	     db '\system\drvmgr.exe',0
drvdir	     db '\system\drv',0
env_var      db '%sysdir=*',0
;free Zone
	 db ($$+512-$) dup 0
;_______________________________________________________________________
org $800
use16

INITmodule:


	     lidt fword[IDTR]
	     lgdt fword[GDTR]
	     mov eax,cr0
	     and eax,$9FFFFFFF ;clear CD,NW	{CacheDisable,NotWrite}
	     or al,$01	;set PE 		{Protected_mode_Enable}
	     mov cr0,eax
	     jmp 8:$0000000

LogDiskReaderDAP: ;DL-drive number
		  ;ES:SI-DAP(disk address packet)
	      ; return: C=0, AH=0 -success
	      ; 	C=1, AH=error code
		mov ah,$42
		int 13h
		ret

LogDiskReaderReg: ;DL-drive number
		  ;EBX-absolute address
		  ;CX-count sectors
		  ;EAX-start logical sector
	      ; return: C=0, AH=0 -success
	      ; 	C=1, AH=error code
		push si
		mov si,LogDiskDAP
		mov [DAP.count],cx
		mov dword[DAP.flat64addr],ebx
		add eax,[LogSector0]
		call LogDiskReaderDAP
		pop si
		ret

use32



;free Zone
	 db ($$+$800-$) dup 0

;__________________________________________________________________________
;kernel module -PROTECTED MODE-
org $000
use32
	     mov ax,$10
	     mov ss,ax
	     mov ax,$18
	     mov ds,ax
	     mov es,ax
;
       mov dword[$FEC00000],$11
       mov dword[$FEC00010],$0
       mov dword[$FEC00000],$10
       mov dword[$FEC00010],$20
;
       mov dword[$FEC00000],$13
       mov dword[$FEC00010],$0
       mov dword[$FEC00000],$12
       mov dword[$FEC00010],$21
;
       mov dword[$FEC00000],$15
       mov dword[$FEC00010],$0
       mov dword[$FEC00000],$14
       mov dword[$FEC00010],$22

	     mov esp,STACKpointer
	     mov dword[0],0
	     call MMUinit   ;memory manager
	     call PMUinit   ;process manager
	     call IRQinit   ;interrupt manager
	 ;    call PortMUinit
	     call PageMUinit;page manager
	     call TMUinit   ;task(thread) manager

	     stdcall PageMUalignPhys2Lin,[SystemHeader],$FEE00000,$7F0000,1,3

align $100
	     stdcall MMUcreateIntTrapGateDescr,$8,1,8,v8,0

	     stdcall MMUcreateIntTrapGateDescr,$20,0,8,S0,0
	     stdcall MMUcreateIntTrapGateDescr,$21,0,8,S1,0
	     stdcall MMUcreateIntTrapGateDescr,$22,0,8,TaskManager_time,0
	     sti
	  ;   int $20
	     mov eax,[$7f0210]
	     nop
	     jmp $

v8:	     mov eax,8
	     iret

S0:	     mov eax,$20
	     iret
S1:	     mov eax,$21
	     mov eax,[$7f0110]
	     in al,$60
	     mov bl,al
	     in al,$61
	     mov ah,al
	     or al,$80
	     out $61,al
	     xchg ah,al
	     out $61,al
	     mov al,$20
	     out $20,al
	     mov dword[$7f00B0],0
	     mov eax,[$7f0110]
	     iret
S2:	     mov eax,$22
	     mov eax,[$7f0110]
	     mov dword[$7f00B0],0
	     mov eax,[$7f0110]
	     iret

	     jmp $

align $100
include 'Routines.asm'
include 'MemMU.asm'
include 'PageMU.asm'
include 'ProcMU.asm'
include 'TaskMU.asm'
include 'EventMU.asm'
include 'PortMU.asm'
include 'InterruptMU.asm'

;free Zone
	 db ($$+KernelModuleSize-$) dup $FF
kernel_init_end:

include 'ramdisk.asm'
