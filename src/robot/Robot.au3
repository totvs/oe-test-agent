#include <Array.au3>
#include <ScreenCapture.au3>
#include <UDFb64.au3>

;
; OE Robot
;
; Commands:
;
;	*** Returns an opened window handle with the given title.
; 		-w $sTitle [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $iTimeout - Timeout, in miliseconds, to wait for this window
;		** The title can be delimited with | to search a window with more than one title.
;
;	*** Sends keyboard events to the informed window.
;		-w $sTitle -k $sKeys [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $sKeys - Keyboard events (using AutoIt patterns)
;		* $iTimeout - Timeout, in miliseconds, to wait for this window
;
;
;;	*** Clicks on a button of the informed window.
;		-w $sTitle -k $sKeys [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $sKeys - Keyboard events (using AutoIt patterns)
;		* $iTimeout - Timeout, in miliseconds, to wait for this window
;
;	*** Takes a screenshot of the system.
; 		-s $sFile
;		* $sFile - Absolute path where the screenshot file will be stored
;		** The Base64 string from the screenshot is also written in the console to be captured by STDOUT
;
; Error levels:
; 	-1: Window not found with the given title.
;	-2: Window not informed.
;	-4: Impossible to send key events to the informed window.
;	-4: Invalid informed button.
;	-5: Impossible to click on the button of the informed window.
;	-6: Impossible to take a screenshot.
;
; @author Rubens dos Santos Filho
;

; Configure to match any substring in the title, case insensitive.
AutoItSetOption("WinTitleMatchMode", -2)

; Parameters variables.
Local $sTitle = ""
Local $sKeys = ""
Local $sButton = ""
Local $bScreenshot = False
Local $sFile = ""
Local $iTimeout = 1000

; OE MESSAGE VIEW-AS ALERT-BOX buttons.
Local $aButtons[7][2]
$aButtons[0][0] = 6
$aButtons[1][0] = "OK"
$aButtons[1][1] = 1
$aButtons[2][0] = "YES"
$aButtons[2][1] = 1
$aButtons[3][0] = "NO"
$aButtons[3][1] = 2
$aButtons[4][0] = "CANCEL" ; YES-NO-CANCEL
$aButtons[4][1] = 3
$aButtons[5][0] = "CANCEL" ; OK-CANCEL
$aButtons[5][1] = 2
$aButtons[6][0] = "RETRY" ; RETRY-CANCEL
$aButtons[6][1] = 1

; Window handle.
Local $hWindow = -1

; Loop through the informed commands:
$iParam = 1

While $iParam <= $CmdLine[0]
   If StringLeft($CmdLine[$iParam], 1) = "-" Then
	  Switch StringLower($CmdLine[$iParam])
		 Case "-w"
			$iParam += 1
			$sTitle = $CmdLine[$iParam]
		 Case "-k"
			$iParam += 1
			$sKeys = $CmdLine[$iParam]
		 Case "-b"
			$iParam += 1
			$sButton = $CmdLine[$iParam]
		 Case "-t"
			$iParam += 1
			$iTimeout = $CmdLine[$iParam]
		 Case "-s"
			$iParam += 1
			$bScreenshot = True
			$sFile = $CmdLine[$iParam]
	  EndSwitch
   EndIf

   $iParam += 1
WEnd

; Execute the command to recover a window handle:
If $sTitle <> "" Then
   Local $aTitles = StringSplit($sTitle, "|")

   ; Try to locate the window with the informed title
   For $i = 1 To $aTitles[0]
	  $hWindow = GetWindowHandle($aTitles[$i], $iTimeout)

	  If $hWindow > 0 Then
		 ExitLoop
	  EndIf
   Next

   If $hWindow = -1 Then
	  Exit(-1)
   EndIf
EndIf

; Execute the command to send keyboard events to an opened window:
If $sKeys <> "" Then
   If $hWindow = -1 Then
	  Exit(-2)
   EndIf

   If Not SendKeys($hWindow, $sKeys) Then
	  Exit(-3)
   EndIf
EndIf

; Execute the command to click in a button of an opened window:
If $sButton <> "" Then
   If $hWindow = -1 Then
	  Exit(-2)
   EndIf

   Local $bClicked = False

   ; Tries to click on the informed button.
   For $i = 1 To $aButtons[0][0]
	  If $aButtons[$i][0] = $sButton Then
		 If ClickOEButton($hWindow, "[CLASS:Button; INSTANCE:"&$aButtons[$i][1]&"]") Then
			$bClicked = True
			ExitLoop
		 EndIf
	  EndIf
   Next

   If Not $bClicked Then
	  Exit(-5)
   EndIf
EndIf

; Execute the screenshot command:
If $bScreenshot Then
   If Not TakeScreenshot($sFile) Then
	  Exit(-6)
   EndIf

   ; 0 for ANSI but is irrelevent because its a file and thus is ignored.
   ; 64 for the line length and 1 meaning its a file we are processing.
   ConsoleWrite(B64Encode($sFile, 0, 64, 1))
   FileDelete($sFile)
EndIf

;
; Search for a opened window with the given title and return its handle.
;
; @param $title Window title
; @returns Window handle or -1 if the windows wasn't found
;
Func GetWindowHandle($sTitle, $iTimeout)
   ; Try to locate the window with the informed title
   $hWindow = WinWait($sTitle, "", $iTimeout / 1000)
   Return $hWindow > 0 ? $hWindow : -1
EndFunc

;
; Send keyboard events on a opened window.
;
; Sometimes, when Windows is locked, the keys are not sent at the first time.
; In this case we test the window text, if the text does not exist, the keys
; are sent at least 10 more times before throwing an error.
;
; @param $hWindow Window handle
; #param $sKeys Key events (using AutoIt patterns)
; @param $iRetries Maximum of retries before throwing an error
;
; @return True if the keyboard events were successfully made
;
Func SendKeys($hWindow, $sKeys, $iRetries = 10)
   ; Activate the window.
   WinActivate($hWindow)

   ; Send the keyboard events to the window.
   ControlSend($hWindow, "", "", $sKeys)

   ; Test if the window contains the sent keys.
   If WinExists($hWindow, $sKeys) Then
	  Return True
   Else
	  Sleep(500)
	  $iRetries -= 1

	  If $iRetries > 0 Then
		 Return SendKeys($hWindow, $sKeys, $iRetries)
	  Else
		 Return False
	  EndIf
   EndIf
EndFunc

;
; Execute a click event on a OE AlertBox Window.
;
; Sometimes, when Windows is locked, the keys are not sent at the first time.
; In this case we test the window text, if the text does not exist, the keys
; are sent at least 10 more times before throwing an error.
;
; @param $hWindow Window handle
; #param $sControl Control name of the button
; @param $iRetries Maximum of retries before throwing an error
;
; @return True if the click event was successfully made
;
Func ClickOEButton($hWindow, $sControl, $iRetries = 10)
   ; Activate the window.
   WinActivate($hWindow)

   ; Send the keyboard events to the window.
   ControlClick($hWindow, "", $sControl)

   ; Test if the window contains the sent keys.
   If Not WinExists($hWindow) Then
	  Return True
   Else
	  Sleep(500)
	  $iRetries -= 1

	  If $iRetries > 0 Then
		 Return ClickOEButton($hWindow, $sControl, $iRetries)
	  Else
		 Return False
	  EndIf
   EndIf
EndFunc

;
; Take a screenshot and save it in the provided path.
;
; @param $sFile Absolute file where the screenshot will be stored.
; @return True if the screenshot was taken successfully.
;
Func TakeScreenshot($sFile)
   Return _ScreenCapture_Capture($sFile)
EndFunc

; Exit application
Exit(0)
