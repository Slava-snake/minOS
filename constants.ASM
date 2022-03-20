; constants
;system
initialMEMORYranges=$F000
GDTbase=$10000
GDTsize=$10000
GDTcountRec=GDTsize/8
GDTseg16=GDTbase/$10
GDTrange=GDTbase+GDTsize
LDTsize=$1000
IDTbase=$20000
IDTsize=256*8;=$800
IDTrange=IDTbase+IDTsize
SMMbase=$30000
SMMsize=$10000
STACKbase=$F000
STACKsize=$1000
STACKlimit=STACKbase-STACKsize+1
STACKpointer=$10000-$10
initialMEMORYranges=STACKbase
TAB_FreeBlock=$7C00
TAB_FreeBlockCount=$200
TAB_FreeBlockSize=TAB_FreeBlockCount*sizeof.tRange
TAB_PORTsize=$2000
Process0LDT=GDTcountRec-TaskMaxCount-ProcessesMaxCount
LDTselector0=GDTbase+Process0LDT*8
TSSselector0=GDTbase+GDTsize-TaskMaxCount*8; 8-size of descriptor TSS
GDT_1st_free_init=GDTbase+LDTselector0+8*ProcessesMaxCount

KernelModuleBase=$1000
KernelModuleSize=$6C00
initialGDTsize=initialGDT_end-initialGDT
TAB_FreeBlockRange=TAB_FreeBlock+TAB_FreeBlockCount

;Memory module
DESCR_CODE_SEG=24
DESCR_CODE_SEG_R=26
DESCR_CODE_SEG_CONF=28
DESCR_CODE_SEG_R_CONF=30
DESCR_DATA_SEG=18
DESCR_DATA_SEG_RO=16
DESCR_STACK_SEG=22
DESCR_LDT=2
DESCR_TASK_GATE=5
DESCR_TSS=9
DESCR_CALL_GATE=12
DESCR_INTERRUPT_GATE=14
DESCR_TRAP_GATE=15

;Task module
TaskMaxCount=2048

 ;for LDT
CS_DESCR_DEF=0+4
SS0_DESCR_DEF=8+4
SS1_DESCR_DEF=16+4
SS2_DESCR_DEF=24+4
SS3_DESCR_DEF=32+4
DS_DESCR_DEF=48+4
SYS_DESCR_DEF=56+4

;Process module
ProcessesMaxCount=256
HandleMaxCount=1024
ProcessNameLen=64

FIFO=1
LIFO=0
cReleaseToHead=0
cReleaseToTail=1
PrHeaderTypeMax=(PrHeaderTypeEnd-PrHeaderTypes)/sizeof.tPrHeaderType