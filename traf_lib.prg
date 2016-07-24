*************************************************
* function:  WINDOW()
* notes:     функция открытия окон
* синтаксис:  WINDOW([<N>/<C>/<L>/<D>]/[<N>,<N>,<N>,<N>,<N>,<N>[,<N>][,<C>]])
* параметры:                 инфо       нач.поз,   координаты,  тень,   BOX
*
*             пример написания: excolor = SETCOLOR('GR+/B')
*                               WINDOW(ROW(),COL(),10,10,20,20,1,'AAAAAAAA ')
*                               .. продолжение программы
*                               WINDOW(ROW(),COL(),15,15,25,25,6,'BBBBBBBB ')
*                               ..
*                               do while WINDOW() # 0
*                                   * закрыть ВСЕ открытые окна
*                               enddo
*                               SETCOLOR(excolor)       && восстановить цвет
*
*                               цвет тени - десятичное число,
*                               означающее атрибут цвета символа
*                               (см руководство по IBM PC)
*
*                               Для открываемого окна могут быть переданы
*                               как рамка BOX, так и экран в формате
*                               'символ-атрибут' (например, сохраненный
*                               функцией SAVESCREEN() или построенный
*                               программой MED Ю. Данилова)
*
*************************************************

FUNCTION window
    PARAMETERS cury, curx, top, left, bottom, right, shadow, stringbox
    PRIVATE noscreen, no, kadr, ;
            rctlbr, row, col, t, l, b, r, ;
            dminy, dminx, dmaxy, dmaxx, ;
            goup, godown, goleft, goright, i

    noscreen = 0                && числовой номер последнего открытого окна
    no = "1"                    && строковый номер открываемого окна

    * определение последнего неоткрытого окна
    DO WHILE Type("AREA_&no.") # "U"
        noscreen = M->noscreen + 1
        no = LTrim(Str(M->noscreen + 1))
    ENDDO

    *
    * здесь известен числовой номер последнего открытого окна NoScreen
    * а также строковый номер открываемого окна No
    *
    * Обработка в зависимости от числа переданных параметров:
    * если 0 - закрытие окна
    * если 1 любого типа - запрос на получение номера последнего открытого окна
    * если 7 - открытие окна с параметром рамки по умолчанию
    * если 8 - открытие окна либо с переменной экрана, либо с рамкой BOX
    *

    IF PCount() = 0 .AND. M->noscreen = 0      && попытка закрыть неоткрытое окно
        RETURN 0
    ENDIF

    IF PCount() = 1                         && запрос на получение No откр.окна
        RETURN M->noscreen
    ENDIF

    *                      +----------------------------+
    *                      |                            |
    *                      | открытие или закрытие окна |
    *                      |                            |
    *                      +----------------------------+

    kadr = 15                                 && количество смен кадра

    IF PCount() = 6
        shadow    = .F.                     && тень не нужна
        stringbox = "┌─╖║╝═╘│ "             && параметр строки BOXа по умолчанию
    ENDIF

    IF PCount() = 7
        IF Type ("SHADOW") = "C"
            stringbox = M->shadow
            shadow = .F.
        ELSEIF Type ("SHADOW") = "N"
            stringbox = "┌─╖║╝═╘│ "
        ENDIF
    ENDIF

    * массивы восстанавливающих полосок
    DECLARE arrt[M->kadr], arrl[M->kadr], arrb[M->kadr], arrr[M->kadr]

    *
    *                       +----------------------+
    *                       |                      |
    *                       | эффект открытия окна |
    *                       |                      |
    *                       +----------------------+
    *
    IF PCount() >= 6
        PUBLIC area_&no.         && стало известно программе очередное окно
        *
        * формирование переменной сохраняемого экрана
        * начальные 6 байт - позиции: 2 - курсора, 4 - окна
        * и затем сохраняемый экран
        *
        rctlbr =    Chr(Row()) +                                    ;
                    Chr(Col()) +                                    ;
                    Chr(M->top) +                                   ;
                    Chr(M->left) +                                  ;
                    Chr(Iif(M->bottom < 24, M->bottom + 1, 24)) +   ;
                    Chr(Iif(M->right < 77, M->right + 2, 79))
        area_&no. = M->rctlbr + SaveScreen(M->top,          ;
                    M->left,                                ;
                    Iif(M->bottom < 24, M->bottom + 1, 24), ;
                    Iif(M->right < 77, M->right + 2, 79))

        * определение шага по векторам
        dminy = (M->top    - M->cury) / M->kadr
        dminx = (M->left   - M->curx) / M->kadr
        dmaxy = (M->bottom - M->cury) / M->kadr
        dmaxx = (M->right  - M->curx) / M->kadr

        * определение направления движения окна (булевы переменные)
        goup    = M->dminy * M->dmaxy > 0 .AND. M->dmaxy < 0
        godown  = M->dminy * M->dmaxy > 0 .AND. M->dminy > 0
        goleft  = M->dminx * M->dmaxx > 0 .AND. M->dmaxx < 0
        goright = M->dminx * M->dmaxx > 0 .AND. M->dminx > 0

        * начальные координаты разворачивания
        t = M->cury
        l = M->curx
        b = M->cury
        r = M->curx

        FOR i = 1 TO M->kadr

            t = Iif(M->i < M->kadr, M->t + M->dminy, M->top)
            l = Iif(M->i < M->kadr, M->l + M->dminx, M->left)
            b = Iif(M->i < M->kadr, M->b + M->dmaxy, M->bottom)
            r = Iif(M->i < M->kadr, M->r + M->dmaxx, M->right)

            IF M->goup
                arrb[M->i] = SaveScreen(M->b - M->dmaxy, M->l, M->b, M->r)
                arrt[M->i] = ''
            ENDIF
            IF M->godown
                arrt[M->i] = SaveScreen(M->t, M->l, M->t + M->dminy, M->r)
                arrb[M->i] = ''
            ENDIF
            IF M->goleft
                arrr[M->i] = SaveScreen(M->t, M->r - M->dmaxx, M->b, M->r)
                arrl[M->i] = ''
            ENDIF
            IF M->goright
                arrl[M->i] = SaveScreen(M->t, M->l, M->b, M->l + M->dminx)
                arrr[M->i] = ''
            ENDIF
        NEXT

        * начальные координаты разворачивания
        t = M->cury
        l = M->curx
        b = M->cury
        r = M->curx

        FOR i = 1 TO M->kadr

            t = Iif(M->i < M->kadr, M->t + M->dminy, M->top)
            l = Iif(M->i < M->kadr, M->l + M->dminx, M->left)
            b = Iif(M->i < M->kadr, M->b + M->dmaxy, M->bottom)
            r = Iif(M->i < M->kadr, M->r + M->dmaxx, M->right)

            IF Len(M->stringbox) <= 9               && строка BOXа
                @ M->t, M->l, M->b, M->r BOX M->stringbox
            ELSE                                    && передан экран (MED)
                RestScreen(M->t, M->l, M->b, M->r, M->stringbox)
            ENDIF

            IF M->goup
                RestScreen(M->b - M->dmaxy, M->l, M->b, M->r, arrb[M->i])
            ENDIF
            IF M->godown
                RestScreen(M->t, M->l, M->t + M->dminy, M->r, arrt[M->i])
            ENDIF
            IF M->goleft
                RestScreen(M->t, M->r - M->dmaxx, M->b, M->r, arrr[M->i])
            ENDIF
            IF M->goright
                RestScreen(M->t, M->l, M->b, M->l + M->dminx, arrl[M->i])
            ENDIF

        NEXT

        IF Len(M->stringbox) <= 9              && строка BOXа
            @ M->t, M->l, M->b, M->r BOX M->stringbox
        ELSE                                && передан экран (MED)
            RestScreen(M->t, M->l, M->b, M->r, M->stringbox)
        ENDIF
        IF Type("SHADOW") = "N"
            cfill(M->bottom + 1, M->left + 2, M->bottom + 1, M->right + 2, ;
                                                    M->shadow)  && тень внизу
            cfill(M->top + 1, M->right + 1, M->bottom + 1, M->right + 2, ;
                                                    M->shadow)    && тень справа
        ENDIF
        RETURN M->noscreen + 1
    ENDIF
    *
    *                       +----------------------+
    *                       |                      |
    *                       | эффект закрытия окна |
    *                       |                      |
    *                       +----------------------+
    *
    IF PCount() = 0
        no = LTrim(Str(M->noscreen))        && стр.номер - к закр. окну
        rctlbr  = Left(M->area_&no., 6)     && 6 байтов с параметрами
        area_&no. = StrTran(M->area_&no., M->rctlbr, "")  && экран без парам.

        row    = Asc(SubStr(M->rctlbr, 1, 1))
        col    = Asc(SubStr(M->rctlbr, 2, 1))
        top    = Asc(SubStr(M->rctlbr, 3, 1))
        left   = Asc(SubStr(M->rctlbr, 4, 1))
        bottom = Asc(SubStr(M->rctlbr, 5, 1))
        right  = Asc(SubStr(M->rctlbr, 6, 1))

        * начальная позиция восстановления
        cury = M->top  + Int((M->bottom - M->top) / 2)
        curx = M->left + Int((M->right - M->left) / 2)

        * определение шага по векторам
        dminy = (M->top    - M->cury) / M->kadr
        dminx = (M->left   - M->curx) / M->kadr
        dmaxy = (M->bottom - M->cury) / M->kadr
        dmaxx = (M->right  - M->curx) / M->kadr

        t = M->cury
        l = M->curx
        b = M->cury
        r = M->curx

        FOR i = 1 TO M->kadr

            t = Iif(M->i < M->kadr, M->t + M->dminy, M->top)
            l = Iif(M->i < M->kadr, M->l + M->dminx, M->left)
            b = Iif(M->i < M->kadr, M->b + M->dmaxy, M->bottom)
            r = Iif(M->i < M->kadr, M->r + M->dmaxx, M->right)

            RestScreen(M->t, M->l, M->b, M->r, M->area_&no.)

        NEXT

        RELEASE area_&no.        && уничтожить переменную старого экрана
        @ M->row, M->col SAY ""     && курсор на старое место
        RETURN M->noscreen - 1
    ENDIF

RETURN M->noscreen

*** end of WINDOW() ***********

*******************************
*
*           функция вывода сообщения
*           использует функцию WINDOW()
*           возвращает нажатую клавишу
*
*           Синтаксис:
*           _MESSAGE(<C>[,<C>[,<C>[,<C>[,<C>[,<C>[,<C>[,<C>]]]]]]])
*                       стр1 стр2 стр3 стр4 стр5 стр6 стр7 стр8

FUNCTION _message
    PARAMETERS str_1, str_2, str_3, str_4, str_5, str_6, str_7, str_8
    PRIVATE strwait, maxstr, deltay, deltax, t, l, b, r, i, noparam, excolor, retk

    excolor = SetColor('W+/G')
    strwait = 'press any key...'

    * к-во переданных в параметрах строк
    maxstr = PCount()

    * высота окна (с учетом внутренней строки)
    deltay = M->maxstr * 2 + 3

    * границы окна по вертикали
    t = (24 - M->deltay) / 2
    b = M->t + M->deltay + 1

    * определение длины окна (по горизонтали)
    deltax = 0
    FOR i = 1 TO M->maxstr
        noparam = Str(M->i, 1)
        deltax = Max(M->deltax, Len(M->str_&noparam.))
    NEXT

    * Если строчка из параметров короче внутренней
    deltax = Max(M->deltax, Len(M->strwait)) + 2

    * границы окна по горизонтали
    l = (79 - M->deltax) / 2
    r = M->l + M->deltax + 1

    * раскрыть окошко
    window(12, 39, M->t, M->l, M->b, M->r, 6)
    tone (1500, 2)
    * печатать строки
    FOR i = 1 TO M->maxstr
        noparam = Str(M->i, 1)
        @   M->t + M->i * 2, ;
            M->l + (M->deltax - Len(M->str_&noparam.)) / 2 + 1 ;
            SAY M->str_&noparam.
    NEXT
    * просить нажать любую клавишу
    @ Row() + 2, M->l + (M->deltax - Len(M->strwait)) / 2 + 1 SAY M->strwait
    CLEAR TYPEAHEAD
    retk = InKey(5)
    window()
    SetColor(M->excolor)
RETURN retk

*******************************
*
*           функция вывода сообщения об ошибке
*           использует функцию WINDOW()
*           возвращает логическое значение (.T.- нормальное завершение)
*
*           Синтаксис:
*           ERR_MESSAGE(<C>[,<C>[,<C>[,<C>[,<C>[,<C>[,<C>[,<C>]]]]]]])
*                       стр1 стр2 стр3 стр4 стр5 стр6 стр7 стр8
*
*           пример написания:   IF ERROR_FLAG
*                                   ERR_MESSAGE('Произошла ошибка')
*                               ENDIF
*

FUNCTION err_message
    PARAMETERS str_1, str_2, str_3, str_4, str_5, str_6
    PRIVATE maxstr, i, noparam, excolor, ss, retk

    excolor = SetColor('GR+/R')

    * к-во переданных в параметрах строк
    maxstr = PCount()

    * раскрыть окошко
    Window(0, 0, 1, 2, 10, 77, 6, '███▐▀▀▀▌ ')
	 setcolor('N/GR*')
	 @ 1, 4 say 'Error message'
    SetColor('GR+/R')
    tone (1200, 2)
    * печатать строки
    FOR i = 1 TO M->maxstr
        noparam = Str(M->i, 1)
		  ss = str_&noparam.
		  ss = AllTrim(SubStr(ss, 1, 75))
        @ 2 + M->i, 2 + Center(77, M->ss) SAY M->ss
    NEXT i
    * просить нажать любую клавишу
    CLEAR TYPEAHEAD
	 for i = 5 to 1 step -1
	 	ss = 'Wait... '+ Str(i, 1)
	 	@ 9, center(77, ss) say ss
		retk = InKey(1)
	   if retk # 0
			exit
		endif
	 next i
    window()
    SetColor(M->excolor)
RETURN retk

*******************************
* function: STRDATE()
* notes:    возврат строки даты вида: "25 сентября 1990 г."
*
*          пример написания:    SET DATE GERMAN
*                               VAR = CTOD('01.01.90')
*                               ? STRDATE(VAR)
*                               * результат: 1 января 1990 г.
FUNCTION strdate
    PARAMETERS pdate

    RETURN  LTrim(Str(Day(M->pdate))) + " " + ;
            Lower(Iif(Right(CMonth(M->pdate), 1) $ "тТ", ;
            CMonth(M->pdate) + "а", ;
            Left(CMonth(M->pdate), Len(CMonth(M->pdate)) - 1) + "я")) + " " + ;
            Left(DtoS(M->pdate), 4) + " г."

*** end of STRDATE() **********

*******************************
* function: DB_CREATE()
*
* notes:    Функция создания базы данных с указанной структурой; до 30 полей !
*           Создается БД указанной структуры БЕЗ ИНДЕКСАЦИИ И СВЯЗЕЙ в текущей
*           рабочей области.
*
* Call:     DB_CREATE('DB_NAME',;
*                     'FIELD_NAME-1','FIELD_TYPE-1',FIELD_LEN-1,FIELD_DEC-1,;
*                     'FIELD_NAME-2','FIELD_TYPE-2',FIELD_LEN-2,FIELD_DEC-2,;
*                     'FIELD_NAME-3','FIELD_TYPE-3',FIELD_LEN-3,FIELD_DEC-3,;
*                     ......................................................;
*                     'FIELD_NAME-9','FIELD_TYPE-9',FIELD_LEN-9,FIELD_DEC-9)
*
* Example:  DB_CREATE('FILENAME',;
*                     'KOD'   , 'N',  3, 0,;
*                     'FIO'   , 'C', 25, 0,;
*                     'ADRESS', 'C',100, 0,;
*                     'SUMMA' , 'N',  9, 2,;
*                     'DATE_R', 'D',  8, 0)
*
function DB_CREATE
    parameters DB_NAME,;
               F_N_1,  F_T_1,  F_L_1,  F_D_1,;
               F_N_2,  F_T_2,  F_L_2,  F_D_2,;
               F_N_3,  F_T_3,  F_L_3,  F_D_3,;
               F_N_4,  F_T_4,  F_L_4,  F_D_4,;
               F_N_5,  F_T_5,  F_L_5,  F_D_5,;
               F_N_6,  F_T_6,  F_L_6,  F_D_6,;
               F_N_7,  F_T_7,  F_L_7,  F_D_7,;
               F_N_8,  F_T_8,  F_L_8,  F_D_8,;
               F_N_9,  F_T_9,  F_L_9,  F_D_9

private KOL_FIELDS, INDX, _NAME_, _TYPE_, _LEN_, _DEC_
	KOL_FIELDS = (pcount() - 1) / 4
	select 0
	create TEMPO.DBF
	for INDX = 1 to KOL_FIELDS
	    _NAME_ = 'F_N_' + alltrim(str(int(INDX)))
	    _TYPE_ = 'F_T_' + alltrim(str(int(INDX)))
	    _LEN_  = 'F_L_' + alltrim(str(int(INDX)))
	    _DEC_  = 'F_D_' + alltrim(str(int(INDX)))
	    append blank
	    replace FIELD_NAME with &_NAME_.,;
	            FIELD_TYPE with &_TYPE_.,;
	            FIELD_LEN  with &_LEN_. ,;
	            FIELD_DEC  with &_DEC_.
	next
	use
	create &DB_NAME from TEMPO
	erase TEMPO.DBF
	use
return ''
*** end of DB_CREATE() ********

*******************************
* function:  CENTER()
* notes:
*
function CENTER
parameters COLUMN, STRING
private COLUMN
COLUMN = Int((COLUMN / 2) - (Len(STRING) / 2))
return Iif(COLUMN < 0, 0, COLUMN)
*** end of CENTER() ***********


*******************************
* procedure: CHECK_SPACE
* notes:
*
procedure CHECK_SPACE
   declare DBF_ARRAY[ADir('*.DBF')], NTX_ARRAY[ADir('*.NTX')]
   private DBF_SPACE, NTX_SPACE, INDX

	StatusLine('Checking free space...')
	store 0 to DBF_SPACE, NTX_SPACE
	for INDX = 1 to ADir('*.DBF', .T., DBF_ARRAY)
       DBF_SPACE = DBF_SPACE + DBF_ARRAY[INDX]
   next

   for INDX = 1 to ADir('*.NTX', .T., NTX_ARRAY)
       NTX_SPACE = NTX_SPACE + NTX_ARRAY[INDX]
   next
   if (DBF_SPACE + NTX_SPACE) > DiskSpace()
      ERR_MESSAGE('* * *  LOW SPACE WARNING  * * *',;
                  '! ! !   BE CAREFUL  ! ! !',;
                  'Better exit and cleanup your HDD !')
   endif
	WriteLog('+ Free space: ' + Str(DiskSpace()))
return
*** end of CHECK_SPACE ********

*******************************
* procedure: CHK_DBF
* notes:
*
procedure CHK_DBF
	StatusLine('Checking/creating/reindexing databases...')

	WriteLog('+ Checking TRAFFICS.DBF...')
	if .not. file('TRAFFICS.DBF')
		WriteLog('+ ...Creating TRAFFICS.DBF')
		DB_CREATE('TRAFFICS',;
			'STN_NUM' , 'C',  3, 0,;
			'CO_LINE' , 'C',  3, 0,;
			'DATE'    , 'D',  0, 0,;
			'TIME'    , 'C',  8, 0,;
			'DURATION', 'C',  8, 0,;
			'CALL_NUM', 'C', 18, 0,;
			'CLASS',    'N',  1, 0 )
		erase TRAFFICS.NTX
	endif
	if .not. file('TRAFFICS.NTX')
		select 0
	   use TRAFFICS
		WriteLog('+ ...Indexing TRAFFICS.DBF')
	   index on DATE to TRAFFICS
	   use
	endif
	select 0
	WriteLog('+ ...Opening TRAFFICS.DBF')
   use TRAFFICS index TRAFFICS

*********************************************************
	WriteLog('+ Checking COD_GOR.DBF...')
   if .not. file('COD_GOR.DBF')
		WriteLog('+ ...Creating COD_GOR.DBF')
   	DB_CREATE('COD_GOR',;
      	'CODE'    , 'C', 13, 0,;
         'NAME'    , 'C', 40, 0,;
         'PRICE'   , 'N',  8, 2 )
		erase COD_GOR.NTX
   endif
   if .not. file('COD_GOR.NTX')
		select 0
   	use COD_GOR
		WriteLog('+ ...Indexing COD_GOR.DBF')
      index on CODE to COD_GOR
      use
   endif
	WriteLog('+ ...Opening COD_GOR.DBF')
   select 0
   use COD_GOR index COD_GOR

*********************************************************
	WriteLog('+ Checking LINES.DBF...')
   if .not. file('LINES.DBF')
		WriteLog('+ ...Creating LINES.DBF')
   	DB_CREATE('LINES',;
      	'PBX'   , 'C',  3, 0,;
         'GSTN'  , 'C',  7, 0,;
         'MINSEC', 'N',  5, 0,;
         'NEED'  , 'L',  1, 0)
		erase LINES.NTX
   endif
   if .not. file('LINES.NTX')
		select 0
      use LINES
		WriteLog('+ ...Indexing LINES.DBF')
      index on PBX to LINES
      use
   endif
	WriteLog('+ ...Opening LINES.DBF')
	select 0
   use LINES index LINES

*********************************************************
	WriteLog('+ Checking STAT.DBF...')
   if .not. file('STAT.DBF')
		WriteLog('+ ...Creating STAT.DBF')
   	DB_CREATE('STAT',;
      	'HOUR_DATA' , 'N',  5, 0)
   endif
	WriteLog('+ ...Opening STAT.DBF')
	select 0
   use STAT
	if LastRec() <> 24
		WriteLog('+ ...STAT data corrupted, resetting.')
		zap
		for i = 1 to 24
			append blank
			replace HOUR_DATA with 0
		next i
	endif
return
*** end of CHK_DBF ********

****
* Function: Odd()
* Note:     Четность/Нечетность
* return:   .T. if odd parameter, .F. if even
* Author: Solyanik S.V.
****
Function ODD
	parameters _NUM
Return ((_NUM % 2) <> 0)
******* end of function Odd()

*******************************
* procedure:  STATUSLINE()
* notes:      Выдает состояние
*
procedure STATUSLINE
parameters _STR
private OldColor, ss

   OldColor = setcolor('W+/B')
   @  12, 2 say Space(45)
	ss = AllTrim(SubStr(_STR, 1, 45))
	@  12, 2 say iif(GOD_MODE, '$ ', '')+iif(Empty(ss), 'Idle.', ss)

	SetColor(OldColor)
return
*** end of STATUSLINE() ***********

*******************************
* procedure:  DoCheat()
* notes:
*
procedure DoCheat
parameters _i
private OldColor

   OldColor = setcolor('GR+/R')

	StatusLine('Secret code No. '+AllTrim(Str(_i))+' activated!')

	Tone(100*_i,2)
	do case
		case _i = 1
			_Message('My name is Sergey Solyanik, aka Solik',;
				'',;
				'mailto:solik@netdeeper.sumy.ua',;
				'or meet me on irc.sumy.net on #portal')
		case _i = 2
			_Message('Samsung SKP-56/120 monitor utility',;
						'version 2.1.0  09.11.2000 22:38',;
                  '(c) Solik, 1996-2000')
		case _i = 3
			GOD_MODE = .F.
   		StatusLine('God mode: OFF')
			inkey(1)
   		set printer to
			inkey(1)
		case _i = 4
			* God mode for testing ;)
			GOD_MODE = .T.
   		StatusLine('God mode: ON')
			inkey(1)
   		string = '_Test_.PRN'
   		StatusLine('Printer redirected to '+string)
   		set printer to &string
			inkey(1)

		otherwise
			_Message('Hey, where coders ?!',;
			 'Undescribed cheat code ! Again! 8-E')
	endcase


	SetColor(OldColor)
return
*** end of DoCheat() ***********

*******************************
* function:  MakeFileName()
* notes:     возвращает имя файла печати
*
function MakeFileName
parameters _type
private str, indx, ttype, exx

	do case
		case _type = 1
			ttype = '.A'
		case _type = 2
			ttype = '.B'
		otherwise
			err_message('Internal Error: MakeFileName.', 'Uknown "_type"')
			return ''
	endcase

	indx = 0
	str = Transform(DtoC(_q_PRTDATE), 'XX_XX_XX')+ttype+Transform(indx, '@B99')
	exx = File(str)
	do while exx
		indx = indx + 1
		if indx > 99
			indx = 0
			exx = .f.
		else
			str = Transform(DtoC(_q_PRTDATE), 'XX_XX_XX')+ttype+Transform(indx, '@B99')
			exx = File(str)
		endif
	enddo

return AllTrim(str)
*** end of MakeFileName() ***********

*******************************
* function:  ValidFile()
* notes:     возвращает имя файла печати
*
function ValidFile
parameters _s
private i, invalid, isvalid

* Follow these rules when naming files and directories:
*   o  A name cannot contain more than eight characters.
*      This includes punctuation marks and blank spaces.
*
*   o  An extension can be added to a name.
*      The extension can only contain up to three characters.
*      The extension must be separated from the name by a period.
*
*   o  The following symbols cannot be used in file or directory names:
*
*      0-1F hex   \   /   :   *   ?   "   .
*      <   >   |   ,   +   =   [   ]   ;
*
*   o  The * and ? symbols can be used as global file-name characters.
*
*   o  The following reserved device names cannot be used
*      as file or directory names:
*
*      KBD$   PRN    NUL    COM1    COM2    COM3    COM4   CLOCK$
*      LPT1   LPT2   LPT3   CON     SCREEN$    POINTER$    MOUSE$
*
* information above is extracted from OS/2 Warp 3 Command reference, (c)(p) IBM Corp.

	declare invalid[15]
	invalid[1] = 'KBD$'
	invalid[2] = 'PRN'
	invalid[3] = 'NUL'
	invalid[4] = 'COM1'
	invalid[5] = 'COM2'
	invalid[6] = 'COM3'
	invalid[7] = 'COM4'
	invalid[8] = 'CLOCK$'
	invalid[9] = 'LPT1'
	invalid[10] = 'LPT2'
	invalid[11] = 'LPT3'
	invalid[12] = 'CON'
	invalid[13] = 'SCREEN$'
	invalid[14] = 'POINTER$'
	invalid[15] = 'MOUSE$'

	_s = AllTrim(_s)
	isvalid = .t.
	i = 1
	do while (i < 16) .and. isvalid
		if _s = invalid[i]
			isvalid = .f.
			err_message('Invalid filename (reserved by system)')
		endif
		i = i + 1
	enddo

	i = 1
	do while (i < Len(_s)+1) .and. isvalid
		if (Asc(SubStr(_s, i, 1)) < 33) .or. (Asc(SubStr(_s, i, 1)) > 126)
			isvalid = .f.
			err_message('Some chars in filename < 33 or > 126')
		endif
		if SubStr(_s, i, 1) $ '\/:*?".*<>|,+=[];'
			isvalid = .f.
			err_message('Reserved char in filename')
		endif
		i = i + 1
	enddo

return isvalid
*** end of ValidFile() ***********

*******************************
* function:  OpenLogFile()
* notes:     Opens log file
*
function OpenLogFile
parameters _fname

	hLOG = FOpen(_fName, 2)
	if hLOG < 0
		hLOG = FCreate(_fname)
		if hLOG < 0
			return .f.
		endif
	endif
	FSeek(hLOG, 0, 2)
return .t.
*** end of OpenLogFile() ***********

***
procedure WriteLog
parameters _str
private _sss

	_sss = iif(Len(_str) = 0, chr(13) + chr(10), DtoC(Date()) + ' ' + Time() + ' ' + _str + chr(13) + chr(10))
	FWrite(hLOG, _sss)

return
***

***
procedure CloseLogFile

	FClose(hLOG)

return
***

***
procedure DrawSpin
private OldColor

	OldColor = setcolor('N/W*')
	@ 2, 45 say SubStr(sp_str, sp_pos, 1)
	* Здесь 4 - это длина sp_str
	sp_pos = iif(sp_pos <= 4, sp_pos + 1, 1)
	setcolor(OldColor)
return
***
