

WoD Retextured v5 by foxware aka premiumdiettea


a basic skinpack and wallpaper loaded for war of dots, now with a ui!

usage:

1. Start WoDLauncher.exe
2. Confirm the detected War of Dots installation. Use Browse if needed.
3. Choose a pack for each category, or choose Skip.
4. Enable Apply wallpapers if desired.
5. Click Launch With Selected Packs.
6. Select the skin packs and/or wallpapers from the in-game skinpack selection.
6. Keep the launcher open until the game closes so the original files can be
   restored.

War of Dots loads skin packs and wallpapers from disk while it is running.
The launcher therefore starts the game first and applies the selected files
shortly afterward. You can also change the selections at any time while the
game is open and click Refresh. Refresh restores the original session files and
applies the new selection without restarting the game. If skins do not appear return to the 

Do not close the launcher while a texture session is active. If it stops
unexpectedly, use Steam file verification before playing normally.
This will restore the missing or replaced files to their normal state if the launcher fails to do so,
typically caused by it being stopped early.



Packs and wallpapers

Put replacement PNG files directly inside each pack folder as shown the example packs here.
ensure that filenames match the game files they replace exactly.
    pack/
      smileypack/
        red_inf1.png
      tourney/
        red_inf1.png

Wallpaper files go directly inside wallpapers/. Supported names include
winter.png, troopers.png, red.png, and home_background.png. The first three
replace files in the game's assets/wallpapers folder. home_background.png
replaces the file in the game's assets folder, becoming the default background.



Game detection

The launcher checks the normal Steam location, Steam registry settings,
registered Steam libraries, and Steam app manifests. It does not scan the
whole drive, only neccessary areas for detection.

If detection fails, create wodroot.txt beside WoDLauncher.exe and put the full
War of Dots folder path on its first line. The folder must contain game.exe.
This adds a default for the detection to fall back on, similar to browse to select.