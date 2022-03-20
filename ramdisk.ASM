;RAMDISK
org 0

RAMDISKSIZE=191*512
;__________________________________________________________________
   RamDisk tMinOSfs


	 db (RAMDISKSIZE-$) dup $AA
