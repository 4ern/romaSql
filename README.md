romaSQL
---
Diese autoIt UDF ist nach dem Prinzip von Laravel Query Builder & doctrine aufgebaut.
romaSQL ermöglicht eine neue, einfache & sehr bequeme Art von SQL Abfragen in autoIt.
Es werden bereits fast alle gängigen SQL Abfrage unterstützt und weitere folgen demnächst.

**Ich freue mich über jede Unterstützung von euch.**

##Connections

Für die Connection wird das Object ADODB genzutzt, daher bassieren die Connection String auf ODBC.

Natürlich kannst du auch OLEDB Connections Strings nutzen oder andere Datenbank Connections einbauen. Hierzu müssen deine Erweiterung in der Funktion `__4ern_SQL_Connection` erfolgen. *Ich würde mich sehr freuen, wenn du deine Veränderung mit mir teilen würdest*

###Derzeit unterstützte Connections

- MySQL (odbc)
- Microsoft SQL Server (odbc)
- SQLite (odbc)
- Microsoft Access (odbc)

##Befehls Referenz

```autoit
$SQL_connect; stellt die Verbindung her
$SQL_returnType; Ergebnisse in einem Array oder Dictionary ('oDict') Object (Default = Array)
$SQL_setDefaultTable; Setzte den standard Tabellennamen
$SQL_setDefaultKey; Setzt den standard Key (Default = id)
$SQL_debug; Wenn TRUE wird der SQL Befehl in der Console ausgegeben.
	
$SQL_get
$SQL_update
$SQL_delete
$SQL_insertInto
$SQL_take
$SQL_limit
$SQL_table
$SQL_select
$SQL_distinct

$SQL_where
$SQL_orWhere
$SQL_whereBetween
$SQL_whereNotBetween
$SQL_whereIn
$SQL_whereNotIn
$SQL_whereNull
$SQL_whereNotNull
$SQL_having
$SQL_orHaving
$SQL_havingBetween
$SQL_havingNotBetween
$SQL_havingIn
$SQL_havingNotIn
$SQL_havingNull
$SQL_havingNotNull
$SQL_groupBy
$SQL_orderBy
```

##In Plannung
- Database
	- SQL Create Table
	- SQL Drop Table
	- SQL Truncate Table
	- SQL Alter
	- SQL View
- Aggregates
	- SQL AVG() Function
	- SQL COUNT() Function
	- SQL SUM() Function
	- SQL MAX() Function
	- SQL MIN() Function
- SQL Joins
	- SQL INNER JOIN
	- SQL LEFT JOIN
	- SQL RIGHT JOIN
- Unions
- Oracle Connection
- PostgrSQl Connection

##Beispiele

**Create Connection** *muss nur einmal erfolgen*
```autoit
;-----/
; SQLite Connection
;-----/
$SQL_setDatabase('sqlite')
$SQL_connect('C:\project.db')

;-----/
; Access Connection
; Database, User, Password
;-----/
$SQL_setDatabase('access')
$SQL_connect('C:\project.mdb')
;or as Admin
$SQL_connect('C:\project.mdb', '4ern', 'root')

;-----/
; SQLServer Connection
; Database, User, Password, Server, Driver
;-----/
$SQL_setDatabase('sqlserver')
$SQL_connect('myDB', '4ern', 'root', 'localhost')
;or with Driver
$SQL_connect('myDB', '4ern', 'root', 'localhost', 'SQL Server')

;-----/
; MySQL Connection
; Database, User, Password, Server, Driver
;-----/
$SQL_setDatabase('mysql')
$SQL_connect('myDB', '4ern', 'root', 'localhost')
;or with Driver
$SQL_connect('myDB', '4ern', 'root', 'localhost', 'MySQL ODBC 5.2 UNICODE Driver')
```

**Einfache SQL Abfrage**
```autoit
$SQL_table('albums')
$aRet = $SQL_get()

if IsArray($aRet ) then
	_ArrayDisplay($aRet )
else
	ConsoleWrite('Keine Ergebnisse' & @LF)
endif
```

**Select**
```autoit
$SQL_table('albums')
$SQL_select('id', 'Name', 'Artist', 'Song')

;or pass to an Array
Local $aSelect = ['id', 'Name', 'Artist', 'Song']
$SQL_select($aSelect)

$aRet = $SQL_get()
if IsArray($aRet ) then
	_ArrayDisplay($aRet )
else
	ConsoleWrite('Keine Ergebnisse' & @LF)
endif
```

**where**
```autoit
$SQL_table('albums')
$SQL_select('id', 'Name', 'Artist', 'Song', 'Votes')
$SQL_where('Artist', 'adele')
$SQL_where('Votes', '>=' ,'9')
$SQL_orWhere('Artist', '=' ,'Rag'n'Bone Man')

;or pass to an 2dArray
Local $aSelect = [['Artist','adele'],['Votes', '>=' ,'9']]
$SQL_where($aSelect)

$aRet = $SQL_get()
if IsArray($aRet ) then
	_ArrayDisplay($aRet )
else
	ConsoleWrite('Keine Ergebnisse' & @LF)
endif
```

Ich hoffe euch gefällt meine UDF und Ihr findet einsatz hierfür.