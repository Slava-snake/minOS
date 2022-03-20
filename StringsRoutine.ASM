;some routines
copy_sz:  ;ESI-source
	  ;EDI-destination
	 push ax
   copy_sz1:
	 lodsb
	 stosb
	 test al,al
	 jnz copy_sz1
	 pop ax
	 ret

copy_sz_get_len:  ;ESI-source, EDI-destination
      ;return: ECX-length
	 push ax
	 xor ecx,ecx
   copy_sz1byte:
	 lodsb
	 stosb
	 inc ecx
	 test al,al
	 jnz copy_sz1byte
	 pop ax
	 ret


copy_count_sz:	;ESI-source  , ECX-count
		;EDI-destination
	;return: ECX-changed, ECX=0
	 push edi
	 repnz stosb
	 pop edi
	 ret


StringRoutine_get_length_sz:  ;ESI-source  ; length 0-end string with #0
	  ;return: ECX-count,C=0;
	  ;	   C=1,error
	 push esi
	 push ax
	 xor ecx,ecx
	 test esi,esi
	 jnz @f
	 stc
	 jmp StringRoutine_get_length_sz_finish
      @@:lodsb
	 inc ecx
	 test al,al
	 jnz @b
    StringRoutine_get_length_sz_finish:
	 pop ax
	 pop esi
	 ret

StringRoutine_copy_sz:;ESI-source, EAX-limit length, EDI-destination;
	;return: C=0-success
	 test esi,esi
	 stc
	 jz StringRoutine_copy_sz_error1
	 push ecx
	 call StringRoutine_get_length_sz
	 cmp eax,ecx
	 jb StringRoutine_copy_sz_error0
	 push esi
	 push edi
	 rep movsb
	 pop edi
	 pop esi
   StringRoutine_copy_sz_error0:
	 pop ecx
   StringRoutine_copy_sz_error1:
	 ret
