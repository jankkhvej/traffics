public          RESET_FOSS      ; �㭪�� ��� �ࠩ��� FOSSIL � �஢�ન ��� ������ � �����
public          INIT_FOSS       ; �㭪�� ���樠����樨 ���� � ��⠭���� ��ࠬ��஢ ����
public          READ_WAIT       ; �㭪�� �⥭�� ���� � ���������
public          DATA_READY      ; �㭪�� ��।������ ������ � ���� ������ ����㯨��� � COM ����
public          SET_BLNK        ; �㭪�� ����祭�� �������
public          SET_INTS        ; �㭪�� ����祭�� ��⥭ᨢ����
public          TSK_SWTCH       ; �㭪�� �⤠� ���⪠ ⠩�᫠��
public          DOS_VERSN       ; �㭪�� ��⥪樨 ����樮���
public		PR_CHECK	; �㭪�� �஢�ન ��⠭���� PRINT.COM
public		PR_SUBMIT	; �㭪�� ���⠭���� 䠩�� � ��।� PRINT.COM
public		PR_CANCEL	; �㭪�� ���⪨ �ᥩ ��।� PRINT.COM

extrn           __PARNI:far, __PARC:far, __RETL:far, __RETNI:far, __RETC:far

;Format of PRINT submit packet:
;Offset  Size    Description     (Table 1880)
; 00h    BYTE    level (must be 00h)
; 01h    DWORD   pointer to ASCIZ filename (no wildcards)
PR_PACKET	struc
		Level	db	0
		pptr	dd	?
PR_PACKET	ends


_PROG           segment 'CODE'
                assume  cs:_PROG

;*****************************************************************************
; �㭪�� �ந������ ��� �ࠩ��� FOSSIL � �஢���� ��� ����稥 � �����
; �맮�:        RESET_FOSS(����� ����)
; �����頥�:   TRUE - �᫨ �ࠩ��� ����㦥�, FALSE - �᫨ �ࠩ��� �� ����㦥�
;*****************************************************************************
RESET_FOSS      proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************

                ; ����祭�� ��ࢮ�� ��ࠬ��� No COM ����
                mov     ax, 1
                push    ax
                call	__PARNI
                add     sp, 2

                mov     word ptr cs:Port, ax
                mov     dx, ax
                mov     ah, 04h
                int     14h
                xor     bx, bx
                cmp     ax, 1954h
                jnz     Exit_RESET_FOSS
                mov     bx, 1
        Exit_RESET_FOSS:
                push    bx
                call    __RETL
                add     sp, 2

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
RESET_FOSS      endp
;*****************************************************************************


;*****************************************************************************
; �㭪�� ���樠����樨 ���� � ��⠭���� ��ࠬ��஢ ����
; �맮�:        INIT_FOSS(INIT ����)
; �����頥� �ᥣ�� TRUE
;*****************************************************************************
INIT_FOSS       proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************

                ; ����祭�� ��ࢮ�� ��ࠬ��� INIT ����
                mov     ax, 1
                push    ax
                call	__PARNI
                add     sp, 2

                mov     dx, word ptr cs:Port
                mov     ah, 00h
                int     14h

                mov     ax, 1
                push    ax
                call    __RETL
                add     sp, 2

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
INIT_FOSS       endp
;*****************************************************************************

;*****************************************************************************
; �㭪�� �⥭�� ���� � ���������
; �맮�:        READ_WAIT()
; �����頥�:   ���⠭� ���� (ASCII ���)
;*****************************************************************************
READ_WAIT       proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************

                mov     ah, 02h
                mov     dx, word ptr cs:Port
                int     14h
                xor     ah, ah
                push    ax
                call    __RETNI
                add     sp, 2

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
READ_WAIT       endp
;*****************************************************************************

;*****************************************************************************
; �㭪�� ��।������ ������ � ���� ������ ����㯨��� � COM ����
; �맮�:        DATA_READY()
; �����頥�:   TRUE - �᫨ ����� ����㯨��, FALSE - �᫨ ���� ����
;*****************************************************************************
DATA_READY      proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************

;                mov     ah, 0Ch
;                mov     dx, word ptr cs:Port
;                int     14h
;                xor     bx, bx
;                cmp     ax, 0FFFFh
		mov	ah, 03h
		mov     dx, word ptr cs:Port
		int	14h
		xor	bx, bx
		test	ah, 1
                jz      BUFFER_EMPTY
                mov     bx, 1
BUFFER_EMPTY:
                push    bx
                call    __RETL
                add     sp, 2

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
DATA_READY      endp
;*****************************************************************************

;*****************************************************************************
; �맮�:        Set_Blnk()
; �����頥�:   void
;*****************************************************************************
SET_BLNK        proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
		mov	bl, 1
		mov     ax, 1003h
		int	10h

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
SET_BLNK        endp
;*****************************************************************************

;*****************************************************************************
; �맮�:        Set_Ints()
; �����頥�:   void
;*****************************************************************************
SET_INTS        proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
		mov	bl, 0
		mov     ax, 1003h
		int	10h

                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
SET_INTS        endp
;*****************************************************************************

PR_CHECK	proc	far	; �㭪�� �஢�ન ��⠭���� PRINT.COM
                push    bp	; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
;--------c-2F0100-----------------------------
;INT 2F - DOS 3.0+ PRINT - INSTALLATION CHECK
;        AX = 0100h
;Return: AL = status
;            00h not installed
;            01h not installed, but not OK to install
;            FFh installed
;                AH = 00h (Novell DOS 7)
;
		mov	ax, 0100h
		int	2Fh
		xor	bx, bx		; assume false
		cmp	al, 0FFh
		jne	@False
		mov	bx, 1
@False:
		push	bx
		call	__RetL
		add	sp, 2
                ; *****************************************
                pop     di	; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
PR_CHECK        endp


PR_SUBMIT	proc	far	; �㭪�� ���⠭���� 䠩�� � ��।� PRINT.COM
                push    bp	; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
;INT 2F - DOS 3.0+ PRINT - SUBMIT FILE FOR PRINTING
;        AX = 0101h
;        DS:DX -> submit packet (see #1880)
;Return: CF clear if successful
;            AL = status
;                01h added to queue
;                9Eh now printing
;        CF set on error
;            AX = error code (see #1881,#0980 at INT 21/AH=59h)
		mov	ax, 1
		push	ax
		call	__ParC
		add	sp, 2
		; dx:ax -> string
		mov	word ptr [MyPRPacket.pptr], ax
		mov	word ptr [MyPRPacket.pptr+2], dx
		mov	dx, cs
		mov	ds, dx
		mov	dx, offset MyPRPacket
		mov	ax, 0101h
		int	2Fh
                ; *****************************************
                pop     di	; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
PR_SUBMIT	endp


PR_CANCEL	proc	far	; �㭪�� ���⪨ �ᥩ ��।� PRINT.COM
                push    bp	; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
;--------c-2F0103-----------------------------
;INT 2F - DOS 3.0+ PRINT - CANCEL ALL FILES IN PRINT QUEUE
;        AX = 0103h
;Return: CF clear if successful
;        CF set on error
;            AX = error code (see #1881)
		mov	ax, 0103h
		int	2Fh

                ; *****************************************
                pop     di	; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
PR_CANCEL	endp

;*****************************************************************************
; �㭪�� �⤠� ���⪠ ⠩�᫠�� ��쪥
; �맮�:        TSK_SWTCH()
;*****************************************************************************
TSK_SWTCH       proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************
ideal
		cmp	[OS_Type], 0		; DOS ?
  		je	_Fine
		cmp	[OS_Type], 1		; Windows ?
  		je	_Win_Slice
  		cmp	[OS_Type], 2		; OS/2 ?
  		je	_OS2_Slice
_DV_TV:
  		mov	Ax, 1000h
  		int	15h
  		jmp	_Fine
_Win_Slice:
; Currently I don't wont to release slices for F$#king Windoze!
  		;mov	Ax, 1680h
  		;int	2Fh
		jmp	_Fine
_OS2_Slice:
	        ; OS/2 correct! timeslice release.
    		MOV	DX, 0
    		MOV	AX, 100h
		HLT
    		DB	35H
    		DB	0CAH
_Fine:
masm
                ; *****************************************
                pop     di              ; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
TSK_SWTCH       endp
;*****************************************************************************

;*****************************************************************************
; �㭪�� ��⥪樨 ����樮���
; �맮�:        ver = DOS_VERSN()
;*****************************************************************************
DOS_VERSN       proc    far
                push    bp              ; Save registers
                mov     bp, sp
                push    ds
                push    es
                push    si
                push    di
                ; *****************************************

  		mov	OS_Vers, 0
  		mov	OS_Type, 0
		mov	AX, 3001h
  		int	21h

		; iz diz OS/2 VDM ?
		cmp	AL, 20
  		je	_OS2

		; iz diz under Windows ?
		mov	AX, 160Ah
  		int	2Fh

  		cmp	AX, 0
  		je	_Win

		; iz diz DesqView/TopView ?
		mov	AX, 1022h
  		mov	BX, 0000h
  		int	15h
  		cmp	BX, 0
  		jne	_DESQview

		; iz diz really TopView ?
		mov	AX, 2B01h
  		mov	CX, 4445h
  		mov	DX, 5351h
  		int	21h
  		cmp	AL, 0FFh
  		jne	_TopView
  		jmp	_Fin
_Win:
		Mov	OS_Type, 1
  		Mov	OS_Vers, BX
  		jmp	_Fin
_OS2:
  		Mov	OS_Type, 2
  		Mov	BH, AH
  		Xor	AH, AH
  		Mov	CL, 10
  		Div	CL
  		Mov	AH, BH
  		Xchg	AH, AL
  		Mov	OS_Vers, AX
  		jmp	_Fin
_DESQview:
  		mov	OS_Type, 3
  		jmp	_Fin
_TopView:
		mov	OS_Type, 4
_Fin:
		mov	dx, cs
		mov	bx, OS_Type
		shl	bx, 1
		mov	ax, [OS_TypeS][bx]
		push	dx
		push	ax
		call	__retc
		add	sp, 4                ; �������� 㪠��⥫� �⥪�

                ; *****************************************
                pop     di	; Restore registers
                pop     si
                pop     es
                pop     ds
                pop     bp
                ret
DOS_VERSN       endp
;*****************************************************************************


Port            dw      0       ; ����� �࠭���� ����� COM ����
MyPRPacket	pr_packet {}
; 1 - Windows, 2 - OS/2 VDM, 3 - DesqView, 4 - TopView
OS_Type		dw	0
OS_Vers		dw	0
OS_TypeS	dw	sOS_Type0, sOS_Type1, sOS_Type2, sOS_Type3, sOS_Type4
sOS_Type0	db	'DOS', 0
sOS_Type1	db	'Windows', 0
sOS_Type2	db	'OS/2', 0
sOS_Type3	db	'DESQview', 0
sOS_Type4	db	'TopView', 0
CopyLeft        db      0dh,0ah,0dh,0ah,'(c) Solik 1996-2000, solik@netdeeper.sumy.ua',0dh,0ah
		db	0dh,0ah
_PROG           ends
                end
