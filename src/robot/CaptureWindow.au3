#include <GDIPlus.au3>
#include <WinAPISysWin.au3>

Func Capture_Window($Title, $SaveImagePath)
   WinSetState($Title, "", @SW_SHOW)

   Local $hWnd = WinGetHandle($Title)
   Local $w = _WinAPI_GetWindowWidth($hWnd)
   Local $h = _WinAPI_GetWindowHeight($hWnd)

   _GDIPlus_Startup()

   If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)
   If Int($w) < 1 Then Return SetError(2, 0, 0)
   If Int($h) < 1 Then Return SetError(3, 0, 0)

   Local Const $hDC_Capture = _WinAPI_GetDC(HWnd($hWnd))
   Local Const $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)

   Local Const $hHBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
   Local Const $hObjectOld = _WinAPI_SelectObject($hMemDC, $hHBitmap)

   DllCall("gdi32.dll", "int", "SetStretchBltMode", "hwnd", $hDC_Capture, "uint", 4)
   DllCall("user32.dll", "int", "PrintWindow", "hwnd", $hWnd, "handle", $hMemDC, "int", 0)

   _WinAPI_DeleteDC($hMemDC)
   _WinAPI_SelectObject($hMemDC, $hObjectOld)
   _WinAPI_ReleaseDC($hWnd, $hDC_Capture)

   $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)
   _WinAPI_DeleteObject($hHBitmap)

   $hBmp = _GDIPlus_BitmapCloneArea($hBmp, 0, 0, $w, $h)
   _GDIPlus_ImageSaveToFile($hBmp, $SaveImagePath)
   _GDIPlus_Shutdown()

   Return $hBmp
EndFunc   ;==>Capture_Window
