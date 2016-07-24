* ................... Переменные верхнего уровня .......................
public _s_PORT, _s_BAUD, _s_PARITY, _s_STOPBIT, _s_DATALEN, _s_AUTO
public _s_PAGE, _s_NPORT, _s_INIT, _s_OLD_LIMIT, _s_ORGAN, _s_COUNTRY
public _s_REGION, _s_LOCLEN, _s_ILOC, _s_ICIT, _s_ISTA, _s_SPOOL
public GOD_MODE, cheat_code, cheat_pose, _OS_
public _q_PRTDATE, _q_SAFEEXIT, _q_DCALLS, _q_SCALLS, _q_HH, hLOG, zzz
private i, just_one, endwork, IN_KEYs, PARAMS, TT, HH, sp_pos

* .......................... Настройка среды ...........................
set procedure to TRAF_LIB
set procedure to GET_COM
set procedure to SETUPS
set procedure to SET_COD
set procedure to SET_LIN
set procedure to REP_CALL


set century on              && Hope it helps to work in 2000

set date german             && Установка формата даты ЧЧ.ММ.ГГ
set cursor off              && Выключение курсора
set scoreboard off          && Отмена сообщений
set wrap on                 && Включение циклического прохода меню
set bell on                 && Включение зв.сигнала
set deleted on              && Удаленные записи не обрабатывать
set confirm on              && Отключение автоперемещения курсора
set softseek off
set exclusive on

zzz = ;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'──У──У──У──У──У──У──У──У──У──У──У──У'+;
	'00Я00Я00Я00Я00Я11Я11Я11Я11Я11Я22Я22Я'+;
	'01Я23Я45Я67Я89Я01Я23Я45Я67Я89Я01Я23Я'

GOD_MODE = .F.
endwork = .F.
cheat_code = ''
cheat_pose = 0
max_cheats = 4
declare cheats[max_cheats]

cheats[1] = 'solik'
cheats[2] = 'about'
cheats[3] = 'killme'
cheats[4] = 'gotbebebe?'
* cheats[5] = ''
* cheats[6] = ''
* cheats[7] = ''

Set_Ints()

DrawBkg()
setcolor('W+/N,N/W')

StatusLine('Opening system LOG...')
if .not. OpenLogFile('Traffics.log')
	Err_Message("Can't open 'Traffics.log'", 'Fatal ERROR')
	endwork = .t.
endif

WriteLog('')
WriteLog('* Traffics started...')
StatusLine('Checking activity LOG...')
if File('TRAFFICS.ACT')
	restore from TRAFFICS.ACT additive
	if (Type('_q_PRTDATE') # 'D').or.(Type('_q_SAFEEXIT') # 'L').or.(Type('_q_DCALLS') # 'N')
		_q_PRTDATE = Date()-1
		_q_SAFEEXIT = .f.
		_q_DCALLS = 0
	endif
	if .not. _q_SAFEEXIT
		WriteLog('* ...after ubnormal exit :(')
		Err_Message('Traffics was _NOT_ shutdown properly!',;
			'Indexes will be rebuilded')
		erase COD_GOR.NTX
		erase LINES.NTX
		erase TRAFFICS.NTX
	else
		WriteLog('* ...after normal shutdown')
	endif
else
	WriteLog('* ...first time :)')
	Err_Message('Traffics _FIRST_TIME_ run!',;
		'Installation mode forced')
	_q_PRTDATE = Date()-1
	_q_DCALLS = 0
	_q_SCALLS = 0
	_q_HH = 0
endif
_q_SAFEEXIT = .f.
save to TRAFFICS.ACT all like _q_*

_OS_ = DOS_VERSN()
WriteLog('* ...Running under OS: '+_OS_)

CHK_DBF()
CHECK_SPACE()

StatusLine('Checking passed parameters...')
PARAMS = ''
parameters PARAMS
WriteLog('* Parameters: '+PARAMS)

if lower(PARAMS) = '/'+cheats[max_cheats]
	* God mode for testing ;)
	GOD_MODE = .T.
   err_message('God mode: ON')
endif

if upper(PARAMS) = '/SETUP'
   SETUP()
	endwork = .t.
endif

if (.not. endwork).and.(upper(PARAMS) = '/CODES')
   StatusLine('Entering Codes setup...')
   SET_CODS()
	endwork = .t.
endif

if (.not. endwork).and.(upper(PARAMS) = '/LINES')
   StatusLine('Entering Lines setup...')
   SET_LINS()
	endwork = .t.
endif

if .not. endwork
	select COD_GOR
	if LastRec() = 0
		WriteLog('- COD_GOR.DBF is empty')
		err_message('COD_GOR.DBF is empty.','Please, run TRAFFICS /CODES')
		endwork = .t.
	endif
endif

if .not. endwork
	select LINES
	if LastRec() = 0
		WriteLog('- LINES.DBF is empty')
		err_message('LINES.DBF is empty.','Please, run TRAFFICS /LINES')
		endwork = .t.
	endif
endif

if .not. endwork
	ReadINI()
endif

if .not. endwork
	if _s_SPOOL
		WriteLog('+ Spooling requested, checking...')
		StatusLine('Checking existance of spooler...')
		if pr_check()
			setcolor('N/W*')
			@ 24, 30 say 'Cancel PRINT queue'
			setcolor('R+/W*')
			@ 24, 26 say 'F10'
			WriteLog('+ ...Ok')
		else
			err_message('Spooling requested, but does not seems to be installed.',;
				'Run TRAFFICS.BAT instead of directly start .EXE, please!')
			WriteLog('- ...Bad, if it is, it seems to be not compatible with PRINT ;)')
			endwork = .t.
		endif
	endif
endif

if .not. endwork
	setcolor('W/N')
	StatusLine('Checking FOSSIL...')
	WriteLog('+ Checking FOSSIL...')
	if .not. RESET_FOSSIL(_s_NPORT)
		WriteLog('- ...FOSSIL not present')
		if .not. GOD_MODE
			err_message('FOSSIL driver required!',;
				'Run TRAFFICS.BAT please.')
			endwork = .t.
		endif
	else
		WriteLog('+ ...Ok')
	endif
endif

if .not. endwork
	if .not. GOD_MODE
		WriteLog('+ Init FOSSIL')
		INIT_FOSS(_s_INIT)
	endif
endif

StatusLine('')
WriteLog('■ Entering main loop')
TT = 0
HH = 0
sp_pos = 1
sp_str = '-\|/'
IN_KEYs = 0
do while .not. endwork
	* Раз в секунду
	if Abs(Seconds() - TT) > 1
		TT = Seconds()
		* Spinning...
		DrawSpin()
		* Update info...
		DrawGauge()
   endif

	* Раз в четверть часа
	if Abs(Seconds() - HH) > 900
		HH = Seconds()
		* Update stat screen...
		UpdStat()
	endif

	* Проверить клавишу
	IN_KEYs = inkey()

	if IN_KEYs = 301
		WriteLog('- Alt-X pressed')
		if Err_message('ARE YOU REALLY WANNA ABORT ME ?!',;
						'- press Alt-X again if sure -') = 301
			endwork = .t.
		endif
	endif
	* По пробелу - прорисовка статистики
	if IN_KEYs = 32
		UpdStat()
		HH = Seconds()
	endif

	if IN_KEYs = 28
		WriteLog('■ F1 pressed')
		* About...
		DoCheat(3)
	endif
	if IN_KEYs # 0
	* cheating... process only AlphaNumeric keys,
	*             any other ignored and resets cheat_code
		if (chr(IN_KEYs) $ '1234567890abcdefghijklmnopqrstuwvxyz')
			cheat_code = cheat_code + chr(IN_KEYs)
			cheat_pose = cheat_pose + 1
			* prevent overflow
			if cheat_pose > 20
				cheat_code = ''
				cheat_pose = 0
			endif
		else
			cheat_code = ''
			cheat_pose = 0
		endif

		just_one = .f.
		for i = 1 to max_cheats
			if cheat_code = cheats[i]
				WriteLog('■ Cheat code activated: ' + Alltrim(Str(i)))
				DoCheat(i)
				cheat_code = ''
				cheat_pose = 0
			else
				if SubStr(cheats[i], 1, cheat_pose) = cheat_code
					just_one = .t.
				endif
			endif
		next i
		if .not. just_one
			cheat_code = ''
			cheat_pose = 0
		endif
	endif

	* Нажата <F9> manual report по Линиям (для сравнения с МАТС)
	if IN_KEYs = -8
		WriteLog('■ F9 Manual report requested')
	   tone(1000, 1)
	   Rep_Call2(0,0)
	endif

	* Нажата <F10> - cancel PRINT queue
	if IN_KEYs = -9
		WriteLog('■ F10 Cancelling PRINT queue')
	   tone(1000, 1)
		pr_cancel()
	endif

	* Нажата <Shift-F1> manual edit ;)
	if (IN_KEYs = -10) .and. GOD_MODE
		WriteLog('■ Shift-F1 Manual edit of report database requested')
	   tone(1000, 1)
	   tone(400, 1)
	   Report_Edit()
	endif

	* test for next day
	if _q_PRTDATE < Date()
		WriteLog('■ Day turn encountered.')
		* debug
		* WriteLog('$ _q_PRTDATE = '+DtoC(_q_PRTDATE))
		_q_DCALLS = 0
		_q_HH = 0
		if _s_OLD_LIMIT # 0
			StatusLine('Packing databases...')
			WriteLog('■ Packing database...')
			OldRec = RecNo()
			OldArea = DBf()
			select TRAFFICS
			DELETE ALL FOR (DATE < (Date() - _s_OLD_LIMIT))
			Pack
			Go Top
			commit
			select &OldArea
			go OldRec
			WriteLog('■ ...Ok. Packing done')
		endif
		if _s_AUTO
			WriteLog("■ It's time to print reports")
		   tone(1000, 10)
			if _s_ILOC
				WriteLog('■ ...Rep_Call2(2,0)')
				Rep_Call2(2,0)
			endif
			if _s_ICIT
				WriteLog('■ ...Rep_Call2(2,1)')
				Rep_Call2(2,1)
			endif
			if _s_ISTA
				WriteLog('■ ...Rep_Call2(2,2)')
				Rep_Call2(2,2)
			endif
			WriteLog('■ Printing is done')
		endif
		_q_PRTDATE = Date()
		save to TRAFFICS.ACT all like _q_*
	endif

	if .not. GOD_MODE
		* Читать данные из порта
	   GET_DATA()
	endif

	StatusLine('')
   TSK_SWTCH()
enddo

WriteLog('* Going DOWN...')
StatusLine('ShutDown...')
set printer to
_q_SAFEEXIT = .t.
save to TRAFFICS.ACT all like _q_*
WriteLog('* ...CleanUp databases')
close all
commit
Set_Blnk()
setcolor('W/N')
clear screen
WriteLog('* Completely shutdown')
WriteLog('')
quit

***
procedure ReadINI
private _bad

	WriteLog('+ Reading TRAFFICS.INI...')
	StatusLine('Restoring setup from TRAFFICS.INI ...')
	_bad = .f.
	if file('TRAFFICS.INI')
		restore from TRAFFICS.INI additive
	else
		_bad = .t.
	endif
	if _bad
		WriteLog('+ ...Bad TRAFFICS.INI, aborting')
		err_message('TRAFFICS.INI not found or corrupted.','Please, run TRAFFICS /SETUP')
		endwork = .t.
	else
		WriteLog('+ ...Ok')
		DrawStat()
	endif
return
***

procedure DrawBkg
	private i

	setcolor('B+/B')
	@ 0, 0, 24, 79 box '░░░░░░░░░'
	setcolor('N/W*')
	@ 0, 0 say Space(80)
	@ 24, 0 say Space(80)
	@ 0, 2 say 'Samsung SKP-56/120 monitor utility'
	@ 24, 7 say 'Exit     Printing'
	@ 24, 60 say 'Mem:      Disk:'
	setcolor('R+/W*')
	@ 24, 1 say 'Alt-X'
	@ 24, 13 say 'F9'
	if _s_SPOOL
		@ 24, 26 say 'F10'
	endif
* Windows
	setcolor('W+/B')
	@ 2, 1, 13, 47 box '███▐▀▀▀▌ '
	@ 2, 49, 13, 78 box '███▐▀▀▀▌ '
	@ 15, 1, 22, 78 box '███▐▀▀▀▌ '
	@ 11, 49 say '██▌                        ▐██'
	@ 12, 49 say '██▌                        ▐██'
	for i = 17 to 21
		@ i, 35 say '│'
	next i
	setcolor('GB/B')
	for i = 3 to 10
		@ i, 50 say Replicate('─', 28)
	next i
	RestScreen(3, 52, 12, 75, zzz)
	setcolor('N/W*')
	@ 2, 3 say 'Station activity'
	@ 2, 44 say '[ ]'
	@ 2, 51 say 'Station loading'
	@ 15, 3 say 'System status'
	setcolor('GR+/B')
	@ 3, 2 say 'EXT COM Start    Duration Dialed number      '
	setcolor('W/N')
	scroll(4,2,12,46,0)
	setcolor('N+/N')
	for i = 4 to 11
		@ i, 5 say '│   │        │        │'
	next i
	setcolor('W+/G')
	@ 16, 1 say '▌'+Space(76)+'▐'
	setcolor('W/B')
	@ 17, 2 say 'Country code:'
	@ 18, 2 say 'Region code:'
	@ 19, 2 say 'Max ignored length:'
	@ 20, 2 say 'Host OS:'
	@ 17, 36 say 'AutoPrint'
	@ 18, 36 say 'Spooling'
	@ 19, 37 say 'local'
	@ 20, 37 say 'intercities'
	@ 21, 37 say 'international'
	@ 17, 61 say 'Lines/page'
	@ 18, 61 say 'Old limit'
	@ 19, 61 say 'Rec.Count'
	@ 20, 61 say 'DBF Size'
	@ 21, 61 say 'Call count'
return

procedure DrawGauge
	private oldcolor, _hdd, _mem, string, ss, oldarea, _dbf

	oldcolor = setcolor('N/W*')
	oldarea = dbf()
	select traffics

	@ 0, 64 say DtoC(Date()) + ' ' + SubStr(Time(), 1, 5)
	_hdd = Round(DiskSpace() / 1024, 0)
   _dbf = LastRec()*RecSize() + Header() + 1
	if (_dbf*3) > (_hdd*1024)
		* Low space warning
		setcolor('GR+/R')
		@ 15, 28 say ' * LOW SPACE WARNING * '
		* WriteLog('! Warining: Low space.')
	else
		setcolor('N/W*')
		@ 15, 28 say Space(23)
	endif
	_mem = Round(Memory(0), 0)

	ss = 'K'
	setcolor('N/W*')
	string = AllTrim(Transform(_mem, '999'))
	@ 24, 64 say string+ss+Space(3 - Len(string))
	if _hdd > 999
		_hdd = Round(_hdd / 1024, 0)
		ss = 'M'
	endif
	if _hdd > 999
		_hdd = Round(_hdd / 1024, 0)
		ss = 'G'
	endif
	if _hdd > 999
		_hdd = Round(_hdd / 1024, 0)
		ss = 'T'
	endif

	string = AllTrim(Transform(_hdd, '999'))
	@ 24, 75 say string+ss+Space(3 - Len(string))

	setcolor('W+/B')
	string = AllTrim(Transform(LastRec(), '999999'))
	@ 19, 72 say string+Space(6-Len(string))
	ss = ''
	if _dbf > 999
		_dbf = Round(_dbf / 1024, 0)
		ss = 'K'
	endif
	if _dbf > 999
		_dbf = Round(_dbf / 1024, 0)
		ss = 'M'
	endif
	if _dbf > 999
		_dbf = Round(_dbf / 1024, 0)
		ss = 'G'
	endif
	string = AllTrim(Transform(_dbf, '999'))
	@ 20, 72 say string+ss+Space(3-Len(string))
	string = AllTrim(Transform(_q_DCALLS, '99999'))
	@ 21, 72 say string+Space(5-Len(string))

	select &oldarea
	setcolor(oldcolor)
return

procedure DrawStat
private OldColor, s1, s2

	oldcolor = setcolor('W+/G')
	s1 = AllTrim(_s_ORGAN)
	@ 16, Center(80, s1) say s1
	setcolor('W+/B')
	@ 17, 25 say _s_COUNTRY
	@ 18, 25 say _s_REGION
	@ 19, 25 say Transform(_s_LOCLEN, '9')
	@ 20, 25 say _OS_
	s1 = _s_PORT + ', ' + _s_BAUD + ', ' + _s_DATALEN + SubStr(_s_PARITY, 1, 1) + _s_STOPBIT
	@ 21, 2 + Center(33, s1) say s1
	@ 17, 51 say iif(_s_AUTO, 'Enabled', 'Disabled')
	@ 18, 51 say iif(_s_SPOOL, 'Enabled', 'Disabled')
	@ 19, 51 say iif(_s_ILOC, 'Enabled', 'Disabled')
	@ 20, 51 say iif(_s_ICIT, 'Enabled', 'Disabled')
	@ 21, 51 say iif(_s_ISTA, 'Enabled', 'Disabled')

	@ 17, 72 say AllTrim(Transform(_s_PAGE, '999'))
	@ 18, 72 say AllTrim(Transform(_s_OLD_LIMIT, '999'))
	setcolor(oldcolor)
return

procedure UpdStat
	private OldColor, OldArea, cHour, i, sData

	OldArea = Dbf()
	cHour = Val(SubStr(Time(), 1, 2)) + 1
	oldcolor = setcolor('W+/B')
	@ 13, 52 say replicate('▀', 24)
	setcolor('GR+/B')
	@ 13, 51 + cHour say ''
	select STAT
	go cHour
	if cHour > _q_HH
		replace HOUR_DATA with _q_SCALLS
	else
		replace HOUR_DATA with HOUR_DATA + _q_SCALLS
	endif
	_q_HH = cHour
	_q_SCALLS = 0

* Здесь надо прорисовать базу на экране...

* ██Station loading█████████████
* ▌────────────────────────────▐ 7
* ▌────────────────────────────▐ 6
* ▌────────────────────────────▐ 5
* ▌────────────────────────────▐ 4
* ▌────────────────────────────▐ 3
* ▌────────────────────────────▐ 2
* ▌────────────────────────────▐ 1
* ▌────────────────────────────▐ 0
* ██▌000000000111111111122222▐██
* ██▌123456789012345678901234▐██
* ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

* Прочитаем данные
	Declare sData[24]
	for i = 1 to 24
		go i
		sData[i] = HOUR_DATA
	next i

* Найдем максимум
	sMax = 0
	for i = 1 to 24
		sMax = iif(sMax < sData[i], sData[i], sMax)
	next i
	* debug
	* WriteLog('$ sMax = '+Str(sMax))
	if sMax = 0
		return
	endif

* Примем максимум за 100%, найдем цену деления (всего 16 делений)
	cOne = sMax / 16
	* debug
	* WriteLog('$ cOne = '+Str(cOne))
* Очистим экран...
	RestScreen(3, 52, 12, 75, zzz)
* пауза по просьбе Зайцева...
	inkey(.2)
	for i = 1 to cHour
		cHeight = Round((sData[i] / cOne) / 2, 0)
		setcolor(iif(Odd(i), 'GR+/B', 'GR+/B*'))
		@ 10-cHeight+1, 51+i, 10, 51+i box '█'
		if ((cHeight*2) - (sData[i] / cOne) > .5)
			@ 10-cHeight+1, 51+i say '▄'
		endif
		if (cHeight = 0).and.(sData[i] > 0)
			@ 10, 51+i say '_'
		endif
	next i
	for i = cHour+1 to 24
		cHeight = Round((sData[i] / cOne) / 2, 0)
		setcolor(iif(Odd(i), 'W/B', 'W/B*'))
		@ 10-cHeight+1, 51+i, 10, 51+i box '█'
		if ((cHeight*2) - (sData[i] / cOne) > .5)
			@ 10-cHeight+1, 51+i say '▄'
		endif
		if (cHeight = 0).and.(sData[i] > 0)
			@ 10, 51+i say '_'
		endif
	next i

	select &OldArea
	setcolor(oldcolor)
return
