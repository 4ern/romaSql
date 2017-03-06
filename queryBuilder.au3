#include-once
#include 'romaSql.au3'

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Building ......:
;				   - SELECT oder DISTINCT
;				   - Take (only sqlServer)
;				   - From Table
;				   - LIMIT
;				   - Joins - (in Plannung)
;				   - WHERE
;				   - Groupby
;				   - Having
;				   - Order BY
; ===============================================================================================================================
func __4ern_SQL_QueryBuilder_get()

	Local $SQL = Null
	
	;----------------------------------------------------------------------------------------------/
	; Stelle SQL String zusammen.
	;----------------------------------------------------------------------------------------------/
		$select  = __4ern_SQL__QueryBuilder__select('get')
		$from    = __4ern_SQL__QueryBuilder__table('get')
		if @error then return SetError(@error, 0, $from)

		;----------------------------------------------------------------------------------------------/
		; Bei SQL-Server nehmen Take anstatt von LIMIT
		;----------------------------------------------------------------------------------------------/
		$limit   = (__4ern_SQL_Connection() <> 'sqlServer') ? __4ern_SQL__QueryBuilder__limit(-1,'get') : ''
		$where   = __4ern_SQL__QueryBuilder__where('getWhere')
		$groupBy = __4ern_SQL__QueryBuilder__groupBy('get')
		$having  = __4ern_SQL__QueryBuilder__where('getHaving')
		$orderBy = __4ern_SQL__QueryBuilder__orderBy('get')

	;----------------------------------------------------------------------------------------------/
	; Erstelle SQL String
	;----------------------------------------------------------------------------------------------/
		$SQL = StringStripWS($select & $from & $where & $groupBy & $having & $orderBy & $limit, 4)

	;----------------------------------------------------------------------------------------------/
	; Feuere Abfrage ab.
	;----------------------------------------------------------------------------------------------/
	$ret = __4ern_SQL_rawQuery($SQL,'get()')
	return SetError(@error, 0, $ret)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: UPDATE Statement
; Source.........: https://www.w3schools.com/sql/sql_update.asp
; ===============================================================================================================================	
func __4ern_SQL_QueryBuilder_Update(ByRef $COLM, $VAL = DEFAULT)

	Local $SQL    = NULL
	Local $String = ''

	;----------------------------------------------------------------------------------------------/
	; Erstelle Update String
	;----------------------------------------------------------------------------------------------/
		if IsArray($COLM) then 
			$iColm = UBound($COLM, 2)
			Select

				;----------------------------------------------------------------------------------------------/
				; 1D Array
				;----------------------------------------------------------------------------------------------/
				Case $iColm = 0
					__4ern_SQL_Console('error', 'UPDATE -- QUERY BUILDER', '2D Array erforderlich')
					return SetError(1, 0, 0)

				Case $iColm > 2
					__4ern_SQL_Console('error', 'UPDATE -- QUERY BUILDER', '2D Array erforderlich')
					return SetError(1, 0, 0)

				;----------------------------------------------------------------------------------------------/
				; 2D Array with 2 Colms
				; Without Operators
				;----------------------------------------------------------------------------------------------/
				Case $iColm = 2
					for $i = 0 to $iColm -1
						if (IsString($COLM[$i][1]) = 1) and (StringRegExp($COLM[$i][1], '\w*\(\)|NULL') = 0) then
							$String &= StringFormat('%s="%s", ',$COLM[$i][0],$COLM[$i][1])
						else
							$String &= StringFormat('%s=%s, ',$COLM[$i][0],$COLM[$i][1])
						endif
					next
					$String = StringReplace($String, ', ', '', -1)
			endselect
		else 
			if $VAL = DEFAULT then 
				__4ern_SQL_Console('error', 'UPDATE -- QUERY BUILDER', 'Es wurde kein Update Wert eingegeben')
				return SetError(1, 0, 0)
			endif
			if (IsString($VAL) = 1) and (StringRegExp($VAL, '\w*\(\)|NULL') = 0) then
				$String &= StringFormat('%s="%s" ',$COLM,$VAL)
			else
				$String &= StringFormat('%s=%s ',$COLM,$VAL)
			endif
		endif

	;----------------------------------------------------------------------------------------------/
	; Stelle SQL String zusammen.
	;----------------------------------------------------------------------------------------------/get')

		$table = __4ern_SQL__QueryBuilder__table('get')
		if @error then return SetError(@error, 0, $table)
		$table = StringReplace($table, 'FROM', 'UPDATE')
		$table = (StringSplit($table, ',', 2))[0] & ' SET '
		$where = __4ern_SQL__QueryBuilder__where('getWhere')

	;----------------------------------------------------------------------------------------------/
	; Erstelle SQL String
	;----------------------------------------------------------------------------------------------/
	$SQL = StringStripWS($table & $String &' '& $where, 4)

	;----------------------------------------------------------------------------------------------/
	; Feuere Abfrage ab.
	;----------------------------------------------------------------------------------------------/
	return __4ern_SQL_rawQuery($SQL,'update()')
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: DELTE Statement
; Source.........: https://www.w3schools.com/sql/sql_delete.asp
; ===============================================================================================================================
func __4ern_SQL_QueryBuilder_Delete()

	Local $SQL    = NULL
	Local $String = ''
	;----------------------------------------------------------------------------------------------/
	; Stelle SQL String zusammen.
	;----------------------------------------------------------------------------------------------/get')

		$table = __4ern_SQL__QueryBuilder__table('get')
		if @error then return SetError(@error, 0, $table)
		$where   = __4ern_SQL__QueryBuilder__where('getWhere')

	;----------------------------------------------------------------------------------------------/
	; Erstelle SQL String
	;----------------------------------------------------------------------------------------------/
	$SQL = StringStripWS('DELETE ' & $table & $String & $where, 4)

	;----------------------------------------------------------------------------------------------/
	; Feuere Abfrage ab.
	;----------------------------------------------------------------------------------------------/
	return __4ern_SQL_rawQuery($SQL,'update()')
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: INSERT INTO Statement
; Source.........: http://www.w3schools.com/sql/sql_insert.asp
; ===============================================================================================================================
func __4ern_SQL_Query_insert($COLM , $V1 = DEFAULT)

	local Static $table = __4ern_SQL__QueryBuilder__table('get')
		if @error then return SetError(@error, 0, $table)
	$table = StringReplace($table, 'FROM', 'INSERT INTO ')

	;----------------------------------------------------------------------------------------------/
	; Prüfen ob $COLM ein 2D Array ist..
	;----------------------------------------------------------------------------------------------/
	if IsArray($COLM) then

		;----------------------------------------------------------------------------------------------/
		; Check Array
		;----------------------------------------------------------------------------------------------/
		if UBound($COLM, 2) <> 2 then
			__4ern_SQL_Console('error', 'Insert Into -- QUERY BUILDER', 'Es muss ein 2D Array mit exakt 2 Spalten sein')
			return SetError(1, 0, 0)
		endif

		$string = ' ('
		for $i = 0 to Ubound($COLM) -1
			$string &= stringformat('%s,' ,$COLM[$i][0])
		next
		$string = StringReplace($string, ',', '', -1)
		
		$string &= ') VALUES('
		for $i = 0 to Ubound($COLM) -1
			if (IsString($COLM[$i][1]) = 1) and (StringRegExp($COLM[$i][1], '\w*\(\)|NULL') = 0) then 
				$COLM[$i][1] = StringReplace($COLM[$i][1], '"', '`')
				$COLM[$i][1] = StringReplace($COLM[$i][1], "'", '`')
				$string &= StringFormat('"%s",', $COLM[$i][1])
			else
				$string &= StringFormat('%s,', $COLM[$i][1])
			endif
		next
		$string = StringReplace($string, ',', '', -1)
		$string &= ');'
		
		;----------------------------------------------------------------------------------------------/
		; Erstelle SQL String
		;----------------------------------------------------------------------------------------------/
		$SQL = StringStripWS($table & $string,4)
		;----------------------------------------------------------------------------------------------/
		; Feuere Abfrage ab.
		;----------------------------------------------------------------------------------------------/

		return __4ern_SQL_rawQuery($SQL,'update()')
	endif

	;----------------------------------------------------------------------------------------------/
	; Insert über Parameter
	;----------------------------------------------------------------------------------------------/
	$V1 = StringReplace($V1, '"', '`')
	$V1 = StringReplace($V1, "'", '`')

	if (IsString($V1) = 1) and (StringRegExp($V1, '\w*\(\)|NULL') = 0) then
		$string = StringFormat('(%s) VALUES ("%s")', $COLM, $V1)
	else
		$string = StringFormat('(%s) VALUES (%s)', $COLM, $V1)
	endif

	$SQL = StringStripWS($table & $string,4)
	return __4ern_SQL_rawQuery($SQL,'update()')
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: Set table command
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__table($ACTION = DEFAULT, $COLM = DEFAULT)
	;----------------------------------------------------------------------------------------------/
	; Eigenschaften
	;----------------------------------------------------------------------------------------------/
	Local Static $QUEUE = ObjCreate("System.Collections.Queue")
	if IsObj($QUEUE) = 0 then $QUEUE = ObjCreate("System.Collections.Queue")
	if __4ern_SQL__IsDefault($ACTION, '-1,', ',') Then $ACTION = 'store'

	;----------------------------------------------------------------------------------------------/
	; AKTION
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION
		;----------------------------------------------------------------------------------------------/
		; Speichere die Select spalten in eine Queue
		;----------------------------------------------------------------------------------------------/
		Case 'store'
			;----------------------------------------------------------------------------------------------/
			; Array Verarbeitung
			; 	-> Ansonsten String
			;----------------------------------------------------------------------------------------------/
			IF IsArray($COLM) then 
				for $element in $COLM 
					if isstring($element) then $QUEUE.Enqueue($element)
				next
			ELSE
				if IsString($COLM) then $QUEUE.Enqueue($COLM)
			endif

		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'get'

			$String = 'FROM '
			;----------------------------------------------------------------------------------------------/
			; Wenn keine Einträge vorhanden, dann * 
			;----------------------------------------------------------------------------------------------/
			If $QUEUE.Count = 0 then 
				$ret =  __4ern_SQL__QueryBuilder__setTable(-1,-1,'getTable')
				if @error then return SetError(@error, 0, $ret)
				return $String & $ret & ' '
			endif
			;----------------------------------------------------------------------------------------------/
			; Erstelle String
			;----------------------------------------------------------------------------------------------/
			for $elemet in $QUEUE
				$String &= $elemet & ', '
			next
			;----------------------------------------------------------------------------------------------/
			; Lösche alle Einträge aus der Queue
			;----------------------------------------------------------------------------------------------/
			$QUEUE.clear

			;----------------------------------------------------------------------------------------------/
			; Return 
			;----------------------------------------------------------------------------------------------/				
			return StringReplace($String, ',', '', -1)
	
	EndSwitch
endfunc
func __4ern_SQL_Query_table($COLM = DEFAULT,$C1=DEFAULT,$C2=DEFAULT,$C3=DEFAULT,$C4=DEFAULT,$C5=DEFAULT,$C6=DEFAULT,$C7=DEFAULT,$C8=DEFAULT,$C9=DEFAULT)
	
	;----------------------------------------------------------------------------------------------/
	; Prüfen ob $COLM ein 2D Array ist..
	;----------------------------------------------------------------------------------------------/
	if IsArray($COLM) then
		if UBound($COLM, 2) <> 0 then
			__4ern_SQL_Console('error', 'TABLE -- QUERY BUILDER', 'Es sind nur 1D Arrays erlaubt')
			return SetError(1, 0, 0)
		endif
	endif

	;----------------------------------------------------------------------------------------------/
	; Übergabe der Parameter an QueryBuilder
	;----------------------------------------------------------------------------------------------/
	__4ern_SQL__QueryBuilder__table(-1,$COLM)

	;----------------------------------------------------------------------------------------------/
	; Param to Array
	;----------------------------------------------------------------------------------------------/
	$aParam = [$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9]
	for $param in $aParam
		if $param <> default then __4ern_SQL__QueryBuilder__table(-1,$param)
	next

	return 1
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: To limit the number of results returned from the query
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__limit($pLIMIT = DEFAULT, $ACTION = 'set')
	
	Local Static $LIMIT = NULL

	Switch $ACTION
		Case 'set'
			If IsNumber($pLIMIT) then 
				$LIMIT = $pLIMIT
				return
			endif
			__4ern_SQL_Console('error', 'TAKE/LIMIT -- QUERY BUILDER', 'Keine gueltige Nummer')

		Case 'get'
			if $LIMIT = NULL Then return ''

			Local $defDatabase = __4ern_SQL_Connection()
			;----------------------------------------------------------------------------------------------/
			; Return TOP für SQL Server Syntax
			;----------------------------------------------------------------------------------------------/
			if ($defDatabase = 'sqlserver') then return StringFormat(' TOP %s ', $LIMIT)

			;----------------------------------------------------------------------------------------------/
			; Setze eine Where Abfrage für Oracle Syntax
			;----------------------------------------------------------------------------------------------/
			if ($defDatabase = 'oracle') then
				__4ern_SQL_Query_where('ROWNUM','<=', $LIMIT)
				return ''
			endif

			;----------------------------------------------------------------------------------------------/
			; Return LIMIT
			;----------------------------------------------------------------------------------------------/
			return StringFormat(' LIMIT %s ', $LIMIT)
	EndSwitch
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: SELECT & DISTINCT Statement
; Source.........: http://www.w3schools.com/sql/sql_select.asp
; Source.........: http://www.w3schools.com/sql/sql_distinct.asp
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__select($ACTION = DEFAULT, $COLM = DEFAULT, $METHODE = 'SELECT')
	;----------------------------------------------------------------------------------------------/
	; Eigenschaften
	;----------------------------------------------------------------------------------------------/
	Local Static $QUEUE = ObjCreate("System.Collections.Queue")
	if __4ern_SQL__IsDefault($ACTION, '-1,', ',') Then $ACTION = 'store'
	Local Static $isMethode = Null

	;----------------------------------------------------------------------------------------------/
	; Setze Methode
	;----------------------------------------------------------------------------------------------/
	if $isMethode = Null then $isMethode = $METHODE

	;----------------------------------------------------------------------------------------------/
	; AKTION
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION

		;----------------------------------------------------------------------------------------------/
		; Speichere die Select spalten in eine Queue
		;----------------------------------------------------------------------------------------------/
		Case 'store'
			Switch $METHODE

				;----------------------------------------------------------------------------------------------/
				; Methode SELECT
				;----------------------------------------------------------------------------------------------/
				Case 'SELECT'
					if $isMethode <> $METHODE then
						__4ern_SQL_Console('error', 'SELECT -- QUERY BUILDER', 'Es wurde bereits die Methode DISTINCT aufgerufen.')
						return SetError(1, 0, 0) 
					endif

					;----------------------------------------------------------------------------------------------/
					; Array Verarbeitung
					; 	-> Ansonsten String
					;----------------------------------------------------------------------------------------------/
					IF IsArray($COLM) then 
						for $element in $COLM 
							if isstring($element) then $QUEUE.Enqueue($element)
						next
					ELSE
						if IsString($COLM) then $QUEUE.Enqueue($COLM)
					endif

				;----------------------------------------------------------------------------------------------/
				; Methode DISTINCT
				;----------------------------------------------------------------------------------------------/
				Case 'DISTINCT'
					if $isMethode <> $METHODE then
						__4ern_SQL_Console('error', 'DISTINCT -- QUERY BUILDER', 'Es wurde bereits die Methode SELECT aufgerufen.')
						return SetError(1, 0, 0) 
					endif

					;----------------------------------------------------------------------------------------------/
					; Array Verarbeitung
					; 	-> Ansonsten String
					;----------------------------------------------------------------------------------------------/
					IF IsArray($COLM) then 
						for $element in $COlM 
							if isstring($element) then $QUEUE.Enqueue($element)
						next
					ELSE
						if IsString($COlM) then $QUEUE.Enqueue($COlM)
					endif
			EndSwitch
		
		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'get'

			;----------------------------------------------------------------------------------------------/
			; Bei SQL-Server nehmen Take anstatt von LIMIT
			;----------------------------------------------------------------------------------------------/
			if __4ern_SQL_Connection = 'sqlServer' then
				Local $take = __4ern_SQL__QueryBuilder__limit(-1,'get')
				Local $String = StringFormat('%s %s ', $isMethode,  $take)
			else
				Local $String = $isMethode & ' '
			endif
			
			;----------------------------------------------------------------------------------------------/
			; Wenn keine Einträge vorhanden, dann * 
			;----------------------------------------------------------------------------------------------/
			If $QUEUE.Count = 0 then Return $String & '* '

			;----------------------------------------------------------------------------------------------/
			; Erstelle String
			;----------------------------------------------------------------------------------------------/
			for $elemet in $QUEUE
				$String &= $elemet & ', '
			next

			;----------------------------------------------------------------------------------------------/
			; Lösche alle Einträge aus der Queue
			;----------------------------------------------------------------------------------------------/
			while $QUEUE.Count <> 0
				$QUEUE.clear
			wend
			$isMethode = Null

			;----------------------------------------------------------------------------------------------/
			; Return 
			;----------------------------------------------------------------------------------------------/				
			return StringReplace($String, ',', '', -1)
	EndSwitch
endfunc
func __4ern_SQL_Query_select($COLM,$C1=DEFAULT,$C2=DEFAULT,$C3=DEFAULT,$C4=DEFAULT,$C5=DEFAULT,$C6=DEFAULT,$C7=DEFAULT,$C8=DEFAULT,$C9=DEFAULT)
	
	;----------------------------------------------------------------------------------------------/
	; Prüfen ob $COLM ein 2D Array ist..
	;----------------------------------------------------------------------------------------------/
	if IsArray($COLM) then
		if UBound($COLM, 2) <> 0 then
			__4ern_SQL_Console('error', 'SELECT -- QUERY BUILDER', 'Es sind nur 1D Arrays erlaubt')
			return SetError(1, 0, 0)
		endif
	endif

	;----------------------------------------------------------------------------------------------/
	; Übergabe der Parameter an QueryBuilder
	;----------------------------------------------------------------------------------------------/
	__4ern_SQL__QueryBuilder__SELECT(-1,$COLM)

	;----------------------------------------------------------------------------------------------/
	; Param to Array
	;----------------------------------------------------------------------------------------------/
	$aParam = [$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9]
	for $param in $aParam
		if $param <> default then __4ern_SQL__QueryBuilder__SELECT(-1,$param)
	next

	return 1
endfunc
func __4ern_SQL_Query_distinct($COLM,$C1=DEFAULT,$C2=DEFAULT,$C3=DEFAULT,$C4=DEFAULT,$C5=DEFAULT,$C6=DEFAULT,$C7=DEFAULT,$C8=DEFAULT,$C9=DEFAULT)
	
	;----------------------------------------------------------------------------------------------/
	; Prüfen ob $COLM ein 2D Array ist..
	;----------------------------------------------------------------------------------------------/
	if IsArray($COLM) then
		if UBound($COLM, 2) <> 0 then
			__4ern_SQL_Console('error', 'DISTINCT -- QUERY BUILDER', 'Es sind nur 1D Arrays erlaubt')
			return SetError(1, 0, 0)
		endif
	endif

	;----------------------------------------------------------------------------------------------/
	; Übergabe der Parameter an QueryBuilder
	;----------------------------------------------------------------------------------------------/
	__4ern_SQL__QueryBuilder__SELECT(-1,$COLM, 'DISTINCT')
	
	;----------------------------------------------------------------------------------------------/
	; Param to Array
	;----------------------------------------------------------------------------------------------/
	$aParam = [$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9]
	for $param in $aParam
		if $param <> default then __4ern_SQL__QueryBuilder__SELECT(-1,$param, 'DISTINCT')
	next


	return 1
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: WHERE Clause
; Source.........: http://www.w3schools.com/sql/sql_where.asp
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__where($ACTION = DEFAULT, $aVALUE = DEFAULT, $METHODE = DEFAULT, $SQL_OPERATOR = DEFAULT, $SET_QUE = DEFAULT)

	;----------------------------------------------------------------------------------------------/
	; Eigenschaften
	;----------------------------------------------------------------------------------------------/
	Local Static $WHERE_QUEUE    = ObjCreate("System.Collections.Queue")
	Local Static $HAVING_QUEUE   = ObjCreate("System.Collections.Queue")
	Local Static $bWhereBetween  = Null
	Local Static $bHavingBetween = Null
	Local Static $bWhereIn       = Null
	Local Static $bHavingIn      = Null

	;----------------------------------------------------------------------------------------------/
	; DEFAUL Eingenschaften
	;----------------------------------------------------------------------------------------------/
	if __4ern_SQL__IsDefault($ACTION, '-1,', ',') Then $ACTION             = 'store'
	if __4ern_SQL__IsDefault($SET_QUE, '-1,', ',') Then $SET_QUE           = 'WHERE'
	if __4ern_SQL__IsDefault($SQL_OPERATOR, '-1,', ',') Then $SQL_OPERATOR = 'AND'
	if __4ern_SQL__IsDefault($METHODE, '-1,', ',') Then $METHODE           = 'AND'

	;----------------------------------------------------------------------------------------------/
	; QUE
	;----------------------------------------------------------------------------------------------/
	if $SET_QUE = 'WHERE' then 
		$QUEUE    = $WHERE_QUEUE
		$bBetween = $bWhereBetween
		$bIn      = $bWhereIn
	endif

	if $SET_QUE = 'HAVING' then
		$QUEUE    = $HAVING_QUEUE
		$bBetween = $bHavingBetween
		$bIn      = $bHavingIn
	endif

	;----------------------------------------------------------------------------------------------/
	; METHODEN
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION
		Case 'store'

			;----------------------------------------------------------------------------------------------/
			; SQL Operator
			;----------------------------------------------------------------------------------------------/
			Switch $METHODE

				Case 'AND', 'OR'
					IF IsArray($aVALUE) then 
						for $element in $aVALUE 
							if isString($element) then $QUEUE.Enqueue(stringformat('%s (%s)', $METHODE, $element))
						next
					ELSE
						if IsString($aVALUE) then $QUEUE.Enqueue(stringformat('%s (%s)', $METHODE, $aVALUE))
					endif

				Case 'BETWEEN', 'NOT BETWEEN'
					if $bBetween = Null then
						if IsString($aVALUE) then $QUEUE.Enqueue(stringformat('%s (%s)', $SQL_OPERATOR, $aVALUE))
						$bBetween = 1
					else
						__4ern_SQL_Console('error', 'BETWEEN -- QUERY BUILDER', 'Der Parameter BETWEEN kann nur einmal pro Query erfolgen')
					endif

				Case 'IN', 'NOT IN'
					if $bIn = Null then
						if IsString($aVALUE) then $QUEUE.Enqueue(stringformat('%s (%s)', $SQL_OPERATOR, $aVALUE))
						$bIn = 1
					else
						__4ern_SQL_Console('error', 'BETWEEN -- QUERY BUILDER', 'Der Parameter BETWEEN kann nur einmal pro Query erfolgen')
					endif

				Case 'IS NULL', 'IS NOT NULL'
					IF IsArray($aVALUE) then 
						for $element in $aVALUE 
							if isString($element) then $QUEUE.Enqueue(stringformat('%s (%s)', $SQL_OPERATOR, $element))
						next
					ELSE
						if IsString($aVALUE) then $QUEUE.Enqueue(stringformat('%s (%s)', $SQL_OPERATOR, $aVALUE))
					endif
			EndSwitch

		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'getWhere'

			;**********************************************************************************************/
			; Ablauf
			;	- Erstelle String 'WHERE '
			;	- Anzahl der Que = 0 dan return String 'Where 1'
			;	- Erstelle String mit aus der Que heraus
			;	- Bereinige Static Variablen und leere die QUE
			;	- Bereinigung und Return des Strings
			;**********************************************************************************************/

			$String = 'WHERE '
			If $WHERE_QUEUE.Count = 0 then Return ''
			for $elemet in $WHERE_QUEUE
				$String &= $elemet & ' '
			next
			$WHERE_QUEUE.clear
			$bHavingBetween = Null
			$bHavingIn      = Null
			return StringStripWS(StringReplace(StringReplace($String, 'WHERE AND', 'WHERE', 1), 'WHERE OR', 'WHERE', 1), 4)

		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'getHaving'

			;**********************************************************************************************/
			; Ablauf
			;	- Erstelle String 'HAVING '
			;	- Anzahl der Que = 0 dan return String leer String
			;	- Erstelle String mit aus der Que heraus
			;	- Bereinige Static Variablen und leere die QUE
			;	- Bereinigung und Return des Strings
			;**********************************************************************************************/

			$String = 'HAVING '
			If $HAVING_QUEUE.Count = 0 then Return ''
			for $elemet in $HAVING_QUEUE
				$String &= $elemet & ' '
			next
			$HAVING_QUEUE.clear
			$bHavingBetween = Null
			$bHavingIn      = Null
			return StringStripWS(StringReplace(StringReplace($String, 'HAVING AND', 'WHERE', 1), 'HAVING OR', 'HAVING', 1), 4)

	EndSwitch
endfunc
func __4ern_SQL_Query_where($COLM,$V1 = DEFAULT, $V2 = DEFAULT, $METHODE = 'AND', $SET_QUE = DEFAULT)

	;----------------------------------------------------------------------------------------------/
	; Prüfen ob COLM ein 2D Array ist.
	;----------------------------------------------------------------------------------------------/
	if IsArray($COLM) Then
		$iColm = UBound($COLM, 2)
		Select

			;----------------------------------------------------------------------------------------------/
			; 1D Array
			;----------------------------------------------------------------------------------------------/
			Case $iColm = 0
				__4ern_SQL_Console('error', 'WHERE - HAVING -- QUERY BUILDER', '2D Array erforderlich')
				return SetError(1, 0, 0)

			;----------------------------------------------------------------------------------------------/
			; 2D Array with 2 Colms
			; Without Operators
			;----------------------------------------------------------------------------------------------/
			Case $iColm = 2
				for $i = 0 to Ubound($COLM) -1
					;----------------------------------------------------------------------------------------------/
					; Unterscheidung zwischen INT & String
					;----------------------------------------------------------------------------------------------/
					if IsString($COLM[$i][1]) then 
						$string = StringFormat('%s = "%s"', $COLM[$i][0], $COLM[$i][1])
					else
						$string = StringFormat('%s = %s', $COLM[$i][0], $COLM[$i][1])
					endif
					;----------------------------------------------------------------------------------------------/
					; Store Where String
					;----------------------------------------------------------------------------------------------/
					__4ern_SQL__QueryBuilder__WHERE(-1,$string, $METHODE, DEFAULT, $SET_QUE)
				next

			;----------------------------------------------------------------------------------------------/
			; 2D Array with 3 Colms
			; With Operators
			;----------------------------------------------------------------------------------------------/
			Case $iColm = 3
				for $i = 0 to Ubound($COLM) -1
					;----------------------------------------------------------------------------------------------/
					; Prüfung auf Parameter Gültigkeit
					;----------------------------------------------------------------------------------------------/
					if (StringRegExp($COLM[$i][1], '(<>|!=|>=|<=)')) = 0 and _ 
						(StringRegExp(StringMid($COLM[$i][1], 1, 1), '(=|<|>)')) = 0 Then
						ContinueLoop
					endif

					;----------------------------------------------------------------------------------------------/
					; Unterscheidung zwischen INT & String
					;----------------------------------------------------------------------------------------------/
					if IsString($COLM[$i][2]) then 
						$string = StringFormat('%s %s "%s"', $COLM[$i][0], $COLM[$i][1], $COLM[$i][2])
					else
						$string = StringFormat('%s %s %s', $COLM[$i][0], $COLM[$i][1], $COLM[$i][2])
					endif

					;----------------------------------------------------------------------------------------------/
					; Store Where String
					;----------------------------------------------------------------------------------------------/
					__4ern_SQL__QueryBuilder__WHERE(-1,$string, $METHODE, DEFAULT, $SET_QUE)
				next

			;----------------------------------------------------------------------------------------------/
			; 2D Array undefinierte Spalten
			;----------------------------------------------------------------------------------------------/
			Case Else
				__4ern_SQL_Console('error', 'WHERE - HAVING -- QUERY BUILDER', '2D Array hat mehr als 3 Spalten')
				return SetError(1, 0, 0)
		Endselect
	endif

	;----------------------------------------------------------------------------------------------/
	; Param Übergabe
	;----------------------------------------------------------------------------------------------/
	;----------------------------------------------------------------------------------------------/
	; Prüfen ob ein Vergleichswert übergeben wurde.
	;----------------------------------------------------------------------------------------------/
	If $V1 = DEFAULT then 
		__4ern_SQL_Console('error', 'WHERE - HAVING -- QUERY BUILDER', 'Es wurde kein Vergleichswert angegeben')
		return SetError(1, 0, 0)
	endif

	;----------------------------------------------------------------------------------------------/
	; Prüfe ob V1 ein Operator ist
	;----------------------------------------------------------------------------------------------/
	if (StringRegExp($V1, '(<>|!=|>=|<=)')) = 1 or _ 
		(StringRegExp(StringMid($V1, 1, 1), '(=|<|>)')) = 1 Then

		;----------------------------------------------------------------------------------------------/
		; Prüfe ob ein Vergleichswert angegeben wurde
		;----------------------------------------------------------------------------------------------/
		If $V2 = DEFAULT then 
			__4ern_SQL_Console('error', 'WHERE - HAVING -- QUERY BUILDER', 'Es wurde kein Vergleichswert angegeben')
			return SetError(1, 0, 0)
		endif

		;----------------------------------------------------------------------------------------------/
		; Unterscheidung zwischen INT & String
		;----------------------------------------------------------------------------------------------/
		if IsString($V2) then 
			$string = StringFormat('%s %s "%s"', $COLM, $V1, $V2)
		else
			$string = StringFormat('%s %s %s', $COLM, $V1, $V2)
		endif

		;----------------------------------------------------------------------------------------------/
		; Store Where String
		;----------------------------------------------------------------------------------------------/
		__4ern_SQL__QueryBuilder__WHERE(-1,$string, $METHODE, DEFAULT, $SET_QUE)
		return 1 
	else
		;----------------------------------------------------------------------------------------------/
		; Unterscheidung zwischen INT & String
		;----------------------------------------------------------------------------------------------/
		if IsString($V1) then 
			$string = StringFormat('%s = "%s"', $COLM, $V1)
		else
			$string = StringFormat('%s = %s', $COLM, $V1)
		endif
		;----------------------------------------------------------------------------------------------/
		; Store Where String
		;----------------------------------------------------------------------------------------------/
		__4ern_SQL__QueryBuilder__WHERE(-1,$string, $METHODE, DEFAULT, $SET_QUE)
		return 1
	endif
endfunc
func __4ern_SQL_Query_orWhere($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_where($COLM, $V1, $V2, 'OR')
	Return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_whereBetween($COLM, $V1 = DEFAULT, $V2 = DEFAULT, $METHODE = 'BETWEEN', $SET_QUE = DEFAULT)

	Select
		Case IsString($V1)
			if IsString($V2) = 0 then 
				__4ern_SQL_Console('error', 'WHERE '&$METHODE&' -- QUERY BUILDER', 'Beide Paremter muessen den selben Typ besitzen')
				return SetError(1, 0, 0)
			endif
			__4ern_SQL__QueryBuilder__WHERE(-1, StringFormat('%s %s "%s" AND "%s"',$COLM, $METHODE, $V1, $V2), $METHODE, DEFAULT, $SET_QUE)

		Case IsInt($V1)
			If IsInt($V2) = 0 then 
				__4ern_SQL_Console('error', 'WHERE '&$METHODE&' -- QUERY BUILDER', 'Beide Paremter muessen den selben Typ besitzen')
				return SetError(1, 0, 0)
			endif
			__4ern_SQL__QueryBuilder__WHERE(-1, StringFormat('%s %s %s AND %s',$COLM, $METHODE, $V1, $V2), $METHODE, DEFAULT, $SET_QUE)
	EndSelect
endfunc
func __4ern_SQL_Query_whereNotBetween($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereBetween($COLM, $V1, $V2, 'NOT BETWEEN')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_whereIn($COLM, $V1 = DEFAULT, $V2 = DEFAULT, $METHODE = 'IN', $SET_QUE = DEFAULT)

	Select
		case IsArray($V1)
			if UBound($V1, 2) = 0 then
				for $element in $V1
					if IsString($element) then 
						$string = StringFormat('%s %s "%s"', $COLM, $METHODE, $element)
					else
						$string = StringFormat('%s %s %s', $COLM, $METHODE, $element)
					endif
				next
				__4ern_SQL__QueryBuilder__WHERE(-1, $string, $METHODE, DEFAULT, $SET_QUE)			
				return 1			
			endif

		Case IsString($V1)
			if IsString($V2) = 0 then 
				__4ern_SQL_Console('error', 'WHERE '&$METHODE&' -- QUERY BUILDER', 'Beide Paremter muessen den selben Typ besitzen')
				return SetError(1, 0, 0)
			endif
			__4ern_SQL__QueryBuilder__WHERE(-1, StringFormat('%s %s "%s" AND "%s"',$COLM, $METHODE, $V1, $V2), $METHODE)

		Case IsInt($V1)
			If IsInt($V2) = 0 then 
				__4ern_SQL_Console('error', 'WHERE '&$METHODE&' -- QUERY BUILDER', 'Beide Paremter muessen den selben Typ besitzen')
				return SetError(1, 0, 0)
			endif
			__4ern_SQL__QueryBuilder__WHERE(-1, StringFormat('%s %s %s AND %s',$COLM, $METHODE, $V1, $V2), $METHODE, DEFAULT, $SET_QUE)
	EndSelect
endfunc
func __4ern_SQL_Query_whereNotIn($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereIn($COLM, $V1, $V2, 'NOT IN')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_whereNull($COLM, $METHODE = 'IS NULL', $SET_QUE = DEFAULT)
	$ret = __4ern_SQL__QueryBuilder__WHERE(-1, StringFormat('%s %s', $COLM, $METHODE), $METHODE, DEFAULT, $SET_QUE)
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_whereNotNull($COLM)
	$ret = __4ern_SQL_Query_whereNull($COLM, 'IS NOT NULL')
	return SetError(@error, 0, $ret)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: SQL HAVING Clause
; Source.........: http://www.w3schools.com/sql/sql_having.asp
; ===============================================================================================================================
func __4ern_SQL_Query_having($COLM,$V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_where($COLM,$V1, $V2, 'AND', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_orHaving($COLM,$V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_where($COLM,$V1, $V2, 'OR', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingBetween($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereBetween($COLM,$V1, $V2, 'BETWEEN', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingNotBetween($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereBetween($COLM,$V1, $V2, 'NOT BETWEEN', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingIn($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereIn($COLM,$V1, $V2, 'IN', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingNotIn($COLM, $V1 = DEFAULT, $V2 = DEFAULT)
	$ret = __4ern_SQL_Query_whereIn($COLM,$V1, $V2, 'NOT IN', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingNull($COLM)
	$ret = __4ern_SQL_Query_whereNull($COLM, 'IS NULL', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc
func __4ern_SQL_Query_havingNotNull($COLM)
	$ret = __4ern_SQL_Query_whereNull($COLM, 'IS NOT NULL', 'HAVING')
	return SetError(@error, 0, $ret)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: SQL GROUP BY Statement
; Source.........: http://www.w3schools.com/sql/sql_groupby.asp
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__groupBy($ACTION = DEFAULT, $COLM = DEFAULT)
	;----------------------------------------------------------------------------------------------/
	; Eigenschaften
	;----------------------------------------------------------------------------------------------/
	Local Static $QUEUE = ObjCreate("System.Collections.Queue")
	if __4ern_SQL__IsDefault($ACTION, '-1,', ',') Then $ACTION = 'store'

	;----------------------------------------------------------------------------------------------/
	; AKTION
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION

		;----------------------------------------------------------------------------------------------/
		; Speichere die Select spalten in eine Queue
		;----------------------------------------------------------------------------------------------/
		Case 'store'
			if IsString($COLM) then $QUEUE.Enqueue(stringformat('AND %s ', $COLM))
			return 1
		
		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'get'

			Local $SQL = 'GROUP BY '

			;----------------------------------------------------------------------------------------------/
			; Wenn keine Einträge vorhanden, dann * 
			;----------------------------------------------------------------------------------------------/
			If $QUEUE.Count = 0 then Return ''

			;----------------------------------------------------------------------------------------------/
			; Erstelle String
			;----------------------------------------------------------------------------------------------/
			for $elemet in $QUEUE
				$SQL &= $elemet
			next

			;----------------------------------------------------------------------------------------------/
			; Lösche alle Einträge aus der Queue
			;----------------------------------------------------------------------------------------------/
			$QUEUE.clear

			;----------------------------------------------------------------------------------------------/
			; Return 
			;----------------------------------------------------------------------------------------------/		
			return StringStripWS(StringReplace($SQL, 'BY AND', 'BY', 1), 4)	
	EndSwitch
endfunc
func __4ern_SQL_Query_groupBy($COLM)
	$ret = __4ern_SQL__QueryBuilder__groupBy(-1, $COLM)
	return SetError(@error, 0, $ret)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: SQL ORDER BY Keyword
; Source.........: http://www.w3schools.com/sql/sql_orderby.asp
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__Orderby($ACTION = DEFAULT, $COLM = DEFAULT)
	;----------------------------------------------------------------------------------------------/
	; Eigenschaften
	;----------------------------------------------------------------------------------------------/
	Local Static $QUEUE = ObjCreate("System.Collections.Queue")
	if __4ern_SQL__IsDefault($ACTION, '-1,', ',') Then $ACTION = 'store'

	;----------------------------------------------------------------------------------------------/
	; AKTION
	;----------------------------------------------------------------------------------------------/
	Switch $ACTION

		;----------------------------------------------------------------------------------------------/
		; Speichere die Select spalten in eine Queue
		;----------------------------------------------------------------------------------------------/
		Case 'store'
			;----------------------------------------------------------------------------------------------/
			; Array Verarbeitung
			; 	-> Ansonsten String
			;----------------------------------------------------------------------------------------------/
			if IsString($COLM) then $QUEUE.Enqueue($COLM)
		
		;----------------------------------------------------------------------------------------------/
		; Ermittle alle Elemete aus der Queue, und erstelle an Select String
		;----------------------------------------------------------------------------------------------/
		Case 'get'

			$string = 'ORDER BY '
			;----------------------------------------------------------------------------------------------/
			; Wenn keine Einträge vorhanden, dann * 
			;----------------------------------------------------------------------------------------------/
			If $QUEUE.Count = 0 then Return ''

			;----------------------------------------------------------------------------------------------/
			; Erstelle String
			;----------------------------------------------------------------------------------------------/
			for $elemet in $QUEUE
				$string &= $elemet & ', '
			next

			;----------------------------------------------------------------------------------------------/
			; Lösche alle Einträge aus der Queue
			;----------------------------------------------------------------------------------------------/
			$QUEUE.clear
			;----------------------------------------------------------------------------------------------/
			; Return 
			;----------------------------------------------------------------------------------------------/				
			return StringReplace($string, ',', '', -1)
	EndSwitch
endfunc
func __4ern_SQL_Query_orderBy($COLM,$V1='asc')
	
	;----------------------------------------------------------------------------------------------/
	; Prüfe ob ein valider Sortier wert eingegeben wurde
	;----------------------------------------------------------------------------------------------/
	if StringRegExp($V1, '(asc|desc)') = 0 then
		__4ern_SQL_Console('error', 'ORDER BY -- QUERY BUILDER', StringFormat('(%s) ist kein valider ORDER BY Keyword', $V1))
		return SetError(1, 0, 0)
	endif

	;----------------------------------------------------------------------------------------------/
	; Übergabe der Parameter an QueryBuilder
	;----------------------------------------------------------------------------------------------/
	$ret = __4ern_SQL__QueryBuilder__ORDERBY(-1,StringFormat('%s %s', $COLM, $V1))
	return SetError(@error, 0, $ret)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: Table DEFAULT Settings
; ===============================================================================================================================
func __4ern_SQL__QueryBuilder__setTable($P_TABLE = DEFAULT, $P_TKEY = DEFAULT, $ACTION = 'set')
	
	Local Static $S_table
	Local Static $S_tKey

	Switch $ACTION
		Case 'set'
			If not __4ern_SQL__IsDefault($P_TABLE, '-1,', ',') Then $S_table = $P_TABLE
			If not __4ern_SQL__IsDefault($P_TKEY, '-1,', ',') Then $S_tKey   = $P_TKEY
	
		;----------------------------------------------------------------------------------------------/
		; Tabelle übergeben.
		;----------------------------------------------------------------------------------------------/
		Case 'getTable'
			If not __4ern_SQL__IsDefault($S_table, '-1,', ',') Then 
				$S_table = DEFAULT
				return $S_table
			endif
			__4ern_SQL_Console('error', 'SQL Table', 'Es wurde keine Tabelle ausgewaehlt')
			return SetError(1, 0, 0)
		
		;----------------------------------------------------------------------------------------------/
		; Schlüssel übergeben
		;----------------------------------------------------------------------------------------------/
		Case 'getTKey'
			If not __4ern_SQL__IsDefault($S_tKey, '-1,', ',') Then return $S_tKey
			__4ern_SQL_Console('warning', 'Es wurde kein Tabellen Schluessel ausgewaehlt.')
			return $S_tKey

	EndSwitch
endfunc
func __4ern_SQL__QueryBuilder__setkey($key)

	__4ern_SQL__QueryBuilder__setTable(DEFAULT, $key)
endfunc

; #FUNCTION# ====================================================================================================================
; Author ........: 4ern.de
; Description....: RAW SQL Statement
; ===============================================================================================================================
func __4ern_SQL_rawQueryExpr($SQL)
	__4ern_SQL_rawQuery($SQL,'get()')
endfunc