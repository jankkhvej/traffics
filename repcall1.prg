*******************************
* funcftion: Rep_Call1
* notes:
*
function Rep_Call1
* parapara = 0 - manual report
*          = 1 - single call, must process printed
*          = 2 - after that, will be called Rep_Call2, must process printed
parameters parapara
private STRING, OldRec, OldArea, OldColor
private _DATE_F, _DATE_L, _PAGE, _TIME_F, _TIME_L
private _PBX_I, _PBX_O, _GSTN_N, _DATE, _TIME, _DURATION, _CALL_NUM, _LOCATION, _COST1MIN, _COSTALL
* _all_ - за один внутр номер:
* Итого по XXX  hhhh:mm:ss,99999999999.99
private _all_TIME, _all_COST
* _vse_ - всего по атс:
* Итого  hhhh:mm:ss,99999999999.99
private _vse_TIME, _vse_COST, lKeys, _ext

	StatusLine('Prepare to make report...')
	WriteLog('& RepCall1 called...')
   OldRec = RecNo()
   OldArea = DBf()
   OldColor = setcolor('W+/BG,W+/N')

	string = MakeFileName(1)
	if parapara = 0
		WriteLog('& ...in manual mode')
		_ext = SubStr(string, At('.',string))
		string = SubStr(string, 1, At('.',string)-1)
* ---------- Ручной вызов
*    2═════════3═════════4═════════5═════════6═
*    012345678901234567890123456789012345678901
*  7 █Printing█F10█report██████████████████████
*  8 ▌                                        ▐
*  9 ▌ Please, specify file name for printout ▐
* 10 ▌                                        ▐
* 11 ▌              XXXXXXXX.PRN              ▐
* 12 ▌                                        ▐
* 13 ▌       ESC cancels  Enter accepts       ▐
* 14 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
*    012345678901234567890123456789012345678901
*    2═════════3═════════4═════════5═════════6═
*
		WriteLog('& ...prompt user for input. WARNING! data may be lost')
		window(Row(), Col(), 7, 20, 14, 61, 8, '███▐▀▀▀▌ ')
		@  9, 22 say 'Please, specify file name for printout'
		@ 11, 43 say _ext
		@ 13, 32 say 'cancels        accepts'
		setcolor('R+/BG')
		@ 13, 28 say 'ESC'
		@ 13, 41 say 'Enter'
		setcolor('N/W*')
		@ 7, 21 say 'Printing F10 report'
		lKeys = .t.
	   do while lKeys
			Tone(432, 1)
			@ 11, 35 get string picture '@K@!XXXXXXXX' valid ValidFile(string)
			set cursor on
			read
			set cursor off
			lKeys = (LastKey()#13) .and. (LastKey()#27)
	   enddo
		window()
		if lastkey() # 13
			WriteLog('& ...ESC pressed, exiting')
			return ''
		endif
	endif
	string = string + _ext
	set printer to &string
	WriteLog('& ...printer redirected to ' + string)

* Отобрать все, которые printed = .F.
	select TRAFFICS
	set filter to
	go top
	locate all for PRINTED = .F.
	if Found()
		_DATE_F = DATE
		_TIME_F = TIME
	else
		if parapara = 0
			err_message('No new records in database',;
		 		'There all was printed',;
		 		'Better check Your archives! ;)')
		endif
		WriteLog('& ...no new records, exiting')
		return ''
	endif

	WriteLog('& ...Creating _TARIF_.DBF')
	StatusLine('Creating temporary report database...')
* Создадим временную базу...
   DB_CREATE('_TARIF_',;
               'PBX_I'   , 'C',  3, 0,;
               'PBX_O'   , 'C',  3, 0,;
               'GSTN_N'  , 'C',  7, 0,;
               'DATE'    , 'D',  0, 0,;
               'TIME'    , 'C',  8, 0,;
               'DURATION', 'C',  8, 0,;
               'CALL_NUM', 'C', 18, 0,;
               'LOCATION', 'C', 26, 0,;
               'COST1MIN', 'N',  8, 2)

	select 0
	use _TARIF_
   index on (PBX_I+PBX_O+DtoC(DATE)) to _TARIF_
   use
   use _TARIF_ index _TARIF_
	WriteLog('& ...Ok')

	WriteLog('& ...Making report database')
	select TRAFFICS
	go top
	locate all for PRINTED = .F.
	do while Found()
		StatusLine('Prepare report database...')
		if .not. GOD_MODE
			replace PRINTED with .T.
		endif
	   _DURATION  	= DURATION
		_PBX_O     	= CO_LINE
	   _CALL_NUM  	= CALL_NUM
		if Ret_Need(_PBX_O) .and. (Ret_Sec(_DURATION) > Ret_MinSec(_PBX_O)) ;
			.and. (Len(AllTrim(_CALL_NUM)) > _s_LOCLEN)
		   _PBX_I     	= STN_NUM
		   _GSTN_N    	= Ret_GSTN(_PBX_O)
		   _DATE      	= DATE
		   _TIME      	= TIME
		   _CALL_NUM  	= CALL_NUM
		   _LOCATION  	= iif(CLASS = 0,'-Local-',Ret_LOC(_CALL_NUM))
		   _COST1MIN  	= Ret_COST(_CALL_NUM)
	      _DATE_L     = DATE
	      _TIME_L     = TIME

			select _TARIF_
			append blank
			replace	PBX_I			with _PBX_I,;
	               PBX_O       with _PBX_O,;
	               GSTN_N      with _GSTN_N,;
	               DATE        with _DATE,;
	               TIME        with _TIME,;
	               DURATION    with _DURATION,;
	               CALL_NUM    with _CALL_NUM,;
	               LOCATION    with _LOCATION,;
	               COST1MIN    with _COST1MIN
			select TRAFFICS
		endif
		continue
		* Не забыть считать данные из порта
		if .not. GOD_MODE
			* Читать данные из порта
	   	GET_DATA()
		endif
	enddo
	WriteLog('& ...Ok')

* Если после этого вырубить питание,
* то пропадет вся информация.
* Но можно будет поменять в базе printed снова

* Теперь будем печатать из врем. базы
	WriteLog('& ...Printing report database')

	Set Device to PRINTER
	SetPrc(0, 0)
	_PAGE = 1
	Set Device to SCREEN

	select _TARIF_
	go top
   _all_TIME = 0
   _all_COST = 0
   _vse_TIME = 0
   _vse_COST = 0
   _PBX_I = PBX_I
   _PBX_O = PBX_O

	do while .not. Eof()
		StatusLine('Printing report database...')
		if PRow() = 0
			* Заголовок
			*   Тарификационная ведомость по xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx за период с dd/mm/yy hh:mm:ss по dd/mm/yy hh:mm:ss
			* страница 999
			* --------------------------------------------------------------------------------------------------------------------------------
			* Внутр|Внеш|Ном. ГТС|    Дата    |  Время   | Длительн |  Набранный номер   | Город, страна              |Цена 1 мин| Цена
			* --------------------------------------------------------------------------------------------------------------------------------
			string = 'Тарификационная ведомость по ' + _s_ORGAN + ' за период с ' +;
                  DtoC(_DATE_F) + ' '+ _TIME_F + ' по ' + DtoC(_DATE_L) + ' '+ _TIME_L
			Set Device to PRINTER
			@ PRow()+1, Center(128, STRING) say String
			if _s_PAGE > 0
				@ PRow()+1, 0 say 'страница ' + Str(_PAGE)
			endif
			@ PRow()+1, 0 say Replicate('-', 128)
			@ PRow()+1, 0 say 'Внутр|Внеш|Ном. ГТС|   Дата   |  Время   | Длительн |  Набранный номер   | Город, страна              |Цена 1 мин| Цена'
			@ PRow()+1, 0 say Replicate('-', 128)
			Set Device to SCREEN
		endif

      _PBX_I = PBX_I
      _PBX_O = PBX_O


* XXX | xxx xXXXXXX | dd/mm/yyyy | hh:mm:ss | hh:mm:ss | xxxxxxxxxxxxxxxxxx | Лихтенштейн, Сам-Глав Бург | 99999.99 | 9999999.99
      _COSTALL = Round( Ret_Sec(DURATION) * (COST1MIN / 60), 2)
      string = PBX_I+' | '+PBX_O+' '+GSTN_N+' | '+DtoC(DATE)+' | '+TIME+' | '+;
            DURATION+' | '+CALL_NUM+' | '+LOCATION+' | '+iif(COST1MIN = 0, Space(8), Transform(COST1MIN,'99999.99'))+' | '+;
            iif(_COSTALL = 0, Space(10), Transform(_COSTALL, '9999999.99'))
		Set Device to PRINTER
		@ PRow() + 1, 1 say string
		Set Device to SCREEN
		_all_TIME = _all_TIME + Ret_Sec(DURATION)
      _all_COST = _all_COST + _COSTALL
      _vse_TIME = _vse_TIME + Ret_Sec(DURATION)
      _vse_COST = _vse_COST + _COSTALL

		skip

      if _PBX_I # PBX_I
* Итого по XXX                             hhhh:mm:ss                                                            99999999999.99
			Set Device to PRINTER
         string = 'Итого по '+_PBX_I
         @ PRow() + 1, 0 say string
         string = Ret_hhmmss(_all_TIME)
         @ PRow(), 53-Len(string) say string
         string = Alltrim(Transform(_all_COST, '99999999999.99'))
         @ PRow(), 127-Len(string) say string
         _all_TIME = 0
         _all_COST = 0
         @ PRow() + 1, 0 say ''
			Set Device to SCREEN
      endif

      if (PRow() > _s_PAGE) .and. _s_PAGE # 0
			EJECT
			_PAGE = _PAGE + 1
		endif

		* Не забыть считать данные из порта
		if .not. GOD_MODE
			* Читать данные из порта
	   	GET_DATA()
		endif
   enddo
* Итого по АТС                            hhhhh:mm:ss                                                          9999999999999.99
	Set Device to PRINTER
   string = 'Итого по АТС'
   @ PRow() + 1, 0 say string
   string = Ret_hhmmss(_vse_TIME)
   @ PRow(), 53-Len(string) say string
   string = Alltrim(Transform(_vse_COST, '9999999999999.99'))
   @ PRow(), 127-Len(string) say string
   string = ''
   @ PRow() + 2, 0 say string

   Set Device to SCREEN
	WriteLog('& ...Ok')

* Удалим временную базу...

	WriteLog('& ...Closing _TARIF_.DBF')
	StatusLine('Deleting temporary report database...')
	select _TARIF_
	use
	WriteLog('& ...Ok')
	if .not. GOD_MODE
		WriteLog('& ...Deleting _TARIF_.DBF')
		Erase _TARIF_.DBF
		Erase _TARIF_.NTX
		WriteLog('& ...Ok')
	endif

   select &OldArea
	go OldRec
   setcolor(OldColor)
	WriteLog('& ...Ok. RepCall1 done')
return ''
*******************************
