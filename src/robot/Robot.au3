#include <Array.au3>

; Robot -w "title" [-k keys] [-b button] [-t timeout]
; Return ERRORLEVEL:
; -1 Window title not informed
; -2 Window not found (timeout error)
; -3 Keys couldn't be sent to the informed window
; -4 Button couldn't be clicked at the informed window
Local $title = ""
Local $keys = ""
Local $button = ""
Local $timeout = 0

Local $buttons[4][2]
$buttons[0][0] = "OK"
$buttons[0][1] = 1
$buttons[1][0] = "YES"
$buttons[1][1] = 1
$buttons[2][0] = "NO"
$buttons[2][1] = 2
$buttons[3][0] = "CANCEL"
$buttons[3][1] = 3

; AutoIt Settings
AutoItSetOption("WinTitleMatchMode", -2) ; Match any substring in the title, case insensitive

; Loop through the informed commands
$i = 1

While $i <= $CmdLine[0]
   If StringLeft($CmdLine[$i], 1) = "-" Then
	  Switch StringLower($CmdLine[$i])
		 Case "-w"
			$i += 1
			$title = $CmdLine[$i]
		 Case "-k"
			$i += 1
			$keys = $CmdLine[$i]
		 Case "-b"
			$i += 1
			$button = $CmdLine[$i]
		 Case "-t"
			$i += 1
			$timeout = $CmdLine[$i]
	  EndSwitch
   EndIf

   $i += 1
WEnd

; Validate if the window title was informed
If $title = "" Then Exit(-1)

; Try to locate window with the informed title
$whWnd = WinWait($title, "", $timeout / 1000)
If $whWnd = 0 Then Exit(-2)

WinActivate($whWnd)

If $keys <> "" Then
   If SendKeys($whWnd, $keys) <> 0 Then Exit(-3)
EndIf


If $button <> "" Then
   $index = _ArraySearch($buttons, $button)
   If ClickButton($whWnd, "[CLASS:Button; INSTANCE:"&$buttons[$index][1]&"]") <> 0 Then Exit(-4)
EndIf

; Execute a send keys event on a opened window
; Sometimes, when Windows is locked, the keys are not sent at the first time.
; In this case we test the window text, if the text does not exist, the keys
; are sent at least 2 more times before throwing an error.
Func SendKeys($window, $keys, $retries = 30)
   WinActivate($whWnd)
   ControlSend($window, "", "", $keys)

   If WinExists($window, $keys) Then
	  Return 0
   Else
	  Sleep(500)
	  $retries -= 1

	  If $retries > 0 Then
		 Return SendKeys($window, $keys, $retries)
	  Else
		 Return 1
	  EndIf
   EndIf
EndFunc


; Execute a click event on a OE AlertBox Window
; Sometimes, when Windows is locked, the click does not work at the first time.
; In this case we test the window handle, if still exists, the click is retried
; at least 2 more times before throwing an error.
Func ClickButton($window, $control, $retries = 30)
   WinActivate($whWnd)
   ControlClick($whWnd, "", $control)

   If Not WinExists($whWnd) Then
	  Return 0
   Else
	  Sleep(500)
	  $retries -= 1

	  If $retries > 0 Then
		 Return ClickButton($window, $control, $retries)
	  Else
		 Return 1
	  EndIf
   EndIf
EndFunc


; Exit application
Exit(0)
