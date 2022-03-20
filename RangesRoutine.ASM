;ranges routine
proc RangesRoutine_CREATElist stdcall aDesc,aMem,sizeMem
		stdcall ListsRoutine_CREATE_FIX,[aDesc],[aMem],[sizeMem],sizeof.tRange,LIFO
		ret
endp

RangesRoutine_INC:  ;EBX-base, EDX-size, EDI-addr FRECLIST
	    ;return: C=0-success, C=1-error
		call ListsRoutine_LOCK
		push esi
		push eax
		mov [FRECLIST.prev],edi
		mov esi,[FRECLIST.Uhead]       ;
		test esi,esi
		jnz RangesRoutine_INC_check
		mov esi,edi
    RangesRoutine_INC_new:
		call ListsRoutine_ADDrec
		mov [aRange.base],ebx
		mov [aRange.size],edx
		jmp RangesRoutine_INC_finish
    RangesRoutine_INC_check:
		cmp ebx,[Range.base]
		jb RangesRoutine_INC_early
		ja RangesRoutine_INC_later
    RangesRoutine_INC_error:
		stc
		jmp RangesRoutine_INC_finish1
    RangesRoutine_INC_early:
		mov eax,ebx
		add eax,edx
		cmp eax,[Range.base]
		ja RangesRoutine_INC_error
		jb RangesRoutine_INC_insert
	       ;inc beginning
		sub [Range.base],edx
		add [Range.size],edx
		jmp RangesRoutine_INC_finish
    RangesRoutine_INC_insert:
		call ListsRoutine_INSERTrec
		mov [aRange.base],ebx
		mov [aRange.size],edx
		jmp RangesRoutine_INC_finish
    RangesRoutine_INC_later:
		mov eax,[Range.base]
		add eax,[Range.size]
		cmp ebx,eax
		jb RangesRoutine_INC_error
		je RangesRoutine_INC_append
	       ;next range
		call ListsRoutine_NEXTrec
		jnz RangesRoutine_INC_check
		jmp RangesRoutine_INC_new
    RangesRoutine_INC_append:
		add [Range.size],edx
		cmp [Range.next],0
		je RangesRoutine_INC_finish
		add eax,edx
		push esi
		call ListsRoutine_NEXTrec
		cmp eax,[Range.base]
		je @f
		pop esi
		ja RangesRoutine_INC_error
		jc RangesRoutine_INC_finish
	     @@:add eax,[Range.size]
		call ListsRoutine_DELETErec
		pop esi
		mov [Range.size],eax
    RangesRoutine_INC_finish:
		clc
    RangesRoutine_INC_finish1:
		pop eax
		pop esi
		ret

RangesRoutine_DEC_fix: ;EDI-addr of RECLIST, EBX-base, EDX-size
	   ;return: EAX-addr, C=0;
	   ;	    C=1-error, EAX-error code
		push esi
		push ebp
		call RangesRoutine_DEC_init
		jz RangesRoutine_DEC_error
    RangesRoutine_DEC_CheckFRec:
		mov eax,ebx
		add eax,edx
    RangesRoutine_DEC_CheckRange:
		cmp ebx,[Range.base]
		ja RangesRoutine_DEC_inRange
		je RangesRoutine_DEC_atBeg
    RangesRoutine_DEC_Next:
		call ListsRoutine_NEXTrec
		jz RangesRoutine_DEC_error
		mov ebp,[Range.base]
		add ebp,[Range.size];limit
		jmp RangesRoutine_DEC_CheckRange
    RangesRoutine_DEC_atBeg:
		cmp edx,[Range.size]
		je RangesRoutine_DEC_DelFRec
		jb RangesRoutine_DEC_CutBeg
    RangesRoutine_DEC_noFit:
		xor eax,eax
		stc
		jmp RangesRoutine_DEC_error
    RangesRoutine_DEC_inRange:
		cmp eax,ebp	  ;compare limits
		ja RangesRoutine_DEC_Next
		je RangesRoutine_DEC_CutEnd
    RangesRoutine_DEC_Split:
		sub ebp,eax
		push eax
		call ListsRoutine_ADDrec
		jc RangesRoutine_DEC_error
		sub [Range.size],edx
		sub [Range.size],ebp
		mov esi,eax
		pop eax
		mov [Range.base],eax
		mov [Range.size],ebp
		jmp RangesRoutine_DEC_Finish
    RangesRoutine_DEC_CutBeg:
		add [Range.base],edx
    RangesRoutine_DEC_CutEnd:
		sub [Range.size],edx
		jmp RangesRoutine_DEC_Finish
    RangesRoutine_DEC_DelFRec:
		call ListsRoutine_DELETErec
    RangesRoutine_DEC_Finish:
		mov eax,ebx
		clc
    RangesRoutine_DEC_error:
		pop ebp
		pop esi
		ret

RangesRoutine_DEC_first: ;EDI-addr of RECLIST, ECX-leveling, EDX-size
	   ;return: EAX-addr, C=0;
	   ;	    C=1-error, EAX-error code
		push esi
		push ebp
		push ecx
		call Routine_leveling_mask
		jc RangesRoutine_DEC_first_error
		push eax
		call RangesRoutine_DEC_init
		jz RangesRoutine_DEC_first_error
    RangesRoutine_DEC_first_FindFit:
		cmp edx,[Range.size]
		jbe @f
    RangesRoutine_DEC_first_FindNext:
		call ListsRoutine_NEXTrec
		jz RangesRoutine_DEC_first_error
		mov ebp,[Range.base]
		add ebp,[Range.size];limit
		jmp RangesRoutine_DEC_first_FindFit
	     @@:mov ecx,[Range.base]
		test ecx,[esp]
		jz RangesRoutine_DEC_first_fitRange
		mov eax,[esp]
		not eax
		and ecx,eax
		neg eax
		add ecx,eax  ; EBX-leveled addr
    RangesRoutine_DEC_first_fitRange:
		mov eax,ecx
		add eax,edx   ; fit range
		cmp eax,ebp
		ja RangesRoutine_DEC_first_FindNext
		je RangesRoutine_DEC_first_RangeMatch
		cmp ecx,[Range.base]
		je RangesRoutine_DEC_first_CutBeg
		sub ebp,eax
		push eax
		call ListsRoutine_ADDrec
		jc RangesRoutine_DEC_first_error
		sub [Range.size],edx
		sub [Range.size],ebp
		mov esi,eax
		pop eax
		mov [Range.base],eax
		mov [Range.size],ebp
		jmp RangesRoutine_DEC_first_Finish
    RangesRoutine_DEC_first_RangeMatch:
		cmp ecx,[Range.base]
		jne RangesRoutine_DEC_first_CutEnd
		call ListsRoutine_DELETErec
    RangesRoutine_DEC_first_Finish:
		pop eax
		mov eax,ecx
		jmp @f
    RangesRoutine_DEC_first_error:
		stc
		pop eax
	     @@:pop ecx
		pop ebp
		pop esi
		ret
    RangesRoutine_DEC_first_CutBeg:
		add [Range.base],edx
    RangesRoutine_DEC_first_CutEnd:
		sub [Range.size],edx
		jmp RangesRoutine_DEC_first_Finish

RangesRoutine_DEC_init:
		call ListsRoutine_LOCK
		mov [FRECLIST.prev],edi
		mov esi,[FRECLIST.Uhead]
		test esi,esi
		jnz @f
    .error:
	     @@:mov ebp,[Range.base]
		add ebp,[Range.size];limit
		ret

RangesRoutine_intersection: ;Range(pESI) compares EBX-EDX
	      ;return: C=1-intersection ,C=0-no
	      ;        C,Z=0-no more intersected ranges
		cmp dword[esi],0
		jnz @f
		ret
	    @@: cmp [Range.base],ebx
		jz RangesRoutine_intersection1
		jc RangesRoutine_intersection_checkRange
		push edx
		add edx,ebx
		cmp [Range.base],edx
		pop edx
		ret
    RangesRoutine_intersection_checkRange:
		push eax
		mov eax,[Range.base]
		add eax,[Range.size]
		cmp ebx,eax
		pop eax
		ret
    RangesRoutine_intersection1:
		stc
		ret

RangesRoutine_IS_add: ;EDI-RECLIST, EBX-base, EDX-size	 ;intersected ranges
	     ;return: Z=1-error
	     ;	      C=0-success
		push ecx
		push esi
		push eax
		mov [FRECLIST.prev],edi
		mov esi,[FRECLIST.Uhead]       ;
		mov eax,ebx
		add eax,edx
		test esi,esi
		jnz RangesRoutine_IS_add_check
		mov esi,edi
    RangesRoutine_IS_add_new:
		call ListsRoutine_ADDrec
		mov [aRange.base],ebx
		mov [aRange.size],edx
		jmp RangesRoutine_IS_add_finish
    RangesRoutine_IS_add_check:
		mov ebp,[Range.base]
		add ebp,[Range.size]
		cmp [Range.base],ebx
		je RangesRoutine_IS_add_ext
		ja RangesRoutine_IS_add_follow
		cmp ebp,ebx
		je RangesRoutine_IS_add_concat
		ja RangesRoutine_IS_add_intersect
		call ListsRoutine_NEXTrec
		jnz RangesRoutine_IS_add_check
    RangesRoutine_IS_add_error:
		stc
		pop eax
		pop esi
		pop ecx
		ret
    RangesRoutine_IS_add_intersect:
		sub [Range.size],ebp
		add [Range.size],ebx
    RangesRoutine_IS_add_concat:
		add [Range.size],edx
    RangesRoutine_IS_add_checkNext:
		cmp dword[Range.next],0
		je RangesRoutine_IS_add_finish
		mov ecx,[Range.next]
		cmp eax,[cRange.base]
		jb RangesRoutine_IS_add_finish
		push eax
		je @f
		mov ebp,[cRange.base]
		add ebp,[cRange.size]
		cmp eax,ebp
		jae RangesRoutine_IS_add_deletenext
		sub [Range.size],eax
		mov eax,[cRange.base]
		add [Range.size],eax
	    @@: mov eax,[cRange.size]
		add [Range.size],eax
    RangesRoutine_IS_add_deletenext:
		pop eax
		call ListsRoutine_DELETEnextRec
		ja RangesRoutine_IS_add_checkNext
    RangesRoutine_IS_add_finish:
		clc
    RangesRoutine_IS_add_finish1:
		pop eax
		pop esi
		pop ecx
		ret
    RangesRoutine_IS_add_ext:
		cmp ebp,eax
		jae RangesRoutine_IS_add_finish
		mov [Range.size],edx
		jmp RangesRoutine_IS_add_checkNext
    RangesRoutine_IS_add_follow:
		cmp eax,[Range.base]
		je RangesRoutine_IS_add_stretch
		ja @f
		call ListsRoutine_INSERTrec
		jc RangesRoutine_IS_add_error
		mov [aRange.base],ebx
		mov [aRange.size],edx
		jmp RangesRoutine_IS_add_finish
	     @@:cmp eax,ebp
		jb RangesRoutine_IS_add_resize
		mov [Range.base],ebx
		mov [Range.size],edx
		ja RangesRoutine_IS_add_checkNext
		jmp RangesRoutine_IS_add_finish1
    RangesRoutine_IS_add_resize:
		sub [Range.size],eax
		mov ecx,[Range.base]
		add [Range.size],ecx
    RangesRoutine_IS_add_stretch:
		add [Range.size],edx
		mov [Range.base],ebx
		jmp RangesRoutine_IS_add_finish

RangesRoutine_IS_sub: