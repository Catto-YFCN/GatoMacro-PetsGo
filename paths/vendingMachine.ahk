#SingleInstance Force
Sleep, 2000
Send, {a down}
Sleep, 4000
Send, {a up}

Send, {w down}
Send, {a down}
Sleep, 3500
Send, {w up}
Send, {a up}


Send, {w down}
Send, {d down}
Sleep, 3000
Send, {w up}
Send, {d up}

Send, {a down}
Sleep, 1500
Send, {a up}
Sleep, 2000



SetTimer, CheckColor, 100
unknownCount := 0

CheckColor:
    PixelGetColor, color, 800, 795, RGB

    if (color = 0x1F4F00) {
        ToolTip, Potion Available
        Click, 800, 740
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight - 1
        unknownCount := 0
    } else {
        PixelGetColor, color2, 900, 795, RGB

        if (color2 = 0x1F4F00) {
            ToolTip, Potion Unavailable: No stock
            MouseMove, 900, 740, 0
            Sleep, 100
            Click, 900, 740
            MouseMove, A_ScreenWidth // 2, A_ScreenHeight - 1
            SetTimer, CheckColor, Off
            ToolTip,
            Send, {a down}
            Sleep, 3000
            Send, {a up}

            Send, {a down}
            Send, {w down}
            Sleep, 2000
            Send, {a up}
            Send, {w up}

            Send, {a down}
            Sleep, 3000
            Send, {a up}


            Send, {s down}
            Sleep, 750
            Send, {s up}


            Send, {a down}
            Sleep, 500
            Send, {a up}
        } else {
            ToolTip, Unknown Color: %color%
            unknownCount++
            if (unknownCount >= 100) {
                ToolTip
                SetTimer, CheckColor, Off
                ToolTip,
                Send, {a down}
                Sleep, 3000
                Send, {a up}
                            
                Send, {a down}
                Send, {w down}
                Sleep, 2000
                Send, {a up}
                Send, {w up}
                            
                Send, {a down}
                Sleep, 3000
                Send, {a up}
                            
                            
                Send, {s down}
                Sleep, 750
                Send, {s up}
                            
                            
                Send, {a down}
                Sleep, 500
                Send, {a up}
            }
        }
    }
return

F3::ExitApp