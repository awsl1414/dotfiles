import os, shutil

HOME = os.path.expanduser("~")

EXCLUDE = [".git", ".gitignore", ".DS_Store", "restore.sh", "backup.sh", "README.md"]

file_list = os.listdir(".")

def restore():
    for flie in file_list:
        if flie in EXCLUDE:
            continue
        if os.path.isfile(flie):
            shutil.copy2(flie, HOME)
        elif os.path.isdir(flie):
            shutil.copytree(flie, HOME, dirs_exist_ok=True)
            

if __name__ == '__main__':
    restore()
