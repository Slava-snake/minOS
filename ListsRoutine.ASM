;lists routine


proc ListsRoutine_CREATE_FREE stdcall uses edi edx ,aDesc,countRec,sizeRec,useType
     ;return: C=0, EAX=addr
		xor eax,eax
		cmp [countRec],eax ;param2
		je .error
		cmp [sizeRec],eax ;param3
		je .error
		mov edi,[aDesc] ;param1
		mov [FRECLIST.Ulast],eax
		mov [FRECLIST.Uhead],eax
		mov eax,[useType]
		call ListsRoutine_CREATE_useT
		mov eax,[countRec]
		mul [sizeRec]
		test edx,edx
		jnz .error
		cmp byte[RUNsystem],0
		jz @f
		stdcall PMUgetMem,eax,[sizeRec]    ;return: EAX-addr
		jc .error
		jmp .format
	   @@:	mov edx,eax
		push ecx
		xor ecx,ecx
		stdcall MMUgetMem1
		pop ecx
		jc .error
    .format:	push eax
		mov [FRECLIST.Fhead],eax
		mov edx,eax
	   @@:	add eax,[sizeRec]
		mov [edx],eax
		dec [countRec]
		jz .finish
		mov edx,eax
		jmp @b
    .finish:	mov dword[edx],0
		mov [FRECLIST.Flast],edx
		pop eax
    .error:	ret
endp

ListsRoutine_CREATE_useT:
		cmp eax,1
		jbe @f
		xor eax,eax
	    @@: mov dword[FRECLIST.release],eax
		ret

proc ListsRoutine_CREATE_FIX stdcall uses edi edx, aDesc,aMem,sizeMem,sizeRec,useType
     ;return: EAX-last rec
		xor eax,eax
		cmp [aMem],eax	;param2
		je .error
		cmp [sizeMem],eax ;param3
		je .error
		cmp [sizeRec],eax ;param4
		je .error
		mov edi,[aDesc] ;param1
		mov [FRECLIST.Ulast],eax
		mov [FRECLIST.Uhead],eax
		mov eax,[useType]
		call ListsRoutine_CREATE_useT
		mov eax,[aMem]
		mov edx,eax
		add [sizeMem],eax
		mov [FRECLIST.Fhead],eax
	    @@: add eax,[sizeRec]
		cmp eax,[sizeMem]
		jae .finish
		mov [edx],eax
		mov edx,eax
		jmp @b
    .finish:	mov dword[edx],0
		mov [FRECLIST.Flast],edx
    .error:	ret
endp


ListsRoutine_LOCK: ;EDI-addr FRECLIST

		ret

ListsRoutine_GETfreeRec:  ;EDI-addr FRECLIST
		;return: C=0, EAX-addr
		mov eax,[FRECLIST.Fhead]
		test eax,eax
		jz @f
		push eax
		mov eax,[eax]
		mov [FRECLIST.Fhead],eax
		clc
		pop eax
		ret
	     @@:stc
		ret

ListsRoutine_FREE: ;EDI-addr FRECLIST, ESI-addr of Rec
		cmp byte[FRECLIST.release],cReleaseToHead
		je ListsRoutine_FREErec2head

ListsRoutine_FREErec2last:;EDI-addr FRECLIST, ESI-addr of Rec
		mov eax,[FRECLIST.Flast]
		mov [eax],esi
		mov dword[esi],0
		mov [FRECLIST.Flast],esi
		ret

ListsRoutine_FREErec2head:;EDI-addr FRECLIST, ESI-addr of Rec
		mov eax,[FRECLIST.Fhead]
		mov [esi],eax
		mov [FRECLIST.Fhead],esi
		ret

ListsRoutine_NEXTrec: ; EDI-addr FRECLIST, ESI-current
	       ;return: (Z=0) ESI-next;
		       ;(Z=1),ESI=0-no more REC
		push eax
		mov eax,[esi]
		test eax,eax
		jz ListsRoutine_NEXTrec_finish
		mov [FRECLIST.prev],esi
		mov esi,eax
    ListsRoutine_NEXTrec_finish:
		pop eax
		ret

ListsRoutine_INSERTrec:  ; ESI-addr of current REC, EDI- addr of FRECLIST
	       ;return: EAX-addr of new(C=0)
		call ListsRoutine_GETfreeRec
		jc @f
		push ebx
		mov ebx,[FRECLIST.prev]
		mov [ebx],eax
		mov [eax],esi
		pop ebx
		clc
		ret
	     @@:stc
		ret

ListsRoutine_ADDlastRec:;EDI-addr of FRECLIST,
	      ;return: EAX-addr of new(C=0)
		push esi
		mov esi,[FRECLIST.Ulast]
		call ListsRoutine_ADDrec
		jc @f
		mov dword[eax],0
		pop esi
		ret

ListsRoutine_ADDrec:	;ESI-addr of current REC, EDI- addr of FRECLIST
	      ;return: EAX-addr of new(C=0)
		call ListsRoutine_GETfreeRec
		jnc @f
		stc
		ret
	    @@: test esi,esi
		jnz @f
		mov [FRECLIST.Uhead],eax
		mov [FRECLIST.Ulast],eax
		mov dword[eax],0
		mov [esi],eax
		clc
		ret
	    @@: push edi
		mov edi,[esi]
		mov [eax],edi
		mov [esi],eax
		pop edi
		cmp dword[eax],0
		jnz @f
		mov [FRECLIST.Ulast],eax
	    @@: clc
		ret

ListsRoutine_DELETErec:  ; ESI-addr of current REC, EDI-addr of FRECLIST,
		push eax
		push ebx
		mov eax,[esi]
		mov ebx,[FRECLIST.prev]
		mov [ebx],eax
       cmp esi,[FRECLIST.Ulast]
       jne @f
       cmp ebx,edi
       jne @f
       mov dword[FRECLIST.Ulast],0
  ;		 test eax,eax ;is last ?
  ;		 jnz @f
  ;
  ;		 cmp esi,[FRECLIST.Uhead];is head ?
  ;		 jne @f
  ;		 mov [FRECLIST.Uhead],0
  ;	      @@:
  ;		 mov [FRECLIST.Ulast],ebx
	 @@:	call ListsRoutine_FREE
		pop ebx
		pop eax
		ret

ListsRoutine_DELETEnextRec:  ;ESI-current REC, EDI- RECLIST
		push eax
		push esi
		mov eax,[esi]
		push eax
		mov eax,[eax]
		test eax,eax ;is last ?
		jnz @f
		mov [FRECLIST.Ulast],esi
	     @@:mov [esi],eax
		pop esi
		call ListsRoutine_FREE
		pop esi
		pop eax
		ret
