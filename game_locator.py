
# primary file for locating the game path

from __future__ import annotations

import re
from pathlib import Path
from typing import Iterable


GAME_NAME = "War of Dots"


def find_game_root(launcher_root: Path) -> Path | None:
    """returns the configured game root, or attempts to find one in common locations."""
    configured_path = launcher_root / "wodroot.txt"
    if configured_path.is_file():
        configured_root = Path(configured_path.read_text(encoding="utf-8").splitlines()[0].strip().strip('"'))
        if is_game_root(configured_root):
            return configured_root

    for candidate in _steam_candidates():
        if is_game_root(candidate):
            return candidate
    return None


def is_game_root(path: Path) -> bool:
    return (path / "game.exe").is_file()


def _steam_candidates() -> Iterable[Path]:
    roots = list(_registry_steam_roots())
    roots.extend(
        [
            Path.home() / "AppData/Local/Steam",
            Path("C:/Program Files (x86)/Steam"),
            Path("C:/Program Files/Steam"),
        ]
    )

    seen: set[Path] = set()
    for steam_root in roots:
        steam_root = steam_root.expanduser()
        if steam_root in seen or not steam_root.is_dir():
            continue
        seen.add(steam_root)
        yield steam_root / "steamapps/common/War of Dots"

        library_file = steam_root / "steamapps/libraryfolders.vdf"
        for library_root in _library_roots(library_file):
            yield library_root / "steamapps/common/War of Dots"

        manifest_dir = steam_root / "steamapps"
        if manifest_dir.is_dir():
            for manifest in manifest_dir.glob("appmanifest_*.acf"):
                yield from _manifest_candidates(manifest, steam_root)


def _registry_steam_roots() -> Iterable[Path]:
    try:
        import winreg
    except ImportError:
        return

    registry_locations = (
        (winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam"),
        (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Valve\Steam"),
    )
    for hive, key_path in registry_locations:
        try:
            with winreg.OpenKey(hive, key_path) as key:
                for value_name in ("SteamPath", "InstallPath"):
                    try:
                        value, _ = winreg.QueryValueEx(key, value_name)
                    except OSError:
                        continue
                    if value:
                        yield Path(value)
        except OSError:
            continue


def _library_roots(library_file: Path) -> Iterable[Path]:
    if not library_file.is_file():
        return
    contents = library_file.read_text(encoding="utf-8", errors="replace")
    for match in re.finditer(r'"path"\s+"([^"]+)"', contents):
        yield Path(match.group(1).replace("\\\\", "\\"))


def _manifest_candidates(manifest: Path, steam_root: Path) -> Iterable[Path]:
    contents = manifest.read_text(encoding="utf-8", errors="replace")
    name_match = re.search(r'"name"\s+"([^"]+)"', contents)
    install_match = re.search(r'"installdir"\s+"([^"]+)"', contents)
    if name_match and install_match and name_match.group(1) == GAME_NAME:
        yield steam_root / "steamapps/common" / install_match.group(1)