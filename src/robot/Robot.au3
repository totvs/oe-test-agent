#include <Array.au3>

;
; ROBOT
;
; Company:
;	TOTVS
;
; Author:
;	Rubens dos Santos Filho
;
; Usage:
; 	robot -w "title|titles" [-k keys] [-b button] [-t timeout] [-p file]
;
; Parameters:
;	-w "title|titles" - Search and activate a window with the informed title
;   -k keys - Send the informed keyboard events to the found window
;   -b button - Click the informed button from the found window *
;   -t timeout - Set a timeout to finding a window (in miliseconds)
;   -p file - Take a screenshot and save it to the informed file
;
;   * In this case the window should be an OpenEdge ALERT-BOX MESSAGE
;
; Returns:
;   -1 Window title not informed or window not found
;   -2 The informed keyboard events couldn't be sent to the informed window
;   -3 The informed button couldn't be clicked at the informed window
;

Local $titles = ""
Local $keys = ""
Local $button = ""
Local $timeout = 0
Local $screenshot = ""

;
; Errors
;
Local WINDOW_NOT_FOUND = -1
Local KEYS_ERROR = -2
Local BUTTON_NOT_FOUND = -3
Local BUTTON_CLICK_ERROR = -4

;
; OpenEdge MESSAGE VIEW-AS ALERT-BOX buttons
;
Local $buttons[4][2]
$buttons[0][0] = "OK"
$buttons[0][1] = 1
$buttons[1][0] = "YES"
$buttons[1][1] = 1
$buttons[2][0] = "NO"
$buttons[2][1] = 2
$buttons[3][0] = "CANCEL"
$buttons[3][1] = 3

;
; AutoIt Settings.
;
AutoItSetOption("WinTitleMatchMode", -2) ; Match any substring in the title, case insensitive.

;
; Loop through the informed commands.
;
$i = 1

While $i <= $CmdLine[0]
   If StringLeft($CmdLine[$i], 1) = "-" Then
	  Switch StringLower($CmdLine[$i])
		 Case "-w"
			$title = $CmdLine[$i]
		 Case "-k"
			$keys = $CmdLine[$i]
		 Case "-b"
			$button = $CmdLine[$i]
		 Case "-t"
			$timeout = $CmdLine[$i]
		 Case "-t"
			$screenshot = $CmdLine[$i]
	  EndSwitch

	  $i += 1
   EndIf

   $i += 1
WEnd

; ------------------------------------------------------------------------------
; MAIN BLOCK
; ------------------------------------------------------------------------------
Local $wHnd = 0

If $title <> "" Then
   $wHnd = GetWindow($title)
   If $wHnd = 0 Then Exit(WINDOW_NOT_FOUND)
EndFunc

If $keys <> "" Then
   If $wHnd = 0 Then Exit(WINDOW_NOT_FOUND)
   If SendKeys($wHnd, $keys) = 0 Then Exit(-2)
EndIf

If $button <> "" Then
   If $wHnd = 0 Then Exit(WINDOW_NOT_FOUND)

   $index = _ArraySearch($buttons, $button)
   If $index = -1 Then Exit(BUTTON_NOT_FOUND)
   If ClickButton($wHnd, "[CLASS:Button; INSTANCE:"&$buttons[$index][1]&"]") = 0 Then Exit(BUTTON_CLICK_ERROR)
EndIf

;
; Quit the application.
;
Exit(0)

; ------------------------------------------------------------------------------
;
; Search for a window with the informed title.
;
; Parameter:
; 	$title Window title.
;
; Returns:
;	$wHnd Window found handle or 0 in case of an error.
;
; ------------------------------------------------------------------------------
Func GetWindow($title)
   ; Check if the window title was informed.
   If $title = "" Then Return 0

   ; Try to locate window with the informed title.
   Return WinWait($title, "", $timeout / 1000)
EndFunc

; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
Func ActivateWindow($wHnd)
   Return WinActivate($wHnd)
EndFunc

; ------------------------------------------------------------------------------
; Sends keyboard eventos to a window
; Sometimes, when Windows is locked, the keys are not sent at the first time.
; In this case we test the window text, if the text does not exist, the keys
; are sent at least 2 more times before throwing an error.
; ------------------------------------------------------------------------------
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

; ------------------------------------------------------------------------------
; Execute a click event on a OE AlertBox Window
; Sometimes, when Windows is locked, the click does not work at the first time.
; In this case we test the window handle, if still exists, the click is retried
; at least 2 more times before throwing an error.
; ------------------------------------------------------------------------------
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
