;structures
;MEMORY
struc tRECLIST
  { .Uhead dd ?
    .Ulast dd ?
    .Fhead dd ?
    .Flast dd ?
    .prev  dd ?
    .release dw ?
    .lock  dw ?
    sizeof.#tRECLIST=$-.Uhead }
virtual at EDI
  FRECLIST tRECLIST
end virtual
virtual at EAX
  RECLIST tRECLIST
end virtual

struc t1Range
  { .base dd ?
    .size dd ?
    sizeof.#t1Range=$-.base }

struc tRange
  { .next  dd ?
    .base  dd ?
    .size  dd ?
    sizeof.#tRange=$-.next }
virtual at ESI
  Range  tRange
end virtual
virtual at EAX
  aRange  tRange
end virtual
virtual at ECX
  cRange  tRange
end virtual

struc tTabDescr
   { .start   dd ?
     .end     dd ?
     .free1   dd ?
     .recSize dd ?
     .res1    db ?
     .res2    db ?
     .eco     db ?
     .lock    db ? }
virtual at ESI
  TABdescr tTabDescr
end virtual

;PROCESS
struc tPROCESS
  { .next dd ?
    .addr dd ?
    .reserve dd ?
    sizeof.#tPROCESS=$-.next}
virtual at EAX
  PROCESS tPROCESS
end virtual

struc tProcessHeader  ; 4K
  { .id 	  dw ?
    .parent	  dw ?	;+2
    .LDTselector  dw ?
    .baseprior	  db ?	;+6
    .level	  db ?	;+7
    .PDaddr	  dd ?	;+8   ;own 4K-page
    .LDT	  tTabDescr	      ;+12    ;14
    .Handles	  tTabDescr	      ;+26    ;14
    .mem	  dd ?		    ;+40    ;4
    .usage	  tRECLIST	    ;+44    ;24
    .unused	  tRECLIST	    ;+68    ;24
    .VirtUsage	  tRECLIST	    ;+92    ;24
    .CommandLine  dd ?	;+116
    .WorkDir	  dd ?	;+120
    .VarEnv	  dd ?	;+124
    .name	  db ProcessNameLen dup ? ;+128
    sizeof.#tProcessHeader=$-.id }
virtual at EDI
  PrHeader tProcessHeader
end virtual

struc tPrHeaderType p0,p1,p2,p3,p4,p5,p6,p7,p8
  { .pagesCount     dd p0
    .lenCommandLine dd p1
    .lenWorkDir     dd p2
    .lenVarEnv	    dd p3
    .lenUsage	    dd p4 ;(12)
    .lenUnused	    dd p5 ;(12)
    .lenVirtUsage   dd p6 ;(12)
    .lenLDT	    dd p7 ;(8)
    .lenHandles     dd p8 ;(4)
  ;  .lenMsgBox      dd p9 ;(32)
    sizeof.#tPrHeaderType=$-.pagesCount }
virtual at EBX
  PrHeaderType tPrHeaderType ?,?,?,?,?,?,?,?,?
end virtual


;TASK
struc tTASK
  {  .next	   dd ?
     .status	   db ?
     .basePrior    db ?
     .process	   dw ?
   ;  .parentTask   dw ?
   ;  .FirstChild   dw ?
   ;  .NextBro	    dw ?
     .TSSaddr	   dd ?
   ;  .CR3	    dd ?
     .MsgBox	   dd ?
     sizeof.#tTASK=$-.next }
virtual at ESI
  TASK tTASK
end virtual
virtual at EAX
  mTASK tTASK
end virtual

;TSS
struc tTSS32
  { .PreviousTask dw ? ;+0
    .Reserved0	  dw ?	      ;+2
    .ESP0	  dd ?	      ;+4
    .SS0	  dw ?	      ;+8
    .Reserved1	  dw ?	      ;+0Ah
    .ESP1	  dd ?	      ;+0Ch
    .SS1	  dw ?	      ;+10h
    .Reserved2	  dw ?	      ;+12h
    .ESP2	  dd ?
    .SS2	  dw ?
    .Reserved3	  dw ?	      ;
    .CR3	  dd ?	       ;+1Ch
    .EIP	  dd ?	       ;+20h
    .EFLAGS	  dd ?
    .EAX	  dd ?	      ;  44
    .ECX	  dd ?
    .EDX	  dd ?	      ;52
    .EBX	  dd ?
    .ESP	  dd ?	      ; 60
    .EBP	  dd ?
    .ESI	  dd ?	      ;+40h
    .EDI	  dd ?	      ;72
    .ES 	  dw ?
    .Reserved4	  dw ?	     ; 76
    .CS 	  dw ?
    .Reserved5	  dw ?
    .SS 	  dw ?
    .Reserved6	  dw ?
    .DS 	  dw ?
    .Reserved7	  dw ?
    .FS 	  dw ?
    .Reserved8	  dw ?
    .GS 	  dw ?
    .Reserved9	  dw ?
    .LDT	  dw ?
    .Reserved10   dw ?
    .DebugByte	  db ?
    .Reserved11   db ?
    .IOMapBase	  dw ?
    .reserved	  db 24 dup ?
    sizeof.#tTSS32=$-.PreviousTask }  ;128 bytes
virtual at ESI
  TSS tTSS32
end virtual


;DAP
struc tDAP
  {  .size	 db ?
     .reserved	 db ?
     .count	 dw ?
     .buffer	 dd ?
     .startblock dq ?
     .flat64addr dq ?
     sizeof.#tDAP=$-.size }
virtual at SI
  DAP tDAP
end virtual

;partition strutures
;minOS file system
struc tMinOSfs	;512 bytes
  {  .jmp	 db 3 dup ?   ;3
     .FSname	 db 13 dup ?  ;13
     .size	 dd ?	      ;4
     .root	 dd ?	      ;4
     .reserves1  dd ?	      ;4
     .freeBlocks tRECLIST    ;20
     .freeRanges db (38*sizeof.tRange) dup ? ;456  ;+48
     .nextFBsect dd ?	      ;4
     .reserved2  dw ?	      ;2
     .sig	 dw ? }       ;2
virtual at ESI
  fsHEAD tMinOSfs
end virtual

;handle structures
struc tHANDLE
  {  .next	 dd ?
     .FShandle	 dd ?
     .attr	 dd ?
     sizeof.#tHANDLE=$-.next  }
virtual at ESI
  Handle tHANDLE
end virtual

;Program image description
;  dw ? Nseg
;    db ? type
;    dd ? Vbase
;    dd ? size
;    dw ? Nsect
;      dd ? Vbase
;      dd ? size

;pushad
;  Push(EAX);  +28
;  Push(ECX);  +24
;  Push(EDX);  +20
;  Push(EBX);  +16
;  Push(ESP_old);+12
;  Push(EBP);  +8
;  Push(ESI);  +4
;  Push(EDI);  +0
