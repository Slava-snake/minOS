;macroses
include 'macro\proc32.inc'

PAGE_AVL=111b
PAGE_NON_AVL=000b



macro EOI
  { mov eax,[APICEOI]
    mov dword[eax],0 }

macro DEFINE_CODE_SEG base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10011010b 		 ;type 26
    db ((limit and $000F0000) shr 16) or 01000000b
    db base shr 24  }

macro DEFINE_DATA_SEG base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10010010b 		  ; type 18
    db ((limit and $000F0000) shr 16) or 01000000b
    db (base and $FF000000) shr 24  }

macro DEFINE_LDT base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10000010b 		   ;type 2
    db ((limit and $000F0000) shr 16) or 00000000b
    db (base and $FF000000) shr 24  }

macro DEFINE_TRAP_GATE selector,addr,dpl
  { dw addr and 0FFFFh
    dw selector
    dw (dpl shl 13) or 1000111100000000b   ;type 15
    dw addr shr 16   }

macro DEFINE_INT_GATE selector,addr,dpl
  { dw addr and 0FFFFh
    dw selector
    dw (dpl shl 13) or 1000111000000000b    ;type 7
    dw addr shr 16   }

macro DEFINE_TASK_GATE selector,dpl
  { dw 0
    dw selector
    db 0
    db (dpl shl 5) or 10000101b       ;type 5
    dw 0 }

macro DEFINE_TSS base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base shr 16) and $FF
    db 10001001b or (dpl shl 5)      ;type 9
    db (limit shr 16) and $0F
    db base shr 24  }

macro VECTOR irq,vect,selector,addr,type,pl
  { db irq,vect,type,pl
    dw selector
    dd addr }

struc TSS32
  { .PreviousTaskLink dw ? ;+0
    .taskid    dw ?	   ;+2
    .ESP0      dd ?	   ;+4
    .SS0       dw ?	   ;+8
    .Reserved1 dw ?	   ;+0Ah
    .ESP1      dd ?	   ;+0Ch
    .SS1       dw ?	   ;+10h
    .Reserved2 dw ?	   ;+12h
    .ESP2      dd ?
    .SS2       dw ?
    .Reserved3 dw ?	   ;
    .tsCR3    dd ?	   ;+1Ch
    .tsEIP    dd ?	   ;+20h
    .tsEFLAGS dd ?
    .tsEAX    dd ?	  ;  44
    .tsECX    dd ?
    .tsEDX    dd ?	  ;52
    .tsEBX    dd ?
    .tsESP    dd ?	  ; 60
    .tsEBP    dd ?
    .tsESI    dd ?	  ;+40h
    .tsEDI    dd ?	  ;72
    .tsES      dw ?
    .Reserved4 dw ?	  ; 76
    .tsCS      dw ?
    .Reserved5 dw ?
    .tsSS      dw ?
    .Reserved6 dw ?
    .tsDS      dw ?
    .Reserved7 dw ?
    .tsFS      dw ?
    .Reserved8 dw ?
    .tsGS      dw ?
    .Reserved9 dw ?
    .LDT       dw ?
    .Reserved10 dw ?
    .DebugByte	db ?
    .Reserved11in db ?
    .IOMapBase dw ?
    sizeof.#TSS32=$-.PreviousTaskLink }

struc Tthr   ; 16 bytes
  { .tss       dw ?  ;selector GDT
    .idproc    dw ?
    .parent    dw ?  ;id parent task
    .Tfree     dd ?
    .prior     db ?
    .status    db ?
    .eventmask dw ?
    .reserve   db 2 dup ?
    sizeof.#Tthr=$-.tss }

struc Tprocess
  { .header	 dd ?
    .level     dd ?
    .PD        dd ?
    .LDTaddr   dd ?
    .LDTsel    dw ?
    .reserve   dw ?
    .TSSaddr   dd ?
    .TSSsize   dd ?
    sizeof.#Tprocess=$-.header }

struc TprocHeader
  { .name	db 512 dup ?
    .CS 	dw ?
    .DS 	dw ?
    .SS 	dw ?
    .ES 	dw ?
    .id 	dw ?
    .pagegrcount  dd ?
    .pagegroup	dd 300 dup (?,?)
    .thrcount	dw ?
    .threads	dw MAXTASKSPERPROCESS dup ?  }

struc Tsection
  { .start   dd ?
    .size    dd ?
    .image   dd ?
    sizeof.#Tsection=$-.start }

macro HEX32VIEW addr,x,y
  { push ecx
    push esi
    mov ecx,4
    mov esi,addr
    mov [posEDI],y*160+x*2+$b8000
    call dump4
    pop esi
    pop ecx }

macro HI x,y,c,s
  { push edx
    push eax
    mov dh,x
    mov dl,y
    mov al,s
    mov ah,c
    call showchar
    pop eax
    pop edx }

