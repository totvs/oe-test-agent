#include <AutoItConstants.au3>
#include <Array.au3>
#include <ScreenCaptureMod.au3>
#include <WinAPICom.au3>

;
; OE Robot
;
; Commands:
;
;	*** Returns a handle of an opened window with the given title.
; 		-w $sTitle [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $iTimeout - Timeout, in miliseconds, to wait for the window to be visible
;		** The title can be delimited with | to search with more than one title.
;
;	*** Sends keyboard events to the informed window.
;		-w $sTitle -k $sKeys [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $sKeys - Keyboard events (using Send patterns)
;		* $iTimeout - Timeout, in miliseconds, to wait for the window to be visible
;		** The title can be delimited with | to search with more than one title.
;
;;	*** Clicks on a button of the informed OE alert box window.
;		-w $sTitle -b $sButton [-t $iTimeout]
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $sButton - Name of the button - OK, YES, NO, CANCEL and RETRY
;		* $iTimeout - Timeout, in miliseconds, to wait for the window to be visible
;		** The title can be delimited with | to search with more than one title.
;
;	*** Takes a screenshot of each process window and returns a list of filenames.
; 		-s $sPath <[-w $sTitle] [-p $sProcess]> [-e $sExclusions]
;		* $sPath - Absolute path where the screenshot files will be stored
;		* $sTitle - Window title (full or partial - case insensitive)
;		* $sProcess - Process name
;		* $sExclusions - Windows titles that will be excluded
;		** The title and exclusions can be delimited with | to search with more than one title.
;
; Error levels:
;	** All errors is readable by STDERR
; 	-1: Window not found with the given title.
;	-2: Window title not informed.
;	-3: Couldn't send key events to the informed window.
;	-4: Invalid informed button.
;	-5: Couldn't click the button of the informed window.
;	-6: Process name or window title not informed.
;	-7: Couldn't take the screenshots.
;
; @author Rubens dos Santos Filho
;

; Configure to match any substring in the title, case insensitive.
AutoItSetOption("WinTitleMatchMode", -2)

; Parameters variables.
Local $sTitle = ""
Local $sKeys = ""
Local $sButton = ""
Local $sPath = ""
Local $sProcess = ""
Local $sExclusions = ""
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
Local $iParam = 1

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
			$sPath = StringReplace($CmdLine[$iParam], "/", "\")
		 Case "-p"
			$iParam += 1
			$sProcess = $CmdLine[$iParam]
		 Case "-e"
			$iParam += 1
			$sExclusions = $CmdLine[$iParam]
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
	  ExitWithError(-1, "Window not found with the given title.")
   EndIf
EndIf

; Execute the command to send keyboard events to an opened window:
If $sKeys <> "" Then
   If $hWindow = -1 Then
	  ExitWithError(-2, "Window title not informed.")
   EndIf

   If Not SendKeys($hWindow, $sKeys) Then
	  ExitWithError(-3, "Couldn't send key events to the informed window.")
   EndIf
EndIf

; Execute the command to click in a button of an opened window:
If $sButton <> "" Then
   If $hWindow = -1 Then
	  ExitWithError(-2, "Window title not informed.")
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
	  ExitWithError(-5, "Couldn't click the button of the informed window.")
   EndIf
EndIf

; Execute the screenshot command:
If $sPath Then
   Local $bTaken = False
   Local $sFiles = ""
   Local $aWindows[2]

   If $sProcess = "" And $hWindow = -1 Then
	  ExitWithError(-6, "Process name or window title not informed.")
   EndIf

   If $hWindow > 0 Then
	  $aWindows[0] = 1
	  $aWindows[1] = $hWindow
   Else
	  $aWindows = GetWindowsByProcess($sProcess)
   EndIf

   If Not FileExists($sPath) Then
	  DirCreate($sPath)
   EndIf

   For $i = 1 To $aWindows[0][0]
	  Local $sFile = $sPath & "\" & StringRegExpReplace(_WinAPI_CreateGUID(), "[{}-]", "") & ".png"

	  If $sExclusions <> "" And StringRegExp($aWindows[$i][0], "(?i)(" & $sExclusions & ")") Then
		 ContinueLoop
	  EndIf

	  If TakeScreenshot($aWindows[$i][1], $sFile) Then
		 $bTaken = True
		 $sFiles = $sFiles & ($sFiles = "" ? "" : "|") & $sFile
	  EndIf
   Next

   If Not $bTaken Then
	  ExitWithError(-7, "Couldn't take the screenshots.")
   EndIf

   ConsoleWrite($sFiles)
EndIf

;
; Search for a opened window with the given title and return its handle.
;
; @param $title Window title
; @returns Window handle or -1 if the windows wasn't found
;
Func GetWindowHandle($sTitle, $iTimeout)
   ; Try to locate the window with the informed title
   Local $hWindow = WinWait($sTitle, "", $iTimeout / 1000)
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
; Take a screenshot of a window and save it in the provided path.
;
; @param $vWindow Window title or handle
; @param $sFile Absolute file where the screenshot will be stored
;
; @return True if the screenshot was taken successfully
;
Func TakeScreenshot($vWindow, $sFile)
   ;Return Capture_Window($vWindow, $sFile) <> 0
   ;WinSetState($vWindow, "", @SW_RESTORE) ; Restores the windows (if its minimized)
   WinActivate($vWindow) ; Activates the window on top to take the screenshot
   Return _ScreenCapture_CaptureWnd_mod($sFile, $vWindow, False)
EndFunc

;
; Return a list of handles from the informed process name visible windows.
;
; @param $sProcess Process name
; @return List handles of the visible process windows
;
Func GetWindowsByProcess($sProcess)
   Local $aWindows[1][2] = [[0,0]]
   Local $aProcesses = ProcessList($sProcess)
   Local $aWinList = WinList()

   For $i = 1 To $aProcesses[0][0]
	  If Not ProcessExists($aProcesses[$i][1]) Then
		 ContinueLoop
	  EndIf

	  For $j = 1 To $aWinList[0][0]
		 If WinGetProcess($aWinList[$j][1]) = $aProcesses[$i][1] And BitAND(WinGetState($aWinList[$j][1]), $WIN_STATE_VISIBLE) Then
			$aWindows[0][0] += 1
			_ArrayAdd($aWindows, _ArrayExtract($aWinList, $j, $j))
		 EndIf
	  Next
   Next

   Return $aWindows
EndFunc

;
; Exit the application with registering a error number and message.
;
; @param $iCode Error code
; @param $sMessage Error message
;
Func ExitWithError($iCode, $sMessage)
   ConsoleWriteError($sMessage & @CRLF)
   Exit($iCode)
EndFunc
