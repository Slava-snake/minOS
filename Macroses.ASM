;Macroses for Partitions
include 'macro\proc32.inc'

macro SHOW_OFFSET
  { bits = 32
    display 'Offset=0x'
    repeat bits/4
	d = '0' + $ shr (bits-%*4) and 0Fh
	if d > '9'
	    d = d + 'A'-'9'-1
	end if
	display d
    end repeat
    display 13,10   }



macro DEFINE_PARTITION boot,FS,sHead,sCyl,sSect,eHead,eCyl,eSect,oSect,SectSize
  { db boot shl 7
    db sHead
    db(sCyl and $300) shr 2 +sSect
    db sCyl and $FF
    db FS
    db eHead
    db (eCyl and $300) shr 2 +eSect
    db eCyl and $FF
    dd oSect
    dd SectSize  }

macro NO_PARTITION
  { dd 4 dup 0 }

macro DEFINE_CODE_SEG base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10011000b 		 ;type 26
    db ((limit and $000F0000) shr 16) or 01000000b
    db base shr 24  }

macro DEFINE_STACK_SEG base,limit,dpl
  { dw (limit-1) and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10010110b 		  ; type 22
    db (((limit-1) and $000F0000) shr 16) or 00000000b
    db (base and $FF000000) shr 24  }

macro DEFINE_DATA_SEG base,limit,dpl
  { dw limit and $FFFF
    dw base and $FFFF
    db (base and $00FF0000) shr 16
    db (dpl shl 5) or 10010010b 		  ; type 18
    db ((limit and $000F0000) shr 16) or 11000000b
    db (base and $FF000000) shr 24  }

