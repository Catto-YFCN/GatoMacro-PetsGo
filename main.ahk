Menu, Tray, Icon, %A_ScriptDir%\images\paw.ico
#Persistent
#SingleInstance Force
#Include lib\OCR.ahk
#Include lib\Gdip_All.ahk
#Include lib\webhook.ahk
Gdip_Startup()
; Path to the INI file
IniFile := A_ScriptDir . "\settings\config.ini"
; Define a list of colors


IniWrite, 0.0.1, %IniFile%, Stats, localVersion
; Update Check
url := "https://raw.githubusercontent.com/Catto-YFCN/GatoMacroData/refs/heads/main/Data.ini"
configFile := A_ScriptDir "\settings\config.ini"

tempFile := A_Temp "\Data.ini"

URLDownloadToFile, %url%, %tempFile%
if !FileExist(tempFile)
{
    MsgBox, 16, Error, Failed to download the INI file.
    ExitApp
}

IniRead, currentVersion, %tempFile%, Version, currentVersion
IniRead, severityLevel, %tempFile%, Version, severityLevel
IniRead, description, %tempFile%, Version, description

; Replace \n with actual new lines in the description
description := StrReplace(description, "\n", "`n")

IniRead, localVersion, %configFile%, Stats, localVersion

if (CompareVersions(localVersion, currentVersion) < 0)
{
    if (severityLevel = 1)
    {
        output := "Your version: " localVersion "`n" "Current Version: " currentVersion "`n`n"
        output .= "Description:`n" description "`n`n"
        output .= "Update?`n"

        MsgBox, 4, Update Detected!, %output%

        ; Handle the user's response
        ifMsgBox Yes
        {
            Run % "https://github.com/Catto-YFCN/GatoMacroData/releases/tag/Release"
        }
    }
}

FileDelete, %tempFile%

CompareVersions(v1, v2)
{
    StringSplit, v1Array, v1, .
    StringSplit, v2Array, v2, .

    if (v1Array1 < v2Array1)
        return -1
    if (v1Array1 > v2Array1)
        return 1

    if (v1Array2 < v2Array2)
        return -1
    if (v1Array2 > v2Array2)
        return 1

    if (v1Array3 < v2Array3)
        return -1
    if (v1Array3 > v2Array3)
        return 1

    return 0
}

; Pre-loading boo
IniRead, firstTime, %IniFile%, Stats, firstTime, 1
if(firstTime=1){
    MsgBox, 64, Welcome!, Seems like it's your first time here. Remember that when starting, you need to make sure you haven't done anything, as in rejoin the server, and don't touch anything, and start the macro.
    IniWrite, 0, %IniFile%, Stats, firstTime
}
; Pre-loading these 4 because of the webhook function boohoo
IniRead, webhookLink, %IniFile%, Settings, webhookLink, DefaultLink
IniRead, webhookToggle, %IniFile%, Settings, webhookToggle, 0
IniRead, pingToggle, %IniFile%, Settings, pingToggle, 0
IniRead, discordID, %IniFile%, Settings, discordID, 123456789


webhookPost({embedContent: "Connected to Discord!", embedColor:"5066239"})
zoomOut(){
    Send, {O down}
    Sleep, 2000
    Send, {O up}
}

zoomOutTiny(){
    Send, {O down}
    Sleep, 400
    Send, {O up}
}
; Sleep, 2000
; zoomOutTiny()
zoomIn(){
    Send, {I down}
    Sleep, 2000
    Send, {I up}
}


redpixel(x, y) {
    Gui, PixelGUI:New, -Caption +ToolWindow +AlwaysOnTop +E0x20 ; Transparent GUI with no window title
    Gui, Color, Red  ; Set the GUI's background color to red (the "pixel")
    
    ; Create a 1x1 pixel window at the specified coordinates
    Gui, Show, x%x% y%y% w100 h100, RedPixel
    
    ; Set a timer to hide the pixel after 5 seconds
    SetTimer, HidePixel, -5000
    return

    HidePixel:
        Gui, PixelGUI:Destroy  ; Remove the GUI after 5 seconds
    return
}


align() {
    colorToFind := 0x00FFFF
    searchTolerance := 0
    Send, {D down}
    Send, {S down}
    Send, {Space down}

    loop {
        PixelSearch, xPos, yPos, 860, 440, 1060, 640, colorToFind, searchTolerance, Fast RGB

        if (ErrorLevel = 0) {
            while true {
                PixelSearch, xCheck, yCheck, 860, 440, 1060, 640, colorToFind, searchTolerance, Fast RGB
                if (ErrorLevel != 0) {
                    ; redpixel(xPos, yPos)  ; Using the last known coordinates from xPos, yPos
                    break
                }
                Sleep, 100
            }
            Send, {D up}
            Send, {S up}
            Send, {Space up}
            return
        }
        Sleep, 100
    }
}



closeChat()
{
    PixelGetColor, chatColor, 48, 485, Fast RGB
    if (chatColor = 0xBBCDDD)
    {
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2
        return true
    }
    else
    {
        return false
    }
}



waitStart() {
    Loop {
        if (closeChat())
            break
        Sleep, 500
    }
}



CheckBottomCenter(filePath) {
    topLeft := [860, 1000]
    size := [200, 65]

    pBitmap := Gdip_BitmapFromScreen(topLeft[1] "|" topLeft[2] "|" size[1] "|" size[2])
    if !pBitmap {
        MsgBox, Failed to capture screen.
        return
    }

    if !Gdip_SaveBitmapToFile(pBitmap, filePath) {
        Gdip_DisposeImage(pBitmap)
        return
    }

    Gdip_DisposeImage(pBitmap)
}

screenshot(filePath)
{
    ; Initialize GDI+ and create a graphics object
    pToken := Gdip_Startup()
    
    ; Capture the entire screen
    pBitmap := Gdip_BitmapFromScreen()
    
    ; Save the bitmap to the specified file path (supports png, jpg, bmp, etc.)
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    
    ; Clean up resources
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    
    ; Return the path for confirmation (optional)
    return filePath
}

; Variable to track macro state
MacroRunning := False

; Register global hotkeys
Hotkey, F1, StartMacro, On
Hotkey, F2, PauseMacro, On
Hotkey, F3, StopMacro, On

; GUI Creation
Gui, New, +Resize
Gui, Font, s10  ; Smaller font size for buttons

; Create the tabs
Gui, Add, Tab2, x10 y10 w480 h205 vMainTab hwndTabHWND, Main|Settings|Credits

; MAIN TAB
Gui, Tab, Main
Gui, Font, s10  ; Smaller font size within the tabs

; Rolling GroupBox
Gui, Add, GroupBox, x15 y35 w120 h90, Rolling
Gui, Add, Checkbox, x20 y55 vEnableRoll gSaveSettings, Enable Rolling
Gui, Add, GroupBox, x20 y70 w110 h50
Gui, Add, Checkbox, x25 y80 vEnableAutoRoll gSaveSettings, Auto Roll
Gui, Add, Checkbox, x25 y100 vEnableHideRoll gSaveSettings, Hide Roll

; Vending GroupBox
Gui, Add, GroupBox, x145 y35 w125 h90, Vending
Gui, Add, Checkbox, x150 y55 vEnableVending gSaveSettings, Enable Vending
Gui, Add, GroupBox, x150 y70 w115 h50
Gui, Add, Checkbox, x155 y80 vEnableVendingPotion gSaveSettings, Potions
; Gui, Add, Checkbox, x155 y100 vEnableVendingHolder gSaveSettings, Placeholder

; Gui, Add, Text, x20 y65, Select Map:
; Gui, Add, DropDownList, x20 y80 w100 vSelectMap gSaveSettings, 1 - Planet Namak|2 - Sand Village|3 - Double Dungeon
; Gui, Add, Text, x20 y105, Select Level:
; Gui, Add, DropDownList, x20 y120 w100 vSelectLevel gSaveSettings, Act 1|Act 2|Act 3|Act 4|Act 5|Act 6|Infinite|Paragon
; Gui, Add, Text, x20 y145, Select Type:
; Gui, Add, DropDownList, x20 y160 w100 vSelectType gSaveSettings, Normal|Nightmare


; ; Farming+ GroupBox
; Gui, Add, GroupBox, x140 y35 w135 h110, Farming+ ( Legend )
; ; Info button
; Gui, Add, Button, x255 y40 w20 h20 gFarmingPlusInfoBox, ?
; Gui, Add, Checkbox, x145 y50 vEnableFarmingPlus gSaveSettings, Enable Farming+
; Gui, Add, Text, x145 y65, Select Map:
; Gui, Add, DropDownList, x145 y80 w100 vSelectMapPlus gSaveSettings, 1 - Sand Village|2 - Double Dungeon
; Gui, Add, Text, x145 y105, Select Level:
; Gui, Add, DropDownList, x145 y120 w100 vSelectLevelPlus gSaveSettings, Act 1|Act 2|Act 3

; ; Time Chamber GroupBox
; Gui, Add, GroupBox, x140 y145 w135 h40, Time Chamber
; Gui, Add, Checkbox, x145 y160 vEnableTimeChamber gSaveSettings, Enable Time Chamber

; ; Macro GroupBox
; Gui, Add, GroupBox, x280 y35 w205 h175, Macro
; ; Info Button
; Gui, Add, Button, x465 y40 w20 h20 gMacroInfoBox, ?
; Gui, Add, Text, x285 y50, Starting Macro
; Gui, Add, DropDownList, x285 y65 w90 vSelectStartMacro gSaveSettings, 
; Gui, Add, Text, x385 y50, Repeating Macro
; Gui, Add, DropDownList, x385 y65 w90 vSelectRepeatMacro gSaveSettings, 
; PopulateDropdowns()
; ; Set font size smaller before adding the text
; Gui, Font, s7 ; Set font size to 8 (you can adjust this value to make it smaller or larger)

; ; Macro Creator GroupBox
; Gui, Add, GroupBox, x285 y90 w190 h115, Macro Creator
; Gui, Add, Text, x290 y105 c008000, You should join the discord to better`nunderstand this feature.
; Gui, Add, Button, x290 y135 w150 gMacroCreatorOpen, Open Macro Creator  ; Set width to 150
; Gui, Add, Button, x290 y165 w150 gMacroCreatorEdit, Edit Existing Macro  ; Set the same width


; ; Below Farming, Farming+/Time Chamber too empty so this line is to just filler
; Gui, Add, Text, x15 y200 w262 h1 0x10,  ; A thin horizontal line
; Gui, Add, Text, x15 y201 w262 h1 0x10,  ; A thin horizontal line
; Gui, Add, Text, x15 y202 w262 h1 0x10,  ; A thin horizontal line

; EXTRAS Tab


; Gui, Tab, Extras
; Gui, Add, Text, x15 y40 cRed, Notice: 
; Gui, Add, Text, x+0 y40, All options in this tab still use macros from the main tab.
; ; Raids GroupBox
; Gui, Add, GroupBox, x15 y55 w135 h110, Raids
; Gui, Add, Checkbox, x20 y70 vEnableRaid gSaveSettings, Enable Raid
; Gui, Add, Text, x20 y85, Select Map:
; Gui, Add, DropDownList, x20 y100 w100 vSelectMapRaid gSaveSettings, 1 - Spider Forest
; Gui, Add, Text, x20 y125, Select Level:
; Gui, Add, DropDownList, x20 y140 w100 vSelectLevelRaid gSaveSettings, Act 1|Act 2|Act 3|Act 4

; ; Boss Raid GroupBox
; Gui, Add, GroupBox, x15 y165 w135 h40, Boss Raids
; Gui, Add, Checkbox, x20 y180 vEnableBossRaid gSaveSettings, Enable Boss Raids

; Gui, Add, GroupBox, x15 y95 w120 h60, Challenges ( Soon )


; ; Farming+ GroupBox
; Gui, Add, GroupBox, x140 y35 w135 h110, Farming+
; ; Info button
; Gui, Add, Button, x255 y40 w20 h20 gFarmingPlusInfoBox, ?
; Gui, Add, Checkbox, x145 y50 vEnableFarmingPlus gSaveSettings, Enable Farming+
; Gui, Add, Text, x145 y65, Select Map:
; Gui, Add, DropDownList, x145 y80 w100 vSelectMapPlus gSaveSettings, 1 - Sand Village|2 - Double Dungeon
; Gui, Add, Text, x145 y105, Select Level:
; Gui, Add, DropDownList, x145 y120 w100 vSelectLevelPlus gSaveSettings, Act 1|Act 2|Act 3

; ; Time Chamber GroupBox
; Gui, Add, GroupBox, x140 y145 w135 h40, Time Chamber
; Gui, Add, Checkbox, x145 y160 vEnableTimeChamber gSaveSettings, Enable Time Chamber


; SETTINGS TAB
Gui, Tab, Settings
Gui, Font, s8  ; Smaller font size within the tabs

; Webhook Section
Gui, Add, GroupBox, x15 y35 w220 h125, Discord Webhook
Gui, Add, Checkbox, x20 y50 vEnableWebhook gSaveSettings, Enable Webhook
Gui, Add, Text, x20 y65, Webhook URL:
Gui, Add, Edit, x20 y80 w200 vWebhookInput gSaveSettings, Webhook URL
Gui, Add, Checkbox, x20 y105 vEnablePings gSaveSettings, Enable Pings
Gui, Add, Text, x20 y120, Discord User ID:
Gui, Add, Edit, x20 y135 w200 vPingInput gSaveSettings, User ID

; Reconnect Section
Gui, Add, Button, x445 y40 w20 h20 gReconnectInfoBox, ?
Gui, Add, GroupBox, x245 y35 w220 h70, Reconnect
Gui, Add, Checkbox, x250 y50 vEnableReconnect gSaveSettings, Enable Reconnect
Gui, Add, Text, x250 y65, Private Server Link:
Gui, Add, Edit, x250 y80 w200 vReconnectTime gSaveSettings, Server Link

; User Info
; Info Box
; Gui, Add, Button, x445 y110 w20 h20 gUserInfoInfoBox, ?
; Gui, Add, GroupBox, x245 y105 w220 h40, Info
; Gui, Add, Text, x250 y125, Level:
; ; Gui, Add, Edit, x290 y120 w30 h15 vUserLevel gSaveSettings, 0
; Gui, Add, DropDownList, x290 y120 w100 vUserLevel gSaveSettings, Level 21 and below|Level 22 and above

Gui, Add, Button, x445 y120 w20 h20 gSettingsInfoBox, ?
Gui, Add, GroupBox, x245 y115 w220 h45, Settings
Gui, Add, Button, x250 y130 w90 gExportSettings, Export Settings  ; Set the same width
Gui, Add, Button, x350 y130 w90 gImportSettings, Import Settings  ; Set the same width

; CREDITS TAB
Gui, Tab, Credits

; Creators GroupBox
Gui, Add, GroupBox, x20 y40 w250 h80, Creators
Gui, Add, Picture, x25 y55 w60 h60, %A_ScriptDir%\images\Gato.png
Gui, Add, Text, x90 y55, Gato -  Lead developer, I made this`nmacro because I've seen macro's`nfor numerous games and wanted`nto give it a shot lol. ; Placeholder text for Gato image

; Add a line (separator) between the two images
; Gui, Add, Text, x20 y125 w253 h1 0x10,  ; A thin horizontal line

; Gui, Add, Picture, x25 y140 w60 h60, %A_ScriptDir%\images\Kanekovisk.png
; Gui, Add, Text, x90 y140, Kanekovisk -  Ex-developer, helped`nin the early development of Gato`nMacro but has since stopped working`non it, this wouldn't have been possible`nwithout him. ; Placeholder text for Kanekovisk image

; DolphSol & Natro GroupBox
Gui, Add, GroupBox, x280 y40 w200 h80, DolphSol n Natro
Gui, Add, Picture, x285 y55 w60 h60, %A_ScriptDir%\images\Dolph.png
Gui, Add, Picture, x355 y55 w60 h60, %A_ScriptDir%\images\Natro.ico
Gui, Add, Text, x420 y50, Helped me`nunderstand`nAHK and`nhad some`nrecourses. ; Placeholder text for DolphSol image

; Natro GroupBox
; Gui, Add, GroupBox, x280 y125 w200 h85, Natro
; Gui, Add, Picture, x285 y55 w60 h60, %A_ScriptDir%\images\Natro.ico
; Gui, Add, Text, x350 y160, Placeholder  ; Placeholder text for Natro image

Gui, Tab  ; Reset to default tab

; Add the Discord join button
Gui, Add, Picture, x455 y220 w30 h25 gJoinDiscord, %A_ScriptDir%/images/discordIcon.png

; Add the bottom buttons
Gui, Font, s8
Gui, Add, Button, x10 y220 w80 h25 gStartMacro, F1 - Start
Gui, Add, Button, x100 y220 w80 h25 gPauseMacro, F2 - Pause
Gui, Add, Button, x190 y220 w80 h25 gStopMacro, F3 - Stop

; Show the GUI
Gui, Show, w500 h250, GatoMacro - Pets Go! v%localVersion%
; Read and load settings at startup (Auto-load configs)
IniRead, webhookToggle, %IniFile%, Settings, webhookToggle
IniRead, webhookLink, %IniFile%, Settings, webhookLink
IniRead, pingToggle, %IniFile%, Settings, pingToggle
IniRead, discordID, %IniFile%, Settings, discordID
IniRead, reconnectToggle, %IniFile%, Settings, reconnectToggle
IniRead, serverLink, %IniFile%, Settings, serverLink
IniRead, rollToggle, %IniFile%, Settings, rollToggle
IniRead, autoRollToggle, %IniFile%, Settings, autoRollToggle
IniRead, hideRollToggle, %IniFile%, Settings, hideRollToggle
IniRead, vendingToggle, %IniFile%, Settings, vendingToggle
IniRead, vendingPotionToggle, %IniFile%, Settings, vendingPotionToggle


GuiControl,, EnableWebhook, %webhookToggle%
GuiControl,, WebhookInput, %webhookLink%
GuiControl,, EnablePings, %pingToggle%
GuiControl,, PingInput, %discordID%
GuiControl,, EnableReconnect, %reconnectToggle%
GuiControl,, ReconnectTime, %serverLink%
GuiControl,, EnableRoll, %rollToggle%
GuiControl,, EnableAutoRoll, %autoRollToggle%
GuiControl,, EnableHideRoll, %hideRollToggle%
GuiControl,, EnableVending, %vendingToggle%
GuiControl,, EnableVendingPotion, %vendingPotionToggle%

return

GuiClose:
ExitApp

SaveSettings:
    GuiControlGet, webhookToggle,, EnableWebhook
    GuiControlGet, webhookLink,, WebhookInput
    GuiControlGet, pingToggle,, EnablePings
    GuiControlGet, discordID,, PingInput
    GuiControlGet, reconnectToggle,, EnableReconnect
    GuiControlGet, serverLink,, ReconnectTime
    GuiControlGet, rollToggle,, EnableRoll
    GuiControlGet, autoRollToggle,, EnableAutoRoll
    GuiControlGet, hideRollToggle,, EnableHideRoll
    GuiControlGet, vendingToggle,, EnableVending
    GuiControlGet, vendingPotionToggle,, EnableVendingPotion

    if (webhookToggle) {
        if (webhookLink = "") {
            webhookLink := "https://discord.com/api/webhooks/"
        } else if (webhookLink != "https://discord.com/api/webhooks/" && !RegExMatch(webhookLink, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)")) { ; Filter by natro.. got from dolphSol
            MsgBox, Invalid Webhook URL. Please enter a valid URL.
            return
        }
    }
    
    
    if (discordID != "") {
        if (!RegExMatch(discordID, "^\d+$")) {
            MsgBox, Invalid Discord User ID. Please enter a valid numeric ID. ; Very simple check to see if it has only numbers
            return
        }
    }
    
    if (reconnectToggle) {
        if (serverLink != "" && !InStr(serverLink, "privateServerLinkCode=")) {  ; Ensure server link contains "privateServerLinkCode="
            MsgBox, % "The private server link you provided is a share link, instead of a privateServerLinkCode link. To get the code link, paste the share link into your browser and run it. This should convert the link to a privateServerLinkCode link. Copy and paste the converted link into the Private Server setting to fix this issue.`n`nThe link should look like: https://www.roblox.com/games/18901165922/PETS-GO-NEW?privateServerLinkCode=..."
            return
        }
    }
    
    

    ; Write the updated settings to the INI file
    IniWrite, %webhookToggle%, %IniFile%, Settings, webhookToggle
    IniWrite, %webhookLink%, %IniFile%, Settings, webhookLink
    IniWrite, %pingToggle%, %IniFile%, Settings, pingToggle
    IniWrite, %discordID%, %IniFile%, Settings, discordID
    IniWrite, %reconnectToggle%, %IniFile%, Settings, reconnectToggle
    IniWrite, %serverLink%, %IniFile%, Settings, serverLink
    IniWrite, %rollToggle%, %IniFile%, Settings, rollToggle
    IniWrite, %autoRollToggle%, %IniFile%, Settings, autoRollToggle
    IniWrite, %hideRollToggle%, %IniFile%, Settings, hideRollToggle
    IniWrite, %vendingToggle%, %IniFile%, Settings, vendingToggle
    IniWrite, %vendingPotionToggle%, %IniFile%, Settings, vendingPotionToggle

    ; Old version
    ; if (rollToggle = 1) {
    ;     GuiControl, Enable, EnableAutoRoll
    ;     GuiControl, Enable, EnableHideRoll
    ; } else if (vendingToggle = 1) {
    ;     GuiControl, Enable, EnableVendingPotion
    ; } else {
    ;     GuiControl, Disable, EnableAutoRoll
    ;     GuiControl, Disable, EnableHideRoll
    ;     GuiControl, Disable, EnableVendingPotion
    ; }

    if (rollToggle = 1) {
        GuiControl, Enable, EnableAutoRoll
        GuiControl, Enable, EnableHideRoll
    } else {
        GuiControl, Disable, EnableAutoRoll
        GuiControl, Disable, EnableHideRoll
    }
    
    if (vendingToggle = 1) {
        GuiControl, Enable, EnableVendingPotion
    } else {
        GuiControl, Disable, EnableVendingPotion
    }
    
return


ClickAndReturn:
    MouseGetPos, origX, origY
    Click, 960, 945
    MouseMove, %origX%, %origY%, 0
    return


checkAndRoll(){
    global autoRollToggle
    global hideRollToggle
    CheckBottomCenter(A_ScriptDir . "\roll.png")
    result := ocr(A_ScriptDir . "\roll.png", "en")
    result := Trim(result)
    if (InStr(result, "Ro", false)) {
        if (InStr(result, "in", false)){
        }
        else{
        Tooltip, % result "Success"
        Click, 960, 945
        Sleep, 1000
        if (autoRollToggle=1){
            Click, 415, 970
            Sleep, 1000
        }
        if (hideRollToggle=1){
            Click, 1510, 965
        }
        ToolTip, 
        }
    } else {
        ; Tooltip, % ocr("roll.png", "en")
    }
}

mainLoop(){
    global vendingToggle
    global vendingPotionToggle
    loop{
        Sleep, 300000
        if (vendingToggle = 1) {
            if (vendingPotionToggle = 1){
                webhookPost({embedContent:"Going to vending machine & buying from it!", embedColor:"3066993"})
                Run, % A_ScriptDir . "\paths\vendingMachine.ahk"
            }
            else{
            }
        }
    }
}



StartMacro:
    if (MacroRunning) {
        MsgBox, Macro is already running.
        return
    }
    MacroRunning := True
    webhookPost({embedContent:"Macro Started!", embedColor:"16777215"})

    Gui, Hide

    SetTimer, CheckReconnect, 3000

    Process, Exist, RobloxPlayerBeta.exe
    if (!ErrorLevel) {
        if (serverLink != "") {
            StringGetPos, pos, serverLink, privateServerLinkCode=
            if (pos >= 0) {
                psID := SubStr(serverLink, pos + StrLen("privateServerLinkCode=") + 1)
                Run % "roblox://placeID=18901165922&linkCode=" psID
            } else {
                Run % "roblox://placeID=18901165922"
            }
        }
    } else {
        WinActivate, ahk_exe RobloxPlayerBeta.exe
        Sleep, 1000
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2
        Click
        zoomIn()
        MouseClickDrag, R, A_ScreenWidth // 2, A_ScreenHeight // 2, A_ScreenWidth // 2, A_ScreenHeight // 2 + 500, 0
        zoomOutTiny()
        Sleep, 1000
        align()
        zoomOut()
        if (rollToggle = 1 and (autoRollToggle or hideRollToggle = 1)) {
            checkAndRoll()
        }
        else if (rollToggle = 1) {
            SetTimer, ClickAndReturn, 2000
        }
        if (vendingToggle = 1) {
            if (vendingPotionToggle = 1){
                webhookPost({embedContent:"Going to vending machine & buying from it!", embedColor:"3066993"})
                Run, % A_ScriptDir . "\paths\vendingMachine.ahk"
            }
            else{
            }
        }
        Sleep, 120000
        mainLoop()
    }
return



PauseMacro:
    if (!MacroRunning) {
        MsgBox, Macro is not running. Start the macro first.
        return
    }
    webhookPost({embedContent:"Macro Paused!", embedColor:"16777215"})
    MsgBox, supposed to pause, but this really doesn't do anything atm lol
return

StopMacro:
    if (!MacroRunning) {
        MsgBox, Macro is not running. Start the macro first.
        return
    }
    CloseRunningScripts()
    MacroRunning := False
    webhookPost({embedContent:"Macro Stopped!", embedColor:"16777215"})

    
    ; Restore the macro GUI
    WinActivate, ahk_exe AutoHotKey.exe
return

JoinDiscord:
Run % "https://discord.gg/3cg26VYV"
return






; Reconnecting
CheckReconnect:
    Process, Exist, RobloxPlayerBeta.exe
    if (ErrorLevel) {
        ImageSearch, Reconnectx, Reconnecty, 960, 600, 1150, 650, *20 %A_ScriptDir%/images/reconnect.png
        if !ErrorLevel
        {
            screenshot(A_ScriptDir . "\screenshot.png")
            if (pingToggle=1){
                webhookPost({content: "<@" discordID ">",files:[A_ScriptDir "\screenshot.png"],embedImage:"attachment://screenshot.png",embedContent: "Disconnected! Reconnecting..", embedColor:"16711680"})
            }
            else{
                webhookPost({files:[A_ScriptDir "\screenshot.png"],embedImage:"attachment://screenshot.png",embedContent: "Disconnected! Reconnecting..", embedColor:"16711680"})
            }
            FileDelete, % A_ScriptDir . "\screenshot.png"
            CloseRunningScripts()
            closeRoblox()
            Sleep, 5000
            if (serverLink != "") {
                StringGetPos, pos, serverLink, privateServerLinkCode=
                if (pos >= 0) {
                    psID := SubStr(serverLink, pos + StrLen("privateServerLinkCode=") + 1)
                    Run % "roblox://placeID=18901165922&linkCode=" psID
                } else {
                    Run % "roblox://placeID=18901165922"
                }
            }
            SetTimer, CheckRoblox, 1000
            waitStart()
            Sleep, 1000
            MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2
            Click
            zoomIn()
            MouseClickDrag, R, A_ScreenWidth // 2, A_ScreenHeight // 2, A_ScreenWidth // 2, A_ScreenHeight // 2 + 500, 0
            zoomOutTiny()
            Sleep, 1000
            align()
            zoomOut()
            if (rollToggle = 1 and (autoRollToggle or hideRollToggle = 1)) {
                checkAndRoll()
            }
            else if (rollToggle = 1) {
                SetTimer, ClickAndReturn, 2000
            }
            if (vendingToggle = 1) {
                if (vendingPotionToggle = 1)
                    Run, % A_ScriptDir . "\paths\vendingMachine.ahk"
                else{
                }
            }
            Sleep, 120000
            mainLoop()

        }
    } else {
        screenshot(A_ScriptDir . "\screenshot.png")
        if (pingToggle=1){
            webhookPost({content: "<@" discordID ">",files:[A_ScriptDir "\screenshot.png"],embedImage:"attachment://screenshot.png",embedContent: "Disconnected! Reconnecting..", embedColor:"16711680"})
        }
        else{
            webhookPost({files:[A_ScriptDir "\screenshot.png"],embedImage:"attachment://screenshot.png",embedContent: "Disconnected! Reconnecting..", embedColor:"16711680"})
        }
        FileDelete, % A_ScriptDir . "\screenshot.png"
        CloseRunningScripts()
        closeRoblox()
        Sleep, 5000
        if (serverLink != "") {
            StringGetPos, pos, serverLink, privateServerLinkCode=
            if (pos >= 0) {
                psID := SubStr(serverLink, pos + StrLen("privateServerLinkCode=") + 1)
                Run % "roblox://placeID=18901165922&linkCode=" psID
            } else {
                Run % "roblox://placeID=18901165922"
            }
        }

        SetTimer, CheckRoblox, 1000
        waitStart()
        Sleep, 1000
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2
        Click
        zoomIn()
        MouseClickDrag, R, A_ScreenWidth // 2, A_ScreenHeight // 2, A_ScreenWidth // 2, A_ScreenHeight // 2 + 500, 0
        zoomOutTiny()
        Sleep, 1000
        align()
        zoomOut()
        if (rollToggle = 1 and (autoRollToggle or hideRollToggle = 1)) {
            checkAndRoll()
        }
        else if (rollToggle = 1) {
            SetTimer, ClickAndReturn, 2000
        }
        if (vendingToggle = 1) {
            if (vendingPotionToggle = 1)
                Run, % A_ScriptDir . "\paths\vendingMachine.ahk"
            else{
            }
        }
        Sleep, 120000
        mainLoop()
    }
return


CheckRoblox:
    Process, Exist, RobloxPlayerBeta.exe
    
    if (ErrorLevel) {
        WinActivate, ahk_exe RobloxPlayerBeta.exe
        SetTimer, CheckRoblox, Off
    }
return

CloseRunningScripts() {
    DetectHiddenWindows, On  ; Enable detection of hidden windows

    WinGet, idList, List, ahk_class AutoHotkey
    Loop, %idList%
    {
        hwnd := idList%A_Index%
        if (hwnd != A_ScriptHwnd)
        {
            WinClose, ahk_id %hwnd%
        }
    }
}


; CheckHourlyReport:
;     ; Get the current time in HH:mm:ss format
;     FormatTime, currentTime, , HH:mm:ss

;     ; Check if the current time is exactly at the start of an hour and if MacroRunning is true
;     if (MacroRunning && (currentTime ~= "00:59:59|01:59:59|02:59:59|03:59:59|04:59:59|05:59:59|06:59:59|07:59:59|08:59:59|09:59:59|10:59:59|11:59:59|12:59:59|13:59:59|14:59:59|15:59:59|16:59:59|17:59:59|18:59:59|19:59:59|20:59:59|21:59:59|22:59:59|23:59:59")) {
;         ; Run the script
;         Run, % A_ScriptDir . "\Tracker\format.ahk"
;         Sleep, 1000
;         Run, % A_ScriptDir . "\Tracker\HourlyReport.ahk"
;         ; Sleep for a minute to prevent it from running multiple times within the same hour
;         Sleep, 60000
;     }
; return




closeRoblox(){
    WinClose, Roblox
    WinClose, % "Roblox Crash"
    Sleep, 300
    WinClose, Roblox
    WinClose, % "Roblox Crash"
}

F1::
    Gosub, StartMacro
    return

F2::
    Gosub, PauseMacro
    return

F3::
    Gosub, StopMacro
    return

MacroCreatorEdit:
    ; macroCreatorDir := A_ScriptDir "\MacroCreator"
    ; FileSelectFile, SelectedFile, 3, %macroCreatorDir%, Select an AHK file, AHK Files (*.ahk)
    
    ; if SelectedFile
    ; {
    ;     MsgBox, You selected: %SelectedFile%
    ; }
    MsgBox, Work in progress.
return

ExportSettings:
    configFilePath := A_ScriptDir . "\settings\config.ini"
    
    ; Check if the file exists
    if FileExist(configFilePath)
    {
        FileRead, fileContents, %configFilePath%
        if !ErrorLevel
        {
            Clipboard := fileContent
            MsgBox, Config copied to clipboard!
        }
        else
        {
            MsgBox, Error reading file: %configFilePath%
        }
    }
    else
    {
        MsgBox, The file does not exist: %configFilePath%
    }
return


ImportSettings:
    MsgBox, 4,, Have you exported the settings to your clipboard?

    IfMsgBox, Yes
    {
        clipboardContent := Clipboard
        
        MsgBox, 4,, Would you like to import this?`n`n%clipboardContent%
        
        IfMsgBox, Yes
        {
            configFilePath := A_ScriptDir . "\settings\config.ini"

            if !FileExist(configFilePath) 
            {
                FileAppend,, %configFilePath%
            }

            FileDelete, %configFilePath%
            FileAppend, %clipboardContent%, %configFilePath%

            MsgBox, Config settings updated successfully!
        }
    }
    else
    {
        MsgBox, Please export the settings to your clipboard first.
    }
return

SettingsInfoBox:
    MsgBox, Click on Export Settings in an old version, then import it into the new version.
return

ReconnectInfoBox:
    MsgBox, The private server link is optional, if not inputted, you'll join a public server. Just make sure you have this feature enabled.
return