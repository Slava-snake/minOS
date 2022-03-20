;show SystemManagement
use16
org $7C00
CURR_SEG=$0000 ;current segment
NEW_SEG=$60
sektors=18
;set new segments
	mov sp,$7FFC
	mov ax,CURR_SEG
	mov ds,ax
	mov ss,ax
	mov ax,3   ; cls
	int 10h
	mov ax,NEW_SEG
	mov es,ax
;load 2KB (4 sectors) at  ES:BX=0060:0000
	xor bx,bx
	mov cx,2 ;
	mov ax,$0200+sektors
	mov dh,0
	int 13h
	cli
	lgdt fword[GDTR]
	mov eax,cr0
	or al,1
	mov cr0,eax
	jmp 8:$1000

;data
align 4
GDTR	 dw GDT_end-GDT-1
	 dd NEW_SEG*16

;free zone
	 db ($$+446-$) dup 0
;partition table
	 db 80h,01h,01h,0,4,1,0E0h,0e6h,0fh,0,0,0,0a0h,0f9h,50 dup 0,55h,0AAh
include 'str.asm'
include '5_1.asm'
