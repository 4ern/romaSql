#include 'romaSql.au3'
#include <Array.au3>

;-----/
; SQLite Connection + Settings
;-----/
$SQL_setDatabase('sqlite')
$SQL_connect(@scriptdir & '\chinook.db')
$SQL_setDefaultTable('customers')
$SQL_debug()

;-----/
; Get Customers
;-----/
$SQL_table('customers')
	$SQL_where('country', 'Germany')
	$SQL_orWhere('country', 'France')
	$SQL_whereNotNull('email')
	$SQL_orderBy('country', 'desc')
$aCustomers = $SQL_get()



If IsArray($aCustomers) Then
	_ArrayDisplay($aCustomers, 'Debug Array Line 16')
Else
	ConsoleWrite('Error Line 16: "$aCustomers" isnt an array' & @LF)
EndIf
