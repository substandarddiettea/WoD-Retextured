
#handles the backing up, replacing, and restoring of texture packs in the game directory / launcher directory

from __future__ import annotations

import shutil
from pathlib import Path
from typing import Callable


ProgressCallback = Callable[[str], None]

TARGET_DIRECTORIES = {
    "countryballs": Path("assets/skins/countryballs"),
    "coldwar": Path("assets/skins/coldwar"),
    "agincourt": Path("assets/skins/agincourt"),
    "base_assets": Path("assets"),
    "wallpapers": Path("assets/wallpapers"),
}


class TextureInstaller:
    def __init__(self, game_root: Path, launcher_root: Path, report: ProgressCallback) -> None:
        self.game_root = game_root
        self.backup_root = launcher_root / "backup"
        self.report = report
        self.active_files: set[Path] = set()

    def install(self, selections: dict[str, Path], wallpapers: bool) -> None:
        if self.backup_root.exists():
            raise RuntimeError(
                f"A previous backup already exists at {self.backup_root}. "
                "Restore it or remove it before starting another session."
            )

        self.backup_root.mkdir(parents=True)
        try:
            for asset_group, pack_path in selections.items():
                if asset_group == "wallpapers":
                    continue
                self._replace_pack(asset_group, pack_path)
            if wallpapers:
                wallpaper_path = selections.get("wallpapers")
                if wallpaper_path is not None:
                    self._replace_pack("wallpapers", wallpaper_path)
                    self._replace_single_file(
                        wallpaper_path / "home_background.png",
                        self.game_root / "assets/home_background.png",
                        self.backup_root / "assets/home_background.png",
                    )
        except Exception:
            self.restore()
            raise

    def restore(self) -> None:
        if not self.backup_root.is_dir():
            return
        self._restore_active_files()
        for backup_file in self.backup_root.rglob("*"):
            if not backup_file.is_file():
                continue
            relative_path = backup_file.relative_to(self.backup_root)
            target_file = self.game_root / relative_path
            target_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(backup_file, target_file)
            self.report(f"Restored {relative_path}")
        shutil.rmtree(self.backup_root, ignore_errors=True)

    def refresh(self, selections: dict[str, Path], wallpapers: bool) -> None:
        """Replace the active files while preserving the original backup."""
        if not self.backup_root.is_dir():
            raise RuntimeError("No active texture session is available to refresh.")

        self._restore_active_files()
        try:
            for asset_group, pack_path in selections.items():
                if asset_group == "wallpapers":
                    continue
                self._replace_pack(asset_group, pack_path, create_backup=False)
            if wallpapers:
                wallpaper_path = selections.get("wallpapers")
                if wallpaper_path is not None:
                    self._replace_pack("wallpapers", wallpaper_path, create_backup=False)
                    self._replace_single_file(
                        wallpaper_path / "home_background.png",
                        self.game_root / "assets/home_background.png",
                        self.backup_root / "assets/home_background.png",
                        create_backup=False,
                    )
        except Exception:
            self._restore_active_files()
            raise

    def _restore_active_files(self) -> None:
        for target_file in self.active_files:
            relative_path = target_file.relative_to(self.game_root)
            backup_file = self.backup_root / relative_path
            if backup_file.is_file():
                shutil.copy2(backup_file, target_file)
            elif target_file.exists():
                target_file.unlink()
        self.active_files.clear()

    def _replace_pack(self, asset_group: str, pack_path: Path, create_backup: bool = True) -> None:
        target_directory = self.game_root / TARGET_DIRECTORIES[asset_group]
        if not target_directory.is_dir():
            raise FileNotFoundError(f"Target texture directory not found: {target_directory}")

        files = list(pack_path.glob("*.png"))
        if not files:
            raise FileNotFoundError(f"No PNG files found in pack: {pack_path}")

        for source_file in files:
            if asset_group == "wallpapers" and source_file.name.casefold() == "home_background.png":
                continue
            target_file = target_directory / source_file.name
            backup_file = self.backup_root / TARGET_DIRECTORIES[asset_group] / source_file.name
            self._replace_single_file(source_file, target_file, backup_file, create_backup)

    def _replace_single_file(
        self,
        source_file: Path,
        target_file: Path,
        backup_file: Path,
        create_backup: bool = True,
    ) -> None:
        if not source_file.is_file():
            return
        if create_backup and target_file.is_file():
            backup_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target_file, backup_file)
        shutil.copy2(source_file, target_file)
        self.active_files.add(target_file)
        self.report(f"Replaced {target_file.name}")