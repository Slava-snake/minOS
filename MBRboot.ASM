;MBRBOOT-sector
FlatDiskHeads=2
FlatDiskCylinders=2
FlatDiskSectors=63
FlatDiskTotalSectors=FlatDiskHeads*FlatDiskCylinders*FlatDiskSectors; size in sectors
FlatDiskSize=FlatDiskTotalSectors*512


file 'MBR-HPformat.bin':0,446

;partition table
   DEFINE_PARTITION 1,$BB,0,0,2,FlatDiskHeads-1,FlatDiskCylinders-1,FlatDiskSectors,1,FlatDiskTotalSectors-1
   NO_PARTITION
   NO_PARTITION
   NO_PARTITION
    dw $AA55
