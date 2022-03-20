;interrupt module

IRQinit:
	;mask PIC
	 mov al,$11
	 out $20,al
	 mov al,$30
	 out $21,al
	 mov al,4
	 out $21,al
	 mov al,1
	 out $21,al

	 mov al,$FF
	 out $21,al
	 out $A1,al

