;Page management unit

PageMUinit:
	     mov edi,[SystemHeader]
	     call PMUget0page
	     mov [PDaddr],eax
	     mov [PrHeader.PDaddr],eax
	     mov cr3,eax
       ;method 4MB-pages
;	      mov edi,eax
;	      mov ebp,dword[MaxRAM]
;	      mov ecx,$400000 ; 4MB step
;	      mov eax,$083  ;PDE   PS,W,P;
;	  @@: stosd
;	      add eax,ecx
;	      cmp eax,$F0000000
;	      jae @f
;	      cmp eax,ebp
;	      jb @b
;	  @@: mov edi,[PDaddr]
;	      add edi,$F0000000 shr 20
;	      mov eax,$F000009B ;PDE PS,PCD,PWT,W,P
;	  @@: stosd
;	      add eax,ecx
;	      jnc @b

	;method 4KB-pages
	     mov esi,initialMEMORYranges
	     mov cl,[RangeCount]

	 @@: cmp byte[esi+16],1
	     jne PageMUinit_out
	     cmp dword[esi+4],0
	     jnz PageMUinit_out
	     mov eax,[esi+8]
	     call Routine_Round_EAXto4K
	     shr eax,12
	     stdcall PageMUalignPhys2Lin,edi,[esi],[esi],eax,3
     PageMUinit_out:
	     add esi,$20
	     dec cl
	     jnz @b

	 ;init PageMode
	     mov eax,cr4
	     or eax,$90 ; PGE,PSE
	     mov cr4,eax
	     mov eax,cr0
	     bts eax,31   ;PG
	     mov cr0,eax
;	      mov eax,cr3
;	      bts dword[eax],7	;set G for page (0-4MB)
	     ret

PageMU_getTaskCR3: ;EAX-task number
		  ;return: EDX-addr,C=0
	     cmp eax,TaskMaxCount
	     jae PageMU_getTaskCR3_error
	     push eax
	     mov edx,sizeof.tTASK
	     mul edx
	     add eax,[TaskListAddr]
;	      mov edx,[mTASK.CR3]
	     pop  eax
	     ret
     PageMU_getTaskCR3_error:
	     xor edx,edx
	     stc
	     ret

PageMU_virt2phys_get: ;EBX-PDaddr, EDX-linear addr,
	  ;return: C=0,Z=0, EAX-phys addr
	  ;	   C=0, Z=1, EDX-EAX-phys addr(40bit)
	  ;	   C=1, EAX=0, not assigned

	     mov eax,edx
	     shr eax,22
	     mov eax,[ebx+eax*4] ;PDE
	     test eax,eax
	     jnz @f

	 @@: bt eax,0 ;present
	     jc @f

	  @@:bt eax,7  ;PS
	     jnc @f
	    ;4MB page
	     push eax
	     and eax,$FFC00000
	     and edx,$003FFFFF
	     or eax,edx
	     pop edx
	     and edx,$001FE000
	     shr edx,13
	     push eax
	     xor eax,eax
	     pop eax
	     jmp PageMU_virt2phys_final
	 @@:

PageMU_virt2phys: ;EAX-task number, EDX-addr
	     ;return: EAX-phys addr, C=0
	     push edx
	     call PageMU_getTaskCR3
	     mov eax,[esp]
	     shr eax,22
	     mov eax,[edx+eax*4]
	     pop edx
	     bt ax,0
	     jnc PageMU_virt2phys_error
	     bt ax,7
	     jnc PageMU_virt2phys_PTentry
	     and edx,$003FFFFF
	     and eax,$FFC00000
	     jmp PageMU_virt2phys_final
    PageMU_virt2phys_PTentry:
	     and ax,$F000
	     and edx,$3FFFFF
	     shr edx,12
	     mov eax,[eax+edx*4]
	     bt ax,0
	     jnc PageMU_virt2phys_error
	     and ax,$F000
	     mov edx,[esp-4]
	     and edx,$FFF
    PageMU_virt2phys_final:
	     add eax,edx
	     ret
    PageMU_virt2phys_error:
	     stc
	     ret

PageMU_phys2virt: ;EAX-task number, EDX-addr
	     ;return: EAX-addr, C=0
	     push edx
	     call PageMU_getTaskCR3
    PageMU_phys2virt_getPDE:
	     mov eax,[edx]
	     bt eax,0
	     jnc PageMU_phys2virt_nextPDE
	     bt eax,7
	     jnc PageMU_phys2virt_gotoPTE
	   ;check PDentry
	     xor eax,[esp]
	     test eax,$FFC00000
	     jz PageMU_phys2virt_bingoPDE
    PageMU_phys2virt_nextPDE:
	     add edx,4
	     test dx,$0FFF
	     jnz PageMU_phys2virt_getPDE
    PageMU_phys2virt_error:
	     pop edx
	     xor eax,eax
	     stc
	     ret
    PageMU_phys2virt_gotoPTE:
	     push edx
	     and eax,$FFC00000
	     mov edx,eax
    PageMU_phys2virt_getPTE:
	     mov eax,[edx]
	     bt eax,0
	     jnc PageMU_phys2virt_error
	     xor eax,[esp+4]
	     test eax,$FFFFF000
	     jz PageMU_phys2virt_bingoPTE
    PageMU_phys2virt_nextPTE:
	     add edx,4
	     test dx,$0FFF
	     jnz PageMU_phys2virt_getPTE
	     pop edx
	     jmp PageMU_phys2virt_nextPDE
    PageMU_phys2virt_bingoPTE:
	     mov eax,[edx]
	     and ax,$F000
	     pop edx
	     mov edx,[esp]
	     and edx,$00000FFF
	     jmp PageMU_phys2virt_bingo
    PageMU_phys2virt_bingoPDE:
	     mov eax,[edx]
	     and eax,$FFC00000
	     mov edx,[esp]
	     and edx,$003FFFFF
    PageMU_phys2virt_bingo:
	     add eax,edx
	     pop edx
	     ret

proc PageMUalignPhys2Lin uses eax ecx ebx edx edi esi,PrHead,physA,linA,len4K,mask;EDI-process Header
	    ;return: C=0-success
	     mov ebx,[physA]
	     mov eax,[linA]
	     mov ecx,[len4K]
	     mov esi,[PrHeader.PDaddr]
	     mov edi,[mask]
	     and ebx,$FFFFF000
	     shr eax,22
	     shl eax,2
	     add esi,eax
    PageMUalignPhys2Lin_checkPDE:
	     lodsd
	     test eax,eax
	     jnz PageMUalignPhys2Lin_enterPT
	     mov edi,[PrHead]
	     call PMUget0page;-------------------------------------------------add to process usage
	     mov edi,[mask]
	     mov [esi-4],edi
	     or [esi-4],eax
	     jmp @f
    PageMUalignPhys2Lin_enterPT:
	     and ax,$FC00
	  @@:mov edx,[linA]
	     and edx,$003FF000
	     shr edx,10
	     add eax,edx
	  @@:cmp dword[eax],0
	     jnz PageMUalignPhys2Lin_nextPTE
	   ;set addr
	     mov [eax],edi
	     or [eax],ebx
	   ;select next
    PageMUalignPhys2Lin_nextPTE:
	     add ebx,$1000
	     add [linA],$1000
	     dec ecx
	     jz PageMUalignPhys2Lin_finish
	     add eax,4
	     test ax,$0FFF
	     jnz @b
	     jmp PageMUalignPhys2Lin_checkPDE
    PageMUalignPhys2Lin_error:
	   ;backup changes --------------------------______________
	     stc
    PageMUalignPhys2Lin_finish:
	     ret
endp


