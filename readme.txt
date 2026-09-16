
retextured v1.0 by foxware

the tl:dr
this launches War of Dots with a custom texture pack enabled.
it backs up the original countryball textures, replaces them with the
png files in the "pack" folder, then restores the originals when the game
closes.

setup

1. make sure War of Dots is installed through Steam in the usual location:
	"C:\Program Files (x86)\Steam\steamapps\common\War of Dots"

2. put the replacement .png files in the "pack" folder.
	the files need to have the same names as the textures they replace. i.e. red_inf1.png

3. keep "pack" and "retexturedlaunch.bat" together in this folder.

usage

double-click "retexturedlaunch.bat".
the launcher will start the game, replace any matching textures, and wait
until the game closes before putting the original files back. 
this is very important, if the files are not restored the game will raise a "file corrupted" error, ]
thats also why theres a delay on the injection of the new textures

important

do not close the launcher window while the game is running.
the launcher needs to stay open so it can restore the original files when
the game exits.

the texture pack is temporary. closing the game normally removes the backup
and restores the unmodified files in the War of Dots folder.

troubleshooting

if the game cannot be found, check that it is installed at the Steam path
above and that the executable is named "game.exe".

if a texture does not change, check that its png filename exactly matches
the original filename in:
"War of Dots\assets\skins\countryballs"

have fun and try not to break anything :) oh and, at some point ill add support for 4 color changing via basegame textures.

