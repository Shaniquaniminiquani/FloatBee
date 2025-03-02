Version:="0.4"																 								; Written by JayC_
;@Ahk2Exe-SetVersion %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%					 								; Version updater
;@Ahk2Exe-SetMainIcon MusicBee.ico 	 																		; Set default Icon
;@Ahk2Exe-ExeName FloatBee					 																; Compile to FloatBee

#NoEnv
SendMode Input
#SingleInstance Force
Menu Tray, NoStandard
Menu Tray, Add, Settings, Settings
Menu Tray, Add, Exit, ExitApp

RegRead WorkingDir, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", WorkingDir
if (WorkingDir = "") || (WorkingDir != "" && !FileExist(WorkingDir)) {
	if (WorkingDir = "")
		FirstTimeSetup := True
	else TrayTip("Old working Directory no longer exists`nChanging it to current directory",,,, False)
	RegWrite REG_SZ, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", % "WorkingDir", % WorkingDir := A_ScriptDir
}
SetWorkingDir % WorkingDir

RegRead RegistrySave, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", RegistrySave
if (RegistrySave) {
	RegRead MusicBeeFolder, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", MusicBeeFolder
	RegRead AutoStart, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", AutoStart
	RegRead DarkMode, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", DarkMode
	RegRead Fix, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", Fix
	RegRead FixerHotkey, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", FixerHotkey
	RegRead SendKey, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", SendKey
	RegRead AOT, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", AOT
} else if FileExist("Settings.Ini") {
	IniRead MusicBeeFolder, Settings.ini, MusicBeeFolder, Value, % A_Space
	IniRead AutoStart, Settings.Ini, AutoStart, Value, % A_Space
	IniRead DarkMode, Settings.ini, DarkMode, Value, % A_Space
	IniRead Fix, Settings.ini, Fix, Value, % A_Space
	IniRead FixerHotkey, Settings.ini, FixerHotkey, Value, % A_Space
	IniRead SendKey, Settings.ini, SendKey, Value, % A_Space ;"^{]}" for me
	IniRead RegistrySave, Settings.ini, RegistrySave, Value, % A_Space
	IniRead AOT, Settings.ini, AOT, Value, % A_Space
}

if (MusicBeeFolder = "")
	MusicBeeFolder := FileExist("C:\Program Files (x86)\MusicBee\MusicBee.exe") ? "C:\Program Files (x86)\MusicBee" : ""
if (AutoStart = "")
	AutoStart := False
if (DarkMode = "")
	DarkMode := True
if (Fix = "")
	Fix := False
if (RegistrySave = "")
	RegistrySave := False
if (AOT = "")
	AOT := False

Global CurrentOs := CheckOS(), FirstLaunch, RegistrySave
Global MusicBeeFloatHwnd, MusicBeeFloatTextHwnd, MainBeeHwnd, BeeHwnd
Global BeeX, BeeY, BeeW, BeeH, TitlebarH, Border

if (FirstTimeSetup) {
	TrayTip("First time setup detected`nLaunching Settings`nThis will only happen once")
	Gosub Settings
	if (MusicBeeFolder = "")
		TrayTip("Non standard MusicBee install detected`nConsider updating Folder Location")
	WinWaitClose % "ahk_id" SettingsHwnd
	TrayTip("Setup finished`nYou can always access it again via its Tray Icon on the bottom right")
}
	
if (MusicBeeFolder != "")
	Menu Tray, Icon, % MusicBeeFolder "\Skins\MusicBee.ico"

if !WinExist("ahk_exe MusicBee.exe") {
	if (AutoStart) {
		if (MusicBeeFolder = "")
			TrayTip("MusicBee Folder not set`nCan't auto Start`nRun settings to update path")
		else if FileExist(MusicBeeFolder "\MusicBee.exe") {
			Run % MusicBeeFolder "\MusicBee.exe", % MusicBeeFolder
			WinWaitActive % "ahk_exe MusicBee.exe"
			Sleep 800
			if (Fix && Sendkey != "") {
				Send % SendKey
				Sleep 150
				Send % SendKey
			} else if (Fix && SendKey = "")
				TrayTip("Nothing Sent`nAssign a key to send in Settings")
		}
	} 
}
if !WinExist("ahk_exe MusicBee.exe") {
	TrayTip("MusicBee is not running`nExiting Script", 5000)
	ExitApp
} else if WinExist("ahk_exe MusicBee.exe") {
	WinActivate % "ahk_exe MusicBee.exe"
	WinGet BeeList, List, % "ahk_exe MusicBee.exe"
	Loop % BeeList {
		WinGet Style, Style, % "ahk_id" BeeList%A_Index%
		if (Style && (Style = "0x16C70000" || Style = "0x17C70000")) {
			MainBeeHwnd := BeeList%A_Index%
			Continue
		} else if (Style && (Style = "0x16C40000" || Style = "0x16000000")) {
			BeeHwnd := BeeList%A_Index%
			Continue
		}
	}
	if !(MainBeeHwnd) || !(BeeHwnd) {
		TrayTip("Was unable to attach`nTrying secondary method", 1000, 200)
			Loop % BeeList {
				WinGet Style, Style, % "ahk_id" BeeList%A_Index%
				if (Style & 0x10000) {
					MainBeeHwnd := BeeList%A_Index%
					Continue
				}
				BeeHwnd := BeeList%A_Index%
			}
	} 
	if !(MainBeeHwnd) || !(BeeHwnd) {
		TrayTip("Make sure MusicBee is in the forground along an instance of the floating window. Last attempt", 1000, 200)
		Count := ""
		Loop % BeeList
			Count++
		if (Count = 2)
			Loop % BeeList {
				WinGetTitle, title, % "ahk_id" BeeList%A_Index%
				if (RegExMatch(title, "- MusicBee$")) {
					MainBeeHwnd := BeeList%A_Index%
					Continue
				}
				BeeHwnd := BeeList%A_Index%
			}
	} 
	if !(MainBeeHwnd) || !(BeeHwnd) {
		TrayTip("Unable to attach. Make sure MusicBee is playing music before running the script again to avoid failure")
		TrayTip("Exiting Script")
		ExitApp
	} else if (MainBeeHwnd && BeeHwnd) {
		WinGetPos BeeX, BeeY, BeeW, BeeH, % "ahk_id" BeeHwnd
		SysGet TitlebarH, 4
		SysGet Border, 33
		
		DetectHiddenWindows On
		Gui MusicBeeFloat:New
		Gui % "MusicBeeFloat: +resize " (AOT ? "+AlwaysOnTop" : "") " +HwndMusicBeeFloatHwnd -DPIscale"
		Gui MusicBeeFloat:Color, Blue
		WinSet TransColor, Blue, % "ahk_id" MusicBeeFloatHwnd
		if (CurrentOs != "WIN_7")
			Gui MusicBeeFloat:Add, Text, % "x0 y0 w"BeeW - (Border * 2) " h" BeeH - TitlebarH - (Border * 2) " +HwndMusicBeeFloatTextHwnd"
		Gui MusicBeeFloat:Show, % "x" BeeX " y" BeeY " w"BeeW - (Border * 2) " h" BeeH - TitlebarH - (Border * 2), % "MusicBee"
		DetectHiddenWindows Off
		if (CurrentOs != "WIN_7")
			DllCall("SetParent", "uint", BeeHwnd, "uint", MusicBeeFloatTextHwnd)
		else DllCall("SetParent", "uint", BeeHwnd, "uint", MusicBeeFloatHwnd)
		WinMove % "ahk_id" BeeHwnd,, -Border, -TitlebarH - Border
		WinSet Style, -0xC00000, % "ahk_id" BeeHwnd
		WinSet Style, -0x40000, % "ahk_id" BeeHwnd
		if (DarkMode)
			if (A_OSVersion >= "10.0.17763") {
				attr := 19
				if (A_OSVersion >= "10.0.18985")
					attr := 20
				DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MusicBeeFloatHwnd, "int", attr, "int*", true, "int", 4)
				DllCall("dwmapi\DwmSetWindowAttribute", "ptr", BeeHwnd, "int", attr, "int*", true, "int", 4)
				WinActivate % "ahk_id" MusicBeeFloatHwnd
			}
		if (CurrentOs != "WIN_7")
			OnMessage(0x0005, "WM_SIZE_HANDLER")
		else OnMessage(0x0005, "WM_SIZE_HANDLER_WIN7")
		FirstLaunch := True
		SetTimer DetectWindow, 300
		OnExit("ExitHandler")
	}
	if (FixerHotkey && !Fix) || (!AutoStart && Fix) {
		Hotkey, % FixerHotkey " up", Hotkeylabel
		TrayTip("Always On Top hotkey enabled`n Current key is : """ FixerHotkey """",,,, False)
	}
}
return

Hotkeylabel:
{
	if (FirstPress) {
		FirstPress := False
		return
	}
	SaveHandler("AOT", AOT := !AOT)
	if WinExist("ahk_id" MusicBeeFloatHwnd)
		WinSet AlwaysOnTop, % (AOT ? On : Off), % "ahk_id" MusicBeeFloatHwnd
	if (SettingsHwnd)
		GuiControl,, % Checkbox5, % (AOT ? 1 : 0)
	return
}

DetectWindow() {
	static lastTitle
	if (WinActive("ahk_id" BeeHwnd) && (FirstLaunch = False))
		WinActivate % "ahk_id" MusicBeeFloatHwnd
	else if (!WinActive("ahk_id" BeeHwnd) && FirstLaunch)
		FirstLaunch := False
	if (WinExist("ahk_exe MusicBee.exe") && WinExist("ahk_id" MusicBeeFloatHwnd)) {
		WinGetTitle MainBeeTitle, % "ahk_id" MainBeeHwnd
		MainBeeTitle := SubStr(MainBeeTitle, 1, -11)
		if (MainBeeTitle != lastTitle) {
			lastTitle := MainBeeTitle
			WinSetTitle % "ahk_id" MusicBeeFloatHwnd,, % lastTitle
		}
	} else if (!WinExist("ahk_exe MusicBee.exe") && WinExist("ahk_id" MusicBeeFloatHwnd))
		ExitHandler()
}

WM_SIZE_HANDLER(wParam, lParam, Msg, Hwnd) {
	if (Hwnd != MusicBeeFloatHwnd)
		return
	if (wParam = 0)
		SetTimer ResizeHandler, -100
	else if (wParam = 2) {
		WinGetPos,,, Width, Height, % "ahk_id" MusicBeeFloatHwnd
		WinMove % "ahk_id" MusicBeeFloatTextHwnd,, 0, 0, Width - (Border * 2), Height - TitlebarH - (Border * 2) 
		WinMove % "ahk_id" BeeHwnd,, -Border, -TitlebarH - Border, Width, Height 
	} 
	return
	
	ResizeHandler:
	{
		WinGetPos,,, Width, Height, % "ahk_id" MusicBeeFloatHwnd
		WinMove % "ahk_id" MusicBeeFloatTextHwnd,, 0, 0, Width - (Border * 2), Height - TitlebarH - (Border * 2) 
		WinMove % "ahk_id" BeeHwnd,, -Border, -TitlebarH - Border, Width, Height
		return
	}
}

WM_SIZE_HANDLER_WIN7(wParam, lParam, Msg, Hwnd) {
	if (Hwnd != MusicBeeFloatHwnd)
		return
	WinGetPos,,, Width, Height, % "ahk_id" Hwnd
	WinMove % "ahk_id" BeeHwnd,, -Border, -TitlebarH - Border, Width, Height 
}

CheckOS() {
	if (SubStr(A_OSVersion, 1, 3) = 10.) {
		CurrentOs := StrSplit(A_OSVersion, ".")
		if (CurrentOs[3] >= 22000)
			return "WIN_11"
		else if (CurrentOs[3] >= 10240)
			return "WIN_10"
		return
	} else return A_OSVersion
}

CheckStyles(WinTitle, Style) {
	WinGet CurStyles, Style, % WinTitle
	return (CurStyles & Style)
}

ExitHandler(ExitReason := "") {
	Static Flag
	if (Flag)
		return
	Flag := True
	if (SettingsHwnd)
		Gui Settings:Destroy
	if (BeeHwnd) {
		WinGetPos BeeX, BeeY, BeeW, BeeH, % "ahk_id" BeeHwnd
		DllCall("SetParent", "uint", BeeHwnd, "uint", 0)
		Gui MusicBeeFloat:Hide
		WinMove % "ahk_id" BeeHwnd,, BeeX, BeeY, BeeW, BeeH
		if !CheckStyles("ahk_id" BeeHwnd, "0xC00000")
			WinSet Style, +0xC00000, % "ahk_id" BeeHwnd
		if !CheckStyles("ahk_id" BeeHwnd, "0x40000")
			WinSet Style, +0x40000, % "ahk_id" BeeHwnd
		TrayTip("Successfully Detached`nExiting Script", 1000, 200)
	}
    ExitApp
}

ExitApp:
MusicBeeFloatGuiClose:
{
	ExitApp
}

Settings:
{
	MaxTextLength:= DPI(160)
	Padding:= DPI({Outer: 10, Inner: 7.4, TextAd: 4.7, Ok: 8.7})
	EditDim:= DPI({w: 220, h: 22, x: Ref(MaxTextLength + Padding.Outer) + 20})
	ButtonDim:= DPI({w: 18, h: Ref(EditDim.h), x: Ref(EditDim.x) -20})
	SettingsWidth:= (Padding.Outer*2) + MaxTextLength + ButtonDim.w + DPI(2)+1 + EditDim.w
	OKDim:= DPI({h: 20, w: 40, x: Ref((SettingsWidth/2)) - 20})
	HalfDim:= DPI({x: Ref(OkDim.x) + 44, Edit: Ref(OkDim.x) + 97, EditW: 123, check: Ref(SettingsWidth) - 26})
	Height:= DPI({y0Text: Ref(Padding.Outer + Padding.TextAd), y1: Ref(Padding.Outer + EditDim.h + Padding.inner), y1Text: ""
															 , y2: Ref(Padding.Outer + (EditDim.h * 2) + (Padding.inner * 2)), y2Text: ""
															 , y3: Ref(Padding.Outer + (EditDim.h * 3) + (Padding.inner * 3)), y3Text: ""
															 , y4: Ref(Padding.Outer + (EditDim.h * 4) + (Padding.inner * 4)), y4Text: ""
															 , Ok: ""})
	Height.y1Text:= Height.y1 + Padding.TextAd
	Height.y2Text:= Height.y2 + Padding.TextAd
	Height.y3Text:= Height.y3 + Padding.TextAd
	Height.y4Text:= Height.y4 + Padding.TextAd
	Height.Ok := Height.y4 + EditDim.h + Padding.Ok
	SettingsHeight:= Height.Ok + OKDim.h + Padding.Outer

	Gui Settings:New
	Gui Settings:+AlwaysOnTop -MinimizeBox +ToolWindow -DPIScale +HwndSettingsHwnd
	if (A_OSVersion >= "10.0.17763") {
			attr := 19
			if (A_OSVersion >= "10.0.18985")
				attr := 20
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", SettingsHwnd, "int", attr, "int*", 1, "int", 4)
	}
	Gui Settings:Color, 1b1b1a
	Gui Settings:Font, S10 Cfff4e0
	Gui Settings:Add, Text, % "x"Padding.Outer " y" Height.y0Text " " (!RegistrySave ? "" : "Hidden") " HwndText1", % "Working Script Directory"
	Gui Settings:Add, Edit, % "w" EditDim.w " h" EditDim.h " x" EditDim.x " y" Padding.Outer " " (!RegistrySave ? "" : "Hidden") "  c000000 gEditChangeHandler vWorkingDir HwndSettingsEdit1", % WorkingDir
	Gui Settings:Add, Button, % "w" ButtonDim.w " h" ButtonDim.h " x" ButtonDim.x " y" Padding.Outer " " (!RegistrySave ? "" : "Hidden") " -Theme gChangeDir vWorkingDirButton HwndButton1"
	Gui Settings:Add, Text, % "x"Padding.Outer " y" Height.y1Text " HwndText2", % "MusicBee Folder Location"
	Gui Settings:Add, Edit, % "w" EditDim.w " h" EditDim.h " x" EditDim.x " y" Height.y1 " c000000 gEditChangeHandler vMusicBeeFolder HwndSettingsEdit2", % MusicBeeFolder
	Gui Settings:Add, Button, % "w" ButtonDim.w " h" ButtonDim.h " x" ButtonDim.x " y" Height.y1 " -Theme gChangeDir vMusicBeeFolderButton HwndButton2"
	Gui Settings:Add, Text, % "x"Padding.Outer " y" Height.y2Text " " (MusicBeeFolder != "" ? "" : "Hidden") " HwndText3", % "Automatically launch MB"
	Gui Settings:Add, Checkbox, % "w" ButtonDim.w " h" ButtonDim.h " x" ButtonDim.x + DPI(2.7) " y" Height.y2 " " (MusicBeeFolder != "" ? "" : "Hidden") " checked" AutoStart " vAutoStart gEditChangeHandler HwndCheckbox1"
	Gui Settings:Add, Text, % "x"HalfDim.x " y" Height.y2Text " HwndText4", % "Dark Mode Toggle"
	Gui Settings:Add, Checkbox, % "w" ButtonDim.w " h" ButtonDim.h " x" HalfDim.Check " y" Height.y2 " checked" DarkMode " vDarkMode gEditChangeHandler HwndCheckbox2"
	Gui Settings:Add, Text, % "x"Padding.Outer " y" Height.y3Text " " ((AutoStart && Sendkey) ? "" : "Hidden") " HwndText5", % "Fix for Legacy Visualizers"
	Gui Settings:Add, Checkbox, % "w" ButtonDim.w " h" ButtonDim.h " x" ButtonDim.x + DPI(2.7) " y" Height.y3 " checked" Fix " " ((AutoStart && Sendkey) ? "" : "Hidden") " vFix gEditChangeHandler HwndCheckbox3"
	Gui Settings:Add, Text, % "x"HalfDim.x " y" Height.y3Text " HwndText6", % "Hotkey"
	Gui Settings:Add, Hotkey, % "w" HalfDim.EditW " h" EditDim.h " x" HalfDim.Edit " y" Height.y3 " vFixerHotkey gEditChangeHandler HwndHotkey1", % FixerHotkey
	Gui Settings:Add, Text, % "x"Padding.Outer " y" Height.y4Text " HwndText7", % "Save to registry"
	Gui Settings:Add, Checkbox, % "w" ButtonDim.w " h" ButtonDim.h " x" ButtonDim.x + DPI(2.7) " y" Height.y4 " checked" RegistrySave " vRegistrySave gEditChangeHandler HwndCheckbox4"
	Gui Settings:Add, Text, % "x"HalfDim.x " y" Height.y4Text " HwndText8", % "Always On Top Toggle"
	Gui Settings:Add, Checkbox, % "w" ButtonDim.w " h" ButtonDim.h " x" HalfDim.Check " y" Height.y4 " checked" (AOT ? 1 : 0) " vAOT gEditChangeHandler HwndCheckbox5"
	Gui Settings:Add, Button, % "h" OkDim.h " w" OkDim.w " x" OkDim.x " y" Height.Ok " -Theme gSaveToIni HwndButtonOK", Save
	Gui Settings:Add, Text, w0 h0 vInvisText
	GuiControl Settings:Focus, InvisText	;Fix focus on open
	Gui Settings:Show, % "h"SettingsHeight " w"SettingsWidth " x" (A_ScreenWidth/2)-(SettingsWidth/2) " y" (A_ScreenHeight/2)-(SettingsHeight/2), % (FirstTimeSetup ? " Setup" : " Settings")
	Gui Settings:-ToolWindow	;Remove icon on titlebar
	return
}

DPI(Value) {
	if IsObject(Value) {
		for key, val in Value
			Value[key] := Val*(A_ScreenDPI / 96)
		return Value
	}
	return Value*(A_ScreenDPI / 96)
}

Ref(Value) {
	return Value /(A_ScreenDPI / 96)
}

EditChangeHandler:
{
	Global A_GuiControlTimer := A_GuiControl
	if (A_GuiControl = "AutoStart") {
		SaveHandler("AutoStart",, Checkbox1)
		if ((AutoStart) && (Sendkey)) {
			GuiControl Show, % Text5
			GuiControl Show, % Checkbox3
			if (Fix) {
				ClearHotkey()
				TrayTip("Always On Top hotkey disabled`nLegacy Visualizer fixer enabled",,,, False)
			}
		} else {
			GuiControl Hide, % Text5
			GuiControl Hide, % Checkbox3
			if ((FixerHotkey) && (Fix)) {
				Hotkey, % FixerHotkey " up", Hotkeylabel, On
				TrayTip("Always On Top hotkey enabled`nLegacy Visualizer fixer disabled",,,, False)
			} else if (AutoStart)
				TrayTip("Set a hotkey in order to access legacy visualizer fix",,,, False)
		}
	} else if (A_GuiControl = "DarkMode") {
		SaveHandler("DarkMode",, Checkbox2)
		if (A_OSVersion >= "10.0.17763") {
			attr := 19
			if (A_OSVersion >= "10.0.18985")
				attr := 20
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", MusicBeeFloatHwnd, "int", attr, "int*", (DarkMode ? true : false), "int", 4)
			DllCall("dwmapi\DwmSetWindowAttribute", "ptr", BeeHwnd, "int", attr, "int*", (DarkMode ? true : false), "int", 4)
			WinActivate % "ahk_id" MusicBeeFloatHwnd
		} else TrayTip("Dark mode is unsupported on your OS")
	} else if (A_GuiControl = "Fix") {
		SaveHandler("Fix",, Checkbox3)
		if (Fix) {
			ClearHotkey()
			TrayTip("Always On Top hotkey disabled`nLegacy Visualizer fixer enabled",,,, False)
		} else {
			Hotkey, % FixerHotkey " up", Hotkeylabel, On
			TrayTip("Always On Top hotkey enabled`nLegacy Visualizer fixer disabled",,,, False)
		}
	}
	else if (A_GuiControl = "RegistrySave") {
		SaveHandler("RegistrySave",, Checkbox4)
		if (RegistrySave) {
			GuiControl Hide, % Text1
			GuiControl Hide, % SettingsEdit1
			GuiControl Hide, % Button1
			if FileExist("Settings.Ini")
				FileDelete Settings.Ini
		} else {
			GuiControl Show, % Text1
			GuiControl Show, % SettingsEdit1
			GuiControl Show, % Button1
			Loop Reg, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee" 
			{
				if (A_LoopRegName != "WorkingDir")
					RegDelete % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", % A_LoopRegName
			}
		}
		if ((MusicBeeFolder) && (MusicBeeFolder != "C:\Program Files (x86)\MusicBee"))
			SaveHandler("MusicBeeFolder", MusicBeeFolder)
		if (AutoStart != False)
			SaveHandler("AutoStart", AutoStart)
		if (DarkMode != True)
			SaveHandler("DarkMode", DarkMode)
		if (Fix != False)
			SaveHandler("Fix", Fix)
		if (AOT != False)
			SaveHandler("AOT", AOT)
		if (FixerHotkey)
			SaveHandler("FixerHotkey", FixerHotkey)
		if (SendKey)
			SaveHandler("SendKey", SendKey)	
	} else if (A_GuiControl = "AOT") {
		SaveHandler("AOT",, Checkbox5)
		if WinExist("ahk_id" MusicBeeFloatHwnd)
			WinSet AlwaysOnTop, % (AOT ? On : Off), % "ahk_id" MusicBeeFloatHwnd
	} else if (A_GuiControl = "FixerHotkey") {
		GuiControlGet FixerHotkey,, % Hotkey1
		RegExMatch(FixerHotkey, "O)(?=.*[^\+\^\!])([\+\^\!]+)?(?![\+\^\!])(.+)", Hotkey)
		if (FixerHotkey && !Hotkey[2])
			return
		else if (FixerHotkey = "") {
			ClearHotkey()
			SaveHandler("FixerHotkey", FixerHotkey := "")
			SaveHandler("SendKey", SendKey := "")
			GuiControl Hide, % Text5
			GuiControl Hide, % Checkbox3
			TrayTip("Hotkey cleared",,,, False)
		} else {
			FirstPress:= True
			GuiControl Settings:Focus, InvisText
			ClearHotkey()
			SaveHandler("FixerHotkey", FixerHotkey)
			SaveHandler("SendKey", SendKey := Hotkey[1] "{" hotkey[2] "}")
			if (AutoStart) {
				GuiControl Show, % Text5
				GuiControl Show, % Checkbox3
			}	
			Hotkey, % FixerHotkey " up", Hotkeylabel, On
			TrayTip("Always On Top hotkey enabled",,,, False)
		}
	} else SetTimer EditChange, -1000
	return
	
	EditChange:
	{
		if (A_GuiControlTimer = "WorkingDir") {
			ControlGetText NewWorkingDir,, % "ahk_id" SettingsEdit1
			if InStr(FileExist(NewWorkingDir), "D") {
				if (NewWorkingDir = WorkingDir) {
					TrayTip("No change detected")
					return
				} else if CheckWritePerms(NewWorkingDir) {
					if FileExist("Settings.Ini")
						FileMove Settings.Ini, % NewWorkingDir "\Settings.Ini"
					SetWorkingDir % WorkingDir := NewWorkingDir
					RegWrite REG_SZ, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", % "WorkingDir", % WorkingDir
					TrayTip("Script directory updated successfully")
				} else TrayTip("Insufficient Write permissions`nNo changes have been made`nChoose a different dir or save to registry")
			} else TrayTip("No folder path saved`nPlease try again")
		} else if (A_GuiControlTimer = "MusicBeeFolder") {
			ControlGetText NewMusicBeeFolder,, % "ahk_id" SettingsEdit2
			if FileExist(NewMusicBeeFolder) && RegExMatch(NewMusicBeeFolder, "\\MusicBee$")
				if (NewMusicBeeFolder = MusicBeeFolder) {
					TrayTip("No change detected")
					return
				} else {
					SaveHandler("MusicBeeFolder", MusicBeeFolder := NewMusicBeeFolder)
					TrayTip("MusicBee Path changed Successfully")
				}
			if (MusicBeeFolder != "") {
				Menu Tray, Icon, % MusicBeeFolder "\Skins\MusicBee.ico"
				GuiControlGet AutoIsVisible, Visible, % Text3
				if !(AutoIsVisible) {
					GuiControl Show, % Text3
					GuiControl Show, % Checkbox1
				}
			}
		}
		return
	}
}

ClearHotkey() {
	if (RegistrySave)
		RegRead FixerHotkey, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", FixerHotkey
	else IniRead FixerHotkey, Settings.ini, FixerHotkey, Value, % A_Space
	if (FixerHotkey)
		Hotkey, % FixerHotkey " up", Off
}

SaveToIni:
{
	ControlGetText NewMusicBeeFolder,, % "ahk_id" SettingsEdit2
	if FileExist(NewMusicBeeFolder) && (NewMusicBeeFolder != MusicBeeFolder) {
		if !(RegExMatch(NewMusicBeeFolder, "\\MusicBee$"))
			TrayTip("Ensure correct path was saved. It's not the standard folder")
		SaveHandler("MusicBeeFolder", MusicBeeFolder := NewMusicBeeFolder)
	} else if !FileExist(NewMusicBeeFolder) {
		TrayTip("MusicBee Path does not exist`nCheck its correct")
		return
	}
	TrayTip("Settings save themselves on change`nSettings Forcefully saved")
	Gui Settings:Destroy
	return
}

ChangeDir:
{
	if (A_GuiControl = "WorkingDirButton") {
		NewWorkingDir := SelectFolder(WorkingDir, "Select script directory", SettingsHwnd)
		if InStr(FileExist(NewWorkingDir), "D") {
			if (NewWorkingDir = WorkingDir) {
				TrayTip("No change detected")
				return
			} else if CheckWritePerms(NewWorkingDir) {
				if FileExist("Settings.Ini")
					FileMove Settings.Ini, % NewWorkingDir "\Settings.Ini"
				SetWorkingDir % WorkingDir := NewWorkingDir
				RegWrite REG_SZ, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", % "WorkingDir", % WorkingDir
				GuiControl % "Settings: -g", WorkingDir
				GuiControl Settings:Text, WorkingDir, % WorkingDir
				GuiControl % "Settings: +gEditChangeHandler", WorkingDir
				TrayTip("Script directory updated successfully")
			} else TrayTip("Insufficient Write permissions`nNo changes have been made`nChoose a different dir or save to registry")
		} else TrayTip("No folder path saved`nPlease try again")
	} else if (A_GuiControl = "MusicBeeFolderButton") {
		NewMusicBeeFolder := SelectFolder(MusicBeeFolder, "Select MusicBee Folder", SettingsHwnd)
		if InStr(FileExist(NewMusicBeeFolder), "D") {
			if (NewMusicBeeFolder = MusicBeeFolder)
				TrayTip("No change detected")
			else if RegExMatch(NewMusicBeeFolder, "\\MusicBee$") {
				GuiControl % "Settings: -g", MusicBeeFolder
				GuiControl Settings:Text, MusicBeeFolder, % NewMusicBeeFolder
				GuiControl % "Settings: +gEditChangeHandler", MusicBeeFolder
				IniWrite % MusicBeeFolder := NewMusicBeeFolder, Settings.Ini, MusicBeeFolder, Value
			} if (MusicBeeFolder != "") {
				Menu Tray, Icon, % MusicBeeFolder "\Skins\MusicBee.ico"
				GuiControlGet AutoIsVisible, Visible, % Text3
				if !(AutoIsVisible) {
					GuiControl Show, % Text3
					GuiControl Show, % Checkbox1
				}
			}
			return
		} else TrayTip("MusicBee Folder Path unchanged`nPlease try again")
	}
	return
}

SettingsGuiEscape:
{
	ControlGetFocus FocusedControl, % "ahk_id" SettingsHwnd
	if (FocusedControl = "msctls_hotkey321") {
		Send {Shift}
		GuiControl Settings:Focus, InvisText
	} else Gui Settings:Destroy
	return
}

CheckWritePerms(Dir) {
	if !FileExist(Dir)
		return
	Loop {
		Random Rand, 1, 1000
		if !FileExist(Dir "\Temp " Rand)
			Break
	}
	FileCreateDir % Dir "\Temp " Rand
	if !ErrorLevel
		FileRemoveDir % Dir "\Temp " Rand
	return !ErrorLevel
}

SaveHandler(Name, Value:= "", CHwnd:= "") {
	if (CHwnd)
		GuiControlGet CtrlVal,, % CHwnd
	if (RegistrySave || Name = "RegistrySave")
		RegWrite REG_SZ, % "HKEY_CURRENT_USER\Software\Scripts\FloatBee", % Name, % (Value ? Value : %Name% := CtrlVal)
	else
		IniWrite % (Value ? Value : %Name% := CtrlVal), Settings.Ini, % Name, Value
}

SelectFolder(StartingFolder:="", Prompt:="", GuiHwnd:=0, ButtonLabel:="", Options:=0x2002028) {
	OSVersion := DllCall("GetVersion") & 0xFFFF
	if (OSVersion <= 6) {																								; IFileDialog req Vista(+). Vista is 6
		FileSelectFolder, SelectedFolder, % StartingFolder, 3, % Prompt
		if ErrorLevel																									; If cancel, exit
			return
		return SelectedFolder
	}
	IFileDialog := ComObjCreate("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}")
	vtable := NumGet(IFileDialog + 0)
	if ((StartingFolder != "") && FileExist(StartingFolder)) {															; If the directory exists and starting folder parameter is used
		VarSetCapacity(IID_IShellItem, 16, 0)
		DllCall("Ole32.dll\IIDFromString", "WStr", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", &IID_IShellItem := 0)
		DllCall("Shell32.dll\SHCreateItemFromParsingName", "WStr", StartingFolder, "Ptr", 0, "Ptr", &IID_IShellItem, "Ptr*", DefaultPath)
		DllCall(NumGet(vtable + 0, 12 * A_PtrSize), "Ptr", IFileDialog, "Ptr", DefaultPath)								; SetFolder offset = 12
	}
	if (ButtonLabel != "")
		DllCall(NumGet(vtable + 0, 18 * A_PtrSize), "Ptr", IFileDialog, "WStr", ButtonLabel)							; SetOkButtonLabel offset = 18
	if (Prompt != "")
		DllCall(NumGet(vtable + 0, 17 * A_PtrSize), "Ptr", IFileDialog, "WStr", Prompt)									; SetTitle offset = 17
	if ((GuiHwnd != 0) && !WinExist("ahk_id" GuiHwnd))																	; Check if Hwnd isn't empty and exists. If not pass null
		GuiHwnd := 0
	DllCall(NumGet(vtable + 0, 9 * A_PtrSize), "Ptr", IFileDialog, "Uint", Options)										; https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/ne-shobjidl_core-_fileopendialogoptions Defaults: FOS_DONTADDTORECENT|FOS_PICKFOLDERS|FOS_NOCHANGEDIR|FOS_CREATEPROMPT
	DllCall(NumGet(vtable + 0, 3 * A_PtrSize), "Ptr", IFileDialog, "Ptr", GuiHwnd)										; Show offset = 3
	DllCall(NumGet(vtable + 0, 20 * A_PtrSize), "Ptr", IFileDialog, "Ptr*", ResultPath) 								; GetResult offset = 20
	DllCall(NumGet(NumGet(ResultPath + 0) + 0, 5 * A_PtrSize), "Ptr", ResultPath, "Uint", 0x80058000, "Ptr*", sPtr)		; GetDisplayName offset = 5 | SIGDN_FILESYSPATH
	SelectedFolder := StrGet(sPtr, "UTF-16")
	DllCall("Ole32.dll\CoTaskMemFree", "Ptr", sPtr)
	if (DefaultPath)
		ObjRelease(DefaultPath)
	ObjRelease(ResultPath)
	ObjRelease(IFileDialog)
	if (SelectedFolder != "")
		return SelectedFolder
	return
}

TrayTip(Message, Duration:= 3000, time:= 800, Rounded:=False, Sleep:= True) {
	static MinWidth:= A_ScreenWidth/6.98
	static MinHeight:= A_ScreenHeight/16.875
	static OffSet:= MinWidth/34.375
	static FontSize
	if (A_ScreenWidth " x " A_ScreenHeight = "3840 x 2160")
		FontSize:= 15
	Else FontSize:= 8
	DetectHiddenWindows On
    Gui CTrayTip:New
	Gui CTrayTip:+AlwaysOnTop -Caption -DPIScale +HwndCTrayTipHwnd
	Gui CTrayTip:Color, 1b1b1a 
	Gui CTrayTip:Font, % "S"FontSize " Cfff4e0"
	Gui CTrayTip:Add, Text, % "+HwndTextHwnd", % Message
	Gui CTrayTip:Show, % "w"MinWidth " h"MinHeight " Hide"
	WinGetPos,,,TrayTipWidth, TrayTipHeight, % "ahk_id" CTrayTipHwnd
	If (Rounded)
		WinSet, Region, % "0-0 w"TrayTipWidth " h"TrayTipHeight " R10-30", % "ahk_id" CTrayTipHwnd
	SysGet WorkArea, MonitorWorkArea
	x := WorkAreaRight - TrayTipWidth - (OffSet/2)
	If !(Rounded)
		y := WorkAreaBottom - TrayTipHeight
	Else y := WorkAreaBottom - TrayTipHeight + 1
	ControlGetPos,,, TextWidth, TextHeight, , % "ahk_id" TextHwnd
	if (TextWidth <= MinWidth)
		ControlMove,, (TrayTipWidth/2)-(TextWidth/2), (TrayTipHeight/2)-(TextHeight/2),,, % "ahk_id" TextHwnd
	else ControlMove,, OffSet, OffSet, MinWidth-(OffSet*2), MinHeight, % "ahk_id" TextHwnd
	Gui CTrayTip:Show, % "x"x " y"y " Hide"
    DetectHiddenWindows Off
	
	FadeIn(CTrayTipHwnd, time)
	if (Sleep) {
		Sleep % Duration
		FadeOut(CTrayTipHwnd, time)
		Gui CTrayTip:Destroy
	} else if (!Sleep)
		SetTimer closing, % "-" Duration
	return
	
	Closing:
	{
		FadeOut(CTrayTipHwnd, time)
		Gui CTrayTip:Destroy
		return
	}
	
}

FadeIn(ID, time:= 800) {
	static AW_SLIDE			:= 0x00040000
	static AW_VER_NEGATIVE	:= 0x00000008
	DllCall("AnimateWindow", "ptr", ID, "uint", time, "uint", AW_VER_NEGATIVE|AW_SLIDE)
}

FadeOut(ID, time:= 800) {
	static AW_BLEND := 0x00080000
	static AW_HIDE := 0x00010000
	DllCall("AnimateWindow", "ptr", ID, "uint", time, "uint", AW_BLEND|AW_HIDE)
}