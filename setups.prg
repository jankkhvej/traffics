function SETUP
   private FOR_RET, OldColor, X_BYTE
   private _s__BAUD, _s__PARITY, _s__STOPBIT, _s__DATALEN, lKeys, hFile

	WriteLog('& Entering setup...')
   FOR_RET = .F.
   OldColor = setcolor('GR+/BG, W+/N')

*     ÍÍÍ1ÍÍÍÍÍÍÍÍÍ2ÍÍÍÍÍÍÍÍÍ3ÍÍÍÍÍÍÍÍÍ4ÍÍÍÍÍÍÍÍÍ5ÍÍÍÍÍÍÍÍÍ6ÍÍÍÍÍÍÍÍÍ7ÍÍÍ
*     7890123456789012345678901234567890123456789012345678901234567890123
*   1 ÛÛSystemÛsetupÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ  1
*   2 ÝGeneral configurationÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿Þ  2
*   3 Ý³Company name:  xxxxxx_s_ORGANxxxxxxxxxxxxxxxxxxxxxxxxxx        ³Þ  3
*   4 Ý³Country code:  XXX   Region code:  XXXXXXXXXX                  ³Þ  4
*   5 Ý³Max ingored length: X (useful for skip local calls processing) ³Þ  5
*   6 ÝÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÞ  6
*   7 ÝCommunication setupÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿Þ  7
*   8 Ý³Port:      COM2  (COM1..COM4)                                  ³Þ  8
*   9 Ý³Baud:      9600  (300, 600, 1200, 2400, 4800, 9600)            ³Þ  9
*  10 Ý³Data Bits: 8     (5, 6, 7, 8)                                  ³Þ 10
*  11 Ý³Parity:    NONE  (NONE, ODD, EVEN)                             ³Þ 11
*  12 Ý³Stop Bits: 1     (1, 2)                                        ³Þ 12
*  13 ÝÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÞ 13
*  14 ÝPrinting configurationÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿Þ 14
*  15 Ý³AutoPrint:  Y   (Y enables AutoPrint at midnight, N disables)  ³Þ 15
*  16 Ý³Spooling:   Y   (Y enables usage of PRINT.COM, N disables)     ³Þ 16
*  17 Ý³Lines/page: 999 (0 or > 19; if 0, prints w/o pagebreaks)       ³Þ 17
*  18 Ý³Old limit:  999 days (older than limit records will be deleted)³Þ 18
*  19 Ý³Include local         Y (Y/N)                                  ³Þ 19
*  20 Ý³        intercities   Y (Y/N)                                  ³Þ 20
*  21 Ý³        international Y (Y/N)                                  ³Þ 21
*  22 ÝÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÞ 22
*  23 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 23
*     7890123456789012345678901234567890123456789012345678901234567890123
*     ÍÍÍ1ÍÍÍÍÍÍÍÍÍ2ÍÍÍÍÍÍÍÍÍ3ÍÍÍÍÍÍÍÍÍ4ÍÍÍÍÍÍÍÍÍ5ÍÍÍÍÍÍÍÍÍ6ÍÍÍÍÍÍÍÍÍ7ÍÍÍ
   WINDOW(Row(), Col(), 1, 7, 23, 73, 7, 'ÛÛÛÞßßßÝ ')

	@ 2,8,6,72 box 'ÚÄ¿³ÙÄÀ³ '
	@ 7,8,13,72 box 'ÚÄ¿³ÙÄÀ³ '
	@ 14,8,22,72 box 'ÚÄ¿³ÙÄÀ³ '
	@ 2, 8 say 'General configuration'
	@ 7, 8 say 'Communication setup'
	@ 14, 8 say 'Printing configuration'
	setcolor('N/BG')
	@ 3, 9 say 'Company name:'
	@ 4, 9 say 'Country code:        Region code:'
	@ 5, 9 say 'Max ingored length:   (useful for skip local calls processing)'
	@ 8, 9 say 'Port:            (COM1..COM4)'
	@ 9, 9 say 'Baud:            (300, 600, 1200, 2400, 4800, 9600)'
	@ 10, 9 say 'Data Bits:       (5, 6, 7, 8)'
	@ 11, 9 say 'Parity:          (NONE, ODD, EVEN)'
	@ 12, 9 say 'Stop Bits:       (1, 2)'
	@ 15, 9 say 'AutoPrint:      (Y enables AutoPrint at midnight, N disables)'
   @ 16, 9 say 'Spooling:       (Y enables usage of PRINT.COM, N disables)'
	@ 17, 9 say 'Lines/page:     (0 or > 19; if 0, prints w/o pagebreaks)'
	@ 18, 9 say 'Old limit:      days (older than limit records will be deleted)'
	@ 19, 9 say 'Include local           (Y/N)'
	@ 20, 17 say 'intercities     (Y/N)'
	@ 21, 17 say 'international Y (Y/N)'
	setcolor('N/GR*')
	@ 1, 9 say 'System setup'

   if .not. file('TRAFFICS.INI')
		WriteLog('& ...Creating new TRAFFICS.INI')
      _s_PORT      = space(4)
      _s_BAUD      = space(4)
      _s_PARITY    = space(4)
      _s_STOPBIT   = space(1)
      _s_DATALEN   = space(1)
      _s_AUTO      = .T.
      _s_SPOOL     = .F.
      _s_ILOC      = .F.
      _s_ICIT      = .F.
      _s_ISTA      = .F.
      _s_PAGE      = 0
      _s_NPORT     = 0
      _s_INIT      = 0
      _s_OLD_LIMIT = 0
      _s_ORGAN     = space(40)
      _s_COUNTRY   = space(3)
      _s_REGION    = space(10)
      _s_LOCLEN    = 0
   else
       restore from TRAFFICS.INI additive
   endif
   _s_ORGAN     = _s_ORGAN + space(40-Len(_s_ORGAN))
   _s_COUNTRY   = _s_COUNTRY + space(3-Len(_s_COUNTRY))
   _s_REGION    = _s_REGION + space(10-Len(_s_REGION))

	lKeys = .t.
	do while lKeys
		@ 3, 24 get _s_ORGAN picture '@S38'
		@ 4, 24 get _s_COUNTRY picture '###'
		@ 4, 44 get _s_REGION picture '##########'
		@ 5, 29 get _s_LOCLEN picture '#' valid (_s_LOCLEN >= 0)

		@ 8, 20 get _s_PORT picture '!!!!' valid ((_s_PORT='COM1') .or.;
                                                 (_s_PORT='COM2') .or.;
                                                 (_s_PORT='COM3') .or.;
                                                 (_s_PORT='COM4'))

      @  9, 20 get _s_BAUD picture '####' valid ((val(_s_BAUD)=300) .or.;
                                                 (val(_s_BAUD)=600) .or.;
                                                 (val(_s_BAUD)=1200) .or.;
                                                 (val(_s_BAUD)=2400) .or.;
                                                 (val(_s_BAUD)=4800) .or.;
                                                 (val(_s_BAUD)=9600))

      @ 10, 20 get _s_DATALEN picture '#' valid ((_s_DATALEN='5') .or. ;
                                                 (_s_DATALEN='6') .or. ;
                                                 (_s_DATALEN='7') .or. ;
                                                 (_s_DATALEN='8'))

      @ 11, 20 get _s_PARITY picture '!!!!' valid ((alltrim(_s_PARITY)='ODD') .or.;
                                                       (_s_PARITY='NONE') .or.;
                                                       (_s_PARITY='EVEN'))

      @ 12, 20 get _s_STOPBIT picture '#' valid ((_s_STOPBIT='1').or.(_s_STOPBIT='2'))

		@ 15, 21 get _s_AUTO picture 'Y'

		@ 16, 21 get _s_SPOOL picture 'Y'

      @ 17, 21 get _s_PAGE picture '###' valid ((_s_PAGE = 0).or.(_s_PAGE > 19))

      @ 18, 21 get _s_OLD_LIMIT picture '###' valid (_s_OLD_LIMIT >= 0)

		@ 19, 31 get _s_ILOC picture 'Y'
		@ 20, 31 get _s_ICIT picture 'Y'
		@ 21, 31 get _s_ISTA picture 'Y'

      set cursor on
      read
      set cursor off
		lKeys = (LastKey()#13) .and. (LastKey()#27)
   enddo

   do case
      case _s_PORT  = 'COM1'
           _s_NPORT = 0
      case _s_PORT  = 'COM2'
           _s_NPORT = 1
      case _s_PORT  = 'COM3'
           _s_NPORT = 2
      case _s_PORT  = 'COM4'
           _s_NPORT = 3
   endcase

   do case
      case _s_BAUD  = '300'
           _s__BAUD = 64
      case _s_BAUD  = '600'
           _s__BAUD = 64 + 32
      case _s_BAUD  = '1200'
           _s__BAUD = 128
      case _s_BAUD  = '2400'
           _s__BAUD = 128 + 32
      case _s_BAUD  = '4800'
           _s__BAUD = 128 + 64
      case _s_BAUD  = '9600'
           _s__BAUD = 128 + 64 + 32
   endcase

   do case
      case _s_PARITY  = 'NONE'
           _s__PARITY = 0
      case _s_PARITY  = 'ODD'
           _s__PARITY = 8
      case _s_PARITY  = 'EVEN'
           _s__PARITY = 16 + 8
   endcase

   do case
      case _s_STOPBIT  = '1'
           _s__STOPBIT =  0
      case _s_STOPBIT  = '2'
           _s__STOPBIT =  4
   endcase

   do case
      case _s_DATALEN  = '5'
           _s__DATALEN =  0
      case _s_DATALEN  = '6'
           _s__DATALEN =  1
      case _s_DATALEN  = '7'
           _s__DATALEN =  2
      case _s_DATALEN  = '8'
           _s__DATALEN = 2 + 1
   endcase

   _s_INIT = _s__BAUD + _s__PARITY + _s__STOPBIT + _s__DATALEN
   _s_ORGAN = AllTrim(_s_ORGAN)
   _s_COUNTRY = AllTrim(_s_COUNTRY)
   _s_REGION = AllTrim(_s_REGION)

   if LastKey()=13
		WriteLog('& ...Saving setup')
      save to TRAFFICS.INI all like _s_*

		WriteLog('& ...Creating TRAFFICS.BAT')
		hFile = FCreate('TRAFFICS.BAT', 0)
		string = '@echo off' + chr(13) + chr(10) +;
				iif(_s_SPOOL, 'rem Install Your favorite PRINT-compatible spooler here' + chr(13) + chr(10) +;
               'PRINT /D:LPT1 /B:16384  ' + chr(13) + chr(10), '') +;
				'rem And here Your favorite FOSSIL driver' + chr(13) + chr(10) +;
				'BNU /R:8192' + chr(13) + chr(10) +;
            'TRAFFICS.EXE' + chr(13) + chr(10) +;
            'BNU /U' + chr(13) + chr(10)
      FWrite(hFile, string)
		FClose(hFile)
      tone(500, 5)
      FOR_RET = .T.
   endif

   clear typeahead

   WINDOW()
   setcolor(OldColor)
	WriteLog('& ...Ok. Setup done')
return FOR_RET
