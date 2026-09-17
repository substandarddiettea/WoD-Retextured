"""main file for the launchers front end."""

from __future__ import annotations

import subprocess
import sys
import threading
import tkinter as tk
import time
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from game_locator import find_game_root, is_game_root
from pack_catalog import find_packs, find_wallpapers
from texture_installer import TextureInstaller


ASSET_GROUPS = (
    ("Countryballs", "countryballs"),
    ("Cold War", "coldwar"),
    ("Agincourt", "agincourt"),
    ("Base assets", "base_assets"),
)

GAME_START_TIMEOUT = 60
GAME_CHECK_INTERVAL = 0.25
REPLACE_DELAY = 3


class LauncherWindow:
    def __init__(self, root: tk.Tk, launcher_root: Path) -> None:
        self.root = root
        self.launcher_root = launcher_root
        self.game_root: Path | None = None
        self.pack_paths: list[Path] = []
        self.session_active = False
        self.session_ready = threading.Event()
        self.session_installer: TextureInstaller | None = None

        self.root.title("War of Dots Retextured")
        self.root.minsize(560, 420)
        self.root.protocol("WM_DELETE_WINDOW", self.close)
        self.root.columnconfigure(1, weight=1)

        ttk.Label(root, text="War of Dots Retextured", font=("Segoe UI", 16, "bold")).grid(
            row=0, column=0, columnspan=3, padx=24, pady=(22, 18), sticky="w"
        )
        ttk.Label(root, text="Game installation").grid(row=1, column=0, padx=(24, 8), pady=6, sticky="w")
        self.game_path = tk.StringVar()
        ttk.Entry(root, textvariable=self.game_path).grid(row=1, column=1, padx=8, pady=6, sticky="ew")
        ttk.Button(root, text="Browse", command=self.browse_game).grid(row=1, column=2, padx=(8, 24), pady=6)

        self.pack_variables: dict[str, tk.StringVar] = {}
        self.pack_boxes: dict[str, ttk.Combobox] = {}
        for row, (label, key) in enumerate(ASSET_GROUPS, start=2):
            ttk.Label(root, text=label).grid(row=row, column=0, padx=(24, 8), pady=6, sticky="w")
            variable = tk.StringVar(value="Skip")
            combo = ttk.Combobox(root, textvariable=variable, state="readonly")
            combo.grid(row=row, column=1, columnspan=2, padx=(8, 24), pady=6, sticky="ew")
            self.pack_variables[key] = variable
            self.pack_boxes[key] = combo

        self.wallpapers_enabled = tk.BooleanVar()
        ttk.Checkbutton(root, text="Apply wallpapers", variable=self.wallpapers_enabled).grid(
            row=6, column=0, columnspan=3, padx=24, pady=(12, 6), sticky="w"
        )

        self.status = tk.StringVar(value="Checking for War of Dots...")
        ttk.Label(root, textvariable=self.status, wraplength=500).grid(
            row=7, column=0, columnspan=3, padx=24, pady=(18, 12), sticky="w"
        )
        button_frame = ttk.Frame(root)
        button_frame.grid(row=8, column=0, columnspan=3, padx=24, pady=(4, 24), sticky="e")
        self.refresh_button = ttk.Button(button_frame, text="Refresh", command=self.refresh)
        self.refresh_button.pack(side="left", padx=4)
        self.base_game_button = ttk.Button(button_frame, text="Launch Base Game", command=self.launch_base_game)
        self.base_game_button.pack(side="left", padx=4)
        self.launch_button = ttk.Button(button_frame, text="Launch With Selected Packs", command=self.launch_with_packs)
        self.launch_button.pack(side="left", padx=4)

        self.refresh()

    def refresh(self) -> None:
        if self.session_active:
            self.refresh_active_session()
            return

        previous_selections = {key: variable.get() for key, variable in self.pack_variables.items()}
        previous_wallpapers = self.wallpapers_enabled.get()
        self.pack_paths = find_packs(self.launcher_root)
        choices = ["Skip"] + [path.name for path in self.pack_paths]
        for key, combo in self.pack_boxes.items():
            combo["values"] = choices
            selected = previous_selections.get(key, "Skip")
            combo.set(selected if selected in choices else "Skip")
        self.wallpapers_enabled.set(previous_wallpapers)

        self.game_root = find_game_root(self.launcher_root)
        if self.game_root:
            self.game_path.set(str(self.game_root))
            wallpaper_count = len(find_wallpapers(self.launcher_root))
            self.status.set(f"Found the game. {len(self.pack_paths)} texture pack(s) and {wallpaper_count} wallpaper(s) available.")
        else:
            self.game_path.set("")
            self.status.set("War of Dots was not found. Choose its folder or create wodroot.txt beside this launcher.")

    def selected_packs(self) -> tuple[dict[str, Path], bool] | None:
        selections: dict[str, Path] = {}
        for asset_group, variable in self.pack_variables.items():
            selected_name = variable.get()
            if selected_name != "Skip":
                matching_paths = [path for path in self.pack_paths if path.name == selected_name]
                if not matching_paths:
                    messagebox.showerror("Pack not found", f"The selected pack is no longer available: {selected_name}")
                    return None
                selections[asset_group] = matching_paths[0]

        apply_wallpapers = self.wallpapers_enabled.get()
        if apply_wallpapers:
            if not find_wallpapers(self.launcher_root):
                messagebox.showerror("No wallpapers", "There are no PNG files in the wallpapers folder.")
                return None
            selections["wallpapers"] = self.launcher_root / "wallpapers"
        return selections, apply_wallpapers

    def browse_game(self) -> None:
        selected = filedialog.askdirectory(title="Select the War of Dots folder")
        if not selected:
            return
        candidate = Path(selected)
        if not is_game_root(candidate):
            messagebox.showerror("Invalid game folder", "That folder does not contain game.exe.")
            return
        self.game_root = candidate
        self.game_path.set(str(candidate))
        self.status.set("Game folder selected.")

    def launch_base_game(self) -> None:
        if not self.game_root or not is_game_root(self.game_root):
            messagebox.showerror("Game not found", "Select a valid War of Dots folder first.")
            return
        try:
            subprocess.Popen([str(self.game_root / "game.exe")], cwd=self.game_root)
        except OSError as error:
            messagebox.showerror("Could not launch game", str(error))
            return
        self.status.set("War of Dots launched with its original textures.")

    def launch_with_packs(self) -> None:
        if not self.game_root or not is_game_root(self.game_root):
            messagebox.showerror("Game not found", "Select a valid War of Dots folder first.")
            return

        selected = self.selected_packs()
        if selected is None:
            return
        selections, apply_wallpapers = selected

        if not selections:
            self.launch_base_game()
            return

        self.session_active = True
        self.session_ready.clear()
        self.base_game_button.configure(state="disabled")
        self.launch_button.configure(state="disabled")
        threading.Thread(target=self._run_pack_session, args=(selections, apply_wallpapers), daemon=True).start()

    def refresh_active_session(self) -> None:
        if not self.session_ready.is_set() or self.session_installer is None:
            self.status.set("The game is still starting; try Refresh again in a moment.")
            return
        selected = self.selected_packs()
        if selected is None:
            return
        selections, apply_wallpapers = selected
        self.refresh_button.configure(state="disabled")
        threading.Thread(
            target=self._refresh_session_worker,
            args=(selections, apply_wallpapers),
            daemon=True,
        ).start()

    def _refresh_session_worker(self, selections: dict[str, Path], apply_wallpapers: bool) -> None:
        assert self.session_installer is not None
        try:
            self._report_from_worker("Restoring originals and applying the new selection...")
            self.session_installer.refresh(selections, apply_wallpapers)
            self._report_from_worker("New packs reapplied. The game may need to revisit a screen to reload them.")
        except Exception as error:
            self._report_from_worker(f"Refresh failed: {error}")
        finally:
            self.root.after(0, lambda: self.refresh_button.configure(state="normal"))

    def _run_pack_session(self, selections: dict[str, Path], apply_wallpapers: bool) -> None:
        assert self.game_root is not None
        installer = TextureInstaller(self.game_root, self.launcher_root, self._report_from_worker)
        self.session_installer = installer
        process: subprocess.Popen[bytes] | None = None
        try:
            self._report_from_worker("Launching War of Dots...")
            process = subprocess.Popen([str(self.game_root / "game.exe")], cwd=self.game_root)
            self._wait_for_game_start(process)
            self._report_from_worker("Backing up original textures and applying selected packs...")
            installer.install(selections, apply_wallpapers)
            self.session_ready.set()
            self._report_from_worker("Texture packs active. Keep the launcher open while playing.")
            process.wait()
            self._report_from_worker("Game closed. Restoring original textures...")
        except Exception as error:
            self._report_from_worker(f"Launch failed: {error}")
        finally:
            installer.restore()
            self.session_ready.clear()
            self.session_installer = None
            self.root.after(0, self._session_finished)

    def _wait_for_game_start(self, process: subprocess.Popen[bytes]) -> None:
        self._report_from_worker("Checking for the game to open...")
        deadline = time.monotonic() + GAME_START_TIMEOUT
        while time.monotonic() < deadline:
            if self._is_game_open(process):
                self._report_from_worker(f"Game is open. Waiting {REPLACE_DELAY} second before applying textures...")
                time.sleep(REPLACE_DELAY)
                return
            time.sleep(GAME_CHECK_INTERVAL)

        raise TimeoutError(
            f"The game did not open within the {GAME_START_TIMEOUT} second limit. "
            "This may be a client-side issue."
        )

    def _is_game_open(self, process: subprocess.Popen[bytes]) -> bool:
        """Check Windows' process list, falling back to the launched process."""
        process_list_state = self._game_name_in_process_list()
        if process_list_state is not None:
            return process_list_state
        return process.poll() is None

    @staticmethod
    def _game_name_in_process_list() -> bool | None:
        try:
            result = subprocess.run(
                ["tasklist", "/fi", "IMAGENAME eq game.exe"],
                capture_output=True,
                text=True,
                creationflags=subprocess.CREATE_NO_WINDOW,
                check=False,
            )
        except OSError:
            return None
        return "game.exe" in result.stdout.casefold()

    def _report_from_worker(self, message: str) -> None:
        self.root.after(0, self.status.set, message)

    def _session_finished(self) -> None:
        self.session_active = False
        self.base_game_button.configure(state="normal")
        self.launch_button.configure(state="normal")
        self.refresh_button.configure(state="normal")
        self.status.set("Game session finished. Original textures restored.")

    def close(self) -> None:
        if self.session_active:
            close_anyway = messagebox.askyesno(
                "Game session active",
                "The game is still running. Closing now may leave replacement textures installed "
                "and prevent the original files from being restored.\n\n"
                "Close anyway?",
                default=messagebox.NO,
            )
            if close_anyway:
                self.root.destroy()
            return
        self.root.destroy()


def main() -> None:
    root = tk.Tk()
    launcher_root = Path(sys.executable).resolve().parent if getattr(sys, "frozen", False) else Path(__file__).resolve().parent
    LauncherWindow(root, launcher_root)
    root.mainloop()


if __name__ == "__main__":
    main()