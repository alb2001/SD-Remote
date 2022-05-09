;
; AutoIt Version: 3.0
; Language:       English
; Platform:       Win9x/NT
; Author:         alb2001
;
; Script Function:
;   Single click frontend for UltraVNC (reverse connection).
;
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=helpdesk.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <TrayConstants.au3>

#Region ### START Koda GUI section ### Form=C:\Program Files (x86)\AutoIt3\Extras\Koda\Forms\frmmain2.kxf
$frmMain = GUICreate("Service Desk Remote Tool", 488, 280, -1, -1)
$lAgents = GUICtrlCreateList("", 8, 8, 257, 201)
$LOGO = GUICtrlCreatePic("", 288, 8, 174, 60)
$TEXTTOP = GUICtrlCreateLabel("TEXTTOP", 8, 209, 262, 17, $SS_CENTER)
$TEXTMIDDLE = GUICtrlCreateLabel("TEXTMIDDLE", 8, 233, 257, 17, $SS_CENTER)
$TEXTBOTTOM = GUICtrlCreateLabel("TEXTBOTTOM", 8, 252, 257, 17, $SS_CENTER)
$TEXTRIGHTTOP = GUICtrlCreateLabel("TEXTRIGHTTOP", 279, 209, 200, 17, $SS_CENTER)
$TEXTRIGHTMIDDLE = GUICtrlCreateLabel("TEXTRIGHTMIDDLE", 279, 227, 200, 17, $SS_CENTER)
$TEXTRIGHTBOTTOM = GUICtrlCreateLabel("TEXTRIGHTBOTTOM", 279, 243, 128, 17)
$btnConnect = GUICtrlCreateButton("Connect", 424, 248, 57, 25)
$grpInfo = GUICtrlCreateGroup("grpInfo", 288, 80, 177, 129)
$labHostName = GUICtrlCreateLabel("labHostName", 296, 100, 68, 17)
$labHostName2 = GUICtrlCreateLabel("labHostName2", 371, 100, 90, 17)
$labUserName = GUICtrlCreateLabel("labUsername", 296, 116, 68, 17)
$labUsername2 = GUICtrlCreateLabel("labUsername2", 371, 116, 90, 17)
$labOSVersion = GUICtrlCreateLabel("labOSVersion", 296, 132, 68, 17)
$labOSVersion2 = GUICtrlCreateLabel("labOSVersion2", 371, 132, 90, 17)
$labIpaddr = GUICtrlCreateLabel("labIpaddr", 296, 148, 68, 17)
$labIpaddr2 = GUICtrlCreateLabel("labIpaddr2", 371, 148, 90, 55)

GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Disable default menu (Paused/Exit)
AutoItSetOption("TrayMenuMode",1)
; Disable Tray icon
TraySetState($TRAY_ICONSTATE_HIDE)


; Disable button control
GUICtrlSetState($btnConnect, $GUI_DISABLE)

; Help desk file where agents will show up (format is: agent,machine)
Local $helpdeskfile = "agents.txt"

; Window text strings file
Local $textinifile = "strings.txt"

; Logo
Local $logofile = "logo.bmp"

; Update window text strings
GUICtrlSetData($TEXTTOP,IniRead($textinifile, "WindowText", "TEXTTOP", ""))
GUICtrlSetData($TEXTMIDDLE,IniRead($textinifile, "WindowText", "TEXTMIDDLE", ""))
GUICtrlSetData($TEXTBOTTOM,IniRead($textinifile, "WindowText", "TEXTBOTTOM", ""))
GUICtrlSetData($TEXTRIGHTBOTTOM,IniRead($textinifile, "WindowText", "TEXTRIGHTBOTTOM", ""))
GUICtrlSetData($TEXTRIGHTTOP,IniRead($textinifile, "WindowText", "TEXTRIGHTTOP", ""))
GUICtrlSetData($TEXTRIGHTMIDDLE,IniRead($textinifile, "WindowText", "TEXTRIGHTTOP", ""))

; Update Info frame
GUICtrlSetData($grpInfo, "Computer Information")

; Add host name
GUICtrlSetData($labHostName,"Name:")
GUICtrlSetData($labHostName2,@ComputerName)

; Add Username
GUICtrlSetData($labUserName,"Username:")
GUICtrlSetData($labUsername2,@UserName)

; Add OS
GUICtrlSetData($labOSVersion,"OS Version:")
GUICtrlSetData($labOSVersion2,@OSVersion)

; Add available IP Addresses (@Ipaddress macro doesn't allow variables so it has to be done 4 times, need to find a better way)
GUICtrlSetData($labIpaddr,"IP Address:")
$ipaddress = ""
If @IPAddress1 <> "0.0.0.0" Then
	$ipaddress = $ipaddress & @IPAddress1 & @LF
EndIf
If @IPAddress2 <> "0.0.0.0" Then
	$ipaddress = $ipaddress & @IPAddress2 & @LF
EndIf
If @IPAddress3 <> "0.0.0.0" Then
	$ipaddress = $ipaddress & @IPAddress3 & @LF
EndIf
If @IPAddress4 <> "0.0.0.0" Then
	$ipaddress = $ipaddress & @IPAddress4 & @LF
EndIf
GUICtrlSetData($labIpaddr2,$ipaddress)

; Update logo
GUICtrlSetImage($LOGO, $logofile)

;Array creation
Local $arr

;Open Helpdeskfile and read its contents
_FileReadToArray($helpdeskfile, $arr, Default, ",")

; For testing purposes, on the array the first row and column is the total number of rows and columns. Useless in this case
For $i = 0 to UBound ($arr, 1) -1
	For $j = 0 to UBound ($arr, 2) -1
		ConsoleWrite("$arr[" & $i & "][" & $j & "]:=" & $arr[$i][$j] & @LF)
	Next
	ConsoleWrite(@LF)
Next

; Check if 64 bit version and obtain UltraVNC Path
If @OSArch="X64" Or @OSArch="IA64" Then
	Local $uvncpath = RegRead("HKLM64\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Ultravnc2_is1", "InstallLocation")
Else
	Local $uvncpath = RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Ultravnc2_is1", "InstallLocation")
EndIf

; Fill the Agents list with the agents from the array (1 is used to avoid total number of agents)
For $i = 1 to UBound ($arr, 1) -1
	GUICtrlSetData($lAgents, $arr[$i][0])
Next

; Main window loop
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $lAgents
			; Check if an agent has been clicked
			If GUICtrlRead($lAgents) <> "" Then
				GUICtrlSetState($btnConnect, $GUI_ENABLE)
			EndIf

		Case $btnConnect
			; Compare the name and find the machine associated with it (1 is used to avoid searching the first value)
			For $i = 1 to UBound ($arr, 1) -1
				If $arr[$i][0] == GUICtrlRead($lAgents) Then
					Run($uvncpath & "winvnc.exe -sc_prompt -sc_exit -multi -connect " & $arr[$i][1] & " -run", $uvncpath)
					if @error <> 0 Then
						MsgBox(48,"Helpdesktool","Unable to run VNC. Check if it is installed.")
					EndIf
					Exit
				EndIf
			Next
	EndSwitch
WEnd

