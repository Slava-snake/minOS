;list of processors
align 16
processors db 1,'Other',0
	   db 2,'Unknown',0
	   db 3,'8086',0
	   db 4,'80286',0
	   db 5,'80386',0
	   db 6,'80486',0
	   db 7,'8087',0
	   db 8,'80287',0
	   db 9,'80387',0
	   db $0A,'80487',0
	   db $0B,'Pentium',0
	   db $0C,'Pentium Pro',0
	   db $0D,'Pentium II',0
	   db $0E,'Pentium MMX',0
	   db $0F,'Celeron',0
	   db $10,'Pentium II Xeon',0
	   db $11,'Pentium III',0
	   db $12,'M1',0
	   db $13,'M2',0
	   db $14,'Celeron M',0
	   db $15,'Pentium 4 HT',0
	   db $18,'AMD Duron',0
	   db $19,'K5',0
	   db $1A,'K6',0
	   db $1B,'K6-2',0
	   db $1C,'K6-3',0
	   db $1D,'AMD Athlon',0
	   db $1E,'AMD29000',0
	   db $1F,'K6-2+',0
	   db $20,'Power PC',0
	   db $21,'Power PC 601',0
	   db $22,'Power PC 603',0
	   db $23,'Power PC 603+',0
	   db $24,'Power PC 604',0
	   db $25,'Power PC 620',0
	   db $26,'Power PC x704',0
	   db $27,'Power PC 750',0
	   db $28,'Core Duo',0
	   db $29,'Core Duo M',0
	   db $2A,'Core Solo M',0
	   db $2B,'Atom',0
	   db $2C,'Core M',0
	   db $30,'Alpha',0
	   db $31,'Alpha 21064',0
	   db $32,'Alpha 21066',0
	   db $33,'Alpha 21164',0
	   db $34,'Alpha 21164PC',0
	   db $35,'Alpha 21164a',0
	   db $36,'Alpha 21264',0
	   db $37,'Alpha 21364',0
	   db $38,'AMD Turion II Ultra 2-core M',0
	   db $39,'AMD Turion II 2-core M',0
	   db $3A,'AMD Athlon 2-core M',0
	   db $3B,'AMD Opteron 6100',0
	   db $3C,'AMD Opteron 4100',0
	   db $3D,'AMD Opteron 6200',0
	   db $3E,'AMD Opteron 4200',0
	   db $3F,'AMD FX',0
	   db $40,'Mips',0
	   db $41,'Mips R4000',0
	   db $42,'Mips R4200',0
	   db $43,'Mips R4400',0
	   db $44,'Mips R4600',0
	   db $45,'Mips R10000',0
	   db $46,'AMD C',0
	   db $47,'AMD E',0
	   db $48,'AMD A',0
	   db $49,'AMD G',0
	   db $4A,'AMD Z',0
	   db $4B,'AMD R',0
	   db $4C,'AMD Opteron 4300',0
	   db $4D,'AMD Opteron 6300',0
	   db $4E,'AMD Opteron 3300',0
	   db $4F,'AMD FirePro',0
	   db $50,'SPARC',0
	   db $51,'SuperSPARC',0
	   db $52,'microSPARC II',0
	   db $53,'microSPARC IIep',0
	   db $54,'UltraSPARC',0
	   db $55,'UltraSPARC II',0
	   db $56,'UltraSPARC Iii',0
	   db $57,'UltraSPARC III',0
	   db $58,'UltraSPARC IIIi',0
	   db $60,'68040',0
	   db $61,'68xxx',0
	   db $62,'68000',0
	   db $63,'68010',0
	   db $64,'68020',0
	   db $65,'68030',0
	   db $66,'AMD Athlon X4',0
	   db $67,'AMD Opteron X1000',0
	   db $68,'AMD Opteron X2000 APU',0
	   db $70,'Hobbit',0
	   db $78,'Crusoe TM5000',0
	   db $79,'Crusoe TM3000',0
	   db $7A,'Efficeon TM8000',0
	   db $80,'Weitek',0
	   db $82,'Itanium',0
	   db $83,'AMD Athlon64',0
	   db $84,'AMD Opteron',0
	   db $85,'AMD Sempron',0
	   db $86,'AMD Turion64 M',0
	   db $87,'AMD Opteron 2-core',0
	   db $88,'AMD Athlon X2',0
	   db $89,'AMD Turion X2 M',0
	   db $8A,'AMD Opteron X4',0
	   db $8B,'AMD Opteron 3rd gen',0
	   db $8C,'AMD Phemon FX 4-core',0
	   db $8D,'AMD Phemon X4',0
	   db $8E,'AMD Phemon X2',0
	   db $8F,'AMD Athlon X2',0
	   db $90,'PA-RISC',0
	   db $91,'PA-RISC 8500',0
	   db $92,'PA-RISC 8000',0
	   db $93,'PA-RISC 7300LC',0
	   db $94,'PA-RISC 7200',0
	   db $95,'PA-RISC 7100LC',0
	   db $96,'PA-RISC 7100',0
	   db $A0,'V30',0
	   db $A1,'Xeon 3200 4-core',0
	   db $A2,'Xeon 3000 2-core',0
	   db $A3,'Xeon 5300 4-core',0
	   db $A4,'Xeon 5100 2-core',0
	   db $A5,'Xeon 5000 2-core',0
	   db $A6,'Xeon LV 2-core',0
	   db $A7,'Xeon ULV 2-core',0
	   db $A8,'Xeon 7100 2-core',0
	   db $A9,'Xeon 5400 4-core',0
	   db $AA,'Xeon 4-core',0
	   db $AB,'Xeon 5200 2-core',0
	   db $AC,'Xeon 7200 2-core',0
	   db $AD,'Xeon 7300 4-core',0
	   db $AE,'Xeon 7400 4-core',0
	   db $AF,'Xeon 7400 multi-core',0
	   db $B0,'Pentium III Xeon',0
	   db $B1,'Pentium III SpeedStep',0
	   db $B2,'Pentium 4',0
	   db $B3,'Xeon',0
	   db $B4,'AS400',0
	   db $B5,'Xeon MP',0
	   db $B6,'AMD Athlon XP',0
	   db $B7,'AMD Athlon MP',0
	   db $B8,'Itanium 2',0
	   db $B9,'Pentium M',0
	   db $BA,'Celeron D',0
	   db $BB,'Pentium D',0
	   db $BC,'Pentium EE',0
	   db $BD,'Core Solo',0
	   db $BF,'Core 2 Duo',0
	   db $C0,'Core 2 Solo',0
	   db $C1,'Core 2 Extreme',0
	   db $C2,'Core 2 Quad',0
	   db $C3,'Core 2 Extreme M',0
	   db $C4,'Core 2 Duo M',0
	   db $C5,'Core 2 Solo M',0
	   db $C6,'Core i7',0
	   db $C7,'Celeron 2-core',0
	   db $C8,'IBM390',0
	   db $C9,'G4',0
	   db $CA,'G5',0
	   db $CB,'ESA/390 G6',0
	   db $CC,'z/Archotecture base',0
	   db $CD,'Core i5',0
	   db $CE,'Core i3',0
	   db $D2,'VIA C7-M',0
	   db $D3,'VIA C7-D',0
	   db $D4,'VIA C7',0
	   db $D5,'VIA Eden',0
	   db $D6,'Xeon multi-core',0
	   db $D7,'Xeon 3xxx 2-core',0
	   db $D8,'Xeon 3xxx 4-core',0
	   db $D9,'VIA Nano',0
	   db $DA,'Xeon 5xxx 2-core',0
	   db $DB,'Xeon 5xxx 4-core',0
	   db $DD,'Xeon 7xxx 2-core',0
	   db $DE,'Xeon 7xxx 4-core',0
	   db $DF,'Xeon 7xxx multi-core',0
	   db $E0,'Xeon 3400 multi-core',0
	   db $E4,'AMD Opteron 3000',0
	   db $E5,'AMD Sempron II',0
	   db $E6,'Embedded AMD Opteron 4-core',0
	   db $E7,'AMD Phenom 3-core',0
	   db $E8,'AMD Turion Ultra 2-core M',0
	   db $E9,'AMD Turion 2-core M',0
	   db $EA,'AMD Athlon 2-core',0
	   db $EB,'AMD Sempron SI',0
	   db $EC,'AMD Phenom II',0
	   db $ED,'AMD Athlon II',0
	   db $EE,'AMD Opteron 6-core',0
	   db $EF,'AMD Sempron M',0
	   db $FA,'i860',0
	   db $FB,'i960',0
	   db 0

type_proc  db 1,'Other',0
	   db 2,'Unknown',0
	   db 3,'Central',0
	   db 4,'Math',0
	   db 5,'DSP',0
	   db 6,'Video',0
	   db 0

proc_status db 0,'Unknown',0
	    db 1,'CPU enabled',0
	    db 2,'CPU disabled by User',0
	    db 3,'CPU disabled by BIOS',0
	    db 4,'CPU is idle',0
	    db 7,'Other',0
	    db 0

mem_array_loc db 1,'Other',0
	      db 2,'Unknown',0
	      db 3,'Motherboard',0
	      db 4,'ISA card',0
	      db 5,'EISA card',0
	      db 6,'PCI card',0
	      db 7,'MCA card',0
	      db 8,'PCMCIA card',0
	      db 9,'Proprietary card',0
	      db $0A,'NuBus',0
	      db $A0,'PC-98/C20 card',0
	      db $A1,'PC-98/C24 card',0
	      db $A2,'PC-98/E card',0
	      db $A3,'PC-98/local bus card',0
	      db 0

mem_array_use db 1,'Other',0
	      db 2,'Unknown',0
	      db 3,'System',0
	      db 4,'Video',0
	      db 5,'Flash',0
	      db 6,'Non-volatile RAM',0
	      db 7,'Cache',0
	      db 0

mem_device_form db 1,'Other',0
		db 2,'Unknown',0
		db 3,'SIMM',0
		db 4,'SIP',0
		db 5,'Chip',0
		db 6,'DIP',0
		db 7,'ZIP',0
		db 8,'Proprietary card',0
		db 9,'DIMM',0
		db $0A,'TSOP',0
		db $0B,'Row of chips',0
		db $0C,'RIIM',0
		db $0D,'SODIMM',0
		db $0E,'SRIMM',0
		db $0F,'FB-DIMM',0
		db 0

mem_device_type db 1,'Other',0
		db 2,'Unknown',0
		db 3,'DRAM',0
		db 4,'EDRAM',0
		db 5,'VRAM',0
		db 6,'SRAM',0
		db 7,'RAM',0
		db 8,'ROM',0
		db 9,'FLASH',0
		db 10,'EEPROM',0
		db 11,'FEPROM',0
		db 12,'EPROM',0
		db 13,'CDRAM',0
		db 14,'3DRAM',0
		db 15,'SDRAM',0
		db 16,'SGRAM',0
		db 17,'RDRAM',0
		db 18,'DDR',0
		db 19,'DDR2',0
		db 20,'DDR2 FB-DIMM',0
		db 24,'DDR3',0
		db 25,'FBD2',0
		db 26,'DDR4',0
		db 27,'LPDDR',0
		db 28,'LPDDR2',0
		db 29,'LPDDR3',0
		db 30,'LPDDR4',0
		db 0

mem_device_detail db 1,'Other',0
		  db 2,'Unknown',0
		  db 3,'fast-paged',0
		  db 4,'static_column',0
		  db 5,'pseudo-static',0
		  db 6,'RAMBUS',0
		  db 7,'synchronous',0
		  db 8,'CMOS',0
		  db 9,'EDO',0
		  db 10,'Window_DRAM',0
		  db 11,'Cache_DRAM',0
		  db 12,'non-volatile',0
		  db 13,'buffered',0
		  db 14,'unbuffered',0
		  db 15,'LRDIMM',0
		  db 0

onboard_device	db 1,'Other',0
		db 2,'Unknown',0
		db 3,'Video',0
		db 4,'SCSI_controller',0
		db 5,'Ethernet',0
		db 6,'Token_Ring',0
		db 7,'Sound',0
		db 8,'PATA_controller',0
		db 9,'SATA_controller',0
		db 10,'SAS_controller',0
		db 0
