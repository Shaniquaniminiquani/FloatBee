# **FloatBee**
FloatBee is program written in ahk with the intention to unattach the MusicBee Floating window from its parent player 

The default behavior of a floating window as of MusicBee's latest release is to mimick the parent window in other words, if the main window minimizes or closes, the floating window follows suit\
This is normally not an issue until you bring visualizers into the equation . Something which you may want to maintain open while musicbee is minimized.\
This is the main usecase FloatBee wishes to solve.

## List of "Features"
- Creates a window that hosts the Musicbee floating window that allows clickthrough which uses the MusicBee icon (if set)
- Maintained MusicBee titlebar functionality as well as added darkmode on supported OS's (win10+)
- Ability to resize and move the window freely (Dynamically on resize finish. This is by design to avoid unnecessary calculations) as well as minimize and maximize support (On windows 7 all of these are instant)
- Proper Focus detection (Clicking any area of the window will properly bring it to the forefront)
- Gracefully unparents itself on script close/termination meaning it can be closed and reran at will.
- Redundant attempts of hooking onto parent window for stronger detection
- New Settings menu when right clicking the exe's tray icon (Will automatically launch on first execution)
  - Logic to the settings menu that prohibits unintended use of the application. (Options will be removed depending on what you have enabled)
  - Allows you to point at the Musicbee directory to enable additional features such as.
    - Allow you to Automatically run MusicBee if it is closed when executed 
    - Adds a fix for old visualizers that need to be instantiated before use (You must manually go into MusiBee's preferences and set a hotkey for "View: Show Visualizer" and assign the same to FloatBee)
  - AlwaysOnTop mode for FloatBee. By default any hotkey assigned to FloatBee without the legacy fix active will make Floatbee toggle between AlwaysOnTop modes on that hotkey press
  - DarkMode titlebar is now a toggle in order to account for light themed MusicBee Skins
  - Optionally use the registry instead of a .ini file to store persistent variables to account for protected directories such as the one MusicBee is installed onto by default ("C:\Program Files (x86)\MusicBee")
-Force closes the script when MusicBee is no longer running

## Visuals
Here's an example of what the settings can look like:\
![image](https://github.com/user-attachments/assets/4c594c3b-e03e-4448-a6ed-c1ca71ca70f3)\
As well as its location and a look of FloatBee with darkmode enabled:\
![image](https://github.com/user-attachments/assets/a27f2a84-e290-46c6-a352-3d51d52e6d57)\

## Installation
  ### PreCompiled :
There are 2 ways to download the program, the first is to go to the latest [release](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4) and downloading the already precompiled exe (FloatBee.exe) The issue with this is that it may give you some warning due to me self signing on an external computer. Rest assured that the file is completely safe if it does, but it's something to keep in mind.
  ### Compiling it yourself :
The second way (Which shouldn't really give any troubles) is to compile it yourself on your own machine. To do this you must first download AHK v1.1 from its official [site](https://www.autohotkey.com/)\
After finishing the express installation you can either decide to download the .ahk from the latest [release](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4) or rightclicking on your desktop and creating a new .ahk file\
![image](https://github.com/user-attachments/assets/ab2c8bc4-18a8-46aa-b165-ed7d0f665d68)\
Next proceed to open it inside of any text editor (notepad will work just fine) and copying the entire [source code](https://raw.githubusercontent.com/Shaniquaniminiquani/FloatBee/refs/heads/main/FloatBee.ahk) of the script inside, making sure to save\
Once this is done, you want to go into your MusicBee installation folder, navigating into the skins folder within it and copy and pasting the "MusicBee.ico" file inside onto the location of the .ahk file you have created earlier.\
![image](https://github.com/user-attachments/assets/06e89b7c-01e5-4f2c-926e-f63f7568d941)\
The last step is to simply rightclick that .ahk file and selecting "Compile Script"\
![image](https://github.com/user-attachments/assets/c97c3e33-e90d-471e-aebb-4618f0b4846e)\
And thats it, you're done. You can now delete the extra .ico and .ahk you had grabbed from earlier and run it.

Get the latest release [here](https://github.com/Shaniquaniminiquani/FloatBee/releases/tag/v0.4)\
<sub>Has been tested in win 7, 10 and 11</sub>

