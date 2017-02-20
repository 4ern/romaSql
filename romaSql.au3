#include 'queryBuilder.au3'

; #INDEX# =======================================================================================================================
; Title .........: SQL Query Builder
; AutoIt Version : 3.3.14.2
; Language ......: German
; Description ...: SQL Query Builder
; Insperiert of .: doctrine & Laravel 
; Author(s) .....: 4ern.de
; ===============================================================================================================================

; #Commands# =====================================================================================================================
; $SQL_debug
; $SQL_connect
; $SQL_returnType
; $SQL_setDefaultTable
; $SQL_setDefaultKey
	
; $SQL_get
; $SQL_update
; $SQL_delete
; $SQL_insertInto
; $SQL_take
; $SQL_limit
; $SQL_table
; $SQL_select
; $SQL_distinct
;
; $SQL_where
; $SQL_orWhere
; $SQL_whereBetween
; $SQL_whereNotBetween
; $SQL_whereIn
; $SQL_whereNotIn
; $SQL_whereNull
; $SQL_whereNotNull
; $SQL_having
; $SQL_orHaving
; $SQL_havingBetween
; $SQL_havingNotBetween
; $SQL_havingIn
; $SQL_havingNotIn
; $SQL_havingNull
; $SQL_havingNotNull
; $SQL_groupBy
; $SQL_orderBy    
; ===============================================================================================================================     

; #IN PLANNING# =================================================================================================================
; + Database
;	- SQL Create Table
;	- SQL Drop Table
;	- SQL Truncate Table
;	- SQL Alter
;	- SQL View
; + Aggregates
; 	- SQL AVG() Function
; 	- SQL COUNT() Function
; 	- SQL SUM() Function
; 	- SQL MAX() Function
; 	- SQL MIN() Function
; + SQL Joins
; 	- SQL INNER JOIN
; 	- SQL LEFT JOIN
; 	- SQL RIGHT JOIN
; + Unions
; + Oracle Connection
; + PostgrSQl Connection
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __4ern_SQL__IsDefault 		;thx BugFix
; __4ern_SQL_rawQuery
; __4ern_SQL_raw_getAll
; __4ern_SQL_raw_getFirst
; __4ern_SQL__QueryBuilder__table
; __4ern_SQL__QueryBuilder__SELECT
; __4ern_SQL__QueryBuilder__WHERE
; __4ern_SQL__QueryBuilder__groupBy
; __4ern_SQL__QueryBuilder__Orderby
; ===============================================================================================================================

; #GLOBAL CONSTANTS# ============================================================================================================
; FUNKTIONS KONSTANTEN 
; ===============================================================================================================================
	$SQL_debug            = __4ern_SQL_Console_startUp
	$SQL_connect          = __4ern_SQL_Connect
	$SQL_returnType       = __4ern_SQL_defReturn
	$SQL_setDefaultTable  = __4ern_SQL__QueryBuilder__setTable
	$SQL_setDefaultKey    = __4ern_SQL__QueryBuilder__setkey
	$SQL_setDatabase	  = __4ern_set_SQL_Connection
	
	$SQL_get              = __4ern_SQL_QueryBuilder_get
	$SQL_update           = __4ern_SQL_QueryBuilder_Update
	$SQL_delete           = __4ern_SQL_QueryBuilder_Delete
	$SQL_insertInto       = __4ern_SQL_Query_insert
	$SQL_take	          = __4ern_SQL__QueryBuilder__limit
	$SQL_limit	          = __4ern_SQL__QueryBuilder__limit
	$SQL_table            = __4ern_SQL_Query_table
	$SQL_select           = __4ern_SQL_Query_select
	$SQL_distinct         = __4ern_SQL_Query_distinct
	$SQL_where            = __4ern_SQL_Query_where
	$SQL_orWhere          = __4ern_SQL_Query_orWhere
	$SQL_whereBetween     = __4ern_SQL_Query_whereBetween
	$SQL_whereNotBetween  = __4ern_SQL_Query_whereNotBetween
	$SQL_whereIn          = __4ern_SQL_Query_whereBetween
	$SQL_whereNotIn       = __4ern_SQL_Query_whereNotBetween
	$SQL_whereNull        = __4ern_SQL_Query_whereNull
	$SQL_whereNotNull     = __4ern_SQL_Query_whereNotNull
	$SQL_having           = __4ern_SQL_Query_having
	$SQL_orHaving         = __4ern_SQL_Query_orHaving
	$SQL_havingBetween    = __4ern_SQL_Query_havingBetween
	$SQL_havingNotBetween = __4ern_SQL_Query_havingNotBetween
	$SQL_havingIn         = __4ern_SQL_Query_havingIn
	$SQL_havingNotIn      = __4ern_SQL_Query_havingNotIn
	$SQL_havingNull       = __4ern_SQL_Query_havingNull
	$SQL_havingNotNull    = __4ern_SQL_Query_havingNotNull
	$SQL_groupBy          = __4ern_SQL__QueryBuilder__groupBy
	$SQL_orderBy          = __4ern_SQL_Query_orderBy
	$SQL_raw			  = __4ern_SQL_rawQueryExpr

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: Return Type 
; ...............: Default: Object Dictionary
; ...............: Array 
; ===============================================================================================================================
func __4ern_SQL_defReturn($ptype = DEFAULT)
	Local Static $rType = 'array'
	if __4ern_SQL__IsDefault($ptype, '-1,', ',') Then return $rType
	if $ptype = 'array' Then $rType = 'array'
	if $ptype = 'oDict' Then $rType = 'oDict'
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: set Default Database
; ...............: Default: MySQL
; ===============================================================================================================================
func __4ern_set_SQL_Connection($database = 'mysql')
	__4ern_SQL_Connection('set', -1, -1, -1, -1, -1, $database)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: set Connectionstrings
; ...............: Default: MySQL
; ...............: ConnectionString
;
; ...............: https://www.connectionstrings.com
; ===============================================================================================================================
func __4ern_SQL_Connection($action = 'getDatabase', $SERVER=NULL, $DB=NULL, $USER=NULL, $PASSWORD=NULL, $DRIVER=NULL, $database=NULL) 
	
	local static $databaseDefault

	;----------------------------------------------------------------------------------------------/
	; setze die Standart Datenbank
	;----------------------------------------------------------------------------------------------/
	if $action = 'set' then
		$databaseDefault = $database
		return $databaseDefault
	endif

	;----------------------------------------------------------------------------------------------/
	; Übergebe die gesetzte Database
	;----------------------------------------------------------------------------------------------/
	if $action = 'getDatabase' then return $databaseDefault

	;----------------------------------------------------------------------------------------------/
	; Übergebe den Connectionstring
	;----------------------------------------------------------------------------------------------/
	if $action = 'getConnectionString' then
		switch $databaseDefault
			
			case 'mySql'
				if __4ern_SQL__IsDefault($DRIVER, '-1,', ',') then 
					return StringFormat('Driver={MySQL ODBC 5.3 ANSI Driver};Server=%s;Database=%s;User=%s;Password=%s;',$SERVER, $DB, $USER, $PASSWORD)
				endif
				return StringFormat('Driver={%s};Server=%s;Database=%s;User=%s;Password=%s;',$DRIVER, $SERVER, $DB, $USER, $PASSWORD)
				
			case 'sqlServer'
				if __4ern_SQL__IsDefault($DRIVER, '-1,', ',') then 
					return StringFormat('DRIVER={SQL Server};SERVER=%s;DATABASE=%s;uid=%s;pwd=%s;',$SERVER, $DB, $USER, $PASSWORD)
				endif
				return StringFormat('DRIVER={%s};SERVER=%s;DATABASE=%s;uid=%s;pwd=%s;', $DRIVER, $SERVER, $DB, $USER, $PASSWORD)
			
			case 'access'
				if __4ern_SQL__IsDefault($DRIVER, '-1,', ',') then 
					return StringFormat('Driver={Microsoft Access Driver (*.mdb)};%s;Uid=%s;Pwd=%s;',$DB, $USER, $PASSWORD)
				endif
				return StringFormat('Driver={%s};%s;Uid=%s;Pwd=%s;',$DRIVER, $DB, $USER, $PASSWORD)

			case 'sqLite'
				if __4ern_SQL__IsDefault($DRIVER, '-1,', ',') then 
					return StringFormat('DRIVER=SQLite3 ODBC Driver;Database=%s;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;',$DB)
				endif
				return StringFormat('DRIVER=%s;Database=%s;LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;', $DRIVER, $DB)
		endswitch
	endif
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: MSSQL ADO Connection Object
; =====================================================================================================================
func __4ern_SQL_Connect($pDB = DEFAULT, $pUSER = DEFAULT, $pPASSWORD = DEFAULT, $pSERVER = DEFAULT, $pDRIVER = DEFAULT, $ACTION = DEFAULT)
	
	;----------------------------------------------------------------------------------------------/
	; Deklaration
	;----------------------------------------------------------------------------------------------/
	Global $gO__4ern_SQLError = ObjEvent("AutoIt.Error", "__4ern_SQL_errFunc")
	Local Static $oCon, $SERVER = NULL, $DB = NULL, $USER = NULL, $PASSWORD = NULL, $DRIVER, $conInfo = NULL

	;----------------------------------------------------------------------------------------------/
	; Erstelle ein ADODB Verbindung
	;----------------------------------------------------------------------------------------------/
	$oCon                   = ObjCreate('ADODB.Connection')
	$oCon.ConnectionTimeout = 30	

	;----------------------------------------------------------------------------------------------/
	; Setze DEFAULTS
	;----------------------------------------------------------------------------------------------/
	IF $ACTION 	  =  DEFAULT THEN $ACTION 	= 'get()'
	IF $pDB       <> DEFAULT THEN $DB       = $pDB
	IF $pUSER     <> DEFAULT THEN $USER     = $pUSER
	IF $pPASSWORD <> DEFAULT THEN $PASSWORD = $pPASSWORD
	IF $pSERVER   <> DEFAULT THEN $SERVER   = $pSERVER
	IF $pDRIVER   <> DEFAULT THEN $DRIVER   = $pDRIVER

	;----------------------------------------------------------------------------------------------/
	; Prüfe ob alle Zugangsparameter vorhanden sind.
	;----------------------------------------------------------------------------------------------/
	$errorLogin = False
	switch __4ern_SQL_Connection()
		case 'mySql'
			If ($DB = NULL) OR ($USER = NULL) OR ($PASSWORD = NULL) OR ($SERVER = NULL) Then $errorLogin = True
		case 'sqlServer'
			If ($DB = NULL) OR ($USER = NULL) OR ($PASSWORD = NULL) OR ($SERVER = NULL) Then $errorLogin = True
		case 'access'
			If ($DB = NULL) OR ($USER = NULL) OR ($PASSWORD = NULL) Then $errorLogin = True
		case 'sqLite'
			If ($DB = NULL) Then $errorLogin = True
	endswitch
	
	If ($errorLogin = True) Then 
		__4ern_SQL_Console('error', 'Fehler!', 'Eines der Zugangsparameter´oder der Datenbankpfad wurde nicht angegeben.')
		return SetError(1, '', $error)
	endif

	;----------------------------------------------------------------------------------------------/
	; Connection Information
	;----------------------------------------------------------------------------------------------/
	if $conInfo == NULL then
		__4ern_SQL_Console('info', 'Connection String', StringFormat('DATABASE=%s, SERVER=%s, DATABASE=%s, $USER=%s, PW=***, TimeOut=%s',__4ern_SQL_Connection(), $SERVER, $DB, $USER, $oCon.ConnectionTimeout))
		$conInfo = 1
	endif

	;----------------------------------------------------------------------------------------------/
	; Schließe Connection falls diese offen ist.
	;----------------------------------------------------------------------------------------------/
	if not $oCon.state = 0 then $oCon.close

	;----------------------------------------------------------------------------------------------/
	; Action
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION

		;----------------------------------------------------------------------------------------------/
		; Verbindungsaufbau
		;----------------------------------------------------------------------------------------------/
		Case 'write()'
	
			;----------------------------------------------------------------------------------------------/
			; Wenn Objekt erstellt wurde, stelle Verbindung her.
			;----------------------------------------------------------------------------------------------/
			If IsObj($oCon) Then
				;----------------------------------------------------------------------------------------------/
				; Object Mode
				;----------------------------------------------------------------------------------------------/
				$oCon.Mode = 16 

			Else
				__4ern_SQL_Console('error', '$oCon = ObjCreate', 'ADODB Objekt konnte nicht erstellt werden.')
				return SetError(3, '', 0)
			EndIf

		;----------------------------------------------------------------------------------------------/
		; Beende die ADODB Verbindung
		;----------------------------------------------------------------------------------------------/
		Case 'get()'

			;----------------------------------------------------------------------------------------------/
			; Wenn Objekt erstellt wurde, stelle Verbindung her.
			;----------------------------------------------------------------------------------------------/
			If IsObj($oCon) Then
				;----------------------------------------------------------------------------------------------/
				; Cursor Side
				;----------------------------------------------------------------------------------------------/
				$oCon.CursorLocation = 3

			Else
				__4ern_SQL_Console('error', '$oCon = ObjCreate', 'ADODB Objekt konnte nicht erstellt werden.')
				return SetError(3, '', 0)
			EndIf

		Case 'reset()'
			$oCon.close
			$conInfo  = NULL
			$SERVER   = NULL
			$DB       = NULL
			$USER     = NULL
			$PASSWORD = NULL
			return
	EndSwitch

	;----------------------------------------------------------------------------------------------/
	; SQL Server Connection String
	;----------------------------------------------------------------------------------------------/
	$oCon.Open(__4ern_SQL_Connection('getConnectionString', $SERVER, $DB, $USER, $PASSWORD, $DRIVER))
	IF @error then
		__4ern_SQL_Console('error', '$oCon.Open', 'Verbindung zum Server konnte nicht hergestellt werden.')
		return SetError(2, '', 0)
	endif
	
	;----------------------------------------------------------------------------------------------/
	; Retrun ADO Connection Object
	;----------------------------------------------------------------------------------------------/
	return $oCon
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: ADO SQL Execute
; ===============================================================================================================================
func __4ern_SQL_rawQuery($pQuery = DEFAULT, $ACTION = DEFAULT)

	;----------------------------------------------------------------------------------------------/
	; Local Statics
	;----------------------------------------------------------------------------------------------/
	Local $oRecordSet, $error

	;----------------------------------------------------------------------------------------------/
	; DEFAULT
	;----------------------------------------------------------------------------------------------/
	if ($ACTION = DEFAULT) or ($ACTION = -1) or ($ACTION = '') then $ACTION = 'get()'

	;----------------------------------------------------------------------------------------------/
	; Erstelle eine Verbindung zur DB
	;----------------------------------------------------------------------------------------------/
	if $ACTION == 'get()' Then 	
		$oCon = __4ern_SQL_Connect()
	else
		$oCon = __4ern_SQL_Connect(DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 'write()')
	endif
	
	if @error or IsObj($oCon) = 0 then return SetError(@error, '', $oCon)

	;----------------------------------------------------------------------------------------------/
	; FastEscape 
	;----------------------------------------------------------------------------------------------/
	$pQuery = StringReplace($pQuery, '"', "'")
	$pQuery = StringReplace($pQuery, '`', '"')
	__4ern_SQL_Console('SQL', $pQuery)

	;----------------------------------------------------------------------------------------------/
	; Führe Query aus
	;----------------------------------------------------------------------------------------------/
	$oRecordSet = $oCon.Execute($pQuery)
	if @error Then 
		$error = '4ern SQL Error -- Query konnte nicht ausgefuehrt werden.'
		__4ern_SQL_Console('error', '$oCon.Execute($pQuery)', 'Query konnte nicht ausgefuehrt werden.')
		$oCon.close
		return SetError(@error, '', $oRecordSet)
	endif

	;----------------------------------------------------------------------------------------------/
	; Prüfe ob Query Daten enthält
	;----------------------------------------------------------------------------------------------/
	if $action == 'get()' then
		if $oRecordSet.eof Then
			__4ern_SQL_Console('warning', '$oRecordSet.eof Query enthält keine Daten')
			$oCon.close
			return SetError(1, '', 0)
		endif
	endif

	;----------------------------------------------------------------------------------------------/
	; Return Switch
	;----------------------------------------------------------------------------------------------/
	Switch $action 

		;----------------------------------------------------------------------------------------------/
		; Übergibt alle Werte
		;----------------------------------------------------------------------------------------------/
		Case StringInStr($action, 'get()') <> 0
			return __4ern_SQL_raw_getAll($oRecordSet, $oCon)

		Case StringInStr($action, 'update()') <> 0
			return 1
	EndSwitch
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; ===============================================================================================================================
func __4ern_SQL_raw_getAll($oRecordSet, $oCon)

	;----------------------------------------------------------------------------------------------/
	; Return Typ
	;----------------------------------------------------------------------------------------------/
	Local CONST $rType = __4ern_SQL_defReturn()

	;----------------------------------------------------------------------------------------------/
	; Ermittle die Anzahl der Ergebniss
	;----------------------------------------------------------------------------------------------/

	if $oRecordSet.RecordCount = 1 then 
		return __4ern_SQL_raw_getFirst($oRecordSet, $rType, $oCon)
	endif

	;----------------------------------------------------------------------------------------------/
	; Erstellung der Array mit Spaltnamen
	;----------------------------------------------------------------------------------------------/
	
		;----------------------------------------------------------------------------------------------/
		; Return Typ
		;----------------------------------------------------------------------------------------------/
		Switch $rType

			;----------------------------------------------------------------------------------------------/
			; Return als Object Dictionary
			;----------------------------------------------------------------------------------------------/
			Case 'oDict'

				;----------------------------------------------------------------------------------------------/
				; Haupt Dictionary
				;----------------------------------------------------------------------------------------------/
				Local $oDict = ObjCreate('Scripting.Dictionary')

				;----------------------------------------------------------------------------------------------/
				; Ermittle Row Key
				;----------------------------------------------------------------------------------------------/
				$oRecordSet = $oRecordSet.Clone
				$rRowKey = __4ern_SQL__QueryBuilder__setTable(-1, -1, 'getTKey')

				;----------------------------------------------------------------------------------------------/
				; Anzahl der Spalte
				;----------------------------------------------------------------------------------------------/
				$i_Colum = $oRecordSet.Fields.Count

				;----------------------------------------------------------------------------------------------/
				; Prüfe ob RowKey Colm vorhanden ist.
				; 	--> Wenn nicht vorhanden, werden Zeilennummern als RowKey genutzt
				;----------------------------------------------------------------------------------------------/
				$bColm = false
				for $i = 0 to $i_Colum -1
					if $oRecordSet.Fields($i).Name == $rRowKey then 
						$bColm = True
						ExitLoop
					endif
				next

				;----------------------------------------------------------------------------------------------/
				; Erstelle die Spalten
				;----------------------------------------------------------------------------------------------/
				for $element in $oRecordSet.Fields
					$oDict.add($element.Name, ObjCreate('Scripting.Dictionary'))
				next

				;----------------------------------------------------------------------------------------------/
				; Erstelle ein Dictionary Object
				;----------------------------------------------------------------------------------------------/
				while Not $oRecordSet.eof
					$rowKey = ($bColm = True) ? $oRecordSet.Fields($rRowKey).Value : $oRecordSet.AbsolutePosition
					for $element in $oRecordSet.Fields
						$oDict($element.Name).add($rowKey,$element.Value)
					next
					$oRecordSet.MoveNext
				wend
				$oCon.close
				return $oDict

			;----------------------------------------------------------------------------------------------/
			; Return als Array
			;----------------------------------------------------------------------------------------------/
			Case 'array'
				With $oRecordSet
					Local $iFields = .Fields.Count
					Local $sFields[1][$iFields] 
					for $i = 0 to $iFields -1
						$sFields[0][$i] = .Fields($i).Name
					next
					$aValue = .GetRows()
				Endwith
				_ArrayConcatenate($sFields, $aValue)
		EndSwitch

	;----------------------------------------------------------------------------------------------/
	; Retrun Array
	;----------------------------------------------------------------------------------------------/
	$oCon.close
	return $sFields
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; ===============================================================================================================================
func __4ern_SQL_raw_getFirst($oRecordSet, $rType, $oCon)
	
		;----------------------------------------------------------------------------------------------/
		; Return Typ
		;----------------------------------------------------------------------------------------------/
		Switch $rType

			;----------------------------------------------------------------------------------------------/
			; Return als Object Dictionary
			;----------------------------------------------------------------------------------------------/
			Case 'oDict'
				Local $oDict = ObjCreate('Scripting.Dictionary')
				for $elemet in $oRecordSet.Fields
					$oDict.Add($elemet.Name, $elemet.Value)
				next
				$oCon.close
				return $oDict

			;----------------------------------------------------------------------------------------------/
			; Return als Array
			;----------------------------------------------------------------------------------------------/
			Case 'array'
				Local $array[$oRecordSet.Fields.Count]
				Local $i = 0
				for $row in $oRecordSet.Fields
					$array[$i] = $row.Value
					$i += 1
				next
				$oCon.close
				return $array

		Endswitch	
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: Console Dubugger
; ===============================================================================================================================
func __4ern_SQL_Console_startUp($mode = 'Console')
	__4ern_SQL_Console('set',$mode)
	return
endfunc
func __4ern_SQL_Console($ACTION = DEFAULT, $PTITEL = 'none', $PTXT = 'none')
	
	Local Static $Output = NULL

	;----------------------------------------------------------------------------------------------/
	; Art der Ausgabe!
	;-------------------------------------------------s---------------------------------------------/
		SELECT 
			;----------------------------------------------------------------------------------------------/
			; Output to Console
			;----------------------------------------------------------------------------------------------/
			Case $Output == 'Console'
				Switch $ACTION
					Case 'error'
						$str = @CRLF &'*** FEHLER - ERROR **************************************************************************************'
						$str &=  @CRLF &'- Funktion:'&@tab&@tab&$PTITEL
						$str &=  @CRLF &'- TEXT:'&@tab&@tab&@tab&$PTXT
						$str &=  @CRLF &'*********************************************************************************************************'
					
					Case 'warning'
						$str = @CRLF &'*** Warning *********************************************************************************************'
						$str &=  @CRLF &'- TEXT:'&@tab&$PTITEL

					Case 'info'
						$str = @CRLF &'*** Information *****************************************************************************************'
						$str &=  @CRLF &'- Title:'&@tab&$PTITEL
						$str &=  @CRLF &'- TEXT:'&@tab&$PTXT

					Case 'SQL'
						$str = @CRLF &'*** RAW SQL *********************************************************************************************'
						$str &= @CRLF &'>> '&$PTITEL&' <<'
				EndSwitch
				ConsoleWrite($str & @CRLF)

			;----------------------------------------------------------------------------------------------/
			; SET OUTPUT
			;----------------------------------------------------------------------------------------------/
			Case $ACTION == 'set'
				$Output = $PTITEL
				return
		ENDSELECT

	;----------------------------------------------------------------------------------------------/
	; Return
	;----------------------------------------------------------------------------------------------/
	RETURN
endfunc

;----------------------------------------------------------------------------------------------/
; Beschreibung: = Object Error Info
; @return:      = bool
; von           = 4ern.de
;----------------------------------------------------------------------------------------------/
func __4ern_SQL_errFunc()
	$str = 	"We intercepted a COM Error !" 		  & @CRLF & @CRLF                             & _
			"err.description is: "                & @TAB  & $gO__4ern_SQLError.description    & @CRLF & _
			"err.windescription:"                 & @TAB  & $gO__4ern_SQLError.windescription & @CRLF & _
			"err.number is: "                     & @TAB  & Hex($gO__4ern_SQLError.number, 8) & @CRLF & _
			"err.lastdllerror is: "               & @TAB  & $gO__4ern_SQLError.lastdllerror   & @CRLF & _
			"err.scriptline is: "                 & @TAB  & $gO__4ern_SQLError.scriptline     & @CRLF & _
			"err.source is: "                     & @TAB  & $gO__4ern_SQLError.source         & @CRLF & _
			"err.helpfile is: "                   & @TAB  & $gO__4ern_SQLError.helpfile       & @CRLF & _
			"err.helpcontext is: "                & @TAB  & $gO__4ern_SQLError.helpcontext
			
	__4ern_SQL_Console('error', 'SQL ERROR', $str)
	Return 1
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: BugFix
; ===============================================================================================================================
Func __4ern_SQL__IsDefault($var, $sOtherDefaults='-0', $sDelim=Default)
	Local $aDef[1] = [0], $match = 0
	If IsKeyword($sDelim) Then $sDelim = Opt('GUIDataSeparatorChar')
	If $sOtherDefaults <> '-0' Then $aDef = StringSplit($sOtherDefaults, $sDelim, 1)
	If Not $aDef[0] Then Return IsKeyword($var)
	For $i = 1 To $aDef[0]
		If $var = $aDef[$i] Then $match = 1
	Next
	If Not $match Then Return IsKeyword($var)
	Return 1
EndFunc