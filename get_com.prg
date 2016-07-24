*******************************
*funcftion: GET_DATA
*notes:
*
function GET_DATA
private STRING, LX, OldRec, OldArea, OldColor, STR_Line, SuccessRec
private _STN_NUM, _CO_LINE, _DATE, _TIME, _DURATION, _CALL_NUM

	DrawSpin()
   if DATA_READY()
		StatusLine('Getting data...')
	   OldRec = RecNo()
	   OldArea = DBf()
	   OldColor = setcolor('W+/BG')
	   select TRAFFICS
	   STRING = ''
      select TRAFFICS
	   LX = 0
      do while LX # 10
         LX = READ_WAIT()
         STRING = STRING + iif(((LX # 13) .and. (LX # 10)), chr(LX), '')
			DrawSpin()
      enddo

      STRING = alltrim(STRING)
      _STN_NUM  = substr(STRING, 1, 3)
      _CO_LINE  = substr(STRING, 8, 3)
      _DATE     = substr(STRING, 15, 5)
      _DATE     = substr(_DATE, 4, 2)+ '.' + substr(_DATE, 1, 2) + '.' + str(year(date()))
      _TIME     = substr(STRING, 23, 8)
      _DURATION = substr(STRING, 34, 8)
      _CALL_NUM = substr(STRING, 45)
      _CALL_NUM = iif(len(_CALL_NUM) > 18, substr(_CALL_NUM, 1, 17) + '.', _CALL_NUM)

* Validity checking
      SuccessRec = .T.
      SuccessRec = SuccessRec.and.(val(_STN_NUM) > 99)
      SuccessRec = SuccessRec.and.(val(_CO_LINE) > 699)
      SuccessRec = SuccessRec.and.(CtoD(_DATE) >= ctod('01.01.90'))
      SuccessRec = SuccessRec.and.(Ret_Sec(_TIME) >= 0)
      SuccessRec = SuccessRec.and.(Ret_Sec(_DURATION) >= 0)

      if .not. SuccessRec
         WriteLog('! Bad data readed from COM port')
         Err_Message('Bad data readed from COM port')
       else
         * Сохранить в БД
         append blank
         replace STN_NUM  with _STN_NUM   ,;
                 CO_LINE  with _CO_LINE   ,;
                 DATE     with ctod(_DATE),;
                 TIME     with _TIME      ,;
                 DURATION with _DURATION  ,;
                 CALL_NUM with _CALL_NUM  ,;
                 CLASS    with iif(SubStr(Alltrim(_CALL_NUM), 1, 3) = '810', 2, iif(SubStr(Alltrim(_CALL_NUM), 1, 1) = '8', 1, 0))
			_q_DCALLS = _q_DCALLS + 1
			_q_SCALLS = _q_SCALLS + 1
         commit
      endif

      * Нарисовать на экране
      setcolor('W/N')
      scroll(4, 2, 11, 46, 1)
		setcolor('N+/N')
		@ 11, 5 say '│   │        │        │'
      setcolor('W/N')
      @ 11, 2 say _STN_NUM
		@ 11, 6 say _CO_LINE
		@ 11, 10 say _TIME
		@ 11, 19 say _DURATION
		@ 11, 28 say _CALL_NUM

      select &OldArea
      go OldRec
      setcolor(OldColor)
   endif
return ''
*******************************
