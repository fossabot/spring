; Script generated by the HM NIS Edit Script Wizard.

; Compiler-defines to generate different types of installers
;   SP_UPDATE - Only include changed files and no maps

; Use the 7zip-like compressor
SetCompressor lzma

!include "springsettings.nsh"
!include "LogicLib.nsh"

; HM NIS Edit Wizard helper defines
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\SpringClient.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "graphics\SideBanner.bmp"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Licensepage
!insertmacro MUI_PAGE_LICENSE "gpl.txt"

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page

!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\main.html"
!define MUI_FINISHPAGE_RUN "$INSTDIR\settings.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Configure ${PRODUCT_NAME} settings now"
!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully installed or updated from a previous version.  It is recommended that you configure Spring settings now if this is a fresh installation, otherwise you may encounter problems."

; Finish page
;!ifndef SP_UPDATE

;!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\main.html"
;!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully installed on your computer. It is recommended that you configure Spring settings now if this is a fresh installation, otherwise you may encounter problems."

;!define MUI_FINISHPAGE_RUN "$INSTDIR\settings.exe"
;!define MUI_FINISHPAGE_RUN_TEXT "Configure ${PRODUCT_NAME} settings now"

;!else

;!define MUI_FINISHPAGE_TEXT "${PRODUCT_NAME} version ${PRODUCT_VERSION} has been successfully updated from a previous version."

;!endif


!define MUI_FINISHPAGE_LINK "The ${PRODUCT_NAME} website"
!define MUI_FINISHPAGE_LINK_LOCATION ${PRODUCT_WEB_SITE}
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

;!ifdef SP_UPDATE
;!define SP_OUTSUFFIX1 "_update"
;!else
!define SP_OUTSUFFIX1 ""
;!endif

OutFile "${SP_BASENAME}${SP_OUTSUFFIX1}.exe"
InstallDir "$PROGRAMFILES\Spring"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
;ShowInstDetails show ;fix graphical glitch
;ShowUnInstDetails show ;fix graphical glitch

!include fileassoc.nsh

Function .onInit
  Push $0

  ; The core cannot be deselected
  SectionGetFlags 0 $0
;  IntOp $0 $0 & 14
  IntOp $0 $0 | 16
  SectionSetFlags 0 $0
  
  Pop $0

FunctionEnd

; Only allow installation if spring.exe is from version 0.75
Function CheckVersion
  ClearErrors
  FileOpen $0 "$INSTDIR\spring.exe" r
  IfErrors Fail
  FileSeek $0 0 END $1
;  IntCmp $1 2637824 Done             ; 0.60b1
;  IntCmp $1 2650112 Done             ; 0.61b1
;  IntCmp $1 2670592 Done             ; 0.61b2
;  IntCmp $1 2678784 Done             ; 0.62b1
;  IntCmp $1 2682880 Done             ; 0.63b1 & 0.63b2
;  IntCmp $1 2703360 Done             ; 0.64b1
;  IntCmp $1 3006464 Done             ; 0.65b1
;  IntCmp $1 3014656 Done             ; 0.65b2
;  IntCmp $1 3031040 Done             ; 0.66b1
;  IntCmp $1 3035136 Done             ; 0.67b1 & 0.67b2 & 0.67b3
;  IntCmp $1 2633728 Done             ; 0.70b1
;  IntCmp $1 2650112 Done             ; 0.70b2
;  IntCmp $1 2707456 Done             ; 0.70b3
;  IntCmp $1 5438464 Done             ; 0.74b1
;  IntCmp $1 5487104 Done             ; 0.74b2
;  IntCmp $1 5478912 Done             ; 0.74b3
  IntCmp $1 7470080 Done              ; 0.75b1
  IntCmp $1 7471104 Done              ; 0.75b2
Fail:
  MessageBox MB_ICONSTOP|MB_OK "This installer can only be used to upgrade a full installation of Spring 0.75. Your current folder does not contain a spring.exe from that version, so the installation will be aborted.. Please download the full installer instead and try again."
  Abort "Unable to upgrade, version 0.75b1 or 0.75b2 not found.."
  Goto done

Done:
  FileClose $0

FunctionEnd

;Three functions which check to make sure OTA Content is installed before installing Mods that depend on it.
Function CheckTATextures
  ClearErrors
  FileOpen $0 "$INSTDIR\base\tatextures_v062.sdz" r
  IfErrors Fail
  FileSeek $0 0 END $1

  IntCmp $1 1245637 Done              
Fail:
  inetc::get \
             "http://buildbot.no-ip.org/~lordmatt/base/tatextures_v062.sdz" "$INSTDIR\base\tatextures_v062.sdz" 
Done:
  FileClose $0

FunctionEnd

Function CheckOTAContent
  ClearErrors
  FileOpen $0 "$INSTDIR\base\otacontent.sdz" r
  IfErrors Fail
  FileSeek $0 0 END $1

  IntCmp $1 7421640 Done              
Fail:
  inetc::get \
             "http://buildbot.no-ip.org/~lordmatt/base/otacontent.sdz" "$INSTDIR\base\otacontent.sdz" 
Done:
  FileClose $0

FunctionEnd

Function CheckTAContent
  ClearErrors
  FileOpen $0 "$INSTDIR\base\tacontent_v2.sdz" r
  IfErrors Fail
  FileSeek $0 0 END $1

  IntCmp $1 284 Done              
Fail:
  inetc::get \
             "http://buildbot.no-ip.org/~lordmatt/base/tacontent_v2.sdz" "$INSTDIR\base\tacontent_v2.sdz"
Done:
  FileClose $0

FunctionEnd


Section "Main application (req)" SEC_MAIN
!ifdef SP_UPDATE
!ifndef TEST_BUILD
  Call CheckVersion
!endif
!endif
  !define INSTALL
  !include "sections\main.nsh"
  !include "sections\luaui.nsh"
  !undef INSTALL
SectionEnd


Section "Multiplayer battleroom" SEC_BATTLEROOM
  !define INSTALL
  !include "sections\tasclient.nsh"
  !undef INSTALL
SectionEnd


SectionGroup "Maps"
	Section "Defualt Maps" SEC_MAPS
	!define INSTALL
	!include "sections\maps.nsh"
	!undef INSTALL
	SectionEnd

        Section "1 vs 1 Maps" SEC_1V1MAPS
	!define INSTALL
	!include "sections\1v1maps.nsh"
	!undef INSTALL
	SectionEnd

	Section "Teamplay Maps" SEC_TEAMMAPS
	!define INSTALL
	!include "sections\teammaps.nsh"
	!undef INSTALL
	SectionEnd
SectionGroupEnd


SectionGroup "Mods (The Games You Can Play)"
	Section "Balanced Annihilation (BA)" SEC_BA
	!define INSTALL
        Call CheckTATextures
        Call CheckOTAContent
        Call CheckTAContent
	!include "sections\ba.nsh"
	!undef INSTALL
	SectionEnd

	Section "XTA" SEC_XTA
	!define INSTALL
        Call CheckTATextures
        Call CheckOTAContent
        Call CheckTAContent
	!include "sections\xta.nsh"
	!undef INSTALL
	SectionEnd
SectionGroupEnd

Section "Start menu shortcuts" SEC_START
  !define INSTALL
  !include "sections\shortcuts.nsh"
  !undef INSTALL
SectionEnd

Section "Desktop shortcut" SEC_DESKTOP
${If} ${SectionIsSelected} ${SEC_BATTLEROOM}
  SetOutPath "$INSTDIR"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME} battleroom.lnk" "$INSTDIR\TASClient.exe"
${EndIf}
SectionEnd

Section "Easy content installation" SEC_ARCHIVEMOVER
  !define INSTALL
  !include "sections\archivemover.nsh"
  !undef INSTALL
SectionEnd

SectionGroup "AI opponent plugins (Bots)"
	Section "AAI" SEC_AAI
	!define INSTALL
	!include "sections\aai.nsh"
	!undef INSTALL
	SectionEnd

	Section "KAI" SEC_KAI
	!define INSTALL
	!include "sections\kai.nsh"
	!undef INSTALL
	SectionEnd
SectionGroupEnd

!include "sections\sectiondesc.nsh"

Section -Documentation
  !define INSTALL
  !include "sections\docs.nsh"
  !undef INSTALL
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\springclient.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\spring.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
  IfSilent +3
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  IfSilent +3
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall

  !include "sections\maps.nsh"
  !include "sections\1v1maps.nsh"
  !include "sections\teammaps.nsh"

  !include "sections\main.nsh"

  !include "sections\docs.nsh"
  !include "sections\shortcuts.nsh"
  !include "sections\archivemover.nsh"
  !include "sections\aai.nsh"
  !include "sections\kai.nsh"
  !include "sections\tasclient.nsh"
  !include "sections\luaui.nsh"

  !include "sections\BA.nsh"
  !include "sections\XTA.nsh"

  Delete "$DESKTOP\${PRODUCT_NAME} battleroom.lnk"

  ; All done
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
