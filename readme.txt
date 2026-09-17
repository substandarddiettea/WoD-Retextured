
retextured v1.0 by foxware

the tl:dr
this launches War of Dots with a custom texture pack enabled.
it backs up the original png files, replaces them with matching files from
the selected pack, then restores the originals when the game closes.

setup

1. make sure War of Dots is installed through Steam.
	the launcher first checks the original Steam location:
	"C:\Program Files (x86)\Steam\steamapps\common\War of Dots"
	if that is not found, it checks Steam registry entries, registered Steam
	libraries, and Steam app manifests. it does not scan the whole drive.

	if automatic detection does not find the game, create "wodroot.txt" beside
	"retexturedlaunch.bat". put the full War of Dots game folder path on its
	first line, for example:
	"D:\SteamLibrary\steamapps\common\War of Dots"

2. keep the "helpers" folder beside "retexturedlaunch.bat".
	the launcher uses "helpers\find-wodroot.ps1" for automatic Steam detection.

3. make a subfolder for each texture pack inside the "pack" folder.
	put the replacement .png files in the pack subfolder. the files need to have
	the same names as the textures they replace. i.e. red_inf1.png

4. keep "pack", "wallpapers", "helpers", and "retexturedlaunch.bat" together in this folder.

5. put wallpaper replacement files named "winter.png", "troopers.png", "red.png",
	and/or "home_background.png" directly inside the "wallpapers" folder.
	filenames must match the game's files. "home_background.png" is replaced in
	"War of Dots\assets"; the other wallpaper files are replaced in
	"War of Dots\assets\wallpapers".


much of this should be setup in the intial download

usage

double-click "retexturedlaunch.bat".
the launcher numbers the pack subfolders and asks which pack to use for:

	countryballs: "War of Dots\assets\skins\countryballs"
	coldwar: "War of Dots\assets\skins\coldwar"
	agincourt: "War of Dots\assets\skins\agincourt"
	base assets: directly inside "War of Dots\assets"
	wallpapers: "War of Dots\assets\wallpapers" and "home_background.png" in
	"War of Dots\assets"

choose a pack number for each location, or leave the selection blank to skip
that location. the same pack or different packs can be selected for each one.
only matching png files are replaced; subfolders inside a selected pack are
not searched.

after the skin-pack choices, the launcher asks "apply wallpapers (y/n):".
answer y to replace every matching PNG in the local "wallpapers" folder, or
n to skip wallpapers. wallpaper files are backed up temporarily and restored
when the game closes. 
important note is that wallpapers also have the "same name" rule

if no packs are selected, enter y to launch with the game's original
textures, n to close, or r to return to pack selection.

the launcher waits for the game to start before replacing files. when the
game closes, it restores the backed-up files and removes the temporary backup.

important

do not close the launcher window while the game is running.
the launcher needs to stay open so it can restore the original files when
the game exits. closing it early can leave replacement files in the game
folder and may cause Steam's file verification to report corrupted files.

the texture pack is temporary. the original files are backed up before each
replacement and restored when the game closes. if a copy or backup fails,
the launcher reports the file and attempts to restore the original files.

4 color and boat texture changes are supported through the base game assets.
select a pack for base assets when those textures are needed.

troubleshooting

if the game cannot be found, check that the game folder contains "game.exe".
you can also create "wodroot.txt" manually with the full game folder path.

if automatic detection is not working, make sure "helpers\find-wodroot.ps1"
is still beside the launcher and that Windows PowerShell is available.

if a texture does not change, check that its png filename exactly matches
the original filename and that it is in the pack folder's top level.

if the launcher reports that a target folder is missing, verify the game's
asset folders have not been renamed or moved.

if you mess up the files, verify the game files through Steam to restore them.

have fun and try not to break anything c:



oh also if you want developer diagnostics
the launcher has developer file checks disabled by default.
to enable them, open "retexturedlaunch.bat" and change:
	set "DEV_ECHOS=disabled"
to:
	set "DEV_ECHOS=enabled"

when enabled, the launcher reports whether important launcher files and game
folders were found. the checks only test the known launcher and War of Dots
paths; they do not search the whole drive or change any files.