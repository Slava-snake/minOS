use16
org $7C00

include 'macroses.asm'
    mov eax,$80000000
    neg eax
    mov ebp,$8000001d
    mov ecx,0
 @@:mov eax,ebp
    cpuid
    inc ecx
    cmp ecx,5
    jb @b
    lgdt fword[GDT]
    mov eax,cr0
    inc al
    mov cr0,eax
    jmp 8:0

align $10
PM:
org 0
use32
    mov ax,$10
    mov ss,ax
    mov ax,$18
    mov ds,ax
    mov es,ax
    mov esp,$FFF0
       mov dword[$FEC00000],$11
       mov dword[$FEC00010],$20
       mov dword[$FEC00000],$13
       mov dword[$FEC00010],$21
       mov dword[$FEC00000],$15
       mov dword[$FEC00010],$22
    sti
align $20

@@:
;	      mov eax,[$FEE00200]
;	      mov eax,[$FEE00210]
;	      mov eax,[$FEE00220]
;	      mov eax,[$FEE00230]
;	      mov eax,[$FEE00240]
;	      mov eax,[$FEE00250]
;	      mov eax,[$FEE00260]
;	      mov eax,[$FEE00270]
;	      mov eax,[$FEE00100]
;	      mov eax,[$FEE00110]
;	      mov eax,[$FEE00120]
;	      mov eax,[$FEE00130]
;	      mov eax,[$FEE00140]
;	      mov eax,[$FEE00150]
;	      mov eax,[$FEE00160]
;	      mov eax,[$FEE00170]

	     jmp @b

;free Zone
	 db ($$+256-$-PM+$7C00) dup 0

org $7D00

GDT dw initialGDT_end-initialGDT-1
    dd initialGDT

initialGDT:
    db 8 dup 0
    DEFINE_CODE_SEG  PM,255,0
    DEFINE_STACK_SEG 0,$F000,0
    DEFINE_DATA_SEG  0,$FFFFFFFF,0
 ;   db $FF,$FF,0,0,0,$92,$CF,0 ; 4 GB
initialGDT_end:


;free Zone
	 db ($$+510-$-256) dup 0
	 dw $AA55
