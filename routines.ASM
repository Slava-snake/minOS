;file for routines
include 'ListsRoutine.asm'
include 'RangesRoutine.asm'
include 'StringsRoutine.asm'
include 'TablesRoutine.asm'

proc Routine_check_0 stdcall uses ecx,count ;EAX-start addr
     ;return: Z=1, array is 0
		mov ecx,[count]
		dec ecx
	     @@:cmp byte[eax+ecx*1],0
		jnz @f
		sub ecx,1
		jnc @b
	     @@:ret
endp

proc Routine_set0 stdcall uses ecx,count ;EAX-start addr
		mov ecx,[count]
		dec ecx
	     @@:mov byte[eax+ecx*1],0
		sub ecx,1
		jnc @b
	     @@:ret
endp

Routine_leveling_mask: ;ECX-leveling;
     ;return: EAX-mask , C=0
		push ecx
		bsf eax,ecx
		jz Routine_leveling_begin
		push eax
		bsr eax,ecx
		cmp eax,[esp]
		pop eax
		jne Routine_leveling_error
		mov cl,al
    Routine_leveling_begin:
		mov eax,$FFFFFFFF
		shl eax,cl
		not eax ;mask
		pop ecx
		clc
		ret
    Routine_leveling_error:
		xor eax,eax
		stc
		pop ecx
		ret

Routine_leveled_addr: ;EAX-leveling_mask, EBX-addr
	;return: EBX-leveled addr
		push eax
		not eax
		and eax,ebx
		jz @f
		neg eax
		add ebx,eax  ; EBX-leveled addr
	     @@:pop eax
		ret

Routine_Round_EBXto4:
	    test bl,$03
	    jz @f
	    add ebx,4
	    and bl,$FC
	 @@:ret

Routine_Round_EBXto8:
	    test bl,$07
	    jz @f
	    add ebx,8
	    and bl,$F8
	 @@:ret

Routine_Round_EDXto4K: ;EDX-size;
       ; return: EDX-arounded to 4K (0-0, 1-4K, 2-4K, ..)
	    test edx,$FFF
	    jz @f
	    add edx,$1000
	    and edx,$FFFFF000
	 @@:ret

Routine_Round_ECXto4K: ;ECX-size;
       ; return: ECX-arounded to 4K (0-0, 1-4K, 2-4K, ..)
	    test ecx,$FFF
	    jz @f
	    add ecx,$1000
	    and ecx,$FFFFF000
	 @@:ret

Routine_Round_EAXto4K: ;EDX-size;
       ; return: EDX-arounded to 4K (0-0, 1-4K, 2-4K, ..)
	    test eax,$FFF
	    jz @f
	    add eax,$1000
	    and eax,$FFFFF000
	 @@:ret


