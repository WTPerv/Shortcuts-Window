; https://www.autohotkey.com/docs/v2/

; #############################################################################
; ######################################## SETTINGS ###########################
; #############################################################################

#Requires AutoHotkey v2.0
#SingleInstance Force
SetKeyDelay 0
SendMode "Input"

targetSoftware := "Krita"
targetClass := "Qt5157QWindowIcon" ; Krita's class, found using Window Spy (included in AutoHotkey)

saveReminder := 5 * 60 * 1000 ; turns save button red every 5 mins
colorBG := "303030"
colorFont := "White"
colorBtn := "Black"
colorBtnPress := "555555"
colorSave := "Green"
colorSaveRemind := "Red"
btnStyle := "w107 h50 Center 0x0200 Background" colorBtn
btnStyleInTab := "w100 h50 Center 0x0200 Background" colorBtn ; a lil thinner

; #################################################################
; ############################### LOGIC ###########################
; #################################################################

; ########################### INIT ###########################
guiDown := ""
btnSave := ""
dictHold := Map()

; ########################### INI FILE ###########################
iniFilename := "Persistent.ini"
posX := IniRead(iniFilename, "Window", "posX", 0)
posY := IniRead(iniFilename, "Window", "posY", 0)

; ########################### MY SHORTCUTS FILE ###########################
shortcutsFilename := "MyShortcuts.txt"
shortcutTabs := Array()
shortcutCategories := Array()
ReadShortcuts(shortcutsFilename)

; ########################### GET TARGET SOFTWARE ###########################
GroupAdd "TARGET", "ahk_class " targetClass

; ########################### DRAW WINDOW ###########################
myGui := Gui('AlwaysOnTop ')
myGui.Title := "Shortcuts"
myGui.SetFont("s11 c" colorFont)
myGui.BackColor := colorBG

DrawButtons()
myGui.Show("x" posX " y" posY)

; ########################### SUB TO EVENTS ###########################
myGui.OnEvent('Close', (*) => ExitApp())

if btnSave
    SetTimer(OnSaveReminder, saveReminder)

OnMessage 0x0201, OnMouseDown ; WM_LBUTTONDOWN
OnMessage 0x0202, OnMouseUp ; WM_LBUTTONUP
OnExit OnExiting

; ##############################################################################
; ######################################## FUNCTIONS ###########################
; ##############################################################################

; ########################### DRAW BUTTONS ###########################
DrawButtons() {
    ; CATEGORY
    tabCount := 0
    loop shortcutCategories.Length {
        currCategory := shortcutCategories[A_Index]
        isGlobal := currCategory.name == "Global"

        ; TABS
        if not isGlobal {
            tabCount++
            if tabCount == 1 {
                myGui.MarginX := 5
                myTabs := myGui.AddTab3("XS Background" colorBG, shortcutTabs)
            }
            myTabs.UseTab(tabCount)
        }

        ; BUTTON
        loop currCategory.shortcuts.Length {
            sIndex := A_Index
            sObj := currCategory.shortcuts[sIndex]
            OutputDebug(sObj.name)

            ; BUTTON STYLE AND POSITION
            sStyle := btnStyle
            if not isGlobal
                sStyle := btnStyleInTab
            if sIndex == 1
                sStyle := sStyle " Section" ; position reset for following buttons using XS
            else {
                if Mod(sIndex, 2) == 1
                    sStyle := sStyle " XS" ; below ALL prev buttons
                else
                    sStyle := sStyle " YP" ; next to prev button
            }
            if sObj.mode == "hold"
                sStyle := sStyle " 0x1000" ; adds border

            ; BUTTON BASIC EVENTS
            sBtn := myGui.AddText(sStyle, sObj.name) ; AddText instead of AddButton so we can color them
            if sObj.mode == "click"
                sBtn.OnEvent("Click", OnClick.Bind(sObj.keystroke))
            else {
                sBtn.OnEvent("Click", OnClickEmpty)
                dictHold[sBtn] := sObj.keystroke
            }

            ; SPECIAL BUTTON
            if sObj.name == "Save" {
                btnSave := sBtn
                btnSave.Opt("Background" colorSave)
            }
        }
    }
}

; ########################### TIMER ###########################
OnSaveReminder() {
    btnSave.Opt("Background" colorSaveRemind)
    btnSave.Redraw
}

; ########################### ON CLOSE ###########################
OnExiting(reason, code) {
    myGui.GetPos(&posX, &posY)
    IniWrite(posX, iniFilename, "Window", "posX")
    IniWrite(posY, iniFilename, "Window", "posY")
}

; ########################### FOCUS TARGET SOFTWARE ###########################
ActivateIt(guiCtrl) {
    if WinExist("ahk_group TARGET")
        WinActivate ; CAUSES A DELAY IN THE THREAD (waits till window is active)
    else {
        SetTimer(OnHold, 0)
        MsgBox("No " targetSoftware " active, shutting down", "Shortcuts Window", "0x10 0x40000")
        ExitApp
    }
}

; ########################### MANAGE MOUSE + HOLD ###########################
OnMouseDown(wParam, lParam, msg, hwnd) {
    ; GET BUTTON
    global guiDown := GuiCtrlFromHwnd(hwnd)
    if not guiDown
        return
    if guiDown.Type !== "Text" {
        guiDown := ""
        return
    }

    ; FANCY COLOR ON PRESS
    guiDown.Opt("Background" colorBtnPress)
    guiDown.Redraw

    ; HOLD
    if dictHold.Has(guiDown) {
        SetTimer(OnHold, 100) ; repeat code every 100ms
        OnHold()
    }
}

OnMouseUp(wParam, lParam, msg, hwnd) {
    ; GET BUTTON (LAST PRESSED)
    global guiDown
    if not guiDown
        return

    ; FANCY COLOR ON RELEASE
    guiDown.Opt("Background" colorBtn)
    if (guiDown == btnSave) ; special color
        guiDown.Opt("Background" colorSave)
    guiDown.Redraw

    ; UNHOLD
    if dictHold.Has(guiDown) {
        SetTimer(OnHold, 0) ;cancel hold timer
    }

    guiDown := ""
}

; ########################### BUTTONS EVENTS ###########################
OnClick(keystroke, guiCtrl, info) { ; Click events are called a few ms after the mouse is pressed and NOT when it is released
    ActivateIt(guiCtrl)
    Send keystroke
}

OnClickEmpty(guiCtrl, info) { ; if hold buttons aren't tied to any event, button down/up don't recognize them as buttons
}

OnHold() {
    global guiDown
    if not guiDown {
        try
            SetTimer(, 0) ; cancel my timer
        return
    }

    keystroke := dictHold[guiDown] ; ActivateIt causes a delay, so let's save the value
    ActivateIt(guiDown)
    Send keystroke
}

; ########################### USER SHORTCUTS ###########################
ReadShortcuts(filename) {
    dict := Map()

    loop read, filename {
        currLine := A_LoopReadLine
        if currLine == "" || SubStr(currLine, 1, 2) == "//"
            continue
        try {
            currData := StrSplit(currLine, A_Space)
            category := currData[1]
            name := currData[2]
            mode := currData[3]
            keystroke := currData[4]

            currShortcut := Shortcut(name, mode, keystroke)

            if dict.Has(category) {
                dict[category].Add(currShortcut)
            } else {
                currCategory := ShortcutCategory(category)
                currCategory.Add(currShortcut)
                dict[category] := currCategory
                shortcutCategories.Push(currCategory)
                if (category !== "Global")
                    shortcutTabs.Push(category)
            }
        } catch Error as e {
            MsgBox("Error on '" shortcutsFilename "' on line: '" currLine "'", "Shortcuts Window", "0x10 0x40000")
            ExitApp
        }
    }
}

; ##############################################################################
; ########################################## CLASSES ###########################
; ##############################################################################

class ShortcutCategory {
    name := ""
    shortcuts := Array()

    __New(name) {
        this.name := name
    }

    Add(shortcut) {
        this.shortcuts.Push(shortcut)
    }
}

class Shortcut {
    name := ""
    mode := ""
    keystroke := ""

    __New(name, mode, keystroke) {
        this.name := StrReplace(name, "_", A_Space)
        this.mode := mode
        this.keystroke := keystroke
    }
}
