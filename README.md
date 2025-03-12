# 🖱 Shortcuts Window
A floating window with configurable buttons that replicate keystrokes when clicked or held\
**This script requires you to have [AutoHotkey V2](https://www.autohotkey.com/) installed**

I recently became temporarily unable to use my left hand\
I do draw with my right hand, but I need the left to press all the shortcuts I use (which turns out to be a lot)

Thought it'd be neat to have a tool like this to keep drawing even while one-handed, but I couldn't find anything like it\
So here we are

![AutoHotkey64_qOo9DgWhSK](https://github.com/user-attachments/assets/a200e56c-04b9-4745-a089-6e8fd3b077ef)

## 👀 What does it do?
- Every button emulates a different keystroke

- Allows 2 kinds of button behaviours:
  - Clickable buttons
  - Holdable buttons (you can also just click these)

- Contains a fixed set of buttons and other sets separated by tabs for more specific scenarios

- This window always remains on top, but brings the focus back to your target software as soon as you press any of the buttons

- Reminds you to **save** every few minutes

- Remembers where you positioned the window when you closed it

## 🤔 How do I use it?
- If you've never used **Github** before:
  - Look for the big green **Code** button, click it and hit **Download ZIP**
- If you've never used **AutoHotkey** before:
  - After installing it, opening the [ShortcutsWindow.ahk](ShortcutsWindow.ahk) file will execute the script, revealing the window for you to use
- Position it somewhere on top of your drawing software where it's comfortable
- Buttons with a white border are holdable, the rest only respond to clicks

## 💢 These shortcuts are trash / I don't use Krita
- The shortcuts are obviously catered to my taste and how I have Krita set up
  - You can customize **which buttons** are shown, in **what order**, in **which tab**, **what keystrokes** they emulate and **more** by messing with the [MyShortcuts.txt](MyShortcuts.txt) file (more instructions in there)

- I wrote this while working on Krita, but it *should* be possible to use this with any drawing software (like **Clip Studio Paint**, **SAI**, **Photoshop**, etc), though I haven't tested it yet
  - In order to change the target software, you should modify the lines 12-13 on [ShortcutsWindow.ahk](ShortcutsWindow.ahk#L12-L13)
  - The most important one is the `targetClass`, which you should replace with your software's class
  - You can find this value out by:
    1. Opening AutoHotkey Dash
    2. Click on "Window spy"
    3. Hovering your cursor over your software's **main window**
    4. Noting down the value next to `ahk_class`\

      ![AutoHotkeyUX_lYZgzheNIn](https://github.com/user-attachments/assets/fa30f030-e442-4072-8ff4-6a690503816b)

## ⚠ Known Issues
- Due to the "bringing focus to your target software", **spamming buttons is kinda broken**
  - Hence the holdable buttons
  - Be gentle pls

- Holding down a button, moving the mouse away from the window and letting go means **the mouse release won't get detected**
  - You can fix it by clicking again the problem button

- Since it remembers where the window was last, if you had it placed on a second monitor and then opened it again without one, **the window might get lost**
  - You can fix it by going into [Persistent.ini](Persistent.ini), messing with those coordinates and restarting the script

- Long button names don't wrap to 2 lines
  - There is no fix 👌💦
