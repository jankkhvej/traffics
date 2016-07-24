*******************************
*function:  SET_LINS()
*notes:
*
function SET_LINS
  private DEL_, MAX_FIELDS

  WriteLog('& Entering LINES setup...')
  MAX_FIELDS = 4
  declare AFIELDS[MAX_FIELDS], MSG_FIELDS[MAX_FIELDS]

  AFIELDS[1] = 'PBX'
  AFIELDS[2] = 'GSTN'
  AFIELDS[3] = 'MINSEC'
  AFIELDS[4] = 'NEED'

  MSG_FIELDS[1] = 'Номер внешней'
  MSG_FIELDS[2] = 'Номер ГТС'
  MSG_FIELDS[3] = 'Мин. время для тариф. (сек)'
  MSG_FIELDS[4] = 'Надо ли вообще тариф.'

  DEL_ = .F.

  select LINES
  go top

  setcolor('N/BG,W/N')
  WINDOW(ROW(), COL(), 1, 0, 21, 79, 8, '╔═╗║╝═╚║ ')
  Tone(600, 1)
  setcolor('W+/N,N/W')
  DBEdit(2, 1, 20, 78, AFIELDS, "F_SET_LINS", .T., MSG_FIELDS, .T., .T., .T.)
  if DEL_
	  WriteLog('& ...Packing LINES.DBF')
	  pack
  endif
  WINDOW()
  WriteLog('& ...Ok. LINES setup done')
return ''
*** end of SET_LINS() **********

*******************************
*function:  F_SET_LINS()
*notes:
*
function F_SET_LINS
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
           if POL_POINT=1
              FCHK = PBX
              @ Row(), Col() get FCHK picture '###' valid CHK_LIN(FCHK)
              keyboard iif(LastKey() # -1, chr(LastKey()), '')
              read
              set cursor off
              if LastKey()=13
                 replace PBX with Alltrim(FCHK)
              endif
              return 2
            else
              @ Row(), Col() get &FN_MACRO
              keyboard iif(LastKey() # -1, chr(LastKey()), '')
              read
              set cursor off
           endif
        endif
endcase
return 1
*** end of F_SET_LINS() *********

function CHK_LIN
parameters X
private O_Rec, XS, FR

O_Rec = RecNo()
FR = .F.
XS = Alltrim(X)
go top
seek XS
if .not. found()
   FR = .T.
 else
   tone(100, 1)
endif
go O_Rec
return FR
