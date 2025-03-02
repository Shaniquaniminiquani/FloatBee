# **FloatBee**
FloatBee is a program written in AHK with the intention of unattaching the MusicBee Floating window from its parent player. 

The default behavior of a floating window as of MusicBee's latest release is to mimick its parent window; in other words, if the main window minimizes or closes, the floating window follows suit.\
This is normally not an issue until you bring visualizers into the equation (something which you may want to maintain open while MusicBee is minimized)\
This is the main use case FloatBee wishes to solve.

## List of "Features"
- Creates a window that hosts the MusicBee floating window that allows clickthrough which uses the MusicBee icon (if set).
- Maintained MusicBee title bar functionality as well as added DarkMode on supported OS's (Win10+).
- Ability to resize and move the window freely (dynamically on resize finish. This is by design to avoid unnecessary calculations) as well as minimize and maximize support (on Windows 7 all of these are instant).
- Proper focus detection (clicking any area of the window will properly bring it to the forefront).
- Gracefully unparents itself on script close/termination meaning it can be closed and rerun at will.
- Redundant attempts of hooking onto the parent window for stronger detection
- New Settings menu when right-clicking the exe's tray icon (will automatically launch on first execution)
  - Logic added to the settings menu that prohibits unintended use of the application (options will be removed depending on what you have enabled).
  - Allows you to point at the MusicBee directory to enable additional features such as.
    - Allow you to automatically run MusicBee if it is closed when executed.
    - Adds a fix for old visualizers that need to be instantiated before use (you must manually go into MusiBee's preferences and set a hotkey for "View: Show Visualizer" and assign the same to FloatBee).
  - AlwaysOnTop mode for FloatBee. By default any hotkey assigned to FloatBee without the legacy fix active will make FloatBee toggle between AlwaysOnTop modes upon hotkey press.
  - DarkMode title bar is now a toggle in order to account for light-themed MusicBee skins.
  - Optionally use the registry instead of a .ini file to store persistent variables to account for protected directories such as the one MusicBee is installed onto by default ("C:\Program Files (x86)\MusicBee").
- Force closes the script when MusicBee is no longer running.

## Visuals
Here's an example of what the settings can look like:

![image](https://github.com/user-attachments/assets/4c594c3b-e03e-4448-a6ed-c1ca71ca70f3)

As well as its location and look of FloatBee with DarkMode enabled:

![image](https://github.com/user-attachments/assets/a27f2a84-e290-46c6-a352-3d51d52e6d57)

## Installation
  ### Precompiled :
There are 2 ways to download the program, the first is to go to the latest [release](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4) and downloading the already precompiled exe (FloatBee.exe).\
The issue with this is that it may give you a one time warning due to me self signing on an external computer.\
If you aren't familiar with the warning it may be unintuitive on how to continue from that point on.
Essentially you need to hit "More info" and then "Run anyway". This prompt should only appear the very first time you install and I can assure you its completely safe and normal for unpublished executables to behave this way. The steps should look like this more or less:

<img width="394" alt="Untitled" src="https://github.com/user-attachments/assets/a9140adb-a287-4771-91cc-68c29bf25087" />


  ### Compiling it yourself :
The second way (which shouldn't give any starting warnings and is somewhat recommended) is to compile it yourself on your own machine. To do this you must first download AHK v1.1 from its official [site](https://www.autohotkey.com/).\
After finishing the express installation you can either decide to download the .ahk from the latest [release](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4) or right-clicking your desktop and creating a new .ahk file.

![image](https://github.com/user-attachments/assets/ab2c8bc4-18a8-46aa-b165-ed7d0f665d68)

Next, proceed to open it inside of any text editor (Notepad will work just fine) and copy the entire [source code](https://raw.githubusercontent.com/Shaniquaniminiquani/FloatBee/refs/heads/main/FloatBee.ahk) of the script inside, making sure to save.\
Once this is done, you want to go into your MusicBee installation folder, navigating into the skins folder within it and copy-pasting the "MusicBee.ico" file inside into the directory the .ahk file you created earlier is in.

![image](https://github.com/user-attachments/assets/06e89b7c-01e5-4f2c-926e-f63f7568d941)

The last step is to simply right-click the .ahk file and selecting "Compile Script"

![image](https://github.com/user-attachments/assets/c97c3e33-e90d-471e-aebb-4618f0b4846e)

And that's it, you're done. You can now delete the extra .ico and .ahk you had grabbed from earlier and run it to get the first time setup. You may also completely uninstall AHK at this point if you so choose; you only needed it to compile.

Get the latest release [here](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4)\
<sub>Has been tested in Win 7, 10, and 11</sub>

