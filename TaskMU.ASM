;Task management unit

TMUinit:
		 stdcall ListsRoutine_CREATE_FREE,TaskList,TaskMaxCount,sizeof.tTASK,FIFO
		 mov [TaskListAddr],eax
		 mov edi,[SystemHeader]
		 mov ebx,eax
		 mov edx,TaskMaxCount*sizeof.tTASK
		 call PMUaddUsage

;		  stdcall TMUcreate_task,0,0,0,0,0,0,127,TMUinit,8,$18,$18,STACKbase,STACKsize,0,0,0,0,0,0
		 stdcall TMUcreate_task,0,0,0,0,0,127,TaskManager,8,$18,$18,$7F000,$1000,0,0,0,0,0,0

	       ;create TaskManager
;		  mov ebp,TaskManager
;		  mov bx,8
;		  mov ax,0
;		  mov ecx,$1000
;		  call TMUcreate_task
	       ;create EventManager
;		  mov ebp,EventManager
;		  mov bx,8
;		  mov ax,0
;		  call TMUcreate_task
		  ret

TMUgetCurrentTASK:  ;current task
		 xor eax,eax
		 str ax
		 sub eax,TSSselector0
		 shr eax,3
		 ret

TMUaddr2id:  ;convert addr in EAX  to Task_id
		 push edx
		 sub eax,[TaskListAddr]
		 xor edx,edx
		 push dword(sizeof.tTASK)
		 div dword[esp]
		 pop edx
		 pop edx
		 ret

proc TMUcreateStack stdcall uses edx esi ,base,size; EDI-process header
       ;checkSTACKsize: 0-64KB
       ;return: C=0, EBX-phys addr, EAX-selector
		 mov edx,[size]
		 cmp edx,4096
		 jae @f
		 mov edx,4096
		 jmp TMUcheckSTACKsize_finish
	     @@: cmp edx,$10000
		 jbe TMUcheckSTACKsize_finish
		 mov edx,$10000
    TMUcheckSTACKsize_finish:
		 call PMUgetMem4stack	   ;EBX=EAX
		 jc TMUcreateStack_error
		 mov eax,[size]
		 shr eax,12
		 stdcall PageMUalignPhys2Lin,edi,ebx,[base],eax
		 mov eax,PrHeader.LDT-PrHeader.id
		 add eax,edi
		 stdcall TablesRoutine_get_free,eax
		 jc TMUcreateStack_error
		 movzx esi,byte[PrHeader.level]
		 push esi
		 push edx
		 push [base]
		 push eax
		 push dword(PrHeader.LDT-PrHeader.id)
		 add [esp],edi
		 call MMUcreateStackDescr;,[PrHeader.LDT],eax,[base],edx,esi
		 ret
     TMUcreateStack_error:
		 mov eax,-1
		 ret
endp

proc TMUcreate_task stdcall uses ecx esi edx ,type,sizeTSS,parent,prior,status,MsgBoxsize,entryPoint,CSsel,DSsel,ESsel,\
				 StackBase,StackSize,Sb2,Ss2,Sb1,Ss1,Sb0,Ss0  ;EDI-process header
	      ;return: EAX-task number;
		 movzx ecx,word[PrHeader.id]
		 push edi
		 mov edi,TaskList
		 call ListsRoutine_GETfreeRec
		 mov esi,eax
		 pop edi
		 push eax
		 call TMUaddr2id
		 push eax  ;id task
		 mov [TASK.process],cx
		 mov al,byte[status]
		 mov [TASK.status],al
		 mov al,byte[prior]
		 mov [TASK.basePrior],al ;-------------------------------
;		  mov ax,[parent]
;		  mov [TASK.parentTask],ax
;		  mov eax,[PDaddr]
;		  mov [TASK.CR3],eax
	     ;create TSS
		 mov eax,[type]
		 mov edx,[sizeTSS]
		 cmp [type],0
		 ja @f
		 cmp edx,sizeof.tTSS32
		 jae TMUcreateTSS_begin
		 mov edx,sizeof.tTSS32
		 jmp TMUcreateTSS_begin
	      @@:;ckeck other variants

       TMUcreateTSS_begin:
		 mov ecx,$10
		 call PMUgetMem_serv ;get mem for TSS
		 jc TMUcreateTask_error
		 mov esi,eax
	    ;create descriptor
		 ;id task in [esp]
		 pop eax
		 stdcall MMUcreateTSSdescr,eax,esi,edx
	    ;fill TSS
		 mov ax,word[ESsel]
		 mov [TSS.ES],ax
		 mov ax,word[CSsel]
		 mov [TSS.CS],ax
		 mov ax,word[DSsel]
		 mov [TSS.DS],ax
		 mov eax,[entryPoint]
		 mov [TSS.EIP],eax
		 mov [TSS.EFLAGS],$202 ; IF=1
		 mov ax,[PrHeader.LDTselector]
		 mov [TSS.LDT],ax
		 mov eax,[PrHeader.PDaddr]
		 mov [TSS.CR3],eax
	     ;create stack segments
		 movzx ecx,byte[PrHeader.level]
		 stdcall TMUcreateStack,[StackBase],[StackSize]
		 mov [TSS.SS],ax
		 mov dword[TSS.ESP],$FFF0 ;initial
		 mov eax,ecx;level
	      @@:sub cl,1
		 jc @f
		 sub eax,ecx
		 stdcall TMUcreateStack,[StackBase+eax*8],[StackSize+eax*8]
		 mov [TSS+ecx*8+8],ax
		 mov dword[TSS+ecx*8+4],$FFF0
		 mov al,[PrHeader.level]
		 jmp @b
	      @@:
	   ;create MSGbox
		 mov eax,[MsgBoxsize]
		 pop esi
		 call EMUcreateMsgBox
		 clc
    TMUcreateTask_error:
		 ret
endp

TMUdestroy_task:
TMUpause_task:
TMUresume_task:
TMUclone_task:


;________________________________________________________________________________________
TaskManager:
	;init area
	      nop
	      str [TaskManagerSel]
	;work
TaskManager_work:
	      nop
	      ;clear BUSY flag prev TSS
	      ;count stat prev Task
	      ;check msgs
	      ;select next Task
	      ;set BUSY flag selected TSS
	      ;write in own TSS selected descr TSS in prev field
	      ;jmp tss
    SHOW_OFFSET
TaskManager_time:
	   ;here is interrupt entry
	      nop
	     mov dword[$7f00B0],0
	      iret
		 jmp $