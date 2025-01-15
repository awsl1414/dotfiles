import os, shutil

HOME = os.path.expanduser("~")

BACKUP_DIR = "."

BACKUP_FILES = [
    ".npmrc",
    ".yarnrc",
    ".czrc",
    ".commitlintrc.cjs",
    ".gitconfig",
    ".cargo/config.toml",
    ".config/alacritty",
    ".config/kitty",
    ".config/nvim",
    ".config/pdm",
    ".config/pip",
]


def backup():
    for file in BACKUP_FILES:
        full_path = os.path.join(HOME, file.lstrip("/"))
        if not os.path.exists(full_path):
            print(f"File {full_path} does not exist, skipping")
            continue
        if os.path.isfile(full_path):
            shutil.copy2(full_path, BACKUP_DIR)
        
        elif os.path.isdir(full_path):
            shutil.copytree(
                full_path,
                os.path.join(BACKUP_DIR, file),
                dirs_exist_ok=True,
            )


if __name__ == "__main__":
    backup()
