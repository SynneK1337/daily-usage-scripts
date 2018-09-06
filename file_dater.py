"""
Useful script for every photograph who want to burn his photos to DVD/BD chronologicaly when photo counter resets during session.
Requires pillow (pip install pillow).
Developed with <3 by synnek1337
"""

import os
from PIL import Image

path = input("Podaj sciezke: ")

os.chdir(path)
files = os.listdir()

index = 0
datesfiles = {}

for file in files:
    datesfiles[Image.open(file)._getexif()[0x9003].replace(
        ":", "").replace(" ", "")] = file

for date in sorted(datesfiles):
    os.rename(datesfiles[date], ("0"*(4-len(str(index)))+str(index)+".jpg"))
    index += 1
