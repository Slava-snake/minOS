;Ports Management Unit

PortMUinit:  xor ebx,ebx
	     mov ecx,$1000
	     mov edx,65536/8 ; bitmap size
	     call MMUget0Mem1
	     mov [TAB_PORT_BM],eax
	     ret

PortMUgetPort: ; AX-port
	     ;return: C=0-succes
