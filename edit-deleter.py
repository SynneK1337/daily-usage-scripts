# This script deletes "-Edit" from files exported from Adobe Lightroom
# Developed by synnek1337

import os

path = input("Enter the path: ")
os.chdir(path)
files = os.listdir()

for file in files:
    if "-Edit" in file:
        os.rename(file, file.replace("-Edit", ""))