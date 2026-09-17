# finds and logs the available packs and wallpapers in the launcher directory

from __future__ import annotations

from pathlib import Path


def find_packs(launcher_root: Path) -> list[Path]:
    pack_root = launcher_root / "pack"
    if not pack_root.is_dir():
        return []
    return sorted((path for path in pack_root.iterdir() if path.is_dir()), key=lambda path: path.name.casefold())


def find_wallpapers(launcher_root: Path) -> list[Path]:
    wallpaper_root = launcher_root / "wallpapers"
    if not wallpaper_root.is_dir():
        return []
    return sorted(
        (path for path in wallpaper_root.glob("*.png") if path.is_file()),
        key=lambda path: path.name.casefold(),
    )