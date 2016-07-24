*******************************
* function: Rep_Call2
* notes:
*
function Rep_Call2
parameters parapara, _class, _date_f, _date_l
* parapara = 0 - manual report, ask for date, class, filename
*          = 1 - automatic
*          = 2 - automatic
* _class = 0 - local calls
*        = 1 - intercities calls
*        = 2 - interstates calls

private STRING, OldRec, OldArea, OldColor, pFile
private lKeys, _FPBX, _FEXT
private _ILOC, _ICIT, _ISTA, _ext


	WriteLog('& RepCall2 called...')
	StatusLine('Prepare to make report...')
   OldRec = RecNo()
   OldArea = DBf()
   OldColor = setcolor('W+/BG,W+/N')
	_ILOC = _s_ILOC
	_ICIT = _s_ICIT
	_ISTA = _s_ISTA

 	* сделаем имя файлка
	pFile = MakeFileName(2)

  	StatusLine('Prepare report database...')

	* Если мы вызваны автоматически, то передается долько два параметра,
	* или если кто-то забыл из передать... ;-)
	if PCount() < 3
		_DATE_F = _q_PRTDATE
		_DATE_L = _q_PRTDATE
	endif
	WriteLog('& ...Date_F = '+DtoC(_DATE_F))
	WriteLog('& ...Date_L = '+DtoC(_DATE_L))

	select TRAFFICS
	go top

	* А не вручную ли нас позвали ? =0
	if parapara = 0
		WriteLog('& ...in manual mode')
		_ext = SubStr(pFile, At('.',pFile))
		pFile = SubStr(pFile, 1, At('.',pFile)-1)
		_FPBX = '   '
		_FEXT = '   '
* ---------- Ручной вызов
*    2═════════3═════════4═════════5═════════6═
*    012345678901234567890123456789012345678901
*  6 █Printing█report██████████████████████████
*  7 ▌                                        ▐
*  8 ▌ File name for printout XXXXXXXX.PRN    ▐
*  9 ▌                                        ▐
* 10 ▌ Include: local         Y  (Y/N)        ▐
* 11 ▌  	intercities          N  (Y/N)        ▐
* 12 ▌  	international        Y  (Y/N)        ▐
* 13 ▌                                        ▐
* 14 ▌ Date:    from          dd/mm/yy        ▐
* 15 ▌          to            dd/mm/yy        ▐
* 16 ▌                                        ▐
* 17 ▌ PBX station number:    999 (empty-all) ▐
* 18 ▌ EXT port number:       999 (empty-all) ▐
* 19 ▌                                        ▐
* 20 ▌       ESC cancels  Enter accepts       ▐
* 21 ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
*    012345678901234567890123456789012345678901
*    2═════════3═════════4═════════5═════════6═
		window(Row(), Col(), 6, 20, 21, 61, 8, '███▐▀▀▀▌ ')
		@ 8, 22 say 'File name for printout         '+_ext
		@ 10, 22 say 'Include: local            (Y/N)'
		@ 11, 24 say 'intercities             (Y/N)'
		@ 12, 24 say 'international           (Y/N)'
		@ 14, 22 say 'Date:    from'
		@ 15, 31 say 'to'
		@ 17, 22 say 'PBX station number:        (empty-all)'
		@ 18, 22 say 'EXT port number:           (empty-all)'
		@ 20, 32 say 'cancels        accepts'
		setcolor('N/BG')
		@ 20, 28 say 'ESC'
		@ 20, 41 say 'Enter'
		setcolor('N/W*')
		@ 6, 21 say 'Printing report'
		lKeys = .t.
		WriteLog('& ...prompt user for input. WARNING! data may be lost')
		do while lKeys
			Tone(432, 1)
			@ 8, 45 get pFile picture '@K@!XXXXXXXX' valid ValidFile(pFile)
			@ 10, 45 get _ILOC picture 'Y'
			@ 11, 45 get _ICIT picture 'Y'
			@ 12, 45 get _ISTA picture 'Y'
			@ 14, 45 get _DATE_F
			@ 15, 45 get _DATE_L
			@ 17, 45 get _FPBX picture '999'
			@ 18, 45 get _FEXT picture '999'

			set cursor on
			read
			set cursor off
			lKeys = (LastKey()#13) .and. (LastKey()#27)
		enddo
		window()
		if LastKey() # 13
			WriteLog('& ...ESC pressed, exiting')
			return ''
		else
 * Мы тут вручную собираемся отпечатать рапорт...
			pFile = pFile + _ext
			set printer to &pFile
			WriteLog('& ...printer redirected to ' + pFile)

			if _ILOC

*				WriteLog('& ...Rep_Call2(3,0) recourse')
*				Rep_Call2(3,0, _date_f, _date_l, _FPBX, _FEXT)

				Prepare2(0, _date_f, _date_l, _FPBX, _FEXT)
				Print2(0, _date_f, _date_l, _FPBX, _FEXT)

			endif


			if _ICIT
*				WriteLog('& ...Rep_Call2(3,1) recourse')
*				Rep_Call2(3,1, _date_f, _date_l, _FPBX, _FEXT)

				Prepare2(1, _date_f, _date_l, _FPBX, _FEXT)
				Print2(1, _date_f, _date_l, _FPBX, _FEXT)

			endif

			if _ISTA
*				WriteLog('& ...Rep_Call2(3,2) recourse')
*				Rep_Call2(3,2, _date_f, _date_l, _FPBX, _FEXT)

				Prepare2(2, _date_f, _date_l, _FPBX, _FEXT)
				Print2(2, _date_f, _date_l, _FPBX, _FEXT)

			endif

			WriteLog('& ...Ok. Manual RepCall2 done')
		endif
	else
	* Сюда мы попадем, если нас звали автоматом...
		set printer to &pFile
		WriteLog('& ...printer redirected to ' + pFile)

	  	Prepare2(_class, _date_f, _date_l, _FPBX, _FEXT)
		Print2(_class, _date_f, _date_l, _FPBX, _FEXT)

	endif
	set printer to
	WriteLog('& ...printer file closed')
	if _s_SPOOL
		WriteLog('& Spooling file...')
		pr_submit(pFile)
		WriteLog('& ...Ok. File spooled.')
	endif

	select &OldArea
	go OldRec
   setcolor(OldColor)
	WriteLog('& ...Ok. RepCall2 done')
return ''
*******************************

*******************************
* function: Prepare2
* notes:		Делает выборку во временную базу
*           звонков с даты по дату одного класса
function Prepare2
parameters _class, _date_f, _date_l, _FPBX, _FEXT
* _class = 0 - local calls
*        = 1 - intercities calls
*        = 2 - interstates calls
* _Date_f, _Date_l - даты начала и конца выборки соотв.
*

private STRING, OldColor, _condit
private _PAGE, _DURATION, _CALL_NUM, _eof_
private _GSTN_N,	_FULL_N, _LOCATION, _COST1MIN, _DATE, _TIME

	WriteLog('& Prepare2 called...')

   OldColor = setcolor('W+/BG,W+/N')

	WriteLog('& ...Creating _TARIF1.DBF')
	StatusLine('Creating temporary database...')
* Создадим временную базу...
   DB_CREATE('_TARIF1',;
               'GSTN_N'  , 'C',  7, 0,;
               'PBX_N'   , 'C',  3, 0,;
					'FULL_N'  , 'C', 24, 0,;
               'LOCATION', 'C', 26, 0,;
               'COST1MIN', 'N',  8, 2,;
               'DATE'    , 'D',  0, 0,;
               'TIME'    , 'C',  8, 0,;
               'DURATION', 'C',  8, 0,;
               'CALL_NUM', 'C', 18, 0)

	select 0
	use _TARIF1
	StatusLine('Indexing temporary database...')
   index on (GSTN_N+FULL_N+DtoC(DATE)) to _TARIF1
	set index to _TARIF1
	WriteLog('& ...Ok')

	if PCount() < 4
		_FPBX = '   '
		_FEXT = '   '
	endif

	WriteLog('& ...Making report database')

	set softseek on
	select TRAFFICS
	go top
	seek _date_f
	_eof_ = (DATE > _date_l)

	do while .not. _eof_
		DrawSpin()
		StatusLine('Prepare report database...')

**************
		if (CLASS = _CLASS)

			_DURATION  	= DURATION
			_PBX_O     	= STN_NUM
			_CALL_NUM  	= CALL_NUM

			_condit = Ret_Need(CO_LINE) .and. (Ret_Sec(_DURATION) > Ret_MinSec(CO_LINE)) ;
				.and. (Len(AllTrim(_CALL_NUM)) > _s_LOCLEN)

			if .not.(Empty(_FPBX))
				_condit = (STN_NUM = _FPBX) .and. _condit
			endif
			if .not.(Empty(_FEXT))
				_condit = (CO_LINE = _FEXT) .and. _condit
			endif

			if _condit

				_GSTN_N   = Ret_GSTN(CO_LINE)
				_FULL_N   = Ret_FullNum(_CALL_NUM)
			   _LOCATION = iif(CLASS = 0,'-Local-',Ret_LOC(_CALL_NUM))
				_COST1MIN = Ret_Cost(_CALL_NUM)
				_DATE     = DATE
				_TIME     = TIME

				select _TARIF1
				append blank
				replace GSTN_N   with _GSTN_N,;
						  PBX_N    with _PBX_O,;
						  FULL_N   with _FULL_N,;
						  LOCATION with _LOCATION,;
						  COST1MIN with _COST1MIN,;
						  DATE     with _DATE,;
						  TIME     with _TIME,;
						  DURATION with _DURATION,;
						  CALL_NUM with _CALL_NUM
			endif
		endif

		* Не забыть считать данные из порта
		if .not. GOD_MODE
		   GET_DATA()
		endif

		select TRAFFICS
		skip
		_eof_ = (DATE > _date_l).or.Eof()

	enddo
	WriteLog('& ...Ok')

	select TRAFFICS
	set softseek off

   setcolor(OldColor)
	WriteLog('& ...Ok. Prepare2 done')
return ''
*******************************


*******************************
* function: Print2
* notes:		Делает печать из временной базы
*
function Print2
parameters _class, _date_f, _date_l, _FPBX, _FEXT

private STRING, OldColor
private _PAGE, _DURATION, _CALL_NUM
private _GSTN_N,	_FULL_N, _LOCATION, _COST1MIN, _DATE, _TIME
private _all_TIME, _all_COST, _ALL_NUM

	WriteLog('& Print2 called...')
   OldColor = setcolor('W+/BG,W+/N')

	SetPrc(0, 0)
	_PAGE = 1

	_GSTN_N = ''
	_LOCATION = ''
   _all_TIME = 0
   _all_COST = 0
	_ALL_NUM = 0

	select _TARIF1
	go top

	do while .not. Eof()
		DrawSpin()
		StatusLine('Printing report database...')
		if PRow() = 0
			Set Device to PRINTER
			* Заголовок
			STRING = 'Сводная ведомость по '+_s_ORGAN+' за период с '+DtoC(_DATE_F)+' по '+DtoC(_DATE_L)
			@ PRow()+1, Center(106, STRING) say STRING
			STRING = '*** звонки класса '+Transform(_Class, '9') + ' ('
			STRING = STRING + iif(_Class = 0, 'локальные', iif(_Class = 1, 'междугородные', 'международные'))+') по внешним линиям ***'
			@ PRow()+1, Center(106, STRING) say STRING
			if PCount() = 5
				STRING = ''
				if .not. Empty(_FPBX)
					STRING = STRING + 'PBX = ' + _FPBX
				endif
				if .not. Empty(_FEXT)
					STRING = STRING + '; EXT = ' + _FEXT
				endif
				if .not. Empty(STRING)
					@ PRow()+1, Center(106, STRING) say STRING
				endif
			endif
		* So, diz for print table header...
			_GSTN_N = ''
			if _s_PAGE > 0
				@ PRow()+1, 0 say 'страница ' + Str(_PAGE)
			endif
			Set Device to SCREEN
		endif

* xXXXXXX|xxx|Лихтенштейн, Сам-Глав Бург, 99999.99|dd/mm/yyyy|hh:mm:ss|hh:mm:ss|xxxxxxxxxxxxxxxxxx|9999999.99
* GSTN_N	PBX_N LOCATION		               COST1MIN DATE     TIME     DURATION	CALL_NUM           _COSTALL
	   _COSTALL = Round( Ret_Sec(DURATION)*(COST1MIN / 60), 2)
		_LOCATION = LOCATION
		if _GSTN_N # GSTN_N
			STRING = GSTN_N
			_GSTN_N = STRING
			Set Device to PRINTER
			@ PRow()+1, 0 say Replicate('-', 107)
			@ PRow()+1, 0 say 'Ном.ГТС|Кто|Город, страна, цена минуты          |   Дата   | Время  |Длительн| Набранный номер  | $$$$$'
			@ PRow()+1, 0 say Replicate('-', 107)
			Set Device to SCREEN
		else
			STRING = Space(Len(GSTN_N))
		endif
		_FULL_N = FULL_N
		_ALL_TIME = _ALL_TIME + Ret_Sec(DURATION)
		_ALL_COST = _ALL_COST + _COSTALL
		_ALL_NUM = _ALL_NUM + 1
		STRING = STRING+'|'+PBX_N+'|'
		STRING = STRING+_LOCATION+'  '+iif(COST1MIN = 0, Space(8), Transform(COST1MIN,'99999.99'))+'|'

		STRING = STRING+DtoC(DATE)+'|'+TIME+'|'+DURATION+'|'+CALL_NUM+'|'+iif(_COSTALL = 0, Space(10), Transform(_COSTALL, '9999999.99'))
		Set Device to PRINTER
		@ PRow() + 1, 0 say string
		Set Device to SCREEN

		skip

* New Location ?
		if _LOCATION # LOCATION
			Set Device to PRINTER
* Итого xxxxx звонков в Лихтенштейн, Сам-Глав Бург:                     hhh:mm:ss                      999999999.99
	      string = 'Итого '+AllTrim(Transform(_ALL_NUM, '999999'))
			@ PRow() + 1, 0 say string
			string = 'звон'+iif(_all_num = 1, 'ок', iif(_all_num < 5,'ка','ков'))+' в ' + AllTrim(_LOCATION) + ':'
			@ PRow(), PCol() + 1 say string
	      string = Ret_hhmmss(_ALL_TIME)
	      @ PRow(), 77-Len(string) say string
	      string = Alltrim(Transform(_all_COST, '999999999.99'))
	      @ PRow(), 107-Len(string) say string
	      _all_TIME = 0
	      _all_COST = 0
			_ALL_NUM = 0
   	   @ PRow() + 1, 0 say ''
			Set Device to SCREEN
	   endif

		if _GSTN_N # GSTN_N
* New line
			Set Device to PRINTER
			@ Prow()+2, 0 say ''
			Set Device to SCREEN
	      _all_TIME = 0
	      _all_COST = 0
			_ALL_NUM = 0
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

* All data printed!
   Set Device to SCREEN

	StatusLine('Deleting temporary report database...')
	WriteLog('& ...Closing _TARIF_.DBF')
	select _TARIF1
	use
	WriteLog('& ...Ok')
	if .not. GOD_MODE
		WriteLog('& ...Deleting _TARIF_.DBF')
		Erase _TARIF1.DBF
		Erase _TARIF1.NTX
	endif

   setcolor(OldColor)
	WriteLog('& ...Ok. Print2 done')
return ''
*******************************

*******************************
* funcftion: Report_Edit
* notes:     TRAFFICS.DBF manual edit
*
function Report_Edit
private STRING, OldRec, OldArea, OldColor
private _STN_NUM, _CO_LINE, _DATE, _TIME, _DURATION, _CALL_NUM
private DEL_, MAX_FIELDS

	StatusLine('!You may violate all laws! ;)')
	OldRec = RecNo()
   OldArea = DBf()
   OldColor = setcolor('W+/BG')
	select traffics
	go top

	MAX_FIELDS = 7
	declare AFIELDS[MAX_FIELDS], MSG_FIELDS[MAX_FIELDS]

	AFIELDS[1] = 'STN_NUM'
	AFIELDS[2] = 'CO_LINE'
	AFIELDS[3] = 'DATE'
	AFIELDS[4] = 'TIME'
	AFIELDS[5] = 'DURATION'
	AFIELDS[6] = 'CALL_NUM'
	AFIELDS[7] = 'CLASS'

	MSG_FIELDS[1] = 'ВнутрНом'
	MSG_FIELDS[2] = 'ВнешнНом'
	MSG_FIELDS[3] = 'Дата'
	MSG_FIELDS[4] = 'Время'
	MSG_FIELDS[5] = 'Длительн'
	MSG_FIELDS[6] = 'Набранный номер'
	MSG_FIELDS[7] = 'Класс'

	DEL_ = .F.
	set color to N/BG, W/N
	WINDOW(ROW(), COL(), 1, 0, 21, 79, 8, '╔═╗║╝═╚║ ')

	Tone(600, 1)
	set color to W+/N, N/W
	DBEdit(2, 1, 20, 78, AFIELDS, "F_REP_EDIT", .T., MSG_FIELDS, .T., .T., .T.)
	if DEL_
		pack
	endif
	WINDOW()

   select &OldArea
   go OldRec
   setcolor(OldColor)
return ''
*******************************

*******************************
* function:  F_REP_EDIT()
* notes:
*
function F_REP_EDIT
  parameters REG, POL_POINT
  private FN_MACRO, FCHK
  FN_MACRO = AFIELDS[POL_POINT]
do case
   case REG = 0                                  && если режим 0
        ********
        return 1
   case (REG = 1) .or. (REG = 2)
        ********
        return 1
   case REG = 4
*-----------------
        if lastkey() = 7                       && Нажата <DEL>-Удаление тек.зап.
           Tone(700, 1)
           DEL_ = .T.
           delete
           skip
           return 2
        endif
*-----------------
        if LastKey() = 22                    && <INS>-Ввод данных
           Tone(300, 1)
           append blank
           return 2
        endif
*-----------------
        if LastKey() = 27                      && Нажата<ESC>-Конец ввода/Выход
           Tone(90, 1)
           Tone(60, 1)
           return 0
        endif
*-----------------
        if LastKey() = 13                        && Нажата <ENTER>
           if POL_POINT = MAX_FIELDS
              keyboard Chr(24) + Chr(29)
             else
              keyboard Chr(4)
           endif
           return 1
        endif
*-----------------
        if ((LastKey() >= 32) .and. (LastKey() <= 254)) .or. LastKey() = -1 && Нажата буква или цифра или <F2>
           set cursor on
           @ Row(), Col() get &FN_MACRO
           keyboard iif(LastKey() # -1, chr(LastKey()), '')
           read
           set cursor off
        endif
endcase
return 1
*** end of F_REP_EDIT() *********


*******************************
* function: Ret_GSTN
* notes:    Возвращает по номеру PBX внешней линии номер
*           подкл. к ней линии ГТС (GSTN - Global Switched Telephone Network)
*
function Ret_GSTN
	parameters _PBX
   private OldArea, _GSTN

   OldArea = DBf()
	select LINES
	go top
	seek _PBX
	if Found()
		_GSTN = GSTN
	else
		_GSTN = "-ERROR-"
	endif

   select &OldArea
return _GSTN
*******************************

*******************************
* function: Ret_Need
* notes:    Возвращает по номеру PBX внешней линии need to 'tarif'
*           подкл. к ней линии ГТС (GSTN - Global Switched Telephone Network)
*
function Ret_Need
	parameters _PBX
   private OldArea, _Need

   OldArea = DBf()
	_Need = .T.
	select LINES
	go top
	seek _PBX
	if Found()
		_Need = NEED
	endif

   select &OldArea
return _Need
*******************************

*******************************
* function: Ret_MinSec
* notes:    Возвращает по номеру PBX внешней линии need to 'tarif'
*           подкл. к ней линии ГТС (GSTN - Global Switched Telephone Network)
*
function Ret_MinSec
	parameters _PBX
   private OldArea, _MinSec

   OldArea = DBf()
	_MinSec = 0
	select LINES
	go top
	seek _PBX
	if Found()
		_MinSec = MINSEC
	endif

   select &OldArea
return _MinSec
*******************************

*******************************
* function: Ret_FullNum
* notes:
*
function Ret_FullNum
   parameters _N
   private _FN

   if SubStr(_N, 1, 3) = '810'
      _FN = SubStr(_N, 4, Len(_N)-3)
   elseif SubStr(_N, 1, 1) = '8'
		if SubStr(_N, 2, 1) = '2'
			* Областной
			_FN = _s_COUNTRY + _s_REGION + SubStr(_N, 3, Len(_N)-2)
*			WriteLog('$ _FN = '+_FN)
		else
			_FN = _s_COUNTRY + SubStr(_N, 2, Len(_N)-1)
		endif
   else
      _FN = _s_COUNTRY + _s_REGION + _N
   endif
return _FN
*******************************

*******************************
* funcftion: Ret_LOC
* notes:    Возвращает по номеру после восьмерки место куда звонили,
*           первые 26 символов
*
function Ret_LOC
	parameters _CN
   private OldArea, _LOC, _seek, _pos

   OldArea = DBf()
	select COD_GOR
   go top
	* WriteLog('$ _CN[1] = '+_CN)
   _CN = Ret_FullNum(AllTrim(_CN))

	* WriteLog('$ _CN[2] = '+_CN)
   _pos = 13
   _LOC = '-Unknown-'
   do while _pos > 0
      seek SubStr(_CN, 1, _pos)
		* WriteLog('$ Seeking: '+SubStr(_CN, 1, _pos))
      if Found()
         _LOC = NAME
			* WriteLog('$ ...Found: '+_LOC)
         _pos = 0
      else
			* WriteLog('$ ...Not Found')
         _pos = _pos - 1
      endif
   enddo
	* WriteLog('$ _LOC = '+_LOC)
   select &OldArea

return AllTrim(_LOC)
*******************************

*******************************
* funcftion: Ret_COST
* notes:     Возвращает по номеру после восьмерки цену куда звонили,
*
function Ret_COST
   parameters _CN
   private OldArea, _COST, _seek, _pos

      OldArea = DBf()
		select COD_GOR
      go top
      _CN = Ret_FullNum(_CN)

      _pos = 13
      _COST = 0
      do while _pos > 0
         seek SubStr(_CN, 1, _pos)
         if Found()
            _COST = PRICE
            _pos = 0
         else
            _pos = _pos - 1
         endif
      enddo
   select &OldArea
return _COST
*******************************

*******************************
* funcftion: Ret_Sec
* notes:     Возвращает число секунд из строки времени
* hh:mm:ss
* 12345678
*
function Ret_Sec
	parameters _HHMMSS
   private _sec
* 12345678
* hh:mm:ss
   _sec = (Val(SubStr(_HHMMSS, 1, 2)) * 3600) + ;
         (Val(SubStr(_HHMMSS, 4, 2)) * 60) + ;
         Val(SubStr(_HHMMSS, 7, 2))
return _sec
*******************************

*******************************
* funcftion: Ret_hhmmss
* notes:     Возвращает строку времени hhhhh:mm:ss из секунд
*
function Ret_hhmmss
	parameters _Sec
   private String, ss, mm, hh, _ss, _mm, _hh

	String = ''
   _hh = Int(_Sec / 3600)
   _mm = Int((_Sec - (_hh * 3600)) / 60)
   _ss = _Sec - ((_hh * 3600) + (_mm * 60))

   ss = Alltrim(Str(_ss,2,0))
   mm = Alltrim(Str(_mm,2,0))
   hh = Transform(_hh, "99999")

   ss = ':' + Replicate('0', 2 - Len(ss)) + ss
   mm = ':' + Replicate('0', 2 - Len(mm)) + mm

return AllTrim(hh+mm+ss)
*******************************
