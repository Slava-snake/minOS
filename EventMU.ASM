;Event Management Unit


EMUcreateMsgBox:; EAX-MsgBox size in records , ESI-task record, EDI-process header
	 ;return: C=0 successful
	     push edx
	     push ecx
	     inc eax
	     shl eax,5 ;msg size=32
	     cmp eax,4096
	     jbe @f
	     mov eax,$1000
	 @@: mov edx,eax
	     mov ecx,$1000
	     call PMUgetMem_serv
	     mov [TASK.MsgBox],eax
	     pop ecx
	     pop edx
	     ret

EventManager:
	     jmp $

