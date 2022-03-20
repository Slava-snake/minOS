;Routine for tables

proc TablesRoutine_create stdcall uses esi ,TabDescr,base,size,recSize,eco
	 ;size of table in bytes  {maybe size>recSize*count}
	 ;eco=1 => clear first dword of record

	 ;return: EAX-count of records
	 ;	  CF=0 success
	 ;	  CF=1 error
	    mov esi,[TabDescr]
	    mov eax,[base]
	    mov [TABdescr.start],eax
	    mov [TABdescr.free1],eax
	    push edx
	    mov eax,[size]
	    cmp eax,4
	    jae @f
	    push dword 0
	    stc
	    jmp TablesRoutine_create_finish
	@@: xor edx,edx
	    div [recSize]
	    push eax
	    test eax,eax
	    jnz TablesRoutine_create_ok
	    stc
	    jmp TablesRoutine_create_finish
    TablesRoutine_create_ok:
	    mov eax,[size]
	    sub eax,edx
	    sub eax,[recSize]
	    add eax,[base]
	    jc TablesRoutine_create_finish
	    mov [TABdescr.end],eax
	    mov eax,[recSize]
	    mov [TABdescr.recSize],eax
	    mov edx,[esp] ;<>0
	    mov al,byte[eco]
	    mov [TABdescr.eco],al
	    mov [TABdescr.lock],0
	    test al,al
	    jz TablesRoutine_create_clear
	    mov eax,[base]
	@@: mov dword[eax],0
	    add eax,[recSize]
	    dec edx
	    jnz @b
    TablesRoutine_create_finish:
	    pop eax
	    pop edx
	    ret
    TablesRoutine_create_clear:
	    mov edx,[base]
	    mov eax,[size]
	@@: mov byte[edx],0
	    inc edx
	    dec eax
	    jnz @b
	    jmp TablesRoutine_create_finish
endp

proc TablesRoutine_get_free stdcall uses esi ,TabDescr
	;return: C=0, EAX-addr
	    mov esi,[TabDescr]
	    test [TABdescr.eco],$2
	    jz @f
	    xor eax,eax
	    stc ;no free
	    ret
	 @@:
	    mov eax,[TABdescr.free1]
	    push eax
    TablesRoutine_get_free_next:
	    add eax,[TABdescr.recSize]
	    cmp eax,[TABdescr.end]
	    jbe @f
	    or [TABdescr.eco],2
	    jmp TablesRoutine_get_free_finish
	 @@:test [TABdescr.eco],1
	    jnz @f
	    cmp dword[eax],0
	    jne TablesRoutine_get_free_next
	    jmp TablesRoutine_get_free_new
	 @@:stdcall Routine_check_0,[TABdescr.recSize]
	    jnz TablesRoutine_get_free_next
	    clc
    TablesRoutine_get_free_new:
	    mov [TABdescr.free1],eax
    TablesRoutine_get_free_finish:
	    pop eax
	    ret
endp

proc TablesRoutine_free stdcall uses esi, TabDescr
	;EAX-pointer
	;C=1-error
	    mov esi,[TabDescr]
	    cmp eax,[TABdescr.start]
	    jae @f
	    ret
	 @@:cmp [TABdescr.end],eax
	    jae @f
	    ret
	 @@:btr word[TABdescr.eco],1
	    jc @f
	    cmp eax,[TABdescr.free1]
	    jae TablesRoutine_free_clear
	 @@:mov [TABdescr.free1],eax
    TablesRoutine_free_clear:
	    test [TABdescr.eco],1
	    jz @f
	    mov dword[eax],0
	    ret
	 @@:stdcall Routine_set0,[TABdescr.recSize]
	    ret
endp
