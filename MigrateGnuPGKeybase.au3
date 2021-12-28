#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=res\MigrateGnuPGKeybase.ico
#AutoIt3Wrapper_Outfile=bin\MigrateGnuPGKeybase.exe
#AutoIt3Wrapper_Outfile_x64=bin\MigrateGnuPGKeybase64.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Comment=Ein Migrationswerkzeug für die Migration der Schlüsseldatenbank von GnuPGv1 auf GnuPGv2. Konfiguriert über eine INI-Datei mit gleichem Namen der EXE-Datei.
#AutoIt3Wrapper_Res_Description=Ein Migrationswerkzeug für die Migration der Schlüsseldatenbank von GnuPGv1 auf GnuPGv2. Konfiguriert über eine INI-Datei mit gleichem Namen der EXE-Datei.
#AutoIt3Wrapper_Res_Fileversion=1.0.30.0
#AutoIt3Wrapper_Res_ProductName=MigrateGnuPGKeybase
#AutoIt3Wrapper_Res_ProductVersion=1.0.30.0
#AutoIt3Wrapper_Res_LegalCopyright=Copyright 2017-2021 by Veit Berwig. Lizenzierung unter der GPL 3.0 (Open-Source)
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Field=Author|Veit Berwig
#AutoIt3Wrapper_Res_Field=Info|Ein Migrationswerkzeug für die Migration der Schlüsseldatenbank von GnuPGv1 auf GnuPGv2. Konfiguriert über eine INI-Datei mit gleichem Namen der EXE-Datei.
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; ########## !!! THIS FILE IS ENCODED IN UTF-8 with BOM !!! #########


; Author: 	Veit Berwig
; Desc.: 	Program-Launcher derived fron StartController for
;           launching programs without commandline-options
; Version: 	1.0.0.23
; Important Info:	We have to do a case sensitive string-diff with:
; 					If Not ("String1" == "String2") Then ...
;					We have to do a case in-sensitive string-diff with:
; 					If Not ("String1" <> "String2") Then ...
; 					here !!
;
; == 	Test if two strings are equal. Case sensitive.
;		The left and right values are converted to strings if they are
;		not strings already. This operator should only be used if
;		string comparisons need to be case sensitive.
; <> 	Tests if two values are not equal. Case insensitive	when used
;		with strings. To do a case sensitive not equal comparison use
; Not ("string1" == "string2")
;

#cs
	;****************************************************************
	History:

	Relaunched a new rewrite for migrating the gnupg key-database
	to the new V2 version, so new version-numbering was issued here.

	Although this program checks for multiple conditions before
	initialising the migration to the new version, it is recommended
	to run this program only once by the reg-key:
	HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce

	1.0.0.0 - 1.0.0.23

	-	Old Code


	1.0.0.24 (25.01.2021)

	- 	New Code

	-	Strip down the code to only execute a given program with local
		environment by using an ini-filename
	- 	File-Creation removed from code.
	- 	File-Creation for ini-config-file, when not existent

	1.0.0.25 (02.06.2021)

	-	Added a new option "DontCheckPATH" in INI-file for disabling the
		check of file-existence; so we can use programs without
		full-spec path and use them from search-PATH.

	1.0.0.26 (17.06.2021)

	-	Added a new option "REMOVE" in INI-file for deleting files after
		[KillApp]-Section. This is for a cleanup in order to remove
		stale files. Now user-context environment-variables are supported
		for cleaning up old files; i.e. %USERPROFILE%, %APPDATA%, %TEMP%,
		etc. For example cleaning up the socket-files of "gpg-agent" after
		killing all "Gpg4Win"-processes in order to start "Kleopatra"
		much faster under Windows at first time.

	-   The cleanupProc() was disabled, due to double execution of some
		functions in the main program and twice on exit() by cleanupProc().

	1.0.0.27 (26.07.2021)

	-	Re-Design for GnuPG keybase migration from v1.x -> v2.x
	-	Writing logfile into eventlog
	-	Create splash-output for user-information
	- 	Autotest - key-import by "remote-cotrolled" app

		Check:
		%SYSTEMDRIVE%\Users\[USERNAME]\AppData\Roaming\gnupg / gnupg_$GpgGUID
		%USERPROFILE%\AppData\Roaming\gnupg / gnupg_$GpgGUID

		Workflow:
		=========
		01) if exist "%USERPROFILE%\AppData\Roaming\gnupg_$GpgGUID"
		      => "Allready done => Exit"

		02) if exist "%USERPROFILE%\AppData\Roaming\gnupg\pubring.kbx"
		      => "GnuPGv2 detected => Exit"

		03) if exist "%USERPROFILE%\AppData\Roaming\gnupg\S.dirmngr"
		      => "GnuPGv2 detected => Exit"

		04) if not exist "%USERPROFILE%\AppData\Roaming\gnupg"
		      => "No Keybase exist => Exit"

		05) if exist "%USERPROFILE%\AppData\Roaming\gnupg" but no keyrings
		      => "No Keybase exist => Exit"

		06) => move	"%USERPROFILE%\AppData\Roaming\gnupg" to \
					"%USERPROFILE%\AppData\Roaming\gnupg_$GpgGUID"

		07) Launch "Kleopatra" in Autotest-Mode   when "kleopatra.exe" in string
			Launch "GnuPG"     in Unattended-Mode when "gpg.exe"       in string

		08) Create gnupg-dir by GnuPG-invocation throught "Kleopatra"
			or "GnuPG" itself.

		09) Remote-Control of "Kleopatra" over Windows-Handle or
			invocation of "GnuPG" in batch-mode ...

		10) Import private keybase

		11) Import public keybase

		12) Exit

			========================================
			Kleopatra-Window relevant Autotest-Data:
			========================================
			; Title: "Kleopatra"
			; Class: "Qt5150QWindowIcon"

			; Title: "Zertifikatsdatei auswählen"
			; Class: "#32770"

			; Title: "Geheimer Schlüssel importiert - Kleopatra"
			; Class: "Qt5150QWindowIcon"

			; Title: "Ergebnis des Zertifikat-Imports - Kleopatra"
			; Class: "Qt5150QWindowIcon"

	1.0.28.0 (16.08.2021)

	- Release Change, due to evaluation of version numbers from 1.0.0.27
	  to 1.0.28.0

	- Autotest-Mode for "kleopatra" at "secring"- and "pubring"-import fixed.

	- Added unattended import of "secring" and "pubring" by "GnuPG" as an
	  alternative to "kleopatra"-AutoTest-Mode (faster and more consistent).
	  If "gpg.exe" is provided at the ini-file in "LaunchAPP" and "LaunchPROC",
	  "gpg.exe" will be used for import; if "kleopatra.exe" is provided at
	  the ini-file in "LaunchAPP" and "LaunchPROC", "kleopatra.exe" will be
	  used for import by Autotest (remote-controlling)-features of "AutoIT".
	  Both actions are enabled, when "GpgMigrate" will be set to "true"
	  in section [GpgMigrate].

	1.0.29.0 (23.08.2021)

	- $GpgGUID used now in code below ( shit, i've forgotten this stuff :-( )

	- "ShowSplash", "true" / "false" used now for disabling or enabling a tiny
	  spalsh-screen in the upper-right corner of the display to show the user
	  some infos about my hackings ... maybe not so informational ... so
	  disable this stuff here, when you will get rid of it ...

	- Changed "EventID" to "65535" in order to prevent the Eventsystem from
	  logging false informations from already registered "EventID"s with
	  special Numbers (see Func EventWrite()).

	1.0.30.0 (04.10.2021)

	- Added an eventlog-entry, when "$launchproc" runs already in memory
	  and exit silently without an error-messagebox, when "$ShowSplash"
	  was set to "false" in ini-file.
	;****************************************************************
#ce

#include <File.au3>
#include <string.au3>
#include <Constants.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>
#include <GuiConstants.au3>
#include <GUIConstantsEx.au3>
#include <FileConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>
#include <Date.au3>
#include <EventLog.au3>


; product name
; Global $prod_name = "MigrateGnuPGKeybase"

; generate dynamic name-instance from filename
; Global $app_name = $prod_name

; product name
; - generate dynamic name-instance from filename
; - retrieve short version of @ScriptName
; - remove the 4 rightmost characters from the string.
Global $scriptname_short = StringTrimRight(@ScriptName, 4)
If Not (StringLen($scriptname_short) = 0) Then
	$app_name = $scriptname_short
EndIf

Global $app_version = "1.0.30.0"
Global $app_copy = "Copyright 2017-2021 Veit Berwig"
Global $appname = $app_name & " " & $app_version
Global $appGUID = $app_name & "-C42E3373-4BAE-4bb9-8237-76B25C327C74"

; write to eventlog
Global $_EventError = 1
Global $_EventWarning = 2
Global $_EventInfo = 4

; Check for GnuPG Keybase
Global $GpgMigrate
; GnuPG SEMAPHORE-ID
Global $GpgGUID = "904899B5-AC07-4080-897D-A34169BA4DAF"
; User-Profile-Roaming
Global $UserProfRoaming
; GnuPG Profile-Directory
Global $GpgProfile = "gnupg"
Global $GpgPubFile = "pubring.kbx"
Global $GpgSocket = "S.dirmngr"

Local $PATHENVCLEAN
Global $sEnvPATH = EnvGet("PATH")
Global $pidController = 0
Global $pidController2 = 0

Global $ComSpec, $ComSpec_loc
Global $sControllerpath, $sControllerpath_, $PrgWorkDir, $PrgWorkDirloc, $EnvUpdate_bool
Global $Config_File, $launchapp, $dontcheckpath, $launchproc, $launchapp_param, $launchproc_sleep
Global $https_proxy, $http_proxy, $ftp_proxy
Global $launchproc_cascade, $launchproc_cascade_bool, $launchproc_hidden, $launchproc_hidden_bool
Global $launchproc_wait, $launchproc_wait_bool
Global $launchproc_dontcheck, $launchproc_dontcheck_bool

Global $killapp
Global $killapp0, $killapp1, $killapp2, $killapp3, $killapp4
Global $killapp5, $killapp6, $killapp7, $killapp8, $killapp9
Global $killapp10, $killapp11, $killapp12, $killapp13, $killapp14
Global $killapp15, $killapp16, $killapp17, $killapp18, $killapp19

Global $closewin
Global $closewin0, $closewin1, $closewin2, $closewin3, $closewin4
Global $closewin5, $closewin6, $closewin7, $closewin8, $closewin9
Global $closewin10, $closewin11, $closewin12, $closewin13, $closewin14
Global $closewin15, $closewin16, $closewin17, $closewin18, $closewin19

Global $remove
Global $remove0, $remove1, $remove2, $remove3, $remove4
Global $remove5, $remove6, $remove7, $remove8, $remove9
Global $remove10, $remove11, $remove12, $remove13, $remove14
Global $remove15, $remove16, $remove17, $remove18, $remove19

; Show splash-screen for user information
Global $ShowSplash

Global $closewinWAIT_bool, $closewinTMOUT

Global $sDateTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC

Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("TrayAutoPause", 0)    ; The script will not pause when selecting the tray icon.
Opt("TrayMenuMode", 2)     ; Items are not checked when selected.
Opt("ExpandEnvStrings", 1) ; 1 = erweitert Umgebungsvariablen innerhalb von Strings und %-Symbolen im Code und in den INI-Dateien.

; Extend the behaviour of the script tray icon/menu.
; This can be done with a combination (adding) of the following values.
; 0 = default menu items (Script Paused/Exit) are appended to the usercreated menu;
;     usercreated checked items will automatically unchecked; if you double click
;     the tray icon then the controlid is returned which has the "Default"-style (default).
; 1 = no default menu
; 2 = user created checked items will not automatically unchecked if you click it
; 4 = don't return the menuitemID which has the "default"-style in the main
;     contextmenu if you double click the tray icon
; 8 = turn off auto check of radio item groups
Opt("TrayMenuMode", 10)
; Opt("TrayMenuMode", 1)

TrayItemSetText($TRAY_ITEM_EXIT, $app_name & " beenden ...") ; Set the text of the default 'Exit' item.
TrayItemSetText($TRAY_ITEM_PAUSE, $app_name & " anhalten ...") ; Set the text of the default 'Pause' item.

TraySetClick(16)
TraySetToolTip($app_name)

$sControllerpath = FileGetLongName(@ScriptDir)
; If whe have only 3 chars, then we are in the root-dir with an
; additional backslash at the end of the pathname. this will
; result in \\; so we have to fix this here.
If (StringLen($sControllerpath) = 3) Then
	$sControllerpath_ = StringRegExpReplace($sControllerpath, "([\\])", "")
Else
	$sControllerpath_ = $sControllerpath
EndIf

; debug-info
;MsgBox(0, "Controllerpath is:", $sControllerpath_)

; Check for running only one instance of process (in Misc.au3)
; $sOccurenceName String to identify the occurrence of the script.
; This string may not contain the \ character unless you are placing the
; object in a namespace (See Remarks).
;
; $iFlag [optional] Behavior options.
; 0 - Exit the script with the exit code -1 if another instance already exists.
; 1 - Return from the function without exiting the script.
; 2 - Allow the object to be accessed by anybody in the system. This is useful
;     if specifying a "Global\" object in a multi-user environment.
; You can place the object in a namespace by prefixing your object name with
; either "Global\" or "Local\". "Global\" objects combined with the flag 2 are
; useful in multi-user environments.
If _Singleton($appGUID, 1) = 0 Then
	MsgBox(16, $appname, "Eine Instanz dieses Programmes:" & @CRLF & '"' & $appname & '"' & @CRLF & "läuft schon im Hauptspeicher !" & @CRLF & @CRLF & "Bitte das Programm erst beenden !", 10)
	Exit
EndIf


; ------------ WRITE DEFAULT INI FILE


; Build absolute file-pathname
$Config_File = FileGetLongName($sControllerpath_ & "\" & $app_name & ".ini")

; Install the ini-file if no ini-file is existent
If (FileExists($Config_File) <> 1) Then
	; Write the value of 'Value' to the key 'Key' and in the section labelled 'Section'.
	; IniWrite("INI-File", "Section", "Key", "Value")
	IniWrite($Config_File, "Main Prefs", "LaunchAPP", "rel-path\program.exe")
	IniWrite($Config_File, "Main Prefs", "DontCheckPATH", "false")
	IniWrite($Config_File, "Main Prefs", "LaunchPROC", "program.exe")
	IniWrite($Config_File, "Main Prefs", "LaunchPROC_SLEEP", "4")

	IniWrite($Config_File, "Main Prefs", "WORK_DIR", "")
	IniWrite($Config_File, "Main Prefs", "ComSpec", "")

	IniWrite($Config_File, "Main Prefs", "LaunchAPP_Param", "")
	IniWrite($Config_File, "Main Prefs", "LaunchPROC_CASCADE", "false")
	IniWrite($Config_File, "Main Prefs", "LaunchPROC_HIDDEN", "false")

	IniWrite($Config_File, "Main Prefs", "LaunchPROC_WAIT", "true")
	IniWrite($Config_File, "Main Prefs", "LaunchPROC_DONTCHECK", "false")

	IniWrite($Config_File, "Main Prefs", "EnvUpdate", "false")

	IniWrite($Config_File, "Main Prefs", "http_proxy", "")
	IniWrite($Config_File, "Main Prefs", "http_proxy_format_example", "http://proxyserver:proxyport/")
	IniWrite($Config_File, "Main Prefs", "http_proxy_example", "http://127.0.0.1:3128/")
	IniWrite($Config_File, "Main Prefs", "https_proxy", "")
	IniWrite($Config_File, "Main Prefs", "https_proxy_format_example", "https://proxyserver:proxyport/")
	IniWrite($Config_File, "Main Prefs", "https_proxy_example", "https://127.0.0.1:3128/")
	IniWrite($Config_File, "Main Prefs", "ftp_proxy", "")
	IniWrite($Config_File, "Main Prefs", "ftp_proxy_format_example", "http://proxyserver:proxyport/")
	IniWrite($Config_File, "Main Prefs", "ftp_proxy_example", "http://127.0.0.1:3128/")

	IniWrite($Config_File, "GpgMigrate", "GpgMigrate", "false")
	IniWrite($Config_File, "GpgMigrate", "ShowSplash", "true")
	IniWrite($Config_File, "GpgMigrate", "GpgGUID", $GpgGUID)
	IniWrite($Config_File, "GpgMigrate", "UserProfRoaming", "%%USERPROFILE%%\AppData\Roaming")
	IniWrite($Config_File, "GpgMigrate", "GpgProfile", "gnupg")
	IniWrite($Config_File, "GpgMigrate", "GpgPubFile", "pubring.kbx")
	IniWrite($Config_File, "GpgMigrate", "GpgSocket", "S.dirmngr")

	IniWrite($Config_File, "KillApp", "KILLAPP0", "")
	IniWrite($Config_File, "KillApp", "KILLAPP1", "")
	IniWrite($Config_File, "KillApp", "KILLAPP2", "")
	IniWrite($Config_File, "KillApp", "KILLAPP3", "")
	IniWrite($Config_File, "KillApp", "KILLAPP4", "")
	IniWrite($Config_File, "KillApp", "KILLAPP5", "")
	IniWrite($Config_File, "KillApp", "KILLAPP6", "")
	IniWrite($Config_File, "KillApp", "KILLAPP7", "")
	IniWrite($Config_File, "KillApp", "KILLAPP8", "")
	IniWrite($Config_File, "KillApp", "KILLAPP9", "")

	IniWrite($Config_File, "KillApp", "KILLAPP10", "")
	IniWrite($Config_File, "KillApp", "KILLAPP11", "")
	IniWrite($Config_File, "KillApp", "KILLAPP12", "")
	IniWrite($Config_File, "KillApp", "KILLAPP13", "")
	IniWrite($Config_File, "KillApp", "KILLAPP14", "")
	IniWrite($Config_File, "KillApp", "KILLAPP15", "")
	IniWrite($Config_File, "KillApp", "KILLAPP16", "")
	IniWrite($Config_File, "KillApp", "KILLAPP17", "")
	IniWrite($Config_File, "KillApp", "KILLAPP18", "")
	IniWrite($Config_File, "KillApp", "KILLAPP19", "")

	IniWrite($Config_File, "Remove", "REMOVE0", "")
	IniWrite($Config_File, "Remove", "REMOVE1", "")
	IniWrite($Config_File, "Remove", "REMOVE2", "")
	IniWrite($Config_File, "Remove", "REMOVE3", "")
	IniWrite($Config_File, "Remove", "REMOVE4", "")
	IniWrite($Config_File, "Remove", "REMOVE5", "")
	IniWrite($Config_File, "Remove", "REMOVE6", "")
	IniWrite($Config_File, "Remove", "REMOVE7", "")
	IniWrite($Config_File, "Remove", "REMOVE8", "")
	IniWrite($Config_File, "Remove", "REMOVE9", "")

	IniWrite($Config_File, "Remove", "REMOVE10", "")
	IniWrite($Config_File, "Remove", "REMOVE11", "")
	IniWrite($Config_File, "Remove", "REMOVE12", "")
	IniWrite($Config_File, "Remove", "REMOVE13", "")
	IniWrite($Config_File, "Remove", "REMOVE14", "")
	IniWrite($Config_File, "Remove", "REMOVE15", "")
	IniWrite($Config_File, "Remove", "REMOVE16", "")
	IniWrite($Config_File, "Remove", "REMOVE17", "")
	IniWrite($Config_File, "Remove", "REMOVE18", "")
	IniWrite($Config_File, "Remove", "REMOVE19", "")

	IniWrite($Config_File, "CloseWin", "CLOSEWIN0", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN1", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN2", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN3", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN4", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN5", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN6", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN7", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN8", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN9", "")

	IniWrite($Config_File, "CloseWin", "CLOSEWIN10", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN11", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN12", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN13", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN14", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN15", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN16", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN17", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN18", "")
	IniWrite($Config_File, "CloseWin", "CLOSEWIN19", "")

	IniWrite($Config_File, "CloseWin", "CLOSEWINWAIT", "false")
	IniWrite($Config_File, "CloseWin", "CLOSEWINTMOUT", "10")

EndIf


; ------------ READ INI FILE


$launchapp = StringLower(IniRead($Config_File, "Main Prefs", "LaunchAPP", ""))

; Check for file-existence of LaunchAPP - executable (default: checking is enabled).
$dontcheckpath = StringLower(IniRead($Config_File, "Main Prefs", "DontCheckPATH", "false"))
If $dontcheckpath <> "true" Then
	$dontcheckpath = "false"
EndIf

$launchproc = StringLower(IniRead($Config_File, "Main Prefs", "LaunchPROC", ""))

$PrgWorkDir = IniRead($Config_File, "Main Prefs", "WORK_DIR", "")
If $PrgWorkDir <> "" Then
	$PrgWorkDirloc = FileGetLongName($PrgWorkDir)
	If Not FileExists($PrgWorkDirloc) Then
		MsgBox(64, $appname, "Das Verzeichnis in der Variablen " & """" & "WORK_DIR" & """" & ":" & @CRLF & @CRLF & $PrgWorkDirloc & @CRLF & @CRLF & "konnte nicht gefunden werden !" & @CRLF & @CRLF & "Es muss ein existierender Pfad angegeben werden !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
Else
	;Assign("PrgWorkDirloc", $sControllerpath_)
	$PrgWorkDirloc = $sControllerpath_
EndIf

$ComSpec = StringLower(IniRead($Config_File, "Main Prefs", "ComSpec", ""))
$ComSpec_loc = ""
If $ComSpec <> "" Then
	$ComSpec_loc = FileGetLongName($ComSpec)
	If Not FileExists($ComSpec_loc) Then
		MsgBox(64, $appname, "Die Datei in der Variablen " & """" & "ComSpec" & """" & ":" & @CRLF & @CRLF & $ComSpec_loc & @CRLF & @CRLF & "konnte nicht gefunden werden !" & @CRLF & @CRLF & "Es muss ein existierender Pfad angegeben werden !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
	If StringRight($ComSpec, 4) <> ".exe" Then
		MsgBox(64, $appname, "Die Datei in der Variablen " & """" & "ComSpec" & """" & ":" & @CRLF & @CRLF & $ComSpec_loc & @CRLF & @CRLF & "muss eine ausführbare .exe-Datei sein !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
EndIf

If $launchapp = "" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchAPP" & '"' & @CRLF & @CRLF & "muss (darf) den absoluten Pfad zu diesem Programm  " & @CRLF & "und die ausführbare Datei beinhalten !", 10)
	Exit
EndIf

If $launchproc = "" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC" & '"' & @CRLF & @CRLF & "muss den ausführbaren Teil der Variablen LaunchAPP  " & @CRLF & "oder ein gestartetes Programm beinhalten !", 10)
	Exit
EndIf

If $launchproc = ".exe" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC" & '"' & @CRLF & @CRLF & "muss den ausführbaren Teil der Variablen LaunchAPP  " & @CRLF & "oder ein gestartetes Programm beinhalten !", 10)
	Exit
EndIf

If StringRight($launchproc, 4) <> ".exe" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC" & '"' & @CRLF & @CRLF & "muss den ausführbaren Teil der Variablen LaunchAPP  " & @CRLF & "oder ein gestartetes Programm beinhalten !", 10)
	Exit
EndIf

$launchproc_sleep = IniRead($Config_File, "Main Prefs", "LaunchPROC_SLEEP", "4")
If StringIsDigit($launchproc_sleep) <> 1 Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC_SLEEP" & '"' & @CRLF & @CRLF & "muss einen numerischen Wert in Sekunden " & @CRLF & "( z.B.: 6 für 6 Sek. ) beinhalten !", 10)
	Exit
EndIf

; Check for exporting local environment to global environment and update its content to the OS
$EnvUpdate_bool = StringLower(IniRead($Config_File, "Main Prefs", "EnvUpdate", "false"))
If $EnvUpdate_bool <> "true" Then
	$EnvUpdate_bool = "false"
EndIf

; Check proxy-url formats
$http_proxy = IniRead($Config_File, "Main Prefs", "http_proxy", "")
If $http_proxy <> "" Then
	If StringLen($http_proxy) > 50 Then
		MsgBox(64, $appname, "Die Variable " & """" & "http_proxy" & """" & ":" & @CRLF & @CRLF & $http_proxy & @CRLF & @CRLF & "ist grösser als 50 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
	If StringInStr($http_proxy, ":", 0, 1) = 0 Then
		MsgBox(64, $appname, "Die Variable " & """" & "http_proxy" & """" & ":" & @CRLF & @CRLF & $http_proxy & @CRLF & @CRLF & "enthält kein "":"" Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
EndIf

; Check proxy-url formats
$https_proxy = IniRead($Config_File, "Main Prefs", "https_proxy", "")
If $https_proxy <> "" Then
	If StringLen($https_proxy) > 50 Then
		MsgBox(64, $appname, "Die Variable " & """" & "https_proxy" & """" & ":" & @CRLF & @CRLF & $https_proxy & @CRLF & @CRLF & "ist grösser als 50 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
	If StringInStr($https_proxy, ":", 0, 1) = 0 Then
		MsgBox(64, $appname, "Die Variable " & """" & "https_proxy" & """" & ":" & @CRLF & @CRLF & $https_proxy & @CRLF & @CRLF & "enthält kein "":"" Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
EndIf

; Check proxy-url formats
$ftp_proxy = IniRead($Config_File, "Main Prefs", "ftp_proxy", "")
If $ftp_proxy <> "" Then
	If StringLen($ftp_proxy) > 50 Then
		MsgBox(64, $appname, "Die Variable " & """" & "ftp_proxy" & """" & ":" & @CRLF & @CRLF & $ftp_proxy & @CRLF & @CRLF & "ist grösser als 50 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
	If StringInStr($ftp_proxy, ":", 0, 1) = 0 Then
		MsgBox(64, $appname, "Die Variable " & """" & "ftp_proxy" & """" & ":" & @CRLF & @CRLF & $ftp_proxy & @CRLF & @CRLF & "enthält kein "":"" Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
EndIf

; Check for cascaded execution of same-named processes.
; (name.exe is calling name.exe in another dir and is exiting after child execution ...)
$launchproc_cascade = StringLower(IniRead($Config_File, "Main Prefs", "LaunchPROC_CASCADE", "false"))
If $launchproc_cascade = "false" Then
	$launchproc_cascade_bool = "0"
ElseIf $launchproc_cascade = "true" Then
	$launchproc_cascade_bool = "1"
Else
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC_CASCADE" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Check for execution check if already running.
; (could be a problem when multiple processes running; like "cmd.exe")
$launchproc_dontcheck = StringLower(IniRead($Config_File, "Main Prefs", "LaunchPROC_DONTCHECK", "false"))
If $launchproc_dontcheck = "false" Then
	$launchproc_dontcheck_bool = "0"
ElseIf $launchproc_dontcheck = "true" Then
	$launchproc_dontcheck_bool = "1"
Else
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC_DONTCHECK" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Check for waiting of execution of same-named processes.
; (synchronous mode, when true)
$launchproc_wait = StringLower(IniRead($Config_File, "Main Prefs", "LaunchPROC_WAIT", "true"))
If $launchproc_wait = "false" Then
	$launchproc_wait_bool = "0"
ElseIf $launchproc_wait = "true" Then
	$launchproc_wait_bool = "1"
Else
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC_WAIT" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Check for hidden execution flag of same-named process.
$launchproc_hidden = StringLower(IniRead($Config_File, "Main Prefs", "LaunchPROC_HIDDEN", "false"))
If $launchproc_hidden = "false" Then
	$launchproc_hidden_bool = @SW_SHOWNORMAL
ElseIf $launchproc_hidden = "true" Then
	$launchproc_hidden_bool = @SW_HIDE
Else
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "LaunchPROC_HIDDEN" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Search for special string "XXXXXX" and replace it with
; local program-start-time-string, so we are able to
; create unique output file every second.
$launchapp_param = IniRead($Config_File, "Main Prefs", "LaunchAPP_Param", "")
If (StringInStr($launchapp_param, "XXXXXX") <> 0) Then
	Local $s_launchapp_param = StringReplace($launchapp_param, "XXXXXX", $sDateTime)
	$launchapp_param = $s_launchapp_param
EndIf

; Read Migration Vars ##################################### --- BEGIN

; Read and check for migration-flag, that can be true or false
$GpgMigrate = StringLower(IniRead($Config_File, "GpgMigrate", "GpgMigrate", "false"))
If $GpgMigrate <> "false" And $GpgMigrate <> "true" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "GpgMigrate" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Read and check for ShowSplash-flag, that can be true or false
$ShowSplash = StringLower(IniRead($Config_File, "GpgMigrate", "ShowSplash", "true"))
If $ShowSplash <> "false" And $ShowSplash <> "true" Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "ShowSplash" & '"' & @CRLF & @CRLF & "muss einen BOOLEAN Wert mit " & '"' & "true" & '"' & " oder " & '"' & "false" & '"' & " beinhalten !", 10)
	Exit
EndIf

; Read and check format of GUID ($GpgGUID)
$GpgGUID = IniRead($Config_File, "GpgMigrate", "GpgGUID", $GpgGUID)
If $GpgGUID <> "" Then
	; 36 characters in any GUID
	If StringLen($GpgGUID) > 36 Then
		MsgBox(64, $appname, "Die Variable " & """" & "GpgGUID" & """" & ":" & @CRLF & @CRLF & $GpgGUID & @CRLF & @CRLF & "ist grösser als 36 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
	; Count of 4 for string "-"
	If StringInStr($GpgGUID, "-", 0, 4) = 0 Then
		MsgBox(64, $appname, "Die Variable " & """" & "GpgGUID" & """" & ":" & @CRLF & @CRLF & $GpgGUID & @CRLF & @CRLF & "enthält nicht die richtige Anzahl an ""-"" Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
		Exit
	EndIf
EndIf

; Read profiledir
$UserProfRoaming = IniRead($Config_File, "GpgMigrate", "UserProfRoaming", "%USERPROFILE%\AppData\Roaming")

$GpgProfile = StringLower(IniRead($Config_File, "GpgMigrate", "GpgProfile", "gnupg"))
$GpgPubFile = StringLower(IniRead($Config_File, "GpgPubFile", "GpgProfile", "pubring.kbx"))
$GpgSocket = StringLower(IniRead($Config_File, "GpgSocket", "GpgProfile", "S.dirmngr"))

; Read Migration Vars ###################################### ---  END


; Read apps to kill
$killapp0 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP0", ""))
$killapp1 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP1", ""))
$killapp2 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP2", ""))
$killapp3 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP3", ""))
$killapp4 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP4", ""))
$killapp5 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP5", ""))
$killapp6 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP6", ""))
$killapp7 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP7", ""))
$killapp8 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP8", ""))
$killapp9 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP9", ""))

$killapp10 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP10", ""))
$killapp11 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP11", ""))
$killapp12 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP12", ""))
$killapp13 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP13", ""))
$killapp14 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP14", ""))
$killapp15 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP15", ""))
$killapp16 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP16", ""))
$killapp17 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP17", ""))
$killapp18 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP18", ""))
$killapp19 = StringLower(IniRead($Config_File, "KillApp", "KILLAPP19", ""))

; Read opbjects to remove from filesystem
$remove0 = StringLower(IniRead($Config_File, "Remove", "REMOVE0", ""))
$remove1 = StringLower(IniRead($Config_File, "Remove", "REMOVE1", ""))
$remove2 = StringLower(IniRead($Config_File, "Remove", "REMOVE2", ""))
$remove3 = StringLower(IniRead($Config_File, "Remove", "REMOVE3", ""))
$remove4 = StringLower(IniRead($Config_File, "Remove", "REMOVE4", ""))
$remove5 = StringLower(IniRead($Config_File, "Remove", "REMOVE5", ""))
$remove6 = StringLower(IniRead($Config_File, "Remove", "REMOVE6", ""))
$remove7 = StringLower(IniRead($Config_File, "Remove", "REMOVE7", ""))
$remove8 = StringLower(IniRead($Config_File, "Remove", "REMOVE8", ""))
$remove9 = StringLower(IniRead($Config_File, "Remove", "REMOVE9", ""))

$remove10 = StringLower(IniRead($Config_File, "Remove", "REMOVE10", ""))
$remove11 = StringLower(IniRead($Config_File, "Remove", "REMOVE11", ""))
$remove12 = StringLower(IniRead($Config_File, "Remove", "REMOVE12", ""))
$remove13 = StringLower(IniRead($Config_File, "Remove", "REMOVE13", ""))
$remove14 = StringLower(IniRead($Config_File, "Remove", "REMOVE14", ""))
$remove15 = StringLower(IniRead($Config_File, "Remove", "REMOVE15", ""))
$remove16 = StringLower(IniRead($Config_File, "Remove", "REMOVE16", ""))
$remove17 = StringLower(IniRead($Config_File, "Remove", "REMOVE17", ""))
$remove18 = StringLower(IniRead($Config_File, "Remove", "REMOVE18", ""))
$remove19 = StringLower(IniRead($Config_File, "Remove", "REMOVE19", ""))

; Read windows names to softly close windows
$closewin0 = IniRead($Config_File, "CloseWin", "CLOSEWIN0", "")
$closewin1 = IniRead($Config_File, "CloseWin", "CLOSEWIN1", "")
$closewin2 = IniRead($Config_File, "CloseWin", "CLOSEWIN2", "")
$closewin3 = IniRead($Config_File, "CloseWin", "CLOSEWIN3", "")
$closewin4 = IniRead($Config_File, "CloseWin", "CLOSEWIN4", "")
$closewin5 = IniRead($Config_File, "CloseWin", "CLOSEWIN5", "")
$closewin6 = IniRead($Config_File, "CloseWin", "CLOSEWIN6", "")
$closewin7 = IniRead($Config_File, "CloseWin", "CLOSEWIN7", "")
$closewin8 = IniRead($Config_File, "CloseWin", "CLOSEWIN8", "")
$closewin9 = IniRead($Config_File, "CloseWin", "CLOSEWIN9", "")

$closewin10 = IniRead($Config_File, "CloseWin", "CLOSEWIN10", "")
$closewin11 = IniRead($Config_File, "CloseWin", "CLOSEWIN11", "")
$closewin12 = IniRead($Config_File, "CloseWin", "CLOSEWIN12", "")
$closewin13 = IniRead($Config_File, "CloseWin", "CLOSEWIN13", "")
$closewin14 = IniRead($Config_File, "CloseWin", "CLOSEWIN14", "")
$closewin15 = IniRead($Config_File, "CloseWin", "CLOSEWIN15", "")
$closewin16 = IniRead($Config_File, "CloseWin", "CLOSEWIN16", "")
$closewin17 = IniRead($Config_File, "CloseWin", "CLOSEWIN17", "")
$closewin18 = IniRead($Config_File, "CloseWin", "CLOSEWIN18", "")
$closewin19 = IniRead($Config_File, "CloseWin", "CLOSEWIN19", "")

; Check for waiting of closing windows
$closewinWAIT_bool = StringLower(IniRead($Config_File, "CloseWin", "CLOSEWINWAIT", "false"))
If $closewinWAIT_bool <> "true" Then
	$closewinWAIT_bool = "false"
EndIf

; Check for timeout when waiting for closing windows
$closewinTMOUT = IniRead($Config_File, "CloseWin", "CLOSEWINTMOUT", "10")
If StringIsDigit($closewinTMOUT) <> 1 Then
	MsgBox(16, "Fehler in der INI-Datei ...", "Die Variable:" & @CRLF & @CRLF & '"' & "CLOSEWINTMOUT" & '"' & @CRLF & @CRLF & "muss einen numerischen Wert in Sekunden " & @CRLF & "( z.B.: 6 für 6 Sek. ) beinhalten !", 10)
	Exit
EndIf

; Check format of $remove0-$remove19 paths
For $i = 0 To 19 Step 1
	$remove = Eval("remove" & $i)

	If $remove <> "" Then
		If StringLen($remove) > 256 Then
			MsgBox(64, $appname, "Eine Variable in der Sektion " & """" & "[Remove]" & """" & ":" & @CRLF & @CRLF & $remove & @CRLF & @CRLF & "ist grösser als 256 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
			Exit
		EndIf
		If StringLen($remove) < 10 Then
			MsgBox(64, $appname, "Eine Variable in der Sektion " & """" & "[Remove]" & """" & ":" & @CRLF & @CRLF & $remove & @CRLF & @CRLF & "ist kleiner als 10 Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
			Exit
		EndIf
		If StringInStr($remove, "\", 0, 1) = 0 Then
			MsgBox(64, $appname, "Eine Variable in der Sektion " & """" & "[Remove]" & """" & ":" & @CRLF & @CRLF & $remove & @CRLF & @CRLF & "enthält kein ""\"" Zeichen !" & @CRLF & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 20)
			Exit
		EndIf
	EndIf

Next

; ------------ CRECK FILES

; ------------ WRITE ENVIRONMENT

EnvSet("EXEC_DATE", $sDateTime)
EnvSet("WORK_DIR", $PrgWorkDirloc)
EnvSet("DIRCMD", "/O:GNE")


If $ComSpec_loc <> "" Then
	EnvSet("ComSpec", $ComSpec_loc)
EndIf

; ------------ Set the proxy-server for programs evaluating the http_proxy scheme
If $http_proxy <> "" Then
	EnvSet("http_proxy", $http_proxy)
EndIf
If $https_proxy <> "" Then
	EnvSet("https_proxy", $https_proxy)
EndIf
If $ftp_proxy <> "" Then
	EnvSet("ftp_proxy", $ftp_proxy)
EndIf


; PATH of local execution
EnvSet("CONTROLLERPATH", $sControllerpath_)

; Cleanup PATH-String from trash
$PATHENVCLEAN = $sControllerpath_
EnvSet("PATH", $PATHENVCLEAN & ";" & $sEnvPATH)

; Make Environment global
If $EnvUpdate_bool = "true" Then EnvUpdate()

; Check if process runs already in system, launch
; a messagebox or do an eventlog-entry and exit.
If $launchproc_dontcheck = "false" Then
	If ProcessExists($launchproc) Then
		EventWrite($_EventError, $app_name, "Der Prozess:" & @CRLF & '"' & $launchproc & '"' & @CRLF & "läuft schon im Hauptspeicher !" & @CRLF & "Abbruch des Vorgangs !")
		If $ShowSplash = "true" Then
			MsgBox(16, $appname, "Der Prozess:" & @CRLF & '"' & $launchproc & '"' & @CRLF & "läuft schon im Hauptspeicher !" & @CRLF & @CRLF & "Abbruch des Vorgangs !", 10)
		EndIf
		Exit
	EndIf
EndIf

OnAutoItExitRegister("cleanupProc")
runController()
Exit

; ############################ FUNCTIONS ############################

Func EventWrite($type = 4, $GHeader = $app_name, $GMessage = "   ")
	; #include <EventLog.au3>

	; Local $hEventLog, $aData = [354, 0x4A, 0x65, 0x64, 0x65, 0x73, 0x20, 0x43, 0x6F, 0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x70, 0x72, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x6D, 0x20, 0x62, 0x65, 0x73, 0x69, 0x74, 0x7A, 0x74, 0x20, 0x28, 0x6D, 0x69, 0x6E, 0x64, 0x65, 0x73, 0x74, 0x65, 0x6E, 0x73, 0x29, 0x20, 0x7A, 0x77, 0x65, 0x69, 0x20, 0x5A, 0x77, 0x65, 0x63, 0x6B, 0x65, 0x3A, 0x20, 0x45, 0x69, 0x6E, 0x65, 0x6E, 0x20, 0x66, 0x75, 0x65, 0x72, 0x20, 0x64, 0x65, 0x6E, 0x20, 0x65, 0x73, 0x20, 0x67, 0x65, 0x73, 0x63, 0x68, 0x72, 0x69, 0x65, 0x62, 0x65, 0x6E, 0x20, 0x77, 0x75, 0x72, 0x64, 0x65, 0x20, 0x75, 0x6E, 0x64, 0x20, 0x65, 0x69, 0x6E, 0x65, 0x6E, 0x20, 0x61, 0x6E, 0x64, 0x65, 0x72, 0x65, 0x6E, 0x2C, 0x20, 0x66, 0x75, 0x65, 0x72, 0x20, 0x64, 0x65, 0x6E, 0x20, 0x65, 0x73, 0x20, 0x6E, 0x69, 0x63, 0x68, 0x74, 0x20, 0x67, 0x65, 0x73, 0x63, 0x68, 0x72, 0x69, 0x65, 0x62, 0x65, 0x6E, 0x20, 0x77, 0x75, 0x72, 0x64, 0x65, 0x2E, 0x20, 0x28, 0x41, 0x6C, 0x61, 0x6E, 0x20, 0x4A, 0x2E, 0x20, 0x50, 0x65, 0x72, 0x6C, 0x69, 0x73, 0x20, 0x2F, 0x20, 0x45, 0x70, 0x69, 0x67, 0x72, 0x61, 0x6D, 0x73, 0x20, 0x69, 0x6E, 0x20, 0x50, 0x72, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x6D, 0x69, 0x6E, 0x67, 0x20, 0x23, 0x31, 0x36, 0x2E, 0x29, 0x2C, 0x20, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x64, 0x65, 0x2E, 0x77, 0x69, 0x6B, 0x69, 0x70, 0x65, 0x64, 0x69, 0x61, 0x2E, 0x6F, 0x72, 0x67, 0x2F, 0x77, 0x69, 0x6B, 0x69, 0x2F, 0x41, 0x6C, 0x61, 0x6E, 0x5F, 0x4A, 0x2E, 0x5F, 0x50, 0x65, 0x72, 0x6C, 0x69, 0x73, 0x2C, 0x20, 0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x63, 0x70, 0x73, 0x63, 0x2E, 0x79, 0x61, 0x6C, 0x65, 0x2E, 0x65, 0x64, 0x75, 0x2F, 0x65, 0x70, 0x69, 0x67, 0x72, 0x61, 0x6D, 0x73, 0x2D, 0x70, 0x72, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x6D, 0x69, 0x6E, 0x67, 0x2C, 0x20, 0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x77, 0x77, 0x77, 0x2E, 0x63, 0x73, 0x2E, 0x79, 0x61, 0x6C, 0x65, 0x2E, 0x65, 0x64, 0x75, 0x2F, 0x68, 0x6F, 0x6D, 0x65, 0x73, 0x2F, 0x70, 0x65, 0x72, 0x6C, 0x69, 0x73, 0x2D, 0x61, 0x6C, 0x61, 0x6E, 0x2F, 0x71, 0x75, 0x6F, 0x74, 0x65, 0x73, 0x2E, 0x68, 0x74, 0x6D, 0x6C, 0x20, 0x28, 0x46, 0x75, 0x63, 0x6B, 0x20, 0x57, 0x69, 0x6E, 0x64, 0x6F, 0x77, 0x73, 0x21, 0x29]
	Local $hEventLog, $aData = [9, 0x43, 0x6F, 0x76, 0x65, 0x72, 0x20, 0x6D, 0x65, 0x21]
	$hEventLog = _EventLog__Open("", $GHeader)

	; _EventLog__Report(HANDLE, TYPE, CATEGORY, EVENTID, USERNAME, DESCRIPTION/MESSAGE, DATA)
	;     TYPE: $_EventError = 1 , $_EventWarning = 2 , $_EventInfo = 4 ,
	; CATEGORY: 0 - None , 1 - Devices , 2 - Disk , 3 - Printers ,
	;           4 - Services , 5 - Shell , 6 - System , 7 - Network

	; Using an "EventID" of "65535" (MAXVAL of 16-bit WORD) in "Cathegory" "0"
	; (None) will prevent us from a false interpretation of an already registered
	; "EventID", so Microsoft Windows will do its fucking shit of messages like:
	; "The description for event ID 65535 from source ... could not be found ..."
	; ignore this stupid stuff ..."
	_EventLog__Report($hEventLog, $type, 0, 65535, "", $GMessage, $aData)
	_EventLog__Close($hEventLog)
EndFunc   ;==>EventWrite


Func runController()
	If $dontcheckpath = "false" Then
		If Not FileExists($launchapp) Then
			MsgBox(64, $appname, "In dem Verzeichnis:" & @CRLF & $sControllerpath_ & @CRLF & "konnte die Datei:" & @CRLF & @CRLF & '"' & $launchapp & '"' & @CRLF & @CRLF & "nicht gefunden werden !" & @CRLF & "Bitte bearbeiten Sie die INI-Datei ...     ", 10)
			Exit
		EndIf
	EndIf

	; #####################################################################
	; # Migration ENABLED
	; #####################################################################

	If $GpgMigrate = "true" Then
		If $ShowSplash = "true" Then SplashTextOn($app_name & ": Information", "--- GnuPG Profil-Migration ---" & @CRLF & "Hinweis: " & @CRLF & "GnuPG Profil-Migration wird geprüft ...", 360, 100, @DesktopWidth - 370, @DesktopHeight / 100, 17, "", 8)
		If $ShowSplash = "true" Then Sleep(4000)
		EventWrite($_EventInfo, $app_name, "GnuPG Profil-Migration wird geprüft ...")
		If FileExists($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID) Then
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Das GnuPG-Verzeichnis wurde schon umbenannt:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !", 10)
			If $ShowSplash = "true" Then Sleep(6000)
			If $ShowSplash = "true" Then SplashOff()
			EventWrite($_EventInfo, $app_name, "Das GnuPG-Verzeichnis wurde schon umbenannt:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !")
			Exit
		ElseIf FileExists($UserProfRoaming & "\" & $GpgProfile & "\" & $GpgPubFile) Then
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "GnuPG Profil-Version 2.x erkannt:" & $GpgPubFile & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !", 10)
			If $ShowSplash = "true" Then Sleep(6000)
			If $ShowSplash = "true" Then SplashOff()
			EventWrite($_EventInfo, $app_name, "GnuPG Profil-Version 2.x erkannt: " & $GpgPubFile & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !")
			Exit
		ElseIf FileExists($UserProfRoaming & "\" & $GpgProfile & "\" & $GpgSocket) Then
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "GnuPG Profil-Version 2.x erkannt:" & $GpgSocket & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !", 10)
			If $ShowSplash = "true" Then Sleep(6000)
			If $ShowSplash = "true" Then SplashOff()
			EventWrite($_EventInfo, $app_name, "GnuPG Profil-Version 2.x erkannt: " & $GpgSocket & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !")
			Exit
		ElseIf Not FileExists($UserProfRoaming & "\" & $GpgProfile) Then
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "GnuPG Profil-Verzeichnis existiert noch nicht." & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !", 10)
			If $ShowSplash = "true" Then Sleep(6000)
			If $ShowSplash = "true" Then SplashOff()
			EventWrite($_EventInfo, $app_name, "GnuPG Profil-Verzeichnis existiert noch nicht." & @CRLF & "Migration des GnuPG-Ordners nicht notwendig !")
			Exit
		Else
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "GnuPG Profil-Version 1.x erkannt." & @CRLF & "Migration des GnuPG-Ordners wird eingeleitet ...", 10)
			If $ShowSplash = "true" Then Sleep(4000)
			EventWrite($_EventWarning, $app_name, "GnuPG Profil-Version 1.x erkannt." & @CRLF & "Migration des GnuPG-Ordners wird eingeleitet ...")
			Local $DirMoveExit = 1
			$DirMoveExit = DirMove($UserProfRoaming & "\" & $GpgProfile, $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID)
			If $DirMoveExit = 0 Then
				If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Fehler bei der Umbenennung des Profils:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "... in ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """", 10)
				If $ShowSplash = "true" Then Sleep(6000)
				If $ShowSplash = "true" Then SplashOff()
				EventWrite($_EventError, $app_name, "Fehler bei der Umbenennung des Profils:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "... in ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """")
				Exit
			Else
				If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "GnuPG Profil-Version 1.x ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "... erfolgreich umbenannt in ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """", 10)
				If $ShowSplash = "true" Then Sleep(4000)
				EventWrite($_EventInfo, $app_name, "GnuPG Profil-Version 1.x ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """" & @CRLF & "... erfolgreich umbenannt in ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """")
			EndIf
		EndIf

		; #####################################################################
		; # IMPORT SEQUENCE --- BEGIN ---
		; #####################################################################

		; #############################################################
		; # Import with "GnuPG" when "gpg.exe" is in string           #
		; #############################################################

		If (StringInStr($launchapp, "gpg.exe") <> 0) Then
			; Alternatively we may do an import of "secring" and "pubring", by
			; doing a direct call to "GnuPG" with hidden run-flag, which could be
			; much more consistent than doing an "autotest-sequence" with the risk
			; of missing some dialog IDs when using the indirection by
			; "Kleopatra.exe"-gui:
			; gpg --check-signatures & gpg --batch --import "secring.gpg"
			; gpg --check-signatures & gpg --batch --import "pubring.gpg"
			;
			; Batch Oneliner:
			; gpg --check-signatures >nul 2>&1 & \
			; gpg --check-signatures >nul 2>&1 & \
			; gpg --batch --import "%USERPROFILE%\AppData\Roaming\gnupg_904899B5-AC07-4080-897D-A34169BA4DAF\secring.gpg" & \
			; gpg --batch --import "%USERPROFILE%\AppData\Roaming\gnupg_904899B5-AC07-4080-897D-A34169BA4DAF\pubring.gpg"

			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Migration wird mit GnuPG im Batch-Betrieb durchgeführt ...", 10)
			If $ShowSplash = "true" Then Sleep(4000)
			EventWrite($_EventInfo, $app_name, "Migration wird mit GnuPG im Batch-Betrieb durchgeführt ...")

			; Set ErrorStatus of GnuPG execution to "False"
			Global $ControllerExitError = 0

			; Import private keys only, when "secring.gpg" exist ...
			If FileExists($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg") Then
				EventWrite($_EventInfo, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... existiert, fahre mit dem Import fort !")
				; Create new GnuPG directory, when not existent
				$ControllerExit = RunWait($launchapp & " --check-signatures", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				; Initialize new GnuPG database, when new GnuPG directory exist
				$ControllerExit = RunWait($launchapp & " --check-signatures", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				; Import "Secring"
				$ControllerExit = RunWait($launchapp & " --batch --import " & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				EventWrite($_EventInfo, $app_name, "Import der Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... abgeschlossen, bitte Vollständigkeit der Daten prüfen !")
			Else
				EventWrite($_EventWarning, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... existiert nicht, kein Import von " & """" & "secring.gpg" & """" & " !")
			EndIf

			; Import public keys only, when "pubring.gpg" exist ...
			If FileExists($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg") Then
				EventWrite($_EventInfo, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... existiert, fahre mit dem Import fort !")
				; Create new GnuPG directory, when not existent
				$ControllerExit = RunWait($launchapp & " --check-signatures", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				; Initialize new GnuPG database, when new GnuPG directory exist
				$ControllerExit = RunWait($launchapp & " --check-signatures", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				; Import "Pubring"
				$ControllerExit = RunWait($launchapp & " --batch --import " & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """", $PrgWorkDirloc, $launchproc_hidden_bool)
				If @error Then
					$ControllerExitError = 1
				EndIf
				EventWrite($_EventInfo, $app_name, "Import der Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... abgeschlossen, bitte Vollständigkeit der Daten prüfen !")
			Else
				EventWrite($_EventWarning, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... existiert nicht, kein Import von " & """" & "pubring.gpg" & """" & " !")
			EndIf

			If $ControllerExitError = 1 Then
				If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Ein Fehler war beim Start von:" & @CRLF & """" & $launchapp & """" & @CRLF & "aufgetreten, bitte das Ergebnis prüfen !", 10)
				If $ShowSplash = "true" Then Sleep(4000)
				EventWrite($_EventError, $app_name, "Ein Fehler war beim Start von:" & @CRLF & """" & $launchapp & """" & @CRLF & "aufgetreten, bitte das Ergebnis prüfen !")
			EndIf

			; gpg.exe is exiting norally after import in batch-processing,
			; so we do this only for completeness :-)
			If ProcessExists($launchproc) Then
				; Close App by "Killing Process" ...
				TraySetToolTip($app_name & ": " & @CRLF & "Der Prozess " & """" & $launchproc & """" & " wird beendet !")
				EventWrite($_EventInfo, $app_name, "Der Prozess:" & @CRLF & """" & $launchproc & """" & @CRLF & "wird beendet !")
				ProcessClose($launchproc)
			EndIf


			; #############################################################
			; # Import with "Kleopatra" when "kleopatra.exe" is in string #
			; #############################################################

		ElseIf (StringInStr($launchapp, "kleopatra.exe") <> 0) Then
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Migration wird mit Kleopatra im Autotest-Betrieb durchgeführt ...", 10)
			If $ShowSplash = "true" Then Sleep(4000)
			EventWrite($_EventInfo, $app_name, "Migration wird mit Kleopatra im Autotest-Betrieb durchgeführt ...")

			; Check For processname
			If Not ProcessExists($launchproc) Then
				; Check for Window-Instance
				; Title: "Kleopatra"
				; Class: "Qt5150QWindowIcon"
				; If Not WinExists("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]") Then
				If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Das Programm: " & """" & $launchproc & """" & " wird gestartet ...", 10)
				If $ShowSplash = "true" Then Sleep(4000)
				Local $ControllerExit = 0
				$ControllerExit = Run($launchapp & " " & $launchapp_param, $PrgWorkDirloc)
				If $ControllerExit = 0 Then
					If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Fehler beim Start von:" & @CRLF & """" & $launchapp & """" & " !", 10)
					If $ShowSplash = "true" Then Sleep(4000)
					EventWrite($_EventError, $app_name, "Fehler beim Start von:" & @CRLF & """" & $launchapp & """" & " !")
					; Rollback previously managed DirMove:
					If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Rollback Profilumbenennung wird durchgeführt:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """" & @CRLF & "... zurück nach ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """", 10)
					If $ShowSplash = "true" Then Sleep(4000)
					EventWrite($_EventInfo, $app_name, "Rollback Profilumbenennung wird durchgeführt:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & """" & @CRLF & "... zurück nach ..." & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & """")
					$DirMoveExit = DirMove($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID, $UserProfRoaming & "\" & $GpgProfile)
					If $DirMoveExit = 0 Then
						If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Fehler bei Rollback Profilumbenennung !", 10)
						If $ShowSplash = "true" Then Sleep(4000)
						EventWrite($_EventError, $app_name, "Fehler bei Rollback Profilumbenennung !")
					Else
						If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Rollback Profilumbenennung erfolgreich !", 10)
						If $ShowSplash = "true" Then Sleep(4000)
						EventWrite($_EventInfo, $app_name, "Rollback Profilumbenennung erfolgreich !")
					EndIf
					SplashOff()
					Exit
				Else
					If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & """" & $launchapp & """" & @CRLF & "... wurde erfolgreich gestartet !", 10)
					If $ShowSplash = "true" Then Sleep(2000)
					EventWrite($_EventInfo, $app_name, """" & $launchapp & """" & @CRLF & "... wurde erfolgreich gestartet !")
				EndIf
			EndIf

			; Autotesting App ...
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Beginne mit Autotest (Fernsteuerung) von:" & @CRLF & """" & $launchapp & """" & " !", 10)
			TraySetToolTip($app_name & ": " & "Beginne mit Autotest (Fernsteuerung) von:" & @CRLF & """" & $launchapp & """")
			EventWrite($_EventInfo, $app_name, "Beginne mit Autotest (Fernsteuerung) von:" & @CRLF & """" & $launchapp & """")

			; Import private keys only, when "secring.gpg" exist ...
			If FileExists($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg") Then
				EventWrite($_EventInfo, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... existiert, fahre mit dem Import fort !")
				; ! New Dialog !
				; Title: "Kleopatra"
				; Class: "Qt5150QWindowIcon"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster von Kleopatra (sec-key) ...")
				WinWait("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Fenster von Kleopatra (sec-key) ...")
				WinActivate("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Kleopatra (sec-key) ...")
				WinWaitActive("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende Importbefehl an Kleopatra (sec-key) ...")
				; STRG-i (Importieren ...)
				Send("^i")

				; ! New Dialog !
				; Title: "Zertifikatsdatei auswählen"
				; Class: "#32770"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Dateiauswahl-Fenster (sec-key) ...")
				WinWait("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere #32770-Fenster (sec-key) ...")
				WinActivate("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Dateiauswahl-Fenster (sec-key) ...")
				WinWaitActive("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende Import-Pfad mit Dateiname an Dateiauswahl-Fenster (sec-key) ...")
				Send($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg{Enter}")

				; ! New Dialog !
				; Title: "Geheimer Schlüssel importiert - Kleopatra"
				; Class: "Qt5150QWindowIcon"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Import-Key-Fenster (sec-key) ...")
				WinWait("[TITLE:Geheimer Schlüssel importiert - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Import-Key-Fenster (sec-key) ...")
				WinActivate("[TITLE:Geheimer Schlüssel importiert - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Aktivierung von Import-Key-Fenster (sec-key) ...")
				WinWaitActive("[TITLE:Geheimer Schlüssel importiert - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende " & """" & "ja" & """" & " an Dialog (sec-key) ...")
				Send("!j")

				; ! New Dialog !
				; Title: "Ergebnis des Zertifikat-Imports - Kleopatra"
				; Class: "Qt5150QWindowIcon"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Import Ergebnis-Fenster (sec-key) ...")
				WinWait("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Import Ergebnis-Fenster (sec-key) ...")
				WinActivate("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Aktivierung von Import Ergebnis-Fenster (sec-key) ...")
				WinWaitActive("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende " & """" & "ok" & """" & " an Dialog (sec-key) ...")
				Send("!o")
				EventWrite($_EventInfo, $app_name, "Import der Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... abgeschlossen, bitte Vollständigkeit der Daten prüfen !")
			Else
				EventWrite($_EventWarning, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "secring.gpg" & """" & @CRLF & "... existiert nicht, kein Import von " & """" & "secring.gpg" & """" & " !")
			EndIf

			; Import public keys only, when "pubring.gpg" exist ...
			If FileExists($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg") Then
				EventWrite($_EventInfo, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... existiert, fahre mit dem Import fort !")
				; ! New Dialog !
				; Title: "Kleopatra"
				; Class: "Qt5150QWindowIcon"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster von Kleopatra (pub-key) ...")
				WinWait("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Fenster von Kleopatra (pub-key) ...")
				WinActivate("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Kleopatra (pub-key) ...")
				WinWaitActive("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende Importbefehl an Kleopatra (pub-key) ...")
				; STRG-i (Importieren ...)
				Send("^i")

				; ! New Dialog !
				; Title: "Zertifikatsdatei auswählen"
				; Class: "#32770"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Dateiauswahl-Fenster (pub-key) ...")
				WinWait("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere #32770-Fenster (pub-key) ...")
				WinActivate("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Dateiauswahl-Fenster (pub-key) ...")
				WinWaitActive("[TITLE:Zertifikatsdatei auswählen; CLASS:#32770]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende Import-Pfad mit Dateiname an Dateiauswahl-Fenster (pub-key) ...")
				Send($UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg{Enter}")

				; ! New Dialog !
				; Title: "Ergebnis des Zertifikat-Imports - Kleopatra"
				; Class: "Qt5150QWindowIcon"
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Import Ergebnis-Fenster (pub-key) ...")
				WinWait("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Import Ergebnis-Fenster (pub-key) ...")
				WinActivate("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Aktivierung von Import Ergebnis-Fenster (pub-key) ...")
				WinWaitActive("[TITLE:Ergebnis des Zertifikat-Imports - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
				TraySetToolTip($app_name & ": " & @CRLF & "Sende " & """" & "ok" & """" & " an Dialog (pub-key) ...")
				Send("!o")
				EventWrite($_EventInfo, $app_name, "Import der Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... abgeschlossen, bitte Vollständigkeit der Daten prüfen !")
			Else
				EventWrite($_EventWarning, $app_name, "Die Datei:" & @CRLF & """" & $UserProfRoaming & "\" & $GpgProfile & "_" & $GpgGUID & "\" & "pubring.gpg" & """" & @CRLF & "... existiert nicht, kein Import von " & """" & "pubring.gpg" & """" & " !")
			EndIf

			If ProcessExists($launchproc) Then
				; Close App by "Killing Process" ...
				TraySetToolTip($app_name & ": " & @CRLF & "Der Prozess " & """" & $launchproc & """" & " wird beendet !")
				EventWrite($_EventInfo, $app_name, "Der Prozess:" & @CRLF & """" & $launchproc & """" & @CRLF & "wird beendet !")
				ProcessClose($launchproc)
			Else
				; Write error in LOG, because maybe $launchproc was not
				; provided correctly in INI-file. Checking for $launchproc
				; in INI-files by "LaunchPROC_DONTCHECK" is only relevant
				; for checking of already running processes, but not for
				; already NOT running processes ! So this could be an
				; issue, when $launchproc is not provided correctly in
				; INI-file !!
				TraySetToolTip($app_name & ": " & @CRLF & "!!Warnung!! - Der Prozess " & """" & $launchproc & """" & " ... existiert nicht !")
				EventWrite($_EventWarning, $app_name, "!!Warnung!! - Der Prozess:" & @CRLF & """" & $launchproc & """" & @CRLF & "... existiert nicht !" & @CRLF & "Bitte INI-Datei prüfen !!")
			EndIf

			; Close App by "Autotest" ...
			; ! New Dialog !
			; Title: "Kleopatra"
			; Class: "Qt5150QWindowIcon"
			;#TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster von Kleopatra (Exportergebnis) ...")
			;#WinWait("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			;#TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Fenster von Kleopatra (Exportergebnis) ...")
			;#WinActivate("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			;#TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Kleopatra (Exportergebnis) ...")
			;#WinWaitActive("[TITLE:Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			; STRG-q (Beenden ...)
			;#Send("^q")

			; ! New Dialog !
			; Title: "Wirklich beenden? - Kleopatra"
			; Class: "Qt5150QWindowIcon"
			;#TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster von Kleopatra (BEENDEN) ...")
			;#WinWait("[TITLE:Wirklich beenden? - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			;#TraySetToolTip($app_name & ": " & @CRLF & "Aktiviere Fenster von Kleopatra (BEENDEN) ...")
			;#WinActivate("[TITLE:Wirklich beenden? - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			;#TraySetToolTip($app_name & ": " & @CRLF & "Warte auf Fenster-Aktivierung von Kleopatra (BEENDEN) ...")
			;#WinWaitActive("[TITLE:Wirklich beenden? - Kleopatra; CLASS:Qt5150QWindowIcon]", "")
			;#Send("!e")

			; #############################################################
			; # NO IMPORT IN DESPITE OF $GpgMigrate is "true"             #
			; #############################################################
		Else
			If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Migration ignoriert, da gpg.exe oder kleopatra.exe nicht in Kommandozeile vorhanden sind.", 10)
			If $ShowSplash = "true" Then Sleep(6000)
			EventWrite($_EventWarning, $app_name, "Migration ignoriert, da gpg.exe oder kleopatra.exe nicht in Kommandozeile vorhanden sind.")
		EndIf

		If $ShowSplash = "true" Then ControlSetText($app_name & ": Information", "", "Static1", "--- GnuPG Profil-Migration ---" & @CRLF & "Ende der Migration der GnuPG-Schlüssel mit:" & @CRLF & """" & $launchapp & """" & @CRLF & @CRLF & "BITTE VOLLSTÄNDIGKEIT IHRER DATEN PRÜFEN !" & @CRLF & "Original-Daten stehen als Sicherung zur Verfügung.", 10)
		If $ShowSplash = "true" Then Sleep(6000)
		If $ShowSplash = "true" Then SplashOff()
		; #####################################################################
		; # IMPORT SEQUENCE ---  END  ---
		; #####################################################################
	Else
		TraySetToolTip($app_name & ": " & @CRLF & "Starte " & """" & $launchapp & """" & " ...")
		Local $ControllerExit = 0
		$ControllerExit = Run($launchapp & " " & $launchapp_param, $PrgWorkDirloc, $launchproc_hidden_bool)
		If $ControllerExit = 0 Then
			EventWrite($_EventError, $app_name, "Fehler beim Start von:" & @CRLF & """" & $launchapp & """")
			Exit
		Else
			EventWrite($_EventInfo, $app_name, """" & $launchapp & """" & @CRLF & "... wurde erfolgreich gestartet !")
		EndIf
	EndIf

	TraySetToolTip($app_name)

	If $launchproc_wait = "true" Then
		; Wait for process ...
		; We pay attention for loaders which are named like their started applications !!
		;Sleep($launchproc_sleep) ; Sleep for $launchproc_sleep seconds and wait for possible loaders.
		TraySetToolTip($app_name & ":" & " warte max. " & $launchproc_sleep & " Sek. auf Prozess ...")
		; Wait for the $launchproc process to exist.
		ProcessWait($launchproc, $launchproc_sleep)

		TraySetToolTip($app_name & ":" & " warte auf Prozess-Ende ...")
		; Wait for the $launchproc process to exit.
		ProcessWaitClose($pidController)

		; check for cascaded execution of same-named processes.
		; (name.exe is calling name.exe in another dir and is exiting after child execution ...)
		; ToDo: additional checks are necessary here due to new created PID for sub-process
		; 		Maybe $pidController2 is not the correct PID here ...
		If $launchproc_cascade_bool = "1" Then
			TraySetToolTip($app_name & ":" & " warte max. " & $launchproc_sleep & " Sek. auf Prozess ...")
			; Wait for the $launchproc process to exist.
			$pidController2 = ProcessWait($launchproc, $launchproc_sleep)

			TraySetToolTip($app_name & ":" & " warte auf Prozess-Ende ...")
			; Wait for the $launchproc process to exit.
			ProcessWaitClose($pidController2)
		EndIf

	EndIf

	TraySetToolTip($app_name)

	; First try to close windows named CLOSEWIN0-CLOSEWIN19 softly
	For $i = 0 To 19 Step 1
		$closewin = Eval("closewin" & $i)
		If $closewin <> "" Then
			WinClose($closewin)
			If $closewinWAIT_bool == "true" Then
				WinWaitClose($closewin, "", $closewinTMOUT)
			EndIf
		EndIf
	Next

	; Second forced kill processes KILLAPP0-KILLAPP19
	For $i = 0 To 19 Step 1
		$killapp = Eval("killapp" & $i)
		If $killapp <> "" Then
			If StringRight($killapp, 4) = ".exe" Then
				ProcessClose($killapp)
			EndIf
		EndIf
	Next

	; Third try to delete filesystem-objects REMOVE0-REMOVE19
	For $i = 0 To 19 Step 1
		$remove = Eval("remove" & $i)
		If $remove <> "" Then
			Local $iFileExists = FileExists($remove)
			If $iFileExists Then
				; For debugging
				; MsgBox(48, $appname, "Löschung von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & @CRLF & @CRLF & "erfolgt in 20 Sek. oder nach Kilck von OK ...   ", 10)
				; Exit
				Local $iDelete = FileDelete($remove)
				; For debugging
				; If $iDelete Then
				; 	MsgBox(64, $appname, "Löschung von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & @CRLF & @CRLF & "erfolgreich !   ", 10)
				; Else
				; 	MsgBox(16, $appname, "Fehler beim Löschen von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & " !", 10)
				; EndIf
			EndIf
		EndIf
	Next

EndFunc   ;==>runController

Func cleanupProc()

	;	; First try to close windows named CLOSEWIN0-CLOSEWIN19 softly
	;	For $i = 0 To 19 Step 1
	;		$closewin = Eval("closewin" & $i)
	;		If $closewin <> "" Then
	;			WinClose($closewin)
	;			If $closewinWAIT_bool == "true" Then
	;				WinWaitClose($closewin, "", $closewinTMOUT)
	;			EndIf
	;		EndIf
	;	Next
	;
	;	; Second forced kill processes KILLAPP0-KILLAPP19
	;	For $i = 0 To 19 Step 1
	;		$killapp = Eval("killapp" & $i)
	;		If $killapp <> "" Then
	;			If StringRight($killapp, 4) = ".exe" Then
	;				ProcessClose($killapp)
	;			EndIf
	;		EndIf
	;	Next
	;
	;	; Third try to delete filesystem-objects REMOVE0-REMOVE19
	;	For $i = 0 To 19 Step 1
	;		$remove = Eval("remove" & $i)
	;		If $remove <> "" Then
	;			Local $iFileExists = FileExists($remove)
	;			If $iFileExists Then
	;				; For debugging
	;				; MsgBox(48, $appname, "Löschung von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & @CRLF & @CRLF & "erfolgt in 20 Sek. oder nach Kilck von OK ...   ", 10)
	;				; Exit
	;				Local $iDelete = FileDelete($remove)
	;				; For debugging
	;				; If $iDelete Then
	;				; 	MsgBox(64, $appname, "Löschung von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & @CRLF & @CRLF & "erfolgreich !   ", 10)
	;				; Else
	;				; 	MsgBox(16, $appname, "Fehler beim Löschen von Objekt:" & @CRLF & @CRLF & '"' & $remove & '"' & " !", 10)
	;				; EndIf
	;			EndIf
	;		EndIf
	;	Next

EndFunc   ;==>cleanupProc

