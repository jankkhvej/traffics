***
*	ERRORSYS
*
*	Clipper error system, modified for Traffics
*

NOTE ALTD()

RETURN

***
*	expr_error(name, line, info, model, _1, _2, _3)
*
function EXPR_ERROR
parameters NAME, LINE, INFO, MODEL, _1, _2, _3
	set device to screen
	WriteLog('! EXPR_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('EXPR_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .f.


***
*	undef_error(name, line, info, model, _1)
*
function UNDEF_ERROR
parameters NAME, LINE, INFO, MODEL, _1

	set device to screen
	WriteLog('! UNDEF_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('UNDEF_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .f.


***
*	misc_error(name, line, info, model)
*
function MISC_ERROR
parameters NAME, LINE, INFO, MODEL
	set device to screen
	WriteLog('! MISC_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('MISC_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .f.


***
*	open_error(name, line, info, model, _1)
*
function OPEN_ERROR
parameters NAME, LINE, INFO, MODEL, _1
	set device to screen
	WriteLog('! OPEN_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('OPEN_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .t.


***
*	db_error(name, line, info)
*
function DB_ERROR
parameters NAME, LINE, INFO, MODEL
	set device to screen
	WriteLog('! DB_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('DB_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .f.


***
*	print_error(name, line)
*
function PRINT_ERROR
parameters NAME, LINE, INFO, MODEL
	set device to screen
	WriteLog('! PRINT_ERROR: procedure '+ M->NAME)
	WriteLog('! in line: ' + AllTrim(Str(M->LINE)))
	WriteLog('! info:    ' + M->INFO)
	WriteLog('! model:   ' + M->MODEL)
	Err_Message('PRINT_ERROR: procedure '+ M->NAME,;
		'in line: ' + AllTrim(Str(M->LINE)),;
		'info: ' + M->INFO,;
		'model: ' + M->MODEL)
	quit
return .F.
