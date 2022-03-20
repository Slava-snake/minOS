;Memory Management Unit

MMUinit:
	     ;set used memory for kernel and others
		stdcall RangesRoutine_CREATElist,MMUfreeRanges,TAB_FreeBlock,TAB_FreeBlockSize
		movzx eax,word[MaxRAM] ;size in 64KB-blocks >16MB
		test eax,eax
		jz @f
		shl eax,16 ;64K->bytes
		add eax,$1000000 ;add 16MB
		jmp MMUinitRanges
	   @@:	movzx eax,word[RAMbetween1M_16M]
		shl eax,10 ; 1K->bytes
		add eax,$100000; add 1MB
       MMUinitRanges:
		mov dword[MaxRAM],eax
		mov esi,initialMEMORYranges
		mov cl,[RangeCount]
       MMUinitGetRange:
		cmp byte[esi+16],1
		jne @f
		mov ebx,[esi]
		mov edx,[esi+8]
	       ; cmp dword[esi+4],0
	       ; je MMUinitBelow4GB

       MMUinitBelow4GB:
		call MMUfreeMem;
	       ; call MMUaddLastRec  ;ESI-FreeRange
	       ;mov esi,eax
	       ; mov eax,[ebx]
	       ; mov [FreeRange.base],eax
	       ; mov eax,[ebx+8]
	       ; mov [FreeRange.size],eax
	     @@:add esi,$20
		dec cl
		jnz MMUinitGetRange
	     ;set used areas
		mov ebx,0
		mov edx,$600
		call MMUgetMem_FIX ;BIOS area is reserved
		mov ebx,$600
		mov edx,$200
		call MMUgetMem_FIX ;kernel data
		mov ebx,$800
		mov edx,$800
		call MMUgetMem_FIX ;init module
		mov ebx,KernelModuleBase
		mov edx,KernelModuleSize
		call MMUgetMem_FIX ;kernel module
		mov ebx,TAB_FreeBlock
		mov edx,TAB_FreeBlockSize
		call MMUgetMem_FIX ;table of free memory blocks
		mov ebx,STACKbase
		mov edx,STACKsize
		call MMUgetMem_FIX; stack segment
		mov ebx,GDTbase
		mov edx,GDTsize
		call MMUgetMem_FIX ;GDT
		mov ebx,IDTbase
		mov edx,IDTsize
		call MMUget0Mem_FIX;IDT
		mov ebx,SMMbase
		mov edx,SMMsize
		call MMUget0Mem_FIX;SMM
		ret

MMUcopyMem_:   ;ESI-source, EDI-dest, ECX-count


MMUfillMemory: ;EDI-base, ECX-size in bytes, EAX/AX/AL- fill
	       ;BL- 00(dwords),10(words), others(bytes)
		push edi
		push ecx
		test bl,bl
		jnz @f
		shr ecx,2
		rep stosd
		jmp MMUfillMemory_exit
	     @@:cmp bl,2
		jne @f
		shr ecx,1
		rep stosw
		jmp MMUfillMemory_exit
	     @@:rep stosb
   MMUfillMemory_exit:
		pop ecx
		pop edi
		ret

MMUget0Mem1:	; EDX-size;
	   ;return: EAX-addr, C=0; C=1-error, EAX-error code
		call MMUgetMem1
 MMUset0mem:	push edi
		push ecx
		mov edi,eax
		mov ecx,edx
		call MMUzeroMemory
		pop ecx
		pop edi
		ret

MMUget0Mem_FIX: ;EBX-base, EDX-size
	   ;return: EAX-addr, C=0; C=1-error, EAX-error code
		call MMUgetMem_FIX
		jmp MMUset0mem

MMUzeroMemory: ;EDI-base, ECX-size in bytes
		push bx
		push eax
		xor eax,eax
		mov bl,cl
		and bl,$3
		call MMUfillMemory
		pop eax
		pop bx
		ret

MMUsetPage0:   ;EAX-addr
		push ecx
		push edi
		push eax
		and eax,$FFFFF000
		mov edi,eax
		mov ecx,$400
		xor eax,eax
		rep stosd
		pop eax
		pop edi
		pop ecx
		ret

MMUgetFreeRAM: ;return EAX-bytes
		push esi
		xor eax,eax
		mov esi,[MMUfreeRanges]
	    @@: test esi,esi
		jz @f
		add eax,[Range.size]
		mov esi,[Range.next]
		jmp @b
	    @@: pop esi
		ret

MMUgetMemGEthan: ;EBX-minimum addr, ECX-leveling, EDX-size
	   ;return: EAX-addr, C=0; C=1-error, EAX-error code
		push esi
		push ebx
		mov esi,MMUfreeRanges
		call Routine_leveling_mask
		jc MMUgetMemGEthan_error
		call Routine_leveled_addr ; EBX-leveled
     MMUgetMemGEthan_check_next:
		mov esi,[esi]
		test esi,esi
		jz MMUgetMemGEthan_error1
	    @@: mov eax,[Range.base]
		add eax,[Range.size]
		cmp ebx,eax
		jae MMUgetMemGEthan_check_next
		sub eax,ebx
		cmp eax,edx
		jb MMUgetMemGEthan_check_next;next
	      ;bingo
		call MMUgetMem_FIX
     MMUgetMemGEthan_error:
		pop ebx
		pop esi
		ret
     MMUgetMemGEthan_error1:
		stc
		jb MMUgetMemGEthan_error

MMUget0pages: ;ECX-count
	      ;return: EAX-addr
		push ecx
		push edx
		mov edx,ecx
		neg ecx
		cmp ecx,$FFF00001
		jb MMUget0pages_error
		shl edx,12  ; size in bytes
		mov ecx,$1000
		call MMUget0Mem1
     MMUget0pages_error:
		pop edx
		pop ecx
		ret


MMUget0page4K: ;return:EAX-addr
		push ecx
		push edx
		mov ecx,$1000
		mov edx,ecx
		call MMUget0Mem1
		pop edx
		pop ecx
		ret

MMUget4K:   ;return: EAX-addr
		push ecx
		push edx
		mov ecx,$1000
		mov edx,ecx
		call MMUgetMem1
		pop edx
		pop ecx
		ret

MMUgetPages4K:; EDX-count pages
	     ;return EAX-addr
		push ecx
		push edx
		neg edx
		cmp edx,$FFF00001
		jb MMUgetPages4K_error
		mov ecx,$1000
		mov edx,[esp]
		shl edx,12
		call MMUgetMem1
      MMUgetPages4K_error:
		pop edx
		pop ecx
		ret

MMUgetMem1: ; EDX-size, ECX-leveling
	   ;return: EAX-addr, C=0; C=1-error, EAX-error code
		push edi
		mov edi,MMUfreeRanges ; description of list
		call RangesRoutine_DEC_first
		jc @f
		sub [FreeRAM],edx
	     @@:pop edi
		ret

MMUgetMem_FIX: ; EDX-size, EBX-base
	   ;return: EAX-addr, C=0; C=1-error, EAX-error code
		push edi
		mov edi,MMUfreeRanges ; description of list
		call RangesRoutine_DEC_fix
		jc @f
		sub [FreeRAM],edx
	     @@:pop edi
		ret

MMUfreeMem:  ;EBX-base, EDX-size
	    ;return: C=0-success, C=1-error
		push edi
		mov edi,MMUfreeRanges ; description of list
		call RangesRoutine_INC
		jc @f
		add [FreeRAM],edx
	     @@:pop edi
		ret
;-------------------------------------------------------------------------------------------------------

proc MMUcreateTaskGateDescr stdcall uses edi  ,table,num,sel,level
		mov edi,[num]
		shl edi,3
		push edi
		add edi,[table]
		mov eax,[sel]
		shl eax,16
		stosd
		mov eax,[level]
		shl eax,13
		or ah,$80+DESCR_TASK_GATE
		stosd
		pop eax
		or eax,[level]
		mov edi,[table]
		call MMUcreateDescr_check_GDT
		ret
endp

MMUcreateDescr_check_GDT: ;EDI-addr of table, AX-descr
	    ;return: set TI bit for LDT
		cmp edi,GDTbase
		je @f
		or al,4
	     @@:ret

proc MMUcreateIntTrapGateDescr stdcall uses eax edi,num,type,sel,ofs,level ;type 1 -trap, type 0 -interrupt
		mov edi,[num]
		shl edi,3 ; *8
		add edi,IDTbase
		mov ax,word[sel]
		shl eax,16
		mov ax,word[ofs]
		stosd
		mov eax,[ofs]
		mov ax,word[level]
		shl ax,13
		or ah,$80+DESCR_INTERRUPT_GATE
		or ah,byte[type]
	     @@:stosd
		ret
endp

proc MMUcreateCallGateDescr stdcall uses   ,table,num,type,sel,ofs,level,params

endp

proc MMUcreateLDTdescr stdcall uses edi ,PRnum,base,size,level ;in GDT ;one process has own LDT
		mov edi,[PRnum]
		shl edi,3
		push edi
		add edi,LDTselector0
		mov eax,[size]
		call MMUcreateDescr_count_limit
		add eax,[base]
		stdcall MMUcreateDescr_writeBL,[base],eax,DESCR_LDT,[level]
		pop eax
		add eax,Process0LDT*8
		or al,byte[level]
		ret
endp

MMUcreateDescr_count_limit: ;EAX-size -> limit
		cmp eax,$100000
		jb @f
		shr eax,12
		bts eax,23
	     @@:dec eax
		ret

proc MMUcreateTSSdescr stdcall uses edi  ,num,base,size ;in GDT
		mov edi,[num]
		shl edi,3
		push edi
		add edi,TSSselector0
		mov eax,[size]
		call MMUcreateDescr_count_limit
		stdcall MMUcreateDescr_writeBL,[base],eax,DESCR_TSS,0
		pop eax
		ret
endp

proc MMUcreateDescr_writeBL stdcall base,limit,type,level ;EDI-addr in proper table
	;return: EAX-descriptor
		mov eax,[base]
		shl eax,16
		mov ax,word[limit]
		stosd
		mov ah,byte[base+3]
		mov al,byte[limit+2]
		shl eax,16
		mov al,byte[base+2]
		mov ah,byte[level]
		shl ah,5
		or ah,byte[type]
		or ah,$80
		stosd
		ret
endp

proc MMUcreateStackDescr stdcall uses edi esi edx,tableDesc,addr,base,size,level  ;max size 64 KB
		mov eax,[addr]
		mov esi,[tableDesc]
		movzx edi,word[TABdescr.recSize]
		xor edx,edx
		sub eax,[TABdescr.start]
		div edi
		push eax  ;number
		mov edi,[addr]
		mov eax,$10000
		push eax
		cmp [size],eax
		jbe @f;above 64K
		pop eax
		stc
		ret
	     @@:mov eax,[base]
		add eax,[size]
		sub eax,[esp]
		mov [base],eax
		pop eax
		sub eax,[size]
		dec eax
		mov [size],eax
		stdcall MMUcreateDescr_writeBL,[base],[size],DESCR_STACK_SEG,[level]
		pop eax
		or al,byte[level]
		mov edi,esi
		call MMUcreateDescr_check_GDT
     .finish:	ret
endp

proc MMUcreateCDdescr32 stdcall uses  ,table,num,type,base,size,level

		mov edi,[num]
		shl edi,3
		push edi
		add edi,[table]

		mov eax,[size]
		call MMUcreateDescr_count_limit
		bts eax,22 ;set D bit ->32bit
		stdcall MMUcreateDescr_writeBL,[base],eax,type,[level]
		pop eax
		or al,byte[level]
		mov edi,[table]
		call MMUcreateDescr_check_GDT
		ret
endp


MMU_create_LDT:  ;AL-level, EBX-dedicated mem, EDX-size
	       ;AX-selector(C=0), C=1-error
		mov ah,DESCR_LDT

MMU_create_descr: ;AH-type, AL-privilage level,
		  ;CH-1(32-bits segment),0(16-bits), CL-params count
		  ;E(BX)-base(selector), EDX-size(offset),
		  ;for LDT : EBP-addr of table, ESI-addr of 1st free
		  ;for IDT : EBP-#int
		;-> E(AX)-descriptor
		push ebx
		push edi
		push esi
		push ebp
		push eax
		btr dword[ERRORresults],0
		cmp ah,$10;
		jae  MMU_create_descr_code_data ;code/data
		cmp ah, DESCR_TASK_GATE ;5
		jne MMU_create_descr_check_type1 ;
	      ;TASK Gate
		call MMU_create_descr_GET_free_GDT_rec
		bt dword[ERRORresults],0
		jc MMU_create_descr_error
		shl ebx,16
		mov [edi],ebx
		shl al,5
		or al,$80
		or ah,al
		and eax,$0000FF00
		mov [edi+4],eax
		jmp MMU_create_descr_index
     MMU_create_descr_check_type1:
		bt ax,10 ; LDT & TSS
		jc MMU_create_descr_check_type2 ;
		xor ch,ch ; 0-bit (0-16bit, 1-32-bit)
			  ; 1-bit (0-GDT, 1-LDT)
     MMU_create_descr_code_data:
		bt cx,9
		jc MMU_create_descr_ready1
		call MMU_create_descr_GET_free_GDT_rec
		jmp MMU_create_descr_check1
     MMU_create_descr_ready1:
		call MMU_create_descr_GET_free_LDT_rec
     MMU_create_descr_check1:
		bt dword[ERRORresults],0
		jc MMU_create_descr_error  ;no error
	     ;Code/Data/TSS/LDT
		cmp edx,0
		je MMU_create_descr_bad_size
		cmp edx,$100000
		jb @f
	       ;size in 4K-pages
		test edx,$FFF
		jnz MMU_create_descr_bad_size
		shr edx,12
		bts edx,23
	    @@: dec edx
		call MMU_create_descr_setBO
		shr edx,16
		bt cx,8
		jnc @f
		bts edx,6  ; D/B
	    @@: shr ebx,16
		mov ah,bh
		mov al,dl
		shl eax,16
		call MMU_create_descr_setAH
		mov al,bl
		stosd
    MMU_create_descr_index: ;EBP-index -> EAX-descriptor index
		pop eax
		and eax,$0003
		or eax,ebp
		clc
       MMU_create_descr_exit:
		pop ebp
		pop esi
		pop edi
		pop ebx
		ret
     MMU_create_descr_bad_size:
	      ;00000004 - bad paraters
		bts dword[ERRORresults],0
		mov eax,4
     MMU_create_descr_error:
		sub esp,4
		stc
		jmp MMU_create_descr_exit
     MMU_create_descr_setAH:
		mov ax,[esp+4]
		shl al,5
		bts ax,15 ;present bit
		or ah,al
		ret
     MMU_create_descr_setBO:
		mov ax,bx
		shl eax,16
		mov ax,dx
		stosd
		ret

     MMU_create_descr_check_type2:
		bt ax,9 ; call gate
		jnc MMU_create_descr_check_type3
	    ;Call, Interrupt, Trap Gate
		xor cl,cl
		call MMU_create_descr_GET_free_IDT_rec
		jmp MMU_create_descr_type3

     MMU_create_descr_check_type3: ;call gate
		bt cx,9
		jc MMU_create_descr_type3_LDT
		call MMU_create_descr_GET_free_GDT_rec
		jmp MMU_create_descr_type3
	MMU_create_descr_type3_LDT:
		call MMU_create_descr_GET_free_LDT_rec
	MMU_create_descr_type3:
		bt dword[ERRORresults],0
		jc MMU_create_descr_error  ;no error
		call MMU_create_descr_setBO
		mov eax,edx
		call MMU_create_descr_setAH
		mov al,cl
		stosd
		jmp MMU_create_descr_index

    MMU_create_descr_GET_free_IDT_rec: ;EBP-#int
		cmp ebp,$100
		jae @f
		shl ebp,3
		mov edi,IDTbase
		add edi,ebp
		ret
	      ;00000002-error (wrong #int )
	    @@: mov eax,2
		bts dword[ERRORresults],0
		ret

    MMU_create_descr_GET_free_LDT_rec: ;ESI-addr of 1st free, EBP- addr of LDT
		push ebp
		add ebp,LDTsize
		call MMU_find_free_rec
		jnc @f	; no error
	      ;00000001-error (No free record in LDT)
		mov eax,1
	    @@: sub ebp,[esp]
		add esp,4
		bts bp,3
		ret

    MMU_create_descr_GET_free_GDT_rec: ;-> EDI-addr
		mov ebp,GDTrange
		mov esi,GDT_1st_free
		call MMU_find_free_rec
		jnc @f	; no error
	      ;00000000-error (No free record in GDT)
		xor eax,eax
	    @@: sub ebp,GDTbase
		ret

    MMU_find_free_rec: ; EBP-table range, ESI- 1st free rec
		cmp dword[esi],0
		jnz @f ; free_rec
		cmp dword[esi+4],0
		jnz @f
		xor edi,edi
		bts [ERRORresults],0
		stc
		ret
	   @@:	push esi
		mov esi,[esi]
		mov edi,esi
	       ;find new free record
	   @@:	add esi,8
		cmp esi,ebp
		jae MMU_set_new_free_rec_set_no_free
		cmp dword[esi],0
		jne @b
		cmp dword[esi+4],0
		jne @b
		mov ebp,esi
		jmp @f
	 MMU_set_new_free_rec_set_no_free:
		xor ebp,ebp
	    @@: pop esi
		mov dword[esi],ebp
		mov ebp,edi
		btr [ERRORresults],0
		clc
		ret

;------------------------------------------------------------------------------------------------------------------------------
       