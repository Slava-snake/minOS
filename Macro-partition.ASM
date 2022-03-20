;Macroses for Partitions
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
