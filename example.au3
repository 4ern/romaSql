#include 'romaSql.au3'
#include <Array.au3>


Local $aSelect = [['Artist','adele'],['Votes', '>=' ,'9']]
If IsArray($aSelect) Then
	_ArrayDisplay($aSelect, 'Debug Array Line 5')
Else
	ConsoleWrite('Error Line 5: "$aSelect" isnt an array' & @LF)
EndIf

exit
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
