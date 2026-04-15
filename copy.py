import os
import shutil
import glob

source_dir = r"c:\Users\Hp\Downloads\vFlat-20260310T013814Z-3-001\vFlat"
dest_dir = r"c:\Users\Hp\Downloads\vFlat-20260310T013814Z-3-001\app_files\assets\pages"

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

files = glob.glob(os.path.join(source_dir, "*.jpg"))
files.sort()

count = 0
for i, file_path in enumerate(files, start=1):
    dest_path = os.path.join(dest_dir, f"{i}.jpg")
    shutil.copy2(file_path, dest_path)
    count += 1

print(f"Copied {count} files to pages.")
