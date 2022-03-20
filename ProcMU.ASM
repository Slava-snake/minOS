;Processes management unit

PMUinit:  ;create Process0
	     stdcall ListsRoutine_CREATE_FREE,ProcessList,ProcessesMaxCount,sizeof.tPROCESS,FIFO
	     mov [ProcessListAddr],eax
	 ;create PrHandle for Process0-system
	    mov edi,ProcessList
	    call ListsRoutine_ADDlastRec
	    inc word[ProcessCount]
	    push eax
	    call PMUaddr2id
	    stdcall PMUcreateHeaderSpec,eax,0,process0name,0,1, 0,0,0,768,768,64,8*8,64 ; return: EDI-PrHeader
	;    mov eax,PrHeader.LDTselector-PrHeader.id
	;    add eax,edi
	    lldt word[PrHeader.LDTselector];[eax]
	    pop eax
	    mov [PROCESS.addr],edi
	    mov [SystemHeader],edi
		mov ebx,0
		mov edx,$600
		call PMUaddUsage ;BIOS area is reserved
		mov ebx,$600
		mov edx,$200
		call PMUaddUsage ;kernel data
		mov ebx,$800
		mov edx,$800
		call PMUaddUsage ;init module
		mov ebx,KernelModuleBase
		mov edx,KernelModuleSize
		call PMUaddUsage ;kernel module
		mov ebx,TAB_FreeBlock
		mov edx,TAB_FreeBlockSize
		call PMUaddUsage ;table of free memory blocks
		mov ebx,[ProcessListAddr]
		mov edx,ProcessesMaxCount*sizeof.tPROCESS
		call PMUaddUsage
		mov ebx,STACKbase
		mov edx,STACKsize
		call PMUaddUsage; stack segment
		mov ebx,GDTbase
		mov edx,GDTsize
		call PMUaddUsage ;GDT
		mov ebx,IDTbase
		mov edx,IDTsize
		call PMUaddUsage;IDT
		mov ebx,SMMbase
		mov edx,SMMsize
		call PMUaddUsage;SMM

;	     mov eax,HandleMaxCount
;	     mov edx,sizeof.tHANDLE
;	     mov ecx,$1000
;	     xor ebx,ebx
;	     mov edi,HandleList
;	     call ListsRoutine_CREATE_FREE

	 ;   xor eax,eax
	 ;   mov esi,process0name
	;    call PMUcreate
	;    mov eax,[PDaddr]
	;    mov [PrHeader.PDaddr],eax
;	     mov [PrHeader.pChildList],0
;	     mov [PrHeader.pOwnTaskList],0
	;    mov eax,HandleList+8;(tRECLIST.Fhead-tRECLIST.Uhead)
;	     mov [PrHeader.pHandle],eax


	    ret


proc PMUcreateHeaderSpec uses esi ecx ebx edx, id,parent,name,level,prior, p1,p2,p3,p4,p5,p6,p7,p8; EAX-addr in ProcessList
   ;return: EDI-PrHeader
	    mov eax,sizeof.tProcessHeader
	    mov esi,[p1]
	    call StringRoutine_get_length_sz
	    add eax,ecx
	    mov esi,[p2]
	    call StringRoutine_get_length_sz
	    add eax,ecx
	    mov esi,[p3]
	    call StringRoutine_get_length_sz
	    add eax,ecx
	    add eax,[p4]
	    add eax,[p5]
	    add eax,[p6]
	    add eax,[p7]
	    add eax,[p8]
	    mov edx,eax
	    call Routine_Round_EAXto4K
	    push eax
	    shr eax,12
	    mov ecx,eax
	    call MMUget0pages
	    mov edi,eax
	    mov ax,word[id]
	    mov [PrHeader.id],ax
	    mov ah,byte[level]
	    mov al,byte[prior]
	    mov word[PrHeader.baseprior],ax
	    mov eax,edi
	    mov esi,[name]
	    add edi,PrHeader.name-PrHeader.id
	    call copy_sz
	    mov edi,eax
	    mov ebx,sizeof.tProcessHeader
	    add ebx,eax
	    mov esi,[p1]
	    test esi,esi
	    jnz @f
	    mov [PrHeader.CommandLine],0
	    jmp .workdir
	@@: mov edi,ebx
	    mov [PrHeader.CommandLine],ebx
	    call copy_sz_get_len
	    add ebx,ecx
   .workdir:mov esi,[p2]
	    test esi,esi
	    jnz @f
	    mov [PrHeader.WorkDir],0
	    jmp .varenv
	@@: mov edi,ebx
	    mov [PrHeader.WorkDir],ebx
	    call copy_sz_get_len
	    add ebx,ecx
   .varenv: mov esi,[p3]
	    test esi,esi
	    jnz @f
	    mov [PrHeader.VarEnv],0
	    jmp .usage
	@@: mov edi,ebx
	    mov [PrHeader.VarEnv],ebx
	    call copy_sz_get_len
	    add ebx,ecx
     .usage:call Routine_Round_EBXto4
	    mov edi,eax
	    add eax,PrHeader.usage-PrHeader.id
	    stdcall RangesRoutine_CREATElist,eax,ebx,[p4]
	    add ebx,[p4]
	  ;unused
	    call Routine_Round_EBXto4
	    mov eax,PrHeader.unused-PrHeader.id
	    add eax,edi
	    stdcall RangesRoutine_CREATElist,eax,ebx,[p5]
	    add ebx,[p5]
	  ;virt usage
	    call Routine_Round_EBXto4
	    mov eax,PrHeader.VirtUsage-PrHeader.id
	    add eax,edi
	    stdcall RangesRoutine_CREATElist,eax,ebx,[p6]
	    add ebx,[p6]
	  ;LDT
	    call Routine_Round_EBXto8
	    stdcall PMUcreateLDT,ebx,[p7]
	    add ebx,[p7]
	  ;handles
	    mov eax,PrHeader.Handles-PrHeader.id
	    add eax,edi
	    stdcall TablesRoutine_create,eax,ebx,[p8],4;---------size of handle
	    ;add ebx,[p8]
	 ;configuring header
	    pop eax
	    push edx
	    mov ebx,edi
	    mov edx,eax
	    call PMUaddUsage
	    pop edx
	    sub eax,edx
	    jz @f
	    add ebx,edx
	    mov edx,eax
	    call PMUaddUnUsed
	@@: ret
endp

proc PMUcreateLDT stdcall base,size ; EDI-process header
	    mov eax,PrHeader.LDT-PrHeader.id
	    add eax,edi
	    stdcall TablesRoutine_create,eax,[base],[size],8; size of descriptor
	    movzx eax,byte[PrHeader.level]
	    push eax
	    push [size]
	    push [base]
	    movzx eax,word[PrHeader.id]
	    push eax
	    call MMUcreateLDTdescr
	    mov [PrHeader.LDTselector],ax
	    ret
endp

PMUprocessName: ;EDI-header, ESI-sz_string;
	    push edi
	    add edi,PrHeader.name-PrHeader.id
	    call copy_sz
	    pop edi
	    ret

PMUaddr2id: ;EAX-addr in ProcessList
	  ;return: EAX-id
	    sub eax,[ProcessListAddr]
	    push edx
	    xor edx,edx
	    push word(sizeof.tPROCESS)
	    div word[esp]
	    pop dx
	    pop edx
	    ret


PMUadr2id:  ;ESI-addr in ProcessList
	  ;return: ESI-id Process
	    sub esi,[ProcessListAddr]
	    shr esi,3
	    ret

PMUid2adr:  ;EAX-id process
	  ;return: EAX-addr in ProcessList(C=0)
	    push eax
	    shl eax,2
	    add eax,[ProcessListAddr]
	    mov esi,eax
	    pop eax
	    ret

PMUgetHeader: ;EAX-id process
	  ;return: (C=0)EDI-addr of ProcessHeader
	    push esi
	    mov edi,ProcessList
	    call PMUid2adr
	    mov edi,[PROCESS.addr]
	    pop esi
	    ret


PMUgetMem4stack: ;EDX-size
      ;return: C=0, EAX,EBX-addr
		push esi
		mov esi,MMUfreeRanges
     PMUgetMem4stack_check_next:
		mov esi,[esi]
		test esi,esi
		jz PMUgetMem4stack_error1
	    @@: mov eax,[Range.base]
		add eax,[Range.size]
		and ax,$F000; truncate to 4K
	       ; xor ax,ax ;truncate to 64K range
		sub eax,[Range.base]
		jbe PMUgetMem4stack_check_next
		cmp eax,edx
		jb PMUgetMem4stack_check_next
		add eax,[Range.base]
		sub eax,edx
		mov ebx,eax
		call MMUgetMem_FIX
		jc PMUgetMem4stack_check_next
		call PMUaddUsage
     PMUgetMem4stack_error1:
		pop esi
		ret

PMUaddUsage: ;EDI-addr of Process Header, EBX-base, EDX-size
	   ;return: C=0-success
	    push edi
	    add edi,PrHeader.usage-PrHeader.id
	    call RangesRoutine_INC
	    pop edi
	    jc @f
	    add [PrHeader.mem],edx
	@@: ret

PMUaddUnUsed: ;EDI-addr of Process Header, EBX-base, EDX-size
	   ;return: C=0-success
	    push edi
	    add edi,PrHeader.unused-PrHeader.id
	    call RangesRoutine_INC
	    pop edi
	    ret


PMUcreate: ;EAX-id parent process, CH-level, CL-prog model, ESI-process name, EBX-image description
	;stack: DD-sz CommandLine
	;	DD-sz WorkDir
	;	DD-sz EnvVar

	   ;return: (C=0) EDI-addr of Process Header
	    pushad
	    mov edi,ProcessList
	    call ListsRoutine_ADDlastRec
	    jc PMUcreate_finish
	    inc word[ProcessCount]
	    push eax ;PocessList rec
    ;Create header structure
       ;here is analyze type of header
	    cmp cl,[PrHeaderTypeMax]
	    ja PMUcreate_finish1
	    cmp cl,$FF
	    je PMUcreate_special_header
	    mov eax,sizeof.tPrHeaderType
	    mul cl
	    add eax,PrHeaderTypes
	    mov ebx,eax; description for header

	    mov ecx,[ebx]; count of header's pages
	    call MMUget0pages	;get mem for header
	    jc PMUcreate_finish1
	    mov edi,eax  ;PrHeader
	    pop esi
	    mov [PROCESS.addr],edi
	    call PMUadr2id
	    mov [PrHeader.id],si
	    mov eax,[esp+28]
	    mov [PrHeader.parent],ax
	;set up header's blocks
	  ;CommandLine,WorkDir,VarEnv
	    mov esi,ebx
	    add esi,4
	    mov cl,3
	    mov edx,PrHeader.CommandLine-PrHeader.id
	    add edx,edi
	    mov eax,sizeof.tProcessHeader
	    add eax,edi
       @@:  mov [edx],eax
	    add eax,[esi]
	    add edx,4
	    add esi,4
	    dec cl
	    jnz @b
	  ;usage
	    push edi
	    add dword[esp],PrHeader.usage-PrHeader.id
	    push eax
	    push dword[esi]
	    push dword(sizeof.tRange)
	    push dword(0)
	    call ListsRoutine_CREATE_FIX
	  ;add header in usage list
	    push ebx
	    mov edx,[ebx]
	    mov ebx,edi
	    call PMUaddUsage
	    pop ebx
	    add eax,[esi]
	    add esi,4
	  ;unused
	    push edi
	    add dword[esp],PrHeader.unused-PrHeader.id
	    push eax
	    push dword[esi]
	    push dword(sizeof.tRange)
	    push dword(0)
	    call ListsRoutine_CREATE_FIX
	    add eax,[esi]
	    add esi,4
	  ;virt usage
	    push edi
	    add dword[esp],PrHeader.VirtUsage-PrHeader.id
	    push eax
	    push dword[esi]
	    push dword(sizeof.tRange)
	    push dword(0)
	    call ListsRoutine_CREATE_FIX
	    add eax,[esi]
	    add esi,4
	  ;LDT
   ;	     mov [PrHeader.LDT.base],eax
	    push eax
	    push ebx
	    push edx
	    mov ebx,eax
	    mov edx,[esi]
    ;	     mov [PrHeader.LDT.size],edx
	    mov al,[esp+25+12]
	    mov [PrHeader.level],al
	    call MMU_create_LDT
	    jc PMUcreate_finish2
	    mov [PrHeader.LDTselector],ax
	    pop edx
	    pop ebx
	    pop eax
	    add eax,[esi]
	    add esi,4
	  ;handles
 ;	     mov [PrHeader.Handles.base],eax
	    mov eax,[esi]
  ;	     mov [PrHeader.Handles.size],eax
	    add esi,4
	  ;Process name
	    mov esi,[esp+4]
	    mov eax,ProcessNameLen
	    push edi
	    add edi,PrHeader.name-PrHeader.id
	    call StringRoutine_copy_sz
	    pop edi
	  ;CommandLine,WorkDir,VarEnv
	    mov ecx,3
	    push edi
	    mov edx,PrHeader.VarEnv-PrHeader.id
	    add edx,edi
	    mov ebp,esp
	    add ebp,36
	@@: mov eax,[PrHeaderType+ecx*4]
	    mov esi,[ebp]
	    mov edi,[edx]
	    call StringRoutine_copy_sz
	    sub edx,4
	    add ebp,4
	    dec cl
	    jnz @b
	    pop edi
      ;create PD
	    call PMUget0page
	    mov [PrHeader.PDaddr],eax
      ;create MSGBox
      ;      mov edx,[PrHeaderType.lenMsgBox]  ; count of msg
	    inc edx   ; header
	    shl edx,5 ; * msg_size ;  * 32
	    mov ebx,edx
	    call PMUgetMem
	    sub edx,ebx
	    jz @f
	    call PMUaddUnUsed
	 @@:
       ;Image is ready and correct
	  ;ESI-pImage, EBX-pDescr

	    mov cx,[ebx]
	    add ebx,2
    PMUcreate_seg:

	    call PMUcreate_seg_LDT
	    push cx
	    mov cx,[ebx+9]
	    add ebx,11

	    mov edx,[ebx+2]
	    call PMUgetMem



	    dec cx
	    jnz PMUcreate_seg

    PMUcreate_finish:
	    popad
	    ret
    PMUcreate_finish2:

    PMUcreate_finish1:
	    call ListsRoutine_DELETErec
	    pop eax
	    pop esi
	    stc
	    jmp PMUcreate_finish
    PMUcreate_special_header:

PMUdestroy:

PMUaddUsage4K:;EDI-ProcessHeader
	    push edx
	    mov edx,$1000
	    call PMUaddUsage
	    pop edx
	    ret

PMUget0page:;EDI-ProcessHeader
	    push ebx
	    call MMUget0page4K
	    mov ebx,eax
	    call PMUaddUsage4K
	    pop ebx
	    ret



PMUgetMem_serv: ;EDI-ProcessHeader, EDX-size, ECX-leveling
	   ;return: EAX-phys addr
;get memory in serving area (not available for task)
	    push edi
	    add edi,PrHeader.unused-PrHeader.id
	    call RangesRoutine_DEC_first
	    pop edi
      ;same as call PMUgetUnusedMem1
	    jc @f
	    ret
	@@: push edx
	    call Routine_Round_EDXto4K
	    call PMUgetMem
	    push ebx
	    mov ebx,eax
	    call PMUaddUnUsed
	    pop ebx
	    pop edx
	    jnc PMUgetMem_serv
	 ;zero dedicated memory
	    push edx
	    push eax
	 @@:mov byte[eax],0
	    inc eax
	    dec edx
	    jnz @b
	    pop eax
	    pop edx
;	     push ebx
;	     push edx
;	     mov ebx,eax
;	     add ebx,edx
;	     call Routine_Round_EDXto4K
;	     sub edx,[esp]
;	     call PMUaddUnUsed
;	     pop edx
;	     pop ebx
	 @@:ret

PMUgetMem: ;EDI-ProcessHeader, EDX-size
	   ;return: EAX-phys addr
	    push ecx
	    push ebx
	    push edx
	    mov ecx,$1000
 ;	     mov edx,ebx
 ;	     and bx,$F000
 ;	     sub edx,ebx
 ;	     add edx,[esp]
 ;	     xor ebx,ebx
	    call Routine_Round_EDXto4K
	    call MMUgetMem1
	    jc PMUgetMem_error
	    mov ebx,eax
	    call PMUaddUsage
    PMUgetMem_error:
	    pop edx
	    pop ebx
	    pop ecx
	    ret

PMUcreate_seg_LDT: ;EDI-PrHeader, EBX-pDescrSeg
	    push ax
	    push cx
	    push ebx
	    push edx
	    push ebp
	    mov ah,[ebx]
	    mov al,[PrHeader.level]
	    mov edx,[ebx+5]
	    mov ebp,[PrHeader.LDT]
	    mov ch,1
	    mov ebx,[ebx+1]
	    call MMU_create_descr
	    pop ebp
	    pop edx
	    pop ebx
	    pop cx
	    pop ax
	    ret

PMUcreate_frag_segment:
PMUcreate_solid_segment:

PMUcreate_segmentID: ;EAX-id process, CL-type(0-data,1-code,2-stack),
		   ;EBX-lin base, EDX-size;
	     ;return: EDI-phys addr,
	;    call PMUgetHeader: ;EAX-id process, EDI-addr ProcessHeader
PMUcreate_segmentHeader: ;EDI-addr ProcessHeader,CL-type(0-data,1-code,2-stack),EBX-lin base, EDX-size;
	    call PMUgetMem
	    ret