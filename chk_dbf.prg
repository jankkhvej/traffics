    if .not. file('TRAFFICS.DBF')
        DB_CREATE('TRAFFICS',;
                   'STN_NUM' , 'C',  3, 0,;
                   'CO_LINE' , 'C',  3, 0,;
                   'DATE'    , 'D',  0, 0,;
                   'TIME'    , 'C',  8, 0,;
                   'DURATION', 'C',  8, 0,;
                   'CALL_NUM', 'C', 18, 0,;
                   'PRINTED' , 'L',  1, 0,;
                   'CLASS',    'N',  1, 0 )

        use TRAFFICS
        index on dtoc(DATE) to TRAFFICS
        use
        use TRAFFICS index TRAFFICS
    endif
    if .not. file('TRAFFICS.NTX')
        use TRAFFICS
        index on dtoc(DATE) to TRAFFICS
        use
        use TRAFFICS index TRAFFICS
    endif
    use TRAFFICS index TRAFFICS

*********************************************************
    select 0
    if .not. file('COD_GOR.DBF')
        DB_CREATE('COD_GOR',;
                   'CODES'   , 'C',  5, 0,;
                   'NAME'    , 'C', 40, 0,;
                   'PRICE'   , 'N',  8, 2 )

        use COD_GOR
        index on CODES to COD_GOR
        use
        use COD_GOR index COD_GOR
    endif
    if .not. file('COD_GOR.NTX')
        use COD_GOR
        index on CODES to COD_GOR
        use
        use COD_GOR index COD_GOR
    endif
    use COD_GOR index COD_GOR

