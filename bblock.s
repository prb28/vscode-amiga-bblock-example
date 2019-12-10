;------------------------------
; Example of boot bloc code
;------------------------------

; Documentation from http://lclevy.free.fr/adflib/adf_info.html
; -------------------------------------------------------------------------------
; offset	size    number	name		meaning
; -------------------------------------------------------------------------------
; 0/0x00  char    4       DiskType	'D''O''S' + flags
;                                         flags = 3 least signifiant bits
;                                                set         clr
; 					         0    FFS         OFS
;                                           1    INTL ONLY   NO_INTL ONLY
;                                           2    DIRC&INTL   NO_DIRC&INTL
; 4/0x04  ulong   1       Chksum          special block checksum
; 8/0x08  ulong   1       Rootblock       Value is 880 for DD and HD 
; 					 (yes, the 880 value is strange for HD)
; 12/0x0c char    *       Bootblock code  (see 5.2 'Bootable disk' for more info)
;                                         The size for a floppy disk is 1012,
;                                         for a harddisk it is
;                                         (DosEnvVec->Bootblocks * BSIZE) - 12
; -------------------------------------------------------------------------------
; The DiskType flag informs of the disk format.
;     OFS = Old/Original File System, the first one. (AmigaDOS 1.2)
;     FFS = Fast File System (AmigaDOS 2.04)
;     INTL = International characters Mode (see section 5.4).
;     DIRC = stands for Directory Cache Mode. This mode speeds up directory listing, but uses more disk space (see section 4.7). 


; Boot definition
boot:
;OxOO
  dc.l      "DOS"<<8         ; DiskType
;OxO4
  dc.l      0                ; Checksum will be added by the build 
;OxO8
  dc.l      880              ; Rootblock

;OxOc
  lea       dos(pc),a1       ;name
  jsr       -96(a6)          ;FindResident()
  tst.l     d0
  beq.b     error2           ;not found
  move.l    d0,a0
  move.l    22(a0),a0        ;DosInit sub
  moveq     #0,d0
  rts
error2:
  moveq     #-1,d0
  rts

dos:  
  dc.b      "dos.library"


;   * The Bootblock becomes :
; 0/0x00	long	1	ID		'D''O''S' + flags
; 4/0x04	long	1	checksum	computed
; 8/0x08	long	1	rootblock ?	880
; 12/0x0c	byte	81	bootcode	AmigaDOS 3.0 version
; 	values			disassembled
; 	--------------+---------------------
; 	43FA003E		lea	exp(pc),a1	;Lib name
; 	7025			moveq	#37,d0		;Lib version
; 	4EAEFDD8		jsr	-552(a6)	;OpenLibrary()
; 	4A80			tst.l	d0		;error == 0
; 	670C			beq.b	error1
; 	2240			move.l	d0,a1		;lib pointer
; 	08E90006 0022		bset	#6,34(a1)	;(*)
; 	4EAEFE62		jsr	-414(a6)	;CloseLibrary()
; 	43FA0018	error1:	lea	dos(PC),a1	;name
; 	4EAEFFA0		jsr	-96(a6)		;FindResident()
; 	4A80			tst.l	d0
; 	670A			beq.b	error2		;not found
; 	2040			move.l	d0,a0
; 	20680016		move.l	22(a0),a0	;DosInit sub
; 	7000			moveq	#0,d0
; 	4E75			rts
; 	70FF		error2:	moveq	#-1,d0
; 	4E75			rts
; 	646F732E 6C696272 617279
; 			dos:	"dos.library"
; 	00						;padding byte
; 	65787061 6E73696F 6E2E6C69 62726172 79
; 			exp:	"expansion.library"
; 93/0x5d	byte	931	full of zeros
